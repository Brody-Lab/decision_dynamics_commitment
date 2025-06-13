// OutputsPage.cpp : implementation file
//

#include "stdafx.h"
#include "HalTest.h"
#include "HalTestDlg.h"
#include "OutputsPage.h"
#include "OutSourceSelect.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

#include "Fader.h"
#include "VUMeter.h"

/////////////////////////////////////////////////////////////////////////////
// COutputsPage property page

IMPLEMENT_DYNCREATE(COutputsPage, CPropertyPage)

/////////////////////////////////////////////////////////////////////////////
COutputsPage::COutputsPage() : CPropertyPage(COutputsPage::IDD)
/////////////////////////////////////////////////////////////////////////////
{
	//{{AFX_DATA_INIT(COutputsPage)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
	m_pHalAdapter = theApp.m_pHalAdapter;
	m_pHalMixer = theApp.m_pHalMixer;
}

/////////////////////////////////////////////////////////////////////////////
COutputsPage::~COutputsPage()
/////////////////////////////////////////////////////////////////////////////
{
}

/////////////////////////////////////////////////////////////////////////////
void COutputsPage::DoDataExchange(CDataExchange* pDX)
/////////////////////////////////////////////////////////////////////////////
{
	CPropertyPage::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(COutputsPage)
		// NOTE: the ClassWizard will add DDX and DDV calls here
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(COutputsPage, CPropertyPage)
	// Source Menu Selection
	ON_COMMAND_RANGE(IDM_SOURCE_RECORD1LEFT, IDM_SOURCE_PLAY8RIGHT, OnSourceMenuSelect)
	// Output Play Mix Selection
	ON_COMMAND_RANGE(IDC_OUT1_PMIXA_SELECT, IDC_OUT16_PMIXD_SELECT, OnPMixSelect)
	// Source Select Dialog
	ON_CONTROL_RANGE(BN_CLICKED,IDC_OUT1_DIALOG, IDC_OUT16_DIALOG, OnSourceSelectDialog)
	// Mutes
	ON_CONTROL_RANGE(BN_CLICKED,IDC_OUT1_PMIXA_MUTE, IDC_OUT16_PMIXD_MUTE, OnMute)
	ON_CONTROL_RANGE(BN_DOUBLECLICKED,IDC_OUT1_PMIXA_MUTE, IDC_OUT16_PMIXD_MUTE, OnMute)

	ON_CONTROL_RANGE(BN_CLICKED,IDC_OUT1_MUTE, IDC_OUT16_MUTE, OnMute)
	ON_CONTROL_RANGE(BN_DOUBLECLICKED,IDC_OUT1_MUTE, IDC_OUT16_MUTE, OnMute)
	// Phase
	ON_CONTROL_RANGE(BN_CLICKED,IDC_OUT1_PHASE, IDC_OUT16_PHASE, OnPhase)
	ON_CONTROL_RANGE(BN_DOUBLECLICKED,IDC_OUT1_PHASE, IDC_OUT16_PHASE, OnPhase)
	// Dither
	ON_CONTROL_RANGE(BN_CLICKED,IDC_OUT1_DITHER, IDC_OUT16_DITHER, OnDither)
	ON_CONTROL_RANGE(BN_DOUBLECLICKED,IDC_OUT1_DITHER, IDC_OUT16_DITHER, OnDither)
	//{{AFX_MSG_MAP(COutputsPage)
	ON_WM_SHOWWINDOW()
	ON_WM_VSCROLL()
	ON_WM_TIMER()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// COutputsPage message handlers

/////////////////////////////////////////////////////////////////////////////
BOOL COutputsPage::OnInitDialog() 
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulValue;

	CPropertyPage::OnInitDialog();

	// Create the ToolTip control.
	m_tooltip.Create(this);
	m_tooltip.Activate(TRUE);

	// TODO: Use one of the following forms to add controls:
	// m_tooltip.AddTool(GetDlgItem(IDC_<name>), <string-table-id>);

	int	nLineCtls = IDC_OUT2_VOLUME - IDC_OUT1_VOLUME;

	for( int i=0; i<16; i++ )
	{
		CWnd *pCtl = GetDlgItem(IDC_OUT1_VOLUME+(i*nLineCtls));

		FaderSetRange( pCtl->m_hWnd, MIN_VOLUME, MAX_VOLUME );
		m_pHalMixer->GetControl( LINE_OUT_1 + i, LINE_NO_SOURCE, CONTROL_VOLUME, 0, &ulValue );
		FaderSetPosition( pCtl->m_hWnd, ulValue );

		m_tooltip.AddTool( pCtl, IDS_TT_VOLUME);

		m_tooltip.AddTool(GetDlgItem(IDC_OUT1_VUMETER+(i*nLineCtls)), IDS_TT_VUMETER);
		m_tooltip.AddTool(GetDlgItem(IDC_OUT1_MUTE+(i*nLineCtls)), IDS_TT_MUTE);
		m_tooltip.AddTool(GetDlgItem(IDC_OUT1_PHASE+(i*nLineCtls)), IDS_TT_PHASE);
		m_tooltip.AddTool(GetDlgItem(IDC_OUT1_DITHER+(i*nLineCtls)), IDS_TT_DITHER);
	}

	return TRUE;  // return TRUE unless you set the focus to a control
	              // EXCEPTION: OCX Property Pages should return FALSE
}

