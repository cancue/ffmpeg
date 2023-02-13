if [ $EMSDK_LOADED != 1 ]; then
  echo 0
  export EMSDK_LOADED=1
else
  echo 1
fi
