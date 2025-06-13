// OutSourceSelect.cpp : implementation file
//

#include "stdafx.h"
#include "HalTest.h"
#include "HalTestDlg.h"
#include "OutputsPage.h"
#include "OutSourceSelect.h"
#include "VUMeter.h"
#include "Fader.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// COutSourceSelect dialog


COutSourceSelect::COutSourceSelect(CWnd* pParent /*=NULL*/)
	: CDialog(COutSourceSelect::IDD, pParent)
{
	//{{AFX_DATA_INIT(COutSourceSelect)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
	m_pHalAdapter = theApp.m_pHalAdapter;
	m_pHalMixer = theApp.m_pHalMixer;
}


void COutSourceSelect::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(COutSourceSelect)
	DDX_Control(pDX, IDC_SOURCE_D, m_DSource);
	DDX_Control(pDX, IDC_SOURCE_C, m_CSource);
	DDX_Control(pDX, IDC_SOURCE_B, m_BSource);
	DDX_Control(pDX, IDC_SOURCE_A, m_ASource);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(COutSourceSelect, CDialog)
	ON_CONTROL_RANGE(CBN_SELCHANGE,IDC_SOURCE_A, IDC_SOURCE_D, OnChangeSource)
	ON_CONTROL_RANGE(BN_CLICKED,IDC_MUTE_A, IDC_MASTER_MUTE, OnMute)
	ON_CONTROL_RANGE(BN_CLICKED,IDC_PHASE_A, IDC_MASTER_PHASE, OnPhase)
	//{{AFX_MSG_MAP(COutSourceSelect)
	ON_WM_VSCROLL()
	ON_BN_CLICKED(IDC_MASTER_DITHER, OnDither)
	ON_WM_TIMER()
	ON_WM_SHOWWINDOW()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

char *gszSource[] = 
{
	"01 Record 1 Left", 
	"02 Record 1 Right",
	"03 Record 2 Left", 
	"04 Record 2 Right",
	"05 Record 3 Left", 
	"06 Record 3 Right",
	"07 Record 4 Left", 
	"08 Record 4 Right",
	"09 Record 5 Left", 
	"10 Record 5 Right",
	"11 Record 6 Left", 
	"12 Record 6 Right",
	"13 Record 7 Left", 
	"14 Record 7 Right",
	"15 Record 8 Left", 
	"16 Record 8 Right",
	"17 Play 1 Left",   
	"18 Play 1 Right",  
	"19 Play 2 Left",   
	"20 Play 2 Right",  
	"21 Play 3 Left",   
	"22 Play 3 Right",  
	"23 Play 4 Left",   
	"24 Play 4 Right",  
	"25 Play 5 Left",   
	"26 Play 5 Right",  
	"27 Play 6 Left",   
	"28 Play 6 Right",  
	"29 Play 7 Left",   
	"30 Play 7 Right",  
	"31 Play 8 Left",   
	"32 Play 8 Right"
};

/////////////////////////////////////////////////////////////////////////////
// COutSourceSelect message handlers

