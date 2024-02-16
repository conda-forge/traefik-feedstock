#!/usr/bin/env bash
set -eux

# uses about 2gb
export TMPDIR="$( pwd )/tmp"
mkdir -p "${TMPDIR}"


export GOPATH="$( pwd )"
export GOFLAGS="-buildmode=pie -trimpath -mod=vendor -modcacherw -ldflags=-linkmode=external"
# consumed by `scripts/binary` below to avoid wrangling versioned flags
export VERSION="${PKG_VERSION}"
export DATE="$(date -u '+%Y-%m-%d_%I:%M:%S%p')"

module='github.com/traefik/traefik'

cd "src/${module}"

go mod vendor

make binary

mkdir -p "${PREFIX}/bin"

find dist
# exactly one should end up as dist/(darwin|linux|windows)/(amd64|arm64)/traefik
cp $(ls dist/*/*/*) "${PREFIX}/bin/traefik${target_goexe}"

GOFLAGS="" go-licenses save \
    "." \
    --save_path "${SRC_DIR}/library_licenses/"
