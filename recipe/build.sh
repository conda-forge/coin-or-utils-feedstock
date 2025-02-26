#!/usr/bin/env bash

set -e

if [ ! -z ${LIBRARY_PREFIX+x} ]; then
    USE_PREFIX=$LIBRARY_PREFIX
else
    USE_PREFIX=$PREFIX
fi

if [[ "${target_platform}" == win-* ]]; then
  BLAS_LIB=( --with-blas-lib='${LIBRARY_PREFIX}/lib/mkl_intel_ilp64.lib ${LIBRARY_PREFIX}/lib/mkl_sequential.lib ${LIBRARY_PREFIX}/lib/mkl_core.lib' )
  LAPACK_LIB=(--with-lapack )
  EXTRA_FLAGS=( --enable-msvc )
else
  # Get an updated config.sub and config.guess (for mac arm and lnx aarch64)
  cp $BUILD_PREFIX/share/gnuconfig/config.* ./CoinUtils 
  cp $BUILD_PREFIX/share/gnuconfig/config.* .
  BLAS_LIB=( --with-blas-lib='-L${PREFIX}/lib -lblas' )
  LAPACK_LIB=( --with-lapack-lib='-L${PREFIX}/lib -llapack' )
  EXTRA_FLAGS=()
fi

./configure \
  --prefix="${USE_PREFIX}" \
  --exec-prefix="${USE_PREFIX}" \
  "${BLAS_LIB[@]}" \
  "${LAPACK_LIB[@]}" \
  "${EXTRA_FLAGS[@]}" || cat CoinUtils/config.log

make -j "${CPU_COUNT}"

if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" ]]; then
  make test
fi

make install
