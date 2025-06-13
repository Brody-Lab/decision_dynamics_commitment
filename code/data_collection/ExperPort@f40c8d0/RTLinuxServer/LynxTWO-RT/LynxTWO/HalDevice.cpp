/****************************************************************************
 HalDevice.cpp

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
#include "HalDevice.h"

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalDevice::Open( PHALADAPTER pHalAdapter, ULONG ulDeviceNumber )
/////////////////////////////////////////////////////////////////////////////
{
	m_pHalAdapter		= pHalAdapter;
	m_ulDeviceNumber	= ulDeviceNumber;
	m_pCallback			= NULL;
	m_usMode			= MODE_STOP;
	m_bInUse			= FALSE;

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalDevice::Close()
/////////////////////////////////////////////////////////////////////////////
{
	Stop();
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalDevice::Start()
/////////////////////////////////////////////////////////////////////////////
{
	m_usMode = MODE_RUNNING;
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalDevice::Stop()
/////////////////////////////////////////////////////////////////////////////
{
	m_usMode = MODE_STOP;
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalDevice::RegisterCallback( PHALCALLBACK pCallback, PVOID pContext1, PVOID pContext2 )
/////////////////////////////////////////////////////////////////////////////
{
	m_pCallback = pCallback;
	m_pContext1 = pContext1;
	m_pContext2 = pContext2;

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalDevice::Aquire( void )
/////////////////////////////////////////////////////////////////////////////
{
	if( m_bInUse )
		return( HSTATUS_ALREADY_IN_USE );
	
	m_bInUse = TRUE;

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalDevice::Release( void )
/////////////////////////////////////////////////////////////////////////////
{
	if( m_bInUse )
		m_bInUse = FALSE;

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalDevice::Service( ULONG ulReason )
/////////////////////////////////////////////////////////////////////////////
{
	USHORT	usStatus = HSTATUS_OK;

	//	DPF(("CHalDevice::Service( %lu ), callback: %p\n", ulReason, m_pCallback));

	if( m_pCallback )
		usStatus = m_pCallback( ulReason, m_pContext1, m_pContext2 );
#ifdef DEBUG
	else
		DB('C',COLOR_BOLD_U);
#endif

	return( usStatus );
}
