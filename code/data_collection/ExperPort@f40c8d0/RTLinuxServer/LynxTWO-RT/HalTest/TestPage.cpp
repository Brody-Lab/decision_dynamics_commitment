// TestPage.cpp : implementation file
//

#include "StdAfx.h"
#include "HalTest.h"
#include "HalTestDlg.h"
#include "TestPage.h"
#include "Fader.h"
#include "VUMeter.h"

#include "WaveFile.h"
#include "HalWaveDevice.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

#include "PCIBios.h"
#include "VendorID.h"
#include "Callback.h"

USHORT	FindAdapter( PVOID pContext, PPCI_CONFIGURATION pPCI );
USHORT	MapAdapter( PVOID pContext, PPCI_CONFIGURATION pPCI );
USHORT	UnmapAdapter( PVOID pContext, PPCI_CONFIGURATION pPCI );
USHORT	AllocateMemory( PVOID *pObject, PVOID *pVAddr, PVOID *pPAddr, ULONG ulLength, ULONG ulAddressMask );
USHORT	FreeMemory( PVOID pObject, PVOID pVAddr );

enum
{
	COLUMN_VENDORNAME = 0,
	COLUMN_BUS,
	COLUMN_DEVICE,
	COLUMN_VENDORID,
	COLUMN_DEVICEID,
	COLUMN_IRQ,
	COLUMN_BAR0,
	COLUMN_BAR1,
	COLUMN_BAR2,
	COLUMN_BAR3,
	COLUMN_BAR4,
	NUM_COLUMNS
};

char	*gpszColumnTitles[]		= { "Vendor Name", "Bus", "Device", "Vendor ID", "Device ID", "IRQ", "BAR0", "BAR1", "BAR2", "BAR3", "BAR4" };

/////////////////////////////////////////////////////////////////////////////
// CTestPage property page

IMPLEMENT_DYNCREATE(CTestPage, CPropertyPage)

/////////////////////////////////////////////////////////////////////////////
CTestPage::CTestPage() : CPropertyPage(CTestPage::IDD)
/////////////////////////////////////////////////////////////////////////////
{
	//{{AFX_DATA_INIT(CTestPage)
	m_bRepeat = FALSE;
	//}}AFX_DATA_INIT
	m_pHalAdapter = theApp.m_pHalAdapter;
	m_pHalMixer = theApp.m_pHalMixer;
	m_nPlayMode = MODE_STOP;
	m_nRecordMode = MODE_STOP;
	strcpy( m_szFileName, "" );
}

/////////////////////////////////////////////////////////////////////////////
CTestPage::~CTestPage()
/////////////////////////////////////////////////////////////////////////////
{
}

/////////////////////////////////////////////////////////////////////////////
void CTestPage::DoDataExchange(CDataExchange* pDX)
/////////////////////////////////////////////////////////////////////////////
{
	CPropertyPage::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CTestPage)
	DDX_Control(pDX, IDC_RECORDDEVICE, m_RecordDevice);
	DDX_Control(pDX, IDC_PLAYDEVICE, m_PlayDevice);
	DDX_Control(pDX, IDC_DEVICELIST, m_DeviceList);
	DDX_Check(pDX, IDC_REPEAT, m_bRepeat);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CTestPage, CPropertyPage)
	//{{AFX_MSG_MAP(CTestPage)
	ON_BN_CLICKED(IDC_FIND, OnFind)
	ON_BN_CLICKED(IDC_OPEN, OnOpen)
	ON_NOTIFY(NM_CLICK, IDC_DEVICELIST, OnClickDeviceList)
	ON_BN_CLICKED(IDC_REFRESH, OnRefresh)
	ON_BN_CLICKED(IDC_SAVE, OnSave)
	ON_BN_CLICKED(IDC_RESTORE, OnRestore)
	ON_WM_VSCROLL()
	ON_BN_CLICKED(IDC_CLOSE, OnClose)
	ON_BN_CLICKED(IDC_PLAY, OnPlay)
	ON_WM_SHOWWINDOW()
	ON_BN_CLICKED(IDC_REPEAT, OnRepeat)
	ON_WM_TIMER()
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_BN_CLICKED(IDC_RECORD, OnRecord)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CTestPage message handlers

/////////////////////////////////////////////////////////////////////////////
BOOL CTestPage::OnInitDialog() 
/////////////////////////////////////////////////////////////////////////////
{
	CTestPage*	pDlg = (CTestPage*)theApp.m_pMainWnd;
	m_pHalAdapter = theApp.m_pHalAdapter;
	m_pHalMixer = theApp.m_pHalMixer;

	CPropertyPage::OnInitDialog();

	// Create the ToolTip control.
	m_tooltip.Create(this);
	m_tooltip.Activate(TRUE);

	for( int i=0;i<NUM_COLUMNS;i++ )
	{
		m_DeviceList.InsertColumn( i, gpszColumnTitles[i] );
	}

	int nColumnCount = m_DeviceList.GetHeaderCtrl()->GetItemCount();
	for( i=0;i<nColumnCount;i++ )
	{
		m_DeviceList.SetColumnWidth( i, LVSCW_AUTOSIZE_USEHEADER );
	}

	//CWnd *pCtl = GetDlgItem(IDC_PLAY1L_VOLUME);
	//FaderSetRange( pCtl->m_hWnd, MIN_VOLUME, MAX_VOLUME );
	//FaderSetPosition( pCtl->m_hWnd, MAX_VOLUME );
	//m_tooltip.AddTool( pCtl, IDS_TT_VOLUME);
	
	//pCtl = GetDlgItem(IDC_PLAY1R_VOLUME);
	//FaderSetRange( pCtl->m_hWnd, MIN_VOLUME, MAX_VOLUME );
	//FaderSetPosition( pCtl->m_hWnd, MAX_VOLUME );
	//m_tooltip.AddTool( pCtl, IDS_TT_VOLUME);

	CString	DeviceName;

	for( i=0; i<8; i++ )
	{
		DeviceName.Format( "Play %d", i+1 );
		m_PlayDevice.AddString( DeviceName );

		DeviceName.Format( "Record %d", i+1 );
		m_RecordDevice.AddString( DeviceName );
	}
	
	m_PlayDevice.SetCurSel( 0 );
	m_RecordDevice.SetCurSel( 0 );

	OnRefresh();

	return TRUE;  // return TRUE unless you set the focus to a control
	              // EXCEPTION: OCX Property Pages should return FALSE
}

