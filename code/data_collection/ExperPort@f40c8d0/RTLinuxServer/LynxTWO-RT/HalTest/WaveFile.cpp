// WaveFile.cpp: implementation of the CWaveFile class.
//
//////////////////////////////////////////////////////////////////////

#include "StdAfx.h"
#include "HalTest.h"
#include "WaveFile.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
CWaveFile::CWaveFile()
/////////////////////////////////////////////////////////////////////////////
{
	m_dwDataSize = 0;
	m_dwBytesRead = 0;
	m_wSamplesPerBlock = 0;

	RtlZeroMemory( &m_mmckinfoParent, sizeof( MMCKINFO ) );
	RtlZeroMemory( &m_mmckinfoSubchunk, sizeof( MMCKINFO ) );
}

/////////////////////////////////////////////////////////////////////////////
CWaveFile::~CWaveFile()
/////////////////////////////////////////////////////////////////////////////
{
}

/////////////////////////////////////////////////////////////////////////////
int CWaveFile::SetFormat( WORD wFormatTag, WORD wBitsPerSample, DWORD dwSamplesPerSec, int nChannels )
/////////////////////////////////////////////////////////////////////////////
{
	m_wSamplesPerBlock = 0;

	// make sure everything has a value first
	m_FormatEx.wFormatTag		= wFormatTag;
	m_FormatEx.nChannels		= nChannels;
	m_FormatEx.nSamplesPerSec	= dwSamplesPerSec;
	m_FormatEx.nAvgBytesPerSec	= 0;
	m_FormatEx.nBlockAlign		= 0;
	m_FormatEx.wBitsPerSample	= 0;
	m_FormatEx.cbSize			= 0;

	switch( wFormatTag )
	{
	case WAVE_FORMAT_PCM:
		m_lFormatSize = sizeof( PCMWAVEFORMAT );
		m_wSamplesPerBlock = 1;
		switch( wBitsPerSample )
		{
		case 8:
			m_FormatEx.nBlockAlign = nChannels;
			m_FormatEx.wBitsPerSample = 8;
			break;
		default:
		case 16:
			m_FormatEx.nBlockAlign = nChannels * 2;
			m_FormatEx.wBitsPerSample = 16;
			break;
		case 32:
			m_FormatEx.nBlockAlign = nChannels * 4;
			m_FormatEx.wBitsPerSample = 32;
			break;
		}
		break;

	case WAVE_FORMAT_ADPCM:
		{
		LPADPCMWAVEFORMAT lpADPCM = (LPADPCMWAVEFORMAT)&m_FormatEx;

		m_wSamplesPerBlock	= 500;
		m_lFormatSize 	= sizeof( WAVEFORMATEX ) + 32;
		m_FormatEx.cbSize	= 32;
		m_FormatEx.nBlockAlign = nChannels * 256;
		m_FormatEx.wBitsPerSample = 4;
		lpADPCM->wSamplesPerBlock = m_wSamplesPerBlock;
		lpADPCM->wNumCoef = 7;
		lpADPCM->aCoef[0].iCoef1 = 256;
		lpADPCM->aCoef[0].iCoef2 = 0;
		lpADPCM->aCoef[1].iCoef1 = 512;
		lpADPCM->aCoef[1].iCoef2 = -256;
		lpADPCM->aCoef[2].iCoef1 = 0;
		lpADPCM->aCoef[2].iCoef2 = 0;
		lpADPCM->aCoef[3].iCoef1 = 192;
		lpADPCM->aCoef[3].iCoef2 = 64;
		lpADPCM->aCoef[4].iCoef1 = 240;
		lpADPCM->aCoef[4].iCoef2 = 0;
		lpADPCM->aCoef[5].iCoef1 = 460;
		lpADPCM->aCoef[5].iCoef2 = -208;
		lpADPCM->aCoef[6].iCoef1 = 392;
		lpADPCM->aCoef[6].iCoef2 = -232;
		}
		break;

	case WAVE_FORMAT_DOLBY_AC2:
		if( (m_FormatEx.nSamplesPerSec > 30700L) && (m_FormatEx.nSamplesPerSec < 33300L) )
			m_FormatEx.nBlockAlign = 190 * m_FormatEx.nChannels;

		if( (m_FormatEx.nSamplesPerSec > 42200L) && (m_FormatEx.nSamplesPerSec < 45800L) )
			m_FormatEx.nBlockAlign = 184 * m_FormatEx.nChannels;

		if( (m_FormatEx.nSamplesPerSec > 46000L) && (m_FormatEx.nSamplesPerSec < 50000L) )
			m_FormatEx.nBlockAlign = 168 * m_FormatEx.nChannels;

		m_wSamplesPerBlock = 512;
		m_FormatEx.wBitsPerSample = 3;
		m_FormatEx.cbSize = 2;
		break;

	case WAVE_FORMAT_MPEG:
		{
		LPMPEG1WAVEFORMAT lpMPEG = (LPMPEG1WAVEFORMAT)&m_FormatEx;
		DWORD dwKB, dwSR, dwTemp;

		m_lFormatSize		= sizeof( MPEG1WAVEFORMAT );

		switch( lpMPEG->fwHeadLayer )
		{
		case ACM_MPEG_LAYER1:
			m_wSamplesPerBlock 	= 384;
			break;
		default:
		case ACM_MPEG_LAYER2:
			lpMPEG->fwHeadLayer = ACM_MPEG_LAYER2;
			m_wSamplesPerBlock 	= 1152;
			break;
		case ACM_MPEG_LAYER3:
			m_wSamplesPerBlock 	= 1152;
			break;
		}

/*
		With a sampling frequency of 32 or 48 kHz, the size of an MPEG audio frame is a function of the 
		bit rate. If an audio stream uses a constant bit rate, the size of the audio frames does not vary. 
		Therefore, the following formulas apply:
			Layer 1: nBlockAlign = 4*(int)(12*BitRate/SamplingFreq)
			Layers 2 and 3: nBlockAlign = (int)(144*BitRate/SamplingFreq)
		Example 1: For layer 1, with a sampling frequency of 32000 Hz and a bit rate of 256 kbits/s, 
		nBlockAlign = 384 bytes.
*/

		dwKB						= (m_lMPEGBitRate * nChannels) / 1000;
		dwSR						= m_FormatEx.nSamplesPerSec / 100L;
		dwTemp						= ((DWORD)m_wSamplesPerBlock * dwKB * 320L) / dwSR;
		m_FormatEx.nBlockAlign		= (WORD)(dwTemp >> 8);
		m_FormatEx.wBitsPerSample	= 16;
		m_FormatEx.cbSize			= 22;

		lpMPEG->fwHeadModeExt		= 0x000f;
		lpMPEG->wHeadEmphasis		= 1;			// no emphasis
		lpMPEG->fwHeadFlags			= ACM_MPEG_ID_MPEG1 | ACM_MPEG_PROTECTIONBIT;	// ACM_MPEG_COPYRIGHT or ACM_MPEG_ORIGINALHOME
		lpMPEG->dwPTSLow			= 0;
		lpMPEG->dwPTSHigh			= 0;

		if( nChannels == 1 )
			lpMPEG->fwHeadMode		= ACM_MPEG_SINGLECHANNEL;
		else
			lpMPEG->fwHeadMode		= ACM_MPEG_JOINTSTEREO;
			//lpMPEG->fwHeadMode = ACM_MPEG_DUALCHANNEL;
			//lpMPEG->fwHeadMode = ACM_MPEG_STEREO;

		// bits per seconds
		lpMPEG->dwHeadBitrate		= m_lMPEGBitRate * nChannels;
		}
		break;


	case WAVE_FORMAT_APTX:
		m_wSamplesPerBlock			= 4;
		m_lFormatSize				= sizeof( WAVEFORMATEX );
		m_FormatEx.nBlockAlign		= nChannels * 2;
		m_FormatEx.wBitsPerSample	= 4;
		break;

	case WAVE_FORMAT_G723_ADPCM:
		m_wSamplesPerBlock			= 8;
		m_lFormatSize				= sizeof( WAVEFORMATEX );
		m_FormatEx.nBlockAlign		= 3;
		m_FormatEx.wBitsPerSample	= 3;
		break;

	case WAVE_FORMAT_G721_ADPCM:
		m_wSamplesPerBlock			= 2;
		m_lFormatSize				= sizeof( WAVEFORMATEX );
		m_FormatEx.nBlockAlign		= 1;
		m_FormatEx.wBitsPerSample	= 4;
		break;

	case WAVE_FORMAT_ALAW:
	case WAVE_FORMAT_MULAW:
		m_lFormatSize				= sizeof( WAVEFORMATEX );
		m_wSamplesPerBlock			= 1;
		m_FormatEx.nBlockAlign		= nChannels;
		m_FormatEx.wBitsPerSample	= 8;
		break;

	default:
		return( TRUE );
	}


	m_FormatEx.nAvgBytesPerSec = ((( (DWORD)m_FormatEx.nSamplesPerSec * 100L) / (DWORD)m_wSamplesPerBlock) * (DWORD)m_FormatEx.nBlockAlign) / 100L;
	return( FALSE );
}

