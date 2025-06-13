/****************************************************************************
 Hal4114.cpp

 Description:	Lynx Application Programming Interface Header File

 Created: David A. Hoatson, June 2003
	
 Copyright © 2003 Lynx Studio Technology, Inc.

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

#ifndef LINUX
#include <StdAfx.h>
#endif
#include "HalAdapter.h"

/////////////////////////////////////////////////////////////////////////////
USHORT	CHal4114::Open( PHALADAPTER pHalAdapter )
/////////////////////////////////////////////////////////////////////////////
{
	PLYNXTWOREGISTERS	pRegisters = pHalAdapter->GetRegisters();

	// save the pointer to the parent adapter object
	m_pHalAdapter	= pHalAdapter;
	m_usDeviceID	= pHalAdapter->GetDeviceID();

	m_RegVCXOCTL.Init( &pRegisters->VCXOCTL );				// Setting an initial value in Init doesn't do a write to hardware
	m_RegVCXOCTLRead.Init( &pRegisters->VCXOCTL );			// Setting an initial value in Init doesn't do a write to hardware
	m_RegMISCTL.Init( &pRegisters->MISCTL, REG_WRITEONLY );	// Setting an initial value in Init doesn't do a write to hardware
	m_RegMISCTL.Write( REG_MISCTL_AESPDn | REG_MISCTL_CSINIT );

	for( ULONG ulTheChip = kChip1; ulTheChip < kNumberOf4114Chips; ulTheChip++ )
	{
		m_pRegAK4114Control[ ulTheChip ]	= &pRegisters->AESBlock.AK4114Control[ ulTheChip ];
		m_pRegAK4114Status[ ulTheChip ]		= &pRegisters->AESBlock.AK4114Status[ ulTheChip ];

		// enable the chips and take them out of power down mode
		// Turn on the PLL, Clock Source is X'tal
		m_ulClkPwr[ ulTheChip ] = REG_CLKPWR_RSTN | REG_CLKPWR_PWN | REG_CLKPWR_OCKS_MODE3 | REG_CLKPWR_BCU | REG_CLKPWR_CM_MODE0 | REG_CLKPWR_OUTPUT_VALID;
		WRITE_REGISTER_ULONG( &m_pRegAK4114Control[ ulTheChip ]->CLKPWR, REG_AK4114CTL_WREQ | m_ulClkPwr[ ulTheChip ] );
		
		m_ulFmtDEmp[ ulTheChip ] = REG_FMTDEMP_DIF_SLAVE;
		WRITE_REGISTER_ULONG( &m_pRegAK4114Control[ ulTheChip ]->FMTDEMP, REG_AK4114CTL_WREQ | m_ulFmtDEmp[ ulTheChip ] );

		// set the default to VALID, PCM & No EMPHASIS
		m_ulOutputStatus[ ulTheChip ] = MIXVAL_OUTSTATUS_VALID;
	}

	// This turns off the CSINIT bit
	m_RegMISCTL.Write( REG_MISCTL_AESPDn );

	SetDefaults();

	// Init the CS Transmit Data
	LONG	lRate, lSource, lReference;
	m_pHalAdapter->GetSampleClock()->Get( &lRate, &lSource, &lReference );
	SampleClockChanged( lRate, lSource );

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHal4114::Close()
/////////////////////////////////////////////////////////////////////////////
{
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHal4114::SetDefaults( void )
/////////////////////////////////////////////////////////////////////////////
{
	SetSynchroLock( TRUE );
	SetWideWireIn( FALSE );
	SetWideWireOut( FALSE );

	if( m_usDeviceID == PCIDEVICE_LYNX_AES16SRC )
	{
		m_RegMISCTL.BitSet( REG_MISCTL_SRCEN_0 | REG_MISCTL_SRCEN_1 | REG_MISCTL_SRCEN_2 | REG_MISCTL_SRCEN_3, FALSE );
	}

	m_bSRCEnable[ kSRC0 ] = FALSE;
	m_bSRCEnable[ kSRC1 ] = FALSE;
	m_bSRCEnable[ kSRC2 ] = FALSE;
	m_bSRCEnable[ kSRC3 ] = FALSE;

	SetSRCMatchPhase( FALSE );	// This will update the Master/Slave bits on the top four inputs

	for( ULONG ulTheChip = kChip1; ulTheChip < kNumberOf4114Chips; ulTheChip++ )
	{
		SetOutputStatus( ulTheChip, MIXVAL_OUTSTATUS_VALID );
	}

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHal4114::GetInputRate( ULONG ulTheChip, PLONG plRate )
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulRate;

	m_pHalAdapter->GetFrequencyCounter( AES16_FREQCOUNTER_DI1 + (USHORT)ulTheChip, &ulRate );

	m_pHalAdapter->NormalizeFrequency( ulRate, plRate );

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHal4114::GetInputStatus( ULONG ulTheChip, PULONG pulStatus )
/////////////////////////////////////////////////////////////////////////////
{
	USHORT	usRXSTAT10	= (USHORT)READ_REGISTER_ULONG( &m_pRegAK4114Status[ ulTheChip ]->RXSTAT10 );
	USHORT	usRXCS10	= (USHORT)READ_REGISTER_ULONG( &m_pRegAK4114Status[ ulTheChip ]->RXCS10 );
	//USHORT	usPREAMPD10	= (USHORT)READ_REGISTER_ULONG( &m_pRegAK4114Status[ ulTheChip ]->PREAMPD10 );
	ULONG	ulStatus = 0;
	BOOLEAN	bProfessional = (usRXCS10 & MIXVAL_DCS_BYTE0_PRO) ? TRUE : FALSE;

	//ULONG	ulReg = (ULONG)&m_pRegAK4114Status[ ulTheChip ]->RXSTAT10 - (ULONG)m_pHalAdapter->GetRegisters();
	//DX32( ulReg, COLOR_NORMAL );
	//DC(' ');
	//DX16( usRXSTAT10, COLOR_NORMAL );
	//DC(' ');

	// Non-Channel Status Related...
	if( usRXSTAT10 & REG_AK4114STAT0_PAR )
		SET( ulStatus, kInStatusErrParity );

	if( usRXSTAT10 & REG_AK4114STAT0_UNLCK )
		SET( ulStatus, kInStatusErrUnlock );

	if( usRXSTAT10 & REG_AK4114STAT1_CCRC )
		SET( ulStatus, kInStatusErrCSCRC );

	if( !(usRXSTAT10 & REG_AK4114STAT1_INVALID) )	// ON is Invalid
		SET( ulStatus, kInStatusValidity );

	if( bProfessional )
		SET( ulStatus, kInStatusProfessional );

	if( usRXSTAT10 & REG_AK4114STAT0_AUDION )
	{
		// NOTE: This may be IEC-60958 compatible ONLY
		USHORT	usPREAMPC10	= (USHORT)READ_REGISTER_ULONG( &m_pRegAK4114Status[ ulTheChip ]->PREAMPC10 );

		// Non PCM
		switch( usPREAMPC10 & REG_AK4114_RXCSPC_MASK )
		{
		default:
		case REG_AK4114_RXCSPC_NULL:		SET( ulStatus, kInStatusNonPCM );			break;
		case REG_AK4114_RXCSPC_DOLBYAC3:	SET( ulStatus, kInStatusNonPCMDolbyAC3 );	break;
		case REG_AK4114_RXCSPC_PAUSE:		SET( ulStatus, kInStatusNonPCMPause );		break;
		case REG_AK4114_RXCSPC_MPEG1_L1:	SET( ulStatus, kInStatusNonPCMMPEG1L1 );	break;
		case REG_AK4114_RXCSPC_MPEG1_L2:	SET( ulStatus, kInStatusNonPCMMPEG1L2 );	break;
		case REG_AK4114_RXCSPC_MPEG2:		SET( ulStatus, kInStatusNonPCMMPEG2 );		break;
		case REG_AK4114_RXCSPC_MPEG2_L1:	SET( ulStatus, kInStatusNonPCMMPEG2L1 );	break;
		case REG_AK4114_RXCSPC_MPEG2_L23:	SET( ulStatus, kInStatusNonPCMMPEG2L23 );	break;
		case REG_AK4114_RXCSPC_DTS_I:		SET( ulStatus, kInStatusNonPCMDTSI );		break;
		case REG_AK4114_RXCSPC_DTS_II:		SET( ulStatus, kInStatusNonPCMDTSII );		break;
		case REG_AK4114_RXCSPC_DTS_III:		SET( ulStatus, kInStatusNonPCMDTSIII );		break;
		case REG_AK4114_RXCSPC_ATRAC:		SET( ulStatus, kInStatusNonPCMATRAC );		break;
		case REG_AK4114_RXCSPC_ATRAC23:		SET( ulStatus, kInStatusNonPCMATRAC23 );	break;
		case REG_AK4114_RXCSPC_MPEG2_AAC:	SET( ulStatus, kInStatusNonPCMMPEG2AAC );	break;
		}
	}
	else
	{
		if( bProfessional )
		{
			USHORT	usRXCS32	= (USHORT)READ_REGISTER_ULONG( &m_pRegAK4114Status[ ulTheChip ]->RXCS32 );

			// PCM
			switch( usRXCS32 & MIXVAL_DCS_PRO_BYTE2_AUX_MASK )
			{
			case MIXVAL_DCS_PRO_BYTE2_AUX_UNDEFINED:
				switch( usRXCS32 & MIXVAL_DCS_PRO_BYTE2_AUXBITS_MASK )
				{
				default:								SET( ulStatus, kInStatusPCM );		break;	// word length not indicated
				case MIXVAL_DCS_PRO_BYTE2_AUX_U19BITS:	SET( ulStatus, kInStatusPCM19 );	break;
				case MIXVAL_DCS_PRO_BYTE2_AUX_U18BITS:	SET( ulStatus, kInStatusPCM18 );	break;
				case MIXVAL_DCS_PRO_BYTE2_AUX_U16BITS:	SET( ulStatus, kInStatusPCM16 );	break;
				case MIXVAL_DCS_PRO_BYTE2_AUX_U20BITS:	SET( ulStatus, kInStatusPCM20 );	break;
				}
				break;
			case MIXVAL_DCS_PRO_BYTE2_AUX_MAIN24:
				switch( usRXCS32 & MIXVAL_DCS_PRO_BYTE2_AUXBITS_MASK )
				{
				default:								SET( ulStatus, kInStatusPCM );		break;	// word length not indicated
				case MIXVAL_DCS_PRO_BYTE2_AUX_23BITS:	SET( ulStatus, kInStatusPCM23 );	break;
				case MIXVAL_DCS_PRO_BYTE2_AUX_22BITS:	SET( ulStatus, kInStatusPCM22 );	break;
				case MIXVAL_DCS_PRO_BYTE2_AUX_20BITS:	SET( ulStatus, kInStatusPCM20 );	break;
				case MIXVAL_DCS_PRO_BYTE2_AUX_24BITS:	SET( ulStatus, kInStatusPCM24 );	break;
				}
				break;
			}
		}
		else
		{
			SET( ulStatus, kInStatusPCM );
		}
	}

	if( usRXSTAT10 & REG_AK4114STAT0_PEM )
	{
		if( bProfessional )
		{
			// Determine the type of preemphasis
			switch( usRXCS10 & MIXVAL_DCS_PRO_BYTE0_EMPH_MASK )
			{
			case MIXVAL_DCS_PRO_BYTE0_EMPH_UNKNOWN:		SET( ulStatus, kInStatusEmphUnknown );	break;
			case MIXVAL_DCS_PRO_BYTE0_EMPH_NONE:		SET( ulStatus, kInStatusEmphNone );		break;
			case MIXVAL_DCS_PRO_BYTE0_EMPH_5015:		SET( ulStatus, kInStatusEmph5015 );		break;
			case MIXVAL_DCS_PRO_BYTE0_EMPH_CCITTJ17:	SET( ulStatus, kInStatusEmphCCITTJ17 );	break;
			}
		}
		else
		{
			// In consumer mode, 50/15us is all that is available
			SET( ulStatus, kInStatusEmph5015 );
		}
	}

	switch( usRXSTAT10 & REG_AK4114STAT1_FS_MASK )
	{
	case REG_AK4114STAT1_FS_32000:	SET( ulStatus, kInStatusSR32000 );	break;
	case REG_AK4114STAT1_FS_44100:	SET( ulStatus, kInStatusSR44100 );	break;
	case REG_AK4114STAT1_FS_48000:	SET( ulStatus, kInStatusSR48000 );	break;
	case REG_AK4114STAT1_FS_88200:	SET( ulStatus, kInStatusSR88200 );	break;
	case REG_AK4114STAT1_FS_96000:	SET( ulStatus, kInStatusSR96000 );	break;
	case REG_AK4114STAT1_FS_176400:	SET( ulStatus, kInStatusSR176400 );	break;
	case REG_AK4114STAT1_FS_192000:	SET( ulStatus, kInStatusSR192000 );	break;
	default:
		if( bProfessional )
		{
			USHORT	usRXCS4		= (USHORT)READ_REGISTER_ULONG( &m_pRegAK4114Status[ ulTheChip ]->RXCS4 );
			// the receiver was unable to decode the sample rate, let's see if we can do it ourselves
			switch( usRXCS4 & MIXVAL_DCS_PRO_BYTE4_FS_MASK )
			{
			case MIXVAL_DCS_PRO_BYTE4_FS_22050:	SET( ulStatus, kInStatusSR22050 );	break;
			case MIXVAL_DCS_PRO_BYTE4_FS_24000:	SET( ulStatus, kInStatusSR24000 );	break;
			}
		}
		break;
	}

	*pulStatus = ulStatus;

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
BOOLEAN	CHal4114::IsInputLocked( ULONG ulTheChip )
/////////////////////////////////////////////////////////////////////////////
{
	USHORT	usRXSTAT10	= (USHORT)READ_REGISTER_ULONG( &m_pRegAK4114Status[ ulTheChip ]->RXSTAT10 );

	if( usRXSTAT10 & REG_AK4114STAT0_UNLCK )
		return( FALSE );

	return( TRUE );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHal4114::GetSRCEnable( ULONG ulTheChip, PULONG pulEnable )
/////////////////////////////////////////////////////////////////////////////
{
	if( m_usDeviceID != PCIDEVICE_LYNX_AES16SRC )
		return( HSTATUS_INVALID_MIXER_CONTROL );

	*pulEnable = m_bSRCEnable[ ulTheChip ];

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHal4114::SetSRCEnable( ULONG ulTheChip, ULONG ulEnable )
// NOTE: When the SRC is enabled, the transmitter associated with that input
// goes dead.
/////////////////////////////////////////////////////////////////////////////
{
	if( m_usDeviceID != PCIDEVICE_LYNX_AES16SRC )
		return( HSTATUS_INVALID_MIXER_CONTROL );

	m_bSRCEnable[ ulTheChip ] = (BOOLEAN)ulEnable;	// This must be set before calling SetSRCMatchPhase or SetMasterSlave

	m_RegMISCTL.BitSet( (REG_MISCTL_SRCEN_0 << ulTheChip), (BOOLEAN)ulEnable );

	// if we just changed SRC0, update the match phase
	if( ulTheChip == kSRC0 )
	{
		SetSRCMatchPhase( m_bSRCMatchPhaseMixer );
		// let the world know about the change
		m_pHalAdapter->GetMixer()->ControlChanged( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_DIGITALIN_SRC_MATCHPHASE );
	}
	else
	{
		// Only need to update the Master/Slave bits if we didn't change the SRCMatchPhase
		SetMasterSlave( 4 + ulTheChip );
	}

	return( HSTATUS_OK );
}

#define SRCRATIO_SCALE	10000L		// 5 digits of precision
#define SRCRATIO_NORMAL	0x10000		// 1:1

/////////////////////////////////////////////////////////////////////////////
USHORT	CHal4114::GetSRCRatio( ULONG ulTheChip, PULONG pulSRCRatio )
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulLRClock, ulDigitalIn, ulSRCRatio = 0;

	if( m_usDeviceID != PCIDEVICE_LYNX_AES16SRC )
		return( HSTATUS_INVALID_MIXER_CONTROL );

	// if the SRC Enable is OFF, then the SRC Ratio should be 0
	if( m_bSRCEnable[ ulTheChip ] )
	{
		m_pHalAdapter->GetFrequencyCounter( AES16_FREQCOUNTER_DI5 + (USHORT)ulTheChip, &ulDigitalIn );	// this will return 0 if the input is unlocked

		// The ratio is LRClock / DigitalIn
		// This is returned as a 16:16 fixed point number
		if( ulDigitalIn )
		{
			m_pHalAdapter->GetFrequencyCounter( AES16_FREQCOUNTER_LRCLOCK, &ulLRClock );
			ulSRCRatio = (((ulLRClock * SRCRATIO_SCALE) / ulDigitalIn) * SRCRATIO_NORMAL) / SRCRATIO_SCALE;
		}
	}

	*pulSRCRatio = ulSRCRatio;

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHal4114::SetSRCMatchPhase( ULONG ulSRCMatchPhase )
/////////////////////////////////////////////////////////////////////////////
{
	m_bSRCMatchPhaseMixer = (BOOLEAN)ulSRCMatchPhase;

	// SRC0 must be ON for Match Phase to do anything
	if( !m_bSRCEnable[ kSRC0 ] )
		m_bSRCMatchPhase = FALSE;
	else
		m_bSRCMatchPhase = m_bSRCMatchPhaseMixer;

	m_RegMISCTL.BitSet( REG_MISCTL_MPHASE, m_bSRCMatchPhase );

	// Update the Master/Slave on all four SRC Inputs
	for( ULONG ulTheChip = kChip5; ulTheChip < kNumberOf4114Chips; ulTheChip++ )
	{
		SetMasterSlave( ulTheChip );
	}

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHal4114::GetSRCMatchPhase( PULONG pulSRCMatchPhase )
/////////////////////////////////////////////////////////////////////////////
{
	if( m_usDeviceID != PCIDEVICE_LYNX_AES16SRC )
		return( HSTATUS_INVALID_MIXER_CONTROL );

	*pulSRCMatchPhase = m_bSRCMatchPhase;

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHal4114::GetOutputStatus( ULONG ulTheChip, PULONG pulStatus )
/////////////////////////////////////////////////////////////////////////////
{
	*pulStatus = m_ulOutputStatus[ ulTheChip ];

	return( HSTATUS_OK );
}

BYTE	Invert( BYTE ucIn );	// in Hal8420.h

/////////////////////////////////////////////////////////////////////////////
BYTE	CalculateCSCRCC( PBYTE pucChannelStatus )
/////////////////////////////////////////////////////////////////////////////
{
	USHORT	usCRCC;
	USHORT	usBit0, usBit2, usBit3, usBit4;
	BYTE	ucByte;
	int		byte, bit;

	//  initialize the CRCC
	usCRCC = 0x1FF;

	//  for each of the 23 channel-status array bytes
	for( byte=0; byte<23; byte++ )
	{
		ucByte = *pucChannelStatus++;
		//DPF(("%02x ", ucByte ));

		// go through each bit of the byte
		for( bit=0; bit<8; bit++ )
		{
			//  shift the CRCC left by 1 bit, this clears bit 0
			usCRCC <<= 1;

			//  fill the LSB of the CRCC
			usBit0 = ((usCRCC & kBit8) >> 8) ^ (ucByte & kBit0);	// only bit 0 has a value
			//  and apply the XOR taps ...
			usBit4 = ((usCRCC & kBit4) >> 4) ^ usBit0;
			usBit3 = ((usCRCC & kBit3) >> 3) ^ usBit0;
			usBit2 = ((usCRCC & kBit2) >> 2) ^ usBit0;
			
			usCRCC &= 0xE2;	// clear bits 4, 3, 2 & 0
			usCRCC |= (usBit4 << 4) | (usBit3 << 3) | (usBit2 << 2) | usBit0;
			
			// shift the channel status byte down one so the next time around the bit we want is at zero
			ucByte >>= 1;
		}
	}

	// The channel status CRC goes out LSB first, so we must invert it here...
	usCRCC = Invert( (BYTE)usCRCC );
	//DPF(("CRCC %02x\n", (BYTE)usCRCC ));
	
	return( (BYTE)usCRCC );
}


/////////////////////////////////////////////////////////////////////////////
USHORT	CHal4114::SampleClockChanged( LONG lRate, LONG lSource )
// Called by CHalSampleClock when the clock rate is changed
/////////////////////////////////////////////////////////////////////////////
{
	RtlZeroMemory( &m_TxCBuffer, sizeof( m_TxCBuffer ) );

	// correct any code that isn't AES16 aware
	if( lSource < MIXVAL_AES16_CLKSRC_INTERNAL )
		lSource += MIXVAL_AES16_CLKSRC_INTERNAL;

	// Note: VCXOLOEN and VCXOHIEN bits are only used when the FPGA detects that the clock source is internal 
	switch( lRate )
	{
	case 44100:
	case 88200:
	case 176400:
		m_RegVCXOCTL.Write( REG_VCXOCTL_VCXOLOEN, (REG_VCXOCTL_VCXOLOEN | REG_VCXOCTL_VCXOHIEN) );
		break;
	case 48000:
	case 96000:
	case 192000:
		m_RegVCXOCTL.Write( REG_VCXOCTL_VCXOHIEN, (REG_VCXOCTL_VCXOLOEN | REG_VCXOCTL_VCXOHIEN) );
		break;
	default:
		m_RegVCXOCTL.Write( 0, (REG_VCXOCTL_VCXOLOEN | REG_VCXOCTL_VCXOHIEN) );	// turn both bits off
		break;
	}

	for( ULONG ulTheChip = 0; ulTheChip < kNumberOf4114Chips; ulTheChip++ )
	{
		/////////////////////////////////////////////////////////////////////

		SetMasterSlave( ulTheChip, lSource );

		/////////////////////////////////////////////////////////////////////

		m_TxCBuffer[ ulTheChip ][0]	= MIXVAL_DCS_BYTE0_PRO | MIXVAL_DCS_PRO_BYTE0_LOCKED;

		switch( m_ulOutputStatus[ ulTheChip ] & MIXVAL_OUTSTATUS_EMPHASIS_MASK )
		{
		default:
		case MIXVAL_OUTSTATUS_EMPHASIS_NONE:	SET( m_TxCBuffer[ ulTheChip ][0], MIXVAL_DCS_PRO_BYTE0_EMPH_NONE );		break;
		case MIXVAL_OUTSTATUS_EMPHASIS_5015:	SET( m_TxCBuffer[ ulTheChip ][0], MIXVAL_DCS_PRO_BYTE0_EMPH_5015 );		break;
		case MIXVAL_OUTSTATUS_EMPHASIS_J17:		SET( m_TxCBuffer[ ulTheChip ][0], MIXVAL_DCS_PRO_BYTE0_EMPH_CCITTJ17 );	break;
		}
		
		switch( lRate )
		{
		case 22050:		SET( m_TxCBuffer[ ulTheChip ][4], MIXVAL_DCS_PRO_BYTE4_FS_22050 );		break;	// not possible
		case 24000:		SET( m_TxCBuffer[ ulTheChip ][4], MIXVAL_DCS_PRO_BYTE4_FS_24000 );		break;	// not possible
		case 32000:		SET( m_TxCBuffer[ ulTheChip ][0], MIXVAL_DCS_PRO_BYTE0_FS_32000 );		break;
		case 44056:		SET( m_TxCBuffer[ ulTheChip ][0], MIXVAL_DCS_PRO_BYTE0_FS_44100 );
						SET( m_TxCBuffer[ ulTheChip ][4], MIXVAL_DCS_PRO_BYTE4_FS_PULLDOWN );	break;
		case 44100:		SET( m_TxCBuffer[ ulTheChip ][0], MIXVAL_DCS_PRO_BYTE0_FS_44100 );		break;
		case 48000:		SET( m_TxCBuffer[ ulTheChip ][0], MIXVAL_DCS_PRO_BYTE0_FS_48000 );		break;
		case 88200:		SET( m_TxCBuffer[ ulTheChip ][4], MIXVAL_DCS_PRO_BYTE4_FS_88200 );		break;
		case 96000:		SET( m_TxCBuffer[ ulTheChip ][4], MIXVAL_DCS_PRO_BYTE4_FS_96000 );		break;
		case 176400:	SET( m_TxCBuffer[ ulTheChip ][4], MIXVAL_DCS_PRO_BYTE4_FS_176400 );		break;
		case 192000:	SET( m_TxCBuffer[ ulTheChip ][4], MIXVAL_DCS_PRO_BYTE4_FS_192000 );		break;
		}

		// default to stereo mode.
		m_TxCBuffer[ ulTheChip ][1] = MIXVAL_DCS_PRO_BYTE1_CM_STEREO;
		
		// if wide wire is on and the sample rate is greater than 50kHz, then we are in dual-wire mode.
		if( (lRate > 50000) && m_bWideWireOut )
		{
			if( (ulTheChip == kChip1) || (ulTheChip == kChip3) || (ulTheChip == kChip5) || (ulTheChip == kChip7) )
			{
				// left channel
				m_TxCBuffer[ ulTheChip ][1] = MIXVAL_DCS_PRO_BYTE1_CM_1CH_2SR_SML;
			}
			else
			{
				// right channel
				m_TxCBuffer[ ulTheChip ][1] = MIXVAL_DCS_PRO_BYTE1_CM_1CH_2SR_SMR;
			}
		}

		m_TxCBuffer[ ulTheChip ][2] = MIXVAL_DCS_PRO_BYTE2_AUX_MAIN24 | MIXVAL_DCS_PRO_BYTE2_AUX_24BITS;
		
		m_TxCBuffer[ ulTheChip ][6] = 'A';
		m_TxCBuffer[ ulTheChip ][7] = '1';
		m_TxCBuffer[ ulTheChip ][8] = '6';
		m_TxCBuffer[ ulTheChip ][9] = '1' + (BYTE)ulTheChip;

		if( m_ulOutputStatus[ ulTheChip ] & MIXVAL_OUTSTATUS_NONAUDIO )
			SET( m_TxCBuffer[ ulTheChip ][0], MIXVAL_DCS_BYTE0_NONPCM );

		m_TxCBuffer[ ulTheChip ][23] = CalculateCSCRCC( m_TxCBuffer[ ulTheChip ] );

		// Write the CS Data
		WRITE_REGISTER_ULONG( &m_pRegAK4114Control[ ulTheChip ]->TXCS10, MAKEWORD( m_TxCBuffer[ ulTheChip ][0], m_TxCBuffer[ ulTheChip ][1] ) );
		WRITE_REGISTER_ULONG( &m_pRegAK4114Control[ ulTheChip ]->TXCS32, MAKEWORD( m_TxCBuffer[ ulTheChip ][2], m_TxCBuffer[ ulTheChip ][3] ) );
		WRITE_REGISTER_ULONG( &m_pRegAK4114Control[ ulTheChip ]->TXCS54, MAKEWORD( m_TxCBuffer[ ulTheChip ][4], m_TxCBuffer[ ulTheChip ][5] ) );
		WRITE_REGISTER_ULONG( &m_pRegAK4114Control[ ulTheChip ]->TXCS76, MAKEWORD( m_TxCBuffer[ ulTheChip ][6], m_TxCBuffer[ ulTheChip ][7] ) );
		WRITE_REGISTER_ULONG( &m_pRegAK4114Control[ ulTheChip ]->TXCS98, MAKEWORD( m_TxCBuffer[ ulTheChip ][8], m_TxCBuffer[ ulTheChip ][9] ) );
		WRITE_REGISTER_ULONG( &m_pRegAK4114Control[ ulTheChip ]->TXCS2322, MAKEWORD( m_TxCBuffer[ ulTheChip ][22], m_TxCBuffer[ ulTheChip ][23] ) );
	}

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHal4114::SetOutputStatus( ULONG ulTheChip, ULONG ulStatus )
/////////////////////////////////////////////////////////////////////////////
{
	m_ulOutputStatus[ ulTheChip ] = ulStatus;

	// Validity
	if( ulStatus & MIXVAL_OUTSTATUS_VALID )
		CLR( m_ulClkPwr[ ulTheChip ], REG_CLKPWR_OUTPUT_VALID );	// Set the Validity Bit
	else
		SET( m_ulClkPwr[ ulTheChip ], REG_CLKPWR_OUTPUT_VALID );	// Clear the Validity Bit
	WRITE_REGISTER_ULONG( &m_pRegAK4114Control[ ulTheChip ]->CLKPWR, REG_AK4114CTL_WREQ | m_ulClkPwr[ ulTheChip ] );

	// Non-Audio
	if( ulStatus & MIXVAL_OUTSTATUS_NONAUDIO )
		SET( m_TxCBuffer[ ulTheChip ][0], MIXVAL_DCS_BYTE0_NONPCM );
	else
		CLR( m_TxCBuffer[ ulTheChip ][0], MIXVAL_DCS_BYTE0_NONPCM );

	// Emphasis
	CLR( m_TxCBuffer[ ulTheChip ][0], MIXVAL_DCS_PRO_BYTE0_EMPH_MASK );
	switch( ulStatus & MIXVAL_OUTSTATUS_EMPHASIS_MASK )
	{
	default:
	case MIXVAL_OUTSTATUS_EMPHASIS_NONE:	SET( m_TxCBuffer[ ulTheChip ][0], MIXVAL_DCS_PRO_BYTE0_EMPH_NONE );		break;
	case MIXVAL_OUTSTATUS_EMPHASIS_5015:	SET( m_TxCBuffer[ ulTheChip ][0], MIXVAL_DCS_PRO_BYTE0_EMPH_5015 );		break;
	case MIXVAL_OUTSTATUS_EMPHASIS_J17:		SET( m_TxCBuffer[ ulTheChip ][0], MIXVAL_DCS_PRO_BYTE0_EMPH_CCITTJ17 );	break;
	}

	// write just the CS0&1 register
	WRITE_REGISTER_ULONG( &m_pRegAK4114Control[ ulTheChip ]->TXCS10, MAKEWORD( m_TxCBuffer[ ulTheChip ][0], m_TxCBuffer[ ulTheChip ][1] ) );

	// calculate the new CRCC
	m_TxCBuffer[ ulTheChip ][23] = CalculateCSCRCC( m_TxCBuffer[ ulTheChip ] );
	// and write it out too
	WRITE_REGISTER_ULONG( &m_pRegAK4114Control[ ulTheChip ]->TXCS2322, MAKEWORD( m_TxCBuffer[ ulTheChip ][22], m_TxCBuffer[ ulTheChip ][23] ) );

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHal4114::SetSynchroLock( ULONG ulEnable )
/////////////////////////////////////////////////////////////////////////////
{
	m_bSynchroLock = ulEnable ? TRUE : FALSE;
	m_RegVCXOCTL.BitSet( REG_VCXOCTL_SLOCK, m_bSynchroLock );
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHal4114::GetSynchroLock( PULONG pulEnable )
/////////////////////////////////////////////////////////////////////////////
{
	*pulEnable = m_bSynchroLock;
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHal4114::GetSynchroLockStatus( PULONG pulStatus )
/////////////////////////////////////////////////////////////////////////////
{
	*pulStatus = m_RegVCXOCTLRead.Read();
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHal4114::SetWideWireIn( ULONG ulEnable )
/////////////////////////////////////////////////////////////////////////////
{
	LONG	lRate;
	PHALSAMPLECLOCK pClock = m_pHalAdapter->GetSampleClock();

	m_bWideWireIn = (BOOLEAN)ulEnable;
	//DPF(("WideWire %lu\n", (ULONG)m_bWideWire ));
	m_RegMISCTL.BitSet( REG_MISCTL_WIDEWIREIN, m_bWideWireIn );
	
	// Need to call CHalSampleClock::Set...
	pClock->Get( &lRate );
	pClock->Set( lRate, TRUE );
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHal4114::GetWideWireIn( PULONG pulEnable )
/////////////////////////////////////////////////////////////////////////////
{
	*pulEnable = m_bWideWireIn;
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHal4114::SetWideWireOut( ULONG ulEnable )
/////////////////////////////////////////////////////////////////////////////
{
	LONG	lRate;
	PHALSAMPLECLOCK pClock = m_pHalAdapter->GetSampleClock();

	m_bWideWireOut = (BOOLEAN)ulEnable;
	//DPF(("WideWire %lu\n", (ULONG)m_bWideWire ));
	m_RegMISCTL.BitSet( REG_MISCTL_WIDEWIREOUT, m_bWideWireOut );
	
	// Need to call CHalSampleClock::Set...
	pClock->Get( &lRate );
	pClock->Set( lRate, TRUE );
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHal4114::GetWideWireOut( PULONG pulEnable )
/////////////////////////////////////////////////////////////////////////////
{
	if( !m_pHalAdapter->HasWideWireOut() )
		return( HSTATUS_INVALID_MIXER_CONTROL );

	*pulEnable = m_bWideWireOut;
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
void	CHal4114::SetMasterSlave( ULONG ulTheChip, LONG lSource )
// Private
// NOTE: lSource is only used if ulTheChip is kChip1 to kChip4.
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulFmtDEmp = m_ulFmtDEmp[ ulTheChip ];
	(void) lSource; // avoid compiler warnings about unused params..

	CLR( ulFmtDEmp, REG_FMTDEMP_DIF_MASK );

	// is this digital input the master clock or is SRC on?
	if( ulTheChip < 4 )
	{
		/*
		// only the first for chips can be the clock source
		if( lSource == (MIXVAL_AES16_CLKSRC_DIGITAL_0 + (long)ulTheChip) )
		{
			DPF(("MASTER on %d\n", ulTheChip+1 ));
			SET( ulFmtDEmp, REG_FMTDEMP_DIF_MASTER );	// LRCK is an output
		}
		else
		*/
		//{
			//DPF(("SLAVE on %d\n", ulTheChip+1 ));
			SET( ulFmtDEmp, REG_FMTDEMP_DIF_SLAVE );		// LRCK is an input
		//}
	}
	else
	{
		// only the last four chips have an SRC
		if( m_bSRCEnable[ ulTheChip-4 ] )
		{
			// if Match Phase is on, then we must be in SLAVE mode (except for kChip5)
			if( m_bSRCMatchPhase && (ulTheChip != kChip5) )
			{
				//DPF(("SLAVE on %d (MatchPhase)\n", ulTheChip+1 ));
				SET( ulFmtDEmp, REG_FMTDEMP_DIF_SLAVE );		// LRCK is an input
			}
			else
			{
				//DPF(("MASTER on %d\n", ulTheChip+1 ));
				SET( ulFmtDEmp, REG_FMTDEMP_DIF_MASTER );	// LRCK is an output
			}
		}
		else
		{
			//DPF(("SLAVE on %d\n", ulTheChip+1 ));
			SET( ulFmtDEmp, REG_FMTDEMP_DIF_SLAVE );		// LRCK is an input
		}
	}

	// Only write this register if something has changed
	if( ulFmtDEmp != m_ulFmtDEmp[ ulTheChip ] )
	{
		m_ulFmtDEmp[ ulTheChip ] = ulFmtDEmp;
		WRITE_REGISTER_ULONG( &m_pRegAK4114Control[ ulTheChip ]->FMTDEMP, REG_AK4114CTL_WREQ | m_ulFmtDEmp[ ulTheChip ] );
	}
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHal4114::SetMixerControl( USHORT usControl, ULONG ulValue )
/////////////////////////////////////////////////////////////////////////////
{
	if( !((m_usDeviceID == PCIDEVICE_LYNX_AES16) || (m_usDeviceID == PCIDEVICE_LYNX_AES16SRC)) )
		return( HSTATUS_INVALID_MIXER_CONTROL );

	switch( usControl )
	{
	case CONTROL_WIDEWIREIN:			return( SetWideWireIn( ulValue ) );
	case CONTROL_WIDEWIREOUT:			return( SetWideWireOut( ulValue ) );
	case CONTROL_SYNCHROLOCK_ENABLE:	return( SetSynchroLock( ulValue ) );
	case CONTROL_DIGITALIN_SRC_MATCHPHASE:	return( SetSRCMatchPhase( ulValue ) );
	
	case CONTROL_DIGITALIN5_SRC_ENABLE:	return( SetSRCEnable( kSRC0, ulValue ) );
	case CONTROL_DIGITALIN6_SRC_ENABLE:	return( SetSRCEnable( kSRC1, ulValue ) );
	case CONTROL_DIGITALIN7_SRC_ENABLE:	return( SetSRCEnable( kSRC2, ulValue ) );
	case CONTROL_DIGITALIN8_SRC_ENABLE:	return( SetSRCEnable( kSRC3, ulValue ) );
	
	case CONTROL_DIGITALOUT1_STATUS:	return( SetOutputStatus( kChip1, ulValue ) );
	case CONTROL_DIGITALOUT2_STATUS:	return( SetOutputStatus( kChip2, ulValue ) );
	case CONTROL_DIGITALOUT3_STATUS:	return( SetOutputStatus( kChip3, ulValue ) );
	case CONTROL_DIGITALOUT4_STATUS:	return( SetOutputStatus( kChip4, ulValue ) );
	case CONTROL_DIGITALOUT5_STATUS:	return( SetOutputStatus( kChip5, ulValue ) );
	case CONTROL_DIGITALOUT6_STATUS:	return( SetOutputStatus( kChip6, ulValue ) );
	case CONTROL_DIGITALOUT7_STATUS:	return( SetOutputStatus( kChip7, ulValue ) );
	case CONTROL_DIGITALOUT8_STATUS:	return( SetOutputStatus( kChip8, ulValue ) );
	
	default:							return( HSTATUS_INVALID_MIXER_CONTROL );
	}
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHal4114::GetMixerControl( USHORT usControl, PULONG pulValue )
/////////////////////////////////////////////////////////////////////////////
{
	if( !((m_usDeviceID == PCIDEVICE_LYNX_AES16) || (m_usDeviceID == PCIDEVICE_LYNX_AES16SRC)) )
		return( HSTATUS_INVALID_MIXER_CONTROL );

	switch( usControl )
	{
	case CONTROL_WIDEWIREIN:			return( GetWideWireIn( pulValue ) );
	case CONTROL_WIDEWIREOUT:			return( GetWideWireOut( pulValue ) );
	case CONTROL_SYNCHROLOCK_ENABLE:	return( GetSynchroLock( pulValue ) );
	case CONTROL_SYNCHROLOCK_STATUS:	return( GetSynchroLockStatus( pulValue ) );
	case CONTROL_DIGITALIN_SRC_MATCHPHASE:	return( GetSRCMatchPhase( pulValue ) );
	
	case CONTROL_DIGITALIN5_SRC_ENABLE:	return( GetSRCEnable( kSRC0, pulValue ) );
	case CONTROL_DIGITALIN6_SRC_ENABLE:	return( GetSRCEnable( kSRC1, pulValue ) );
	case CONTROL_DIGITALIN7_SRC_ENABLE:	return( GetSRCEnable( kSRC2, pulValue ) );
	case CONTROL_DIGITALIN8_SRC_ENABLE:	return( GetSRCEnable( kSRC3, pulValue ) );

	case CONTROL_DIGITALIN5_SRC_RATIO:	return( GetSRCRatio( kSRC0, pulValue ) );
	case CONTROL_DIGITALIN6_SRC_RATIO:	return( GetSRCRatio( kSRC1, pulValue ) );
	case CONTROL_DIGITALIN7_SRC_RATIO:	return( GetSRCRatio( kSRC2, pulValue ) );
	case CONTROL_DIGITALIN8_SRC_RATIO:	return( GetSRCRatio( kSRC3, pulValue ) );

	case CONTROL_DIGITALIN1_RATE:		return( m_pHalAdapter->GetFrequencyCounter( AES16_FREQCOUNTER_DI1, pulValue ) );
	case CONTROL_DIGITALIN2_RATE:		return( m_pHalAdapter->GetFrequencyCounter( AES16_FREQCOUNTER_DI2, pulValue ) );
	case CONTROL_DIGITALIN3_RATE:		return( m_pHalAdapter->GetFrequencyCounter( AES16_FREQCOUNTER_DI3, pulValue ) );
	case CONTROL_DIGITALIN4_RATE:		return( m_pHalAdapter->GetFrequencyCounter( AES16_FREQCOUNTER_DI4, pulValue ) );
	case CONTROL_DIGITALIN5_RATE:		return( m_pHalAdapter->GetFrequencyCounter( AES16_FREQCOUNTER_DI5, pulValue ) );
	case CONTROL_DIGITALIN6_RATE:		return( m_pHalAdapter->GetFrequencyCounter( AES16_FREQCOUNTER_DI6, pulValue ) );
	case CONTROL_DIGITALIN7_RATE:		return( m_pHalAdapter->GetFrequencyCounter( AES16_FREQCOUNTER_DI7, pulValue ) );
	case CONTROL_DIGITALIN8_RATE:		return( m_pHalAdapter->GetFrequencyCounter( AES16_FREQCOUNTER_DI8, pulValue ) );

	case CONTROL_DIGITALIN1_STATUS:		return( GetInputStatus( kChip1, pulValue ) );
	case CONTROL_DIGITALIN2_STATUS:		return( GetInputStatus( kChip2, pulValue ) );
	case CONTROL_DIGITALIN3_STATUS:		return( GetInputStatus( kChip3, pulValue ) );
	case CONTROL_DIGITALIN4_STATUS:		return( GetInputStatus( kChip4, pulValue ) );
	case CONTROL_DIGITALIN5_STATUS:		return( GetInputStatus( kChip5, pulValue ) );
	case CONTROL_DIGITALIN6_STATUS:		return( GetInputStatus( kChip6, pulValue ) );
	case CONTROL_DIGITALIN7_STATUS:		return( GetInputStatus( kChip7, pulValue ) );
	case CONTROL_DIGITALIN8_STATUS:		return( GetInputStatus( kChip8, pulValue ) );

	case CONTROL_DIGITALOUT1_STATUS:	return( GetOutputStatus( kChip1, pulValue ) );
	case CONTROL_DIGITALOUT2_STATUS:	return( GetOutputStatus( kChip2, pulValue ) );
	case CONTROL_DIGITALOUT3_STATUS:	return( GetOutputStatus( kChip3, pulValue ) );
	case CONTROL_DIGITALOUT4_STATUS:	return( GetOutputStatus( kChip4, pulValue ) );
	case CONTROL_DIGITALOUT5_STATUS:	return( GetOutputStatus( kChip5, pulValue ) );
	case CONTROL_DIGITALOUT6_STATUS:	return( GetOutputStatus( kChip6, pulValue ) );
	case CONTROL_DIGITALOUT7_STATUS:	return( GetOutputStatus( kChip7, pulValue ) );
	case CONTROL_DIGITALOUT8_STATUS:	return( GetOutputStatus( kChip8, pulValue ) );

	default:							return( HSTATUS_INVALID_MIXER_CONTROL );
	}
	return( HSTATUS_OK );
}

