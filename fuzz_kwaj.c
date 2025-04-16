#include <mspack.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef FUZZING
#include <signal.h>
#include <sys/wait.h>
#include <unistd.h>

// Helper to write the fuzz input to a temporary file so that libmspack’s API can open it.
static char *write_tempfile(const uint8_t *data, size_t size) {
    char tmpl[] = "/tmp/kwaj_inputXXXXXX";
    int fd = mkstemp(tmpl);
    if (fd < 0)
        return NULL;
    if (write(fd, data, size) != (ssize_t)size) {
        close(fd);
        return NULL;
    }
    close(fd);
    return strdup(tmpl);
}

// Fuzzing target: LLVMFuzzerTestOneInput reads fuzz data, writes it to a temporary file,
// and then processes it using the same functions as the regression test suite.
int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    // Limit input size to avoid overly heavy inputs.
    if (size > 4096)
        return 0;

    char *tmpname = write_tempfile(data, size);
    if (!tmpname)
        return 0;

    struct mskwaj_decompressor *kwajd = mspack_create_kwaj_decompressor(NULL);
    if (!kwajd) {
        free(tmpname);
        return 0;
    }

    // Call open() like the regression test does.
    struct mskwajd_header *hdr = kwajd->open(kwajd, tmpname);
    // If open() fails, we simply clean up and return.
    if (!hdr) {
        mspack_destroy_kwaj_decompressor(kwajd);
        free(tmpname);
        return 0;
    }

    // Optionally, mimic the regression test by inspecting the filename.
    // In the test suite, for f00.kwj the filename is expected to be NULL.
    // For other files, a non-NULL value is expected.
    // In fuzzing we simply call extract() regardless.
    if (hdr->filename != NULL) {
        // (For debugging purposes you might print or log the filename.)
        // printf("Parsed filename: %s\n", hdr->filename);
    }

    // Call extract() to decompress the input (output is sent to /dev/null).
    int ret = kwajd->extract(kwajd, hdr, "/dev/null");
    (void)ret; // For fuzzing we don't need to act upon ret; crashes are what we're after

    // Clean up: close the header and destroy the decompressor.
    kwajd->close(kwajd, hdr);
    mspack_destroy_kwaj_decompressor(kwajd);
    free(tmpname);
    return 0;
}

#else // Standalone mode

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <kwaj_file>\n", argv[0]);
        return 1;
    }
    const char *input_file = argv[1];

    struct mskwaj_decompressor *kwajd = mspack_create_kwaj_decompressor(NULL);
    if (!kwajd) {
        fprintf(stderr, "Failed to create KWAJ decompressor\n");
        return 1;
    }

    // Open the test file as in the regression test suite.
    struct mskwajd_header *hdr = kwajd->open(kwajd, input_file);
    if (!hdr) {
        mspack_destroy_kwaj_decompressor(kwajd);
        return 0;
    }

    // In the test suite, the header fields (like filename) are verified.
    // Here we simply print them if present.
    if (hdr->filename != NULL)
        printf("Parsed filename: %s\n", hdr->filename);
    else
        printf("No filename parsed.\n");

    int ret = kwajd->extract(kwajd, hdr, "/dev/null");
    if (ret != MSPACK_ERR_OK) {
        fprintf(stderr, "Extraction failed with error code %d\n", ret);
    }

    kwajd->close(kwajd, hdr);
    mspack_destroy_kwaj_decompressor(kwajd);
    return 0;
}
#endif
