// AdapterPage.cpp : implementation file
//

#include "stdafx.h"

#include "HalTest.h"
#include "AdapterPage.h"
#include "Hal8420.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CAdapterPage property page

long	glSampleRates[] = { 8000, 11025, 16000, 22050, 32000, 44100, 48000, 64000, 88200, 96000, 128000, 176400, 192000 };
#define NUM_SAMPLE_RATES	(sizeof( glSampleRates ) / sizeof( long ))

char	*gpszClockSource[]		= { "Internal", "Digital", "External", "Header", "Video", "Option Port 1", "Option Port 2" };
char	*gpszClockReference[]	= { "Auto", "13.5MHz", "27MHz", "Word", "Word256" };

HBITMAP	hLEDGreen	= NULL;
HBITMAP	hLEDYellow	= NULL;
HBITMAP	hLEDRed		= NULL;
HBITMAP	hLEDOff		= NULL;

HBITMAP	hForwardOn	= NULL;
HBITMAP	hForwardOff	= NULL;
HBITMAP	hReverseOn	= NULL;
HBITMAP	hReverseOff	= NULL;

IMPLEMENT_DYNCREATE(CAdapterPage, CPropertyPage)

/////////////////////////////////////////////////////////////////////////////
CAdapterPage::CAdapterPage() : CPropertyPage(CAdapterPage::IDD)
/////////////////////////////////////////////////////////////////////////////
{
	//{{AFX_DATA_INIT(CAdapterPage)
	m_nClockSource = -1;
	m_nClockReference = -1;
	//}}AFX_DATA_INIT
	m_pHalAdapter = theApp.m_pHalAdapter;
	m_pHalMixer = theApp.m_pHalMixer;

	for( int i=0; i<8; i++ )
		m_ulRate[ i ] = -1;
}

/////////////////////////////////////////////////////////////////////////////
CAdapterPage::~CAdapterPage()
/////////////////////////////////////////////////////////////////////////////
{
}

/////////////////////////////////////////////////////////////////////////////
void CAdapterPage::DoDataExchange(CDataExchange* pDX)
/////////////////////////////////////////////////////////////////////////////
{
	CPropertyPage::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CAdapterPage)
	DDX_Control(pDX, IDC_CLOCK_REFERENCE, m_ClockReference);
	DDX_Control(pDX, IDC_CLOCK_SOURCE, m_ClockSource);
	DDX_Control(pDX, IDC_SAMPLERATE, m_SampleRate);
	DDX_CBIndex(pDX, IDC_CLOCK_SOURCE, m_nClockSource);
	DDX_CBIndex(pDX, IDC_CLOCK_REFERENCE, m_nClockReference);
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CAdapterPage, CPropertyPage)
	ON_CONTROL_RANGE(BN_CLICKED, IDC_TRIM_AIN12_PLUS4, IDC_TRIM_AOUT34_MINUS10, OnTrimClicked)
	ON_CONTROL_RANGE(BN_CLICKED, IDC_DF_AESEBU, IDC_DF_SPDIF, OnFormatClicked)
	ON_CONTROL_RANGE(BN_CLICKED, IDC_DIGITAL_MODE1, IDC_DIGITAL_MODE5, OnChangeSRC)
	ON_CONTROL_RANGE(BN_CLICKED, IDC_LS1_FCKDIR_OUT, IDC_LS1_FCKDIR_IN, OnLS1FrameClock)
	ON_CONTROL_RANGE(BN_CLICKED, IDC_LS2_FCKDIR_OUT, IDC_LS2_FCKDIR_IN, OnLS2FrameClock)
	ON_CONTROL_RANGE(BN_CLICKED, IDC_LS2_OUTPUT18, IDC_LS2_OUTPUT916, OnLS2OutputSelect)
	ON_CONTROL_RANGE(BN_CLICKED, IDC_LS2_HD1DIR_OUT, IDC_LS2_HD1DIR_IN, OnLS2HD1Direction)
	ON_CONTROL_RANGE(BN_CLICKED, IDC_LS2_HD2DIR_OUT, IDC_LS2_HD2DIR_IN, OnLS2HD2Direction)
	ON_CONTROL_RANGE(BN_CLICKED, IDC_LS2_HDINSEL_HD1, IDC_LS2_HDINSEL_HD2, OnLS2HDInputSelect)
	ON_CONTROL_RANGE(BN_CLICKED, IDC_DITHERTYPE_NONE, IDC_DITHERTYPE_RECTANGULAR, OnDitherType)
	//{{AFX_MSG_MAP(CAdapterPage)
	ON_WM_SHOWWINDOW()
	ON_CBN_SELCHANGE(IDC_SAMPLERATE, OnSelchangeSampleRate)
	ON_CBN_SELCHANGE(IDC_CLOCK_SOURCE, OnSelchangeClockSource)
	ON_CBN_SELCHANGE(IDC_CLOCK_REFERENCE, OnSelchangeClockReference)
	ON_BN_CLICKED(IDC_TCRX_ENABLE, OnTCRxEnable)
	ON_BN_CLICKED(IDC_TCTX_ENABLE, OnTCTxEnable)
	ON_EN_CHANGE(IDC_TX_POSITION, OnChangeTxPosition)
	ON_BN_CLICKED(IDC_DOUT_VALID, OnDOutValid)
	ON_BN_CLICKED(IDC_DOUT_NONAUDIO, OnDOutNonAudio)
	ON_BN_CLICKED(IDC_CALIBRATE, OnCalibrate)
	ON_BN_CLICKED(IDC_DITHERTYPE_NONE, OnDitherType)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CAdapterPage message handlers

