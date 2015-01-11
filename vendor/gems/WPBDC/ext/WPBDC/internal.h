#ifndef _INTERNAL_H
#define _INTERNAL_H

// ---------------------------------------------------------------------
// --------Internal Data Structures and Constants ----------------------
// ---------------------------------------------------------------------

/* 
  Memory management convention:

  Data structures TBridge, TGeometry, TLoading, and TAnalysis are managed according
  to the following conventions.

	o  Caller allocates these objects.  Our favorite allocation is as an array
		of one element, e.g. TBridge bridge[1], so that the name 'bridge' can be
		used as a pointer, avoiding a lot of &s in the code.
	o  Caller initializes a freshly allocated object by calling init_foo for an
		object of type TFoo, e.g. init_bridge(bridge) for a TBridge.
	o  Caller "fills in" the initialized object by appropriate calls to "setup_foo"
		"parse_foo", etc.
	o  Callers deallocate memory allocated by "fill in" routines by calling clear_foo.
	o  The clear_foo routines leave the object just as after init_foo.
	o  Most fill in routines begin by calling clear_foo and then allocate (malloc or calloc)
		fresh internal storage for the object, e.g. for joint and member vectors in a TBridge.
 */

// Need rubyish memory allocators.
#include "rubydefs.h"

// External interface
#include "judge.h"

// Defines that we don't want visible as Perl constants.
#define True	((TBool)1)
#define False	((TBool)0)
#define STATIC_ARRAY_SIZE(A)	(sizeof A/sizeof A[0])
#define _STR(P)	#P
#define STR(P)	_STR(P)

#define NewStrSz(x,v,s,sz)			\
	do {							\
		sz = strlen(s)+1;			\
		New(x, v, sz, char);		\
		memcpy(v, s, sz);			\
	} while (0)

#define NewStr(x,v,s)				\
	do {							\
		unsigned sz;				\
		NewStrSz(x,v,s,sz);			\
	} while (0)

// Basic stuff.
typedef unsigned char TBool;				// 1 byte
typedef double TFloat;						// 8 bytes
typedef signed short TCoordinate;			// 2 bytes
typedef unsigned short TElementNumber;		// 2 bytes

// ---------------------------------------------------------------------
// -------- Structural elements ----------------------------------------
// ---------------------------------------------------------------------

// Bridge joint.
typedef struct joint_t {
	TElementNumber number;
	TCoordinate x, y;
} TJoint;

// Member cross-section attributes.
typedef struct x_section_t {
	TElementNumber material;
	TElementNumber section;
	TElementNumber size;
} TXSection;

#define FORCE_STR_SIZE	16

// Bridge structural member.
typedef struct member_t {
	TElementNumber number;
	TElementNumber start_joint, end_joint;
	TXSection x_section;
	char compression[FORCE_STR_SIZE];
	char tension[FORCE_STR_SIZE];
} TMember;

// ---------------------------------------------------------------------
// -------- Load scenarios ---------------------------------------------
// ---------------------------------------------------------------------

typedef unsigned TSupportType;

// Known support type categories.
#define ARCH_SUPPORT			(1)
#define CABLE_SUPPORT_LEFT		(2)
#define CABLE_SUPPORT_RIGHT		(4)
#define	INTERMEDIATE_SUPPORT	(8)
#define	HI_NOT_LO				(16)

// Cable anchorage offset in grid units
#define CABLE_ANCHORAGE_X_OFFSET	32

// Scenario description.
typedef enum load_scenario_error_t {
	LoadScenarioNoError,
	LoadScenarioIndexRange,
	LoadScenarioIndexValue,
} TLoadScenarioError;

// Load scenario. DON'T CHANGE THIS without changing the initialization constant below.
typedef struct load_scenario_t {
	TLoadScenarioError error;						// Error status.
	TFloat grid_size;								// Size of grid squares where joints are plotted.
	TFloat joint_radius;							// Radius of joint graphic.
	unsigned load_case;								// Load case 0 = A, 1 = B, 2 = C, 3 = D.
	unsigned n_panels;								// Number of panels in deck.
	unsigned num_length_grids;						// Number of grid squares in X direction.
	unsigned over_meters;							// Number of meters over the roadway allowed for truss height.
	unsigned over_grids;							// Number of grid squares above road surface (Y positive).
	unsigned under_meters;							// Number of meters under the roadway allowed for truss.
	unsigned under_grids;							// Number of grid squares below road surface (Y negative).
	TSupportType support_type;						// Type of support.
	TElementNumber intermediate_support_joint_no;	// Joint number of intermediate support; 0 if none.
	TElementNumber n_loaded_joints;					// Number of loaded joints (joints connected to road surface).
	unsigned n_prescribed_joints;					// Number of prescribed joints in this scenario.
	TJoint *prescribed_joints;						// List of joints determined by scenario.
} TLoadScenario;

