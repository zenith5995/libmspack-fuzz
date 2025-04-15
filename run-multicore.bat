@echo off
setlocal

set SEEDS_DIR=%cd%\seeds_cab
set OUT_DIR=%cd%\findings_cab
set IMAGE=libmspack-fuzz

echo [+] Starting AFL++ master and workers with ASAN and auto-resume...

REM Master instance
start "fuzzer-master" docker run -it ^
  -e AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 ^
  -e AFL_AUTORESUME=1 ^
  -e AFL_USE_ASAN=1 ^
  -e ASAN_OPTIONS=detect_leaks=0:symbolize=0:abort_on_error=1 ^
  -v "%SEEDS_DIR%":/seeds ^
  -v "%OUT_DIR%":/findings ^
  %IMAGE% bash -c "afl-fuzz -M fuzzer-master -i /seeds -o /findings -- ./fuzz_cab_open @@"

REM Worker instance 1
start "fuzzer-worker1" docker run -it --rm ^
  -e AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 ^
  -e AFL_AUTORESUME=1 ^
  -e AFL_USE_ASAN=1 ^
  -e ASAN_OPTIONS=detect_leaks=0:symbolize=0:abort_on_error=1 ^
  -v "%SEEDS_DIR%":/seeds ^
  -v "%OUT_DIR%":/findings ^
  %IMAGE% bash -c "afl-fuzz -S fuzzer-worker1 -i /seeds -o /findings -- ./fuzz_cab_open @@"

REM Worker instance 2
start "fuzzer-worker2" docker run -it --rm ^
  -e AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 ^
  -e AFL_AUTORESUME=1 ^
  -e AFL_USE_ASAN=1 ^
  -e ASAN_OPTIONS=detect_leaks=0:symbolize=0:abort_on_error=1 ^
  -v "%SEEDS_DIR%":/seeds ^
  -v "%OUT_DIR%":/findings ^
  %IMAGE% bash -c "afl-fuzz -S fuzzer-worker2 -i /seeds -o /findings -- ./fuzz_cab_open @@"

endlocal
