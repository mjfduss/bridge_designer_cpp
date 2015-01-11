#include "stdafx.h"
#include "internal.h"

// Loading ---------------------------------------------------------------------

// Initialize a loading.
void init_loading(TLoading *loading)
{
	memset(loading, 0, sizeof(*loading));
}

// Free storage for a loading and re-initialize it.
void clear_loading(TLoading *loading)
{
	unsigned i;

	for (i = 1; i <= loading->n_load_instances; i++)
		Safefree(loading->load_instances[i].point_load);
	Safefree(loading->load_instances);
	init_loading(loading);
}

// Fill in a loading with information from a bridge, its geometry, and
// analysis parameters.
void setup_loading(TLoading *loading,	
				   TBridge *bridge, 
				   TGeometry *geometry,
				   TParams *params)
{
	unsigned joint_index, member_index, load_instance_index;
	TGeometry local_geometry[1];
	TParams local_params[1];
	TLoadCase *lc;
	unsigned n_equations = 2 * bridge->n_joints;

	clear_loading(loading);

	// If caller didn't provide these things, we'll do it ourselves.
	if (!geometry) {
		geometry = local_geometry;
		init_geometry(geometry);
		setup_geometry(geometry, bridge);
	}

	if (!params) {
		params = local_params;
		init_params(params);
		setup_params(params);
	}

	loading->n_load_instances = bridge->load_scenario.n_loaded_joints + 1;
	Newz(240, loading->load_instances, loading->n_load_instances + 1, TLoadInstance);
	for (load_instance_index = 1; load_instance_index <= loading->n_load_instances; load_instance_index++) {
		Newz(250, loading->load_instances[load_instance_index].point_load, n_equations + 1, TFloat);
	}

	// Apply self-weight.

	for (member_index = 1; member_index <= bridge->n_members; member_index++) {

		TMember *member = &bridge->members[member_index];

		TFloat dead_load = 	params->dead_load_factor *	
		// half weight of member
		params->shapes[member->x_section.section][member->x_section.size].area *
		geometry->length[member_index] *
		params->materials[member->x_section.material].density * 9.8066 / 2.0 / 1000.0;

		unsigned dof1 = 2 * member->start_joint;
		unsigned dof2 = 2 * member->end_joint;

		for (load_instance_index = 1; load_instance_index <= loading->n_load_instances; load_instance_index++) {
			TLoadInstance *load_instance = &loading->load_instances[load_instance_index];
			load_instance->point_load[dof1] -= dead_load;
			load_instance->point_load[dof2] -= dead_load;
		}
	}

	// Get access to the right load case.

	lc = &params->load_cases[bridge->load_scenario.load_case];

	// Apply dead load.

	for (joint_index = 1; joint_index <= bridge->load_scenario.n_loaded_joints; joint_index++) {
		unsigned dof= 2 * joint_index;
		for (load_instance_index = 1; load_instance_index <= loading->n_load_instances; load_instance_index++) {

			TFloat load = lc->point_dead_load;

			// Account for ends of deck.
			if (joint_index == 1 || joint_index == bridge->load_scenario.n_loaded_joints)
				load /= 2;
			loading->load_instances[load_instance_index].point_load[dof] -= load;
		}
	}

	// Apply live load.

	for (load_instance_index = 2; load_instance_index <= loading->n_load_instances - 1; load_instance_index++) {
		TLoadInstance *load_instance = &loading->load_instances[load_instance_index];
		unsigned dof_front = 2 * load_instance_index;
		unsigned dof_rear = dof_front - 2;
		load_instance->point_load[dof_front] -= params->live_load_factor * lc->front_axle_load;
		load_instance->point_load[dof_rear]  -= params->live_load_factor * lc->rear_axle_load;
	}

#ifdef TEST_PRINT
	for (load_instance_index = 1; load_instance_index <= loading->n_load_instances; load_instance_index++) {
		TLoadInstance *load_instance = &loading->load_instances[load_instance_index];
		printf("\nPoint Loads Load Case %d\n", load_instance_index);
		printf("Jnt #      X           Y\n");
		printf("----- ----------- -----------\n");
		for (joint_index = 1; joint_index <= bridge->n_joints; joint_index++) {
			printf("%5d %11.5lf %11.5lf\n", 
				joint_index,
				load_instance->point_load[2 * joint_index - 1],
				load_instance->point_load[2 * joint_index]);
		}
	}
#endif

	if (geometry == local_geometry)
		clear_geometry(geometry);
	if (params == local_params)
		clear_params(params);
}

