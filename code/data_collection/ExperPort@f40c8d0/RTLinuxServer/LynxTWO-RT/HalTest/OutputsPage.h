#if !defined(AFX_OUTPUTSPAGE_H__249E039C_F362_498B_B75D_A66B99BC53A1__INCLUDED_)
#define AFX_OUTPUTSPAGE_H__249E039C_F362_498B_B75D_A66B99BC53A1__INCLUDED_

#include "..\LYNXTWO\HalEnv.h"	// Added by ClassView
#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// OutputsPage.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// COutputsPage dialog

class COutputsPage : public CPropertyPage
{
	DECLARE_DYNCREATE(COutputsPage)

// Construction
public:
	void UpdateMeters( void );
	COutputsPage();
	~COutputsPage();
	virtual BOOL PreTranslateMessage(MSG* pMsg);
	void UpdateLine( int nLine );

// Dialog Data
	//{{AFX_DATA(COutputsPage)
	enum { IDD = IDD_OUTPUTS };
		// NOTE - ClassWizard will add data members here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_DATA


// Overrides
	// ClassWizard generate virtual function overrides
	//{{AFX_VIRTUAL(COutputsPage)
	public:
	virtual BOOL OnApply();
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	CToolTipCtrl	m_tooltip;
	afx_msg void OnPMixSelect( UINT nID );
	afx_msg void OnSourceMenuSelect( UINT nID );
	afx_msg void OnMute( UINT nID );
	afx_msg void OnPhase( UINT nID );
	afx_msg void OnDither( UINT nID );
	afx_msg void OnSourceSelectDialog( UINT nID );

	// Generated message map functions
	//{{AFX_MSG(COutputsPage)
	virtual BOOL OnInitDialog();
	afx_msg void OnShowWindow(BOOL bShow, UINT nStatus);
	afx_msg void OnVScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

private:
	UINT		m_nPlaySelectID;
	PHALADAPTER	m_pHalAdapter;
	PHALMIXER	m_pHalMixer;
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_OUTPUTSPAGE_H__249E039C_F362_498B_B75D_A66B99BC53A1__INCLUDED_)
