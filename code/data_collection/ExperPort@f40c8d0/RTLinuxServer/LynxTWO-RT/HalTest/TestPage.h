#if !defined(AFX_TESTPAGE_H__54D30E12_2AA3_4F65_8B25_49C4D01260DA__INCLUDED_)
#define AFX_TESTPAGE_H__54D30E12_2AA3_4F65_8B25_49C4D01260DA__INCLUDED_

#include "..\LYNXTWO\HalEnv.h"	// Added by ClassView
#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// TestPage.h : header file
//

#include "HalAdapter.h"
#include "HalMixer.h"
#include "WaveFile.h"
#include <HalEnv.h>
#include "PCIBios.h"

#define MODE_STOP	0
#define MODE_RUN	1

/////////////////////////////////////////////////////////////////////////////
// CTestPage dialog

class CTestPage : public CPropertyPage
{
	DECLARE_DYNCREATE(CTestPage)

// Construction
public:
	CTestPage();
	~CTestPage();

	BOOLEAN RestorePCIConfiguration( BYTE ucBus, BYTE ucDevice );
	BOOLEAN SavePCIConfiguration( BYTE ucBus, BYTE ucDevice );
	char * GetVendorName( USHORT usVendorID, USHORT usDeviceID );
	void RefreshDeviceList();
	void UpdateMeters( void );
	void PollInterrupts( void );

// Dialog Data
	//{{AFX_DATA(CTestPage)
	enum { IDD = IDD_TESTPAGE };
	CComboBox	m_RecordDevice;
	CComboBox	m_PlayDevice;
	CListCtrl	m_DeviceList;
	BOOL	m_bRepeat;
	//}}AFX_DATA


// Overrides
	// ClassWizard generate virtual function overrides
	//{{AFX_VIRTUAL(CTestPage)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	CToolTipCtrl	m_tooltip;
	// Generated message map functions
	//{{AFX_MSG(CTestPage)
	virtual BOOL OnInitDialog();
	afx_msg void OnFind();
	afx_msg void OnOpen();
	afx_msg void OnClickDeviceList(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnRefresh();
	afx_msg void OnSave();
	afx_msg void OnRestore();
	afx_msg void OnVScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar);
	afx_msg void OnClose();
	afx_msg void OnPlay();
	afx_msg void OnShowWindow(BOOL bShow, UINT nStatus);
	afx_msg void OnRepeat();
	afx_msg void OnRecord();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

private:
	void		StartPlayback( void );
	void		StopPlayback( void );
	void		StartRecord( void );
	void		StopRecord( void );

	friend USHORT InterruptCallback( ULONG ulReason, PVOID pvContext1, PVOID pvContext2 );
	USHORT		ServiceInterrupt( ULONG ulReason, PVOID pvContext );

	int			m_nPlayDevice;
	int			m_nRecordDevice;
	LONG		m_lSampleRate;
	char		m_szFileName[ 255 ];
	PVOID		m_pPlayBuffer;
	ULONG		m_ulPlayBufferSize;
	ULONG		m_ulPlayBufferPages;
	PHYSICALREGION m_Pages[16];
	PVOID		m_pRecordBuffer;
	CWaveFile	m_WavePlayFile;
	CWaveFile	m_WaveRecordFile;
	volatile int m_nPlayMode;
	volatile int m_nRecordMode;
	PHALADAPTER	m_pHalAdapter;
	PHALMIXER	m_pHalMixer;
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_TESTPAGE_H__54D30E12_2AA3_4F65_8B25_49C4D01260DA__INCLUDED_)