/////////////////////////////////////////////////////////////////////////////
BOOL CAdapterPage::OnInitDialog() 
/////////////////////////////////////////////////////////////////////////////
{
	CPropertyPage::OnInitDialog();

	// Create the ToolTip control.
	m_tooltip.Create(this);
	m_tooltip.Activate(TRUE);

	// TODO: Use one of the following forms to add controls:
	// m_tooltip.AddTool(GetDlgItem(IDC_<name>), <string-table-id>);
	//m_tooltip.AddTool(GetDlgItem(IDC_Adapter1_LEFT_VOLUME), IDS_SC_MOVE);

	// fill the sample rate combo box
	CString strSampleRate;
	
	for( int i=0; i<NUM_SAMPLE_RATES; i++ )
	{
		strSampleRate.Format( "%ld", glSampleRates[ i ] );
		m_SampleRate.AddString( strSampleRate );
	}
	
	for( i=0; i<NUM_CLKSRCS; i++ )
		m_ClockSource.AddString( gpszClockSource[ i ] );

	for( i=0; i<NUM_CLKREFS; i++ )
		m_ClockReference.AddString( gpszClockReference[ i ] );

	hLEDRed		= LoadBitmap( AfxGetInstanceHandle(), MAKEINTRESOURCE( IDB_LED_RED ) );
	hLEDYellow	= LoadBitmap( AfxGetInstanceHandle(), MAKEINTRESOURCE( IDB_LED_YELLOW ) );
	hLEDGreen	= LoadBitmap( AfxGetInstanceHandle(), MAKEINTRESOURCE( IDB_LED_GREEN ) );
	hLEDOff		= LoadBitmap( AfxGetInstanceHandle(), MAKEINTRESOURCE( IDB_LED_OFF ) );

	hForwardOn	= LoadBitmap( AfxGetInstanceHandle(), MAKEINTRESOURCE( IDB_FORWARD_ON ) );
	hForwardOff	= LoadBitmap( AfxGetInstanceHandle(), MAKEINTRESOURCE( IDB_FORWARD_OFF ) );
	hReverseOn	= LoadBitmap( AfxGetInstanceHandle(), MAKEINTRESOURCE( IDB_REVERSE_ON ) );
	hReverseOff	= LoadBitmap( AfxGetInstanceHandle(), MAKEINTRESOURCE( IDB_REVERSE_OFF ) );

	return TRUE;  // return TRUE unless you set the focus to a control
	              // EXCEPTION: OCX Property Pages should return FALSE
}

