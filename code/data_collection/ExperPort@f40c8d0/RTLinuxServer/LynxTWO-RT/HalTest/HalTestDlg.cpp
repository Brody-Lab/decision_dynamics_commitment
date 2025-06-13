// HalTestDlg.cpp : implementation file
//

#include "StdAfx.h"
#include <math.h>
//#include <commctrl.h>

#include "HalTest.h"
#include "HalTestDlg.h"

#include "Hal.h"
#include "HalAdapter.h"
#include "HalSampleClock.h"
#include "HalWaveDMADevice.h"
#include "PCIBios.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CHalTestDlg dialog

/////////////////////////////////////////////////////////////////////////////
CHalTestDlg::CHalTestDlg(CWnd* pParent /*=NULL*/)
	: CPropertySheet(CHalTestDlg::IDD, pParent = NULL)
/////////////////////////////////////////////////////////////////////////////
{
	//ZeroMemory( m_ulControlMap, sizeof( m_ulControlMap ) );
	AddPage( &m_TestPage );
	AddPage( &m_AdapterPage );
	AddPage( &m_RecordPage );
	AddPage( &m_OutputsPage );

	//{{AFX_DATA_INIT(CHalTestDlg)
	//}}AFX_DATA_INIT
	// Note that LoadIcon does not require a subsequent DestroyIcon in Win32
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
	m_hSmallIcon = (HICON)LoadImage( 
		AfxGetInstanceHandle(), 
		MAKEINTRESOURCE( IDR_MAINFRAME ), 
		IMAGE_ICON, 
		16, 16, 
		LR_DEFAULTCOLOR );

	m_pHalAdapter = theApp.m_pHalAdapter;
	m_pHalMixer = theApp.m_pHalMixer;
}

/////////////////////////////////////////////////////////////////////////////
void CHalTestDlg::DoDataExchange(CDataExchange* pDX)
/////////////////////////////////////////////////////////////////////////////
{
	CPropertySheet::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CHalTestDlg)
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CHalTestDlg, CPropertySheet)
	ON_MESSAGE(WM_MENUSELECT, OnMenuSelect)
	ON_MESSAGE(WM_EXITMENULOOP, OnExitMenuLoop)
	//{{AFX_MSG_MAP(CHalTestDlg)
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_COMMAND(IDM_EXIT, OnExit)
	ON_WM_ACTIVATE()
	ON_WM_SIZE()
	ON_WM_CLOSE()
	ON_WM_SYSCOMMAND()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CHalTestDlg message handlers

static int rgiButtons[] = { IDOK, IDCANCEL, ID_APPLY_NOW, IDHELP };
//#define MENUBAR_HEIGHT		10
#define MENUBAR_HEIGHT		0

#define STATUSBAR_HEIGHT	10
#define VOLUMESTATUS_WIDTH	45
#define LOCKSTATUS_WIDTH	34
#define INTERCONTROL_WIDTH	2