/////////////////////////////////////////////////////////////////////////////
BOOL COutputsPage::PreTranslateMessage(MSG* pMsg)
/////////////////////////////////////////////////////////////////////////////
{
	// CG: The following block was added by the ToolTips component.
	{
		// Let the ToolTip process this message.
		m_tooltip.RelayEvent(pMsg);
	}
	return CPropertyPage::PreTranslateMessage(pMsg);	// CG: This was added by the ToolTips component.
}

/////////////////////////////////////////////////////////////////////////////
void COutputsPage::OnShowWindow(BOOL bShow, UINT nStatus) 
/////////////////////////////////////////////////////////////////////////////
{
	CPropertyPage::OnShowWindow(bShow, nStatus);
	
	if( bShow )
	{
		for( int i=0; i<16; i++ )
			UpdateLine( i );

		theApp.m_nPage = PAGE_OUTPUTS;
		//SetTimer( 0, 10, NULL );
	}
	else
	{
		//KillTimer( 0 );
	}
}

/////////////////////////////////////////////////////////////////////////////
BOOL COutputsPage::OnApply() 
/////////////////////////////////////////////////////////////////////////////
{
	// do not call the base class
	return( FALSE );
}

/////////////////////////////////////////////////////////////////////////////
void COutputsPage::OnVScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar) 
/////////////////////////////////////////////////////////////////////////////
{
	USHORT	wPos = (USHORT)nPos;
	int		nChange = 0, nAbs;
	int		nVolume;
	int		nID = GetWindowLong( pScrollBar->m_hWnd, GWL_ID );

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
	
	((CHalTestDlg *)GetParent())->ShowVolume( nVolume );
	
	FaderSetPosition( pScrollBar->m_hWnd, nVolume );

	m_pHalMixer->SetControl( LINE_OUT_1 + (nID - IDC_OUT1_VOLUME), LINE_NO_SOURCE, CONTROL_VOLUME, 0, nVolume );
}

