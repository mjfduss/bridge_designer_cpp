/*
 * bridge.c -- Bridges
 */

// Constants and data structures Perl does not need to know about.
#include "stdafx.h"
#include "internal.h"

// TBridge initialization values.  This must align  with declaration!
// Set contents of a bridge to known-empty.
void init_bridge(TBridge *bridge)
{
	static TBridge constant_init_bridge = INIT_BRIDGE;
	*bridge = constant_init_bridge;
}

// Free allocated memory for a bridge and reset it to known-empty.
void clear_bridge(TBridge *bridge)
{
	Safefree(bridge->designer);
	Safefree(bridge->project_id);
	Safefree(bridge->joints);
	Safefree(bridge->members);
	clear_load_scenario(&bridge->load_scenario);
	init_bridge(bridge);
}

// Compare two joint lists (arrays) for functional equality.
TBool joint_lists_eq(TJoint *a, TJoint *b, unsigned n)
{
	unsigned i;

	for (i = 0; i < n; i++) {
		if (a[i].x != b[i].x || a[i].y != b[i].y)
			return False;
	}
	return True;
}

TBool x_section_lists_eq(TXSection *a, TXSection *b, unsigned n)
{
	return memcmp(a, b,	n * sizeof(TXSection)) == 0;
}

// Table mapping section to sectio name.
static char *section_str_table[NSections] = {
	"Bar",
	"Tube",
};

char *section_str(TSection section)
{
	return (unsigned)section < NSections ? section_str_table[section] : "<unknown>";
}

// Compare two member lists (arrays) for functional equality.
TBool member_lists_eq(TMember *a, TMember *b, unsigned n)
{
	unsigned i;

	// Equality comparison must ignore the compression and tension strings.
	for (i = 0; i < n; i++) {
		if (a[i].start_joint != b[i].start_joint ||
			a[i].end_joint != b[i].end_joint ||
			!x_section_lists_eq(&a[i].x_section, &b[i].x_section, 1))

			return False;
	}

	return True;
}

// Make a fresh copy of a bridge.  The bridge
// can't be erroneous.  If so, the copy just
// fails quietly.
void copy_bridge(TBridge *dst, TBridge *src)
{
	if (src->error != BridgeNoError)
		return;

	clear_bridge(dst);

	dst->version = src->version;
	dst->test_status = src->test_status;
	dst->scenario_descriptor = src->scenario_descriptor;
	NewStr(145, dst->designer, src->designer);
	NewStr(147, dst->project_id, src->project_id);
	dst->n_design_iterations = src->n_design_iterations;
	dst->n_joints = src->n_joints;
	New(150, dst->joints, dst->n_joints + 1/*, TJoint*/);
	memcpy(dst->joints, src->joints, (dst->n_joints + 1) * sizeof(TJoint));
	dst->n_members = src->n_members;
	New(160, dst->members, dst->n_members + 1/*, TMember*/);
	memcpy(dst->members, src->members, (dst->n_members + 1) * sizeof(TMember));
	dst->label_pos = src->label_pos;
	copy_load_scenario(&dst->load_scenario, &src->load_scenario);
}

// Compare two bridges for identical geometry and materials.
TBool bridges_indentical(TBridge *a, TBridge *b)
{
	return
		a->version		== b->version									&&
		a->scenario_descriptor.index == b->scenario_descriptor.index	&&
		a->n_joints		== b->n_joints									&&
		a->n_members	== b->n_members									&&
		joint_lists_eq(&a->joints[1], &b->joints[1], b->n_joints)		&&
		member_lists_eq(&a->members[1], &b->members[1],	b->n_members);
}