/////////////////////////////////////////////////////////////////////////////
void CTestPage::OnShowWindow(BOOL bShow, UINT nStatus) 
/////////////////////////////////////////////////////////////////////////////
{
	CPropertyPage::OnShowWindow(bShow, nStatus);
	
	if( bShow )
	{
		theApp.m_nPage = PAGE_TEST;
		//SetTimer( 1, 1, NULL );
	}
	else
	{
		//KillTimer( 1 );
	}
}

/////////////////////////////////////////////////////////////////////////////
void CTestPage::UpdateMeters( void )
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulValue;

	int nRecordDevice	= m_RecordDevice.GetCurSel();
	int nPlayDevice		= m_PlayDevice.GetCurSel();

	// go get the VU meters information
	m_pHalMixer->GetControl( LINE_RECORD_0+nRecordDevice, LINE_NO_SOURCE, CONTROL_PEAKMETER, LEFT, &ulValue );
	VUSetDlgLevel( m_hWnd, IDC_RECORD1L_VUMETER, ulValue );
	m_pHalMixer->GetControl( LINE_RECORD_0+nRecordDevice, LINE_NO_SOURCE, CONTROL_PEAKMETER, RIGHT, &ulValue );
	VUSetDlgLevel( m_hWnd, IDC_RECORD1R_VUMETER, ulValue );

	m_pHalMixer->GetControl( LINE_OUT_1+nPlayDevice, LINE_NO_SOURCE, CONTROL_PEAKMETER, 0, &ulValue );
	VUSetDlgLevel( m_hWnd, IDC_OUT1_VUMETER, ulValue );
	m_pHalMixer->GetControl( LINE_OUT_2+nPlayDevice, LINE_NO_SOURCE, CONTROL_PEAKMETER, 0, &ulValue );
	VUSetDlgLevel( m_hWnd, IDC_OUT2_VUMETER, ulValue );
}

/////////////////////////////////////////////////////////////////////////////
void CTestPage::OnFind() 
/////////////////////////////////////////////////////////////////////////////
{
	USHORT			usStatus;
	usStatus = m_pHalAdapter->Find();
	if( usStatus )
	{
		MessageBox( "OnFind:Find Failed!" );
	}
	else
	{
		MessageBox( "Found Device!" );
	}
}

/////////////////////////////////////////////////////////////////////////////
void CTestPage::OnOpen() 
/////////////////////////////////////////////////////////////////////////////
{
	USHORT	usStatus;
	PHALWAVEDEVICE	pHD;
	ULONG			i;

	if( !m_pHalAdapter->IsOpen() )
	{
		for( i=0; i<m_pHalAdapter->GetNumWaveDevices(); i++ )
		{
			pHD = m_pHalAdapter->GetWaveDevice( i );
			pHD->RegisterCallback( InterruptCallback, this, pHD );
		}

		usStatus = m_pHalAdapter->Open();
		if( usStatus )
		{
			MessageBox( "Open Failed!" );
			return;
		}

		for( i=0; i<m_pHalAdapter->GetNumWaveDevices(); i++ )
		{
			pHD = m_pHalAdapter->GetWaveDevice( i );
			pHD->RegisterCallback( InterruptCallback, this, pHD );
		}
	}
	else
	{
		MessageBox( "Adapter is open!" );
	}

	// Route the RECORD_3 source to OUT1 (This routes DIGITAL IN->ANALOGOUT DAC A)
	//m_pHalMixer->SetControl( LINE_OUT_1, LINE_PLAY_MIXB, CONTROL_SOURCE, 0, MIXVAL_PMIXSRC_RECORD2L );	// Digital In L
	//m_pHalMixer->SetControl( LINE_OUT_2, LINE_PLAY_MIXB, CONTROL_SOURCE, 0, MIXVAL_PMIXSRC_RECORD2R );	// Digital In R

	//m_pHalMixer->SetControl( LINE_OUT_3, LINE_PLAY_MIXA, CONTROL_SOURCE, 0, MIXVAL_PMIXSRC_PLAY0L );
	//m_pHalMixer->SetControl( LINE_OUT_4, LINE_PLAY_MIXA, CONTROL_SOURCE, 0, MIXVAL_PMIXSRC_PLAY0R );
	//m_pHalMixer->SetControl( LINE_OUT_5, LINE_PLAY_MIXA, CONTROL_SOURCE, 0, MIXVAL_PMIXSRC_PLAY0L );
	//m_pHalMixer->SetControl( LINE_OUT_6, LINE_PLAY_MIXA, CONTROL_SOURCE, 0, MIXVAL_PMIXSRC_PLAY0R );

	// mute the monitor's
	//m_pHalMixer->SetControl( LINE_OUT_1, LINE_PLAY_MIXD, CONTROL_MUTE, 0, TRUE );
	//m_pHalMixer->SetControl( LINE_OUT_2, LINE_PLAY_MIXD, CONTROL_MUTE, 0, TRUE );
	//m_pHalMixer->SetControl( LINE_OUT_3, LINE_PLAY_MIXD, CONTROL_MUTE, 0, TRUE );
	//m_pHalMixer->SetControl( LINE_OUT_4, LINE_PLAY_MIXD, CONTROL_MUTE, 0, TRUE );
	//m_pHalMixer->SetControl( LINE_OUT_5, LINE_PLAY_MIXD, CONTROL_MUTE, 0, TRUE );
	//m_pHalMixer->SetControl( LINE_OUT_6, LINE_PLAY_MIXD, CONTROL_MUTE, 0, TRUE );

	// Turn off the mutes so we can hear it
	//m_pHalMixer->SetControl( LINE_OUT_1, LINE_PLAY_MIXB, CONTROL_MUTE, 0, FALSE );
	//m_pHalMixer->SetControl( LINE_OUT_2, LINE_PLAY_MIXB, CONTROL_MUTE, 0, FALSE );

	// set the digital in mode to loopback
	//m_pHalMixer->SetControl( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_DIGITAL_MODE, 0, MIXVAL_DIGITAL_MODE_2 );

	// set all trims to -10dBV
	//m_pHalMixer->SetControl( LINE_RECORD_0, LINE_IN_1, CONTROL_TRIM, 0, MIXVAL_TRIM_MINUS10 );
	//m_pHalMixer->SetControl( LINE_RECORD_0, LINE_IN_3, CONTROL_TRIM, 0, MIXVAL_TRIM_MINUS10 );
	//m_pHalMixer->SetControl( LINE_OUT_1, LINE_NO_SOURCE, CONTROL_TRIM, 0, MIXVAL_TRIM_MINUS10 );
	//m_pHalMixer->SetControl( LINE_OUT_3, LINE_NO_SOURCE, CONTROL_TRIM, 0, MIXVAL_TRIM_MINUS10 );
	
	// turn on the LTC Rx & Tx
	//m_pHalAdapter->GetTCRx()->Start();
	//m_pHalAdapter->GetTCTx()->Start();
}

