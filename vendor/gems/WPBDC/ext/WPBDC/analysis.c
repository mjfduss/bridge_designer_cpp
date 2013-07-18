#include "stdafx.h"
#include "internal.h"

// Analysis --------------------------------------------------------------------

// Initialize an analysis.
void init_analysis(TAnalysis *anal)
{
	memset(anal, 0, sizeof(*anal));
}

// Free storage for an analysis and re-initialize it.
void clear_analysis(TAnalysis *anal)
{
	Safefree(anal->x_restraint);
	Safefree(anal->y_restraint);
	Safefree(anal->stiffness);
	Safefree(anal->displacement);
	Safefree(anal->member_force);
	Safefree(anal->member_strength);
	Safefree(anal->max_forces);
	init_analysis(anal);
}

// Max of two floats.
static __inline void fold_max(TFloat *max, TFloat x)
{
	if (x > *max) *max = x;
}

// Square a float.
static __inline TFloat sqr(TFloat x) 
{
	return x * x;
}

// Do the analysis, filling it in along the way.
void setup_analysis(TAnalysis *anal, 
					TBridge *bridge, 
					TGeometry *geometry,
					TLoading *loading, 
					TParams *params)
{
	unsigned member_index, joint_index, load_instance_index, equation_index;
	TGeometry local_geometry[1];
	TParams local_params[1];
	TLoading local_loading[1];

	unsigned n_equations = bridge->n_joints * 2;

	clear_analysis(anal);

	// Punt if bridge is in error.
	if (bridge->error != BridgeNoError) {
		anal->error = AnalBadBridge;
		return;
	}

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

	if (!loading) {
		loading = local_loading;
		init_loading(loading);
		setup_loading(loading, bridge, geometry, params);
	}

	// Since calloc returns zero'ed memory, these are automagically false.
	Newz(260, anal->x_restraint, bridge->n_joints + 1, TBool);
	Newz(270, anal->y_restraint, bridge->n_joints + 1, TBool);

	// Apply restraints.

	// Assume simple support.  Left side...
	anal->x_restraint[1] = anal->y_restraint[1] = True;
	// Right side...
	anal->y_restraint[bridge->load_scenario.n_loaded_joints] = True;

	// Set up index to point to joint after last loaded joint.
	joint_index = bridge->load_scenario.n_loaded_joints + 1;

	// Adjust for intermediate support.
	if (bridge->load_scenario.support_type & INTERMEDIATE_SUPPORT) {
		if (bridge->load_scenario.support_type & HI_NOT_LO) {
			anal->x_restraint[bridge->load_scenario.intermediate_support_joint_no] = 
				anal->y_restraint[bridge->load_scenario.intermediate_support_joint_no] = True;
			anal->x_restraint[1] = False;
		}
		else {
			anal->x_restraint[joint_index] = anal->y_restraint[joint_index] = True;
			joint_index++;
		}
	}

	// And arches
	if (bridge->load_scenario.support_type & ARCH_SUPPORT) {

		// Set x and y restraints for both arch supports.
		anal->x_restraint[joint_index] = anal->y_restraint[joint_index] = True;
		joint_index++;
		anal->x_restraint[joint_index] = anal->y_restraint[joint_index] = True;
		joint_index++;

		// Undo simple support.  Left side...
		anal->x_restraint[1] = anal->y_restraint[1] = False;
		// Right side...
		anal->y_restraint[bridge->load_scenario.n_loaded_joints] = False;
	}

	// And cable supports
	if (bridge->load_scenario.support_type & CABLE_SUPPORT_LEFT)  {
		anal->x_restraint[joint_index] = anal->y_restraint[joint_index] = True;
		joint_index++;
	}
	if (bridge->load_scenario.support_type & CABLE_SUPPORT_RIGHT)  {
		anal->x_restraint[joint_index] = anal->y_restraint[joint_index] = True;
		joint_index++;
	}

	Newz(280, anal->stiffness, n_equations * n_equations, TFloat);

	// Go through this hassle to save some memory for cache coherency.
	#define Stiffness(I, J) (anal->stiffness[((I)-1) * n_equations + ((J)-1)])

	// Initialize stiffness matrix.

	for (member_index = 1; member_index <= bridge->n_members; member_index++) {
		unsigned j1 = bridge->members[member_index].start_joint;
		unsigned j2 = bridge->members[member_index].end_joint;
		TXSection *xs = &bridge->members[member_index].x_section;
		TFloat aeoverl = params->shapes[xs->section][xs->size].area * params->materials[xs->material].E / geometry->length[member_index];
		TFloat xx = aeoverl * sqr(geometry->cos_x[member_index]);
		TFloat yy = aeoverl * sqr(geometry->cos_y[member_index]);
		TFloat xy = aeoverl * geometry->cos_x[member_index] * geometry->cos_y[member_index];
		unsigned j12m1 = 2 * j1 - 1;
		unsigned j12 = 2 * j1;
		unsigned j22m1 = 2 * j2 - 1;
		unsigned j22 = 2 * j2;
		Stiffness(j12m1, j12m1) += xx;
		Stiffness(j12m1, j12)	+= xy;
		Stiffness(j12m1, j22m1) -= xx;
		Stiffness(j12m1, j22)	-= xy;
		Stiffness(j12, j12m1)	+= xy;
		Stiffness(j12, j12) 	+= yy;
		Stiffness(j12, j22m1)	-= xy;
		Stiffness(j12, j22) 	-= yy;
		Stiffness(j22m1, j12m1) -= xx;
		Stiffness(j22m1, j12)	-= xy;
		Stiffness(j22m1, j22m1) += xx;
		Stiffness(j22m1, j22)	+= xy;
		Stiffness(j22, j12m1)	-= xy;
		Stiffness(j22, j12) 	-= yy;
		Stiffness(j22, j22m1)	+= xy;
		Stiffness(j22, j22) 	+= yy;
	}

	// Apply support restraints.

	for (load_instance_index = 1; load_instance_index <= loading->n_load_instances; load_instance_index++) {
		TLoadInstance *load_instance = &loading->load_instances[load_instance_index];
		for (joint_index = 1; joint_index <= bridge->n_joints; joint_index++) {
			if (anal->x_restraint[joint_index]) {
				unsigned i2m1 = 2 * joint_index - 1;
				unsigned j;
				for (j = 1; j <= n_equations; j++)
					Stiffness(i2m1, j) = Stiffness(j, i2m1) = 0;
				Stiffness(i2m1, i2m1) = 1;
				load_instance->point_load[i2m1] = 0;
			}
			if (anal->y_restraint[joint_index]) {
				unsigned i2 = 2 * joint_index;
				unsigned j;
				for (j = 1; j <= n_equations; j++)
					Stiffness(i2, j) = Stiffness(j, i2) = 0;
				Stiffness(i2, i2) = 1;
				load_instance->point_load[i2] = 0;
			}
		}
	}

	// Invert.

	for (equation_index = 1; equation_index <= n_equations; equation_index++) {

		unsigned j, k;
		TFloat pivr;

		TFloat pivot = Stiffness(equation_index, equation_index);
		if (fabs(pivot) < 0.99) {
			anal->error = AnalBadPivot;
			return;
		}

		pivr = 1.0 / pivot;
		for (k = 1; k <= n_equations; k++)
			Stiffness(equation_index, k) /= pivot;

		for (k = 1; k <= n_equations; k++) {
			if (k != equation_index) {
				pivot = Stiffness(k, equation_index);
				for (j = 1; j <= n_equations; j++) 
					Stiffness(k, j) -= Stiffness(equation_index, j) * pivot;
				Stiffness(k, equation_index) = -pivot * pivr;
			}
		}
		Stiffness(equation_index, equation_index) = pivr;
	}

	Newz(290, anal->displacement, n_equations * loading->n_load_instances, TFloat);
	Newz(300, anal->member_force, bridge->n_members * loading->n_load_instances, TFloat);

#define Displacement(I, J)	(anal->displacement[((I)-1) * loading->n_load_instances + ((J)-1)])
#define MemberForce(I, J)	(anal->member_force[((I)-1) * loading->n_load_instances + ((J)-1)])

	// Compute joint displacements.
	
	for (load_instance_index = 1; load_instance_index <= loading->n_load_instances; load_instance_index++) {
		unsigned i, j;
		for (i = 1; i <= n_equations; i++) {
			TFloat tmp = 0;
			for (j = 1; j <= n_equations; j++)
				tmp += Stiffness(i, j) * loading->load_instances[load_instance_index].point_load[j];
			Displacement(i, load_instance_index) = tmp;
		}

#ifdef TEST_PRINT
		printf("\nJoint displacements for Load Case %d\n", load_instance_index);
		printf("Jnt #     /\\X         /\\Y\n");
		printf("----- ----------- -----------\n");
		for (i = 1; i <= bridge->n_joints; i++) {
			TFloat d1 = Displacement(2 * i - 1, load_instance_index);
			TFloat d2 = Displacement(2 * i, load_instance_index);
			printf("%5d %11.5lf %11.5lf\n", i, d1, d2);
		}
#endif

		// Compute end forces.

		for (member_index = 1; member_index <= bridge->n_members; member_index++) {
			TXSection *xs = &bridge->members[member_index].x_section;
			TFloat ae_over_l = params->shapes[xs->section][xs->size].area * 
				params->materials[xs->material].E / 
				geometry->length[member_index];
			unsigned j1 = bridge->members[member_index].start_joint;
			unsigned j2 = bridge->members[member_index].end_joint;
			MemberForce(member_index, load_instance_index) = 
				ae_over_l * 
				((geometry->cos_x[member_index] * 
					(Displacement((2 * j2 - 1), load_instance_index) - 
					 Displacement((2 * j1 - 1), load_instance_index))) + 
				 (geometry->cos_y[member_index] * 
					(Displacement((2 * j2), load_instance_index) - 
					 Displacement((2 * j1), load_instance_index))));
		}
	}

	// Compute member strengths.

	Newz(310, anal->member_strength, bridge->n_members + 1, TMemberStrength);

	for (member_index = 1; member_index <= bridge->n_members;  member_index++) {
		TXSection *xs = &bridge->members[member_index].x_section;
		TMemberStrength *s = &anal->member_strength[member_index];
		TFloat Fy = params->materials[xs->material].Fy;
		TFloat area = params->shapes[xs->section][xs->size].area;
		TFloat moment = params->shapes[xs->section][xs->size].moment;
		TFloat radius_of_gyration =  (area > 0) ? sqrt(moment / area) : 0;
		TFloat slenderness = (radius_of_gyration > 0) ? geometry->length[member_index] / radius_of_gyration : 0;

		// if the bridge has cable support joints or else slenderness is not excessive
		if ((bridge->load_scenario.support_type & (CABLE_SUPPORT_LEFT | CABLE_SUPPORT_RIGHT)) != 0 ||
			slenderness < params->slenderness_limit) {

			// New lambda point method.
			TFloat lambda = 
				sqr(geometry->length[member_index]) * Fy * area / 
				(9.8696044 * params->materials[xs->material].E * moment);
			if (lambda <= 2.25) {
				s->compressive_fail_mode = FailModeYields;	// now a misnomer, but usable for debugging
				s->compressive = 
					params->compression_resistance_factor * pow(0.66, lambda) * Fy * area;
			}
			else {
				s->compressive_fail_mode = FailModeBuckles; // now a misnomer, but usable for debugging
				s->compressive =
					params->compression_resistance_factor * 0.88 * Fy * area / lambda;
			}

			s->tensile_fail_mode = FailModeYields;
			s->tensile = params->tension_resistance_factor * Fy * area;
		}
		else {
			s->compressive_fail_mode = s->tensile_fail_mode = FailModeSlenderness;
			s->compressive = s->tensile = 0;
		}
	}

	// Summarize results.

	Newz(320, anal->max_forces, bridge->n_members + 1, TMaxForces);

	anal->n_compressive_failures = 0;
	anal->n_tensile_failures = 0;
	for (member_index = 1; member_index <= bridge->n_members; member_index++) {
		TFloat max_compression = 0;
		TFloat max_tension = 0;
		for (load_instance_index = 1; load_instance_index <= loading->n_load_instances; load_instance_index++) {
			if (MemberForce(member_index, load_instance_index) < 0)
				fold_max(&max_compression, -MemberForce(member_index, load_instance_index));
			else
				fold_max(&max_tension, MemberForce(member_index, load_instance_index));
		}
		anal->max_forces[member_index].compression = max_compression;
		anal->max_forces[member_index].tension = max_tension;

		if (anal->member_strength[member_index].compressive_fail_mode != FailModeSlenderness && 
				max_compression < anal->member_strength[member_index].compressive)
			anal->member_strength[member_index].compressive_fail_mode = FailModeNone;
		else
			anal->n_compressive_failures++;

		if (anal->member_strength[member_index].tensile_fail_mode != FailModeSlenderness &&
				max_tension < anal->member_strength[member_index].tensile)
			anal->member_strength[member_index].tensile_fail_mode = FailModeNone;
		else
			anal->n_tensile_failures++;
	}

	if (geometry == local_geometry)
		clear_geometry(geometry);
	if (params == local_params)
		clear_params(params);
	if (loading == local_loading)
		clear_loading(loading);
}