/////////////////////////////////////////////////////////////////////////////
void CWaveFile::SetMPEGBitRate( LONG lBitRate )
// Need to have a ValidateMPEGBitRate function as well...
/////////////////////////////////////////////////////////////////////////////
{
	m_lMPEGBitRate = lBitRate;
}

/////////////////////////////////////////////////////////////////////////////
int CWaveFile::ReadHeader( void )
/////////////////////////////////////////////////////////////////////////////
{
	// Locate a 'RIFF' chunk with a 'WAVE' form type to make sure it's a WAVE file.
	m_mmckinfoParent.fccType = mmioFOURCC('W','A','V','E');
	if( Descend( &m_mmckinfoParent, NULL, MMIO_FINDRIFF ) )
	{
		DPF(("Cannot Descend into WAVE chunk!\n"));
		Close();
		return( FALSE );
	}

	// Now, find the format chunk (form type 'fmt '). It should be a subchunk of the 'RIFF' parent chunk.
	m_mmckinfoSubchunk.ckid = mmioFOURCC('f','m','t',' ');
	if( Descend( &m_mmckinfoSubchunk, &m_mmckinfoParent, MMIO_FINDCHUNK ) )
	{
		DPF(("Cannot find format chunk!\n"));
		Close();
		return( FALSE );
	}

	// Get the size of the format chunk
	m_lFormatSize = m_mmckinfoSubchunk.cksize;

	// read the format chunk
	if( Read( (HPSTR)&m_FormatEx, m_lFormatSize ) != (LONG)m_lFormatSize )
	{
		DPF(("Cannot read format chunk!\n"));
		Close();
		return( FALSE );
	}

	// Ascend out of the format subchunk.
	if( Ascend( &m_mmckinfoSubchunk ) )
	{
		DPF(("Ascend format subchunk failed!\n"));
	}

	// Find the data subchunk.
	m_mmckinfoSubchunk.ckid = mmioFOURCC('d','a','t','a');
	if( Descend( &m_mmckinfoSubchunk, &m_mmckinfoParent, MMIO_FINDCHUNK ) )
	{
		DPF(("Cannot Descend into data subchunk!\n"));
		Close();
		return( FALSE );
	}

	// Get the size of the data subchunk.
	m_dwDataSize = m_mmckinfoSubchunk.cksize;
	//DPF(("Data Size is %ld\n", m_dwDataSize ));
	
	// round file to integral number of audio blocks
	if( m_FormatEx.nBlockAlign )
		m_dwDataSize = (m_dwDataSize / m_FormatEx.nBlockAlign ) * m_FormatEx.nBlockAlign;

	//DPF(("Computed Data Size is %ld\n", m_dwDataSize ));

	if( m_dwDataSize == 0L )
	{
		DPF(("DataSize is zero!\n"));
		Close();
		return( FALSE );
	}

	m_dwBytesRead = 0;

	return( TRUE );
}

