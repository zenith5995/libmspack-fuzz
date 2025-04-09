@echo off
setlocal

echo [+] Minimizing corpus using afl-cmin...

REM Ensure minimized folder exists
if not exist minimized (
    mkdir minimized
)

REM Run afl-cmin inside Docker
docker run -it --rm ^
  -e AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 ^
  -v "%cd%\findings":/findings ^
  -v "%cd%\minimized":/minimized ^
  -v "%cd%":/src ^
  libmspack-fuzz bash -c "cd /src && afl-cmin -i /findings/main/queue -o /minimized -- ./fuzz_cab_open @@"

echo [+] Replacing seeds/ with minimized corpus...

REM Backup old seeds folder (optional)
if exist seeds (
    rename seeds seeds_backup
)

REM Move minimized to seeds
rename minimized seeds

echo [+] Done! You can now run run.bat or run-multicore.bat to restart fuzzing with the trimmed corpus.

endlocal
