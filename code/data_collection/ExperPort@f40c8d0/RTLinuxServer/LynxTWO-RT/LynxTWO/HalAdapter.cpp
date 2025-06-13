/****************************************************************************
 HalAdapter.cpp

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
 May 16 03 DAH	Added m_bAutoRecalibrate, and broke out the HPF for the OEM B9 cards.
 May 15 03 DAH	Added call to EEPROMGetSerialNumber and special case code for
				specific serial numbers.
****************************************************************************/

#ifndef LINUX
#include <StdAfx.h>
#endif

#include "HalAdapter.h"

//#ifdef NT
#define INTERRUPT_TIMING
//#endif

/////////////////////////////////////////////////////////////////////////////
CHalAdapter::CHalAdapter( PHALDRIVERINFO pHalDriverInfo, ULONG ulAdapterNumber )
// Constructor - Cannot touch the hardware here...
/////////////////////////////////////////////////////////////////////////////
{
	//DPF(("CHalAdapter::CHalAdapter\n"));

	// clear the PCI Configuration Structure
	RtlZeroMemory( &m_PCIConfig, sizeof( PCI_CONFIGURATION ) );

	RtlZeroMemory( m_aIORegisters, NUM_IO_REGISTERS );
	
	RtlCopyMemory( &m_HalDriverInfo, pHalDriverInfo, sizeof( HALDRIVERINFO ) );

	//RtlZeroMemory( &m_aulFCValues, sizeof( m_aulFCValues ) );
	//RtlZeroMemory( &m_aucFCEntry, sizeof( m_aucFCEntry ) );

	// Initialize the member variables
	m_bOpen				= FALSE;
	m_pRegisters		= NULL;
	m_pAudioBuffers		= NULL;
	m_ulAdapterNumber	= ulAdapterNumber;
	m_PCIConfig.ulAdapterIndex = ulAdapterNumber;
	
	m_pDMA_VAddr		= NULL;
	m_pDMA_PAddr		= NULL;

	m_ulICHead			= 0;
	m_ulICTail			= 0;

	m_ulInterruptSamples = 0;	// will be set by the open command

	m_usDeviceID		= 0;
	m_usPCBRev			= 0;
	m_usFirmwareRev		= 0;
	m_usFirmwareDate	= 0;
	m_usMinSoftwareAPIRev	= 0;
	m_ulSerialNumber	= 0;

	m_usDitherType		= MIXVAL_DITHER_NONE;
	m_bAutoRecalibrate	= TRUE;
	m_bAIn12HPFEnable	= TRUE;
	m_bAIn34HPFEnable	= TRUE;
	m_bAIn56HPFEnable	= TRUE;
	m_bDACDeEmphasis	= FALSE;
	
	m_bSyncStart		= TRUE;
	m_ulSyncGroup		= 0;
	m_ulSyncReady		= 0;
	m_bLStreamSyncStart	= FALSE;

	m_ulMTCSource		= MIXVAL_MTCSOURCE_LTCRX;
	
	m_bHasAK5394A			= FALSE;
	m_bHasCS8420			= FALSE;
	m_bHasAK4114			= FALSE;
	m_bHasGlobalSyncStart	= FALSE;
	m_bHasTIVideoPLL		= FALSE;
	m_bHasP16				= FALSE;
	m_bHasDualMono			= FALSE;
	m_bHasLStream11			= FALSE;
	m_bHasLRClock			= FALSE;
	m_bHasLTC				= FALSE;
	m_bHas40MHzXtal			= FALSE;
	m_bHasMultiChannel		= FALSE;
	m_bHasWideWireOut		= FALSE;
}