/////////////////////////////////////////////////////////////////////////////
BOOL CHalTestDlg::OnInitDialog()
/////////////////////////////////////////////////////////////////////////////
{
	// Allow the parent to init
	CPropertySheet::OnInitDialog();

	// put the menu on the dialog box
	CMenu menu;
	menu.LoadMenu( IDR_MENU );
	//SetMenu( &menu );

	DrawMenuBar();
	
	// hide the buttons
	for( int i = 0; i < 4; i++ )
	{
		CWnd *pCtrl = GetDlgItem( rgiButtons[i] );
		pCtrl->ShowWindow( SW_HIDE );
	}

	// change the style to include the WS_CHILD bit so the window will not be centered
	DWORD dwStyle = GetStyle();

	SET( dwStyle, WS_CHILD );
	SET( dwStyle, WS_MINIMIZEBOX );
	//CLR( dwStyle, WS_MAXIMIZEBOX );		// doesn't appear to work

	::SetWindowLong( m_hWnd, GWL_STYLE, dwStyle );

	CMenu * pSystemMenu;
	pSystemMenu = GetSystemMenu( FALSE );
	pSystemMenu->InsertMenu( 0, MF_BYPOSITION, SC_MINIMIZE, "Mi&nimize" );
	pSystemMenu->InsertMenu( 0, MF_BYPOSITION | MF_GRAYED, SC_RESTORE, "&Restore" );

	CRect rect;
	GetWindowRect( &rect );
	
	// resize the window to fit the status bar
	SetWindowPos( NULL, 0, 0, rect.right - rect.left, rect.bottom - rect.top + MENUBAR_HEIGHT, SWP_NOZORDER | SWP_NOMOVE );

	ScreenToClient( rect );

	// Make the "Client" frame look
	CRect FrameRect;
	FrameRect.top = 0;
	FrameRect.left = 1;
	FrameRect.right = rect.right - 5;
	FrameRect.bottom = rect.bottom - (24 - MENUBAR_HEIGHT);	// room for status bar
	m_Frame.Create( "Static", "", WS_VISIBLE | WS_CHILD | SS_GRAYFRAME | SS_SUNKEN, FrameRect, this, IDC_STATIC, NULL );

	GetWindowRect( &rect );
	ScreenToClient( rect );

	// calculate the rectangle for the "Status" control
	rect.top = rect.bottom - 20;
	rect.bottom -= 2;
	rect.left = 2;
	rect.right -= (INTERCONTROL_WIDTH + VOLUMESTATUS_WIDTH + INTERCONTROL_WIDTH + LOCKSTATUS_WIDTH);
	m_Status.Create( "Static", "Ready", WS_VISIBLE | WS_CHILD | SS_LEFT, rect, this, IDC_STATUS, NULL );
	
	m_Font.CreatePointFont( 8, TEXT("MS Sans Serif") );
	m_Status.SetFont( &m_Font );
	
	// calculate the rectangle for the "Volume Status" control
	rect.top -= 2;
	rect.bottom -= 2;
	rect.left = rect.right + INTERCONTROL_WIDTH;
	rect.right += VOLUMESTATUS_WIDTH;
	m_VolumeStatus.Create( "Static", "", WS_VISIBLE | WS_CHILD | SS_RIGHT | SS_SUNKEN, rect, this, IDC_VOLUMESTATUS, NULL );
	m_VolumeStatus.SetFont( &m_Font );

	// calculate the rectangle for the "LOCK" control
	rect.left = rect.right + INTERCONTROL_WIDTH;
	rect.right += LOCKSTATUS_WIDTH;
	m_LockStatus.Create( "Static", "LOCK", WS_VISIBLE | WS_CHILD | SS_LEFT | SS_SUNKEN, rect, this, IDC_LOCKSTATUS, NULL );
	m_LockStatus.SetFont( &m_Font );
	
	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hSmallIcon, FALSE);		// Set small icon

	theApp.m_ThreadEvent = CreateEvent( NULL, FALSE, FALSE, NULL );
	theApp.m_pThread = AfxBeginThread( MeterThread, this );

	return TRUE;  // return TRUE  unless you set the focus to a control
}

/////////////////////////////////////////////////////////////////////////////
void CHalTestDlg::OnMenuSelect( WPARAM wParam, LPARAM lParam )
/////////////////////////////////////////////////////////////////////////////
{
	UINT uItem = (UINT) LOWORD(wParam);   // menu item or submenu index

	switch( uItem )
	{
	case SC_RESTORE:	uItem = IDS_SC_RESTORE;		break;
	case SC_MINIMIZE:	uItem = IDS_SC_MINIMIZE;	break;
	case SC_MOVE:		uItem = IDS_SC_MOVE;		break;
	case SC_CLOSE:		uItem = IDM_EXIT;			break;
	default:			break;
	}
	
	CString	strItem;
	strItem.LoadString( uItem );
	m_Status.SetWindowText( strItem );
}

/////////////////////////////////////////////////////////////////////////////
void CHalTestDlg::OnExitMenuLoop( WPARAM wParam, LPARAM lParam )
/////////////////////////////////////////////////////////////////////////////
{
	CString	strItem;
	strItem.LoadString( IDS_READY );
	m_Status.SetWindowText( strItem );
}

/////////////////////////////////////////////////////////////////////////////
void CHalTestDlg::OnExit() 
/////////////////////////////////////////////////////////////////////////////
{
	EndDialog( 0 );
}

/////////////////////////////////////////////////////////////////////////////
void CHalTestDlg::OnPaint() 
/////////////////////////////////////////////////////////////////////////////
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, (WPARAM) dc.GetSafeHdc(), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CPropertySheet::OnPaint();
	}
}

/////////////////////////////////////////////////////////////////////////////
void CHalTestDlg::OnSize(UINT nType, int cx, int cy) 
/////////////////////////////////////////////////////////////////////////////
{
	CPropertySheet::OnSize(nType, cx, cy);
	
	// update the system menu
	CMenu*	pSystemMenu;
	pSystemMenu = GetSystemMenu( FALSE );

	switch( nType )
	{
	//case SIZE_MAXIMIZED:
	case SIZE_MINIMIZED:
		pSystemMenu->EnableMenuItem( SC_RESTORE, MF_BYCOMMAND | MF_ENABLED );
		pSystemMenu->EnableMenuItem( SC_MINIMIZE, MF_BYCOMMAND | MF_GRAYED );
		break;
	case SIZE_RESTORED:
		pSystemMenu->EnableMenuItem( SC_RESTORE, MF_BYCOMMAND | MF_GRAYED );
		pSystemMenu->EnableMenuItem( SC_MINIMIZE, MF_BYCOMMAND | MF_ENABLED );
		break;
	}
}

