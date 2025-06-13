/*-----------------------------------------------------------------------------
 L22.h

 Modified:

   Calin A. Culianu <calin@rtlab.org>, Sept. 16, 2005

 Copyright: 

   See next comment block.

 Description:

   This header was modified from LynxTWO.h and adapted to Linux.

   LynxTWO.h is distributed with the LynxTWO HAL kit available from Lynx
   Studion Technology, Inc.
 
   Original header comments (and copyright info) from LynxTWO.h follow below.
-----------------------------------------------------------------------------*/


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

#include <linux/types.h>

#ifndef LYNXTWO_H
#define LYNXTWO_H

#define PCIVENDOR_LYNX				0x1621 /* Lynx Studio Technology, Inc. PCI ID */

/*---------------------------------------------------------------------------
  BAR0 REGISTER REGIONS
-----------------------------------------------------------------------------*/
/*  
    NB: these registers are byte offsets relative to PCI Base Address region 0 
    (BAR0 as it is known in PCI-lingo)                                        
    
    Legend: R = Read-only   W = Write-only   RW = Read/write                 
*/
#define L22_PCICTL 0x100    /*  W */
#define L22_DMACTL 0x104    /*  W */
#define L22_MISTAT 0x108    /* R  */
#define L22_AISTAT 0x10c    /* R  */
#define L22_STRMCTL 0x110   /*  W */
#define L22_PLLCTL 0x114    /*  W */
#define L22_IOADDR 0x118    /*  W */
#define L22_IODATA 0x11c    /* RW */
#define L22_OPIOCTL 0x120   /*  W */
#define L22_OPDEVCTL 0x124  /*  W */
#define L22_OPDEVSTAT 0x128 /* R  */
#define L22_OPBUFSTAT 0x12c /* R  */
#define L22_SCBLOCK 0x200   /* RW */
#define L22_TCBLOCK 0x300   /* RW */
#define L22_MIXBLOCK 0x400  /* RW */

#define L22_SCBLOCK_SZ (64*sizeof(int)) /* 64 dwords; 256 bytes */
#define L22_TCBLOCK_SZ (64*sizeof(int)) /* 64 dwords; 256 bytes */
#define L22_MIXBLOCK_SZ (256*sizeof(int)) /* 64 dwords; 256 bytes */

#ifndef BIT0

#define FAR /* FAR has no meaning in Linux... */

#define SET( value, mask )	value |= (mask)
#define CLR( value, mask )	value &= (~mask)

#define BIT0	0x00000001
#define BIT1	0x00000002
#define BIT2	0x00000004
#define BIT3	0x00000008
#define BIT4	0x00000010
#define BIT5	0x00000020
#define BIT6	0x00000040
#define BIT7	0x00000080
#define BIT8	0x00000100
#define BIT9	0x00000200
#define BIT10	0x00000400
#define BIT11	0x00000800
#define BIT12	0x00001000
#define BIT13	0x00002000
#define BIT14	0x00004000
#define BIT15	0x00008000
#define BIT16	0x00010000
#define BIT17	0x00020000
#define BIT18	0x00040000
#define BIT19	0x00080000
#define BIT20	0x00100000
#define BIT21	0x00200000
#define BIT22	0x00400000
#define BIT23	0x00800000
#define BIT24	0x01000000
#define BIT25	0x02000000
#define BIT26	0x04000000
#define BIT27	0x08000000
#define BIT28	0x10000000
#define BIT29	0x20000000
#define BIT30	0x40000000
#define BIT31	0x80000000

#endif

#define PCIDEVICE_LYNXTWO_A			0x0020
#define PCIDEVICE_LYNXTWO_B			0x0021
#define PCIDEVICE_LYNXTWO_C			0x0022
#define PCIDEVICE_LYNX_L22			0x0023
#define PCIDEVICE_LYNX_AES16		0x0024
#define PCIDEVICE_LYNX_AES16SRC		0x0025

/* Each 32-bit register used to talk to the board is called a 'mailbox' 
   in the Lynx Studio Tech. driver lingo.. */
typedef unsigned long	Mbx_t;

typedef unsigned char Byte;

/* /////////////////////////////////////////////////////////////////////////// */
/*  Sample Rate */
/* /////////////////////////////////////////////////////////////////////////// */
#define L22_MIN_SAMPLE_RATE		8000		/*  8kHz */
#define L22_MAX_SAMPLE_RATE		215000		/*  215kHz */

/* /////////////////////////////////////////////////////////////////////////// */
/*  Number of Devices */
/* /////////////////////////////////////////////////////////////////////////// */

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
	WAVE_PLAY0_DEVICE=NUM_WAVE_RECORD_DEVICES,	/*  play devices start after record devices */
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
#define NUM_WAVE_PHYSICAL_OUTPUTS			16	/*  not really associated with play devices */

#define	MIDI_RECORD0_DEVICE					0
#define	MIDI_PLAY0_DEVICE					1

#define NUM_MIDI_RECORD_DEVICES				1
#define NUM_MIDI_PLAY_DEVICES				1
#define NUM_MIDI_DEVICES					(NUM_MIDI_RECORD_DEVICES + NUM_MIDI_PLAY_DEVICES)

/* /////////////////////////////////////////////////////////////////////////// */
/*  Xylinx */
/* /////////////////////////////////////////////////////////////////////////// */

#define NUM_BASE_ADDRESS_REGIONS			2
#define PCI_REGISTERS_INDEX					0	/*  The base address of the PCI/Local configuration registers */
#define AUDIO_DATA_INDEX					1	/*  The base address of the Audio Data Region */

#define BAR0_SIZE							2048	/*  in bytes */
#define AES16_BAR0_SIZE						4096	/*  in bytes */
#define BAR1_SIZE							262144	/*  in bytes */

/* /////////////////////////////////////////////////////////////////////////// */
/*  EEPROM */
/* /////////////////////////////////////////////////////////////////////////// */
/*BOOLEAN	EEPROMGetSerialNumber( PULONG pulSerialNumber, PVOID pL2Registers  );*/

/* /////////////////////////////////////////////////////////////////////////// */
/* /////////////////////////////////////////////////////////////////////////// */
/*  Register Mailboxes */
/* /////////////////////////////////////////////////////////////////////////// */
/* /////////////////////////////////////////////////////////////////////////// */

/* /////////////////////////////////////////////////////////////////////////// */
/*  PCI Bus Control (Write Only) */
/* /////////////////////////////////////////////////////////////////////////// */
#define L22_REG_PCICTL_GIE		BIT0	/*  PCI Interrupt Enable */
#define L22_REG_PCICTL_AIE		BIT1	/*  Audio Interrupt Enable */
#define L22_REG_PCICTL_MIE		BIT2	/*  Misc Interrupt Enable */
#define L22_REG_PCICTL_LED		BIT3	/*  LED */
#define L22_REG_PCICTL_CNFDO	BIT4	/*  FPGA Configuration EEPROM data out */
#define L22_REG_PCICTL_CNFTMS	BIT5	/*  FPGA Configuration EEPROM TMS */
#define L22_REG_PCICTL_CNFCK	BIT6	/*  FPGA Configuration EEPROM clock */
#define L22_REG_PCICTL_CNFEN	BIT7	/*  FPGA Configuration EEPROM write enable */
#define L22_REG_PCICTL_ADCREV	BIT8	/*  Set to 1 for Serial Numbers >= 0317 */

/* /////////////////////////////////////////////////////////////////////////// */
/*  Global DMA Control Register (Write Only) */
/* /////////////////////////////////////////////////////////////////////////// */
#define L22_REG_DMACTL_GDMAEN			BIT0	/*  Global DMA Enable */
#define L22_REG_DMACTL_GDBLADDR_OFFSET	1

