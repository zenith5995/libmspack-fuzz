@echo off
setlocal

set SEEDS_DIR=%cd%\seeds_chm
set OUT_DIR=%cd%\findings_chm
set IMAGE=libmspack-fuzz

echo [+] Starting AFL++ master and workers for CHM harness...

REM Master instance
start "CHM-Master" docker run -it --rm ^
  -e AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 ^
  -e AFL_AUTORESUME=1 ^
  -e AFL_SKIP_CPUFREQ=1 ^
  -e AFL_USE_ASAN=1 ^
  -v "%SEEDS_DIR%":/seeds ^
  -v "%OUT_DIR%":/findings ^
  %IMAGE% bash -c "cd /src && afl-fuzz -M chm-master -i /seeds -o /findings -- ./fuzz_chm_open @@"

REM Slave 1
start "CHM-Worker1" docker run -it --rm ^
  -e AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 ^
  -e AFL_AUTORESUME=1 ^
  -e AFL_SKIP_CPUFREQ=1 ^
  -e AFL_USE_ASAN=1 ^
  -v "%SEEDS_DIR%":/seeds ^
  -v "%OUT_DIR%":/findings ^
  %IMAGE% bash -c "cd /src && afl-fuzz -S chm-worker1 -i /seeds -o /findings -- ./fuzz_chm_open @@"

REM Slave 2
start "CHM-Worker2" docker run -it --rm ^
  -e AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 ^
  -e AFL_AUTORESUME=1 ^
  -e AFL_SKIP_CPUFREQ=1 ^
  -e AFL_USE_ASAN=1 ^
  -v "%SEEDS_DIR%":/seeds ^
  -v "%OUT_DIR%":/findings ^
  %IMAGE% bash -c "cd /src && afl-fuzz -S chm-worker2 -i /seeds -o /findings -- ./fuzz_chm_open @@"

endlocal
