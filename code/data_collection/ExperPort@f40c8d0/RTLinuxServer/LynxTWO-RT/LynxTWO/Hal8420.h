/****************************************************************************
 Hal8420.h

 Description:	Interface for the Hal8420 class.

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
#ifndef _HAL8420_H
#define _HAL8420_H

#include "Hal.h"

// Register Offsets
enum
{
	k8420MiscControl1 = 1,		// 1
	k8420MiscControl2,			// 2
	k8420DataFlowControl,		// 3
	k8420ClockSourceControl,	// 4
	k8420SerialInputFormat,		// 5
	k8420SerialOutputFormat,	// 6
	k8420Interrupt1Status,		// 7
	k8420Interrupt2Status,		// 8
	k8420Interrupt1Mask,		// 9
	k8420Interrupt1ModeMSB,		// 10
	k8420Interrupt1ModeLSB,		// 11
	k8420Interrupt2Mask,		// 12
	k8420Interrupt2ModeMSB,		// 13
	k8420Interrupt2ModeLSB,		// 14
	k8420RxChannelStatus,		// 15
	k8420RxErrors,				// 16
	k8420RxErrorMask,			// 17
	k8420CSDataBufferControl,	// 18
	k8420UDataBufferControl,	// 19
	k8420QSubCodeData,			// 20-29
	k8420SampleRateRatio = 30,	// 30
	k8420CorUDataBuffer = 32,	// 32-55
	k8420IDandVersion = 127		// 127
};

// Addr 1 Miscellaneous Control 1
#define k8420_MC1_TCBLD				kBit0
#define k8420_MC1_IntOutActiveHigh	(0<<1)
#define k8420_MC1_IntOutActiveLow	(1<<1)
#define k8420_MC1_IntOutOpenAL		(2<<1)
#define k8420_MC1_DITH				kBit3
#define k8420_MC1_MUTEAES			kBit4
#define k8420_MC1_MUTESAO			kBit5
#define k8420_MC1_VSET				kBit6
#define k8420_MC1_SWCLK				kBit7

// Addr 2 Miscellaneous Control 2
#define k8420_MC2_AES3TxMonoR		kBit0	// AES Tx Channel Mono Mode (Left or Right)
#define k8420_MC2_AES3TxCSB			kBit1	// AES Tx Channel Status Data in Mono Mode
#define k8420_MC2_AES3TxMono		kBit2	// AES Tx Mono Mode
#define k8420_MC2_AES3RxMono		kBit3	// AES Rx Mono Mode
#define k8420_MC2_RMCKF				kBit4	// RMCK output frequency, 0=256Fs, 128Fs
#define k8420_MC2_HOLD00			(0)		// Hold the last valid audio sample
#define k8420_MC2_HOLD01			kBit5	// Replace the current audio sample with 00
#define k8420_MC2_HOLD10			kBit6	// Do not change the receive audio sample
#define k8420_MC2_HOLD_MASK			(kBit5 | kBit6)

// Addr 3 Data Flow Control
#define k8420_DFC_SRCD				kBit0	// SRCD
#define k8420_DFC_SPD00				(0<<1)	// Serial Audio Output Source: SRC Output
#define k8420_DFC_SPD01				(1<<1)	// Serial Audio Output Source: Serial Audio Input Port
#define k8420_DFC_SPD10				(2<<1)	// Serial Audio Output Source: AESRX
#define k8420_DFC_SPD_MASK			(3<<1)
#define	k8420_DFC_TXD00				(0<<3)	// AES3 Tx Data Source: SRC Output
#define	k8420_DFC_TXD01				(1<<3)	// AES3 Tx Data Source: Serial Audio Input Port
#define	k8420_DFC_TXD10				(2<<3)	// AES3 Tx Data Source: AESRX
#define	k8420_DFC_TXD_MASK			(3<<3)
#define k8420_DFC_AESBP				kBit5
#define k8420_DFC_TXOFF				kBit6
#define k8420_DFC_AMLL				kBit7

// Addr 3 Data Flow Control - Alternate constatnts
#define	k8420_DFC_SPD0			kBit1
#define k8420_DFC_SPD1			kBit2
#define k8420_DFC_TXD0			kBit3
#define k8420_DFC_TXD1			kBit4

// Addr 4 Clock Source Control
#define k8420_CSC_RXD00			(0<<0)	// 256*Fsi, Fsi from ILRCK
#define k8420_CSC_RXD01			(1<<0)	// 256*Fsi, Fsi from AESRX
#define k8420_CSC_RXD10			(2<<0)	// Bypass PLL, 256*Fsi via RMCK
#define k8420_CSC_RXD_MASK		(3<<0)
#define k8420_CSC_INC			kBit2	// Input Time Base, 0=Recovered Input Clock, 1=OMCK Input Pin
#define k8420_CSC_OUTC			kBit3	// Output Time Base, 0=OMCK input pin, 1=Recovered Input Clock
#define k8420_CSC_CLK256		(0<<4)
#define k8420_CSC_CLK384		(1<<4)
#define k8420_CSC_CLK512		(2<<4)
#define k8420_CSC_RUN			kBit6

// Addr 5 Serial Audio Input Port Format
#define k8420_SAI_SILRPOL		kBit0
#define k8420_SAI_SISPOL		kBit1
#define k8420_SAI_SIDEL			kBit2
#define k8420_SAI_SIJUST		kBit3
#define k8420_SAI_SIRES00		(0<<4)	// 24-bit
#define k8420_SAI_SIRES01		(1<<4)	// 20-bit
#define k8420_SAI_SIRES10		(2<<4)	// 16-bit
#define k8420_SAI_SIRES11		(3<<4)	// Reserved
#define k8420_SAI_SIRES_MASK	(3<<4)
#define k8420_SAI_SISF			kBit6
#define k8420_SAI_SIMS			kBit7	// Master/Save Mode Selector 0=slave-in, 1=master-out

// Addr 6 Serial Audio Output Port Data Format
#define k8420_SAO_SOLRPOL		kBit0	// OLRCK Clock Polarity 0=left, 1=right
#define k8420_SAO_SOSPOL		kBit1	// OLRCK Clock Polarity 0=falling edge, 1=rising edge
#define k8420_SAO_SODEL			kBit2
#define k8420_SAO_SOJUST		kBit3
#define k8420_SAO_SORES00		(0<<4)	// 24-bit
#define k8420_SAO_SORES01		(1<<4)	// 20-bit
#define k8420_SAO_SORES10		(2<<4)	// 16-bit
#define k8420_SAO_SORES11		(3<<4)	// Copy of AES3RX
#define k8420_SAO_SORES_MASK	(3<<4)
#define k8420_SAO_SOSF			kBit6
#define k8420_SAO_SOMS			kBit7	// Master/Slave Mode Selector 0=slave-in, 1=master-out

// Addr 7 Interrupt 1 Status
#define	k8420_Int1_RERR		kBit0
#define	k8420_Int1_EFTC		kBit1	// E to F Transfer C Bit (Transmitter)
#define	k8420_Int1_DETC		kBit2	// D to E Transfer C Bit (Receiver)
#define k8420_Int1_OVRGR	kBit3
#define k8420_Int1_OVRGL	kBit4
#define k8420_Int1_SRE		kBit5	// Sample Rate Range Exceeded
#define k8420_Int1_OSLIP	kBit6	// Serial Audio Output Data Slip
#define k8420_Int1_TSLIP	kBit7	// AES3 Transmitter Data Slip

// Addr 8 Interrupt 2 Status
#define	k8420_Int2_QCH		kBit1
#define	k8420_Int2_EFTU		kBit2	// E to F Transfer U Bit (Block Mode Only) (Transmitter)
#define	k8420_Int2_DETU		kBit3	// D to E Transfer U Bit (Block Mode Only) (Receiver)
#define k8420_Int2_REUNLOCK	kBit4	// Sample Rate Converter Unlock Indicator
#define k8420_Int2_VFIFO	kBit5	// Varispeed FIFO overflow Indicator

// Addr 15 Receiver Channel Status
#define k8420_RxCS_ORIG		kBit0	// Set for SCMS Orginal Mode, Clear for 1st Gen+ Copy
#define k8420_RxCS_COPY		kBit1	// Set for SCMS Copyright
#define k8420_RxCS_AUDIOn	kBit2	// Set for Non-Audio, Clear for PCM Audio
#define k8420_RxCS_Pro		kBit3	// Set for PRO mode, Clear for Consumer

// Addr 16 & 17, Receiver Errors & Receiver Error Mask
#define k8420_RxErr_PAR		kBit0	// Parity
#define k8420_RxErr_BIP		kBit1	// Bi-phase
#define k8420_RxErr_CONF	kBit2	// Confidence
#define k8420_RxErr_VAL		kBit3	// Validity
#define k8420_RxErr_UNLOCK	kBit4	// Unlock
#define k8420_RxErr_CCRC	kBit5	// Channel Status CRC
#define k8420_RxErr_QCRC	kBit6	// Q Subcode CRC

// Addr 18 Channel Status Data Buffer Control
#define k8420_CsDB_CHS		kBit0	// Channel select bit, 0 = Channel A, 1 = Channel B
#define k8420_CsDB_CAM		kBit1	// C-data buffer control port access mode bit (must be clear)
#define k8420_CsDB_EFTCI	kBit2	// Inhibit C-data E to F buffer transfers
#define k8420_CsDB_DETCI	kBit3	// Inhibit C-data D to E buffer transfers
#define k8420_CsDB_CBMR		kBit4	// Set to prevent D to E buffer transfers from overwriting 
									// first 5 bytes of channel status data
#define k8420_CsDB_BSEL		kBit5	// 0 = Channel Status Data, 1 = User Data

// Addr 19 User Data Buffer Control
#define k8420_UDB_UD		kBit0	// Set if U pin is an output

// Addr 20-29, Q-Channel Subcode Bytes
typedef struct
{
	BYTE	ucAddrCntl;
	BYTE	ucTrack;
	BYTE	ucIndex;
	BYTE	ucMinute;
	BYTE	ucSecond;
	BYTE	ucFrame;
	BYTE	ucZero;
	BYTE	ucABSMinute;
	BYTE	ucABSSecond;
	BYTE	ucABSFrame;
} QCHANNELSUBCODE, *PQCHANNELSUBCODE;

/////////////////////////////////////////////////////////////////////////////
// PROFESSIONAL MODE (AES3-1992)
/////////////////////////////////////////////////////////////////////////////

// from AN22 - NOT WHAT THE 8420 ACTUALLY OUTPUTS.  Must use Invert()...
#define MIXVAL_DCS_BYTE0_CON				(0)
#define MIXVAL_DCS_BYTE0_PRO				(kBit0)
#define MIXVAL_DCS_BYTE0_PCM				(0)
#define MIXVAL_DCS_BYTE0_NONPCM				(kBit1)

// Emphasis
#define MIXVAL_DCS_PRO_BYTE0_EMPH_UNKNOWN	(0)
#define MIXVAL_DCS_PRO_BYTE0_EMPH_NONE		(kBit2)
#define MIXVAL_DCS_PRO_BYTE0_EMPH_5015		(kBit2 | kBit3)
#define MIXVAL_DCS_PRO_BYTE0_EMPH_CCITTJ17	(kBit2 | kBit3 | kBit4)
#define MIXVAL_DCS_PRO_BYTE0_EMPH_MASK		(kBit2 | kBit3 | kBit4)

// Lock Source Sample Frequency
#define MIXVAL_DCS_PRO_BYTE0_LOCKED			(0)
#define MIXVAL_DCS_PRO_BYTE0_UNLOCKED		(kBit5)

// Sample Frequency
#define MIXVAL_DCS_PRO_BYTE0_FS_UNKNOWN		(0)
#define MIXVAL_DCS_PRO_BYTE0_FS_44100		(kBit6)
#define MIXVAL_DCS_PRO_BYTE0_FS_48000		(kBit7)
#define MIXVAL_DCS_PRO_BYTE0_FS_32000		(kBit6 | kBit7)
#define MIXVAL_DCS_PRO_BYTE0_FS_MASK		(kBit6 | kBit7)

// Channel Mode
#define MIXVAL_DCS_PRO_BYTE1_CM_UNKNOWN		(0)						// Mode not indicated
#define MIXVAL_DCS_PRO_BYTE1_CM_MASK		(kBit0 | kBit1 | kBit2 | kBit3)	// Channel Mode Bit Mask
#define MIXVAL_DCS_PRO_BYTE1_CM_2CH			kBit3
#define MIXVAL_DCS_PRO_BYTE1_CM_1CH			kBit2
#define MIXVAL_DCS_PRO_BYTE1_CM_STEREO		kBit1					// Stereophonic Mode
#define MIXVAL_DCS_PRO_BYTE1_CM_1CH_2SR		(kBit1 | kBit2 | kBit3)	// Single Channel, Double Sample Rate, Mono
#define MIXVAL_DCS_PRO_BYTE1_CM_1CH_2SR_SML	(kBit0)					// Single Channel, Double Sample Rate, Stereo Mode Left
#define MIXVAL_DCS_PRO_BYTE1_CM_1CH_2SR_SMR	(kBit0 | kBit3)			// Single Channel, Double Sample Rate, Stereo Mode Right
#define MIXVAL_DCS_PRO_BYTE1_CM_MULTICHANNEL (kBit0 | kBit1 | kBit2 | kBit3)	// Multichannel Mode, See Byte 3 for Channel ID

// AUX: Use of auxiliary sample bits
#define MIXVAL_DCS_PRO_BYTE2_AUX_UNDEFINED	0		// Max 20bits
#define MIXVAL_DCS_PRO_BYTE2_AUX_MAIN24		(kBit2)
#define MIXVAL_DCS_PRO_BYTE2_AUX_MASK		(kBit0 | kBit1 | kBit2)

#define MIXVAL_DCS_PRO_BYTE2_AUXBITS_MASK	(kBit3 | kBit4 | kBit5)
// Used when Bit 2 is set
#define MIXVAL_DCS_PRO_BYTE2_AUX_23BITS		kBit5
#define MIXVAL_DCS_PRO_BYTE2_AUX_22BITS		kBit4
#define MIXVAL_DCS_PRO_BYTE2_AUX_20BITS		(kBit4 | kBit5)
#define MIXVAL_DCS_PRO_BYTE2_AUX_24BITS		(kBit3 | kBit5)
// Used when Bits 0-2 are clear
#define MIXVAL_DCS_PRO_BYTE2_AUX_U19BITS	kBit5
#define MIXVAL_DCS_PRO_BYTE2_AUX_U18BITS	kBit4
#define MIXVAL_DCS_PRO_BYTE2_AUX_U16BITS	(kBit4 | kBit5)
#define MIXVAL_DCS_PRO_BYTE2_AUX_U20BITS	(kBit3 | kBit5)

// From AES-3 1992 Amendment 3
#define MIXVAL_DCS_PRO_BYTE4_FS_MASK		(kBit3 | kBit4 | kBit5 | kBit6)
#define MIXVAL_DCS_PRO_BYTE4_FS_24000		(kBit3)					// 24kHz
#define MIXVAL_DCS_PRO_BYTE4_FS_96000		(kBit4)					// 96kHz
#define MIXVAL_DCS_PRO_BYTE4_FS_192000		(kBit3 | kBit4)			// 192kHz
#define MIXVAL_DCS_PRO_BYTE4_FS_22050		(kBit3 | kBit6)			// 22.05kHz
#define MIXVAL_DCS_PRO_BYTE4_FS_88200		(kBit4 | kBit6)			// 88.2kHz
#define MIXVAL_DCS_PRO_BYTE4_FS_176400		(kBit3 | kBit4 | kBit6)	// 176.4kHz

#define MIXVAL_DCS_PRO_BYTE4_FS_PULLDOWN	(kBit7)

/////////////////////////////////////////////////////////////////////////////
// CONSUMER MODE / IEC-958 (IEC-60958)
/////////////////////////////////////////////////////////////////////////////

#define MIXVAL_DCS_CON_BYTE0_COPY_PERMIT	(kBit2)

#define MIXVAL_DCS_CON_BYTE0_EMPH_NONE		(0)
#define MIXVAL_DCS_CON_BYTE0_EMPH_5015		(kBit3)

#define MIXVAL_DCS_CON_BYTE1_CAT_DIGDIGCONV	(kBit1)
#define MIXVAL_DCS_CON_BYTE1_CAT_TAPEDISK	(kBit0 | kBit1)

#define MIXVAL_DCS_CON_BYTE1_CAT010_PCM		(0)
#define MIXVAL_DCS_CON_BYTE1_CAT010_SRC		(kBit3 | kBit4)

#define MIXVAL_DCS_CON_BYTE3_FS_44100		(0)
#define MIXVAL_DCS_CON_BYTE3_FS_48000		(kBit1)
#define MIXVAL_DCS_CON_BYTE3_FS_32000		(kBit0 | kBit1)

#define MIXVAL_DCS_CON_BYTE3_CA_LEVELII		(0)				// Level II Clock Accuracy, +/- 1000ppm
#define MIXVAL_DCS_CON_BYTE3_CA_LEVELIII	(kBit5)			// Level III Clock Accuracy, Varispeed
#define MIXVAL_DCS_CON_BYTE3_CA_LEVELI		(kBit4)			// Level I Clock Accuracy, +/- 50ppm

/////////////////////////////////////////////////////////////////////////////

#define MIXVAL_OUTSTATUS_VALID			kBit0
#define MIXVAL_OUTSTATUS_NONAUDIO		kBit1
#define MIXVAL_OUTSTATUS_EMPHASIS_MASK	(kBit2 | kBit3)
#define MIXVAL_OUTSTATUS_EMPHASIS_NONE	(0)
#define MIXVAL_OUTSTATUS_EMPHASIS_5015	kBit2
#define MIXVAL_OUTSTATUS_EMPHASIS_J17	kBit3

enum
{
	MIXVAL_SRCMODE_SRC_ON=0,		// AES In, SRC
	MIXVAL_SRCMODE_SRC_OFF_CLKSYNC,	// Synchronous AES In, No SRC
	MIXVAL_SRCMODE_SRC_OFF,			// Slave to AES In, No SRC
	MIXVAL_SRCMODE_SRC_ON_DIGOUT,	// AES out SRC to AES in
	MIXVAL_SRCMODE_TXONLY,			// AES out only
	NUM_DIGITAL_MODES
};

/////////////////////////////////////////////////////////////////////////////

class CHal8420
{
public:
	CHal8420()	{}	// constructor
	~CHal8420()	{}	// destructor

	USHORT	Open( PHALADAPTER pHalAdapter );
	USHORT	Close();

	USHORT	Write( ULONG ulRegister, BYTE ucValue, BYTE ucMask = 0xFF );
	USHORT	Write( ULONG ulRegister, PBYTE pucValue, ULONG ulSize );
	USHORT	Read( ULONG ulRegister, PBYTE pucValue );
	USHORT	Read( ULONG ulRegister, PBYTE pucValue, ULONG ulSize  );

	BOOLEAN	IsInputLocked();

	USHORT	SetInputMuteOnError( BOOLEAN bMuteOnError );
	BOOLEAN	GetInputMuteOnError()	{ return( m_bMuteOnError );		}

	ULONG	GetInputStatus();

	USHORT	SetOutputNonAudio( BOOLEAN bNonAudio );

	USHORT	SetOutputStatus( ULONG ulStatus );
	ULONG	GetOutputStatus()	{ return( m_ulOutputStatus );		}

	USHORT	SetOutputFormat( ULONG ulFormat, LONG lSampleRate, BOOLEAN bNonAudio );

	USHORT	SampleClockChanged( LONG lRate );

	USHORT	SetFormat( ULONG ulFormat );
	ULONG	GetFormat()			{ return( m_ulFormat );				}

	USHORT	SetMode( ULONG ulMode );
	ULONG	GetMode()			{ return( m_ulMode );				}
	
	USHORT	GetInputSampleRate( PLONG plRate );
	BYTE	GetSRCRatio();

	//USHORT	GetQChannelSubcode( PQCHANNELSUBCODE pSubcode );
	USHORT	ReadCUBuffer( PBYTE pBuffer );
	USHORT	WriteCUBuffer( PBYTE pBuffer );
	
	USHORT	Service();

private:
	BYTE	GetInputErrors();
	BYTE	GetRxChannelStatus();

	PHALADAPTER	m_pHalAdapter;
	//QCHANNELSUBCODE m_QSubcode;
	//BYTE	m_RxCBuffer[ 24 ];
	BYTE	m_TxCBuffer[ 24 ];
	ULONG	m_ulFormat;
	ULONG	m_ulMode;
	BOOLEAN	m_bMuteOnError;
	BOOLEAN	m_bWriteCUFirstTime;
	ULONG	m_ulOutputStatus;
};

#endif // _HAL8420_H