/////////////////////////////////////////////////////////////////////////////
BOOL CAdapterPage::PreTranslateMessage(MSG* pMsg)
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
void CAdapterPage::OnShowWindow(BOOL bShow, UINT nStatus) 
// OnShowWindow with bShow set to TRUE is done before the call to the page losing the focus
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulValue;

	CPropertyPage::OnShowWindow(bShow, nStatus);
	
	if( bShow )
	{
		if( !m_pHalAdapter->IsOpen() )
			return;

		m_pHalMixer->GetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_AIN12_TRIM, 0, &ulValue );
		CheckRadioButton( IDC_TRIM_AIN12_PLUS4, IDC_TRIM_AIN12_MINUS10, IDC_TRIM_AIN12_PLUS4 + ulValue );

		m_pHalMixer->GetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_AIN34_TRIM, 0, &ulValue );
		CheckRadioButton( IDC_TRIM_AIN34_PLUS4, IDC_TRIM_AIN34_MINUS10, IDC_TRIM_AIN34_PLUS4 + ulValue );
		
		m_pHalMixer->GetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_AOUT12_TRIM, 0, &ulValue );
		CheckRadioButton( IDC_TRIM_AOUT12_PLUS4, IDC_TRIM_AOUT12_MINUS10, IDC_TRIM_AOUT12_PLUS4 + ulValue );
		
		m_pHalMixer->GetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_AOUT34_TRIM, 0, &ulValue );
		CheckRadioButton( IDC_TRIM_AOUT34_PLUS4, IDC_TRIM_AOUT34_MINUS10, IDC_TRIM_AOUT34_PLUS4 + ulValue );

		m_pHalMixer->GetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_DIGITAL_FORMAT, 0, &ulValue );
		CheckRadioButton( IDC_DF_AESEBU, IDC_DF_SPDIF, IDC_DF_AESEBU + ulValue );

		m_pHalMixer->GetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_DITHER_TYPE, 0, &ulValue );
		CheckRadioButton( IDC_DITHERTYPE_NONE, IDC_DITHERTYPE_RECTANGULAR, IDC_DITHERTYPE_NONE + ulValue );

		UpdateSampleClock();

		BYTE	ucData;
		m_pHalAdapter->IORead( kOptionIOControl, &ucData );
		
		CheckRadioButton( IDC_LS1_FCKDIR_OUT, IDC_LS1_FCKDIR_IN, (ucData & IO_OPT_OPBFCKDIR) ? IDC_LS1_FCKDIR_IN : IDC_LS1_FCKDIR_OUT );
		CheckRadioButton( IDC_LS2_FCKDIR_OUT, IDC_LS2_FCKDIR_IN, (ucData & IO_OPT_OPHFCKDIR) ? IDC_LS2_FCKDIR_IN : IDC_LS2_FCKDIR_OUT );
		CheckRadioButton( IDC_LS2_OUTPUT18, IDC_LS2_OUTPUT916,	 (ucData & IO_OPT_OPHBLKSEL) ? IDC_LS2_OUTPUT916 : IDC_LS2_OUTPUT18 );
		CheckRadioButton( IDC_LS2_HD1DIR_OUT, IDC_LS2_HD1DIR_IN, (ucData & IO_OPT_OPHD1DIR) ? IDC_LS2_HD1DIR_IN : IDC_LS2_HD1DIR_OUT );
		CheckRadioButton( IDC_LS2_HD2DIR_OUT, IDC_LS2_HD2DIR_IN, (ucData & IO_OPT_OPHD2DIR) ? IDC_LS2_HD2DIR_IN : IDC_LS2_HD2DIR_OUT );
		CheckRadioButton( IDC_LS2_HDINSEL_HD1, IDC_LS2_HDINSEL_HD2, (ucData & IO_OPT_OPHDINSEL) ? IDC_LS2_HDINSEL_HD2 : IDC_LS2_HDINSEL_HD1 );

		m_pHalAdapter->IORead( kMisc, &ucData );
		//((CButton *)GetDlgItem( IDC_VIDEN ))->SetCheck( ucData & IO_MISC_VIDEN ? TRUE : FALSE );

		((CButton *)GetDlgItem( IDC_TCRX_ENABLE ))->SetCheck( m_pHalAdapter->GetTCRx()->IsRunning() );
		((CButton *)GetDlgItem( IDC_TCTX_ENABLE ))->SetCheck( m_pHalAdapter->GetTCTx()->IsRunning() );

		theApp.m_nPage = PAGE_ADAPTER;
		m_ulDigitalInStatus = -1;
		UpdateScreen();
	}
}

/////////////////////////////////////////////////////////////////////////////
char *	FormatRate( ULONG ulRate, char *szRate )
/////////////////////////////////////////////////////////////////////////////
{
	if( ulRate > 1000000 )
		sprintf( szRate, "%3.1lf MHz", ((double)ulRate / 1000000.0) );
	else
	if( ulRate > 1000 )
		sprintf( szRate, "%3.3lf kHz", ((double)ulRate / 1000.0) );
	else
	if( ulRate > 0 )
		sprintf( szRate, "%lu Hz", ulRate );
	else
		sprintf( szRate, "Not Present" );

	return( szRate );
}

