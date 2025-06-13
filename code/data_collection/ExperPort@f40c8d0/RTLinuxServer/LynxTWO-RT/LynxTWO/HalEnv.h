/****************************************************************************
 HalEnv.h

 Description:	Lynx Application Programming Interface Header File

 Created: David A. Hoatson, September 2000
	
 Copyright © 2000 Lynx Studio Technology, Inc.

 This software contains the valuable TRADE SECRETS and CONFIDENTIAL INFORMATION 
 of Lynx Studio Technology, Inc. The software is protected under copyright 
 laws as an unpublished work of Lynx Studio Technology, Inc.  Notice is 
 for informational purposes only and does not imply publication.  The user 
 of this software may make copies of the software for use with products 
 manufactured by Lynx Studio Technology, Inc. or under license from 
 Lynx Studio Technology, Inc. and for no other use.

 THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
 KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR
 PURPOSE.

 Environment: 

 4 spaces per tab

 Revision History
 
 When      Who  Description
 --------- ---  ------------------------------------------------------------
****************************************************************************/
#ifndef _HALENV_H
#define _HALENV_H

/////////////////////////////////////////////////////////////////////////////
// Figure out which compiler we are using
/////////////////////////////////////////////////////////////////////////////

// Is the Microsoft key #define'd
#ifdef _MSC_VER
	#ifndef MICROSOFT
		#define MICROSOFT
	#endif
#endif

// Is the Borland key #define'd
#ifdef __BORLANDC__
	#ifndef BORLAND
		#define BORLAND
		#define DOS			// MUST be in DOS mode as well
	#endif
#endif

// Make sure we didn't define both
#if defined(MICROSOFT) && defined(BORLAND)
	#error Cannot have MICROSOFT and BORLAND both defined!
#endif

/////////////////////////////////////////////////////////////////////////////
// Figure out which operating system we are using
/////////////////////////////////////////////////////////////////////////////

#if !defined(NT) && !defined(LINUX)
#ifdef i386
	#define NT
#endif
#endif

#ifdef ALPHA
	#define NT
#endif

#ifdef WDM
	#undef NT
#endif

#ifdef __MWERKS__ 
	#ifdef TARGET_API_MAC_OSX
		#define OSX_USER_MODE
	#else
		#define MACINTOSH
	#endif
#endif

// Make sure we defined some environment
#if defined(WIN95USER)
	#if defined(ENVIRON)
		#error Multiple Environments Defined!
	#endif
	#define ENVIRON
#endif
#if defined(WIN95VXD)
	#if defined(ENVIRON)
		#error Multiple Environments Defined!
	#endif
	#define ENVIRON
#endif
#if defined(NT)
	#if defined(ENVIRON)
		#error Multiple Environments Defined!
	#endif
	#define ENVIRON
#endif
#if defined(WDM)
	#if defined(ENVIRON)
		#error Multiple Environments Defined!
	#endif
	#define ENVIRON
#endif
#if defined(WIN32USER)
	#if defined(ENVIRON)
		#error Multiple Environments Defined!
	#endif
	#define ENVIRON
#endif
#if defined(DOS)
	#if defined(ENVIRON)
		#error Multiple Environments Defined!
	#endif
	#define ENVIRON
#endif
#if defined(MACINTOSH)
	#if defined(ENVIRON)
		#error Multiple Environments Defined!
	#endif
	#define ENVIRON
#endif
#if defined(OSX)
	#if defined(ENVIRON)
		#error Multiple Environments Defined!
	#endif
	#define ENVIRON
#endif
#if defined(OSX_USER_MODE)
	#if defined(ENVIRON)
		#error Multiple Environments Defined!
	#endif
	#define ENVIRON
#endif

#if defined(LINUX)
#       if defined(ENVIRON)
#          error Multiple Environments Defined!
#       endif
#       define ENVIRON
#endif

#if !defined(ENVIRON)
#       error You must define an environment!
#endif

/////////////////////////////////////////////////////////////////////////////
// Everybody Gets These
/////////////////////////////////////////////////////////////////////////////
#ifndef MAKEULONG
#       define MAKEULONG(low, high)	((ULONG)(((USHORT)(low)) | (((ULONG)((USHORT)(high))) << 16)))
#endif
//#ifndef MAKELONG
//	#define MAKELONG(a, b)      ((LONG)(((WORD)(a)) | ((DWORD)((WORD)(b))) << 16))
//#endif
#ifndef MAKEUSHORT
#       define MAKEUSHORT(low, high)	((USHORT)(((BYTE)(low)) | (((USHORT)((BYTE)(high))) << 8)))
#endif
//#ifndef MAKEWORD
//	#define MAKEWORD(a, b)      ((WORD)(((BYTE)(a)) | ((WORD)((BYTE)(b))) << 8))
//#endif

#define SET( value, mask )	value |= (mask)
#define CLR( value, mask )	value &= (~mask)

/////////////////////////////////////////////////////////////////////////////
// Microsoft
/////////////////////////////////////////////////////////////////////////////
#ifdef MICROSOFT
	// Nothing at the moment
#endif  // MICROSOFT

