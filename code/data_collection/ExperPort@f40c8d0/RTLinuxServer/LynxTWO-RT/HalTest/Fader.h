/***************************************************************************
 Fader.h

 Created: David A. Hoatson, September 1998
	
 Copyright (C) 1998	Lynx Studio Technology, Inc.

 Environment: Win32 User Mode

 Revision History
 
 When      Who  Description
 --------- ---  ------------------------------------------------------------
****************************************************************************/

void	FaderSetRange( HWND hFader, int nMin, int nMax );
void	FaderSetPosition( HWND hFader, int nPos );
int		FaderGetPosition( HWND hFader );
BOOL	RegisterFaderClasses( HINSTANCE hInstance );