/* /////////////////////////////////////////////////////////////////////////// */
/*  Miscellaneous Interrupt Status / Reset Register (Read Only) */
/* /////////////////////////////////////////////////////////////////////////// */
#define L22_REG_MISTAT_LRXAIF	BIT0	/*  LTC Receive Buffer A Interrupt Flag */
#define L22_REG_MISTAT_LRXBIF	BIT1	/*  LTC Receive Buffer B Interrupt Flag */
#define L22_REG_MISTAT_LTXAIF	BIT2	/*  LTC Transmit Buffer A Interrupt Flag */
#define L22_REG_MISTAT_LTXBIF	BIT3	/*  LTC Transmit Buffer B Interrupt Flag */
#define L22_REG_MISTAT_LRXQFIF	BIT4	/*  LTC Receive quarter frame interrupt flag */
#define L22_REG_MISTAT_OPSTATIF	BIT5	/*  Option port status received interrupt flag */
#define L22_REG_MISTAT_RX8420	BIT6	/*  CS8420 Interrupt Flag */
#define L22_REG_MISTAT_CNFDI	BIT7	/*  FPGA configuration EEPROM data in */
#define L22_REG_MISTAT_MIDI1	BIT14	/*  Phantom MIDI port service required... :-) */
#define L22_REG_MISTAT_MIDI2	BIT15	/*  Phantom MIDI port service required... :-) */

/* /////////////////////////////////////////////////////////////////////////// */
/*  Audio Interrupt / Status / Reset Register (Read Only) */
/* /////////////////////////////////////////////////////////////////////////// */
#define L22_REG_AISTAT_REC0AIF	BIT0	/*  Record 0 Circular Buffer Interrupt Flag */
#define L22_REG_AISTAT_REC1AIF	BIT1	/*  Record 1 Circular Buffer Interrupt Flag */
#define L22_REG_AISTAT_REC2AIF	BIT2	/*  Record 2 Circular Buffer Interrupt Flag */
#define L22_REG_AISTAT_REC3AIF	BIT3	/*  Record 3 Circular Buffer Interrupt Flag */
#define L22_REG_AISTAT_REC4AIF	BIT4	/*  Record 4 Circular Buffer Interrupt Flag */
#define L22_REG_AISTAT_REC5AIF	BIT5	/*  Record 5 Circular Buffer Interrupt Flag */
#define L22_REG_AISTAT_REC6AIF	BIT6	/*  Record 6 Circular Buffer Interrupt Flag */
#define L22_REG_AISTAT_REC7AIF	BIT7	/*  Record 7 Circular Buffer Interrupt Flag */

#define L22_REG_AISTAT_PLAY0AIF	BIT8	/*  Play 0 Circular Buffer Interrupt Flag */
#define L22_REG_AISTAT_PLAY1AIF	BIT9	/*  Play 1 Circular Buffer Interrupt Flag */
#define L22_REG_AISTAT_PLAY2AIF	BIT10	/*  Play 2 Circular Buffer Interrupt Flag */
#define L22_REG_AISTAT_PLAY3AIF	BIT11	/*  Play 3 Circular Buffer Interrupt Flag */
#define L22_REG_AISTAT_PLAY4AIF	BIT12	/*  Play 4 Circular Buffer Interrupt Flag */
#define L22_REG_AISTAT_PLAY5AIF	BIT13	/*  Play 5 Circular Buffer Interrupt Flag */
#define L22_REG_AISTAT_PLAY6AIF	BIT14	/*  Play 6 Circular Buffer Interrupt Flag */
#define L22_REG_AISTAT_PLAY7AIF	BIT15	/*  Play 7 Circular Buffer Interrupt Flag */

#define L22_REG_AISTAT_REC0DIF	BIT16	/*  Record 0 DMA Buffer Interrupt Flag */
#define L22_REG_AISTAT_REC1DIF	BIT17	/*  Record 1 DMA Buffer Interrupt Flag */
#define L22_REG_AISTAT_REC2DIF	BIT18	/*  Record 2 DMA Buffer Interrupt Flag */
#define L22_REG_AISTAT_REC3DIF	BIT19	/*  Record 3 DMA Buffer Interrupt Flag */
#define L22_REG_AISTAT_REC4DIF	BIT20	/*  Record 4 DMA Buffer Interrupt Flag */
#define L22_REG_AISTAT_REC5DIF	BIT21	/*  Record 5 DMA Buffer Interrupt Flag */
#define L22_REG_AISTAT_REC6DIF	BIT22	/*  Record 6 DMA Buffer Interrupt Flag */
#define L22_REG_AISTAT_REC7DIF	BIT23	/*  Record 7 DMA Buffer Interrupt Flag */

#define L22_REG_AISTAT_PLAY0DIF	BIT24	/*  Play 0 DMA Buffer Interrupt Flag */
#define L22_REG_AISTAT_PLAY1DIF	BIT25	/*  Play 1 DMA Buffer Interrupt Flag */
#define L22_REG_AISTAT_PLAY2DIF	BIT26	/*  Play 2 DMA Buffer Interrupt Flag */
#define L22_REG_AISTAT_PLAY3DIF	BIT27	/*  Play 3 DMA Buffer Interrupt Flag */
#define L22_REG_AISTAT_PLAY4DIF	BIT28	/*  Play 4 DMA Buffer Interrupt Flag */
#define L22_REG_AISTAT_PLAY5DIF	BIT29	/*  Play 5 DMA Buffer Interrupt Flag */
#define L22_REG_AISTAT_PLAY6DIF	BIT30	/*  Play 6 DMA Buffer Interrupt Flag */
#define L22_REG_AISTAT_PLAY7DIF	BIT31	/*  Play 7 DMA Buffer Interrupt Flag */

/* /////////////////////////////////////////////////////////////////////////// */
/*  Global Stream Control Register (Write Only) */
/* /////////////////////////////////////////////////////////////////////////// */
#define L22_REG_STRMCTL_GLIMIT_MASK		0xFFF
#define L22_REG_STRMCTL_GSYNC			BIT12	/*  Global SyncStart Enable */

#define L22_REG_STRMCTL_RMULTI			BIT16	/*  Multi-channel RECORD device mode enable. In this mode, one multi-channel record device is supported  */
											/*  with up to 16 channels. The Record 0 Stream Control Registers and its associated 4096 on-board buffer  */
											/*  are assigned to the multi-channel device. Channels 0,1,2,3,… of the device are mapped to Record 1 Left,  */
											/*  Record 1 Right, Record 2 Left, Record 2 Right,… record streams. RNUMCHNL must be set to indicate the  */
											/*  number of channels of the device. */

#define L22_REG_STRMCTL_RNUMCHNL_OFFSET	17
#define L22_REG_STRMCTL_RNUMCHNL_MASK	(BIT17 | BIT18 | BIT19)	/*  Indicates number of channels of multi-channel RECORD device according to:  */
																/*  RNUMCHNL = (# channels / 2 ) - 1. The number of channels must be a multiple of 2. */

#define L22_REG_STRMCTL_PMULTI			BIT20	/*  Multi-channel PLAY device mode enable. In this mode, one multi-channel play device is supported with up  */
											/*  to 16 channels. The Play 0 Stream Control Registers and its associated 4096 on-board buffer are assigned  */
											/*  to the multi-channel device. Channels 0,1,2,3,… of the device are mapped to Play 1 Left, Play 1 Right,  */
											/*  Play 2 Left, Play 2 Right,… play streams. Streams not used are placed in idle mode with muted outputs.  */
											/*  PNUMCHNL must be set to indicate the number of channels of the device. */

