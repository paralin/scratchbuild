#!/usr/bin/env bash
set +x
set -eo pipefail; [[ $SCRATCH_TRACE ]] && set -x
if [ -z "$ARCH" ]; then
  ARCH=$(uname -m)
fi
if [[ $ARCH == armv* ]]; then
  ARCH=arm
fi
if [[ $ARCH == aarch* ]]; then
  ARCH=arm
fi
ARCHUPPER=$(echo "$ARCH" | awk '{print toupper($0)}')

# To save time these base images are used instead of compiling all the way down
# This is because ubuntu, for example, takes a LONG time to clone.
CREW_ARM_BASE_IMAGES=(\
  ubuntu=armbuild/ubuntu \
  alpine=armbuild/alpine \
  busybox=armbuild/busybox \
  golang=armbuild/golang \
  wordpress=armbuild/wordpress \
  fedora=armv7/armhf-fedora \
  java8=armv7/armhf-java8 \
  archlinux=armv7/armhf-archlinux \
  baseimage=armv7/armhf-baseimage \
  debian=armbuild/debian \
  gentoo=armbuild/gentoo \
)

CREW_X86_64_BASE_IMAGES=(\
  ubuntu=ubuntu \
)

crew_log_info1() {
  echo " --> $1"
}

crew_log_info2() {
  echo " ==> $1"
}

# Can specify version remaps like so:
# CREW_ARM_UBUNTU_VERSION_REMAP=( precise=12.04 )


if [ -z "$CREW_SCRATCH_TMPDIR" ]; then
  CREW_SCRATCH_TMPDIR="/tmp/crewscratch-$(date +%s)"
  if mountpoint -q /mnt/persist ; then
    CREW_SCRATCH_TMPDIR="/mnt/persist/tmp/crewscratch-$(date +%s)"
    mkdir -p $CREW_SCRATCH_TMPDIR
  fi
fi
export CREW_SCRATCH_TMPDIR

function CREW_CLEANUP_SCRATCH {
  rm -rf $CREW_SCRATCH_TMPDIR;
}

function CREW_REGISTER_SCRATCH_CLEANUP {
  trap CREW_CLEANUP_SCRATCH EXIT;
}

function CREW_REGISTER_SCRATCH_INTERRUPT {
  trap "CREW_CLEANUP_SCRATCH && echo 'Caught ctrl-c, exiting...' && exit 1" SIGINT HUP TERM INT
}

