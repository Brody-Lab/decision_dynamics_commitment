/***************************************************************************
 Fader.c

 Created: David A. Hoatson, September 1998
	
 Copyright (C) 1998	Lynx Studio Technology, Inc.

 Environment: Win32 User Mode

 Revision History
 
 When      Who  Description
 --------- ---  ------------------------------------------------------------
****************************************************************************/
#include "stdafx.h"

#define NOMINMAX
#include <windows.h>
#include <stdlib.h>
#include "resource.h"

#ifndef WM_MOUSEWHEEL
#define WM_MOUSEWHEEL                   0x020A
#endif

/* Global Varibles for Fader Window */
typedef struct tag_FADERINFO 
{
	int		nMin;
	int		nMax;
	int		nPos;

	int		nWindowX;
	int		nWindowY;
	int		nBitmapX;
	int		nBitmapPos;

	BOOL	bMouseDown;
	BOOL	bHasFocus;
	HBITMAP	hFader;
	HBITMAP	hGradient;
	BITMAP	bmFader;
	BITMAP	bmGradient;
	HDC		hFaderDC;
	HDC		hGradientDC;
} FADERINFO, *PFADERINFO, FAR *FPFADERINFO;

#define CARET_OFFSET	16

//The supported WM_APPCOMMAND events
#ifndef WM_APPCOMMAND
	#define WM_APPCOMMAND						0x319
	#define APPCOMMAND_BROWSER_BACKWARD       1
	#define APPCOMMAND_BROWSER_FORWARD        2
	#define APPCOMMAND_BROWSER_REFRESH        3
	#define APPCOMMAND_BROWSER_STOP           4
	#define APPCOMMAND_BROWSER_SEARCH         5
	#define APPCOMMAND_BROWSER_FAVORITES      6
	#define APPCOMMAND_BROWSER_HOME           7
	#define APPCOMMAND_VOLUME_MUTE            8
	#define APPCOMMAND_VOLUME_DOWN            9
	#define APPCOMMAND_VOLUME_UP              10
	#define APPCOMMAND_MEDIA_NEXTTRACK        11
	#define APPCOMMAND_MEDIA_PREVIOUSTRACK    12
	#define APPCOMMAND_MEDIA_STOP             13
	#define APPCOMMAND_MEDIA_PLAY_PAUSE       14
	#define APPCOMMAND_LAUNCH_MAIL            15
	#define APPCOMMAND_LAUNCH_MEDIA_SELECT    16
	#define APPCOMMAND_LAUNCH_APP1            17
	#define APPCOMMAND_LAUNCH_APP2            18
	#define APPCOMMAND_BASS_DOWN              19
	#define APPCOMMAND_BASS_BOOST             20
	#define APPCOMMAND_BASS_UP                21
	#define APPCOMMAND_TREBLE_DOWN            22
	#define APPCOMMAND_TREBLE_UP              23

	#define FAPPCOMMAND_MOUSE 0x8000
	#define FAPPCOMMAND_KEY   0
	#define FAPPCOMMAND_OEM   0x1000
	#define FAPPCOMMAND_MASK  0xF000

	#define GET_APPCOMMAND_LPARAM(lParam) ((short)(HIWORD(lParam) & ~FAPPCOMMAND_MASK))
	#define GET_DEVICE_LPARAM(lParam)     ((WORD)(HIWORD(lParam) & FAPPCOMMAND_MASK))
	#define GET_MOUSEORKEY_LPARAM         GET_DEVICE_LPARAM
	#define GET_FLAGS_LPARAM(lParam)      (LOWORD(lParam))
	#define GET_KEYSTATE_LPARAM(lParam)   GET_FLAGS_LPARAM(lParam)
#endif

