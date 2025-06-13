/*
 * This file is part of the RT-Linux Multichannel Data Acquisition System
 *
 * Copyright (c) 2002  Calin Culianu
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program (see COPYRIGHT file); if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA, or go to their website at
 * http://www.gnu.org.
 */
#if !defined(MBUFF_VERSION) && !defined(_RTOS_SHARED_MEMORY_H)
#define MBUFF_VERSION "0.7.2"
#define _RTOS_SHARED_MEMORY_H

#ifdef __cplusplus
extern "C" {
#endif

/*---------------------------- MBUFF STUFF ----------------------------------
  We are using out own custom mbuff functions here because the rtl versions
  of these produced compiler warnings.  Hopefully they won't change too 
  much across rtl versions...
-----------------------------------------------------------------------------*/

/* max length of the name of the shared memory area */
#define MBUFF_NAME_LEN 32
#define MBUFF_MAX_MMAPS 16  
#ifndef MBUFF_DEV_NAME
#define MBUFF_DEV_NAME "/dev/mbuff"
#endif
#ifndef MBUFF_DEV_NAME2
#define MBUFF_DEV_NAME2 "/dev/rtl_shm" /* for RTLinux 3.2 and/or devfs users */
#endif

#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>



/*
   All ioctl()s are called with name filled in with the appropriate
   name for the mbuff to be referenced.  Calls to any ioctl() makes
   that mbuff "active", i.e., read(), write(), and mmap() use that
   mbuff.  I didn't do this yet.

   ioctl()s:

   ALLOCATE:
      Call with size=0 to just find out if the area exists; no
      mbuff will be allocated.  Otherwise, allocate an mbuff with
      that size.
   DEALLOCATE:
      Decrease reference count for an mbuff.

   issues:
      - using this method, it is *really* easy to get dangling
        mbuffs, i.e., mbuffs that nobody owns.  When you close
	/dev/mbuff, it would be a good idea to decrease the ref
	count of the active mbuff.
 */
#define IOCTL_MBUFF_INFO 0
#define IOCTL_MBUFF_ALLOCATE 1
#define IOCTL_MBUFF_DEALLOCATE 2
#define IOCTL_MBUFF_SELECT 3
#define IOCTL_MBUFF_LAST IOCTL_MBUFF_SELECT

struct mbuff_request_struct {
	unsigned int flags;

	char name[MBUFF_NAME_LEN+1];

	size_t size;

	unsigned int reserved[4];
};


/* you can use mbuff_alloc several times, the buffer
will be deallocated when mbuff_free was called the same number of times
AND area is not mmaped anywhere anymore
AND it is not used in the kernel as well */
/* if you have a need to mmap the area at the specific address, use
 * mbuff_alloc_at */

/* mbuff_attach and mbuff_detach do not change usage counters -
   area allocated using mbuff_attach will be deallocated on program exit/kill
   if nobody else uses it - mbuff_detach is not needed -
   the only lock keeping area allocated is mmap */

static void * mbuff_attach_at(const char *name, int size, void * addr) {
	int fd;
	struct mbuff_request_struct req={0, "default", 0, {0}};
	void * mbuf;

	if(name) strncpy(req.name, name, sizeof(req.name));
	req.name[sizeof(req.name)-1]='\0';
	req.size = size;
	if((( fd = open(MBUFF_DEV_NAME, O_RDWR) ) < 0)
       && (( fd = open(MBUFF_DEV_NAME2, O_RDWR) ) < 0)){
		perror("open failed");
		return NULL;
	}
	ioctl(fd,IOCTL_MBUFF_ALLOCATE,&req);
	mbuf=mmap(addr, size, PROT_WRITE|PROT_READ, MAP_SHARED|MAP_FILE, fd, 0);
	/* area will be deallocated on the last munmap, not now */
	ioctl(fd, IOCTL_MBUFF_DEALLOCATE, &req);
	if( mbuf == (void *) -1) 
		mbuf=NULL;
	close(fd);
	return mbuf;
}

static void * mbuff_attach(const char *name, int size) {
	return mbuff_attach_at(name, size, NULL);
}

static void mbuff_detach(const char *name, void * mbuf) {
	int fd;
	struct mbuff_request_struct req={0,"default",0,{0}};
	int size;

	if(name) strncpy(req.name,name,sizeof(req.name));
	req.name[sizeof(req.name)-1]='\0';
	if( (( fd = open(MBUFF_DEV_NAME,O_RDWR) ) < 0) 
       && (( fd = open(MBUFF_DEV_NAME2,O_RDWR) ) < 0)) {
		perror("open failed");
		return;
	}
	size = ioctl(fd,IOCTL_MBUFF_SELECT,&req);
	if(size > 0) munmap( mbuf, size);
	close(fd);
	/* in general, it could return size, but typical "free" is void */
	return;
}
/*-------------------------- END MBUFF STUFF --------------------------------*/

static inline unsigned long nam2num(const char *name)
{
        unsigned long retval;
        int c, i;
 
        if (!(c = name[0])) {
           return 0xFFFFFFFF;
        }
        i = retval = 0;
        do {
                if (c >= 'a' && c <= 'z') {
                        c +=  (11 - 'a');
                } else if (c >= 'A' && c <= 'Z') {
                        c += (11 - 'A');
                } else if (c >= '0' && c <= '9') {
                        c -= ('0' - 1);
                } else {
                        c = c == '_' ? 37 : 38;
                }
                retval = retval*39 + c;
        } while (i < 5 && (c = name[++i]));
        return retval;
}
 
static inline void num2nam(unsigned long num, char *name)
{
        int c, i, k, q;
        if (num == 0xFFFFFFFF) {
                name[0] = 0;
                return;
        }
        i = 5;
        while (num && i >= 0) {
                q = num/39;
                c = num - q*39;
                num = q;
                if ( c < 37) {
                        name[i--] = c > 10 ? c + 'A' - 11 : c + '0' - 1;
                } else {
                        name[i--] = c == 37 ? '_' : '$';
                }
        }
        for (k = 0; i < 5; k++) {
                name[k] = name[++i];
        }
        name[k] = 0;
}


#define RTAI_SHM_DEV "/dev/rtai_shm" /* RTAI 2.x */
#define RTAI3_SHM_DEV "/dev/RTAI_SHM" /* RTAI 3.x */
#define RTAI_IOCTL_CMD_ATTACH 1
#define RTAI_IOCTL_CMD_GET_SZ 2
#define RTAI_IOCTL_CMD_FREE   3

static inline int rtai_shmrq(int srq, unsigned int whatever)
{
        int fd;
        int ret;
 
        /* First, try RTAI2 SHM device */
        fd = open(RTAI_SHM_DEV,O_RDWR);
        
        /* if above fails, try again with a differen SHM device for RTAI3 */  
        if ( fd < 0 ) {
          srq += 186; /* it might be RTAI3-style IOCTL which are 
                         +186 from the originals.. */
          fd = open(RTAI3_SHM_DEV,O_RDWR);
          if (fd < 0) return fd;
        }

        ret = ioctl(fd, srq, whatever);
 
        close(fd);
        return ret;
}


static void *rtai_malloc(unsigned long name, int size)
{
        void *adr = 0;
        int hook;
        struct { unsigned long name, size; } arg;
 
        if (size <= 0) {
                return 0;
        }
 
        if ((hook = open(RTAI_SHM_DEV, O_RDWR)) < 0
            && (hook = open(RTAI3_SHM_DEV, O_RDWR)) < 0) 
          return 0;
        
        arg.name = name;
        arg.size = size;
 
        if (!(size = rtai_shmrq(RTAI_IOCTL_CMD_ATTACH, (unsigned long)(&arg)))) 
          goto out;

        adr = mmap(NULL, size, PROT_WRITE|PROT_READ, MAP_SHARED|MAP_FILE, hook,
0);
 
out:
        close(hook);
 
        return adr;
}

static inline void *rtai_malloc_adr(void *start_address, unsigned long name, 
                                    int size)
{
        void *adr = 0;
        int hook, rtai3 = 0;
        struct { unsigned long name, size; } arg;
 
        if (size <= 0) {
                return 0;
        }
        if ((hook = open(RTAI_SHM_DEV, O_RDWR)) < 0
            && (rtai3=186) 
            && (hook = open(RTAI3_SHM_DEV, O_RDWR)) < 0) goto out;
 
        arg.name = name;
        arg.size = size;
        if (!(size = ioctl(hook, RTAI_IOCTL_CMD_ATTACH + rtai3, 
                           (unsigned long)(&arg)))) goto out;
 
        adr = mmap(start_address, size, PROT_WRITE|PROT_READ,
                   MAP_FIXED|MAP_SHARED|MAP_FILE, hook, 0);
 
out:
        close(hook);
        return adr;
}

static inline void rtai_free(int name, void *adr)
{  
        int size;

        if ((size = rtai_shmrq(RTAI_IOCTL_CMD_GET_SZ, name))) {
          munmap(adr, size);
          rtai_shmrq(RTAI_IOCTL_CMD_FREE, name);
        }
}

/* same interface as mbuff_attach */
static void *rtai_shm_attach(const char *name,  int size)
{
  unsigned long name_as_num = nam2num(name);

  return rtai_malloc(name_as_num, size);
}

/* same interface as mbuff_detach */
static void rtai_shm_detach(const char *name, void * mbuf) 
{
  unsigned long name_as_num = nam2num(name);
  
  rtai_free(name_as_num, mbuf);
}

#ifdef __cplusplus
}
#endif

#endif 
