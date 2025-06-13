#if !defined(AFX_ADAPTERPAGE_H__52D47466_A013_4C6B_8E14_D9420FF0F1A7__INCLUDED_)
#define AFX_ADAPTERPAGE_H__52D47466_A013_4C6B_8E14_D9420FF0F1A7__INCLUDED_

#include "..\LYNXTWO\HalEnv.h"	// Added by ClassView
#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// AdapterPage.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CAdapterPage dialog

class CAdapterPage : public CPropertyPage
{
	DECLARE_DYNCREATE(CAdapterPage)

// Construction
public:
	CAdapterPage();
	~CAdapterPage();
	virtual BOOL PreTranslateMessage(MSG* pMsg);
	void UpdateScreen( void );
	void UpdateSampleClock();

// Dialog Data
	//{{AFX_DATA(CAdapterPage)
	enum { IDD = IDD_ADAPTER };
	CComboBox	m_ClockReference;
	CComboBox	m_ClockSource;
	CComboBox	m_SampleRate;
	int			m_nClockSource;
	int			m_nClockReference;
	//}}AFX_DATA


// Overrides
	// ClassWizard generate virtual function overrides
	//{{AFX_VIRTUAL(CAdapterPage)
	public:
	virtual BOOL OnApply();
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	CToolTipCtrl	m_tooltip;
	afx_msg void OnTrimClicked( UINT nID );
	afx_msg void OnFormatClicked( UINT nID );
	afx_msg	void OnChangeSRC( UINT nID );
	afx_msg void OnLS1FrameClock( UINT nID );
	afx_msg void OnLS2FrameClock( UINT nID );
	afx_msg void OnLS2OutputSelect( UINT nID );
	afx_msg void OnLS2HD1Direction( UINT nID );
	afx_msg void OnLS2HD2Direction( UINT nID );
	afx_msg void OnLS2HDInputSelect( UINT nID ); 
	afx_msg void OnDitherType( UINT nID );

	// Generated message map functions
	//{{AFX_MSG(CAdapterPage)
	virtual BOOL OnInitDialog();
	afx_msg void OnShowWindow(BOOL bShow, UINT nStatus);
	afx_msg void OnSelchangeSampleRate();
	afx_msg void OnSelchangeClockSource();
	afx_msg void OnSelchangeClockReference();
	afx_msg void OnTCRxEnable();
	afx_msg void OnTCTxEnable();
	afx_msg void OnChangeTxPosition();
	afx_msg void OnDOutValid();
	afx_msg void OnDOutNonAudio();
	afx_msg void OnCalibrate();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

private:
	ULONG		m_ulDigitalInStatus;
	ULONG		m_ulRate[ 8 ];
	PHALADAPTER	m_pHalAdapter;
	PHALMIXER	m_pHalMixer;
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_ADAPTERPAGE_H__52D47466_A013_4C6B_8E14_D9420FF0F1A7__INCLUDED_)