/////////////////////////////////////////////////////////////////////////////
void	PaintControl( HDC hScreenDC, PFADERINFO pFI )
/////////////////////////////////////////////////////////////////////////////
{
	HPEN	hShadowPen;
	HPEN	hHilightPen;
	HPEN	hMiddlePen;
	HPEN	hOrgPen;
	HDC		hMemoryDC;

	hMemoryDC = CreateCompatibleDC( hScreenDC );

	// put up the background bitmap
	SelectObject( hMemoryDC, pFI->hGradient );
	BitBlt( 
		hScreenDC, 0, 0,
		pFI->bmGradient.bmWidth, 
		pFI->bmGradient.bmHeight, 
		hMemoryDC, 0, 0, SRCCOPY );

	hShadowPen = CreatePen( PS_SOLID, 1, GetSysColor( COLOR_3DSHADOW ) );
	hOrgPen = (HPEN)SelectObject( hScreenDC, hShadowPen );

	// start at bottom left corner
	MoveToEx( hScreenDC, 0, pFI->nWindowY-1, NULL );
	LineTo( hScreenDC, 0, 0 );
	LineTo( hScreenDC, pFI->nWindowX-1, 0 );

	// select a white pen
	hHilightPen = CreatePen( PS_SOLID, 1, GetSysColor( COLOR_3DHIGHLIGHT ) );
	SelectObject( hScreenDC, hHilightPen );
	DeleteObject( hShadowPen );

	LineTo( hScreenDC, pFI->nWindowX-1, pFI->nWindowY-1 );
	LineTo( hScreenDC, 0, pFI->nWindowY-1 );

	// Draw line down the middle
	if( (pFI->nPos <= 2) || (pFI->nPos >= 65535) )
		hMiddlePen = (HPEN)GetStockObject( BLACK_PEN );
	else
		hMiddlePen = CreatePen( PS_SOLID, 1, RGB( 255, 0, 0 ) );	// RED_PEN

	SelectObject( hScreenDC, hMiddlePen );
	DeleteObject( hHilightPen );

	MoveToEx( hScreenDC, pFI->nWindowX / 2, (pFI->bmFader.bmHeight / 2), NULL );
	LineTo( hScreenDC, pFI->nWindowX / 2, pFI->nWindowY - (pFI->bmFader.bmHeight / 2) );

	SelectObject( hScreenDC, hOrgPen );
	DeleteObject( hMiddlePen );

	// Put up the new control knob
	SelectObject( hMemoryDC, pFI->hFader );

	BitBlt( 
		hScreenDC, 
		pFI->nBitmapX, 
		pFI->nBitmapPos, 
		pFI->bmFader.bmWidth, 
		pFI->bmFader.bmHeight, 
		hMemoryDC, 0, 0, SRCCOPY );

	DeleteDC( hMemoryDC );
}

/////////////////////////////////////////////////////////////////////////////
void	MoveKnob( HDC hScreenDC, int nPos, PFADERINFO pFI )
/////////////////////////////////////////////////////////////////////////////
{
	// if above top of fader, put at top of fader
	if( nPos < 2 )
		nPos = 2;
	
	// if below bottom of fader, put at bottom of fader
	if( nPos > (pFI->nWindowY - pFI->bmFader.bmHeight - 2) )
		nPos = pFI->nWindowY - pFI->bmFader.bmHeight - 2;

	pFI->nBitmapPos	= nPos;
	
	// Draw the new knob
	PaintControl( hScreenDC, pFI );
}

/////////////////////////////////////////////////////////////////////////////
void	FaderSetRange( HWND hFader, int nMin, int nMax )
/////////////////////////////////////////////////////////////////////////////
{
	PFADERINFO		pFI;

	pFI = (PFADERINFO)GetWindowLong( hFader, GWL_USERDATA );
	if( !pFI ) 
		return;

	pFI->nMax	= nMax;
	pFI->nMin	= nMin;
}

/////////////////////////////////////////////////////////////////////////////
void	FaderSetPosition( HWND hFader, int nPos )
/////////////////////////////////////////////////////////////////////////////
{
	PFADERINFO		pFI;
	HDC				hDC;

	pFI = (PFADERINFO)GetWindowLong( hFader, GWL_USERDATA );
	if( !pFI ) 
		return;

	if( !pFI->nMax )
		return;

	pFI->nPos = nPos;

	if( pFI->bHasFocus )
		HideCaret( hFader );
	
	hDC = GetDC( hFader );
	// MoveKnob updates pFI->nBitmapPos
	MoveKnob( hDC, (pFI->nMax - pFI->nPos) * (pFI->nWindowY - pFI->bmFader.bmHeight) / pFI->nMax, pFI );
	ReleaseDC( hFader, hDC );

	if( pFI->bHasFocus )
	{
		SetCaretPos( pFI->nBitmapX + 2, pFI->nBitmapPos + (CARET_OFFSET/2) );
		ShowCaret( hFader );
	}
}

/////////////////////////////////////////////////////////////////////////////
int		FaderGetPosition( HWND hFader )
/////////////////////////////////////////////////////////////////////////////
{
	PFADERINFO	pFI = (PFADERINFO)GetWindowLong( hFader, GWL_USERDATA );

	if( !pFI )
		return( -1 );

	return( pFI->nPos );
}