#define INIT_LOAD_SCENARIO																		\
{						/* TLoadScenario load_scenario;										*/	\
	LoadScenarioNoError,	/* Error status.												*/	\
	0.0,					/* Size of grid squares where joints are plotted.				*/	\
	0.0,					/* Radius of joint graphic.										*/	\
	0,						/* Load case 0 = A, 1 = B, 2 = C, 3 = D.						*/	\
	0,						/* Number of panels in deck.									*/	\
	0,						/* Number of grid squares in X direction.						*/	\
	0,						/* Number of meters over the roadway allowed for truss height.	*/	\
	0,						/* Number of grid squares above road surface (Y positive).		*/	\
	0,						/* Number of meters under the roadway allowed for truss.		*/	\
	0,						/* Number of grid squares below road surface (Y negative).		*/	\
	-1,					 	/* Type of support.												*/	\
	0,						/* Joint number of intermediate support; 0 if none.				*/	\
	0,						/* Number of loaded joints (joints connected to road surface).	*/	\
	0,						/* Number of prescribed joints in this scenario.				*/	\
	(TJoint*)0,				/* List of joints determined by scenario.						*/	\
}

typedef struct scenario_descriptor_t {
	int index;							// -1 for error condition
	char id[SCENARIO_ID_SIZE + 1];
	char number[SCENARIO_NUMBER_SIZE + 1];
	TFloat site_cost;
} TScenarioDescriptor;

#define NULL_SCENARIO_DESCRIPTOR { -1, "----------", "---", -1 }

// ---------------------------------------------------------------------
// -------- Bridge -----------------------------------------------------
// ---------------------------------------------------------------------

// A compleat bridge. DON'T CHANGE THIS without re-aligning the
// initialization constant below.
typedef struct bridge_t {

	TBridgeError error;							// Parse error if any.
	unsigned error_line;						// Line where error occurred, 0 if none.

	TVersion version;							// WPBD version
	TTestStatus test_status;					// Client-recorded test status of design.
	TScenarioDescriptor scenario_descriptor;	// Scenario code, all blank if none.
	char *designer;								// Name of designer as string.
	char *project_id;							// Name of project as string.
	unsigned n_design_iterations;				// Number of design iterations.
	TElementNumber n_joints;					// Number of joints in bridge.
	TJoint *joints;								// Vector of joints.
	TElementNumber n_members;					// Number of members in bridge.
	TMember *members;							// Vector of members.
	double label_pos;							// Where labels are put on early, small projects.
	TLoadScenario load_scenario;				// Load data for this scenario.
} TBridge;

#define INIT_BRIDGE																\
{							/* TBrdige bridge;								*/	\
	BridgeNoError,				/* TBridgeError error;						*/	\
	~0u,						/* unsigned error_line;						*/	\
																				\
	0x0000,						/* TVersion version;						*/	\
	NullTestStatus,				/* TTestStatus test_status;					*/	\
	NULL_SCENARIO_DESCRIPTOR,	/* TScenarioDescriptor scenario_descriptor;	*/	\
	NULL,						/* char *designer;							*/	\
	NULL,						/* char *project_id;						*/	\
	0,							/* unsigned n_design_iterations;			*/	\
	0,							/* TElementNumber n_joints;					*/	\
	NULL,						/* TJoint *joints;							*/	\
	0,							/* TElementNumber n_members;				*/	\
	NULL,						/* TMember *members;						*/	\
	-1.0,						/* double label_pos;						*/	\
	INIT_LOAD_SCENARIO															\
}

// Max line length in an unpacked bridge file.
#define MAX_LINE_LENGTH	512

// ---------------------------------------------------------------------
// -------- Parameters (of scenarios) ----------------------------------
// ---------------------------------------------------------------------

// Descriptors of member cross-sections.
#define NMaterials	3				// Number of available materials.
#define	NSections	2				// Number of available sections.

// The available sections themselves (must match NSections above).
typedef enum section_t {
	Bar,
	Tube,
} TSection;

// Number of sizes of Bars available (corresponds to TSection above).
#define NBarSizes	33

