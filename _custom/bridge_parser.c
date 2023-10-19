/*
 * bridge_parser.c -- Parsers and unparsers of various kinds
 */

#include "stdafx.h"
#include "internal.h"
//#include "rc4.h"

// unadvertised global hack that allows rewriter to read other-year bridge files
unsigned contest_year = CONTEST_YEAR;

#define FILE_BANNER		"West Point Bridge Designer 2004"
#define LOWEST_SCENARIO_NUMBER	MinVariableScenario
#define HIGHEST_SCENARIO_NUMBER	MaxVariableScenario

// Get a line by replacing \n in buffer with \0 and returning the line start.
// I.e. *buf is modified.
// Set a pointer 'next' to the start of next line, if there is one.  Otherwise set it to NULL.
// Return start of line gotten.
// We take care of \r\n line terminators by setting _both_ the \r and \n to \0.
// If buffer is NULL or if line exceeds max length, both *next and the returned line 
// pointer are set to NULL.  Consequence of this convention is that you can ask for more
// than one line in a row without checking return
// value until the end:
// line_1 = get_line(buf, &next);
// line_2 = get_line(next, &next);
// line_3 = get_line(next, &next);
// if (!line_3) error(...)
char *get_line(char *buf, char **next)
{
	char *p;

	if (!buf) {
		*next = NULL;
		return NULL;
	}

	p = buf;
	for (;;) {

		if (p - buf >= MAX_LINE_LENGTH) {
			*next = NULL;
			return NULL;
		}
		if (*p == '\n' || *p == '\r') {
			*p = '\0';
			p++;
			if (*p == '\n')
				*p++ = '\0';
			*next = p;
			return buf;
		}
		if (*p == '\0') {
			*next = NULL;
			return buf;
		}

		p++;
	}
}

// Parse a string from buf and copy it to str without the surrounding quotes.
// Embedded repeated quotes become a single quote per Basic convention.
// On error (NULL buffer or unterminated string), returns NULL and sets str
// to the empty string.  Return pointer to whatever follows with string.
char *parse_string(char *buf, char *str)
{
	char *p = buf;

	if (!p || *p != '"') {
		*str = '\0';
		return NULL;
	}

	// Skip past quote.
	p++;

	// Loop through all appearances of repeated quote.
	for (;;) {

		// Loop until next quote (or misplaced end of string).
		for (;;) {
			if (*p == '\0') {
				*str = '\0';
				return NULL;
			}
			if (*p == '"')
				break;
			*str++ = *p++;
		}

		// Skip matching quote.
		p++;

		// If next char is not a repeat quote, we're done.
		if (*p != '"')
			break;

		// Handle repeat quote.
		*str++ = '"';
		p++;
	}

	*str = '\0';
	return p;
}

// Convert given source string to Basic format at dst.  This
// consists of putting "" around it and doubling any embedded "'s.
void basic_string (char *dst, char *src)
{
	*dst++ = '\"';
	while (*src)
		if ((*dst++ = *src++) == '\"')
			*dst++ = '\"';
	*dst++ = '\"';
	*dst = '\0';
}

// Check that next character is a comma and return pointer to whatever follows the comma.
// If comma is not found, return NULL.
char *parse_comma(char *buf)
{
	if (!buf || *buf != ',')
		return NULL;
	return buf + 1;
}

// Get an unsigned value from the field of given width, possibly
// with leading but no trailing spaces.  Return a pointer to the
// character following the field in next.
unsigned scan_unsigned(char *str, unsigned width, char **next)
{
	unsigned val = 0;

	if (!str) {
		*next = 0;
		return 0;
	}

	// Skip whitespace.
	while (width > 0 && *str == ' ') {
		width--;
		str++;
	}
	while (width > 0) {
		if ('0' <= *str && *str <= '9') {
			val = val * 10 + (*str - '0');
			width--;
			str++;
		}
		else {
			*next = 0;
			return 0;
		}
	}
	*next = str;
	return val;
}