/////////////////////////////////////////////////////////////////////////////
void CTestPage::OnClose() 
/////////////////////////////////////////////////////////////////////////////
{
	if( m_pHalAdapter->IsOpen() )
		m_pHalAdapter->Close();
	else
		MessageBox( "Adapter is closed!" );
}

/////////////////////////////////////////////////////////////////////////////
void CTestPage::OnClickDeviceList(NMHDR* pNMHDR, LRESULT* pResult) 
/////////////////////////////////////////////////////////////////////////////
{
	// TODO: Add your control notification handler code here
	*pResult = 0;
}

/////////////////////////////////////////////////////////////////////////////
char * CTestPage::GetVendorName( USHORT usVendorID, USHORT usDeviceID )
/////////////////////////////////////////////////////////////////////////////
{
	int	i=0;

	if( usVendorID == PCIVENDOR_PLX )
	{
		if( usDeviceID == PCIDEVICE_LYNXONE )
			return( "** LynxONE **" );

		if( usDeviceID == PCIDEVICE_PLX_9050 )
			return( "** Unprogrammed LynxONE **" );
	}
	if( usVendorID == PCIVENDOR_LYNX )
	{
		if( usDeviceID == PCIDEVICE_LYNXTWO_A )
			return( "** LynxTWO-A **" );
		if( usDeviceID == PCIDEVICE_LYNXTWO_B )
			return( "** LynxTWO-B **" );
		if( usDeviceID == PCIDEVICE_LYNXTWO_C )
			return( "** LynxTWO-C **" );
		if( usDeviceID == PCIDEVICE_LYNX_L22 )
			return( "** Lynx L22 **" );
	}

	while( gPCIVendorInfo[ i ].usVendorID != 0xFFFF )
	{
		if( gPCIVendorInfo[ i ].usVendorID == usVendorID )
			return( gPCIVendorInfo[ i ].pszName );
		i++;
	}
	return( "" );
}

