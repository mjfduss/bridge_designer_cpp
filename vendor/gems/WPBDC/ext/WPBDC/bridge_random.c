#include "stdafx.h"
#include "internal.h"

void randomly_permute_unsigned(unsigned *v, unsigned n)
{
	unsigned i, r, t;

	if (n == 0)
		return;
	for (i = n - 1; i > 0; i--) {
		r = rand() % (i + 1);
		t = v[r];
		v[r] = v[i];
		v[i] = t;
	}
}

void randomly_permute_members(TMember *v, unsigned n)
{
	unsigned i, r;
	TMember t;

	if (n == 0)
		return;
	for (i = n - 1; i > 0; i--) {
		r = rand() % (i + 1);
		t = v[r];
		v[r] = v[i];
		v[i] = t;
	}
}

// Select sn values at random from the range [m,n]
// and place them (ascending sorted) into s.
void sample(unsigned *s, unsigned sn,
			unsigned m, unsigned n)
{
	unsigned i, j, t, sz;

	sz = n - m + 1;
	assert(sn <= sz);
	for (i = 0; i < sn; i++) {
		t = (m + i) + rand() % (sz - i);
		for (j = i; j > 0; j--)
			if (s[j-1] < t) 
				break;
			else {
				t--;
				s[j] = s[j-1];
			}
		s[j] = t;
	}
}

void perturb(TBridge *dst, TBridge *src, unsigned seed,
			 unsigned n_joints, unsigned n_members)
{
	unsigned i, j, dir;
	unsigned n_perturbable_joints;
	TCoordinate x, y, x_min, x_max, y_min, y_max;
	TXSection *xs;

	// Define offsets in ccw order.
	static int dx[] = { 1, 1, 0, -1, -1, -1, 0,   1};
	static int dy[] = { 0, 1, 1,  1,  0, -1, -1, -1};

	if (src->error != BridgeNoError)
		return;

	if (seed)
		srand(seed);

	copy_bridge(dst, src);

	if (n_joints > 0) {

		unsigned pj_indices[MAX_JOINTS];

		// Check parameter.
		n_perturbable_joints = dst->n_joints - dst->load_scenario.n_prescribed_joints;
		if (n_joints > n_perturbable_joints)
			n_joints = n_perturbable_joints;

		sample(pj_indices, n_joints, dst->load_scenario.n_prescribed_joints + 1, dst->n_joints);

		// Establish bounding box for perturbed coordinates.
		x_min = 0;
		x_max = dst->load_scenario.num_length_grids;
		y_min = -(int)dst->load_scenario.under_grids;
		y_max = dst->load_scenario.over_grids;

		// Perturb the joints.
		for (i = 0; i < n_joints; i++) {
			j = dir = rand() / (RAND_MAX / 8 + 1);
			assert(dir < 8);
			// Search around the clock in case we have a joint right
			// at the edge and would otherwise push it out of bounds.
			do {
				x = dst->joints[pj_indices[i]].x + dx[j];
				y = dst->joints[pj_indices[i]].y + dy[j];
				j = (j + 1) % 8;
			} while (j != dir && (x < x_min || x > x_max || y < y_min || y > y_max));
			if (j != dir) {
				dst->joints[pj_indices[i]].x = x;
				dst->joints[pj_indices[i]].y = y;
			}
			else {
				assert(0);	// Should never happen.
			}
		}
	}
	if (n_members > 0) {

		unsigned pm_indices[MAX_MEMBERS];

		if (n_members > dst->n_members)
			n_members = dst->n_members;

		sample(pm_indices, n_members, 1, dst->n_members);

		for (i = 0; i < n_members; i++) {
			xs = &dst->members[pm_indices[i]].x_section;

			// If we're not already at largest size, bump up one, else bump down one.
			if (xs->size < n_sizes(xs->section) - 1)
				xs->size++;
			else
				xs->size--;
		}
	}
}