// Number of sizes of Tubes available (corresponds to TSection above).				
#define NTubeSizes	33

// Max of above sizes.
#define MaxNSizes	33

// Descriptor for a material.
typedef struct material_t {
	char *name;						// Name as string.
	char *short_name;				// Name as a short string (for tables).
	TFloat E;						// Modulus of elasticity.
	TFloat Fy;						// Yield strength.
	TFloat density;					// Density in Kg/m^3.
	TFloat cost[NSections];			// Cost in dollars per cm^3 by section.
} TMaterial;

// Descriptor for a structural shape.
typedef struct shape_t {
	char *name;						// Name as string.
	TFloat width;					// Width dimension.
	TFloat area;					// Cross-sectional area, m^3.
	TFloat moment;					// First moment.
} TShape;

#define NLoadCases 4

typedef struct load_case_t {
	char *name;								// Name as string.
	TFloat point_dead_load;					// Dead load due to roadway.
	TFloat front_axle_load;					// Live load due to front axle.
	TFloat rear_axle_load;					// Live load due to rear axle.
} TLoadCase;

// Parameters of analysis.
typedef struct params_t {
	TFloat slenderness_limit;				// The least illegal slenderness value.
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

#define INIT_CONSTANT_PARAMS																\
{																							\
	300,										/* Slenderness limit */						\
	DEAD_LOAD_FACTOR,							/* TFloat dead_load_factor; */				\
	1.75 * 1.33,								/* TFloat live_load_factor; */				\
	0.90,										/* TFloat compression_resistance_factor; */	\
	0.95,										/* TFloat tension_resistance_factor; */		\
	{											/* TLoadCase load_cases[NLoadCases]; */		\
		{	/* [0] */																		\
			"Case A (Heavy Deck, Light Truck)",												\
			DEAD_LOAD_FACTOR * 120.265 + 33.097,		/* TFloat point_dead_load; */		\
			44,											/* TFloat front_axle_load; */		\
			181,										/* TFloat rear_axle_load; */		\
		},																					\
		{	/* [1] */																		\
			"Case B (Heavy Deck, Heavy Truck)",												\
			DEAD_LOAD_FACTOR * 120.265 + 33.097,		/* TFloat point_dead_load; */		\
			124,										/* TFloat front_axle_load; */		\
			124,										/* TFloat rear_axle_load; */		\
		},																					\
		{	/* [2] */																		\
			"Case C (Light Deck, Light Truck)",												\
			DEAD_LOAD_FACTOR * 82.608 + 33.097,			/* TFloat point_dead_load; */		\
			44,											/* TFloat front_axle_load; */		\
			181,										/* TFloat rear_axle_load; */		\
		},																					\
		{	/* [3] */																		\
			"Case D (Light Deck, Heavy Truck)",												\
			DEAD_LOAD_FACTOR * 82.608 + 33.097,			/* TFloat point_dead_load; */		\
			124,										/* TFloat front_axle_load; */		\
			124,										/* TFloat rear_axle_load; */		\
		},																					\
	},																						\
	500,										/* TFloat connection_cost; */				\
	1000,										/* TFloat ordering_fee; */					\
	{	/* TMaterial materials[NMaterials];	*/												\
		{																					\
			"Carbon Steel (A36)",			/* char *name; */								\
			"CS",							/* char *short_name; */							\
			200000000,						/* TFloat E; */									\
			250000,							/* TFloat Fy; */								\
			7850,							/* TFloat density; */							\
			{								/* TFloat cost[NSections]; */					\
				4.30,							/* Bar */									\
				6.30,							/* Tube */									\
			}																				\
		},																					\
		{																					\
			"High Strength Steel (A572)",	/* char *name; */								\
			"HSS",							/* char *short_name; */							\
			200000000,						/* TFloat E; */									\
			345000,							/* TFloat Fy; */								\
			7850,							/* TFloat density; */							\
			{								/* TFloat cost[NSections]; */					\
				5.60,							/* Bar */									\
				7.00,							/* Tube	*/									\
			}																				\
		},																					\
		{																					\
			"Quenched & Tempered Steel",	/* char *name; */								\
			"QTS",							/* char *short_name; */							\
			200000000,						/* TFloat E; */									\
			485000,							/* TFloat Fy; */								\
			7850,							/* TFloat density; */							\
			{								/* TFloat cost[NSections]; */					\
				6.00,							/* Bar */									\
				7.70,							/* Tube	*/									\
			}																				\
		},																					\
	}																						\
}

// ---------------------------------------------------------------------
// -------- Geometry ---------------------------------------------------
// ---------------------------------------------------------------------

// Geometry info calculated from a bridge that we want to avoid
// recalculating. So we put it in here in order to pass it around for 
// subsequent calculations. 
typedef struct geometry_t {
	TFloat *cos_x, *cos_y;
	TFloat *length;
} TGeometry;

// ---------------------------------------------------------------------
// -------- Loadings and load instances --------------------------------
// ---------------------------------------------------------------------

// Information regarding a single load case.
typedef struct load_instance_t {
	TFloat *point_load;
} TLoadInstance;

// A loading consisting of a vector of load cases to analyze.
typedef struct loading_t {
	unsigned n_load_instances;
	TLoadInstance *load_instances;
} TLoading;

// ---------------------------------------------------------------------
// -------- Analyses ---------------------------------------------------
// ---------------------------------------------------------------------

// Errors that can happen when the truss is being analyzed.
typedef enum anal_err_t {
	NoAnalError,
	AnalBadBridge,
	AnalBadPivot,
} TAnalysisError;

// Ways that materials can fail in the V3 material model; overloaded 
// in the V4 model with two modes that are not really indicated by 
// the names.
typedef enum cmode_t {
	FailModeNone, 
	FailModeBuckles, 
	FailModeYields,
	FailModeSlenderness, // new for 2010
} TFailMode;

// Characterization of member strength and failure.
typedef struct strength_t {
	TFloat compressive;
	TFloat tensile;
	TFailMode compressive_fail_mode;
	TFailMode tensile_fail_mode;
} TMemberStrength;

// Record of max forces occurring at a member.
typedef struct max_forces_t {
	TFloat compression;
	TFloat tension;
} TMaxForces;

// All information associated with an analysis and its results.
// Arrays are indexed starting at 1, and the 0'th element is ignored.
typedef struct analysis_t {
	TAnalysisError error;
	TBool *x_restraint, *y_restraint;
	TFloat *stiffness;
	TFloat *displacement;
	TFloat *member_force;
	TMemberStrength *member_strength;
	TMaxForces *max_forces;
	unsigned n_compressive_failures;
	unsigned n_tensile_failures;
} TAnalysis;

// Key used to scramble bridge files.
extern char RC4_Key[];

// ---------------------------------------------------------------------
// -------- Prototypes -------------------------------------------------
// ---------------------------------------------------------------------

/* analysis.c */
void init_analysis(TAnalysis *anal);
void clear_analysis(TAnalysis *anal);
void setup_analysis(TAnalysis *anal, TBridge *bridge, TGeometry *geometry, TLoading *loading, TParams *params);
void do_analyze(STRING *bridge_as_string, TAnalysis *analysis, TBridge *bridge, TGeometry *geometry, TLoading *loading, TParams *params, struct analysis_result_t *result);
char *analysis_to_html(TAnalysis *analysis, TBridge *bridge, TGeometry *geometry, TLoading *loading, TParams *params, struct analysis_result_t *result);
char *analysis_to_text(TAnalysis *analysis, TBridge *bridge, TGeometry *geometry, TLoading *loading, TParams *params, struct analysis_result_t *result);
void print_analysis(FILE *f, TAnalysis *anal, TBridge *bridge, TGeometry *geometry, TLoading *loading, TParams *params);
/* bridge.c */
void init_bridge(TBridge *bridge);
void clear_bridge(TBridge *bridge);
TBool joint_lists_eq(TJoint *a, TJoint *b, unsigned n);
TBool x_section_lists_eq(TXSection *a, TXSection *b, unsigned n);
char *section_str(TSection section);
TBool member_lists_eq(TMember *a, TMember *b, unsigned n);
void copy_bridge(TBridge *dst, TBridge *src);
TBool bridges_indentical(TBridge *a, TBridge *b);
void canonicalize(TBridge *dst, TBridge *src);
void print_material(FILE *f, unsigned index, TMaterial *material);
void print_shape(FILE *f, unsigned section_index, unsigned size_index, TShape *shape);
/* bridge_cost.c */
int lookup_scenario_descriptor(TScenarioDescriptor *desc, char *id);
TFloat bridge_cost(TBridge *bridge, TGeometry *geometry, TParams *params);
int test_scenario_table(void);
/* bridge_hash.c */
void hashify_vec(unsigned int *v, unsigned v_len, unsigned int *hash, unsigned h_len);
char *hex_nibble(int n, char *p);
char *hex_byte(int b, char *p);
char *hex_str(char *s, unsigned n, char *p);
int hash_bridge(TBridge *bridge, char *hash);
/* bridge_parser.c */
char *get_line(char *buf, char **next);
char *parse_string(char *buf, char *str);
void basic_string(char *dst, char *src);
char *parse_comma(char *buf);
unsigned scan_unsigned(char *str, unsigned width, char **next);
int scan_int(char *str, unsigned width, char **next);
TTestStatus lookup_test_status_tag(const char *str);
char *get_to_delim(char *str, char **next);
void endecrypt_in_place(char *buf, int size);
void parse_bridge(TBridge *bridge, STRING *str);
void parse_unpacked_bridge_destructive(TBridge *bridge, char *str);
void parse_packed_bridge_destructive(TBridge *bridge, char *str);
char *unparse_bridge(TBridge *bridge);
char *unparse_packed_bridge(TBridge *bridge);
char *unparse_unpacked_bridge(TBridge *bridge);
void pack_bridge(STRING *in_str, STRING *out_str, TBool decrypt_p, TBool encrypt_p);
void unpack_bridge(STRING *in_str, STRING *out_str, TBool decrypt_p, TBool encrypt_p);
/* bridge_random.c */
void randomly_permute_unsigned(unsigned *v, unsigned n);
void randomly_permute_members(TMember *v, unsigned n);
void sample(unsigned *s, unsigned sn, unsigned m, unsigned n);
void perturb(TBridge *dst, TBridge *src, unsigned seed, unsigned n_joints, unsigned n_members);
int fix_failure(TBridge *dst, TBridge *src, TParams *params);
int induce_failure(TBridge *dst, TBridge *src, unsigned seed);
void vary(TBridge *dst, TBridge *src, unsigned seed);
/* bridge_sketch.c */
void do_sketch(TBridge *bridge, TAnalysis *analysis, int width, int height, COMPRESSED_IMAGE *compressed_image);
/* geometry.c */
void init_geometry(TGeometry *geometry);
void clear_geometry(TGeometry *geometry);
void setup_geometry(TGeometry *geometry, TBridge *bridge);
/* loading.c */
void init_loading(TLoading *loading);
void clear_loading(TLoading *loading);
void setup_loading(TLoading *loading, TBridge *bridge, TGeometry *geometry, TParams *params);
/* params.c */
unsigned n_sizes(TSection section);
void init_params(TParams *params);
void clear_params(TParams *params);
void setup_params(TParams *params);
void print_load_case(FILE *f, unsigned index, TLoadCase *load_case);
void print_params(FILE *f, TParams *params);
/* scenario.c */
char *local_contest_number_to_id(char *number);
void init_load_scenario(TLoadScenario *load_scenario);
void clear_load_scenario(TLoadScenario *load_scenario);
void setup_load_scenario(TLoadScenario *load_scenario, TScenarioDescriptor *desc);
void copy_load_scenario(TLoadScenario *dst, TLoadScenario *src);
/* sketch.c */
void init_image(IMAGE *image);
void clear_image(IMAGE *image);
void setup_image(IMAGE *image, UNSIGNED width, UNSIGNED height, RGB_TRIPLE *color);
void set_viewport(IMAGE *image, UNSIGNED x_left, UNSIGNED x_right, UNSIGNED y_bottom, UNSIGNED y_top);
void draw_line_raw(IMAGE *image, UNSIGNED x1, UNSIGNED y1, UNSIGNED x2, UNSIGNED y2, RGB_TRIPLE *color);
void draw_rect_raw(IMAGE *image, UNSIGNED x1, UNSIGNED y1, UNSIGNED x2, UNSIGNED y2, RGB_TRIPLE *color);
void clip_segment(FLOAT *x1p, FLOAT *y1p, FLOAT *x2p, FLOAT *y2p, FLOAT x_left, FLOAT x_right, FLOAT y_bottom, FLOAT y_top, int *segment_survives_p);
void draw_line(IMAGE *image, FLOAT x1, FLOAT y1, FLOAT x2, FLOAT y2, RGB_TRIPLE *color);
void init_compressed_image(COMPRESSED_IMAGE *compressed_image);
void clear_compressed_image(COMPRESSED_IMAGE *compressed_image);
int compress_image(IMAGE *image, COMPRESSED_IMAGE *compressed_image);

// Found by cproto with mkproto.bat and inserted by hand.


#endif
