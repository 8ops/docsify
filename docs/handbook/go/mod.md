# mod

## env

```bash
$ go env
GO111MODULE="on"
GOARCH="amd64"
GOBIN=""
GOCACHE="/Users/jesse/Library/Caches/go-build"
GOENV="/Users/jesse/Library/Application Support/go/env"
GOEXE=""
GOFLAGS=""
GOHOSTARCH="amd64"
GOHOSTOS="darwin"
GOINSECURE=""
GONOPROXY="*.domain.cn"
GONOSUMDB="*.domain.cn"
GOOS="darwin"
GOPATH="~/workspace/"
GOPRIVATE="*.domain.cn"
GOPROXY="https://goproxy.io"
GOROOT="/usr/local/go"
GOSUMDB="sum.golang.org"
GOTMPDIR=""
GOTOOLDIR="/usr/local/go/pkg/tool/darwin_amd64"
GCCGO="gccgo"
AR="ar"
CC="clang"
CXX="clang++"
CGO_ENABLED="1"
GOMOD="/dev/null"
CGO_CFLAGS="-g -O2"
CGO_CPPFLAGS=""
CGO_CXXFLAGS="-g -O2"
CGO_FFLAGS="-g -O2"
CGO_LDFLAGS="-g -O2"
PKG_CONFIG="pkg-config"
GOGCCFLAGS="-fPIC -m64 -pthread -fno-caret-diagnostics -Qunused-arguments -fmessage-length=0 -fdebug-prefix-map=/var/folders/j5/75qwps5s5y7ffk67y1hhxj0h0000gp/T/go-build222936204=/tmp/go-build -gno-record-gcc-switches -fno-common"
```

## mod

```bash
$ go mod
Go mod provides access to operations on modules.

Note that support for modules is built into all the go commands,
not just 'go mod'. For example, day-to-day adding, removing, upgrading,
and downgrading of dependencies should be done using 'go get'.
See 'go help modules' for an overview of module functionality.

Usage:

	go mod <command> [arguments]

The commands are:

	download    download modules to local cache
	edit        edit go.mod from tools or scripts
	graph       print module requirement graph
	init        initialize new module in current directory
	tidy        add missing and remove unused modules
	vendor      make vendored copy of dependencies
	verify      verify dependencies have expected content
	why         explain why packages or modules are needed

Use "go help mod <command>" for more information about a command.

```

常用操作

```bash
go get package
go get -u packagego 
go get -u=patch package
go get package@version
go mod tidy
go mod edit -replace=old[@v]=new[@v]
```

GO111MODULE在`1.11`版本后默认启动

vendor开始弱化

```bash
$ cat go.mod
module sample

go 1.12

require (
	gonum.org/v1/netlib v0.0.0-20200229103305-d71f404090bf // indirect
	gonum.org/v1/plot v0.7.0
	k8s.io/klog v0.3.2
)
```

```bash
$ cat go.sum
k8s.io/klog v0.3.2 h1:qvP/U6CcZ6qyi/qSHlJKdlAboCzo3mT0DAm0XAarpz4=
k8s.io/klog v0.3.2/go.mod h1:Gq+BEi5rUBO/HRz0bTSXDUcqjScdoY3a9IHpCEIOOfk=s
```