/////////////////////////////////////////////////////////////////////////////
// Borland DOS
/////////////////////////////////////////////////////////////////////////////
#ifdef BORLAND
	#define register
#endif

/////////////////////////////////////////////////////////////////////////////
// Windows 2000/XP Kernel Mode
/////////////////////////////////////////////////////////////////////////////
#ifdef WDM
	
#ifdef __cplusplus
extern "C" {
#endif
	#include <wdm.h>
	#include <basetsd.h>	// DAH Added May 30, 2000 to be compatible with new MSSDK include files
	#include <windef.h>
	#include <mmsystem.h>
#ifdef __cplusplus
}
#endif

//	inline void* __cdecl operator new(size_t n)
//	{
//		return ExAllocatePool( NonPagedPool, n );
//	}

//	inline void __cdecl operator delete(void* p)
//	{
//		ExFreePool(p);
//	}

	#ifndef WAVE_FORMAT_DOLBY_AC3_SPDIF
		#define	WAVE_FORMAT_DOLBY_AC3_SPDIF            0x0092
	#endif

#endif  // NT

/////////////////////////////////////////////////////////////////////////////
// Windows NT Kernel Mode
/////////////////////////////////////////////////////////////////////////////
#ifdef NT
	//#include <wdm.h>
#ifdef __cplusplus
extern "C" {
#endif
	#include <ntddk.h>
	#include <basetsd.h>	// DAH Added May 30, 2000 to be compatible with new MSSDK include files
	#include <windef.h>
	#include <mmsystem.h>
	#define NOBITMAP	
	#include <mmreg.h>
#ifdef __cplusplus
}
#endif
	#include <wchar.h>

	inline void* __cdecl operator new(size_t n)
	{
		return ExAllocatePool( NonPagedPool, n );
	}

	#ifndef _LYNXGSIF_H_
	inline void __cdecl operator delete(void* p)
	{
		ExFreePool(p);
	}
	#endif

#endif  // NT

/////////////////////////////////////////////////////////////////////////////
// Windows 95 VXD
/////////////////////////////////////////////////////////////////////////////
#ifdef WIN95VXD

extern "C" {
	#define WANTVXDWRAPS
	#include <windows.h>
	#include <mmsystem.h>

	#undef CDECL
	#undef PASCAL
	#undef PSZ
	
	#include <vmm.h>
	#include <vmmreg.h>
	
	#pragma warning (disable:4142)          // turn off "benign redefinition of type"
	#define _NTDEF_	// make sure _LARGE_INTEGER doesn't get defined 
	#include <basedef.h>
	#pragma warning (default:4142)          // turn on "benign redefinition of type"
	
	#include <vxdldr.h>		// must go before vxdwraps.h
	#include <vwin32.h>
	#include <vpicd.h>		// must go before vxdwraps.h and after basedef.h
	#include <vxdwraps.h>
	
	#ifdef CURSEG
	#undef CURSEG
	#endif
	#include <configmg.h>
	#include <regstr.h>
	#include <winerror.h>

	#undef PASCAL
	#define PASCAL      __stdcall

	#include <dsound.h>
	#include <dsdriver.h>
	#include <dscert.h>

	//#include <debug.h>

	#pragma intrinsic(strcpy, strlen)

	#include <string.h>		// for memXXX functions
}	
	#pragma VxD_LOCKED_DATA_SEG
	#pragma VxD_LOCKED_CODE_SEG

	typedef unsigned char		BOOLEAN;
	typedef unsigned char		UCHAR;
	typedef unsigned short		USHORT;
	typedef short				SHORT;
	typedef unsigned long		ULONG;
	typedef unsigned char		*PUCHAR;
	typedef unsigned long		*PULONG;
	typedef unsigned long		*LPULONG;
	typedef unsigned short		*LPUSHORT;

	#define VOID	void

	#define READ_REGISTER_ULONG( pAddr )				*(volatile ULONG * const)(pAddr)
	#define WRITE_REGISTER_ULONG( pAddr, ulValue )		*(volatile ULONG * const)(pAddr) = (ulValue)

	#define READ_REGISTER_BUFFER_ULONG(x, y, z) {                           \
		PULONG registerBuffer = x;                                          \
		PULONG readBuffer = y;                                              \
		ULONG readCount;                                                    \
		for (readCount = z; readCount--; readBuffer++, registerBuffer++) {  \
			*readBuffer = *(volatile ULONG * const)(registerBuffer);        \
		}                                                                   \
	}

	#define WRITE_REGISTER_BUFFER_ULONG(x, y, z) {                            \
		PULONG registerBuffer = x;                                            \
		PULONG writeBuffer = y;                                               \
		ULONG writeCount;                                                     \
		for (writeCount = z; writeCount--; writeBuffer++, registerBuffer++) { \
			*(volatile ULONG * const)(registerBuffer) = *writeBuffer;         \
		}                                                                     \
	}

#ifdef DEBUG
extern "C" {
	int __cdecl _inp( unsigned port );
	int __cdecl _outp( unsigned port, int databyte );
}
	#pragma intrinsic( _inp, _outp )

	#define WRITE_PORT_UCHAR(a,x)						_outp( (unsigned)(a), (int)(x) )
	#define READ_PORT_UCHAR(a)							_inp( (unsigned)(a) )
