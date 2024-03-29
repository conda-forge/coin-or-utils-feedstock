#!/usr/bin/env bash
set -e

# for win
if [[ "${target_platform}" == win-* ]]; then
  /bin/mkdir -p /tmp
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
    WITH_BLAS_LIB="${LIBRARY_PREFIX}\lib\cblas.lib"
    WITH_LAPACK_LIB="${LIBRARY_PREFIX}\lib\lapack.lib"
else
    USE_PREFIX=$PREFIX
    WITH_BLAS_LIB="-L${PREFIX}/lib -lblas"
    WITH_LAPACK_LIB="-L${PREFIX}/lib -llapack"
    export CFLAGS="${CFLAGS} -O3"
    export CXXFLAGS="${CXXFLAGS} -O3"
    export CXXFLAGS="${CXXFLAGS//-std=c++17/-std=c++11}"
fi


if [[ "${target_platform}" == win-* ]]; then
    WIN_FLAGS="--build=x86_64-w64-mingw32 --enable-msvc"
fi

./configure \
    --prefix="${USE_PREFIX}" \
    --exec-prefix="${USE_PREFIX}" \
    --with-blas="${WITH_BLAS_LIB}" \
    --with-lapack="${WITH_LAPACK_LIB}" \
    ${WIN_FLAGS}

make -j "${CPU_COUNT}"
make install