#define L22_REG_STRMCTL_PNUMCHNL_OFFSET	21
#define L22_REG_STRMCTL_PNUMCHNL_MASK	(BIT21 | BIT22 | BIT23)	/*  Indicates number of channels of multi-channel PLAY device according to: */
																/*  PNUMCHNL = (# channels / 2 ) - 1. The number of channels must be a multiple of 2. */


/* /////////////////////////////////////////////////////////////////////////// */
/*  PLL Control Register (Write Only) */
/* /////////////////////////////////////////////////////////////////////////// */

#define L22_REG_PLLCTL_M_OFFSET			0
#define L22_REG_PLLCTL_BypassM_OFFSET	11
#define L22_REG_PLLCTL_N_OFFSET			12
#define L22_REG_PLLCTL_P_OFFSET			23
#define L22_REG_PLLCTL_CLKSRC_OFFSET	25
#define L22_REG_PLLCTL_WORDALIGN_OFFSET	28
#define L22_REG_PLLCTL_SPEED_OFFSET		29
#define L22_REG_PLLCTL_PLLPDn			31

#define MAKE_PLLCTL_L2AREVNC( M, bpM, N, P, CLK, W, S )	((M) | (bpM << 11) | (N << 12) | (P << 23) | (CLK << 25) | (W << 28) | (S << 29) | BIT31 )
#define MAKE_PLLCTL( M, bpM, N, P, CLK, W, S )		((M) | (bpM << 11) | (N << 12) | (P << 23) | (CLK << 25) | (W << 28) | (S << 29) )

#define SR_P2	0
#define SR_P4	1
#define SR_P8	2
#define SR_P16	3

#define SR_SPEED_1X	0
#define SR_SPEED_2X	1
#define SR_SPEED_4X	2

/*  Values for CONTROL_CLOCKSOURCE */
enum	
{
	MIXVAL_L2_CLKSRC_INTERNAL=0,		/*  Internal Clock */
	MIXVAL_L2_CLKSRC_DIGITAL,			/*  Digital (AESEBU) Input */
	MIXVAL_L2_CLKSRC_EXTERNAL,			/*  External BNC Input */
	MIXVAL_L2_CLKSRC_HEADER,			/*  Internal Header Input */
	MIXVAL_L2_CLKSRC_VIDEO,				/*  Video Input */
	MIXVAL_L2_CLKSRC_LSTREAM_PORT1,		/*  Option Port Clock */
	MIXVAL_L2_CLKSRC_LSTREAM_PORT2,		/*  Option Port Clock */

	MIXVAL_AES16_CLKSRC_INTERNAL,		/*  Internal Clock */
	MIXVAL_AES16_CLKSRC_EXTERNAL,		/*  External BNC Input */
	MIXVAL_AES16_CLKSRC_HEADER,			/*  Internal Header Input */
	MIXVAL_AES16_CLKSRC_LSTREAM,		/*  Option Port Clock */
	MIXVAL_AES16_CLKSRC_DIGITAL_0,		/*  Digital In 0 */
	MIXVAL_AES16_CLKSRC_DIGITAL_1,		/*  Digital In 1 */
	MIXVAL_AES16_CLKSRC_DIGITAL_2,		/*  Digital In 2 */
	MIXVAL_AES16_CLKSRC_DIGITAL_3,		/*  Digital In 3 */
	NUM_CLKSRC							/*  Never used */
};

/*  Values for CONTROL_CLOCKREFERENCE */
enum
{
	MIXVAL_CLKREF_AUTO=0,		/*  Automatic Clock Reference */
	MIXVAL_CLKREF_13p5MHZ,		/*  13.5Mhz Clock Reference */
	MIXVAL_CLKREF_27MHZ,		/*  27Mhz Clock Reference */
	MIXVAL_CLKREF_WORD,			/*  Word Clock */
	MIXVAL_CLKREF_WORD256,		/*  SuperClock */
	NUM_CLKREFS
};

#define L22_REG_PLLCTL_SPEED_SINGLE			0
#define L22_REG_PLLCTL_SPEED_DOUBLE			BIT29
#define L22_REG_PLLCTL_SPEED_QUAD			(BIT29 | BIT30)

/* /////////////////////////////////////////////////////////////////////////// */
/*  I/O Control Block Indirect Address Register (Write Only) */
/* /////////////////////////////////////////////////////////////////////////// */

#define L22_REG_IOADDR_WRITE	(0<<8)
#define L22_REG_IOADDR_READ		BIT8

/*  See Hal8420.h for it's register offsets */

/*  Register Offsets */
enum
{
	kDAC_A_Control = 0x81,		/*  80 - 83, DAC A Control (serially-controlled) */
	kDAC_B_Control = 0x85,		/*  84 - 87, DAC B Control (serially-controlled) */
	kDAC_C_Control = 0x89,		/*  88 - 8B, DAC C Control (serially-controlled) */
	kADC_A_Control = 0x90,		/*  90, ADC A Control (pin-controlled) */
	kADC_B_Control,				/*  91, ADC B Control (pin-controlled) */
	kTrim,						/*  92, Analog Trim Control (pin-controlled) */
	kMisc,						/*  93, Miscellaneous Control (pin-controlled) */
	kOptionIOControl,			/*  94, Option Port I/O Control (no longer defined) */
	kADC_C_Control,				/*  95, ADC C Control (pin-controlled) */
	NUM_IO_REGISTERS
};

/* /////////////////////////////////////////////////////////////////////////// */
/*  I/O Control Block Data Register (R/W) */
/* /////////////////////////////////////////////////////////////////////////// */

/*  DAC Control (0x81, 0x85, 0x89)	Crystal CS4396 */
#define IO_DAC_CNTL_PDN				BIT0		/*  Power Down */
#define IO_DAC_CNTL_MODE_MASK		(0x1F<<1)	/*  Mode Select mask */
#define IO_DAC_CNTL_MODE_1X_EMPOFF	(0x0D<<1)	/*  Single speed, de-emphasis off */
#define IO_DAC_CNTL_MODE_1X_EMP32K	(0x01<<1)	/*  Single speed, 32K de-emphasis */
#define IO_DAC_CNTL_MODE_1X_EMP44K	(0x05<<1)	/*  Single speed, 44.1K de-emphasis */
#define IO_DAC_CNTL_MODE_1X_EMP48K	(0x09<<1)	/*  Single speed, 48K de-emphasis */
#define IO_DAC_CNTL_MODE_2X			(0x1D<<1)	/*  Double speed */
#define IO_DAC_CNTL_MODE_4X			(0x19<<1)	/*  Quad speed */
#define IO_DAC_CNTL_MUTEn			BIT6		/*  Soft Mute - Active Low */
#define IO_DAC_CNTL_CAL				BIT7		/*  Enables DC Offset Calibration */

/*  ADC Control (0x90, 0x91, 0x95)	AKM AK5394 */
#define IO_ADC_CNTL_RSTn			BIT0	/*  Reset - Active Low */
#define IO_ADC_CNTL_ZCAL			BIT1	/*  Zero Calibration Control */
#define IO_ADC_CNTL_DFS_MASK		(3<<2)	/*  Output Sample Rate Select mask */
#define IO_ADC_CNTL_DFS_1X			(0<<2)	/*  Output Sample Rate Select - single speed */
#define IO_ADC_CNTL_DFS_2X			BIT2	/*  Output Sample Rate Select - double speed */
#define IO_ADC_CNTL_DFS_4X			(2<<2)	/*  Output Sample Rate Select - quad speed */
#define IO_ADC_CNTL_HPFE			BIT4	/*  High-pass filter enable */

