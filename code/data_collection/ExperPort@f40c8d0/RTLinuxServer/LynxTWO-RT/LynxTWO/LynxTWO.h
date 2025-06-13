/****************************************************************************
 LynxTWO.h

 Description:	LynxTWO Interface Header File

 Created: David A. Hoatson, June 2000
	
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

 Environment: Windows 95/98/NT/2000 Kernel mode

 4 spaces per tab

 Revision History
 
 When      Who  Description
 --------- ---  ------------------------------------------------------------
****************************************************************************/
#ifndef _LYNXTWO_H
#define _LYNXTWO_H

#include "Hal.h"

#ifdef  __cplusplus
extern "C" {
#endif

#define PCIDEVICE_LYNXTWO_A			0x0020
#define PCIDEVICE_LYNXTWO_B			0x0021
#define PCIDEVICE_LYNXTWO_C			0x0022
#define PCIDEVICE_LYNX_L22			0x0023
#define PCIDEVICE_LYNX_AES16		0x0024
#define PCIDEVICE_LYNX_AES16SRC		0x0025

typedef unsigned long	MBX;

/////////////////////////////////////////////////////////////////////////////
// Sample Rate
/////////////////////////////////////////////////////////////////////////////
#define MIN_SAMPLE_RATE		8000		// 8kHz
#define MAX_SAMPLE_RATE		215000		// 215kHz

/////////////////////////////////////////////////////////////////////////////
// Number of Devices
/////////////////////////////////////////////////////////////////////////////

enum
{
	WAVE_RECORD0_DEVICE=0,
	WAVE_RECORD1_DEVICE,
	WAVE_RECORD2_DEVICE,
	WAVE_RECORD3_DEVICE,
	WAVE_RECORD4_DEVICE,
	WAVE_RECORD5_DEVICE,
	WAVE_RECORD6_DEVICE,
	WAVE_RECORD7_DEVICE,
	NUM_WAVE_RECORD_DEVICES
};

enum
{
	WAVE_PLAY0_DEVICE=NUM_WAVE_RECORD_DEVICES,	// play devices start after record devices
	WAVE_PLAY1_DEVICE,
	WAVE_PLAY2_DEVICE,
	WAVE_PLAY3_DEVICE,
	WAVE_PLAY4_DEVICE,
	WAVE_PLAY5_DEVICE,
	WAVE_PLAY6_DEVICE,
	WAVE_PLAY7_DEVICE,
	NUM_WAVE_PLAY_DEVICES=(WAVE_PLAY7_DEVICE-WAVE_PLAY0_DEVICE+1)
};

#define NUM_WAVE_DEVICES					(NUM_WAVE_RECORD_DEVICES + NUM_WAVE_PLAY_DEVICES)

#define NUM_CHANNELS_PER_DEVICE				2
#define NUM_WAVE_PHYSICAL_INPUTS			(NUM_WAVE_RECORD_DEVICES * NUM_CHANNELS_PER_DEVICE)
#define NUM_WAVE_PHYSICAL_OUTPUTS			16	// not really associated with play devices

#define	MIDI_RECORD0_DEVICE					0
#define	MIDI_PLAY0_DEVICE					1

#define NUM_MIDI_RECORD_DEVICES				1
#define NUM_MIDI_PLAY_DEVICES				1
#define NUM_MIDI_DEVICES					(NUM_MIDI_RECORD_DEVICES + NUM_MIDI_PLAY_DEVICES)

/////////////////////////////////////////////////////////////////////////////
// Xylinx
/////////////////////////////////////////////////////////////////////////////

#define NUM_BASE_ADDRESS_REGIONS			2
#define PCI_REGISTERS_INDEX					0	// The base address of the PCI/Local configuration registers
#define AUDIO_DATA_INDEX					1	// The base address of the Audio Data Region

#define BAR0_SIZE							2048	// in bytes
#define AES16_BAR0_SIZE						4096	// in bytes
#define BAR1_SIZE							262144	// in bytes

/////////////////////////////////////////////////////////////////////////////
// EEPROM
/////////////////////////////////////////////////////////////////////////////
BOOLEAN	EEPROMGetSerialNumber( PULONG pulSerialNumber, PVOID pL2Registers  );

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
// Register Mailboxes
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
// PCI Bus Control (Write Only)
/////////////////////////////////////////////////////////////////////////////
#define REG_PCICTL_GIE		kBit0	// PCI Interrupt Enable
#define REG_PCICTL_AIE		kBit1	// Audio Interrupt Enable
#define REG_PCICTL_MIE		kBit2	// Misc Interrupt Enable
#define REG_PCICTL_LED		kBit3	// LED
#define REG_PCICTL_CNFDO	kBit4	// FPGA Configuration EEPROM data out
#define REG_PCICTL_CNFTMS	kBit5	// FPGA Configuration EEPROM TMS
#define REG_PCICTL_CNFCK	kBit6	// FPGA Configuration EEPROM clock
#define REG_PCICTL_CNFEN	kBit7	// FPGA Configuration EEPROM write enable
#define REG_PCICTL_ADCREV	kBit8	// Set to 1 for Serial Numbers >= 0317

/////////////////////////////////////////////////////////////////////////////
// Global DMA Control Register (Write Only)
/////////////////////////////////////////////////////////////////////////////
#define REG_DMACTL_GDMAEN			kBit0	// Global DMA Enable
#define REG_DMACTL_GDBLADDR_OFFSET	1

/////////////////////////////////////////////////////////////////////////////
// Miscellaneous Interrupt Status / Reset Register (Read Only)
/////////////////////////////////////////////////////////////////////////////
#define REG_MISTAT_LRXAIF	kBit0	// LTC Receive Buffer A Interrupt Flag
#define REG_MISTAT_LRXBIF	kBit1	// LTC Receive Buffer B Interrupt Flag
#define REG_MISTAT_LTXAIF	kBit2	// LTC Transmit Buffer A Interrupt Flag
#define REG_MISTAT_LTXBIF	kBit3	// LTC Transmit Buffer B Interrupt Flag
#define REG_MISTAT_LRXQFIF	kBit4	// LTC Receive quarter frame interrupt flag
#define REG_MISTAT_OPSTATIF	kBit5	// Option port status received interrupt flag
#define REG_MISTAT_RX8420	kBit6	// CS8420 Interrupt Flag
#define REG_MISTAT_CNFDI	kBit7	// FPGA configuration EEPROM data in
#define REG_MISTAT_MIDI1	kBit14	// Phantom MIDI port service required... :-)
#define REG_MISTAT_MIDI2	kBit15	// Phantom MIDI port service required... :-)

/////////////////////////////////////////////////////////////////////////////
// Audio Interrupt / Status / Reset Register (Read Only)
/////////////////////////////////////////////////////////////////////////////
#define REG_AISTAT_REC0AIF	kBit0	// Record 0 Circular Buffer Interrupt Flag
#define REG_AISTAT_REC1AIF	kBit1	// Record 1 Circular Buffer Interrupt Flag
#define REG_AISTAT_REC2AIF	kBit2	// Record 2 Circular Buffer Interrupt Flag
#define REG_AISTAT_REC3AIF	kBit3	// Record 3 Circular Buffer Interrupt Flag
#define REG_AISTAT_REC4AIF	kBit4	// Record 4 Circular Buffer Interrupt Flag
#define REG_AISTAT_REC5AIF	kBit5	// Record 5 Circular Buffer Interrupt Flag
#define REG_AISTAT_REC6AIF	kBit6	// Record 6 Circular Buffer Interrupt Flag
#define REG_AISTAT_REC7AIF	kBit7	// Record 7 Circular Buffer Interrupt Flag

#define REG_AISTAT_PLAY0AIF	kBit8	// Play 0 Circular Buffer Interrupt Flag
#define REG_AISTAT_PLAY1AIF	kBit9	// Play 1 Circular Buffer Interrupt Flag
#define REG_AISTAT_PLAY2AIF	kBit10	// Play 2 Circular Buffer Interrupt Flag
#define REG_AISTAT_PLAY3AIF	kBit11	// Play 3 Circular Buffer Interrupt Flag
#define REG_AISTAT_PLAY4AIF	kBit12	// Play 4 Circular Buffer Interrupt Flag
#define REG_AISTAT_PLAY5AIF	kBit13	// Play 5 Circular Buffer Interrupt Flag
#define REG_AISTAT_PLAY6AIF	kBit14	// Play 6 Circular Buffer Interrupt Flag
#define REG_AISTAT_PLAY7AIF	kBit15	// Play 7 Circular Buffer Interrupt Flag

#define REG_AISTAT_REC0DIF	kBit16	// Record 0 DMA Buffer Interrupt Flag
#define REG_AISTAT_REC1DIF	kBit17	// Record 1 DMA Buffer Interrupt Flag
#define REG_AISTAT_REC2DIF	kBit18	// Record 2 DMA Buffer Interrupt Flag
#define REG_AISTAT_REC3DIF	kBit19	// Record 3 DMA Buffer Interrupt Flag
#define REG_AISTAT_REC4DIF	kBit20	// Record 4 DMA Buffer Interrupt Flag
#define REG_AISTAT_REC5DIF	kBit21	// Record 5 DMA Buffer Interrupt Flag
#define REG_AISTAT_REC6DIF	kBit22	// Record 6 DMA Buffer Interrupt Flag
#define REG_AISTAT_REC7DIF	kBit23	// Record 7 DMA Buffer Interrupt Flag

#define REG_AISTAT_PLAY0DIF	kBit24	// Play 0 DMA Buffer Interrupt Flag
#define REG_AISTAT_PLAY1DIF	kBit25	// Play 1 DMA Buffer Interrupt Flag
#define REG_AISTAT_PLAY2DIF	kBit26	// Play 2 DMA Buffer Interrupt Flag
#define REG_AISTAT_PLAY3DIF	kBit27	// Play 3 DMA Buffer Interrupt Flag
#define REG_AISTAT_PLAY4DIF	kBit28	// Play 4 DMA Buffer Interrupt Flag
#define REG_AISTAT_PLAY5DIF	kBit29	// Play 5 DMA Buffer Interrupt Flag
#define REG_AISTAT_PLAY6DIF	kBit30	// Play 6 DMA Buffer Interrupt Flag
#define REG_AISTAT_PLAY7DIF	kBit31	// Play 7 DMA Buffer Interrupt Flag

/////////////////////////////////////////////////////////////////////////////
// Global Stream Control Register (Write Only)
/////////////////////////////////////////////////////////////////////////////
#define REG_STRMCTL_GLIMIT_MASK		0xFFF
#define REG_STRMCTL_GSYNC			kBit12	// Global SyncStart Enable

#define REG_STRMCTL_RMULTI			kBit16	// Multi-channel RECORD device mode enable. In this mode, one multi-channel record device is supported 
											// with up to 16 channels. The Record 0 Stream Control Registers and its associated 4096 on-board buffer 
											// are assigned to the multi-channel device. Channels 0,1,2,3,… of the device are mapped to Record 1 Left, 
											// Record 1 Right, Record 2 Left, Record 2 Right,… record streams. RNUMCHNL must be set to indicate the 
											// number of channels of the device.

#define REG_STRMCTL_RNUMCHNL_OFFSET	17
#define REG_STRMCTL_RNUMCHNL_MASK	(kBit17 | kBit18 | kBit19)	// Indicates number of channels of multi-channel RECORD device according to: 
																// RNUMCHNL = (# channels / 2 ) - 1. The number of channels must be a multiple of 2.

#define REG_STRMCTL_PMULTI			kBit20	// Multi-channel PLAY device mode enable. In this mode, one multi-channel play device is supported with up 
											// to 16 channels. The Play 0 Stream Control Registers and its associated 4096 on-board buffer are assigned 
											// to the multi-channel device. Channels 0,1,2,3,… of the device are mapped to Play 1 Left, Play 1 Right, 
											// Play 2 Left, Play 2 Right,… play streams. Streams not used are placed in idle mode with muted outputs. 
											// PNUMCHNL must be set to indicate the number of channels of the device.

#define REG_STRMCTL_PNUMCHNL_OFFSET	21
#define REG_STRMCTL_PNUMCHNL_MASK	(kBit21 | kBit22 | kBit23)	// Indicates number of channels of multi-channel PLAY device according to:
																// PNUMCHNL = (# channels / 2 ) - 1. The number of channels must be a multiple of 2.


/////////////////////////////////////////////////////////////////////////////
// PLL Control Register (Write Only)
/////////////////////////////////////////////////////////////////////////////

#define REG_PLLCTL_M_OFFSET			0
#define REG_PLLCTL_BypassM_OFFSET	11
#define REG_PLLCTL_N_OFFSET			12
#define REG_PLLCTL_P_OFFSET			23
#define REG_PLLCTL_CLKSRC_OFFSET	25
#define REG_PLLCTL_WORDALIGN_OFFSET	28
#define REG_PLLCTL_SPEED_OFFSET		29
#define REG_PLLCTL_PLLPDn			31

#define MAKE_PLLCTL_L2AREVNC( M, bpM, N, P, CLK, W, S )	((M) | (bpM << 11) | (N << 12) | (P << 23) | (CLK << 25) | (W << 28) | (S << 29) | kBit31 )
#define MAKE_PLLCTL( M, bpM, N, P, CLK, W, S )		((M) | (bpM << 11) | (N << 12) | (P << 23) | (CLK << 25) | (W << 28) | (S << 29) )

#define SR_P2	0
#define SR_P4	1
#define SR_P8	2
#define SR_P16	3

#define SR_SPEED_1X	0
#define SR_SPEED_2X	1
#define SR_SPEED_4X	2

// Values for CONTROL_CLOCKSOURCE
enum	
{
	MIXVAL_L2_CLKSRC_INTERNAL=0,		// Internal Clock
	MIXVAL_L2_CLKSRC_DIGITAL,			// Digital (AESEBU) Input
	MIXVAL_L2_CLKSRC_EXTERNAL,			// External BNC Input
	MIXVAL_L2_CLKSRC_HEADER,			// Internal Header Input
	MIXVAL_L2_CLKSRC_VIDEO,				// Video Input
	MIXVAL_L2_CLKSRC_LSTREAM_PORT1,		// Option Port Clock
	MIXVAL_L2_CLKSRC_LSTREAM_PORT2,		// Option Port Clock

	MIXVAL_AES16_CLKSRC_INTERNAL,		// Internal Clock
	MIXVAL_AES16_CLKSRC_EXTERNAL,		// External BNC Input
	MIXVAL_AES16_CLKSRC_HEADER,			// Internal Header Input
	MIXVAL_AES16_CLKSRC_LSTREAM,		// Option Port Clock
	MIXVAL_AES16_CLKSRC_DIGITAL_0,		// Digital In 0
	MIXVAL_AES16_CLKSRC_DIGITAL_1,		// Digital In 1
	MIXVAL_AES16_CLKSRC_DIGITAL_2,		// Digital In 2
	MIXVAL_AES16_CLKSRC_DIGITAL_3,		// Digital In 3
	NUM_CLKSRC							// Never used
};

// Values for CONTROL_CLOCKREFERENCE
enum
{
	MIXVAL_CLKREF_AUTO=0,		// Automatic Clock Reference
	MIXVAL_CLKREF_13p5MHZ,		// 13.5Mhz Clock Reference
	MIXVAL_CLKREF_27MHZ,		// 27Mhz Clock Reference
	MIXVAL_CLKREF_WORD,			// Word Clock
	MIXVAL_CLKREF_WORD256,		// SuperClock
	NUM_CLKREFS
};

#define REG_PLLCTL_SPEED_SINGLE			0
#define REG_PLLCTL_SPEED_DOUBLE			kBit29
#define REG_PLLCTL_SPEED_QUAD			(kBit29 | kBit30)

/////////////////////////////////////////////////////////////////////////////
// I/O Control Block Indirect Address Register (Write Only)
/////////////////////////////////////////////////////////////////////////////

#define REG_IOADDR_WRITE	(0<<8)
#define REG_IOADDR_READ		kBit8

// See Hal8420.h for it's register offsets

// Register Offsets
enum
{
	kDAC_A_Control = 0x81,		// 80 - 83, DAC A Control (serially-controlled)
	kDAC_B_Control = 0x85,		// 84 - 87, DAC B Control (serially-controlled)
	kDAC_C_Control = 0x89,		// 88 - 8B, DAC C Control (serially-controlled)
	kADC_A_Control = 0x90,		// 90, ADC A Control (pin-controlled)
	kADC_B_Control,				// 91, ADC B Control (pin-controlled)
	kTrim,						// 92, Analog Trim Control (pin-controlled)
	kMisc,						// 93, Miscellaneous Control (pin-controlled)
	kOptionIOControl,			// 94, Option Port I/O Control (no longer defined)
	kADC_C_Control,				// 95, ADC C Control (pin-controlled)
	NUM_IO_REGISTERS
};

/////////////////////////////////////////////////////////////////////////////
// I/O Control Block Data Register (R/W)
/////////////////////////////////////////////////////////////////////////////

// DAC Control (0x81, 0x85, 0x89)	Crystal CS4396
#define IO_DAC_CNTL_PDN				kBit0		// Power Down
#define IO_DAC_CNTL_MODE_MASK		(0x1F<<1)	// Mode Select mask
#define IO_DAC_CNTL_MODE_1X_EMPOFF	(0x0D<<1)	// Single speed, de-emphasis off
#define IO_DAC_CNTL_MODE_1X_EMP32K	(0x01<<1)	// Single speed, 32K de-emphasis
#define IO_DAC_CNTL_MODE_1X_EMP44K	(0x05<<1)	// Single speed, 44.1K de-emphasis
#define IO_DAC_CNTL_MODE_1X_EMP48K	(0x09<<1)	// Single speed, 48K de-emphasis
#define IO_DAC_CNTL_MODE_2X			(0x1D<<1)	// Double speed
#define IO_DAC_CNTL_MODE_4X			(0x19<<1)	// Quad speed
#define IO_DAC_CNTL_MUTEn			kBit6		// Soft Mute - Active Low
#define IO_DAC_CNTL_CAL				kBit7		// Enables DC Offset Calibration

// ADC Control (0x90, 0x91, 0x95)	AKM AK5394
#define IO_ADC_CNTL_RSTn			kBit0	// Reset - Active Low
#define IO_ADC_CNTL_ZCAL			kBit1	// Zero Calibration Control
#define IO_ADC_CNTL_DFS_MASK		(3<<2)	// Output Sample Rate Select mask
#define IO_ADC_CNTL_DFS_1X			(0<<2)	// Output Sample Rate Select - single speed
#define IO_ADC_CNTL_DFS_2X			kBit2	// Output Sample Rate Select - double speed
#define IO_ADC_CNTL_DFS_4X			(2<<2)	// Output Sample Rate Select - quad speed
#define IO_ADC_CNTL_HPFE			kBit4	// High-pass filter enable

// Trim Control @ byte address 0x92
#define IO_TRIM_ABC_AIN12_PLUS4		(0)		// All Models
#define IO_TRIM_ABC_AIN12_MINUS10	kBit0
#define IO_TRIM_ABC_AIN12_MASK		kBit0

#define IO_TRIM_AC_AIN34_PLUS4		(0)		// A & C Models
#define IO_TRIM_AC_AIN34_MINUS10	kBit1
#define IO_TRIM_AC_AIN34_MASK		kBit1

#define IO_TRIM_B_AOUT56_PLUS4		(0)		// B Model
#define IO_TRIM_B_AOUT56_MINUS10	kBit1
#define IO_TRIM_B_AOUT56_MASK		kBit1

#define IO_TRIM_AB_AOUT12_PLUS4		(0)		// A & B Models
#define IO_TRIM_AB_AOUT12_MINUS10	kBit2
#define IO_TRIM_AB_AOUT12_MASK		kBit2

#define IO_TRIM_C_AIN56_PLUS4		(0)		// C Model
#define IO_TRIM_C_AIN56_MINUS10		kBit2
#define IO_TRIM_C_AIN56_MASK		kBit2

#define IO_TRIM_AB_AOUT34_PLUS4		(0)		// A & B Models
#define IO_TRIM_AB_AOUT34_MINUS10	kBit3
#define IO_TRIM_AB_AOUT34_MASK		kBit3

#define IO_TRIM_C_AOUT12_PLUS4		(0)		// C Model
#define IO_TRIM_C_AOUT12_MINUS10	kBit3
#define IO_TRIM_C_AOUT12_MASK		kBit3

// Misc Control @ byte address 0x93
#define IO_MISC_DACCRSTn		kBit0	// DAC C power down, active low (B Model Only)
#define IO_MISC_DF_AESEBU		(0)
#define IO_MISC_DF_SPDIF		kBit1
#define IO_MISC_DF_MASK			kBit1
#define IO_MISC_DACARSTn		kBit2	// DAC A power down, active low
#define IO_MISC_DACBRSTn		kBit3	// DAC B power down, active low
#define IO_MISC_CS8420RSTn		kBit4	// CS8420 reset, active low
#define IO_MISC_DILRCKDIR		kBit5	// Digital In LRCK Direction, 0=output, 1=input
#define IO_MISC_DIRMCKDIR		kBit6	// Digital In RMCK Direction, 0=output, 1=input
#define IO_MISC_VIDEN			kBit7	// Enables routing of SYNC IN to video sync, Rev NC A Model Only

// 06/24/2002: New firmware no longer supports this register
// Option Control @ byte address 0x94
#define IO_OPT_OPHD1DIR			kBit0		// Header Option Port OPHD1 direction, 0=output, 1=input
#define IO_OPT_OPHD2DIR			kBit1		// Header Option Port OPHD2 direction, 0=output, 1=input
#define IO_OPT_OPHDINSEL		kBit2		// Header Option Port input data select, 0 = OPHD1, 1=OPHD2
#define IO_OPT_OPHSIG			kBit3		// Header Option Port OPHSIG state
#define IO_OPT_OPHSIGDIR		kBit4		// Header Option Port OPHSIG Direction, 0=output, 1=input
#define IO_OPT_OPBFCKDIR		kBit5		// Bracket Option Port Frame Clock Direction, 0=output, 1=input
#define IO_OPT_OPHFCKDIR		kBit6		// Header Option Port Frame Clock Direction, 0=output, 1=input
#define IO_OPT_OPHBLKSEL		kBit7		// Header Option Port Data Source, 0=PMIX 0-7, 1=PMIX 8-15

/////////////////////////////////////////////////////////////////////////////
// Stream Control Register
/////////////////////////////////////////////////////////////////////////////
#define REG_STREAMCTL_PCPTR_OFFSET		0	// b0-11 Host Circular Buffer Pointer
#define REG_STREAMCTL_MODE_OFFSET		12	// b12-13: Mode Control
#define REG_STREAMCTL_FMT_OFFSET		14	// b14-15: Format Control
#define REG_STREAMCTL_CHNUM_OFFSET		16	// b16 0=MONO, 1=STEREO

#define REG_STREAMCTL_PCPTR_MASK		0xFFF

#define REG_STREAMCTL_MODE_MASK			(kBit12 | kBit13)
#define REG_STREAMCTL_MODE_IDLE			0
#define REG_STREAMCTL_MODE_RUN			kBit12
#define REG_STREAMCTL_MODE_UNDEFINED	kBit13
#define REG_STREAMCTL_MODE_SYNCREADY	(kBit12 | kBit13)

#define REG_STREAMCTL_FMT_MASK			(kBit14 | kBit15)
#define REG_STREAMCTL_FMT_PCM8			0
#define REG_STREAMCTL_FMT_PCM16			kBit14
#define REG_STREAMCTL_FMT_PCM24			kBit15
#define REG_STREAMCTL_FMT_PCM32			(kBit14 | kBit15)

#define REG_STREAMCTL_CHNUM_MONO		0
#define REG_STREAMCTL_CHNUM_STEREO		kBit16

#define REG_STREAMCTL_LIMIE				kBit17	// Limit Interrupt Enable
#define REG_STREAMCTL_OVERIE			kBit18	// Overrun Interrupt Enable

#define REG_STREAMCTL_XFERDONE			kBit19	// Transfer Complete

#define REG_STREAMCTL_DMAEN				kBit20	// DMA Enable
#define REG_STREAMCTL_DMAHST			kBit21	// DMA Host Start

#define REG_STREAMCTL_DMABINX_OFFSET	22	// b22-25: DMABINX
#define REG_STREAMCTL_DMABINX_MASK		(kBit22 | kBit23 | kBit24 | kBit25)

#define REG_STREAMCTL_DMAMODE			kBit26	// DMA State (0=IDLE, 1=ENABLED)
#define REG_STREAMCTL_DMASTARV			kBit27	// DMA Starvation Mode

#define REG_STREAMCTL_DMASINGLE			kBit28	// DMA Single

#define REG_STREAMCTL_DMADUALMONO		kBit29	// Only valid if FMT_PCM32 & CHNUM_STEREO are set

/////////////////////////////////////////////////////////////////////////////
// Stream Status Register
/////////////////////////////////////////////////////////////////////////////
#define REG_STREAMSTAT_L2PTR_OFFSET		0	// b0-11 Hardware Circular Buffer Pointer
#define REG_STREAMSTAT_BYTECNT_OFFSET	12	// b12-13
#define REG_STREAMSTAT_MODE_OFFSET		14	// b14 0=IDLE, 1=RUN
#define REG_STREAMSTAT_LIMHIT_OFFSET	15	// b15 Circular Buffer Limit Hit Flag
#define REG_STREAMSTAT_OVER_OFFSET		16	// b16 Circular Buffer Overrun Flag

#define REG_STREAMSTAT_L2PTR_MASK		0xFFF
#define REG_STREAMSTAT_RUN_MODE			kBit14
#define REG_STREAMSTAT_LIMHIT			kBit15
#define REG_STREAMSTAT_OVER				kBit16

/////////////////////////////////////////////////////////////////////////////
// Stream Control Block
/////////////////////////////////////////////////////////////////////////////
typedef struct 
{
	MBX			RecordControl[ NUM_WAVE_RECORD_DEVICES ];
	MBX			PlayControl[ NUM_WAVE_PLAY_DEVICES ];
	MBX			RecordStatus[ NUM_WAVE_RECORD_DEVICES ];
	MBX			PlayStatus[ NUM_WAVE_PLAY_DEVICES ];
} SCBLOCK, FAR *PSCBLOCK;

/////////////////////////////////////////////////////////////////////////////
// Time Code Buffers
/////////////////////////////////////////////////////////////////////////////
#define TCBUFFER_FRAME_UNITS_MASK	0x0000000F
#define TCBUFFER_FRAME_TENS_MASK	0x00000300
#define TCBUFFER_SECONDS_UNITS_MASK	0x0000000F
#define TCBUFFER_SECONDS_TENS_MASK	0x00000700
#define TCBUFFER_MINUTES_UNITS_MASK	0x0000000F
#define TCBUFFER_MINUTES_TENS_MASK	0x00000700
#define TCBUFFER_HOURS_UNITS_MASK	0x0000000F
#define TCBUFFER_HOURS_TENS_MASK	0x00000300
#define TCBUFFER_TENS_OFFSET		8
#define TCBUFFER_DROPFRAME_MASK		kBit10

/////////////////////////////////////////////////////////////////////////////
// Time Code Block
// 64 DWORDs
/////////////////////////////////////////////////////////////////////////////
#define TCBUFFER_SIZE	4	// in DWORDs
typedef struct 
{
	MBX			LTCRxBufA[ TCBUFFER_SIZE ];
	MBX			LTCRxBufB[ TCBUFFER_SIZE ];
	MBX			LTCTxBufA[ TCBUFFER_SIZE ];
	MBX			LTCTxBufB[ TCBUFFER_SIZE ];
	MBX			VITCRxBuf1A[ TCBUFFER_SIZE ];
	MBX			VITCRxBuf1B[ TCBUFFER_SIZE ];
	MBX			VITCRxBuf2A[ TCBUFFER_SIZE ];
	MBX			VITCRxBuf2B[ TCBUFFER_SIZE ];
	MBX			LTCControl;
	MBX			VITCControl;
	MBX			TCStatus;
	MBX			LTCRxFrameRate;
	MBX			Unused[ 28 ];
} TCBLOCK, FAR *PTCBLOCK;

/////////////////////////////////////////////////////////////////////////////
// LTC Control Register
/////////////////////////////////////////////////////////////////////////////

#define REG_LTCCONTROL_LRXEN				kBit0
#define REG_LTCCONTROL_LRXIE				kBit1
#define REG_LTCCONTROL_LTXEN				kBit2
#define REG_LTCCONTROL_LTXIE				kBit3
#define REG_LTCCONTROL_LTXCLK				kBit4
#define REG_LTCCONTROL_LTXSYNC_FREERUNNING	(0)
#define REG_LTCCONTROL_LTXSYNC_VIDEOLINE5	kBit5
#define REG_LTCCONTROL_LTXSYNC_LTCRX		(2<<5)
#define REG_LTCCONTROL_LTXSYNC_REGWRITE		(3<<5)
#define REG_LTCCONTROL_LTXSYNC_MASK			(3<<5)
#define REG_LTCCONTROL_LTXRATE_24FPS		(0)
#define REG_LTCCONTROL_LTXRATE_25FPS		kBit7
#define REG_LTCCONTROL_LTXRATE_2997FPS		kBit8
#define REG_LTCCONTROL_LTXRATE_30FPS		(kBit7 | kBit8)
#define REG_LTCCONTROL_LTXRATE_MASK			(kBit7 | kBit8)
#define REG_LTCCONTROL_LRXQFIE				kBit9	// LTC Receive quarter frame interrupt enable

/////////////////////////////////////////////////////////////////////////////
// Time Code Status Register
/////////////////////////////////////////////////////////////////////////////

#define TCSTATUS_LRXLOCK			kBit0
#define TCSTATUS_LRXDIR_BACKWARD	(0<<1)
#define TCSTATUS_LRXDIR_FORWARD		kBit1
#define TCSTATUS_LRXDIR_MASK		kBit1

/////////////////////////////////////////////////////////////////////////////
// LTC Receive Frame Rate
/////////////////////////////////////////////////////////////////////////////
#define LTCRXRATE_MASK				0x0000FFFF

/////////////////////////////////////////////////////////////////////////////
// Frequency Counter Block (Read Only)
/////////////////////////////////////////////////////////////////////////////
typedef struct
{
	MBX			Count;
	MBX			Scale;
} FREQCOUNTER, FAR *PFREQCOUNTER;

enum
{
	L2_FREQCOUNTER_LRCLOCK=0,	// Left/Right Clock
	L2_FREQCOUNTER_DIGITALIN,	// Digital Input
	L2_FREQCOUNTER_EXTERNAL,	// External Input
	L2_FREQCOUNTER_HEADER,		// Header Input
	L2_FREQCOUNTER_VIDEO,		// Video Input, Should be either 15.734kHz NTSC or 15.625 kHz PAL
	L2_FREQCOUNTER_LSTREAM1,	// Option Port 1 Input
	L2_FREQCOUNTER_LSTREAM2,	// Option Port 2 Input
	L2_FREQCOUNTER_PCI,			// PCI Clock
	L2_FREQCOUNTER_NUMENTIRES
};

enum
{
	AES16_FREQCOUNTER_LRCLOCK=0,// Left/Right Clock
	AES16_FREQCOUNTER_EXTERNAL,	// External Input
	AES16_FREQCOUNTER_HEADER,	// Header Input
	AES16_FREQCOUNTER_LSTREAM,	// Option Port 2 Input
	AES16_FREQCOUNTER_PCI,		// PCI Clock
	AES16_FREQCOUNTER_DI1,		// Digital Input 1
	AES16_FREQCOUNTER_DI2,		// Digital Input 2
	AES16_FREQCOUNTER_DI3,		// Digital Input 3
	AES16_FREQCOUNTER_DI4,		// Digital Input 4
	AES16_FREQCOUNTER_DI5,		// Digital Input 5
	AES16_FREQCOUNTER_DI6,		// Digital Input 6
	AES16_FREQCOUNTER_DI7,		// Digital Input 7
	AES16_FREQCOUNTER_DI8,		// Digital Input 8
	AES16_FREQCOUNTER_NUMENTIRES
};

#define REG_FCBLOCK_COUNT_MASK	0xFFFF
#define REG_FCBLOCK_SCALE_MASK	0xF
#define REG_FCBLOCK_NTSCPALn	kBit4

/////////////////////////////////////////////////////////////////////////////
// Product Data Block
// 32 DWORDs in length
/////////////////////////////////////////////////////////////////////////////
typedef struct 
{
	MBX		LY;
	MBX		NX;
	MBX		DeviceID;		// Device ID
	MBX		PCBRev;			// PCB Revision
	MBX		FWRevID;		// Firmware Revision & ID
	MBX		FWDate;			// Firmware Date
	MBX		MinSWAPIRev;	// Minimum Software API Revision Required
	MBX		Spare[ 25 ];
} PDBLOCK, FAR *PPDBLOCK;

// Serial Number is encoded as:
#define L2SN_GET_UNITID( SN )	(SN & 0xFFF)
#define L2SN_GET_WEEK( SN )		((SN >> 12) & 0xFF)
#define L2SN_GET_YEAR( SN )		((SN >> 20) & 0xF)
#define L2SN_GET_MODEL( SN )	((SN >> 24) & 0xFF)

/////////////////////////////////////////////////////////////////////////////
// CS8420 Control/Status Block
/////////////////////////////////////////////////////////////////////////////

// See Hal8420.h for a complete description of these fields

typedef struct
{
	// 8420 Control Register Map
	BYTE	Unknown0;				// 0
	BYTE	Control1;				// 1
	BYTE	Control2;				// 2
	BYTE	DataFlowControl;		// 3
	BYTE	ClockSourceControl;		// 4
	BYTE	SerialInputFormat;		// 5
	BYTE	SerialOutputFormat;		// 6
	BYTE	Interrupt1Status;		// 7
	BYTE	Interrupt2Status;		// 8
	BYTE	Interrupt1Mask;			// 9
	BYTE	Interrupt1ModeMSB;		// 10
	BYTE	Interrupt1ModeLSB;		// 11
	BYTE	Interrupt2Mask;			// 12
	BYTE	Interrupt2ModeMSB;		// 13
	BYTE	Interrupt2ModeLSB;		// 14
	BYTE	ReceiverCSData;			// 15
	BYTE	ReceiverErrors;			// 16
	BYTE	ReceiverErrorMask;		// 17
	BYTE	CSDataBufferControl;	// 18
	BYTE	UDataBufferControl;		// 19
	BYTE	QSubCodeData[ 10 ];		// 20-29
	BYTE	SampleRateRatio;		// 30
	BYTE	Unknown1;				// 31
	BYTE	CorUDataBuffer[ 24 ];	// 32-55
	BYTE	Unknown2[ 71 ];			// 56-126
	BYTE	IDandVersion;			// 127
} CS8420BLOCK, FAR *PCS8420BLOCK;

/////////////////////////////////////////////////////////////////////////////
// I/O Control Block (Accessed indirectly via IOADDR and IODATA)
/////////////////////////////////////////////////////////////////////////////
typedef struct 
{
	CS8420BLOCK	CS8420Block;		// 128 bytes
	MBX			DACAControl[ 4 ];	// 0x80 - 0x83
	MBX			DACBControl[ 4 ];	// 0x84 - 0x87
	MBX			ADCAControl;		// 0x90
	MBX			ADCBControl;		// 0x91
	MBX			TrimControl;		// 0x92
	MBX			MiscControl;		// 0x93
	MBX			OptionControl;		// 0x94
} IOBLOCK, FAR *PIOBLOCK;

/////////////////////////////////////////////////////////////////////////////
// OPIOCTL: Option Port (LStream) I/O Control Register (write only)
/////////////////////////////////////////////////////////////////////////////

#define REG_OPIOCTL_OPHD1DIR		kBit0	// Header option port OPHD1 direction, 0 = output, 1 = input (default to output)	W
#define REG_OPIOCTL_OPHD2DIR		kBit1	// Header option port OPHD2 direction, 0 = output, 1 = input (default to input)		W
#define REG_OPIOCTL_OPHDINSEL		kBit2	// Header option port input data select, 0 = OPHD1, 1 = OPHD2	W
#define REG_OPIOCTL_OPBBLKSEL		kBit3	// Selects the data sources for bracket option port output
											// 0 = PMIX 8 -15 routed to bracket port channels 0 - 7
											//	   PMIX 0 - 7 routed to bracket port channels 8 - 15
											// 1 = PMIX 0 - 7 routed to bracket port channels 0 - 7
											//	   PMIX 8 - 15 routed to bracket port channels 8 - 15	W
#define REG_OPIOCTL_OPHBCKENn		kBit4	// Header option port bit clock output enable, 0 = enabled, 1 = hi-z	W
#define REG_OPIOCTL_OPBFCKDIR		kBit5	// Bracket option port frame clock direction, 0 = output, 1 = input	W
#define REG_OPIOCTL_OPHFCKDIR		kBit6	// Header option port frame clock direction, 0 = output, 1 = input	W
#define REG_OPIOCTL_OPHBLKSEL		kBit7	// Selects the data sources for header option port output
											// 0 = PMIX 8 -15 routed to header port channels 0 - 7
											//	   PMIX 0 - 7 routed to header port channels 8 - 15
											// 1 = PMIX 0 - 7 routed to header port channels 0 - 7
											//	   PMIX 8 - 15 routed to header port channels 8 - 15	W
#define REG_OPIOCTL_OPHDUAL			kBit8	// Dual Internal Mode
#define REG_OPIOCTL_OPHSIGDIR		kBit9	// Header option port OPHSIG direction, 0 = output, 1 = input	W
#define REG_OPIOCTL_OPSTATIE		kBit10	// Option port status interrupt enable. Enables interrupt generation 
											// when status data from either option port is available in status FIFO. 
											// An interrupt is generated when the FIFO becomes not empty or full.	
#define REG_OPIOCTL_OPCTLRST		kBit11	// Option port device control FIFO reset. Resets FIFO pointers to an 
											// empty state. Writing a "1" to this bit position generates a single 
											// reset pulse. Clear is not required.	
#define REG_OPIOCTL_OPSTATRST		kBit12	// Option port device status FIFO reset. Resets FIFO pointers to an 
											// empty state. Writing a "1" to this bit position generates a single 
											// reset pulse. Clear is not required.	

enum {
	MIXVAL_LSTREAM_OUTSEL_9TO16_1TO8=0,
	MIXVAL_LSTREAM_OUTSEL_1TO8_9TO16
};

/////////////////////////////////////////////////////////////////////////////
// OPDEVCTL: Option Port (LStream) Device Control Register (write only)
/////////////////////////////////////////////////////////////////////////////
#define REG_OPDEVCTL_DATA_OFFSET	0		// Bit 0
#define REG_OPDEVCTL_ADDR_OFFSET	8		// Bit 8
#define REG_OPDEVCTL_PORT_OFFSET	15		// Bit 15

#define REG_OPDEVCTL_DATA_MASK		0x00FF	// 7:0	DATA[7:0]: Device control data
#define REG_OPDEVCTL_ADDR_MASK		0x7F00	// 14:8	ADDR[6:0]: Device control register address
#define REG_OPDEVCTL_PORT			kBit15	// 15	PORT: Indicates target option port. 
											// 0 = bracket port (LStream 1)
											// 1 = header option port (LStream 2)

/////////////////////////////////////////////////////////////////////////////
// OPDEVSTAT: Option Port (LStream) Device Status Register (read only)
/////////////////////////////////////////////////////////////////////////////
#define REG_OPDEVSTAT_DATA_OFFSET	0		// Bit 0
#define REG_OPDEVSTAT_ADDR_OFFSET	8		// Bit 8
#define REG_OPDEVSTAT_PORT_OFFSET	15		// Bit 15

#define REG_OPDEVSTAT_DATA_MASK		0x00FF	// 7:0	DATA[7:0]: Device status data
#define REG_OPDEVSTAT_ADDR_MASK		0x7F00	// 14:8	ADDR[6:0]: Device status register address
#define REG_OPDEVSTAT_PORT			kBit15	// 15	PORT: Indicates target option port. 0 = bracket port (LStream 1), 1 = header option port (LStream 2)
#define REG_OPDEVSTAT_STAT_EMPTY	kBit16	// 16	STAT_EMPTY: Option port status FIFO empty flag
#define REG_OPDEVSTAT_STAT_FULL		kBit17	// 17	STAT_FULL: Option port status FIFO full flag
#define REG_OPDEVSTAT_CTL_EMPTY		kBit18	// 18	CTL_EMPTY: Option port control FIFO empty flag
#define REG_OPDEVSTAT_CTL_FULL		kBit19	// 19	CTL_FULL: Option port control FIFO full flag
#define REG_OPDEVSTAT_LOCKED0		kBit20	// 20	LOCKED0: Option port 0 (bracket) input locked flag
#define REG_OPDEVSTAT_LOCKED1		kBit21	// 21	LOCKED1: Option port 1 (header) input locked flag


/////////////////////////////////////////////////////////////////////////////
// OPBUFSTAT: Option Port (LStream) Buffer Status Register (read only)
/////////////////////////////////////////////////////////////////////////////

#define REG_OPBUFSTAT_STAT_EMPTY	kBit16	// 16	STAT_EMPTY: Option port status FIFO empty flag
#define REG_OPBUFSTAT_STAT_FULL		kBit17	// 17	STAT_FULL: Option port status FIFO full flag
#define REG_OPBUFSTAT_CTL_EMPTY		kBit18	// 18	CTL_EMPTY: Option port control FIFO empty flag
#define REG_OPBUFSTAT_CTL_FULL		kBit19	// 19	CTL_FULL: Option port control FIFO full flag
#define REG_OPBUFSTAT_LOCKED0		kBit20	// 20	LOCKED0: Option port 0 (bracket) input locked flag
#define REG_OPBUFSTAT_LOCKED1		kBit21	// 21	LOCKED1: Option port 1 (header) input locked flag
#define REG_OPBUFSTAT_LRCLOCK		kBit22	// 22	LRCLOCK

/////////////////////////////////////////////////////////////////////////////
// Record Mix Control Register
/////////////////////////////////////////////////////////////////////////////

#define REG_RMIX_INSRC_OFFSET		0
#define REG_RMIX_INSRC_MASK			0x3F

#define REG_RMIX_DITHERTYPE_NONE					(0)
#define REG_RMIX_DITHERTYPE_TRIANGULAR_PDF			kBit6
#define REG_RMIX_DITHERTYPE_TRIANGULAR_PDF_HI_PASS	kBit7
#define REG_RMIX_DITHERTYPE_RECTANGULAR_PDF			(kBit6 | kBit7)
#define REG_RMIX_DITHERTYPE_MASK					(kBit6 | kBit7)

#define REG_RMIX_DITHERDEPTH_8BITS					(0)
#define REG_RMIX_DITHERDEPTH_16BITS					kBit8
#define REG_RMIX_DITHERDEPTH_20BITS					kBit9
#define REG_RMIX_DITHERDEPTH_24BITS					(kBit8 | kBit9)
#define REG_RMIX_DITHERDEPTH_MASK					(kBit8 | kBit9)

#define REG_RMIX_DITHER				kBit10
#define REG_RMIX_MUTE				kBit11

/////////////////////////////////////////////////////////////////////////////
// Play Mix Input Control Register
/////////////////////////////////////////////////////////////////////////////

#define REG_PMIX_VOLUME_OFFSET		0
#define REG_PMIX_VOLBYPASS_OFFSET	16
#define REG_PMIX_PLAYSOURCE_OFFSET	17
#define REG_PMIX_DITHER_OFFSET		22
#define REG_PMIX_OPCTL_OFFSET		24

#define REG_PMIX_VOLUME_MASK		0x0000FFFF
#define REG_PMIX_VOLBYPASS			kBit16
#define REG_PMIX_PLAYSOURCE_MASK	(0x1F << REG_PMIX_PLAYSOURCE_OFFSET)	// 5 bits
#define REG_PMIX_DITHER				kBit22
#define REG_PMIX_OPCTL_MASK			0xFF000000

enum
{
	PMIX_LINE_A=0,
	PMIX_LINE_B,
	PMIX_LINE_C,
	PMIX_LINE_D,
	NUM_PMIX_LINES
};

typedef struct 
{
	MBX			PMixControl[ NUM_PMIX_LINES ];
} PLAYMIXCTL, FAR *PPLAYMIXCTL;	// 4 DWORDs

/////////////////////////////////////////////////////////////////////////////
// Mixer Control Block
/////////////////////////////////////////////////////////////////////////////

#define REG_RMIXSTAT_LEVEL_OFFSET	0

#define REG_RMIXSTAT_LEVEL_MASK		0x000FFFFF	// 20 bits
#define REG_RMIXSTAT_LEVEL_RESET	kBit20

#define REG_PMIXSTAT_LEVEL_MASK		0x000FFFFF	// 20 bits
#define REG_PMIXSTAT_LEVEL_RESET	kBit20
#define REG_PMIXSTAT_OVERLOAD		kBit21
#define REG_PMIXSTAT_OVERLOAD_RESET	kBit22

typedef struct 
{
	MBX			RMixControl[ NUM_WAVE_PHYSICAL_INPUTS ];	// 0x0400	16 DWORDs
	MBX			Reserved1[ 48 ];							// 0x0440	48 DWORDs
	PLAYMIXCTL	PMixControl[ NUM_WAVE_PHYSICAL_OUTPUTS ];	// 0x0500	64 DWORDs
	MBX			RMixStatus[ NUM_WAVE_PHYSICAL_INPUTS ];		// 0x0600	16 DWORDs
	MBX			PMixStatus[ NUM_WAVE_PHYSICAL_OUTPUTS ];	// 0x0640	16 DWORDs
	MBX			Reserved2[ 96 ];							// 0x0680	96 DWORDs
} MIXBLOCK, FAR *PMIXBLOCK;	// 256 DWORDs

/////////////////////////////////////////////////////////////////////////////
// AES AK4114 Control Registers (AES16 Only)
/////////////////////////////////////////////////////////////////////////////

typedef struct 
{
	MBX		TXCS10;		// Transmit channel status byte 0 & 1
	MBX		TXCS32;		// Transmit channel status byte 2 & 3
	MBX		TXCS54;		// Transmit channel status byte 4 & 5
	MBX		TXCS76;		// Transmit channel status byte 6 & 7
	MBX		TXCS98;		// Transmit channel status byte 8 & 9
	MBX		TXCS2322;	// Transmit channel status byte 22 & 23
	MBX		CLKPWR;		// Clock and power down control
	MBX		FMTDEMP;	// Format and de-emphasis control
} AK4114CTL, FAR *PAK4114CTL;	// 8 DWORDs

/////////////////////////////////////////////////////////////////////////////
// AES AK4114 Status Registers (AES16 Only)
/////////////////////////////////////////////////////////////////////////////

typedef struct 
{						// Bits 15:8			Bits 7:0
	MBX		RXSTAT10;	// Receiver Status 1	Receiver Status 0
	MBX		RXCS10;		// RX CS byte 1			RX CS byte 0
	MBX		RXCS32;		// RX CS byte 3			RX CS byte 2
	MBX		RXCS4;		// unused				RX CS byte 4
	MBX		PREAMPC10;	// Non-PCM Preamble Pc byte 1	Non-PCM Preamble Pc byte 0
	MBX		PREAMPD10;	// Non-PCM Preamble Pd byte 1	PREAMPD0: Non-PCM Preamble Pd byte 0
	MBX		Reserved[ 2 ];
} AK4114STAT, FAR *PAK4114STAT;	// 8 DWORDs

/////////////////////////////////////////////////////////////////////////////
// AES Control Block (AES16 Only)
/////////////////////////////////////////////////////////////////////////////

typedef struct 
{

	AK4114CTL	AK4114Control[ 8 ];		// 64 DWORDs
	MBX			Reserved1[ 64 ];		// 64 DWORDs
	AK4114STAT	AK4114Status[ 8 ];		// 64 DWORDs
	MBX			Reserved2[ 64 ];		// 64 DWORDs
} AESBLOCK, FAR *PAESBLOCK;	// 256 DWORDs

/////////////////////////////////////////////////////////////////////////////
// BAR0 Shared Memory Window
/////////////////////////////////////////////////////////////////////////////
typedef struct 
{
	PDBLOCK		PDBlock;	// 32 DWORDS
	FREQCOUNTER	FRBlock[ 16 ];	// 32 DWORDS Frequency Counter Block
	MBX			PCICTL;		// 100, PCI Bus Control
	MBX			DMACTL;		// 104, Global DMA Control
	MBX			MISTAT;		// 108, Misc Interrupt Status / Reset
	MBX			AISTAT;		// 10C, Audio Interrupt Status / Reset
	MBX			STRMCTL;	// 110, Global Stream Control
	MBX			PLLCTL;		// 114, PLL Control
	union 
	{
		MBX		IOADDR;		// 118, IOBLOCK Indirect Address
		MBX		VCXOCTL;	// 118, VCXO registers, debug only
	};
	union 
	{
		MBX		IODATA;		// 11C, IOBLOCK Data
		MBX		MISCTL;		// 11C, Misc Control Register
	};
	MBX			OPIOCTL;	// 120, Option Port I/O control
	MBX			OPDEVCTL;	// 124,	Option Port device control
	MBX			OPDEVSTAT;	// 128, Option Port device status
	MBX			OPBUFSTAT;	// 12C, Option Port FIFO status
	MBX			Unused1[ 52 ];	// 130-1FF
	SCBLOCK		SCBlock;	// 200: 32 DWORDS Stream Control Block
	MBX			Unused2[ 32 ];	// 280-2FF
	TCBLOCK		TCBlock;	// 300: 64 DWORDS Time Code Block
	MIXBLOCK	MIXBlock;	// 400: 256 DWORDs Mix Control Block
	AESBLOCK	AESBlock;	// 800: 256 DWORDs AES Control Block
	//MBX			RegisterSpare[ (STANDARD_REGISTER_SIZE - REGISTER_SIZE) ];
} LYNXTWOREGISTERS, FAR *PLYNXTWOREGISTERS;

/////////////////////////////////////////////////////////////////////////////
// BAR1 Shared Memory Window
/////////////////////////////////////////////////////////////////////////////
#define WAVE_CIRCULAR_BUFFER_SIZE	0x1000	// in DWORDs (4096) = 16384 bytes

typedef struct
{
#ifdef DOS
	MBX			Buffer[ 10 ];
#else
	MBX			Buffer[ WAVE_CIRCULAR_BUFFER_SIZE ];
#endif
} AUDIOBUFFER, FAR *PAUDIOBUFFER;

typedef struct
{
	AUDIOBUFFER	Record[ NUM_WAVE_RECORD_DEVICES ];
	AUDIOBUFFER	Play[ NUM_WAVE_PLAY_DEVICES ];
} LYNXTWOAUDIOBUFFERS, FAR *PLYNXTWOAUDIOBUFFERS;	// 65536 DWORDs / 262144 bytes long

#define MEMORY_TEST_SIZE	(sizeof(LYNXTWOAUDIOBUFFERS)/sizeof(ULONG))	// in DWORDs

/////////////////////////////////////////////////////////////////////////////
// Interrupt Context
/////////////////////////////////////////////////////////////////////////////
typedef struct
{
	MBX			MISTAT;		// Misc Interrupt Status
	MBX			AISTAT;		// Audio Interrupt Status
} LYNXTWOINTERRUPTCONEXT, FAR *PLYNXTWOINTERRUPTCONTEXT;

#define MAX_PENDING_INTERRUPTS	16	// the most number of interrupts pending at one time

/////////////////////////////////////////////////////////////////////////////
// DMA Buffer List
/////////////////////////////////////////////////////////////////////////////
typedef struct
{
	volatile ULONG	ulHostPtr;		// Must be DWORD aligned
	volatile ULONG	ulControl;		// b0-b21: Host Buffer Length
									// b22: HBUFIE, Host Buffer Transfer Completion Interrupt Enable
} DMABUFFERENTRY, FAR *PDMABUFFERENTRY;

#define DMACONTROL_BUFLEN_MASK	0x3FFFFF
#define DMACONTROL_HBUFIE		kBit22

#define NUM_BUFFERS_PER_STREAM	16	// the number of buffers allowed per stream

typedef struct
{
	DMABUFFERENTRY	Entry[ NUM_BUFFERS_PER_STREAM ];
} DMABUFFERBLOCK, FAR *PDMABUFFERBLOCK;

typedef struct
{
	DMABUFFERBLOCK	Record[ NUM_WAVE_RECORD_DEVICES ];	
	DMABUFFERBLOCK	Play[ NUM_WAVE_PLAY_DEVICES ];	
} DMABUFFERLIST, FAR *PDMABUFFERLIST;

#ifdef  __cplusplus
}
#endif

#endif	// _LYNXTWO_H