// Same as above, but allow for a negative sign.
int scan_int(char *str, unsigned width, char **next)
{
	int val = 0;
	TBool negate_p = False;

	if (!str) {
		*next = 0;
		return 0;
	}

	// Skip whitespace.
	while (width > 0 && *str == ' ') {
		width--;
		str++;
	}

	// Process negative sign, if present.
	if (width >= 2 && *str == '-') {
		width--;
		str++;
		negate_p = True;
	}

	while (width > 0) {
		if ('0' <= *str && *str <= '9') {
			val = val * 10 + (*str - '0');
			width--;
			str++;
		}
		else {
			*next = 0;
			return 0;
		}
	}
	*next = str;
	return negate_p ? -val : val;
}

// Get a string fieldd of given width into a buffer with \0 termination.
void scan_field(char *buf, char *str, unsigned width, char **next)
{
	char *p = buf;

	if (!str) {
		*next = 0;
		return;
	}

	while (width > 0) {
		if (*str == '\0') {
			*next = 0;
			buf[0] = '\0';
			return;
		}
		width--;
		*p++ = *str++;
	}
	*p = '\0';
	*next = str;
}

// These are the status values we'll find in the V4+ bridge files.
static char *test_status_tag[] = {
	"",	
	"\007",
	"\011",
	"\007\011",
};

// Return a TestStatus enumeration value given the corresponding
// code string from the V4+ bridge file.
TTestStatus lookup_test_status_tag(const char *str)
{
	int i;

	for (i = 0; i < STATIC_ARRAY_SIZE(test_status_tag); i++)
		if (strcmp(str, test_status_tag[i]) == 0)
			return (TTestStatus)i;
	return NullTestStatus;
}

// Destructive: scan to next delimiter; replace with \0;
// return scanned string.
#define PACKED_DELIM "|"

char *get_to_delim(char *str, char **next) 
{
	char *p;

	if (!str) {
		*next = 0;
		return 0;
	}
	for (p = str; *p; p++) {
		if (*p == PACKED_DELIM[0]) {
			*p++ = '\0';
			*next = p;
			return str;
		}
	}
	*next = 0;
	return str;
}

// Encrypt or decrpyt a buffer of given size.  You can't use 
// strlen to find size of an encrypted buffer!
/*void endecrypt_in_place(char *buf, int size)
{
	TRC4State rc4[1];

	init_rc4(rc4);
	setup_rc4(rc4, RC4_Key, strlen(RC4_Key));
	endecrypt_rc4(buf, size, rc4);
	clear_rc4(rc4);
}*/

// Parse a long string to fill a bridge structure.
// Bridge structure must be set to known-empty by init_bridge.
// This allocates memory that can be reclaimed later with clear_bridge.
void parse_bridge(TBridge *bridge, STRING *str)
{
	unsigned i, line_no;
	unsigned char *mutable_copy, *p;

	New(95, mutable_copy, str->size + 1/*, unsigned char*/);
	memcpy(mutable_copy, str->ptr, str->size);

	// Check for illegal characters.
	for (line_no = 1, i = 0, p = mutable_copy; i < (unsigned)str->size; i++, p++) {
		if (*p == '\0' || (128 <= *p && *p <= 159)) {
			Safefree(mutable_copy);
			clear_bridge(bridge);

#if defined(UNPACKED_BRIDGE_FILES)
			bridge->error_line = line_no;
#else
			bridge->error_line = i + 1; // character number
#endif

			bridge->error = BridgeBadChar;
			return;
		}
		if (*p == '\n')
			line_no++;
	}
	*p = '\0';

#if defined(UNPACKED_BRIDGE_FILES)
	parse_unpacked_bridge_destructive(bridge, mutable_copy);
#else
	parse_packed_bridge_destructive(bridge, mutable_copy);
#endif

	Safefree(mutable_copy);
}

