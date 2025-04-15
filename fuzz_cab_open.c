#include <mspack.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
    if (argc < 2)
        return 1;

    const char *input_file = argv[1];

    // Create the CAB decompressor using the default I/O system
    struct mscab_decompressor *cabd = mspack_create_cab_decompressor(NULL);
    if (!cabd)
        return 1;

    // Try to open the input CAB file
    struct mscabd_cabinet *cab = cabd->open(cabd, input_file);
    if (!cab) {
        mspack_destroy_cab_decompressor(cabd);
        return 0;
    }

    // Try extracting all files inside this CAB file.
    // This will trigger decompression routines (and possibly bugs).
    struct mscabd_file *file;
    for (file = cab->files; file != NULL; file = file->next) {
        cabd->extract(cabd, cab, file);
    }

    // Access and touch some cabinet metadata to trigger parsing code.
    // (These are volatile to avoid compiler optimizing them away.)
    volatile unsigned short set_id = cab->set_id;
    volatile unsigned short num_folders = 0;
    volatile unsigned short num_files = 0;

    // Count number of folders and files manually
    struct mscabd_folder *folder;
    for (folder = cab->folders; folder != NULL; folder = folder->next) {
        num_folders++;
    }

    for (file = cab->files; file != NULL; file = file->next) {
        num_files++;
        volatile const char *filename = file->filename; // trigger filename parsing
    }

    // Close and clean up
    cabd->close(cabd, cab);
    mspack_destroy_cab_decompressor(cabd);
    return 0;
}