/////////////////////////////////////////////////////////////////////////////
void CTestPage::OnRefresh() 
/////////////////////////////////////////////////////////////////////////////
{
#ifdef USEHARDWARE
	ULONG	ulVendorID;
	ULONG	ulDeviceID;
	ULONG	ulInterruptLine;
	ULONG	ulBAR[ PCI_TYPE0_ADDRESSES ];
	BYTE	ucBusNumber;
	BYTE	ucDeviceFunction;
	BYTE	ucDevice;
	int		iItem = 0;
	int		i;

	// no painting during change
	LockWindowUpdate();

	m_DeviceList.DeleteAllItems();
	
	for( ucBusNumber=0; ucBusNumber<0xFF; ucBusNumber++ )
	{
		for( ucDevice=0; ucDevice<0x1F; ucDevice++ )
		{
			ucDeviceFunction = ucDevice << 3;
			
			ReadConfigurationArea( READ_CONFIG_WORD, ucBusNumber, ucDeviceFunction, PCI_CS_VENDOR_ID, &ulVendorID );
			ulVendorID &= 0xFFFF;
			if( ulVendorID == 0xFFFF )
				continue;
			
			ReadConfigurationArea( READ_CONFIG_WORD, ucBusNumber, ucDeviceFunction, PCI_CS_DEVICE_ID, &ulDeviceID );
			ulDeviceID &= 0xFFFF;
			if( ulDeviceID == 0xFFFF )
				continue;
			
			CString strText;
			
			// Insert items in the list view control.
			m_DeviceList.InsertItem( iItem, GetVendorName( (USHORT)ulVendorID, (USHORT)ulDeviceID ) );

			strText.Format( "%d", ucBusNumber );
			m_DeviceList.SetItemText( iItem, COLUMN_BUS, strText );

			strText.Format( "%2d", ucDevice );
			m_DeviceList.SetItemText( iItem, COLUMN_DEVICE, strText );

			strText.Format( "%04lx", ulVendorID );
			m_DeviceList.SetItemText( iItem, COLUMN_VENDORID, strText );

			strText.Format( "%04lx", ulDeviceID );
			m_DeviceList.SetItemText( iItem, COLUMN_DEVICEID, strText );

			ReadConfigurationArea( READ_CONFIG_BYTE, ucBusNumber, ucDeviceFunction, PCI_CS_INTERRUPT_LINE, &ulInterruptLine );
			ulInterruptLine &= 0xFF;
			strText.Format( "%2ld", ulInterruptLine );
			m_DeviceList.SetItemText( iItem, COLUMN_IRQ, strText );

			for( i=0; i<PCI_TYPE0_ADDRESSES; i++ )
			{
				ReadConfigurationArea( 
					READ_CONFIG_DWORD, 
					ucBusNumber, ucDeviceFunction, 
					PCI_CS_BASE_ADDRESS_0+(i*sizeof(DWORD)), 
					&ulBAR[ i ] );

				strText.Format( "%08lx", ulBAR[ i ] );
				m_DeviceList.SetItemText( iItem, COLUMN_BAR0+i, strText );
			}

			iItem++;
		}
	}

	m_DeviceList.SetColumnWidth( COLUMN_VENDORNAME, LVSCW_AUTOSIZE );
	for( i=0; i<PCI_TYPE0_ADDRESSES; i++ )
	{
		m_DeviceList.SetColumnWidth( COLUMN_BAR0+i, LVSCW_AUTOSIZE );
	}

	// repaint changes
	UnlockWindowUpdate();
#else
	m_DeviceList.InsertItem( 0, "Use Hardware is OFF" );
	m_DeviceList.SetColumnWidth( COLUMN_VENDORNAME, LVSCW_AUTOSIZE );
#endif
}


#define REG_STR_PATH	TEXT("Software\\Lynx\\HalTest\\Bus %d Device %d")

/////////////////////////////////////////////////////////////////////////////
BOOLEAN CTestPage::SavePCIConfiguration( BYTE ucBusNumber, BYTE ucDevice )
/////////////////////////////////////////////////////////////////////////////
{
#ifdef USEHARDWARE
	HKEY	hKey;
	DWORD	dwDisposition;
	ULONG	ulValue;
	BYTE	ucDeviceFunction;
	int		i;
	char	szBuffer[ 128 ];

	sprintf( szBuffer, REG_STR_PATH, ucBusNumber, ucDevice );

	ucDeviceFunction = ucDevice << 3;

	RegCreateKeyEx( HKEY_CURRENT_USER, szBuffer, 0, NULL, REG_OPTION_NON_VOLATILE, KEY_ALL_ACCESS, NULL, &hKey, &dwDisposition );

	ReadConfigurationArea( READ_CONFIG_BYTE, ucBusNumber, ucDeviceFunction, PCI_CS_CACHE_LINE_SIZE, &ulValue );
	ulValue &= 0xFF;
	RegSetValueEx( hKey, "CacheLineSize", 0, REG_DWORD, (LPBYTE)&ulValue, sizeof( ULONG ) );

	ReadConfigurationArea( READ_CONFIG_BYTE, ucBusNumber, ucDeviceFunction, PCI_CS_MASTER_LATENCY, &ulValue );
	ulValue &= 0xFF;
	RegSetValueEx( hKey, "MasterLatency", 0, REG_DWORD, (LPBYTE)&ulValue, sizeof( ULONG ) );

	for( i=0; i<PCI_TYPE0_ADDRESSES; i++ )
	{
		ReadConfigurationArea( 
			READ_CONFIG_DWORD, 
			ucBusNumber, ucDeviceFunction, 
			PCI_CS_BASE_ADDRESS_0+(i*sizeof(ULONG)), 
			&ulValue );
		sprintf( szBuffer, "BAR%d", i );
		RegSetValueEx( hKey, szBuffer, 0, REG_DWORD, (LPBYTE)&ulValue, sizeof( ULONG ) );
	}

	ReadConfigurationArea( READ_CONFIG_BYTE, ucBusNumber, ucDeviceFunction, PCI_CS_INTERRUPT_LINE, &ulValue );
	ulValue &= 0xFF;
	RegSetValueEx( hKey, "InterruptLine", 0, REG_DWORD, (LPBYTE)&ulValue, sizeof( ULONG ) );

	RegFlushKey( hKey );
	RegCloseKey( hKey );

#endif
	return( TRUE );
}

