@echo on

bash ./configure ^
    --prefix="%LIBRARY_PREFIX%" ^
    --exec-prefix="%LIBRARY_PREFIX%" ^
    --with-blas-lib="%LIBRARY_PREFIX%\lib\cblas.lib" ^
    --with-lapack-lib="%LIBRARY_PREFIX%\lib\lapack.lib" ^
    --enable-msvc || cat CoinUtils/config.log
if %ERRORLEVEL% neq 0 exit 1

make -j "${CPU_COUNT}"
if %ERRORLEVEL% neq 0 exit 1

make test
if %ERRORLEVEL% neq 0 exit 1

make install
if %ERRORLEVEL% neq 0 exit 1
