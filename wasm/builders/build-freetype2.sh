#!/bin/bash

echo \# freetype
set -euo pipefail
source $(dirname $0)/common.sh

LIB_PATH=wasm/builders/libs/freetype2
CONF_FLAGS=(
  --prefix=$BUILD_DIR                                 # install library in a build directory for FFmpeg to include
  --host=x86_64-gnu                                   # use i686 linux
  --enable-shared=no                                  # not to build shared library
  --without-harfbuzz
)
echo "CONF_FLAGS=${CONF_FLAGS[@]}"
(cd $LIB_PATH && \
  emconfigure ./autogen.sh && \
  emconfigure ./configure "${CONF_FLAGS[@]}")
emmake make -C $LIB_PATH clean
# build apinames manually to prevent it built by emcc
gcc -o wasm/builders/libs/freetype2/objs/apinames wasm/builders/libs/freetype2/src/tools/apinames.c
emmake make -C $LIB_PATH install -j