#endif

	inline void* __cdecl operator new(size_t n)
	{
		return _HeapAllocate( n, 0 );
	}

	inline void __cdecl operator delete(void* p)
	{
		_HeapFree(p,0);
	}

	#define PCI_TYPE0_ADDRESSES		5

	#ifndef WAVE_FORMAT_DOLBY_AC3_SPDIF
		#define	WAVE_FORMAT_DOLBY_AC3_SPDIF            0x0092
	#endif

#endif  // VXD

/////////////////////////////////////////////////////////////////////////////
// Windows 95 User Mode (16 Bit)
/////////////////////////////////////////////////////////////////////////////
#ifdef WIN95USER

#ifdef WIN32	// Compiling within the IDE
	#undef MAKEWORD
#endif

	#include <windows.h>
	#include <mmsystem.h>

	#define MMNOAUXDEV
	#define MMNOJOYDEV
	#define MMNOMCIDEV
	#define MMNOTASKDEV
	#include <mmddk.h>
	#include <mmreg.h>

#ifdef WIN32	// Compiling within the IDE
	#undef FAR
	#undef NEAR
	#define FAR                 
	#define NEAR                
	#define EXPORT
	#define LOADDS
	#define MAKELP(sel, off)    ((void FAR*)MAKELONG((off), (sel)))
	#define DRVM_EXIT		0x65
	#define	DRVM_DISABLE	0x66
	#define	DRVM_ENABLE		0x67
#else
	#define EXPORT	_export
	#define LOADDS	_loadds
#endif

	#ifndef MM_LYNX
	#define	MM_LYNX		212
	#endif

	// generate intrinsic code instead of function calls
	void _enable( void );
	void _disable( void );
	#pragma intrinsic( _enable, _disable )

	typedef unsigned int		UINT;
	typedef unsigned char		BOOLEAN;
	typedef unsigned char		UCHAR;
	typedef unsigned short		USHORT;
	typedef short				SHORT;
	typedef unsigned long		ULONG;
	typedef unsigned short FAR	*LPUSHORT;
	typedef unsigned char FAR	*LPBYTE;
	typedef unsigned char FAR	*LPUCHAR;
	typedef unsigned long FAR	*LPULONG;
	typedef char FAR			*LPSTR;
	#define VOID	void
	
	#define labs(a)         (a) < 0 ? (-a) : (a)
	#define abs(a)          (a) < 0 ? (-a) : (a)
#endif

/////////////////////////////////////////////////////////////////////////////
// Win32 User Mode
/////////////////////////////////////////////////////////////////////////////
#ifdef WIN32USER
	#include <windows.h>
	#include <mmsystem.h>

	#define PCI_TYPE0_ADDRESSES	5	// used by ShowLynx

	#define VOID                void
	
	typedef unsigned char		BOOLEAN;
	typedef unsigned char		UCHAR;
	//typedef char				TCHAR;

	typedef short				SHORT;
	typedef long				LONG;
	typedef unsigned short		USHORT;
	typedef unsigned long		ULONG;

	typedef short FAR			*PSHORT;
	typedef long FAR			*PLONG;
	typedef unsigned short FAR	*PUSHORT;
	typedef unsigned long FAR	*PULONG;
	
	typedef unsigned char FAR	*PBYTE;
	typedef unsigned char FAR	*PUCHAR;
	typedef unsigned char FAR	*LPUCHAR;
	typedef unsigned long FAR	*LPULONG;

	typedef unsigned char       BYTE;
	typedef unsigned short      WORD;
	typedef unsigned long       DWORD;
	typedef unsigned long		ULONG;
	typedef unsigned int		UINT;

	#ifndef WAVE_FORMAT_DOLBY_AC3_SPDIF
		#define	WAVE_FORMAT_DOLBY_AC3_SPDIF            0x0092
	#endif

	DWORD	ReadDWORD( PULONG pAddress );
	VOID	WriteDWORD( PULONG pAddress, ULONG ulData );
	VOID	ReadDWORDBuffer( PULONG pAddress, PULONG pBuffer, ULONG ulLength );
	VOID	WriteDWORDBuffer( PULONG pAddress, PULONG pBuffer, ULONG ulLength  );

#undef READ_REGISTER_ULONG
#undef WRITE_REGISTER_ULONG

//	#define READ_REGISTER_ULONG( pAddr )				*(DWORD FAR *)(pAddr)
//	#define WRITE_REGISTER_ULONG( pAddr, ulValue )		*(DWORD FAR *)(pAddr) = (ulValue)
	#define READ_REGISTER_ULONG( pAddr )				ReadDWORD( pAddr )
	#define WRITE_REGISTER_ULONG( pAddr, ulValue )		WriteDWORD( pAddr, ulValue )

	#define READ_REGISTER_BUFFER_ULONG( pAddr, pBuffer, ulSize )	ReadDWORDBuffer( pAddr, pBuffer, ulSize )
	#define WRITE_REGISTER_BUFFER_ULONG( pAddr, pBuffer, ulSize )	WriteDWORDBuffer( pAddr, pBuffer, ulSize )
