module github.com/paralin/scratchbuild

go 1.12

replace github.com/docker/docker => github.com/moby/moby v0.7.3-0.20190816182709-c9aee96bfd1b

replace github.com/Sirupsen/logrus => github.com/sirupsen/logrus v1.4.3-0.20190807103436-de736cf91b92

require (
	github.com/Azure/azure-sdk-for-go v16.2.1+incompatible // indirect
	github.com/Azure/go-ansiterm v0.0.0-20170929234023-d6e3b3328b78 // indirect
	github.com/Azure/go-autorest v10.8.1+incompatible // indirect
	github.com/Microsoft/go-winio v0.4.14 // indirect
	github.com/Microsoft/hcsshim v0.8.6 // indirect
	github.com/Shopify/logrus-bugsnag v0.0.0-20171204204709-577dee27f20d // indirect
	github.com/Sirupsen/logrus v0.0.0-00010101000000-000000000000 // indirect
	github.com/aws/aws-sdk-go v1.15.11 // indirect
	github.com/bitly/go-simplejson v0.5.0 // indirect
	github.com/bmizerany/assert v0.0.0-20160611221934-b7ed37b82869 // indirect
	github.com/bshuster-repo/logrus-logstash-hook v0.4.1 // indirect
	github.com/bugsnag/bugsnag-go v0.0.0-20141110184014-b1d153021fcd // indirect
	github.com/bugsnag/osext v0.0.0-20130617224835-0dd3f918b21b // indirect
	github.com/bugsnag/panicwrap v0.0.0-20151223152923-e2c28503fcd0 // indirect
	github.com/containerd/continuity v0.0.0-20190815185530-f2a389ac0a02 // indirect
	github.com/containerd/fifo v0.0.0-20190816180239-bda0ff6ed73c // indirect
	github.com/coreos/etcd v3.3.13+incompatible // indirect
	github.com/denverdino/aliyungo v0.0.0-20190125010748-a747050bb1ba // indirect
	github.com/dgrijalva/jwt-go v0.0.0-20170104182250-a601269ab70c // indirect
	github.com/dnaeon/go-vcr v1.0.1 // indirect
	github.com/docker-library/go-dockerlibrary v0.0.0-20190627000812-fed46530e521
	github.com/docker/cli v0.0.0-20190815010145-aa097cf1aa19
	github.com/docker/distribution v2.7.1-0.20190205005809-0d3efadf0154+incompatible
	github.com/docker/docker v1.14.0-0.20190319215453-e7b5f7dbe98c
	github.com/docker/go-connections v0.4.1-0.20190612165340-fd1b1942c4d5 // indirect
	github.com/docker/go-metrics v0.0.0-20181218153428-b84716841b82 // indirect
	github.com/docker/go-units v0.4.0 // indirect
	github.com/docker/libtrust v0.0.0-20160708172513-aabc10ec26b7 // indirect
	github.com/docker/swarmkit v1.12.1-0.20190726162629-f1fb59c9e831 // indirect
	github.com/garyburd/redigo v0.0.0-20150301180006-535138d7bcd7 // indirect
	github.com/gogo/protobuf v1.2.1 // indirect
	github.com/google/uuid v1.1.1 // indirect
	github.com/gorilla/handlers v0.0.0-20150720190736-60c7bfde3e33 // indirect
	github.com/gorilla/mux v1.7.2 // indirect
	github.com/hashicorp/go-memdb v1.0.3 // indirect
	github.com/inconshreveable/mousetrap v1.0.0 // indirect
	github.com/jmespath/go-jmespath v0.0.0-20160803190731-bd40a432e4c7 // indirect
	github.com/marstr/guid v1.1.0 // indirect
	github.com/mattn/go-shellwords v1.0.6 // indirect
	github.com/mitchellh/mapstructure v1.1.2 // indirect
	github.com/mitchellh/osext v0.0.0-20151018003038-5e2d6d41470f // indirect
	github.com/moby/buildkit v0.6.1
	github.com/ncw/swift v1.0.47 // indirect
	github.com/opencontainers/go-digest v1.0.0-rc1.0.20190228220655-ac19fd6e7483 // indirect
	github.com/opencontainers/runtime-spec v1.0.1 // indirect
	github.com/opencontainers/selinux v1.3.0 // indirect
	github.com/prometheus/client_golang v1.1.1-0.20190813114604-4efc3ccc7a66 // indirect
	github.com/prometheus/client_model v0.0.0-20190812154241-14fe0d1b01d4 // indirect
	github.com/prometheus/common v0.6.1-0.20190730175846-637d7c34db12 // indirect
	github.com/prometheus/procfs v0.0.4-0.20190815142708-6df11039f8de // indirect
	github.com/ryanuber/go-glob v1.0.0
	github.com/satori/go.uuid v1.2.0 // indirect
	github.com/sirupsen/logrus v1.4.2
	github.com/smartystreets/goconvey v0.0.0-20190330032615-68dc04aab96a // indirect
	github.com/spf13/cobra v0.0.3 // indirect
	github.com/spf13/pflag v1.0.3 // indirect
	github.com/tonistiigi/fsutil v0.0.0-20190403235420-524c23dab726 // indirect
	github.com/urfave/cli v1.21.0
	github.com/vbatts/tar-split v0.11.1 // indirect
	github.com/yvasiyarov/go-metrics v0.0.0-20140926110328-57bccd1ccd43 // indirect
	github.com/yvasiyarov/gorelic v0.0.0-20141212073537-a9bba5b9ab50 // indirect
	github.com/yvasiyarov/newrelic_platform_go v0.0.0-20140908184405-b21fdbd4370f // indirect
	go.etcd.io/bbolt v1.3.3 // indirect
	golang.org/x/crypto v0.0.0-20190701094942-4def268fd1a4
	golang.org/x/oauth2 v0.0.0-20190604053449-0f29369cfe45 // indirect
	golang.org/x/time v0.0.0-20190308202827-9d24e82272b4 // indirect
	google.golang.org/api v0.0.0-20160322025152-9bf6e6e569ff // indirect
	google.golang.org/cloud v0.0.0-20151119220103-975617b05ea8 // indirect
	google.golang.org/grpc v1.23.0 // indirect
	gopkg.in/src-d/go-git.v4 v4.13.1
	pault.ag/go/debian v0.0.0-20190530135403-b831f604d664 // indirect
)
