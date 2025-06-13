/****************************************************************************
 HalSampleClock.h

 Description:	Interface for the HalSampleClock class.

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

#ifndef _HALSAMPLECLOCK_H
#define _HALSAMPLECLOCK_H

#include "Hal.h"

typedef struct
{
	ULONG	ulM;
	ULONG	ulBypassM;
	ULONG	ulN;
	ULONG	ulP;
	ULONG	ulClkSrc;
	ULONG	ulWord;
	ULONG	ulSpeed;
} PLLCLOCKINFO, *PPLLCLOCKINFO;

typedef struct
{
	long	lSRate;
	USHORT	usM;
	USHORT	usN;
	USHORT	usP;
} SRREGS, *PSRREGS;

class CHalSampleClock
{
public:
	CHalSampleClock()	{}
	~CHalSampleClock()	{}

	void	operator= (long lRate)		{ Set( lRate );	}
			operator long()				{ return( m_lRate );	}

	USHORT	Open( PHALADAPTER pHalAdapter );
	USHORT	Close();

	USHORT	Get( long *plRate, long *plSource, long *plReference );
	USHORT	Get( long *plRate );
	USHORT	Set( long lRate, long lSource, long lReference, BOOLEAN bForce = FALSE );
	USHORT	Set( long lRate, BOOLEAN bForce = FALSE );
	
	USHORT	GetClockRate( long *plRate, long *plSource, long *plReference );

	USHORT	GetMinMax( long *plMin, long *plMax );

private:
	USHORT	GetClockInfo( long *plRate, PSRREGS pSRRegs, PPLLCLOCKINFO pClockInfo, int ulNumberOfEntires );

	PHALADAPTER		m_pHalAdapter;
	CHalRegister	m_RegPLLCTL;
	long	m_lRate;
	long	m_lSource;
	long	m_lReference;
	ULONG	m_ulSpeed;
	ULONG	m_ulP;
};

#endif // _HALSAMPLECLOCK_H
