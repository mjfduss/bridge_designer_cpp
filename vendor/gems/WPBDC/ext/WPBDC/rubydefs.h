#ifndef _RUBYDEFS_H
#define _RUBYDEFS_H

#if !defined(NATIVE_TEST)

#include <ruby.h>

// For safety, generate a compile error if we try to call
// one of the underlying C allocators.
#undef	malloc
#define	malloc	@oops@
#undef	calloc
#define	calloc	@oops@
#undef	realloc
#define	realloc	@oops@
#undef	strdup
#define	strdup	@oops@
#undef	free
#define	free	@oops@

#define New(x,v,n,t)									\
	do {												\
	    v = ALLOC_N(t, n);                              \
	} while (0)

#define Newz(x,v,n,t)									\
	do {												\
	    v = ALLOC_N(t, n);                              \
        MEMZERO(v, t, n);                               \
	} while (0)

#define Renew(v,n,t)									\
	do {												\
	    v = REALLOC_N(v, t, n);                         \
	} while (0)

#define Safefree(p)										\
	do {												\
		xfree(p);										\
	} while (0)

#else

#include <stdio.h>

#define New(x,v,n,t)									\
	do {												\
		if ( !(v = (t*)malloc((n)*sizeof(t))) ) {		\
			fprintf(stderr, "out of memory (%d)\n", x);	\
			exit(1);									\
		}												\
	} while (0)

#define Newz(x,v,n,t)									\
	do {												\
		if ( !(v = (t*)calloc(n, sizeof(t))) ) {		\
			fprintf(stderr, "out of memory (%d)\n", x);	\
			exit(1);									\
		}												\
	} while (0)

#define Renew(v,n,t)									\
	do {												\
		if ( !(v = (t*)realloc(v, (n)*sizeof(t))) ) {	\
			fprintf(stderr, "out of memory in Renew\n");\
			exit(1);									\
		}												\
	} while (0)

#define Safefree(p)										\
	do {												\
		free(p);										\
	} while (0)

#endif

#endif