/*  Trim Control @ byte address 0x92 */
#define IO_TRIM_ABC_AIN12_PLUS4		(0)		/*  All Models */
#define IO_TRIM_ABC_AIN12_MINUS10	BIT0
#define IO_TRIM_ABC_AIN12_MASK		BIT0

#define IO_TRIM_AC_AIN34_PLUS4		(0)		/*  A & C Models */
#define IO_TRIM_AC_AIN34_MINUS10	BIT1
#define IO_TRIM_AC_AIN34_MASK		BIT1

#define IO_TRIM_B_AOUT56_PLUS4		(0)		/*  B Model */
#define IO_TRIM_B_AOUT56_MINUS10	BIT1
#define IO_TRIM_B_AOUT56_MASK		BIT1

#define IO_TRIM_AB_AOUT12_PLUS4		(0)		/*  A & B Models */
#define IO_TRIM_AB_AOUT12_MINUS10	BIT2
#define IO_TRIM_AB_AOUT12_MASK		BIT2

#define IO_TRIM_C_AIN56_PLUS4		(0)		/*  C Model */
#define IO_TRIM_C_AIN56_MINUS10		BIT2
#define IO_TRIM_C_AIN56_MASK		BIT2

#define IO_TRIM_AB_AOUT34_PLUS4		(0)		/*  A & B Models */
#define IO_TRIM_AB_AOUT34_MINUS10	BIT3
#define IO_TRIM_AB_AOUT34_MASK		BIT3

#define IO_TRIM_C_AOUT12_PLUS4		(0)		/*  C Model */
#define IO_TRIM_C_AOUT12_MINUS10	BIT3
#define IO_TRIM_C_AOUT12_MASK		BIT3

/*  Misc Control @ byte address 0x93 */
#define IO_MISC_DACCRSTn		BIT0	/*  DAC C power down, active low (B Model Only) */
#define IO_MISC_DF_AESEBU		(0)
#define IO_MISC_DF_SPDIF		BIT1
#define IO_MISC_DF_MASK			BIT1
#define IO_MISC_DACARSTn		BIT2	/*  DAC A power down, active low */
#define IO_MISC_DACBRSTn		BIT3	/*  DAC B power down, active low */
#define IO_MISC_CS8420RSTn		BIT4	/*  CS8420 reset, active low */
#define IO_MISC_DILRCKDIR		BIT5	/*  Digital In LRCK Direction, 0=output, 1=input */
#define IO_MISC_DIRMCKDIR		BIT6	/*  Digital In RMCK Direction, 0=output, 1=input */
#define IO_MISC_VIDEN			BIT7	/*  Enables routing of SYNC IN to video sync, Rev NC A Model Only */

/*  06/24/2002: New firmware no longer supports this register */
/*  Option Control @ byte address 0x94 */
#define IO_OPT_OPHD1DIR			BIT0		/*  Header Option Port OPHD1 direction, 0=output, 1=input */
#define IO_OPT_OPHD2DIR			BIT1		/*  Header Option Port OPHD2 direction, 0=output, 1=input */
#define IO_OPT_OPHDINSEL		BIT2		/*  Header Option Port input data select, 0 = OPHD1, 1=OPHD2 */
#define IO_OPT_OPHSIG			BIT3		/*  Header Option Port OPHSIG state */
#define IO_OPT_OPHSIGDIR		BIT4		/*  Header Option Port OPHSIG Direction, 0=output, 1=input */
#define IO_OPT_OPBFCKDIR		BIT5		/*  Bracket Option Port Frame Clock Direction, 0=output, 1=input */
#define IO_OPT_OPHFCKDIR		BIT6		/*  Header Option Port Frame Clock Direction, 0=output, 1=input */
#define IO_OPT_OPHBLKSEL		BIT7		/*  Header Option Port Data Source, 0=PMIX 0-7, 1=PMIX 8-15 */

/* /////////////////////////////////////////////////////////////////////////// */
/*  Stream Control Register */
/* /////////////////////////////////////////////////////////////////////////// */
#define L22_REG_STREAMCTL_PCPTR_OFFSET		0	/*  b0-11 Host Circular Buffer Pointer */
#define L22_REG_STREAMCTL_MODE_OFFSET		12	/*  b12-13: Mode Control */
#define L22_REG_STREAMCTL_FMT_OFFSET		14	/*  b14-15: Format Control */
#define L22_REG_STREAMCTL_CHNUM_OFFSET		16	/*  b16 0=MONO, 1=STEREO */

#define L22_REG_STREAMCTL_PCPTR_MASK		0xFFF

#define L22_REG_STREAMCTL_MODE_MASK			(BIT12 | BIT13)
#define L22_REG_STREAMCTL_MODE_IDLE			0
#define L22_REG_STREAMCTL_MODE_RUN			BIT12
#define L22_REG_STREAMCTL_MODE_UNDEFINED	BIT13
#define L22_REG_STREAMCTL_MODE_SYNCREADY	(BIT12 | BIT13)

#define L22_REG_STREAMCTL_FMT_MASK			(BIT14 | BIT15)
#define L22_REG_STREAMCTL_FMT_PCM8			0
#define L22_REG_STREAMCTL_FMT_PCM16			BIT14
#define L22_REG_STREAMCTL_FMT_PCM24			BIT15
#define L22_REG_STREAMCTL_FMT_PCM32			(BIT14 | BIT15)

#define L22_REG_STREAMCTL_CHNUM_MONO		0
#define L22_REG_STREAMCTL_CHNUM_STEREO		BIT16

#define L22_REG_STREAMCTL_LIMIE				BIT17	/*  Limit Interrupt Enable */
#define L22_REG_STREAMCTL_OVERIE			BIT18	/*  Overrun Interrupt Enable */

#define L22_REG_STREAMCTL_XFERDONE			BIT19	/*  Transfer Complete */

#define L22_REG_STREAMCTL_DMAEN				BIT20	/*  DMA Enable */
#define L22_REG_STREAMCTL_DMAHST			BIT21	/*  DMA Host Start */

#define L22_REG_STREAMCTL_DMABINX_OFFSET	22	/*  b22-25: DMABINX */
#define L22_REG_STREAMCTL_DMABINX_MASK		(BIT22 | BIT23 | BIT24 | BIT25)

#define L22_REG_STREAMCTL_DMAMODE			BIT26	/*  DMA State (0=IDLE, 1=ENABLED) */
#define L22_REG_STREAMCTL_DMASTARV			BIT27	/*  DMA Starvation Mode */

#define L22_REG_STREAMCTL_DMASINGLE			BIT28	/*  DMA Single */

#define L22_REG_STREAMCTL_DMADUALMONO		BIT29	/*  Only valid if FMT_PCM32 & CHNUM_STEREO are set */

/* /////////////////////////////////////////////////////////////////////////// */
/*  Stream Status Register */
/* /////////////////////////////////////////////////////////////////////////// */
#define L22_REG_STREAMSTAT_L2PTR_OFFSET		0	/*  b0-11 Hardware Circular Buffer Pointer */
#define L22_REG_STREAMSTAT_BYTECNT_OFFSET	12	/*  b12-13 */
#define L22_REG_STREAMSTAT_MODE_OFFSET		14	/*  b14 0=IDLE, 1=RUN */
#define L22_REG_STREAMSTAT_LIMHIT_OFFSET	15	/*  b15 Circular Buffer Limit Hit Flag */
#define L22_REG_STREAMSTAT_OVER_OFFSET		16	/*  b16 Circular Buffer Overrun Flag */

