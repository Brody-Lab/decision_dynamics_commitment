/****************************************************************************
 HalLStream.h

 Description:	Interface for the HalLStream class.

 Created: David A. Hoatson, September 2002
	
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

#ifndef _HALLSTREAM_H
#define _HALLSTREAM_H

#include "Hal.h"
#include "HalEnv.h"	// Added by ClassView

enum {
	LSTREAM_BRACKET=0,
	LSTREAM_HEADER,
	LSTREAM_NUM_PORTS
};

enum {
	ADAT_OPTICAL_IN_1=0,
	ADAT_OPTICAL_IN_2
};

/////////////////////////////////////////////////////////////////////////////
// Control Registers (Write Only)
/////////////////////////////////////////////////////////////////////////////
enum {
	kControlLSCTL0=0,			// 00 LStream control, generic
	kControlLSREQ,			// 01 LStream status request, generic

	// LS-ADAT Specific
	kControlADATCTL=2,		// 02 LS-ADAT control
	kControlTCRATE0,		// 03 Sync In time code transmission rate, byte 0
	kControlTCRATE1,		// 04 Sync In time code transmission rate, byte 1
	kControlTCCUE0,			// 05 Sync In time code cue frame count, byte 0
	kControlTCCUE1,			// 06 Sync In time code cue frame count, byte 1
	kControlTCCUE2,			// 07 Sync In time code cue frame count, byte 2
	kControlTCCUE3,			// 08 Sync In time code cue frame count, byte 3
	kControlSYNCOUT,		// 09 Sync Out MIDI data on SYNC IN port.
	kControlUSR1TC0,		// 0A ADAT optical out 1 user bit time code, byte 0
	kControlUSR1TC1,		// 0B ADAT optical out 1 user bit time code, byte 1 
	kControlUSR1TC2,		// 0C ADAT optical out 1 user bit time code, byte 2 
	kControlUSR1TC3,		// 0D ADAT optical out 1 user bit time code, byte 3 (MSB)
	kControlUSR1MIDI,		// 0E ADAT optical out 1 user bit MIDI
	kControlUSR2TC0,		// 0F ADAT optical out 2 user bit time code, byte 0 (LSB)
	kControlUSR2TC1,		// 10 ADAT optical out 2 user bit time code, byte 1 
	kControlUSR2TC2,		// 11 ADAT optical out 2 user bit time code, byte 2 
	kControlUSR2TC3,		// 12 ADAT optical out 2 user bit time code, byte 3 (MSB)
	kControlUSR2MIDI,		// 13 ADAT optical out 2 user bit MIDI

	// LS-AES Specific
	kControlDEVCTL=0x02,	// 02 Device Specific Control
	kControlAK4117_PDC=0x08,	// 08 AK4117 Control Register Block (8 Bytes)
	kControlAK4117_CLC,		// 09 AK4117 Register 
	kControlAK4117_IOC,		// 0A AK4117 Register 
	kControlCBLK8420A=0x10,	// 10 CS8420 Control Register Block (16 Bytes)
	kControlCBLK8420B=0x20,	// 20 CS8420 Control Register Block (16 Bytes)
	kControlCBLK8420C=0x30,	// 30 CS8420 Control Register Block (16 Bytes)
	kControlCBLK8420D=0x40,	// 40 CS8420 Control Register Block (16 Bytes)

	kControlNumRegs
};

enum {
	kAES8420MiscControl1 = 0,
	kAES8420MiscControl2,
	kAES8420DataFlowControl,
	kAES8420ClockSourceControl,
	kAES8420RxErrorMask,
	kAES8420CSDataBufferControl,
	kAES8420CSBuffer
};

#define REG_LSCTL0_MRST				kBit0	// Master reset for LStream device logic and state machines, active high (NEVER ASSERT THIS!)
#define REG_LSCTL0_MMUTEn			kBit1	// Master mute.  Must all inputs and outputs, active low
#define REG_LSCTL0_LED				kBit2	// Illuminates LED
#define REG_LSCTL0_PING				kBit3	// Enables periodic transmission of basic status
#define REG_LSCTL0_CKSRC_MASK		(kBit4 | kBit5)
#define REG_LSCTL0_CKSRC_FCK		(0)		// LStream frame clock (FCK)
// LS-ADAT Specific
#define REG_LSCTL0_CKSRC_OP0		kBit4	// ADAT Optical In 0
#define REG_LSCTL0_CKSRC_OP1		kBit5	// ADAT Optical In 1
#define REG_LSCTL0_CKSRC_SYNCIN		(kBit4 | kBit5)	// ADAT Sync In port
// LS-AES Specific
#define REG_LSCTL0_CLKSRC_DIGIN1	0
#define REG_LSCTL0_CLKSRC_DIGIN2	kBit4
#define REG_LSCTL0_CLKSRC_DIGIN3	kBit5
#define REG_LSCTL0_CLKSRC_DIGIN4	(kBit4 | kBit5)
#define REG_LSCTL0_FCKOE			kBit6	// Output frame clock enable, 0=disabled, 1=enabled.

#define REG_LSREQ_ADDR_MASK			0x3F	// Address of requested status register
#define REG_LSREQ_REQSINGLE			kBit6	// Request transmission of single status register at ADDR
#define REG_LSREQ_REQALL			kBit7	// Request transmission of all status registers

#define REG_ADATCTL_RCVRSTn			kBit0	// ADAT receiver reset, resets both receivers, active low.
#define REG_ADATCTL_RCVMUTEn		kBit1	// ADAT receiver reset, mutes both receivers, active low.
#define REG_ADATCTL_XMTMUTEn		kBit2	// ADAT transmitter mute, mutes both transmitters, active low.
#define REG_ADATCTL_TCEN			kBit3	// Enables transmission of SYNC IN timecode to hoast at the rate specified by TCRATE3-0.
#define REG_ADATCTL_TCXMITSYNC		kBit4	// Initalizes the counter used to count cycles between time code transmissions.
#define REG_ADATCTL_TCCUEEN			kBit5	// Enabled time code cuit hit signal transmission to host for starting devices in SYNCREADY mode.
#define REG_ADATCTL_SYNCINEN		kBit6	// Enables transmission of SYNC IN data on arrival

enum {
	MIXVAL_ADATCLKSRC_SLAVE=0,
	MIXVAL_ADATCLKSRC_IN1,
	MIXVAL_ADATCLKSRC_IN2,
	MIXVAL_ADATCLKSRC_SYNCIN
};

#define REG_DEVCTL_DEVRSTn			kBit0
#define REG_DEVCTL_CSINIT			kBit1
#define REG_DEVCTL_RXNOTIFY			kBit2
#define REG_DEVCTL_WIDEWIRE			kBit3
#define REG_DEVCTL_DIOFMT1			kBit4
#define REG_DEVCTL_DIOFMT2			kBit5
#define REG_DEVCTL_DIOFMT3			kBit6
#define REG_DEVCTL_DIOFMT4			kBit7

enum {
	MIXVAL_AESCLKSRC_SLAVE=0,
	MIXVAL_AESCLKSRC_IN1,
	MIXVAL_AESCLKSRC_IN2,
	MIXVAL_AESCLKSRC_IN3,
	MIXVAL_AESCLKSRC_IN4
};

/////////////////////////////////////////////////////////////////////////////
// Status Registers (Read Only)
/////////////////////////////////////////////////////////////////////////////
enum {
	kStatusLSDEVID=0,		// 00 LStream device ID LS-ADAT 1, LS-AES 2, LS-TDIF 3
	kStatusPCBRREV,			// 01 LStream device PCB revision, 0=NC, 1=A, 2=B, etc.
	kStatusFWREV,			// 02 LStream device firmware build number
	kStatusLSSTAT,			// 03 LStream device status/errors, generic (locked, power, parity)

	// LS-ADAT Specific
	kStatusADATSTAT=4,		// 04 LS-ADAT status (receiver errors)
	kStatusSYNCTC0,			// 05 ADAT SYNC IN port time code, byte 0 (LSB)
	kStatusSYNCTC1,			// 06 ADAT SYNC IN port time code, byte 1 
	kStatusSYNCTC2,			// 07 ADAT SYNC IN port time code, byte 2 
	kStatusSYNCTC3,			// 08 ADAT SYNC IN port time code, byte 3 (MSB)
	kStatusSYNCIN,			// 09 ADAT SYNC IN port MIDI data
	kStatusUSR1TC0,			// 0A ADAT optical in 1 user bit time code, byte 0 (LSB)
	kStatusUSR1TC1,			// 0B ADAT optical in 1 user bit time code, byte 1 
	kStatusUSR1TC2,			// 0C ADAT optical in 1 user bit time code, byte 2 
	kStatusUSR1TC3,			// 0D ADAT optical in 1 user bit time code, byte 3 (MSB)
	kStatusUSR1MIDI,		// 0E ADAT optical in 1 user bit MIDI
	kStatusUSR2TC0,			// 0F ADAT optical in 2 user bit time code, byte 0 (LSB)
	kStatusUSR2TC1,			// 10 ADAT optical in 2 user bit time code, byte 1 
	kStatusUSR2TC2,			// 11 ADAT optical in 2 user bit time code, byte 2 
	kStatusUSR2TC3,			// 12 ADAT optical in 2 user bit time code, byte 3 (MSB)
	kStatusUSR2MIDI,		// 13 ADAT optical in 2 user bit MIDI

	// LS-AES Specific
	kStatusFREQCNTA0=3,		// 03 AES Frequency Counter A LSB
	kStatusFREQCNTA1,		// 04 AES Frequency Counter A MSB
	kStatusFREQSCALEA,		// 05 AES Frequency Scale A
	kStatusFREQCNTB0,		// 06 AES Frequency Counter B LSB
	kStatusFREQCNTB1,		// 07 AES Frequency Counter B MSB
	kStatusFREQSCALEB,		// 08 AES Frequency Scale B
	kStatusFREQCNTC0,		// 09 AES Frequency Counter C LSB
	kStatusFREQCNTC1,		// 0A AES Frequency Counter C MSB
	kStatusFREQSCALEC,		// 0B AES Frequency Scale C
	kStatusFREQCNTD0,		// 0C AES Frequency Counter D LSB
	kStatusFREQCNTD1,		// 0D AES Frequency Counter D MSB
	kStatusFREQSCALED,		// 0E AES Frequency Scale D

	kStatusAKSTAT0=0x10,	// 10 AK4117 Receiver Status 0
	kStatusAKSTAT1,			// 11 AK4117 Receiver Status 1
	kStatusAKSTAT2,			// 12 AK4117 Receiver Status 2
	kStatusRXCSA,			// 13 CS8420 Receiver Channel Status, Digital In 1
	kStatusRXERRA,			// 14 CS8420 Receiver Error Status, Digital In 1
	kStatusSRRA,			// 15 CS8420 Sample Rate Ratio, Digital In 1
	kStatusRXCSB,			// 16 CS8420 Receiver Channel Status, Digital In 2
	kStatusRXERRB,			// 17 CS8420 Receiver Error Status, Digital In 2
	kStatusSRRB,			// 18 CS8420 Sample Rate Ratio, Digital In 2
	kStatusRXCSC,			// 19 CS8420 Receiver Channel Status, Digital In 3
	kStatusRXERRC,			// 1A CS8420 Receiver Error Status, Digital In 3
	kStatusSRRC,			// 1B CS8420 Sample Rate Ratio, Digital In 3
	kStatusRXCSD,			// 1C CS8420 Receiver Channel Status, Digital In 4
	kStatusRXERRD,			// 1D CS8420 Receiver Error Status, Digital In 4
	kStatusSRRD,			// 1E CS8420 Sample Rate Ratio, Digital In 4

	kStatusNumRegs
};

enum {
	k8420_A=0,
	k8420_B,
	k8420_C,
	k8420_D,
	LSTREAM_NUM_8420
};

enum
{
	MIXVAL_AESSRCMODE_SRC_ON=0,			// AES In, SRC
	MIXVAL_AESSRCMODE_SRC_OFF,			// Slave to AES In, No SRC
	MIXVAL_AESSRCMODE_SRC_ON_DIGOUT,	// AES out SRC to AES in
	MIXVAL_AESSRCMODE_TXONLY			// AES out only
};


#define REG_LSDEVID_LSADAT			1
#define REG_LSDEVID_LSAES			2
#define REG_LSDEVID_LSTDIF			3

#define REG_ADATSTAT_RCVERR0		kBit0
#define REG_ADATSTAT_RCVERR1		kBit1

// This is the abstract class CHalLStream 
class CHalLStream  
{
public:
	CHalLStream()	{}
	~CHalLStream()	{}

	USHORT	Open( PHALADAPTER pHalAdapter );
	USHORT	Close();
	void	EnableInterrupts();
	void	DisableInterrupts();
	void	ResetFIFOs();
	
	USHORT	SampleClockChanged( long lRate, long lSource, long lReference );

	ULONG	GetDeviceID( ULONG ulPort );
	ULONG	GetPCBRev( ULONG ulPort );
	ULONG	GetFirmwareRev( ULONG ulPort );

	USHORT	ReadStatus( ULONG ulPort, ULONG ulReg, PBYTE pucValue );

	BOOLEAN	IsLocked( ULONG ulPort );
	USHORT	WaitForLock( ULONG ulPort );

	USHORT	SetOutputSelection( ULONG ulPort, ULONG ulOutputSelection );
	ULONG	GetOutputSelection( ULONG ulPort );

	USHORT	SetLStreamDualInternal( ULONG ulLStreamDualInternal );
	ULONG	GetLStreamDualInternal()	{	return( m_bLStreamDualInternal );	}

	// LS-ADAT Specific
	USHORT	ADATSetClockSource( ULONG ulPort, ULONG ulClockSource );
	BYTE	ADATGetClockSource( ULONG ulPort );
	BOOLEAN ADATIsLocked( ULONG ulPort, ULONG ulInput );
	USHORT	ADATEnableTimeCodeToMTC( ULONG ulPort, BOOLEAN bEnable );
	USHORT	ADATSetTimeCodeTxRate( ULONG ulPort, ULONG ulTCTxRateSamples );
	USHORT	ADATSetCuePoint( ULONG ulPort, ULONG ulCuePoint );
	ULONG	ADATGetCuePoint( ULONG ulPort );
	USHORT	ADATCuePointEnable();
	USHORT	ADATGetSyncInTimeCode( ULONG ulPort, PULONG pulTimecode );
	USHORT	ADATGetPosition( ULONG ulPort, PULONG pulPosition );

	// LS-AES Specific
	USHORT	AESSetClockSource( ULONG ulPort, ULONG ulClockSource, BOOLEAN bInISR = FALSE );
	ULONG	AESGetClockSource( ULONG ulPort );
	USHORT	AESSetSRCMode( ULONG ulPort, ULONG ulTheChip, ULONG ulMode );
	ULONG	AESGetSRCMode( ULONG ulPort, ULONG ulTheChip );
	USHORT	AESSetFormat( ULONG ulPort, ULONG ulTheChip, ULONG ulFormat );
	ULONG	AESGetFormat( ULONG ulPort, ULONG ulTheChip );
	USHORT	AESSetInputMuteOnError( ULONG ulPort, BOOLEAN bMuteOnError );
	USHORT	AESSetOutputStatus( ULONG ulPort, ULONG ulTheChip, ULONG ulStatus );
	ULONG	AESGetOutputStatus( ULONG ulPort, ULONG ulTheChip );
	ULONG	AESGetInputSampleRate( ULONG ulPort, ULONG ulTheChip );
	ULONG	AESGetSRCRatio( ULONG ulPort, ULONG ulTheChip );
	ULONG	AESGetInputStatus( ULONG ulPort, ULONG ulTheChip );
	USHORT	AESSetWideWire( ULONG ulPort, ULONG ulWideWire );
	ULONG	AESGetWideWire( ULONG ulPort );

	USHORT	Service( BOOLEAN bPolled = FALSE );

private:
	USHORT	InitializeDevice( ULONG ulPort );
	USHORT	WriteControl( ULONG ulPort, ULONG ulReg, BYTE ucValue, BYTE ucMask = 0xFF );
	// LS-AES Specific
	ULONG	AESGetBaseControl( ULONG ulTheChip );
	ULONG	AESGetBaseStatus( ULONG ulTheChip );
	USHORT	AESInitialize8420( ULONG ulPort, ULONG ulTheChip );
	USHORT	AESWriteCSBuffer( ULONG ulPort, ULONG ulTheChip, PBYTE pBuffer );

	PHALADAPTER		m_pHalAdapter;
	CHalRegister	m_RegOPIOCTL;
	CHalRegister	m_RegOPDEVCTL;
	CHalRegister	m_RegOPDEVSTAT;
	CHalRegister	m_RegOPBUFSTAT;
	CHalMIDIDevice *m_pMIDIRecord;

	LONG			m_lSampleRate;
	ULONG			m_ulSpeed;
	BYTE			m_aControlRegisters[ LSTREAM_NUM_PORTS ][ 127 ];	// 2 ports, 0x7F registers each
	BYTE			m_aStatusRegisters[ LSTREAM_NUM_PORTS ][ 127 ];	// 2 ports, 0x7F registers each
	ULONG			m_ulOutputSelection[ LSTREAM_NUM_PORTS ];
	BOOLEAN			m_bInitialized[ LSTREAM_NUM_PORTS ];

	BOOLEAN			m_bLStreamDualInternal;
	
	// LS-ADAT Specific
	ULONG			m_ulADATClockSource[ LSTREAM_NUM_PORTS ];
	ULONG			m_ulLastTimecode[ LSTREAM_NUM_PORTS ];
	ULONG			m_ulADATTimeCodeTxRate[ LSTREAM_NUM_PORTS ];
	ULONG			m_ulADATCuePoint[ LSTREAM_NUM_PORTS ];
	BOOLEAN			m_bEnableMTC[ LSTREAM_NUM_PORTS ];

	// LS-AES Specific
	ULONG			m_ulAESClockSource[ LSTREAM_NUM_PORTS ];
	ULONG			m_ulWideWire[ LSTREAM_NUM_PORTS ];
	ULONG			m_ulFormat[ LSTREAM_NUM_PORTS ][ LSTREAM_NUM_8420 ];
	ULONG			m_ulSRCMode[ LSTREAM_NUM_PORTS ][ LSTREAM_NUM_8420 ];
	ULONG			m_ulOutputStatus[ LSTREAM_NUM_PORTS ][ LSTREAM_NUM_8420 ];
};

#endif // _HALLSTREAM_H
