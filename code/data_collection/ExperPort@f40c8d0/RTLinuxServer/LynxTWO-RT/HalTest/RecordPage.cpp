// RecordPage.cpp : implementation file
//

#include "stdafx.h"
#include "HalTest.h"
#include "HalTestDlg.h"
#include "RecordPage.h"
#include "Fader.h"
#include "VUMeter.h"

#include "Hal.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CRecordPage property page

IMPLEMENT_DYNCREATE(CRecordPage, CPropertyPage)

/////////////////////////////////////////////////////////////////////////////
CRecordPage::CRecordPage() : CPropertyPage(CRecordPage::IDD)
/////////////////////////////////////////////////////////////////////////////
{
	//{{AFX_DATA_INIT(CRecordPage)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
	m_pHalAdapter = theApp.m_pHalAdapter;
	m_pHalMixer = theApp.m_pHalMixer;
}

/////////////////////////////////////////////////////////////////////////////
CRecordPage::~CRecordPage()
/////////////////////////////////////////////////////////////////////////////
{
}

/////////////////////////////////////////////////////////////////////////////
void CRecordPage::DoDataExchange(CDataExchange* pDX)
/////////////////////////////////////////////////////////////////////////////
{
	CPropertyPage::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CRecordPage)
		// NOTE: the ClassWizard will add DDX and DDV calls here
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CRecordPage, CPropertyPage)
	ON_COMMAND_RANGE(IDM_SOURCE_ANALOGIN1, IDM_SOURCE_LSTREAM2IN16, OnSourceMenuSelect)

	// Record Source
	ON_CONTROL_RANGE(BN_CLICKED,IDC_RECORD1L_SELECT, IDC_RECORD1R_SELECT, OnRecordSelect)
	ON_CONTROL_RANGE(BN_CLICKED,IDC_RECORD2L_SELECT, IDC_RECORD2R_SELECT, OnRecordSelect)
	ON_CONTROL_RANGE(BN_CLICKED,IDC_RECORD3L_SELECT, IDC_RECORD3R_SELECT, OnRecordSelect)
	ON_CONTROL_RANGE(BN_CLICKED,IDC_RECORD4L_SELECT, IDC_RECORD4R_SELECT, OnRecordSelect)
	ON_CONTROL_RANGE(BN_CLICKED,IDC_RECORD5L_SELECT, IDC_RECORD5R_SELECT, OnRecordSelect)
	ON_CONTROL_RANGE(BN_CLICKED,IDC_RECORD6L_SELECT, IDC_RECORD6R_SELECT, OnRecordSelect)
	ON_CONTROL_RANGE(BN_CLICKED,IDC_RECORD7L_SELECT, IDC_RECORD7R_SELECT, OnRecordSelect)
	ON_CONTROL_RANGE(BN_CLICKED,IDC_RECORD8L_SELECT, IDC_RECORD8R_SELECT, OnRecordSelect)
	
	// Mute
	ON_CONTROL_RANGE(BN_CLICKED,IDC_RECORD1L_MUTE, IDC_RECORD1R_MUTE, OnMute)
	ON_CONTROL_RANGE(BN_CLICKED,IDC_RECORD2L_MUTE, IDC_RECORD2R_MUTE, OnMute)
	ON_CONTROL_RANGE(BN_CLICKED,IDC_RECORD3L_MUTE, IDC_RECORD3R_MUTE, OnMute)
	ON_CONTROL_RANGE(BN_CLICKED,IDC_RECORD4L_MUTE, IDC_RECORD4R_MUTE, OnMute)
	ON_CONTROL_RANGE(BN_CLICKED,IDC_RECORD5L_MUTE, IDC_RECORD5R_MUTE, OnMute)
	ON_CONTROL_RANGE(BN_CLICKED,IDC_RECORD6L_MUTE, IDC_RECORD6R_MUTE, OnMute)
	ON_CONTROL_RANGE(BN_CLICKED,IDC_RECORD7L_MUTE, IDC_RECORD7R_MUTE, OnMute)
	ON_CONTROL_RANGE(BN_CLICKED,IDC_RECORD8L_MUTE, IDC_RECORD8R_MUTE, OnMute)

	// Dither
	ON_CONTROL_RANGE(BN_CLICKED,IDC_RECORD1L_DITHER, IDC_RECORD1R_DITHER, OnDither)
	ON_CONTROL_RANGE(BN_CLICKED,IDC_RECORD2L_DITHER, IDC_RECORD2R_DITHER, OnDither)
	ON_CONTROL_RANGE(BN_CLICKED,IDC_RECORD3L_DITHER, IDC_RECORD3R_DITHER, OnDither)
	ON_CONTROL_RANGE(BN_CLICKED,IDC_RECORD4L_DITHER, IDC_RECORD4R_DITHER, OnDither)
	ON_CONTROL_RANGE(BN_CLICKED,IDC_RECORD5L_DITHER, IDC_RECORD5R_DITHER, OnDither)
	ON_CONTROL_RANGE(BN_CLICKED,IDC_RECORD6L_DITHER, IDC_RECORD6R_DITHER, OnDither)
	ON_CONTROL_RANGE(BN_CLICKED,IDC_RECORD7L_DITHER, IDC_RECORD7R_DITHER, OnDither)
	ON_CONTROL_RANGE(BN_CLICKED,IDC_RECORD8L_DITHER, IDC_RECORD8R_DITHER, OnDither)

	//{{AFX_MSG_MAP(CRecordPage)
	ON_WM_SHOWWINDOW()
	ON_WM_TIMER()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CRecordPage message handlers