/////////////////////////////////////////////////////////////////////////////
void CAdapterPage::UpdateScreen( void )
// If the worker thread is terminating, then the message pump will be gone and
// all of the SetDlgItemText and SetBitmap functions will fail miserably.
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulValue;
	char	szBuffer[ 20 ];
	PHAL8420	pHal8420 = m_pHalAdapter->Get8420();

	if( !m_pHalAdapter->IsOpen() )
		return;

	for( int i=0; i<8; i++ )
	{
		m_pHalMixer->GetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_FREQUENCY_COUNTER_1+i, 0, &ulValue );
		if( m_ulRate[ i ] != ulValue )
		{
			m_ulRate[ i ] = ulValue;
			SetDlgItemText( IDC_FC1+i, FormatRate( ulValue, szBuffer ) );
		}
	}
	
	m_pHalMixer->GetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_DIGITALIN_STATUS, 0, &ulValue );

	if( m_ulDigitalInStatus != ulValue )
	{
		m_ulDigitalInStatus = ulValue;

		// if the digital input is unlocked, skip everything else
		((CStatic *)GetDlgItem( IDC_DIS_LOCK ))->SetBitmap( ulValue & k8420_RxErr_UNLOCK ? hLEDRed : hLEDGreen );	// reversed

		if( ulValue & k8420_RxErr_UNLOCK )
		{
			((CStatic *)GetDlgItem( IDC_DIS_VALID ))->SetBitmap( hLEDOff );
			((CStatic *)GetDlgItem( IDC_DIS_CONFIDENCE ))->SetBitmap( hLEDOff );
			((CStatic *)GetDlgItem( IDC_DIS_PARITY ))->SetBitmap( hLEDOff );
			((CStatic *)GetDlgItem( IDC_DIS_BIPHASE ))->SetBitmap( hLEDOff );
			((CStatic *)GetDlgItem( IDC_DIS_CSCRC ))->SetBitmap( hLEDOff );
			((CStatic *)GetDlgItem( IDC_DIS_QCRC ))->SetBitmap( hLEDOff );

			((CStatic *)GetDlgItem( IDC_DIS_AUDIOn ))->SetBitmap( hLEDOff );
			((CStatic *)GetDlgItem( IDC_DIS_COPY ))->SetBitmap( hLEDOff );
			((CStatic *)GetDlgItem( IDC_DIS_ORIG ))->SetBitmap( hLEDOff );
			
			SetDlgItemText( IDC_DI_MODE, "Unknown" );
			SetDlgItemText( IDC_DI_SAMPLERATE, "Not Present" );
			SetDlgItemText( IDC_SRC_RATIO, "Unknown" );
		}
		else
		{
			((CStatic *)GetDlgItem( IDC_DIS_VALID ))->SetBitmap( ulValue & k8420_RxErr_VAL ? hLEDOff : hLEDGreen );
			((CStatic *)GetDlgItem( IDC_DIS_CONFIDENCE ))->SetBitmap( ulValue & k8420_RxErr_CONF ? hLEDRed : hLEDOff );
			((CStatic *)GetDlgItem( IDC_DIS_PARITY ))->SetBitmap( ulValue & k8420_RxErr_PAR ? hLEDRed : hLEDOff );
			((CStatic *)GetDlgItem( IDC_DIS_BIPHASE ))->SetBitmap( ulValue & k8420_RxErr_BIP ? hLEDRed : hLEDOff );
			((CStatic *)GetDlgItem( IDC_DIS_CSCRC ))->SetBitmap( ulValue & k8420_RxErr_CCRC ? hLEDRed : hLEDOff );
			((CStatic *)GetDlgItem( IDC_DIS_QCRC ))->SetBitmap( ulValue & k8420_RxErr_QCRC ? hLEDRed : hLEDOff );

			// get the digital in channel status data
			ulValue = m_ulDigitalInStatus >> 8;

			((CStatic *)GetDlgItem( IDC_DIS_AUDIOn ))->SetBitmap( ulValue & k8420_RxCS_AUDIOn ? hLEDGreen : hLEDOff );

			if( ulValue & k8420_RxCS_Pro )
			{
				SetDlgItemText( IDC_DI_MODE, "Professional" );
				((CStatic *)GetDlgItem( IDC_DIS_COPY ))->SetBitmap( hLEDOff );
				((CStatic *)GetDlgItem( IDC_DIS_ORIG ))->SetBitmap( hLEDOff );
			}
			else
			{
				SetDlgItemText( IDC_DI_MODE, "Consumer" );
				((CStatic *)GetDlgItem( IDC_DIS_COPY ))->SetBitmap( ulValue & k8420_RxCS_COPY ? hLEDOff : hLEDGreen );
				((CStatic *)GetDlgItem( IDC_DIS_ORIG ))->SetBitmap( ulValue & k8420_RxCS_ORIG ? hLEDGreen : hLEDOff );
			}
		}
	}

	// if digital input is locked
	if( !(m_ulDigitalInStatus & k8420_RxErr_UNLOCK) )
	{
		pHal8420->GetInputSampleRate( (LONG *)&ulValue );
		SetDlgItemText( IDC_DI_SAMPLERATE, FormatRate( ulValue, szBuffer ) );

		// SRC Ratio
		m_pHalMixer->GetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_SRC_RATIO, 0, &ulValue );
		double dRate = (double)((ulValue & 0xC0) >> 6) + ((double)(ulValue & 0x3F) / 64.0);
		sprintf( szBuffer, "%1.3lf : 1", dRate );
		SetDlgItemText( IDC_SRC_RATIO, szBuffer );
	}

	//m_pHalMixer->GetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_LTCIN_ENABLE, 0, &ulValue );
	//if( ulValue )
	{
		TIMECODE	Timecode;
		m_pHalMixer->GetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_LTCIN_POSITION, 0, &Timecode.ulTimecode );
		sprintf( szBuffer, "%02d:%02d:%02d:%02d", 
			Timecode.Bytes.ucHour, Timecode.Bytes.ucMinute, Timecode.Bytes.ucSecond, Timecode.Bytes.ucFrame );
		SetDlgItemText( IDC_RX_POSITION, szBuffer );

		m_pHalMixer->GetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_LTCIN_LOCKED, 0, &ulValue );
		((CStatic *)GetDlgItem( IDC_TCIN_LOCK ))->SetBitmap( ulValue ? hLEDGreen : hLEDOff );

		m_pHalMixer->GetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_LTCIN_DIRECTION, 0, &ulValue );
		((CStatic *)GetDlgItem( IDC_TCIN_REVERSE ))->SetBitmap( ulValue ? hReverseOff : hReverseOn );
		((CStatic *)GetDlgItem( IDC_TCIN_FORWARD ))->SetBitmap( ulValue ? hForwardOn : hForwardOff  );

		m_pHalMixer->GetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_LTCIN_FRAMERATE, 0, &ulValue );
		sprintf( szBuffer, "%2.3lf fps", (double)ulValue / 1000.0 );
		SetDlgItemText( IDC_RX_FRAMERATE, szBuffer );
	}

	m_pHalMixer->GetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_LTCOUT_ENABLE, 0, &ulValue );
	if( ulValue )
	{
		TIMECODE	Timecode;
		m_pHalMixer->GetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_LTCOUT_POSITION, 0, &Timecode.ulTimecode );
		sprintf( szBuffer, "%02d:%02d:%02d:%02d", 
			Timecode.Bytes.ucHour, Timecode.Bytes.ucMinute, Timecode.Bytes.ucSecond, Timecode.Bytes.ucFrame );
		SetDlgItemText( IDC_TX_POSITION, szBuffer );
	}
}

