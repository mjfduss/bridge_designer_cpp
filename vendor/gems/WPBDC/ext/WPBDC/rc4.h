#ifndef _RC4_H
#define _RC4_H

/*
 * rc4.h -- Declarations for a simple rc4 encryption/decryption implementation.
 * The code was inspired by libtomcrypt.  See www.libtomcrypt.org.
 */
typedef struct TRC4State_t {
	int x, y;
	unsigned char buf[256];
} TRC4State;

/* rc4.c */
void init_rc4(TRC4State *state);
void clear_rc4(TRC4State *state);
void setup_rc4(TRC4State *state, char *key, int keylen);
unsigned long endecrypt_rc4(unsigned char *buf, unsigned long len, TRC4State *state);

#endif