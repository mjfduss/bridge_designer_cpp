#include "rc4.h"

void init_rc4(TRC4State *state)
{
	int x;

	state->x = state->y = 0;

    // Set up permutation.
    for (x = 0; x < 256; x++)
        state->buf[x] = x;
}

void clear_rc4(TRC4State *state)
{
	init_rc4(state);
}

void setup_rc4(TRC4State *state, char *key, int keylen)
{
    unsigned tmp;
    int x, y;

	  // use only first 256 characters of key 
    if (keylen > 256) 
		    keylen = 256;

    for (x = y = 0; x < 256; x++) {
        y = (y + state->buf[x] + key[x % keylen]) & 255;
        tmp = state->buf[x]; 
		    state->buf[x] = state->buf[y]; 
		    state->buf[y] = tmp;
    }
    state->x = x;
    state->y = y;

	// DEBUG: Temporary while Steve fixes bug.
	// Removed 1 December 2003
	// state->y = 0;
}

unsigned long endecrypt_rc4(unsigned char *buf, unsigned long len, TRC4State *state)
{
   int x, y; 
   unsigned char *s, tmp;
   unsigned long n;

   n = len;
   x = state->x;
   y = state->y;
   s = state->buf;
   while (len--) {
      x = (x + 1) & 255;
      y = (y + s[x]) & 255;
      tmp = s[x]; s[x] = s[y]; s[y] = tmp;
      tmp = (s[x] + s[y]) & 255;
      *buf++ ^= s[tmp];
   }
   state->x = x;
   state->y = y;
   return n;
}