// Struct that describes what happened in analysis.
/*
struct analysis_result_t {
	TVersion version;			// WPBDC version of parsed bridge.
	TScenarioIndex scenario;	// WPBDC scenario number.
	TTestStatus test_status;	// Load test flag from uploaded file.
	int status; 				// Summary status
	TBridgeError error; 		// Bridge error condition.
	double cost;				// Cost in dollars.
	char hash[HASH_SIZE];		// Bridge hash value.
};
*/

// Do an analysis.	Intermediate buffers may be passed in.
// If they are, the caller is responsible for clearing them.
void do_analyze(STRING *bridge_as_string, 
				TAnalysis *analysis,
				TBridge *bridge,
				TGeometry *geometry,
				TLoading *loading,
				TParams *params,
				struct analysis_result_t *result)
{
	TAnalysis local_analysis[1];
	TBridge local_bridge[1];
	TGeometry local_geometry[1];
	TLoading local_loading[1];
	TParams local_params[1];
	struct analysis_result_t local_result[1];

	// User our own memory if caller didn't provide any.
	// Make sure to clear at end.
	if (!analysis)
		analysis = local_analysis;
	if (!bridge)
		bridge = local_bridge;
	if (!geometry)
		geometry = local_geometry;
	if (!loading)
		loading = local_loading;
	if (!params)
		params = local_params;

