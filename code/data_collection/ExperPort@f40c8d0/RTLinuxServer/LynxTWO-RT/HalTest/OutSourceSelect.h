#if !defined(AFX_OUTSOURCESELECT_H__D0E26B86_1645_4164_A8D3_2245B42104CB__INCLUDED_)
#define AFX_OUTSOURCESELECT_H__D0E26B86_1645_4164_A8D3_2245B42104CB__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// OutSourceSelect.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// COutSourceSelect dialog

class COutSourceSelect : public CDialog
{
// Construction
public:
	COutSourceSelect(CWnd* pParent = NULL);   // standard constructor
	USHORT	m_usDstLine;

// Dialog Data
	//{{AFX_DATA(COutSourceSelect)
	enum { IDD = IDD_OUTPUT_SOURCE_SELECT };
	CComboBox	m_DSource;
	CComboBox	m_CSource;
	CComboBox	m_BSource;
	CComboBox	m_ASource;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(COutSourceSelect)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	afx_msg void OnChangeSource( UINT nID );
	afx_msg void OnMute( UINT nID );
	afx_msg void OnPhase( UINT nID );

	// Generated message map functions
	//{{AFX_MSG(COutSourceSelect)
	virtual BOOL OnInitDialog();
	afx_msg void OnVScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar);
	afx_msg void OnTimer(UINT nIDEvent);
	afx_msg void OnDither();
	afx_msg void OnShowWindow(BOOL bShow, UINT nStatus);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

private:
	COutputsPage * m_pOutputsPage;
	PHALADAPTER	m_pHalAdapter;
	PHALMIXER	m_pHalMixer;
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_OUTSOURCESELECT_H__D0E26B86_1645_4164_A8D3_2245B42104CB__INCLUDED_)
