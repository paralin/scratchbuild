module github.com/paralin/scratchbuild

go 1.12

replace (
	github.com/Sirupsen/logrus => github.com/sirupsen/logrus v1.4.3-0.20190807103436-de736cf91b92
	github.com/containerd/containerd => github.com/containerd/containerd v1.3.1-0.20191114164420-d7ec45b172d9
	github.com/docker/docker => github.com/moby/moby v0.7.3-0.20190816182709-c9aee96bfd1b
	github.com/moby/buildkit => github.com/moby/buildkit v0.6.2-0.20191113225518-5c9365b6f4c2
	github.com/tonistiigi/fsutil => github.com/tonistiigi/fsutil v0.0.0-20191018213012-0f039a052ca1
)

require (
	github.com/Azure/go-ansiterm v0.0.0-20170929234023-d6e3b3328b78 // indirect
	github.com/Microsoft/hcsshim v0.8.6 // indirect
	github.com/docker-library/go-dockerlibrary v0.0.0-20190627000812-fed46530e521
	github.com/docker/cli v0.0.0-20190815010145-aa097cf1aa19
	github.com/docker/distribution v2.7.1-0.20190205005809-0d3efadf0154+incompatible
	github.com/docker/docker v1.14.0-0.20190319215453-e7b5f7dbe98c
	github.com/docker/go-connections v0.4.1-0.20190612165340-fd1b1942c4d5 // indirect
	github.com/docker/go-units v0.4.0 // indirect
	github.com/gogo/protobuf v1.2.1 // indirect
	github.com/golang/protobuf v1.3.2 // indirect
	github.com/gorilla/mux v1.7.2 // indirect
	github.com/moby/buildkit v0.6.2-0.20191113225518-5c9365b6f4c2
	github.com/opencontainers/go-digest v1.0.0-rc1.0.20190228220655-ac19fd6e7483 // indirect
	github.com/ryanuber/go-glob v1.0.0
	github.com/sirupsen/logrus v1.4.2
	github.com/urfave/cli v1.21.0
	golang.org/x/crypto v0.0.0-20190701094942-4def268fd1a4
	golang.org/x/time v0.0.0-20190308202827-9d24e82272b4 // indirect
	gopkg.in/src-d/go-git.v4 v4.13.1
	pault.ag/go/debian v0.0.0-20190530135403-b831f604d664 // indirect
)
