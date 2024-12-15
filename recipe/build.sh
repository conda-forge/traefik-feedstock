#!/usr/bin/env bash
set -eux

# uses about 2gb
export TMPDIR="$( pwd )/tmp"
mkdir -p "${TMPDIR}"


export GOPATH="$( pwd )"
export GOFLAGS="-buildmode=pie -trimpath -mod=vendor -modcacherw -ldflags=-linkmode=external"

module='github.com/traefik/traefik'

cd "src/${module}"

go mod vendor

pushd webui
    yarn --ignore-scripts
    yarn build:nc
popd

go build \
    -v \
    -ldflags "-X ${module}/v3/pkg/version.Version=${PKG_VERSION}" \
    ./cmd/traefik

mkdir -p "${PREFIX}/bin"

cp ./cmd/traefik "${PREFIX}/bin/"

GOFLAGS="" \
    go-licenses save \
    "." \
    --save_path "${SRC_DIR}/library_licenses/"
