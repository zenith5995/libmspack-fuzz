@echo off
REM Build Docker image
docker build -t libmspack-fuzz .

REM Ensure findings directory exists
if not exist findings (
    mkdir findings
)

REM Run AFL++ with environment fix for core_pattern
docker run -it --rm ^
  -e AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 ^
  -v "%cd%\seeds":/seeds ^
  -v "%cd%\findings":/findings ^
  -v "%cd%":/src ^
  libmspack-fuzz bash -c "cd /src && afl-clang-fast -I/libmspack/libmspack -I/libmspack/libmspack/mspack -o fuzz_cab_open fuzz_cab_open.c /libmspack/libmspack/mspack/system.c /libmspack/libmspack/mspack/cabd.c /libmspack/libmspack/mspack/cabc.c /libmspack/libmspack/mspack/mszipd.c /libmspack/libmspack/mspack/qtmd.c /libmspack/libmspack/mspack/lzxd.c && afl-fuzz -i /seeds -o /findings -- ./fuzz_cab_open @@"
