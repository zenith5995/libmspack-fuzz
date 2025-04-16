@echo off
setlocal

set SEEDS_DIR=%cd%\seeds_cab
set OUT_DIR=%cd%\findings_cab
set IMAGE=libmspack-fuzz

echo [+] Starting AFL++ master and workers with ASAN and auto-resume...

REM Master instance (explore strategy)
start "fuzzer-master" docker run -it ^
  -e AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 ^
  -e AFL_AUTORESUME=1 ^
  -e AFL_USE_ASAN=1 ^
  -e ASAN_OPTIONS=detect_leaks=0:symbolize=0:abort_on_error=1 ^
  -v "%SEEDS_DIR%":/seeds ^
  -v "%OUT_DIR%":/findings ^
  %IMAGE% bash -c "exec afl-fuzz -M fuzzer-master -i /seeds -o /findings -p explore -- ./fuzz_cab_open @@"

REM Worker instance 1 (fast strategy)
start "fuzzer-worker1" docker run -it --rm ^
  -e AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 ^
  -e AFL_AUTORESUME=1 ^
  -e AFL_USE_ASAN=1 ^
  -e ASAN_OPTIONS=detect_leaks=0:symbolize=0:abort_on_error=1 ^
  -v "%SEEDS_DIR%":/seeds ^
  -v "%OUT_DIR%":/findings ^
  %IMAGE% bash -c "exec afl-fuzz -S fuzzer-worker1 -i /seeds -o /findings -p fast -- ./fuzz_cab_open @@"

REM Worker instance 2 (exploit strategy)
start "fuzzer-worker2" docker run -it --rm ^
  -e AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 ^
  -e AFL_AUTORESUME=1 ^
  -e AFL_USE_ASAN=1 ^
  -e ASAN_OPTIONS=detect_leaks=0:symbolize=0:abort_on_error=1 ^
  -v "%SEEDS_DIR%":/seeds ^
  -v "%OUT_DIR%":/findings ^
  %IMAGE% bash -c "exec afl-fuzz -S fuzzer-worker2 -i /seeds -o /findings -p exploit -- ./fuzz_cab_open @@"

endlocal
