@echo off
setlocal

set SEEDS_DIR=%cd%\seeds_kwaj
set OUT_DIR=%cd%\findings_cab
set IMAGE=libmspack-fuzz-kwaj

echo [+] Starting AFL++ master and workers with ASAN and auto-resume...

REM Master instance (explore strategy)
start "fuzzer-master" docker run -it ^
  -w /src ^
  -e AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 ^
  -e AFL_AUTORESUME=1 ^
  -e AFL_USE_ASAN=1 ^
  -e ASAN_OPTIONS=detect_leaks=0:symbolize=0:abort_on_error=1 ^
  -v "%SEEDS_DIR%":/seeds ^
  -v "%OUT_DIR%":/findings ^
  %IMAGE% bash -c "exec afl-fuzz -M fuzzer-master -i /seeds -o /findings -p explore -t 10000+ -- ./fuzz_kwaj @@"

REM Worker instance 1 (fast strategy)
start "fuzzer-worker1" docker run -it --rm ^
  -w /src ^
  -e AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 ^
  -e AFL_AUTORESUME=1 ^
  -e AFL_USE_ASAN=1 ^
  -e ASAN_OPTIONS=detect_leaks=0:symbolize=0:abort_on_error=1 ^
  -v "%SEEDS_DIR%":/seeds ^
  -v "%OUT_DIR%":/findings ^
  %IMAGE% bash -c "exec afl-fuzz -S fuzzer-worker1 -i /seeds -o /findings -p fast  -t 10000+ -- ./fuzz_kwaj @@"

REM Worker instance 2 (exploit strategy)
start "fuzzer-worker2" docker run -it --rm ^
  -w /src ^
  -e AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 ^
  -e AFL_AUTORESUME=1 ^
  -e AFL_USE_ASAN=1 ^
  -e ASAN_OPTIONS=detect_leaks=0:symbolize=0:abort_on_error=1 ^
  -v "%SEEDS_DIR%":/seeds ^
  -v "%OUT_DIR%":/findings ^
  %IMAGE% bash -c "exec afl-fuzz -S fuzzer-worker2 -i /seeds -o /findings -p exploit -t 10000+ -- ./fuzz_kwaj @@"

endlocal
