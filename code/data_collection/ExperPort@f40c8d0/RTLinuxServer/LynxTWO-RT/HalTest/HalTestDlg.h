// HalTestDlg.h : header file
//

#if !defined(AFX_HALTESTDLG_H__E988F6A1_BE7D_4E2A_8DBA_BF0468ED9C32__INCLUDED_)
#define AFX_HALTESTDLG_H__E988F6A1_BE7D_4E2A_8DBA_BF0468ED9C32__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "HalAdapter.h"
#include "..\LynxTWO\HalEnv.h"	// Added by ClassView

#include "TestPage.h"
#include "AdapterPage.h"
#include "RecordPage.h"
//#include "PlayPage.h"
#include "OutputsPage.h"

/////////////////////////////////////////////////////////////////////////////
// CHalTestDlg dialog

class CHalTestDlg : public CPropertySheet
{
// Construction
public:
	COutputsPage	m_OutputsPage;
	void MyThread();
	CHalTestDlg(CWnd* pParent = NULL);	// standard constructor
	
	void ShowVolume( long lVolume );
	void OnMenuSelect( WPARAM wParam, LPARAM lParam );
	void OnExitMenuLoop( WPARAM wParam, LPARAM lParam );

// Dialog Data
	//{{AFX_DATA(CHalTestDlg)
	enum { IDD = IDS_HALTEST };
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CHalTestDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	CTestPage		m_TestPage;
	CAdapterPage	m_AdapterPage;
	CRecordPage		m_RecordPage;

	CWnd			m_Frame;
	CWnd			m_Status;
	CWnd			m_VolumeStatus;
	CWnd			m_LockStatus;
	CFont			m_Font;
	HICON			m_hIcon;
	HICON			m_hSmallIcon;

	// Generated message map functions
	//{{AFX_MSG(CHalTestDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	afx_msg void OnExit();
	afx_msg void OnActivate( UINT nState, CWnd* pWndOther, BOOL bMinimized );
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
private:
	friend UINT MeterThread( LPVOID pParam );
	PHALADAPTER	m_pHalAdapter;
	PHALMIXER	m_pHalMixer;
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_HALTESTDLG_H__E988F6A1_BE7D_4E2A_8DBA_BF0468ED9C32__INCLUDED_)
