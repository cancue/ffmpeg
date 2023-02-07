#!/bin/bash -x

#clean
rm -rf wasm
make uninstall-data
make uninstall
make distclean
make clean

#load emcc
~/Developer/wasm/emsdk/emsdk install latest
~/Developer/wasm/emsdk/emsdk activate latest
source ~/Developer/wasm/emsdk/emsdk_env.sh
emcc -v
PATH=$(em-config LLVM_ROOT):$PATH

CFLAGS="-s USE_PTHREADS"
LDFLAGS="$CFLAGS -s INITIAL_MEMORY=33554432" # 33554432 bytes = 32 MB
FFMPEG_FLAGS=(
  --target-os=none
  --enable-cross-compile
  --arch=x86_32
  --disable-x86asm
  --disable-inline-asm
  --disable-programs
  --disable-doc
  --extra-cflags="$CFLAGS"
  --extra-cxxflags="$CFLAGS"
  --extra-ldflags="$LDFLAGS"
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
  -Llibavcodec -Llibavdevice -Llibavfilter -Llibavformat -Llibavutil -Llibpostproc -Llibswscale -Llibswresample
  -Qunused-arguments
  -o wasm/dist/ffmpeg-core.js fftools/ffmpeg_filter.c fftools/ffmpeg_hw.c fftools/ffmpeg_mux.c fftools/ffmpeg_opt.c  fftools/cmdutils.c fftools/opt_common.c fftools/ffmpeg.c
  -lavdevice -lavfilter -lavformat -lavcodec -lswresample -lswscale -lavutil -lm
  -O3
  -s USE_SDL=2                                                            # use SDL2
  -s USE_PTHREADS=1                                                       # enable pthreads support
  -s PROXY_TO_PTHREAD=1                                                  # detach main() from browser/UI main thread
  -s EXPORTED_FUNCTIONS="[_main]"                            # export main and proxy_main funcs
  -s EXPORTED_RUNTIME_METHODS="[FS, cwrap, setValue, writeAsciiToMemory]" # export preamble funcs
  -s INITIAL_MEMORY=33554432                                              # 33554432 bytes = 32 MB
  -s INVOKE_RUN=0                                                         # not to run the main() in the beginning
  -s INITIAL_MEMORY=33554432                                              # 33554432 bytes = 32 MB
  -s ENVIRONMENT=web,worker
)

emcc "${EMCC_FLAGS[@]}"

#emcc \
#  -Llibavcodec -Llibavdevice -Llibavfilter -Llibavformat -Llibavutil -Llibpostproc -Llibswscale -Llibswresample \
#  -s USE_PTHREADS \
#  -s INITIAL_MEMORY=33554432 \
#  -Wl,-z,noexecstack -Wl,-rpath-link=:libpostproc:libswresample:libswscale:libavfilter:libavdevice:libavformat:libavcodec:libavutil
#  -Qunused-arguments \
#  -o ffmpeg_g fftools/ffmpeg_filter.o fftools/ffmpeg_hw.o fftools/ffmpeg_mux.o fftools/ffmpeg_opt.o  fftools/cmdutils.o fftools/opt_common.o fftools/ffmpeg.o \
#  -lavdevice -lavfilter -lavformat -lavcodec -lswresample -lswscale -lavutil -lm \
#  -sUSE_SDL=2 -pthread -lm -lm -pthread -lm -lm -lm -pthread -lm -lX11

