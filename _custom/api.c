#include <dirent.h>
#include <string.h>
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
    /*
    f = fopen("bridge_files/MyDesign.bdc", "rb");
    if (!f) {
        printf("can't open bridge file\n");
        return 1;
    }
    n = fread(raw, 1, sizeof raw, f);
    raw[n] = '\0';
    fclose(f);

    bridge_str->size = n;
    bridge_str->ptr = raw;
    //endecrypt(bridge_str);
    */
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
    // printf("%d\n", bridge->load_scenario.prescribed_joints[0].number);
    //   text = unparse_bridge(bridge);
    //     bridge_str->ptr = text;
    //     bridge_str->size = strlen(text);

    // printf("bridge:\n");
    // for (i = 0; i < n; i++)
    //   putchar(bridge_str->ptr[i]);
    // printf("\n");

    return 0;
    //  char hash[20];
    //  hash_bridge(new_bridge, hash);
}

int main()
{
    return initialze_new_bridge();
}