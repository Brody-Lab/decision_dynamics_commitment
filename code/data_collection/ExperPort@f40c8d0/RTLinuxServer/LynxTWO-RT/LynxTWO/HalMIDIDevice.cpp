/****************************************************************************
 HalMIDIDevice.cpp

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
 Aug 09 04 DAH	Changed to 29.97fps from 30fps for LTC start when in 30D
****************************************************************************/

#include <StdAfx.h>
#include "HalAdapter.h"

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalMIDIDevice::Open( PHALADAPTER pHalAdapter, ULONG ulDeviceNumber )
/////////////////////////////////////////////////////////////////////////////
{
	RtlZeroMemory( m_CurrentMessage, MIDI_RX_BUFFER_SIZE );
	m_ucQFM				= 0;
	m_ulHead			= 0;
	m_ulTail			= 0;
	m_MTCPosition.ulTimecode = 0xFFFFFFFF;
	m_ulMTCSource		= 0;	// read from CHalAdapter on Start
	m_pTCRx				= pHalAdapter->GetTCRx();
	m_pTCTx				= pHalAdapter->GetTCTx();
	m_pLStream			= pHalAdapter->GetLStream();

	m_bIsRecord = ulDeviceNumber == MIDI_RECORD0_DEVICE ? TRUE : FALSE;

	return( CHalDevice::Open( pHalAdapter, ulDeviceNumber ) );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalMIDIDevice::Close()
/////////////////////////////////////////////////////////////////////////////
{
	return( CHalDevice::Close() );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalMIDIDevice::Start()
/////////////////////////////////////////////////////////////////////////////
{
	//DPF(("CHalMIDIDevice::Start\n"));

	if( IsRecord() )
	{
		RtlZeroMemory( m_CurrentMessage, MIDI_RX_BUFFER_SIZE );
		m_ucQFM		= 0;
		m_ulHead	= 0;
		m_ulTail	= 0;
		
		m_pHalAdapter->GetMTCSource( &m_ulMTCSource );

		switch( m_ulMTCSource )
		{
		case MIXVAL_MTCSOURCE_LTCRX:
			if( m_pTCRx )	m_pTCRx->EnableMTC( TRUE );
			break;
		case MIXVAL_MTCSOURCE_LSTREAM1_ADAT_SYNCIN:
			m_ulADATPort = LSTREAM_BRACKET;
			m_pLStream->ADATEnableTimeCodeToMTC( m_ulADATPort, TRUE );
			break;
		case MIXVAL_MTCSOURCE_LSTREAM2_ADAT_SYNCIN:
			m_ulADATPort = LSTREAM_HEADER;
			m_pLStream->ADATEnableTimeCodeToMTC( m_ulADATPort, TRUE );
			break;
		}
	}
	else
	{
		m_MTCPosition.ulTimecode = 0xFFFFFFFF;
	}
	return( CHalDevice::Start() );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalMIDIDevice::Stop()
/////////////////////////////////////////////////////////////////////////////
{
	//DPF(("CHalMIDIDevice::Stop\n"));

	if( IsRecord() )
	{
		switch( m_ulMTCSource )
		{
		case MIXVAL_MTCSOURCE_LTCRX:
			if( m_pTCRx )	m_pTCRx->EnableMTC( FALSE );
			break;
		case MIXVAL_MTCSOURCE_LSTREAM1_ADAT_SYNCIN:
		case MIXVAL_MTCSOURCE_LSTREAM2_ADAT_SYNCIN:
			m_pLStream->ADATEnableTimeCodeToMTC( m_ulADATPort, FALSE );
			break;
		}
	}
	else
	{
		m_MTCPosition.ulTimecode = 0xFFFFFFFF;
	}
	return( CHalDevice::Stop() );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalMIDIDevice::Read( PBYTE pBuffer, ULONG ulSize, PULONG pulBytesRead )
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulBytesRead = 0;
	//DPF(("CHalMIDIDevice::Read Requesting %lu Bytes\n", ulSize ));
	
	// MTC messages are always 2 bytes long
	while( (m_ulHead != m_ulTail) && (ulBytesRead < ulSize) )
	{
		//DPF(("Head %02lx Tail %02lx %lu %lu\n", m_ulHead, m_ulTail, ulBytesRead, ulSize ));
		*pBuffer++ = m_CurrentMessage[ m_ulTail++ ];
		m_ulTail &= (MIDI_RX_BUFFER_SIZE-1);				// make sure tail doesn't wrap
		ulBytesRead++;
	}

	*pulBytesRead = ulBytesRead;

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalMIDIDevice::Write( PBYTE pBuffer, ULONG ulSize, PULONG pulBytesWritten )
/////////////////////////////////////////////////////////////////////////////
{
	BYTE		ucCurrentByte;
	BYTE		ucQFM;
	PHALMIXER	pMixer;

	for( ULONG i=0; i<ulSize; i++ )
	{
		ucCurrentByte = *pBuffer++;
		//DPF(("%02x ", ucCurrentByte ));

		if( (ucCurrentByte & 0xF0) == 0xB0 )	// Control Change
		{
			m_ulHead = 0;
			m_CurrentMessage[ m_ulHead++ ] = ucCurrentByte;
			m_ulBytesInMessage = 2;
			continue;
		}
		if( ucCurrentByte == 0xF1 )				// MTC Quarterframe Message
		{
			m_ulHead = 0;
			m_CurrentMessage[ m_ulHead++ ] = ucCurrentByte;
			m_ulBytesInMessage = 1;
			continue;
		}
		if( m_ulBytesInMessage )
		{
			m_CurrentMessage[ m_ulHead++ ] = ucCurrentByte;
			m_ulHead &= (MIDI_RX_BUFFER_SIZE-1);				// make sure head doesn't wrap
			m_ulBytesInMessage--;

			// if we still have bytes remaining, continue
			if( m_ulBytesInMessage )
				continue;

			// we have collected all the bytes for this message, process it

			//			Control Change						Main Volume
			if( ((m_CurrentMessage[0] & 0xF0) == 0xB0) && (m_CurrentMessage[1] == 7) )
			{
				USHORT	usDst = LINE_OUT_1 + (m_CurrentMessage[0] & 0xF);
				pMixer = m_pHalAdapter->GetMixer();
				// 65535 / 127 = 516, changed to 517 so 127*517 > 65535
				pMixer->SetControl( usDst, LINE_NO_SOURCE, CONTROL_VOLUME, 0, (ULONG)m_CurrentMessage[2] * 517 );
				// Notify Mixer Driver that a control has changed
				pMixer->ControlChanged( usDst, LINE_NO_SOURCE, CONTROL_VOLUME );
			}
			
			// MTC Quarterframe Message
			if( m_pTCTx && (m_CurrentMessage[0] == 0xF1) )
			{
				ucQFM = (m_CurrentMessage[1] >> 4);

				// make sure we haven't already seen this message
				if( m_ucQFM & (1<<ucQFM) )
					m_bDrop = TRUE;

				// flag that we have seen this message
				m_ucQFM |= (1<<ucQFM);

				switch( ucQFM )
				{
				case 0:	
					m_ulMTCMessages = (m_CurrentMessage[1] & 0xF);	// frame 0
					m_ucQFM = (1<<ucQFM);	// reset
					break;
				case 1:	m_ulMTCMessages |= ((m_CurrentMessage[1] & 0x1) << 4);	break;	// frame 10
				case 2:	m_ulMTCMessages |= ((m_CurrentMessage[1] & 0xF) << 8);	break;	// second 0
				case 3:	m_ulMTCMessages |= ((m_CurrentMessage[1] & 0xF) << 12);	break;	// second 10
				case 4:	m_ulMTCMessages |= ((m_CurrentMessage[1] & 0xF) << 16);	break;	// minute 0
				case 5:	m_ulMTCMessages |= ((m_CurrentMessage[1] & 0xF) << 20);	break;	// minute 10
				case 6:	m_ulMTCMessages |= ((m_CurrentMessage[1] & 0xF) << 24);	break;	// hour 0
				case 7:	m_ulMTCMessages |= ((m_CurrentMessage[1] & 0x1) << 28);			// hour 10 (fall through)

					// if we have not received all 8 quarter frame messages, we dropped something 
					if( m_ucQFM != 0xFF )	
						m_bDrop = TRUE;

					m_ucQFM = 0;

					// if we have dropped any messages, reset everything and start over
					if( m_bDrop )
					{
						m_bDrop = FALSE;
						continue;
					}
					
					m_usMTCFrameRate	= (m_CurrentMessage[1] >> 1) & 0x3;
					
					m_MTCPosition.Bytes.ucFrame		= TC_GET_FRM( m_ulMTCMessages );
					m_MTCPosition.Bytes.ucSecond	= TC_GET_SEC( m_ulMTCMessages );
					m_MTCPosition.Bytes.ucMinute	= TC_GET_MIN( m_ulMTCMessages );
					m_MTCPosition.Bytes.ucHour		= TC_GET_HRS( m_ulMTCMessages );

					//DPF(("m_ulMTCPosition %08lx\n", m_ulMTCPosition ));
					
					// Ok, we are ready to start the LTC Transmitter, if we can
					// if the timecode transmitter is already on, this was all for nothing!
					if( m_pTCTx->IsRunning() )
						continue;
					
					switch( m_usMTCFrameRate )
					{
					case MTC_FRAMERATE_24:
						m_pTCTx->SetFrameRate( MIXVAL_TCFRAMERATE_24FPS );
						break;
					case MTC_FRAMERATE_25:
						m_pTCTx->SetFrameRate( MIXVAL_TCFRAMERATE_25FPS );
						break;
					case MTC_FRAMERATE_30DROP:
						m_pTCTx->SetFrameRate( MIXVAL_TCFRAMERATE_2997FPS );	// DAH Changed to 29.97 from 30 on Aug 9, 2004
						m_pTCTx->SetDropFrame( TRUE );
						break;
					case MTC_FRAMERATE_30:
						m_pTCTx->SetFrameRate( MIXVAL_TCFRAMERATE_30FPS );
						m_pTCTx->SetDropFrame( FALSE );
						break;
					}
					
					// TODO: we should really increase this by 2 frames.

					m_pTCTx->SetPosition( m_MTCPosition.ulTimecode );	// set the current position 
					m_pTCTx->Start();							// start the timecode transmitter
					
					pMixer = m_pHalAdapter->GetMixer();
					
					pMixer->ControlChanged( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_LTCOUT_ENABLE );
					pMixer->ControlChanged( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_LTCOUT_FRAMERATE );
					pMixer->ControlChanged( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_LTCOUT_DROPFRAME );
					break;
				}
			}
		}
	}

	// act like we sent all the data out the port
	*pulBytesWritten = ulSize;
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalMIDIDevice::GetMTCPosition( PULONG pulTimecode )
// Only called from CHalTimecode::Service() at interrupt time
/////////////////////////////////////////////////////////////////////////////
{
	*pulTimecode = 0;

	if( IsRunning() )
		*pulTimecode = m_MTCPosition.ulTimecode;
	else
		return( HSTATUS_INVALID_MODE );
	
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalMIDIDevice::ResetMTCPosition( void )
// Only called from CHalTimecode::Service() at interrupt time when the 
// LTC Transmitter is too far off from the GetMTCPosition above.  The very 
// next complete MTC message written from the application will set this back 
// to valid timecode.
/////////////////////////////////////////////////////////////////////////////
{
	m_MTCPosition.ulTimecode = 0xFFFFFFFF;

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalMIDIDevice::AddByteToBuffer( BYTE ucByte )
// Called at interrupt time, not from the DPC so this cannot call any other functions!
/////////////////////////////////////////////////////////////////////////////
{
	m_CurrentMessage[ m_ulHead++ ] = ucByte;
	m_ulHead &= (MIDI_RX_BUFFER_SIZE-1);				// make sure head doesn't wrap
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalMIDIDevice::Service( ULONG ulReason )
// Called at DPC time when a new quarter frame message or other MIDI data 
// needs to be sent to the driver
/////////////////////////////////////////////////////////////////////////////
{
	BYTE	ucQFM;
	BYTE	ucMTCFrameRate;

	if( !IsRecord() )
		return( HSTATUS_INVALID_MODE );

	//DC('M');

	switch( ulReason )
	{
	case kMIDIReasonLTCQFM:
		//DX8(m_ucQFM,COLOR_NORMAL);
		ucQFM = (m_ucQFM << 4);

		// we should always be reading new frame data on a 0 or 4 MTC message...
		if( m_pTCRx )
		{
			// did we just read valid timecode?
			if( m_pTCRx->HasValidTimecode() )
			{
				if( !((m_ucQFM == 0) || (m_ucQFM == 4)) )
				{
					// reset the QFM back to zero - which forces a new GetPosition call below...
					m_ucQFM = 0;
					DC('Q');
					DPF(("QFM Out Of Sync!\n"));
				}
			}
		}

		switch( m_ucQFM )
		{
		case 0:
			if( m_pTCRx )
			{
				// did we just read valid timecode?
				if( !m_pTCRx->HasValidTimecode() )
				{
					DC('T');
					DPF(("No valid timecode!\n"));
					return( HSTATUS_OK );
				}
				// this position should have just been read from the hardware on *this* interrupt
				m_pTCRx->GetPosition( &m_MTCPosition.ulTimecode );
			}
			ucQFM |= (m_MTCPosition.Bytes.ucFrame & 0xF);
			break;
		case 1:	ucQFM |= ((m_MTCPosition.Bytes.ucFrame >> 4) & 0x1);	break;
		case 2:	ucQFM |= (m_MTCPosition.Bytes.ucSecond & 0xF);			break;
		case 3:	ucQFM |= ((m_MTCPosition.Bytes.ucSecond >> 4) & 0xF);	break;
		case 4:	ucQFM |= (m_MTCPosition.Bytes.ucMinute & 0xF);			break;
		case 5:	ucQFM |= ((m_MTCPosition.Bytes.ucMinute >> 4) & 0xF);	break;
		case 6:	ucQFM |= (m_MTCPosition.Bytes.ucHour & 0xF);			break;
		case 7:
			if( m_pTCRx )	m_pTCRx->GetMTCFrameRate( &ucMTCFrameRate );
			ucQFM |= ((m_MTCPosition.Bytes.ucHour >> 4) & 0x1) + (ucMTCFrameRate << 1);
			break;
		}
		
		// make sure the timecode gets reset so we can sync-up later...
		if( m_pTCRx )	m_pTCRx->ResetValidTimecode();

		AddByteToBuffer( 0xF1 );	// MTC Quarterframe Message
		AddByteToBuffer( ucQFM );

		m_ucQFM++;
		if( m_ucQFM > 7 )
			m_ucQFM = 0;
		break;
	case kMIDIReasonADATQFM:
		//DX8(m_ucQFM,COLOR_NORMAL);
		ucQFM = (m_ucQFM << 4);

		switch( m_ucQFM )
		{
		case 0:	
			// this position should have just been read from the hardware on *this* interrupt
			m_pLStream->ADATGetPosition( m_ulADATPort, &m_MTCPosition.ulTimecode );
			// Convert from samples to Timecode
			ucQFM |= (m_MTCPosition.Bytes.ucFrame & 0xF);
			break;
		case 1:	ucQFM |= ((m_MTCPosition.Bytes.ucFrame >> 4) & 0x1);	break;
		case 2:	ucQFM |= (m_MTCPosition.Bytes.ucSecond & 0xF);			break;
		case 3:	ucQFM |= ((m_MTCPosition.Bytes.ucSecond >> 4) & 0xF);	break;
		case 4:	ucQFM |= (m_MTCPosition.Bytes.ucMinute & 0xF);			break;
		case 5:	ucQFM |= ((m_MTCPosition.Bytes.ucMinute >> 4) & 0xF);	break;
		case 6:	ucQFM |= (m_MTCPosition.Bytes.ucHour & 0xF);			break;
		case 7:
			ucQFM |= ((m_MTCPosition.Bytes.ucHour >> 28) & 0x1) + (MTC_FRAMERATE_30 << 1);
			break;
		}

		AddByteToBuffer( 0xF1 );	// MTC Quarterframe Message
		AddByteToBuffer( ucQFM );
		
		m_ucQFM++;
		if( m_ucQFM > 7 )
			m_ucQFM = 0;
		break;
	case kMIDIReasonADATMIDI:
		// Nothing extra to do as byte has already been added to the buffer by CHalLStream::Service
		break;
	}

	// let the driver service the interrupt for this device
	return( CHalDevice::Service( kReasonMIDI ) );
}

