#!/bin/bash

set -euo pipefail
source $(dirname $0)/var.sh

FLAGS=(
  "${FFMPEG_CONFIG_FLAGS_BASE[@]}"
  --enable-static
  --enable-gpl            # required by x264
  --enable-nonfree        # required by fdk-aac
  --enable-zlib           # enable zlib
  --enable-libx264        # enable x264
  # --enable-libx265        # enable x265
  --enable-libvpx         # enable libvpx / webm
  # --enable-libwavpack     # enable libwavpack
  --enable-libmp3lame     # enable libmp3lame
  --enable-libfdk-aac     # enable libfdk-aac
  # --enable-libtheora      # enable libtheora
  # --enable-librbis      # enable libvorbis
  # --enable-libfreetype    # enable freetype
  --enable-libopus        # enable opus
  --enable-libwebp        # enable libwebp
  # --enable-libass         # enable libass
  # --enable-libfribidi     # enable libfribidi
  # --enable-libaom         # enable libaom
  ###--enable-demuxer=mov # also mp4,m4a,3gp,3g2,mj2
  ####--enable-decoder=h264,libfdk_aac
  ###--enable-encoder=libx264,libfdk_aac
  ####--enable-parser=h264,aac
  ###--enable-muxer=mp4
  ###--enable-filter=buffersink,scale,format,fps
  ###--enable-filter=abuffersink,aformat
  ###--enable-filter=abuffer
  ###--enable-filter=amix,aresample
)
echo "FFMPEG_CONFIG_FLAGS=${FLAGS[@]}"
emconfigure $ROOT_DIR/configure "${FLAGS[@]}"
