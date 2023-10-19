#include "stdafx.h"
#include "internal.h"

// Bridge geometry -------------------------------------------------------------

// Initialize a geometry.
void init_geometry(TGeometry *geometry)
{
	memset(geometry, 0, sizeof(*geometry));
}

// Free storage of a geometry and re-initialize it.
void clear_geometry(TGeometry *geometry)
{
	Safefree(geometry->cos_x);
	Safefree(geometry->cos_y);
	Safefree(geometry->length);
	init_geometry(geometry);
}

// Fill in a geometry by calculation from given bridge.
void setup_geometry(TGeometry *geometry, TBridge *bridge)
{
	unsigned member_index;

	clear_geometry(geometry);

	Newz(210, geometry->length, bridge->n_members + 1, sizeof(TFloat));
	Newz(220, geometry->cos_x,  bridge->n_members + 1, sizeof(TFloat));
	Newz(230, geometry->cos_y,  bridge->n_members + 1, sizeof(TFloat));

	// Convert grid coords to physical world coords.
#define World(Grid)	((Grid) * bridge->load_scenario.grid_size)

	for (member_index = 1; member_index <= bridge->n_members; member_index++) {
		TJoint *start = &bridge->joints[bridge->members[member_index].start_joint];
		TJoint *end   = &bridge->joints[bridge->members[member_index].end_joint];
		TFloat dx = World(end->x - start->x);
		TFloat dy = World(end->y - start->y);
		TFloat len = sqrt(dx * dx + dy * dy);
		geometry->length[member_index] = len;
		geometry->cos_x[member_index] = dx / len;
		geometry->cos_y[member_index] = dy / len;
	}
}