// This parses the bridge string and munges it in the process.
void parse_unpacked_bridge_destructive(TBridge *bridge, char *str)
{
	char buf[MAX_LINE_LENGTH + 1];
	unsigned 
		n_design_iterations, 
		n_joints, n_members, 
		line_no, 
		start_line_no,
		start_joint,
		end_joint,
		material,
		section,
		size,
		joint_index,
		member_index;
	int	x, y;
	double label_pos;
	char *line, *next;

	clear_bridge(bridge);

	// Line 1 - Banner
	line_no = 1;
	line = get_line(str, &str);
	if (!line) {
		clear_bridge(bridge);
		bridge->error_line = line_no;
		bridge->error = BridgeMissingData;
		return;
	}
	next = parse_string(line, buf);
	if (!next) {
		clear_bridge(bridge);
		bridge->error_line = line_no;
		bridge->error = BridgeMissingHeader;
		return;
	}

	// Vector to parser depending on version.
	if (strcmp(buf, FILE_BANNER) != 0) {
		// Couldn't match banner.
		clear_bridge(bridge);
		bridge->error_line = line_no;
		bridge->error = BridgeBadHeader;
		return;
	}

	// Version 4.00 or later contest derivative
	bridge->version = BD_VERSION;

	// Test status flag.
	next = parse_comma(next);
	next = parse_string(next, buf);
	if (!next) {
		clear_bridge(bridge);
		bridge->error_line = line_no;
		bridge->error = BridgeMissingTestStatus;
		return;
	}

	if ((bridge->test_status = lookup_test_status_tag(buf)) == NullTestStatus) {
		clear_bridge(bridge);
		bridge->error_line = line_no;
		bridge->error = BridgeBadTestStatus;
		return;
	}

	// Line 2 - Scenario.
	line_no++;
	line = get_line(str, &str);
	if (!line) {
		clear_bridge(bridge);
		bridge->error_line = line_no;
		bridge->error = BridgeMissingData;
		return;
	}
	if (lookup_scenario_descriptor(&bridge->scenario_descriptor, line) < 0) {
		clear_bridge(bridge);
		bridge->error_line = line_no;
		bridge->error = BridgeBadScenario;
		return;
	}

	// Fill in load scenario based on index.
	setup_load_scenario(&bridge->load_scenario, &bridge->scenario_descriptor);
	if (bridge->load_scenario.error != LoadScenarioNoError) {
		clear_bridge(bridge);
		bridge->error_line = line_no;
		bridge->error = BridgeBadLoadScenario;
		return;
	}

	// Line 3 - Designer/Project ID.
	line_no++;
	line = get_line(str, &str);
	if (!line) {
		clear_bridge(bridge);
		bridge->error_line = line_no;
		bridge->error = BridgeMissingData;
		return;
	}
	next = parse_string(line, buf);
	if (!next) {
		clear_bridge(bridge);
		bridge->error_line = line_no;
		bridge->error = BridgeSyntax;
		return;
	}

	NewStr(98, bridge->designer, buf);
	next = parse_comma(next);
	next = parse_string(next, buf);
	if (!next) {
		clear_bridge(bridge);
		bridge->error_line = line_no;
		bridge->error = BridgeSyntax;
		return;
	}
	NewStr(99, bridge->project_id, buf);
	
	// Line 4 - # design iterations.
	line_no++;
	line = get_line(str, &str);
	if (!line) {
		clear_bridge(bridge);
		bridge->error_line = line_no;
		bridge->error = BridgeMissingData;
		return;
	}
	if (sscanf(line, "%u", &n_design_iterations) != 1) {
		clear_bridge(bridge);
		bridge->error_line = line_no;
		bridge->error = BridgeBadNDesignIterations;
		return;
	}
	bridge->n_design_iterations = n_design_iterations;

	// Line 5 - # joints, # members
	line_no++;
	line = get_line(str, &str);
	if (!line) {
		clear_bridge(bridge);
		bridge->error_line = line_no;
		bridge->error = BridgeMissingData;
		return;
	}
	if (sscanf(line, "%u,%u", &n_joints, &n_members) != 2) {
		clear_bridge(bridge);
		bridge->error_line = line_no;
		bridge->error = BridgeMissingData;
		return;
	}
	if (n_joints < 3) {
		clear_bridge(bridge);
		bridge->error_line = line_no;
		bridge->error = BridgeTooFewJoints;
		return;
	}
	if (n_members < 3) {
		clear_bridge(bridge);
		bridge->error_line = line_no;
		bridge->error = BridgeTooFewMembers;
		return;
	}
	if (n_joints > MAX_JOINTS ||
		n_members > MAX_MEMBERS) {
		clear_bridge(bridge);
		bridge->error_line = line_no;
		bridge->error = BridgeTooManyElements;
		return;
	}
	bridge->n_joints = n_joints;
	bridge->n_members = n_members;

	// Joint array is 1-based for easy transposition of Basic code in analysis.
	Newz(120, bridge->joints, n_joints + 1, sizeof(TJoint));
	joint_index = 1;
	for (start_line_no = ++line_no; line_no < start_line_no + n_joints; line_no++) {
		line = get_line(str, &str);
		if (!line) {
			clear_bridge(bridge);
			bridge->error_line = line_no;
			bridge->error = BridgeTooFewJoints;
			return;
		}
		if (sscanf(line, "%d,%d", &x, &y) != 2) {
			clear_bridge(bridge);
			bridge->error_line = line_no;
			bridge->error = BridgeSyntax;
			return;
		}
		bridge->joints[joint_index].number = joint_index;
		bridge->joints[joint_index].x = x;
		bridge->joints[joint_index].y = y;
		joint_index++;
	}

	if (n_joints < bridge->load_scenario.n_prescribed_joints ||
		!joint_lists_eq(bridge->load_scenario.prescribed_joints,
						&bridge->joints[1], 
						bridge->load_scenario.n_prescribed_joints)) {
		clear_bridge(bridge);
		bridge->error_line= line_no;
		bridge->error = BridgeWrongPrescribedJoints;
		return;
	}

	// Member array is 1-based for easy transposition of Basic code in analysis.
	Newz(130, bridge->members, n_members + 1, sizeof(TMember));
	member_index = 1;
	for (start_line_no = line_no; line_no < start_line_no + n_members; line_no++) {
		line = get_line(str, &str);
		if (!line) {
			clear_bridge(bridge);
			bridge->error_line = line_no;
			bridge->error = BridgeTooFewMembers;
			return;
		}
		if (sscanf(line, "%u,%u,%u,%u,%u,%s", 
			&start_joint,
			&end_joint,
			&material,
			&section,
			&size,
			buf) != 6 ||	// Buffer gets tension and compression test strings.
			start_joint > n_joints ||
			end_joint > n_joints ||
			start_joint == end_joint ||
			material >= NMaterials ||
			section >= NSections ||
			size >= n_sizes(section)) {

			clear_bridge(bridge);
			bridge->error_line = line_no;
			bridge->error = BridgeSyntax;
			return;
		}

		bridge->members[member_index].number = member_index;
		bridge->members[member_index].start_joint = start_joint;
		bridge->members[member_index].end_joint = end_joint;
		bridge->members[member_index].x_section.material = material;
		bridge->members[member_index].x_section.section = section;
		bridge->members[member_index].x_section.size = size;

		// Move the force strings into the line buffer for parsing.
		strcpy(line, buf);
		next = parse_string(line, buf);
		if (!next || 
			strlen(buf) >= FORCE_STR_SIZE || 
			strchr(buf, '"')) {	// Embedded quote is illegal and would unparse with bad syntax.
			clear_bridge(bridge);
			bridge->error_line = line_no;
			bridge->error = BridgeSyntax;
			return;
		}
		strcpy(bridge->members[member_index].compression, buf);

		next = parse_comma(next);

		next = parse_string(next, buf);
		if (!next || 
			strlen(buf) >= FORCE_STR_SIZE || 
			strchr(buf, '"')) {	// Embedded quote is illegal and would unparse with bad syntax.
			clear_bridge(bridge);
			bridge->error_line = line_no;
			bridge->error = BridgeSyntax;
			return;
		}
		strcpy(bridge->members[member_index].tension, buf);

		member_index++;
	}

	// Next Line - Label position
	line = get_line(str, &str);
	if (!line) {
		clear_bridge(bridge);
		bridge->error_line = line_no;
		bridge->error = BridgeMissingData;
		return;
	}

	if (sscanf(line, "%lf", &label_pos) != 1) {
		clear_bridge(bridge);
		bridge->error_line = line_no;
		bridge->error = BridgeBadLabelPos;
		return;
	}
	bridge->label_pos = label_pos;

	// EOF
	line_no++;
	line = get_line(str, &str);
	if ( (line && *line != '\0') || str ) {
		clear_bridge(bridge);
		bridge->error_line = line_no;
		bridge->error = BridgeExtraJunk;
		return;
	}
}

