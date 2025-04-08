@echo off
REM Ensure findings dir exists
if not exist findings (
    mkdir findings
)

REM Start master fuzzer (compiles harness and starts -M instance)
start "afl-master" docker run -it --rm ^
  -e AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 ^
  -v "%cd%\seeds":/seeds ^
  -v "%cd%\findings":/findings ^
  -v "%cd%":/src ^
  libmspack-fuzz bash -c "cd /src && afl-clang-fast -I/libmspack/libmspack -I/libmspack/libmspack/mspack -o fuzz_cab_open fuzz_cab_open.c /libmspack/libmspack/mspack/system.c /libmspack/libmspack/mspack/cabd.c /libmspack/libmspack/mspack/cabc.c /libmspack/libmspack/mspack/mszipd.c /libmspack/libmspack/mspack/qtmd.c /libmspack/libmspack/mspack/lzxd.c && afl-fuzz -M main -i /seeds -o /findings -- ./fuzz_cab_open @@"

REM Start secondary fuzzer 1
start "afl-secondary-1" docker run -it --rm ^
  -e AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 ^
  -v "%cd%\seeds":/seeds ^
  -v "%cd%\findings":/findings ^
  -v "%cd%":/src ^
  libmspack-fuzz bash -c "cd /src && afl-fuzz -S fuzzer1 -i /seeds -o /findings -- ./fuzz_cab_open @@"

REM Start secondary fuzzer 2
start "afl-secondary-2" docker run -it --rm ^
  -e AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 ^
  -v "%cd%\seeds":/seeds ^
  -v "%cd%\findings":/findings ^
  -v "%cd%":/src ^
  libmspack-fuzz bash -c "cd /src && afl-fuzz -S fuzzer2 -i /seeds -o /findings -- ./fuzz_cab_open @@"
