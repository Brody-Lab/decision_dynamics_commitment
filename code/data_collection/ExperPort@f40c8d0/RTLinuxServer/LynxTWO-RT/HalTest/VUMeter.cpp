/***************************************************************************
 VUMeter.c

 Created: David A. Hoatson, June 1997
	
 Copyright (C) 1997	Spectrum Productions

 This code may only be used with the express written permission of 
 Spectrum Productions.

 Environment: Win32 User Mode

 Revision History
 
 When      Who  Description
 --------- ---  ------------------------------------------------------------
****************************************************************************/
#include <StdAfx.h>

#include <windows.h>
#include "VUMeter.h"

#define GWL_LEVEL		0
#define GWL_PREVIOUS	4
#define WM_SETVULEVEL	WM_USER+1

HPEN	ghGreenOn  = NULL;
HPEN	ghYellowOn = NULL;
HPEN	ghRedOn    = NULL;
HPEN	ghGreenOff  = NULL;
HPEN	ghYellowOff = NULL;
HPEN	ghRedOff    = NULL;

int		gnWindowCount = 0;

// 16-bit values (70 segments)
// these are the actual values for the 70 segments
//int		gnLogValues[] = {65533,63677,61870,60115,58409,56752,55142,53577,52057,50097,48211,46396,45080,43801,42558,41350,38295,35466,32846,31008,29274,27636,26090,24163,22378,20724,19565,18471,17437,16462,15246,14119,13076,12345,11654,11002,10387,9619,8909,8250,7789,7353,6942,6554,5841,5206,4640,4256,3904,3581,3285,2927,2609,2325,2072,1554,1165,874,655,369,207,117,66,30,14,7,4,3,2,1};
//short	gsSegment[] = { 0,-1,-2,-3,-4,-6,-8,-10,-12,-14,-16,-18,-20,-23,-26,-30,-40,-60,-80,-96 };

// 20-bit values
int		gnLogValues[] = { 524287,467272,428618,393161,371167,340463,312299,286464,262144,208723,165794,131072,110808,93233,78446,65536,52429,41646,32768,27834,23419,19705,16384,13170,10461,8192,6991,5883,4950,4096,3308,2628,2048,1756,1478,1243,1024,831,660,512,441,371,312,256,209,166,128,111,93,78,64,56,47,39,32,28,23,20,21,18,15,12,10,8,7,5,4,3,2,1 };
short	gsSegment[]	= { 0,-3,-6,-12,-18,-24,-30,-36,-42,-48,-54,-60,-66,-72,-78,-84,-88,-94,-100,-120 };

// 32-bit values
//ULONG	gulLogValues[] = {4233600378,3827893632,3411613790,3040603991,2709941160,2415237601,2152582778,1918491420,1709857278,1523911903,1358187913,1210486252,1078847007,961523408,856958639,763765191,680706443,606680256,540704347,481903257,429496730,382789363,341161379,304060399,270994116,241523760,215258278,191849142,170985728,152391190,135818791,121048625,107884701,96152341,85695864,76376519,68070644,60668026,54070435,48190326,42949673,38278936,34116138,30406040,27099412,24152376,21525828,19184914,17098573,15239119,13581879,12104863,10788470,9615234,8569586,7637652,6807064,6066803,5407043,4819033,4294967,3827894,3411614,3040604,2709941,2415238,2152583,1918491,1709857,1523912,1358188,1210486,1078847,961523,856959,763765,680706,606680,540704,481903,429497,382789,341161,304060,270994,241524,215258,191849,170986,152391,135819,121049,107885,96152,85696,76377,68071,60668,54070,48190,42950,38279,34116,30406,27099,24152,21526,19185,17099,15239,13582,12105,10788,9615,8570,7638,6807,6067,5407,4819,4295 };

