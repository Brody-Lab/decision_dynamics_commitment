/****************************************************************************
 HalTimecode.cpp

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
 Oct 19 04 DAH	Set the m_ulDeviceNumber so SetDefaults would not fail.
 Aug 09 04 DAH	Reset the MTC position so it will be invalid until the next 
				valid MTC message comes in
****************************************************************************/

#include <StdAfx.h>
#include "HalAdapter.h"

/////////////////////////////////////////////////////////////////////////////
USHORT CHalTimecode::Open( PHALADAPTER pHalAdapter, ULONG ulDeviceNumber )
/////////////////////////////////////////////////////////////////////////////
{
	PLYNXTWOREGISTERS	pRegisters = pHalAdapter->GetRegisters();

	m_pRegLTCControl = pHalAdapter->GetRegLTCControl();
	
	m_CurrentPosition.ulTimecode = 0;
	m_bDropFrame		= TRUE;
	
	m_ucMTCFrameRate	= MTC_FRAMERATE_30;
	m_ucMaxFrame		= 0;
	m_bHasValidTimecode	= FALSE;

	m_bMTCRunning = FALSE;
	
	// must be setup before SetDefaults
	m_ulDeviceNumber	= ulDeviceNumber;

	if( IsRx() )
	{
		m_RegLTCRxRate.Init( &pRegisters->TCBlock.LTCRxFrameRate, REG_READONLY );
		m_RegTCStatus.Init( &pRegisters->TCBlock.TCStatus, REG_READONLY );
		
		// enable the TC Receiver
		m_pRegLTCControl->BitSet( REG_LTCCONTROL_LRXEN | REG_LTCCONTROL_LRXIE, TRUE );
	}
	else
	{
		SetDefaults();
	}

	m_bOpen = TRUE;

	return( CHalDevice::Open( pHalAdapter, ulDeviceNumber ) );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalTimecode::Close()
/////////////////////////////////////////////////////////////////////////////
{
	//DPF(("CHalTimecode::Close\n"));
	if( m_bOpen )
		Stop();

	m_bOpen = FALSE;
	return( CHalDevice::Close() );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalTimecode::Start()
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	PCBuffer[ TCBUFFER_SIZE ];

	if( !m_bOpen )
		return( HSTATUS_ADAPTER_NOT_OPEN );

	if( IsRx() )
		return( HSTATUS_INVALID_PARAMETER );

	// Transmit Start

	// Preload two buffers worth of timecode data to the hardware
	EncodeTxBuffer( PCBuffer );
	WriteTimecode( TC_BUFFERA, PCBuffer );
	IncrementTimecode();

	EncodeTxBuffer( PCBuffer );
	WriteTimecode( TC_BUFFERB, PCBuffer );
	IncrementTimecode();

	// turn on the transmitter
	m_pRegLTCControl->BitSet( REG_LTCCONTROL_LTXEN | REG_LTCCONTROL_LTXIE, TRUE );

	return( CHalDevice::Start() );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalTimecode::Stop()
/////////////////////////////////////////////////////////////////////////////
{
	if( IsRx() )
		return( HSTATUS_INVALID_PARAMETER );
	
	// Transmit Stop
	m_pRegLTCControl->BitSet( REG_LTCCONTROL_LTXEN | REG_LTCCONTROL_LTXIE, FALSE );

	m_bMTCRunning = FALSE;

	return( CHalDevice::Stop() );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalTimecode::EnableMTC( BOOLEAN bEnable )
/////////////////////////////////////////////////////////////////////////////
{
	if( !IsRx() )
		return( HSTATUS_INVALID_PARAMETER );

	if( bEnable )
	{
		m_pRegLTCControl->BitSet( REG_LTCCONTROL_LRXQFIE, TRUE );
		//m_pRegLTCControl->BitSet( REG_LTCCONTROL_LRXEN | REG_LTCCONTROL_LRXIE, TRUE );
	}
	else
	{
		m_pRegLTCControl->BitSet( REG_LTCCONTROL_LRXQFIE, FALSE );
		//m_pRegLTCControl->BitSet( REG_LTCCONTROL_LRXEN | REG_LTCCONTROL_LRXIE, FALSE );
	}
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalTimecode::GetMTCFrameRate( PBYTE pucMTCFrameRate )
/////////////////////////////////////////////////////////////////////////////
{
	if( !IsRx() )
		return( HSTATUS_INVALID_PARAMETER );

	if( !IsInputLocked() )
		return( HSTATUS_INVALID_MODE );

	*pucMTCFrameRate = m_ucMTCFrameRate;

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalTimecode::SetFrameRate( ULONG ulFrameRate )
/////////////////////////////////////////////////////////////////////////////
{
	BOOLEAN	bDropFrame = m_bDropFrame;

	//DPF(("CHalTimecode::SetFrameRate %lu\n", ulFrameRate ));

	if( IsRx() )
		return( HSTATUS_INVALID_PARAMETER );

	if( IsRunning() )
		return( HSTATUS_INVALID_MODE );

	switch( ulFrameRate )
	{
	case MIXVAL_TCFRAMERATE_24FPS:
		m_pRegLTCControl->Write( REG_LTCCONTROL_LTXRATE_24FPS, REG_LTCCONTROL_LTXRATE_MASK );
		m_ucMaxFrame = 23;	// 0..23
		m_bDropFrame = FALSE;
		break;
	case MIXVAL_TCFRAMERATE_25FPS:
		m_pRegLTCControl->Write( REG_LTCCONTROL_LTXRATE_25FPS, REG_LTCCONTROL_LTXRATE_MASK );
		m_ucMaxFrame = 24;	// 0..24
		m_bDropFrame = FALSE;
		break;
	case MIXVAL_TCFRAMERATE_2997FPS:
		m_pRegLTCControl->Write( REG_LTCCONTROL_LTXRATE_2997FPS, REG_LTCCONTROL_LTXRATE_MASK );
		m_ucMaxFrame = 29;	// 0..29
		break;
	case MIXVAL_TCFRAMERATE_30FPS:
		m_pRegLTCControl->Write( REG_LTCCONTROL_LTXRATE_30FPS, REG_LTCCONTROL_LTXRATE_MASK );
		m_ucMaxFrame = 29;	// 0..29
		break;
	default:
		return( HSTATUS_INVALID_PARAMETER );
	}
	
	// if we changed the drop from status, update the mixer
	if( m_bDropFrame != bDropFrame )
		m_pHalAdapter->GetMixer()->ControlChanged( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_LTCOUT_DROPFRAME );
	
	m_ulFrameRate = ulFrameRate;

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
BOOLEAN CHalTimecode::IsInputLocked( void )
/////////////////////////////////////////////////////////////////////////////
{
	BOOLEAN	bLocked;

	if( !IsRx() )
	  return static_cast<BOOLEAN>( -1 );
	
	bLocked = m_RegTCStatus & TCSTATUS_LRXLOCK ? TRUE : FALSE;
	if( !bLocked )
	{
		// Do not reset the current position, or the mixer UI will show 0 when we go unlocked!
		m_bDropFrame = 0;
		m_ucMaxFrame = 0;
		m_bHasValidTimecode = FALSE;
	}

	return( bLocked );
}

/////////////////////////////////////////////////////////////////////////////
ULONG	CHalTimecode::GetInputDirection( void )
// returns TRUE for forward, FALSE for backward
/////////////////////////////////////////////////////////////////////////////
{
	if( !IsRx() )
		return static_cast<ULONG>( -1 );
	
	if( !IsInputLocked() )
		return static_cast<ULONG>( -1 );

	return( m_RegTCStatus & TCSTATUS_LRXDIR_MASK ? TRUE : FALSE );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalTimecode::GetFrameRate( PULONG pulFrameRate )
/////////////////////////////////////////////////////////////////////////////
{
	*pulFrameRate = 50000000;	// this is identified as 'invalid'

	if( IsRx() )
	{
		if( !IsInputLocked() )
			return( HSTATUS_INVALID_MODE );

		ULONG ulCount = (m_RegLTCRxRate & LTCRXRATE_MASK) + 1;		// get the rate from the hardware
		//DPF(("%04lx ", ulCount ));
		m_ulFrameRate = (50000000 + (ulCount/2)) / ulCount;			// the rate is in (frames/second) * 1000 (with rounding)
	}

	//DPF(("CHalTimecode::GetFrameRate %lu\n", m_ulFrameRate ));

	*pulFrameRate = m_ulFrameRate;
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalTimecode::SetPosition( ULONG ulPosition )
/////////////////////////////////////////////////////////////////////////////
{
	if( IsRx() )
		return( HSTATUS_INVALID_PARAMETER );

	if( IsRunning() )
		return( HSTATUS_INVALID_MODE );

	m_CurrentPosition.ulTimecode = ulPosition;
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalTimecode::GetPosition( PULONG pulPosition )
/////////////////////////////////////////////////////////////////////////////
{
	*pulPosition = m_CurrentPosition.ulTimecode;
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
BOOLEAN	CHalTimecode::HasValidTimecode( void )
// only used by the MTC code to see if valid timecode was just read on this 
// interrupt
/////////////////////////////////////////////////////////////////////////////
{
	return( m_bHasValidTimecode );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalTimecode::ResetValidTimecode( void )
// Only called by the MTC code to reset the valid timecode flag
/////////////////////////////////////////////////////////////////////////////
{
	m_bHasValidTimecode = FALSE;
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalTimecode::SetDropFrame( BOOLEAN bDropFrame )
/////////////////////////////////////////////////////////////////////////////
{
	if( IsRx() )
		return( HSTATUS_INVALID_PARAMETER );

	switch( m_ulFrameRate )
	{
	case MIXVAL_TCFRAMERATE_2997FPS:
	case MIXVAL_TCFRAMERATE_30FPS:
		m_bDropFrame = bDropFrame;
		break;
	default:
		m_bDropFrame = FALSE;
		return( HSTATUS_INVALID_PARAMETER );
	}
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalTimecode::SetSyncSource( ULONG ulSyncSource )
/////////////////////////////////////////////////////////////////////////////
{
	if( IsRx() )
		return( HSTATUS_INVALID_PARAMETER );
	
	switch( ulSyncSource )
	{
	case MIXVAL_TCSYNCSOURCE_INTERNAL:
		m_pRegLTCControl->Write( REG_LTCCONTROL_LTXSYNC_FREERUNNING, REG_LTCCONTROL_LTXSYNC_MASK );
		break;
	case MIXVAL_TCSYNCSOURCE_VIDEOIN:
		m_pRegLTCControl->Write( REG_LTCCONTROL_LTXSYNC_VIDEOLINE5, REG_LTCCONTROL_LTXSYNC_MASK );
		break;
	default:
		return( HSTATUS_INVALID_PARAMETER );
	}
	m_ulSyncSource = ulSyncSource;

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
void	CHalTimecode::WriteTimecode( ULONG ulBufferID, PULONG pulTxBuffer )
// private
/////////////////////////////////////////////////////////////////////////////
{
	PULONG	pHWBuffer;

	if( ulBufferID == TC_BUFFERA )
	{
		//DC('A');
		pHWBuffer = (PULONG)&m_pHalAdapter->GetRegisters()->TCBlock.LTCTxBufA;
	}
	else
	{
		//DC('B');
		pHWBuffer = (PULONG)&m_pHalAdapter->GetRegisters()->TCBlock.LTCTxBufB;
	}
	
	WRITE_REGISTER_BUFFER_ULONG( pHWBuffer, pulTxBuffer, TCBUFFER_SIZE );
}

/////////////////////////////////////////////////////////////////////////////
void	CHalTimecode::EncodeTxBuffer( PULONG pulTxBuffer )
// private
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulTens, ulUnits;

	ulTens = m_CurrentPosition.Bytes.ucFrame / 10;
	ulUnits = m_CurrentPosition.Bytes.ucFrame - (ulTens * 10);
	pulTxBuffer[ 0 ] = (ulTens << TCBUFFER_TENS_OFFSET) | ulUnits;
	if( m_bDropFrame )
		pulTxBuffer[ 0 ] |= TCBUFFER_DROPFRAME_MASK;

	ulTens = m_CurrentPosition.Bytes.ucSecond / 10;
	ulUnits = m_CurrentPosition.Bytes.ucSecond - (ulTens * 10);
	pulTxBuffer[ 1 ] = (ulTens << TCBUFFER_TENS_OFFSET) | ulUnits;

	ulTens = m_CurrentPosition.Bytes.ucMinute / 10;
	ulUnits = m_CurrentPosition.Bytes.ucMinute - (ulTens * 10);
	pulTxBuffer[ 2 ] = (ulTens << TCBUFFER_TENS_OFFSET) | ulUnits;

	ulTens = m_CurrentPosition.Bytes.ucHour / 10;
	ulUnits = m_CurrentPosition.Bytes.ucHour - (ulTens * 10);
	pulTxBuffer[ 3 ] = (ulTens << TCBUFFER_TENS_OFFSET) | ulUnits;
}

/////////////////////////////////////////////////////////////////////////////
void	CHalTimecode::IncrementTimecode()
// private
/////////////////////////////////////////////////////////////////////////////
{
	m_CurrentPosition.Bytes.ucFrame++;
	if( m_CurrentPosition.Bytes.ucFrame > m_ucMaxFrame )
	{
		m_CurrentPosition.Bytes.ucFrame = 0;
		
		// there actually is no such thing as 30FPS Drop Frame.  It is really 29.97 (30/1.001) Drop Frame.
		if( (m_ulFrameRate == MIXVAL_TCFRAMERATE_2997FPS) || (m_ulFrameRate == MIXVAL_TCFRAMERATE_30FPS) )
		{
			// Drop frame: Every frame :00 & :01 are dropped for each minute change (60 X 2 = 120 frames per hour) 
			// except for minutes with 0’s (00:, 10:, 20:, 30:, 40: & 50:) (6 X 2 = 12, 120 - 12 = 108 frames in one hour)
			if( m_bDropFrame && (m_CurrentPosition.Bytes.ucSecond == 59) && !((m_CurrentPosition.Bytes.ucMinute % 10) == 9))
				m_CurrentPosition.Bytes.ucFrame = 2;
		}

		m_CurrentPosition.Bytes.ucSecond++;
		if( m_CurrentPosition.Bytes.ucSecond > 59 )
		{
			m_CurrentPosition.Bytes.ucSecond = 0;
			m_CurrentPosition.Bytes.ucMinute++;
			if( m_CurrentPosition.Bytes.ucMinute > 59 )
			{
				m_CurrentPosition.Bytes.ucMinute = 0;
				m_CurrentPosition.Bytes.ucHour++;
				if( m_CurrentPosition.Bytes.ucHour > 63 )
				{
					m_CurrentPosition.Bytes.ucHour = 0;
					// no futher rollover possible
				}
			}
		}
	}
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalTimecode::SetDefaults( void )
/////////////////////////////////////////////////////////////////////////////
{
	//DPF(("CHalTimecode::SetDefaults\n"));

	if( !IsRx() )
	{
		//DPF(("SetDefaults TC_TX\n"));

		Stop();
		SetFrameRate( MIXVAL_TCFRAMERATE_2997FPS );
		SetDropFrame( TRUE );
		SetSyncSource( MIXVAL_TCSYNCSOURCE_INTERNAL );
		SetPosition( 0 );
	}

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalTimecode::SetMixerControl( USHORT usControl, ULONG ulValue )
/////////////////////////////////////////////////////////////////////////////
{
	switch( usControl )
	{
	// Timecode
	case CONTROL_LTCOUT_ENABLE:		// boolean
		if( ulValue )	Start();
		else			Stop();
		break;
	case CONTROL_LTCOUT_FRAMERATE:	// mux
		SetFrameRate( ulValue );
		break;
	case CONTROL_LTCOUT_DROPFRAME:	// boolean
		SetDropFrame( (BOOLEAN)ulValue );
		break;
	case CONTROL_LTCOUT_SYNCSOURCE:
		SetSyncSource( ulValue );
		break;
	case CONTROL_LTCOUT_POSITION:	// ulong
		SetPosition( ulValue );
		break;
	
	default:							return( HSTATUS_INVALID_MIXER_CONTROL );
	}
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalTimecode::GetMixerControl( USHORT usControl, PULONG pulValue )
/////////////////////////////////////////////////////////////////////////////
{
	USHORT	usDeviceID = m_pHalAdapter->GetDeviceID();

	// only the LynxTWO-A -B & -C have LTC controls

	if( !((usDeviceID == PCIDEVICE_LYNXTWO_A) || (usDeviceID == PCIDEVICE_LYNXTWO_B) || (usDeviceID == PCIDEVICE_LYNXTWO_C)) )
		return( HSTATUS_INVALID_MIXER_CONTROL );

	switch( usControl )
	{
	// LTC In
	case CONTROL_LTCIN_FRAMERATE:	GetFrameRate( pulValue );				break;
	case CONTROL_LTCIN_LOCKED:		*pulValue = (ULONG)IsInputLocked();		break;
	case CONTROL_LTCIN_DIRECTION:	*pulValue = (ULONG)GetInputDirection();	break;
	case CONTROL_LTCIN_DROPFRAME:	*pulValue = (ULONG)GetDropFrame();		break;
	case CONTROL_LTCIN_POSITION:	GetPosition( pulValue );				break;
	
	// LTC Out
	case CONTROL_LTCOUT_ENABLE:		*pulValue = (ULONG)IsRunning();			break;
	case CONTROL_LTCOUT_FRAMERATE:	GetFrameRate( pulValue );				break;
	case CONTROL_LTCOUT_DROPFRAME:	*pulValue = (ULONG)GetDropFrame();		break;
	case CONTROL_LTCOUT_SYNCSOURCE:	*pulValue = GetSyncSource();			break;
	case CONTROL_LTCOUT_POSITION:	GetPosition( pulValue );				break;

	default:						return( HSTATUS_INVALID_MIXER_CONTROL );
	}
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalTimecode::Service( ULONG ulBufferID )
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	PCBuffer[ TCBUFFER_SIZE ];
	PULONG	pHWBuffer;
	BYTE	ucNewMTCFrameRate;

	DB('t',COLOR_BOLD);
	//DPF(("CHalTimecode::Service\n"));
	
	if( IsRx() )
	{
		if( ulBufferID == TC_BUFFERA )
			pHWBuffer = (PULONG)&m_pHalAdapter->GetRegisters()->TCBlock.LTCRxBufA;
		else
			pHWBuffer = (PULONG)&m_pHalAdapter->GetRegisters()->TCBlock.LTCRxBufB;
		
		READ_REGISTER_BUFFER_ULONG( pHWBuffer, PCBuffer, TCBUFFER_SIZE );

		// Decode the Rx buffer
		m_CurrentPosition.Bytes.ucFrame = (BYTE)(PCBuffer[ 0 ] & TCBUFFER_FRAME_UNITS_MASK);
		m_CurrentPosition.Bytes.ucFrame += (BYTE)(((PCBuffer[ 0 ] & TCBUFFER_FRAME_TENS_MASK) >> TCBUFFER_TENS_OFFSET) * 10);
		m_CurrentPosition.Bytes.ucFrame &= 0x1F;
		m_bDropFrame = (PCBuffer[ 0 ] & TCBUFFER_DROPFRAME_MASK) ? TRUE : FALSE;

		m_CurrentPosition.Bytes.ucSecond = (BYTE)(PCBuffer[ 1 ] & TCBUFFER_SECONDS_UNITS_MASK);
		m_CurrentPosition.Bytes.ucSecond += (BYTE)(((PCBuffer[ 1 ] & TCBUFFER_SECONDS_TENS_MASK) >> TCBUFFER_TENS_OFFSET) * 10);
		m_CurrentPosition.Bytes.ucSecond &= 0x3F;

		m_CurrentPosition.Bytes.ucMinute = (BYTE)(PCBuffer[ 2 ] & TCBUFFER_MINUTES_UNITS_MASK);
		m_CurrentPosition.Bytes.ucMinute += (BYTE)(((PCBuffer[ 2 ] & TCBUFFER_MINUTES_TENS_MASK) >> TCBUFFER_TENS_OFFSET) * 10);
		m_CurrentPosition.Bytes.ucMinute &= 0x3F;

		m_CurrentPosition.Bytes.ucHour = (BYTE)(PCBuffer[ 3 ] & TCBUFFER_HOURS_UNITS_MASK);
		m_CurrentPosition.Bytes.ucHour += (BYTE)(((PCBuffer[ 3 ] & TCBUFFER_HOURS_TENS_MASK) >> TCBUFFER_TENS_OFFSET) * 10);
		m_CurrentPosition.Bytes.ucHour &= 0x1F;

		m_bHasValidTimecode = TRUE;

		// see if the frame rate needs to be updated.  Valid minimum range is 0..23
		if( m_CurrentPosition.Bytes.ucFrame > 22 )
		{
			// for the receiver, m_ucMaxFrame is only evaluated below
			m_ucMaxFrame = m_CurrentPosition.Bytes.ucFrame;
			//DPF(("Updating Max Frame to %u ", (USHORT)m_ucMaxFrame ));
		}

		// only update the frame rate on frame zero
		if( m_CurrentPosition.Bytes.ucFrame == 0 )
		{
			switch( m_ucMaxFrame )
			{
			case 23:	// 0..23 is 24fps
				ucNewMTCFrameRate = MTC_FRAMERATE_24;
				break;
			case 24:	// 0..24 is 25fps
				ucNewMTCFrameRate = MTC_FRAMERATE_25;
				break;
			default:
				if( m_bDropFrame )
					ucNewMTCFrameRate = MTC_FRAMERATE_30DROP;
				else
					ucNewMTCFrameRate = MTC_FRAMERATE_30;
				break;
			}
			//DPF(( "[%02d:%02d:%02d:%02d]\n", m_CurrentPosition.Bytes.ucHour, m_CurrentPosition.Bytes.ucMinute, m_CurrentPosition.Bytes.ucSecond, m_CurrentPosition.Bytes.ucFrame ));
			
			// if the frame rate changed, update it now (since we are on the 'zero' frame, it is a good time!)
			if( ucNewMTCFrameRate != m_ucMTCFrameRate )
			{
				m_ucMTCFrameRate = ucNewMTCFrameRate;
				//DPF(( "New Frame Rate is %u [%02d:%02d:%02d:%02d]\n", m_ucMTCFrameRate, m_CurrentPosition.Bytes.ucHour, m_CurrentPosition.Bytes.ucMinute, m_CurrentPosition.Bytes.ucSecond, m_CurrentPosition.Bytes.ucFrame ));
			}
		}

	}
	else
	{
		EncodeTxBuffer( PCBuffer );
		WriteTimecode( ulBufferID, PCBuffer );
		IncrementTimecode();

		TIMECODE		MTCPosition;

		// Go get the current MTC position from the MIDI Output Driver
		if( m_pHalAdapter->GetMIDIOutDevice( 0 )->GetMTCPosition( &MTCPosition.ulTimecode ) )
		{
			// the GetMTCPosition returned an error, was MTC running?
			if( m_bMTCRunning )
			{
				DPF(("Stopping LTC Generator because MTC stopped\n"));
				Stop();
				m_pHalAdapter->GetMixer()->ControlChanged( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_LTCOUT_ENABLE );
			}
		}
		else	// MIDI Out Is Open & Started
		{
			// if the timecode is not -1, then MTC Out is running
			if( MTCPosition.ulTimecode != 0xFFFFFFFF )
			{
				int	nLTCSeconds;
				int	nMTCSeconds;

				nLTCSeconds  = m_CurrentPosition.Bytes.ucHour * 3600;
				nLTCSeconds += m_CurrentPosition.Bytes.ucMinute * 60;
				nLTCSeconds += m_CurrentPosition.Bytes.ucSecond;
				
				nMTCSeconds  = MTCPosition.Bytes.ucHour * 3600;
				nMTCSeconds += MTCPosition.Bytes.ucMinute * 60;
				nMTCSeconds += MTCPosition.Bytes.ucSecond;

				m_bMTCRunning = TRUE;

#define abs( n )	((n)<0?(n)*-1:(n))

				// if the difference between the MTC time and the LTC time is more than 2 seconds
				if( abs(nLTCSeconds - nMTCSeconds) > 2 )
				{
					// turn off the LTC Generator
					//DPF(("Stopping LTC Generator because MTC is more than 2 seconds off %ld %ld\n", nLTCSeconds, nMTCSeconds ));
					Stop();
					m_pHalAdapter->GetMIDIOutDevice( 0 )->ResetMTCPosition();	// DAH Aug 9, 2004: Reset the MTC position so it will be invalid until the next valid MTC message comes in
					m_pHalAdapter->GetMixer()->ControlChanged( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_LTCOUT_ENABLE );
				}
			}
		}
	}

	//CHalDevice::Service( kReasonTimecode );
	
	return( HSTATUS_OK );
}
