# load emcc

if [ -z "${EMSDK_LOADED:-}" ]; then
  EMSDK_VERSION=latest
  $EMSDK/emsdk install $EMSDK_VERSION
  $EMSDK/emsdk activate $EMSDK_VERSION
  source $EMSDK/emsdk_env.sh
  emcc -v
  PATH=$(em-config LLVM_ROOT):$PATH

  export EMSDK_LOADED=1
fi