/////////////////////////////////////////////////////////////////////////////
BOOL CAdapterPage::OnApply() 
/////////////////////////////////////////////////////////////////////////////
{
	// do not call the base class
	return( FALSE );
}

/////////////////////////////////////////////////////////////////////////////
void CAdapterPage::UpdateSampleClock()
/////////////////////////////////////////////////////////////////////////////
{
	long	lRate, lSource, lReference;
	ULONG	ulValue;

	m_pHalAdapter->GetSampleClock()->Get( &lRate, &lSource, &lReference );
	m_nClockSource = lSource;
	m_nClockReference = lReference;

	CString strSampleRate;
	strSampleRate.Format( "%ld", lRate );
	m_SampleRate.SetCurSel( m_SampleRate.FindStringExact( 0, strSampleRate ) );

	m_pHalMixer->GetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_SRC_MODE, 0, (PULONG)&ulValue );
	CheckRadioButton( IDC_DIGITAL_MODE1, IDC_DIGITAL_MODE5, IDC_DIGITAL_MODE1 + ulValue );

	UpdateData(FALSE);	// Do the DX to the controls
}

/////////////////////////////////////////////////////////////////////////////
void CAdapterPage::OnSelchangeSampleRate() 
/////////////////////////////////////////////////////////////////////////////
{
	*m_pHalAdapter->GetSampleClock() = glSampleRates[ m_SampleRate.GetCurSel() ];
	UpdateSampleClock();
}

