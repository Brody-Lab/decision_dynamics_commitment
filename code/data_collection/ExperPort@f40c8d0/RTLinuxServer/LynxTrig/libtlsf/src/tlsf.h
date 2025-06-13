/*
 * Two Levels Segregate Fit memory allocator (TLSF)
 * Version 2.1
 *
 * Written by Miguel Masmano Tello <mimastel@doctor.upv.es>
 *
 * Thanks to Ismael Ripoll for his suggestions and reviews
 *
 * Copyright (C) 2005, 2004
 *
 * This code is released using a dual license strategy: GPL/LGPL
 * You can choose the licence that better fits your requirements.
 *
 * Released under the terms of the GNU General Public License Version 2.0
 * Released under the terms of the GNU Lesser General Public License Version 2.1
 * Adapted to kernel mode by Calin A. Culianu <calin@ajvar.org> 
 * using the GPL license.
 *
 */

#ifndef _TLSF_H_
#define _TLSF_H_

// The  debug functions  only can  be used  when _DEBUG_TLSF_  is set.
//#define _DEBUG_TLSF_

// Some IMPORTANT TLSF parameters
// Unlike the preview TLSF versions, now they are statics
/* #define MAX_FLI 26 /\* Supports up to 64MB *\/ */
#define MAX_FLI 28 /* supports up to 256MB */

// If MAX_LOG2_SLI is modified, don't forget to update MAX_SLI with
// the correct value, that is, MAX_SLI = 2^MAX_LOG2_SLI
#define MAX_LOG2_SLI 5
#define MAX_SLI 32 /* MAX_SLI = 2^MAX_LOG2_SLI */

#ifdef __KERNEL__

#  include <linux/types.h>

#else /* !__KERNEL__ */

#  include <stddef.h>

#endif

// TYPES used by TLSF
typedef unsigned long u32_t;
typedef signed long s32_t;
typedef unsigned char u8_t;

/// Possible return values from init_memory_pool
enum { TLSF_POOL_INVALID = -1,  /* Passed invalid params, NULL pointer, 
                                   or pool smaller than ~128 bytes */
       TLSF_POOL_NOT_ALIGNED = -2, /* Pool needs to be dword aligned. */
       TLSF_FLI_TOOSMALL = -3}; /* Pool is too big -- need to change 
                                   compile-time MAX_FLI param. */

extern int init_memory_pool (size_t, void *);
extern void destroy_memory_pool (void *);
extern void *malloc_ex (size_t, void *);
extern void free_ex (void *, void *);
extern void *realloc_ex (void *, size_t, void *);
extern void *calloc_ex (size_t, size_t, void *);
#endif