/////////////////////////////////////////////////////////////////////////////
BOOLEAN CTestPage::RestorePCIConfiguration( BYTE ucBusNumber, BYTE ucDevice )
/////////////////////////////////////////////////////////////////////////////
{
#ifdef USEHARDWARE
	ULONG	ulValue;
	BYTE	ucDeviceFunction;
	int		i;
	HKEY	hKey;
	LONG	ReturnCode;
	ULONG	ulKeySize;
	ULONG	ulType;
	char	szBuffer[ 128 ];

	sprintf( szBuffer, REG_STR_PATH, ucBusNumber, ucDevice );

	ucDeviceFunction = ucDevice << 3;

	//TEST
	//for( i=0; i<0x40; i+=sizeof(ULONG) )
	//{
	//	ReadConfigurationArea( READ_CONFIG_DWORD, ucBusNumber, ucDeviceFunction, i, &ulValue );
	//	DPF(("%02x %08lx\n", i, ulValue ));
	//}
	//TEST

	ReturnCode = RegOpenKeyEx( HKEY_CURRENT_USER, szBuffer, 0, KEY_ALL_ACCESS, &hKey );
	if( ReturnCode )
		return( FALSE );
	
	ulKeySize = sizeof( ULONG );
	ulType = REG_DWORD;
	ReturnCode = RegQueryValueEx( hKey, "CacheLineSize", 0, &ulType, (LPBYTE)&ulValue, &ulKeySize );
	if( !ReturnCode )
	{
		WriteConfigurationArea( WRITE_CONFIG_BYTE, ucBusNumber, ucDeviceFunction, PCI_CS_CACHE_LINE_SIZE, ulValue );
	}

	ulKeySize = sizeof( ULONG );
	ulType = REG_DWORD;
	ReturnCode = RegQueryValueEx( hKey, "MasterLatency", 0, &ulType, (LPBYTE)&ulValue, &ulKeySize );
	if( !ReturnCode )
	{
		WriteConfigurationArea( WRITE_CONFIG_BYTE, ucBusNumber, ucDeviceFunction, PCI_CS_MASTER_LATENCY, ulValue );
	}

	for( i=0; i<PCI_TYPE0_ADDRESSES; i++ )
	{
		ulKeySize = sizeof( ULONG );
		ulType = REG_DWORD;

		sprintf( szBuffer, "BAR%d", i );
		
		ReturnCode = RegQueryValueEx( hKey, szBuffer, 0, &ulType, (LPBYTE)&ulValue, &ulKeySize );
		if( !ReturnCode )
		{
			WriteConfigurationArea( 
				WRITE_CONFIG_DWORD, 
				ucBusNumber, ucDeviceFunction, 
				PCI_CS_BASE_ADDRESS_0+(i*sizeof(ULONG)), 
				ulValue );
		}
	}

	ulKeySize = sizeof( ULONG );
	ulType = REG_DWORD;
	ReturnCode = RegQueryValueEx( hKey, "InterruptLine", 0, &ulType, (LPBYTE)&ulValue, &ulKeySize );
	if( !ReturnCode )
	{
		WriteConfigurationArea( WRITE_CONFIG_BYTE, ucBusNumber, ucDeviceFunction, PCI_CS_INTERRUPT_LINE, ulValue );
	}

	RegCloseKey( hKey );
#endif
	return( TRUE );
}

/////////////////////////////////////////////////////////////////////////////
void CTestPage::OnSave() 
/////////////////////////////////////////////////////////////////////////////
{
	int	nSelectedCount = m_DeviceList.GetSelectedCount();
	int	nItem = -1;
	int	i;
	BYTE	ucBus, ucDevice;
	char	szBuffer[ 8 ];
	
	// Update all of the selected items.
	if( nSelectedCount > 0 )
	{
		for( i=0; i<nSelectedCount; i++ )
		{
			nItem = m_DeviceList.GetNextItem( nItem, LVNI_SELECTED );
			m_DeviceList.GetItemText( nItem, COLUMN_BUS, szBuffer, sizeof( szBuffer ) );
			ucBus = atoi( szBuffer );
			m_DeviceList.GetItemText( nItem, COLUMN_DEVICE, szBuffer, sizeof( szBuffer ) );
			ucDevice = atoi( szBuffer );
			SavePCIConfiguration( ucBus, ucDevice );
			m_DeviceList.Update( nItem ); 
		}
	}
}

/////////////////////////////////////////////////////////////////////////////
void CTestPage::OnRestore() 
/////////////////////////////////////////////////////////////////////////////
{
	int	nSelectedCount = m_DeviceList.GetSelectedCount();
	int	nItem = -1;
	int	i;
	BYTE	ucBus, ucDevice;
	char	szBuffer[ 8 ];
	
	// Update all of the selected items.
	if( nSelectedCount > 0 )
	{
		for( i=0; i<nSelectedCount; i++ )
		{
			nItem = m_DeviceList.GetNextItem( nItem, LVNI_SELECTED );
			m_DeviceList.GetItemText( nItem, COLUMN_BUS, szBuffer, sizeof( szBuffer ) );
			ucBus = atoi( szBuffer );
			m_DeviceList.GetItemText( nItem, COLUMN_DEVICE, szBuffer, sizeof( szBuffer ) );
			ucDevice = atoi( szBuffer );
			RestorePCIConfiguration( ucBus, ucDevice );
			m_DeviceList.Update( nItem ); 
		}
	}
	
	OnRefresh();
}

/////////////////////////////////////////////////////////////////////////////
void CTestPage::OnVScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar) 
/////////////////////////////////////////////////////////////////////////////
{
	USHORT	wPos = (USHORT)nPos;
	int		nChange = 0, nAbs;
	int		nVolume;
	int		nID = GetWindowLong( pScrollBar->m_hWnd, GWL_ID );
	int		nCh;

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

	//switch( nID )
	//{
	//case IDC_PLAY1L_VOLUME:	nCh = LEFT;		break;
	//case IDC_PLAY1R_VOLUME:	nCh = RIGHT;	break;
	//}
	nCh = LEFT;

	m_pHalMixer->SetControl( LINE_OUT_1, LINE_PLAY_0 + m_PlayDevice.GetCurSel(), CONTROL_VOLUME, nCh, nVolume );
	
	((CHalTestDlg *)GetParent())->ShowVolume( nVolume );
	
	FaderSetPosition( pScrollBar->m_hWnd, nVolume );
}

