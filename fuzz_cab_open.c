#include <mspack.h>
#include <stdio.h>
#include <stdlib.h>

extern struct mspack_system *mspack_default_system;

int main(int argc, char **argv) {
    if (argc != 2)
        return 1;

    const char *input_path = argv[1];
    struct mspack_system *sys = mspack_default_system;
    struct mscab_decompressor *cabd = mspack_create_cab_decompressor(sys);
    if (!cabd)
        return 2;

    struct mscabd_cabinet *cab = cabd->open(cabd, (char *)input_path);
    if (cab) {
        struct mscabd_file *file = cab->files;
        while (file)
            file = file->next;
        cabd->close(cabd, cab);
    }

    mspack_destroy_cab_decompressor(cabd);
    return 0;
}