	init_analysis(analysis);
	init_bridge(bridge);
	init_geometry(geometry);
	init_loading(loading);
	init_params(params);

	// Does not have to be cleared at end.
	if (!result)
		result = local_result;

	// Fill result with zeros for cases where we find an error.
	memset(result, 0, sizeof(struct analysis_result_t));

	// Convert string to a bridge data structure.
	parse_bridge(bridge, bridge_as_string);

	// Fill in result data structure.
	result->version = bridge->version;
	strncpy(result->scenario_id, bridge->scenario_descriptor.id, SCENARIO_ID_SIZE);
	strncpy(result->scenario_number, bridge->scenario_descriptor.number, SCENARIO_NUMBER_SIZE);
	result->test_status = bridge->test_status;
	result->error = bridge->error;

	// Handle parse errors.
	result->status = BRIDGE_OK;
	if (bridge->error == BridgeBadHeader) {
		result->status = BRIDGE_WRONGVERSION;
		goto err_rtn;
	}
	if (bridge->error != BridgeNoError) {
		result->status = BRIDGE_MALFORMED;
		goto err_rtn;
	}
	if (hash_bridge(bridge, result->hash) != 0) {
		result->status = BRIDGE_MALFORMED;
		goto err_rtn;
	}

	// Run the load test.
	setup_params(params);
	setup_geometry(geometry, bridge);
	setup_loading(loading, bridge, geometry, params);
	setup_analysis(analysis, bridge, geometry, loading, params);
	if (analysis->error != NoAnalError ||
		analysis->n_compressive_failures > 0 ||
		analysis->n_tensile_failures > 0) {
		result->status = BRIDGE_FAILEDTEST;
		goto err_rtn;
	}