#define L22_REG_STREAMSTAT_L2PTR_MASK		0xFFF
#define L22_REG_STREAMSTAT_RUN_MODE			BIT14
#define L22_REG_STREAMSTAT_LIMHIT			BIT15
#define L22_REG_STREAMSTAT_OVER				BIT16

/* /////////////////////////////////////////////////////////////////////////// */
/*  Stream Control Block */
/* /////////////////////////////////////////////////////////////////////////// */
typedef struct 
{
	Mbx_t			RecordControl[ NUM_WAVE_RECORD_DEVICES ];
	Mbx_t			PlayControl[ NUM_WAVE_PLAY_DEVICES ];
	Mbx_t			RecordStatus[ NUM_WAVE_RECORD_DEVICES ];
	Mbx_t			PlayStatus[ NUM_WAVE_PLAY_DEVICES ];
} SCBLOCK, FAR *PSCBLOCK;

/* /////////////////////////////////////////////////////////////////////////// */
/*  Time Code Buffers */
/* /////////////////////////////////////////////////////////////////////////// */
#define TCBUFFER_FRAME_UNITS_MASK	0x0000000F
#define TCBUFFER_FRAME_TENS_MASK	0x00000300
#define TCBUFFER_SECONDS_UNITS_MASK	0x0000000F
#define TCBUFFER_SECONDS_TENS_MASK	0x00000700
#define TCBUFFER_MINUTES_UNITS_MASK	0x0000000F
#define TCBUFFER_MINUTES_TENS_MASK	0x00000700
#define TCBUFFER_HOURS_UNITS_MASK	0x0000000F
#define TCBUFFER_HOURS_TENS_MASK	0x00000300
#define TCBUFFER_TENS_OFFSET		8
#define TCBUFFER_DROPFRAME_MASK		BIT10

/* /////////////////////////////////////////////////////////////////////////// */
/*  Time Code Block */
/*  64 DWORDs */
/* /////////////////////////////////////////////////////////////////////////// */
#define TCBUFFER_SIZE	4	/*  in DWORDs */
typedef struct 
{
	Mbx_t			LTCRxBufA[ TCBUFFER_SIZE ];
	Mbx_t			LTCRxBufB[ TCBUFFER_SIZE ];
	Mbx_t			LTCTxBufA[ TCBUFFER_SIZE ];
	Mbx_t			LTCTxBufB[ TCBUFFER_SIZE ];
	Mbx_t			VITCRxBuf1A[ TCBUFFER_SIZE ];
	Mbx_t			VITCRxBuf1B[ TCBUFFER_SIZE ];
	Mbx_t			VITCRxBuf2A[ TCBUFFER_SIZE ];
	Mbx_t			VITCRxBuf2B[ TCBUFFER_SIZE ];
	Mbx_t			LTCControl;
	Mbx_t			VITCControl;
	Mbx_t			TCStatus;
	Mbx_t			LTCRxFrameRate;
	Mbx_t			Unused[ 28 ];
} TCBLOCK, FAR *PTCBLOCK;

/* /////////////////////////////////////////////////////////////////////////// */
/*  LTC Control Register */
/* /////////////////////////////////////////////////////////////////////////// */

#define L22_REG_LTCCONTROL_LRXEN				BIT0
#define L22_REG_LTCCONTROL_LRXIE				BIT1
#define L22_REG_LTCCONTROL_LTXEN				BIT2
#define L22_REG_LTCCONTROL_LTXIE				BIT3
#define L22_REG_LTCCONTROL_LTXCLK				BIT4
#define L22_REG_LTCCONTROL_LTXSYNC_FREERUNNING	(0)
#define L22_REG_LTCCONTROL_LTXSYNC_VIDEOLINE5	BIT5
#define L22_REG_LTCCONTROL_LTXSYNC_LTCRX		(2<<5)
#define L22_REG_LTCCONTROL_LTXSYNC_REGWRITE		(3<<5)
#define L22_REG_LTCCONTROL_LTXSYNC_MASK			(3<<5)
#define L22_REG_LTCCONTROL_LTXRATE_24FPS		(0)
#define L22_REG_LTCCONTROL_LTXRATE_25FPS		BIT7
#define L22_REG_LTCCONTROL_LTXRATE_2997FPS		BIT8
#define L22_REG_LTCCONTROL_LTXRATE_30FPS		(BIT7 | BIT8)
#define L22_REG_LTCCONTROL_LTXRATE_MASK			(BIT7 | BIT8)
#define L22_REG_LTCCONTROL_LRXQFIE				BIT9	/*  LTC Receive quarter frame interrupt enable */

/* /////////////////////////////////////////////////////////////////////////// */
/*  Time Code Status Register */
/* /////////////////////////////////////////////////////////////////////////// */

#define TCSTATUS_LRXLOCK			BIT0
#define TCSTATUS_LRXDIR_BACKWARD	(0<<1)
#define TCSTATUS_LRXDIR_FORWARD		BIT1
#define TCSTATUS_LRXDIR_MASK		BIT1

/* /////////////////////////////////////////////////////////////////////////// */
/*  LTC Receive Frame Rate */
/* /////////////////////////////////////////////////////////////////////////// */
#define LTCRXRATE_MASK				0x0000FFFF

/* /////////////////////////////////////////////////////////////////////////// */
/*  Frequency Counter Block (Read Only) */
/* /////////////////////////////////////////////////////////////////////////// */
typedef struct
{
	Mbx_t			Count;
	Mbx_t			Scale;
} FREQCOUNTER, FAR *PFREQCOUNTER;

enum
{
	L2_FREQCOUNTER_LRCLOCK=0,	/*  Left/Right Clock */
	L2_FREQCOUNTER_DIGITALIN,	/*  Digital Input */
	L2_FREQCOUNTER_EXTERNAL,	/*  External Input */
	L2_FREQCOUNTER_HEADER,		/*  Header Input */
	L2_FREQCOUNTER_VIDEO,		/*  Video Input, Should be either 15.734kHz NTSC or 15.625 kHz PAL */
	L2_FREQCOUNTER_LSTREAM1,	/*  Option Port 1 Input */
	L2_FREQCOUNTER_LSTREAM2,	/*  Option Port 2 Input */
	L2_FREQCOUNTER_PCI,			/*  PCI Clock */
	L2_FREQCOUNTER_NUMENTIRES
};

enum
{
	AES16_FREQCOUNTER_LRCLOCK=0,/*  Left/Right Clock */
	AES16_FREQCOUNTER_EXTERNAL,	/*  External Input */
	AES16_FREQCOUNTER_HEADER,	/*  Header Input */
	AES16_FREQCOUNTER_LSTREAM,	/*  Option Port 2 Input */
	AES16_FREQCOUNTER_PCI,		/*  PCI Clock */
	AES16_FREQCOUNTER_DI1,		/*  Digital Input 1 */
	AES16_FREQCOUNTER_DI2,		/*  Digital Input 2 */
	AES16_FREQCOUNTER_DI3,		/*  Digital Input 3 */
	AES16_FREQCOUNTER_DI4,		/*  Digital Input 4 */
	AES16_FREQCOUNTER_DI5,		/*  Digital Input 5 */
	AES16_FREQCOUNTER_DI6,		/*  Digital Input 6 */
	AES16_FREQCOUNTER_DI7,		/*  Digital Input 7 */
	AES16_FREQCOUNTER_DI8,		/*  Digital Input 8 */
	AES16_FREQCOUNTER_NUMENTIRES
};

#define L22_REG_FCBLOCK_COUNT_MASK	0xFFFF
#define L22_REG_FCBLOCK_SCALE_MASK	0xF
#define L22_REG_FCBLOCK_NTSCPALn	BIT4