/////////////////////////////////////////////////////////////////////////////
void COutputsPage::OnPMixSelect( UINT nID )
/////////////////////////////////////////////////////////////////////////////
{
	CMenu	Menu;
	CMenu	PopupMenu;
	CPoint	Point;
	int		nDst, nSrc;
	ULONG	ulValue;

	m_nPlaySelectID = nID;	// remember which control launced the popup menu

	nDst = (m_nPlaySelectID - IDC_OUT1_PMIXA_SELECT) /
			(IDC_OUT2_PMIXA_SELECT - IDC_OUT1_PMIXA_SELECT);

	nSrc = ((m_nPlaySelectID - IDC_OUT1_PMIXA_SELECT) - (nDst * (IDC_OUT2_PMIXA_SELECT - IDC_OUT1_PMIXA_SELECT))) / 
			((IDC_OUT1_PMIXD_SELECT - IDC_OUT1_PMIXA_SELECT) / 2);

	m_pHalMixer->GetControl( LINE_OUT_1 + nDst, LINE_PLAY_MIXA + nSrc, CONTROL_SOURCE, 0, &ulValue );

	Menu.LoadMenu( IDR_OUTPUT_SOURCE );
	PopupMenu.Attach( Menu.GetSubMenu( 0 )->m_hMenu );
	
	GetCursorPos( &Point );
	PopupMenu.CheckMenuItem( IDM_SOURCE_RECORD1LEFT + ulValue, MF_BYCOMMAND | MF_CHECKED );
	PopupMenu.TrackPopupMenu( TPM_LEFTALIGN, Point.x, Point.y, this, NULL );
}

/////////////////////////////////////////////////////////////////////////////
void COutputsPage::OnSourceMenuSelect( UINT nID ) 
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulValue = nID - IDM_SOURCE_RECORD1LEFT;
	int		nDst, nSrc;

	nDst = (m_nPlaySelectID - IDC_OUT1_PMIXA_SELECT) /
			(IDC_OUT2_PMIXA_SELECT - IDC_OUT1_PMIXA_SELECT);

	nSrc = ((m_nPlaySelectID - IDC_OUT1_PMIXA_SELECT) - (nDst * (IDC_OUT2_PMIXA_SELECT - IDC_OUT1_PMIXA_SELECT))) / 
			((IDC_OUT1_PMIXD_SELECT - IDC_OUT1_PMIXA_SELECT) / 2);

	m_pHalMixer->SetControl( LINE_OUT_1 + nDst, LINE_PLAY_MIXA + nSrc, CONTROL_SOURCE, 0, ulValue );
	m_pHalMixer->GetControl( LINE_OUT_1 + nDst, LINE_PLAY_MIXA + nSrc, CONTROL_SOURCE, 0, &ulValue );

	// update the control on the screen
	char szBuffer[ 20 ];
	sprintf( szBuffer, "%02d", (ulValue + 1) );
	SetDlgItemText( m_nPlaySelectID, szBuffer );
}

/////////////////////////////////////////////////////////////////////////////
void COutputsPage::UpdateMeters( void ) 
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulValue;

	// go get the VU meters information
	for( int i=0; i<16; i++ )
	{
		m_pHalMixer->GetControl( LINE_OUT_1+i, LINE_NO_SOURCE, CONTROL_PEAKMETER, 0, &ulValue );
		VUSetDlgLevel( m_hWnd, IDC_OUT1_VUMETER+i, ulValue );
	}
}

/////////////////////////////////////////////////////////////////////////////
void COutputsPage::OnMute( UINT nID ) 
/////////////////////////////////////////////////////////////////////////////
{
	CButton *pButton;
	ULONG	ulValue;

	pButton = (CButton *)GetDlgItem( nID );
	
	ulValue = pButton->GetCheck() ? 0 : 1;	// reverse the state of the check box

	if( nID >= IDC_OUT1_PMIXA_MUTE && nID <= IDC_OUT16_PMIXD_MUTE )
	{
		USHORT usDst = (nID - IDC_OUT1_PMIXA_MUTE) / 4;
		USHORT usSrc = (nID - IDC_OUT1_PMIXA_MUTE) - (usDst * 4);
		m_pHalMixer->SetControl( LINE_OUT_1 + usDst, LINE_PLAY_MIXA + usSrc, CONTROL_MUTE, 0, ulValue );
	}
	else
	{
		m_pHalMixer->SetControl( LINE_OUT_1 + (nID - IDC_OUT1_MUTE), LINE_NO_SOURCE, CONTROL_MUTE, 0, ulValue );
	}
	
	pButton->SetCheck( ulValue );
}

