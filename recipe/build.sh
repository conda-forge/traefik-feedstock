#!/usr/bin/env bash
set -eux

# uses about 2gb
export TMPDIR="$( pwd )/tmp"
mkdir -p "${TMPDIR}"

export GOPATH="$( pwd )"
export GOFLAGS="-buildmode=pie -trimpath -mod=vendor -modcacherw -ldflags=-linkmode=external"

module='github.com/traefik/traefik'

cd "src/${module}"

pushd webui
    yarn --ignore-scripts
    yarn build:nc
popd

go mod vendor

go build \
    -v \
    -ldflags "-X ${module}/v3/pkg/version.Version=${PKG_VERSION}" \
    -o "${PREFIX}/bin/traefik" \
    ./cmd/traefik

GOFLAGS="" \
    go-licenses save \
    "." \
    --save_path "${SRC_DIR}/library_licenses/"
