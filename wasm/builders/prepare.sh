set -euo pipefail
source $(dirname $0)/var.sh

LIBS=(
  https://github.com/ffmpegwasm/x264.git
	https://github.com/ffmpegwasm/WavPack
	https://github.com/ffmpegwasm/lame
	https://github.com/ffmpegwasm/testdata
	https://github.com/ffmpegwasm/libvpx
	https://github.com/ffmpegwasm/x265
	https://github.com/ffmpegwasm/WavPack
	https://github.com/ffmpegwasm/lame
	https://github.com/ffmpegwasm/fdk-aac
	https://github.com/ffmpegwasm/vorbis
	https://github.com/ffmpegwasm/Ogg
	https://github.com/ffmpegwasm/theora
	https://github.com/ffmpegwasm/aom
	https://github.com/ffmpegwasm/zlib
	https://github.com/ffmpegwasm/freetype2
	https://github.com/ffmpegwasm/opus
	https://github.com/ffmpegwasm/libwebp
	https://github.com/fribidi/fribidi.git
	https://github.com/harfbuzz/harfbuzz.git
	https://github.com/libass/libass.git
)

cd $ROOT_DIR/wasm/builders
git clone https://github.com/emscripten-core/emsdk.git

mkdir libs
cd libs
for remote in ${LIBS[@]}; do
  git clone $remote
done

cd $ROOT_DIR
