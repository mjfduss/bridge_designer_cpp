#ifndef _JUDGE_H
#define _JUDGE_H

/*
 *
 * judge.h -- Ruby Extension WPBDC.  Support for the West Point 
 * Bicentennial Design Contest web site.  Ruby-visible constants
 * and functions.
 */

#include "rubydefs.h"
#include "sketch.h"

#define CONTEST_YEAR 2012
#define YEAR_TO_VERSION(Y) (((((Y) % 100) / 10) << 8) | (((Y) % 10) << 4) | 0x400c)
#define BD_VERSION YEAR_TO_VERSION(CONTEST_YEAR)

// The id for the semifinal scenario including a null value
#define NULL_SEMIFINAL_SCENARIO_ID "0000000000"

// When you set this, you _must_ change the scenario table so its record is in sorted order!
#define SEMIFINAL_SCENARIO_ID "3100003100"
//#define SEMIFINAL_SCENARIO_ID NULL_SEMIFINAL_SCENARIO_ID

// Status returns from analyze().
#define BRIDGE_OK           0
#define BRIDGE_MALFORMED    1
#define BRIDGE_WRONGVERSION 2
#define BRIDGE_FAILEDTEST   3

// Maximum element counts. Increased for 2012.
// #define MAX_JOINTS   50
// #define MAX_MEMBERS  120
#define MAX_JOINTS  100
#define MAX_MEMBERS 200

// Size of hash value in bytes.
#define HASH_SIZE   20

// Possible errors during bridge parsing.
typedef enum bridge_err_t {
    BridgeNoError,
    BridgeMissingData,
    BridgeSyntax,
    BridgeMissingHeader,
    BridgeBadHeader,
    BridgeMissingTestStatus,
    BridgeBadTestStatus,
    BridgeBadScenario,
    BridgeBadNDesignIterations,
    BridgeTooManyElements,
    BridgeBadJointBanner,
    BridgeTooFewJoints,
    BridgeWrongPrescribedJoints,
    BridgeBadMemberBanner,
    BridgeTooFewMembers,
    BridgeBadLabelPos,
    BridgeExtraJunk,
    BridgeDupJoints,
    BridgeDupMembers,
    BridgeJointOnMember,
    BridgeBadLoadScenario,
    BridgeBadChar,
} TBridgeError;

// Test status flag values read from bridge file.
typedef enum test_status_t {
    NullTestStatus = -1,
    Unrecorded,
    Untested,
    Failed,
    Passed,
} TTestStatus;

#define SCENARIO_ID_SIZE 10
#define SCENARIO_NUMBER_SIZE 3

// WPBD version number.
typedef unsigned short TVersion;            // 2 bytes

// Struct that describes what happened in analysis.
// We don't typedef it as a cue that it isn't covered
// by the standard init-setup-clear management protocol.
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

// This must match ruby string length type.
typedef long STRLEN;

// Representation for a string of arbitrary length, which may possibly 
// contain NULLs.  We'll convert RSTRINGs to and from this type.
typedef struct t_string {
    char *ptr;
    STRLEN size;
} STRING;

// Encrypt/decrypt a bridge by modifying string in place.
void endecrypt(STRING *bridge_as_string);

// Parse bridge as string.
// Return a result struct that describes what happened.
void analyze(STRING *bridge_as_string, struct analysis_result_t *result);

// Compare two bridges for functional equality, that is geometry
// identical up to joint and member numbers.  
// Returns -1 if one or both bridges were malformed.
// Else returns a boolean indicating equality.
#define BRIDGE_COMPARISON_ERROR -1
#define BRIDGES_EQUAL           1
#define BRIDGES_NOT_EQUAL       0
int compare(STRING *bridge_as_string_a, STRING *bridge_as_string_b);

// Return a variant of a bridge with permuted joints, members, and joint references
// with members.  This is for testing comparison and hashing functions.
char *variant(STRING *bridge_as_string, int seed);

// Return a variant of a bridge where one member chosen at random has been reduced
// in size until the bridge fails.  This is for testing member force computations.
char *failed_variant(STRING *bridge_as_string, int seed);

// Return a perturbation of a bridge with the given number of joints moved by
// one grid and/or the given number of members thickened (or sometimes thinned).
// The resulting bridge has _no_ guarantee of correctness, let alone that it will
// carry any kind of load.
char *perturbation(STRING *bridge_as_string, int seed, 
                   int n_joints, int n_members);

// Do an analysis and also return a PNG image sketch of the bridge.
void sketch(STRING *bridge_as_string,
            int width, int height,
            COMPRESSED_IMAGE *compressed_image,
            struct analysis_result_t *result);

// Return HTML for a table of analysis data.
char *analysis_table(STRING *bridge_as_string);

// Accept a string containing a scenario number.
// Return a pointer to the 3-character local contest code or null if no match.
char *get_local_contest_number(STRING *number_as_string);

#endif