#endif

/////////////////////////////////////////////////////////////////////////////
// DOS BorlandC
/////////////////////////////////////////////////////////////////////////////
#ifdef DOS
	#include <memory.h>

	#ifndef MAKELONG
		#define MAKELONG(a, b)      ((LONG)(((WORD)(a)) | ((DWORD)((WORD)(b))) << 16))
	#endif

#ifdef DEBUG
	#undef DPF
	_CRTIMP int __cdecl printf(const char *, ...);
	#define DPF( _SZ_ )	printf _SZ_
#else
	#define DPF( _SZ_ )
#endif

	#ifndef TRUE
		#define TRUE    1
	#endif
	#ifndef FALSE
		#define FALSE   0
	#endif

	#define VOID                void
#ifdef WIN32
	#define FAR                 
	#define NEAR
	#undef HUGE
	#define HUGE
#else
	#define NEAR                _near
	#define FAR                 _far
	#undef HUGE
	#define HUGE				_huge
#endif
	#define PASCAL              _pascal
	#define CDECL               _cdecl
	#define NULL				0

	typedef unsigned char		BOOLEAN;
	typedef unsigned char		BOOL;
	typedef unsigned char		UCHAR;

	typedef short				SHORT;
	typedef long				LONG;
	typedef unsigned short		USHORT;
	typedef unsigned long		ULONG;

	typedef short FAR			*PSHORT;
	typedef long FAR			*PLONG;
	typedef unsigned short FAR	*PUSHORT;
	typedef unsigned long FAR	*PULONG;
	
	typedef unsigned char FAR	*PBYTE;
	typedef unsigned char FAR	*PUCHAR;
	typedef unsigned char FAR	*PVOID;
	typedef unsigned char FAR	*LPUCHAR;
	typedef unsigned long FAR	*LPULONG;
	typedef unsigned char FAR	*LPVOID;

	typedef unsigned char       BYTE;
	typedef unsigned short      WORD;
	typedef unsigned long       DWORD;
	typedef unsigned int		UINT;
	typedef unsigned long		ULONG;

	typedef unsigned long		LONGLONG;	// BUGBUG

	#define LOBYTE(w)           ((BYTE)(w))
	#define HIBYTE(w)           ((BYTE)(((WORD)(w) >> 8) & 0xFF))
	#define LOWORD(l)           ((WORD)(DWORD)(l))
	#define HIWORD(l)           ((WORD)((((DWORD)(l)) >> 16) & 0xFFFF))

	typedef struct waveformat_tag {
		WORD    wFormatTag;        /* format type */
		WORD    nChannels;         /* number of channels (i.e. mono, stereo, etc.) */
		DWORD   nSamplesPerSec;    /* sample rate */
		DWORD   nAvgBytesPerSec;   /* for buffer estimation */
		WORD    nBlockAlign;       /* block size of data */
	} WAVEFORMAT, *PWAVEFORMAT, NEAR *NPWAVEFORMAT, FAR *LPWAVEFORMAT;

	/* flags for wFormatTag field of WAVEFORMAT */
	#define WAVE_FORMAT_PCM     1
	#define	WAVE_FORMAT_DOLBY_AC3_SPDIF            0x0092

	/* specific waveform format structure for PCM data */
	typedef struct pcmwaveformat_tag {
		WAVEFORMAT  wf;
		WORD        wBitsPerSample;
	} PCMWAVEFORMAT, *PPCMWAVEFORMAT, NEAR *NPPCMWAVEFORMAT, FAR *LPPCMWAVEFORMAT;

	typedef struct tWAVEFORMATEX
	{
		WORD        wFormatTag;         /* format type */
		WORD        nChannels;          /* number of channels (i.e. mono, stereo...) */
		DWORD       nSamplesPerSec;     /* sample rate */
		DWORD       nAvgBytesPerSec;    /* for buffer estimation */
		WORD        nBlockAlign;        /* block size of data */
		WORD        wBitsPerSample;     /* number of bits per sample of mono data */
		WORD        cbSize;             /* the count in bytes of the size of */
	} WAVEFORMATEX, *PWAVEFORMATEX, NEAR *NPWAVEFORMATEX, FAR *LPWAVEFORMATEX;

	// Assumes pAddr is in segment:offset form.
	// 386 instructions must be turned on for this to work
	#define READ_REGISTER_ULONG( pAddr )				*(DWORD FAR *)(pAddr)
	#define WRITE_REGISTER_ULONG( pAddr, ulValue )		*(DWORD FAR *)(pAddr) = (ulValue)

	VOID	ReadDWORDBuffer( PULONG pAddress, PULONG pBuffer, ULONG ulLength );
	VOID	WriteDWORDBuffer( PULONG pAddress, PULONG pBuffer, ULONG ulLength  );
	#define READ_REGISTER_BUFFER_ULONG( pAddr, pBuffer, ulSize )	ReadDWORDBuffer( pAddr, pBuffer, ulSize )
	#define WRITE_REGISTER_BUFFER_ULONG( pAddr, pBuffer, ulSize )	WriteDWORDBuffer( pAddr, pBuffer, ulSize )

	#define PCI_TYPE0_ADDRESSES		5
