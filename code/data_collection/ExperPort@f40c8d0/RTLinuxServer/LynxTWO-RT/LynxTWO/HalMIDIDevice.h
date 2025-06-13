/****************************************************************************
 HalMIDIDevice.h

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


#if !defined(AFX_HALMIDIDEVICE_H__6F31BA61_956B_11D4_BA01_005004612939__INCLUDED_)
#define AFX_HALMIDIDEVICE_H__6F31BA61_956B_11D4_BA01_005004612939__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "HalDevice.h"
#include "HalEnv.h"	// Added by ClassView

enum
{
	MTC_FRAMERATE_24 = 0,
	MTC_FRAMERATE_25,
	MTC_FRAMERATE_30DROP,
	MTC_FRAMERATE_30,
	MTC_NUMFRAMERATES
};

#define	MIDI_RX_BUFFER_SIZE	64

class CHalMIDIDevice : public CHalDevice  
{
public:
	CHalMIDIDevice()	{}
	~CHalMIDIDevice()	{}
	
	USHORT	Open( PHALADAPTER pHalAdapter, ULONG ulDeviceNumber );
	USHORT	Close();
	USHORT	Start();
	USHORT	Stop();

	BOOLEAN	IsRecord()	{ return( m_bIsRecord );	}

	USHORT	Read( PBYTE pBuffer, ULONG ulSize, PULONG pulBytesRead );
	USHORT	Write( PBYTE pBuffer, ULONG ulSize, PULONG pulBytesWritten );

	// Only called from HalLStream.cpp
	USHORT	AddByteToBuffer( BYTE ucByte );
	
	USHORT	SetMTCFrameRate( USHORT usFrameRate );
	USHORT	GetMTCPosition( PULONG pulTimecode );
	USHORT	ResetMTCPosition( void );

	USHORT	Service( ULONG ulReason );

private:
	BOOLEAN	m_bIsRecord;
	CHalTimecode *m_pTCRx;
	CHalTimecode *m_pTCTx;
	CHalLStream	*m_pLStream;
	ULONG		m_ulMTCMessages;
	TIMECODE	m_MTCPosition;
	USHORT		m_usMTCFrameRate;
	BYTE		m_ucQFM;
	BOOLEAN		m_bDrop;

	ULONG		m_ulADATPort;
	ULONG		m_ulMTCSource;
	
	BYTE		m_CurrentMessage[ MIDI_RX_BUFFER_SIZE ];
	ULONG		m_ulHead;
	ULONG		m_ulTail;
	ULONG		m_ulBytesInMessage;
};

#endif // !defined(AFX_HALMIDIDEVICE_H__6F31BA61_956B_11D4_BA01_005004612939__INCLUDED_)