#define YEAR_LEN				4
#define SCENARIO_CODE_LEN		10
#define N_JOINTS_LEN			2
#define	N_MEMBERS_LEN			3
#define JOINT_COORD_LEN			3
#define MEMBER_JOINT_LEN		2
#define MEMBER_MATERIAL_LEN		1
#define MEMBER_SECTION_LEN		1
#define MEMBER_SIZE_LEN			2
#define MAX_TOKEN_LEN			10

// This parses the bridge string and munges it in the process.
void parse_packed_bridge_destructive(TBridge *bridge, char *str)
{
	unsigned 
		year,
		n_design_iterations, 
		n_joints, n_members, 
		start_joint,
		end_joint,
		material,
		section,
		size,
		joint_index,
		member_index;
	int	x, y;
	char
		*next, 
		*mark, 
		*compression, 
		*tension, 
		*field;
	double label_pos;

	clear_bridge(bridge);

	// Version 4.00 or later contest derivative
	bridge->version = BD_VERSION;

	// Packed format doesn't include test status.
	bridge->test_status = Unrecorded;

	// Field 1: Year of contest.
	mark = str;
	year = scan_unsigned(str, YEAR_LEN, &next);
	if (!next || year != contest_year) {
		clear_bridge(bridge);
		bridge->error_line = (mark - str) + 1;
		bridge->error = BridgeBadHeader;
		return;
	}

	//  Field 2: Scenario id.
	mark = next;
	if (lookup_scenario_descriptor(&bridge->scenario_descriptor, next) < 0) {
		clear_bridge(bridge);
		bridge->error_line = (mark - str) + 1;
		bridge->error = BridgeBadScenario;
		return;
	}
	next += SCENARIO_ID_SIZE;

	// Fill in load scenario based on index.
	setup_load_scenario(&bridge->load_scenario, &bridge->scenario_descriptor);
	if (bridge->load_scenario.error != LoadScenarioNoError) {
		clear_bridge(bridge);
		bridge->error_line = (mark - str) + 1;
		bridge->error = BridgeBadLoadScenario;
		return;
	}

	// Field 3 - # joints, # members
	mark = next;
	n_joints  = scan_unsigned(next, N_JOINTS_LEN,  &next);
	n_members = scan_unsigned(next, N_MEMBERS_LEN, &next);
	if (!next) {
		clear_bridge(bridge);
		bridge->error_line = (mark - str) + 1;
		bridge->error = BridgeMissingData;
		return;
	}
	if (n_joints < 3) {
		clear_bridge(bridge);
		bridge->error_line = (mark - str) + 1;
		bridge->error = BridgeTooFewJoints;
		return;
	}
	if (n_members < 3) {
		clear_bridge(bridge);
		bridge->error_line = (mark - str) + 1;
		bridge->error = BridgeTooFewMembers;
		return;
	}
	if (n_joints > MAX_JOINTS ||
		n_members > MAX_MEMBERS) {
		clear_bridge(bridge);
		bridge->error_line = (mark - str) + 1;
		bridge->error = BridgeTooManyElements;
		return;
	}
	bridge->n_joints = n_joints;
	bridge->n_members = n_members;

	// Fields 4 through 4 + n_joints - 1: Joint coordinates
	// Joint array is 1-based for easy transposition of Basic code in analysis.
	Newz(120, bridge->joints, n_joints + 1, sizeof(TJoint));
	for (joint_index = 1; joint_index <= n_joints; joint_index++) {
		mark = next;
		x = scan_int(next, JOINT_COORD_LEN, &next);
		y = scan_int(next, JOINT_COORD_LEN, &next);
		if (!next) {
			clear_bridge(bridge);
			bridge->error_line = (mark - str) + 1;
			bridge->error = BridgeSyntax;
			return;
		}
		bridge->joints[joint_index].number = joint_index;
		bridge->joints[joint_index].x = x;
		bridge->joints[joint_index].y = y;
	}

	// Verify that prescribed joints are where they should be.
	if (n_joints < bridge->load_scenario.n_prescribed_joints ||
		!joint_lists_eq(bridge->load_scenario.prescribed_joints,
						&bridge->joints[1], 
						bridge->load_scenario.n_prescribed_joints)) {
		clear_bridge(bridge);
		bridge->error_line= (mark - str) + 1;
		bridge->error = BridgeWrongPrescribedJoints;
		return;
	}

	// Member array is 1-based for easy transposition of Basic code in analysis.
	Newz(130, bridge->members, n_members + 1, sizeof(TMember));
	for (member_index = 1; member_index <= n_members; member_index++) {
		mark = next;
		start_joint = scan_unsigned(next, MEMBER_JOINT_LEN,    &next);
		end_joint   = scan_unsigned(next, MEMBER_JOINT_LEN,    &next);
		material    = scan_unsigned(next, MEMBER_MATERIAL_LEN, &next);
		section     = scan_unsigned(next, MEMBER_SECTION_LEN,  &next);
		size        = scan_unsigned(next, MEMBER_SIZE_LEN,     &next);
		if (!next ||
			start_joint > n_joints ||
			end_joint > n_joints ||
			start_joint == end_joint ||
			material >= NMaterials ||
			section >= NSections ||
			size >= n_sizes(section)) {

			clear_bridge(bridge);
			bridge->error_line = (mark - str) + 1;
			bridge->error = BridgeSyntax;
			return;
		}
		bridge->members[member_index].number = member_index;
		bridge->members[member_index].start_joint = start_joint;
		bridge->members[member_index].end_joint = end_joint;
		bridge->members[member_index].x_section.material = material;
		bridge->members[member_index].x_section.section = section;
		bridge->members[member_index].x_section.size = size;
	}

	for (member_index = 1; member_index <= n_members; member_index++) {
		mark = next;
		compression = get_to_delim(next, &next);
		tension     = get_to_delim(next, &next);
		if (!next ||
			strlen(compression) >= FORCE_STR_SIZE ||
			strlen(tension)     >= FORCE_STR_SIZE) {

			clear_bridge(bridge);
			bridge->error_line = (mark - str) + 1;
			bridge->error = BridgeSyntax;
			return;
		}
		strcpy(bridge->members[member_index].compression, compression);
		strcpy(bridge->members[member_index].tension, tension);
	}

	// Designer
	mark = next;
	field = get_to_delim(next, &next);
	if (!next || field - mark > MAX_LINE_LENGTH) {
		clear_bridge(bridge);
		bridge->error_line = (mark - str) + 1;
		bridge->error = BridgeSyntax;
		return;
	}
	NewStr(98, bridge->designer, field);

	// Project ID
	mark = next;
	field = get_to_delim(next, &next);
	if (!next || field - mark > MAX_LINE_LENGTH) {
		clear_bridge(bridge);
		bridge->error_line = (mark - str) + 1;
		bridge->error = BridgeSyntax;
		return;
	}
	NewStr(99, bridge->project_id, field);

	// Design iteration
	mark = next;
	field = get_to_delim(next, &next);
	if (!next || 
		field - mark > MAX_LINE_LENGTH ||
		sscanf(field, "%u", &n_design_iterations) != 1) {

		clear_bridge(bridge);
		bridge->error_line = (mark - str) + 1;
		bridge->error = BridgeSyntax;
		return;
	}
	bridge->n_design_iterations = n_design_iterations;

	// Label position.
	mark = next;
	field = get_to_delim(next, &next);
	if (!next ||
		sscanf(field, "%lf", &label_pos) != 1) {

		clear_bridge(bridge);
		bridge->error_line = (mark - str) + 1;
		bridge->error = BridgeSyntax;
		return;
	}
	bridge->label_pos = label_pos;

	// Scan once more for end of string. Allow a CRLF for 
	// editing test data during debugging,
	mark = next;
	if (next[0] && next[1] && next[2]) {
		clear_bridge(bridge);
		bridge->error_line = (mark - str) + 1;
		bridge->error = BridgeExtraJunk;
		return;
	}
}

