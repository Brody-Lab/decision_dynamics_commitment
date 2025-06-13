/*
 * This file is part of the RT-Linux Multichannel Data Acquisition System
 *
 * Copyright (C) 1999-2003 David Christini, Calin Culianu
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
#ifndef _RTOS_UTILITY_H
#define _RTOS_UTILITY_H

#include <sys/types.h>

namespace RTOS
{
  enum RTOS {
    Unknown = 0,
    None = Unknown,
    RTLinux, 
    RTAI    
  };

  extern RTOS determine();  
  extern const char *name(); // returns the string name of the current RTOS

  enum ShmStatus {
    Ok = 0,
    WrongSize,
    NotFound,
    InvalidDevFile,
    MissingDevFile
  };
  
  extern void *shmAttach(const char *shm_name, size_t size, ShmStatus *s=0);
  extern void shmDetach(const void *shm, ShmStatus *status=0);

  /* true iff /dev/mbuff or /dev/rtai_shm is valid and openable for RDWR */
  extern bool shmDevFileIsValid(); 
  /* true iff /dev/mbuff or /dev/rtai_shm at least exists */
  extern bool shmDevFileExists(); 

  extern const char *shmDevFile();  // returns filename string of shm dev file
  extern const char *shmDriverName(); // returns name of shm driver

  // opens /dev/rtf[minor no] and returns its fd or -errno on error            
  enum ModeFlag { Read = 1, Write = 2, ReadWrite = Read|Write };
  extern int openFifo(int minor_no, ModeFlag m = Read); 

  extern const char *statusString(ShmStatus s);
};

#endif