/* /////////////////////////////////////////////////////////////////////////// */
/*  Product Data Block */
/*  32 DWORDs in length */
/* /////////////////////////////////////////////////////////////////////////// */
typedef struct 
{
	Mbx_t		LY;
	Mbx_t		NX;
	Mbx_t		DeviceID;		/*  Device ID */
	Mbx_t		PCBRev;			/*  PCB Revision */
	Mbx_t		FWRevID;		/*  Firmware Revision & ID */
	Mbx_t		FWDate;			/*  Firmware Date */
	Mbx_t		MinSWAPIRev;	/*  Minimum Software API Revision Required */
	Mbx_t		Spare[ 25 ];
} PDBLOCK, FAR *PPDBLOCK;

/*  Serial Number is encoded as: */
#define L2SN_GET_UNITID( SN )	(SN & 0xFFF)
#define L2SN_GET_WEEK( SN )		((SN >> 12) & 0xFF)
#define L2SN_GET_YEAR( SN )		((SN >> 20) & 0xF)
#define L2SN_GET_MODEL( SN )	((SN >> 24) & 0xFF)

/* /////////////////////////////////////////////////////////////////////////// */
/*  CS8420 Control/Status Block */
/* /////////////////////////////////////////////////////////////////////////// */

/*  See Hal8420.h for a complete description of these fields */

typedef struct
{
	/*  8420 Control Register Map */
	Byte	Unknown0;				/*  0 */
	Byte	Control1;				/*  1 */
	Byte	Control2;				/*  2 */
	Byte	DataFlowControl;		/*  3 */
	Byte	ClockSourceControl;		/*  4 */
	Byte	SerialInputFormat;		/*  5 */
	Byte	SerialOutputFormat;		/*  6 */
	Byte	Interrupt1Status;		/*  7 */
	Byte	Interrupt2Status;		/*  8 */
	Byte	Interrupt1Mask;			/*  9 */
	Byte	Interrupt1ModeMSB;		/*  10 */
	Byte	Interrupt1ModeLSB;		/*  11 */
	Byte	Interrupt2Mask;			/*  12 */
	Byte	Interrupt2ModeMSB;		/*  13 */
	Byte	Interrupt2ModeLSB;		/*  14 */
	Byte	ReceiverCSData;			/*  15 */
	Byte	ReceiverErrors;			/*  16 */
	Byte	ReceiverErrorMask;		/*  17 */
	Byte	CSDataBufferControl;	/*  18 */
	Byte	UDataBufferControl;		/*  19 */
	Byte	QSubCodeData[ 10 ];		/*  20-29 */
	Byte	SampleRateRatio;		/*  30 */
	Byte	Unknown1;				/*  31 */
	Byte	CorUDataBuffer[ 24 ];	/*  32-55 */
	Byte	Unknown2[ 71 ];			/*  56-126 */
	Byte	IDandVersion;			/*  127 */
} CS8420BLOCK, FAR *PCS8420BLOCK;

/* /////////////////////////////////////////////////////////////////////////// */
/*  I/O Control Block (Accessed indirectly via IOADDR and IODATA) */
/* /////////////////////////////////////////////////////////////////////////// */
typedef struct 
{
	CS8420BLOCK	CS8420Block;		/*  128 bytes */
	Mbx_t			DACAControl[ 4 ];	/*  0x80 - 0x83 */
	Mbx_t			DACBControl[ 4 ];	/*  0x84 - 0x87 */
	Mbx_t			ADCAControl;		/*  0x90 */
	Mbx_t			ADCBControl;		/*  0x91 */
	Mbx_t			TrimControl;		/*  0x92 */
	Mbx_t			MiscControl;		/*  0x93 */
	Mbx_t			OptionControl;		/*  0x94 */
} IOBLOCK, FAR *PIOBLOCK;

/* /////////////////////////////////////////////////////////////////////////// */
/*  OPIOCTL: Option Port (LStream) I/O Control Register (write only) */
/* /////////////////////////////////////////////////////////////////////////// */

#define L22_REG_OPIOCTL_OPHD1DIR		BIT0	/*  Header option port OPHD1 direction, 0 = output, 1 = input (default to output)	W */
#define L22_REG_OPIOCTL_OPHD2DIR		BIT1	/*  Header option port OPHD2 direction, 0 = output, 1 = input (default to input)		W */
#define L22_REG_OPIOCTL_OPHDINSEL		BIT2	/*  Header option port input data select, 0 = OPHD1, 1 = OPHD2	W */
#define L22_REG_OPIOCTL_OPBBLKSEL		BIT3	/*  Selects the data sources for bracket option port output */
											/*  0 = PMIX 8 -15 routed to bracket port channels 0 - 7 */
											/* 	   PMIX 0 - 7 routed to bracket port channels 8 - 15 */
											/*  1 = PMIX 0 - 7 routed to bracket port channels 0 - 7 */
											/* 	   PMIX 8 - 15 routed to bracket port channels 8 - 15	W */
#define L22_REG_OPIOCTL_OPHBCKENn		BIT4	/*  Header option port bit clock output enable, 0 = enabled, 1 = hi-z	W */
#define L22_REG_OPIOCTL_OPBFCKDIR		BIT5	/*  Bracket option port frame clock direction, 0 = output, 1 = input	W */
#define L22_REG_OPIOCTL_OPHFCKDIR		BIT6	/*  Header option port frame clock direction, 0 = output, 1 = input	W */
#define L22_REG_OPIOCTL_OPHBLKSEL		BIT7	/*  Selects the data sources for header option port output */
											/*  0 = PMIX 8 -15 routed to header port channels 0 - 7 */
											/* 	   PMIX 0 - 7 routed to header port channels 8 - 15 */
											/*  1 = PMIX 0 - 7 routed to header port channels 0 - 7 */
											/* 	   PMIX 8 - 15 routed to header port channels 8 - 15	W */
#define L22_REG_OPIOCTL_OPHDUAL			BIT8	/*  Dual Internal Mode */
#define L22_REG_OPIOCTL_OPHSIGDIR		BIT9	/*  Header option port OPHSIG direction, 0 = output, 1 = input	W */
#define L22_REG_OPIOCTL_OPSTATIE		BIT10	/*  Option port status interrupt enable. Enables interrupt generation  */
											/*  when status data from either option port is available in status FIFO.  */
											/*  An interrupt is generated when the FIFO becomes not empty or full.	 */
#define L22_REG_OPIOCTL_OPCTLRST		BIT11	/*  Option port device control FIFO reset. Resets FIFO pointers to an  */
											/*  empty state. Writing a "1" to this bit position generates a single  */
											/*  reset pulse. Clear is not required.	 */
#define L22_REG_OPIOCTL_OPSTATRST		BIT12	/*  Option port device status FIFO reset. Resets FIFO pointers to an  */
											/*  empty state. Writing a "1" to this bit position generates a single  */
											/*  reset pulse. Clear is not required.	 */

enum {
	MIXVAL_LSTREAM_OUTSEL_9TO16_1TO8=0,
	MIXVAL_LSTREAM_OUTSEL_1TO8_9TO16
};

/* /////////////////////////////////////////////////////////////////////////// */
/*  OPDEVCTL: Option Port (LStream) Device Control Register (write only) */
/* /////////////////////////////////////////////////////////////////////////// */
#define L22_REG_OPDEVCTL_DATA_OFFSET	0		/*  Bit 0 */
#define L22_REG_OPDEVCTL_ADDR_OFFSET	8		/*  Bit 8 */
#define L22_REG_OPDEVCTL_PORT_OFFSET	15		/*  Bit 15 */

