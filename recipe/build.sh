#!/usr/bin/env bash
set -e

if [[ "${target_platform}" == win-* ]]; then
  /bin/mkdir -p /tmp
fi

if [[ "${target_platform}" == linux-* ]]; then
    export FLIBS="-lgcc_s -lgcc -lstdc++ -lm"
fi

if [[ "${target_platform}" == osx-arm64 ]]; then
    export OSX_ARM_FLAGS="--host=arm-apple-darwin20"
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
    export CFLAGS="${CFLAGS} -O3"
    export CXXFLAGS="${CXXFLAGS} -O3"
    export CXXFLAGS="${CXXFLAGS} -std=c++11"
fi


if [[ "${target_platform}" == win-* ]]; then
    WIN_FLAGS="--build=x86_64-w64-mingw32 --enable-msvc"
fi

./configure \
    --prefix="${USE_PREFIX}" \
    --exec-prefix="${USE_PREFIX}" \
    ${WIN_FLAGS} ${OSX_ARM_FLAGS} || cat CoinUtils/config.log

make -j "${CPU_COUNT}"
make install
