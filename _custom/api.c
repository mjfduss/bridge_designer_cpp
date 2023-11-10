#include <dirent.h>
#include <string.h>
#include <stdlib.h>
#include "internal.h"
#include "judge.h"
#include "scenario_descriptors.h"
#include "api.h"

void initialze_new_bridge(TBridge *bridge)
{
    DIR *d;
    FILE *f;
    char fname[256];
    char raw[4 * 1024];
    STRING bridge_str[1], copy_str[1];
    char raw_hash[HASH_SIZE];
    char variant_hash[HASH_SIZE];
    char buf[256], path[256], name[256], ext[256];
    char *text;

    struct dirent *dir_ent;

    TBridge copy[1];
    int i, n, test_case;
    COMPRESSED_IMAGE compressed_image[1];

    init_bridge(bridge);
    init_bridge(copy);

    init_compressed_image(compressed_image);

    bridge->version = BD_VERSION;
    bridge->test_status = Unrecorded;
    bridge->scenario_descriptor = scenario_descriptor_tbl[0];
    setup_load_scenario(&bridge->load_scenario, &bridge->scenario_descriptor);

    fill_bridge_from_load_scenario(bridge);
    bridge->n_members = 3;
    int max = bridge->n_members + 1;
    Newz(1, bridge->members, max, sizeof(TMember));
    for (i = 1; i < max; i++)
    {
        bridge->members[i].number = i;
        bridge->members[i].start_joint = i;
        bridge->members[i].end_joint = i + 1;
        bridge->members[i].x_section.material = 1;
        bridge->members[i].x_section.section = 1;
        bridge->members[i].x_section.size = 1;
        char *compression = "none";
        char *tension = "none";
        strcpy(bridge->members[i].compression, compression);
        strcpy(bridge->members[i].tension, tension);
    }
    bridge->n_design_iterations = 1;
    bridge->project_id = "api";
    bridge->designer = "Mr Roboto";
    /*


    // Bridge as string
    text = unparse_bridge(bridge);
    bridge_str->ptr = text;
    bridge_str->size = strlen(text) + 1;

    printf("bridge:\n");
    for (i = 0; i < bridge_str->size; i++)
        putchar(bridge_str->ptr[i]);
    printf("\n");

    if (bridge->error != BridgeNoError)
    {
        printf("parse error %d, line %d in %s; skipping...\n", bridge->error, bridge->error_line, fname);
    }
    printf("scenario id %s\n", bridge->scenario_descriptor.id);

    n = compare(bridge_str, bridge_str);
    printf("%d", n);
    printf("\n");

    // Do a sketch
    do_sketch(bridge, analysis, 300, 300, compressed_image);
    f = fopen("api_bridge.png", "wb");
    if (!f)
    {
        printf("can't open api_bridge.png for output");
        return 3;
    }
    fwrite(compressed_image->data, compressed_image->filled, 1, f);
    fclose(f);
    */
    // TODO: Convert to library accesible by python
    // https://www.youtube.com/watch?v=neexS0HK9TY
    // TODO: Return and recieve the joints and the members as vectors
    // MAX_JOINTS 100 [(x1,y1),(x2,y2),...,(x100,y100)]
    // MAX_MEMBERS 200 [(start_joint, end_joint)]
}

void test_bridge(TBridge *bridge, TAnalysis *analysis)
{
    TGeometry geometry[1];
    TParams params[1];
    TLoading loading[1];
    struct analysis_result_t result[1];

    init_geometry(geometry);
    init_params(params);
    setup_params(params);
    init_loading(loading);
    init_analysis(analysis);

    // Run the load test.
    setup_geometry(geometry, bridge);
    setup_loading(loading, bridge, geometry, params);
    setup_analysis(analysis, bridge, geometry, loading, params);
    if (analysis->error != NoAnalError ||
        analysis->n_compressive_failures > 0 ||
        analysis->n_tensile_failures > 0)
    {
        result->status = BRIDGE_FAILEDTEST;
        printf("in error state\n");
    }
}

int main()
{
    TBridge bridge[1];
    initialze_new_bridge(bridge);
    TAnalysis analysis[1];
    test_bridge(bridge, analysis);

    return 0;
}
