#!/usr/bin/env bash

set -e

if [[ "${target_platform}" == win-* ]]; then
  EXTRA_FLAGS="--enable-msvc"
else
  # Get an updated config.sub and config.guess (for mac arm and lnx aarch64)
  cp $BUILD_PREFIX/share/gnuconfig/config.* ./CoinUtils 
  cp $BUILD_PREFIX/share/gnuconfig/config.* .
fi

if [ ! -z ${LIBRARY_PREFIX+x} ]; then
    USE_PREFIX=$LIBRARY_PREFIX
else
    USE_PREFIX=$PREFIX
fi

./configure \
    --prefix="${USE_PREFIX}" \
    --exec-prefix="${USE_PREFIX}" \
    ${EXTRA_FLAGS} || cat CoinUtils/config.log

make -j "${CPU_COUNT}"

if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" ]]; then
  make test
fi

make install
