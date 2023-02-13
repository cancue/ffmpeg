set -euo pipefail
source $(dirname $0)/var.sh

# deps
cmds=()

# Detect what dependencies are missing.
for cmd in autoconf automake libtool pkg-config ragel
do
  if ! command -v $cmd &> /dev/null
  then
    cmds+=("$cmd")
  fi
done

# Install missing dependencies
if [ ${#cmds[@]} -ne 0 ];
then
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    apt-get update
    apt-get install -y ${cmds[@]}
  else
    brew install ${cmds[@]}
  fi
fi

# libs
LIBS=(
  https://github.com/ffmpegwasm/x264.git
	https://github.com/ffmpegwasm/WavPack
	https://github.com/ffmpegwasm/lame # replace 3.100 to 3.99.99
	https://github.com/ffmpegwasm/testdata
	https://github.com/ffmpegwasm/libvpx
	https://github.com/ffmpegwasm/x265
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