/////////////////////////////////////////////////////////////////////////////
void CAdapterPage::OnSelchangeClockSource() 
/////////////////////////////////////////////////////////////////////////////
{
	m_pHalMixer->SetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_CLOCKSOURCE, 0, m_ClockSource.GetCurSel() );
	UpdateSampleClock();
}

/////////////////////////////////////////////////////////////////////////////
void CAdapterPage::OnSelchangeClockReference() 
/////////////////////////////////////////////////////////////////////////////
{
	m_pHalMixer->SetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_CLOCKREFERENCE, 0, m_ClockReference.GetCurSel() );
	UpdateSampleClock();
}

/////////////////////////////////////////////////////////////////////////////
void CAdapterPage::OnTrimClicked( UINT nID ) 
/////////////////////////////////////////////////////////////////////////////
{
	switch( nID )
	{
	case IDC_TRIM_AIN12_PLUS4:
		m_pHalMixer->SetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_AIN12_TRIM, 0, MIXVAL_TRIM_PLUS4 );
		CheckRadioButton( IDC_TRIM_AIN12_PLUS4, IDC_TRIM_AIN12_MINUS10, nID );
		break;
	case IDC_TRIM_AIN12_MINUS10:
		m_pHalMixer->SetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_AIN12_TRIM, 0, MIXVAL_TRIM_MINUS10 );
		CheckRadioButton( IDC_TRIM_AIN12_PLUS4, IDC_TRIM_AIN12_MINUS10, nID );
		break;
	case IDC_TRIM_AIN34_PLUS4:
		m_pHalMixer->SetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_AIN34_TRIM, 0, MIXVAL_TRIM_PLUS4 );
		CheckRadioButton( IDC_TRIM_AIN34_PLUS4, IDC_TRIM_AIN34_MINUS10, nID );
		break;
	case IDC_TRIM_AIN34_MINUS10:
		m_pHalMixer->SetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_AIN34_TRIM, 0, MIXVAL_TRIM_MINUS10 );
		CheckRadioButton( IDC_TRIM_AIN34_PLUS4, IDC_TRIM_AIN34_MINUS10, nID );
		break;
	case IDC_TRIM_AOUT12_PLUS4:
		m_pHalMixer->SetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_AOUT12_TRIM, 0, MIXVAL_TRIM_PLUS4 );
		CheckRadioButton( IDC_TRIM_AOUT12_PLUS4, IDC_TRIM_AOUT12_MINUS10, nID );
		break;
	case IDC_TRIM_AOUT12_MINUS10:
		m_pHalMixer->SetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_AOUT12_TRIM, 0, MIXVAL_TRIM_MINUS10 );
		CheckRadioButton( IDC_TRIM_AOUT12_PLUS4, IDC_TRIM_AOUT12_MINUS10, nID );
		break;
	case IDC_TRIM_AOUT34_PLUS4:
		m_pHalMixer->SetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_AOUT34_TRIM, 0, MIXVAL_TRIM_PLUS4 );
		CheckRadioButton( IDC_TRIM_AOUT34_PLUS4, IDC_TRIM_AOUT34_MINUS10, nID );
		break;
	case IDC_TRIM_AOUT34_MINUS10:
		m_pHalMixer->SetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_AOUT34_TRIM, 0, MIXVAL_TRIM_MINUS10 );
		CheckRadioButton( IDC_TRIM_AOUT34_PLUS4, IDC_TRIM_AOUT34_MINUS10, nID );
		break;
	}
}