/////////////////////////////////////////////////////////////////////////////
BOOL COutSourceSelect::OnInitDialog() 
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulValue;

	CDialog::OnInitDialog();

	{
	// Set the window position
	RECT	ScreenRect;
	RECT	ThisRect;
	int		nCount;
	int		nX, nY;
	
	// Figure out where to put the window on the screen...
	
	// get the rect for the screen
	::GetWindowRect( ::GetDesktopWindow(), &ScreenRect );
	
	// get the rect for this dialogbox
	::GetWindowRect( m_hWnd, &ThisRect );
	
	// compute number of windows across the screen
	nCount = ScreenRect.right / ThisRect.right;
	nX	= ((m_usDstLine % nCount) * ThisRect.right) + 1;
	nY	= (m_usDstLine / nCount) * ThisRect.bottom;
	
	::SetWindowPos( m_hWnd, HWND_TOP, nX, nY, 0, 0, SWP_NOSIZE );
	}

	m_pOutputsPage = &((CHalTestDlg *)theApp.m_pMainWnd)->m_OutputsPage;

	char szBuffer[ 80 ];
	sprintf( szBuffer, "Output Source %d", m_usDstLine - LINE_OUT_1 + 1 );
	SetWindowText( szBuffer );

	for( int i=0; i<sizeof( gszSource )/sizeof( char * ); i++ )
	{
		m_ASource.AddString( gszSource[i] );
		m_BSource.AddString( gszSource[i] );
		m_CSource.AddString( gszSource[i] );
		m_DSource.AddString( gszSource[i] );
	}

	for( i=LINE_PLAY_MIXA; i<=LINE_PLAY_MIXD; i++ )
	{
		CComboBox *pSource = (CComboBox *)GetDlgItem( IDC_SOURCE_A + (i-LINE_PLAY_MIXA) );
		m_pHalMixer->GetControl( m_usDstLine, i, CONTROL_SOURCE, 0, &ulValue );
		pSource->SetCurSel( ulValue );

		CWnd *pCtl = GetDlgItem(i-LINE_PLAY_MIXA+IDC_VOLUME_A);
		FaderSetRange( pCtl->m_hWnd, MIN_VOLUME, MAX_VOLUME );
		m_pHalMixer->GetControl( m_usDstLine, i, CONTROL_VOLUME, 0, &ulValue );
		FaderSetPosition( pCtl->m_hWnd, ulValue );
		
		m_pHalMixer->GetControl( m_usDstLine, i, CONTROL_MUTE, 0, &ulValue );
		((CButton *)GetDlgItem(i-LINE_PLAY_MIXA+IDC_MUTE_A))->SetCheck( ulValue );
		
		m_pHalMixer->GetControl( m_usDstLine, i, CONTROL_PHASE, 0, &ulValue );
		((CButton *)GetDlgItem(i-LINE_PLAY_MIXA+IDC_PHASE_A))->SetCheck( ulValue );
	}

	// Do the master line
	CWnd *pCtl = GetDlgItem(IDC_MASTER_VOLUME);

	FaderSetRange( pCtl->m_hWnd, MIN_VOLUME, MAX_VOLUME );
	m_pHalMixer->GetControl( m_usDstLine, LINE_NO_SOURCE, CONTROL_VOLUME, 0, &ulValue );
	FaderSetPosition( pCtl->m_hWnd, ulValue );
	
	m_pHalMixer->GetControl( m_usDstLine, LINE_NO_SOURCE, CONTROL_MUTE, 0, &ulValue );
	((CButton *)GetDlgItem(IDC_MASTER_MUTE))->SetCheck( ulValue );
	
	m_pHalMixer->GetControl( m_usDstLine, LINE_NO_SOURCE, CONTROL_PHASE, 0, &ulValue );
	((CButton *)GetDlgItem(IDC_MASTER_PHASE))->SetCheck( ulValue );

	m_pHalMixer->GetControl( m_usDstLine, LINE_NO_SOURCE, CONTROL_DITHER, 0, &ulValue );
	((CButton *)GetDlgItem(IDC_MASTER_DITHER))->SetCheck( ulValue );

	return TRUE;  // return TRUE unless you set the focus to a control
	              // EXCEPTION: OCX Property Pages should return FALSE
}

/////////////////////////////////////////////////////////////////////////////
void COutSourceSelect::OnShowWindow(BOOL bShow, UINT nStatus) 
/////////////////////////////////////////////////////////////////////////////
{
	CDialog::OnShowWindow(bShow, nStatus);
	
	if( bShow )
	{
		SetTimer( 0, 10, NULL );
	}
	else
	{
		KillTimer( 0 );
	}
}

/////////////////////////////////////////////////////////////////////////////
void COutSourceSelect::OnTimer(UINT nIDEvent) 
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulValue;

	// go get the VU meters information
	m_pHalMixer->GetControl( m_usDstLine, LINE_NO_SOURCE, CONTROL_PEAKMETER, 0, &ulValue );
	VUSetDlgLevel( m_hWnd, IDC_VUMETER, ulValue );

	CDialog::OnTimer(nIDEvent);
}

/////////////////////////////////////////////////////////////////////////////
void COutSourceSelect::OnChangeSource( UINT nID ) 
/////////////////////////////////////////////////////////////////////////////
{
	CComboBox *pCtl = (CComboBox *)GetDlgItem( nID );
	ULONG	ulValue;

	ulValue = pCtl->GetCurSel();

	m_pHalMixer->SetControl( m_usDstLine, LINE_PLAY_MIXA+(nID-IDC_SOURCE_A), CONTROL_SOURCE, 0, ulValue );

	m_pHalMixer->GetControl( m_usDstLine, LINE_PLAY_MIXA+(nID-IDC_SOURCE_A), CONTROL_SOURCE, 0, &ulValue );
	pCtl->SetCurSel( ulValue );

	m_pOutputsPage->UpdateLine( m_usDstLine - LINE_OUT_1 );
}