case "$1" in
  build)
    [[ -z $2 ]] && echo "Please specify an image to scratchbuild." && exit 1
    IMAGE="$2"

    # Specify default latest
    if [ -n "${IMAGE##*:*}" ]; then
      echo "${IMAGE} does not have a version specifier, using latest..."
      IMAGE="${IMAGE}:latest"
    fi

    # Separate out the version and the tag
    IMAGE_PTS=(${IMAGE//:/ })
    IMAGENAME="${IMAGE_PTS[0]}"
    IMAGENAMEUPPER=$(echo "$IMAGENAME" | awk '{print toupper($0)}')
    IMAGEVERSION="${IMAGE_PTS[1]}"

    crew_log_info2 "Scratch building ${IMAGE}...";

    # Check if image with tag already exists, if so, exit with success
    DOCKER_IMAGES_LIST=$(docker images | sed 1d | awk 'NR > 1 { print $1 ":" $2 }')
    # DOCKER_IMAGES_LIST is a list of ubuntu:latest or so
    IMAGE_EXISTS=$(echo -n "$DOCKER_IMAGES_LIST" | grep "^$IMAGE\$") || true
    if [ -n "$IMAGE_EXISTS" ]; then
      crew_log_info1 "$IMAGE exists, skipping..."
      export CREW_SUB_IMAGE="$IMAGE"
      echo $CREW_SUB_IMAGE
      exit 0
    fi

    # If the image contains a / then it is namespaced, and cannot be fetched through the official images
    if [ -z "${IMAGENAME##*/*}" ]; then
      echo "${IMAGENAME} is namespaced, not enough info to know the source for sure, or if it's compatible with ${ARCH}."
      echo "Pulling ${IMAGENAME} directly, and assuming it works on ${ARCH}. If you have exec format errors, this is why."
      docker pull ${IMAGE}
      export CREW_SUB_IMAGE="${IMAGE}"
      echo $CREW_SUB_IMAGE
      exit 0
    fi

    # Make sure ctrl c is capable of killing everything
    CREW_REGISTER_SCRATCH_INTERRUPT

    # Check to see if this is a supported pullable image
    CREW_ARCH_BASE_IMAGES_VAR=CREW_${ARCHUPPER}_BASE_IMAGES
    eval CREW_BASE_IMAGES=\( \${${CREW_ARCH_BASE_IMAGES_VAR}[@]} \)
    if [ -n "$CREW_BASE_IMAGES" ]; then
      CREW_BASE_IMAGE=
      for i in "${CREW_BASE_IMAGES[@]}"; do
        ipts=(${i//=/ })
        if [ "${ipts[0]}" == "${IMAGE_PTS[0]}" ]; then
          CREW_BASE_IMAGE="${ipts[1]}"
          break
        fi
      done
      if [ -n "$CREW_BASE_IMAGE" ]; then
        # Check for version override
        CREW_ARCH_BASE_IMAGES_VERSION_VAR="CREW_${ARCHUPPER}_${IMAGENAMEUPPER}_VERSION_REMAP[@]"
        CREW_BASE_IMAGE_VERSION="${IMAGEVERSION}"
        CREW_ARCH_BASE_IMAGES_VERSION=(${!CREW_ARCH_BASE_IMAGES_VERSION_VAR})
        if [ ${#CREW_ARCH_BASE_IMAGES_VERSION[@]} -ne 0 ]; then
          for i in "${CREW_ARCH_BASE_IMAGES_VERSION[@]}"; do
            ipts=(${i//=/ })
            if [ "${ipts[0]}" == "${IMAGEVERSION}" ]; then
              CREW_BASE_IMAGE_VERSION="${ipts[1]}"
              break
            fi
          done
        fi
        echo "${IMAGE} can be properly provided on ${ARCH} by ${CREW_BASE_IMAGE}:${CREW_BASE_IMAGE_VERSION}, pulling it..."
        export CREW_SUB_IMAGE="${CREW_BASE_IMAGE}:${CREW_BASE_IMAGE_VERSION}"
        docker pull ${CREW_SUB_IMAGE}
        echo $CREW_SUB_IMAGE
        exit 0
      fi
    fi
    # If CREW_SCRATCHSESSION not set check if a scratchbuild session is running already and wait if so
    CREW_OFFICIAL_IMAGES_PATH="${CREW_SCRATCH_TMPDIR}/official-images/"
    if [ -z "$CREW_SCRATCHSESSION" ]; then
      CREW_SCRATCHSESSION=1
      if [ -n "$CREW_IGNORE_EXISTING_SBDIR" ]; then
        rm -rf $CREW_SCRATCH_TMPDIR || true
      else
        if [ -d "$CREW_SCRATCH_TMPDIR" ]; then
          crew_log_info2 "A scratch build is already in progress, waiting...";
        fi

        until [ ! -d "$CREW_SCRATCH_TMPDIR" ]
        do
          sleep 1
        done
      fi

      # Register trap for exit to cleanup
      CREW_REGISTER_SCRATCH_CLEANUP

      # Make temp dir
      mkdir -p $CREW_SCRATCH_TMPDIR

      # Clone list of libraries
      git clone https://github.com/docker-library/official-images.git "$CREW_OFFICIAL_IMAGES_PATH"

      # Bring in any patches specified by the user
      if [ -n "$CREW_OFFICAL_IMAGE_FORKS" ]; then
        pushd $CREW_OFFICIAL_IMAGES_PATH
        idx=0
        for i in "${CREW_OFFICIAL_IMAGE_FORKS[@]}"; do
          git remote add pull-$idx $i
          git fetch pull-$idx master
          git merge --no-edit pull-$idx/master
          idx=$((idx + 1))
        done
        popd
      fi
    fi

    CREW_SCRATCH_REPO_ROOT=
    CREW_SCRATCH_REPO_BUILD_PATH=
    CREW_SCRATCH_REPO_DOCKERFILE=

    # Search for library in list of libraries
    CREW_OFFICIAL_IMAGE_PATH="$CREW_OFFICIAL_IMAGES_PATH/library/$IMAGENAME"
    if [ -f "$CREW_OFFICIAL_IMAGE_PATH" ]; then
      # Search for version in the file
      verstr=$(grep "^${IMAGEVERSION}:" $CREW_OFFICIAL_IMAGE_PATH | head -n1) || true
      if [ -z "$verstr" ]; then
        echo "${IMAGE} is an official image, but version ${IMAGEVERSION} is not supported."
        exit 1
      fi

      gitreps=$(echo "$verstr" | awk '{ print $2; }')
      gitpath=$(echo "$verstr" | awk '{ print $3; }')
      gitrep=${gitreps%%@*}
      gitver=$(echo "$gitreps" | cut -d "@" -f2)

      CREW_SCRATCH_REPO_ROOT="${CREW_SCRATCH_TMPDIR}/${IMAGENAME}-${IMAGEVERSION}"
      git clone "$gitrep" "$CREW_SCRATCH_REPO_ROOT"
      cd $CREW_SCRATCH_REPO_ROOT && git checkout $gitver && cd -
      CREW_SCRATCH_REPO_BUILD_PATH="${CREW_SCRATCH_REPO_ROOT}/${gitpath}"
      CREW_SCRATCH_REPO_DOCKERFILE="${CREW_SCRATCH_REPO_BUILD_PATH}/Dockerfile"

      # Check docker file exists
      if [ ! -f "$CREW_SCRATCH_REPO_DOCKERFILE" ]; then
        echo "Repository doesn't contain a dockerfile at ${gitpath}."
        exit 1
      fi
    else
      echo "${IMAGENAME} is not an official image, we don't have enough info to scratch build it!"
      exit 1
    fi

    # Check if it is sourced from "scratch", or sourced from a supported base image, if not, recurse call on the base library
    fromstr=$(grep "^FROM" "$CREW_SCRATCH_REPO_DOCKERFILE") || true

    if [ -z "$fromstr" ]; then
      echo "Repository dockerfile doesn't contain a FROM declaration."
      exit 1
    fi

    exec 5>&1
    CREW_BASE_IMAGE=$(echo "$fromstr" | awk '{ print $2; }')
    if [ "$CREW_BASE_IMAGE" == "scratch" ]; then
      echo "${IMAGENAME} is built from scratch, starting build here."
    else
      unset CREW_SUB_IMAGE

      # Recurse into this image
      export CREW_SCRATCHSESSION
      CREW_SUB_IMAGE=$($0 build $CREW_BASE_IMAGE | tee >(cat - >&5) | tail -n1 )

      # Explicit mode will make sure the last one was successful
      # Patch the from line with the new base
      if [ -n "$CREW_SUB_IMAGE" ]; then
        echo "Patching ${IMAGENAME} FROM declaration: ${CREW_BASE_IMAGE} -> ${CREW_SUB_IMAGE}"
        sed -i -e "s#^FROM.*\$#FROM ${CREW_SUB_IMAGE}#" $CREW_SCRATCH_REPO_DOCKERFILE
      fi
    fi

    crew_log_info1 "Starting docker build on ${IMAGE}...";
    ID=$(docker build "$CREW_SCRATCH_REPO_BUILD_PATH" | tee >(cat - >&5) | tail -n1 | grep -o '[^ ]*$')
    docker tag -f $ID $IMAGE
    echo $IMAGE

    exit 0
    ;;

  *)
    echo "build <image>, Build a Docker standard library from scratch."
    ;;

esac
