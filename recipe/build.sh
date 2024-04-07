#!/usr/bin/env bash

set -e

if [[ "${target_platform}" == win-* ]]; then
  EXTRA_FLAGS="--enable-msvc"
else
  # Get an updated config.sub and config.guess (for mac arm and lnx aarch64)
  cp $BUILD_PREFIX/share/gnuconfig/config.* ./CoinUtils 
  cp $BUILD_PREFIX/share/gnuconfig/config.* .
  export CXXFLAGS="${CXXFLAGS} -std=c++11" # macOS clang defaults to cxx17 but coinutils 2.11.10 still has register kws
fi

if [[ "${target_platform}" == linux-* ]]; then
    export FLIBS="-lgcc_s -lgcc -lstdc++ -lm"
fi

# Use only 1 thread with OpenBLAS to avoid timeouts on CIs.
# This should have no other affect on the build. A user
# should still be able to set this (or not) to a different
# value at run-time to get the expected amount of parallelism.
export OPENBLAS_NUM_THREADS=1

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