char *unparse_bridge(TBridge *bridge)
{
#if defined(UNPACKED_BRIDGE_FILES)
	return unparse_unpacked_bridge(bridge);
#else
	return unparse_packed_bridge(bridge);
#endif
}

// Turns bridge back into a string.  String is allocated
// with "malloc".  Must be freed by caller.  With the possible
// exception of the last line (floating point label height), 
// this ought to exactly invert parse_packed_bridge above.
char *unparse_packed_bridge(TBridge *bridge)
{
	size_t rtn_size = 1024 * 8;
	char *rtn, *p;
	char buf[MAX_LINE_LENGTH + 1];
	unsigned joint_index, member_index;

	if (bridge->error != BridgeNoError)
		return 0;

	// Allocate an initial return buffer.
	New(140, rtn, rtn_size/*, char*/);
	p = rtn;

#define Append(S)	do {							\
	char *q = (S);									\
	while ((*p = *q++) != 0)						\
		if (++p >= rtn + rtn_size) {				\
			unsigned p_ofs = p - rtn;				\
			rtn_size *= 2;							\
			Renew(rtn, rtn_size/*, char*/);				\
			p = rtn + p_ofs;						\
		}											\
	} while (0)

	// Year
	sprintf(buf, "%u", contest_year);
	Append(buf);

	// Scenario ID.
	Append(bridge->scenario_descriptor.id);

	// Numbers of joints and members.
	sprintf(buf,
			"%" STR(N_JOINTS_LEN)  "u"
			"%" STR(N_MEMBERS_LEN) "u", 
		bridge->n_joints, 
		bridge->n_members);
	Append(buf);

	// Joint coordinates.
	for (joint_index = 1; joint_index <= bridge->n_joints; joint_index++) {
		sprintf(buf, 
				"%" STR(JOINT_COORD_LEN) "d" 
				"%" STR(JOINT_COORD_LEN) "d",
			bridge->joints[joint_index].x,
			bridge->joints[joint_index].y);
		Append(buf);
	}

	// Members data.
	for (member_index = 1; member_index <= bridge->n_members; member_index++) {
		sprintf(buf, 
				"%" STR(MEMBER_JOINT_LEN)    "d" 
				"%" STR(MEMBER_JOINT_LEN)    "d" 
				"%" STR(MEMBER_MATERIAL_LEN) "d" 
				"%" STR(MEMBER_SECTION_LEN)  "d" 
				"%" STR(MEMBER_SIZE_LEN)     "d",
			bridge->members[member_index].start_joint,
			bridge->members[member_index].end_joint,
			bridge->members[member_index].x_section.material,
			bridge->members[member_index].x_section.section,
			bridge->members[member_index].x_section.size);
		Append(buf);
	}

	// Variable length data.

	// Most recent member forces.
	for (member_index = 1; member_index <= bridge->n_members; member_index++) {
		sprintf(buf, "%s" PACKED_DELIM "%s" PACKED_DELIM, 
			bridge->members[member_index].compression,
			bridge->members[member_index].tension);
		Append(buf);
	}

	// Designer.
	Append(bridge->designer);
	Append(PACKED_DELIM);

	// Project ID
	Append(bridge->project_id);
	Append(PACKED_DELIM);

	// # Design iterations.
	sprintf(buf, "%u" PACKED_DELIM, bridge->n_design_iterations);
	Append(buf);

	// Label position
	sprintf(buf, "%.7lg" PACKED_DELIM, bridge->label_pos);
	Append(buf);

	// Return the buffer.  Could trim with realloc here.
	return rtn;