// Make a canonical variant of the source bridge.  This is just
// sorting joints and members into a canonical order.  But we have
// to keep joint references in members correct.
void canonicalize(TBridge *dst, TBridge *src)
{
	unsigned *new_joint_to_old, *old_joint_to_new;
	unsigned joint_index, member_index;

	if (src->error != BridgeNoError)
		return;

	copy_bridge(dst, src);

	Newz(170, new_joint_to_old, dst->n_joints + 1, sizeof(unsigned));
	for (joint_index = 1; joint_index <= dst->n_joints; joint_index++)
		new_joint_to_old[joint_index] = joint_index;

	{	// Indirect insertion sort of joint map so that, when done,
		// joints[new_joint_to_old[i]] for sort_base + 1 <= i <= n_joints are in ascending order.
		// Sort_base is first joint after those fixed by the scenario.  We could sort these, too,
		// but then the canonical bridge won't be usable by the Designer.
		// Sort order is lexicographic on x and then y.
		unsigned i, j, t;
		unsigned sort_base = dst->load_scenario.n_prescribed_joints + 1;
		
#define JointGT(A, B)								\
		(dst->joints[A].x > dst->joints[B].x ||		\
			(dst->joints[A].x == dst->joints[B].x &&\
				dst->joints[A].y > dst->joints[B].y))

		for (i = sort_base + 1; i <= dst->n_joints; i++) {
			t = new_joint_to_old[i];
			for (j = i; j > sort_base && JointGT(new_joint_to_old[j-1], t); j--)
				new_joint_to_old[j] = new_joint_to_old[j-1];
			new_joint_to_old[j] = t;
		}
	}

	// Compute inverse map.
	Newz(180, old_joint_to_new, dst->n_joints + 1, sizeof(unsigned));
	for (joint_index = 1; joint_index <= dst->n_joints; joint_index++)
		old_joint_to_new[new_joint_to_old[joint_index]] = joint_index;

	// Translate joint numbers in members.
	for (member_index = 1; member_index <= dst->n_members; member_index++) {
		dst->members[member_index].start_joint = old_joint_to_new[dst->members[member_index].start_joint];
		dst->members[member_index].end_joint = old_joint_to_new[dst->members[member_index].end_joint];
	}

	// Now actually move the joints.
	// Copy from source joints to avoid overlapping moves. Renumber while copying.
	for (joint_index = 1; joint_index <= dst->n_joints; joint_index++) {
		dst->joints[joint_index] = src->joints[new_joint_to_old[joint_index]];
		dst->joints[joint_index].number = joint_index;
	}

	Safefree(new_joint_to_old);
	Safefree(old_joint_to_new);

	// Swap joint references so lowest joint number is first.
	for (member_index = 1; member_index <= dst->n_members; member_index++) {
		TElementNumber j1 = dst->members[member_index].start_joint;
		TElementNumber j2 = dst->members[member_index].end_joint;
		if (j1 > j2) {
			dst->members[member_index].start_joint = j2;
			dst->members[member_index].end_joint = j1;
		}
	}

	{	// Now do a direct sort of members into a canonical order.
		// We use lexicographic order on start_joint then end_joint.
		unsigned i, j;
		TMember t;
		
		for (i = 2; i <= dst->n_members; i++) {
			t = dst->members[i];
			for (	j = i; 
					j > 1 && 
						(dst->members[j-1].start_joint > t.start_joint ||
							(dst->members[j-1].start_joint == t.start_joint &&
								dst->members[j-1].end_joint > t.end_joint));
					j--)
				dst->members[j] = dst->members[j-1];
			dst->members[j] = t;
		}
	}

	// And renumber members, too.
	for (member_index = 1; member_index <= dst->n_members; member_index++)
		dst->members[member_index].number = member_index;

	// Set error in the canonical bridge if there are geometry problems.
	// First check for duplicate joints, which will show up as adjacent
	// in the canonical bridge.
	for (joint_index = 1; joint_index < dst->n_joints; joint_index++) {
		if (joint_lists_eq(
				&dst->joints[joint_index], 
				&dst->joints[joint_index + 1], 1)) {
			clear_bridge(dst);
			dst->error = BridgeDupJoints;
			return;
		}
	}

	// Check for duplicate members, which, again, will show up as adjacent
	// in canonical bridge.
	for (member_index = 1; member_index < dst->n_members; member_index++) {
		if (member_lists_eq(
				&dst->members[member_index], 
				&dst->members[member_index + 1], 1)) {
			clear_bridge(dst);
			dst->error = BridgeDupMembers;
			return;
		}
	}

	// Finally check for joints lying exactly on members.
	for (member_index = 1; member_index <= dst->n_members; member_index++) {

		TMember *member = &dst->members[member_index];
		TJoint *start = &dst->joints[member->start_joint];
		TJoint *end = &dst->joints[member->end_joint];

		for (joint_index = 1; joint_index <= dst->n_joints; joint_index++) {
			long A, B;
			TJoint *joint;

			// First make sure we're not looking at one of the member's ends!
			if (joint_index == member->start_joint ||
				joint_index == member->end_joint)
				continue;

			// Ignore joints that are outside the rectangular extent of the member.
			joint = &dst->joints[joint_index];
			if ((start->x > joint->x && end->x > joint->x) ||
				(start->x < joint->x && end->x < joint->x) ||
				(start->y > joint->y && end->y > joint->y) ||
				(start->y < joint->y && end->y < joint->y))
				continue;

			// Check if the joint is on the line struck by the member ends.
			A = end->y - start->y;
			B = start->x - end->x;
			if (A * start->x + B * start->y == A * joint->x + B * joint->y) {
				clear_bridge(dst);
				dst->error = BridgeJointOnMember;
				return;
			}
		}
	}
}

void print_material(FILE *f,
					unsigned index,
					TMaterial *material)
{
	unsigned section_index;

	fprintf(f, "[%u] material '%s (%s)':\n", index, material->name, material->short_name);
	fprintf(f, " elasticity     = %.4f\n", material->E);
	fprintf(f, " yield strength = %.4f\n", material->Fy);
	fprintf(f, " density        = %.4f\n", material->density);
	fprintf(f, " cost:\n");
	for (section_index = 0; section_index < NSections; section_index++)
		fprintf(f, "%4s = %f\n", section_str(section_index), material->cost[section_index]);
}

void print_shape(FILE *f,
				 unsigned section_index,
				 unsigned size_index,
				 TShape *shape)
{
	fprintf(f, "[section=%u, size=%u] shape %s:\n", section_index, size_index, shape->name);
	fprintf(f, " width  = %.4f\n", shape->width);
	fprintf(f, " area   = %.4f\n", shape->area);
	fprintf(f, " moment = %.4f\n", shape->moment);
}

