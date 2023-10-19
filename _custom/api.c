#include <dirent.h>
#include "judge.h"
#include "api.h"



void initialze_new_bridge() 
{
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

    //char hash[20];
    //hash_bridge(new_bridge, hash);
}

int main()
{
    initialze_new_bridge();
    return 0;
}