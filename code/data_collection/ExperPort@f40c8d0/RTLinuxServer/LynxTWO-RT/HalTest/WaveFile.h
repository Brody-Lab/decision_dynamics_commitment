// WaveFile.h: interface for the CWaveFile class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_WAVEFILE_H__A5DBBF15_5AD9_11D1_B8AA_00AA00642170__INCLUDED_)
#define AFX_WAVEFILE_H__A5DBBF15_5AD9_11D1_B8AA_00AA00642170__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

#include "MediaFile.h"
#include <mmreg.h>				// extentions to the mmsystem.h

class CWaveFile : public CMediaFile  
{
public:
	CWaveFile();
	virtual ~CWaveFile();

	DWORD	GetSampleCount( void );
	int		SetFormat( WORD wFormatTag, WORD wBitsPerSample, DWORD dwSamplesPerSec, int nChannels );
	PWAVEFORMATEX	GetFormat( void )	{	return( &m_FormatEx );	}
	void	SetMPEGBitRate( LONG lBitRate );
	int		ReadHeader( void );
	int		WriteHeader( void );
	int		UpdateHeader( void );
	LONG	GetBytesRemaining( void );
	LONG	ReadBlock( HPSTR pch, LONG cch );
	LONG	WriteBlock( HPSTR pch, LONG cch );

private:
	DWORD	m_dwBytesRead;
	DWORD	m_dwDataSize;
	MMCKINFO m_mmckinfoParent;
	MMCKINFO m_mmckinfoSubchunk;
	LONG	m_lMPEGBitRate;
	LONG	m_lFormatSize;
	WORD	m_wSamplesPerBlock;
	WAVEFORMATEX m_FormatEx;
};

#endif // !defined(AFX_WAVEFILE_H__A5DBBF15_5AD9_11D1_B8AA_00AA00642170__INCLUDED_)