#define NUM_VALUE_SEGMENTS	(sizeof( gsSegment ) / sizeof( gsSegment[0] ))
#define	NUM_METER_SEGMENTS	(sizeof( gnLogValues ) / sizeof( gnLogValues[0]))
#define	LAST_RED_SEGMENT	16
#define	LAST_YELLOW_SEGMENT	23

void	DrawBar( HWND hWnd, HDC hDC, int nLevel );

/////////////////////////////////////////////////////////////////////////////
void	VUSetDlgLevel( HWND hDlg, int hControl, int nLevel )
/////////////////////////////////////////////////////////////////////////////
{
	VUSetLevel( GetDlgItem( hDlg, hControl ), nLevel );
}

/////////////////////////////////////////////////////////////////////////////
void	VUSetLevel( HWND hWnd, int nNewLevel )
/////////////////////////////////////////////////////////////////////////////
{
	HDC		hDC;

	// get the device context
	hDC = GetDC( hWnd );
	
	// update the bar graph
	DrawBar( hWnd, hDC, nNewLevel );
	
	// release the device context
	ReleaseDC( hWnd, hDC );
}

/*
Response Time:
VU Mode				300mS / 20 dB attack & release
PPM Mode			0 mS attack, 2.8 Sec / 24dB release
Peak Mode			50 usec attack, 300 msec release
Average Mode		35 msec attack, 300 msec release
*/

/////////////////////////////////////////////////////////////////////////////
void	DrawSegment( HDC hDC, WORD wWidth, short iSegment, BOOLEAN bOn )
/////////////////////////////////////////////////////////////////////////////
{
	HPEN	hColor;
	register int nX, nY, nCX;
	
	//if( iSegment >= NUM_METER_SEGMENTS )
	//	return;
	
	if( iSegment <= LAST_RED_SEGMENT )
		hColor = bOn ? ghRedOn : ghRedOff;
	else if( iSegment <= LAST_YELLOW_SEGMENT )
		hColor = bOn ? ghYellowOn : ghYellowOff;
	else
		hColor = bOn ? ghGreenOn : ghGreenOff;
	
	nX	= 2;
	nCX	= nX + wWidth;
	nY	= (iSegment * 2) + 2;
	
	SelectObject( hDC, hColor );
	MoveToEx( hDC, nX, nY, NULL );
	LineTo( hDC, nCX, nY );
}

/////////////////////////////////////////////////////////////////////////////
void	DrawBar( HWND hWnd, HDC hDC, int nLevel )
/////////////////////////////////////////////////////////////////////////////
{
	short	nSegment, nCurrentTopSegment, nPreviousTopSegment;
	WORD	wWidth;
	RECT	WinRect;	// size of the window
	
	// get the window size
	GetClientRect( hWnd, &WinRect );
	
	wWidth = WinRect.right - 4;
	
	nPreviousTopSegment = (short)GetWindowLong( hWnd, GWL_LEVEL );
	
	if( nLevel >= 0 )
	{
		// 0 is the top of the bar graph
		for( nSegment=0; nSegment<NUM_METER_SEGMENTS; nSegment++ )
			if( nLevel >= gnLogValues[ nSegment ] ) 
				break;
		nCurrentTopSegment = nSegment;

		if( nCurrentTopSegment < nPreviousTopSegment )	// level is more than last time, turn on bars
		{
			for( nSegment=nCurrentTopSegment; nSegment<nPreviousTopSegment; nSegment++ )
				DrawSegment( hDC, wWidth, nSegment, TRUE );
		}
		if( nCurrentTopSegment > nPreviousTopSegment )	// level is less than last time, turn off bars
		{
			nCurrentTopSegment = nPreviousTopSegment + 1;	// decay the level
			for( nSegment=nPreviousTopSegment; nSegment<nCurrentTopSegment; nSegment++ )
				DrawSegment( hDC, wWidth, nSegment, FALSE );
		}
	}
	else
	{
		// no change
		nCurrentTopSegment = nPreviousTopSegment;

		for( nSegment=0; nSegment<NUM_METER_SEGMENTS; nSegment++ )
			DrawSegment( hDC, wWidth, nSegment, (BOOLEAN)((nCurrentTopSegment > nSegment) ? FALSE : TRUE) );
	}


	//nPreviousTopSegment++;	// decay the previous level
	//if( nPreviousTopSegment > NUM_METER_SEGMENTS )
	//	nPreviousTopSegment = NUM_METER_SEGMENTS;
	SetWindowLong( hWnd, GWL_LEVEL, nCurrentTopSegment );
}