int fix_failure(TBridge *dst, TBridge *src, TParams *params)
{
	unsigned member_index;
	TAnalysis analysis[1];
	int n_fixups;

	if (src->error != BridgeNoError)
		return -1;

	init_analysis(analysis);

	copy_bridge(dst, src);

	n_fixups = 0;
	for (;;) {
		setup_analysis(analysis, dst, 0, 0, 0);

		//  Check for analysis problems.
		if (analysis->error != NoAnalError)
			return -2;

		if (analysis->n_compressive_failures == 0 &&
			analysis->n_tensile_failures == 0)
			return n_fixups;

		// Find a failed member.
		for (member_index = 1; member_index <= dst->n_members; member_index++) {
			if (analysis->member_strength[member_index].tensile_fail_mode != FailModeNone ||
				analysis->member_strength[member_index].compressive_fail_mode != FailModeNone)
				break;
		}
		if (member_index > dst->n_members)  // search failed; should never happen
			return -3;
		// Have located a failed member.  Increase its size if possible.
		if (dst->members[member_index].x_section.size >= params->n_sizes[dst->members[member_index].x_section.section])
			return -4;  // already at top of scale
		++dst->members[member_index].x_section.size;
		++n_fixups;
	}
}

int induce_failure(TBridge *dst, TBridge *src, unsigned seed)
{
	unsigned start_member_index, member_index;
	unsigned new_size, saved_size;
	TAnalysis analysis[1];

	if (src->error != BridgeNoError)
		return -1;

	init_analysis(analysis);

	if (seed)
		srand(seed);

	copy_bridge(dst, src);

	start_member_index = (rand() % dst->n_members) + 1;

#define NEXT(I)	((((I) - 1 + 1) % dst->n_members) + 1)

	for (member_index = NEXT(start_member_index);
		 member_index != start_member_index; 
		 member_index = NEXT(member_index)) {

		// Get the size of the randomly selected member.
		saved_size = dst->members[member_index].x_section.size;
		if (saved_size > 0) {
			// Reduce size one at a time until failure.
			do {
				new_size = --dst->members[member_index].x_section.size;
				setup_analysis(analysis, dst, 0, 0, 0);

                // Punt for this member on slenderness failure.
                if (analysis->error != NoAnalError) {
                    break;
                }

				// Check for failure and return if we've done it!
				if (analysis->n_compressive_failures > 0 || analysis->n_tensile_failures > 0) {
					return 0;
				}
			} while (new_size > 0);
			// Couldn't do it with this member.  
			// Restore and loop to try the next member.
			dst->members[member_index].x_section.size = saved_size;
		}
	}
#undef NEXT
	// Very very unlikely, but who knows?
	return -1;
}

// Make a randomized variant of the source bridge.  This is just
// permuting joints and members into a pseudo-random order.  But we have
// to keep joint references in members correct.
void vary(TBridge *dst, TBridge *src, unsigned seed)
{
	unsigned *new_joint_to_old, *old_joint_to_new;
	unsigned joint_index, member_index;

	if (src->error != BridgeNoError)
		return;

	if (seed)
		srand(seed);

	copy_bridge(dst, src);

	Newz(170, new_joint_to_old, dst->n_joints + 1, sizeof(unsigned));
	for (joint_index = 1; joint_index <= dst->n_joints; joint_index++)
		new_joint_to_old[joint_index] = joint_index;

	{	
		// Indirect random reordering of joint map so that, when done,
		// joints[new_joint_to_old[i]] for permute_base + 1 <= i <= n_joints are randomized.
		// Sort_base is first joint after those fixed by the scenario.  We can't permute
		// prescribed joints, or the bridge won't be usable by the Designer.
		unsigned permute_base = dst->load_scenario.n_prescribed_joints + 1;
		randomly_permute_unsigned(&new_joint_to_old[permute_base], dst->n_joints - permute_base + 1);
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

	// Randomly swap joint references.
	for (member_index = 1; member_index <= dst->n_members; member_index++) {
		if (rand() < RAND_MAX/2) {
			TElementNumber j1 = dst->members[member_index].start_joint;
			TElementNumber j2 = dst->members[member_index].end_joint;
			dst->members[member_index].start_joint = j2;
			dst->members[member_index].end_joint = j1;
		}
	}

	// Now randomize order of members.
	randomly_permute_members(&dst->members[1], dst->n_members);

	// And renumber members, too.
	for (member_index = 1; member_index <= dst->n_members; member_index++)
		dst->members[member_index].number = member_index;
}