/////////////////////////////////////////////////////////////////////////////
void CAdapterPage::OnFormatClicked( UINT nID ) 
/////////////////////////////////////////////////////////////////////////////
{
	switch( nID )
	{
	case IDC_DF_AESEBU:
		m_pHalMixer->SetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_DIGITAL_FORMAT, 0, MIXVAL_DF_AESEBU );
		CheckRadioButton( IDC_DF_AESEBU, IDC_DF_SPDIF, nID );
		break;
	case IDC_DF_SPDIF:
		m_pHalMixer->SetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_DIGITAL_FORMAT, 0, MIXVAL_DF_SPDIF );
		CheckRadioButton( IDC_DF_AESEBU, IDC_DF_SPDIF, nID );
		break;
	}
}

/////////////////////////////////////////////////////////////////////////////
void CAdapterPage::OnChangeSRC( UINT nID ) 
/////////////////////////////////////////////////////////////////////////////
{
	m_pHalMixer->SetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_SRC_MODE, 0, nID - IDC_DIGITAL_MODE1 );
	UpdateSampleClock();
}

/////////////////////////////////////////////////////////////////////////////
void CAdapterPage::OnTCRxEnable() 
/////////////////////////////////////////////////////////////////////////////
{
	PHALTIMECODE	pTC = m_pHalAdapter->GetTCRx();
	
	if( pTC->IsRunning() )
		pTC->Stop();
	else
		pTC->Start();
}

/////////////////////////////////////////////////////////////////////////////
void CAdapterPage::OnTCTxEnable() 
/////////////////////////////////////////////////////////////////////////////
{
	PHALTIMECODE	pTC = m_pHalAdapter->GetTCTx();
	
	if( pTC->IsRunning() )
		pTC->Stop();
	else
		pTC->Start();
}

/////////////////////////////////////////////////////////////////////////////
void CAdapterPage::OnChangeTxPosition() 
/////////////////////////////////////////////////////////////////////////////
{
	PHALTIMECODE	pTC = m_pHalAdapter->GetTCTx();
	char			szTimecode[ 40 ];
	TIMECODE		Timecode;
	char			*pszHrs, *pszMin, *pszSec, *pszFrm;

	if( pTC->IsRunning() )
		return;
	
	GetDlgItemText( IDC_TX_POSITION, szTimecode, sizeof( szTimecode ) );

	Timecode.ulTimecode = 0;

	pszHrs = strtok( szTimecode, ":" );
	pszMin = strtok( NULL, ":" );
	pszSec = strtok( NULL, ":" );
	pszFrm = strtok( NULL, ":" );

	if( pszHrs )
		Timecode.Bytes.ucHour		= atoi( pszHrs ) & 0x1F;
	if( pszMin )
		Timecode.Bytes.ucMinute	= atoi( pszMin ) & 0x3F;
	if( pszSec )
		Timecode.Bytes.ucSecond	= atoi( pszSec ) & 0x3F;
	if( pszFrm )
		Timecode.Bytes.ucFrame	= atoi( pszFrm ) & 0x1F;

	pTC->SetPosition( Timecode.ulTimecode );
}

/////////////////////////////////////////////////////////////////////////////
void CAdapterPage::OnLS1FrameClock( UINT nID ) 
/////////////////////////////////////////////////////////////////////////////
{
	switch( nID )
	{
	case IDC_LS1_FCKDIR_OUT:
		m_pHalAdapter->IOWrite( kOptionIOControl, (BYTE)0, IO_OPT_OPBFCKDIR );
		break;
	case IDC_LS1_FCKDIR_IN:
		m_pHalAdapter->IOWrite( kOptionIOControl, IO_OPT_OPBFCKDIR, IO_OPT_OPBFCKDIR );
		break;
	}
}

/////////////////////////////////////////////////////////////////////////////
void CAdapterPage::OnLS2FrameClock( UINT nID ) 
/////////////////////////////////////////////////////////////////////////////
{
	switch( nID )
	{
	case IDC_LS2_FCKDIR_OUT:
		m_pHalAdapter->IOWrite( kOptionIOControl, (BYTE)0, IO_OPT_OPHFCKDIR );
		break;
	case IDC_LS2_FCKDIR_IN:
		m_pHalAdapter->IOWrite( kOptionIOControl, IO_OPT_OPHFCKDIR, IO_OPT_OPHFCKDIR );
		break;
	}
}