#endif

#ifdef MACINTOSH
	//#define DEBUG
	#include <DriverServices.h>
	#include <DriverSynchronization.h>	// brings in SynchronizeIO()
	#include <DriverGestalt.h>
	#include <PCI.h>					// will include NameRegistry.h
	#include <NameRegistry.h>

	#include <stdio.h>
	#include <unix.h>
	#include <stdlib.h>
	#include <string.h>

	#ifndef TRUE
		#define TRUE    1
	#endif
	#ifndef FALSE
		#define FALSE   0
	#endif

	#define FAR                 
	#define NEAR
	
	#define VOID                void
	
	typedef unsigned char		BOOLEAN;
	typedef unsigned char		BOOL;
	typedef unsigned char		UCHAR;
	typedef char				TCHAR;

	typedef short				SHORT;
	typedef long				LONG;
	typedef unsigned short		USHORT;
	typedef unsigned long		ULONG;

	typedef short FAR			*PSHORT;
	typedef long FAR			*PLONG;
	typedef unsigned short FAR	*PUSHORT;
	typedef unsigned long FAR	*PULONG;
	typedef unsigned char FAR	*PBOOLEAN;
	
	typedef unsigned char FAR	*PBYTE;
	typedef unsigned char FAR	*PUCHAR;
	typedef unsigned char FAR	*PVOID;
	typedef unsigned char FAR	*LPUCHAR;
	typedef unsigned long FAR	*LPULONG;
	typedef unsigned char FAR	*LPVOID;

	typedef unsigned char       BYTE;
	typedef unsigned short      WORD;
	typedef unsigned long       DWORD;
	typedef unsigned int		UINT;
	typedef unsigned long		ULONG;
	typedef unsigned int		UINT;
	
#ifdef MICROSOFT
	typedef __int64				LONGLONG;
	typedef unsigned __int64	ULONGLONG;
	#define pascal
#else
	typedef long long			__int64;
	typedef long long			LONGLONG;
	typedef unsigned long long	ULONGLONG;
#endif
	
	//#define MAKELONG(a, b)      ((LONG)(((WORD)(a)) | ((DWORD)((WORD)(b))) << 16))
	//#define MAKEWORD(a, b)      ((WORD)(((BYTE)(a)) | ((WORD)((BYTE)(b))) << 8))
	#ifndef MAKEWORD
		#define MAKEWORD(a, b)      ((WORD)(((BYTE)(a)) | ((WORD)((BYTE)(b))) << 8))
	#endif

//	#define i64
	
	#define	TEXT( a )	a
	
	#define PCI_TYPE0_ADDRESSES	5

	#define LOBYTE(w)           ((BYTE)(w))
	#define HIBYTE(w)           ((BYTE)(((WORD)(w) >> 8) & 0xFF))
	#define LOWORD(l)           ((WORD)(DWORD)(l))
	#define HIWORD(l)           ((WORD)((((DWORD)(l)) >> 16) & 0xFFFF))

	typedef struct waveformat_tag {
		WORD    wFormatTag;        /* format type */
		WORD    nChannels;         /* number of channels (i.e. mono, stereo, etc.) */
		DWORD   nSamplesPerSec;    /* sample rate */
		DWORD   nAvgBytesPerSec;   /* for buffer estimation */
		WORD    nBlockAlign;       /* block size of data */
	} WAVEFORMAT, *PWAVEFORMAT, NEAR *NPWAVEFORMAT, FAR *LPWAVEFORMAT;

	/* flags for wFormatTag field of WAVEFORMAT */
	#define WAVE_FORMAT_PCM     1
	#define	WAVE_FORMAT_DOLBY_AC3_SPDIF            0x0092

	/* specific waveform format structure for PCM data */
	typedef struct pcmwaveformat_tag {
		WAVEFORMAT  wf;
		WORD        wBitsPerSample;
	} PCMWAVEFORMAT, *PPCMWAVEFORMAT, NEAR *NPPCMWAVEFORMAT, FAR *LPPCMWAVEFORMAT;

	typedef struct tWAVEFORMATEX
	{
		WORD        wFormatTag;         /* format type */
		WORD        nChannels;          /* number of channels (i.e. mono, stereo...) */
		DWORD       nSamplesPerSec;     /* sample rate */
		DWORD       nAvgBytesPerSec;    /* for buffer estimation */
		WORD        nBlockAlign;        /* block size of data */
		WORD        wBitsPerSample;     /* number of bits per sample of mono data */
		WORD        cbSize;             /* the count in bytes of the size of */
	} WAVEFORMATEX, *PWAVEFORMATEX, NEAR *NPWAVEFORMATEX, FAR *LPWAVEFORMATEX;

	ULONG	MacReadULONG( PULONG pAddress );
	void	MacWriteULONG( PULONG pAddress, ULONG ulValue );

//#ifdef L2UPDATE
	#define READ_REGISTER_ULONG( pAddr )				MacReadULONG( pAddr )