#printf "LD\t%s\n" ffmpeg_g; emcc -Llibavcodec -Llibavdevice -Llibavfilter -Llibavformat -Llibavutil -Llibpostproc -Llibswscale -Llibswresample -s USE_PTHREADS -s INITIAL_MEMORY=33554432  -Wl,-z,noexecstack -Wl,-rpath-link=:libpostproc:libswresample:libswscale:libavfilter:libavdevice:libavformat:libavcodec:libavutil -Qunused-arguments   -o ffmpeg_g fftools/ffmpeg_filter.o fftools/ffmpeg_hw.o fftools/ffmpeg_mux.o fftools/ffmpeg_opt.o  fftools/cmdutils.o fftools/opt_common.o fftools/ffmpeg.o  -lavdevice -lavfilter -lavformat -lavcodec -lswresample -lswscale -lavutil  -lm -sUSE_SDL=2 -pthread -lm -lm -pthread -lm -lm -lm -pthread -lm -lX11
#printf "STRIP\t%s\n" ffmpeg; strip -o ffmpeg ffmpeg_g
#printf "CC\t%s\n" fftools/ffplay.o; emcc -I. -I./ -D_ISOC99_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_POSIX_C_SOURCE=200112 -D_XOPEN_SOURCE=600 -s USE_PTHREADS -std=c11 -fomit-frame-pointer -pthread -g -Wdeclaration-after-statement -Wall -Wdisabled-optimization -Wpointer-arith -Wredundant-decls -Wwrite-strings -Wtype-limits -Wundef -Wmissing-prototypes -Wstrict-prototypes -Wempty-body -Wno-parentheses -Wno-switch -Wno-format-zero-length -Wno-pointer-sign -Wno-unused-const-variable -Wno-bool-operation -Wno-char-subscripts -O3 -fno-math-errno -fno-signed-zeros -mstack-alignment=16 -Qunused-arguments -Werror=implicit-function-declaration -Werror=missing-prototypes -Werror=return-type -sUSE_SDL=2  -sUSE_SDL=2  -MMD -MF fftools/ffplay.d -MT fftools/ffplay.o -c -o fftools/ffplay.o fftools/ffplay.c
#printf "LD\t%s\n" ffplay_g; emcc -Llibavcodec -Llibavdevice -Llibavfilter -Llibavformat -Llibavutil -Llibpostproc -Llibswscale -Llibswresample -s USE_PTHREADS -s INITIAL_MEMORY=33554432  -Wl,-z,noexecstack -Wl,-rpath-link=:libpostproc:libswresample:libswscale:libavfilter:libavdevice:libavformat:libavcodec:libavutil -Qunused-arguments   -o ffplay_g fftools/cmdutils.o fftools/opt_common.o fftools/ffplay.o  -lavdevice -lavfilter -lavformat -lavcodec -lswresample -lswscale -lavutil  -lm -sUSE_SDL=2 -pthread -lm -lm -pthread -lm -lm -lm -pthread -lm -lX11  -sUSE_SDL=2
#printf "STRIP\t%s\n" ffplay; strip -o ffplay ffplay_g
#printf "CC\t%s\n" fftools/ffprobe.o; emcc -I. -I./ -D_ISOC99_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_POSIX_C_SOURCE=200112 -D_XOPEN_SOURCE=600 -s USE_PTHREADS -std=c11 -fomit-frame-pointer -pthread -g -Wdeclaration-after-statement -Wall -Wdisabled-optimization -Wpointer-arith -Wredundant-decls -Wwrite-strings -Wtype-limits -Wundef -Wmissing-prototypes -Wstrict-prototypes -Wempty-body -Wno-parentheses -Wno-switch -Wno-format-zero-length -Wno-pointer-sign -Wno-unused-const-variable -Wno-bool-operation -Wno-char-subscripts -O3 -fno-math-errno -fno-signed-zeros -mstack-alignment=16 -Qunused-arguments -Werror=implicit-function-declaration -Werror=missing-prototypes -Werror=return-type -sUSE_SDL=2    -MMD -MF fftools/ffprobe.d -MT fftools/ffprobe.o -c -o fftools/ffprobe.o fftools/ffprobe.c
#printf "LD\t%s\n" ffprobe_g; emcc -Llibavcodec -Llibavdevice -Llibavfilter -Llibavformat -Llibavutil -Llibpostproc -Llibswscale -Llibswresample -s USE_PTHREADS -s INITIAL_MEMORY=33554432  -Wl,-z,noexecstack -Wl,-rpath-link=:libpostproc:libswresample:libswscale:libavfilter:libavdevice:libavformat:libavcodec:libavutil -Qunused-arguments   -o ffprobe_g fftools/cmdutils.o fftools/opt_common.o fftools/ffprobe.o  -lavdevice -lavfilter -lavformat -lavcodec -lswresample -lswscale -lavutil  -lm -sUSE_SDL=2 -pthread -lm -lm -pthread -lm -lm -lm -pthread -lm -lX11
#printf "STRIP\t%s\n" ffprobe; strip -o ffprobe ffprobe_g
