#!/bin/bash
set -e

export CC=afl-clang-fast
$CC -c fuzz_cab_open.c -Ilibmspack
$CC -o fuzz_cab_open fuzz_cab_open.o libmspack/libmspack.a
