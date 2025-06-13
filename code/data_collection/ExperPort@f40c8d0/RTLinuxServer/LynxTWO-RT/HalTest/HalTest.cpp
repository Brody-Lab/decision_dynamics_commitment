// HalTest.cpp : Defines the class behaviors for the application.
//

#include "stdafx.h"
#include "HalTest.h"
#include "HalTestDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

#include "PCIBios.h"
#include "Callback.h"
#include "Fader.h"
#include "VUMeter.h"

/////////////////////////////////////////////////////////////////////////////
// CHalTestApp

BEGIN_MESSAGE_MAP(CHalTestApp, CWinApp)
	//{{AFX_MSG_MAP(CHalTestApp)
		// NOTE - the ClassWizard will add and remove mapping macros here.
		//    DO NOT EDIT what you see in these blocks of generated code!
	//}}AFX_MSG
	ON_COMMAND(ID_HELP, CWinApp::OnHelp)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CHalTestApp construction

CHalTestApp::CHalTestApp()
{
	// TODO: add construction code here,
	// Place all significant initialization in InitInstance
}

/////////////////////////////////////////////////////////////////////////////
// The one and only CHalTestApp object

CHalTestApp theApp;
HANDLE ghDriver = NULL;

/////////////////////////////////////////////////////////////////////////////
// CHalTestApp initialization

BOOL CHalTestApp::InitInstance()
{
	AfxEnableControlContainer();

	RegisterFaderClasses( AfxGetInstanceHandle() );
	RegisterVUClasses( AfxGetInstanceHandle() );
	HALDRIVERINFO	DrvInfo;

	RtlZeroMemory( &DrvInfo, sizeof( HALDRIVERINFO ) );
	DrvInfo.pFind			= FindAdapter;
	DrvInfo.pMap			= MapAdapter;
	DrvInfo.pGetAdapter		= GetAdapter;
	DrvInfo.pUnmap			= UnmapAdapter;
	DrvInfo.pAllocateMemory = AllocateMemory;
	DrvInfo.pFreeMemory		= FreeMemory;
	DrvInfo.pContext		= this;

	m_pHalAdapter = new CHalAdapter( &DrvInfo, 0 );

	// This is safe even though we haven't opened the Hal yet...
	m_pHalMixer = m_pHalAdapter->GetMixer();

#ifdef USEHARDWARE
	if( !IsPCIBiosPresent() )
	{
		MessageBox( NULL, "There is no PCI BIOS present!", NULL, MB_OK | MB_ICONEXCLAMATION );
		return( FALSE );
	}
#endif

	CString VxdName;

	VxdName = (CString)"\\\\.\\" + "LynxMem.VxD";
    m_hVxD  = CreateFile( VxdName, GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ, NULL, 0, FILE_FLAG_DELETE_ON_CLOSE, NULL ); 
	if( m_hVxD == INVALID_HANDLE_VALUE )
	{
		MessageBox( NULL, "Cannot find LynxMem.VxD!", NULL, MB_OK | MB_ICONEXCLAMATION );
		m_hVxD = NULL;
	}

	ghDriver = m_hVxD;

	CHalTestDlg dlg;
	m_pMainWnd = &dlg;

	dlg.m_psh.dwFlags |= PSH_NOAPPLYNOW;

	int nResponse = dlg.DoModal();

	//m_nPage = -1;
	//m_bRunning = FALSE;
	//DPF(("Waiting...\n"));
	//if( WaitForSingleObject( m_ThreadEvent, 1000 ) == WAIT_TIMEOUT )
	//	DPF(("WaitForSingleObject Timed Out!\n"));

	if( m_hVxD )
		CloseHandle( m_hVxD );

	if( m_pHalAdapter->IsOpen() )
		m_pHalAdapter->Close();

	delete m_pHalAdapter;

	// Since the dialog has been closed, return FALSE so that we exit the
	//  application, rather than start the application's message pump.
	return FALSE;
}
