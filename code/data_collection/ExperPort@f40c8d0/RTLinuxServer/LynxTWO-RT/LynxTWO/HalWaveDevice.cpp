/****************************************************************************
 HalWaveDevice.cpp

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
 Dec 03 03 DAH	Added code to Validate to insure the requested sample rate is 
				the same as the currently selected sample rate if any devices
				are already active.
 Jun 17 03 DAH	Added SetSamplePosition
 Jun 04 03 DAH	Added GetSamplePosition
****************************************************************************/

#include <StdAfx.h>
#include "HalAdapter.h"

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalWaveDevice::Open( PHALADAPTER pHalAdapter, ULONG ulDeviceNumber )
/////////////////////////////////////////////////////////////////////////////
{
	m_bIsRecord = (ulDeviceNumber < NUM_WAVE_RECORD_DEVICES) ? TRUE : FALSE;

	//DPF(("CHalWaveDevice::Open %lu\n", ulDeviceNumber ));

	// assign the target mode address for this devices buffer
	// play devices are after record devices so this will work for both
	m_pAudioBuffer = (PULONG)&pHalAdapter->GetAudioBuffers()->Record[ ulDeviceNumber ];
	m_RegStreamControl.Init( &pHalAdapter->GetRegisters()->SCBlock.RecordControl[ ulDeviceNumber ] );
	m_RegStreamStatus.Init( &pHalAdapter->GetRegisters()->SCBlock.RecordStatus[ ulDeviceNumber ], REG_READONLY );

	m_RegStreamControl.Write( 0 );	// init the stream control register
	
	m_lHWIndex				= 0;
	m_lPCIndex				= 0;
	m_ulInterruptSamples	= 0;
	m_ulBytesTransferred	= 0;
	m_ulSamplesTransferred	= 0;
	m_ulOverrunCount		= 0;
	m_bSyncStartEnabled		= FALSE;
	
	m_wFormatTag			= WAVE_FORMAT_PCM;
	m_lNumChannels			= 2;
	m_lSampleRate			= 44100;
	m_lBitsPerSample		= 24;
	m_lBytesPerBlock		= (m_lBitsPerSample * m_lNumChannels) / 8;

	m_ulGBPEntryCount		= 0;
	m_lGBPLastHWIndex		= 0;
	m_ullBytePosition		= 0;

	return( CHalDevice::Open( pHalAdapter, ulDeviceNumber ) );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalWaveDevice::Close()
/////////////////////////////////////////////////////////////////////////////
{
	return( CHalDevice::Close() );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalWaveDevice::Start()
/////////////////////////////////////////////////////////////////////////////
{
	LONG			lCurrentRate;
	PHALSAMPLECLOCK	pClock;
	PHALMIXER		pMixer = m_pHalAdapter->GetMixer();
	USHORT			usDst, usSrc;
	ULONG			ulStreamControl = m_lPCIndex & REG_STREAMCTL_PCPTR_MASK;

	DS(" Start ",COLOR_BOLD);	DX8( (BYTE)m_ulDeviceNumber, COLOR_BOLD );	DC(' ');
	//DPF(("CHalWaveDevice::Start %ld\n", m_ulDeviceNumber ));

	// if the sample rate is not the same as the current sample rate on the card, change it...
	pClock = m_pHalAdapter->GetSampleClock();
	pClock->Get( &lCurrentRate );
	if( lCurrentRate != m_lSampleRate )
		if( pClock->Set( m_lSampleRate ) )
			return( HSTATUS_INVALID_SAMPLERATE );

	if( !m_ulInterruptSamples )
		SetInterruptSamples( 0 );	// make sure the interrupt samples gets set for this sample rate

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

	// if this is a record device, set the dither depth
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

	// Enable the IO Processor and the Limit Interrupt
	SET( ulStreamControl, (REG_STREAMCTL_LIMIE | REG_STREAMCTL_OVERIE) );

	// It is OK to set these to zero here, because the hardware hasn't been put into play mode yet (HWIndex is really zero).
	m_ulGBPEntryCount		= 0;
	m_lGBPLastHWIndex		= 0;

	//m_lHWIndex				= 0;	don't set the HWIndex to zero here, do it in the Stop code instead
	m_ulOverrunCount		= 0;
	pMixer->ControlChanged( usDst, usSrc, CONTROL_OVERRUN_COUNT );

	// the format has changed, inform the driver
	pMixer->ControlChanged( usDst, usSrc, CONTROL_SAMPLE_FORMAT );

	// Check for WAVE_FORMAT_DOLBY_AC3_SPDIF and route this play device to the Digital Output.
	// Only do this on cards that have an CS8420
	if( m_pHalAdapter->HasCS8420() && (m_wFormatTag == WAVE_FORMAT_DOLBY_AC3_SPDIF) && (m_ulDeviceNumber >= WAVE_PLAY0_DEVICE) )
	{
		PrepareForNonPCM();
	}

	if( m_bSyncStartEnabled )
	{
		// only firmware 16 & above has sync start enabled
		if( m_pHalAdapter->HasGlobalSyncStart() )
		{
			SET( ulStreamControl, REG_STREAMCTL_MODE_SYNCREADY );
			DPF(("MODE_SYNCREADY\n"));
		}
		else
		{
			SET( ulStreamControl, REG_STREAMCTL_MODE_RUN );
			DPF(("MODE_RUN\n"));
		}

		DPF(("SynStartReady [%04lx]\n", ulStreamControl & REG_STREAMCTL_FMT_MASK ));
		m_pHalAdapter->SyncStartReady( m_ulDeviceNumber, ulStreamControl );
		// reset the sync start enabled status for next time.
		m_bSyncStartEnabled = FALSE;
	}
	else
	{
		DPF(("Starting Device...\n"));
		// Write the control register to the hardware
		SET( ulStreamControl, REG_STREAMCTL_MODE_RUN );
		m_RegStreamControl = ulStreamControl;
	}

	return( CHalDevice::Start() );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalWaveDevice::Stop()
/////////////////////////////////////////////////////////////////////////////
{
	DisableSyncStart();

	//DPF(("CHalWaveDevice::Stop %ld\n", m_ulDeviceNumber ));
	if( m_usMode == MODE_RUNNING )
	{
		DS(" Stop ",COLOR_BOLD);	DX8( (BYTE)m_ulDeviceNumber, COLOR_BOLD );	DC(' ');

		// stop the device first
		m_RegStreamControl.BitSet( 
			(REG_STREAMCTL_PCPTR_MASK |
			 REG_STREAMCTL_MODE_MASK |
			 REG_STREAMCTL_DMAEN |
			 REG_STREAMCTL_LIMIE |
			 REG_STREAMCTL_OVERIE), FALSE );

		// reset the member variables to reflect the device is stopped
		m_ulBytesTransferred	= 0;	// no longer used
		m_ulSamplesTransferred	= 0;
		m_lHWIndex				= 0;
		m_lPCIndex				= 0;

		m_ulGBPEntryCount		= 0;
		m_lGBPLastHWIndex		= 0;
		
		// must reflect stopped status before calling SetInterruptSamples
		CHalDevice::Stop();

		SetInterruptSamples( 0 );
		
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
	}
	
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalWaveDevice::EnableSyncStart()
/////////////////////////////////////////////////////////////////////////////
{
	if( m_pHalAdapter->GetSyncStartState() )
	{
		//DPF(("Adding Device to Start Group\n"));
		m_bSyncStartEnabled = TRUE;
		m_pHalAdapter->AddToStartGroup( m_ulDeviceNumber );
	}
	else
	{
		DPF(("Adapter SyncStart Disabled\n"));
	}
	
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalWaveDevice::DisableSyncStart()
// This is used to insure that any devices that Stop, are no longer part of
// the StartGroup
/////////////////////////////////////////////////////////////////////////////
{
	m_bSyncStartEnabled = FALSE;
	m_pHalAdapter->RemoveFromStartGroup( m_ulDeviceNumber );
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalWaveDevice::SetFormat( USHORT wFormatTag, LONG lChannels, LONG lSampleRate, LONG lBitsPerSample, LONG lBlockAlign )
// This doesn't actually touch the hardware - all format changes are done
// when the device goes into RUN mode.
/////////////////////////////////////////////////////////////////////////////
{
	USHORT	usStatus;

	//DPF(("CHalWaveDevice::SetFormat\n"));

	// must check to see if device is idle first
	if( m_usMode != MODE_STOP )
	{
		DPF(("CHalWaveDevice::SetFormat: Device Not IDLE!\n"));
		return( HSTATUS_INVALID_MODE );
	}
	
	// make sure this is a valid format
	usStatus = ValidateFormat( wFormatTag, lChannels, lSampleRate, lBitsPerSample, lBlockAlign );
	if( usStatus )
		return( usStatus );

	// remember the format for our device
	m_wFormatTag		= wFormatTag;
	m_lNumChannels		= lChannels;
	m_lSampleRate		= lSampleRate;
	m_lBitsPerSample	= lBitsPerSample;
	m_lBytesPerBlock	= lBlockAlign;

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalWaveDevice::ValidateFormat( USHORT wFormatTag, LONG lChannels, LONG lSampleRate, LONG lBitsPerSample, LONG lBlockAlign )
/////////////////////////////////////////////////////////////////////////////
{
	//DPF(("CHalWaveDevice::ValidateFormat\n"));

	// Validate wFormatTag field
	if( (wFormatTag != WAVE_FORMAT_PCM) && (wFormatTag != WAVE_FORMAT_DOLBY_AC3_SPDIF) )
	{
		//DPF(("CHalWaveDevice::Validate: Not WAVE_FORMAT_PCM!"));
		
		DPF(("Format [%04x] ",	wFormatTag ));
		DPF(("Ch [%ld] ",		lChannels ));
		DPF(("SR [%ld] ",		lSampleRate ));
		DPF(("Bits [%ld]\n",	lBitsPerSample ));

		return( HSTATUS_INVALID_FORMAT );
	}

	//BUGBUG
	// keep 24-bit mono from going through
//	if( (pWaveFormat->wBitsPerSample == 24) && (pWaveFormat->nChannels == 1) )
//	{
//		DPF(("CHalWaveDevice::Validate: Cannot do 24-bit mono!\n"));
//		return( HSTATUS_INVALID_FORMAT );
//	}

	// Validate wBitsPerSample field
	if( (lBitsPerSample != 8) 
	 && (lBitsPerSample != 16)
	 && (lBitsPerSample != 24)
	 && (lBitsPerSample != 32) )
	{
		DPF(("CHalWaveDevice::Validate: Format Not 8, 16, 24 or 32 bits!\n"));
		return( HSTATUS_INVALID_FORMAT );
	}
		
	// Validate nChannels field
	if( lChannels < 1 )
	{
		DPF(("CHalWaveDevice::Validate: Invalid nChannels!\n"));
		return( HSTATUS_INVALID_FORMAT );
	}
	if( m_pHalAdapter->HasMultiChannel() )
	{
		if( lChannels > 16 )
		{
			DPF(("CHalWaveDevice::Validate: Invalid nChannels!\n"));
			return( HSTATUS_INVALID_FORMAT );
		}
	}
	else
	{
		if( lChannels > 2 )
		{
			DPF(("CHalWaveDevice::Validate: Invalid nChannels!\n"));
			return( HSTATUS_INVALID_FORMAT );
		}
	}

	// the lowest sample rate for the AES16 is 32kHz, highest is 192kHz
	if( m_pHalAdapter->Get4114() )
	{
		if( lSampleRate < 32000 )
		{
			return( HSTATUS_INVALID_SAMPLERATE );
		}
		if( lSampleRate > 192000 )
		{
			return( HSTATUS_INVALID_SAMPLERATE );
		}
	}

	// if any other devices on the card are active, limit the sample rate to the currently selected rate
	if( m_pHalAdapter->GetNumActiveWaveDevices() )
	{
		LONG	lCurrentRate;

		m_pHalAdapter->GetSampleClock()->Get( &lCurrentRate );
		if( lCurrentRate != lSampleRate )
		{
			DPF(("CHalWaveDevice::Validate: lSampleRate doesn't match rate of running devices!  Requested: %ld  RunningDevs: %ld\n", lSampleRate, lCurrentRate));
			return( HSTATUS_INVALID_SAMPLERATE );
		}
	}

	// Validate nSamplesPerSec field
	if( lSampleRate < MIN_SAMPLE_RATE )
	{
		DPF(("CHalWaveDevice::Validate: Invalid lSampleRate! %lu\n", lSampleRate ));
		return( HSTATUS_INVALID_SAMPLERATE );
	}

	if( lSampleRate > MAX_SAMPLE_RATE )
	{
		DPF(("CHalWaveDevice::Validate: Invalid lSampleRate! %lu\n", lSampleRate ));
		return( HSTATUS_INVALID_SAMPLERATE );
	}

	// Validate lBlockAlign
	if( lBlockAlign != ((lBitsPerSample * lChannels) / 8) )
	{
		DPF(("CHalWaveDevice::Validate: Invalid lBlockAlign %ld!\n", lBlockAlign));
		return( HSTATUS_INVALID_FORMAT );
	}

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalWaveDevice::PrepareForNonPCM( void )
// This code is only useful on a card with a CS8420
/////////////////////////////////////////////////////////////////////////////
{
	PHALMIXER	pMixer = m_pHalAdapter->GetMixer();
	USHORT		usDstLine, usSrcLine;
	ULONG		ulSource;
	ULONG		ulPlayMixLeft	= (m_ulDeviceNumber * 2) + LEFT;
	ULONG		ulPlayMixRight	= (m_ulDeviceNumber * 2) + RIGHT;

	DPF(("WAVE_FORMAT_DOLBY_AC3_SPDIF on PLAYx: Changing Mixer Layout\n"));

	// Mute any of the Analog Outputs that have this device routed
	for( usDstLine=LINE_OUT_1; usDstLine<=LINE_OUT_6; usDstLine++ )
	{
		for( usSrcLine=LINE_PLAY_MIXA; usSrcLine<=LINE_PLAY_MIXD; usSrcLine++ )
		{
			pMixer->GetControl( usDstLine, usSrcLine, CONTROL_SOURCE, 0, &ulSource );
			if( (ulSource == ulPlayMixLeft) || (ulSource == ulPlayMixRight) )
			{
				pMixer->SetControl( usDstLine, usSrcLine, CONTROL_MUTE, 0, TRUE );
				pMixer->ControlChanged( usDstLine, usSrcLine, CONTROL_MUTE );
			}
		}
	}

	// Mute all playmix'ers for the Digital Output
	for( usSrcLine=LINE_PLAY_MIXA; usSrcLine<=LINE_PLAY_MIXD; usSrcLine++ )
	{
		pMixer->SetControl( LINE_OUT_7, usSrcLine, CONTROL_MUTE, 0, TRUE );
		pMixer->SetControl( LINE_OUT_8, usSrcLine, CONTROL_MUTE, 0, TRUE );
	}

	// Route this device to the Digital Output
	pMixer->SetControl( LINE_OUT_7, LINE_PLAY_MIXB, CONTROL_SOURCE, 0, ulPlayMixLeft );
	pMixer->SetControl( LINE_OUT_8, LINE_PLAY_MIXB, CONTROL_SOURCE, 0, ulPlayMixRight );

	// Unmute this playmix line
	pMixer->SetControl( LINE_OUT_7, LINE_PLAY_MIXB, CONTROL_MUTE, 0, FALSE );
	pMixer->SetControl( LINE_OUT_8, LINE_PLAY_MIXB, CONTROL_MUTE, 0, FALSE );

	// Set the volume to MAX on both the Play Mix and Master
	pMixer->SetControl( LINE_OUT_7, LINE_PLAY_MIXB, CONTROL_VOLUME, 0, MAX_VOLUME );
	pMixer->SetControl( LINE_OUT_8, LINE_PLAY_MIXB, CONTROL_VOLUME, 0, MAX_VOLUME );
	pMixer->SetControl( LINE_OUT_7, LINE_NO_SOURCE, CONTROL_VOLUME, 0, MAX_VOLUME );
	pMixer->SetControl( LINE_OUT_8, LINE_NO_SOURCE, CONTROL_VOLUME, 0, MAX_VOLUME );
	
	// Turn off Phase & Dither
	pMixer->SetControl( LINE_OUT_7, LINE_PLAY_MIXB, CONTROL_PHASE, 0, FALSE );
	pMixer->SetControl( LINE_OUT_8, LINE_PLAY_MIXB, CONTROL_PHASE, 0, FALSE );
	pMixer->SetControl( LINE_OUT_7, LINE_NO_SOURCE, CONTROL_PHASE, 0, FALSE );
	pMixer->SetControl( LINE_OUT_8, LINE_NO_SOURCE, CONTROL_PHASE, 0, FALSE );
	pMixer->SetControl( LINE_OUT_7, LINE_NO_SOURCE, CONTROL_DITHER, 0, FALSE );
	pMixer->SetControl( LINE_OUT_8, LINE_NO_SOURCE, CONTROL_DITHER, 0, FALSE );

	// Turn on Non-Audio
	m_pHalAdapter->Get8420()->SetOutputNonAudio( TRUE );

	// Update the Mixer UI
	for( usSrcLine=LINE_PLAY_MIXA; usSrcLine<=LINE_PLAY_MIXD; usSrcLine++ )
	{
		pMixer->ControlChanged( LINE_OUT_7, usSrcLine, CONTROL_MUTE );
		pMixer->ControlChanged( LINE_OUT_8, usSrcLine, CONTROL_MUTE );
	}

	pMixer->ControlChanged( LINE_OUT_7, LINE_PLAY_MIXB, CONTROL_SOURCE );
	pMixer->ControlChanged( LINE_OUT_8, LINE_PLAY_MIXB, CONTROL_SOURCE );
	
	pMixer->ControlChanged( LINE_OUT_7, LINE_PLAY_MIXB, CONTROL_VOLUME );
	pMixer->ControlChanged( LINE_OUT_8, LINE_PLAY_MIXB, CONTROL_VOLUME );
	pMixer->ControlChanged( LINE_OUT_7, LINE_NO_SOURCE, CONTROL_VOLUME );
	pMixer->ControlChanged( LINE_OUT_8, LINE_NO_SOURCE, CONTROL_VOLUME );

	pMixer->ControlChanged( LINE_OUT_7, LINE_NO_SOURCE, CONTROL_DITHER );
	pMixer->ControlChanged( LINE_OUT_8, LINE_NO_SOURCE, CONTROL_DITHER );
	
	pMixer->ControlChanged( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_DIGITALOUT_STATUS );
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
LONG	CHalWaveDevice::GetHWIndex( BOOLEAN bFromHardware )
/////////////////////////////////////////////////////////////////////////////
{
	if( bFromHardware )
		return( m_RegStreamStatus.Read() & REG_STREAMSTAT_L2PTR_MASK );
	else
		return( m_lHWIndex );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalWaveDevice::GetTransferSize( PULONG pulTransferSize, PULONG pulCircularBufferSize )
// Called at interupt to time determine the amount of audio to transfer
/////////////////////////////////////////////////////////////////////////////
{
	LONG lSize;

	//DPF(("CHalWaveDevice::GetTransferSize\n"));

	// if we are using pre-programmed interrupt sizes, don't read the actual hardware
	if( !m_ulInterruptSamples )
		m_lHWIndex = GetHWIndex();

	//DB('h',COLOR_BOLD);	DX16( (USHORT)m_lHWIndex, COLOR_BOLD );

	*pulCircularBufferSize = (WAVE_CIRCULAR_BUFFER_SIZE - 1) * sizeof( DWORD );	// in bytes

	if( m_usMode == MODE_RUNNING )
	{
		lSize = m_lHWIndex - m_lPCIndex;
		//DPF(( " H%ld P%ld S%ld ", m_lHWIndex, m_lPCIndex, lSize ));
		//DB('h',COLOR_UNDERLINE);	DX16( (USHORT)m_lHWIndex, COLOR_BOLD );
		//DB('p',COLOR_UNDERLINE);	DX16( (USHORT)m_lPCIndex, COLOR_BOLD );
		//DB('s',COLOR_UNDERLINE);	DX16( (USHORT)lSize, COLOR_BOLD );

		// if this is a record device
		if( m_bIsRecord )
		{
			// lSize == 0 means no data is waiting
			if( lSize < 0 )
				lSize += WAVE_CIRCULAR_BUFFER_SIZE;

			if( !lSize )
			{
				// on the LynxTWO, if the HWIndex & PCIndex are exactly equal AND the 
				// overrun bit is set then the buffer is completely FULL not empty.
				ULONG	ulStreamStatus = m_RegStreamStatus.Read();

				// was the overrun bit set?
				if( ulStreamStatus & REG_STREAMSTAT_OVER )
				{
					lSize = WAVE_CIRCULAR_BUFFER_SIZE;
					DPF(("Buffer Overrun+Full!\n"));
				}
				else
				{
					DPF(("HW Error: Record interrupt generated when no data is available!\n"));
				}
			}
			lSize--;	// DAH Mar 22 02 make sure we don't empty the buffer
		}
		else	// this is a play device
		{
			// lSize == 0 means the buffer can be completely filled
			if( lSize <= 0 )
				lSize += WAVE_CIRCULAR_BUFFER_SIZE;
			lSize--;	// make sure we don't fill the buffer
		}
	}
	else	// in IDLE mode
	{
		lSize = WAVE_CIRCULAR_BUFFER_SIZE - 1;
	}

	// make sure we always leave one DWORD free
	if( lSize >= WAVE_CIRCULAR_BUFFER_SIZE )
		lSize = WAVE_CIRCULAR_BUFFER_SIZE - 1;

	//DPF(("s%ld ", lSize ));

	// lSize is now in DWORDs - must convert it to bytes
	*pulTransferSize = lSize * sizeof( DWORD );

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalWaveDevice::TransferAudio( PVOID pBuffer, ULONG ulBufferSize, PULONG pulBytesTransfered, LONG lPCIndex )
// MME / DirectSound Version
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulToTransfer, ulTransferred;
	ULONG	ulLength;
	PULONG	pHWBuffer;
	PULONG	pPCBuffer = (PULONG)pBuffer;

	ulLength = ulBufferSize / sizeof( DWORD );
	*pulBytesTransfered = ulLength * sizeof( DWORD );
	
	// are we overriding the PCIndex (DirectSound only)
	if( lPCIndex != -1 )
		m_lPCIndex = lPCIndex;
	
	while( ulLength )
	{
		// will this transfer need to be split into two parts?
		if( (ulLength + m_lPCIndex) >= WAVE_CIRCULAR_BUFFER_SIZE )
			ulToTransfer = WAVE_CIRCULAR_BUFFER_SIZE - m_lPCIndex;	// from the current position to the end of the buffer
		else
			ulToTransfer = ulLength;	// Transfer the entire buffer in one shot

		pHWBuffer = m_pAudioBuffer + m_lPCIndex;
		
		ulTransferred = ulToTransfer;	// save the amount we are going to transfer 
										// ulToTransfer might get destroyed during the transfer

		if( m_bIsRecord )	{	READ_REGISTER_BUFFER_ULONG( pHWBuffer, pPCBuffer, ulToTransfer );	}
		else				{	WRITE_REGISTER_BUFFER_ULONG( pHWBuffer, pPCBuffer, ulToTransfer );	}
	
		m_lPCIndex += ulTransferred;	// advance the PCIndex
		ulLength -= ulTransferred;		// decrease the amount to go
		m_ulBytesTransferred += (ulTransferred * sizeof( DWORD ));
		if( m_lBytesPerBlock )
			m_ulSamplesTransferred += ((ulTransferred * sizeof( DWORD )) / m_lBytesPerBlock);

		// if we still have more to go, move the buffer pointer forward
		if( ulLength )
		{
			pPCBuffer += ulTransferred;
			m_lPCIndex = 0;				// second part will always start at the begining of the buffer
		}
	}

	if( m_lPCIndex >= WAVE_CIRCULAR_BUFFER_SIZE )
		m_lPCIndex -= WAVE_CIRCULAR_BUFFER_SIZE;

	// Write the PCIndex to the hardware
	//DB('P',COLOR_NORMAL);	DX16( (USHORT)m_lPCIndex, COLOR_NORMAL );	DC(' ');
	m_RegStreamControl.Write( (REG_STREAMCTL_XFERDONE | m_lPCIndex), (REG_STREAMCTL_PCPTR_MASK | REG_STREAMCTL_XFERDONE) );
	//DPF(("h%ld p%ld ", m_RegStreamStatus.Read() & REG_STREAMSTAT_L2PTR_MASK, m_lPCIndex ));

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalWaveDevice::TransferAudio( PVOID pvLeft, PVOID pvRight, ULONG ulSamplesToTransfer, LONG lPCIndex )
// ASIO Version, Sample Format will always be 32-bit Stereo
/////////////////////////////////////////////////////////////////////////////
{
	PULONG	pHWBuffer = (PULONG)m_pAudioBuffer;
	LONG	lLSample = 0, lRSample = 0;
	
	// are we overriding the PCIndex
	if( lPCIndex != -1 )
		m_lPCIndex = lPCIndex;

	m_ulBytesTransferred += (ulSamplesToTransfer * sizeof( DWORD ) * 2);
	m_ulSamplesTransferred += ulSamplesToTransfer;
	
	if( m_bIsRecord )
	{
		register PLONG	pLDst = (PLONG)pvLeft;
		register PLONG	pRDst = (PLONG)pvRight;

		//DC('r');	DX16( (USHORT)ulSamplesToTransfer, COLOR_NORMAL );	DC(' ');
		
		while( ulSamplesToTransfer-- )
		{
			lLSample = READ_REGISTER_ULONG( &pHWBuffer[ m_lPCIndex++ ] );
			lRSample = READ_REGISTER_ULONG( &pHWBuffer[ m_lPCIndex++ ] );
			if( m_lPCIndex >= WAVE_CIRCULAR_BUFFER_SIZE )
				m_lPCIndex = 0;
			if( pLDst )	*pLDst++ = lLSample;
			if( pRDst )	*pRDst++ = lRSample;
		} // while
	}
	else
	{
		register PLONG	pLSrc = (PLONG)pvLeft;
		register PLONG	pRSrc = (PLONG)pvRight;

		//DC('p');	DX16( (USHORT)ulSamplesToTransfer, COLOR_NORMAL );	DC(' ');
		
		while( ulSamplesToTransfer-- )
		{
			if( pLSrc )	lLSample = *pLSrc++;
			if( pRSrc )	lRSample = *pRSrc++;
			WRITE_REGISTER_ULONG( &pHWBuffer[ m_lPCIndex++ ], lLSample );	// Left Channel
			WRITE_REGISTER_ULONG( &pHWBuffer[ m_lPCIndex++ ], lRSample );	// Right Channel
			if( m_lPCIndex >= WAVE_CIRCULAR_BUFFER_SIZE )
				m_lPCIndex = 0;
		} // while
	}

	if( m_lPCIndex >= WAVE_CIRCULAR_BUFFER_SIZE )
		m_lPCIndex -= WAVE_CIRCULAR_BUFFER_SIZE;

	// Write the PCIndex to the hardware
	//DC('{'); DX16( (USHORT)m_lPCIndex, COLOR_BOLD ); DC('}');
	m_RegStreamControl.Write( (REG_STREAMCTL_XFERDONE | m_lPCIndex), (REG_STREAMCTL_XFERDONE | REG_STREAMCTL_PCPTR_MASK) );
	//DPF(("h%ld p%ld ", m_RegStreamStatus.Read() & REG_STREAMSTAT_L2PTR_MASK, m_lPCIndex ));

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalWaveDevice::TransferComplete( LONG lBytesProcessed )
// Called at interupt to inform hardware that the transfer has been completed
/////////////////////////////////////////////////////////////////////////////
{
	(void)lBytesProcessed;
	// if we are using a pre-programmed interrupt rate
	if( m_ulInterruptSamples )
	{
		// advance the (shadow) hardware index
		m_lHWIndex += m_ulInterruptSamples;
		while( m_lHWIndex >= WAVE_CIRCULAR_BUFFER_SIZE )
			m_lHWIndex -= WAVE_CIRCULAR_BUFFER_SIZE;
		//DPF(("H[%ld] ", m_lHWIndex ));
	}

	// call the Position code to make sure the HWIndex doesn't roll over without us knowing it
	GetBytePosition();
	
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalWaveDevice::SetInterruptSamples( ULONG ulInterruptSamples )
/////////////////////////////////////////////////////////////////////////////
{
	if( ulInterruptSamples > (WAVE_CIRCULAR_BUFFER_SIZE / 2) )
		ulInterruptSamples = (WAVE_CIRCULAR_BUFFER_SIZE / 2);

	m_ulInterruptSamples = ulInterruptSamples;

	return( m_pHalAdapter->SetInterruptSamples( ulInterruptSamples ) );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalWaveDevice::ZeroPosition( void )
/////////////////////////////////////////////////////////////////////////////
{
	m_ullBytePosition = 0;
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalWaveDevice::GetSamplePosition( PULONG pulSamplePosition )
// DRIVER MUST CALL GetBytePosition BEFORE CALLING THIS FUNCTION SO 
// m_ullBytePosition IS UPDATED!
/////////////////////////////////////////////////////////////////////////////
{
	if( m_lBytesPerBlock )
	{
		*pulSamplePosition = (ULONG)(m_ullBytePosition / m_lBytesPerBlock);
	}
	else
	{
		DPF(("CHalWaveDevice::GetSamplePosition m_lBytesPerBlock is ZERO\n"));
		return( HSTATUS_INVALID_PARAMETER );
	}

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
ULONGLONG	CHalWaveDevice::GetBytePosition( void )
/////////////////////////////////////////////////////////////////////////////
{
	LONG	lHWIndex;
	LONG	lDiff;

	// protect this function from re-entrancy problems - without a spin lock or other such thing
	if( !m_ulGBPEntryCount )
	{
		m_ulGBPEntryCount++;
		////////////////////
		// Protected
		////////////////////

		lHWIndex = GetHWIndex( TRUE );

		lDiff = lHWIndex - m_lGBPLastHWIndex;
		if( lDiff < 0 )
			lDiff += WAVE_CIRCULAR_BUFFER_SIZE;

		// save the current HW index as the last HW index for the next time around.
		m_lGBPLastHWIndex = lHWIndex;

		// lDiff now has the number of DWORDs that have be processed by the hardware
		// since the last GetBytePosition call.  This needs to be changed to the number
		// of bytes by multiplying by 4.
		lDiff *= sizeof( DWORD );

		// increase the overall sample count for this device
		m_ullBytePosition += (ULONG)lDiff;

		////////////////////
		// Protected
		////////////////////
		m_ulGBPEntryCount--;
	}

	return( m_ullBytePosition );
}

#ifdef DEBUG
/////////////////////////////////////////////////////////////////////////////
VOID	CHalWaveDevice::DebugPrintStatus( VOID )
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulStreamStatus = m_RegStreamStatus.Read();
	ULONG	ulStreamControl = m_RegStreamControl.Read();
	(void) ulStreamStatus; (void)ulStreamControl;
	DC('[');
	DX16( (USHORT)(ulStreamStatus & REG_STREAMSTAT_L2PTR_MASK), COLOR_NORMAL );
	DC(',');
	DX16( (USHORT)(ulStreamControl & REG_STREAMCTL_PCPTR_MASK), COLOR_NORMAL );
	DC(']');
}
#endif

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalWaveDevice::Service()
// Called at interrupt time to service the circular buffer
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulReason = kReasonWave;
	//DC('W');
	//DPF(("CHalWaveDevice::Service: "));
	//DB('s',COLOR_BOLD);	DX8( (BYTE)m_ulDeviceNumber, COLOR_NORMAL );

	// go see why we were called
	ULONG	ulStreamStatus = m_RegStreamStatus.Read();
	//ULONG	ulStreamControl = m_RegStreamControl.Read();
	//DC('[');
	//DX16( (USHORT)(ulStreamStatus & REG_STREAMSTAT_L2PTR_MASK), COLOR_NORMAL );
	//DC(',');
	//DX16( (USHORT)(ulStreamControl & REG_STREAMCTL_PCPTR_MASK), COLOR_NORMAL );
	//DC(']');

	//DPF(("Stream Status %08lx\n", ulStreamStatus ));

	// was the limit hit bit set?
	if( ulStreamStatus & REG_STREAMSTAT_LIMHIT )
	{
		//DC('L');
		//DPF(("Limit Hit\n"));
	}

	// was the overrun bit set?
	if( ulStreamStatus & REG_STREAMSTAT_OVER )
	{
		DB('O',COLOR_BOLD);
		m_ulOverrunCount++;
		DPF(("\nCHalWaveDevice: Overrun Detected %ld\n", m_ulOverrunCount ));
		ulReason = kReasonWaveEmpty;
	}

	if( m_usMode != MODE_RUNNING )
	{
		//DPF(("<%02ld %08lx %08lx>", m_ulDeviceNumber, m_RegStreamControl.Read(), ulStreamStatus ));
		Stop();
		//DPF(("Interrupt Detected on IDLE device %02ld\n", m_ulDeviceNumber ));
		return( HSTATUS_INVALID_MODE );
	}

	// let the driver service the interrupt for this device
	CHalDevice::Service( ulReason );

	return( HSTATUS_OK );
}