/////////////////////////////////////////////////////////////////////////////
void COutputsPage::OnPhase( UINT nID ) 
/////////////////////////////////////////////////////////////////////////////
{
	CButton *pButton;
	ULONG	ulValue;

	pButton = (CButton *)GetDlgItem( nID );
	
	ulValue = pButton->GetCheck() ? 0 : 1;	// reverse the state of the check box

	m_pHalMixer->SetControl( LINE_OUT_1 + (nID - IDC_OUT1_PHASE), LINE_NO_SOURCE, CONTROL_PHASE, 0, ulValue );
	
	pButton->SetCheck( ulValue );
}

/////////////////////////////////////////////////////////////////////////////
void COutputsPage::OnDither( UINT nID ) 
/////////////////////////////////////////////////////////////////////////////
{
	CButton *pButton;
	ULONG	ulValue;

	pButton = (CButton *)GetDlgItem( nID );
	
	ulValue = pButton->GetCheck() ? 0 : 1;	// reverse the state of the check box

	m_pHalMixer->SetControl( LINE_OUT_1 + (nID - IDC_OUT1_DITHER), LINE_NO_SOURCE, CONTROL_DITHER, 0, ulValue );
	
	pButton->SetCheck( ulValue );
}

/////////////////////////////////////////////////////////////////////////////
void COutputsPage::OnSourceSelectDialog( UINT nID ) 
/////////////////////////////////////////////////////////////////////////////
{
	COutSourceSelect dlg;

	dlg.m_usDstLine = LINE_OUT_1 + (nID - IDC_OUT1_DIALOG);

	int nResponse = dlg.DoModal();
	
	// force the screen to repaint
	UpdateLine( dlg.m_usDstLine - LINE_OUT_1 );
}

/////////////////////////////////////////////////////////////////////////////
void COutputsPage::UpdateLine(int nLine)
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulValue;
	char	szBuffer[ 40 ];

	CWnd *pCtl = GetDlgItem(IDC_OUT1_VOLUME+nLine);
	m_pHalMixer->GetControl( LINE_OUT_1+nLine, LINE_NO_SOURCE, CONTROL_VOLUME, 0, &ulValue );
	FaderSetPosition( pCtl->m_hWnd, ulValue );
	
	for( int nSrc = LINE_PLAY_MIXA; nSrc <= LINE_PLAY_MIXD; nSrc++ )
	{
		m_pHalMixer->GetControl( LINE_OUT_1+nLine, nSrc, CONTROL_SOURCE, 0, &ulValue );
		if( ulValue == 0xFF )
			ulValue = -1;
		sprintf( szBuffer, "%02d", (ulValue+1) );
		SetDlgItemText( IDC_OUT1_PMIXA_SELECT+(nLine*4)+(nSrc-LINE_PLAY_MIXA), szBuffer );

		m_pHalMixer->GetControl( LINE_OUT_1+nLine, nSrc, CONTROL_MUTE, 0, &ulValue );
		((CButton *)GetDlgItem( IDC_OUT1_PMIXA_MUTE+(nLine*4)+(nSrc-LINE_PLAY_MIXA) ))->SetCheck( ulValue );
	}

	m_pHalMixer->GetControl( LINE_OUT_1+nLine, LINE_NO_SOURCE, CONTROL_MUTE, 0, &ulValue );
	((CButton *)GetDlgItem(IDC_OUT1_MUTE+nLine))->SetCheck( ulValue );
	
	m_pHalMixer->GetControl( LINE_OUT_1+nLine, LINE_NO_SOURCE, CONTROL_PHASE, 0, &ulValue );
	((CButton *)GetDlgItem(IDC_OUT1_PHASE+nLine))->SetCheck( ulValue );

	m_pHalMixer->GetControl( LINE_OUT_1+nLine, LINE_NO_SOURCE, CONTROL_DITHER, 0, &ulValue );
	((CButton *)GetDlgItem(IDC_OUT1_DITHER+nLine))->SetCheck( ulValue );
}
