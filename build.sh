#!/bin/bash
set -e

export CC=afl-clang
gcc -c fuzz_cab_open.c -Ilibmspack
gcc -o fuzz_cab_open fuzz_cab_open.o libmspack/libmspack.a
