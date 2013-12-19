#include "stdafx.h"
#include "internal.h"


// Scenario descriptors

// Note the index values are used in the hash function, so don't
// fiddle with the indices between main contest and semi-finals.
// The indices do _not_ have to be in order.

// Lookup table is sorted on 10-char ID field for binary search.
// The search routine will bubble the semifinal row to the right location.
// 18 Dec 2013: Now produced by development-only File menu item in bridge designer.
#include "scenario_descriptors.h"

static int to_upper_case(int c)
{
  return ('a' <= c && c <= 'z') ? c + ('A' - 'a') : c;
}

static TBool scenario_numbers_equal(char *a, char *b)
{
  return a[0] == b[0] && a[1] == b[1] && to_upper_case(a[2]) == to_upper_case(b[2]);
}

// Input must be a string of length at least 3.
char *local_contest_number_to_id(char *number)
{
	unsigned i;

	for (i = 0; i < STATIC_ARRAY_SIZE(scenario_descriptor_tbl); i++)
	    if (scenario_numbers_equal(scenario_descriptor_tbl[i].number, number))
			return scenario_descriptor_tbl[i].id;
	return NULL;
}

int lookup_scenario_descriptor(TScenarioDescriptor *desc, char *id)
{
	static TScenarioDescriptor null_desc = NULL_SCENARIO_DESCRIPTOR;
	int lo = 0;
	int hi = STATIC_ARRAY_SIZE(scenario_descriptor_tbl) - 1;
	int cmp, mid;

    /*  NOT THREAD SAFE.  DO BY HAND!

    // Bubble the semifinal scenario to the right position one time.
	static int initialized_p = 0;
	int i;
    if (!initialized_p) {
        initialized_p = 1;
        TScenarioDescriptor semifinal_descriptor = scenario_descriptor_tbl[0];
        for (i = 0; i < STATIC_ARRAY_SIZE(scenario_descriptor_tbl) - 1; i++) {
            if (strncmp(scenario_descriptor_tbl[i + 1].id, semifinal_descriptor.id, SCENARIO_ID_SIZE) < 0)
                scenario_descriptor_tbl[i] = scenario_descriptor_tbl[i + 1];
            else
                break;
        }
        scenario_descriptor_tbl[i] = semifinal_descriptor;
    }
    */

    // Don't bother searching for the null semifinal scenario.
    if (strncmp(id, NULL_SEMIFINAL_SCENARIO_ID, SCENARIO_ID_SIZE) != 0) {

        while (lo <= hi) {
            mid = (unsigned)(lo + hi) >> 1;
            cmp = strncmp(id, scenario_descriptor_tbl[mid].id, SCENARIO_ID_SIZE);
            if (cmp < 0)
                hi = mid - 1;
            else if (cmp > 0)
                lo = mid + 1;
            else {
                if (desc)
                    *desc = scenario_descriptor_tbl[mid];
                return mid;
            }
        }

    }
	if (desc)
		*desc = null_desc;
	return -1;
}

// Load scenarios

// Set contents of a load scenario to known-empty.
void init_load_scenario(TLoadScenario *load_scenario)
{
	static TLoadScenario constant_load_scenario = INIT_LOAD_SCENARIO;
	*load_scenario = constant_load_scenario;
}

// Free allocated memory for a load scenario and reset it to known-empty.
void clear_load_scenario(TLoadScenario *load_scenario)
{
	// Prescribed joint storage is static in non-contest versions.
	Safefree(load_scenario->prescribed_joints);
	init_load_scenario(load_scenario);
}

#define UNSIGNED_FROM_CHAR(C)	((C) - '0')
#define UNSIGNED_FROM_2_CHARS(P) (10 * UNSIGNED_FROM_CHAR((P)[0]) + UNSIGNED_FROM_CHAR((P)[1]))

