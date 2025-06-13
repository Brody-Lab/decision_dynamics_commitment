#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif
#include "rtos_utility.h"
#include "rtos_shared_memory.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h> 
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

RTOS::RTOS RTOS::determine()
{
  RTOS rtosUsed = Unknown;
  struct stat statbuf;

  if (!stat("/proc/rtai", &statbuf)) rtosUsed = RTAI;
  else if(!stat("/proc/modules", &statbuf)) {
    FILE *proc_modules = fopen("/proc/modules", "r");
    static const int BUFSZ = 256;
    char modname_buf[BUFSZ];
    char FMT[32];
    char *lineptr = 0;
    size_t lnsz = 0;

    snprintf(FMT, sizeof(FMT)-1, "%%%ds", BUFSZ);
    FMT[sizeof(FMT)-1] = 0;
    while(rtosUsed == Unknown 
          && getline(&lineptr, &lnsz, proc_modules) > 0) {
      // read in the modules list one at a time and see if 'rtl' is loaded
      if (sscanf(lineptr, FMT, modname_buf)) {
        modname_buf[BUFSZ-1] = 0;
        if (!strcmp("rtl", modname_buf))
          rtosUsed = RTLinux; // bingo!
      }
    }
    if (lineptr) free(lineptr); // clean up after getline
    fclose(proc_modules);
  }
  
  return rtosUsed;
}

#include <map>
#include <string>

struct ShmInfo
{
  std::string name;
  size_t size;
  void *address;
  RTOS::RTOS rtos;
};

typedef std::map<unsigned long, ShmInfo> ShmMap;
static ShmMap shmMap;

void *RTOS::shmAttach(const char *SHM_NAME, size_t size, ShmStatus *s)
{
  void *ret = 0;
  RTOS rtos = determine();
  if (s) *s = Ok;
  if (rtos != Unknown) {
    ShmInfo shm_info;

    shm_info.size = size;
    shm_info.name = SHM_NAME;
    shm_info.rtos = rtos;

    switch(rtos) {
      case RTLinux:  ret = mbuff_attach(SHM_NAME, size);    break;
      case RTAI:  ret = rtai_shm_attach(SHM_NAME, size);    break;
      default:  break;
    }
    
    if (ret) {
      shm_info.address = ret;
      // save the shm's info for quick reference on detach..
      shmMap [reinterpret_cast<unsigned long>(ret)] = shm_info; 
      if (s) *s = Ok;
    } 
    
    else if (s && *s == Ok) { /* if no shm was available, 
                                 status is Ok, and  pointer is not NULL,
                                 update the ShmStatus intelligently      */
      
      if (determine() == RTLinux || determine() == RTAI) {
        if (!shmDevFileExists())
          *s = MissingDevFile;
        else if (!shmDevFileIsValid())
          *s = InvalidDevFile;
        else *s = NotFound;      
      }
    }
  }
  
  return ret;
}

void RTOS::shmDetach(const void *SHM, ShmStatus *s)
{
  unsigned long shm_key = reinterpret_cast<unsigned long>(SHM);
  ShmMap::iterator it = shmMap.find(shm_key);

  if (s) *s = Ok;

  if ( it != shmMap.end() ) {
      ShmInfo & inf = (*it).second;
      switch (inf.rtos) {
        case RTLinux:  mbuff_detach(inf.name.c_str(), inf.address); break;
        case RTAI:     rtai_shm_detach(inf.name.c_str(), inf.address); break;
        default: break;
      }
      shmMap.erase(it);
  } else if (s) {
      *s = NotFound;
  }
}


/* true iff /dev/mbuff or /dev/rtai_shm at least exists */
bool RTOS::shmDevFileExists()
{
  struct stat statbuf;

  switch(determine()) {
    case RTLinux:
      if ( (stat (MBUFF_DEV_NAME, &statbuf) || !S_ISCHR(statbuf.st_mode))
           && (stat (MBUFF_DEV_NAME2, &statbuf) || !S_ISCHR(statbuf.st_mode)))
        return false;
      return true;
    break;
    case RTAI:
      if ( (stat (RTAI_SHM_DEV, &statbuf) || !S_ISCHR(statbuf.st_mode) )
           && (stat (RTAI3_SHM_DEV, &statbuf) || !S_ISCHR(statbuf.st_mode) ) )
        return false;      
      return true;
    break;
    default: break;
  }
  return false;  
}

