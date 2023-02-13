#!/bin/bash

echo \# libpng
set -euo pipefail
source $(dirname $0)/common.sh

LIB_PATH=wasm/builders/libs/libpng
CXXFLAGS=$CFLAGS
CONF_FLAGS=(
  --prefix=$BUILD_DIR                                 # install library in a build directory for FFmpeg to include
  --host=i686-gnu                                     # use i686 linux
  --enable-shared=no                                  # not to build shared library
  --enable-static
)
echo "CONF_FLAGS=${CONF_FLAGS[@]}"
(cd $LIB_PATH && \
  emconfigure ./configure "${CONF_FLAGS[@]}")
emmake make -C $LIB_PATH clean
emmake make -C $LIB_PATH install -j