/////////////////////////////////////////////////////////////////////////////
void COutSourceSelect::OnVScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar) 
/////////////////////////////////////////////////////////////////////////////
{
	USHORT	wPos = (USHORT)nPos;
	int		nChange = 0, nAbs;
	int		nVolume;
	int		nFaderID = GetWindowLong( pScrollBar->m_hWnd, GWL_ID );

	switch( nSBCode )
	{
	case SB_LINEUP:			nChange = VOLCHG_SMALL;		break;
	case SB_LINEDOWN:		nChange = -VOLCHG_SMALL;	break;
	case SB_PAGEUP:			nChange = VOLCHG_LARGE;		break;
	case SB_PAGEDOWN:		nChange = -VOLCHG_LARGE;	break;
	case SB_THUMBPOSITION:
	case SB_THUMBTRACK:		nAbs = wPos;				break;
	case SB_TOP:			nAbs = MAX_VOLUME;			break;
	case SB_BOTTOM:			nAbs = MIN_VOLUME;			break;
	case SB_ENDSCROLL:		return;
	}

	if( nChange )
	{
		nVolume = FaderGetPosition( pScrollBar->m_hWnd );
		nVolume += nChange;
	}
	else
	{
		nVolume = nAbs;
	}
	
	if( nVolume > MAX_VOLUME )	nVolume = MAX_VOLUME;
	if( nVolume < 0 )			nVolume = 0;
	
	FaderSetPosition( pScrollBar->m_hWnd, nVolume );

	if( nFaderID == IDC_MASTER_VOLUME )
		m_pHalMixer->SetControl( m_usDstLine, LINE_NO_SOURCE, CONTROL_VOLUME, 0, nVolume );
	else
		m_pHalMixer->SetControl( m_usDstLine, LINE_PLAY_MIXA+(nFaderID-IDC_VOLUME_A), CONTROL_VOLUME, 0, nVolume );

	m_pOutputsPage->UpdateLine( m_usDstLine - LINE_OUT_1 );
}

/////////////////////////////////////////////////////////////////////////////
void COutSourceSelect::OnMute( UINT nID ) 
/////////////////////////////////////////////////////////////////////////////
{
	CButton *pButton = (CButton *)GetDlgItem( nID );
	ULONG	ulValue;

	ulValue = pButton->GetCheck() ? 0 : 1;	// reverse the state of the check box

	if( nID == IDC_MASTER_MUTE )
		m_pHalMixer->SetControl( m_usDstLine, LINE_NO_SOURCE, CONTROL_MUTE, 0, ulValue );
	else
		m_pHalMixer->SetControl( m_usDstLine, LINE_PLAY_MIXA+(nID-IDC_MUTE_A), CONTROL_MUTE, 0, ulValue );
	
	pButton->SetCheck( ulValue );

	m_pOutputsPage->UpdateLine( m_usDstLine - LINE_OUT_1 );
}

/////////////////////////////////////////////////////////////////////////////
void COutSourceSelect::OnPhase( UINT nID ) 
/////////////////////////////////////////////////////////////////////////////
{
	CButton *pButton = (CButton *)GetDlgItem( nID );
	ULONG	ulValue;

	ulValue = pButton->GetCheck() ? 0 : 1;	// reverse the state of the check box

	if( nID == IDC_MASTER_PHASE )
		m_pHalMixer->SetControl( m_usDstLine, LINE_NO_SOURCE, CONTROL_PHASE, 0, ulValue );
	else
		m_pHalMixer->SetControl( m_usDstLine, LINE_PLAY_MIXA+(nID-IDC_PHASE_A), CONTROL_PHASE, 0, ulValue );
	
	pButton->SetCheck( ulValue );

	for( int i=LINE_PLAY_MIXA; i<=LINE_PLAY_MIXD; i++ )
	{
		m_pHalMixer->GetControl( m_usDstLine, i, CONTROL_PHASE, 0, &ulValue );
		((CButton *)GetDlgItem(i-LINE_PLAY_MIXA+IDC_PHASE_A))->SetCheck( ulValue );
	}

	m_pHalMixer->GetControl( m_usDstLine, LINE_NO_SOURCE, CONTROL_PHASE, 0, &ulValue );
	((CButton *)GetDlgItem(IDC_MASTER_PHASE))->SetCheck( ulValue );

	m_pOutputsPage->UpdateLine( m_usDstLine - LINE_OUT_1 );
}

/////////////////////////////////////////////////////////////////////////////
void COutSourceSelect::OnDither() 
/////////////////////////////////////////////////////////////////////////////
{
	CButton *pButton = (CButton *)GetDlgItem( IDC_MASTER_DITHER );
	ULONG	ulValue;

	ulValue = pButton->GetCheck() ? 0 : 1;	// reverse the state of the check box

	m_pHalMixer->SetControl( m_usDstLine, LINE_NO_SOURCE, CONTROL_DITHER, 0, ulValue );
	
	pButton->SetCheck( ulValue );

	m_pOutputsPage->UpdateLine( m_usDstLine - LINE_OUT_1 );
}


