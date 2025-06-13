/****************************************************************************
 Hal.h

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

#ifndef _HAL_H
#define _HAL_H

#ifndef _MSC_VER
	#ifndef MICROSOFT
		#ifndef DEBUG
			//#define DEBUG
		#endif
	#endif
#endif

#include "HalEnv.h"
#include "HalRegister.h"

#include <DrvDebug.h>

// Put this here because there isn't a better place...
#define MAX_NUMBER_OF_ADAPTERS	8	// BUGBUG

/////////////////////////////////////////////////////////////////////////////
// Lynx Specific Defines
/////////////////////////////////////////////////////////////////////////////

#define PCIVENDOR_PLX				0x10b5
#define PCIDEVICE_PLX_9050			0x9050

#define PCIVENDOR_LYNX				0x1621		// Lynx Studio Technology, Inc. PCI ID
#define PCIDEVICE_LYNXONE			0x1142

#ifndef MM_LYNX
	#define	MM_LYNX					212
#endif

/////////////////////////////////////////////////////////////////////////////
// Forward Declarations of Classes
/////////////////////////////////////////////////////////////////////////////
class	CHalAdapter;
typedef CHalAdapter *PHALADAPTER;

class	CHalDevice;
typedef CHalDevice *PHALDEVICE;

class	CHalWaveDevice; 
typedef	CHalWaveDevice *PHALWAVEDEVICE; 

class	CHalWaveDMADevice; 
typedef	CHalWaveDMADevice *PHALWAVEDMADEVICE;

class	CHalMIDIDevice; 
typedef	CHalMIDIDevice *PHALMIDIDEVICE; 

class	CHal8420;
typedef CHal8420 *PHAL8420;

class	CHal4114;
typedef CHal4114 *PHAL4114;

class	CHalSampleClock;
typedef	CHalSampleClock *PHALSAMPLECLOCK;

class	CHalMixer;
typedef CHalMixer *PHALMIXER;

class	CHalPlayMix;
typedef CHalPlayMix *PHALPLAYMIX;

class	CHalRegister;
typedef	CHalRegister *PHALREGISTER;

class	CHalTimecode;
typedef	CHalTimecode *PHALTIMECODE;

class	CHalDMA;
typedef	CHalDMA *PHALDMA;

class	CHalLStream;
typedef	CHalLStream *PHALLSTREAM;

/////////////////////////////////////////////////////////////////////////////
//	PCI Structures
/////////////////////////////////////////////////////////////////////////////
#ifdef _MSC_VER
#pragma pack( push )
#endif
#pragma pack( 1 )

typedef struct
{
	ULONG				ulPhysicalAddress;
	ULONG				ulAddress;
	ULONG				ulSize;
	USHORT				usType;
} PCI_BASEADDRESS, *PPCI_BASEADDRESS;

enum
{
	PCI_BARTYPE_IO=0,
	PCI_BARTYPE_MEM
};

#define MAX_PCI_ADDRESSES	5
#define MAX_PCI_BUSES		255
#define MAX_PCI_DEVICES		32

typedef	struct
{
	ULONG				ulAdapterIndex;
	ULONG				ulDeviceNode;	// For Windows 95
#if defined(MACINTOSH)
	RegEntryID			EntryID;		// The NameRegistry entry ID for this adapter
	char				szSlotName[ 16 ];
#endif
	USHORT				usVendorID;
	USHORT				usDeviceID;
	USHORT				usBusNumber;
	USHORT				usDeviceFunction;
	USHORT				usInterruptLine;
	USHORT				usInterruptPin;
	PCI_BASEADDRESS		Base[ MAX_PCI_ADDRESSES ];
} PCI_CONFIGURATION, *PPCI_CONFIGURATION;

typedef USHORT (HALFINDPROC)( PVOID pContext, PPCI_CONFIGURATION pPCI );
typedef HALFINDPROC *PHALFINDPROC;

typedef USHORT (HALMAPPROC)( PVOID pContext, PPCI_CONFIGURATION pPCI );
typedef HALMAPPROC *PHALMAPPROC;

typedef USHORT (HALUNMAPPROC)( PVOID pContext, PPCI_CONFIGURATION pPCI );
typedef HALUNMAPPROC *PHALUNMAPPROC;

typedef PHALADAPTER (HALGETADAPTER)( PVOID pContext, ULONG ulAdapterNumber );
typedef HALGETADAPTER *PHALGETADAPTER;

typedef USHORT (HALALLOCMEMORY)( PVOID pContext, PVOID *pVAddr, PVOID *pPAddr, ULONG ulLength, ULONG ulAddressMask );
typedef HALALLOCMEMORY *PHALALLOCMEMORY;

typedef USHORT (HALFREEMEMORY)( PVOID pContext, PVOID pMemory );
typedef HALFREEMEMORY *PHALFREEMEMORY;

typedef struct
{
	PHALFINDPROC		pFind;
	PHALMAPPROC			pMap;
	PHALUNMAPPROC		pUnmap;
	PHALGETADAPTER		pGetAdapter;
	PHALALLOCMEMORY		pAllocateMemory;
	PHALFREEMEMORY		pFreeMemory;
	PVOID				pContext;
} HALDRIVERINFO, *PHALDRIVERINFO;

enum
{
	kReasonNone=0,
	kReasonWave,
	kReasonWaveEmpty,
	kReasonDMABufferComplete,
	kReasonDMALimit,
	kReasonDMAEmpty,
	kReasonMIDI,
	kReasonTimecode,	// probably never use this one
	kNumReasons
};

typedef USHORT (HALCALLBACK)( ULONG ulReason, PVOID pContext1, PVOID pContext2 );
typedef HALCALLBACK *PHALCALLBACK;

typedef USHORT (MIXERCONTROLCHANGEDCALLBACK)( PVOID pContext1, USHORT usDstLine, USHORT usSrcLine, USHORT usControl );
typedef MIXERCONTROLCHANGEDCALLBACK *PMIXERCONTROLCHANGEDCALLBACK;

typedef USHORT (MIXERSCENECALLBACK)( PVOID pContext1, ULONG ulScene );
typedef MIXERSCENECALLBACK *PMIXERSCENECALLBACK;

typedef union
{
	struct 
	{
		BYTE	ucFrame;
		BYTE	ucSecond;
		BYTE	ucMinute;
		BYTE	ucHour;
	} Bytes;
	ULONG	ulTimecode;
} TIMECODE, *PTIMECODE;

#define TC_GET_FRM( tc )	((BYTE)(tc & 0xFF))
#define TC_GET_SEC( tc )	((BYTE)((tc >> 8) & 0xFF))
#define TC_GET_MIN( tc )	((BYTE)((tc >> 16) & 0xFF))
#define TC_GET_HRS( tc )	((BYTE)((tc >> 24) & 0xFF))

#define TC_SET_HMSF( h, m, s, f )	MAKEULONG( MAKEWORD( f, s ), MAKEWORD( m, h ) )

#ifdef _MSC_VER
#pragma pack( pop )
#endif

#include "HalStatusCodes.h"

/////////////////////////////////////////////////////////////////////////////
//	WaveFormat
/////////////////////////////////////////////////////////////////////////////
#ifndef WAVE_FORMAT_PCM

typedef struct 
{
    WORD    wFormatTag;        // format type
    WORD    nChannels;         // number of channels (i.e. mono, stereo, etc.)
    DWORD   nSamplesPerSec;    // sample rate
    DWORD   nAvgBytesPerSec;   // for buffer estimation
    WORD    nBlockAlign;       // block size of data
} WAVEFORMAT, *PWAVEFORMAT;

// flags for wFormatTag field of WAVEFORMAT
#define WAVE_FORMAT_PCM     1

// specific waveform format structure for PCM data
typedef struct 
{
    WAVEFORMAT  wf;
    WORD        wBitsPerSample;
} PCMWAVEFORMAT, *PPCMWAVEFORMAT;

typedef struct tWAVEFORMATEX
{
	WORD        wFormatTag;         // format type
	WORD        nChannels;          // number of channels (i.e. mono, stereo...)
	DWORD       nSamplesPerSec;     // sample rate
	DWORD       nAvgBytesPerSec;    // for buffer estimation
	WORD        nBlockAlign;        // block size of data
	WORD        wBitsPerSample;     // number of bits per sample of mono data
	WORD        cbSize;             // the count in bytes of the size of
} WAVEFORMATEX, *PWAVEFORMATEX;

#endif

/////////////////////////////////////////////////////////////////////////////
//	Memory Macros
/////////////////////////////////////////////////////////////////////////////
#ifndef LINUX
#  include <memory.h>
#endif

#define RtlMoveMemory(Destination,Source,Length)	memmove((Destination),(Source),(Length))
#define RtlCopyMemory(Destination,Source,Length)	memcpy((Destination),(Source),(Length))
#define RtlFillMemory(Destination,Length,Fill)		memset((Destination),(Fill),(Length))
#define RtlZeroMemory(Destination,Length)			memset((Destination),0,(Length))

#ifndef kBit0

#define SET( value, mask )	value |= (mask)
#define CLR( value, mask )	value &= (~mask)

#define kBit0	0x00000001
#define kBit1	0x00000002
#define kBit2	0x00000004
#define kBit3	0x00000008
#define kBit4	0x00000010
#define kBit5	0x00000020
#define kBit6	0x00000040
#define kBit7	0x00000080
#define kBit8	0x00000100
#define kBit9	0x00000200
#define kBit10	0x00000400
#define kBit11	0x00000800
#define kBit12	0x00001000
#define kBit13	0x00002000
#define kBit14	0x00004000
#define kBit15	0x00008000
#define kBit16	0x00010000
#define kBit17	0x00020000
#define kBit18	0x00040000
#define kBit19	0x00080000
#define kBit20	0x00100000
#define kBit21	0x00200000
#define kBit22	0x00400000
#define kBit23	0x00800000
#define kBit24	0x01000000
#define kBit25	0x02000000
#define kBit26	0x04000000
#define kBit27	0x08000000
#define kBit28	0x10000000
#define kBit29	0x20000000
#define kBit30	0x40000000
#define kBit31	0x80000000

#endif

#endif /* _HAL_H */
// END
