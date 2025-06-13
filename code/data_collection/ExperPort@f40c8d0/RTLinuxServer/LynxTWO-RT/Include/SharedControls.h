/****************************************************************************
 SharedControls.h

 Created: David A. Hoatson, September 2002
	
 Copyright © 2002 Lynx Studio Technology, Inc.

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
#ifndef _SHAREDCONTROLS_H
#define	_SHAREDCONTROLS_H

#define SC_NUM_CHANNELS				16
#define SC_NUM_DEVICES				8
#define SC_NUM_FREQUENCY_COUNTERS	13
#define SC_NUM_AES16_STATUS			8
#define SC_NUM_AES16_SRC			4

typedef struct
{
	// Metering
	ULONG		aulInputMeters[ SC_NUM_CHANNELS ];
	ULONG		aulOutputMeters[ SC_NUM_CHANNELS ];
	// LTC In
	ULONG		ulLTCInPosition;
	// LTC Out
	ULONG		ulLTCOutPosition;
	// LStream
	ULONG		ulLS1ADATPosition;
	ULONG		ulLS2ADATPosition;
} FASTUPDATECONTROLS, *PFASTUPDATECONTROLS;

typedef struct
{
	// Metering
	ULONG		aulOutputOverload[ SC_NUM_CHANNELS ];
	// Digital I/O
	LONG		lDigitalInRate;
	ULONG		ulDigitalInSRCRatio;
	ULONG		ulDigitalInStatus;		// Bitmap
	// Frequency Counters
	ULONG		aulFrequencyCounters[ SC_NUM_FREQUENCY_COUNTERS ];
	// AES16
	ULONG		aulDigitalInStatus[ SC_NUM_AES16_STATUS ];
	ULONG		aulDigitalInSRCRatio[ SC_NUM_AES16_SRC ];
	ULONG		ulSynchroLockStatus;
	// LTC In
	ULONG		bLTCInLock;
	ULONG		ulLTCInDirection;
	ULONG		bLTCInDropframe;
	ULONG		ulLTCInFramerate;
	// Device Dropout Count
	ULONG		aulRecordDeviceDropout[ SC_NUM_DEVICES ];
	ULONG		aulPlayDeviceDropout[ SC_NUM_DEVICES ];
	// LStream
	ULONG		ulLS1DeviceID;
	ULONG		ulLS2DeviceID;
	// LS-ADAT
	ULONG		bLS1ADATIn1Lock;
	ULONG		bLS1ADATIn2Lock;
	ULONG		bLS2ADATIn1Lock;
	ULONG		bLS2ADATIn2Lock;
	// LS-AES
	ULONG		ulLS1AESStatus1;
	ULONG		ulLS1AESStatus2;
	ULONG		ulLS1AESStatus3;
	ULONG		ulLS1AESStatus4;
	ULONG		ulLS1AESSRCRatio1;
	ULONG		ulLS1AESSRCRatio2;
	ULONG		ulLS1AESSRCRatio3;
	ULONG		ulLS1AESSRCRatio4;
	ULONG		ulLS2AESStatus1;
	ULONG		ulLS2AESStatus2;
	ULONG		ulLS2AESStatus3;
	ULONG		ulLS2AESStatus4;
	ULONG		ulLS2AESSRCRatio1;
	ULONG		ulLS2AESSRCRatio2;
	ULONG		ulLS2AESSRCRatio3;
	ULONG		ulLS2AESSRCRatio4;
} SLOWUPDATECONTROLS, *PSLOWUPDATECONTROLS;

typedef struct
{
	LONGLONG				llTimestamp;
	ULONG					ulControlRequest;
	FASTUPDATECONTROLS		Fast;
	SLOWUPDATECONTROLS		Slow;
} SHAREDCONTROLS, *PSHAREDCONTROLS;

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

#define	REQ_FAST_CONTROLS	kBit0
#define	REQ_SLOW_CONTROLS	kBit1

#define DIS_ERR_PARITY		kBit0
#define DIS_ERR_BIPHASE		kBit1
#define DIS_ERR_CONFIDENCE	kBit2
#define DIS_ERR_VALIDITY	kBit3
#define DIS_ERR_UNLOCK		kBit4
#define DIS_ERR_CSCRC		kBit5
#define DIS_ERR_QCRC		kBit6
#define DIS_RXCS_ORIGNIAL	kBit8	// Set for SCMS Orginal Mode, Clear for 1st Gen+ Copy
#define DIS_RXCS_COPYRIGHT	kBit9	// Set for SCMS Copyright
#define DIS_RXCS_NONAUDIO	kBit10	// Set for Non-Audio, Clear for PCM Audio
#define DIS_RXCS_PRO		kBit11	// Set for PRO mode, Clear for Consumer

#define DEVICEID_LSADAT		1
#define DEVICEID_LSAES		2
#define DEVICEID_LSTDIF		3

// <AK4114 Digital Input Status>
#define kInStatusErrUnlock		kBit0
#define kInStatusValidity		kBit1
#define kInStatusProfessional	kBit2
#define kInStatusMuted			kBit3	// Digital Input is muted
#define kInStatusErrParity		kBit4
#define kInStatusErrCSCRC		kBit5

#define kInStatusPCMOffset		7
#define kInStatusPCM			0
#define kInStatusPCM16			(1<<kInStatusPCMOffset)
#define kInStatusPCM18			(2<<kInStatusPCMOffset)
#define kInStatusPCM19			(3<<kInStatusPCMOffset)
#define kInStatusPCM20			(4<<kInStatusPCMOffset)
#define kInStatusPCM22			(5<<kInStatusPCMOffset)
#define kInStatusPCM23			(6<<kInStatusPCMOffset)
#define kInStatusPCM24			(7<<kInStatusPCMOffset)
#define kInStatusNonPCM			(8<<kInStatusPCMOffset)
#define kInStatusNonPCMDolbyAC3	(9<<kInStatusPCMOffset)
#define kInStatusNonPCMPause	(10<<kInStatusPCMOffset)
#define kInStatusNonPCMMPEG1L1	(11<<kInStatusPCMOffset)
#define kInStatusNonPCMMPEG1L2	(12<<kInStatusPCMOffset)
#define kInStatusNonPCMMPEG2	(13<<kInStatusPCMOffset)
#define kInStatusNonPCMMPEG2L1	(14<<kInStatusPCMOffset)
#define kInStatusNonPCMMPEG2L23	(15<<kInStatusPCMOffset)
#define kInStatusNonPCMDTSI		(16<<kInStatusPCMOffset)
#define kInStatusNonPCMDTSII	(17<<kInStatusPCMOffset)
#define kInStatusNonPCMDTSIII	(18<<kInStatusPCMOffset)
#define kInStatusNonPCMATRAC	(19<<kInStatusPCMOffset)
#define kInStatusNonPCMATRAC23	(20<<kInStatusPCMOffset)
#define kInStatusNonPCMMPEG2AAC	(21<<kInStatusPCMOffset)
#define kInStatusPCMMask		(31<<kInStatusPCMOffset)	// 5 bits

#define kInStatusEmphOffset		12
#define kInStatusEmphNone		0
#define kInStatusEmphUnknown	(1<<kInStatusEmphOffset)
#define kInStatusEmph5015		(2<<kInStatusEmphOffset)
#define kInStatusEmphCCITTJ17	(3<<kInStatusEmphOffset)
#define kInStatusEmphMask		(3<<kInStatusEmphOffset)	// 2 bits

#define kInStatusSROffset		16
#define kInStatusSRUnknown		0
#define kInStatusSR22050		(1<<kInStatusSROffset)
#define kInStatusSR24000		(2<<kInStatusSROffset)
#define kInStatusSR32000		(3<<kInStatusSROffset)
#define kInStatusSR44100		(4<<kInStatusSROffset)
#define kInStatusSR48000		(5<<kInStatusSROffset)
#define kInStatusSR88200		(6<<kInStatusSROffset)
#define kInStatusSR96000		(7<<kInStatusSROffset)
#define kInStatusSR176400		(8<<kInStatusSROffset)
#define kInStatusSR192000		(9<<kInStatusSROffset)
#define kInStatusSRMask			(15<<kInStatusSROffset)		// 4 bits

// <AK4114 Digital Input Status>

#ifndef MAX_VOLUME
#define MAX_VOLUME	0xFFFF
#endif

#define	LEFT		0
#define RIGHT		1
#endif	// _SHAREDCONTROLS_H