/////////////////////////////////////////////////////////////////////////////
int CWaveFile::WriteHeader( void )
/////////////////////////////////////////////////////////////////////////////
{
	m_mmckinfoParent.fccType = mmioFOURCC('W','A','V','E');
	m_mmckinfoParent.dwFlags = MMIO_DIRTY;
	if( CreateChunk( (LPMMCKINFO)&m_mmckinfoParent, MMIO_CREATERIFF ) )
	{
		DPF(( "Could not create WAVE chunk.\n" ));
		Close();
		return( FALSE );
	}

	m_mmckinfoSubchunk.ckid = mmioFOURCC('f','m','t',' ');
	m_mmckinfoSubchunk.cksize = sizeof( PCMWAVEFORMAT );
	if( CreateChunk( (LPMMCKINFO)&m_mmckinfoSubchunk, (UINT)NULL ) )
	{
		DPF(( "Could not create fmt subchunk.\n" ));
		Close();
		return( FALSE );
	}

	//DPF(("FormatSize %ld\n", m_lFormatSize ));

	if( Write( (HPSTR)&m_FormatEx, m_lFormatSize ) != m_lFormatSize )
	{
		DPF(("Write format Failed!\n"));
		Close();
		return( FALSE );
	}

	// Ascend out of the format subchunk.
	if( Ascend( &m_mmckinfoSubchunk ) )
	{
		DPF(("WriteHeader: Ascend format subchunk Failed\n"));
	}

	if( m_FormatEx.wFormatTag != WAVE_FORMAT_PCM )
	{
		DWORD dwSampleLength = 0;
		MMCKINFO mmckinfoFact;

		// create the fact chunk
		mmckinfoFact.ckid = mmioFOURCC('f','a','c','t');
		mmckinfoFact.cksize = sizeof( DWORD );
		if( CreateChunk( (LPMMCKINFO)&mmckinfoFact, (UINT)NULL ) )
		{
			DPF(("CreateChunk Fact subchunk Failed!\n"));
			Close();
			return( FALSE );
		}

		// write a dummy value for the fact chunk
		if( Write( (HPSTR)&dwSampleLength, sizeof( DWORD ) ) != (LONG)sizeof( DWORD ) )
		{
			DPF(("Write Fact subchunk Failed!\n"));
			Close();
			return( FALSE );
		}

		// Ascend out of the fact subchunk.
		if( Ascend( &mmckinfoFact ) )
		{
			DPF(("Ascend Fact subchunk Failed!\n"));
			Close();
			return( FALSE );
		}
	}

	// create the 'data' sub-chunk
	m_mmckinfoSubchunk.ckid = mmioFOURCC('d','a','t','a');
	m_mmckinfoSubchunk.dwFlags = MMIO_DIRTY;
	if( CreateChunk( (LPMMCKINFO)&m_mmckinfoSubchunk, (UINT)NULL ) )
	{
		DPF(("CreateChunk data Failed!\n"));
		Close();
		return( FALSE );
	}
	//DPF(("fccType [%08lx] %lu\n", m_mmckinfoSubchunk.fccType, m_mmckinfoSubchunk.cksize ));

	return( TRUE );
}