/* true iff /dev/mbuff and/or /dev/rtai_shm is valid and openable for RDWR */
bool RTOS::shmDevFileIsValid()
{
  int fd = -1;

  switch(determine()) {
    case RTLinux:
      /* since mbuff_attach isn't very good about giving us exactly what 
	 went wrong, we will attempt to figure out if it was a permissions
	 issue or some other error. */
      if ( (!shmDevFileExists()
            || (fd = open(MBUFF_DEV_NAME, O_RDWR)) < 0 || close(fd))
           && (!shmDevFileExists() 
               || (fd = open(MBUFF_DEV_NAME2, O_RDWR)) < 0 || close(fd))) 
        return false;
      return true;
    break;
    case RTAI:
      /* since rtai_shm_attach isn't very good about giving us exactly what 
	 went wrong, we will attempt to figure out if it was a permissions
	 issue or some other error. */
      if ( (!shmDevFileExists()
            || (fd = open(RTAI_SHM_DEV, O_RDWR)) < 0 
            || close(fd) )
           && (!shmDevFileExists()
            || (fd = open(RTAI3_SHM_DEV, O_RDWR)) < 0 
               || close(fd) ) )        
        return false;
      return true;
    break;
    default: break;
  }
  return false;
}


const char *RTOS::shmDevFile()
{
  switch(determine()) {
  case RTLinux:
    return MBUFF_DEV_NAME;
    break;
  case RTAI:
    {
      struct stat statbuf;
      if (stat(RTAI3_SHM_DEV, &statbuf) == 0) return RTAI3_SHM_DEV;
    }
    return RTAI_SHM_DEV;
    break;
  default:
    break;
  }
  return "<no dev file>";  
}

const char *RTOS::shmDriverName()
{
  switch(determine()) {
  case RTLinux:
    return "mbuff.o";
    break;
  case RTAI:
    return "rtai_shm.o";
    break;
  default:
    break;
  }
  return "<none>";    
}

const char *RTOS::name()
{
  switch(determine()) {
  case RTLinux:
    return "RTLinux";
    break;
  case RTAI:
    return "RTAI";
    break;
  default:
    break;
  }
  return "<No RTOS>";      
}

// opens /dev/rtf[minor no] and returns its fd or -errno on error              
int RTOS::openFifo(int minor_no, ModeFlag mode)
{
  char buf[64];

  snprintf(buf, 63, "/dev/rtf%d", minor_no);
  int m = mode == Read ? O_RDONLY : (mode == Write ? O_WRONLY : O_RDWR);
  int ret = ::open(buf, m);
  if (ret < 0) return -errno;
  return ret;
}


const char *RTOS::statusString(ShmStatus s)
{
  switch(s) {
  case WrongSize:
    return  "The shared memory buffer was created with a different size than that specified in the attach call.";
  case NotFound:
    return "The shared memory buffer could not be found for the specified name.";
  case InvalidDevFile:
    {
      static char msgBuffer[256];
      ::snprintf(msgBuffer, sizeof(msgBuffer), "The shared memory buffer's device file, %s, does not appear to have the correct permissions.", shmDevFile());
      msgBuffer[sizeof(msgBuffer)-1] = 0;
      return  msgBuffer;
    }
  case MissingDevFile:
    {
      static char msgBuffer[256];
      ::snprintf(msgBuffer, sizeof(msgBuffer), "The shared memory buffer's device file, %s, is missing or otherwise inaccessible.", shmDevFile());
      msgBuffer[sizeof(msgBuffer)-1] = 0;
      return  msgBuffer;
    }
  default:
    break;
  }
  return "Success.";
}
