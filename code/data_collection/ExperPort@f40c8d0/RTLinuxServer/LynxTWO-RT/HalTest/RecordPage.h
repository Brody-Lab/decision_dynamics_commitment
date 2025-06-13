#if !defined(AFX_RECORDPAGE_H__E44CD061_E0A5_436E_A027_030FAC708B32__INCLUDED_)
#define AFX_RECORDPAGE_H__E44CD061_E0A5_436E_A027_030FAC708B32__INCLUDED_

#include "..\LYNXTWO\Hal.h"	// Added by ClassView
#include "..\LYNXTWO\HalEnv.h"	// Added by ClassView
#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// RecordPage.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CRecordPage dialog

class CRecordPage : public CPropertyPage
{
	DECLARE_DYNCREATE(CRecordPage)

// Construction
public:
	CRecordPage();
	~CRecordPage();
	virtual BOOL PreTranslateMessage(MSG* pMsg);
	void UpdateMeters( void );

// Dialog Data
	//{{AFX_DATA(CRecordPage)
	enum { IDD = IDD_RECORD };
		// NOTE - ClassWizard will add data members here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_DATA


// Overrides
	// ClassWizard generate virtual function overrides
	//{{AFX_VIRTUAL(CRecordPage)
	public:
	virtual BOOL OnApply();
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	CToolTipCtrl	m_tooltip;
	afx_msg void OnRecordSelect( UINT nID );
	afx_msg void OnSourceMenuSelect( UINT nID );
	afx_msg void OnMute( UINT nID );
	afx_msg void OnDither( UINT nID );
	
	// Generated message map functions
	//{{AFX_MSG(CRecordPage)
	virtual BOOL OnInitDialog();
	afx_msg void OnShowWindow(BOOL bShow, UINT nStatus);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

private:
	PHALADAPTER	m_pHalAdapter;
	PHALMIXER	m_pHalMixer;
	UINT		m_nRecordSelectID;
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_RECORDPAGE_H__E44CD061_E0A5_436E_A027_030FAC708B32__INCLUDED_)
