// HalTest.h : main header file for the HALTEST application
//

#if !defined(AFX_HALTEST_H__98149DCE_2B58_4D00_B951_F861F11D394B__INCLUDED_)
#define AFX_HALTEST_H__98149DCE_2B58_4D00_B951_F861F11D394B__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#define USEHARDWARE

#include "resource.h"		// main symbols
#include "HalAdapter.h"

#define MIN_VOLUME		0
#define VOLCHG_SMALL	MAX_VOLUME / 20 // 20 clicks
#define VOLCHG_LARGE	MAX_VOLUME / 8	// 8 clicks

#define MAX_CHANNELS	8
#define MAKE_USER( NumChannels, Line, Control, Channel )		( (NumChannels<<24) | (Line<<16) | (Control<<8) | (Channel) )
#define GET_CHANNEL( ID )		(ID & 0xFF)
#define GET_CONTROL( ID )		((ID >>  8) & 0xFF)
#define GET_LINE( ID )			((ID >> 16) & 0xFF)
#define GET_NUMCHANNELS( ID )	((ID >> 24) & 0xFF)

/////////////////////////////////////////////////////////////////////////////
// CHalTestApp:
// See HalTest.cpp for the implementation of this class
//

enum
{
	PAGE_TEST=0,
	PAGE_ADAPTER,
	PAGE_RECORD,
	PAGE_PLAY,
	PAGE_OUTPUTS,
	NUM_PAGES
};

class CHalTestApp : public CWinApp
{
public:
	CHalTestApp();
	HANDLE		m_hVxD;
	PHALADAPTER	m_pHalAdapter;
	PHALMIXER	m_pHalMixer;
	int			m_nPage;
	CWinThread*	m_pThread;
	HANDLE		m_ThreadEvent;
	volatile BOOLEAN m_bRunning;

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CHalTestApp)
	public:
	virtual BOOL InitInstance();
	//}}AFX_VIRTUAL

// Implementation

	//{{AFX_MSG(CHalTestApp)
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

extern CHalTestApp theApp;

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_HALTEST_H__98149DCE_2B58_4D00_B951_F861F11D394B__INCLUDED_)
