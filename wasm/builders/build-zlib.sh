#!/bin/bash

echo \# zlib
set -euo pipefail
source $(dirname $0)/common.sh

LIB_PATH=wasm/builders/libs/zlib
CM_FLAGS=(
  -DCMAKE_INSTALL_PREFIX=$BUILD_DIR
  -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_FILE
  -DBUILD_SHARED_LIBS=OFF
  -DSKIP_INSTALL_FILES=ON
)
echo "CM_FLAGS=${CM_FLAGS[@]}"

cd $LIB_PATH
rm -rf build zconf.h
mkdir -p build
cd build
emcmake cmake .. -DCMAKE_C_FLAGS="$CXXFLAGS" ${CM_FLAGS[@]}
make clean
make all
cd $ROOT_DIR