/////////////////////////////////////////////////////////////////////////////
void CHalTestDlg::OnActivate( UINT nState, CWnd* pWndOther, BOOL bMinimized ) 
/////////////////////////////////////////////////////////////////////////////
{
	// make sure we are on top
	BringWindowToTop();
	CPropertySheet::OnActivate( nState, pWndOther, bMinimized );
}

/////////////////////////////////////////////////////////////////////////////
HCURSOR CHalTestDlg::OnQueryDragIcon()
// The system calls this to obtain the cursor to display while the user drags
//  the minimized window.
/////////////////////////////////////////////////////////////////////////////
{
	return (HCURSOR) m_hIcon;
}

/////////////////////////////////////////////////////////////////////////////
void CHalTestDlg::ShowVolume( long lVolume )
/////////////////////////////////////////////////////////////////////////////
{
	double	dValue;
	TCHAR	szValue[ 10 ];

	if( lVolume > 0 )
	{
		dValue = ((double)lVolume * (double)lVolume) / ((double)0xFFFF * (double)0xFFFF);
		// convert to dB
		dValue = log10( dValue ) * 20.0;
		
		if( dValue <= 0 )
			sprintf( szValue, "%3.1lfdB", dValue );
		else
			sprintf( szValue, "+%3.1lfdB", dValue );
	}
	else
		sprintf( szValue, "" );
	
	SetDlgItemText( IDC_VOLUMESTATUS, szValue );
}

/////////////////////////////////////////////////////////////////////////////
UINT	MeterThread( LPVOID pParam )
// Helper function to launch class based thread
/////////////////////////////////////////////////////////////////////////////
{
	CHalTestDlg *pClass = (CHalTestDlg *)pParam;

	theApp.m_bRunning = TRUE;

	while( theApp.m_bRunning )
	{
		pClass->MyThread();
		if( theApp.m_bRunning )
			Sleep( 0 );
	}
	DPF(("Terminating Thread\n"));
	SetEvent( theApp.m_ThreadEvent );
	return( 0 );
}

/////////////////////////////////////////////////////////////////////////////
void CHalTestDlg::MyThread()
/////////////////////////////////////////////////////////////////////////////
{
	m_TestPage.PollInterrupts();

	ULONG			ulCurrentTime;
	static ULONG	ulLastTime = 0;
	ULONG			ulMS;
	ULONG			ulTimeout;

	ulCurrentTime = timeGetTime();

	ulMS = ulCurrentTime - ulLastTime;

	if( theApp.m_nPage == PAGE_ADAPTER )
		ulTimeout = 25;
	else
		ulTimeout = 10;

	// has 10ms passed?
	if( ulMS > ulTimeout )
	{
		//char	szBuffer[20];
		//sprintf( szBuffer, "[%2.2lf]", ((double)ulMS / 100.0) );
		//OutputDebugStr( szBuffer );
		//DPF((szBuffer));

		//LastTime.QuadPart = CurrentTime.QuadPart;
		ulLastTime = ulCurrentTime;

		switch( theApp.m_nPage )
		{
		case PAGE_TEST:
			m_TestPage.UpdateMeters();
			break;
		case PAGE_ADAPTER:
			m_AdapterPage.UpdateScreen();
			break;
		case PAGE_RECORD:
			m_RecordPage.UpdateMeters();
			break;
		case PAGE_OUTPUTS:
			m_OutputsPage.UpdateMeters();
			break;
		} // switch
	} // if
}

/////////////////////////////////////////////////////////////////////////////
void CHalTestDlg::OnSysCommand(UINT nID, LPARAM lParam) 
/////////////////////////////////////////////////////////////////////////////
{
	switch( nID )
	{
	case SC_CLOSE:
		DPF(("SC_CLOSE\n"));
		theApp.m_nPage = -1;
		theApp.m_bRunning = FALSE;
		//DPF(("Waiting...\n"));
		//SetThreadPriority( GetCurrentThread(), THREAD_PRIORITY_LOWEST );
		// this will kill off the message pump...
		//if( WaitForSingleObject( m_ThreadEvent, 1000 ) == WAIT_TIMEOUT )
		//	DPF(("WaitForSingleObject Timed Out!\n"));
		break;
	}

	CPropertySheet::OnSysCommand(nID, lParam);
}