// Fill contents of load scenario given a scenario index.  
// For V3 and V4, this amounts to looking the load scenario up in a table.
// For V4 (contest), we compute the load scenario from the index digits!
void setup_load_scenario(TLoadScenario *load_scenario, TScenarioDescriptor *desc)
{
	TJoint *prescribed_joints;
	unsigned n_prescribed_joints,
		panel_size,
		x, y,
		joint_index;

	clear_load_scenario(load_scenario);

	// Check that scenario index isn't null.
	if (desc->index < 0) {
		load_scenario->error = LoadScenarioIndexRange;
		return;
	}

	load_scenario->support_type = 0;

	// digit 10 => (0 = low pier, 1 = high pier)
	if (desc->id[9] > '0')
		load_scenario->support_type |= HI_NOT_LO;

	// digit 9 => panel point at which pier is located. (0 = no pier).
	load_scenario->intermediate_support_joint_no = UNSIGNED_FROM_CHAR(desc->id[8]);
	if (load_scenario->intermediate_support_joint_no > 0)
		load_scenario->support_type |= INTERMEDIATE_SUPPORT;

	// digit 8 => (0 = simple, 1 = arch, 2 = cable left, 3 = cable both)
	switch (desc->id[7]) {
	case '0':
		break;
	case '1':
		load_scenario->support_type |= ARCH_SUPPORT;
		break;
	case '2':
		load_scenario->support_type |= CABLE_SUPPORT_LEFT;
		break;
	case '3':
		load_scenario->support_type |= (CABLE_SUPPORT_LEFT | CABLE_SUPPORT_RIGHT);
		break;
	default:
		assert(0);
		break;
	}

	// digits 6 and 7 => meters under span
	load_scenario->under_meters = UNSIGNED_FROM_2_CHARS(&desc->id[5]);

	// digits 4 and 5 => meters over span
	load_scenario->over_meters =  UNSIGNED_FROM_2_CHARS(&desc->id[3]);

	// digits 2 and 3 => number of bridge panels
	load_scenario->n_panels = UNSIGNED_FROM_2_CHARS(&desc->id[1]);

	// digit 1 is the load case, 1-based
	load_scenario->load_case = UNSIGNED_FROM_CHAR(desc->id[0]) - 1;  // -1 correction for 0-based load_case table
	
	// There is no scaling of image in the 2004 version either, but geometry sizes changed.
	load_scenario->grid_size = 0.25;
	panel_size = 16;
	load_scenario->over_grids = load_scenario->over_meters * 4;
	load_scenario->under_grids = load_scenario->under_meters * 4;

	// load_scenario->joint_radius = ??;  Not set because Steve didn't give it to me. Not needed anyway.
	load_scenario->num_length_grids = load_scenario->n_panels * panel_size;
	load_scenario->n_loaded_joints = load_scenario->n_panels + 1;

	// Loaded joints are prescribed.
	n_prescribed_joints = load_scenario->n_loaded_joints;

	// Add one prescribed joint for the intermediate support, if any.
	if ( (load_scenario->support_type & INTERMEDIATE_SUPPORT) 
			&& !(load_scenario->support_type & HI_NOT_LO))
		n_prescribed_joints++;

	// Another two for the arch base, if we have an arch.
	if (load_scenario->support_type & ARCH_SUPPORT)
		n_prescribed_joints += 2;

	// And another one or two for cable anchorages if they're present.
	if (load_scenario->support_type & CABLE_SUPPORT_LEFT) 
		n_prescribed_joints++;
	if (load_scenario->support_type & CABLE_SUPPORT_RIGHT) 
		n_prescribed_joints++;

	// Allocate and fill prescribed joint vector.
	Newz(92, prescribed_joints, n_prescribed_joints, TJoint); 
	x = y = 0;
	for (joint_index = 0; joint_index < load_scenario->n_loaded_joints; joint_index++) {
		prescribed_joints[joint_index].number = joint_index + 1;
		prescribed_joints[joint_index].x = x;
		prescribed_joints[joint_index].y = y;
		x += panel_size;
	}

	// Loop leaves joint_index pointing at next joint.  Add the low intermediate support, if any.
	if ( (load_scenario->support_type & INTERMEDIATE_SUPPORT) 
			&& !(load_scenario->support_type & HI_NOT_LO) ) {
		prescribed_joints[joint_index].number = joint_index + 1;
		prescribed_joints[joint_index].x = (load_scenario->intermediate_support_joint_no - 1) * panel_size;
		prescribed_joints[joint_index].y = -(TCoordinate)load_scenario->under_grids;
		joint_index++;
	}

	// Add the arch base supports, if any.
	if (load_scenario->support_type & ARCH_SUPPORT) {
		prescribed_joints[joint_index].number = joint_index + 1;
		prescribed_joints[joint_index].x = 0;
		prescribed_joints[joint_index].y = -(TCoordinate)load_scenario->under_grids;
		joint_index++;
		prescribed_joints[joint_index].number = joint_index + 1;
		prescribed_joints[joint_index].x = prescribed_joints[load_scenario->n_loaded_joints - 1].x;
		prescribed_joints[joint_index].y = -(TCoordinate)load_scenario->under_grids;
		joint_index++;
	}

	// Add the cable anchorages, if any.
	if (load_scenario->support_type & CABLE_SUPPORT_LEFT) {
		prescribed_joints[joint_index].number = joint_index + 1;
		prescribed_joints[joint_index].x = -CABLE_ANCHORAGE_X_OFFSET;
		prescribed_joints[joint_index].y = 0;
		joint_index++;
	}
	if (load_scenario->support_type & CABLE_SUPPORT_RIGHT) {
		prescribed_joints[joint_index].number = joint_index + 1;
		prescribed_joints[joint_index].x = prescribed_joints[load_scenario->n_loaded_joints - 1].x + CABLE_ANCHORAGE_X_OFFSET;
		prescribed_joints[joint_index].y = 0;
		joint_index++;
	}

	assert(joint_index == n_prescribed_joints);
	load_scenario->n_prescribed_joints = n_prescribed_joints;
	load_scenario->prescribed_joints = prescribed_joints;
}

