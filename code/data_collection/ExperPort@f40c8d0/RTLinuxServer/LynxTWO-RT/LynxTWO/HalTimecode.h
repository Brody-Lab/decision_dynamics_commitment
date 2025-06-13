/****************************************************************************
 HalTimecode.h

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

#ifndef _HALTIMECODE_H
#define _HALTIMECODE_H

#include "HalRegister.h"	// Added by ClassView
#include "Hal.h"
#include "HalEnv.h"	// Added by ClassView
#include "HalDevice.h"
#include "LynxTWO.h"

enum
{
	TC_BUFFERA=0,
	TC_BUFFERB
};

enum
{
	TC_RX=0,
	TC_TX
};

class CHalTimecode : public CHalDevice  
{
public:
	CHalTimecode()	{}
	~CHalTimecode()	{}

	USHORT	Open( PHALADAPTER pHalAdapter, ULONG ulDeviceNumber );
	USHORT	Close();
	USHORT	Start();
	USHORT	Stop();

	USHORT	Service( ULONG ulBufferID );

	USHORT	SetDefaults( void );
	USHORT	SetMixerControl( USHORT usControl, ULONG ulValue );
	USHORT	GetMixerControl( USHORT usControl, PULONG pulValue );

	USHORT	EnableMTC( BOOLEAN bEnable );
	USHORT	GetMTCFrameRate( PBYTE pucMTCFrameRate );

	BOOLEAN	IsRx()					{ return( m_ulDeviceNumber == TC_RX ); };
	
	USHORT	SetFrameRate( ULONG ulFrameRate );
	USHORT	GetFrameRate( PULONG pulFrameRate );

	USHORT	SetPosition( ULONG ulPosition );
	USHORT	GetPosition( PULONG pulPosition );

	USHORT	SetDropFrame( BOOLEAN bDropFrame );
	BOOLEAN	GetDropFrame()			{ return( m_bDropFrame );				};

	USHORT	SetSyncSource( ULONG ulSyncSource );
	ULONG	GetSyncSource()			{ return( m_ulSyncSource );				};

	ULONG	GetInputDirection( void );
	BOOLEAN IsInputLocked( void );

	BOOLEAN	HasValidTimecode( void );
	USHORT	ResetValidTimecode( void );

private:
	void	IncrementTimecode();
	void	WriteTimecode( ULONG ulBufferID, PULONG pulTxBuffer );
	void	EncodeTxBuffer( PULONG pulTxBuffer );

	BOOLEAN			m_bOpen;
	TIMECODE		m_CurrentPosition;
	ULONG			m_ulFrameRate;
	
	BYTE			m_ucMTCFrameRate;
	BYTE			m_ucMaxFrame;
	BOOLEAN			m_bHasValidTimecode;

	CHalRegister	m_RegTCStatus;
	CHalRegister	m_RegLTCRxRate;
	PHALREGISTER	m_pRegLTCControl;
	BOOLEAN			m_bDropFrame;		// Global flag if drop frame is enabled
	ULONG			m_ulSyncSource;
	BOOLEAN			m_bMTCRunning;		// TRUE if MTC has ever been detected running on MIDI Out

};

#endif // _HALTIMECODE_H
