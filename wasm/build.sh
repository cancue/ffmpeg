#!/bin/bash -x

# clean
rm -rf wasm/dist
make uninstall-data
make uninstall
make distclean
make clean

# load vars
set -euo pipefail
source $(dirname $0)/builders/var.sh

# load emcc
# -s EXPORTED_FUNCTIONS="[_main, _proxy_main]"   # export main and proxy_main funcs
EMSDK_VERSION=latest
$EMSDK/emsdk install $EMSDK_VERSION
$EMSDK/emsdk activate $EMSDK_VERSION
source $EMSDK/emsdk_env.sh
emcc -v
PATH=$(em-config LLVM_ROOT):$PATH

# run scripts
$BUILDER_DIR/build-zlib.sh
$BUILDER_DIR/build-x264.sh
$BUILDER_DIR/build-fdk-aac.sh
$BUILDER_DIR/build-libvpx.sh
# $BUILDER_DIR/build-lame.sh
$BUILDER_DIR/build-opus.sh
$BUILDER_DIR/build-libwebp.sh

# config ffmpeg
FFMPEG_FLAGS=(
  --target-os=none
  --enable-cross-compile
  --arch=x86_32
  --disable-x86asm
  --disable-inline-asm
  --disable-programs
  --disable-doc
  #--disable-stripping           # disable stripping
  --disable-debug               # disable debug info, required by closure
  --disable-runtime-cpudetect   # disable runtime cpu detect
  --disable-autodetect          # disable external libraries auto detect
  --enable-static
  --enable-gpl                  # required by x264
  --enable-nonfree              # required by fdk-aac
  --enable-zlib                 # enable zlib
  --enable-libx264              # enable x264
  --enable-libvpx               # enable libvpx / webm
  # --enable-libmp3lame           # enable libmp3lame
  --enable-libfdk-aac           # enable libfdk-aac
  --enable-libopus              # enable opus
  --enable-libwebp              # enable libwebp
  --extra-cflags="$CFLAGS"
  --extra-cxxflags="$CFLAGS"
  --extra-ldflags="$LDFLAGS"
  --pkg-config-flags="--static"
  --nm="llvm-nm"
  --ar=emar
  --ranlib=emranlib
  --cc=emcc
  --cxx=em++
  --objcc=emcc
  --dep-cc=emcc
)
emconfigure ./configure "${FFMPEG_FLAGS[@]}"
emmake make -j8

# build ffmpeg.wasm
mkdir -p wasm/dist
EMCC_FLAGS=(
  -I. -I./fftools
  -Llibavcodec -Llibavdevice -Llibavfilter -Llibavformat -Llibavutil -Llibpostproc -Llibswscale -Llibswresample -Llibavresample -L$BUILD_DIR/lib
  -Qunused-arguments
  -o wasm/dist/ffmpeg-core.js fftools/ffmpeg_filter.c fftools/ffmpeg_hw.c fftools/ffmpeg_mux.c fftools/ffmpeg_opt.c  fftools/cmdutils.c fftools/opt_common.c fftools/ffmpeg.c
  -lavdevice -lavfilter -lavformat -lavcodec -lswresample -lswscale -lavutil -lpostproc -lm -lx264 -lvpx -lfdk-aac -lz -lopus -lwebp
  -O3
  -s USE_SDL=2                      # use SDL2
  -s USE_PTHREADS=1                 # enable pthreads support
  -s PROXY_TO_PTHREAD=1             # detach main() from browser/UI main thread
  -s INVOKE_RUN=0                   # not to run the main() in the beginning
  -s INITIAL_MEMORY=33554432        # 33554432 bytes = 32 MB
  -s ENVIRONMENT=web,worker
  -s EXIT_RUNTIME=1                 # exit runtime after execution
  -s MODULARIZE=1                   # use modularized version to be more flexible
  -s EXPORT_NAME="NewCore"          # assign export name for browser
  -s EXPORTED_FUNCTIONS="[_main]"   # export main
  -s EXPORTED_RUNTIME_METHODS="[FS, callMain, cwrap, ccall, _malloc, setValue, writeAsciiToMemory, lengthBytesUTF8, stringToUTF8, UTF8ToString]"   # export preamble funcs
  --post-js wasm/src/post.js
  --pre-js wasm/src/pre.js
)

emcc "${EMCC_FLAGS[@]}"