	// Compute cost.
	result->cost = floor(100 * bridge_cost(bridge, geometry, params) + 0.5);

	// Clear any storage not tied to bufferprovided by user.
err_rtn:
	if (analysis == local_analysis)
		clear_analysis(analysis);
	if (bridge == local_bridge)
		clear_bridge(bridge);
	if (geometry == local_geometry)
		clear_geometry(geometry);
	if (loading == local_loading)
		clear_loading(loading);
	if (params == local_params)
		clear_params(params);
}

char *analysis_to_html(TAnalysis *analysis, 
					   TBridge *bridge,
					   TGeometry *geometry,
					   TLoading *loading, 
					   TParams *params,
					   struct analysis_result_t *result)
{
	size_t rtn_size = 1024 * 8;
	char *rtn, *p;
	char buf[1024];
	unsigned member_index;
	TLoadScenario *ls;

#define Append(S)	do {							\
	char *q = (S);									\
	while ((*p = *q++) != 0)						\
		if (++p >= rtn + rtn_size) {				\
			unsigned p_ofs = p - rtn;				\
			rtn_size *= 2;							\
			Renew(rtn, rtn_size, char); 			\
			p = rtn + p_ofs;						\
		}											\
	} while (0)

#define AppendInt(X)	do {						\
		sprintf(buf, "%d", (X));					\
		Append(buf);								\
	} while (0)

