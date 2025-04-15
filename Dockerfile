FROM aflplusplus/aflplusplus

RUN apt update && apt install -y git make build-essential clang

# Set environment variables for ASAN
ENV AFL_USE_ASAN=1
ENV CFLAGS="-O1 -g -fsanitize=address"
ENV CXXFLAGS="-O1 -g -fsanitize=address"

# Set working directory
WORKDIR /libmspack

# Clone and build libmspack with ASAN + AFL instrumentation
RUN git clone https://github.com/kyz/libmspack.git && \
    cd libmspack/libmspack && \
    ./rebuild.sh && \
    make clean && \
    make CC=afl-clang-fast CFLAGS="$CFLAGS"

# Set working directory for harness
WORKDIR /src
COPY fuzz_cab_open.c /src/fuzz_cab_open.c

# Compile fuzz target with ASAN
RUN afl-clang-fast $CFLAGS \
    -I/libmspack/libmspack/libmspack -I/libmspack/libmspack/libmspack/mspack \
    -o fuzz_cab_open \
    fuzz_cab_open.c \
    /libmspack/libmspack/libmspack/mspack/system.c \
    /libmspack/libmspack/libmspack/mspack/cabd.c \
    /libmspack/libmspack/libmspack/mspack/cabc.c \
    /libmspack/libmspack/libmspack/mspack/mszipd.c \
    /libmspack/libmspack/libmspack/mspack/qtmd.c \
    /libmspack/libmspack/libmspack/mspack/lzxd.c
