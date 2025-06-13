/***************************************************************************
 VUMeter.h

 Created: David A. Hoatson, June 1997
	
 Copyright (C) 1997	Spectrum Productions

 This code may only be used with the express written permission of 
 Spectrum Productions.

 Environment: Win32 User Mode

 Revision History
 
 When      Who  Description
 --------- ---  ------------------------------------------------------------
****************************************************************************/
BOOL	RegisterVUClasses( HINSTANCE hInstance );
void	VUSetDlgLevel( HWND hDlg, int hControl, int nLevel );
void	VUSetLevel( HWND hWnd, int nNewLevel );
