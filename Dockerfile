FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    clang \
    llvm \
    git \
    make \
    autoconf \
    automake \
    libtool \
    pkg-config \
    wget \
    curl \
    ca-certificates \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install AFL++
RUN git clone https://github.com/AFLplusplus/AFLplusplus.git && \
    cd AFLplusplus && \
    make distrib && \
    make install && \
    cd .. && rm -rf AFLplusplus

# Clone libmspack and build it
RUN git clone https://github.com/kyz/libmspack.git && \
    cd libmspack/libmspack && \
    chmod +x rebuild.sh && \
    ./rebuild.sh && \
    make && \
    make install && \
    cd ..

# Working directory for harness, input, and fuzzing output
WORKDIR /src
