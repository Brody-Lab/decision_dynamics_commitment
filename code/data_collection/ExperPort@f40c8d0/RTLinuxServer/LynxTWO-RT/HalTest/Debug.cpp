/****************************************************************************
 Debug.cpp

 Created: David A. Hoatson, October 1996
	
 Copyright (C) 1996  Spectrum Productions

 Environment: Windows NT Kernel mode

 Revision History
 
 When		Who	Description
 ----------	---	-------------------------------------------------------------
*****************************************************************************/
#include "stdafx.h"

#ifdef DEBUG

#include "HalEnv.h"
#include <DrvDebug.h>
#include <stdarg.h>
#include <stdio.h>

VOID	 DbgPutText( char *szStr, UCHAR cColor );
VOID	 DbgClearScreen( BOOLEAN bCopyright );

extern HANDLE ghDriver;

#define DIOC_DEBUGPRINTSTR		0x1000
#define DIOC_DEBUGPRINTCH		0x1001

/////////////////////////////////////////////////////////////////////////////
VOID	 DbgPutCh( char cChar, UCHAR cColor )
//	This function MUST be protected by raised IRQL as it touches the hardware
/////////////////////////////////////////////////////////////////////////////
{
	char	szStr[3];
	ULONG	ulBytesReturned;

	szStr[0] = cChar;
	szStr[1] = cColor;
	szStr[2] = 0;

	if( ghDriver )
		DeviceIoControl( ghDriver, DIOC_DEBUGPRINTCH, szStr, 2, szStr, 2, &ulBytesReturned, NULL );
}

/////////////////////////////////////////////////////////////////////////////
VOID	 DbgPutStr( char *szStr, UCHAR cColor )
/////////////////////////////////////////////////////////////////////////////
{
	while( *szStr != 0 )
		DbgPutCh( *szStr++, cColor );
}

/////////////////////////////////////////////////////////////////////////////
VOID	 DbgPutChText( UCHAR cChar, UCHAR cColor )
//	This function MUST be protected by raised IRQL as it touches the hardware
/////////////////////////////////////////////////////////////////////////////
{
}

/////////////////////////////////////////////////////////////////////////////
VOID	 DbgPutText( char *szStr, UCHAR cColor )
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulBytesReturned;

	if( !ghDriver )
	{
		OutputDebugString( szStr );
	}
	else
	{
		if( !DeviceIoControl( ghDriver, DIOC_DEBUGPRINTSTR, 
			szStr, strlen( szStr ), 
			szStr, strlen( szStr ),
			&ulBytesReturned, NULL ) )
		{
			//MessageBox( NULL, szStr, "DIOC_DEBUGPRINT Failed!", MB_OK );
		}
	}
}

/////////////////////////////////////////////////////////////////////////////
CHAR	 AsciiNumber( UCHAR ucNum )
/////////////////////////////////////////////////////////////////////////////
	{
	if( ucNum>9 )
		return( ucNum + 'A' - 10 );
	return( ucNum + '0' );
	}

/////////////////////////////////////////////////////////////////////////////
VOID	 DbgPutX8( UCHAR uc8, UCHAR cColor )
/////////////////////////////////////////////////////////////////////////////
	{
	char szBuffer[3];
	szBuffer[0] = AsciiNumber( (UCHAR)(uc8 >> 4) );
	szBuffer[1] = AsciiNumber( (UCHAR)(uc8 & 0x0F) );
	szBuffer[2] = 0;	// null terminate
	DbgPutStr( szBuffer, cColor );
	}

/////////////////////////////////////////////////////////////////////////////
VOID	 DbgPutX16( USHORT w16, UCHAR cColor )
/////////////////////////////////////////////////////////////////////////////
	{
	SHORT i;
	UCHAR cC;
	char szBuffer[5];

	for(i=0; i<4; i++)
		{
		cC = (UCHAR)(w16>>12);
		w16 = w16<<4;
		if(cC>9)
			szBuffer[i] = (cC + 'A' - 10);
		else
			szBuffer[i] = (cC + '0');
		}
	szBuffer[4] = 0;	// null terminate
	DbgPutStr( szBuffer, cColor );
	}

/////////////////////////////////////////////////////////////////////////////
VOID	 DbgPutX32( ULONG dw32, UCHAR cColor )
/////////////////////////////////////////////////////////////////////////////
	{
	SHORT i;
	UCHAR cC;
	char szBuffer[9];

	for(i=0; i<8; i++)
		{
		cC = (UCHAR)(dw32>>28);
		dw32 = dw32<<4;
		if(cC>9)
			szBuffer[i] = (cC + 'A' - 10);
		else
			szBuffer[i] = (cC + '0');
		}
	szBuffer[8] = 0;	// null terminate
	DbgPutStr( szBuffer, cColor );
	}

/////////////////////////////////////////////////////////////////////////////
void __cdecl DbgPrintMono( char *pszFormat, ... )
/////////////////////////////////////////////////////////////////////////////
{
	char	szBuf[256];
	va_list	ap;
	
	va_start( ap, pszFormat );
	vsprintf( szBuf, (char *)pszFormat, ap );
	//MessageBox( NULL, szBuf, "DPF", MB_OK );
	DbgPutText( szBuf, 7 );
	va_end(ap);
}

/////////////////////////////////////////////////////////////////////////////
VOID	 DbgClose( VOID )
/////////////////////////////////////////////////////////////////////////////
{
}

#endif
