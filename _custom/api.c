#include <dirent.h>
#include <string.h>
#include <stdlib.h>
#include "internal.h"
#include "judge.h"
#include "scenario_descriptors.h"
#include "api.h"

int initialze_new_bridge()
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
    struct analysis_result_t result[1];
    struct dirent *dir_ent;

    TBridge bridge[1];
    TBridge copy[1];
    TGeometry geometry[1];
    TParams params[1];
    TLoading loading[1];
    TAnalysis anal[1];
    int i, n, test_case;

    init_bridge(bridge);
    init_bridge(copy);
    init_geometry(geometry);
    init_params(params);
    init_loading(loading);
    init_analysis(anal);
    setup_params(params);

    bridge->version = BD_VERSION;
    bridge->test_status = Unrecorded;
    bridge->scenario_descriptor = scenario_descriptor_tbl[0];
    setup_load_scenario(&bridge->load_scenario, &bridge->scenario_descriptor);
    if (bridge->load_scenario.error != LoadScenarioNoError)
    {
        clear_bridge(bridge);
        bridge->error = BridgeBadLoadScenario;
        return 1;
    }
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
    text = unparse_bridge(bridge);
    bridge_str->ptr = text;
    bridge_str->size = strlen(text);

    printf("bridge:\n");
    for (i = 0; i < bridge_str->size; i++)
        putchar(bridge_str->ptr[i]);
    printf("\n");

    // TODO: Convert to library accesible by python
    // https://www.youtube.com/watch?v=neexS0HK9TY
    // TODO: Return and recieve the joints and the members as vectors
    // MAX_JOINTS 100 [(x1,y1),(x2,y2),...,(x100,y100)]
    // MAX_MEMBERS 200 [(start_joint, end_joint)]

    return 0;
}

int main()
{
    return initialze_new_bridge();
}