/////////////////////////////////////////////////////////////////////////////
BOOL CRecordPage::OnInitDialog() 
/////////////////////////////////////////////////////////////////////////////
{
	//CWnd	*pCtl;
	int		nLineCtls = IDC_RECORD2L_SELECT - IDC_RECORD1L_SELECT;

	CPropertyPage::OnInitDialog();

	// Create the ToolTip control.
	m_tooltip.Create(this);
	m_tooltip.Activate(TRUE);

	// TODO: Use one of the following forms to add controls:
	// m_tooltip.AddTool(GetDlgItem(IDC_<name>), <string-table-id>);
	for( int i=0; i<NUM_WAVE_RECORD_DEVICES-3; i++ )
	{
		m_tooltip.AddTool(GetDlgItem(IDC_RECORD1L_MUTE+(i*nLineCtls)), IDS_TT_MUTE);
		m_tooltip.AddTool(GetDlgItem(IDC_RECORD1R_MUTE+(i*nLineCtls)), IDS_TT_MUTE);
		m_tooltip.AddTool(GetDlgItem(IDC_RECORD1L_DITHER+(i*nLineCtls)), IDS_TT_DITHER);
		m_tooltip.AddTool(GetDlgItem(IDC_RECORD1R_DITHER+(i*nLineCtls)), IDS_TT_DITHER);
	}

	return TRUE;  // return TRUE unless you set the focus to a control
	              // EXCEPTION: OCX Property Pages should return FALSE
}