#define AppendFloat(X,N)	do {					\
		sprintf(buf, "%." #N "lf", (double)(X));	\
		Append(buf);								\
	} while (0)

	assert(analysis);
	assert(bridge);
	assert(geometry);
	assert(loading);
	assert(params);
	// result is optional

	ls = &bridge->load_scenario;

	// Allocate an initial return buffer.
	New(140, rtn, rtn_size, char);
	p = rtn;

	if (analysis->error) {
		sprintf(buf, "Analysis error: %d\n", analysis->error);
		Append(buf);
		return rtn;
	}

	// Header 
	Append(
		"<table class=\"analysis\">\n"
		"<tr><th class=\"analysis_head\" colspan=15>"
	);	
	Append("Load Test Results Report (Design Iteration #");
	AppendInt(bridge->n_design_iterations);
	Append(", Scenario id ");
	Append(bridge->scenario_descriptor.id);
	Append(", number ");
	Append(bridge->scenario_descriptor.number);
	Append(", Cost $");
	if (result)
		AppendFloat(result->cost/100, 2);
	else
		AppendFloat(bridge_cost(bridge, geometry, params), 2);
	Append(
		")</th></tr>\n"
		"<tr>\n"
		" <th class=\"analysis_head\" colspan=5>Member</th><th class=\"analysis_head\">&nbsp;</th><th class=\"analysis_head\" colspan=4>Compression</th><th class=\"analysis_head\" >&nbsp;</th><th class=\"analysis_head\" colspan=4>Tension</th>"
		"</tr>\n"
		"<tr>\n"
		" <th class=\"analysis_head\">#</th><th class=\"analysis_head\">Size</th><th class=\"analysis_head\">Section</th><th class=\"analysis_head\">Matl.</th><th class=\"analysis_head\">Length<br>(m)</th>\n"
		" <th class=\"analysis_head\">&nbsp;</th>\n"
		" <th class=\"analysis_head\">Force<br>(kN)</th><th class=\"analysis_head\">Strength<br>(kN)</th><th class=\"analysis_head\">Force/<br>Strength</th><th class=\"analysis_head\">Status</th>\n"
		" <th class=\"analysis_head\">&nbsp;</th>\n"
		" <th class=\"analysis_head\">Force<br>(kN)</th><th class=\"analysis_head\">Strength<br>(kN)</th><th class=\"analysis_head\">Force/<br>Strength</th><th class=\"analysis_head\">Status</th>\n"
		"</tr>\n"
	);

	for (member_index = 1; member_index <= bridge->n_members; member_index++) {
		TXSection *xs = &bridge->members[member_index].x_section;
		TFloat compressive = analysis->member_strength[member_index].compressive;
		TFloat tensile = analysis->member_strength[member_index].tensile;
		Append("<tr>\n"
			" <td align=\"right\">");
		AppendInt(member_index);
		Append("</td>\n"
			" <td align=\"right\">");
		Append(params->shapes[xs->section][xs->size].name);
		Append("</td>\n"
			" <td align=\"center\">");
		Append(section_str(xs->section));
		Append("</td>\n"
			" <td align=\"center\">");
		Append(params->materials[xs->material].short_name);
		Append("</td>\n"
			" <td align=\"right\">");
		AppendFloat(geometry->length[member_index], 2);
		Append("</td>\n"
			" <td>&nbsp;</td>\n"
			" <td align=\"right\">");
		AppendFloat(analysis->max_forces[member_index].compression, 1);
		Append("</td>\n"
			" <td align=\"right\">");
		AppendFloat(compressive, 1); 
		Append("</td>\n"
			" <td align=\"right\">");
		if (compressive > 0) 
			AppendFloat(analysis->max_forces[member_index].compression/compressive, 4);
		else
			Append("&nbsp;oo");
		Append("</td>\n");
		switch (analysis->member_strength[member_index].compressive_fail_mode) {
		case FailModeNone:
			Append(" <td bgcolor=\"#C0FFC0\" align=\"center\">OK");
			break;
		case FailModeSlenderness:
			Append(" <td bgcolor=\"#FF60FF\" align=\"center\">Fail");
			break;
		default:
			Append(" <td bgcolor=\"#FFC0C0\" align=\"center\">Fail");
			break;
		}
		Append("</td>\n"
			" <td>&nbsp;</td>\n"
			" <td align=\"right\">");
		AppendFloat(analysis->max_forces[member_index].tension, 1);
		Append("</td>\n"
			" <td align=\"right\">");
		AppendFloat(tensile, 1);
		Append("</td>\n"
			" <td align=\"right\">");
		if (tensile > 0) 
			AppendFloat(analysis->max_forces[member_index].tension/tensile, 4);
		else
			Append("&nbsp;oo");
		Append("</td>\n");
		switch (analysis->member_strength[member_index].tensile_fail_mode) {
		case FailModeNone:
			Append(" <td bgcolor=\"#C0FFC0\" align=\"center\">OK");
			break;
		case FailModeSlenderness:
			Append(" <td bgcolor=\"#FF60FF\" align=\"center\">Fail");
			break;
		default:
			Append(" <td bgcolor=\"#FFC0C0\" align=\"center\">Fail");
			break;
		}
		Append("</td>\n"
			"</tr>\n");
	}
	Append("</table>\n");

	return rtn;
}