/////////////////////////////////////////////////////////////////////////////
void CTestPage::OnPlay() 
/////////////////////////////////////////////////////////////////////////////
{
	static char BASED_CODE szFilter[] = "Wave Files(*.wav)|*.wav|All Files(*.*)|*.*||";
	char	szInitialDir[ _MAX_PATH ];
	char	szFileName[ _MAX_PATH ];

	UpdateData( TRUE );	// Get data from the controls

	if( !m_pHalAdapter->IsOpen() )
	{
		MessageBox( "Must Open Adapter First!" );
		return;
	}

 	if( m_nPlayMode == MODE_STOP )
	{
		// Pop up the file dialog box
		CFileDialog	dlg( TRUE, NULL, NULL, OFN_HIDEREADONLY | OFN_PATHMUSTEXIST, szFilter, this );

		if( m_szFileName[0] )
		{
			char	szDrive[ _MAX_DRIVE ];
			char	szDir[ _MAX_DIR ];
			char	szBaseName[ _MAX_FNAME ];
			char	szExt[ _MAX_EXT ];

			_splitpath( m_szFileName, szDrive, szDir, szBaseName, szExt );
			sprintf( szInitialDir, "%s%s", szDrive, szDir );
			sprintf( szFileName, "%s%s", szBaseName, szExt );
			
			dlg.m_ofn.lpstrInitialDir = szInitialDir;
			dlg.m_ofn.lpstrFile = szFileName;
		}
		else
			dlg.m_ofn.lpstrInitialDir = "D:\\Audio";

		if( dlg.DoModal() == IDCANCEL )
			return;

		CString	PathName;
		PathName = dlg.GetPathName();
		strcpy( m_szFileName, PathName.GetBuffer( _MAX_PATH - 1 ) );
		PathName.ReleaseBuffer();
		
		StartPlayback();
	}
	else
	{
		m_bRepeat = FALSE;
		UpdateData(FALSE);	// Send data to the controls
		StopPlayback();
	}
}

/////////////////////////////////////////////////////////////////////////////
void CTestPage::OnRecord() 
/////////////////////////////////////////////////////////////////////////////
{
	static char BASED_CODE szFilter[] = "Wave Files(*.wav)|*.wav|All Files(*.*)|*.*||";
	char	szInitialDir[ _MAX_PATH ];
	char	szFileName[ _MAX_PATH ];

	UpdateData( TRUE );	// Get data from the controls

	if( !m_pHalAdapter->IsOpen() )
	{
		MessageBox( "Must Open Adapter First!" );
		return;
	}

 	if( m_nRecordMode == MODE_STOP )
	{
		// Pop up the file dialog box
		CFileDialog	dlg( TRUE, NULL, NULL, OFN_HIDEREADONLY | OFN_PATHMUSTEXIST, szFilter, this );

		if( m_szFileName[0] )
		{
			char	szDrive[ _MAX_DRIVE ];
			char	szDir[ _MAX_DIR ];
			char	szBaseName[ _MAX_FNAME ];
			char	szExt[ _MAX_EXT ];

			_splitpath( m_szFileName, szDrive, szDir, szBaseName, szExt );
			sprintf( szInitialDir, "%s%s", szDrive, szDir );
			sprintf( szFileName, "%s%s", szBaseName, szExt );
			
			dlg.m_ofn.lpstrInitialDir = szInitialDir;
			dlg.m_ofn.lpstrFile = szFileName;
		}
		else
			dlg.m_ofn.lpstrInitialDir = "D:\\Audio";

		if( dlg.DoModal() == IDCANCEL )
			return;

		CString	PathName;
		PathName = dlg.GetPathName();
		strcpy( m_szFileName, PathName.GetBuffer( _MAX_PATH - 1 ) );
		PathName.ReleaseBuffer();
		
		StartRecord();
	}
	else
	{
		StopRecord();
	}
}

/////////////////////////////////////////////////////////////////////////////
char *SamplesToTime( ULONG ulSampleRate, ULONG ulSampleCount, char *pszBuffer )
/////////////////////////////////////////////////////////////////////////////
{
	short Hour, Min, Sec, MS;
	double dTime = (double)ulSampleCount / (double)ulSampleRate;	// in seconds

	dTime *= 1000;	// convert to milliseconds

	ULONG	lMS = (ULONG)dTime;
	
	// hours
	Hour = (short)(lMS / 3600000L); // number of milliseconds in a hour
	// minutes
	Min = (short)((lMS / 60000L) - ((LONG)Hour * 60L)); // number of milliseconds in a minute 
	// seconds
	Sec = (short)((lMS / 1000L) - ((LONG)Min * 60L) - ((LONG)Hour * 3600L)); // number of milliseconds in a second
	// hundreths
	MS = (short)(lMS % 1000); // extract only the milliseconds
	
	sprintf( pszBuffer, "%02d:%02d:%02d.%03d", Hour, Min, Sec, MS );

	return( pszBuffer );
}

/////////////////////////////////////////////////////////////////////////////
void CTestPage::OnRepeat() 
/////////////////////////////////////////////////////////////////////////////
{
	if( m_bRepeat )	m_bRepeat = FALSE;
	else			m_bRepeat = TRUE;
}

