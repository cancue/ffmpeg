#!/bin/bash -x

# clean
rm -rf wasm/dist
make uninstall-data
make uninstall
make distclean
make clean

# load vars and emsdk
set -euo pipefail
source $(dirname $0)/builders/vars.sh
source $(dirname $0)/builders/emsdk.sh

# run scripts
$BUILDER_DIR/build-zlib.sh
$BUILDER_DIR/build-x264.sh
#$BUILDER_DIR/build-x265.sh
$BUILDER_DIR/build-fdk-aac.sh
$BUILDER_DIR/build-libvpx.sh
$BUILDER_DIR/build-opus.sh
$BUILDER_DIR/build-libwebp.sh

$BUILDER_DIR/build-wavpack.sh
$BUILDER_DIR/build-lame.sh
#$BUILDER_DIR/build-ogg.sh
#$BUILDER_DIR/build-vorbis.sh
#$BUILDER_DIR/build-theora.sh
$BUILDER_DIR/build-freetype2.sh
$BUILDER_DIR/build-fribidi.sh
$BUILDER_DIR/build-libpng.sh
$BUILDER_DIR/build-harfbuzz.sh
$BUILDER_DIR/build-libass.sh

# config ffmpeg
FFMPEG_FLAGS=(
  --target-os=none
  --enable-cross-compile
  --arch=x86_32
  --disable-x86asm
  --disable-inline-asm
  --disable-programs
  --disable-doc
  --enable-demuxer=mov # also mp4,m4a,3gp,3g2,mj2
  --enable-encoder=libx264,libfdk_aac
  --enable-parser=h264,aac
  --enable-muxer=mp4,hls,null
  --disable-stripping           # disable stripping
  --disable-debug               # disable debug info, required by closure
  --disable-runtime-cpudetect   # disable runtime cpu detect
  --disable-autodetect          # disable external libraries auto detect
  --enable-static
  --enable-gpl                  # required by x264
  --enable-nonfree              # required by fdk-aac
  --enable-zlib                 # enable zlib
  --enable-libx264              # enable x264
  #--enable-libx265              # enable x265
  --enable-libvpx               # enable libvpx / webm
  --enable-libmp3lame           # enable libmp3lame
  --enable-libfdk-aac           # enable libfdk-aac
  --enable-libopus              # enable opus
  --enable-libwebp              # enable libwebp
  #--enable-libtheora      # enable libtheora
  #--enable-libvorbis      # enable libvorbis
  ##--enable-libwavpack          # enable libwavpack
  --enable-libfreetype         # enable freetype
  --enable-libass              # enable libass
  --enable-libfribidi          # enable libfribidi
  #--enable-libaom              # enable libaom
  --extra-cflags="$CFLAGS"
  --extra-cxxflags="$CFLAGS"
  --extra-ldflags="$LDFLAGS -L$BUILD_DIR/lib"
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

OPTIM_FLAGS="-O3"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Use closure complier only in linux environment
  OPTIM_FLAGS="$OPTIM_FLAGS --closure 1"
fi

# build ffmpeg.wasm
mkdir -p wasm/dist
EMCC_FLAGS=(
  -I. -I./fftools -I$BUILD_DIR/include
  -Llibavcodec -Llibavdevice -Llibavfilter -Llibavformat -Llibavutil -Llibpostproc -Llibswscale -Llibswresample -Llibavresample -L$BUILD_DIR/lib
  -Wno-deprecated-declarations -Wno-pointer-sign -Wno-implicit-int-float-conversion -Wno-switch -Wno-parentheses -Qunused-arguments -Wbad-function-cast -Wcast-function-type
  -o wasm/dist/ffmpeg-core.js fftools/ffmpeg_filter.c fftools/ffmpeg_hw.c fftools/ffmpeg_mux.c fftools/ffmpeg_opt.c  fftools/cmdutils.c fftools/opt_common.c fftools/ffmpeg.c
  -lavdevice -lavfilter -lavformat -lavcodec -lswresample -lswscale -lavutil -lpostproc -lm -lx264 -lvpx -lfdk-aac -lz -lopus -lwebp -lmp3lame -lharfbuzz -lfribidi -lass -lwavpack -lpng16 -lfreetype -lworkerfs.js
  -pthread
  -s USE_PTHREADS=1                 # enable pthreads support
  -s PROXY_TO_PTHREAD=1             # detach main() from browser/UI main thread
  -s INITIAL_MEMORY=$INITIAL_MEMORY
  -s MAXIMUM_MEMORY=1073741824      # 1GB
  -s ALLOW_MEMORY_GROWTH=1
  -s USE_SDL=2                      # use SDL2
  -s INVOKE_RUN=0                   # not to run the main() in the beginning
  -s EXIT_RUNTIME=1                 # exit runtime after execution
  -s ENVIRONMENT=web,worker
  -s MODULARIZE=1                   # use modularized version to be more flexible
  -s EXPORT_NAME="createInteractor" # assign export name for browser
  -s EXPORTED_FUNCTIONS="[_main, __emscripten_proxy_main]"   # export main
  -s EXPORTED_RUNTIME_METHODS="[FS, FS_mount, FS_unmount, FS_filesystems, callMain, cwrap, ccall, setValue, writeAsciiToMemory, lengthBytesUTF8, stringToUTF8, UTF8ToString]"   # export preamble funcs
  --post-js wasm/src/post.js
  --pre-js wasm/src/pre.js
  $OPTIM_FLAGS
)

emcc "${EMCC_FLAGS[@]}"
