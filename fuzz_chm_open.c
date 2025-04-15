#include <mspack.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input.chm>\n", argv[0]);
        return 1;
    }

    const char *filename = argv[1];

    // Use default static mspack_system (passing NULL)
    struct mschm_decompressor *chmd = mspack_create_chm_decompressor(NULL);
    if (!chmd) {
        fprintf(stderr, "Failed to create CHM decompressor\n");
        return 1;
    }

    struct mschmd_header *chm = chmd->open(chmd, filename);
    if (!chm) {
        mspack_destroy_chm_decompressor(chmd);
        return 0; // Invalid file — skip
    }

    struct mschmd_file *file = chm->files;
    while (file) {
        if (file->section == 0 && file->length > 0) {
            // Correct call with 3 arguments
            chmd->extract(chmd, chm, file);
        }
        file = file->next;
    }

    chmd->close(chmd, chm);
    mspack_destroy_chm_decompressor(chmd);
    return 0;
}
