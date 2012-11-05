/* analysis.c */
void init_analysis(TAnalysis *anal);
void clear_analysis(TAnalysis *anal);
void setup_analysis(TAnalysis *anal, TBridge *bridge, TGeometry *geometry, TLoading *loading, TParams *params);
void do_analyze(STRING *bridge_as_string, TAnalysis *analysis, TBridge *bridge, TGeometry *geometry, TLoading *loading, TParams *params, struct analysis_result_t *result);
char *analysis_to_html(TAnalysis *analysis, TBridge *bridge, TGeometry *geometry, TLoading *loading, TParams *params, struct analysis_result_t *result);
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
void hashify_vec(unsigned long *v, unsigned v_len, unsigned long *hash, unsigned h_len);
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
/* judge.c */
void endecrypt(STRING *bridge_as_string);
void analyze(STRING *bridge_as_string, struct analysis_result_t *result);
int compare(STRING *bridge_as_string_a, STRING *bridge_as_string_b);
char *variant(STRING *bridge_as_string, int seed);
char *failed_variant(STRING *bridge_as_string, int seed);
char *perturbation(STRING *bridge_as_string, int seed, int n_joints, int n_members);
void sketch(STRING *bridge_as_string, int width, int height, COMPRESSED_IMAGE *compressed_image, struct analysis_result_t *result);
char *analysis_table(STRING *bridge_as_string);
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
void init_load_scenario(TLoadScenario *load_scenario);
void clear_load_scenario(TLoadScenario *load_scenario);
void setup_load_scenario(TLoadScenario *load_scenario, unsigned scenario_index);
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