/////////////////////////////////////////////////////////////////////////////
int CWaveFile::UpdateHeader( void )
/////////////////////////////////////////////////////////////////////////////
{
	MMRESULT Result;

	// ascend out of the data subchunk
	Result = Ascend( &m_mmckinfoSubchunk );
	if( Result )
		DPF(("UpdateHeader: Ascend data subchunk failed!\n"));
	//DPF(("fccType [%08lx] %lu\n", m_mmckinfoSubchunk.fccType, m_mmckinfoSubchunk.cksize ));

	// ascend out of the WAVE chunk, which automaticlly updates the cksize field
	Result = Ascend( &m_mmckinfoParent );
	if( Result )
		DPF(("UpdateHeader: Ascend WAVE chunk failed %ld!\n", Result ));
	//DPF(("fccType [%08lx] %lu\n", m_mmckinfoParent.fccType, m_mmckinfoParent.cksize ));

	//MMSYSERR_INVALPARAM 
	// force write to disk
	Result = Flush( MMIO_EMPTYBUF );
	if( Result )
		DPF(("UpdateHeader: Flush failed!\n"));

	// if a compressed format, then update the fact chunk
	if( m_FormatEx.wFormatTag != WAVE_FORMAT_PCM )
	{
		DWORD		dwSampleLength;
		MMCKINFO	mmckinfoFact;

		// move to start of file
		SeekBegin( 0 );

		// find the WAVE chunk
		m_mmckinfoParent.fccType = mmioFOURCC('W','A','V','E');
		if( Descend( (LPMMCKINFO)&m_mmckinfoParent, NULL, MMIO_FINDRIFF ) )
		{
			Close();
			return( FALSE );
		}

		// Now, find the fact chunk 
		mmckinfoFact.ckid = mmioFOURCC('f','a','c','t');
		if( Descend( &mmckinfoFact, &m_mmckinfoParent, MMIO_FINDCHUNK ) )
		{
			Close();
			return( FALSE );
		}

		// compute out the number of samples
		dwSampleLength = GetSampleCount();

		// write the fact chunk
		if( Write( (HPSTR)&dwSampleLength, sizeof( DWORD )) != (LONG)sizeof( DWORD ) )
		{
			Close();
			return( FALSE );
		}

		// Ascend out of the fact subchunk.
		if( Ascend( &mmckinfoFact ) )
			DPF(("Ascend Failed\n"));
		// Ascend out of the WAVE chunk.
		if( Ascend( &m_mmckinfoParent ) )
			DPF(("Ascend Failed\n"));
	}

	return( TRUE );
}

