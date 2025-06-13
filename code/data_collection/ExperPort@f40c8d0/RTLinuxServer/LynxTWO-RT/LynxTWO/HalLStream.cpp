/****************************************************************************
 HalLStream.cpp

 Description:	Lynx Application Programming Interface Header File

 Created: David A. Hoatson, June 2002
	
 Copyright © 2002 Lynx Studio Technology, Inc.

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
 Oct 13 03 DAH	AESSetClockSource now doesn't call ControlChanged when it is 
				being called from inside the ISR.  This avoids a possible 
				problem because ControlChanged must eventually call 
				IoAcquireCancelSpinLock which must be run from 
				IRQL <= DISPATCH_LEVEL. 
****************************************************************************/

#include <StdAfx.h>
#include "HalAdapter.h"

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalLStream::Open( PHALADAPTER pHalAdapter )
/////////////////////////////////////////////////////////////////////////////
{
	m_pHalAdapter		= pHalAdapter;

	RtlZeroMemory( m_aControlRegisters, sizeof( m_aControlRegisters ) );
	RtlZeroMemory( m_aStatusRegisters, sizeof( m_aStatusRegisters ) );

	// Set both device ids to invalid
	m_aStatusRegisters[ LSTREAM_BRACKET ][ kStatusLSDEVID ] = 0xFF;
	m_aStatusRegisters[ LSTREAM_HEADER  ][ kStatusLSDEVID ] = 0xFF;//REG_LSDEVID_LSAES;

	m_ulOutputSelection[ LSTREAM_BRACKET ] = MIXVAL_LSTREAM_OUTSEL_9TO16_1TO8;
	m_ulOutputSelection[ LSTREAM_HEADER ] = MIXVAL_LSTREAM_OUTSEL_9TO16_1TO8;

	PLYNXTWOREGISTERS pRegisters = m_pHalAdapter->GetRegisters();
	m_pMIDIRecord = m_pHalAdapter->GetMIDIDevice( MIDI_RECORD0_DEVICE );

	m_RegOPIOCTL.Init( &pRegisters->OPIOCTL, REG_WRITEONLY );
	m_RegOPDEVCTL.Init( &pRegisters->OPDEVCTL, REG_WRITEONLY );
	m_RegOPDEVSTAT.Init( &pRegisters->OPDEVSTAT, REG_READONLY );
	m_RegOPBUFSTAT.Init( &pRegisters->OPBUFSTAT, REG_READONLY );

	// if this is the SECOND LynxTWO/L22 in the computer, we must NOT set HD2DIR to OUTPUT!
	//if( m_pHalAdapter->GetAdapterNumber() == 0 )
		if( m_pHalAdapter->HasLStream11() )
			m_RegOPIOCTL.Write( REG_OPIOCTL_OPHD2DIR  | REG_OPIOCTL_OPHDINSEL | REG_OPIOCTL_OPBFCKDIR | REG_OPIOCTL_OPHFCKDIR );

	m_lSampleRate = 44100;
	m_ulSpeed = SR_SPEED_1X;

	// We can't init the hardware at this point, because it may not be locked yet.  We wait for 
	// the first PING interrupt to come in and then we setup everything.
	m_bInitialized[ LSTREAM_BRACKET ] = FALSE;
	m_bInitialized[ LSTREAM_HEADER ] = FALSE;
	//m_ulLastTimecode[ LSTREAM_BRACKET ] = 0;
	//m_ulLastTimecode[ LSTREAM_HEADER ] = 0;

	/////////////////////////////////////////////////////////////////////////
	// LS-ADAT Defaults
	/////////////////////////////////////////////////////////////////////////

	m_ulADATTimeCodeTxRate[ LSTREAM_BRACKET ] = 0;	// will get converted to 48000 / 4
	m_ulADATTimeCodeTxRate[ LSTREAM_HEADER ] = 0;

	m_ulADATClockSource[ LSTREAM_BRACKET ] = MIXVAL_ADATCLKSRC_SLAVE;
	m_ulADATClockSource[ LSTREAM_HEADER ] = MIXVAL_ADATCLKSRC_SLAVE;

	m_bEnableMTC[ LSTREAM_BRACKET ] = FALSE;
	m_bEnableMTC[ LSTREAM_HEADER ] = FALSE;

	m_ulADATCuePoint[ LSTREAM_BRACKET ] = 0;
	m_ulADATCuePoint[ LSTREAM_HEADER ] = 0;

	/////////////////////////////////////////////////////////////////////////
	// LS-AES Defaults
	/////////////////////////////////////////////////////////////////////////

	m_bLStreamDualInternal = FALSE;

	m_ulAESClockSource[ LSTREAM_BRACKET ] = MIXVAL_AESCLKSRC_SLAVE;
	m_ulAESClockSource[ LSTREAM_HEADER ] = MIXVAL_AESCLKSRC_IN1;

	m_ulWideWire[ LSTREAM_BRACKET ] = FALSE;
	m_ulWideWire[ LSTREAM_HEADER ] = FALSE;

	m_ulFormat[ LSTREAM_BRACKET ][ k8420_A ] = MIXVAL_DF_AESEBU;
	m_ulFormat[ LSTREAM_BRACKET ][ k8420_B ] = MIXVAL_DF_AESEBU;
	m_ulFormat[ LSTREAM_BRACKET ][ k8420_C ] = MIXVAL_DF_AESEBU;
	m_ulFormat[ LSTREAM_BRACKET ][ k8420_D ] = MIXVAL_DF_AESEBU;
	m_ulFormat[ LSTREAM_HEADER ][ k8420_A ] = MIXVAL_DF_AESEBU;
	m_ulFormat[ LSTREAM_HEADER ][ k8420_B ] = MIXVAL_DF_AESEBU;
	m_ulFormat[ LSTREAM_HEADER ][ k8420_C ] = MIXVAL_DF_AESEBU;
	m_ulFormat[ LSTREAM_HEADER ][ k8420_D ] = MIXVAL_DF_AESEBU;

	m_ulSRCMode[ LSTREAM_BRACKET ][ k8420_A ] = MIXVAL_AESSRCMODE_SRC_ON;
	m_ulSRCMode[ LSTREAM_BRACKET ][ k8420_B ] = MIXVAL_AESSRCMODE_SRC_ON;
	m_ulSRCMode[ LSTREAM_BRACKET ][ k8420_C ] = MIXVAL_AESSRCMODE_SRC_ON;
	m_ulSRCMode[ LSTREAM_BRACKET ][ k8420_D ] = MIXVAL_AESSRCMODE_SRC_ON;
	m_ulSRCMode[ LSTREAM_HEADER ][ k8420_A ] = MIXVAL_AESSRCMODE_SRC_ON;
	m_ulSRCMode[ LSTREAM_HEADER ][ k8420_B ] = MIXVAL_AESSRCMODE_SRC_ON;
	m_ulSRCMode[ LSTREAM_HEADER ][ k8420_C ] = MIXVAL_AESSRCMODE_SRC_ON;
	m_ulSRCMode[ LSTREAM_HEADER ][ k8420_D ] = MIXVAL_AESSRCMODE_SRC_ON;

	m_ulOutputStatus[ LSTREAM_BRACKET ][ k8420_A ] = MIXVAL_OUTSTATUS_VALID;
	m_ulOutputStatus[ LSTREAM_BRACKET ][ k8420_B ] = MIXVAL_OUTSTATUS_VALID;
	m_ulOutputStatus[ LSTREAM_BRACKET ][ k8420_C ] = MIXVAL_OUTSTATUS_VALID;
	m_ulOutputStatus[ LSTREAM_BRACKET ][ k8420_D ] = MIXVAL_OUTSTATUS_VALID;
	m_ulOutputStatus[ LSTREAM_HEADER ][ k8420_A ] = MIXVAL_OUTSTATUS_VALID;
	m_ulOutputStatus[ LSTREAM_HEADER ][ k8420_B ] = MIXVAL_OUTSTATUS_VALID;
	m_ulOutputStatus[ LSTREAM_HEADER ][ k8420_C ] = MIXVAL_OUTSTATUS_VALID;
	m_ulOutputStatus[ LSTREAM_HEADER ][ k8420_D ] = MIXVAL_OUTSTATUS_VALID;

	/////////////////////////////////////////////////////////////////////////

	ResetFIFOs();
	EnableInterrupts();

	// HACK IN PING TILL NEXT LS-ADAT FIRMWARE UPGRADE
	//m_bInitialized[ LSTREAM_HEADER ] = TRUE;
	//WriteControl( LSTREAM_HEADER, kControlLSCTL0, REG_LSCTL0_PING );
	//WriteControl( LSTREAM_HEADER, kControlADATCTL, REG_ADATCTL_RCVRSTn );
	//WriteControl( LSTREAM_HEADER, kControlDEVCTL, REG_DEVCTL_DEVRSTn | REG_DEVCTL_RXNOTIFY );
	//m_bInitialized[ LSTREAM_HEADER ] = FALSE;
	// HACK IN PING TILL NEXT LS-ADAT FIRMWARE UPGRADE

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalLStream::Close()
/////////////////////////////////////////////////////////////////////////////
{
	DisableInterrupts();
	ResetFIFOs();
	
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
void	CHalLStream::EnableInterrupts()
/////////////////////////////////////////////////////////////////////////////
{
	if( m_pHalAdapter->HasLStream11() )
		m_RegOPIOCTL.Write( REG_OPIOCTL_OPSTATIE, REG_OPIOCTL_OPSTATIE );
}

/////////////////////////////////////////////////////////////////////////////
void	CHalLStream::DisableInterrupts()
/////////////////////////////////////////////////////////////////////////////
{
	if( m_pHalAdapter->HasLStream11() )
		m_RegOPIOCTL.Write( 0, REG_OPIOCTL_OPSTATIE );
}

/////////////////////////////////////////////////////////////////////////////
void	CHalLStream::ResetFIFOs()
/////////////////////////////////////////////////////////////////////////////
{
	if( m_pHalAdapter->HasLStream11() )
		m_RegOPIOCTL.Write( REG_OPIOCTL_OPCTLRST | REG_OPIOCTL_OPSTATRST, REG_OPIOCTL_OPCTLRST | REG_OPIOCTL_OPSTATRST );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalLStream::InitializeDevice( ULONG ulPort )
// Based on the Device ID just read from the hardware during this PING cycle
// we setup all the other registers required for this device
/////////////////////////////////////////////////////////////////////////////
{
	ulPort	&= 0x1;

	DPF(("CHalLStream::InitializeDevice\n"));

	switch( m_aStatusRegisters[ ulPort ][ kStatusLSDEVID ] )
	{
	case REG_LSDEVID_LSADAT:
		// Make sure we only run this code once
		m_bInitialized[ ulPort ] = TRUE;
		// Unmute master LSTREAM device
		WriteControl( ulPort, kControlLSCTL0, REG_LSCTL0_MMUTEn | REG_LSCTL0_PING );

		m_aStatusRegisters[ ulPort ][ kStatusADATSTAT ] = REG_ADATSTAT_RCVERR0 | REG_ADATSTAT_RCVERR1;

		// unmute ADAT recev/xmit and enable recevier
		WriteControl( ulPort, kControlADATCTL, REG_ADATCTL_RCVRSTn | REG_ADATCTL_RCVMUTEn | REG_ADATCTL_XMTMUTEn );// | REG_ADATCTL_SYNCINEN );
		
		if( m_bEnableMTC[ ulPort ] )
			ADATEnableTimeCodeToMTC( ulPort, TRUE );
		else
			ADATSetTimeCodeTxRate( ulPort, m_ulADATTimeCodeTxRate[ ulPort ] );

		ADATSetClockSource( ulPort, m_ulADATClockSource[ ulPort ] );
		break;
	case REG_LSDEVID_LSAES:
		// Make sure we only run this code once
		m_bInitialized[ ulPort ] = TRUE;
		// Unmute master LSTREAM device
		WriteControl( ulPort, kControlLSCTL0, REG_LSCTL0_MMUTEn | REG_LSCTL0_PING );

		WriteControl( ulPort, kControlDEVCTL, REG_DEVCTL_DEVRSTn | REG_DEVCTL_RXNOTIFY );
		// Init the AK4117
		WriteControl( ulPort, kControlAK4117_PDC, 0x0F );	// Power Down Control
		WriteControl( ulPort, kControlAK4117_CLC, 0x24 );	// Clock Control
		WriteControl( ulPort, kControlAK4117_IOC, 0x0D );	// I/O Control
		AESInitialize8420( ulPort, k8420_A );
		AESInitialize8420( ulPort, k8420_B );
		AESInitialize8420( ulPort, k8420_C );
		AESInitialize8420( ulPort, k8420_D );
		WriteControl( ulPort, kControlDEVCTL, REG_DEVCTL_CSINIT, REG_DEVCTL_CSINIT );
		CLR( m_aControlRegisters[ ulPort ][ kControlDEVCTL ], REG_DEVCTL_CSINIT );

		// Make sure we let the SetClockSource code know it is being called from inside the ISR...
		AESSetClockSource( ulPort, m_ulAESClockSource[ ulPort ], TRUE );
		
		// Make sure we copy the mute on error from the 8420 (if we have one!)
		if( m_pHalAdapter->HasCS8420() )
			AESSetInputMuteOnError( ulPort, m_pHalAdapter->Get8420()->GetInputMuteOnError() );
		break;
	case REG_LSDEVID_LSTDIF:
	default:
		return( HSTATUS_ADAPTER_NOT_FOUND );
	}

	// Request all Status Registers
	WriteControl( ulPort, kControlLSREQ, REG_LSREQ_REQALL );
	
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalLStream::SampleClockChanged( long lRate, long lSource, long lReference )
// Called from HalSampleClock.cpp whenever the sample clock or rate changes
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulPort;
	(void)lSource; (void) lReference; // avoid compiler warnings.. 

	m_lSampleRate = lRate;

	for( ulPort=LSTREAM_BRACKET; ulPort<LSTREAM_NUM_PORTS; ulPort++ )
	{
		switch( m_aStatusRegisters[ ulPort ][ kStatusLSDEVID ] )
		{
		case REG_LSDEVID_LSADAT:
			if( m_lSampleRate > 100000 )		m_ulSpeed	= SR_SPEED_4X;
			else if( m_lSampleRate > 50000 )	m_ulSpeed	= SR_SPEED_2X;
			else								m_ulSpeed	= SR_SPEED_1X;

			ADATSetTimeCodeTxRate( ulPort, m_ulADATTimeCodeTxRate[ ulPort ] );
			break;
		case REG_LSDEVID_LSAES:
			AESSetFormat( ulPort, k8420_A, AESGetFormat( ulPort, k8420_A ) );
			AESSetFormat( ulPort, k8420_B, AESGetFormat( ulPort, k8420_B ) );
			AESSetFormat( ulPort, k8420_C, AESGetFormat( ulPort, k8420_C ) );
			AESSetFormat( ulPort, k8420_D, AESGetFormat( ulPort, k8420_D ) );
			break;
		case REG_LSDEVID_LSTDIF:
		default:
			break;
		}
	}

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
ULONG	CHalLStream::GetDeviceID( ULONG ulPort )
/////////////////////////////////////////////////////////////////////////////
{
/*
	static BOOLEAN bInService = FALSE;
	if( !bInService && !m_bEnableMTC[ ulPort ] )
	{
		bInService = TRUE;
		Service();
		bInService = FALSE;
	}
*/
	ulPort	&= 0x1;
	//DPF(("DeviceID %lu\n", (ULONG)m_aStatusRegisters[ ulPort ][ kStatusLSDEVID ] ));
	//m_aStatusRegisters[ LSTREAM_HEADER ][ kStatusLSDEVID ] = REG_LSDEVID_LSAES;
	return( (ULONG)m_aStatusRegisters[ ulPort ][ kStatusLSDEVID ] );	
}

/////////////////////////////////////////////////////////////////////////////
ULONG	CHalLStream::GetPCBRev( ULONG ulPort )
/////////////////////////////////////////////////////////////////////////////
{
	ulPort	&= 0x1;
	//DPF(("PCBRev %lu\n", (ULONG)m_aStatusRegisters[ ulPort ][ kStatusPCBRREV ] ));
	return( (ULONG)m_aStatusRegisters[ ulPort ][ kStatusPCBRREV ] );	
}

/////////////////////////////////////////////////////////////////////////////
ULONG	CHalLStream::GetFirmwareRev( ULONG ulPort )
/////////////////////////////////////////////////////////////////////////////
{
	ulPort	&= 0x1;
	//DPF(("FWRev %lu\n", (ULONG)m_aStatusRegisters[ ulPort ][ kStatusFWREV ] ));
	return( (ULONG)m_aStatusRegisters[ ulPort ][ kStatusFWREV ] );	
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalLStream::WriteControl( ULONG ulPort, ULONG ulReg, BYTE ucValue, BYTE ucMask )
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulOrgValue, ulValue;

	ulPort	&= 0x1;
	ulReg	&= 0x7F;
	ucValue &= 0xFF;

	if( m_bInitialized[ ulPort ] )
	{
		// read the current register out of the shadow memory
		ulOrgValue = ulValue = (ULONG)m_aControlRegisters[ ulPort ][ ulReg ];

		CLR( ulValue, ucMask );
		SET( ulValue, (ucValue & ucMask) );

		// Only write the register if it has changed, and the port is locked
		if( !WaitForLock( ulPort ) )	// Massive time waster...
		{
			BOOLEAN bFull;
			do 
			{
				bFull = m_RegOPBUFSTAT.Read() & REG_OPBUFSTAT_CTL_FULL ? TRUE : FALSE;	// Yet another time waster...
			} while( bFull );

			//if( ulOrgValue != ulValue )
			{
				m_RegOPDEVCTL.Write( (ulPort<<REG_OPDEVCTL_PORT_OFFSET) | (ulReg<<REG_OPDEVCTL_ADDR_OFFSET) | ulValue );
				//if( ulOrgValue != ulValue )
				//	DPF(("[WC %02lx %02lx] ", ulReg, ulValue ));
				//else
				//	DPF(("[WC %02lx %02lx NO CHANGE] ", ulReg, ulValue ));
				// save the current register back to the shadow memory
				m_aControlRegisters[ ulPort ][ ulReg ] = (BYTE)ulValue;
			}
		}
		else
		{
			DPF(("CHalLStream::WriteControl Port %lu is Unlocked\n", ulPort ));
			return( HSTATUS_TIMEOUT );
		}
	}

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalLStream::ReadStatus( ULONG ulPort, ULONG ulReg, PBYTE pucValue )
// Never used
/////////////////////////////////////////////////////////////////////////////
{
	ulPort	&= 0x1;
	ulReg	&= 0x7F;

	*pucValue = m_aStatusRegisters[ ulPort ][ ulReg ];

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
BOOLEAN CHalLStream::IsLocked( ULONG ulPort )
/////////////////////////////////////////////////////////////////////////////
{
	ULONG ulValue = 0;

	if( ulPort == LSTREAM_BRACKET )	ulValue = REG_OPBUFSTAT_LOCKED0;
	if( ulPort == LSTREAM_HEADER )	ulValue = REG_OPBUFSTAT_LOCKED1;

	if( m_pHalAdapter->HasLStream11() )
		if(	(m_RegOPBUFSTAT.Read() & ulValue) )
			return( TRUE );
	
	return( FALSE );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalLStream::WaitForLock( ULONG ulPort )
/////////////////////////////////////////////////////////////////////////////
{
	int	nTimeout;
	//DPF(("WaitForLock\n"));

	for( nTimeout=0; nTimeout<1000; nTimeout++ )
	{
		if( IsLocked( ulPort ) )
		{
			nTimeout = 0;
			break;
		}
	}

	if( nTimeout )
	{
		DPF(("Timeout!\n"));
		return( HSTATUS_TIMEOUT );
	}
	
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalLStream::SetOutputSelection( ULONG ulPort, ULONG ulOutputSelection )
/////////////////////////////////////////////////////////////////////////////
{
	ulPort	&= 0x1;
	ulOutputSelection &= 0x1;

	switch( ulPort )
	{
	case LSTREAM_BRACKET:
		switch( ulOutputSelection )
		{
		case MIXVAL_LSTREAM_OUTSEL_9TO16_1TO8:
			m_RegOPIOCTL.BitSet( REG_OPIOCTL_OPBBLKSEL, FALSE );
			break;
		case MIXVAL_LSTREAM_OUTSEL_1TO8_9TO16:
			m_RegOPIOCTL.BitSet( REG_OPIOCTL_OPBBLKSEL, TRUE );
			break;
		}
		m_ulOutputSelection[ ulPort ] = ulOutputSelection;
		break;
	case LSTREAM_HEADER:
		switch( ulOutputSelection )
		{
		case MIXVAL_LSTREAM_OUTSEL_9TO16_1TO8:
			m_RegOPIOCTL.BitSet( REG_OPIOCTL_OPHBLKSEL, FALSE );
			break;
		case MIXVAL_LSTREAM_OUTSEL_1TO8_9TO16:
			m_RegOPIOCTL.BitSet( REG_OPIOCTL_OPHBLKSEL, TRUE );
			break;
		}
		m_ulOutputSelection[ ulPort ] = ulOutputSelection;
		break;
	}
		
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
ULONG	CHalLStream::GetOutputSelection( ULONG ulPort )
/////////////////////////////////////////////////////////////////////////////
{
	ulPort	&= 0x1;
	return( m_ulOutputSelection[ ulPort ] );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalLStream::SetLStreamDualInternal( ULONG ulLStreamDualInternal )
/////////////////////////////////////////////////////////////////////////////
{
	m_bLStreamDualInternal = (BOOLEAN)ulLStreamDualInternal & 0x1;

	if( m_bLStreamDualInternal )
	{
		m_RegOPIOCTL.Write( REG_OPIOCTL_OPHDUAL, REG_OPIOCTL_OPHDUAL );
	}
	else
	{
		m_RegOPIOCTL.Write( 0, REG_OPIOCTL_OPHDUAL );
		
		// LStream 1 should now be invalid
		m_bInitialized[ LSTREAM_BRACKET ] = FALSE;
		m_aStatusRegisters[ LSTREAM_BRACKET ][ kStatusLSDEVID ] = 0;
	}

	AESSetClockSource( LSTREAM_BRACKET, MIXVAL_AESCLKSRC_SLAVE );
	AESSetClockSource( LSTREAM_HEADER, MIXVAL_AESCLKSRC_IN1 );

	m_pHalAdapter->GetMixer()->ControlChanged( LINE_LSTREAM, LINE_NO_SOURCE, CONTROL_LS1_AES_CLKSRC );
	m_pHalAdapter->GetMixer()->ControlChanged( LINE_LSTREAM, LINE_NO_SOURCE, CONTROL_LS2_AES_CLKSRC );

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
//	LS-ADAT Specific
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalLStream::ADATSetClockSource( ULONG ulPort, ULONG ulClockSource )
/////////////////////////////////////////////////////////////////////////////
{
	BYTE	ucValue;
	ulPort	&= 0x1;

	m_ulADATClockSource[ ulPort ] = ulClockSource;

	if( GetDeviceID( ulPort ) != REG_LSDEVID_LSADAT )
		return( HSTATUS_ADAPTER_NOT_FOUND );

	// Need to check to insure the requested port has no errors first.
	switch( ulClockSource )
	{
	case MIXVAL_ADATCLKSRC_SLAVE:
		ucValue = REG_LSCTL0_CKSRC_FCK;
		break;
	case MIXVAL_ADATCLKSRC_IN1:
		//if( !IsADATInLocked( ulPort, ADAT_OPTICAL_IN_1 ) )
		//	return( HSTATUS_INVALID_MODE );

		ucValue = REG_LSCTL0_CKSRC_OP0;
		break;
	case MIXVAL_ADATCLKSRC_IN2:
		//if( !IsADATInLocked( ulPort, ADAT_OPTICAL_IN_2 ) )
		//	return( HSTATUS_INVALID_MODE );

		ucValue = REG_LSCTL0_CKSRC_OP1;
		break;
	case MIXVAL_ADATCLKSRC_SYNCIN:
		ucValue = REG_LSCTL0_CKSRC_SYNCIN;
		break;
	default:
		return( HSTATUS_INVALID_PARAMETER );
	}

	m_ulADATClockSource[ ulPort ] = ulClockSource;
	WriteControl( ulPort, kControlLSCTL0, ucValue, REG_LSCTL0_CKSRC_MASK );

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
BYTE	CHalLStream::ADATGetClockSource( ULONG ulPort )
/////////////////////////////////////////////////////////////////////////////
{
	ulPort	&= 0x1;
	return( (BYTE)m_ulADATClockSource[ ulPort ] );
}

/////////////////////////////////////////////////////////////////////////////
BOOLEAN CHalLStream::ADATIsLocked( ULONG ulPort, ULONG ulInput )
/////////////////////////////////////////////////////////////////////////////
{
	ulPort	&= 0x1;
	ulInput	&= 0x1;

	if( !IsLocked( ulPort ) )
		return( FALSE );
	
	if( GetDeviceID( ulPort ) != REG_LSDEVID_LSADAT )
		return( FALSE );

	if( ulInput == ADAT_OPTICAL_IN_1 )
	{
		if( m_aStatusRegisters[ ulPort ][ kStatusADATSTAT ] & REG_ADATSTAT_RCVERR0 )
			return( FALSE );
		else
			return( TRUE );
	}
	else
	{
		if( m_aStatusRegisters[ ulPort ][ kStatusADATSTAT ] & REG_ADATSTAT_RCVERR1 )
			return( FALSE );
		else
			return( TRUE );
	}
	
	return( FALSE );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalLStream::ADATEnableTimeCodeToMTC( ULONG ulPort, BOOLEAN bEnable )
// NOTE: If ASIO Positioning Protocol is running, this will screw it up.
/////////////////////////////////////////////////////////////////////////////
{
	ulPort	&= 0x1;

	//DPF(("CHalLStream::ADATEnableTimeCodeToMTC\n"));

	m_bEnableMTC[ ulPort ] = bEnable;

	if( !m_bInitialized[ ulPort ] )
		return( HSTATUS_INVALID_MODE );

	if( bEnable )
	{
		// We can tell if ASIO Positioning Protocol is running by looking at 
		// m_ulADATTimeCodeTxRate[ ulPort ]. If it is zero, then APP isn't running.
		if( m_ulADATTimeCodeTxRate[ ulPort ] )
		{
			DPF(("ADAT to MTC NOT enabled. ASIO running!\n"));
			m_bEnableMTC[ ulPort ] = FALSE;
			return( HSTATUS_INVALID_MODE );
		}

		// This will always run at 30fps, we need quarter-frame so that is 120x
		ADATSetTimeCodeTxRate( ulPort, m_lSampleRate / 120 );	// 400 samples @ 48kHz, 367.5 @ 44.1kHz
	}
	else
	{
		ADATSetTimeCodeTxRate( ulPort, 0 );
	}

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalLStream::ADATSetTimeCodeTxRate( ULONG ulPort, ULONG ulTCTxRateSamples )
//	Starts counting at zero, so we need to decrement the timecode by one sample
//	If the requested rate is zero, then we go to 250ms rate
/////////////////////////////////////////////////////////////////////////////
{
	ulPort	&= 0x1;

	// save the requested rate no matter what
	m_ulADATTimeCodeTxRate[ ulPort ] = ulTCTxRateSamples;

	if( m_aStatusRegisters[ ulPort ][ kStatusLSDEVID ] == REG_LSDEVID_LSADAT )
	{
		// Turn off TCEN for this port
		//DPF(("TCEN Off %lu: ", ulPort ));
		//WriteControl( ulPort, kControlADATCTL, 0, REG_ADATCTL_TCEN );

		if( !ulTCTxRateSamples )
		{
			ulTCTxRateSamples = m_lSampleRate / 4;	// ~250ms
		}

		// ulTCTxRateSamples now needs to be adjusted for the speed multiplier
		ulTCTxRateSamples >>= m_ulSpeed;
		ulTCTxRateSamples--;

		WriteControl( ulPort, kControlTCRATE0, LOBYTE( LOWORD( ulTCTxRateSamples ) ) );
		WriteControl( ulPort, kControlTCRATE1, HIBYTE( LOWORD( ulTCTxRateSamples ) ) );
		//DPF(("TCRate to %08lx\n", ulTCTxRateSamples ));

		// Turn on TCEN for this port
		//DPF(("TCEN On %lu: ", ulPort ));
		WriteControl( ulPort, kControlADATCTL, REG_ADATCTL_TCEN, REG_ADATCTL_TCEN );
	}
	
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalLStream::ADATSetCuePoint( ULONG ulPort, ULONG ulCuePoint )
/////////////////////////////////////////////////////////////////////////////
{
	ulPort	&= 0x1;

	//DPF(("CHalLStream::ADATSetCuePoint %lu %lu\n", ulPort, ulCuePoint ));

	m_ulADATCuePoint[ ulPort ] = ulCuePoint;

	if( m_aStatusRegisters[ ulPort ][ kStatusLSDEVID ] == REG_LSDEVID_LSADAT )
	{
		// Make sure the Mixer UI gets updated with the new cue point
		// We have to do this because there is a path to change the cue point that doesn't 
		// go through the mixer (CoolEditPro Sample Accurate Start)
		m_pHalAdapter->GetMixer()->ControlChanged( LINE_LSTREAM, LINE_NO_SOURCE, 
			(ulPort == LSTREAM_BRACKET) ? CONTROL_LS1_ADAT_CUEPOINT : CONTROL_LS2_ADAT_CUEPOINT );
		
		// ulCuePoint now needs to be adjusted for the speed multiplier
		ulCuePoint >>= m_ulSpeed;

		// adjust for the 2 minute ADAT data portion of tape header
		ulCuePoint += 5760000;

		WriteControl( ulPort, kControlADATCTL, 0, REG_ADATCTL_TCCUEEN );

		WriteControl( ulPort, kControlTCCUE0, LOBYTE( LOWORD( ulCuePoint ) ) );
		WriteControl( ulPort, kControlTCCUE1, HIBYTE( LOWORD( ulCuePoint ) ) );
		WriteControl( ulPort, kControlTCCUE2, LOBYTE( HIWORD( ulCuePoint ) ) );
		WriteControl( ulPort, kControlTCCUE3, HIBYTE( HIWORD( ulCuePoint ) ) );
	}

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
ULONG	CHalLStream::ADATGetCuePoint( ULONG ulPort )
/////////////////////////////////////////////////////////////////////////////
{
	ulPort	&= 0x1;
	return( m_ulADATCuePoint[ ulPort ] );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalLStream::ADATCuePointEnable()
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulPort;

	if( m_aStatusRegisters[ LSTREAM_HEADER ][ kStatusLSDEVID ] == REG_LSDEVID_LSADAT )
		ulPort = LSTREAM_HEADER;
	else if( m_aStatusRegisters[ LSTREAM_BRACKET ][ kStatusLSDEVID ] == REG_LSDEVID_LSADAT )
		ulPort = LSTREAM_BRACKET;
	else
		return( HSTATUS_INVALID_MODE );

	//DPF(("CHalLStream::ADATCuePointEnable %lu\n", ulPort ));

	WriteControl( ulPort, kControlADATCTL, REG_ADATCTL_TCCUEEN, REG_ADATCTL_TCCUEEN );

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalLStream::ADATGetSyncInTimeCode( ULONG ulPort, PULONG pulTimecode )
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulTimecode = 0;

	ulPort	&= 0x1;

	if( IsLocked( ulPort ) && (m_aStatusRegisters[ ulPort ][ kStatusLSDEVID ] == REG_LSDEVID_LSADAT)  )
	{
		//DPET();

		ulTimecode = MAKEULONG( 
						MAKEUSHORT( m_aStatusRegisters[ ulPort ][ kStatusSYNCTC0 ], m_aStatusRegisters[ ulPort ][ kStatusSYNCTC1 ] ),
						MAKEUSHORT( m_aStatusRegisters[ ulPort ][ kStatusSYNCTC2 ], m_aStatusRegisters[ ulPort ][ kStatusSYNCTC3 ] ) );
/*
		DPF((" %08lx ", ulTimecode ));
		if( m_ulLastTimecode[ ulPort ] > ulTimecode )
		{
			DS(" Error ",COLOR_BOLD);
			DPF((" Error "));
		}
		m_ulLastTimecode[ ulPort ] = ulTimecode;
*/
		// if the timecode is greater than 2 minutes, subtract 2 minutes from it...
		if( ulTimecode > 5760000 )	//	0x57E400, Number of samples in 2 minutes @ 48kHz
			ulTimecode -= 5760000;
		else
			ulTimecode = 0;
		
		// ulTimecode now needs to be adjusted for the speed multiplier
		ulTimecode <<= m_ulSpeed;

		// Check to see if the timecode is really moving as expected
		//ULONG	ulExpected = m_ulLastTimecode[ ulPort ] + m_ulADATTimeCodeTxRate[ ulPort ];
		//if( ulExpected != ulTimecode )
		//	DPF(("E[%08lx] G[%08lx]  ", ulExpected, ulTimecode ));
	}

	*pulTimecode = ulTimecode;

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalLStream::ADATGetPosition( ULONG ulPort, PULONG pulPosition )
// Returns the current timecode position as HH:MM:SS:FF @ 30fps
// Used in MTC conversion
/////////////////////////////////////////////////////////////////////////////
{
	TIMECODE	TCPosition;
	ULONG		ulTCSamples;

	ulPort	&= 0x1;

	TCPosition.ulTimecode = 0;

	if( m_lSampleRate > 0 )
	{
		ADATGetSyncInTimeCode( ulPort, &ulTCSamples );

		ULONG	ulSeconds = ulTCSamples / m_lSampleRate;
		
		TCPosition.Bytes.ucHour		= (BYTE)(ulSeconds / 3600L);				// Hours
		TCPosition.Bytes.ucMinute	= (BYTE)((ulSeconds / 60L) % 60);			// Minutes
		TCPosition.Bytes.ucSecond	= (BYTE)(ulSeconds % 60);					// Seconds
		TCPosition.Bytes.ucFrame	= (BYTE)((ulTCSamples / (m_lSampleRate/30)) % 30);	// Frames
	}

	*pulPosition = TCPosition.ulTimecode;

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
//	LS-AES Specific
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
ULONG	CHalLStream::AESGetBaseControl( ULONG ulTheChip )
// private
/////////////////////////////////////////////////////////////////////////////
{
	switch( ulTheChip )
	{
	case k8420_A:	return( kControlCBLK8420A );
	case k8420_B:	return( kControlCBLK8420B );
	case k8420_C:	return( kControlCBLK8420C );
	case k8420_D:	return( kControlCBLK8420D );
	}
	return( 0 );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalLStream::AESInitialize8420( ULONG ulPort, ULONG ulTheChip )
// private
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulBase = AESGetBaseControl( ulTheChip );
	ULONG	ulBaseStatus = (ulTheChip*3);
	ULONG	ulOrgMode;
	
	// Init the error register showing the device is not locked...
	m_aStatusRegisters[ ulPort ][ ulBaseStatus + kStatusRXERRA ]	= k8420_RxErr_UNLOCK;

	// 1: Set the direction of TCBL to output
	WriteControl( ulPort, ulBase + kAES8420MiscControl1, k8420_MC1_TCBLD); 

	// 2: Set RMCk output frequncy to 128 Fsi
	WriteControl( ulPort, ulBase + kAES8420MiscControl2, k8420_MC2_RMCKF | k8420_MC2_HOLD01 );	// Mute On Error: ON

	// 3: Data Flow Control
	// Mute on Loss of Lock, Everything else gets set in SetMode
	WriteControl( ulPort, ulBase + kAES8420DataFlowControl, k8420_DFC_AMLL );	

	// 4: Put the chip in run mode
	WriteControl( ulPort, ulBase + kAES8420ClockSourceControl, k8420_CSC_RUN );

	// 17: setup which errors we are interested in...
	WriteControl( ulPort, ulBase + kAES8420RxErrorMask, 
		(k8420_RxErr_PAR | k8420_RxErr_BIP | k8420_RxErr_CONF | k8420_RxErr_VAL | k8420_RxErr_UNLOCK | k8420_RxErr_CCRC | k8420_RxErr_QCRC) );

	// 18: Channel Status Data Buffer Control
	// only interested in DtoE transfers (Receiver), disable EtoF transfers (Transmitter)
	WriteControl( ulPort, ulBase + kAES8420CSDataBufferControl, k8420_CsDB_DETCI, k8420_CsDB_DETCI );	// DAH Sep 05 2002

	ulOrgMode = AESGetSRCMode( ulPort, ulTheChip );
	AESSetSRCMode( ulPort, ulTheChip, MIXVAL_AESSRCMODE_TXONLY );	// Start with Mode 5 so transmitter will always turn on
	AESSetFormat( ulPort, ulTheChip, AESGetFormat( ulPort, ulTheChip ) );
	AESSetOutputStatus( ulPort, ulTheChip, AESGetOutputStatus( ulPort, ulTheChip ) );
	AESSetSRCMode( ulPort, ulTheChip, ulOrgMode );	// Change to requested mode for normal operation
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalLStream::AESSetClockSource( ULONG ulPort, ULONG ulClockSource, BOOLEAN bInISR )
/////////////////////////////////////////////////////////////////////////////
{
	BYTE	ucValue;
	ulPort	&= 0x1;

	m_ulAESClockSource[ ulPort ] = ulClockSource;	// make sure this is saved first...

	if( GetDeviceID( ulPort ) != REG_LSDEVID_LSAES )
		return( HSTATUS_ADAPTER_NOT_FOUND );

	// Default to FCKOE
	ucValue = REG_LSCTL0_FCKOE;

	// If we are in Dual Internal Mode, then we need to make sure that 
	// only one of the LStream ports has the FCKOE turned on...
	if( (ulClockSource != MIXVAL_AESCLKSRC_SLAVE) && (m_bLStreamDualInternal) )
	{
		ULONG	ulOtherPort = ulPort ^ 0x1;
		// make sure the other port *is* set to slave before we write to this port
		AESSetClockSource( ulOtherPort, MIXVAL_AESCLKSRC_SLAVE, bInISR );
		
		// NOTE: This call to ControlChanged can cause problems for the driver as it may be called at interrupt time... 
		if( !bInISR )
		{
			if( ulOtherPort == LSTREAM_BRACKET )
				m_pHalAdapter->GetMixer()->ControlChanged( LINE_LSTREAM, LINE_NO_SOURCE, CONTROL_LS1_AES_CLKSRC );
			else
				m_pHalAdapter->GetMixer()->ControlChanged( LINE_LSTREAM, LINE_NO_SOURCE, CONTROL_LS2_AES_CLKSRC );
		}
	}

	if( (ulClockSource == MIXVAL_AESCLKSRC_SLAVE) && !m_bLStreamDualInternal )
		return( HSTATUS_INVALID_MODE );

	// Need to check to insure the requested port has no errors first.
	switch( ulClockSource )
	{
	case MIXVAL_AESCLKSRC_SLAVE:	ucValue = 0; /* turns off FCKOE */		break;	// will only happen in Dual-Internal mode
	case MIXVAL_AESCLKSRC_IN1:		ucValue |= REG_LSCTL0_CLKSRC_DIGIN1;	break;
	case MIXVAL_AESCLKSRC_IN2:		ucValue |= REG_LSCTL0_CLKSRC_DIGIN2;	break;
	case MIXVAL_AESCLKSRC_IN3:		ucValue |= REG_LSCTL0_CLKSRC_DIGIN3;	break;
	case MIXVAL_AESCLKSRC_IN4:		ucValue |= REG_LSCTL0_CLKSRC_DIGIN4;	break;
	default:						return( HSTATUS_INVALID_PARAMETER );
	}

	WriteControl( ulPort, kControlLSCTL0, ucValue, REG_LSCTL0_FCKOE | REG_LSCTL0_CKSRC_MASK );

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
ULONG	CHalLStream::AESGetClockSource( ULONG ulPort )
/////////////////////////////////////////////////////////////////////////////
{
	ulPort	&= 0x1;
	return( m_ulAESClockSource[ ulPort ] );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalLStream::AESSetSRCMode( ULONG ulPort, ULONG ulTheChip, ULONG ulMode )
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulBase = AESGetBaseControl( ulTheChip );
	
	if( GetDeviceID( ulPort ) == REG_LSDEVID_LSAES )
	{
		switch( ulMode )
		{
		case MIXVAL_AESSRCMODE_SRC_ON:		// (CS8420 Page 14, Figure 12) AES In, SRC
			WriteControl( ulPort, ulBase + kAES8420MiscControl1, (BYTE)0, k8420_MC1_MUTESAO );	// enable the serial audio output
			WriteControl( ulPort, ulBase + kAES8420DataFlowControl, (k8420_DFC_TXD01 | k8420_DFC_SPD00 | k8420_DFC_SRCD), (k8420_DFC_TXD_MASK | k8420_DFC_SPD_MASK | k8420_DFC_SRCD) );
			WriteControl( ulPort, ulBase + kAES8420ClockSourceControl, k8420_CSC_RXD01, (k8420_CSC_OUTC | k8420_CSC_INC | k8420_CSC_RXD_MASK) );
			break;
		case MIXVAL_AESSRCMODE_SRC_OFF:		// (CS8420 Page 14, Figure 13) Slave to AES In, No SRC
			WriteControl( ulPort, ulBase + kAES8420MiscControl1, (BYTE)0, k8420_MC1_MUTESAO );	// enable the serial audio output
			WriteControl( ulPort, ulBase + kAES8420DataFlowControl, (k8420_DFC_TXD01 | k8420_DFC_SPD10), (k8420_DFC_TXD_MASK | k8420_DFC_SPD_MASK | k8420_DFC_SRCD) );
			WriteControl( ulPort, ulBase + kAES8420ClockSourceControl, k8420_CSC_RXD01, (k8420_CSC_OUTC | k8420_CSC_INC | k8420_CSC_RXD_MASK) );
			break;
		case MIXVAL_AESSRCMODE_SRC_ON_DIGOUT:		// (CS8420 Page 14, Figure 11) AES out SRC to AES in
			WriteControl( ulPort, ulBase + kAES8420MiscControl1, k8420_MC1_MUTESAO, k8420_MC1_MUTESAO );	// mute the serial audio output
			WriteControl( ulPort, ulBase + kAES8420DataFlowControl, (BYTE)0, (k8420_DFC_TXD_MASK | k8420_DFC_SPD_MASK | k8420_DFC_SRCD) );
			WriteControl( ulPort, ulBase + kAES8420ClockSourceControl, (k8420_CSC_OUTC | k8420_CSC_INC | k8420_CSC_RXD01), (k8420_CSC_OUTC | k8420_CSC_INC | k8420_CSC_RXD_MASK) );
			break;
		case MIXVAL_AESSRCMODE_TXONLY:		// (CS8420 Page 14, Figure 15) Transmit Only
			WriteControl( ulPort, ulBase + kAES8420DataFlowControl, (k8420_DFC_TXD01 | k8420_DFC_SPD01), (k8420_DFC_TXD_MASK | k8420_DFC_SPD_MASK | k8420_DFC_SRCD) );
			WriteControl( ulPort, ulBase + kAES8420ClockSourceControl, (k8420_CSC_INC | k8420_CSC_RXD00), (k8420_CSC_OUTC | k8420_CSC_INC | k8420_CSC_RXD_MASK) );
			break;
		default:
			return( HSTATUS_INVALID_PARAMETER );
		}
	}

	m_ulSRCMode[ ulPort ][ ulTheChip ] = ulMode;
	
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
ULONG	CHalLStream::AESGetSRCMode( ULONG ulPort, ULONG ulTheChip )
/////////////////////////////////////////////////////////////////////////////
{
	return( m_ulSRCMode[ ulPort ][ ulTheChip ] );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalLStream::AESSetFormat( ULONG ulPort, ULONG ulTheChip, ULONG ulFormat )
/////////////////////////////////////////////////////////////////////////////
{
	BYTE	aucCSBuffer[ 10 ];

	if( GetDeviceID( ulPort ) == REG_LSDEVID_LSAES )
	{
		RtlZeroMemory( aucCSBuffer, sizeof( aucCSBuffer ) );

		switch( ulFormat )
		{
		case MIXVAL_DF_AESEBU:
			// Change the relay
			WriteControl( ulPort, kControlDEVCTL, (BYTE)0, (REG_DEVCTL_DIOFMT1 << ulTheChip) );

			aucCSBuffer[0]	= MIXVAL_DCS_BYTE0_PRO;
			
			switch( m_ulOutputStatus[ ulPort ][ ulTheChip ] & MIXVAL_OUTSTATUS_EMPHASIS_MASK )
			{
			default:
			case MIXVAL_OUTSTATUS_EMPHASIS_NONE:	SET( aucCSBuffer[0], MIXVAL_DCS_PRO_BYTE0_EMPH_NONE );		break;
			case MIXVAL_OUTSTATUS_EMPHASIS_5015:	SET( aucCSBuffer[0], MIXVAL_DCS_PRO_BYTE0_EMPH_5015 );		break;
			case MIXVAL_OUTSTATUS_EMPHASIS_J17:		SET( aucCSBuffer[0], MIXVAL_DCS_PRO_BYTE0_EMPH_CCITTJ17 );	break;
			}
			
			switch( m_lSampleRate )
			{
			case 22050:		SET( aucCSBuffer[4], MIXVAL_DCS_PRO_BYTE4_FS_22050 );	break;
			case 24000:		SET( aucCSBuffer[4], MIXVAL_DCS_PRO_BYTE4_FS_24000 );	break;
			case 32000:		SET( aucCSBuffer[0], MIXVAL_DCS_PRO_BYTE0_FS_32000 );	break;
			case 44056:		SET( aucCSBuffer[0], MIXVAL_DCS_PRO_BYTE0_FS_44100 );
							SET( aucCSBuffer[4], MIXVAL_DCS_PRO_BYTE4_FS_PULLDOWN );break;
			case 44100:		SET( aucCSBuffer[0], MIXVAL_DCS_PRO_BYTE0_FS_44100 );	break;
			case 48000:		SET( aucCSBuffer[0], MIXVAL_DCS_PRO_BYTE0_FS_48000 );	break;
			case 88200:		SET( aucCSBuffer[4], MIXVAL_DCS_PRO_BYTE4_FS_88200 );	break;
			case 96000:		SET( aucCSBuffer[4], MIXVAL_DCS_PRO_BYTE4_FS_96000 );	break;
			case 176400:	SET( aucCSBuffer[4], MIXVAL_DCS_PRO_BYTE4_FS_176400 );	break;
			case 192000:	SET( aucCSBuffer[4], MIXVAL_DCS_PRO_BYTE4_FS_192000 );	break;
			}

			// There are 4 modes of operation:
			// 1) Normal single wire for sample rates below 100kHz
			// 2) Dual-Wire for sample rates between 50kHz and 100kHz (wide wire is ON)
			// 3) Dual-Wire for sample rates above 100kHz (wide wire is OFF) 
			// 4) Quad-Wire for sample rates above 100kHz (wide wire is ON)

			// default to stereo mode. MODE 1
			aucCSBuffer[1] = MIXVAL_DCS_PRO_BYTE1_CM_STEREO;
			
			// if the sample rate is greater than 100kHz and wide wire is on (quad-wire) MODE 4
			if( (m_lSampleRate > 100000) && m_ulWideWire[ ulPort ] )
			{
				aucCSBuffer[1] = MIXVAL_DCS_PRO_BYTE1_CM_MULTICHANNEL;
			}
			// if the sample rate is greater than 50kHz and wide wire is on (dual wire) MODE 2
			// or if sample rate is greater than 100kHz and wide wire is off (dual wire) MODE 3
			else if( ((m_lSampleRate > 50000) && m_ulWideWire[ ulPort ]) || ((m_lSampleRate > 100000) && !m_ulWideWire[ ulPort ]) )
			{
				// then we are in dual-wire mode
				if( (ulTheChip == k8420_A) || (ulTheChip == k8420_C) )
				{
					// left channel
					aucCSBuffer[1] = MIXVAL_DCS_PRO_BYTE1_CM_1CH_2SR_SML;
				}
				else
				{
					// right channel
					aucCSBuffer[1] = MIXVAL_DCS_PRO_BYTE1_CM_1CH_2SR_SMR;
				}
			}

			aucCSBuffer[2] = MIXVAL_DCS_PRO_BYTE2_AUX_MAIN24 | MIXVAL_DCS_PRO_BYTE2_AUX_24BITS;
			
			aucCSBuffer[6] = 'L';
			aucCSBuffer[7] = 'A';
			aucCSBuffer[8] = 'E';
			aucCSBuffer[9] = 'S';
			break;
		case MIXVAL_DF_SPDIF:
			// Change the relay
			WriteControl( ulPort, kControlDEVCTL, (REG_DEVCTL_DIOFMT1 << ulTheChip), (REG_DEVCTL_DIOFMT1 << ulTheChip) );

			aucCSBuffer[0] = MIXVAL_DCS_BYTE0_CON | MIXVAL_DCS_CON_BYTE0_COPY_PERMIT;
		
			if( m_ulOutputStatus[ ulPort ][ ulTheChip ] & MIXVAL_OUTSTATUS_EMPHASIS_5015 )
				SET( aucCSBuffer[0], MIXVAL_DCS_CON_BYTE0_EMPH_5015 );
			
			// default is 44100
			switch( m_lSampleRate )
			{
			case 32000:	SET( aucCSBuffer[3], MIXVAL_DCS_CON_BYTE3_FS_32000 );	break;
			case 44100:	SET( aucCSBuffer[3], MIXVAL_DCS_CON_BYTE3_FS_44100 );	break;
			case 48000:	SET( aucCSBuffer[3], MIXVAL_DCS_CON_BYTE3_FS_48000 );	break;
			}
			SET( aucCSBuffer[3], MIXVAL_DCS_CON_BYTE3_CA_LEVELI );
			break;
		}

		if( m_ulOutputStatus[ ulPort ][ ulTheChip ] & MIXVAL_OUTSTATUS_NONAUDIO )
			SET( aucCSBuffer[0], MIXVAL_DCS_BYTE0_NONPCM );

		// write the transmitters CS data
		AESWriteCSBuffer( ulPort, ulTheChip, aucCSBuffer );
	}

	m_ulFormat[ ulPort ][ ulTheChip ] = ulFormat;
	
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
ULONG	CHalLStream::AESGetFormat( ULONG ulPort, ULONG ulTheChip )
/////////////////////////////////////////////////////////////////////////////
{
	return( m_ulFormat[ ulPort ][ ulTheChip ] );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalLStream::AESSetInputMuteOnError( ULONG ulPort, BOOLEAN bMuteOnError )
/////////////////////////////////////////////////////////////////////////////
{
	if( GetDeviceID( ulPort ) != REG_LSDEVID_LSAES )
		return( HSTATUS_ADAPTER_NOT_FOUND );

	if( bMuteOnError )
	{
		WriteControl( ulPort, AESGetBaseControl( k8420_A ) + kAES8420MiscControl2, k8420_MC2_HOLD01, k8420_MC2_HOLD_MASK );
		WriteControl( ulPort, AESGetBaseControl( k8420_B ) + kAES8420MiscControl2, k8420_MC2_HOLD01, k8420_MC2_HOLD_MASK );
		WriteControl( ulPort, AESGetBaseControl( k8420_C ) + kAES8420MiscControl2, k8420_MC2_HOLD01, k8420_MC2_HOLD_MASK );
		WriteControl( ulPort, AESGetBaseControl( k8420_D ) + kAES8420MiscControl2, k8420_MC2_HOLD01, k8420_MC2_HOLD_MASK );
	}
	else
	{
		WriteControl( ulPort, AESGetBaseControl( k8420_A ) + kAES8420MiscControl2, k8420_MC2_HOLD10, k8420_MC2_HOLD_MASK );
		WriteControl( ulPort, AESGetBaseControl( k8420_B ) + kAES8420MiscControl2, k8420_MC2_HOLD10, k8420_MC2_HOLD_MASK );
		WriteControl( ulPort, AESGetBaseControl( k8420_C ) + kAES8420MiscControl2, k8420_MC2_HOLD10, k8420_MC2_HOLD_MASK );
		WriteControl( ulPort, AESGetBaseControl( k8420_D ) + kAES8420MiscControl2, k8420_MC2_HOLD10, k8420_MC2_HOLD_MASK );
	}

	return( HSTATUS_OK );
}

BYTE	Invert( BYTE ucIn );	// In Hal8420.cpp

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalLStream::AESWriteCSBuffer( ULONG ulPort, ULONG ulTheChip, PBYTE pBuffer )
// private
/////////////////////////////////////////////////////////////////////////////
{
	BYTE	ucByte;
	BYTE	ucRegister = (BYTE)AESGetBaseControl( ulTheChip ) + kAES8420CSBuffer;

	// invert the bytes in the buffer (prepare for transmission)
	for( int i=0; i<10; i++, ucRegister++ )
	{
		ucByte = Invert( pBuffer[i] );
		// if there is no change in the byte, don't write it
		if( m_aControlRegisters[ ulPort ][ ucRegister ] != ucByte )
			WriteControl( ulPort, ucRegister, ucByte );
	}

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalLStream::AESSetOutputStatus( ULONG ulPort, ULONG ulTheChip, ULONG ulStatus )
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulBase = AESGetBaseControl( ulTheChip );
	BYTE	ucMC1;
	BYTE	ucCSBUF0;

	//DPF(("CHalLStream::AESSetOutputStatus %lu %lu %lu\n", ulPort, ulTheChip, ulStatus ));

	if( GetDeviceID( ulPort ) == REG_LSDEVID_LSAES )
	{
		// Validity
		ucMC1 = m_aControlRegisters[ ulPort ][ ulBase + kAES8420MiscControl1 ];
		if( ulStatus & MIXVAL_OUTSTATUS_VALID )
			CLR( ucMC1, k8420_MC1_VSET );	// transmit a 1 for the V bit (Valid)
		else
			SET( ucMC1, k8420_MC1_VSET );	// transmit a 0 for the V bit (Invalid)
		
		if( ucMC1 != m_aControlRegisters[ ulPort ][ ulBase + kAES8420MiscControl1 ] )
			WriteControl( ulPort, ulBase + kAES8420MiscControl1, ucMC1 );

		// Non-Audio
		ucCSBUF0 = Invert( m_aControlRegisters[ ulPort ][ ulBase + kAES8420CSBuffer ] );
		if( ulStatus & MIXVAL_OUTSTATUS_NONAUDIO )
			SET( ucCSBUF0, MIXVAL_DCS_BYTE0_NONPCM );
		else
			CLR( ucCSBUF0, MIXVAL_DCS_BYTE0_NONPCM );

		// Emphasis
		if( ucCSBUF0 & MIXVAL_DCS_BYTE0_PRO )
		{
			CLR( ucCSBUF0, MIXVAL_DCS_PRO_BYTE0_EMPH_MASK );
			switch( ulStatus & MIXVAL_OUTSTATUS_EMPHASIS_MASK )
			{
			default:
			case MIXVAL_OUTSTATUS_EMPHASIS_NONE:	SET( ucCSBUF0, MIXVAL_DCS_PRO_BYTE0_EMPH_NONE );		break;
			case MIXVAL_OUTSTATUS_EMPHASIS_5015:	SET( ucCSBUF0, MIXVAL_DCS_PRO_BYTE0_EMPH_5015 );		break;
			case MIXVAL_OUTSTATUS_EMPHASIS_J17:		SET( ucCSBUF0, MIXVAL_DCS_PRO_BYTE0_EMPH_CCITTJ17 );	break;
			}
		}
		else
		{
			if( ulStatus & MIXVAL_OUTSTATUS_EMPHASIS_5015 )
				SET( ucCSBUF0, MIXVAL_DCS_CON_BYTE0_EMPH_5015 );
			else
				CLR( ucCSBUF0, MIXVAL_DCS_CON_BYTE0_EMPH_5015 );
		}
		
		if( ucCSBUF0 != m_aControlRegisters[ ulPort ][ ulBase + kAES8420CSBuffer ] )
			WriteControl( ulPort, ulBase + kAES8420CSBuffer, Invert( ucCSBUF0 ) );
	}

	m_ulOutputStatus[ ulPort ][ ulTheChip ] = ulStatus;
	
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
ULONG	CHalLStream::AESGetOutputStatus( ULONG ulPort, ULONG ulTheChip )
/////////////////////////////////////////////////////////////////////////////
{
	return( m_ulOutputStatus[ ulPort ][ ulTheChip ] );
}

/////////////////////////////////////////////////////////////////////////////
ULONG	CHalLStream::AESGetInputStatus( ULONG ulPort, ULONG ulTheChip )
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulStatus = k8420_RxErr_UNLOCK;

	if( GetDeviceID( ulPort ) == REG_LSDEVID_LSAES )
	{
		switch( ulTheChip )
		{
		case k8420_A:	
			ulStatus = (ULONG)m_aStatusRegisters[ ulPort ][ kStatusRXERRA ] | 
					   (ULONG)m_aStatusRegisters[ ulPort ][ kStatusRXCSA ] << 8;
			break;
		case k8420_B:
			ulStatus = (ULONG)m_aStatusRegisters[ ulPort ][ kStatusRXERRB ] | 
					   (ULONG)m_aStatusRegisters[ ulPort ][ kStatusRXCSB ] << 8;
			break;
		case k8420_C:
			ulStatus = (ULONG)m_aStatusRegisters[ ulPort ][ kStatusRXERRC ] | 
					   (ULONG)m_aStatusRegisters[ ulPort ][ kStatusRXCSC ] << 8;
			break;
		case k8420_D:
			ulStatus = (ULONG)m_aStatusRegisters[ ulPort ][ kStatusRXERRD ] | 
					   (ULONG)m_aStatusRegisters[ ulPort ][ kStatusRXCSD ] << 8;
			break;
		}
	}
	
	return( ulStatus );
}

/////////////////////////////////////////////////////////////////////////////
ULONG	CHalLStream::AESGetSRCRatio( ULONG ulPort, ULONG ulTheChip )
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulSRCRatio = (1<<6);	// default to 1:1
	ULONG	ulSRCMode = AESGetSRCMode( ulPort, ulTheChip );

	if( AESGetInputStatus( ulPort, ulTheChip ) & k8420_RxErr_UNLOCK )
		return( 0 );

	if( (ulSRCMode == MIXVAL_AESSRCMODE_SRC_ON) || (ulSRCMode == MIXVAL_AESSRCMODE_SRC_ON_DIGOUT) )
	{
		switch( ulTheChip )
		{
		case k8420_A:	ulSRCRatio = (ULONG)m_aStatusRegisters[ ulPort ][ kStatusSRRA ];	break;
		case k8420_B:	ulSRCRatio = (ULONG)m_aStatusRegisters[ ulPort ][ kStatusSRRB ];	break;
		case k8420_C:	ulSRCRatio = (ULONG)m_aStatusRegisters[ ulPort ][ kStatusSRRC ];	break;
		case k8420_D:	ulSRCRatio = (ULONG)m_aStatusRegisters[ ulPort ][ kStatusSRRD ];	break;
		}
	}

	return( ulSRCRatio );
}

/////////////////////////////////////////////////////////////////////////////
ULONG	CHalLStream::AESGetInputSampleRate( ULONG ulPort, ULONG ulTheChip )
/////////////////////////////////////////////////////////////////////////////
{
	ULONG		ulValue = 0;
	(void) ulPort; (void)(ulTheChip);
/************** Rev NC Hardware cannot do this.... ***********************
	ULONG		ulCount, ulScale;
	LONGLONG	llReference;

	llReference	= 32000000;	// only this number needs to be 64 bit for the precision to be OK

	switch( ulTheChip )
	{
	case k8420_A:
		ulCount =	(ULONG)m_aStatusRegisters[ ulPort ][ kStatusFREQCNTA0 ] | 
					(ULONG)m_aStatusRegisters[ ulPort ][ kStatusFREQCNTA1 ] << 8;
		ulScale =	(ULONG)m_aStatusRegisters[ ulPort ][ kStatusFREQSCALEA ];
		break;
	case k8420_B:
		ulCount =	(ULONG)m_aStatusRegisters[ ulPort ][ kStatusFREQCNTB0 ] | 
					(ULONG)m_aStatusRegisters[ ulPort ][ kStatusFREQCNTB1 ] << 8;
		ulScale =	(ULONG)m_aStatusRegisters[ ulPort ][ kStatusFREQSCALEB ];
		break;
	case k8420_C:
		ulCount =	(ULONG)m_aStatusRegisters[ ulPort ][ kStatusFREQCNTC0 ] | 
					(ULONG)m_aStatusRegisters[ ulPort ][ kStatusFREQCNTC1 ] << 8;
		ulScale =	(ULONG)m_aStatusRegisters[ ulPort ][ kStatusFREQSCALEC ];
		break;
	case k8420_D:
		ulCount =	(ULONG)m_aStatusRegisters[ ulPort ][ kStatusFREQCNTD0 ] | 
					(ULONG)m_aStatusRegisters[ ulPort ][ kStatusFREQCNTD1 ] << 8;
		ulScale =	(ULONG)m_aStatusRegisters[ ulPort ][ kStatusFREQSCALED ];
		break;
	}

	if( ulCount )
	{
		//DPF(("%5ld %ld ", ulCount, ulScale ));

		// Range of SCALE is 0..9, but we allow 0..15
		// by using a LONGLONG as the llReference, the intermediate number is 64 bit
		// We add ulCount/2 for rounding
		ulValue = (ULONG)(((llReference<<(ulScale+2))+(ulCount/2)) / ulCount);
		ulValue /= 128;	// The Digital Input is 128x
		if( ulValue < MIN_SAMPLE_RATE )
			ulValue = 0;
	}
************** Rev NC Hardware cannot do this.... ***********************/

	return( ulValue );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalLStream::AESSetWideWire( ULONG ulPort, ULONG ulWideWire )
/////////////////////////////////////////////////////////////////////////////
{
	ulPort &= 0x1;
	ulWideWire &= 0x1;

	if( ulWideWire )
	{
		WriteControl( ulPort, kControlDEVCTL, REG_DEVCTL_WIDEWIRE, REG_DEVCTL_WIDEWIRE );
	}
	else
	{
		WriteControl( ulPort, kControlDEVCTL, 0, REG_DEVCTL_WIDEWIRE );
	}

	m_ulWideWire[ ulPort ] = ulWideWire;
	
	// Now that the global is changed, refresh the channel status for all ports
	AESSetFormat( ulPort, k8420_A, AESGetFormat( ulPort, k8420_A ) );
	AESSetFormat( ulPort, k8420_B, AESGetFormat( ulPort, k8420_B ) );
	AESSetFormat( ulPort, k8420_C, AESGetFormat( ulPort, k8420_C ) );
	AESSetFormat( ulPort, k8420_D, AESGetFormat( ulPort, k8420_D ) );
	
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
ULONG	CHalLStream::AESGetWideWire( ULONG ulPort )
/////////////////////////////////////////////////////////////////////////////
{
	return( m_ulWideWire[ ulPort ] );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalLStream::Service( BOOLEAN bPolled )
// The LStream device has put items in the Status FIFO that need to be read
// Called at interrupt time (not in the DPC), so this cannot call any other
// functions besides CHalRegister::Read()
/////////////////////////////////////////////////////////////////////////////
{
	USHORT	Status = HSTATUS_OK;
	BOOLEAN	bEmpty = FALSE;
	ULONG	ulValue, ulData, ulReg, ulPort;

	if( bPolled )
		 bEmpty = m_RegOPBUFSTAT.Read() & REG_OPBUFSTAT_STAT_EMPTY ? TRUE : FALSE;

	//DB('l',COLOR_BOLD_U);
	//DPET();

	while( !bEmpty )
	{
		ulValue	= m_RegOPDEVSTAT.Read();
		
		ulData	= (ulValue & REG_OPDEVSTAT_DATA_MASK);
		ulReg	= (ulValue & REG_OPDEVSTAT_ADDR_MASK) >> REG_OPDEVSTAT_ADDR_OFFSET;
		ulPort	= (ulValue & REG_OPDEVSTAT_PORT) >> REG_OPDEVSTAT_PORT_OFFSET;

		//DPF(("[Status %08lx %02lx %02lx %02lx ] ", ulValue, ulPort, ulReg, ulData ));
		//DX8( (BYTE)ulReg, COLOR_NORMAL ); DC(':'); DX8( (BYTE)ulData, COLOR_NORMAL ); DC(' ');

		m_aStatusRegisters[ ulPort ][ ulReg ] = (BYTE)ulData;

		// If we haven't already, make sure the device is initialized
		if( (ulReg == kStatusLSDEVID) && (ulData != 0) )
		{
			// is the LStream device requesting initialization?
			if( (BYTE)ulData & kBit7 )
			{
				CLR( m_aStatusRegisters[ ulPort ][ ulReg ], kBit7 );
				m_bInitialized[ ulPort ] = FALSE;
			}

			if( !m_bInitialized[ ulPort ] )
				InitializeDevice( ulPort );
		}

		// If this register is for the LS-ADAT, handle any special functions now
		if( m_aStatusRegisters[ ulPort ][ kStatusLSDEVID ] == REG_LSDEVID_LSADAT )
		{
#ifdef DEBUG
			if( ulReg == kStatusADATSTAT )
				DX8( (BYTE)ulData, COLOR_BOLD );
#endif

			// if this is SYNCIN MIDI data, then inform the MIDI port to send the appropriate data
			if( ulReg == kStatusSYNCIN && m_pMIDIRecord->IsRunning() )	// should only come in if SYNCIN is enable along with interrupts...
			{
				//DX8( (BYTE)ulData, COLOR_BOLD );
				m_pMIDIRecord->AddByteToBuffer( (BYTE)ulData );
				Status = HSTATUS_MIDI2_SERVICE_REQUIRED;
			}

			//if( ulReg == kStatusSYNCTC3 )
			//{
			//	ULONG	ulTimecode;
			//	ADATGetSyncInTimeCode( ulPort, &ulTimecode );
			//	DPF((" %08lx ", ulTimecode ));
			//}

			// if we just received a complete timecode interrupt, and MTC is turned on, 
			// let the MIDI port know it needs to send the QFM
			if( (ulReg == kStatusSYNCTC3) && m_bEnableMTC[ ulPort ] )
			{
				Status = HSTATUS_MIDI1_SERVICE_REQUIRED;
			}
		}

		// If this register is for the LS-AES, handle any special functions now
		//if( m_aStatusRegisters[ ulPort ][ kStatusLSDEVID ] == REG_LSDEVID_LSAES )
		//{
			//if( (ulReg == kStatusLSDEVID) && (m_aStatusRegisters[ ulPort ][ kStatusSRRA ] == 0) )
			//{
			//	WriteControl( ulPort, kControlLSREQ, REG_LSREQ_REQSINGLE | kStatusSRRA );
			//}
		//}

		if( ulValue & REG_OPDEVSTAT_STAT_EMPTY )
			bEmpty = TRUE;
	}

	return( Status );
}
