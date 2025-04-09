FROM aflplusplus/aflplusplus

RUN apt update && apt install -y git make build-essential clang

# Set working directory
WORKDIR /libmspack

# Clone and build libmspack
RUN git clone https://github.com/kyz/libmspack.git && \
    cd libmspack/libmspack && \
    ./rebuild.sh && \
    make

# Copy fuzzing harness
WORKDIR /src
COPY fuzz_cab_open.c /src/fuzz_cab_open.c

# Compile fuzz target (corrected paths!)
RUN afl-clang-fast \
    -I/libmspack/libmspack/libmspack -I/libmspack/libmspack/libmspack/mspack \
    -o fuzz_cab_open \
    fuzz_cab_open.c \
    /libmspack/libmspack/libmspack/mspack/system.c \
    /libmspack/libmspack/libmspack/mspack/cabd.c \
    /libmspack/libmspack/libmspack/mspack/cabc.c \
    /libmspack/libmspack/libmspack/mspack/mszipd.c \
    /libmspack/libmspack/libmspack/mspack/qtmd.c \
    /libmspack/libmspack/libmspack/mspack/lzxd.c