/////////////////////////////////////////////////////////////////////////////
DWORD CWaveFile::GetSampleCount()
/////////////////////////////////////////////////////////////////////////////
{
	if( m_FormatEx.nBlockAlign )
		return( (m_dwDataSize / m_FormatEx.nBlockAlign) * m_wSamplesPerBlock );
	else
		return( 0 );
}

/////////////////////////////////////////////////////////////////////////////
LONG CWaveFile::GetBytesRemaining( void )
/////////////////////////////////////////////////////////////////////////////
{
	if( m_dwDataSize > m_dwBytesRead )
		return( (LONG)( m_dwDataSize - m_dwBytesRead ) );
	else
		return( 0 );
}

/////////////////////////////////////////////////////////////////////////////
LONG CWaveFile::ReadBlock( HPSTR pch, LONG cch )
/////////////////////////////////////////////////////////////////////////////
{
	LONG	lSize;

	lSize = Read( pch, cch );
	if( lSize != -1 )
		m_dwBytesRead += (DWORD)lSize;
	
	return( lSize );
}

/////////////////////////////////////////////////////////////////////////////
LONG CWaveFile::WriteBlock( HPSTR pch, LONG cch )
/////////////////////////////////////////////////////////////////////////////
{
	LONG	lSize;

	lSize = Write( pch, cch );
	if( lSize != cch )
		DPF(("WriteBlock: Did not write all the data!\n"));
	m_dwDataSize += (DWORD)lSize;
	//DPF(("WriteBlock %ld %ld %ld\n", cch, lSize, m_dwDataSize ));
	
	return( lSize );
}
