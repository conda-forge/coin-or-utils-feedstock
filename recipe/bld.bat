copy "%RECIPE_DIR%\build.sh" .
set PREFIX=%PREFIX:\=/%
set LIBRARY_PREFIX=%LIBRARY_PREFIX:\=/%
set SRC_DIR=%SRC_DIR:\=/%
set MSYSTEM=MINGW%ARCH%
set MSYS2_PATH_TYPE=inherit
set CHERE_INVOKING=1
set BUILD_PLATFORM=win-64


bash -lc "./build.sh"
