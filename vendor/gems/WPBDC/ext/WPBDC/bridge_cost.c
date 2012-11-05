#include "stdafx.h"
#include "internal.h"

// Compute the complete cost of a bridge.
TFloat bridge_cost(TBridge *bridge, TGeometry *geometry, TParams *params)
{
	unsigned i, member_index;
	TFloat mtl_cost, connection_cost, product_cost;
	TXSection used[NMaterials * NSections * MaxNSizes];
	unsigned n_used = 0;
	TGeometry local_geometry[1];
	TParams local_params[1];

	if (bridge->error != BridgeNoError)
		return 0.00;

	// If caller didn't provide these things, we'll do it ourself.
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

	// Loop counts number of unique material types for ordering fee.
	// Loop also totals material cost based on volume, density, and cost per unit weight.
	mtl_cost = 0.00;
	for (member_index = 1; member_index <= bridge->n_members; member_index++) {
	
		TXSection *xs = &bridge->members[member_index].x_section;

		mtl_cost += 
			params->materials[xs->material].cost[xs->section] *
			params->shapes[xs->section][xs->size].area *
			geometry->length[member_index] *
			params->materials[xs->material].density;

		// Look for this cross-section in the list of those already used.
		for (i = 0; i < n_used && !x_section_lists_eq(&used[i], xs, 1); i++)
			/* skip */;
		if (i == n_used)
			// Didn't find this cross-section in table.  Add it.
			used[n_used++] = *xs;
	}
	product_cost = n_used * params->ordering_fee;
	connection_cost = bridge->n_joints * params->connection_cost;
	
	if (geometry == local_geometry)
		clear_geometry(geometry);
	if (params == local_params)
		clear_params(params);

	return 2 * (mtl_cost + connection_cost) + product_cost + bridge->scenario_descriptor.site_cost;
}