#undef Append
}

// Turns bridge back into a packed string.  String is allocated
// with "malloc".  Must be freed by caller.  With the possible
// exception of the last line (floating point label height), 
// this ought to exactly invert parse_bridge above.
char *unparse_unpacked_bridge(TBridge *bridge)
{
	size_t rtn_size = 1024 * 8;
	char *rtn, *p;
	char buf[MAX_LINE_LENGTH + 1];
	unsigned joint_index, member_index;

	if (bridge->error != BridgeNoError)
		return 0;

	// Allocate an initial return buffer.
	New(140, rtn, rtn_size/*, char*/);
	p = rtn;

#define Append(S)	do {							\
	char *q = (S);									\
	while ((*p = *q++) != 0)						\
		if (++p >= rtn + rtn_size) {				\
			unsigned p_ofs = p - rtn;				\
			rtn_size *= 2;							\
			Renew(rtn, rtn_size/*, char*/);				\
			p = rtn + p_ofs;						\
		}											\
	} while (0)

	// Line 1 - Banner
	basic_string(buf, FILE_BANNER);
	Append(buf);
	Append(",\"");
	Append(test_status_tag[bridge->test_status]);
	Append("\"\n");

	// Line 2 - Scenario.
	Append(bridge->scenario_descriptor.id);

	// Line 3 - Designer/Project ID.
	basic_string(buf, bridge->designer);
	Append(buf);
	Append(",");
	basic_string(buf, bridge->project_id);
	Append(buf);
	Append("\n");

	// Line 4 - # design iterations.
	sprintf(buf, "%u\n", bridge->n_design_iterations);
	Append(buf);

	// Line 5 - # joints, # members
	sprintf(buf, "%u,%u\n", bridge->n_joints, bridge->n_members);
	Append(buf);

	// Joint array is 1-based for easy transposition of Basic code in analysis.
	for (joint_index = 1; joint_index <= bridge->n_joints; joint_index++) {
		sprintf(buf, "%d,%d\n", 
			bridge->joints[joint_index].x,
			bridge->joints[joint_index].y);
		Append(buf);
	}

	// Member array is 1-based for easy transposition of Basic code in analysis.
	for (member_index = 1; member_index <= bridge->n_members; member_index++) {
		sprintf(buf, "%u,%u,%u,%u,%u,\"%s\",\"%s\"\n", 
			bridge->members[member_index].start_joint,
			bridge->members[member_index].end_joint,
			bridge->members[member_index].x_section.material,
			bridge->members[member_index].x_section.section,
			bridge->members[member_index].x_section.size,
			bridge->members[member_index].compression,
			bridge->members[member_index].tension);
		Append(buf);
	}

	// Next Line - Label position
	sprintf(buf, "%.7lg\n", bridge->label_pos);
	Append(buf);

	// Return the buffer.  Could trim with realloc here.
	return rtn;