/////////////////////////////////////////////////////////////////////////////
BOOL CRecordPage::PreTranslateMessage(MSG* pMsg)
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
void CRecordPage::OnShowWindow(BOOL bShow, UINT nStatus) 
/////////////////////////////////////////////////////////////////////////////
{
	//CWnd	*pCtl;
	CButton *pButton;
	ULONG	ulValue;
	char	szBuffer[ 20 ];

	CPropertyPage::OnShowWindow(bShow, nStatus);
	
	if( bShow )
	{
		int	nLineCtls = IDC_RECORD2L_SELECT - IDC_RECORD1L_SELECT;

		for( int i=0; i<NUM_WAVE_RECORD_DEVICES-3; i++ )
		{
			/////////////////////////////////////////////////////////////////
			// Input Section
			/////////////////////////////////////////////////////////////////

			m_pHalMixer->GetControl( LINE_RECORD_0 + i, LINE_NO_SOURCE, CONTROL_SOURCE_LEFT, 0, &ulValue );
			sprintf( szBuffer, "%02d", (ulValue + 1) );
			SetDlgItemText( IDC_RECORD1L_SELECT + (i*nLineCtls), szBuffer );
			
			m_pHalMixer->GetControl( LINE_RECORD_0 + i, LINE_NO_SOURCE, CONTROL_SOURCE_RIGHT, 0, &ulValue );
			sprintf( szBuffer, "%02d", (ulValue + 1) );
			SetDlgItemText( IDC_RECORD1R_SELECT + (i*nLineCtls), szBuffer );

			m_pHalMixer->GetControl( LINE_RECORD_0 + i, LINE_NO_SOURCE, CONTROL_MUTE, LEFT, &ulValue );
			pButton = (CButton *)GetDlgItem(IDC_RECORD1L_MUTE+(i*nLineCtls));
			pButton->SetCheck( ulValue );

			m_pHalMixer->GetControl( LINE_RECORD_0 + i, LINE_NO_SOURCE, CONTROL_MUTE, RIGHT, &ulValue );
			pButton = (CButton *)GetDlgItem(IDC_RECORD1R_MUTE+(i*nLineCtls));
			pButton->SetCheck( ulValue );
			
			m_pHalMixer->GetControl( LINE_RECORD_0 + i, LINE_NO_SOURCE, CONTROL_DITHER, LEFT, &ulValue );
			pButton = (CButton *)GetDlgItem(IDC_RECORD1L_DITHER+(i*nLineCtls));
			pButton->SetCheck( ulValue );

			m_pHalMixer->GetControl( LINE_RECORD_0 + i, LINE_NO_SOURCE, CONTROL_DITHER, RIGHT, &ulValue );
			pButton = (CButton *)GetDlgItem(IDC_RECORD1R_DITHER+(i*nLineCtls));
			pButton->SetCheck( ulValue );

			/////////////////////////////////////////////////////////////////
			// Monitor Section
			/////////////////////////////////////////////////////////////////

		}
		theApp.m_nPage = PAGE_RECORD;
		//SetTimer( 0, 10, NULL );
	}
	else
	{
		//KillTimer( 0 );
	}
}

/////////////////////////////////////////////////////////////////////////////
BOOL CRecordPage::OnApply() 
/////////////////////////////////////////////////////////////////////////////
{
	// do not call the base class
	return( FALSE );
}

/////////////////////////////////////////////////////////////////////////////
void CRecordPage::OnRecordSelect( UINT nID ) 
/////////////////////////////////////////////////////////////////////////////
{
	CMenu	Menu;
	CMenu	PopupMenu;
	CPoint	Point;
	ULONG	ulValue;
	int		nLineCtls	= IDC_RECORD2L_SELECT - IDC_RECORD1L_SELECT;
	int		nDst		= (nID - IDC_RECORD1L_SELECT) / nLineCtls;
	int		nCh			= nID - (IDC_RECORD1L_SELECT + (nDst * nLineCtls));

	m_nRecordSelectID = nID;	// remember which control launced the popup menu
	
	if( !nCh )	m_pHalMixer->GetControl( LINE_RECORD_0 + nDst, LINE_NO_SOURCE, CONTROL_SOURCE_LEFT, 0, &ulValue );
	else		m_pHalMixer->GetControl( LINE_RECORD_0 + nDst, LINE_NO_SOURCE, CONTROL_SOURCE_RIGHT, 0, &ulValue );

	Menu.LoadMenu( IDR_INPUT_SOURCE );
	PopupMenu.Attach( Menu.GetSubMenu( 0 )->m_hMenu );
	
	GetCursorPos( &Point );
	PopupMenu.CheckMenuItem( IDM_SOURCE_ANALOGIN1 + ulValue, MF_BYCOMMAND | MF_CHECKED );
	PopupMenu.TrackPopupMenu( TPM_LEFTALIGN, Point.x, Point.y, this, NULL );
}

