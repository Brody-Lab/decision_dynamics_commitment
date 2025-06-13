/****************************************************************************
 Hal4114.h

 Description:	Interface for the Hal4114 class.

 Created: David A. Hoatson, June 2003
	
 Copyright © 2003 Lynx Studio Technology, Inc.

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
#ifndef _HAL4114_H
#define _HAL4114_H

#include "Hal.h"

enum 
{
	kChip1=0,
	kChip2,
	kChip3,
	kChip4,
	kChip5,
	kChip6,
	kChip7,
	kChip8,
	kNumberOf4114Chips
};

enum
{
	kSRC0=0,
	kSRC1,
	kSRC2,
	kSRC3,
	kNumberOfSRCChips
};

// VCXOCTL Write
#define REG_VCXOCTL_DACVAL_MASK		0xFFF				// Bits 11:0
#define REG_VCXOCTL_SLOCK			kBit12
#define REG_VCXOCTL_VCXOLOEN		kBit14				// Sample Rate is multiple of 44.1kHz
#define REG_VCXOCTL_VCXOHIEN		kBit15				// Sample Rate is multiple of 48kHz

// VCXOCTL Read
#define REG_VCXOCTL_LOCKED			kBit0

// MISCTL
#define REG_MISCTL_AESPDn			kBit0
#define REG_MISCTL_WIDEWIREIN		kBit1
#define REG_MISCTL_CSINIT			kBit2
#define REG_MISCTL_MPHASE			kBit3
#define REG_MISCTL_SRCEN_0			kBit4
#define REG_MISCTL_SRCEN_1			kBit5
#define REG_MISCTL_SRCEN_2			kBit6
#define REG_MISCTL_SRCEN_3			kBit7
#define REG_MISCTL_WIDEWIREOUT		kBit8

// CLKPWR
#define REG_CLKPWR_RSTN				kBit0
#define REG_CLKPWR_PWN				kBit1
#define REG_CLKPWR_OCKS_MODE1		kBit2				// Mode 1: 
#define REG_CLKPWR_OCKS_MODE2		kBit3				// Mode 2: 
#define REG_CLKPWR_OCKS_MODE3		(kBit2 | kBit3)		// Mode 3: 128 fs Max: 192kHz
#define REG_CLKPWR_OCKS_MASK		(kBit2 | kBit3)
#define REG_CLKPWR_CM_MODE0			0					// Mode 0: PLL On, Clock Source is PLL
#define REG_CLKPWR_CM_MODE1			kBit2				// Mode 1: PLL Off, Clock Source X'tal
#define REG_CLKPWR_CM_MODE2			kBit3				// Mode 2: PLL On, Clock Source X'tal if UNLOCK, PLL if LOCK
#define REG_CLKPWR_CM_MODE3			(kBit4 | kBit5)		// Mode 3: PLL On, Clock Source X'tal
#define REG_CLKPWR_CM_MASK			(kBit4 | kBit5)
#define REG_CLKPWR_BCU				kBit6
#define REG_CLKPWR_CS12				kBit7

#define REG_CLKPWR_OUTPUT_VALID		kBit9

// FMTDEMP
#define REG_FMTDEMP_DIF_MASK		(kBit4 | kBit5 | kBit6)
#define REG_FMTDEMP_DIF_MASTER		(kBit4 | kBit6)
#define REG_FMTDEMP_DIF_SLAVE		(kBit4 | kBit5 | kBit6)

//
#define REG_AK4114CTL_WREQ			kBit8	// Write request flag. Must be set by the host to for a write to the associated 
											// transceiver register. The SPI processor will clear this bit when the serial 
											// write is complete.

#define REG_AK4114STAT0_PAR			kBit0	// Parity or biphase error status, active high
											// Note: transceiver bit is cleared when read by SPI processor
#define REG_AK4114STAT0_AUDION		kBit1	// Audio bit status, 0=audio, 1=non-audio
#define REG_AK4114STAT0_PEM			kBit2	// Pre-emphasis detect
#define REG_AK4114STAT0_DTSCD		kBit3	// DTS-CD detect
#define REG_AK4114STAT0_UNLCK		kBit4	// Receiver PLL unlocked indicator
#define REG_AK4114STAT0_CINT		kBit5	// Channel status buffer interrupt. Set when changes in receive channel status is detected.
											// The SPI processor monitors this bit to determine if new data is available in the receive 
											// channel status registers.
											// Note: transceiver bit is cleared when read by SPI processor
#define REG_AK4114STAT0_AUTO		kBit6	// Non-PCM data auto detect
#define REG_AK4114STAT0_QINT		kBit7	// Q-subcode buffer interrupt. Not used for the AES16

#define REG_AK4114STAT1_CCRC		kBit8	// Channel status CRC error
#define REG_AK4114STAT1_QCRC		kBit9	// Q-subcode CRC error (not valid for AES16)
#define REG_AK4114STAT1_INVALID		kBit10	// Validity channel status bit

// Sampling frequency detection. See AK4114 data sheet table 4. Sample rate is decoded from channel status bytes 0 and 4.
#define REG_AK4114STAT1_FS_MASK		(kBit12 | kBit13 | kBit14 | kBit15)
#define REG_AK4114STAT1_FS_44100	0
#define REG_AK4114STAT1_FS_RESERVED	kBit12
#define REG_AK4114STAT1_FS_48000	kBit13
#define REG_AK4114STAT1_FS_32000	(kBit12 | kBit13)
#define REG_AK4114STAT1_FS_88200	kBit15
#define REG_AK4114STAT1_FS_96000	(kBit13 | kBit15)
#define REG_AK4114STAT1_FS_176400	(kBit14 | kBit15)
#define REG_AK4114STAT1_FS_192000	(kBit13 | kBit14 | kBit15)

// PC
#define REG_AK4114_RXCSPC_NULL		0
#define REG_AK4114_RXCSPC_DOLBYAC3	1
#define REG_AK4114_RXCSPC_PAUSE		3
#define REG_AK4114_RXCSPC_MPEG1_L1	4
#define REG_AK4114_RXCSPC_MPEG1_L2	5
#define REG_AK4114_RXCSPC_MPEG2		6
#define REG_AK4114_RXCSPC_MPEG2_L1	8
#define REG_AK4114_RXCSPC_MPEG2_L23	9
#define REG_AK4114_RXCSPC_DTS_I		11
#define REG_AK4114_RXCSPC_DTS_II	12
#define REG_AK4114_RXCSPC_DTS_III	13
#define REG_AK4114_RXCSPC_ATRAC		14
#define REG_AK4114_RXCSPC_ATRAC23	15
#define REG_AK4114_RXCSPC_MPEG2_AAC	28

#define REG_AK4114_RXCSPC_MASK		(kBit0 | kBit1 | kBit2 | kBit3 | kBit4)

class CHal4114
{
public:
	CHal4114()	{}	// constructor
	~CHal4114()	{}	// destructor

	USHORT	Open( PHALADAPTER pHalAdapter );
	USHORT	Close();
	
	USHORT	SetDefaults( void );

	USHORT	SampleClockChanged( LONG lRate, LONG lSource );

	USHORT	GetInputRate( ULONG ulTheChip, PLONG plRate );
	USHORT	GetInputStatus( ULONG ulTheChip, PULONG pulStatus );
	BOOLEAN	IsInputLocked( ULONG ulTheChip );
	BOOLEAN	IsSlave( ULONG ulTheChip );
	USHORT	GetSRCEnable( ULONG ulTheChip, PULONG pulEnable );
	USHORT	SetSRCEnable( ULONG ulTheChip, ULONG ulEnable );
	USHORT	GetSRCRatio( ULONG ulTheChip, PULONG pulSRCRatio );
	USHORT	SetSRCMatchPhase( ULONG ulSRCMatchPhase );
	USHORT	GetSRCMatchPhase( PULONG pulSRCMatchPhase );
	USHORT	GetOutputStatus( ULONG ulTheChip, PULONG pulStatus );
	USHORT	SetOutputStatus( ULONG ulTheChip, ULONG ulStatus );
	USHORT	SetOutputValid( BOOLEAN bValid );
	USHORT	SetSynchroLock( ULONG ulEnable );
	USHORT	GetSynchroLock( PULONG pulEnable );
	USHORT	GetSynchroLockStatus( PULONG pulStatus );
	USHORT	SetWideWireIn( ULONG ulEnable );
	USHORT	GetWideWireIn( PULONG pulEnable );
	USHORT	SetWideWireOut( ULONG ulEnable );
	USHORT	GetWideWireOut( PULONG pulEnable );
	USHORT	SetMixerControl( USHORT usControl, ULONG ulValue );
	USHORT	GetMixerControl( USHORT usControl, PULONG pulValue );

private:
	void	SetMasterSlave( ULONG ulTheChip, LONG lSource = -1 );

	PAK4114CTL		m_pRegAK4114Control[ kNumberOf4114Chips ];
	PAK4114STAT		m_pRegAK4114Status[ kNumberOf4114Chips ];

	CHalRegister	m_RegVCXOCTL;
	CHalRegister	m_RegVCXOCTLRead;
	CHalRegister	m_RegMISCTL;
	ULONG			m_ulClkPwr[ kNumberOf4114Chips ];	// shadow
	ULONG			m_ulFmtDEmp[ kNumberOf4114Chips ];	// shadow

	PHALADAPTER		m_pHalAdapter;
	USHORT			m_usDeviceID;

	BOOLEAN			m_bWideWireIn;
	BOOLEAN			m_bWideWireOut;
	BOOLEAN			m_bSynchroLock;
	//ULONG			m_ulSynchroLock;
	BOOLEAN			m_bSRCMatchPhase;
	BOOLEAN			m_bSRCMatchPhaseMixer;	// the status of the Match Phase mode as set by the mixer
	BOOLEAN			m_bSRCEnable[ 4 ];	// Chips 5-8
	
	ULONG			m_ulOutputStatus[ kNumberOf4114Chips ];
	BYTE			m_TxCBuffer[ kNumberOf4114Chips ][ 24 ];
};

#endif // _HAL4114_H