/////////////////////////////////////////////////////////////////////////////
LRESULT CALLBACK VUMeterWndProc( HWND hWnd, unsigned iMsg, WPARAM wParam, LONG lParam )
/////////////////////////////////////////////////////////////////////////////
{
	HDC		hDC;
	RECT	Rect;
	PAINTSTRUCT ps;
	HPEN	hPen, hPenOld;
	
	switch( iMsg )
	{
	case WM_CREATE:
		//GetClientRect( hWnd, &Rect );
		//NUM_METER_SEGMENTS = (Rect.bottom - 2) / 2;

		SetWindowLong( hWnd, GWL_LEVEL, NUM_METER_SEGMENTS );

		// if the green brush doesn't exist yet, create all of the brushes
		if( !gnWindowCount )
		{
			ghGreenOn	= CreatePen( PS_SOLID, 1, RGB(0,255,0) );
			ghYellowOn	= CreatePen( PS_SOLID, 1, RGB(255,255,0) );	// red and green
			ghRedOn		= CreatePen( PS_SOLID, 1, RGB(255,0,0) );

			ghGreenOff	= CreatePen( PS_SOLID, 1, RGB(0,128,0) );
			ghYellowOff	= CreatePen( PS_SOLID, 1, RGB(128,96,0) );	// red and green
			ghRedOff	= CreatePen( PS_SOLID, 1, RGB(128,0,0) );
		}
		gnWindowCount++;
		break;
		
	case WM_DESTROY:
		// if this is the last window around, delete all of the used objects
		gnWindowCount--;
		if( !gnWindowCount )
		{
			DeleteObject( ghGreenOn );
			DeleteObject( ghYellowOn );
			DeleteObject( ghRedOn );
			DeleteObject( ghGreenOff );
			DeleteObject( ghYellowOff );
			DeleteObject( ghRedOff );
		}
		break;
		
	case WM_PAINT:
		hDC = BeginPaint( hWnd, &ps );
		
		// Make sure we are doing to whole window
		GetClientRect( hWnd, &Rect );

		// background
		FillRect( hDC, &Rect, (HBRUSH)GetStockObject( BLACK_BRUSH ) );
		
		// draw 3D border

		// select a grey pen
		hPen = CreatePen( PS_SOLID, 1, GetSysColor( COLOR_3DSHADOW ) );
		hPenOld = (HPEN)SelectObject( hDC, hPen );
		
		MoveToEx( hDC, Rect.left, Rect.bottom-1, NULL );
		LineTo( hDC, Rect.left , Rect.top );
		LineTo( hDC, Rect.right, Rect.top );

		// select a white pen
		hPen = CreatePen( PS_SOLID, 1, GetSysColor( COLOR_3DHIGHLIGHT ) );
		SelectObject( hDC, hPen );

		MoveToEx( hDC, Rect.right-1, Rect.top, NULL );
		LineTo( hDC, Rect.right-1, Rect.bottom-1 );
		LineTo( hDC, Rect.left   , Rect.bottom-1 );
		
		SelectObject( hDC, hPenOld );
		DeleteObject( hPen );

		DrawBar( hWnd, ps.hdc, -1 );

		EndPaint( hWnd, &ps );
		break;
		
	default:
		return( DefWindowProc( hWnd, iMsg, wParam, lParam ) );
	}
	return( 0 );
}

