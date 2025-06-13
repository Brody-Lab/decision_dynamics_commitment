// MediaFile.h: interface for the CMediaFile class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_MEDIAFILE_H__A5DBBF14_5AD9_11D1_B8AA_00AA00642170__INCLUDED_)
#define AFX_MEDIAFILE_H__A5DBBF14_5AD9_11D1_B8AA_00AA00642170__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

#include <mmsystem.h>

class CMediaFile
{
public:
	CMediaFile();
	virtual ~CMediaFile();

	BOOLEAN		Open( LPSTR szFilename, DWORD dwFlags );
	MMRESULT	Close( void );
	MMRESULT	Ascend( PMMCKINFO lpck );
	MMRESULT	Descend( PMMCKINFO lpck, PMMCKINFO lpckParent, UINT wFlags );
	MMRESULT	CreateChunk( PMMCKINFO lpck, UINT wFlags );
	LONG		Read( HPSTR pch, LONG cch );
	LONG		Write( HPSTR pch, LONG cch );
	MMRESULT	Flush( UINT uiFlags );
	LONG		Seek( LONG lOffset );
	LONG		SeekBegin( LONG lOffset );
	LONG		SeekEnd( LONG lOffset );

private:
	HMMIO m_hmmio;
};

#endif // !defined(AFX_MEDIAFILE_H__A5DBBF14_5AD9_11D1_B8AA_00AA00642170__INCLUDED_)
