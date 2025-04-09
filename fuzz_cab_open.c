#include <mspack.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
    if (argc < 2)
        return 1;

    const char *input_file = argv[1];

    struct mscab_decompressor *cabd = mspack_create_cab_decompressor(NULL);
    if (!cabd)
        return 1;

    struct mscabd_cabinet *cab = cabd->open(cabd, input_file);
    if (!cab) {
        mspack_destroy_cab_decompressor(cabd);
        return 0;
    }

    struct mscabd_file *file;
    for (file = cab->files; file; file = file->next) {
        // Extract using default I/O system (writes to disk)
        cabd->extract(cabd, cab, file);
    }

    cabd->close(cabd, cab);
    mspack_destroy_cab_decompressor(cabd);
    return 0;
}
