#include "internal.h"

#define INIT_STRING_FROM_VALUE(String, Value) \
    STRING String[1] = {{ RSTRING_PTR(Value), RSTRING_LEN(Value) }}

static VALUE rb_api_endecrypt(VALUE self, VALUE bridge_as_string)
{
    INIT_STRING_FROM_VALUE(bridge_internal_string, bridge_as_string);
    endecrypt(bridge_internal_string);
    return bridge_as_string;
}

/*
struct analysis_result_t {
    TVersion version;                           // WPBDC version of parsed bridge.
    char scenario_id[SCENARIO_ID_SIZE];         // WPBDC scenario ID.
    char scenario_number[SCENARIO_NUMBER_SIZE]; // WPBDC scenario number.
    TTestStatus test_status;                    // Load test flag from uploaded file.
    int status;                                 // Summary status
    TBridgeError error;                         // Bridge error condition.
    double cost;                                // Cost in dollars.
    char hash[HASH_SIZE];                       // Bridge hash value.
};
*/

static VALUE symbol(char *name)
{
    return ID2SYM(rb_intern(name));
}

static void add_analysis_to_hash(VALUE hash, struct analysis_result_t *result)
{
    rb_hash_aset(hash, symbol("version"), INT2FIX(result->version));
    rb_hash_aset(hash, symbol("scenario_id"), rb_str_new(result->scenario_id, SCENARIO_ID_SIZE));
    rb_hash_aset(hash, symbol("scenario_number"), rb_str_new(result->scenario_number, SCENARIO_NUMBER_SIZE));
    rb_hash_aset(hash, symbol("test_status"), INT2FIX(result->test_status));
    rb_hash_aset(hash, symbol("status"), INT2FIX(result->status));
    rb_hash_aset(hash, symbol("error"), INT2FIX(result->error));
    rb_hash_aset(hash, symbol("cost"), rb_float_new(result->cost));
    if (result->status == BRIDGE_OK || result->status == BRIDGE_FAILEDTEST) {
        rb_hash_aset(hash, symbol("hash"), rb_str_new(result->hash, HASH_SIZE));
    }
}

static VALUE rb_api_analyze(VALUE self, VALUE bridge_as_string)
{
    INIT_STRING_FROM_VALUE(bridge_internal_string, bridge_as_string);
    struct analysis_result_t result[1];
    VALUE hash = rb_hash_new();
    analyze(bridge_internal_string, result);
    add_analysis_to_hash(hash, result);
    return hash;
}

static VALUE rb_api_are_same(VALUE self, VALUE bridge_as_string_a, VALUE bridge_as_string_b)
{
    INIT_STRING_FROM_VALUE(bridge_internal_string_a, bridge_as_string_a);
    INIT_STRING_FROM_VALUE(bridge_internal_string_b, bridge_as_string_b);
    int cmp = compare(bridge_internal_string_a, bridge_internal_string_b);
    return (cmp < 0) ? Qnil : (cmp > 0) ? Qtrue : Qfalse;
}

static VALUE c_str_to_value(char *s)
{
    if (s) {
        VALUE value = rb_str_new2(s);
        Safefree(s);
        return value;
    }
    return Qnil;
}

static VALUE rb_api_variant(VALUE self, VALUE bridge_as_string, VALUE seed)
{
    INIT_STRING_FROM_VALUE(bridge_internal_string, bridge_as_string);
    char *result = variant(bridge_internal_string, FIX2INT(seed));
    return c_str_to_value(result);
}

static VALUE rb_api_failed_variant(VALUE self, VALUE bridge_as_string, VALUE seed)
{
    INIT_STRING_FROM_VALUE(bridge_internal_string, bridge_as_string);
    char *result = failed_variant(bridge_internal_string, FIX2INT(seed));
    return c_str_to_value(result);
}

static VALUE rb_api_perturbation(VALUE self, VALUE bridge_as_string, VALUE seed, VALUE n_joints, VALUE n_members)
{
    INIT_STRING_FROM_VALUE(bridge_internal_string, bridge_as_string);
    char *result = perturbation(bridge_internal_string, FIX2INT(seed), FIX2INT(n_joints), FIX2INT(n_members));
    return c_str_to_value(result);
}