#define L22_REG_OPDEVCTL_DATA_MASK		0x00FF	/*  7:0	DATA[7:0]: Device control data */
#define L22_REG_OPDEVCTL_ADDR_MASK		0x7F00	/*  14:8	ADDR[6:0]: Device control register address */
#define L22_REG_OPDEVCTL_PORT			BIT15	/*  15	PORT: Indicates target option port.  */
											/*  0 = bracket port (LStream 1) */
											/*  1 = header option port (LStream 2) */

/* /////////////////////////////////////////////////////////////////////////// */
/*  OPDEVSTAT: Option Port (LStream) Device Status Register (read only) */
/* /////////////////////////////////////////////////////////////////////////// */
#define L22_REG_OPDEVSTAT_DATA_OFFSET	0		/*  Bit 0 */
#define L22_REG_OPDEVSTAT_ADDR_OFFSET	8		/*  Bit 8 */
#define L22_REG_OPDEVSTAT_PORT_OFFSET	15		/*  Bit 15 */

#define L22_REG_OPDEVSTAT_DATA_MASK		0x00FF	/*  7:0	DATA[7:0]: Device status data */
#define L22_REG_OPDEVSTAT_ADDR_MASK		0x7F00	/*  14:8	ADDR[6:0]: Device status register address */
#define L22_REG_OPDEVSTAT_PORT			BIT15	/*  15	PORT: Indicates target option port. 0 = bracket port (LStream 1), 1 = header option port (LStream 2) */
#define L22_REG_OPDEVSTAT_STAT_EMPTY	BIT16	/*  16	STAT_EMPTY: Option port status FIFO empty flag */
#define L22_REG_OPDEVSTAT_STAT_FULL		BIT17	/*  17	STAT_FULL: Option port status FIFO full flag */
#define L22_REG_OPDEVSTAT_CTL_EMPTY		BIT18	/*  18	CTL_EMPTY: Option port control FIFO empty flag */
#define L22_REG_OPDEVSTAT_CTL_FULL		BIT19	/*  19	CTL_FULL: Option port control FIFO full flag */
#define L22_REG_OPDEVSTAT_LOCKED0		BIT20	/*  20	LOCKED0: Option port 0 (bracket) input locked flag */
#define L22_REG_OPDEVSTAT_LOCKED1		BIT21	/*  21	LOCKED1: Option port 1 (header) input locked flag */


/* /////////////////////////////////////////////////////////////////////////// */
/*  OPBUFSTAT: Option Port (LStream) Buffer Status Register (read only) */
/* /////////////////////////////////////////////////////////////////////////// */

#define L22_REG_OPBUFSTAT_STAT_EMPTY	BIT16	/*  16	STAT_EMPTY: Option port status FIFO empty flag */
#define L22_REG_OPBUFSTAT_STAT_FULL		BIT17	/*  17	STAT_FULL: Option port status FIFO full flag */
#define L22_REG_OPBUFSTAT_CTL_EMPTY		BIT18	/*  18	CTL_EMPTY: Option port control FIFO empty flag */
#define L22_REG_OPBUFSTAT_CTL_FULL		BIT19	/*  19	CTL_FULL: Option port control FIFO full flag */
#define L22_REG_OPBUFSTAT_LOCKED0		BIT20	/*  20	LOCKED0: Option port 0 (bracket) input locked flag */
#define L22_REG_OPBUFSTAT_LOCKED1		BIT21	/*  21	LOCKED1: Option port 1 (header) input locked flag */
#define L22_REG_OPBUFSTAT_LRCLOCK		BIT22	/*  22	LRCLOCK */

/* /////////////////////////////////////////////////////////////////////////// */
/*  Record Mix Control Register */
/* /////////////////////////////////////////////////////////////////////////// */

#define L22_REG_RMIX_INSRC_OFFSET		0
#define L22_REG_RMIX_INSRC_MASK			0x3F

#define L22_REG_RMIX_DITHERTYPE_NONE					(0)
#define L22_REG_RMIX_DITHERTYPE_TRIANGULAR_PDF			BIT6
#define L22_REG_RMIX_DITHERTYPE_TRIANGULAR_PDF_HI_PASS	BIT7
#define L22_REG_RMIX_DITHERTYPE_RECTANGULAR_PDF			(BIT6 | BIT7)
#define L22_REG_RMIX_DITHERTYPE_MASK					(BIT6 | BIT7)

#define L22_REG_RMIX_DITHERDEPTH_8BITS					(0)
#define L22_REG_RMIX_DITHERDEPTH_16BITS					BIT8
#define L22_REG_RMIX_DITHERDEPTH_20BITS					BIT9
#define L22_REG_RMIX_DITHERDEPTH_24BITS					(BIT8 | BIT9)
#define L22_REG_RMIX_DITHERDEPTH_MASK					(BIT8 | BIT9)

#define L22_REG_RMIX_DITHER				BIT10
#define L22_REG_RMIX_MUTE				BIT11

/* /////////////////////////////////////////////////////////////////////////// */
/*  Play Mix Input Control Register */
/* /////////////////////////////////////////////////////////////////////////// */

#define L22_REG_PMIX_VOLUME_OFFSET		0
#define L22_REG_PMIX_VOLBYPASS_OFFSET	16
#define L22_REG_PMIX_PLAYSOURCE_OFFSET	17
#define L22_REG_PMIX_DITHER_OFFSET		22
#define L22_REG_PMIX_OPCTL_OFFSET		24

#define L22_REG_PMIX_VOLUME_MASK		0x0000FFFF
#define L22_REG_PMIX_VOLBYPASS			BIT16
#define L22_REG_PMIX_PLAYSOURCE_MASK	(0x1F << L22_REG_PMIX_PLAYSOURCE_OFFSET)	/*  5 bits */
#define L22_REG_PMIX_DITHER				BIT22
#define L22_REG_PMIX_OPCTL_MASK			0xFF000000

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
	Mbx_t			PMixControl[ NUM_PMIX_LINES ];
} PLAYMIXCTL, FAR *PPLAYMIXCTL;	/*  4 DWORDs */

/* /////////////////////////////////////////////////////////////////////////// */
/*  Mixer Control Block */
/* /////////////////////////////////////////////////////////////////////////// */

#define L22_REG_RMIXSTAT_LEVEL_OFFSET	0

#define L22_REG_RMIXSTAT_LEVEL_MASK		0x000FFFFF	/*  20 bits */
#define L22_REG_RMIXSTAT_LEVEL_RESET	BIT20

#define L22_REG_PMIXSTAT_LEVEL_MASK		0x000FFFFF	/*  20 bits */
#define L22_REG_PMIXSTAT_LEVEL_RESET	BIT20
#define L22_REG_PMIXSTAT_OVERLOAD		BIT21
#define L22_REG_PMIXSTAT_OVERLOAD_RESET	BIT22

typedef struct 
{
	Mbx_t			RMixControl[ NUM_WAVE_PHYSICAL_INPUTS ];	/*  0x0400	16 DWORDs */
	Mbx_t			Reserved1[ 48 ];							/*  0x0440	48 DWORDs */
	PLAYMIXCTL	PMixControl[ NUM_WAVE_PHYSICAL_OUTPUTS ];	/*  0x0500	64 DWORDs */
	Mbx_t			RMixStatus[ NUM_WAVE_PHYSICAL_INPUTS ];		/*  0x0600	16 DWORDs */
	Mbx_t			PMixStatus[ NUM_WAVE_PHYSICAL_OUTPUTS ];	/*  0x0640	16 DWORDs */
	Mbx_t			Reserved2[ 96 ];							/*  0x0680	96 DWORDs */
} MIXBLOCK, FAR *PMIXBLOCK;	/*  256 DWORDs */

