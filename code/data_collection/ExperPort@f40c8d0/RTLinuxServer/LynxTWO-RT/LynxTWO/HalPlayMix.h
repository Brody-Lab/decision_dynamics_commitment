// HalPlayMix.h: interface for the CHalPlayMix class.
//
//////////////////////////////////////////////////////////////////////

#ifndef _HALPLAYMIX_H
#define _HALPLAYMIX_H

#include "Hal.h"
#include "LynxTWO.h"

enum
{
	MIXVAL_PMIXSRC_RECORD0L=0,
	MIXVAL_PMIXSRC_RECORD0R,
	MIXVAL_PMIXSRC_RECORD1L,
	MIXVAL_PMIXSRC_RECORD1R,
	MIXVAL_PMIXSRC_RECORD2L,
	MIXVAL_PMIXSRC_RECORD2R,
	MIXVAL_PMIXSRC_RECORD3L,
	MIXVAL_PMIXSRC_RECORD3R,
	MIXVAL_PMIXSRC_RECORD4L,
	MIXVAL_PMIXSRC_RECORD4R,
	MIXVAL_PMIXSRC_RECORD5L,
	MIXVAL_PMIXSRC_RECORD5R,
	MIXVAL_PMIXSRC_RECORD6L,
	MIXVAL_PMIXSRC_RECORD6R,
	MIXVAL_PMIXSRC_RECORD7L,
	MIXVAL_PMIXSRC_RECORD7R,
	MIXVAL_PMIXSRC_PLAY0L,
	MIXVAL_PMIXSRC_PLAY0R,
	MIXVAL_PMIXSRC_PLAY1L,
	MIXVAL_PMIXSRC_PLAY1R,
	MIXVAL_PMIXSRC_PLAY2L,
	MIXVAL_PMIXSRC_PLAY2R,
	MIXVAL_PMIXSRC_PLAY3L,
	MIXVAL_PMIXSRC_PLAY3R,
	MIXVAL_PMIXSRC_PLAY4L,
	MIXVAL_PMIXSRC_PLAY4R,
	MIXVAL_PMIXSRC_PLAY5L,
	MIXVAL_PMIXSRC_PLAY5R,
	MIXVAL_PMIXSRC_PLAY6L,
	MIXVAL_PMIXSRC_PLAY6R,
	MIXVAL_PMIXSRC_PLAY7L,
	MIXVAL_PMIXSRC_PLAY7R
};

class CHalPlayMix 
{
public:
	CHalPlayMix()	{}
	~CHalPlayMix()	{}

	USHORT	Open( PHALMIXER pHalMixer, USHORT usDstLine, PPLAYMIXCTL pPlayMixCtl, PULONG pPlayMixStatus );

	ULONG	GetVolume()		{ return( m_ulMasterVolume );		}
	void	SetVolume( ULONG ulVolume );
	ULONG	GetVolume( USHORT usLine );
	void	SetVolume( USHORT usLine, ULONG ulVolume );
	BOOLEAN	GetMute()		{ return( m_bMasterMute );			}
	void	SetMute( BOOLEAN bMute );
	ULONG	GetLevel();
	void	ResetLevel();
	ULONG	GetOverload();
	void	ResetOverload();
	BOOLEAN	GetPhase()		{ return( m_bMasterPhase );			}
	void	SetPhase( BOOLEAN bPhase );
	BOOLEAN	GetDither()		{ return( m_bMasterDither );		}
	void	SetDither( BOOLEAN bDither );

	BOOLEAN	GetPhase( USHORT usLine );
	void	SetPhase( USHORT usLine, BOOLEAN bPhase );
	BOOLEAN	GetMute( USHORT usLine );
	void	SetMute( USHORT usLine, BOOLEAN bMute );
	USHORT	GetSource( USHORT usLine );
	void	SetSource( USHORT usLine, USHORT usSource );

	//USHORT	GetFirstAvailableConnection( PUSHORT pusLine );
	//USHORT	SetConnection( USHORT usLine, BOOLEAN bConnect );

private:
	void	UpdateVolume( SHORT usLine );
	USHORT	ConvertLine( USHORT usLine );

	CHalRegister m_RegMixControl[ NUM_PMIX_LINES ];
	CHalRegister m_RegMixStatus;

	PHALMIXER	m_pHalMixer;
	USHORT		m_usDstLine;
	
	ULONG		m_aulVolume[ NUM_PMIX_LINES ];
	SHORT		m_asSource[ NUM_PMIX_LINES ];
	BOOLEAN		m_abMute[ NUM_PMIX_LINES ];
	BOOLEAN		m_abPhase[ NUM_PMIX_LINES ];
	BOOLEAN		m_abConnected[ NUM_PMIX_LINES ];
	
	ULONG		m_ulMasterVolume;
	BOOLEAN		m_bMasterMute;
	BOOLEAN		m_bMasterPhase;
	BOOLEAN		m_bMasterDither;
	ULONG		m_ulOverloadCount;
};

#endif // _HALPLAYMIX_H