//#else
//	#define READ_REGISTER_ULONG( pAddr )				*(ULONG FAR *)(pAddr)
//#endif
	#define WRITE_REGISTER_ULONG( pAddr, ulValue )		MacWriteULONG( pAddr, ulValue )

	#define READ_REGISTER_BUFFER_ULONG(x, y, z) {                           \
		PULONG registerBuffer = x;                                          \
		PULONG readBuffer = y;                                              \
		ULONG readCount;                                                    \
		for (readCount = z; readCount--; readBuffer++, registerBuffer++) {  \
			*readBuffer = MacReadULONG( registerBuffer );					\
		}                                                                   \
	}

	#define WRITE_REGISTER_BUFFER_ULONG(x, y, z) {                            \
		PULONG registerBuffer = x;                                            \
		PULONG writeBuffer = y;                                               \
		ULONG writeCount;                                                     \
		for (writeCount = z; writeCount--; writeBuffer++, registerBuffer++) { \
			MacWriteULONG( registerBuffer, *writeBuffer );					\
		}                                                                     \
	}

	//#include <DrvDebug.h>
#endif

#ifdef OSX
	//#define DEBUG

	//#include <stdio.h>
	//#include <stdlib.h>
	//#include <string.h>
	
	#include <IOKit/IOLib.h> //need this only for the kext

	#ifndef TRUE
		#define TRUE    1
	#endif
	#ifndef FALSE
		#define FALSE   0
	#endif

	#define FAR                 
	#define NEAR
	
	#define VOID                void

	typedef unsigned char		BOOLEAN;
	typedef unsigned char		BOOL;
	typedef unsigned char		UCHAR;
	typedef char				TCHAR;
	typedef char				CHAR;

	typedef short				SHORT;
	typedef long				LONG;
	typedef unsigned short		USHORT;
	typedef unsigned long		ULONG;

	typedef short FAR			*PSHORT;
	typedef long FAR			*PLONG;
	typedef unsigned short FAR	*PUSHORT;
	typedef unsigned long FAR	*PULONG;
	
	typedef unsigned char FAR	*PBYTE;
	typedef unsigned char FAR	*PUCHAR;
	typedef unsigned char FAR	*PVOID;
	typedef unsigned char FAR	*LPUCHAR;
	typedef unsigned long FAR	*LPULONG;
	typedef unsigned char FAR	*LPVOID;

	typedef unsigned char       BYTE;
	typedef unsigned short      WORD;
	typedef unsigned long       DWORD;
	typedef unsigned int		UINT;
	typedef unsigned long		ULONG;
	typedef unsigned int		UINT;
	
	typedef long long			__int64;
	typedef long long			LONGLONG;

	typedef unsigned long long	ULONGLONG;
	
	//#define MAKELONG(a, b)      ((LONG)(((WORD)(a)) | ((DWORD)((WORD)(b))) << 16))
	//#define MAKEWORD(a, b)      ((WORD)(((BYTE)(a)) | ((WORD)((BYTE)(b))) << 8))
	#ifndef MAKEWORD
		#define MAKEWORD(a, b)      ((WORD)(((BYTE)(a)) | ((WORD)((BYTE)(b))) << 8))
	#endif

//	#define i64
	
	#define	TEXT( a )	a
	
	#define PCI_TYPE0_ADDRESSES	5

	#define LOBYTE(w)           ((BYTE)(w))
	#define HIBYTE(w)           ((BYTE)(((WORD)(w) >> 8) & 0xFF))
	#define LOWORD(l)           ((WORD)(DWORD)(l))
	#define HIWORD(l)           ((WORD)((((DWORD)(l)) >> 16) & 0xFFFF))

	typedef struct waveformat_tag {
		WORD    wFormatTag;        /* format type */
		WORD    nChannels;         /* number of channels (i.e. mono, stereo, etc.) */
		DWORD   nSamplesPerSec;    /* sample rate */
		DWORD   nAvgBytesPerSec;   /* for buffer estimation */
		WORD    nBlockAlign;       /* block size of data */
	} WAVEFORMAT, *PWAVEFORMAT, NEAR *NPWAVEFORMAT, FAR *LPWAVEFORMAT;

	/* flags for wFormatTag field of WAVEFORMAT */
	#define WAVE_FORMAT_PCM     1
	#define	WAVE_FORMAT_DOLBY_AC3_SPDIF            0x0092

	#define READ_REGISTER_ULONG( pAddr )				*(ULONG FAR *)(pAddr)
	#define WRITE_REGISTER_ULONG( pAddr, ulValue )		*((ULONG *)pAddr) = ulValue

	#define READ_REGISTER_BUFFER_ULONG(x, y, z) {                           \
		PULONG registerBuffer = x;                                          \
		PULONG readBuffer = y;                                              \
		ULONG readCount;                                                    \
		for (readCount = z; readCount--; readBuffer++, registerBuffer++) {  \
			*readBuffer = *(volatile ULONG * const)(registerBuffer);        \
		}                                                                   \
	}
	#define WRITE_REGISTER_BUFFER_ULONG(x, y, z) {                            \
		PULONG registerBuffer = x;                                            \
		PULONG writeBuffer = y;                                               \
		ULONG writeCount;                                                     \
		for (writeCount = z; writeCount--; writeBuffer++, registerBuffer++) { \
			*(volatile ULONG * const)(registerBuffer) = *writeBuffer;         \
		}                                                                     \
	}

