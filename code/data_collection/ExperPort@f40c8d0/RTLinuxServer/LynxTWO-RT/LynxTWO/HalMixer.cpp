/****************************************************************************
 HalMixer.cpp

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
 May 19 03 DAH	Renamed RegisterCallback to RegisterCallbacks and added 
				RestoreSceneCallback & SaveSceneCallback so driver can restore
				/save scenes to/from persistent storage.
 May 19 03 DAH  Added CONTROL_MIXER_RESTORE_SCENE & CONTROL_MIXER_SAVE_SCENE.
 May 19 03 DAH	Moved GetControlType() and IsControlWriteable() from driver 
				into HAL.
 May 19 03 DAH	Added SetDefaults() function
****************************************************************************/

#include <StdAfx.h>
#include "HalAdapter.h"

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalMixer::Open( PHALADAPTER pHalAdapter )
/////////////////////////////////////////////////////////////////////////////
{
	PLYNXTWOREGISTERS	pRegisters;
	int	i;

	m_pHalAdapter	= pHalAdapter;
	m_pSampleClock	= pHalAdapter->GetSampleClock();	// Cannot use, Has *NOT* been opened yet
	m_pCS8420		= pHalAdapter->Get8420();			// Cannot use, Has *NOT* been opened yet
	m_pAK4114		= pHalAdapter->Get4114();
	m_pLStream		= pHalAdapter->GetLStream();
	m_pTCTx			= pHalAdapter->GetTCTx();
	m_pTCRx			= pHalAdapter->GetTCRx();

	pRegisters		= pHalAdapter->GetRegisters();
	m_usDeviceID	= pHalAdapter->GetDeviceID();
	
	for( i=0; i<NUM_WAVE_PHYSICAL_OUTPUTS; i++ )
	{
		m_aPlayMix[ i ].Open( 
			this, 
			i, 
			&pRegisters->MIXBlock.PMixControl[ i ],
			&pRegisters->MIXBlock.PMixStatus[ i ] );
	}

	for( i=0; i<NUM_WAVE_PHYSICAL_INPUTS; i++ )
	{
		m_aRecordMix[ i ].Open( 
			pHalAdapter,
			&pRegisters->MIXBlock.RMixControl[ i ], 
			&pRegisters->MIXBlock.RMixStatus[ i ] );
	}

	m_pControlChangedCallback	= NULL;
	m_pSaveSceneCallback		= NULL;
	m_pRestoreSceneCallback		= NULL;
	m_pContext = NULL;

	SetDefaults( TRUE );

	m_bOpen = TRUE;

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalMixer::Close()
/////////////////////////////////////////////////////////////////////////////
{
	m_bOpen = FALSE;
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalMixer::RegisterCallbacks( 
	PMIXERCONTROLCHANGEDCALLBACK pControlChangedCallback, 
	PMIXERSCENECALLBACK pRestoreSceneCallback, 
	PMIXERSCENECALLBACK pSaveSceneCallback, 
	PVOID pContext )
/////////////////////////////////////////////////////////////////////////////
{
	m_pControlChangedCallback	= pControlChangedCallback;
	m_pRestoreSceneCallback		= pRestoreSceneCallback, 
	m_pSaveSceneCallback		= pSaveSceneCallback, 
	m_pContext	= pContext;

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalMixer::ControlChanged( USHORT usDstLine, USHORT usSrcLine, USHORT usControl )
/////////////////////////////////////////////////////////////////////////////
{
	USHORT	usStatus = HSTATUS_OK;

	//DPF(("ControlChanged %04x %04x %04x\n", usDstLine, usSrcLine, usControl ));
	if( !m_bOpen )
		return( HSTATUS_ADAPTER_NOT_OPEN );

	if( m_pControlChangedCallback )
		usStatus = m_pControlChangedCallback( m_pContext, usDstLine, usSrcLine, usControl );

	return( usStatus );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalMixer::SetDefaults( BOOLEAN bDriverLoading )
/////////////////////////////////////////////////////////////////////////////
{
	int i;

	//DPF(("SetDefaults\n"));

	for( i=0; i<NUM_WAVE_PHYSICAL_OUTPUTS; i++ )
	{
		m_aPlayMix[ i ].SetSource( LINE_PLAY_MIXA, MIXVAL_PMIXSRC_RECORD0L + i );	// 0..15 is RECORD0L..RECORD7R
		m_aPlayMix[ i ].SetSource( LINE_PLAY_MIXB, MIXVAL_PMIXSRC_PLAY0L + i );		// 16..31 is PLAY0L..PLAY7R
		
		m_aPlayMix[ i ].SetMute( LINE_PLAY_MIXB, FALSE );

		if( !bDriverLoading )
		{
			m_aPlayMix[ i ].SetSource( LINE_PLAY_MIXC, 0xFFFF );	// No Source - volume, mute & phase are reset
			m_aPlayMix[ i ].SetSource( LINE_PLAY_MIXD, 0xFFFF );	// No Source - volume, mute & phase are reset
			
			m_aPlayMix[ i ].SetVolume( LINE_PLAY_MIXA, MAX_VOLUME );
			m_aPlayMix[ i ].SetVolume( LINE_PLAY_MIXB, MAX_VOLUME );

			m_aPlayMix[ i ].SetMute( LINE_PLAY_MIXA, TRUE );
			
			m_aPlayMix[ i ].SetPhase( LINE_PLAY_MIXA, FALSE );
			m_aPlayMix[ i ].SetPhase( LINE_PLAY_MIXB, FALSE );
		
			// Master
			m_aPlayMix[ i ].SetVolume( MAX_VOLUME );
			m_aPlayMix[ i ].SetMute( FALSE );
			m_aPlayMix[ i ].SetPhase( FALSE );
			m_aPlayMix[ i ].SetDither( FALSE );
		}
	}

	for( i=0; i<NUM_WAVE_PHYSICAL_INPUTS; i++ )
	{
		if( (m_usDeviceID == PCIDEVICE_LYNX_AES16) || (m_usDeviceID == PCIDEVICE_LYNX_AES16SRC) )
		{
			m_aRecordMix[ i ].SetSource( (USHORT)i );
		}
		else
		{
			// Set the source to a default value
			if( i > 7 )
				m_aRecordMix[ i ].SetSource( (USHORT)i+16 );	// LStream 2
			else
				m_aRecordMix[ i ].SetSource( (USHORT)i );
		}

		if( !bDriverLoading )
		{
			m_aRecordMix[ i ].SetMute( FALSE );
			m_aRecordMix[ i ].SetDither( FALSE );
		}
	}

	// if this is a B Model, reassign the Record Source Selection
	if( m_usDeviceID == PCIDEVICE_LYNXTWO_B )
	{
		m_aRecordMix[ 2 ].SetSource( 0 );
		m_aRecordMix[ 3 ].SetSource( 1 );
		m_aRecordMix[ 4 ].SetSource( 0 );
		m_aRecordMix[ 5 ].SetSource( 1 );
	}

	if( !bDriverLoading )
	{
		// Sample Clock
		if( m_pAK4114 )	m_pSampleClock->Set( 44100, MIXVAL_AES16_CLKSRC_INTERNAL, MIXVAL_CLKREF_AUTO );
		else			m_pSampleClock->Set( 44100, MIXVAL_L2_CLKSRC_INTERNAL, MIXVAL_CLKREF_AUTO );

		// LynxTWO Digital I/O
		if( m_pCS8420 )
		{
			m_pCS8420->SetFormat( MIXVAL_DF_AESEBU );
			m_pCS8420->SetMode( MIXVAL_SRCMODE_SRC_ON );
			m_pCS8420->SetInputMuteOnError( TRUE );
			m_pCS8420->SetOutputStatus( MIXVAL_OUTSTATUS_VALID );	// Non-Audio Off, Emphasis Off
		}
		
		// AES16 Digital I/O
		if( m_pAK4114 )
		{
			m_pAK4114->SetDefaults();
		}
		
		m_pLStream->AESSetInputMuteOnError( LSTREAM_BRACKET, TRUE );
		m_pLStream->AESSetInputMuteOnError( LSTREAM_HEADER, TRUE );
		
		// LTC Generator
		if( m_pTCTx )
		{
			m_pTCTx->SetDefaults();
		}

		m_pHalAdapter->SetMTCSource( MIXVAL_MTCSOURCE_LTCRX );

		// Misc controls
		m_pHalAdapter->SetDitherType( m_aRecordMix[0].GetMixControl(), MIXVAL_DITHER_NONE );

		m_pHalAdapter->SetADHPF( CONTROL_AIN12_HPF, TRUE );
		m_pHalAdapter->SetADHPF( CONTROL_AIN34_HPF, TRUE );
		m_pHalAdapter->SetADHPF( CONTROL_AIN56_HPF, TRUE );

		m_pHalAdapter->SetDADeEmphasis( FALSE );
		m_pHalAdapter->SetSyncStartState( TRUE );
	}

	if( !m_pAK4114 )
	{
		// It doesn't matter which model we are using, we set them all to +4 regardless.
		m_pHalAdapter->SetTrim( CONTROL_AIN12_TRIM, MIXVAL_TRIM_PLUS4 );
		m_pHalAdapter->SetTrim( CONTROL_AIN34_TRIM, MIXVAL_TRIM_PLUS4 );
		m_pHalAdapter->SetTrim( CONTROL_AIN56_TRIM, MIXVAL_TRIM_PLUS4 );
		m_pHalAdapter->SetTrim( CONTROL_AOUT12_TRIM, MIXVAL_TRIM_PLUS4 );
		m_pHalAdapter->SetTrim( CONTROL_AOUT34_TRIM, MIXVAL_TRIM_PLUS4 );
		m_pHalAdapter->SetTrim( CONTROL_AOUT56_TRIM, MIXVAL_TRIM_PLUS4 );
	}

	m_bMixerLock = FALSE;

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalMixer::GetFirstMatchingLine( USHORT usSource, PUSHORT pusDstLine, PUSHORT pusSrcLine )
//	Searches each play mixer (starting with Analog Out 1, PMixA) for the 
//	first matching connection.
//	Returns 0xFFFF if no connection found
/////////////////////////////////////////////////////////////////////////////
{
	USHORT	usDstLine, usSrcLine, usLine;

	for( usDstLine = LINE_OUT_1; usDstLine <= LINE_OUT_16; usDstLine++ )
	{
		for( usSrcLine = LINE_PLAY_MIXA; usSrcLine <= LINE_PLAY_MIXD; usSrcLine++ )
		{
			usLine = m_aPlayMix[ usDstLine ].GetSource( usSrcLine );
			if( usLine == usSource )
			{
				*pusDstLine = usDstLine;
				*pusSrcLine = usSrcLine;
				return( HSTATUS_OK );
			}
		}
	}
	
	return( HSTATUS_INVALID_MIXER_LINE );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalMixer::GetSharedControls( USHORT usControl, PSHAREDCONTROLS pShared )
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	i;

	//DPF(("CHalMixer::GetSharedControls\n"));
	//DB('s',COLOR_UNDERLINE);

	RtlZeroMemory( pShared, sizeof( SHAREDCONTROLS ) );

	pShared->ulControlRequest = REQ_FAST_CONTROLS;

	// Metering
	for( i=0; i<SC_NUM_CHANNELS; i++ )
	{
		pShared->Fast.aulInputMeters[i]	 = m_aRecordMix[i].GetLevel();
		m_aRecordMix[i].ResetLevel();
		pShared->Fast.aulOutputMeters[i] = m_aPlayMix[i].GetLevel();
		m_aPlayMix[i].ResetLevel();
	}
	
	
	// LTC In
	if( m_pTCRx )	m_pTCRx->GetPosition( &pShared->Fast.ulLTCInPosition );
	// LTC Out
	if( m_pTCTx )	m_pTCTx->GetPosition( &pShared->Fast.ulLTCOutPosition );
	// LStream
	m_pLStream->ADATGetSyncInTimeCode( LSTREAM_BRACKET, &pShared->Fast.ulLS1ADATPosition );
	m_pLStream->ADATGetSyncInTimeCode( LSTREAM_HEADER, &pShared->Fast.ulLS2ADATPosition );

	if( usControl == CONTROL_SLOW_SHARED_CONTROLS )
	{
		SET( pShared->ulControlRequest, REQ_SLOW_CONTROLS );
		//DC('s');
		// Metering
		for( i=0; i<SC_NUM_CHANNELS; i++ )
		{
			pShared->Slow.aulOutputOverload[i] = m_aPlayMix[i].GetOverload();
		}
		// Digital I/O
		if( m_pCS8420 )
		{
			// this is OK to call in OSX because we don't call IsInputLocked anymore
			m_pCS8420->GetInputSampleRate( &pShared->Slow.lDigitalInRate );
#ifdef OSX
			pShared->Slow.ulDigitalInStatus	= DIS_ERR_UNLOCK;
			pShared->Slow.ulDigitalInSRCRatio = 0;
#else
			pShared->Slow.ulDigitalInStatus = m_pCS8420->GetInputStatus();
			pShared->Slow.ulDigitalInSRCRatio = (ULONG)m_pCS8420->GetSRCRatio();
#endif
		}
		// Frequency Counters
		for( i=0; i<SC_NUM_FREQUENCY_COUNTERS; i++ )
		{
			m_pHalAdapter->GetFrequencyCounter( (USHORT)i, &pShared->Slow.aulFrequencyCounters[i] );
		}
		// AES16
		if( m_pAK4114 )
		{
			for( i=0; i<SC_NUM_AES16_STATUS; i++ )
			{
				m_pAK4114->GetInputStatus( i, &pShared->Slow.aulDigitalInStatus[i] );
			}
			for( i=0; i<SC_NUM_AES16_SRC; i++ )
			{
				m_pAK4114->GetSRCRatio( i, &pShared->Slow.aulDigitalInSRCRatio[i] );
			}

			m_pAK4114->GetSynchroLockStatus( &pShared->Slow.ulSynchroLockStatus );
		}

		// LTC In
		if( m_pTCRx )
		{
			m_pTCRx->GetFrameRate( &pShared->Slow.ulLTCInFramerate );
			pShared->Slow.bLTCInLock		= m_pTCRx->IsInputLocked();
			pShared->Slow.ulLTCInDirection	= m_pTCRx->GetInputDirection();
			pShared->Slow.bLTCInDropframe	= m_pTCRx->GetDropFrame();
		}
		// Device Dropout Count
		for( i=0; i<SC_NUM_DEVICES; i++ )
		{
			pShared->Slow.aulRecordDeviceDropout[i] = m_pHalAdapter->GetWaveInDevice( i )->GetOverrunCount();
			pShared->Slow.aulPlayDeviceDropout[i] = m_pHalAdapter->GetWaveOutDevice( i )->GetOverrunCount();
		}
		// LStream
		pShared->Slow.ulLS1DeviceID = m_pLStream->GetDeviceID( LSTREAM_BRACKET );
		if( pShared->Slow.ulLS1DeviceID == REG_LSDEVID_LSADAT )
		{
			pShared->Slow.bLS1ADATIn1Lock = m_pLStream->ADATIsLocked( LSTREAM_BRACKET, 0 );
			pShared->Slow.bLS1ADATIn2Lock = m_pLStream->ADATIsLocked( LSTREAM_BRACKET, 1 );
		}
		if( pShared->Slow.ulLS1DeviceID == REG_LSDEVID_LSAES )
		{
			pShared->Slow.ulLS1AESStatus1	= m_pLStream->AESGetInputStatus( LSTREAM_BRACKET, k8420_A );
			pShared->Slow.ulLS1AESStatus2	= m_pLStream->AESGetInputStatus( LSTREAM_BRACKET, k8420_B );
			pShared->Slow.ulLS1AESStatus3	= m_pLStream->AESGetInputStatus( LSTREAM_BRACKET, k8420_C );
			pShared->Slow.ulLS1AESStatus4	= m_pLStream->AESGetInputStatus( LSTREAM_BRACKET, k8420_D );
			pShared->Slow.ulLS1AESSRCRatio1	= m_pLStream->AESGetSRCRatio( LSTREAM_BRACKET, k8420_A );
			pShared->Slow.ulLS1AESSRCRatio2	= m_pLStream->AESGetSRCRatio( LSTREAM_BRACKET, k8420_B );
			pShared->Slow.ulLS1AESSRCRatio3	= m_pLStream->AESGetSRCRatio( LSTREAM_BRACKET, k8420_C );
			pShared->Slow.ulLS1AESSRCRatio4	= m_pLStream->AESGetSRCRatio( LSTREAM_BRACKET, k8420_D );
		}
		pShared->Slow.ulLS2DeviceID = m_pLStream->GetDeviceID( LSTREAM_HEADER );
		if( pShared->Slow.ulLS2DeviceID == REG_LSDEVID_LSADAT )
		{
			pShared->Slow.bLS2ADATIn1Lock = m_pLStream->ADATIsLocked( LSTREAM_HEADER, 0 );
			pShared->Slow.bLS2ADATIn2Lock = m_pLStream->ADATIsLocked( LSTREAM_HEADER, 1 );
		}
		if( pShared->Slow.ulLS2DeviceID == REG_LSDEVID_LSAES )
		{
			pShared->Slow.ulLS2AESStatus1	= m_pLStream->AESGetInputStatus( LSTREAM_HEADER, k8420_A );
			pShared->Slow.ulLS2AESStatus2	= m_pLStream->AESGetInputStatus( LSTREAM_HEADER, k8420_B );
			pShared->Slow.ulLS2AESStatus3	= m_pLStream->AESGetInputStatus( LSTREAM_HEADER, k8420_C );
			pShared->Slow.ulLS2AESStatus4	= m_pLStream->AESGetInputStatus( LSTREAM_HEADER, k8420_D );
			pShared->Slow.ulLS2AESSRCRatio1	= m_pLStream->AESGetSRCRatio( LSTREAM_HEADER, k8420_A );
			pShared->Slow.ulLS2AESSRCRatio2	= m_pLStream->AESGetSRCRatio( LSTREAM_HEADER, k8420_B );
			pShared->Slow.ulLS2AESSRCRatio3	= m_pLStream->AESGetSRCRatio( LSTREAM_HEADER, k8420_C );
			pShared->Slow.ulLS2AESSRCRatio4	= m_pLStream->AESGetSRCRatio( LSTREAM_HEADER, k8420_D );
		}
	}
	return( HSTATUS_OK );
}

///////////////////////////////////////////////////////////////////////////////
ULONG	CHalMixer::GetControlType( USHORT usControl )
// Converts a HAL control name to a standardized mixer control type
///////////////////////////////////////////////////////////////////////////////
{
	switch( usControl )
	{
	case CONTROL_VOLUME:				// ushort
//	case CONTROL_MONITOR_VOLUME:
		return( MIXER_CONTROL_TYPE_VOLUME );
	
//	case CONTROL_MONITOR_PAN:
//		return( MIXER_CONTROL_TYPE_PAN );

	case CONTROL_PEAKMETER:				// short
		return( MIXER_CONTROL_TYPE_PEAKMETER );

//	case CONTROL_MONITOR_MUTE:
	case CONTROL_MUTE:
	case CONTROL_MUTEA:
	case CONTROL_MUTEB:
		return( MIXER_CONTROL_TYPE_MUTE );

	case CONTROL_SOURCE:	// MUX
	case CONTROL_SOURCE_LEFT:	// MUX
	case CONTROL_SOURCE_RIGHT:	// MUX
	case CONTROL_DITHER_DEPTH:	// MUX
	case CONTROL_INPUT_SOURCE:	// MUX
	case CONTROL_CLOCKSOURCE:	// MUX
	case CONTROL_CLOCKREFERENCE:	// MUX
	case CONTROL_DIGITAL_FORMAT:	// MUX
	case CONTROL_SRC_MODE:	// MUX
	case CONTROL_TRIM:	// MUX
	case CONTROL_MONITOR_SOURCE:	// MUX
	case CONTROL_AIN12_TRIM:	// MUX
	case CONTROL_AIN34_TRIM:	// MUX
	case CONTROL_AIN56_TRIM:	// MUX
	case CONTROL_AOUT12_TRIM:	// MUX
	case CONTROL_AOUT34_TRIM:	// MUX
	case CONTROL_AOUT56_TRIM:	// MUX
	case CONTROL_LTCOUT_FRAMERATE:	// MUX
	case CONTROL_LTCOUT_SYNCSOURCE:	// MUX
	case CONTROL_LS1_OUTSEL:	// MUX
	case CONTROL_LS1_ADAT_CLKSRC:	// MUX
	case CONTROL_LS1_AES_CLKSRC:	// MUX
	case CONTROL_LS1_D1_FORMAT:	// MUX
	case CONTROL_LS1_DI1_SRC_MODE:	// MUX
	case CONTROL_LS1_D2_FORMAT:	// MUX
	case CONTROL_LS1_DI2_SRC_MODE:	// MUX
	case CONTROL_LS1_D3_FORMAT:	// MUX
	case CONTROL_LS1_DI3_SRC_MODE:	// MUX
	case CONTROL_LS1_D4_FORMAT:	// MUX
	case CONTROL_LS1_DI4_SRC_MODE:	// MUX
	case CONTROL_LS2_OUTSEL:	// MUX
	case CONTROL_LS2_ADAT_CLKSRC:	// MUX
	case CONTROL_LS2_AES_CLKSRC:	// MUX
	case CONTROL_LS2_D1_FORMAT:	// MUX
	case CONTROL_LS2_DI1_SRC_MODE:	// MUX
	case CONTROL_LS2_D2_FORMAT:	// MUX
	case CONTROL_LS2_DI2_SRC_MODE:	// MUX
	case CONTROL_LS2_D3_FORMAT:	// MUX
	case CONTROL_LS2_DI3_SRC_MODE:	// MUX
	case CONTROL_LS2_D4_FORMAT:	// MUX
	case CONTROL_LS2_DI4_SRC_MODE:	// MUX
	case CONTROL_FP_METER_SOURCE:	// MUX
	case CONTROL_LSLOT_OUT_SOURCE:	// MUX
	case CONTROL_TRIM_AIN_1_4:	// MUX
	case CONTROL_TRIM_AIN_5_8:	// MUX
	case CONTROL_TRIM_AIN_9_12:	// MUX
	case CONTROL_TRIM_AIN_13_16:	// MUX
	case CONTROL_TRIM_AOUT_1_4:	// MUX
	case CONTROL_TRIM_AOUT_5_8:	// MUX
	case CONTROL_TRIM_AOUT_9_12:	// MUX
	case CONTROL_TRIM_AOUT_13_16:	// MUX
	case CONTROL_SOURCEA:	// MUX
	case CONTROL_SOURCEB:	// MUX
	case CONTROL_DITHER_TYPE:	// MUX
	case CONTROL_PLAY_DITHER:	// MUX
	case CONTROL_RECORD_DITHER:	// MUX
	case CONTROL_MTC_SOURCE:	// MUX
		return( MIXER_CONTROL_TYPE_MUX );

//	case CONTROL_MONITOR_LEFT:			// mixer
//	case CONTROL_MONITOR_RIGHT:			// mixer
//		return( MIXER_CONTROL_TYPE_MIXER );

	case CONTROL_DITHER:	// BOOLEAN
	case CONTROL_MONITOR:	// BOOLEAN
	case CONTROL_PHASE:	// BOOLEAN
	case CONTROL_WIDEWIREIN:	// BOOLEAN
	case CONTROL_WIDEWIREOUT:	// BOOLEAN
	case CONTROL_AUTOCLOCKSELECT:	// BOOLEAN
	case CONTROL_DIGITALIN_MUTE_ON_ERROR:	// BOOLEAN
	case CONTROL_LEVELS:	// BOOLEAN
	case CONTROL_SYNCIN_NTSC:	// BOOLEAN
	case CONTROL_DIGITALIN5_SRC_ENABLE:	// BOOLEAN
	case CONTROL_DIGITALIN6_SRC_ENABLE:	// BOOLEAN
	case CONTROL_DIGITALIN7_SRC_ENABLE:	// BOOLEAN
	case CONTROL_DIGITALIN8_SRC_ENABLE:	// BOOLEAN
	case CONTROL_LTCIN_LOCKED:	// BOOLEAN
	case CONTROL_LTCIN_DIRECTION:	// BOOLEAN
	case CONTROL_LTCIN_DROPFRAME:	// BOOLEAN
	case CONTROL_LTCOUT_ENABLE:	// BOOLEAN
	case CONTROL_LTCOUT_DROPFRAME:	// BOOLEAN
	case CONTROL_LS1_ADAT_IN1_LOCK:	// BOOLEAN
	case CONTROL_LS1_ADAT_IN2_LOCK:	// BOOLEAN
	case CONTROL_LS1_ADAT_CUEPOINT_ENABLE:	// BOOLEAN
	case CONTROL_LS1_AES_WIDEWIRE:	// BOOLEAN
	case CONTROL_LS2_ADAT_IN1_LOCK:	// BOOLEAN
	case CONTROL_LS2_ADAT_IN2_LOCK:	// BOOLEAN
	case CONTROL_LS2_ADAT_CUEPOINT_ENABLE:	// BOOLEAN
	case CONTROL_LS2_AES_WIDEWIRE:	// BOOLEAN
	case CONTROL_ADDA_RECALIBRATE:	// BOOLEAN
	case CONTROL_AUTO_RECALIBRATE:	// BOOLEAN
	case CONTROL_AIN12_HPF:	// BOOLEAN
	case CONTROL_AIN34_HPF:	// BOOLEAN
	case CONTROL_AIN56_HPF:	// BOOLEAN
	case CONTROL_ADHIPASSFILTER:	// BOOLEAN
	case CONTROL_DA_AUTOMUTE:	// BOOLEAN
	case CONTROL_DA_DEEMPHASIS:	// BOOLEAN
	case CONTROL_SYNCHROLOCK_ENABLE:	// BOOLEAN
	case CONTROL_DIGITALIN_SRC_MATCHPHASE:	// BOOLEAN
	case CONTROL_SYNCSTART:	// BOOLEAN
	case CONTROL_LSTREAM_DUAL_INTERNAL:	// BOOLEAN
	case CONTROL_MONITOR_OFF_PLAY:	// BOOLEAN
	case CONTROL_MONITOR_ON_RECORD:	// BOOLEAN
	case CONTROL_MIXER_LOCK:	// BOOLEAN
		return( MIXER_CONTROL_TYPE_BOOLEAN );

	case CONTROL_OVERLOAD:	// ULONG
	case CONTROL_OVERRUN_COUNT:	// ULONG
	case CONTROL_SAMPLE_COUNT:	// ULONG
	case CONTROL_SAMPLE_FORMAT:	// ULONG
	case CONTROL_CLOCKRATE:	// ULONG
	case CONTROL_SYNCHROLOCK_STATUS:	// ULONG
	case CONTROL_SRC_RATIO:	// ULONG
	case CONTROL_DIGITALIN_RATE:	// ULONG
	case CONTROL_DIGITALIN_STATUS:	// ULONG
	case CONTROL_DIGITALOUT_STATUS:	// ULONG
	case CONTROL_FREQUENCY_COUNTER_1:	// ULONG
	case CONTROL_FREQUENCY_COUNTER_2:	// ULONG
	case CONTROL_FREQUENCY_COUNTER_3:	// ULONG
	case CONTROL_FREQUENCY_COUNTER_4:	// ULONG
	case CONTROL_FREQUENCY_COUNTER_5:	// ULONG
	case CONTROL_FREQUENCY_COUNTER_6:	// ULONG
	case CONTROL_FREQUENCY_COUNTER_7:	// ULONG
	case CONTROL_FREQUENCY_COUNTER_8:	// ULONG
	case CONTROL_FREQUENCY_COUNTER_9:	// ULONG
	case CONTROL_FREQUENCY_COUNTER_10:	// ULONG
	case CONTROL_FREQUENCY_COUNTER_11:	// ULONG
	case CONTROL_FREQUENCY_COUNTER_12:	// ULONG
	case CONTROL_FREQUENCY_COUNTER_13:	// ULONG
	case CONTROL_DIGITALIN1_STATUS:	// ULONG
	case CONTROL_DIGITALIN1_RATE:	// ULONG
	case CONTROL_DIGITALIN2_STATUS:	// ULONG
	case CONTROL_DIGITALIN2_RATE:	// ULONG
	case CONTROL_DIGITALIN3_STATUS:	// ULONG
	case CONTROL_DIGITALIN3_RATE:	// ULONG
	case CONTROL_DIGITALIN4_STATUS:	// ULONG
	case CONTROL_DIGITALIN4_RATE:	// ULONG
	case CONTROL_DIGITALIN5_STATUS:	// ULONG
	case CONTROL_DIGITALIN5_RATE:	// ULONG
	case CONTROL_DIGITALIN5_SRC_RATIO:	// ULONG
	case CONTROL_DIGITALIN6_STATUS:	// ULONG
	case CONTROL_DIGITALIN6_RATE:	// ULONG
	case CONTROL_DIGITALIN6_SRC_RATIO:	// ULONG
	case CONTROL_DIGITALIN7_STATUS:	// ULONG
	case CONTROL_DIGITALIN7_RATE:	// ULONG
	case CONTROL_DIGITALIN7_SRC_RATIO:	// ULONG
	case CONTROL_DIGITALIN8_STATUS:	// ULONG
	case CONTROL_DIGITALIN8_RATE:	// ULONG
	case CONTROL_DIGITALIN8_SRC_RATIO:	// ULONG
	case CONTROL_DIGITALOUT1_STATUS:	// ULONG
	case CONTROL_DIGITALOUT2_STATUS:	// ULONG
	case CONTROL_DIGITALOUT3_STATUS:	// ULONG
	case CONTROL_DIGITALOUT4_STATUS:	// ULONG
	case CONTROL_DIGITALOUT5_STATUS:	// ULONG
	case CONTROL_DIGITALOUT6_STATUS:	// ULONG
	case CONTROL_DIGITALOUT7_STATUS:	// ULONG
	case CONTROL_DIGITALOUT8_STATUS:	// ULONG
	case CONTROL_LTCIN_FRAMERATE:	// ULONG
	case CONTROL_LTCIN_POSITION:	// ULONG
	case CONTROL_LTCOUT_POSITION:	// ULONG
	case CONTROL_LS1_DEVICEID:	// ULONG
	case CONTROL_LS1_PCBREV:	// ULONG
	case CONTROL_LS1_FIRMWAREREV:	// ULONG
	case CONTROL_LS1_ADAT_POSITION:	// ULONG
	case CONTROL_LS1_ADAT_CUEPOINT:	// ULONG
	case CONTROL_LS1_DI1_RATE:	// ULONG
	case CONTROL_LS1_DI1_SRC_RATIO:	// ULONG
	case CONTROL_LS1_DI1_STATUS:	// ULONG
	case CONTROL_LS1_DO1_STATUS:	// ULONG
	case CONTROL_LS1_DI2_RATE:	// ULONG
	case CONTROL_LS1_DI2_SRC_RATIO:	// ULONG
	case CONTROL_LS1_DI2_STATUS:	// ULONG
	case CONTROL_LS1_DO2_STATUS:	// ULONG
	case CONTROL_LS1_DI3_RATE:	// ULONG
	case CONTROL_LS1_DI3_SRC_RATIO:	// ULONG
	case CONTROL_LS1_DI3_STATUS:	// ULONG
	case CONTROL_LS1_DO3_STATUS:	// ULONG
	case CONTROL_LS1_DI4_RATE:	// ULONG
	case CONTROL_LS1_DI4_SRC_RATIO:	// ULONG
	case CONTROL_LS1_DI4_STATUS:	// ULONG
	case CONTROL_LS1_DO4_STATUS:	// ULONG
	case CONTROL_LS2_DEVICEID:	// ULONG
	case CONTROL_LS2_PCBREV:	// ULONG
	case CONTROL_LS2_FIRMWAREREV:	// ULONG
	case CONTROL_LS2_ADAT_POSITION:	// ULONG
	case CONTROL_LS2_ADAT_CUEPOINT:	// ULONG
	case CONTROL_LS2_DI1_RATE:	// ULONG
	case CONTROL_LS2_DI1_SRC_RATIO:	// ULONG
	case CONTROL_LS2_DI1_STATUS:	// ULONG
	case CONTROL_LS2_DO1_STATUS:	// ULONG
	case CONTROL_LS2_DI2_RATE:	// ULONG
	case CONTROL_LS2_DI2_SRC_RATIO:	// ULONG
	case CONTROL_LS2_DI2_STATUS:	// ULONG
	case CONTROL_LS2_DO2_STATUS:	// ULONG
	case CONTROL_LS2_DI3_RATE:	// ULONG
	case CONTROL_LS2_DI3_SRC_RATIO:	// ULONG
	case CONTROL_LS2_DI3_STATUS:	// ULONG
	case CONTROL_LS2_DO3_STATUS:	// ULONG
	case CONTROL_LS2_DI4_RATE:	// ULONG
	case CONTROL_LS2_DI4_SRC_RATIO:	// ULONG
	case CONTROL_LS2_DI4_STATUS:	// ULONG
	case CONTROL_LS2_DO4_STATUS:	// ULONG
	case CONTROL_VOLUMEA:	// ULONG
	case CONTROL_VOLUMEB:	// ULONG
	case CONTROL_DEVICEID:	// ULONG
	case CONTROL_PCBREV:	// ULONG
	case CONTROL_FIRMWAREREV:	// ULONG
	case CONTROL_FIRMWAREDATE:	// ULONG
	case CONTROL_MINSOFTWAREREV:	// ULONG
	case CONTROL_SERIALNUMBER:	// ULONG
	case CONTROL_MFGDATE:	// ULONG
	case CONTROL_FAST_SHARED_CONTROLS:	// ULONG
	case CONTROL_SLOW_SHARED_CONTROLS:	// ULONG
	case CONTROL_MIXER_RESTORE_SCENE:	// ULONG
	case CONTROL_MIXER_SAVE_SCENE:	// ULONG
		return( MIXER_CONTROL_TYPE_UNSIGNED );
	default:
		DPF(("CHalMixer::GetControlType: Unknown Control %d\n", usControl ));
		break;
	}
	
	return( MIXER_CONTROL_TYPE_UNSIGNED );
}

/////////////////////////////////////////////////////////////////////////////
BOOLEAN	CHalMixer::IsControlWriteable( USHORT usControl )
// Returns FALSE for controls that should not be saved in a scene
/////////////////////////////////////////////////////////////////////////////
{
	switch( usControl )
	{
	case CONTROL_OVERLOAD:	// BOOLEAN
	case CONTROL_PEAKMETER:	// ULONG
	case CONTROL_OVERRUN_COUNT:	// ULONG
	case CONTROL_SAMPLE_COUNT:	// ULONG
	case CONTROL_SAMPLE_FORMAT:	// ULONG
	case CONTROL_DIGITALIN_RATE:	// ULONG
	case CONTROL_SRC_RATIO:	// ULONG
	case CONTROL_DIGITALIN_STATUS:	// ULONG
	
	// AES16
	case CONTROL_SYNCHROLOCK_STATUS:	// ULONG
	case CONTROL_DIGITALIN1_STATUS:	// ULONG
	case CONTROL_DIGITALIN1_RATE:	// ULONG
	case CONTROL_DIGITALIN2_STATUS:	// ULONG
	case CONTROL_DIGITALIN2_RATE:	// ULONG
	case CONTROL_DIGITALIN3_STATUS:	// ULONG
	case CONTROL_DIGITALIN3_RATE:	// ULONG
	case CONTROL_DIGITALIN4_STATUS:	// ULONG
	case CONTROL_DIGITALIN4_RATE:	// ULONG
	case CONTROL_DIGITALIN5_STATUS:	// ULONG
	case CONTROL_DIGITALIN5_RATE:	// ULONG
	case CONTROL_DIGITALIN5_SRC_RATIO:	// ULONG
	case CONTROL_DIGITALIN6_STATUS:	// ULONG
	case CONTROL_DIGITALIN6_RATE:	// ULONG
	case CONTROL_DIGITALIN6_SRC_RATIO:	// ULONG
	case CONTROL_DIGITALIN7_STATUS:	// ULONG
	case CONTROL_DIGITALIN7_RATE:	// ULONG
	case CONTROL_DIGITALIN7_SRC_RATIO:	// ULONG
	case CONTROL_DIGITALIN8_STATUS:	// ULONG
	case CONTROL_DIGITALIN8_RATE:	// ULONG
	case CONTROL_DIGITALIN8_SRC_RATIO:	// ULONG

	case CONTROL_FREQUENCY_COUNTER_1:	// ULONG
	case CONTROL_FREQUENCY_COUNTER_2:	// ULONG
	case CONTROL_FREQUENCY_COUNTER_3:	// ULONG
	case CONTROL_FREQUENCY_COUNTER_4:	// ULONG
	case CONTROL_FREQUENCY_COUNTER_5:	// ULONG
	case CONTROL_FREQUENCY_COUNTER_6:	// ULONG
	case CONTROL_FREQUENCY_COUNTER_7:	// ULONG
	case CONTROL_FREQUENCY_COUNTER_8:	// ULONG
	case CONTROL_FREQUENCY_COUNTER_9:	// ULONG
	case CONTROL_FREQUENCY_COUNTER_10:	// ULONG
	case CONTROL_FREQUENCY_COUNTER_11:	// ULONG
	case CONTROL_FREQUENCY_COUNTER_12:	// ULONG
	case CONTROL_FREQUENCY_COUNTER_13:	// ULONG
	case CONTROL_SYNCIN_NTSC:	// BOOLEAN
	case CONTROL_LTCIN_LOCKED:	// BOOLEAN
	case CONTROL_LTCIN_DIRECTION:	// BOOLEAN
	case CONTROL_LTCIN_DROPFRAME:	// BOOLEAN
	case CONTROL_LTCIN_FRAMERATE:	// ULONG
	case CONTROL_LTCIN_POSITION:	// ULONG
	
	case CONTROL_LS1_DEVICEID:	// ULONG
	case CONTROL_LS1_PCBREV:	// ULONG
	case CONTROL_LS1_FIRMWAREREV:	// ULONG
	case CONTROL_LS1_ADAT_IN1_LOCK:	// BOOLEAN
	case CONTROL_LS1_ADAT_IN2_LOCK:	// BOOLEAN
	case CONTROL_LS1_ADAT_POSITION:
	case CONTROL_LS1_ADAT_CUEPOINT_ENABLE:
	
	case CONTROL_LS1_DI1_RATE:	// ULONG
	case CONTROL_LS1_DI1_SRC_RATIO:	// ULONG
	case CONTROL_LS1_DI1_STATUS:	// ULONG
	case CONTROL_LS1_DI2_RATE:	// ULONG
	case CONTROL_LS1_DI2_SRC_RATIO:	// ULONG
	case CONTROL_LS1_DI2_STATUS:	// ULONG
	case CONTROL_LS1_DI3_RATE:	// ULONG
	case CONTROL_LS1_DI3_SRC_RATIO:	// ULONG
	case CONTROL_LS1_DI3_STATUS:	// ULONG
	case CONTROL_LS1_DI4_RATE:	// ULONG
	case CONTROL_LS1_DI4_SRC_RATIO:	// ULONG
	case CONTROL_LS1_DI4_STATUS:	// ULONG
	
	case CONTROL_LS2_DEVICEID:	// ULONG
	case CONTROL_LS2_PCBREV:	// ULONG
	case CONTROL_LS2_FIRMWAREREV:	// ULONG
	case CONTROL_LS2_ADAT_IN1_LOCK:	// BOOLEAN
	case CONTROL_LS2_ADAT_IN2_LOCK:	// BOOLEAN
	case CONTROL_LS2_ADAT_POSITION:
	case CONTROL_LS2_ADAT_CUEPOINT_ENABLE:
	
	case CONTROL_LS2_DI1_RATE:	// ULONG
	case CONTROL_LS2_DI1_SRC_RATIO:	// ULONG
	case CONTROL_LS2_DI1_STATUS:	// ULONG
	case CONTROL_LS2_DI2_RATE:	// ULONG
	case CONTROL_LS2_DI2_SRC_RATIO:	// ULONG
	case CONTROL_LS2_DI2_STATUS:	// ULONG
	case CONTROL_LS2_DI3_RATE:	// ULONG
	case CONTROL_LS2_DI3_SRC_RATIO:	// ULONG
	case CONTROL_LS2_DI3_STATUS:	// ULONG
	case CONTROL_LS2_DI4_RATE:	// ULONG
	case CONTROL_LS2_DI4_SRC_RATIO:	// ULONG
	case CONTROL_LS2_DI4_STATUS:	// ULONG

	case CONTROL_ADDA_RECALIBRATE:	// BOOLEAN
	case CONTROL_DEVICEID:	// ULONG
	case CONTROL_PCBREV:	// ULONG
	case CONTROL_FIRMWAREREV:	// ULONG
	case CONTROL_FIRMWAREDATE:	// ULONG
	case CONTROL_MINSOFTWAREREV:	// ULONG
	case CONTROL_SERIALNUMBER:	// ULONG
	case CONTROL_MFGDATE:	// ULONG
	case CONTROL_DITHER_DEPTH:	// MUX
	case CONTROL_FAST_SHARED_CONTROLS:
	case CONTROL_SLOW_SHARED_CONTROLS:
	case CONTROL_MIXER_RESTORE_SCENE:
	case CONTROL_MIXER_SAVE_SCENE:
		return( FALSE );
	}
	
	return( TRUE );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalMixer::SetControl( USHORT usDstLine, USHORT usSrcLine, USHORT usControl, USHORT usChannel, ULONG ulValue )
/////////////////////////////////////////////////////////////////////////////
{
	long	lRate, lSource, lReference;
	USHORT	usCh, usDst, usSrc;

	if( !m_bOpen )
		return( HSTATUS_ADAPTER_NOT_OPEN );

	if( m_bMixerLock )
	{
		switch( usControl )
		{
		// allow these controls through no matter what
		case CONTROL_MIXER_LOCK:
		case CONTROL_MIXER_RESTORE_SCENE:
		case CONTROL_MIXER_SAVE_SCENE:
			break;
		default:
			return( HSTATUS_MIXER_LOCKED );
		}
	}

	// handle the play mix controls first
	switch( usSrcLine )
	{
	case LINE_NO_SOURCE:
		if( usDstLine < NUM_WAVE_PHYSICAL_OUTPUTS )
		{
			switch( usControl )
			{
			case CONTROL_VOLUME:
				m_aPlayMix[ usDstLine ].SetVolume( ulValue );
				return( HSTATUS_OK );
			case CONTROL_MUTE:
				m_aPlayMix[ usDstLine ].SetMute( (BOOLEAN)ulValue );
				return( HSTATUS_OK );
			case CONTROL_PHASE:
				m_aPlayMix[ usDstLine ].SetPhase( (BOOLEAN)ulValue );
				return( HSTATUS_OK );
			case CONTROL_DITHER:
				m_aPlayMix[ usDstLine ].SetDither( (BOOLEAN)ulValue );
				return( HSTATUS_OK );
			case CONTROL_OVERLOAD:
				m_aPlayMix[ usDstLine ].ResetOverload();
				return( HSTATUS_OK );
			default:
				// don't think we should error out here because there might
				// be other controls on this line
				//return( HSTATUS_INVALID_MIXER_CONTROL );
				break;
			}
		}
		break;
	case LINE_PLAY_MIXA:
	case LINE_PLAY_MIXB:
	case LINE_PLAY_MIXC:
	case LINE_PLAY_MIXD:
		if( usDstLine < NUM_WAVE_PHYSICAL_OUTPUTS )
		{
			switch( usControl )
			{
			case CONTROL_VOLUME:
				m_aPlayMix[ usDstLine ].SetVolume( usSrcLine, ulValue );
				return( HSTATUS_OK );
			case CONTROL_MUTE:
				m_aPlayMix[ usDstLine ].SetMute( usSrcLine, (BOOLEAN)ulValue );
				return( HSTATUS_OK );
			case CONTROL_PHASE:
				m_aPlayMix[ usDstLine ].SetPhase( usSrcLine, (BOOLEAN)ulValue );
				return( HSTATUS_OK );
			case CONTROL_SOURCE:
				m_aPlayMix[ usDstLine ].SetSource( usSrcLine, (USHORT)ulValue );
				return( HSTATUS_OK );
			default:
				return( HSTATUS_INVALID_MIXER_CONTROL );
			}
		}
		break;
	}

	switch( usDstLine )
	{
	case LINE_ADAPTER:
		// only allow NO_SOURCE thru...
		if( usSrcLine != LINE_NO_SOURCE )
			return( HSTATUS_INVALID_MIXER_LINE );

		switch( usControl )
		{
		case CONTROL_CLOCKSOURCE:
			m_pSampleClock->Get( &lRate, &lSource, &lReference );
			// if there is a AK4114, then this must be an AES16
			if( m_pAK4114 )	ulValue += MIXVAL_AES16_CLKSRC_INTERNAL;
			return( m_pSampleClock->Set( lRate, ulValue, lReference ) );
			break;
		case CONTROL_CLOCKREFERENCE:
			m_pSampleClock->Get( &lRate, &lSource, &lReference );
			return( m_pSampleClock->Set( lRate, lSource, ulValue ) );
			break;
		case CONTROL_CLOCKRATE:
			return( m_pSampleClock->Set( (LONG)ulValue ) );
			break;
		
		// CS8420 Digital I/O
		case CONTROL_DIGITAL_FORMAT:
			if( m_pCS8420 )	m_pCS8420->SetFormat( ulValue );
			break;
		case CONTROL_SRC_MODE:
			if( m_pCS8420 )	m_pCS8420->SetMode( ulValue );
			break;
		case CONTROL_DIGITALIN_MUTE_ON_ERROR:
			if( m_pCS8420 )	m_pCS8420->SetInputMuteOnError( (BOOLEAN)ulValue );
			m_pLStream->AESSetInputMuteOnError( LSTREAM_BRACKET, (BOOLEAN)ulValue );
			m_pLStream->AESSetInputMuteOnError( LSTREAM_HEADER, (BOOLEAN)ulValue );
			break;
		case CONTROL_DIGITALOUT_STATUS:
			if( m_pCS8420 )	m_pCS8420->SetOutputStatus( ulValue );
			break;
		
		// AES16 Digital I/O
		case CONTROL_WIDEWIREIN:	// BOOLEAN
		case CONTROL_WIDEWIREOUT:	// BOOLEAN
		case CONTROL_SYNCHROLOCK_ENABLE:	// BOOLEAN
		case CONTROL_DIGITALIN5_SRC_ENABLE:	// BOOLEAN
		case CONTROL_DIGITALIN6_SRC_ENABLE:	// BOOLEAN
		case CONTROL_DIGITALIN7_SRC_ENABLE:	// BOOLEAN
		case CONTROL_DIGITALIN8_SRC_ENABLE:	// BOOLEAN
		case CONTROL_DIGITALIN_SRC_MATCHPHASE:	// BOOLEAN
		case CONTROL_DIGITALOUT1_STATUS:	// ULONG
		case CONTROL_DIGITALOUT2_STATUS:	// ULONG
		case CONTROL_DIGITALOUT3_STATUS:	// ULONG
		case CONTROL_DIGITALOUT4_STATUS:	// ULONG
		case CONTROL_DIGITALOUT5_STATUS:	// ULONG
		case CONTROL_DIGITALOUT6_STATUS:	// ULONG
		case CONTROL_DIGITALOUT7_STATUS:	// ULONG
		case CONTROL_DIGITALOUT8_STATUS:	// ULONG
			return( m_pAK4114->SetMixerControl( usControl, ulValue ) );

		case CONTROL_AIN12_TRIM:
		case CONTROL_AIN34_TRIM:
		case CONTROL_AIN56_TRIM:
		case CONTROL_AOUT12_TRIM:
		case CONTROL_AOUT34_TRIM:
		case CONTROL_AOUT56_TRIM:
			m_pHalAdapter->SetTrim( usControl, ulValue );
			break;
		
		// Timecode
		case CONTROL_LTCOUT_ENABLE:		// BOOLEAN
		case CONTROL_LTCOUT_FRAMERATE:	// MUX
		case CONTROL_LTCOUT_DROPFRAME:	// BOOLEAN
		case CONTROL_LTCOUT_SYNCSOURCE:	// MUX
		case CONTROL_LTCOUT_POSITION:	// ULONG
			if( !m_pTCTx )	return( HSTATUS_INVALID_MIXER_CONTROL );
			m_pTCTx->SetMixerControl( usControl, ulValue );
			break;

		case CONTROL_MTC_SOURCE:
			m_pHalAdapter->SetMTCSource( ulValue );
			break;

		case CONTROL_ADDA_RECALIBRATE:	// BOOLEAN
			m_pHalAdapter->CalibrateConverters();
			break;
		case CONTROL_AUTO_RECALIBRATE:	// BOOLEAN
			m_pHalAdapter->SetAutoRecalibrate( (BOOLEAN)ulValue );
			break;

		case CONTROL_DITHER_TYPE:		// MUX
			m_pHalAdapter->SetDitherType( m_aRecordMix[0].GetMixControl(), (USHORT)ulValue );
			break;

		case CONTROL_AIN12_HPF:		// BOOLEAN
		case CONTROL_AIN34_HPF:		// BOOLEAN
		case CONTROL_AIN56_HPF:		// BOOLEAN
			m_pHalAdapter->SetADHPF( usControl, (BOOLEAN)ulValue );
			break;
		case CONTROL_DA_DEEMPHASIS:
			m_pHalAdapter->SetDADeEmphasis( (BOOLEAN)ulValue );
			break;
		case CONTROL_SYNCSTART:			// BOOLEAN
			m_pHalAdapter->SetSyncStartState( (BOOLEAN)ulValue );
			break;
		case CONTROL_LSTREAM_DUAL_INTERNAL:		// BOOLEAN
			m_pLStream->SetLStreamDualInternal( ulValue );
			break;
		case CONTROL_MIXER_SAVE_SCENE:
			if( ulValue )
			{
				if( m_pSaveSceneCallback )
					m_pSaveSceneCallback( m_pContext, ulValue );
			}
			else	// scene 0 isn't writable
			{
				return( HSTATUS_INVALID_MIXER_VALUE );
			}
			break;
		case CONTROL_MIXER_RESTORE_SCENE:
			m_bMixerLock = FALSE;	// must have mixer lock off before calling this function

			if( ulValue )
			{
				if( m_pRestoreSceneCallback )
					m_pRestoreSceneCallback( m_pContext, ulValue );
			}
			else
			{
				SetDefaults();
			}
			break;
		case CONTROL_MIXER_LOCK:		// BOOLEAN
			m_bMixerLock = (BOOLEAN)(ulValue & 0x1);
			break;
		
		default:
			return( HSTATUS_INVALID_MIXER_CONTROL );
		}
		break;

	case LINE_LSTREAM:
		// only allow NO_SOURCE thru...
		if( usSrcLine != LINE_NO_SOURCE )
			return( HSTATUS_INVALID_MIXER_LINE );

		switch( usControl )
		{
		// LStream
		case CONTROL_LS1_OUTSEL:	// MUX
			m_pLStream->SetOutputSelection( LSTREAM_BRACKET, ulValue );
			break;
		case CONTROL_LS2_OUTSEL:	// MUX
			m_pLStream->SetOutputSelection( LSTREAM_HEADER, ulValue );
			break;
		
		// LS-ADAT Specific
		case CONTROL_LS1_ADAT_CLKSRC:	// MUX
			m_pLStream->ADATSetClockSource( LSTREAM_BRACKET, ulValue );
			break;
		case CONTROL_LS1_ADAT_CUEPOINT:
			m_pLStream->ADATSetCuePoint( LSTREAM_BRACKET, ulValue );
			break;
		case CONTROL_LS1_ADAT_CUEPOINT_ENABLE:
			m_pHalAdapter->EnableLStreamSyncStart( (BOOLEAN)ulValue );
			break;
		case CONTROL_LS2_ADAT_CLKSRC:	// MUX
			m_pLStream->ADATSetClockSource( LSTREAM_HEADER, ulValue );
			break;
		case CONTROL_LS2_ADAT_CUEPOINT:
			m_pLStream->ADATSetCuePoint( LSTREAM_HEADER, ulValue );
			break;
		case CONTROL_LS2_ADAT_CUEPOINT_ENABLE:
			m_pHalAdapter->EnableLStreamSyncStart( (BOOLEAN)ulValue );
			break;
		
		// LS-AES Specific
		case CONTROL_LS1_AES_CLKSRC:	// MUX
			m_pLStream->AESSetClockSource( LSTREAM_BRACKET, ulValue );
			break;
		case CONTROL_LS1_AES_WIDEWIRE:	// BOOLEAN
			m_pLStream->AESSetWideWire( LSTREAM_BRACKET, ulValue );
			break;
		case CONTROL_LS1_D1_FORMAT:	// MUX
			m_pLStream->AESSetFormat( LSTREAM_BRACKET, k8420_A, ulValue );
			break;
		case CONTROL_LS1_DI1_SRC_MODE:	// MUX
			m_pLStream->AESSetSRCMode( LSTREAM_BRACKET, k8420_A, ulValue );
			break;
		case CONTROL_LS1_DO1_STATUS:	// ULONG
			m_pLStream->AESSetOutputStatus( LSTREAM_BRACKET, k8420_A, ulValue );
			break;
		case CONTROL_LS1_D2_FORMAT:	// MUX
			m_pLStream->AESSetFormat( LSTREAM_BRACKET, k8420_B, ulValue );
			break;
		case CONTROL_LS1_DI2_SRC_MODE:	// MUX
			m_pLStream->AESSetSRCMode( LSTREAM_BRACKET, k8420_B, ulValue );
			break;
		case CONTROL_LS1_DO2_STATUS:	// ULONG
			m_pLStream->AESSetOutputStatus( LSTREAM_BRACKET, k8420_B, ulValue );
			break;
		case CONTROL_LS1_D3_FORMAT:	// MUX
			m_pLStream->AESSetFormat( LSTREAM_BRACKET, k8420_C, ulValue );
			break;
		case CONTROL_LS1_DI3_SRC_MODE:	// MUX
			m_pLStream->AESSetSRCMode( LSTREAM_BRACKET, k8420_C, ulValue );
			break;
		case CONTROL_LS1_DO3_STATUS:	// ULONG
			m_pLStream->AESSetOutputStatus( LSTREAM_BRACKET, k8420_C, ulValue );
			break;
		case CONTROL_LS1_D4_FORMAT:	// MUX
			m_pLStream->AESSetFormat( LSTREAM_BRACKET, k8420_D, ulValue );
			break;
		case CONTROL_LS1_DI4_SRC_MODE:	// MUX
			m_pLStream->AESSetSRCMode( LSTREAM_BRACKET, k8420_D, ulValue );
			break;
		case CONTROL_LS1_DO4_STATUS:	// ULONG
			m_pLStream->AESSetOutputStatus( LSTREAM_BRACKET, k8420_D, ulValue );
			break;

		case CONTROL_LS2_AES_CLKSRC:	// MUX
			m_pLStream->AESSetClockSource( LSTREAM_HEADER, ulValue );
			break;
		case CONTROL_LS2_AES_WIDEWIRE:	// BOOLEAN
			m_pLStream->AESSetWideWire( LSTREAM_HEADER, ulValue );
			break;
		case CONTROL_LS2_D1_FORMAT:	// MUX
			m_pLStream->AESSetFormat( LSTREAM_HEADER, k8420_A, ulValue );
			break;
		case CONTROL_LS2_DI1_SRC_MODE:	// MUX
			m_pLStream->AESSetSRCMode( LSTREAM_HEADER, k8420_A, ulValue );
			break;
		case CONTROL_LS2_DO1_STATUS:	// ULONG
			m_pLStream->AESSetOutputStatus( LSTREAM_HEADER, k8420_A, ulValue );
			break;
		case CONTROL_LS2_D2_FORMAT:	// MUX
			m_pLStream->AESSetFormat( LSTREAM_HEADER, k8420_B, ulValue );
			break;
		case CONTROL_LS2_DI2_SRC_MODE:	// MUX
			m_pLStream->AESSetSRCMode( LSTREAM_HEADER, k8420_B, ulValue );
			break;
		case CONTROL_LS2_DO2_STATUS:	// ULONG
			m_pLStream->AESSetOutputStatus( LSTREAM_HEADER, k8420_B, ulValue );
			break;
		case CONTROL_LS2_D3_FORMAT:	// MUX
			m_pLStream->AESSetFormat( LSTREAM_HEADER, k8420_C, ulValue );
			break;
		case CONTROL_LS2_DI3_SRC_MODE:	// MUX
			m_pLStream->AESSetSRCMode( LSTREAM_HEADER, k8420_C, ulValue );
			break;
		case CONTROL_LS2_DO3_STATUS:	// ULONG
			m_pLStream->AESSetOutputStatus( LSTREAM_HEADER, k8420_C, ulValue );
			break;
		case CONTROL_LS2_D4_FORMAT:	// MUX
			m_pLStream->AESSetFormat( LSTREAM_HEADER, k8420_D, ulValue );
			break;
		case CONTROL_LS2_DI4_SRC_MODE:	// MUX
			m_pLStream->AESSetSRCMode( LSTREAM_HEADER, k8420_D, ulValue );
			break;
		case CONTROL_LS2_DO4_STATUS:	// ULONG
			m_pLStream->AESSetOutputStatus( LSTREAM_HEADER, k8420_D, ulValue );
			break;

		default:
			return( HSTATUS_INVALID_MIXER_CONTROL );
		}
		break;
		
	// Destinations
	case LINE_OUT_1:
		switch( usSrcLine )
		{
		case LINE_NO_SOURCE:	// controls on the destination, PMIX controls are handled above
			return( HSTATUS_INVALID_MIXER_CONTROL );
		case LINE_PLAY_0:
		case LINE_PLAY_1:
		case LINE_PLAY_2:
		case LINE_PLAY_3:
		case LINE_PLAY_4:
		case LINE_PLAY_5:
		case LINE_PLAY_6:
		case LINE_PLAY_7:
			switch( usControl )
			{
			case CONTROL_VOLUME:
				// a number between 0..15
				if( !GetFirstMatchingLine( MIXVAL_PMIXSRC_PLAY0L + (((usSrcLine - LINE_PLAY_0) * 2) + usChannel), &usDst, &usSrc ) )
				{
					m_aPlayMix[ usDst ].SetVolume( usSrc, ulValue );
					ControlChanged( usDst, usSrc, CONTROL_VOLUME );
				}
				break;
/*
			case CONTROL_MONITOR_LEFT:
				m_aMonitorMix[ WAVE_PLAY0_DEVICE + (usSrcLine - LINE_PLAY_0) ].SetDestination( LEFT, ulValue );
				break;
			case CONTROL_MONITOR_RIGHT:
				m_aMonitorMix[ WAVE_PLAY0_DEVICE + (usSrcLine - LINE_PLAY_0) ].SetDestination( RIGHT, ulValue );
				break;
			case CONTROL_MONITOR_PAN:
				break;
			case CONTROL_MONITOR_VOLUME:
				m_aMonitorMix[ WAVE_PLAY0_DEVICE + (usSrcLine - LINE_PLAY_0) ].SetVolume( usChannel, ulValue );
				break;
			case CONTROL_MONITOR_MUTE:
				m_aMonitorMix[ WAVE_PLAY0_DEVICE + (usSrcLine - LINE_PLAY_0) ].SetMute( usChannel, (BOOLEAN)ulValue );
				break;
			case CONTROL_PHASE:
				m_aMonitorMix[ WAVE_PLAY0_DEVICE + (usSrcLine - LINE_PLAY_0) ].SetPhase( usChannel, (BOOLEAN)ulValue );
				break;
*/
			default:
				return( HSTATUS_INVALID_MIXER_CONTROL );
			}
			break;
		default:
			return( HSTATUS_INVALID_MIXER_LINE );
		}
		break;

	case LINE_RECORD_0:
	case LINE_RECORD_1:
	case LINE_RECORD_2:
	case LINE_RECORD_3:
	case LINE_RECORD_4:
	case LINE_RECORD_5:
	case LINE_RECORD_6:
	case LINE_RECORD_7:
		usCh = ((usDstLine - LINE_RECORD_0) * 2) + usChannel;

		//pD = m_pHalAdapter->GetWaveDevice( WAVE_RECORD0_DEVICE + (usChannel / 2) );
		//if( !pD )
		//	return( HSTATUS_INVALID_MIXER_LINE );

		switch( usSrcLine )
		{
		case LINE_NO_SOURCE:			// controls on the destination
			switch( usControl )
			{
			case CONTROL_SOURCE_LEFT:
				// restrict LynxTWO-B's source selection 
				if( m_usDeviceID == PCIDEVICE_LYNXTWO_B )
					if( ulValue >= 2 && ulValue <= 5 )
						return( HSTATUS_INVALID_MIXER_VALUE );
				m_aRecordMix[ usCh + LEFT ].SetSource( (USHORT)ulValue );
				break;
			case CONTROL_SOURCE_RIGHT:
				// restrict LynxTWO-B's source selection 
				if( m_usDeviceID == PCIDEVICE_LYNXTWO_B )
					if( ulValue >= 2 && ulValue <= 5 )
						return( HSTATUS_INVALID_MIXER_VALUE );
				m_aRecordMix[ usCh + RIGHT ].SetSource( (USHORT)ulValue );
				break;
			case CONTROL_MUTE:
				m_aRecordMix[ usCh ].SetMute( (BOOLEAN)ulValue );
				break;
			case CONTROL_DITHER:
				m_aRecordMix[ usCh ].SetDither( (BOOLEAN)ulValue );
				break;
			case CONTROL_DITHER_DEPTH:
				m_aRecordMix[ usCh ].SetDitherDepth( (USHORT)ulValue );
				break;

/*			// monitor
			case CONTROL_MONITOR_LEFT:
				m_aMonitorMix[ WAVE_RECORD0_DEVICE + (usDstLine - LINE_RECORD_0) ].SetDestination( LEFT, ulValue );
				break;
			case CONTROL_MONITOR_RIGHT:
				m_aMonitorMix[ WAVE_RECORD0_DEVICE + (usDstLine - LINE_RECORD_0) ].SetDestination( RIGHT, ulValue );
				break;
			case CONTROL_MONITOR_PAN:
				break;
			case CONTROL_MONITOR_VOLUME:
				m_aMonitorMix[ WAVE_RECORD0_DEVICE + (usDstLine - LINE_RECORD_0) ].SetVolume( usChannel, ulValue );
				break;
			case CONTROL_MONITOR_MUTE:
				m_aMonitorMix[ WAVE_RECORD0_DEVICE + (usDstLine - LINE_RECORD_0) ].SetMute( usChannel, (BOOLEAN)ulValue );
				break;
			case CONTROL_PHASE:
				m_aMonitorMix[ WAVE_RECORD0_DEVICE + (usDstLine - LINE_RECORD_0) ].SetPhase( usChannel, (BOOLEAN)ulValue );
				break;
*/
			default:
				return( HSTATUS_INVALID_MIXER_CONTROL );
			}
			break;
		}
		break;

	default:
		return( HSTATUS_INVALID_MIXER_LINE );
	} // switch( usDstLine )

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalMixer::GetControl( USHORT usDstLine, USHORT usSrcLine, USHORT usControl, USHORT usChannel, PULONG pulValue, ULONG ulSize )
/////////////////////////////////////////////////////////////////////////////
{
	long	lRate, lSource, lReference;
	USHORT	usDst, usSrc;
	USHORT	usCh;
	//DPF(("CHalMixer::GetControl Dst %d Src %d Ctl %d V[%08lx]\n", usDstLine, usSrcLine, usControl, (ULONG)pulValue ));

	if( !pulValue )
		return( HSTATUS_INVALID_PARAMETER );

	// start out with no value
	*pulValue = 0;

	if( !m_bOpen )
		return( HSTATUS_ADAPTER_NOT_OPEN );

	// handle the play mix controls first
	switch( usSrcLine )
	{
	case LINE_NO_SOURCE:
		// the outputs are the first 16 lines
		if( usDstLine < NUM_WAVE_PHYSICAL_OUTPUTS )
		{
			switch( usControl )
			{
			case CONTROL_NUMCHANNELS:	// the number of channels this line has
				*pulValue = 1;
				return( HSTATUS_OK );	// we return here instead of allowing more code to run
			case CONTROL_VOLUME:
				*pulValue = m_aPlayMix[ usDstLine ].GetVolume();
				return( HSTATUS_OK );
			case CONTROL_MUTE:
				*pulValue = m_aPlayMix[ usDstLine ].GetMute();
				return( HSTATUS_OK );
			case CONTROL_PEAKMETER:
				// level returned is 0..7FFFF (19 bits), shift to 15 bits
				*pulValue = (m_aPlayMix[ usDstLine ].GetLevel() >> 4);
				m_aPlayMix[ usDstLine ].ResetLevel();	// after we have read the level, reset it
				return( HSTATUS_OK );
			case CONTROL_OVERLOAD:
				*pulValue = m_aPlayMix[ usDstLine ].GetOverload();
				return( HSTATUS_OK );
			case CONTROL_PHASE:
				*pulValue = m_aPlayMix[ usDstLine ].GetPhase();
				return( HSTATUS_OK );
			case CONTROL_DITHER:
				*pulValue = m_aPlayMix[ usDstLine ].GetDither();
				return( HSTATUS_OK );
			default:
				// don't think we should error out here because there might
				// be other controls on this line (such as TRIM)
				//return( HSTATUS_INVALID_MIXER_CONTROL );
				break;
			}
		}
		break;
	case LINE_PLAY_MIXA:
	case LINE_PLAY_MIXB:
	case LINE_PLAY_MIXC:
	case LINE_PLAY_MIXD:
		if( usDstLine < NUM_WAVE_PHYSICAL_OUTPUTS )
		{
			switch( usControl )
			{
			case CONTROL_NUMCHANNELS:	// the number of channels this line has
				*pulValue = 1;
				return( HSTATUS_OK );	// we return here instead of allowing more code to run
			case CONTROL_VOLUME:
				*pulValue = m_aPlayMix[ usDstLine ].GetVolume( usSrcLine );
				return( HSTATUS_OK );
			case CONTROL_MUTE:
				*pulValue = m_aPlayMix[ usDstLine ].GetMute( usSrcLine );
				return( HSTATUS_OK );
			case CONTROL_PHASE:
				*pulValue = m_aPlayMix[ usDstLine ].GetPhase( usSrcLine );
				return( HSTATUS_OK );
			case CONTROL_SOURCE:
				*pulValue = m_aPlayMix[ usDstLine ].GetSource( usSrcLine );
				return( HSTATUS_OK );
			default:
				return( HSTATUS_INVALID_MIXER_CONTROL );
			}
		}
		break;
	}

	switch( usDstLine )
	{
	case LINE_ADAPTER:
		// only allow NO_SOURCE thru...
		if( usSrcLine != LINE_NO_SOURCE )
			return( HSTATUS_INVALID_MIXER_LINE );

		switch( usControl )
		{
		case CONTROL_NUMCHANNELS:	// the number of channels this line has
			*pulValue = 1;
			break;
		case CONTROL_CLOCKSOURCE:
			m_pSampleClock->Get( &lRate, &lSource, &lReference );
			// if there is a AK4114, then this must be an AES16
			if( m_pAK4114 )	lSource -= MIXVAL_AES16_CLKSRC_INTERNAL;
			*pulValue = lSource;
			break;
		case CONTROL_CLOCKREFERENCE:
			m_pSampleClock->Get( &lRate, &lSource, &lReference );
			*pulValue = lReference;
			break;
		case CONTROL_CLOCKRATE:
			m_pSampleClock->Get( (PLONG)pulValue );
			break;
		
		// Digital I/O
		case CONTROL_DIGITAL_FORMAT:
			if( !m_pCS8420 )	return( HSTATUS_INVALID_MIXER_CONTROL );
			*pulValue = m_pCS8420->GetFormat();
			break;
		case CONTROL_SRC_MODE:
			if( !m_pCS8420 )	return( HSTATUS_INVALID_MIXER_CONTROL );
			*pulValue = m_pCS8420->GetMode();
			break;
		case CONTROL_SRC_RATIO:
			if( !m_pCS8420 )	return( HSTATUS_INVALID_MIXER_CONTROL );
			*pulValue = (ULONG)m_pCS8420->GetSRCRatio();
			break;
		case CONTROL_DIGITALIN_RATE:
			if( !m_pCS8420 )	return( HSTATUS_INVALID_MIXER_CONTROL );
			m_pCS8420->GetInputSampleRate( (PLONG)pulValue );
			break;
		case CONTROL_DIGITALIN_MUTE_ON_ERROR:
			if( !m_pCS8420 )	return( HSTATUS_INVALID_MIXER_CONTROL );
			*pulValue = m_pCS8420->GetInputMuteOnError();
			break;
		case CONTROL_DIGITALIN_STATUS:
			if( !m_pCS8420 )	return( HSTATUS_INVALID_MIXER_CONTROL );
			*pulValue = m_pCS8420->GetInputStatus();
			break;
		case CONTROL_DIGITALOUT_STATUS:
			if( !m_pCS8420 )	return( HSTATUS_INVALID_MIXER_CONTROL );
			*pulValue = m_pCS8420->GetOutputStatus();
			break;

		// AES16 Digital I/O
		case CONTROL_WIDEWIREIN:	// BOOLEAN
		case CONTROL_WIDEWIREOUT:	// BOOLEAN
		case CONTROL_SYNCHROLOCK_ENABLE:	// BOOLEAN
		case CONTROL_SYNCHROLOCK_STATUS:	// ULONG
		case CONTROL_DIGITALIN1_STATUS:	// ULONG
		case CONTROL_DIGITALIN1_RATE:	// ULONG
		case CONTROL_DIGITALIN2_STATUS:	// ULONG
		case CONTROL_DIGITALIN2_RATE:	// ULONG
		case CONTROL_DIGITALIN3_STATUS:	// ULONG
		case CONTROL_DIGITALIN3_RATE:	// ULONG
		case CONTROL_DIGITALIN4_STATUS:	// ULONG
		case CONTROL_DIGITALIN4_RATE:	// ULONG
		case CONTROL_DIGITALIN5_STATUS:	// ULONG
		case CONTROL_DIGITALIN5_RATE:	// ULONG
		case CONTROL_DIGITALIN5_SRC_ENABLE:	// BOOLEAN
		case CONTROL_DIGITALIN5_SRC_RATIO:	// ULONG
		case CONTROL_DIGITALIN6_STATUS:	// ULONG
		case CONTROL_DIGITALIN6_RATE:	// ULONG
		case CONTROL_DIGITALIN6_SRC_ENABLE:	// BOOLEAN
		case CONTROL_DIGITALIN6_SRC_RATIO:	// ULONG
		case CONTROL_DIGITALIN7_STATUS:	// ULONG
		case CONTROL_DIGITALIN7_RATE:	// ULONG
		case CONTROL_DIGITALIN7_SRC_ENABLE:	// BOOLEAN
		case CONTROL_DIGITALIN7_SRC_RATIO:	// ULONG
		case CONTROL_DIGITALIN8_STATUS:	// ULONG
		case CONTROL_DIGITALIN8_RATE:	// ULONG
		case CONTROL_DIGITALIN8_SRC_ENABLE:	// BOOLEAN
		case CONTROL_DIGITALIN8_SRC_RATIO:	// ULONG
		case CONTROL_DIGITALIN_SRC_MATCHPHASE:	// BOOLEAN
		case CONTROL_DIGITALOUT1_STATUS:	// ULONG
		case CONTROL_DIGITALOUT2_STATUS:	// ULONG
		case CONTROL_DIGITALOUT3_STATUS:	// ULONG
		case CONTROL_DIGITALOUT4_STATUS:	// ULONG
		case CONTROL_DIGITALOUT5_STATUS:	// ULONG
		case CONTROL_DIGITALOUT6_STATUS:	// ULONG
		case CONTROL_DIGITALOUT7_STATUS:	// ULONG
		case CONTROL_DIGITALOUT8_STATUS:	// ULONG
			if( !m_pAK4114 )	return( HSTATUS_INVALID_MIXER_CONTROL );
			return( m_pAK4114->GetMixerControl( usControl, pulValue ) );

		// Trim
		case CONTROL_AIN12_TRIM:
		case CONTROL_AIN34_TRIM:
		case CONTROL_AIN56_TRIM:
		case CONTROL_AOUT12_TRIM:
		case CONTROL_AOUT34_TRIM:
		case CONTROL_AOUT56_TRIM:
			return( m_pHalAdapter->GetTrim( usControl, pulValue ) );

		// Frequency Counters
		case CONTROL_FREQUENCY_COUNTER_1:
		case CONTROL_FREQUENCY_COUNTER_2:
		case CONTROL_FREQUENCY_COUNTER_3:
		case CONTROL_FREQUENCY_COUNTER_4:
		case CONTROL_FREQUENCY_COUNTER_5:
		case CONTROL_FREQUENCY_COUNTER_6:
		case CONTROL_FREQUENCY_COUNTER_7:
		case CONTROL_FREQUENCY_COUNTER_8:
		case CONTROL_FREQUENCY_COUNTER_9:
		case CONTROL_FREQUENCY_COUNTER_10:
		case CONTROL_FREQUENCY_COUNTER_11:
		case CONTROL_FREQUENCY_COUNTER_12:
		case CONTROL_FREQUENCY_COUNTER_13:
			return( m_pHalAdapter->GetFrequencyCounter( usControl - CONTROL_FREQUENCY_COUNTER_1, pulValue ) );

		case CONTROL_SYNCIN_NTSC:
			// only cards with an LTC Receiver have this control
			if( !m_pTCRx )	return( HSTATUS_INVALID_MIXER_CONTROL );
			*pulValue = m_pHalAdapter->GetNTSCPAL();
			break;

		// LTC In
		case CONTROL_LTCIN_FRAMERATE:	// ulong
		case CONTROL_LTCIN_LOCKED:		// boolean
		case CONTROL_LTCIN_DIRECTION:	// boolean
		case CONTROL_LTCIN_DROPFRAME:	// boolean
		case CONTROL_LTCIN_POSITION:	// ulong
			if( !m_pTCRx )	return( HSTATUS_INVALID_MIXER_CONTROL );
			return( m_pTCRx->GetMixerControl( usControl, pulValue ) );
		
		// LTC Out
		case CONTROL_LTCOUT_ENABLE:		// boolean
		case CONTROL_LTCOUT_FRAMERATE:	// mux
		case CONTROL_LTCOUT_DROPFRAME:	// boolean
		case CONTROL_LTCOUT_SYNCSOURCE:	// MUX
		case CONTROL_LTCOUT_POSITION:	// ulong
			if( !m_pTCTx )	return( HSTATUS_INVALID_MIXER_CONTROL );
			return( m_pTCTx->GetMixerControl( usControl, pulValue ) );

		// Misc Controls
		case CONTROL_MTC_SOURCE:
			return( m_pHalAdapter->GetMTCSource( pulValue ) );
		
		case CONTROL_ADDA_RECALIBRATE:	// BOOLEAN
			if( (m_usDeviceID == PCIDEVICE_LYNX_AES16) || (m_usDeviceID == PCIDEVICE_LYNX_AES16SRC) )
				return( HSTATUS_INVALID_MIXER_CONTROL );
			break;
		case CONTROL_AUTO_RECALIBRATE:	// BOOLEAN
			if( (m_usDeviceID == PCIDEVICE_LYNX_AES16) || (m_usDeviceID == PCIDEVICE_LYNX_AES16SRC) )
				return( HSTATUS_INVALID_MIXER_CONTROL );
			*pulValue = m_pHalAdapter->GetAutoRecalibrate();
			break;

		case CONTROL_DITHER_TYPE:		// MUX
			*pulValue = m_pHalAdapter->GetDitherType();
			break;

		case CONTROL_AIN12_HPF:		// BOOLEAN
			if( !((m_usDeviceID == PCIDEVICE_LYNXTWO_A) || (m_usDeviceID == PCIDEVICE_LYNXTWO_B) || 
				(m_usDeviceID == PCIDEVICE_LYNXTWO_C) || (m_usDeviceID == PCIDEVICE_LYNX_L22)) )
				return( HSTATUS_INVALID_MIXER_CONTROL );
			*pulValue = m_pHalAdapter->GetADHPF( usControl );
			break;
		case CONTROL_AIN34_HPF:		// BOOLEAN
			if( !((m_usDeviceID == PCIDEVICE_LYNXTWO_A) || (m_usDeviceID == PCIDEVICE_LYNXTWO_C)) )
				return( HSTATUS_INVALID_MIXER_CONTROL );
			*pulValue = m_pHalAdapter->GetADHPF( usControl );
			break;
		case CONTROL_AIN56_HPF:		// BOOLEAN
			// only LynxTWO-C gets this
			if( m_usDeviceID != PCIDEVICE_LYNXTWO_C )
				return( HSTATUS_INVALID_MIXER_CONTROL );
			*pulValue = m_pHalAdapter->GetADHPF( usControl );
			break;
		case CONTROL_DA_DEEMPHASIS:
			if( (m_usDeviceID == PCIDEVICE_LYNX_AES16) || (m_usDeviceID == PCIDEVICE_LYNX_AES16SRC) )
				return( HSTATUS_INVALID_MIXER_CONTROL );
			*pulValue = m_pHalAdapter->GetDADeEmphasis();
			break;
		case CONTROL_SYNCSTART:			// BOOLEAN
			*pulValue = m_pHalAdapter->GetSyncStartState();
			break;
		case CONTROL_LSTREAM_DUAL_INTERNAL:		// BOOLEAN
			// only a single LStream port on the AES16
			if( (m_usDeviceID == PCIDEVICE_LYNX_AES16) || (m_usDeviceID == PCIDEVICE_LYNX_AES16SRC) )
				return( HSTATUS_INVALID_MIXER_CONTROL );
			*pulValue = m_pLStream->GetLStreamDualInternal();
			break;
		
		case CONTROL_DEVICEID:			// ULONG
			*pulValue = m_usDeviceID;
			break;
		case CONTROL_PCBREV:			// ULONG
			*pulValue = m_pHalAdapter->GetPCBRev();
			break;
		case CONTROL_FIRMWAREREV:		// ULONG
			*pulValue = m_pHalAdapter->GetFirmwareRev();
			break;
		case CONTROL_FIRMWAREDATE:		// ULONG
			*pulValue = m_pHalAdapter->GetFirmwareDate();
			break;
		case CONTROL_SERIALNUMBER:		// ULONG
			*pulValue = m_pHalAdapter->GetSerialNumber();
			break;
		case CONTROL_FAST_SHARED_CONTROLS:
		case CONTROL_SLOW_SHARED_CONTROLS:
			if( ulSize == sizeof( DWORD ) )
				return( HSTATUS_OK );
			if( ulSize != sizeof( SHAREDCONTROLS ) )
			{
				DPF(("SHAREDCONTROLS structure incorrect size!\n"));
				return( HSTATUS_INVALID_PARAMETER );
			}
			GetSharedControls( usControl, (PSHAREDCONTROLS)pulValue );
			break;
		case CONTROL_MIXER_RESTORE_SCENE:
		case CONTROL_MIXER_SAVE_SCENE:
			*pulValue = 0;	// nothing to return here - scene numbers aren't persistant
			break;
		case CONTROL_MIXER_LOCK:		// BOOLEAN
			*pulValue = m_bMixerLock;
			break;
		default:
			return( HSTATUS_INVALID_MIXER_CONTROL );

		}
		break;

	/////////////////////////////////////////////////////////////////////////
	case LINE_LSTREAM:
	/////////////////////////////////////////////////////////////////////////
		// only allow NO_SOURCE thru...
		if( usSrcLine != LINE_NO_SOURCE )
			return( HSTATUS_INVALID_MIXER_LINE );

		switch( usControl )
		{
		case CONTROL_NUMCHANNELS:	// the number of channels this line has
			*pulValue = 1;
			break;
		case CONTROL_LS1_DEVICEID:	// ULONG
			*pulValue = m_pLStream->GetDeviceID( LSTREAM_BRACKET );
			break;
		case CONTROL_LS1_PCBREV:	// ULONG
			*pulValue = m_pLStream->GetPCBRev( LSTREAM_BRACKET );
			break;
		case CONTROL_LS1_FIRMWAREREV:	// ULONG
			*pulValue = m_pLStream->GetFirmwareRev( LSTREAM_BRACKET );
			break;
		case CONTROL_LS1_OUTSEL:	// MUX
			*pulValue = m_pLStream->GetOutputSelection( LSTREAM_BRACKET );
			break;
		
		// LS-ADAT Specific
		case CONTROL_LS1_ADAT_CLKSRC:	// MUX
			*pulValue = m_pLStream->ADATGetClockSource( LSTREAM_BRACKET );
			break;
		case CONTROL_LS1_ADAT_IN1_LOCK:	// BOOLEAN
			*pulValue = m_pLStream->ADATIsLocked( LSTREAM_BRACKET, ADAT_OPTICAL_IN_1 );
			break;
		case CONTROL_LS1_ADAT_IN2_LOCK:	// BOOLEAN
			*pulValue = m_pLStream->ADATIsLocked( LSTREAM_BRACKET, ADAT_OPTICAL_IN_2 );
			break;
		case CONTROL_LS1_ADAT_POSITION:	// ULONG
			m_pLStream->ADATGetSyncInTimeCode( LSTREAM_BRACKET, pulValue );
			break;
		case CONTROL_LS1_ADAT_CUEPOINT_ENABLE:
			*pulValue = (ULONG)m_pHalAdapter->GetSyncStartLStreamEnable();
			break;
		case CONTROL_LS1_ADAT_CUEPOINT:
			*pulValue = m_pLStream->ADATGetCuePoint( LSTREAM_BRACKET );
			break;
		
		// LS-AES Specific
		case CONTROL_LS1_AES_CLKSRC:	// MUX
			*pulValue = m_pLStream->AESGetClockSource( LSTREAM_BRACKET );
			break;
		case CONTROL_LS1_AES_WIDEWIRE:	// BOOLEAN
			*pulValue = m_pLStream->AESGetWideWire( LSTREAM_BRACKET );
			break;
		case CONTROL_LS1_D1_FORMAT:	// MUX
			*pulValue = m_pLStream->AESGetFormat( LSTREAM_BRACKET, k8420_A );
			break;
		case CONTROL_LS1_DI1_SRC_MODE:	// MUX
			*pulValue = m_pLStream->AESGetSRCMode( LSTREAM_BRACKET, k8420_A );
			break;
		case CONTROL_LS1_DI1_RATE:	// ULONG
			*pulValue = m_pLStream->AESGetInputSampleRate( LSTREAM_BRACKET, k8420_A );
			break;
		case CONTROL_LS1_DI1_SRC_RATIO:	// ULONG
			*pulValue = m_pLStream->AESGetSRCRatio( LSTREAM_BRACKET, k8420_A );
			break;
		case CONTROL_LS1_DI1_STATUS:	// ULONG
			*pulValue = m_pLStream->AESGetInputStatus( LSTREAM_BRACKET, k8420_A );
			break;
		case CONTROL_LS1_DO1_STATUS:	// ULONG
			*pulValue = m_pLStream->AESGetOutputStatus( LSTREAM_BRACKET, k8420_A );
			break;
		case CONTROL_LS1_D2_FORMAT:	// MUX
			*pulValue = m_pLStream->AESGetFormat( LSTREAM_BRACKET, k8420_B );
			break;
		case CONTROL_LS1_DI2_SRC_MODE:	// MUX
			*pulValue = m_pLStream->AESGetSRCMode( LSTREAM_BRACKET, k8420_B );
			break;
		case CONTROL_LS1_DI2_RATE:	// ULONG
			*pulValue = m_pLStream->AESGetInputSampleRate( LSTREAM_BRACKET, k8420_B );
			break;
		case CONTROL_LS1_DI2_SRC_RATIO:	// ULONG
			*pulValue = m_pLStream->AESGetSRCRatio( LSTREAM_BRACKET, k8420_B );
			break;
		case CONTROL_LS1_DI2_STATUS:	// ULONG
			*pulValue = m_pLStream->AESGetInputStatus( LSTREAM_BRACKET, k8420_B );
			break;
		case CONTROL_LS1_DO2_STATUS:	// ULONG
			*pulValue = m_pLStream->AESGetOutputStatus( LSTREAM_BRACKET, k8420_B );
			break;
		case CONTROL_LS1_D3_FORMAT:	// MUX
			*pulValue = m_pLStream->AESGetFormat( LSTREAM_BRACKET, k8420_C );
			break;
		case CONTROL_LS1_DI3_SRC_MODE:	// MUX
			*pulValue = m_pLStream->AESGetSRCMode( LSTREAM_BRACKET, k8420_C );
			break;
		case CONTROL_LS1_DI3_RATE:	// ULONG
			*pulValue = m_pLStream->AESGetInputSampleRate( LSTREAM_BRACKET, k8420_C );
			break;
		case CONTROL_LS1_DI3_SRC_RATIO:	// ULONG
			*pulValue = m_pLStream->AESGetSRCRatio( LSTREAM_BRACKET, k8420_C );
			break;
		case CONTROL_LS1_DI3_STATUS:	// ULONG
			*pulValue = m_pLStream->AESGetInputStatus( LSTREAM_BRACKET, k8420_C );
			break;
		case CONTROL_LS1_DO3_STATUS:	// ULONG
			*pulValue = m_pLStream->AESGetOutputStatus( LSTREAM_BRACKET, k8420_C );
			break;
		case CONTROL_LS1_D4_FORMAT:	// MUX
			*pulValue = m_pLStream->AESGetFormat( LSTREAM_BRACKET, k8420_D );
			break;
		case CONTROL_LS1_DI4_SRC_MODE:	// MUX
			*pulValue = m_pLStream->AESGetSRCMode( LSTREAM_BRACKET, k8420_D );
			break;
		case CONTROL_LS1_DI4_RATE:	// ULONG
			*pulValue = m_pLStream->AESGetInputSampleRate( LSTREAM_BRACKET, k8420_D );
			break;
		case CONTROL_LS1_DI4_SRC_RATIO:	// ULONG
			*pulValue = m_pLStream->AESGetSRCRatio( LSTREAM_BRACKET, k8420_D );
			break;
		case CONTROL_LS1_DI4_STATUS:	// ULONG
			*pulValue = m_pLStream->AESGetInputStatus( LSTREAM_BRACKET, k8420_D );
			break;
		case CONTROL_LS1_DO4_STATUS:	// ULONG
			*pulValue = m_pLStream->AESGetOutputStatus( LSTREAM_BRACKET, k8420_D );
			break;
		
		/////////////////////////////////////////////////////////////////////
		// LStream 2
		/////////////////////////////////////////////////////////////////////
		case CONTROL_LS2_DEVICEID:	// ULONG
			*pulValue = m_pLStream->GetDeviceID( LSTREAM_HEADER );
			break;
		case CONTROL_LS2_PCBREV:	// ULONG
			*pulValue = m_pLStream->GetPCBRev( LSTREAM_HEADER );
			break;
		case CONTROL_LS2_FIRMWAREREV:	// ULONG
			*pulValue = m_pLStream->GetFirmwareRev( LSTREAM_HEADER );
			break;
		case CONTROL_LS2_OUTSEL:	// MUX
			*pulValue = m_pLStream->GetOutputSelection( LSTREAM_HEADER );
			break;
		
		// LS-ADAT Specific
		case CONTROL_LS2_ADAT_CLKSRC:	// MUX
			*pulValue = m_pLStream->ADATGetClockSource( LSTREAM_HEADER );
			break;
		case CONTROL_LS2_ADAT_IN1_LOCK:	// BOOLEAN
			*pulValue = m_pLStream->ADATIsLocked( LSTREAM_HEADER, ADAT_OPTICAL_IN_1 );
			break;
		case CONTROL_LS2_ADAT_IN2_LOCK:	// BOOLEAN
			*pulValue = m_pLStream->ADATIsLocked( LSTREAM_HEADER, ADAT_OPTICAL_IN_2 );
			break;
		case CONTROL_LS2_ADAT_POSITION:	// ULONG
			m_pLStream->ADATGetSyncInTimeCode( LSTREAM_HEADER, pulValue );
			break;
		case CONTROL_LS2_ADAT_CUEPOINT_ENABLE:
			*pulValue = (ULONG)m_pHalAdapter->GetSyncStartLStreamEnable();
			break;
		case CONTROL_LS2_ADAT_CUEPOINT:
			*pulValue = m_pLStream->ADATGetCuePoint( LSTREAM_HEADER );
			break;
		
		// LS-AES Specific
		case CONTROL_LS2_AES_CLKSRC:	// MUX
			*pulValue = m_pLStream->AESGetClockSource( LSTREAM_HEADER );
			break;
		case CONTROL_LS2_AES_WIDEWIRE:	// BOOLEAN
			*pulValue = m_pLStream->AESGetWideWire( LSTREAM_HEADER );
			break;
		case CONTROL_LS2_D1_FORMAT:	// MUX
			*pulValue = m_pLStream->AESGetFormat( LSTREAM_HEADER, k8420_A );
			break;
		case CONTROL_LS2_DI1_SRC_MODE:	// MUX
			*pulValue = m_pLStream->AESGetSRCMode( LSTREAM_HEADER, k8420_A );
			break;
		case CONTROL_LS2_DI1_RATE:	// ULONG
			*pulValue = m_pLStream->AESGetInputSampleRate( LSTREAM_HEADER, k8420_A );
			break;
		case CONTROL_LS2_DI1_SRC_RATIO:	// ULONG
			*pulValue = m_pLStream->AESGetSRCRatio( LSTREAM_HEADER, k8420_A );
			break;
		case CONTROL_LS2_DI1_STATUS:	// ULONG
			*pulValue = m_pLStream->AESGetInputStatus( LSTREAM_HEADER, k8420_A );
			break;
		case CONTROL_LS2_DO1_STATUS:	// ULONG
			*pulValue = m_pLStream->AESGetOutputStatus( LSTREAM_HEADER, k8420_A );
			break;
		case CONTROL_LS2_D2_FORMAT:	// MUX
			*pulValue = m_pLStream->AESGetFormat( LSTREAM_HEADER, k8420_B );
			break;
		case CONTROL_LS2_DI2_SRC_MODE:	// MUX
			*pulValue = m_pLStream->AESGetSRCMode( LSTREAM_HEADER, k8420_B );
			break;
		case CONTROL_LS2_DI2_RATE:	// ULONG
			*pulValue = m_pLStream->AESGetInputSampleRate( LSTREAM_HEADER, k8420_B );
			break;
		case CONTROL_LS2_DI2_SRC_RATIO:	// ULONG
			*pulValue = m_pLStream->AESGetSRCRatio( LSTREAM_HEADER, k8420_B );
			break;
		case CONTROL_LS2_DI2_STATUS:	// ULONG
			*pulValue = m_pLStream->AESGetInputStatus( LSTREAM_HEADER, k8420_B );
			break;
		case CONTROL_LS2_DO2_STATUS:	// ULONG
			*pulValue = m_pLStream->AESGetOutputStatus( LSTREAM_HEADER, k8420_B );
			break;
		case CONTROL_LS2_D3_FORMAT:	// MUX
			*pulValue = m_pLStream->AESGetFormat( LSTREAM_HEADER, k8420_C );
			break;
		case CONTROL_LS2_DI3_SRC_MODE:	// MUX
			*pulValue = m_pLStream->AESGetSRCMode( LSTREAM_HEADER, k8420_C );
			break;
		case CONTROL_LS2_DI3_RATE:	// ULONG
			*pulValue = m_pLStream->AESGetInputSampleRate( LSTREAM_HEADER, k8420_C );
			break;
		case CONTROL_LS2_DI3_SRC_RATIO:	// ULONG
			*pulValue = m_pLStream->AESGetSRCRatio( LSTREAM_HEADER, k8420_C );
			break;
		case CONTROL_LS2_DI3_STATUS:	// ULONG
			*pulValue = m_pLStream->AESGetInputStatus( LSTREAM_HEADER, k8420_C );
			break;
		case CONTROL_LS2_DO3_STATUS:	// ULONG
			*pulValue = m_pLStream->AESGetOutputStatus( LSTREAM_HEADER, k8420_C );
			break;
		case CONTROL_LS2_D4_FORMAT:	// MUX
			*pulValue = m_pLStream->AESGetFormat( LSTREAM_HEADER, k8420_D );
			break;
		case CONTROL_LS2_DI4_SRC_MODE:	// MUX
			*pulValue = m_pLStream->AESGetSRCMode( LSTREAM_HEADER, k8420_D );
			break;
		case CONTROL_LS2_DI4_RATE:	// ULONG
			*pulValue = m_pLStream->AESGetInputSampleRate( LSTREAM_HEADER, k8420_D );
			break;
		case CONTROL_LS2_DI4_SRC_RATIO:	// ULONG
			*pulValue = m_pLStream->AESGetSRCRatio( LSTREAM_HEADER, k8420_D );
			break;
		case CONTROL_LS2_DI4_STATUS:	// ULONG
			*pulValue = m_pLStream->AESGetInputStatus( LSTREAM_HEADER, k8420_D );
			break;
		case CONTROL_LS2_DO4_STATUS:	// ULONG
			*pulValue = m_pLStream->AESGetOutputStatus( LSTREAM_HEADER, k8420_D );
			break;
		default:
			return( HSTATUS_INVALID_MIXER_CONTROL );
		}
		break;

	// Destinations
	case LINE_OUT_1:
	case LINE_OUT_2:
		switch( usSrcLine )
		{
		case LINE_NO_SOURCE:	// controls on the destination, PMIX controls are handled above
			return( HSTATUS_INVALID_MIXER_CONTROL );
		case LINE_PLAY_0:
		case LINE_PLAY_1:
		case LINE_PLAY_2:
		case LINE_PLAY_3:
		case LINE_PLAY_4:
		case LINE_PLAY_5:
		case LINE_PLAY_6:
		case LINE_PLAY_7:
			// only allow LINE_OUT_1 to have these source lines
			if( usDstLine != LINE_OUT_1 )
				return( HSTATUS_INVALID_MIXER_LINE );

			switch( usControl )
			{
			case CONTROL_NUMCHANNELS:	// the number of channels this line has
				*pulValue = 2;
				break;
			case CONTROL_PEAKMETER:
				// a number between 0..15
				if( !GetFirstMatchingLine( MIXVAL_PMIXSRC_PLAY0L + (((usSrcLine - LINE_PLAY_0) * 2) + usChannel), &usDst, &usSrc ) )
				{
					// level returned is 0..7FFFF (19 bits), shift to 15 bits
					*pulValue = (m_aPlayMix[ usDst ].GetLevel() >> 4);
					m_aPlayMix[ usDst ].ResetLevel();
				}
				break;
			
			case CONTROL_VOLUME:
				// a number between 0..15
				if( !GetFirstMatchingLine( MIXVAL_PMIXSRC_PLAY0L + (((usSrcLine - LINE_PLAY_0) * 2) + usChannel), &usDst, &usSrc ) )
				{
					*pulValue = m_aPlayMix[ usDst ].GetVolume( usSrc );
				}
				break;

			case CONTROL_SAMPLE_FORMAT:
				*pulValue = m_pHalAdapter->GetWaveOutDevice( usSrcLine - LINE_PLAY_0 )->GetSampleFormat();
				break;
			case CONTROL_SAMPLE_COUNT:
				*pulValue = m_pHalAdapter->GetWaveOutDevice( usSrcLine - LINE_PLAY_0 )->GetSamplesTransferred();
				break;
			case CONTROL_OVERRUN_COUNT:
				*pulValue = m_pHalAdapter->GetWaveOutDevice( usSrcLine - LINE_PLAY_0 )->GetOverrunCount();
				break;
			default:
				return( HSTATUS_INVALID_MIXER_CONTROL );
			}
			break;
		default:
			return( HSTATUS_INVALID_MIXER_LINE );
		}
		break;

	case LINE_OUT_3:
	case LINE_OUT_4:
	case LINE_OUT_5:
	case LINE_OUT_6:
	case LINE_OUT_7:
	case LINE_OUT_8:
	case LINE_OUT_9:
	case LINE_OUT_10:
	case LINE_OUT_11:
	case LINE_OUT_12:
	case LINE_OUT_13:
	case LINE_OUT_14:
	case LINE_OUT_15:
	case LINE_OUT_16:
		if( usSrcLine == LINE_NO_SOURCE )	// controls on the destination, PMIX controls are handled above
		{
			return( HSTATUS_INVALID_MIXER_CONTROL );
		}
		else
			return( HSTATUS_INVALID_MIXER_LINE );
		break;

	case LINE_RECORD_0:
	case LINE_RECORD_1:
	case LINE_RECORD_2:
	case LINE_RECORD_3:
	case LINE_RECORD_4:
	case LINE_RECORD_5:
	case LINE_RECORD_6:
	case LINE_RECORD_7:
		// a number between 0..15
		usCh = ((usDstLine - LINE_RECORD_0) * 2) + usChannel;

		switch( usSrcLine )
		{
		case LINE_NO_SOURCE:			// controls on the destination
			switch( usControl )
			{
			case CONTROL_NUMCHANNELS:	// the number of channels this line has
				*pulValue = 2;
				break;
			case CONTROL_PEAKMETER:
				// level returned is 0..7FFFF (19 bits), shift to 15 bits
				*pulValue = (m_aRecordMix[ usCh ].GetLevel() >> 4);
				m_aRecordMix[ usCh ].ResetLevel();	// after we have read the level, reset it
				break;
			case CONTROL_SOURCE_LEFT:
				*pulValue = m_aRecordMix[ usCh + LEFT ].GetSource();
				break;
			case CONTROL_SOURCE_RIGHT:
				*pulValue = m_aRecordMix[ usCh + RIGHT ].GetSource();
				break;
			case CONTROL_MUTE:
				*pulValue = m_aRecordMix[ usCh ].GetMute();
				break;
			case CONTROL_DITHER:
				*pulValue = m_aRecordMix[ usCh ].GetDither();
				break;
			case CONTROL_DITHER_DEPTH:
				*pulValue = m_aRecordMix[ usCh ].GetDitherDepth();
				break;
			case CONTROL_SAMPLE_FORMAT:
				*pulValue = m_pHalAdapter->GetWaveInDevice( usDstLine - LINE_RECORD_0 )->GetSampleFormat();
				break;
			case CONTROL_SAMPLE_COUNT:
				*pulValue = m_pHalAdapter->GetWaveInDevice( usDstLine - LINE_RECORD_0 )->GetSamplesTransferred();
				break;
			case CONTROL_OVERRUN_COUNT:
				*pulValue = m_pHalAdapter->GetWaveInDevice( usDstLine - LINE_RECORD_0 )->GetOverrunCount();
				break;
			default:
				return( HSTATUS_INVALID_MIXER_CONTROL );
			}
			break;

		default:
			return( HSTATUS_INVALID_MIXER_LINE );
		}
		break;

	default:
		return( HSTATUS_INVALID_MIXER_LINE );
	} // switch( usDstLine )

	return( HSTATUS_OK );
}

