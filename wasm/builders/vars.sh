#!/bin/bash

set -euo pipefail

export ROOT_DIR=$PWD
export BUILD_DIR=$ROOT_DIR/build
export BUILDER_DIR=$ROOT_DIR/wasm/builders
export EMSDK=$BUILDER_DIR/emsdk
export PKG_CONFIG_PATH=$BUILD_DIR/lib/pkgconfig
export FFMPEG_ST=no
export INITIAL_MEMORY=33554432

export TOOLCHAIN_FILE=$EMSDK/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake
export EM_PKG_CONFIG_PATH=$BUILD_DIR/lib/pkgconfig
export PATH=$PATH:$EMSDK/upstream/bin
export CFLAGS="-O3 -I$BUILD_DIR/include -s USE_PTHREADS=1 -s USE_ZLIB=1"
export CXXFLAGS=$CFLAGS
export LDFLAGS="$CFLAGS -s INITIAL_MEMORY=$INITIAL_MEMORY" # 33554432 bytes = 32 MB