/////////////////////////////////////////////////////////////////////////////
void CAdapterPage::OnLS2OutputSelect( UINT nID )
/////////////////////////////////////////////////////////////////////////////
{
	switch( nID )
	{
	case IDC_LS2_OUTPUT18:
		m_pHalAdapter->IOWrite( kOptionIOControl, (BYTE)0, IO_OPT_OPHBLKSEL );
		break;
	case IDC_LS2_OUTPUT916:
		m_pHalAdapter->IOWrite( kOptionIOControl, IO_OPT_OPHBLKSEL, IO_OPT_OPHBLKSEL );
		break;
	}
}

/////////////////////////////////////////////////////////////////////////////
void CAdapterPage::OnLS2HD1Direction( UINT nID ) 
/////////////////////////////////////////////////////////////////////////////
{
	switch( nID )
	{
	case IDC_LS2_HD1DIR_OUT:
		m_pHalAdapter->IOWrite( kOptionIOControl, (BYTE)0, IO_OPT_OPHD1DIR );
		break;
	case IDC_LS2_HD1DIR_IN:
		m_pHalAdapter->IOWrite( kOptionIOControl, IO_OPT_OPHD1DIR, IO_OPT_OPHD1DIR );
		break;
	}	
}

/////////////////////////////////////////////////////////////////////////////
void CAdapterPage::OnLS2HD2Direction( UINT nID ) 
/////////////////////////////////////////////////////////////////////////////
{
	switch( nID )
	{
	case IDC_LS2_HD2DIR_OUT:
		m_pHalAdapter->IOWrite( kOptionIOControl, (BYTE)0, IO_OPT_OPHD2DIR );
		break;
	case IDC_LS2_HD2DIR_IN:
		m_pHalAdapter->IOWrite( kOptionIOControl, IO_OPT_OPHD2DIR, IO_OPT_OPHD2DIR );
		break;
	}	
}

/////////////////////////////////////////////////////////////////////////////
void CAdapterPage::OnLS2HDInputSelect( UINT nID ) 
/////////////////////////////////////////////////////////////////////////////
{
	switch( nID )
	{
	case IDC_LS2_HDINSEL_HD1:
		m_pHalAdapter->IOWrite( kOptionIOControl, (BYTE)0, IO_OPT_OPHDINSEL );
		break;
	case IDC_LS2_HDINSEL_HD2:
		m_pHalAdapter->IOWrite( kOptionIOControl, IO_OPT_OPHDINSEL, IO_OPT_OPHDINSEL );
		break;
	}	
}

/////////////////////////////////////////////////////////////////////////////
void CAdapterPage::OnDOutValid() 
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulStatus;
	BOOLEAN bValid = ((CButton *)GetDlgItem( IDC_DOUT_VALID ))->GetCheck();

	ulStatus = m_pHalAdapter->Get8420()->GetOutputStatus();
	if( bValid )
		SET( ulStatus, MIXVAL_OUTSTATUS_VALID );
	else
		CLR( ulStatus, MIXVAL_OUTSTATUS_VALID );
	m_pHalAdapter->Get8420()->SetOutputStatus( ulStatus );
}

/////////////////////////////////////////////////////////////////////////////
void CAdapterPage::OnDOutNonAudio() 
/////////////////////////////////////////////////////////////////////////////
{
	BOOLEAN bNonAudio = ((CButton *)GetDlgItem( IDC_DOUT_NONAUDIO ))->GetCheck();

	m_pHalAdapter->Get8420()->SetOutputNonAudio( bNonAudio );
}

/////////////////////////////////////////////////////////////////////////////
void CAdapterPage::OnDitherType( UINT nID )
/////////////////////////////////////////////////////////////////////////////
{
	m_pHalMixer->SetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_DITHER_TYPE, 0, nID - IDC_DITHERTYPE_NONE );
	/*
	switch( nID )
	{
	case IDC_DITHERTYPE_NONE:
		break;
	case IDC_DITHERTYPE_TRIANGULAR:
		break;
	case IDC_DITHERTYPE_TRIANGULAR_HIPASS:
		break;
	case IDC_DITHERTYPE_RECTANGULAR:
		break;
	}
	*/
}

/////////////////////////////////////////////////////////////////////////////
void CAdapterPage::OnCalibrate() 
/////////////////////////////////////////////////////////////////////////////
{
	BYTE	RxBuffer[24];

	m_pHalAdapter->Get8420()->ReadCUBuffer( RxBuffer );

	for( int i=0; i<sizeof( RxBuffer ); i++ )
	{
		DPF(("%02x ", RxBuffer[i] ));
	}
	DPF(("\n"));
}

