#!/bin/bash

echo \# fdk-aac
set -euo pipefail
source $(dirname $0)/common.sh

LIB_PATH=wasm/builders/libs/fdk-aac
CONF_FLAGS=(
  --prefix=$BUILD_DIR                                 # install library in a build directory for FFmpeg to include
  --host=x86_64-linux
  --disable-shared                                    # disable shared library
  --disable-dependency-tracking                       # speedup one-time build
)
echo "CONF_FLAGS=${CONF_FLAGS[@]}"
(cd $LIB_PATH && \
  emconfigure ./autogen.sh && \
  CFLAGS=$CFLAGS emconfigure ./configure "${CONF_FLAGS[@]}")
emmake make -C $LIB_PATH clean
emmake make -C $LIB_PATH install -j
