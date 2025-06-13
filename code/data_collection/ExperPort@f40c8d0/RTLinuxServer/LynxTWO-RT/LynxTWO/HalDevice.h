/****************************************************************************
 HalDevice.h

 Description:	Interface for the HalDevice class.

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

#ifndef _HALDEVICE_H
#define _HALDEVICE_H

#include "Hal.h"

enum
{
	MODE_STOP=0,
	MODE_RUNNING,
	NUM_MODES
};

// This is the abstract class CHalDevice 
class CHalDevice  
{
public:
	CHalDevice()	{}
	~CHalDevice()	{}

	USHORT	Open( PHALADAPTER pHalAdapter, ULONG ulDeviceNumber );
	USHORT	Close();

	ULONG	GetDeviceNumber()	{ return( m_ulDeviceNumber );			}
	BOOLEAN	IsRunning()			{ return( m_usMode == MODE_RUNNING );	}

	USHORT	Start();
	USHORT	Stop();

	USHORT	RegisterCallback( PHALCALLBACK pCallback, PVOID pContext1, PVOID pContext2 );
	USHORT	Service( ULONG ulReason );

	USHORT	Aquire( void );
	USHORT	Release( void );

protected:
	// allow these member variables to be accessed by child classes
	PHALADAPTER m_pHalAdapter;
	ULONG		m_ulDeviceNumber;
	USHORT		m_usMode;
	BOOLEAN		m_bInUse;
	
	PHALCALLBACK	m_pCallback;
	PVOID			m_pContext1;
	PVOID			m_pContext2;

private:
};

#endif // _HALDEVICE_H
