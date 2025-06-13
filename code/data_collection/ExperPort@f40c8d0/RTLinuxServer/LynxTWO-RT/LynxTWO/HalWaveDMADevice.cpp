/****************************************************************************
 HalWaveDMADevice.cpp

 Description: 

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

#include <StdAfx.h>
#include "HalAdapter.h"

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalWaveDMADevice::Open( PHALADAPTER pHalAdapter, ULONG ulDeviceNumber )
/////////////////////////////////////////////////////////////////////////////
{
	m_DMA.Open( pHalAdapter, ulDeviceNumber );

	m_bIsDMAActive	= FALSE;
	m_bAutoFree		= TRUE;
	m_bOverrunIE	= FALSE;
	m_bLimitIE		= FALSE;
	m_bDMASingle	= FALSE;
	m_bDualMono		= FALSE;
	
	return( CHalWaveDevice::Open( pHalAdapter, ulDeviceNumber ) );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalWaveDMADevice::Close()
/////////////////////////////////////////////////////////////////////////////
{
	Stop();
	
	m_DMA.Close();

	return( CHalWaveDevice::Close() );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalWaveDMADevice::Start( BOOLEAN bDoPreload /* = TRUE */ )
/////////////////////////////////////////////////////////////////////////////
{
	LONG			lCurrentRate;
	PHALSAMPLECLOCK	pClock;
	PHALMIXER		pMixer = m_pHalAdapter->GetMixer();
	USHORT			usDst, usSrc;
	ULONG			ulStreamControl = 0;

	//DPF(("CHalWaveDMADevice::Start %ld\n", m_ulDeviceNumber ));

	m_bIsDMAActive = TRUE;

	// if the sample rate is not the same as the current sample rate on the card, change it...
	pClock = m_pHalAdapter->GetSampleClock();
	pClock->Get( &lCurrentRate );
	if( lCurrentRate != m_lSampleRate )
		if( pClock->Set( m_lSampleRate ) )
			return( HSTATUS_INVALID_SAMPLERATE );

	// set the bits for the sample format
	switch( m_lBitsPerSample )
	{
	case 8:		SET( ulStreamControl, REG_STREAMCTL_FMT_PCM8 );		break;
	case 16:	SET( ulStreamControl, REG_STREAMCTL_FMT_PCM16 );	break;
	case 24:	SET( ulStreamControl, REG_STREAMCTL_FMT_PCM24 );	break;
	case 32:	SET( ulStreamControl, REG_STREAMCTL_FMT_PCM32 );	break;
	}

	// determine which mixer line this is
	if( m_bIsRecord )
	{
		usDst = LINE_RECORD_0 + (USHORT)m_ulDeviceNumber;
		usSrc = LINE_NO_SOURCE;
	}
	else
	{
		usDst = LINE_OUT_1;
		usSrc = LINE_PLAY_0 + ((USHORT)m_ulDeviceNumber - NUM_WAVE_RECORD_DEVICES);
	}

	// if this is a record device, set the dither depth (this only does something when the dither depth is auto
	if( m_bIsRecord )
	{
		pMixer->SetControl( usDst, usSrc, CONTROL_DITHER_DEPTH, LEFT, (ULONG)m_lBitsPerSample );
		pMixer->SetControl( usDst, usSrc, CONTROL_DITHER_DEPTH, RIGHT, (ULONG)m_lBitsPerSample );
	}
	
	// if this device is in stereo mode, set the appropriate bit
	if( m_lNumChannels == 2 )
		SET( ulStreamControl, REG_STREAMCTL_CHNUM_STEREO );

	if( m_lNumChannels > 2 )
	{
		if( m_ulDeviceNumber == WAVE_RECORD0_DEVICE )
		{
			if( m_pHalAdapter->SetMultiChannelRecord( m_lNumChannels ) )
				return( HSTATUS_ALREADY_IN_USE );
		}
		else if( m_ulDeviceNumber == WAVE_PLAY0_DEVICE )
		{
			if( m_pHalAdapter->SetMultiChannelPlay( m_lNumChannels ) )
				return( HSTATUS_ALREADY_IN_USE );
		}
		else
		{
			return( HSTATUS_INVALID_FORMAT );
		}
	}

	m_ulOverrunCount = 0;
	pMixer->ControlChanged( usDst, usSrc, CONTROL_OVERRUN_COUNT );

	// the format has changed, inform the driver
	pMixer->ControlChanged( usDst, usSrc, CONTROL_SAMPLE_FORMAT );

	// Check for WAVE_FORMAT_DOLBY_AC3_SPDIF and route this play device to the Digital Output.
	// Only do this on cards that have an CS8420
	if( m_pHalAdapter->HasCS8420() && (m_wFormatTag == WAVE_FORMAT_DOLBY_AC3_SPDIF) && (m_ulDeviceNumber >= WAVE_PLAY0_DEVICE) )
	{
		PrepareForNonPCM();
	}

	// Write the control register to the hardware
	m_RegStreamControl.Write( ulStreamControl );

	// start the DMA channel
	m_DMA.Start(bDoPreload);

	// note that we call the CHalDevice parent class, not CHalWaveDevice!
	return( CHalDevice::Start() );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalWaveDMADevice::Stop()
/////////////////////////////////////////////////////////////////////////////
{
	//DPF(("CHalWaveDMADevice::Stop %ld\n", m_ulDeviceNumber ));

	// stop the DMA channel
	m_DMA.Stop();

	m_bIsDMAActive	= FALSE;
	m_bOverrunIE	= FALSE;
	m_bLimitIE		= FALSE;
	m_bDMASingle	= FALSE;
	m_bDualMono		= FALSE;
	m_bAutoFree		= TRUE;		// DAH Oct 4, 2004

	if( m_lNumChannels > 2 )
	{
		if( m_ulDeviceNumber == WAVE_RECORD0_DEVICE )
		{
			m_pHalAdapter->ClearMultiChannelRecord();
		}
		else if( m_ulDeviceNumber == WAVE_PLAY0_DEVICE )
		{
			m_pHalAdapter->ClearMultiChannelPlay();
		}
	}

	// and call the parent class
	return( CHalWaveDevice::Stop() );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalWaveDMADevice::Service( BOOLEAN bDMABufferComplete )
// Called at interrupt time to service the DMA
// There could be several reasons why this gets called:
//	1. Over/Under run interrupt
//	2. Limit interrupt
//	3. DMA buffer completed
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulReason		= kReasonDMALimit;	// assume this is a limit interrupt
	ULONG	ulStreamStatus	= m_RegStreamStatus.Read();
#ifdef DEBUG
	ULONG	ulStreamControl = m_RegStreamControl.Read();
	(void) ulStreamControl;

	//DB('d',COLOR_BOLD);	DX8( (BYTE)m_ulDeviceNumber, COLOR_NORMAL );
	//	DPF(("CHalWaveDMADevice::Service\n"));

	DC('[');
	DX16( (USHORT)(ulStreamStatus & REG_STREAMSTAT_L2PTR_MASK), COLOR_NORMAL );
	DC(',');
	DX16( (USHORT)(ulStreamControl & REG_STREAMCTL_PCPTR_MASK), COLOR_NORMAL );
	DC(']');
#endif

	if( bDMABufferComplete )
	{
		DC('D');
		ulReason = kReasonDMABufferComplete;
		DPF(("DMA Buffer Complete on %d\n", (int)GetDeviceNumber()));
	}
	else	// make the limit reason mutually-exclusive to the DMA Buffer Complete reason
	// was the limit hit bit set?
	// NOTE: It is possible that the limit bit may be cleared by the hardware 
	// before the PC has time to read the stream status register.
	if( ulStreamStatus & REG_STREAMSTAT_LIMHIT )
	{
		DC('L');
		DPF(("DMA Limit Hit on %d\n",  (int)GetDeviceNumber()));
		ulReason = kReasonDMALimit;
	}

	// was the overrun bit set? (Note: This overrides kReasonDMABufferComplete or kReasonDMALimit)
	if( ulStreamStatus & REG_STREAMSTAT_OVER )
	{
		DB('O',COLOR_BOLD_U);
		m_ulOverrunCount++;
		DPF(("DMA Overrun Detected %lu on %d\n",m_ulOverrunCount,  (int)GetDeviceNumber()));
		ulReason = kReasonDMAEmpty;
	}

	if( ulReason != kReasonDMAEmpty )
	{
		// free an entry from the DMA list
		if( m_bAutoFree )
			m_DMA.FreeEntry();
	}

	// let the driver service the interrupt for this device
	CHalDevice::Service( ulReason );

	return( HSTATUS_OK );
}
