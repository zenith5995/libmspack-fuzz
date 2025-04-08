#!/bin/bash
set -e

docker build -t libmspack-fuzz .
docker run -it --rm \
  -v $(pwd)/seeds:/seeds \
  -v $(pwd)/findings:/findings \
  libmspack-fuzz \
  bash -c "cd /src && ./build.sh && afl-fuzz -i /seeds -o /findings -- ./fuzz_cab_open @@"