static char *test_status_str[] = {
	"Unrecorded",
	"Untested",
	"Failed",
	"Passed",
};

void print_analysis(FILE *f, 
					TAnalysis *anal, 
					TBridge *bridge,
					TGeometry *geometry,
					TLoading *loading, 
					TParams *params)
{
	unsigned member_index;

	print_params(f, params);

	if (anal->error) {
		fprintf(f, "Analysis error: %d\n", anal->error);
		return;
	}

	fprintf(f, "\n\nV%x bridge '%s' by '%s' scenario id=%s #=%s, status=%s, iter=%d:\n",
		bridge->version,
		bridge->project_id,
		bridge->designer,
		bridge->scenario_descriptor.id,
		bridge->scenario_descriptor.number,
		bridge->test_status >= 0 ? test_status_str[bridge->test_status] : "Null",
		bridge->n_design_iterations);

	fprintf(f, 
		" Mem      Member       Member   Compression Compression Compression ?   Tension     Tension     Tension   ?\n"
		"  #        Size        Length      Force      Strength     Ratio    ?    Force      Strength     Ratio    ?\n"
		"----- -------------- ---------- ----------- ----------- ----------- - ----------- ----------- ----------- -\n");

	for (member_index = 1; member_index <= bridge->n_members; member_index++) {
		TXSection *xs = &bridge->members[member_index].x_section;
		TFloat compressive = anal->member_strength[member_index].compressive;
		TFloat tensile = anal->member_strength[member_index].tensile;
		fprintf(f, "%5d %14s %10.1lf %11.5lf %11.5lf %11.6lf %c %11.5lf %11.5lf %11.6lf %c\n", 
			member_index, 
			params->shapes[xs->section][xs->size].name,
			geometry->length[member_index],
			(double)anal->max_forces[member_index].compression, 
			(double)compressive, 
			compressive > 0 ? (double)anal->max_forces[member_index].compression/compressive : 0.0,
			anal->member_strength[member_index].compressive_fail_mode == FailModeNone ? ' ' : '*',
			(double)anal->max_forces[member_index].tension, 
			(double)tensile,
			tensile > 0 ? (double)anal->max_forces[member_index].tension/tensile : 0.0,
			anal->member_strength[member_index].tensile_fail_mode == FailModeNone ? ' ' : '*');
	}
}