#endif


#ifdef OSX_USER_MODE
	//#define DEBUG

	//#include <stdio.h>
	//#include <stdlib.h>
	//#include <string.h>
	//#include <IOKit/IOLib.h> //need this only for the kext

	#ifndef TRUE
		#define TRUE    1
	#endif
	#ifndef FALSE
		#define FALSE   0
	#endif

	#define FAR                 
	#define NEAR
	
	#define VOID                void

#ifdef DEBUG
	#undef DPF
	#define DPF( _SZ_ )	dprintf _SZ_
#else
	#define DPF( _SZ_ )
#endif

	
	typedef unsigned char		BOOLEAN;
	typedef unsigned char		BOOL;
	typedef unsigned char		UCHAR;
	typedef char				TCHAR;

	typedef short				SHORT;
	typedef long				LONG;
	typedef unsigned short		USHORT;
	typedef unsigned long		ULONG;

	typedef short FAR			*PSHORT;
	typedef long FAR			*PLONG;
	typedef unsigned short FAR	*PUSHORT;
	typedef unsigned long FAR	*PULONG;
	
	typedef unsigned char FAR	*PBYTE;
	typedef unsigned char FAR	*PUCHAR;
	typedef unsigned char FAR	*PVOID;
	typedef unsigned char FAR	*LPUCHAR;
	typedef unsigned long FAR	*LPULONG;
	typedef unsigned char FAR	*LPVOID;

	typedef unsigned char       BYTE;
	typedef unsigned short      WORD;
	typedef unsigned long       DWORD;
	typedef unsigned int		UINT;
	typedef unsigned long		ULONG;
	typedef unsigned int		UINT;
	
	typedef long long			__int64;
	typedef long long			LONGLONG;

	typedef unsigned long long	ULONGLONG;
	
	//#define MAKELONG(a, b)      ((LONG)(((WORD)(a)) | ((DWORD)((WORD)(b))) << 16))
	//#define MAKEWORD(a, b)      ((WORD)(((BYTE)(a)) | ((WORD)((BYTE)(b))) << 8))
	#ifndef MAKEWORD
		#define MAKEWORD(a, b)      ((WORD)(((BYTE)(a)) | ((WORD)((BYTE)(b))) << 8))
	#endif

//	#define i64
	
	#define	TEXT( a )	a
	
	#define PCI_TYPE0_ADDRESSES	5

	#define LOBYTE(w)           ((BYTE)(w))
	#define HIBYTE(w)           ((BYTE)(((WORD)(w) >> 8) & 0xFF))
	#define LOWORD(l)           ((WORD)(DWORD)(l))
	#define HIWORD(l)           ((WORD)((((DWORD)(l)) >> 16) & 0xFFFF))

	typedef struct waveformat_tag {
		WORD    wFormatTag;        /* format type */
		WORD    nChannels;         /* number of channels (i.e. mono, stereo, etc.) */
		DWORD   nSamplesPerSec;    /* sample rate */
		DWORD   nAvgBytesPerSec;   /* for buffer estimation */
		WORD    nBlockAlign;       /* block size of data */
	} WAVEFORMAT, *PWAVEFORMAT, NEAR *NPWAVEFORMAT, FAR *LPWAVEFORMAT;

	/* flags for wFormatTag field of WAVEFORMAT */
	#define WAVE_FORMAT_PCM     1
	#define	WAVE_FORMAT_DOLBY_AC3_SPDIF            0x0092

	ULONG	MacReadULONG( PULONG pAddress );
	void	MacWriteULONG( PULONG pAddress, ULONG ulValue );

	#define READ_REGISTER_ULONG( pAddr )				MacReadULONG( pAddr )
	#define WRITE_REGISTER_ULONG( pAddr, ulValue )		MacWriteULONG( pAddr, ulValue )

	#define READ_REGISTER_BUFFER_ULONG(x, y, z) {                           \
		PULONG registerBuffer = x;                                          \
		PULONG readBuffer = y;                                              \
		ULONG readCount;                                                    \
		for (readCount = z; readCount--; readBuffer++, registerBuffer++) {  \
			*readBuffer = MacReadULONG(registerBuffer);        \
		}                                                                   \
	}
	#define WRITE_REGISTER_BUFFER_ULONG(x, y, z) {                            \
		PULONG registerBuffer = x;                                            \
		PULONG writeBuffer = y;                                               \
		ULONG writeCount;                                                     \
		for (writeCount = z; writeCount--; writeBuffer++, registerBuffer++) { \
			MacWriteULONG( registerBuffer, *writeBuffer );					\
		}                                                                     \
	}

#endif

#ifdef LINUX
	//#define DEBUG

	//#include <stdio.h>
	//#include <stdlib.h>
	//#include <string.h>
	
#       ifndef TRUE
#          define TRUE    1
#       endif

#       ifndef FALSE
#	   define FALSE   0
#	endif

#	define FAR                 
#	define NEAR
	