/////////////////////////////////////////////////////////////////////////////
CHalAdapter::~CHalAdapter()
// Destructor, also cannot touch hardware
/////////////////////////////////////////////////////////////////////////////
{
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalAdapter::Find()
// should be called before Open
/////////////////////////////////////////////////////////////////////////////
{
	m_PCIConfig.usVendorID	= PCIVENDOR_LYNX;

	// call the driver to find the next Lynx device
	if( m_HalDriverInfo.pFind( m_HalDriverInfo.pContext, &m_PCIConfig ) )
	{
		//DPF(("m_HalDriverInfo.pFind Failed! %04x %04x\n", m_PCIConfig.usVendorID, m_PCIConfig.usDeviceID ));
		return( HSTATUS_CANNOT_FIND_ADAPTER );
	}

	m_usDeviceID = m_PCIConfig.usDeviceID;	// this lets the world know what device we are

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalAdapter::Open( BOOLEAN bResume )
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulDevice;
	USHORT	usStatus;

	//DPF(("CHalAdapter::Open\n"));

	// Call find if nobody else has yet...
	if( !m_PCIConfig.usVendorID )
	{
		usStatus = Find();
		if( usStatus )
			return( usStatus );
	}

	if( !bResume )
	{
		// call the driver to map the adapter's BARs
		if( m_HalDriverInfo.pMap( m_HalDriverInfo.pContext, &m_PCIConfig ) )
		{
			DPF(("m_HalDriverInfo.pMap Failed!\n"));
			return( HSTATUS_CANNOT_MAP_ADAPTER );
		}
	}

	// verify we actually got something back, and it looks like our adapter
	if( !m_PCIConfig.Base[ PCI_REGISTERS_INDEX ].ulAddress )
	{
		DPF(("BAR0 is NULL!\n"));
		m_HalDriverInfo.pUnmap( m_HalDriverInfo.pContext, &m_PCIConfig );
		return( HSTATUS_ADAPTER_NOT_FOUND );
	}
	
	if( !((m_PCIConfig.Base[ PCI_REGISTERS_INDEX ].ulSize == BAR0_SIZE) || (m_PCIConfig.Base[ PCI_REGISTERS_INDEX ].ulSize == AES16_BAR0_SIZE)) )
	{
		DPF(("BAR0 size is Invalid!\n"));
		m_HalDriverInfo.pUnmap( m_HalDriverInfo.pContext, &m_PCIConfig );
		return( HSTATUS_ADAPTER_NOT_FOUND );
	}

	if( !m_PCIConfig.Base[ AUDIO_DATA_INDEX ].ulAddress || 
		 m_PCIConfig.Base[ AUDIO_DATA_INDEX ].ulSize != BAR1_SIZE )
	{
		DPF(("BAR1 is Invalid!\n"));
		m_HalDriverInfo.pUnmap( m_HalDriverInfo.pContext, &m_PCIConfig );
		return( HSTATUS_ADAPTER_NOT_FOUND );
	}

	// assign LynxTWO registers the correct starting address
	m_pRegisters	= (PLYNXTWOREGISTERS)m_PCIConfig.Base[ PCI_REGISTERS_INDEX ].ulAddress;
	m_pAudioBuffers	= (PLYNXTWOAUDIOBUFFERS)m_PCIConfig.Base[ AUDIO_DATA_INDEX ].ulAddress;
	
#ifndef DOS
	//DPF(("Test the SRAM\n"));
	/////////////////////////////////////////////////////////////////////////
	// Test the SRAM
	/////////////////////////////////////////////////////////////////////////
	{
		PULONG	pAddr;
		ULONG	i;
		ULONG	ulData;
		ULONG	ulTestData;

#define TEST_PATTERN	0x1234ABCD

		pAddr = (PULONG)m_pAudioBuffers;
		ulTestData = TEST_PATTERN;
		for( i=0; i<MEMORY_TEST_SIZE; i++ )
		{
			WRITE_REGISTER_ULONG( pAddr + i, ulTestData );
			ulTestData += TEST_PATTERN;
		}
		pAddr = (PULONG)m_pAudioBuffers;
		ulTestData = TEST_PATTERN;
		for( i=0; i<MEMORY_TEST_SIZE; i++ )
		{
			ulData = READ_REGISTER_ULONG( pAddr + i );
			if( ulData != ulTestData )
			{
				DPF(("Bad Adapter Ram at %08lx [%08lx] Read [%08lx] XOR [%08lx]\n", i, ulTestData, ulData, ulData^ulTestData ));
				m_HalDriverInfo.pUnmap( m_HalDriverInfo.pContext, &m_PCIConfig );
				return( HSTATUS_BAD_ADAPTER_RAM );
			}
			ulTestData += TEST_PATTERN;
		}

	/////////////////////////////////////////////////////////////////////////
	// Clear the SRAM
	/////////////////////////////////////////////////////////////////////////
		pAddr = (PULONG)m_pAudioBuffers;
		for( i=0; i<MEMORY_TEST_SIZE; i++ )
			WRITE_REGISTER_ULONG( pAddr + i, 0 );
	}
	//DPF(("SRAM Test Complete\n"));
#endif // DOS

	// Verify that the PDBLOCK has what we are looking for...
	usStatus = (USHORT)READ_REGISTER_ULONG( &m_pRegisters->PDBlock.LY );
	if( usStatus != 0x4C59 )	// 0x4C='L' 0x59='Y'
	{
		DPF(("BAR0 does not have valid PDBLOCK (Memory Window Invalid?)! %08lx\n", READ_REGISTER_ULONG( &m_pRegisters->PDBlock.LY ) ));
		m_HalDriverInfo.pUnmap( m_HalDriverInfo.pContext, &m_PCIConfig );
		return( HSTATUS_INCORRECT_FIRMWARE );
	}

	usStatus = (USHORT)READ_REGISTER_ULONG( &m_pRegisters->PDBlock.NX );
	if( usStatus != 0x4E58 )	// 0x4E='N' 0x58='X'
	{
		DPF(("BAR0 does not have valid PDBLOCK (Memory Window Invalid?)! %08lx\n", READ_REGISTER_ULONG( &m_pRegisters->PDBlock.NX ) ));
		m_HalDriverInfo.pUnmap( m_HalDriverInfo.pContext, &m_PCIConfig );
		return( HSTATUS_INCORRECT_FIRMWARE );
	}

	/////////////////////////////////////////////////////////////////////////
	// Setup internal HAL variables
	// From here on, the Open must succeed and cannot return an error
	/////////////////////////////////////////////////////////////////////////
	
	// this is a bit tricky - we must allocate memory for the DMA buffer list and it must be on a 2048 byte boundry
	m_HalDriverInfo.pAllocateMemory( m_HalDriverInfo.pContext, (PVOID *)&m_pDMA_VAddr, (PVOID *)&m_pDMA_PAddr, sizeof( DMABUFFERLIST ), 0xFFFFF800 );

	// now inform the hardware where the DMA Double Buffer is Located
	// only shift out 10 bits because GDBLADDR starts at bit position 1
	WRITE_REGISTER_ULONG( &m_pRegisters->DMACTL, ((m_pDMA_PAddr >> 10) | REG_DMACTL_GDMAEN) );

	DPF(("HalAdapter::Open(): DMACTL is now %08lx and DBL is at %08lx\n",
	     (unsigned long)((m_pDMA_PAddr >> 10) | REG_DMACTL_GDMAEN), 
	     (unsigned long)(m_pDMA_PAddr)));
	     
	
	m_RegPCICTL.Init( &m_pRegisters->PCICTL, REG_WRITEONLY );	// value defaults to 0, not written to hardware at this point
	m_RegSTRMCTL.Init( &m_pRegisters->STRMCTL, REG_WRITEONLY );

	// Fill in the PDBLOCK shadow registers
	m_usDeviceID			= (USHORT)READ_REGISTER_ULONG( &m_pRegisters->PDBlock.DeviceID );	// shouldn't change
	m_usPCBRev				= (USHORT)READ_REGISTER_ULONG( &m_pRegisters->PDBlock.PCBRev );
	m_usFirmwareRev			= (USHORT)READ_REGISTER_ULONG( &m_pRegisters->PDBlock.FWRevID );
	m_usFirmwareDate		= (USHORT)READ_REGISTER_ULONG( &m_pRegisters->PDBlock.FWDate );
	m_usMinSoftwareAPIRev	= (USHORT)READ_REGISTER_ULONG( &m_pRegisters->PDBlock.MinSWAPIRev );

	// PCICTL & MISTAT are used in this function, PCICTL is set to 0 upon exit
	if( EEPROMGetSerialNumber( &m_ulSerialNumber, (PVOID)m_pRegisters ) )
	{
		m_ulSerialNumber = 0xFFFFFFFF;
	}
	else
	{
		// validate the serial number
		if( L2SN_GET_MODEL( m_ulSerialNumber ) != m_usDeviceID )
		{
			m_ulSerialNumber = 0xFFFFFFFF;
		}
	}

	/////////////////////////////////////////////////////////////////////////
	// do any serial number specific work
	/////////////////////////////////////////////////////////////////////////
	if( m_ulSerialNumber != 0xFFFFFFFF )
	{
		DPF(("Serial Number %08lx\n", m_ulSerialNumber ));
		// Custom OEM LynxTWO-A Board Requirements
		if( (L2SN_GET_MODEL( m_ulSerialNumber ) == PCIDEVICE_LYNXTWO_A) && 
			(
				((L2SN_GET_YEAR( m_ulSerialNumber ) == 3) && (L2SN_GET_WEEK( m_ulSerialNumber ) == 18)) ||
				((L2SN_GET_YEAR( m_ulSerialNumber ) == 4) && (L2SN_GET_WEEK( m_ulSerialNumber ) == 1))
			)
		  )
		{
			m_bAutoRecalibrate	= FALSE;
			m_bAIn12HPFEnable	= TRUE;
			m_bAIn34HPFEnable	= FALSE;
		}

		if( ((L2SN_GET_MODEL( m_ulSerialNumber ) == PCIDEVICE_LYNXTWO_A) || (L2SN_GET_MODEL( m_ulSerialNumber ) == PCIDEVICE_LYNXTWO_B) ||
			 (L2SN_GET_MODEL( m_ulSerialNumber ) == PCIDEVICE_LYNXTWO_C) || (L2SN_GET_MODEL( m_ulSerialNumber ) == PCIDEVICE_LYNX_L22)) &&
			(L2SN_GET_YEAR( m_ulSerialNumber ) >= 3) && 
			(L2SN_GET_WEEK( m_ulSerialNumber ) >= 17) )
		{
			m_bHasAK5394A = TRUE;
			m_RegPCICTL.BitSet( REG_PCICTL_ADCREV, TRUE );	// all other bits are already 0
		}
	}

	/////////////////////////////////////////////////////////////////////////
	// Firmware Version Specific Conditionals
	/////////////////////////////////////////////////////////////////////////
	if( ((m_usDeviceID == PCIDEVICE_LYNXTWO_A) && (m_usFirmwareRev >= 16)) ||
		((m_usDeviceID == PCIDEVICE_LYNXTWO_B) && (m_usFirmwareRev >= 2)) ||
		((m_usDeviceID == PCIDEVICE_LYNXTWO_C) && (m_usFirmwareRev >= 2)) ||
		(m_usDeviceID == PCIDEVICE_LYNX_L22) || 
		(m_usDeviceID == PCIDEVICE_LYNX_AES16) || (m_usDeviceID == PCIDEVICE_LYNX_AES16SRC) )
		m_bHasGlobalSyncStart = TRUE;

	if( ((m_usDeviceID == PCIDEVICE_LYNXTWO_A) && (m_usPCBRev > 1)) ||
		((m_usDeviceID == PCIDEVICE_LYNXTWO_B) && (m_usPCBRev > 0)) ||
		(m_usDeviceID == PCIDEVICE_LYNXTWO_C) || (m_usDeviceID == PCIDEVICE_LYNX_L22) || 
		(m_usDeviceID == PCIDEVICE_LYNX_AES16) || (m_usDeviceID == PCIDEVICE_LYNX_AES16SRC) )
		m_bHasTIVideoPLL = TRUE;

	if( ((m_usDeviceID == PCIDEVICE_LYNXTWO_A) && (m_usFirmwareRev >= 17)) ||
		((m_usDeviceID == PCIDEVICE_LYNXTWO_B) && (m_usFirmwareRev >= 2)) ||
		((m_usDeviceID == PCIDEVICE_LYNXTWO_C) && (m_usFirmwareRev >= 3)) ||
		(m_usDeviceID == PCIDEVICE_LYNX_L22) || 
		(m_usDeviceID == PCIDEVICE_LYNX_AES16) || (m_usDeviceID == PCIDEVICE_LYNX_AES16SRC) )
		m_bHasP16 = TRUE;

	if( ((m_usDeviceID == PCIDEVICE_LYNXTWO_A) && (m_usFirmwareRev >= 19)) ||
		((m_usDeviceID == PCIDEVICE_LYNXTWO_B) && (m_usFirmwareRev >= 3)) ||
		((m_usDeviceID == PCIDEVICE_LYNXTWO_C) && (m_usFirmwareRev >= 5)) ||
		((m_usDeviceID == PCIDEVICE_LYNX_L22)  && (m_usFirmwareRev >= 2)) ||
		(m_usDeviceID == PCIDEVICE_LYNX_AES16) || (m_usDeviceID == PCIDEVICE_LYNX_AES16SRC) )
		m_bHasDualMono = TRUE;

	if( ((m_usDeviceID == PCIDEVICE_LYNXTWO_A) && (m_usFirmwareRev >= 20)) ||
		((m_usDeviceID == PCIDEVICE_LYNXTWO_B) && (m_usFirmwareRev >= 4)) ||
		((m_usDeviceID == PCIDEVICE_LYNXTWO_C) && (m_usFirmwareRev >= 6)) ||
		((m_usDeviceID == PCIDEVICE_LYNX_L22)  && (m_usFirmwareRev >= 4)) ||
		(m_usDeviceID == PCIDEVICE_LYNX_AES16) || (m_usDeviceID == PCIDEVICE_LYNX_AES16SRC) )
		m_bHasLStream11 = TRUE;

	if( ((m_usDeviceID == PCIDEVICE_LYNXTWO_A) && (m_usFirmwareRev >= 23)) ||
		((m_usDeviceID == PCIDEVICE_LYNXTWO_B) && (m_usFirmwareRev >= 7)) ||
		((m_usDeviceID == PCIDEVICE_LYNXTWO_C) && (m_usFirmwareRev >= 9)) ||
		((m_usDeviceID == PCIDEVICE_LYNX_L22)  && (m_usFirmwareRev >= 7)) ||
		(m_usDeviceID == PCIDEVICE_LYNX_AES16) || (m_usDeviceID == PCIDEVICE_LYNX_AES16SRC) )
		m_bHasLRClock = TRUE;

	if( (m_usDeviceID == PCIDEVICE_LYNXTWO_A) || (m_usDeviceID == PCIDEVICE_LYNXTWO_B) || (m_usDeviceID == PCIDEVICE_LYNXTWO_C) )
		m_bHasLTC = TRUE;

	if( (m_usDeviceID == PCIDEVICE_LYNXTWO_A) || (m_usDeviceID == PCIDEVICE_LYNXTWO_B) || (m_usDeviceID == PCIDEVICE_LYNXTWO_C) || (m_usDeviceID == PCIDEVICE_LYNX_L22) )
		m_bHasCS8420 = TRUE;

	if( (m_usDeviceID == PCIDEVICE_LYNX_AES16) || (m_usDeviceID == PCIDEVICE_LYNX_AES16SRC) )
		m_bHasAK4114 = TRUE;

	if( (m_usDeviceID == PCIDEVICE_LYNX_AES16) || (m_usDeviceID == PCIDEVICE_LYNX_AES16SRC) )
		m_bHas40MHzXtal = TRUE;
	// SN: 2503230103 & 2503230106 both have 32MHz Crystals

	if( ((m_usDeviceID == PCIDEVICE_LYNXTWO_A)	   && (m_usFirmwareRev >= 28)) ||
		((m_usDeviceID == PCIDEVICE_LYNXTWO_B)	   && (m_usFirmwareRev >= 10)) ||
		((m_usDeviceID == PCIDEVICE_LYNXTWO_C)	   && (m_usFirmwareRev >= 12)) ||
		((m_usDeviceID == PCIDEVICE_LYNX_L22)	   && (m_usFirmwareRev >=  9)) )	// NOTE: AES16 doesn't support multi-channel yet
		m_bHasMultiChannel = TRUE;

	if( ((m_usDeviceID == PCIDEVICE_LYNX_AES16) && (m_usFirmwareRev >= 16)) ||
		((m_usDeviceID == PCIDEVICE_LYNX_AES16SRC) && (m_usFirmwareRev >= 16)) )
		m_bHasWideWireOut = TRUE;


	/////////////////////////////////////////////////////////////////////////
	// Open the devices for this adapter
	/////////////////////////////////////////////////////////////////////////
	//DPF(("CHalAdapter::Open Devices\n"));
	for( ulDevice=0; ulDevice<NUM_WAVE_DEVICES; ulDevice++ )
		m_WaveDevice[ ulDevice ].Open( this, ulDevice );	// This opens the DMA object as well (No writes to hardware)

	for( ulDevice=0; ulDevice<NUM_MIDI_DEVICES; ulDevice++ )
		m_MIDIDevice[ ulDevice ].Open( this, ulDevice );	// No writes to hardware

	// if this is not a AES16
	if(	!((m_usDeviceID == PCIDEVICE_LYNX_AES16) || (m_usDeviceID == PCIDEVICE_LYNX_AES16SRC)) )
	{
		// Setup the Misc Control Reg
		// DILRCKDIR = 1, DILRCK and DISLCK are inputs
		// DIRMCKDIR = 1, DIRMCK is input
		// Enable DACS and 8420
		if( (m_usDeviceID == PCIDEVICE_LYNXTWO_A) && (m_usPCBRev == 0) )
			IOWrite( kMisc, (IO_MISC_DIRMCKDIR | IO_MISC_DACARSTn | IO_MISC_DACBRSTn | IO_MISC_DACCRSTn | IO_MISC_CS8420RSTn | IO_MISC_VIDEN) ); // L2 master clock source
		else
			IOWrite( kMisc, (IO_MISC_DIRMCKDIR | IO_MISC_DACARSTn | IO_MISC_DACBRSTn | IO_MISC_DACCRSTn | IO_MISC_CS8420RSTn) ); // L2 master clock source
		
		if( !m_bHasLStream11 )
		{
			// Configure everything as an input
			IOWrite( kOptionIOControl, (IO_OPT_OPHD1DIR | IO_OPT_OPHD2DIR | IO_OPT_OPHSIGDIR | IO_OPT_OPBFCKDIR | IO_OPT_OPHFCKDIR) );
		}
	}

	// set the mixer
	m_Mixer.Open( this );			// Writes to hardware

	// Set sample rate & clock source to the default values
	m_SampleClock.Open( this );		// Writes to hardware

	// setup the 8420, this must be done *AFTER* the sample clock open
	if( m_bHasCS8420 )
	{
		m_CS8420.Open( this );		// Writes to hardware
	}

	if( m_bHasAK4114 )
	{
		m_AK4114.Open( this );		// Writes to hardware
	}
	
	// Sample Clock must be setup before LStream
	m_LStream.Open( this );			// Writes to hardware

	m_RegLTCControl.Init( &m_pRegisters->TCBlock.LTCControl );

	if( m_bHasLTC )
	{
		m_TimecodeRX.Open( this, TC_RX );	// Writes to hardware
		m_TimecodeTX.Open( this, TC_TX );	// Writes to hardware
	}

	// set the global stream control register (Global Circular Buffer Limit Size) to half the buffer
	SetInterruptSamples();	// RegSTRMCTL must be init'ed before calling this! (SampleClock must be open as well!)

	/////////////////////////////////////////////////////////////////////////
	// Initialize the hardware to a known state
	/////////////////////////////////////////////////////////////////////////

	// if this is not a AES16
	if( !((m_usDeviceID == PCIDEVICE_LYNX_AES16) || (m_usDeviceID == PCIDEVICE_LYNX_AES16SRC)) )
	{
		// Setup the ADCs (pin-controlled)  Doesn't matter if the ADC doesn't exist
		IOWrite( kADC_A_Control, IO_ADC_CNTL_RSTn );	// DAH Jun 14 2002 Recommended by AKM that ZCAL is Zero
		IOWrite( kADC_B_Control, IO_ADC_CNTL_RSTn );
		IOWrite( kADC_C_Control, IO_ADC_CNTL_RSTn );
		SetADHPF( CONTROL_AIN12_HPF, m_bAIn12HPFEnable );	// DAH May 21 2003
		SetADHPF( CONTROL_AIN34_HPF, m_bAIn34HPFEnable );
		SetADHPF( CONTROL_AIN56_HPF, m_bAIn56HPFEnable );

		// Setup the DACs (serial-controlled)
		IOWrite( kDAC_A_Control, (IO_DAC_CNTL_MODE_1X_EMPOFF | IO_DAC_CNTL_MUTEn) );
		// A & B Only
		if( (m_usDeviceID == PCIDEVICE_LYNXTWO_A) || (m_usDeviceID == PCIDEVICE_LYNXTWO_B) )
			IOWrite( kDAC_B_Control, (IO_DAC_CNTL_MODE_1X_EMPOFF | IO_DAC_CNTL_MUTEn) );
		// B Only
		if( m_usDeviceID == PCIDEVICE_LYNXTWO_B )
			IOWrite( kDAC_C_Control, (IO_DAC_CNTL_MODE_1X_EMPOFF | IO_DAC_CNTL_MUTEn) );
	}

	// set the state to open before enabling the interrupts so if an interrupt 
	// is pending now, it can get serviced now
	m_bOpen = TRUE;	

	/////////////////////////////////////////////////////////////////////////
	// Turn on the LED
	/////////////////////////////////////////////////////////////////////////
	m_RegPCICTL.BitSet( REG_PCICTL_LED, TRUE );

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalAdapter::Close( BOOLEAN bSuspend )
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulDevice;
	// put the adapter in power down mode

	if( !m_bOpen )
		return( HSTATUS_ADAPTER_NOT_OPEN );

	for( ulDevice=0; ulDevice<NUM_WAVE_DEVICES; ulDevice++ )
		m_WaveDevice[ ulDevice ].Close();

	for( ulDevice=0; ulDevice<NUM_MIDI_DEVICES; ulDevice++ )
		m_MIDIDevice[ ulDevice ].Close();

	if( m_bHasLTC )
	{
		m_TimecodeRX.Close();
		m_TimecodeTX.Close();
	}

	m_LStream.Close();

	m_Mixer.Close();
	if( m_bHasCS8420 )
	{
		m_CS8420.Close();
	}
	if( m_bHasAK4114 )
	{
		m_AK4114.Close();
	}
	m_SampleClock.Close();

	// turn off all the interrupts and the LED, put the FPGA in CFGEN mode
	WRITE_REGISTER_ULONG( &m_pRegisters->PCICTL, REG_PCICTL_CNFEN );
	{
		ULONG	ulDummy;	// keep the compiler from complaining about empty statements...

		// clear any pending interrupts
		ulDummy = READ_REGISTER_ULONG( &m_pRegisters->MISTAT );
		ulDummy = READ_REGISTER_ULONG( &m_pRegisters->AISTAT );
	}

    if( m_pDMA_VAddr )
    {
		m_HalDriverInfo.pFreeMemory( (PVOID)m_HalDriverInfo.pContext, (PVOID)m_pDMA_VAddr );	
		m_pDMA_VAddr		= NULL;
		m_pDMA_PAddr		= NULL;
    }

	// unmap the configuration (cannot do this until all access to the hardware is done)
	if( !bSuspend )
	{
		m_HalDriverInfo.pUnmap( m_HalDriverInfo.pContext, &m_PCIConfig );
	}
	m_pRegisters		= NULL;
	m_pAudioBuffers		= NULL;

	// Reset this to zero so we start over again...
	m_PCIConfig.usBusNumber			= 0;
	m_PCIConfig.usDeviceFunction	= 0;

	m_bOpen = FALSE;

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
void	CHalAdapter::EnableInterrupts( void )
/////////////////////////////////////////////////////////////////////////////
{
	if( m_bOpen )
	{
		ULONG	ulDummy;	// keep the compiler from complaining about empty statements...

		// clear any pending interrupts
		ulDummy = READ_REGISTER_ULONG( &m_pRegisters->MISTAT );
		ulDummy = READ_REGISTER_ULONG( &m_pRegisters->AISTAT );
		m_RegPCICTL.BitSet( REG_PCICTL_GIE | REG_PCICTL_AIE | REG_PCICTL_MIE, TRUE );
	}
}

/////////////////////////////////////////////////////////////////////////////
void	CHalAdapter::DisableInterrupts( void )
/////////////////////////////////////////////////////////////////////////////
{
	if( m_bOpen )
	{
		m_RegPCICTL.BitSet( REG_PCICTL_GIE | REG_PCICTL_AIE | REG_PCICTL_MIE, FALSE );
	}
}

/////////////////////////////////////////////////////////////////////////////
BOOLEAN			CHalAdapter::IsWaveDeviceRecord( ULONG ulDeviceNumber )
/////////////////////////////////////////////////////////////////////////////
{
	if( ulDeviceNumber < NUM_WAVE_RECORD_DEVICES )
		return( TRUE );
	else
		return( FALSE );
}

/////////////////////////////////////////////////////////////////////////////
PHALWAVEDEVICE	CHalAdapter::GetWaveDevice( ULONG ulDeviceNumber )
/////////////////////////////////////////////////////////////////////////////
{
	if( ulDeviceNumber >= NUM_WAVE_DEVICES )
		return( NULL );

	return( &m_WaveDevice[ ulDeviceNumber ] );
}

/////////////////////////////////////////////////////////////////////////////
PHALWAVEDMADEVICE	CHalAdapter::GetWaveDMADevice( ULONG ulDeviceNumber )
/////////////////////////////////////////////////////////////////////////////
{
	if( ulDeviceNumber >= NUM_WAVE_DEVICES )
		return( NULL );

	return( &m_WaveDevice[ ulDeviceNumber ] );
}

/////////////////////////////////////////////////////////////////////////////
PHALWAVEDEVICE	CHalAdapter::GetWaveInDevice( ULONG ulDeviceNumber )
/////////////////////////////////////////////////////////////////////////////
{
	if( ulDeviceNumber >= NUM_WAVE_RECORD_DEVICES )
		return( NULL );

	return( &m_WaveDevice[ ulDeviceNumber ] );
}

/////////////////////////////////////////////////////////////////////////////
PHALWAVEDEVICE	CHalAdapter::GetWaveOutDevice( ULONG ulDeviceNumber )
/////////////////////////////////////////////////////////////////////////////
{
	if( ulDeviceNumber >= NUM_WAVE_PLAY_DEVICES )
		return( NULL );

	return( &m_WaveDevice[ NUM_WAVE_RECORD_DEVICES + ulDeviceNumber ] );
}

/////////////////////////////////////////////////////////////////////////////
ULONG			CHalAdapter::GetNumActiveWaveDevices( void )
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulNumActive = 0;
	int		nDevice;

	for( nDevice=0; nDevice < (int)GetNumWaveDevices(); nDevice++ )
	{
		if( GetWaveDMADevice( nDevice )->IsRunning() )
		{
			ulNumActive++;
		}
	}

	return( ulNumActive );
}

/////////////////////////////////////////////////////////////////////////////
BOOLEAN			CHalAdapter::IsMIDIDeviceRecord( ULONG ulDeviceNumber )
/////////////////////////////////////////////////////////////////////////////
{
	if( ulDeviceNumber < NUM_MIDI_RECORD_DEVICES )
		return( TRUE );
	else
		return( FALSE );
}

/////////////////////////////////////////////////////////////////////////////
PHALMIDIDEVICE	CHalAdapter::GetMIDIDevice( ULONG ulDeviceNumber )
/////////////////////////////////////////////////////////////////////////////
{
	if( ulDeviceNumber >= NUM_MIDI_DEVICES )
		return( NULL );

	return( &m_MIDIDevice[ ulDeviceNumber ] );
}

/////////////////////////////////////////////////////////////////////////////
PHALMIDIDEVICE	CHalAdapter::GetMIDIInDevice( ULONG ulDeviceNumber )
/////////////////////////////////////////////////////////////////////////////
{
	if( ulDeviceNumber >= NUM_MIDI_RECORD_DEVICES )
		return( NULL );

	return( &m_MIDIDevice[ ulDeviceNumber ] );
}

/////////////////////////////////////////////////////////////////////////////
PHALMIDIDEVICE	CHalAdapter::GetMIDIOutDevice( ULONG ulDeviceNumber )
/////////////////////////////////////////////////////////////////////////////
{
	if( ulDeviceNumber >= NUM_MIDI_PLAY_DEVICES )
		return( NULL );

	return( &m_MIDIDevice[ NUM_MIDI_RECORD_DEVICES + ulDeviceNumber ] );
}

static ULONG gulAdapterSyncGroup = 0;
static ULONG gulAdapterSyncReady = 0;

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalAdapter::SetSyncStartState( BOOLEAN bEnable )
/////////////////////////////////////////////////////////////////////////////
{
	//DPF(("CHalAdapter::SetSyncStartState\n"));

	m_bSyncStart = bEnable;
	// TODO: if any devices are waiting to start, do it now!
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalAdapter::AddToStartGroup( ULONG ulDeviceNumber )
// Called from a Wave Device when it wants to be added to the start group for this adapter
/////////////////////////////////////////////////////////////////////////////
{
	// Add to the start group on this adapter
	SET( m_ulSyncGroup, (1<<ulDeviceNumber) );
	
	// Add this adapter to the start group for the entire machine
	SET( gulAdapterSyncGroup, (1<<m_ulAdapterNumber) );

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalAdapter::RemoveFromStartGroup( ULONG ulDeviceNumber )
// Called from a Wave Device when it wants to be removed from the start group 
// for this adapter.  This code should see if other devices are waiting, and
// start them if needed - but it currently doesn't.
/////////////////////////////////////////////////////////////////////////////
{
	// Remove from the start group on this adapter
	CLR( m_ulSyncGroup, (1<<ulDeviceNumber) );

	// is the sync group now clear?
	if( !m_ulSyncGroup )
	{
		// Remove this adapter to the start group for the entire machine
		CLR( gulAdapterSyncGroup, (1<<m_ulAdapterNumber) );
	}

	return( HSTATUS_OK );
}

#ifdef INTERRUPT_TIMING
#ifdef MACINTOSH
	LONGLONG	SoundGetTime( VOID );
	LONGLONG	gllLastTime = 0;
#else
	LONGLONG SoundGetTime( VOID );
	//#include <stdio.h>
	LONGLONG	gllLastTime = 0;
#endif
#endif

/////////////////////////////////////////////////////////////////////////////
USHORT CHalAdapter::SyncStartPrime()
// This function insures that all devices that are part of a sync start 
// group are ready to go
/////////////////////////////////////////////////////////////////////////////
{
	int	nDevice;

	//DPF(("CHalAdapter::SyncStartPrime A[%lu]\n", m_ulAdapterNumber ));

	// make sure the preload is complete for all DMA play devices
	for( nDevice=WAVE_PLAY0_DEVICE; nDevice<NUM_WAVE_DEVICES; nDevice++ )
	{
		PHALWAVEDMADEVICE	pHDD = GetWaveDMADevice( nDevice );

		// is this device part of the sync group?
		if( ((1<<nDevice) & m_ulSyncGroup) && pHDD->IsDMAActive() )
		{
			PHALDMA	pHDMA = pHDD->GetDMA();
			
			// wait for the preload to complete
			pHDMA->WaitForPreloadToComplete();

			// we must now re-read the stream control register and OR it with the stored value
			// because the PCPTR value has now changed.
			CLR( m_aulStreamControl[ nDevice ], REG_STREAMCTL_PCPTR_MASK );
			m_aulStreamControl[ nDevice ] |= (pHDD->GetStreamControl()->Read() & REG_STREAMCTL_PCPTR_MASK);
			//DPF(("Read StreamControl [%04lx] %ld\n", m_aulStreamControl[ nDevice ] & REG_STREAMCTL_FMT_MASK, nDevice ));
		}
	}

	//DPF(("Starting All Devices\n"));
	for( nDevice=WAVE_RECORD0_DEVICE; nDevice<NUM_WAVE_DEVICES; nDevice++ )
	{
		// is this device part of the sync group?
		if( (1<<nDevice) & m_ulSyncGroup )
		{
			//DS("SyncStart",COLOR_BOLD);	DB('0'+nDevice,COLOR_UNDERLINE);
			m_WaveDevice[ nDevice ].GetStreamControl()->Write( m_aulStreamControl[ nDevice ] );
			//DPF(("Write StreamControl [%04lx] %ld\n", m_aulStreamControl[ nDevice ] & REG_STREAMCTL_FMT_MASK, nDevice ));
		}
	}

	m_ulSyncGroup = 0;
	m_ulSyncReady = 0;

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalAdapter::EnableLStreamSyncStart( BOOLEAN bEnable )
// Called when the application wants the LStream port to send the GSYNC
/////////////////////////////////////////////////////////////////////////////
{
	//DPF(("EnableLStreamSyncStart %d\n", bEnable ));
	m_bLStreamSyncStart = bEnable;

	// Must update both controls in the mixer
	m_Mixer.ControlChanged( LINE_LSTREAM, LINE_NO_SOURCE, CONTROL_LS1_ADAT_CUEPOINT_ENABLE );
	m_Mixer.ControlChanged( LINE_LSTREAM, LINE_NO_SOURCE, CONTROL_LS2_ADAT_CUEPOINT_ENABLE );

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalAdapter::SyncStartGo()
// Starts all devices by setting GSYNC
/////////////////////////////////////////////////////////////////////////////
{
	DPF(("CHalAdapter::SyncStartGo\n"));

	if( m_bLStreamSyncStart )
	{
		// one-shot.  Doesn't write GSYNC to the hardware, lets the LStream port to that
		m_bLStreamSyncStart = FALSE;	

		// Tell the LStream module to go ahead and start looking for the timecode
		// if this fails, then we must go ahead and start the device as normal
		if( m_LStream.ADATCuePointEnable() )
		{
			//DPF(("ADATCuePointEnable Failed!\n"));
			DS(" GSYNC ",COLOR_NORMAL);
			m_RegSTRMCTL.BitSet( REG_STRMCTL_GSYNC, TRUE );
		}

		// Must update both controls in the mixer
		m_Mixer.ControlChanged( LINE_LSTREAM, LINE_NO_SOURCE, CONTROL_LS1_ADAT_CUEPOINT_ENABLE );
		m_Mixer.ControlChanged( LINE_LSTREAM, LINE_NO_SOURCE, CONTROL_LS2_ADAT_CUEPOINT_ENABLE );
	}
	else
	{
		//DS(" GSYNC ",COLOR_NORMAL);
		m_RegSTRMCTL.BitSet( REG_STRMCTL_GSYNC, TRUE );
	}
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalAdapter::SyncStartReady( ULONG ulDeviceNumber, ULONG ulStreamControl )
// Called from a Wave Device when it is ready to start
/////////////////////////////////////////////////////////////////////////////
{
	PHALADAPTER	pHA[ MAX_NUMBER_OF_ADAPTERS ];
	int			nAdapter;
	int			nNumActiveAdapters = 0;
	//PHALADAPTER	pMaster = NULL;
	//int nDevice;

	//DPF(("CHalAdapter::SyncStartReady A[%lu] D[%lu]\n", m_ulAdapterNumber, ulDeviceNumber ));

	// save this for later
	m_aulStreamControl[ ulDeviceNumber ] = ulStreamControl;

	// show that this device is ready to start
	SET( m_ulSyncReady, (1<<ulDeviceNumber) );

	// are all the devices in the group on this adapter ready to start?
	if( m_ulSyncGroup == m_ulSyncReady )
		SET( gulAdapterSyncReady, (1<<m_ulAdapterNumber) );

	// are all the adapters in the group ready to start?
	if( gulAdapterSyncGroup == gulAdapterSyncReady )
	{
		nNumActiveAdapters = 0;
		// scan thru each opened adapter
		for( nAdapter=0; nAdapter<MAX_NUMBER_OF_ADAPTERS; nAdapter++ )
		{
			pHA[ nAdapter ] = NULL;

			// does this adapter have any devices in the sync group?
			if( (1<<nAdapter) & gulAdapterSyncGroup )
			{
				pHA[ nNumActiveAdapters ] = m_HalDriverInfo.pGetAdapter( m_HalDriverInfo.pContext, nAdapter );
				if( !pHA[ nNumActiveAdapters ] )
					continue;
				
				pHA[ nNumActiveAdapters ]->SyncStartPrime();
				nNumActiveAdapters++;
			}
		}

		// Multicard Sample Accurate Sync-Start...
		if( pHA[0] && pHA[0]->HasLRClock() && (nNumActiveAdapters > 1) )
		{
			PLYNXTWOREGISTERS	pRegs = pHA[0]->GetRegisters();
			PULONG				pulOPBUFSTAT = &pRegs->OPBUFSTAT;

			// Wait for L/R clock to transition
			// if LRCK is currently high, wait for it to go low
			while( !(READ_REGISTER_ULONG( pulOPBUFSTAT ) & REG_OPBUFSTAT_LRCLOCK) )
				;
			// LRCK is low, wait for it to go high
			while( (READ_REGISTER_ULONG( pulOPBUFSTAT ) & REG_OPBUFSTAT_LRCLOCK) )
				;
			// ok, we should be safe to start the adapters now
		}
		
		// Start all the adapters
		for( nAdapter=0; nAdapter<nNumActiveAdapters; nAdapter++ )
		{
			if( pHA[ nAdapter ] )
				pHA[ nAdapter ]->SyncStartGo();
		}
		
		// reset for next time around
		gulAdapterSyncGroup = 0;
		gulAdapterSyncReady = 0;

		//DPET();
	}
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalAdapter::SetInterruptSamples( ULONG ulInterruptSamples )
// Sets the number of samples to try and keep in the buffer (the interrupt point)
// This means that if you set the Interrupt Samples to 32, then the limit
// interrupt will fire when there are 32 samples *left to play* leaving only
// 32 sample periods to transfer in new data before an underrun error.
/////////////////////////////////////////////////////////////////////////////
{
	if( !ulInterruptSamples )
	{
/*
		LONG	lSampleRate;
		m_SampleClock.Get( &lSampleRate );

		if( lSampleRate > 100000 )		ulInterruptSamples = WAVE_CIRCULAR_BUFFER_SIZE - 2048;
		else if( lSampleRate > 50000 )	ulInterruptSamples = WAVE_CIRCULAR_BUFFER_SIZE - 1024;
		else if( lSampleRate > 25000 )	ulInterruptSamples = WAVE_CIRCULAR_BUFFER_SIZE - 512;
		else if( lSampleRate > 12500 )	ulInterruptSamples = WAVE_CIRCULAR_BUFFER_SIZE - 256;
		else							ulInterruptSamples = WAVE_CIRCULAR_BUFFER_SIZE - 128;
		//DPF(("ulInterruptSamples %lu lSampleRate %ld\n", ulInterruptSamples, lSampleRate ));
*/
		ulInterruptSamples = (WAVE_CIRCULAR_BUFFER_SIZE / 2);	// Set to half the buffer
	}

	// we need to make sure all the devices are idle before changing this...
	if( GetNumActiveWaveDevices() )
	{
		//DPF(("Device in use. Cannot change Interrupt Samples.\n"));
		return( HSTATUS_ALREADY_IN_USE );
	}

	// FPGA Logic is:
	// RECORD: Limit set when 0 < (PCPTR-L2PTR) < GLIMIT; where PCPTR-L2PTR indicates the number of empty DWORDS in circular buffer. 
	// NOTE:Record limit logic was changed on 4/29/02.
	// PLAY: Limit set when  (L2PTR-PCPTR) > GLIMIT; where L2PTR-PCPTR indicates the number of already played DWORDS in circular buffer.
	//                         214-400=E14 >  1000-200=E00
	//                         E12-200=C12 >  1000-200=E00
	//                         314-600=D14 >  1000-100=F00
	//                         0CA-800=D14 >  1000-400=C00

	// GLIMIT is actually the number of EMPTY samples to fire the interrupt on,
	// not the number of samples remaining.
	ulInterruptSamples = WAVE_CIRCULAR_BUFFER_SIZE - ulInterruptSamples;

	if( m_ulInterruptSamples != ulInterruptSamples )
	{
		//DPF(("Setting Interrupt Samples in Hardware %08lx %ld\n", ulInterruptSamples, WAVE_CIRCULAR_BUFFER_SIZE - ulInterruptSamples ));
		//DS(" IntSamples:", COLOR_NORMAL);	DX16( (USHORT)ulInterruptSamples, COLOR_NORMAL );	DC(' ');
		// set the global stream control register (Global Circular Buffer Limit Size)
		// DAH 10/16/02 make sure we don't write the GSYNC bit by accident (this code clear's the shadow register)
		m_RegSTRMCTL.Write( ulInterruptSamples, REG_STRMCTL_GSYNC | REG_STRMCTL_GLIMIT_MASK );
		m_ulInterruptSamples = ulInterruptSamples;
	}

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalAdapter::GetFrequencyCounter( USHORT usRegister, PULONG pulFrequency )
// might be able to get away with this being a private function
/////////////////////////////////////////////////////////////////////////////
{
	ULONG		ulCount, ulScale, ulValue;
	LONGLONG	llReference;

	if( (m_usDeviceID == PCIDEVICE_LYNX_L22) && (usRegister == L2_FREQCOUNTER_VIDEO) )
		return( HSTATUS_INVALID_MIXER_CONTROL );

	if( (m_usDeviceID == PCIDEVICE_LYNX_AES16) || (m_usDeviceID == PCIDEVICE_LYNX_AES16SRC) )
	{
		if( usRegister >= AES16_FREQCOUNTER_NUMENTIRES )
			return( HSTATUS_INVALID_MIXER_CONTROL );
	}
	else
	{
		if( usRegister >= L2_FREQCOUNTER_NUMENTIRES )
			return( HSTATUS_INVALID_MIXER_CONTROL );
	}

	if( m_bHas40MHzXtal )
		llReference	= 40000000;	// only this number needs to be 64 bit for the precision to be OK
	else
		llReference	= 32000000;	// only this number needs to be 64 bit for the precision to be OK

	ulCount		= READ_REGISTER_ULONG( &m_pRegisters->FRBlock[ usRegister ].Count ) & REG_FCBLOCK_COUNT_MASK;
	ulScale		= READ_REGISTER_ULONG( &m_pRegisters->FRBlock[ usRegister ].Scale ) & REG_FCBLOCK_SCALE_MASK;
	// Count can be 65535 Max and 32768 Min (except for Scale==9, then Count can be any 16-bit number)
	// Scale 9 is     1MHz -> up
	// Scale 8 is   500kHz -> 1MHz
	// Scale 7 is   250kHz -> 500kHz
	// Scale 6 is   125kHz -> 250kHz
	// Scale 5 is  62.5kHz -> 125kHz
	// Scale 4 is 31.25kHz -> 62.5kHz 
	// Scale 3 is  15625Hz -> 31250Hz 
	// Scale 2 is   7812Hz -> 15625Hz

	if( !ulCount )
	{
		*pulFrequency = 0;
	}
	else
	{
		//DPF(("%5ld %ld ", ulCount, ulScale ));

		// Range of SCALE is 0..9, but we allow 0..15
		// by using a LONGLONG as the llReference, the intermediate number is 64 bit
		// We add ulCount/2 for rounding
		ulValue = (ULONG)(((llReference<<(ulScale+2))+(ulCount/2)) / ulCount);

		//DPF(("Counter %lu Scale %lu Count %lu Value %lu\n", (ULONG)usRegister, ulScale, ulCount, ulValue ));

		if( (m_usDeviceID == PCIDEVICE_LYNX_AES16) || (m_usDeviceID == PCIDEVICE_LYNX_AES16SRC) )
		{
			if( (usRegister >= AES16_FREQCOUNTER_DI1) && (usRegister <= AES16_FREQCOUNTER_DI8) )
			{
				if( !m_AK4114.IsInputLocked( usRegister - AES16_FREQCOUNTER_DI1 ) )
				{
					ulValue = 0;
				}
				else
				{
					ulValue /= 128;

					if( ulValue < MIN_SAMPLE_RATE )
						ulValue = 0;
				}
			}
		}
		else	// LynxTWO/L22 cards
		{
			// if this is the digital input counter, scale it so it reads correctly
			if( usRegister == L2_FREQCOUNTER_DIGITALIN )
			{
				ulValue /= 128;

				if( ulValue < MIN_SAMPLE_RATE )
					ulValue = 0;
			}
			// put some limits on the video counter
			if( usRegister == L2_FREQCOUNTER_VIDEO )
			{
				// Video Input, should be either 15.734kHz NTSC or 15.625 kHz PAL
				if( !(((ulValue > 15600) && (ulValue < 15650)) || 
					 ((ulValue > 15709) && (ulValue < 15759))) )
				{
					ulValue = 0;
				}
			}
		}

		*pulFrequency = ulValue;
	}

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalAdapter::NormalizeFrequency( ULONG ulFrequency, PLONG plRate, PLONG plReference )
// Takes any frequency as an input and returns a normalized (standardized)
// frequency in return
/////////////////////////////////////////////////////////////////////////////
{
	LONG	lRate = 0;
	LONG	lReference = 0;
	
	if( plReference )
		lReference = *plReference;

	// normalize the rate
	if( ulFrequency < 16000 )
	{
		lRate = 0;
	}
	else if( ulFrequency < 27025 )	// half way between 22050 & 32kHz
	{
		lRate = 22050;
		lReference = MIXVAL_CLKREF_WORD;
	}
	else if( ulFrequency < 38050 )	// half way between 32kHz & 44.1kHz
	{
		lRate = 32000;
		lReference = MIXVAL_CLKREF_WORD;
	}
	else if( ulFrequency < 46050 )	// half way between 44.1kHz & 48kHz
	{
		lRate = 44100;
		lReference = MIXVAL_CLKREF_WORD;
	}
	else if( ulFrequency < 56000 )	// you get the idea
	{
		lRate = 48000;
		lReference = MIXVAL_CLKREF_WORD;
	}
	else if( ulFrequency < 76100 )
	{
		lRate = 64000;
		lReference = MIXVAL_CLKREF_WORD;
	}
	else if( ulFrequency < 92100 )
	{
		lRate = 88200;
		lReference = MIXVAL_CLKREF_WORD;
	}
	else if( ulFrequency < 112000 )
	{
		lRate = 96000;
		lReference = MIXVAL_CLKREF_WORD;
	}
	else if( ulFrequency < 152200 )
	{
		lRate = 128000;
		lReference = MIXVAL_CLKREF_WORD;
	}
	else if( ulFrequency < 184200 )
	{
		lRate = 176400;
		lReference = MIXVAL_CLKREF_WORD;
	}
	else if( ulFrequency < 215000 )	// 215kHz is the top end of this set
	{
		lRate = 192000;
		lReference = MIXVAL_CLKREF_WORD;
	}
	else if( ulFrequency < 7372800 )	// 8.192MHz - 10%
	{
		lRate = 0;
	}
	else if( ulFrequency < 9740800 )	// half way between 32kHz & 44.1kHz
	{
		lRate = 32000;
		lReference = MIXVAL_CLKREF_WORD256;
	}
	else if( ulFrequency < 11788800 )	// half way between 44.1kHz & 48kHz
	{
		lRate = 44100;
		lReference = MIXVAL_CLKREF_WORD256;
	}
	else if( ulFrequency < 12894000 )	// half way between 44.1kHz & 48kHz
	{
		lRate = 48000;
		lReference = MIXVAL_CLKREF_WORD256;
	}
	else if( ulFrequency < 14942000 )
	{
		lReference = MIXVAL_CLKREF_13p5MHZ;
	}
	else if( ulFrequency < 19481600 )
	{
		lRate = 64000;
		lReference = MIXVAL_CLKREF_WORD256;
	}
	else if( ulFrequency < 23577600 )
	{
		lRate = 88200;
		lReference = MIXVAL_CLKREF_WORD256;
	}
	else if( ulFrequency < 25788000 )
	{
		lRate = 96000;
		lReference = MIXVAL_CLKREF_WORD256;
	}
	else if( ulFrequency < 29884000 )
	{
		lReference = MIXVAL_CLKREF_27MHZ;
	}
	else if( ulFrequency < 38963200 )
	{
		lRate = 128000;
		lReference = MIXVAL_CLKREF_WORD256;
	}
	else if( ulFrequency < 47155200 )
	{
		lRate = 176400;
		lReference = MIXVAL_CLKREF_WORD256;
	}
	else if( ulFrequency < 54067200 )	// 49MHz + 10%
	{
		lRate = 192000;
		lReference = MIXVAL_CLKREF_WORD256;
	}
	else
	{
		lRate = 0;
	}

	*plRate = lRate;
	
	if( plReference )
		*plReference = lReference;

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
BOOLEAN	CHalAdapter::GetNTSCPAL( void )
// returns TRUE for NTSC and FALSE for PAL
/////////////////////////////////////////////////////////////////////////////
{
	if( READ_REGISTER_ULONG( &m_pRegisters->FRBlock[ 0 ].Scale ) & REG_FCBLOCK_NTSCPALn )
		return( TRUE );
	
	return( FALSE );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalAdapter::IOWrite( BYTE ucAddress, BYTE ucData, BYTE ucMask )
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulAddress	= (ULONG)ucAddress;
	ULONG	ulData;

	// IOWrite & IORead are invalid on the AES16
	if( (m_usDeviceID == PCIDEVICE_LYNX_AES16) || (m_usDeviceID == PCIDEVICE_LYNX_AES16SRC) )
		return( HSTATUS_INVALID_PARAMETER );

	if( ucAddress >= NUM_IO_REGISTERS )
		return( HSTATUS_INVALID_PARAMETER );
	
	// read the current register out of the shadow memory
	ulData = (ULONG)m_aIORegisters[ ucAddress ];

	CLR( ulData, ucMask );
	SET( ulData, (ucData & ucMask) );

	//DPF(("IOWrite %02x %02x\n", (USHORT)ulAddress, (USHORT)ulData ));

	///////////////////// THIS MUST NOT BE INTERRUPTED //////////////////////
	WRITE_REGISTER_ULONG( &m_pRegisters->IODATA, (ulData & 0xFF) );
	WRITE_REGISTER_ULONG( &m_pRegisters->IOADDR, (ulAddress | REG_IOADDR_WRITE) );
	///////////////////// THIS MUST NOT BE INTERRUPTED //////////////////////

	// save the current register back to the shadow memory
	m_aIORegisters[ ucAddress ] = (BYTE)ulData;

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalAdapter::IORead( BYTE ucAddress, PBYTE pucData, BOOLEAN bReadShadowOnly )
// Only called by Hal8420
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulAddress	= (ULONG)ucAddress;
	ULONG	ulData;

	// IOWrite & IORead are invalid on the AES16
	if( (m_usDeviceID == PCIDEVICE_LYNX_AES16) || (m_usDeviceID == PCIDEVICE_LYNX_AES16SRC) )
		return( HSTATUS_INVALID_PARAMETER );

	if( ucAddress >= NUM_IO_REGISTERS )
		return( HSTATUS_INVALID_PARAMETER );

	// if this is a read-write register
	if( (ucAddress < 0x90) && !bReadShadowOnly )
	{
		//DPF(("IORead %02x ", (USHORT)ulAddress ));

		///////////////////// THIS MUST NOT BE INTERRUPTED //////////////////////
		WRITE_REGISTER_ULONG( &m_pRegisters->IOADDR, (ulAddress | REG_IOADDR_READ) );
		ulData = READ_REGISTER_ULONG( &m_pRegisters->IODATA ) & 0xFF;
		///////////////////// THIS MUST NOT BE INTERRUPTED //////////////////////

		// save the current register back to the shadow memory
		m_aIORegisters[ ucAddress ] = (BYTE)ulData;
	}

	*pucData = m_aIORegisters[ ucAddress ];

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalAdapter::SetTrim( USHORT usControl, ULONG ulValue )
// No need to check for the model here
/////////////////////////////////////////////////////////////////////////////
{
	switch( usControl )
	{
	case CONTROL_AIN12_TRIM:
		// All three cards have these in common
		if( ulValue )	IOWrite( kTrim, IO_TRIM_ABC_AIN12_MINUS10, IO_TRIM_ABC_AIN12_MASK );
		else			IOWrite( kTrim, IO_TRIM_ABC_AIN12_PLUS4, IO_TRIM_ABC_AIN12_MASK );
		m_lTrimAI12 = ulValue;
		break;
	case CONTROL_AIN34_TRIM:
		// A&C Only
		if( ulValue )	IOWrite( kTrim, IO_TRIM_AC_AIN34_MINUS10, IO_TRIM_AC_AIN34_MASK );
		else			IOWrite( kTrim, IO_TRIM_AC_AIN34_PLUS4, IO_TRIM_AC_AIN34_MASK );
		m_lTrimAI34 = ulValue;
		break;
	case CONTROL_AIN56_TRIM:
		// C Only
		if( ulValue )	IOWrite( kTrim, IO_TRIM_C_AIN56_MINUS10, IO_TRIM_C_AIN56_MASK );
		else			IOWrite( kTrim, IO_TRIM_C_AIN56_PLUS4, IO_TRIM_C_AIN56_MASK );
		m_lTrimAI56 = ulValue;
		break;
	case CONTROL_AOUT12_TRIM:
		// C is different than all the other cards
		if( m_usDeviceID == PCIDEVICE_LYNXTWO_C )
		{
			// Bit3
			if( ulValue )	IOWrite( kTrim, IO_TRIM_C_AOUT12_MINUS10, IO_TRIM_C_AOUT12_MASK );
			else			IOWrite( kTrim, IO_TRIM_C_AOUT12_PLUS4, IO_TRIM_C_AOUT12_MASK );
		}
		else
		{
			// Bit2
			if( ulValue )	IOWrite( kTrim, IO_TRIM_AB_AOUT12_MINUS10, IO_TRIM_AB_AOUT12_MASK );
			else			IOWrite( kTrim, IO_TRIM_AB_AOUT12_PLUS4, IO_TRIM_AB_AOUT12_MASK );
		}
		m_lTrimAO12 = ulValue;
		break;
	case CONTROL_AOUT34_TRIM:
		// A&B Only - Bit3
		if( ulValue )	IOWrite( kTrim, IO_TRIM_AB_AOUT34_MINUS10, IO_TRIM_AB_AOUT34_MASK );
		else			IOWrite( kTrim, IO_TRIM_AB_AOUT34_PLUS4, IO_TRIM_AB_AOUT34_MASK );
		m_lTrimAO34 = ulValue;
		break;
	case CONTROL_AOUT56_TRIM:
		// B Only - Bit1
		if( ulValue )	IOWrite( kTrim, IO_TRIM_B_AOUT56_MINUS10, IO_TRIM_B_AOUT56_MASK );
		else			IOWrite( kTrim, IO_TRIM_B_AOUT56_PLUS4, IO_TRIM_B_AOUT56_MASK );
		m_lTrimAO56 = ulValue;
		break;
	}
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalAdapter::GetTrim( USHORT usControl, PULONG pulValue )
// MUST check for the model here!
/////////////////////////////////////////////////////////////////////////////
{
	if( (m_usDeviceID == PCIDEVICE_LYNX_AES16) || (m_usDeviceID == PCIDEVICE_LYNX_AES16SRC) )
		return( HSTATUS_INVALID_MIXER_CONTROL );

	switch( usControl )
	{
	case CONTROL_AIN12_TRIM:
		// All have this
		*pulValue = m_lTrimAI12;
		break;
	case CONTROL_AIN34_TRIM:
		// only the A&C have this control
		if( (m_usDeviceID == PCIDEVICE_LYNXTWO_B) || (m_usDeviceID == PCIDEVICE_LYNX_L22) )
			return( HSTATUS_INVALID_MIXER_CONTROL );
		*pulValue = m_lTrimAI34;
		break;
	case CONTROL_AIN56_TRIM:
		// only the C has this control
		if( m_usDeviceID != PCIDEVICE_LYNXTWO_C )
			return( HSTATUS_INVALID_MIXER_CONTROL );
		*pulValue = m_lTrimAI56;
		break;
	case CONTROL_AOUT12_TRIM:
		// All have this
		*pulValue = m_lTrimAO12;
		break;
	case CONTROL_AOUT34_TRIM:
		// only the A&B have this control
		if( (m_usDeviceID == PCIDEVICE_LYNXTWO_C) || (m_usDeviceID == PCIDEVICE_LYNX_L22) )
			return( HSTATUS_INVALID_MIXER_CONTROL );
		*pulValue = m_lTrimAO34;
		break;
	case CONTROL_AOUT56_TRIM:
		// only the B has this control
		if( m_usDeviceID != PCIDEVICE_LYNXTWO_B )
			return( HSTATUS_INVALID_MIXER_CONTROL );
		*pulValue = m_lTrimAO56;
		break;
	}

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalAdapter::SetADHPF( USHORT usControl, BOOLEAN bEnable )
/////////////////////////////////////////////////////////////////////////////
{
	// no need to check for validity of usControl here...
	// ADCs are pin-controlled.  Doesn't matter if the ADC don't exist
	switch( usControl )
	{
	case CONTROL_AIN12_HPF:
		IOWrite( kADC_A_Control, bEnable ? IO_ADC_CNTL_HPFE : IO_ADC_CNTL_ZCAL, IO_ADC_CNTL_HPFE | IO_ADC_CNTL_ZCAL );
		m_bAIn12HPFEnable = bEnable;
		break;
	case CONTROL_AIN34_HPF:
		IOWrite( kADC_B_Control, bEnable ? IO_ADC_CNTL_HPFE : IO_ADC_CNTL_ZCAL, IO_ADC_CNTL_HPFE | IO_ADC_CNTL_ZCAL );
		m_bAIn34HPFEnable = bEnable;
		break;
	case CONTROL_AIN56_HPF:
		IOWrite( kADC_C_Control, bEnable ? IO_ADC_CNTL_HPFE : IO_ADC_CNTL_ZCAL, IO_ADC_CNTL_HPFE | IO_ADC_CNTL_ZCAL );
		m_bAIn56HPFEnable = bEnable;
		break;
	}

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
BOOLEAN	CHalAdapter::GetADHPF( USHORT usControl )
/////////////////////////////////////////////////////////////////////////////
{
	// no need to check for validity of usControl here...
	switch( usControl )
	{
	case CONTROL_AIN12_HPF:	return( m_bAIn12HPFEnable );
	case CONTROL_AIN34_HPF:	return( m_bAIn34HPFEnable );
	case CONTROL_AIN56_HPF:	return( m_bAIn56HPFEnable );
	}
	return( FALSE );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalAdapter::SetConverterSpeed( LONG lSampleRate )
/////////////////////////////////////////////////////////////////////////////
{
	// there are no converters on the AES16...
	if( (m_usDeviceID == PCIDEVICE_LYNX_AES16) || (m_usDeviceID == PCIDEVICE_LYNX_AES16SRC) )
		return( HSTATUS_OK );

	//DPF(("Changing Speed\n"));
	if( lSampleRate <= 50000 )
	{
		BYTE	ucMode = IO_DAC_CNTL_MODE_1X_EMPOFF;

		// Setup the ADCs (pin-controlled)
		IOWrite( kADC_A_Control, IO_ADC_CNTL_DFS_1X, IO_ADC_CNTL_DFS_MASK );
		IOWrite( kADC_B_Control, IO_ADC_CNTL_DFS_1X, IO_ADC_CNTL_DFS_MASK );
		IOWrite( kADC_C_Control, IO_ADC_CNTL_DFS_1X, IO_ADC_CNTL_DFS_MASK );

		if( m_bDACDeEmphasis )
		{
			// Half-way between 44.1khz & 32kHz
			if( lSampleRate < 38050 )		ucMode = IO_DAC_CNTL_MODE_1X_EMP32K;
			// Half-way between 48kHz & 44.1kHz
			else if( lSampleRate < 46050 )	ucMode = IO_DAC_CNTL_MODE_1X_EMP44K;
			// Everything else is 48kHz
			else							ucMode = IO_DAC_CNTL_MODE_1X_EMP48K;
		}
		
		// Setup the DACs (serial-controlled)
		IOWrite( kDAC_A_Control, ucMode, IO_DAC_CNTL_MODE_MASK );
		if( (m_usDeviceID == PCIDEVICE_LYNXTWO_A) || (m_usDeviceID == PCIDEVICE_LYNXTWO_B) )
			IOWrite( kDAC_B_Control, ucMode, IO_DAC_CNTL_MODE_MASK );
		if( m_usDeviceID == PCIDEVICE_LYNXTWO_B )
			IOWrite( kDAC_C_Control, ucMode, IO_DAC_CNTL_MODE_MASK );
	}
	else if( lSampleRate <= 100000 )
	{
		IOWrite( kADC_A_Control, IO_ADC_CNTL_DFS_2X,  IO_ADC_CNTL_DFS_MASK );
		IOWrite( kADC_B_Control, IO_ADC_CNTL_DFS_2X,  IO_ADC_CNTL_DFS_MASK );
		IOWrite( kADC_C_Control, IO_ADC_CNTL_DFS_2X,  IO_ADC_CNTL_DFS_MASK );
		
		IOWrite( kDAC_A_Control, IO_DAC_CNTL_MODE_2X, IO_DAC_CNTL_MODE_MASK );
		if( (m_usDeviceID == PCIDEVICE_LYNXTWO_A) || (m_usDeviceID == PCIDEVICE_LYNXTWO_B) )
			IOWrite( kDAC_B_Control, IO_DAC_CNTL_MODE_2X, IO_DAC_CNTL_MODE_MASK );
		if( m_usDeviceID == PCIDEVICE_LYNXTWO_B )
			IOWrite( kDAC_C_Control, IO_DAC_CNTL_MODE_2X, IO_DAC_CNTL_MODE_MASK );
	}
	else // above 100kHz
	{
		IOWrite( kADC_A_Control, IO_ADC_CNTL_DFS_4X,  IO_ADC_CNTL_DFS_MASK );
		IOWrite( kADC_B_Control, IO_ADC_CNTL_DFS_4X,  IO_ADC_CNTL_DFS_MASK );
		IOWrite( kADC_C_Control, IO_ADC_CNTL_DFS_4X,  IO_ADC_CNTL_DFS_MASK );

		IOWrite( kDAC_A_Control, IO_DAC_CNTL_MODE_4X, IO_DAC_CNTL_MODE_MASK );
		if( (m_usDeviceID == PCIDEVICE_LYNXTWO_A) || (m_usDeviceID == PCIDEVICE_LYNXTWO_B) )
			IOWrite( kDAC_B_Control, IO_DAC_CNTL_MODE_4X, IO_DAC_CNTL_MODE_MASK );
		if( m_usDeviceID == PCIDEVICE_LYNXTWO_B )
			IOWrite( kDAC_C_Control, IO_DAC_CNTL_MODE_4X, IO_DAC_CNTL_MODE_MASK );
	}

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalAdapter::SetDADeEmphasis( BOOLEAN bEnable )
/////////////////////////////////////////////////////////////////////////////
{
	LONG	lRate;

	m_SampleClock.Get( &lRate );

	m_bDACDeEmphasis = bEnable;

	// Setting the converter speed also changes the de-emphasis bits on the DACs
	SetConverterSpeed( lRate );

	return( HSTATUS_OK );
}

////////////////////////////////////////////////////////////////////////////
USHORT CHalAdapter::CalibrateConverters()
/////////////////////////////////////////////////////////////////////////////
{
	// there are no converters on the AES16...
	if( (m_usDeviceID == PCIDEVICE_LYNX_AES16) || (m_usDeviceID == PCIDEVICE_LYNX_AES16SRC) )
		return( HSTATUS_OK );

	// enable DC offset calibration on all converters
	IOWrite( kMisc, 0, (IO_MISC_DACARSTn | IO_MISC_DACBRSTn | IO_MISC_DACCRSTn ) ); //reset DAC's
	IOWrite( kADC_A_Control, (BYTE)0, IO_ADC_CNTL_RSTn );
	IOWrite( kADC_B_Control, (BYTE)0, IO_ADC_CNTL_RSTn );
	IOWrite( kADC_C_Control, (BYTE)0, IO_ADC_CNTL_RSTn );

	IOWrite( kMisc, 
		(IO_MISC_DACARSTn | IO_MISC_DACBRSTn | IO_MISC_DACCRSTn ),
		(IO_MISC_DACARSTn | IO_MISC_DACBRSTn | IO_MISC_DACCRSTn ) );

	//Re-write control registers after being cleared by reset
	IOWrite( kDAC_A_Control, (BYTE)0, IO_DAC_CNTL_CAL );
	IOWrite( kDAC_B_Control, (BYTE)0, IO_DAC_CNTL_CAL );
	IOWrite( kDAC_C_Control, (BYTE)0, IO_DAC_CNTL_CAL );

	IOWrite( kADC_A_Control, IO_ADC_CNTL_RSTn, IO_ADC_CNTL_RSTn );
	IOWrite( kADC_B_Control, IO_ADC_CNTL_RSTn, IO_ADC_CNTL_RSTn );
	IOWrite( kADC_C_Control, IO_ADC_CNTL_RSTn, IO_ADC_CNTL_RSTn );

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalAdapter::SetAutoRecalibrate( BOOLEAN bEnable )
/////////////////////////////////////////////////////////////////////////////
{
	m_bAutoRecalibrate = bEnable;
	
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalAdapter::SetDitherType( PHALREGISTER pRMix0Control, USHORT usDitherType )
/////////////////////////////////////////////////////////////////////////////
{
	switch( usDitherType )
	{
	case MIXVAL_DITHER_NONE:
		pRMix0Control->Write( REG_RMIX_DITHERTYPE_NONE, REG_RMIX_DITHERTYPE_MASK );
		break;
	case MIXVAL_DITHER_TRIANGULAR_PDF:
		pRMix0Control->Write( REG_RMIX_DITHERTYPE_TRIANGULAR_PDF, REG_RMIX_DITHERTYPE_MASK );
		break;
	case MIXVAL_DITHER_TRIANGULAR_NS_PDF:
		pRMix0Control->Write( REG_RMIX_DITHERTYPE_TRIANGULAR_PDF_HI_PASS, REG_RMIX_DITHERTYPE_MASK );
		break;
	case MIXVAL_DITHER_RECTANGULAR_PDF:
		pRMix0Control->Write( REG_RMIX_DITHERTYPE_RECTANGULAR_PDF, REG_RMIX_DITHERTYPE_MASK );
		break;
	default:
		return( HSTATUS_INVALID_PARAMETER );
	}
	m_usDitherType = usDitherType;
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalAdapter::SetMTCSource( ULONG ulMTCSource )
/////////////////////////////////////////////////////////////////////////////
{
	// The AES16 doesn't need this control!
	if( (m_usDeviceID == PCIDEVICE_LYNX_AES16) || (m_usDeviceID == PCIDEVICE_LYNX_AES16SRC) )
	{
		return( HSTATUS_INVALID_MIXER_CONTROL );
	}

	switch( ulMTCSource )
	{
	case MIXVAL_MTCSOURCE_LTCRX:
		if( m_usDeviceID == PCIDEVICE_LYNX_L22 )
		{
			// change the default
			if( m_ulMTCSource == MIXVAL_MTCSOURCE_LTCRX )
				m_ulMTCSource = MIXVAL_MTCSOURCE_LSTREAM2_ADAT_SYNCIN;
			return( HSTATUS_INVALID_MIXER_VALUE );
		}
	case MIXVAL_MTCSOURCE_LSTREAM1_ADAT_SYNCIN:
	case MIXVAL_MTCSOURCE_LSTREAM2_ADAT_SYNCIN:
		m_ulMTCSource = ulMTCSource;
		break;
	default:
		return( HSTATUS_INVALID_MIXER_VALUE );
	}
	
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalAdapter::GetMTCSource( PULONG pulMTCSource )
/////////////////////////////////////////////////////////////////////////////
{
	// The AES16 doesn't need this control!
	if( (m_usDeviceID == PCIDEVICE_LYNX_AES16) || (m_usDeviceID == PCIDEVICE_LYNX_AES16SRC) )
	{
		// set the default to Header LStream
		*pulMTCSource = MIXVAL_MTCSOURCE_LSTREAM2_ADAT_SYNCIN;
		return( HSTATUS_INVALID_MIXER_CONTROL );
	}

	*pulMTCSource = m_ulMTCSource;

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalAdapter::SetMultiChannelRecord( LONG lNumChannels )
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulNumberOfChannels;
	int		nDevice;
	PHALWAVEDMADEVICE	pHD;

	if( !m_bHasMultiChannel )
	{
		DPF(("Firmware does not support multi-channel!\n"));
		return( HSTATUS_INVALID_MODE );
	}

	ulNumberOfChannels = (lNumChannels / 2) - 1;

	if( ((ulNumberOfChannels + 1) * 2) != (ULONG)lNumChannels )
		return( HSTATUS_INVALID_PARAMETER );

	// aquire all the record devices on this adapter (except device 0, 
	// which should already be aquired by the driver)
	for( nDevice = WAVE_RECORD1_DEVICE; nDevice <= WAVE_RECORD7_DEVICE; nDevice++ )
	{
		pHD = GetWaveDMADevice( nDevice );
		if( pHD->Aquire() )
		{
			ClearMultiChannelRecord();
			return( HSTATUS_ALREADY_IN_USE );
		}
		
		// call *just* the base class start method so the device looks active
		//((CHalDevice *)pHD)->Start();
	}
	
	m_RegSTRMCTL.Write( REG_STRMCTL_RMULTI | (ulNumberOfChannels<<REG_STRMCTL_RNUMCHNL_OFFSET), REG_STRMCTL_RMULTI | REG_STRMCTL_RNUMCHNL_MASK );

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalAdapter::ClearMultiChannelRecord( void )
/////////////////////////////////////////////////////////////////////////////
{
	int	nDevice;
	PHALWAVEDMADEVICE	pHD;

	for( nDevice = WAVE_RECORD1_DEVICE; nDevice <= WAVE_RECORD7_DEVICE; nDevice++ )
	{
		pHD = GetWaveDMADevice( nDevice );
		pHD->Release();

		// call *just* the base class stop method
		//((CHalDevice *)pHD)->Stop();
	}

	m_RegSTRMCTL.Write( 0, REG_STRMCTL_RMULTI | REG_STRMCTL_RNUMCHNL_MASK );

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalAdapter::SetMultiChannelPlay( LONG lNumChannels )
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulNumberOfChannels;
	int		nDevice;
	PHALWAVEDMADEVICE	pHD;

	if( !m_bHasMultiChannel )
	{
		DPF(("Firmware does not support multi-channel!\n"));
		return( HSTATUS_INVALID_MODE );
	}

	//DPF(("SetMultiChannelPlay %ld\n", lNumChannels ));

	ulNumberOfChannels = (lNumChannels / 2) - 1;

	if( ((ulNumberOfChannels + 1) * 2) != (ULONG)lNumChannels )
	{
		DPF(("lNumChannels does not match!\n"));
		return( HSTATUS_INVALID_PARAMETER );
	}

	// aquire all the play devices on this adapter (except device 0, 
	// which should already be aquired by the driver)
	for( nDevice = WAVE_PLAY1_DEVICE; nDevice <= WAVE_PLAY7_DEVICE; nDevice++ )
	{
		pHD = GetWaveDMADevice( nDevice );
		if( pHD->Aquire() )
		{
			ClearMultiChannelPlay();
			DPF(("A Device Already In Use!\n"));
			return( HSTATUS_ALREADY_IN_USE );
		}
		
		// call *just* the base class start method so the device looks active
		//((CHalDevice *)pHD)->Start();
	}
	
	m_RegSTRMCTL.Write( REG_STRMCTL_PMULTI | (ulNumberOfChannels<<REG_STRMCTL_PNUMCHNL_OFFSET), REG_STRMCTL_PMULTI | REG_STRMCTL_PNUMCHNL_MASK );

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalAdapter::ClearMultiChannelPlay( void )
/////////////////////////////////////////////////////////////////////////////
{
	int	nDevice;
	PHALWAVEDMADEVICE	pHD;

	//DPF(("ClearMultiChannelPlay\n"));

	for( nDevice = WAVE_PLAY1_DEVICE; nDevice <= WAVE_PLAY7_DEVICE; nDevice++ )
	{
		pHD = GetWaveDMADevice( nDevice );
		pHD->Release();

		// call *just* the base class stop method
		//((CHalDevice *)pHD)->Stop();
	}

	m_RegSTRMCTL.Write( 0, REG_STRMCTL_PMULTI | REG_STRMCTL_PNUMCHNL_MASK );

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalAdapter::SaveInterruptContext( ULONG ulAISTAT, ULONG ulMISTAT )
// Called at interrupt time
/////////////////////////////////////////////////////////////////////////////
{
	USHORT	usStatus = HSTATUS_OK;

	//DPET();

	//DC('I');
	if( !m_bOpen )
	{
		DB('!',COLOR_BOLD);
		DPF(("SaveInterruptContext called when adapter is not open!\n"));
		return( HSTATUS_ADAPTER_NOT_OPEN );
	}
	
	//if( m_lEntryCount )
	//{
	//	DPF(("Entry Count Non-Zero!\n"));
	//}
	//m_lEntryCount++;

	LONG lNumberOfPendingInterrupts = (LONG)m_ulICHead - (LONG)m_ulICTail;
	if( lNumberOfPendingInterrupts < 0 )
		lNumberOfPendingInterrupts += MAX_PENDING_INTERRUPTS;

	// don't think this can ever happen the way the above is coded
	if( lNumberOfPendingInterrupts >= MAX_PENDING_INTERRUPTS )
	{
		DB('E',COLOR_BOLD);
		DPF(("Exceeded Maximum Pending Interrupts!\n"));
		return( HSTATUS_INVALID_PARAMETER );
	}

	if( lNumberOfPendingInterrupts < 0 )
	{
		DPF(("lNumberOfPendingInterrupts < 0!\n"));
	}
	//DX8((BYTE)lNumberOfPendingInterrupts, COLOR_REVERSE);

	if( ulMISTAT )	m_aInterruptContext[ m_ulICHead ].MISTAT = ulMISTAT;
	else			m_aInterruptContext[ m_ulICHead ].MISTAT = READ_REGISTER_ULONG( &m_pRegisters->MISTAT );
	if( ulAISTAT )	m_aInterruptContext[ m_ulICHead ].AISTAT = ulAISTAT;
	else			m_aInterruptContext[ m_ulICHead ].AISTAT = READ_REGISTER_ULONG( &m_pRegisters->AISTAT );

	// Clear the CNFDI bit in case it was set - so the compare to zero later in this function will work properly
	CLR( m_aInterruptContext[ m_ulICHead ].MISTAT, REG_MISTAT_CNFDI );

	//DPET();
	//DC(' ');
	//DX32( m_aInterruptContext[ m_ulICHead ].AISTAT, COLOR_UNDERLINE );
	//DC(' ');
	//DX32( m_aInterruptContext[ m_ulICHead ].MISTAT, COLOR_UNDERLINE );
	//DC(' ');
	//DPF(("AISTAT %08lx MISTAT %08lx\n", 
	//	m_aInterruptContext[ m_ulICHead ].AISTAT, 
	//	m_aInterruptContext[ m_ulICHead ].MISTAT ));

#ifdef WIN32USER
#ifndef USE_HARDWARE
	//m_aInterruptContext[ m_ulICHead ].MISTAT = 0;
	//m_aInterruptContext[ m_ulICHead ].AISTAT = 1<<WAVE_PLAY0_DEVICE;
#endif
#endif

	// CS8420 interrupt flag
	if( m_aInterruptContext[ m_ulICHead ].MISTAT & REG_MISTAT_RX8420 )
	{
		if( m_bHasCS8420 )
		{
			m_CS8420.Service();	// Cannot call driver
		}
		CLR( m_aInterruptContext[ m_ulICHead ].MISTAT, REG_MISTAT_RX8420 );
		usStatus = HSTATUS_SERVICE_NOT_REQUIRED;
	}

	// Option port status received interrupt
	if( m_aInterruptContext[ m_ulICHead ].MISTAT & REG_MISTAT_OPSTATIF )
	{
		CLR( m_aInterruptContext[ m_ulICHead ].MISTAT, REG_MISTAT_OPSTATIF );
		usStatus = m_LStream.Service();
		switch( usStatus )
		{
		case HSTATUS_MIDI1_SERVICE_REQUIRED:
			SET( m_aInterruptContext[ m_ulICHead ].MISTAT, REG_MISTAT_MIDI1 );
			usStatus = HSTATUS_OK;
			break;
		case HSTATUS_MIDI2_SERVICE_REQUIRED:
			SET( m_aInterruptContext[ m_ulICHead ].MISTAT, REG_MISTAT_MIDI2 );
			usStatus = HSTATUS_OK;
			break;
		default:
			usStatus = HSTATUS_SERVICE_NOT_REQUIRED;
			break;
		}
	}
/*
	// scan each wave device for an interrupt
	for( ULONG ulDevice=0; ulDevice<NUM_WAVE_DEVICES; ulDevice++ )
	{
		// check for the limit/overrun buffer interrupt flag
		if( m_aInterruptContext[ m_ulICHead ].AISTAT & (1<<ulDevice) )
		{
			if( m_WaveDevice[ ulDevice ].IsDMAActive() )
			{
				// disable any futher limit interrupts
				if( m_WaveDevice[ ulDevice ].GetLimitIE() )
				{
					m_WaveDevice[ ulDevice ].GetStreamControl()->BitSet( REG_STREAMCTL_LIMIE, FALSE );	// disallow further limit interrupts
				}
			}
		}
	}
*/
	if( !m_aInterruptContext[ m_ulICHead ].MISTAT && !m_aInterruptContext[ m_ulICHead ].AISTAT )
	{
		if( usStatus == HSTATUS_OK )
		{
		  //DPF(("CHalAdapter::SaveInterruptContext - No Service Required!\n"));
			DB('N',COLOR_BOLD);
			usStatus = HSTATUS_INVALID_MODE;
		}
	}
	else
	{
		m_ulICHead++;
		m_ulICHead &= (MAX_PENDING_INTERRUPTS-1);
		//m_lNumPendingInterrupts++;
		//DB('+',COLOR_REVERSE);
		usStatus = HSTATUS_OK;
	}

	//m_lEntryCount--;
	return( usStatus );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalAdapter::Service( BOOLEAN bPolled )
// Called at interrupt time
/////////////////////////////////////////////////////////////////////////////
{
	PLYNXTWOINTERRUPTCONTEXT	pInterrupt;
	ULONG	ulDevice;
	USHORT	usStatus;

	if( !m_bOpen )
	{
		DB('!',COLOR_BOLD_U);
		DPF(("Service called when adapter is not open!\n"));
		return( HSTATUS_ADAPTER_NOT_OPEN );
	}

	//DB('s',COLOR_UNDERLINE);
	//DPF(("CHalAdapter::Service\n"));

	if( bPolled )
	{
		usStatus = SaveInterruptContext();
		if( usStatus )
			return( usStatus );
	}

	LONG lNumberOfPendingInterrupts = (LONG)m_ulICHead - (LONG)m_ulICTail;
	if( lNumberOfPendingInterrupts < 0 )
		lNumberOfPendingInterrupts += MAX_PENDING_INTERRUPTS;

	//DX8((BYTE)lNumberOfPendingInterrupts, COLOR_REVERSE);

	// fetch an interrupt context off the circular buffer
	if( lNumberOfPendingInterrupts < 1 )
	{
		DB('I',COLOR_BOLD);
		//DPF(("Service - No Interrupt!\n"));
		return( HSTATUS_INVALID_MODE );
	}

	pInterrupt = &m_aInterruptContext[ m_ulICTail++ ];
	m_ulICTail &= (MAX_PENDING_INTERRUPTS-1);

	//DX32( pInterrupt->AISTAT, COLOR_UNDERLINE );

	if( m_bHasLTC )
	{
		// LTC receive buffer A
		if( pInterrupt->MISTAT & REG_MISTAT_LRXAIF )
		{
			m_TimecodeRX.Service( TC_BUFFERA );
		}
		// LTC receive buffer B
		if( pInterrupt->MISTAT & REG_MISTAT_LRXBIF )
		{
			m_TimecodeRX.Service( TC_BUFFERB );
		}
		// LTC transmit buffer A
		if( pInterrupt->MISTAT & REG_MISTAT_LTXAIF )
		{
			m_TimecodeTX.Service( TC_BUFFERA );
		}
		// LTC transmit buffer B
		if( pInterrupt->MISTAT & REG_MISTAT_LTXBIF )
		{
			m_TimecodeTX.Service( TC_BUFFERB );
		}
		// MTC Quarter Frame from LTC Receiver
		if( pInterrupt->MISTAT & REG_MISTAT_LRXQFIF )
		{
			m_MIDIDevice[ MIDI_RECORD0_DEVICE ].Service( kMIDIReasonLTCQFM );
		}
	}
	// Does the Phantom MIDI port need service?
	if( pInterrupt->MISTAT & REG_MISTAT_MIDI1 )
	{
		m_MIDIDevice[ MIDI_RECORD0_DEVICE ].Service( kMIDIReasonADATQFM );
	}
	// Does the Phantom MIDI port need service?
	if( pInterrupt->MISTAT & REG_MISTAT_MIDI2 )
	{
		m_MIDIDevice[ MIDI_RECORD0_DEVICE ].Service( kMIDIReasonADATMIDI );
	}

	//DPF(("%08lx %08lx %08lx ", (ULONG)m_pRegisters, &m_pRegisters->SCBlock.PlayStatus[ 0 ], &m_pRegisters->SCBlock.PlayControl[ 0 ] ));

	// scan each wave device for an interrupt
	if( pInterrupt->AISTAT )
	{
		//DPF(("[%08lx]", pInterrupt->AISTAT ));
		//DC('[');
		//DX32( pInterrupt->AISTAT, COLOR_UNDERLINE );
		//DC(']');
		//DX16( (USHORT)pInterrupt->AISTAT, COLOR_UNDERLINE );

#ifdef INTERRUPT_TIMING
#ifdef MACINTOSH
		LONGLONG	llTime = SoundGetTime();
		LONG		lElapsed;
	
		lElapsed = (LONG)(llTime - gllLastTime);
		char szBuffer[30];
		sprintf( szBuffer, "%2.3lf", (double)lElapsed/1000.0 );
		DS( szBuffer, COLOR_NORMAL );
		gllLastTime = llTime;
#else
		DPET();
#endif
#endif
		// scan each wave device for an interrupt
		for( ulDevice=0; ulDevice<NUM_WAVE_DEVICES; ulDevice++ )
		{
			// check for the limit/overrun buffer interrupt flag
			if( pInterrupt->AISTAT & (1<<ulDevice) )
			{
				if( m_WaveDevice[ ulDevice ].IsDMAActive() )
					GetWaveDMADevice( ulDevice )->Service();
				else
					GetWaveDevice( ulDevice )->Service();
			}

			// check for the DMA interrupt flag
			if( (pInterrupt->AISTAT >> NUM_WAVE_DEVICES) & (1<<ulDevice) )
			{
				GetWaveDMADevice( ulDevice )->Service( TRUE );
			}
		}
	}

	// we are done with this interrupt context
	pInterrupt->MISTAT = 0;
	pInterrupt->AISTAT = 0;
	//m_lNumPendingInterrupts--;
	//DB('-',COLOR_REVERSE);

	return( HSTATUS_OK );
}

