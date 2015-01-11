/*
 *
 * judge.c -- Ruby Extension WPBDC.  Support for the Engineering Encounters
 * Bridge Design Contest web site.  Ruby-visible constants and functions.
 *
 * Hashing code assumes unsigned int is 32 bits, but should otherwise be portable.
 *
 * This compiles judges for V3, V4 and V4 (contest) of the WPBD
 * according to compile time constants.
 * The corresponding values of BD_VERSION are:
 *  V3 => 0x300
 *  V4 => 0x400
 *  V4 (2002 contest) => 0x402c
 *  V4 (2003 contest) => 0x403c
 *  V4 (2004 contest) => 0x404c
 *  etc.
 */

#include "stdafx.h"

// Constants and data structures Ruby does not need to know about.
#include "internal.h"

// External interface.
#include "judge.h"

#if BD_VERSION != 0x415c
#error Wrong BD_VERSION. Should be 0x415c.
#endif

// Extension stubs --------------------------------------------------------------

// These are the routines called by the Ruby interface code.

void endecrypt(STRING *bridge_as_string)
{
    endecrypt_in_place(bridge_as_string->ptr, bridge_as_string->size);
}

// Parse bridge as string.
// Return a result struct that describes what happened.
void analyze(STRING *bridge_as_string, struct analysis_result_t *result)
{
    do_analyze(bridge_as_string, 0, 0, 0, 0, 0, result);
}

int compare(STRING *bridge_as_string_a, STRING *bridge_as_string_b)
{
    TBridge a[1], canonical_a[1], b[1], canonical_b[1];
    int rtn;

    init_bridge(a);
    init_bridge(canonical_a);
    init_bridge(b);
    init_bridge(canonical_b);

    parse_bridge(a, bridge_as_string_a);
    if (a->error != BridgeNoError)
        return -1;
    parse_bridge(b, bridge_as_string_b);
    if (b->error != BridgeNoError)
        return -1;
    canonicalize(canonical_a, a);
    if (canonical_a->error != BridgeNoError)
        return -1;
    canonicalize(canonical_b, b);
    if (canonical_b->error != BridgeNoError)
        return -1;
    rtn = bridges_indentical(canonical_a, canonical_b);

    clear_bridge(a);
    clear_bridge(canonical_a);
    clear_bridge(b);
    clear_bridge(canonical_b);

    return rtn;
}

char *variant(STRING *bridge_as_string, int seed)
{
    char *rtn;
    TBridge bridge[1], variant_bridge[1];

    init_bridge(bridge);
    init_bridge(variant_bridge);

    parse_bridge(bridge, bridge_as_string);

    if (bridge->error == BridgeNoError) {
        vary(variant_bridge, bridge, seed);
        rtn = unparse_bridge(variant_bridge);
    }
    else {
        rtn = 0;
    }
    clear_bridge(bridge);
    clear_bridge(variant_bridge);

    return rtn;
}

char *failed_variant(STRING *bridge_as_string, int seed)
{
    char *rtn;
    TBridge bridge[1], variant_bridge[1];

    init_bridge(bridge);
    init_bridge(variant_bridge);

    parse_bridge(bridge, bridge_as_string);

    rtn = 0;
    if (bridge->error == BridgeNoError
            && induce_failure(variant_bridge, bridge, seed) == 0) {
        rtn = unparse_bridge(variant_bridge);
    }
    clear_bridge(bridge);
    clear_bridge(variant_bridge);

    return rtn;
}

char *perturbation(STRING *bridge_as_string, int seed, 
                   int n_joints, int n_members)
{
    char *rtn;
    TBridge bridge[1], perturbed_bridge[1];

    init_bridge(bridge);
    init_bridge(perturbed_bridge);

    parse_bridge(bridge, bridge_as_string);

    if (bridge->error == BridgeNoError) {
        perturb(perturbed_bridge, bridge, seed, n_joints, n_members);
        rtn = unparse_bridge(perturbed_bridge);
    }
    else {
        rtn = 0;
    }
    clear_bridge(bridge);
    clear_bridge(perturbed_bridge);

    return rtn;
}


void sketch(STRING *bridge_as_string,
            int width, int height,
            COMPRESSED_IMAGE *compressed_image,
            struct analysis_result_t *result)
{
    TBridge bridge[1];
    TAnalysis analysis[1];
    struct analysis_result_t local_result[1];

    if (!result)
        result = local_result;

    do_analyze(bridge_as_string, analysis, bridge, 0, 0, 0, result);

    if (result->status == BRIDGE_OK) 
        do_sketch(bridge, analysis, width, height, compressed_image);

