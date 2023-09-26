#include "stdafx.h"
#include "internal.h"

/*

  Copied from internal.h...

#define NLoadCases 4

typedef load_case_t {
	TFloat point_dead_load;					// Dead load due to roadway.
	TFloat front_axle_load;					// Live load due to front axle.
	TFloat rear_axle_load;					// Live load due to rear axle.
} TLoadCase;

// Parameters of analysis.
typedef struct params_t {
	TFloat dead_load_factor;				// Dead load safety factor.
	TFloat live_load_factor;				// Live load safety factor.
	TFloat compression_resistance_factor;	// Compression loading safety factor.
	TFloat tension_resistance_factor;		// Tension loading safety factor.
	TLoadCase load_cases[NLoadCases];		// Load cases.
	TFloat connection_cost;					// Cost of connecting members at a joint.
	TFloat ordering_fee;					// Fee per cross-section used.
	TMaterial materials[NMaterials];		// Descriptions of available materials.
	unsigned n_sizes[NSections];			// Number of sizes available by section.
	TShape *shapes[NSections];				// Shape descriptions by section and size.
} TParams;

*/

#define DEAD_LOAD_FACTOR	1.35

// Constant part of the analysis parameters block.  Rest has to be calculated.
// This is similar to the BD_VERSION==0x400, but the cost factors have changed.
static TParams constant_params = INIT_CONSTANT_PARAMS;

// Table mapping section to the number of available sizes of that section.
static unsigned constant_n_sizes[NSections] = {
	NBarSizes,
	NTubeSizes,
};

unsigned n_sizes(TSection section)
{
	return (unsigned)section < NSections ? constant_n_sizes[section] : 0;
}

// Initialize a parameter block.
void init_params(TParams *params)
{
	memset(params, 0, sizeof(*params));
}

// Free storage allocated to a parameter block and re-initialize it.
void clear_params(TParams *params)
{
	unsigned section_index, size_index;

	for (section_index = 0; section_index < NSections; section_index++) {
		for (size_index = 0; size_index < params->n_sizes[section_index]; size_index++) 
			Safefree(params->shapes[section_index][size_index].name);
		Safefree(params->shapes[section_index]);
	}
	init_params(params);
}

// Square a float.
static __inline TFloat sqr(TFloat x) 
{
	return x * x;
}

// Compute fourth power of a float.
static __inline TFloat p4(TFloat x)
{
	return sqr(sqr(x));
}

// Fill in a parameter block.
void setup_params (TParams *params)
{
	unsigned section_index, size_index;
	char buf[256];
	int width, tube_thickness;

    /* From Steve, 15 Nov 2004. Last year these were computed. */
    static int width_tbl[33] = {
        30,35,40,45,50,55,60,65,70,75,80,				/* 0 to 10 */
        90,100,110,120,130,140,150,160,170,180,190,200, /* 11 to 22 */
        220,240,260,280,300,                            /* 23 to 27 */
        320,340,360,400,500                             /* 28 to 32 */
    };

    assert(STATIC_ARRAY_SIZE(width_tbl) == NBarSizes && NBarSizes == NTubeSizes);

	*params = constant_params;
	memcpy(params->n_sizes, constant_n_sizes, sizeof(constant_n_sizes));
	for (section_index = 0; section_index < NSections; section_index++) {

		Newz(200, params->shapes[section_index], params->n_sizes[section_index], sizeof(TShape));

		for (size_index = 0; size_index < params->n_sizes[section_index]; size_index++) {

			switch (section_index) {

			case Bar:
                width = width_tbl[size_index];
				params->shapes[section_index][size_index].width = width;
				params->shapes[section_index][size_index].area = sqr(width) * 1e-6;
				params->shapes[section_index][size_index].moment = p4(width) / 12 * 1e-12;
				sprintf(buf, "%dx%d", width, width);
				NewStr(203, params->shapes[section_index][size_index].name, buf);
				break;

			case Tube:
                width = width_tbl[size_index];
				tube_thickness = width / 20;
				if (tube_thickness < 2)
					tube_thickness = 2;
				params->shapes[section_index][size_index].width = width;
				params->shapes[section_index][size_index].area = ( sqr(width) - sqr(width - 2 * tube_thickness) ) * 1e-6;
				params->shapes[section_index][size_index].moment = ( p4(width) - p4(width -  2 * tube_thickness) ) / 12 * 1e-12;
				sprintf(buf, "%dx%dx%d", width, width, tube_thickness);
				NewStr(206, params->shapes[section_index][size_index].name, buf);
				break;

			default:
				fprintf(stderr, "init_params: unhandled section\n");
				exit(1);
				break;
			}
		}
	}
}

void print_load_case(FILE *f, unsigned index, TLoadCase *load_case)
{
	fprintf(f, "[%u] load case '%s':\n", index, load_case->name);
	fprintf(f, " point_dead_load = %.4f\n", load_case->point_dead_load);
	fprintf(f, " front_axle_load = %.4f\n", load_case->front_axle_load);
	fprintf(f, " rear_axle_load  = %.4f\n", load_case->rear_axle_load);
}

void print_params(FILE *f, TParams *params) 
{
	unsigned material_index,
		section_index,
		size_index,
		load_case_index;

	fprintf(f, "parameters:\n");
	fprintf(f, " dead_load_factor              = %.4f\n", params->dead_load_factor);
	fprintf(f, " live_load_factor              = %.4f\n", params->live_load_factor);
	fprintf(f, " compression_resistance_factor = %.4f\n", params->compression_resistance_factor);
	fprintf(f, " tension_resistance_factor     = %.4f\n", params->tension_resistance_factor);
	for (load_case_index = 0; load_case_index < NLoadCases; load_case_index++)
		print_load_case(f, load_case_index, &params->load_cases[load_case_index]);
	fprintf(f, " connection_cost               = %.4f\n", params->connection_cost);
	fprintf(f, " ordering_fee                  = %.4f\n", params->ordering_fee);
	for (material_index = 0; material_index < NMaterials; material_index++)
		print_material(f, material_index, &params->materials[material_index]);
	for (section_index = 0; section_index < NSections; section_index++)
		for (size_index = 0; size_index < params->n_sizes[section_index]; size_index++)
			print_shape(f, section_index, size_index, &params->shapes[section_index][size_index]);
}
