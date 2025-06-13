/****************************************************************************
 HalRecordMix.cpp

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
****************************************************************************/

#include <StdAfx.h>
#include "HalAdapter.h"

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalRecordMix::Open( PHALADAPTER pHalAdapter, PULONG pRecordMixCtl, PULONG pRecordMixStatus )
/////////////////////////////////////////////////////////////////////////////
{
	m_pHalAdapter = pHalAdapter;
	m_usDeviceID = m_pHalAdapter->GetDeviceID();
	m_RegMixControl.Init( pRecordMixCtl );
	m_RegMixStatus.Init( pRecordMixStatus );

	m_asSource	= 0;

	SetMute( FALSE );
	m_usDitherDepth = 24;
	SetDitherDepth( MIXVAL_DITHERDEPTH_AUTO );
	SetDither( FALSE );

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
ULONG	CHalRecordMix::GetLevel()
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulLevel = m_RegMixStatus.Read() & REG_RMIXSTAT_LEVEL_MASK;
	if( ulLevel > 0x7FFFF )
		ulLevel = 0x7FFFF;
	return( ulLevel );
}

/////////////////////////////////////////////////////////////////////////////
void	CHalRecordMix::ResetLevel()
/////////////////////////////////////////////////////////////////////////////
{
	m_RegMixStatus.BitSet( REG_RMIXSTAT_LEVEL_RESET, TRUE );
}

/////////////////////////////////////////////////////////////////////////////
void	CHalRecordMix::SetSource( USHORT usSource )
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulSource = usSource & REG_RMIX_INSRC_MASK;	// 0..7 & 32-63 are valid
	
	if( (m_usDeviceID == PCIDEVICE_LYNXTWO_A) || 
		(m_usDeviceID == PCIDEVICE_LYNXTWO_B) || 
		(m_usDeviceID == PCIDEVICE_LYNXTWO_C) || 
		(m_usDeviceID == PCIDEVICE_LYNX_L22) )
	{
		if( ulSource > 7 )
			ulSource +=	24;		// 8 == 32
	}
	else	// AES16
	{
		if( ulSource > 15 )
			ulSource += 16;		// 16 == 32, 32-47
	}

	m_RegMixControl.Write( (ulSource << REG_RMIX_INSRC_OFFSET), REG_RMIX_INSRC_MASK );
	m_asSource = usSource;
}

/////////////////////////////////////////////////////////////////////////////
void	CHalRecordMix::SetMute( BOOLEAN bMute )
/////////////////////////////////////////////////////////////////////////////
{
	m_bMute = bMute ? TRUE : FALSE;
	m_RegMixControl.BitSet( REG_RMIX_MUTE, m_bMute );
}

/////////////////////////////////////////////////////////////////////////////
void	CHalRecordMix::SetDitherDepth( USHORT usDitherDepth )
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulDitherDepth = 0;

	// if this call from the driver trying to set the dither depth and the current setting isn't auto, ignore
	if( (usDitherDepth > MIXVAL_DITHERDEPTH_COUNT) && (m_usDitherControl != MIXVAL_DITHERDEPTH_AUTO) )
	{
		m_usDitherDepth = usDitherDepth;	// remember for later...
		return;
	}

	// handle the dither depth control changes from the user
	switch( usDitherDepth )
	{
	case MIXVAL_DITHERDEPTH_AUTO:
		// The user wants the driver to select the dither depth.  
		// Next time this device gets started the dither depth will get set.
		m_usDitherControl = usDitherDepth;
		usDitherDepth = m_usDitherDepth;	// saved from above...
		break;
	case MIXVAL_DITHERDEPTH_8BIT:
		m_usDitherControl = usDitherDepth;
		usDitherDepth = 8;
		break;
	case MIXVAL_DITHERDEPTH_16BIT:
		m_usDitherControl = usDitherDepth;
		usDitherDepth = 16;
		break;
	case MIXVAL_DITHERDEPTH_20BIT:
		m_usDitherControl = usDitherDepth;
		usDitherDepth = 20;
		break;
	case MIXVAL_DITHERDEPTH_24BIT:	// Dither is off
		m_usDitherControl = usDitherDepth;
		usDitherDepth = 24;
		break;
	}
	// We don't update m_usDitherControl if the call came from the driver.
	
	switch( usDitherDepth )
	{
	case 8:		ulDitherDepth = REG_RMIX_DITHERDEPTH_8BITS;		break;
	case 16:	ulDitherDepth = REG_RMIX_DITHERDEPTH_16BITS;	break;
	case 20:	ulDitherDepth = REG_RMIX_DITHERDEPTH_20BITS;	break;
	default:
	case 24:
		ulDitherDepth = REG_RMIX_DITHERDEPTH_24BITS;	
		m_usDitherDepth = 24;
		break;
	}

	m_RegMixControl.Write( ulDitherDepth, REG_RMIX_DITHERDEPTH_MASK );
	SetDither( m_bDither );	// update the dither on/off status
}

/////////////////////////////////////////////////////////////////////////////
void	CHalRecordMix::SetDither( BOOLEAN bDither )
/////////////////////////////////////////////////////////////////////////////
{
	m_bDither = bDither ? TRUE : FALSE;

	// if the dither depth is 24, turn off dither in the hardware
	if( m_usDitherDepth == 24 )
		m_RegMixControl.BitSet( REG_RMIX_DITHER, FALSE );
	else
		m_RegMixControl.BitSet( REG_RMIX_DITHER, m_bDither );
}