    clear_bridge(bridge);
    clear_analysis(analysis);
}

char *get_local_contest_number(STRING *number_as_string)
{
    if (number_as_string->size != SCENARIO_NUMBER_SIZE)
        return NULL;
    return local_contest_number_to_id(number_as_string->ptr);
}

char *analysis_table(STRING *bridge_as_string)
{
    TBridge bridge[1];
    TParams params[1];
    TGeometry geometry[1];
    TLoading loading[1];
    TAnalysis analysis[1];
    struct analysis_result_t result[1];
    char *rtn = 0;

    do_analyze(bridge_as_string, analysis, bridge, geometry, loading, params, result);
    if (!bridge->error)
        rtn = analysis_to_html(analysis, bridge, geometry, loading, params, result);

    clear_analysis(analysis);
    clear_bridge(bridge);
    clear_geometry(geometry);
    clear_loading(loading);
    clear_params(params);

    return rtn;
}

char *analysis_log(STRING *bridge_as_string)
{
    TBridge bridge[1];
    TParams params[1];
    TGeometry geometry[1];
    TLoading loading[1];
    TAnalysis analysis[1];
    struct analysis_result_t result[1];
    char *rtn = 0;

    do_analyze(bridge_as_string, analysis, bridge, geometry, loading, params, result);
    if (!bridge->error)
        rtn = analysis_to_text(analysis, bridge, geometry, loading, params, result);

    clear_analysis(analysis);
    clear_bridge(bridge);
    clear_geometry(geometry);
    clear_loading(loading);
    clear_params(params);

    return rtn;
}

#if defined(NATIVE_TEST) && !defined(CPROTO)

#define WRITE_EXAMPLES

#ifdef WRITE_EXAMPLES
#define PREVIOUS_YEAR_DELTA 1
#define EG_DIR  "../../test/eg/2014"
#define NEW_EG_DIR  "../../test/eg/2015"
#else
#define EG_DIR  "../../test/eg/2015"
#endif

#ifdef WINDOWS
#include <crtdbg.h>
#endif

#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
#include <unistd.h>

void strcpyn(char *dst, char *src, int n)
{
    while (n-- > 0 && *src)
        *dst++ = *src++;
    *dst = '\0';
}

void split_path(char *path, char *drv, char *dir, char *fname, char *ext)
{
    char *colon, *slash, *dot;

    colon = strchr(path, ':');
    if (colon) {
        if (drv) strcpyn(drv, path, colon - path + 1);
        path = colon + 1;
    }
    slash = strrchr(path, '/');
    if (slash) {
        if (dir) strcpyn(dir, path, slash - path + 1);
        path = slash + 1;
    }
    dot = strrchr(path, '.');
    if (dot) {
        if (ext) strcpy(ext, dot);
        if (fname) strcpyn(fname, path, dot - path);
    }
    else {
        if (ext) strcpy(ext, "");
        if (fname) strcpy(fname, path);
    }
}

void split_fn(char *fn, char *path, char *name, char *ext)
{
    char buf[256];
    char *p, *pdot, *pslash;

    strcpy(buf, fn);

    pdot = strrchr(buf, '.');
    if (pdot) {
        strcpy(ext, pdot);
        *pdot = '\0';
    }
    else
        ext[0] = '\0';

    pslash = strrchr(buf, '/');
    if ((p = strrchr(buf, '\\')) != NULL && (!pslash || p > pslash))
        pslash = p;
    if (pslash) {
        strcpy(name, pslash + 1);
        *(pslash + 1) = '\0';
        strcpy(path, buf);
    }
    else {
        strcpy(name, buf);
        path[0] = '\0';
    }
}