#	define VOID                void

	typedef unsigned char		BOOLEAN;
	typedef unsigned char		BOOL;
	typedef unsigned char		UCHAR;
	typedef char				TCHAR;
	typedef char				CHAR;

	typedef short				SHORT;
	typedef long				LONG;
	typedef unsigned short		USHORT;
	typedef unsigned long		ULONG;

	typedef short FAR			*PSHORT;
	typedef long FAR			*PLONG;
	typedef unsigned short FAR	*PUSHORT;
	typedef unsigned long FAR	*PULONG;
	
	typedef unsigned char FAR	*PBYTE;
	typedef unsigned char FAR	*PUCHAR;
	typedef unsigned char FAR	*PVOID;
	typedef unsigned char FAR	*LPUCHAR;
	typedef unsigned long FAR	*LPULONG;
	typedef unsigned char FAR	*LPVOID;

	typedef unsigned char       BYTE;
	typedef unsigned short      WORD;
	typedef unsigned long       DWORD;
	typedef unsigned int		UINT;
	
	typedef long long			__int64;
	typedef long long			LONGLONG;

	typedef unsigned long long	ULONGLONG;
	
	//#define MAKELONG(a, b)      ((LONG)(((WORD)(a)) | ((DWORD)((WORD)(b))) << 16))
	//#define MAKEWORD(a, b)      ((WORD)(((BYTE)(a)) | ((WORD)((BYTE)(b))) << 8))
#	ifndef MAKEWORD
#		define MAKEWORD(a, b)      ((WORD)(((BYTE)(a)) | ((WORD)((BYTE)(b))) << 8))
#	endif

//	#define i64
	
#	define	TEXT( a )	a
	
#	define PCI_TYPE0_ADDRESSES	5

#	define LOBYTE(w)           ((BYTE)(w))
#	define HIBYTE(w)           ((BYTE)(((WORD)(w) >> 8) & 0xFF))
#	define LOWORD(l)           ((WORD)(DWORD)(l))
#	define HIWORD(l)           ((WORD)((((DWORD)(l)) >> 16) & 0xFFFF))

	typedef struct waveformat_tag {
		WORD    wFormatTag;        /* format type */
		WORD    nChannels;         /* number of channels (i.e. mono, stereo, etc.) */
		DWORD   nSamplesPerSec;    /* sample rate */
		DWORD   nAvgBytesPerSec;   /* for buffer estimation */
		WORD    nBlockAlign;       /* block size of data */
	} WAVEFORMAT, *PWAVEFORMAT, NEAR *NPWAVEFORMAT, FAR *LPWAVEFORMAT;

	/* flags for wFormatTag field of WAVEFORMAT */
#	define WAVE_FORMAT_PCM     1
#	define	WAVE_FORMAT_DOLBY_AC3_SPDIF            0x0092

/* Linux-specific stuff.. see HalEnv.c */
#ifdef __cplusplus
extern "C" {
#endif
  extern ULONG read_register_ulong(volatile const void *pAddr);
  extern void write_register_ulong(volatile void *pAddr, ULONG ulValue);
  extern void memcpy_toio_linux(volatile void *dest, void *source, unsigned num);
  extern void memcpy_fromio_linux(void *dest, volatile void *source, unsigned num);
  extern void *memcpy_linux(void *dest, const void *src, unsigned n);
  extern void *memset_linux(void *s, int c, unsigned n);
# ifndef HALENV_INTERNAL
#   define memcpy memcpy_linux
#   define memset memset_linux
# endif
#ifdef __cplusplus
}
#endif 

#ifdef __cplusplus
// operator new and delete implemented in LinuxGlue.cpp
extern void *operator new(unsigned int size);
extern void operator delete(void *p);
extern void *operator new[](unsigned int size);
extern void operator delete[](void *p);
#endif


#	define READ_REGISTER_ULONG( pAddr )				read_register_ulong((volatile const ULONG  *)(pAddr))


#	define WRITE_REGISTER_ULONG( pAddr, ulValue )		write_register_ulong(((ULONG *)pAddr),ulValue)

#	define READ_REGISTER_BUFFER_ULONG(x, y, z)   memcpy_fromio_linux(y, x, z)
/*	{ \
	PULONG registerBuffer = x;                                        \
		PULONG readBuffer = y;                                              \
		ULONG readCount;                                                    \
		for (readCount = z; readCount--; readBuffer++, registerBuffer++) {  \
			*(volatile ULONG *)(readBuffer) = READ_REGISTER_ULONG(registerBuffer);        \
		}                                                                   \
	}
*/
#	define WRITE_REGISTER_BUFFER_ULONG(x, y, z) memcpy_toio_linux(x, y, z)
/*{                            \
		PULONG registerBuffer = x;                                            \
		PULONG writeBuffer = y;                                               \
		ULONG writeCount;                                                     \
		for (writeCount = z; writeCount--; writeBuffer++, registerBuffer++) { \
			WRITE_REGISTER_ULONG(registerBuffer, *writeBuffer);  \
/ * *(volatile ULONG * const)(registerBuffer) = *writeBuffer;         * / \
		}                                                            \
	}
*/
#ifndef NULL
#        define  NULL 0
#endif

#endif /* LINUX */

#endif // _HALENV_H