#undef Append
}

void pack_bridge(STRING *in_str, STRING *out_str,
				TBool decrypt_p, TBool encrypt_p)
{
	TBridge bridge[1];
	char *mutable_copy;

	init_bridge(bridge);

	New(97, mutable_copy, in_str->size + 1/*, char*/);
	memcpy(mutable_copy, in_str->ptr, in_str->size);
	mutable_copy[in_str->size] = '\0';

	//if (decrypt_p)
	//	endecrypt_in_place(mutable_copy, in_str->size);

	parse_unpacked_bridge_destructive(bridge, mutable_copy);
	Safefree(mutable_copy);
	if (bridge->error == BridgeNoError) {
		out_str->ptr = unparse_packed_bridge(bridge);
		out_str->size = strlen(out_str->ptr);
		//if (encrypt_p)
		//	endecrypt_in_place(out_str->ptr, out_str->size);
	}
	else {
		out_str->ptr = 0;
		out_str->size = 0;
	}

	clear_bridge(bridge);
}

void unpack_bridge(STRING *in_str, STRING *out_str,
				   TBool decrypt_p, TBool encrypt_p)
{
	TBridge bridge[1];
	char *mutable_copy;

	init_bridge(bridge);

	New(97, mutable_copy, in_str->size + 1/*, char*/);
	memcpy(mutable_copy, in_str->ptr, in_str->size);
	mutable_copy[in_str->size] = '\0';

	//if (decrypt_p)
	//	endecrypt_in_place(mutable_copy, in_str->size);

	parse_packed_bridge_destructive(bridge, mutable_copy);
	Safefree(mutable_copy);
	if (bridge->error == BridgeNoError) {
		out_str->ptr = unparse_bridge(bridge);
		out_str->size = strlen(out_str->ptr);
		//if (encrypt_p)
		//	endecrypt_in_place(out_str->ptr, out_str->size);
	}
	else {
		out_str->ptr = 0;
		out_str->size = 0;
	}

	clear_bridge(bridge);
}
