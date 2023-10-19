#ifndef _MEMDEFS_H
#define _MEMDEFS_H


#define New(allocation_count, variable, size_needed)	\
/* Allocates the memory needed for a given variable and assigns that memory location */	\
	do {												\
	    variable = malloc(size_needed);             	\
	} while (0)

#define Newz(allocation_count, variable, size_needed, type_size)\
/* Allocates the memory with zeros for a given variable and assigns that memory location */	\
	do {														\
	    variable = calloc(size_needed, type_size);       		\
	} while (0)

#define Renew(variable, size_needed)					\
/* Rellocates the memory needed for a given variable and reassigns a memory location */	\
	do {												\
	    variable = realloc(variable, size_needed);      \
	} while (0)

#define Safefree(variable)								\
/* Frees the memory at the given pointer variable*/		\
	do {												\
		free(variable);									\
	} while (0)


#endif