/////////////////////////////////////////////////////////////////////////////
void CRecordPage::OnSourceMenuSelect( UINT nID ) 
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulValue		= nID - IDM_SOURCE_ANALOGIN1;
	int		nLineCtls	= IDC_RECORD2L_SELECT - IDC_RECORD1L_SELECT;
	int		nDst		= (m_nRecordSelectID - IDC_RECORD1L_SELECT) / nLineCtls;
	int		nCh			= m_nRecordSelectID - (IDC_RECORD1L_SELECT + (nDst * nLineCtls));
	
	if( !nCh )	m_pHalMixer->SetControl( LINE_RECORD_0 + nDst, LINE_NO_SOURCE, CONTROL_SOURCE_LEFT, 0, ulValue );
	else		m_pHalMixer->SetControl( LINE_RECORD_0 + nDst, LINE_NO_SOURCE, CONTROL_SOURCE_RIGHT, 0, ulValue );

	if( !nCh )	m_pHalMixer->GetControl( LINE_RECORD_0 + nDst, LINE_NO_SOURCE, CONTROL_SOURCE_LEFT, 0, &ulValue );
	else		m_pHalMixer->GetControl( LINE_RECORD_0 + nDst, LINE_NO_SOURCE, CONTROL_SOURCE_RIGHT, 0, &ulValue );

	// update the control on the screen
	char szBuffer[ 20 ];
	sprintf( szBuffer, "%02d", (ulValue + 1) );
	SetDlgItemText( m_nRecordSelectID, szBuffer );
}

/////////////////////////////////////////////////////////////////////////////
void CRecordPage::UpdateMeters( void )
/////////////////////////////////////////////////////////////////////////////
{
	int		nDst;
	int		nCtlCount = IDC_RECORD2L_VUMETER - IDC_RECORD1L_VUMETER;
	ULONG	ulValue;

	// go get the VU meters information
	for( nDst=0; nDst<8; nDst++ )
	{
		m_pHalMixer->GetControl( LINE_RECORD_0+nDst, LINE_NO_SOURCE, CONTROL_PEAKMETER, LEFT, &ulValue );
		VUSetDlgLevel( m_hWnd, IDC_RECORD1L_VUMETER + (nCtlCount * nDst), ulValue );

		m_pHalMixer->GetControl( LINE_RECORD_0+nDst, LINE_NO_SOURCE, CONTROL_PEAKMETER, RIGHT, &ulValue );
		VUSetDlgLevel( m_hWnd, IDC_RECORD1R_VUMETER + (nCtlCount * nDst), ulValue );
	}
}

/////////////////////////////////////////////////////////////////////////////
void CRecordPage::OnMute( UINT nID ) 
/////////////////////////////////////////////////////////////////////////////
{
	CButton *pButton;
	ULONG	ulValue;
	int		nLineCtls	= IDC_RECORD2L_MUTE - IDC_RECORD1L_MUTE;
	int		nDst		= (nID - IDC_RECORD1L_MUTE) / nLineCtls;
	int		nCh			= nID - (IDC_RECORD1L_MUTE + (nDst * nLineCtls));

	pButton = (CButton *)GetDlgItem( nID );
	
	ulValue = pButton->GetCheck() ? 0 : 1;	// reverse the state of the check box

	m_pHalMixer->SetControl( LINE_RECORD_0 + nDst, LINE_NO_SOURCE, CONTROL_MUTE, nCh, ulValue );
	m_pHalMixer->GetControl( LINE_RECORD_0 + nDst, LINE_NO_SOURCE, CONTROL_MUTE, nCh, &ulValue );
	
	pButton->SetCheck( ulValue );
}

/////////////////////////////////////////////////////////////////////////////
void CRecordPage::OnDither( UINT nID ) 
/////////////////////////////////////////////////////////////////////////////
{
	CButton *pButton;
	ULONG	ulValue;
	int		nLineCtls	= IDC_RECORD2L_DITHER - IDC_RECORD1L_DITHER;
	int		nDst		= (nID - IDC_RECORD1L_DITHER) / nLineCtls;
	int		nCh			= nID - (IDC_RECORD1L_DITHER + (nDst * nLineCtls));

	pButton = (CButton *)GetDlgItem( nID );
	
	ulValue = pButton->GetCheck() ? 0 : 1;	// reverse the state of the check box

	m_pHalMixer->SetControl( LINE_RECORD_0 + nDst, LINE_NO_SOURCE, CONTROL_DITHER, nCh, ulValue );
	m_pHalMixer->GetControl( LINE_RECORD_0 + nDst, LINE_NO_SOURCE, CONTROL_DITHER, nCh, &ulValue );
	
	pButton->SetCheck( ulValue );
}