void copy_load_scenario(TLoadScenario *dst, TLoadScenario *src)
{
	if (src->error != LoadScenarioNoError)
		return;
	clear_load_scenario(dst);
	*dst = *src;

	// Need fresh storage for prescribed joints.
	Newz(93, dst->prescribed_joints, dst->n_prescribed_joints, TJoint);
	memcpy(dst->prescribed_joints, src->prescribed_joints, dst->n_prescribed_joints * sizeof(TJoint));
}

int test_scenario_table(void)
{
	unsigned i, n;
	char invalid_scenario_ids[][SCENARIO_ID_SIZE + 1] = { 
		"----------",
		"0000000500",
		"1000000000",
		"3999999999",
	};
	TScenarioDescriptor desc[1];
	TLoadScenario load_scenario[1];

	init_load_scenario(load_scenario);

	// Check lookup function for bridges.
	printf("scenario lookup check (find good indices): ");
	for (i = 0; i < STATIC_ARRAY_SIZE(scenario_descriptor_tbl); i++) {
		printf("%d ", i);
		if (strncmp(scenario_descriptor_tbl[i].id, NULL_SEMIFINAL_SCENARIO_ID, SCENARIO_ID_SIZE) == 0)
		    continue;
		if (lookup_scenario_descriptor(desc, scenario_descriptor_tbl[i].id) < 0) {
			printf("\nfailed to find scenario id %s (position %d)\n", 
				scenario_descriptor_tbl[i].id, i);
			return 1;
		}
		setup_load_scenario(load_scenario, desc);
		if (load_scenario->error != LoadScenarioNoError) {
			printf("\nfailed to initialize load scenario for id %s (position %d)\n", 
				scenario_descriptor_tbl[i].id, i);
			return 1;
		}
		clear_load_scenario(load_scenario);
	}

	printf("ok\nscenario lookup check (reject bad indices): ");
	for (i = 0; i < STATIC_ARRAY_SIZE(invalid_scenario_ids); i++) {
		printf("%d ", i);
		if (lookup_scenario_descriptor(NULL, invalid_scenario_ids[i]) >= 0) {
			printf("\nfound invalid code %s (position %d)\n", invalid_scenario_ids[i], i);
			return 2;
		}
	}
	printf("ok\ncable anchorage scenarios: ");
	for (n = i = 0; i < STATIC_ARRAY_SIZE(scenario_descriptor_tbl); i++) {
		if (scenario_descriptor_tbl[i].id[7] > '1') {
			printf(" (%s) %s\n", scenario_descriptor_tbl[i].number, scenario_descriptor_tbl[i].id);
			n++;
		}
	}
	printf("%d cases ok\n", n);
	return 0;
}
