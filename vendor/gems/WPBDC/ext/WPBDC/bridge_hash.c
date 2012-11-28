#include "stdafx.h"
#include "internal.h"

static INLINE int bit_width(unsigned int n)
{
	int w = 0;
	while (n) {
		n >>= 1;
		w++;
	}
	return w;
}

// Hash function starts hash value with alternating 1's and 0's.
// Xors in the significant bits (omitting leading zeros) of the 
// given vector with each set of signifcant bits separated by a 1,
// which is "or'ed" in.
void hashify_vec(unsigned int  *v, unsigned v_len,
				 unsigned int  *hash, unsigned h_len)
{
	unsigned iv, ip;

	assert(v);
	assert(hash);
	assert(h_len >= 1);

	for (ip = 0; ip < h_len; ip++)
		hash[ip] = 0x55555555u;

	ip = 0;
	for (iv = 0; iv < v_len; iv++) {
		unsigned int  val = (v[iv] << 1) | 1;
		unsigned ipw = ip >> 5;
		unsigned ipo = ip & 0x1f;
		assert(ipw < h_len);
		hash[ipw] ^= (val << ipo);
		if (++ipw >= h_len)
			ipw = 0;
		hash[ipw] ^= (val >> (32 - ipo));
		ip += bit_width(val);
		if ((ip >> 5) >= h_len)
			ip -= (h_len << 5);
	}
}

char *hex_nibble(int n, char *p)
{
	p[0] = "0123456789abcdef"[n & 0xf];
	p[1] = '\0';

	return p;
}

char *hex_byte(int b, char *p)
{
	hex_nibble(b >> 4, &p[0]);
	hex_nibble(b, &p[1]);

	return p;
}
 
char *hex_str(char *s, unsigned n, char *p)
{
	unsigned i;

	if (n == 0)
		n = strlen(s);
	for (i = 0; i < n; i++)
		hex_byte(s[i], &p[2 * i]);

	return p;
}

int hash_bridge(TBridge *bridge, char *hash)
{
	unsigned joint_index, member_index, hash_base;
	TBridge cb[1];

	unsigned v_size = 256;
	unsigned p = 0;
	unsigned int *v;
	unsigned int h[HASH_SIZE / sizeof(unsigned int)];

	New(190, v, v_size, unsigned int);

#define Add(Val)	do {													\
		if (p >= v_size) {													\
			v_size *= 2;													\
			Renew(v, v_size, unsigned int);								    \
		}																	\
		v[p++] = (Val);														\
	} while (0)

	init_bridge(cb);
	canonicalize(cb, bridge);

	// Canonicalization can fail if bridge has bad geometry.
	if (cb->error != BridgeNoError)
		return 1;

	// Scenario
	Add(cb->scenario_descriptor.index + 512);

	// Start hashing joints after standard ones dictated by scenario.
	hash_base = cb->load_scenario.n_prescribed_joints + 1;
	for (joint_index = hash_base; joint_index <= bridge->n_joints; joint_index++) {
		Add(cb->joints[joint_index].x);
		Add(cb->joints[joint_index].y);
	}
	for (member_index = 1; member_index <= bridge->n_members; member_index++) {
		Add(cb->members[member_index].start_joint);
		Add(cb->members[member_index].end_joint);
		Add(cb->members[member_index].x_section.material);
		Add(cb->members[member_index].x_section.section);
		Add(cb->members[member_index].x_section.size);
	}

	// Can't hashify directly into hash because it might not be aligned.
	hashify_vec(v, p, h, HASH_SIZE / sizeof(unsigned int));
	memcpy(hash, h, HASH_SIZE);

	Safefree(v);
	clear_bridge(cb);
	return 0;
}