static VALUE rb_api_sketch(VALUE self, VALUE bridge_as_string, VALUE width, VALUE height)
{
    INIT_STRING_FROM_VALUE(bridge_internal_string, bridge_as_string);
	COMPRESSED_IMAGE compressed_image[1];
	struct analysis_result_t result[1];
    VALUE hash = rb_hash_new();

	init_compressed_image(compressed_image);
	sketch(bridge_internal_string, width, height, compressed_image, result);

    /*
    struct analysis_result_t {
        TVersion version;                           // WPBDC version of parsed bridge.
        char scenario_id[SCENARIO_ID_SIZE];         // WPBDC scenario ID.
        char scenario_number[SCENARIO_NUMBER_SIZE]; // WPBDC scenario number.
        TTestStatus test_status;                    // Load test flag from uploaded file.
        int status;                                 // Summary status
        TBridgeError error;                         // Bridge error condition.
        double cost;                                // Cost in dollars.
        char hash[HASH_SIZE];                       // Bridge hash value.
    };
    */
    add_analysis_to_hash(hash, result);
    if (result->status == BRIDGE_OK) {
        rb_hash_aset(hash, rb_str_new2("image"), rb_str_new(compressed_image->data, compressed_image->filled));
        clear_compressed_image(compressed_image);
    }
    return hash;
}

static VALUE rb_api_analysis_table(VALUE self, VALUE bridge_as_string)
{
    INIT_STRING_FROM_VALUE(bridge_internal_string, bridge_as_string);
    char *result = analysis_table(bridge_internal_string);
    return c_str_to_value(result);
}

static VALUE rb_api_local_contest_number_to_id(VALUE self, VALUE number_as_string)
{
    INIT_STRING_FROM_VALUE(number_internal_string, number_as_string);
    char id[SCENARIO_ID_SIZE + 1];
    look_up_local_contest_number(number_internal_string, id);
    return c_str_to_value(id[0] ? id : NULL);
}


#define FUNCTION(Name, Argc) { #Name, rb_api_ ## Name, Argc }

static struct ft_entry {
  char *name;
  VALUE (*func)();
  int argc;
} function_table[] = {
  FUNCTION(endecrypt, 1),
  FUNCTION(analyze, 1),
  FUNCTION(are_same, 2),
  FUNCTION(variant, 2),
  FUNCTION(failed_variant, 2),
  FUNCTION(perturbation, 4),
  FUNCTION(sketch, 3),
  FUNCTION(analysis_table, 1),
  FUNCTION(local_contest_number_to_id, 1),
};

#define INT_CONST(Name) { #Name, Name }

static struct ict_entry {
  char *name;
  int val;
} int_const_table[] = {
  INT_CONST(BRIDGE_OK),
  INT_CONST(BRIDGE_MALFORMED),
  INT_CONST(BRIDGE_WRONGVERSION),
  INT_CONST(BRIDGE_FAILEDTEST),

  INT_CONST(MAX_JOINTS),
  INT_CONST(MAX_MEMBERS),

  // Size of hash value in bytes.
  INT_CONST(HASH_SIZE),

  // Possible errors during bridge parsing.
  INT_CONST(BridgeNoError),
  INT_CONST(BridgeMissingData),
  INT_CONST(BridgeSyntax),
  INT_CONST(BridgeMissingHeader),
  INT_CONST(BridgeBadHeader),
  INT_CONST(BridgeMissingTestStatus),
  INT_CONST(BridgeBadTestStatus),
  INT_CONST(BridgeBadScenario),
  INT_CONST(BridgeBadNDesignIterations),
  INT_CONST(BridgeTooManyElements),
  INT_CONST(BridgeBadJointBanner),
  INT_CONST(BridgeTooFewJoints),
  INT_CONST(BridgeWrongPrescribedJoints),
  INT_CONST(BridgeBadMemberBanner),
  INT_CONST(BridgeTooFewMembers),
  INT_CONST(BridgeBadLabelPos),
  INT_CONST(BridgeExtraJunk),
  INT_CONST(BridgeDupJoints),
  INT_CONST(BridgeDupMembers),
  INT_CONST(BridgeJointOnMember),
  INT_CONST(BridgeBadLoadScenario),
  INT_CONST(BridgeBadChar),

  // Test status flag values read from bridge file.
  INT_CONST(NullTestStatus),
  INT_CONST(Unrecorded),
  INT_CONST(Untested),
  INT_CONST(Failed),
  INT_CONST(Passed),

  INT_CONST(SCENARIO_ID_SIZE),
  INT_CONST(SCENARIO_NUMBER_SIZE),
};

void Init_WPBDC(void)
{
  int i;
  VALUE module;

  module = rb_define_module("WPBDC");

  for (i = 0; i < STATIC_ARRAY_SIZE(function_table); i++) {
    struct ft_entry *e = function_table + i;
    rb_define_module_function(module, e->name, e->func, e->argc);
  }
  for (i = 0; i < STATIC_ARRAY_SIZE(int_const_table); i++) {
    struct ict_entry *e = int_const_table + i;
    rb_define_const(module, e->name, INT2FIX(e->val));
  }
}