/////////////////////////////////////////////////////////////////////////////
void	CTestPage::PollInterrupts( void )
/////////////////////////////////////////////////////////////////////////////
{
	PHALWAVEDEVICE	pHD;
	char	szBuffer[ 40 ];
	ULONG	ulSampleCount;

	if( m_pHalAdapter->IsOpen() )
		m_pHalAdapter->Service( TRUE );

	if( m_nPlayMode == MODE_RUN )
	{
		pHD = m_pHalAdapter->GetWaveOutDevice( m_nPlayDevice );
		ulSampleCount = pHD->GetSamplesTransferred();
		SetDlgItemText( IDC_PLAY_SAMPLECOUNT, SamplesToTime( m_lSampleRate, ulSampleCount, szBuffer ) );
	}
	if( m_nRecordMode == MODE_RUN )
	{
		pHD = m_pHalAdapter->GetWaveInDevice( m_nRecordDevice );
		ulSampleCount = pHD->GetSamplesTransferred();
		SetDlgItemText( IDC_RECORD_SAMPLECOUNT, SamplesToTime( m_lSampleRate, ulSampleCount, szBuffer ) );
	}
}

/////////////////////////////////////////////////////////////////////////////
void	CTestPage::StartPlayback( void )
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulBytesRequested, ulCircularBufferSize, ulBytesTransfered;
	LONG	lBufferSize;
	PHALWAVEDEVICE	pHD;
	PWAVEFORMATEX	pFormatEx;

	if( m_nPlayMode != MODE_STOP )
		return;

	m_nPlayDevice = m_PlayDevice.GetCurSel();

	DPF(("Starting Play Device %d\n", m_nPlayDevice ));

	pHD = m_pHalAdapter->GetWaveOutDevice( m_nPlayDevice );

	if( !m_WavePlayFile.Open( m_szFileName, MMIO_READ ) )
	{
		DPF(("Open Failed!\n"));
		return;
	}

	if( !m_WavePlayFile.ReadHeader() )
	{
		DPF(("ReadHeader Failed!\n"));
		return;
	}
	pFormatEx = m_WavePlayFile.GetFormat();

	//DPF(("SetFormat\n"));
	pHD->SetFormat( pFormatEx->wFormatTag, pFormatEx->nChannels, pFormatEx->nSamplesPerSec, pFormatEx->wBitsPerSample, pFormatEx->nBlockAlign );

	m_lSampleRate = pFormatEx->nSamplesPerSec;

	// Get the amount of free space on device
	//DPF(("GetTransferSize\n"));
	pHD->GetTransferSize( &ulBytesRequested, &ulCircularBufferSize );
	ulCircularBufferSize += sizeof(DWORD);
	m_ulPlayBufferSize = ulCircularBufferSize;

	m_pPlayBuffer = malloc( m_ulPlayBufferSize );
	m_ulPlayBufferPages = GetNumberOfPhysicalPages( m_pPlayBuffer, m_ulPlayBufferSize );
	GetPhysicalPages( m_pPlayBuffer, m_ulPlayBufferSize, &m_ulPlayBufferPages, m_Pages );
	
	//DPF(("ReadBlock %ld\n", ulBytesRequested ));
	lBufferSize = m_WavePlayFile.ReadBlock( (HPSTR)m_pPlayBuffer, ulBytesRequested );
	if( lBufferSize == -1 )
	{
		DPF(("ReadBlock Failed!\n"));
		return;
	}
	//lBufferSize = ulBytesRequested;

	// only call the hal if we have audio to transfer
	if( lBufferSize )
	{
		DPF(("T [%ld]", lBufferSize ));
		pHD->TransferAudio( m_pPlayBuffer, lBufferSize, &ulBytesTransfered );
		//DPF(("Write %ld\n", ulBytesTransfered ));
	}
	
	// make sure the limit register get set correctly
	//DPF(("TransferComplete\n"));
	pHD->TransferComplete( TRUE );
	
	// put the device in MODE_PLAY
	//DPF(("Start\n"));
	
	if( pHD->Start() )
	{
		DPF(("Start Failed!\n"));
	}

	// change the button to stop
	SetDlgItemText( IDC_PLAY, "Stop" );
	
	// set the mode to playing
	m_nPlayMode = MODE_RUN;
}

/////////////////////////////////////////////////////////////////////////////
void	CTestPage::StopPlayback( void )
/////////////////////////////////////////////////////////////////////////////
{
	PHALWAVEDEVICE	pHD;

	if( m_nPlayMode != MODE_RUN )
		return;

	DPF(("Stopping Play Device %d\n", m_nPlayDevice ));

	pHD = m_pHalAdapter->GetWaveOutDevice( m_nPlayDevice );

	//DPF(("Stop\n"));
	if( pHD->Stop() )
	{
		DPF(("Stop Failed!\n"));
	}

	m_nPlayMode = MODE_STOP;

	m_WavePlayFile.Close();

	free( m_pPlayBuffer );
	ReleasePhysicalPages( m_pPlayBuffer, m_ulPlayBufferSize, m_ulPlayBufferPages );

	// change the button to play
	SetDlgItemText( IDC_PLAY, "Play" );
	SetDlgItemText( IDC_PLAY_SAMPLECOUNT, "" );

	if( m_bRepeat )
		StartPlayback();
}

