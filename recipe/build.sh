#!/usr/bin/env bash

set -e

if [ ! -z ${LIBRARY_PREFIX+x} ]; then
    USE_PREFIX=$LIBRARY_PREFIX
else
    USE_PREFIX=$PREFIX
fi

if [[ "${target_platform}" == win-* ]]; then
  BLAS_LIB="${LIBRARY_PREFIX}/lib/mkl_intel_ilp64.lib ${LIBRARY_PREFIX}/lib/mkl_sequential.lib ${LIBRARY_PREFIX}/lib/mkl_core.lib"
  #LAPACK_LIB = The MKL libraries contain both Blas and Lapack
  EXTRA_FLAGS=( --enable-msvc --with-blas-lib="${BLAS_LIB}" --with-lapack=yes )
else
  # Get an updated config.sub and config.guess (for mac arm and lnx aarch64)
  cp $BUILD_PREFIX/share/gnuconfig/config.* ./CoinUtils 
  cp $BUILD_PREFIX/share/gnuconfig/config.* .
  BLAS_LIB="-L${PREFIX}/lib -lblas"
  LAPACK_LIB="-L${PREFIX}/lib -llapack"
  EXTRA_FLAGS=( --with-blas-lib="${BLAS_LIB}" --with-lapack-lib="${LAPACK_LIB}" )
fi

./configure \
  --prefix="${USE_PREFIX}" \
  --exec-prefix="${USE_PREFIX}" \
  ${EXTRA_FLAGS[@]} || cat CoinUtils/config.log

make -j "${CPU_COUNT}"

if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" ]]; then
  make test
fi

make install