int main(int argc, char* argv[])
{
    extern unsigned contest_year;  // ugly hack go read other years' bridge files

    DIR *d;
    FILE *f;
    char fname[256];
    char raw[4*1024];
    STRING bridge_str[1], copy_str[1];
    char raw_hash[HASH_SIZE];
    char variant_hash[HASH_SIZE];
    char buf[256], path[256], name[256], ext[256];
    char *text;
    struct analysis_result_t result[1];
    struct dirent *dir_ent;

    TBridge bridge[1];
    TBridge copy[1];
    TGeometry geometry[1];
    TParams params[1];
    TLoading loading[1];
    TAnalysis anal[1];
    int i, n, test_case;
    //long h;
    COMPRESSED_IMAGE compressed_image[1];

#ifdef WRITE_EXAMPLES
    int n_examples_read = 0;
    int n_examples_written = 0;
#endif

#ifdef _CRTDBG_MAP_ALLOC
    {
        int mem_debug_flags;

        mem_debug_flags = _CrtSetDbgFlag(_CRTDBG_REPORT_FLAG);
        mem_debug_flags |= _CRTDBG_LEAK_CHECK_DF;
        _CrtSetDbgFlag(mem_debug_flags);
        // Leak memory to show we're running.
        malloc(1);
    }
#endif

    d = opendir (EG_DIR "/");
    if (!d) {
        perror ("Couldn't open test input directory " EG_DIR);
        return 17;
    }

    init_bridge(bridge);
    init_bridge(copy);
    init_geometry(geometry);
    init_params(params);
    init_loading(loading);
    init_analysis(anal);
    init_compressed_image(compressed_image);

    setup_params(params);

    if (test_scenario_table() != 0)
        return 1;

    for (test_case = 1;;test_case++) {
        dir_ent = readdir(d);
        if (!dir_ent) {
            closedir(d);
            test_case--;
            break;
        }
        if (strstr(dir_ent->d_name, ".bdc") == NULL)
            continue;

        // SINGLE TEST CASE!
        /*
        if (strcmp(dir_ent->d_name, "semis-01.bdc") != 0)
            continue;
        */

        printf("Test case %d (%s):\n", test_case, dir_ent->d_name);
        sprintf(fname, EG_DIR "/%s", dir_ent->d_name);
        f = fopen(fname, "rb");
        if (!f) {
            printf("can't open bridge file\n");
            return 1;
        }
        n = fread(raw, 1, sizeof raw, f);
        raw[n] = '\0';
        fclose(f);

        bridge_str->size = n;
        bridge_str->ptr = raw;
        endecrypt(bridge_str);

        printf("decrypted bridge:\n");
        for (i = 0; i < n; i++)
            putchar(bridge_str->ptr[i]);
        printf("\n");

#ifdef WRITE_EXAMPLES

        // Set the parser to look for last year's bridges.
        contest_year = CONTEST_YEAR - PREVIOUS_YEAR_DELTA;
#endif

        // Try a parse.
        parse_bridge(bridge, bridge_str);


        // Back to this year.
        contest_year = CONTEST_YEAR;

        if (bridge->error != BridgeNoError) {
            printf("parse error %d, line %d in %s; skipping...\n", bridge->error, bridge->error_line, fname);
            continue;
        }
        printf("scenario id %s\n", bridge->scenario_descriptor.id);

#ifdef WRITE_EXAMPLES

        if (!strstr(dir_ent->d_name, "failed")) {

            struct stat stat_buf[1];

            n_examples_read++;

            split_fn(dir_ent->d_name, path, name, ext);

            n = fix_failure(copy, bridge, params);

            if (n >= 0) {
                printf("writing fixed version\n");
                sprintf(fname, NEW_EG_DIR "/" "%s.bdc", name);
                text = unparse_bridge(copy);
                copy_str->ptr = text;
                copy_str->size = strlen(text);
                endecrypt(copy_str); // really encrypt
                f = fopen(fname, "wb");
                if (!f) {
                    printf("can't open fixed bridge file %s for writing\n", fname);
                    return 1;
                }
                fwrite(text, copy_str->size, 1, f);
                fclose(f);
                n_examples_written++;
            }
            else  {
                printf("attempt to fix bridge %s failed\n", fname);
            }

            // Write a failed version of this bridge for future testing.
            sprintf(fname, NEW_EG_DIR "/" "%s-failed%s", name, ext);
            if (stat(fname, stat_buf) != 0 && induce_failure(copy, bridge, 0) == 0) {
                printf("writing failed version\n");
                text = unparse_bridge(copy);
                copy_str->ptr = text;
                copy_str->size = strlen(text);
                endecrypt(copy_str); // really encrypt
                f = fopen(fname, "wb");
                if (!f) {
                    printf("can't open failed bridge file for writing\n");
                    return 1;
                }
                fwrite(text, copy_str->size, 1, f);
                fclose(f);
                clear_bridge(copy);
                n_examples_written++;
            }
            else {
                printf("attempt to write broken bridge %s failed (either already exists or could not break)\n", fname);
            }
        }
        continue;
#endif

        // Check for idempotency.
        n = compare(bridge_str, bridge_str);
        if (n == -1) {
            printf("idempotency test failed\n");
            exit(1);
        }
        printf("compare is idempotent\n");

        // Check for inverse.
        text = unparse_bridge(bridge);
        if (strncmp(text, raw, strlen(raw) - 10) != 0) {
            printf("inverse test failed:\n%s\n", text);
            exit(1);
        }
        Safefree(text);
        printf("parse and unparse are inverses\n");

        // Hash the bridge.
        hash_bridge(bridge, raw_hash);
        printf("hash=%s\n", hex_str(raw_hash, HASH_SIZE, buf));

        // Check that a bunch of randomized versions of the same bridge
        // compare equal to the original.
        printf("permuting...");
        #define N_PERMS 200
        for (i = 0; i < N_PERMS; i++) {

            vary(copy, bridge, i*13+1);

            copy_str->ptr = unparse_bridge(copy);
            copy_str->size = strlen(copy_str->ptr);

            // printf("Permutation %d:\n%s\n", i+1, text);
            n = compare(copy_str, bridge_str);
            if (n == -1) {
                printf("comparison with permutation failed at i=%d.\n", i);
                exit(1);
            }
            else if ( !n ) {
                printf("are_same test failed at i=%d\n", i);
                exit(1);
            }
            Safefree(copy_str->ptr);

            // Hash the variant.
            hash_bridge(copy, variant_hash);
            if (memcmp(raw_hash, variant_hash, HASH_SIZE) != 0) {
                printf("hash test failed at i=%d.\n", i);
                exit(1);
            }

            if (i % 1000 == 999)
                printf(" %d", i+1);
        }
        printf("\n");

        // Check that randomly perturbed versions of the bridge compare
        // unequal.

        printf("perturbing...");
        #undef N_PERMS
        #define N_PERMS 200
        for (i = 0; i < N_PERMS; i++) {
            perturb(copy, bridge, i*13+1, 1, 0);

            copy_str->ptr = unparse_bridge(copy);
            copy_str->size = strlen(copy_str->ptr);

            // printf("Permutation %d:\n%s\n", i+1, text);
            n = compare(copy_str, bridge_str);
            if (n == -1) {
                printf("comparison with perturbation failed at i=%d.\n", i);
                exit(1);
            }
            else if ( n ) {
                printf("are_same test failed to detect difference at i=%d\n", i);
                exit(1);
            }
            Safefree(copy_str->ptr);

            // Hash the variant.
            hash_bridge(copy, variant_hash);
            if (memcmp(raw_hash, variant_hash, HASH_SIZE) == 0) {
                printf("warning: hash miss at i=%d.\n", i);
            }

            if (i % 1000 == 999)
                printf(" %d", i+1);
        }
        printf("\n");

        // Do an analysis table.
        text = analysis_table(bridge_str);

        if (text) {
            printf("writing analysis table...");
            split_path(dir_ent->d_name, 0, path, name, ext);
            sprintf(buf, "Debug/html/%s.htm", name);
            f = fopen(buf, "w");
            if (!f) {
                fprintf(stderr, "can't open %s for output", buf);
                return 4;
            }
            fputs("<html><head><title>Load Test Results Report</title>\n"
                "<style>\n"
                "  table { font-size : 8pt; font-family: arial, helvetica, sans-serif }\n"
                "  th { font-weight : bold }\n"
                "</style></head><body>\n", f);
            fputs(text, f);
            fputs("</body></html>", f);
            fclose(f);

            Safefree(text);
        }

        // Do an analysis log.
        text = analysis_log(bridge_str);

        if (text) {
            printf("writing analysis log...");
            split_path(dir_ent->d_name, 0, path, name, ext);
            sprintf(buf, "Debug/text/%s.txt", name);
            f = fopen(buf, "w");
            if (!f) {
                fprintf(stderr, "can't open %s for output", buf);
                return 4;
            }
            fputs(text, f);
            fclose(f);

            Safefree(text);
        }

        //print_analysis(stdout, anal, bridge, geometry, loading, params);
        //printf("Cost = $%.2lf\n", (double)bridge_cost(bridge, geometry, params));

        clear_bridge(bridge);
        clear_bridge(copy);
        clear_geometry(geometry);
        clear_params(params);
        clear_loading(loading);
        clear_analysis(anal);

        // Do a sketch
        sketch(bridge_str, 300, 300, compressed_image, result);
        split_path(dir_ent->d_name, 0, path, name, ext);
        sprintf(buf, "Debug/sketch/%s.png", name);
        f = fopen(buf, "wb");
        if (!f) {
            fprintf(stderr, "can't open %s for output", buf);
            return 3;
        }
        fwrite(compressed_image->data, compressed_image->filled, 1, f);
        fclose(f);
    }
    clear_compressed_image(compressed_image);

#ifdef WRITE_EXAMPLES
    printf("%d examples read, %d written\n", n_examples_read, n_examples_written);
#endif

    return 0;
}

#endif
