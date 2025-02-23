#!/usr/bin/env bash
set -ex

# Get an updated config.sub and config.guess (for mac arm and linux aarch64)
cp $BUILD_PREFIX/share/gnuconfig/config.* ./CoinUtils
cp $BUILD_PREFIX/share/gnuconfig/config.* .

./configure \
  --prefix="${PREFIX}" \
  --exec-prefix="${PREFIX}" \
  --with-blas-lib="-L${PREFIX}/lib -lblas" \
  --with-lapack-lib="-L${PREFIX}/lib -llapack" \
  || cat CoinUtils/config.log

make -j "${CPU_COUNT}"

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  make test
fi

make install