/////////////////////////////////////////////////////////////////////////////
LRESULT CALLBACK VUValueWndProc( HWND hWnd, unsigned iMsg, WPARAM wParam, LONG lParam )
/////////////////////////////////////////////////////////////////////////////
{
	HDC hDC;
	short i;
	RECT WinRect, SegRect;
	WORD wSegmentHeight, wSegmentWidth;
	PAINTSTRUCT ps;
	HFONT hFont, hOldFont;
	char szBuf[10];
	char *pszFace = "Small Fonts";
	
	switch( iMsg ) 
	{
	case WM_PAINT:
		hDC = BeginPaint( hWnd, &ps );
		
		FillRect( hDC, &ps.rcPaint, GetSysColorBrush( COLOR_BTNFACE ) );
		
		GetClientRect( hWnd, &WinRect );
		wSegmentHeight = ((WinRect.bottom - 2) / NUM_VALUE_SEGMENTS) - 1;
		wSegmentWidth  = WinRect.right - 2;
		
		SegRect.left   = 1;
		SegRect.right  = SegRect.left + wSegmentWidth;
		
		hFont = CreateFont( 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, pszFace );
		if( hFont == NULL )
		{
		}
		
		hOldFont = (HFONT)SelectObject( hDC, hFont );
		SetBkColor( hDC, GetSysColor( COLOR_BTNFACE ) );
		
		for( i=0; i<NUM_VALUE_SEGMENTS; i++ )					// step thru each segment
		{
			SegRect.top    = i * (wSegmentHeight+1);
			SegRect.bottom = SegRect.top + wSegmentHeight+1;
			if( i <= 4 )
				SetTextColor( hDC, RGB(255,0,0) );		// red foreground
			/*
			else 
			if( i <= 5 )
				SetTextColor( hDC, RGB(255,255,0) );	// yellow foreground
			else
				SetTextColor( hDC, RGB(0,255,0) );		// green foreground
			*/
			else
				SetTextColor( hDC, RGB(0,0,255) );		// blue foreground
			
			wsprintf( szBuf, "%d", gsSegment[i] );
			DrawText( hDC, szBuf, -1, &SegRect, DT_CENTER | DT_TOP );
		}
		
		// get rid of the font
		SelectObject( hDC, hOldFont );
		DeleteObject( hFont );
		
		EndPaint( hWnd, &ps );
		break;
		
	default:
		return( DefWindowProc( hWnd, iMsg, wParam, lParam ) );
	}
	return( 0 );
}

/////////////////////////////////////////////////////////////////////////////
BOOL RegisterVUClasses( HINSTANCE hInstance )
/////////////////////////////////////////////////////////////////////////////
{
	WNDCLASS wc;
	char szClass1[] = "VUMeter";
	char szClass2[] = "VUValue";
	
	// Register the window class
	
	wc.style         = CS_SAVEBITS;
	wc.lpfnWndProc   = (WNDPROC)VUMeterWndProc;
	wc.cbClsExtra    = 0;
	wc.cbWndExtra    = sizeof( LONG ) * 2;
	wc.hInstance     = hInstance;
	wc.hIcon         = NULL;
	wc.hCursor       = LoadCursor( NULL, IDC_ARROW );
	wc.hbrBackground = (HBRUSH)GetStockObject( BLACK_BRUSH );
	wc.lpszMenuName  = NULL;
	wc.lpszClassName = szClass1;
	
	if( !RegisterClass( &wc ) )
		return( FALSE );
	
	wc.lpfnWndProc   = (WNDPROC)VUValueWndProc;
	wc.hbrBackground = GetSysColorBrush( COLOR_BTNFACE );
	wc.lpszClassName = szClass2;
	wc.cbWndExtra    = 0;
	
	if( !RegisterClass( &wc ) )
		return( FALSE );
	
	return( TRUE );
}