/* /////////////////////////////////////////////////////////////////////////// */
/*  AES AK4114 Control Registers (AES16 Only) */
/* /////////////////////////////////////////////////////////////////////////// */

typedef struct 
{
	Mbx_t		TXCS10;		/*  Transmit channel status byte 0 & 1 */
	Mbx_t		TXCS32;		/*  Transmit channel status byte 2 & 3 */
	Mbx_t		TXCS54;		/*  Transmit channel status byte 4 & 5 */
	Mbx_t		TXCS76;		/*  Transmit channel status byte 6 & 7 */
	Mbx_t		TXCS98;		/*  Transmit channel status byte 8 & 9 */
	Mbx_t		TXCS2322;	/*  Transmit channel status byte 22 & 23 */
	Mbx_t		CLKPWR;		/*  Clock and power down control */
	Mbx_t		FMTDEMP;	/*  Format and de-emphasis control */
} AK4114CTL, FAR *PAK4114CTL;	/*  8 DWORDs */

/* /////////////////////////////////////////////////////////////////////////// */
/*  AES AK4114 Status Registers (AES16 Only) */
/* /////////////////////////////////////////////////////////////////////////// */

typedef struct 
{						/*  Bits 15:8			Bits 7:0 */
	Mbx_t		RXSTAT10;	/*  Receiver Status 1	Receiver Status 0 */
	Mbx_t		RXCS10;		/*  RX CS byte 1			RX CS byte 0 */
	Mbx_t		RXCS32;		/*  RX CS byte 3			RX CS byte 2 */
	Mbx_t		RXCS4;		/*  unused				RX CS byte 4 */
	Mbx_t		PREAMPC10;	/*  Non-PCM Preamble Pc byte 1	Non-PCM Preamble Pc byte 0 */
	Mbx_t		PREAMPD10;	/*  Non-PCM Preamble Pd byte 1	PREAMPD0: Non-PCM Preamble Pd byte 0 */
	Mbx_t		Reserved[ 2 ];
} AK4114STAT, FAR *PAK4114STAT;	/*  8 DWORDs */

/* /////////////////////////////////////////////////////////////////////////// */
/*  AES Control Block (AES16 Only) */
/* /////////////////////////////////////////////////////////////////////////// */

typedef struct 
{

	AK4114CTL	AK4114Control[ 8 ];		/*  64 DWORDs */
	Mbx_t			Reserved1[ 64 ];		/*  64 DWORDs */
	AK4114STAT	AK4114Status[ 8 ];		/*  64 DWORDs */
	Mbx_t			Reserved2[ 64 ];		/*  64 DWORDs */
} AESBLOCK, FAR *PAESBLOCK;	/*  256 DWORDs */

/* /////////////////////////////////////////////////////////////////////////// */
/*  BAR0 Shared Memory Window */
/* /////////////////////////////////////////////////////////////////////////// */
typedef struct 
{
	PDBLOCK		PDBlock;	/*  32 DWORDS */
	FREQCOUNTER	FRBlock[ 16 ];	/*  32 DWORDS Frequency Counter Block */
	Mbx_t			PCICTL;		/*  100, PCI Bus Control */
	Mbx_t			DMACTL;		/*  104, Global DMA Control */
	Mbx_t			MISTAT;		/*  108, Misc Interrupt Status / Reset */
	Mbx_t			AISTAT;		/*  10C, Audio Interrupt Status / Reset */
	Mbx_t			STRMCTL;	/*  110, Global Stream Control */
	Mbx_t			PLLCTL;		/*  114, PLL Control */
	union 
	{
		Mbx_t		IOADDR;		/*  118, IOBLOCK Indirect Address */
		Mbx_t		VCXOCTL;	/*  118, VCXO registers, debug only */
	};
	union 
	{
		Mbx_t		IODATA;		/*  11C, IOBLOCK Data */
		Mbx_t		MISCTL;		/*  11C, Misc Control Register */
	};
	Mbx_t			OPIOCTL;	/*  120, Option Port I/O control */
	Mbx_t			OPDEVCTL;	/*  124,	Option Port device control */
	Mbx_t			OPDEVSTAT;	/*  128, Option Port device status */
	Mbx_t			OPBUFSTAT;	/*  12C, Option Port FIFO status */
	Mbx_t			Unused1[ 52 ];	/*  130-1FF */
	SCBLOCK		SCBlock;	/*  200: 32 DWORDS Stream Control Block */
	Mbx_t			Unused2[ 32 ];	/*  280-2FF */
	TCBLOCK		TCBlock;	/*  300: 64 DWORDS Time Code Block */
	MIXBLOCK	MIXBlock;	/*  400: 256 DWORDs Mix Control Block */
	AESBLOCK	AESBlock;	/*  800: 256 DWORDs AES Control Block */
	/* Mbx_t			RegisterSpare[ (STANDARD_REGISTER_SIZE - REGISTER_SIZE) ]; */
} LYNXTWOREGISTERS, FAR *PLYNXTWOREGISTERS;

/* /////////////////////////////////////////////////////////////////////////// */
/*  BAR1 Shared Memory Window */
/* /////////////////////////////////////////////////////////////////////////// */
#define WAVE_CIRCULAR_BUFFER_SIZE	0x1000	/*  in DWORDs (4096) = 16384 bytes */

typedef struct
{
#ifdef DOS
	Mbx_t			Buffer[ 10 ];
#else
	Mbx_t			Buffer[ WAVE_CIRCULAR_BUFFER_SIZE ];
#endif
} AUDIOBUFFER, FAR *PAUDIOBUFFER;

typedef struct
{
	AUDIOBUFFER	Record[ NUM_WAVE_RECORD_DEVICES ];
	AUDIOBUFFER	Play[ NUM_WAVE_PLAY_DEVICES ];
} LYNXTWOAUDIOBUFFERS, FAR *PLYNXTWOAUDIOBUFFERS;	/*  65536 DWORDs / 262144 bytes long */

#define MEMORY_TEST_SIZE	(sizeof(LYNXTWOAUDIOBUFFERS)/sizeof(ulong))	/*  in DWORDs */

/* /////////////////////////////////////////////////////////////////////////// */
/*  Interrupt Context */
/* /////////////////////////////////////////////////////////////////////////// */
typedef struct
{
	Mbx_t			MISTAT;		/*  Misc Interrupt Status */
	Mbx_t			AISTAT;		/*  Audio Interrupt Status */
} LYNXTWOINTERRUPTCONEXT, FAR *PLYNXTWOINTERRUPTCONTEXT;

#define MAX_PENDING_INTERRUPTS	16	/*  the most number of interrupts pending at one time */

/* /////////////////////////////////////////////////////////////////////////// */
/*  DMA Buffer List */
/* /////////////////////////////////////////////////////////////////////////// */
struct L22DMABufferEntry
{
	volatile ulong	hostPtr;		/*  Must be DWORD aligned */
	volatile ulong	control;		/*  b0-b21: Host Buffer Length */
									/*  b22: HBUFIE, Host Buffer Transfer Completion Interrupt Enable */
};

#define DMACONTROL_BUFLEN_MASK	0x3FFFFF
#define DMACONTROL_HBUFIE		BIT22

#define NUM_BUFFERS_PER_STREAM	16	/*  the number of buffers allowed per stream */

struct L22DMABufferBlock
{
	struct L22DMABufferEntry	entry[ NUM_BUFFERS_PER_STREAM ];
};

struct L22DMABufferList
{
	struct L22DMABufferBlock	record[ NUM_WAVE_RECORD_DEVICES ];	
	struct L22DMABufferBlock	play[ NUM_WAVE_PLAY_DEVICES ];	
};

#endif	/*  LYNXTWO_H */