/////////////////////////////////////////////////////////////////////////////
long WINAPI FaderWndProc( HWND hWnd, UINT iMessage, WPARAM wParam, LPARAM lParam )
/////////////////////////////////////////////////////////////////////////////
{
	PAINTSTRUCT	ps;
	PFADERINFO	pFI			= (PFADERINFO)GetWindowLong( hWnd, GWL_USERDATA );
	HWND		hParentWnd	= GetParent( hWnd );
	
	switch( iMessage ) 
	{
	case WM_GETDLGCODE:
		return( DLGC_WANTARROWS );

	case WM_SETFOCUS:
		if( pFI )
		{
			CreateCaret( hWnd, (HBITMAP)1, pFI->bmFader.bmWidth - 5, pFI->bmFader.bmHeight - CARET_OFFSET );
			SetCaretPos( pFI->nBitmapX + 2, pFI->nBitmapPos + (CARET_OFFSET/2) );
			ShowCaret( hWnd );
			pFI->bHasFocus = TRUE;
		}
		break;
		
	case WM_KILLFOCUS:
		if( pFI )
			pFI->bHasFocus = FALSE;
		HideCaret( hWnd );
		DestroyCaret();
		break;
		
	case WM_APPCOMMAND:
		switch( GET_APPCOMMAND_LPARAM(lParam) )
		{
		case APPCOMMAND_VOLUME_MUTE:
			PostMessage( hParentWnd, WM_VSCROLL, (WPARAM)SB_BOTTOM, (LPARAM)hWnd );
			return( TRUE );
		case APPCOMMAND_VOLUME_UP:
			PostMessage( hParentWnd, WM_VSCROLL, (WPARAM)SB_LINEUP, (LPARAM)hWnd );
			return( TRUE );
		case APPCOMMAND_VOLUME_DOWN:
			PostMessage( hParentWnd, WM_VSCROLL, (WPARAM)SB_LINEDOWN, (LPARAM)hWnd );
			return( TRUE );
		default:
			return( DefWindowProc( hWnd, iMessage, wParam, lParam ) );
		}
		break;

	case WM_KEYDOWN:		/* Keyboard Interface for Fader */
		switch( wParam ) 
		{
		case VK_TAB:
			// pass this on to the parent
			//PostMessage( hParentWnd, iMessage, wParam, lParam );
			break;

		case VK_RIGHT:
		case VK_DOWN:
			PostMessage( hParentWnd, WM_VSCROLL, (WPARAM)SB_LINEDOWN, (LPARAM)hWnd );
			break;
			
		case VK_LEFT:
		case VK_UP:
			PostMessage( hParentWnd, WM_VSCROLL, (WPARAM)SB_LINEUP, (LPARAM)hWnd );
			break;
			
		case VK_PRIOR:
			PostMessage( hParentWnd, WM_VSCROLL, (WPARAM)SB_PAGEUP, (LPARAM)hWnd );
			break;
			
		case VK_NEXT:
			PostMessage( hParentWnd, WM_VSCROLL, (WPARAM)SB_PAGEDOWN, (LPARAM)hWnd );
			break;
			
		case VK_HOME:
			PostMessage( hParentWnd, WM_VSCROLL, (WPARAM)SB_TOP, (LPARAM)hWnd );
			break;
			
		case VK_END:
			PostMessage( hParentWnd, WM_VSCROLL, (WPARAM)SB_BOTTOM, (LPARAM)hWnd );
			break;
			
		}
		break;
		
	case WM_LBUTTONUP:
		ReleaseCapture();
		if( pFI )
		{
			// we know this control has the focus
			SetCaretPos( pFI->nBitmapX + 2, pFI->nBitmapPos + (CARET_OFFSET/2) );
			ShowCaret( hWnd );
			pFI->bMouseDown = FALSE;
		}
		break;
		
	case WM_LBUTTONDOWN:
		SetFocus( hWnd );
		SetCapture( hWnd );
		HideCaret( hWnd );
		if( pFI )
		{
			pFI->bMouseDown = TRUE;		/* Fall Through */
		}
		
	case WM_MOUSEMOVE:
		//fwKeys = wParam;        // key flags 
		//xPos = LOWORD(lParam);  // horizontal position of cursor 
		//yPos = HIWORD(lParam);  // vertical position of cursor (zero at the top)

		if( pFI )
		{
			if( pFI->bMouseDown )
			{
				short	X = LOWORD( lParam );
				short	Y = HIWORD( lParam );
				WORD	wPos;
				int		nScale = pFI->nWindowY - pFI->bmFader.bmHeight;

				// make sure we don't go out of bounds
				if( Y > (pFI->nWindowY - (pFI->bmFader.bmHeight/2)) )
					Y = (pFI->nWindowY - (pFI->bmFader.bmHeight/2));
				
				if( Y < (pFI->bmFader.bmHeight/2) )
					Y = (pFI->bmFader.bmHeight/2);

				Y	-= (pFI->bmFader.bmHeight/2);

				if( Y > nScale )
					Y = nScale;

				wPos = pFI->nMax - (((int)Y * pFI->nMax) / nScale);

				PostMessage( hParentWnd, WM_VSCROLL, MAKELONG( SB_THUMBTRACK, wPos ), (LPARAM)hWnd );
			}
		}
		break;

	case WM_MOUSEWHEEL:
		{
		short	fwKeys = LOWORD( wParam );
		short	nZDelta = HIWORD( wParam );
		short	nX = LOWORD( lParam );
		short	nY = HIWORD( lParam );
		POINT	Point;
		HWND	hParent;
//		long	CntlID;

		// what window is the mouse currently above?

		Point.x = nX;
		Point.y = nY;

		hWnd = WindowFromPoint( Point );

		hParent = GetParent( hWnd );

		// if the parent of this window is not our parent, we are done
		if( hParent != hParentWnd )
			return( 0L );
		
		// is this one of our fader windows?
/***********
		CntlID = GetWindowLong( hWnd, GWL_ID );
		switch( CntlID )
		{
		case IDC_OUT1_VOLUME:
		case IDC_OUT2_VOLUME:
		case IDC_OUT3_VOLUME:
		case IDC_OUT4_VOLUME:
			break;
		default:
			return( 0L );
		}
***********/

		SetFocus( hWnd );
		HideCaret( hWnd );

		//sprintf( szBuffer, "fwKeys [%d] nZ [%d] nX [%d] nY [%d]", fwKeys, nZDelta, nX, nY );
		//SetDlgItemText( GetParent( hWnd ), IDC_STATUS, szBuffer );

		if( nZDelta > 0 )
			PostMessage( hParentWnd, WM_VSCROLL, (WPARAM)SB_LINEUP, (LPARAM)hWnd );
		else
			PostMessage( hParentWnd, WM_VSCROLL, (WPARAM)SB_LINEDOWN, (LPARAM)hWnd );
		}
		break;
		
	case WM_SIZE:
		if( pFI )
		{
			pFI->nWindowX = LOWORD( lParam );
			pFI->nWindowY = HIWORD( lParam );
			// Place the Knob at the top of the control
			pFI->nBitmapPos = pFI->nWindowY - pFI->bmFader.bmHeight - 2;
			pFI->nBitmapX = (pFI->nWindowX / 2) - (pFI->bmFader.bmWidth / 2);
		}
		break;
		
	case WM_CREATE:
		pFI = (PFADERINFO)malloc( sizeof( FADERINFO ) );
		SetWindowLong( hWnd, GWL_USERDATA, (DWORD)pFI );
		if( !pFI )
		{
			MessageBox( NULL, TEXT("Fader: malloc failed!"), TEXT("LynxONE Mixer"), MB_OK | MB_ICONSTOP | MB_TASKMODAL );
			break;
		}
		ZeroMemory( pFI, sizeof( FADERINFO ) );
		pFI->hFader = LoadBitmap( AfxGetInstanceHandle(), MAKEINTRESOURCE( IDB_FADER ) );
		pFI->hGradient = LoadBitmap( AfxGetInstanceHandle(), MAKEINTRESOURCE( IDB_GRADIENT ) );
		GetObject( pFI->hFader, sizeof( BITMAP ), (LPSTR)&pFI->bmFader );
		GetObject( pFI->hGradient, sizeof( BITMAP ), (LPSTR)&pFI->bmGradient );
		break;
		
	case WM_DESTROY:
		if( pFI )
		{
			DeleteObject( pFI->hFader );
			DeleteObject( pFI->hGradient );
			free( pFI );
		}
		SetWindowLong( hWnd, GWL_USERDATA, (DWORD)0 );
		break;
		
	case WM_PAINT:
		BeginPaint( hWnd, (LPPAINTSTRUCT)&ps );
		if( pFI )
			PaintControl( ps.hdc, pFI );
		EndPaint( hWnd, (LPPAINTSTRUCT)&ps );
		break;
		
	default:
		return( DefWindowProc( hWnd, iMessage, wParam, lParam ) );
	}
	return( 0L );
}

/////////////////////////////////////////////////////////////////////////////
BOOL RegisterFaderClasses( HINSTANCE hInstance )
// Procedure called when the application is loaded for the first time
/////////////////////////////////////////////////////////////////////////////
{
	WNDCLASS   WndClass;
	
	/* Register Class for Child Window */
	WndClass.hCursor		= LoadCursor( hInstance, MAKEINTRESOURCE( IDC_HANDPOINT ) );
	WndClass.hIcon			= NULL;
	WndClass.cbClsExtra		= 0;
	WndClass.cbWndExtra		= sizeof( DWORD );
	WndClass.lpszMenuName	= NULL;
	WndClass.lpszClassName	= (LPSTR)"Fader";
	WndClass.hbrBackground	= GetSysColorBrush( COLOR_BTNFACE );
	WndClass.hInstance		= hInstance;
	WndClass.style			= CS_HREDRAW | CS_VREDRAW;
	WndClass.lpfnWndProc	= FaderWndProc;
	
	if (!RegisterClass( &WndClass ) )
		return(FALSE);

	return( TRUE );
}