/////////////////////////////////////////////////////////////////////////////
void	CTestPage::StartRecord( void )
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulBytesRequested, ulCircularBufferSize;
	PHALWAVEDEVICE	pHD;
	PWAVEFORMATEX	pFormatEx;

	if( m_nRecordMode != MODE_STOP )
		return;

	m_nRecordDevice = m_RecordDevice.GetCurSel();

	DPF(("Starting Record Device %d\n", m_nRecordDevice ));

	pHD = m_pHalAdapter->GetWaveInDevice( m_nRecordDevice );

	// change the button to stop
	SetDlgItemText( IDC_RECORD, "Stop" );

	if( !m_WaveRecordFile.Open( m_szFileName, MMIO_CREATE | MMIO_READWRITE ) )
	{
		DPF(("CTestPage::StartRecord Open Failed!\n"));
		return;
	}

	m_WaveRecordFile.SetFormat( WAVE_FORMAT_PCM, 24, 44100, 2 );
	pFormatEx = m_WaveRecordFile.GetFormat();

	if( !m_WaveRecordFile.WriteHeader() )
	{
		DPF(("CTestPage::StartRecord WriteHeader Failed!\n"));
	}

	//DPF(("SetFormat\n"));
	pHD->SetFormat( pFormatEx->wFormatTag, pFormatEx->nChannels, pFormatEx->nSamplesPerSec, pFormatEx->wBitsPerSample, pFormatEx->nBlockAlign );

	m_lSampleRate = pFormatEx->nSamplesPerSec;

	// Get the amount of free space on device
	//DPF(("GetTransferSize\n"));
	pHD->GetTransferSize( &ulBytesRequested, &ulCircularBufferSize );
	ulCircularBufferSize += sizeof(DWORD);

	m_pRecordBuffer = malloc( ulCircularBufferSize );

	pHD->SetInterruptSamples( (ulCircularBufferSize / sizeof( DWORD )) / 2 );
	
	// put the device in MODE_RUN
	//DPF(("Start\n"));
	if( pHD->Start() )
	{
		DPF(("Start Failed!\n"));
	}
	
	// advance the hardware pointer so the first interrupt will actually transfer something
	pHD->TransferComplete( TRUE );
	
	// set the mode to Recording
	m_nRecordMode = MODE_RUN;
}

/////////////////////////////////////////////////////////////////////////////
void	CTestPage::StopRecord( void )
/////////////////////////////////////////////////////////////////////////////
{
	PHALWAVEDEVICE	pHD;

	if( m_nRecordMode != MODE_RUN )
		return;

	DPF(("Stopping Record Device %d\n", m_nRecordDevice ));

	pHD = m_pHalAdapter->GetWaveInDevice( m_nRecordDevice );

	//DPF(("Stop\n"));
	if( pHD->Stop() )
	{
		DPF(("Stop Failed!\n"));
	}

	m_nRecordMode = MODE_STOP;

	m_WaveRecordFile.UpdateHeader();
	m_WaveRecordFile.Close();

	free( m_pRecordBuffer );

	// change the button to Record
	SetDlgItemText( IDC_RECORD, "Record" );
	SetDlgItemText( IDC_RECORD_SAMPLECOUNT, "" );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	InterruptCallback( ULONG ulReason, PVOID pvContext1, PVOID pvContext2 )
// C wrapper for C++ callback function
/////////////////////////////////////////////////////////////////////////////
{
	CTestPage *pClass = (CTestPage *)pvContext1;
	return( pClass->ServiceInterrupt( ulReason, pvContext2 ) );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CTestPage::ServiceInterrupt( ULONG ulReason, PVOID pvContext )
/////////////////////////////////////////////////////////////////////////////
{
	//DPF(("<"));
	//DPF(("ServiceInterrupt\n"));

	switch( ulReason )
	{
	case kReasonWave:
		//DPF(("W"));
		//DPF(("kReasonWave\n"));

		PHALWAVEDEVICE pHD;
		ULONG	ulBytesToProcess, ulCircularBufferSize, ulBytesTransfered;
		LONG	lBufferSize;
		
		pHD = (PHALWAVEDEVICE)pvContext;

		//DPF(("d%ld ", pHD->GetDeviceNumber() ));
		
		// Get the amount of free space on device
		//DPF(("GetTransferSize\n"));
		pHD->GetTransferSize( &ulBytesToProcess, &ulCircularBufferSize );
		//DPF(("R%ld ", ulBytesToProcess ));

		if( pHD->IsRecord() )
		{
			pHD->TransferAudio( m_pRecordBuffer, ulBytesToProcess, &ulBytesTransfered );
			if( ulBytesToProcess != ulBytesTransfered )
				DPF(("Did not transfer all the audio! %lu %lu\n", ulBytesToProcess, ulBytesTransfered ));
			m_WaveRecordFile.WriteBlock( (HPSTR)m_pRecordBuffer, ulBytesTransfered );
			//DPF(("W%ld ", ulBytesTransfered ));
		}
		else
		{
			lBufferSize = m_WavePlayFile.ReadBlock( (HPSTR)m_pPlayBuffer, ulBytesToProcess );
	
			// only call the hal if we have audio to transfer
			if( lBufferSize )
			{
				//DPF(("T%ld ", lBufferSize ));
				pHD->TransferAudio( m_pPlayBuffer, lBufferSize, &ulBytesTransfered );
			}
			else
			{
				DPF(("GetBytesRemaining\n"));
				if( !m_WavePlayFile.GetBytesRemaining() )
				{
					StopPlayback();
				}
			}
		}

		// make sure the limit register get set correctly
		//DPF(("TransferComplete\n"));
		pHD->TransferComplete( TRUE );
		break;
	case kReasonDMABufferComplete:
		DPF(("kReasonDMA\n"));

		PHALWAVEDMADEVICE pHDD;
		ULONG	ulSize;

		pHDD = (PHALWAVEDMADEVICE)pvContext;

		ulSize = 0;

		// release the last buffer to the application
		//  ...
		// add a new buffer if available
		pHDD->GetDMA()->AddEntry( m_pPlayBuffer, ulSize, TRUE );
		break;
	case kReasonMIDI:
		DPF(("kReasonMIDI\n"));
		break;
	default:
		DPF(("ServiceInterrupt: Invalid Parameter\n"));
		return( HSTATUS_INVALID_PARAMETER );
	}

	//DPF((">"));
	return( HSTATUS_OK );
}

