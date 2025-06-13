/****************************************************************************
 HalSampleClock.cpp

 Description:	Lynx Application Programming Interface Header File

 Created: David A. Hoatson, September 2000
	
 Copyright © 2000 Lynx Studio Technology, Inc.

 This software contains the valuable TRADE SECRETS and CONFIDENTIAL INFORMATION 
 of Lynx Studio Technology, Inc. The software is protected under copyright 
 laws as an unpublished work of Lynx Studio Technology, Inc.  Notice is 
 for informational purposes only and does not imply publication.  The user 
 of this software may make copies of the software for use with products 
 manufactured by Lynx Studio Technology, Inc. or under license from 
 Lynx Studio Technology, Inc. and for no other use.

 THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
 KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR
 PURPOSE.

 Environment: 

 4 spaces per tab

 Revision History
 
 When      Who  Description
 --------- ---  ------------------------------------------------------------
 Nov 20 03 DAH	Changed override of sample rate to be disabled if bForce is set.
****************************************************************************/

#include <StdAfx.h>
#include "HalAdapter.h"

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalSampleClock::Open( PHALADAPTER pHalAdapter )
/////////////////////////////////////////////////////////////////////////////
{
	m_pHalAdapter	= pHalAdapter;
	m_ulSpeed		= 0xFFFFFFFF;	// invalid
	m_ulP			= 0xFFFFFFFF;	// invalid
	
	m_lRate			= -1;
	m_lSource		= -1;
	m_lReference	= -1;

	m_RegPLLCTL.Init( &m_pHalAdapter->GetRegisters()->PLLCTL, REG_WRITEONLY );
	
	Set( 44100, MIXVAL_L2_CLKSRC_INTERNAL, MIXVAL_CLKREF_AUTO );

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalSampleClock::Close()
/////////////////////////////////////////////////////////////////////////////
{
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalSampleClock::Set( long lRate, BOOLEAN bForce )
/////////////////////////////////////////////////////////////////////////////
{
	return( Set( lRate, m_lSource, m_lReference, bForce ) );
}

// Internal 32MHz Clock Standard Frequency PLL Values
// M,N,and P values selected for minimal PLL jitter and frequency error
static SRREGS	tbl32MHzClk[] =
{
	// Fsr	   M     N    PX2  
	//------------- SPEED 1X-------------------------
	{  8000,  125,  128, SR_P16 },	// exact
	{ 11025,  107,  151, SR_P16 },	// 10.6 ppm error
	{ 11025,  214,  151, SR_P8 },	// 10.6 ppm error (must be second so it is only selected for non-P16 firmware)
	{ 22050,  107,  151, SR_P8 },	// 10.6 ppm error
	{ 32000,  125,  128, SR_P4 },	// exact
	{ 44056,  266,  375, SR_P4 },	// 12.5 ppm error
	{ 44100,  107,  151, SR_P4 },	// 10.6 ppm error
	{ 44144,  206,  291, SR_P4 },	// 9.5  ppm error
	{ 48000,  125,  192, SR_P4 },	// exact
	//------------- SPEED 2X-------------------------
	{ 51200,  224,  367, SR_P4 },	// 4.36 ppm error, better jitter than 0ppm
	{ 52428,  211,  354, SR_P4 },	// 2.08ppm
	{ 88112,  266,  375, SR_P2 },	// 12.5 ppm error
	{ 88200,  107,  151, SR_P2 },	// 10.6 ppm error
	{ 88288,  206,  291, SR_P2 },	// 9.5  ppm error
	{ 96000,  125,  192, SR_P2 },	// exact
	//------------- SPEED 4X-------------------------
	{102400,  224,  367, SR_P4 },	// 4.36ppm
	{104857,  211,  354, SR_P4 },	// 2.08ppm
	{176224,  266,  375, SR_P2 },	// 12.5 ppm error	128FS runs at same rate as 2X speed
	{176400,  107,  151, SR_P2 },	// 10.6 ppm error	128FS runs at same rate as 2X speed
	{176576,  206,  291, SR_P2 },	// 9.5  ppm error	128FS runs at same rate as 2X speed
	{192000,  125,  192, SR_P2 },	// exact			128FS runs at same rate as 2X speed
	{200000,  125,  200, SR_P2 },	// exact			128FS runs at same rate as 2X speed
	{    -1,  125,    0, SR_P2 }	// this value is used to determine the incremental rates
};

// AES16 Internal Clock
static SRREGS	tbl40MHzClk[] =
{
	// Fsr	   M     N    PX2		// NOTE: The AES16 doesn't use the P register, divisor is controlled by SPEED bits
	//------------- SPEED 1X-------------------------
	{ 32000,  177,  145, SR_P4 },	// 11.03 ppm error
	{ 44056,  133,  150, SR_P4 },	// 12.45 ppm error
	{ 44100,  442,  499, SR_P4 },	//  0.64 ppm error
	{ 44144,  123,  139, SR_P4 },	//  4.51 ppm error
	{ 48000,  118,  145, SR_P4 },	// 11.03 ppm error
	//------------- SPEED 2X-------------------------
	{ 88112,  133,  150, SR_P2 },	// 12.45 ppm error
	{ 88200,  442,  499, SR_P2 },	//  0.64 ppm error
	{ 88288,  123,  139, SR_P2 },	//  4.51 ppm error
	{ 96000,  118,  145, SR_P2 },	// 11.03 ppm error
	//------------- SPEED 4X-------------------------
	{176224,  133,  150, SR_P2 },	// 12.45 ppm error	128FS runs at same rate as 2X speed
	{176400,  442,  499, SR_P2 },	//  0.64 ppm error	128FS runs at same rate as 2X speed
	{176576,  123,  139, SR_P2 },	//  4.51 ppm error	128FS runs at same rate as 2X speed
	{192000,  118,  145, SR_P2 },	// 11.03 ppm error	128FS runs at same rate as 2X speed
	{200000,  100,  128, SR_P2 },	// exact			128FS runs at same rate as 2X speed
	{    -1,  156,    0, SR_P2 }	// this value is used to determine the incremental rates
};

// 1X Pixel Clock
static SRREGS	tbl13p5MHzClk[] =
{
	// Fsr	   M     N    PX2   
	{  8000,  220,  534, SR_P16 },	// 5.54  ppm error
	{ 11025,  142,  475, SR_P16 },	// 1.123 ppm error
	{ 11025,  284,  475, SR_P8 },	// 1.123 ppm error (must be second so it is only selected for non-P16 firmware)
	{ 22050,  142,  475, SR_P8 },	// 1.123 ppm error
	{ 32000,  220,  534, SR_P4 },	// 5.54  ppm error
	{ 44056,  158,  528, SR_P4 },	// 12.8  ppm error
	{ 44100,  142,  475, SR_P4 },	// 1.123 ppm error
	{ 44144,  155,  519, SR_P4 },	// 5.09  ppm error
	{ 48000,  181,  659, SR_P4 },	// 1.349 ppm error
	{ 88112,  158,  528, SR_P2 },	// 12.8 ppm error
	{ 88200,  142,  475, SR_P2 },	// 1.123 ppm error
	{ 88288,  155,  519, SR_P2 },	// 5.09  ppm error
	{ 96000,  181,  659, SR_P2 },	// 1.349 ppm error
	{176224,  158,  528, SR_P2 },	// 12.8 ppm
	{176400,  142,  475, SR_P2 },	// 1.12 ppm
	{176576,  155,  519, SR_P2 },	// 5.09 ppm
	{192000,  181,  659, SR_P2 },	// 1.349 ppm
	{200000,  135,  512, SR_P2 },	// 0 ppm
	{    -1,   53,    0, SR_P2 }	// this value is used to determine the incremental rates
};

// Video Clock
static SRREGS	tbl24MHzClk[] =
{
	// Fsr	   M     N    PX2  
	{ 8000,   750, 1024, SR_P16 },	// 0 ppm
	{ 11025,  549, 1033, SR_P16 },	// 0 ppm
	{ 11025,  625,  588, SR_P8 },	// 0 ppm (must be second so it is only selected for non-P16 firmware)
	{ 22050,  549, 1033, SR_P8 },	// 1.5 ppm
	{ 32000,  750, 1024, SR_P4 },	// 0 ppm
	{ 44056,  582, 1094, SR_P4 },	// 1.3 ppm - 44056
	{ 44100,  549, 1033, SR_P4 },	// 1.5 ppm, better jitter than 0 ppm
	{ 44144,  575, 1083, SR_P4 },	// 0.5 ppm - 44144
	{ 48000,  500, 1024, SR_P4 },	// 0 ppm
	{ 88112,  582, 1094, SR_P2 },	// 1.3 ppm
	{ 88200,  549, 1033, SR_P2 },	// 1.5 ppm
	{ 88288,  575, 1083, SR_P2 },	// 0.5 ppm
	{ 96000,  500, 1024, SR_P2 },	// 0ppm
	{176224,  582, 1094, SR_P2 },	// 1.3 ppm
	{176400,  549, 1033, SR_P2 },	// 1.5 ppm
	{176576,  575, 1083, SR_P2 },	// 0.5 ppm
	{192000,  500, 1024, SR_P2 },	// 0 ppm
	{200000,  480, 1024, SR_P2 },	// 0 ppm
	{    -1,   94,    0, SR_P2 }	// this value is used to determine the incremental rates
};

// 2X Pixel Clock
static SRREGS	tbl27MHzClk[] =
{
	// Fsr	   M     N    PX2  
	{ 8000,   440,  534, SR_P16 },	// 5.54 ppm error
	{ 11025,  284,  475, SR_P16 },	// 1.12 ppm error
	{ 11025,  568,  475, SR_P8 },	// 1.12 ppm error (must be second so it is only selected for non-P16 firmware)
	{ 22050,  284,  475, SR_P8 },	// 1.12 ppm error
	{ 32000,  440,  534, SR_P4 },	// 5.54 ppm error
	{ 44056,  319,  533, SR_P4 },	// 10.9 ppm error
	{ 44100,  284,  475, SR_P4 },	// 1.12  ppm error
	{ 44144,  221,  370, SR_P4 },	// 3.63  ppm error
	{ 48000,  362,  659, SR_P4 },	// 1.3 ppm 
	{ 88112,  319,  533, SR_P2 },	// 10.9 ppm error
	{ 88200,  284,  475, SR_P2 },	// 1.12 ppm error
	{ 88288,  221,  370, SR_P2 },	// 3.63 ppm error
	{ 96000,  362,  659, SR_P2 },	// 1.3 ppm error
	{176224,  319,  533, SR_P2 },	// 10.9 ppm
	{176400,  284,  475, SR_P2 },	// 1.12 ppm error
	{176576,  221,  370, SR_P2 },	// 3.63 ppm
	{192000,  362,  659, SR_P2 },	// 1.3 ppm
	{200000,  135,  256, SR_P2 },	// 0 ppm
	{    -1,  105,    0, SR_P2 }	// this value is used to determine the incremental rates
};

// Specific Values for TI Video PLL
static SRREGS	tblTIPll_27MHzClk[] =
{
	// Fsr	   M     N    PX2  
	{ 8000,   543,  659, SR_P16 },	// 1.35 ppm error
	{ 11025,  568,  950, SR_P16 },	// 1.12  ppm error
	{ 11025,  568,  475, SR_P8 },	// 1.12 ppm error (must be second so it is only selected for non-P16 firmware)
	{ 22050,  568,  950, SR_P8 },	// 1.12  ppm error
	{ 32000,  543,  659, SR_P4 },	// 1.35 ppm error
	{ 44056,  319,  533, SR_P4 },	// 10.9 ppm error
	{ 44100,  568,  950, SR_P4 },	// 1.12  ppm error
	{ 44144,  221,  370, SR_P4 },	// 3.63  ppm error
	{ 48000,  362,  659, SR_P4 },	// 1.35 ppm 
	{ 88112,  319,  533, SR_P2 },	// 10.9 ppm error
	{ 88200,  568,  950, SR_P2 },	// 1.12  ppm error
	{ 88288,  221,  370, SR_P2 },	// 3.63 ppm error
	{ 96000,  362,  659, SR_P2 },	// 1.3 ppm error
	{176224,  319,  533, SR_P2 },	// 10.9 ppm
	{176400,  568,  950, SR_P2 },	// 1.12  ppm error
	{176576,  221,  370, SR_P2 },	// 3.63 ppm
	{192000,  362,  659, SR_P2 },	// 1.3 ppm
	{200000,  270,  512, SR_P2 },	// 0 ppm
	{    -1,  105,    0, SR_P2 }	// this value is used to determine the incremental rates
};

#define ARRAYSIZE( a )		(sizeof(a)/sizeof(a[0]))

/////////////////////////////////////////////////////////////////////////////
USHORT CHalSampleClock::Set( long lRate, long lSource, long lReference, BOOLEAN bForce )
/////////////////////////////////////////////////////////////////////////////
{
	PLLCLOCKINFO	ClockInfo;
	PHAL8420		pCS8420 = m_pHalAdapter->Get8420();
	PHAL4114		pAK4114 = m_pHalAdapter->Get4114();
	PHALMIXER		pMixer = m_pHalAdapter->GetMixer();
	USHORT			usDeviceID = m_pHalAdapter->GetDeviceID();
	long			lOriginalSource = m_lSource;
	ULONG			bWideWireIn;

	// correct any code that isn't AES16 aware
	if( pAK4114 && (lSource < MIXVAL_AES16_CLKSRC_INTERNAL) )
		lSource += MIXVAL_AES16_CLKSRC_INTERNAL;

	// if there is no change from current setting, just return.
	if( (m_lRate == lRate)
	 && (m_lSource == lSource)
	 && (m_lReference == lReference)
	 && !bForce )	// if Force is set, always run the entire routine
	{
		return( HSTATUS_OK );
	}

	// if this firmware doesn't support P16, then the lowest sample rate is 11025, not 8000
	if( !m_pHalAdapter->HasP16() )
		if( lRate < 11025 )
			lRate = 11025;

	// the lowest sample rate for the AES16 is 32kHz, highest is 192kHz
	if( pAK4114 )
	{
		if( lRate < 32000 )
		{
			lRate = 32000;
		}
		if( lRate > 192000 )
		{
			lRate = 192000;
		}
		
		// read the wide wire bit for use later on...
		pAK4114->GetWideWireIn( &bWideWireIn );
	}

	// if the requested sample rate is less than the minimum rate, set it at the minimum
	if( lRate < MIN_SAMPLE_RATE )
	{
		lRate = MIN_SAMPLE_RATE;
	}
	
	// if the requested sample rate is greater than the maximum rate, set it at the maximum
	if( lRate > MAX_SAMPLE_RATE )
	{
		lRate = MAX_SAMPLE_RATE;
	}

	if( !bForce )
	{
		// if we are trying to clock from an external input, make sure that input is running at the correct rate
		if( GetClockRate( &lRate, &lSource, &lReference ) )
		{
			DPF(("CHalSampleClock::GetClockRate Failed!\n"));
			return( HSTATUS_INVALID_MODE );
		}

		// make sure all the devices are idle
		if( m_pHalAdapter->GetNumActiveWaveDevices() )
		{
			DPF(("CHalSampleClock::Set: Device in use. Cannot change sample rate.\n"));
			return( HSTATUS_ALREADY_IN_USE );
		}
	}

	//DPF(("CHalSampleClock::Set %ld\n", lRate ));

	// start off with everything turned off
	RtlZeroMemory( &ClockInfo, sizeof( PLLCLOCKINFO ) );

	if( pAK4114 )	ClockInfo.ulClkSrc = lSource - MIXVAL_AES16_CLKSRC_INTERNAL;
	else			ClockInfo.ulClkSrc = lSource;

	switch( lSource )
	{
	case MIXVAL_L2_CLKSRC_INTERNAL:
	case MIXVAL_AES16_CLKSRC_INTERNAL:
		//DPF(("MIXVAL_L2_CLKSRC_INTERNAL\n"));
		lReference = MIXVAL_CLKREF_AUTO;
		if( m_pHalAdapter->Has40MHzXtal() )
			GetClockInfo( &lRate, tbl40MHzClk, &ClockInfo, ARRAYSIZE(tbl40MHzClk) );
		else
			GetClockInfo( &lRate, tbl32MHzClk, &ClockInfo, ARRAYSIZE(tbl32MHzClk) );
		break;
	case MIXVAL_L2_CLKSRC_EXTERNAL:
	case MIXVAL_L2_CLKSRC_HEADER:
	case MIXVAL_AES16_CLKSRC_EXTERNAL:
	case MIXVAL_AES16_CLKSRC_HEADER:
		//DPF(("MIXVAL_L2_CLKSRC_EXTERNAL/HEADER\n"));
		// make sure we allow the change from INTERNAL or DIGITAL
		if( lReference == MIXVAL_CLKREF_AUTO )
			lReference = MIXVAL_CLKREF_27MHZ;

		switch( lReference )
		{
		case MIXVAL_CLKREF_WORD:
			//DPF(("MIXVAL_CLKREF_WORD\n"));
			// Just set the word bit here, the rest will get taken care of later.
			ClockInfo.ulWord	= 1;
			break;
		case MIXVAL_CLKREF_WORD256:
			//DPF(("MIXVAL_CLKREF_WORD256\n"));
						
			//Set M,N,P for quad, single, double speed
			if( lRate > 100000 )		{ ClockInfo.ulM	= 96;	ClockInfo.ulN	= 96;	ClockInfo.ulP	= SR_P2; }
			else if( lRate > 50000 )	{ ClockInfo.ulM	= 48;	ClockInfo.ulN	= 96;	ClockInfo.ulP	= SR_P2; }
			else						{ ClockInfo.ulM	= 24;	ClockInfo.ulN	= 96;	ClockInfo.ulP	= SR_P4; }
			
			break;
		case MIXVAL_CLKREF_13p5MHZ:
			//DPF(("MIXVAL_CLKREF_13p5MHZ\n"));
			GetClockInfo( &lRate, tbl13p5MHzClk, &ClockInfo, ARRAYSIZE(tbl13p5MHzClk) );
			break;
		case MIXVAL_CLKREF_27MHZ:
			//DPF(("MIXVAL_CLKREF_27MHZ\n"));
			GetClockInfo( &lRate, tbl27MHzClk, &ClockInfo, ARRAYSIZE(tbl27MHzClk) );
			break;
		default:
			DPF(("Invalid lReference [%08lx]\n", lReference ));
			return( HSTATUS_INVALID_MIXER_VALUE );
		}
		break;
	case MIXVAL_L2_CLKSRC_VIDEO:
		//DPF(("MIXVAL_L2_CLKSRC_VIDEO\n"));
		if( usDeviceID == PCIDEVICE_LYNX_L22 )
			return( HSTATUS_INVALID_MIXER_VALUE );

		lReference	= MIXVAL_CLKREF_AUTO;
		if( m_pHalAdapter->HasTIVideoPLL() )
			GetClockInfo( &lRate, tblTIPll_27MHzClk, &ClockInfo, ARRAYSIZE(tblTIPll_27MHzClk) );
		else
			GetClockInfo( &lRate, tbl24MHzClk, &ClockInfo, ARRAYSIZE(tbl24MHzClk) );
		break;
	case MIXVAL_L2_CLKSRC_LSTREAM_PORT1:
	case MIXVAL_L2_CLKSRC_LSTREAM_PORT2:
	case MIXVAL_AES16_CLKSRC_LSTREAM:
		//DPF(("MIXVAL_L2_CLKSRC_LSTREAM_PORTX\n"));
		lReference = MIXVAL_CLKREF_WORD;	// force to word
		// Just set the word bit here, the rest will get taken care of later.
		ClockInfo.ulWord	= 1;
		break;
	case MIXVAL_AES16_CLKSRC_DIGITAL_2:
	case MIXVAL_AES16_CLKSRC_DIGITAL_3:
		// rev NC AES16 boards can only sync to digital in 1 & 2
		if( pAK4114 && !m_pHalAdapter->GetPCBRev() )
			return( HSTATUS_INVALID_MIXER_VALUE );
	case MIXVAL_L2_CLKSRC_DIGITAL:
	case MIXVAL_AES16_CLKSRC_DIGITAL_0:
	case MIXVAL_AES16_CLKSRC_DIGITAL_1:
		//DPF(("MIXVAL_L2_CLKSRC_DIGITAL\n"));
		lReference	= MIXVAL_CLKREF_AUTO;	// force to auto
		// Just set the word bit here, the rest will get taken care of later.
		ClockInfo.ulWord	= 1;
		break;
	default:
		DPF(("Invalid lSource [%08lx]\n", lSource ));
		return( HSTATUS_INVALID_MIXER_VALUE );
	}

	// if this is a word clock, limit the sample rate
	if( lReference == MIXVAL_CLKREF_WORD )
	{
		if( m_lReference != lReference )
		{
			if( lRate < 24000 )
				lRate = 44100;
		}
		if( lRate < 24000 )
		{
			//DPF(("Invalid Sample Rate for Word Clock!\n"));
			DPF(("SetSampleRate: Word Clock Below 24000!\n")); 
			return( HSTATUS_INVALID_SAMPLERATE );
		}
	}

	// Set the speed based on the sample rate
	if( lRate > 100000 )		ClockInfo.ulSpeed	= SR_SPEED_4X;
	else if( lRate > 50000 )	ClockInfo.ulSpeed	= SR_SPEED_2X;
	else						ClockInfo.ulSpeed	= SR_SPEED_1X;

	// if the word bit is set, make sure the M, N & P registers are correct for the speed setting
	if( ClockInfo.ulWord )
	{
		ClockInfo.ulM		= 1;		// Ignored
		ClockInfo.ulBypassM	= 1;

		switch( ClockInfo.ulSpeed )
		{
		case SR_SPEED_1X:
			ClockInfo.ulN		= 1024;
			ClockInfo.ulP		= SR_P4;
			break;
		case SR_SPEED_2X:
			ClockInfo.ulN		= 512;
			ClockInfo.ulP		= SR_P2;
			break;
		case SR_SPEED_4X:
			ClockInfo.ulN		= 256;
			ClockInfo.ulP		= SR_P2;
			break;
		}
	}
	
	// if this is an AES16, and the speed isn't 1X, and widewire is on, and the digital input is the sample clock source
	// NOTE: WideWire has already been read above
	if( pAK4114 && (lRate > 50000) && bWideWireIn && ((lSource >= MIXVAL_AES16_CLKSRC_DIGITAL_0) || ((lSource == MIXVAL_AES16_CLKSRC_EXTERNAL) && (lReference == MIXVAL_CLKREF_WORD))) )
	{
		ClockInfo.ulN *= 2;	// double the N value
	}
	
	// change the sample rate in hardware
	//DPF(("Changing Sample Rate in Hardware\n"));
	if( (usDeviceID == PCIDEVICE_LYNXTWO_A) && !m_pHalAdapter->GetPCBRev() )	// is this a Model A rev NC board?
		m_RegPLLCTL = MAKE_PLLCTL_L2AREVNC( ClockInfo.ulM, ClockInfo.ulBypassM, ClockInfo.ulN, ClockInfo.ulP, ClockInfo.ulClkSrc, ClockInfo.ulWord, ClockInfo.ulSpeed );
	else
		m_RegPLLCTL = MAKE_PLLCTL( ClockInfo.ulM, ClockInfo.ulBypassM, ClockInfo.ulN, ClockInfo.ulP, ClockInfo.ulClkSrc, ClockInfo.ulWord, ClockInfo.ulSpeed );

	//set speed in A/D and D/A
	// since these writes are slow, update only if there is a speed change.
	if( m_ulSpeed != ClockInfo.ulSpeed )
	{
		m_pHalAdapter->SetConverterSpeed( lRate );
	}

	// if auto-recalibration is on (which is the default)
	if( m_pHalAdapter->GetAutoRecalibrate() )
	{
		// if P changed or the sample clock changed, recalibrate the converters
		if( (m_lSource != lSource) || (m_lReference != lReference) || (m_ulP != ClockInfo.ulP ) )
		{
			m_pHalAdapter->CalibrateConverters();
		}
	}

	// save the new values
	if( m_lSource != lSource )			pMixer->ControlChanged( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_CLOCKSOURCE );
	if( m_lReference != lReference )	pMixer->ControlChanged( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_CLOCKREFERENCE );
	if( m_lRate != lRate )				pMixer->ControlChanged( LINE_ADAPTER, LINE_NO_SOURCE, CONTROL_CLOCKRATE );

	m_lSource		= lSource;
	m_lReference	= lReference;
	m_lRate			= lRate;
	m_ulSpeed		= ClockInfo.ulSpeed;
	m_ulP			= ClockInfo.ulP;
	
	// if the Sample Clock Source is Digital, then we must set the 8420 to Mode 3
	if( pCS8420 && (m_lSource == MIXVAL_L2_CLKSRC_DIGITAL) )
	{
		// only make the change if the original source was internal
		if( lOriginalSource == MIXVAL_L2_CLKSRC_INTERNAL )
		{
			pCS8420->SetMode( MIXVAL_SRCMODE_SRC_OFF );
		}
	}

	// let the 8420 update the digital out channel status.  Since the 8420 is opened after 
	// the sample clock, make sure we don't call the 8420 until after the adapter is opened.
	if( m_pHalAdapter->IsOpen() )
	{
		if( pCS8420 )	pCS8420->SampleClockChanged( m_lRate );
		if( pAK4114 )	pAK4114->SampleClockChanged( m_lRate, m_lSource );
		m_pHalAdapter->GetLStream()->SampleClockChanged( m_lRate, m_lSource, m_lReference );
	}

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalSampleClock::Get(long *plRate)
/////////////////////////////////////////////////////////////////////////////
{
	*plRate = m_lRate;

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalSampleClock::Get(long *plRate, long *plSource, long *plReference)
/////////////////////////////////////////////////////////////////////////////
{
	*plRate			= m_lRate;
	*plSource		= m_lSource;
	*plReference	= m_lReference;

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalSampleClock::GetClockRate( long *plRate, long *plSource, long *plReference )
/////////////////////////////////////////////////////////////////////////////
{
	PHAL8420	pCS8420 = m_pHalAdapter->Get8420();
	PHAL4114	pAK4114 = m_pHalAdapter->Get4114();
	ULONG		bWideWireIn = FALSE;
	LONG		lDigitalInRate;
	ULONG		ulFrequency;
	USHORT		usRegister = 0;

	if( pAK4114 )
	{
		// read the wide wire bit for use later on...
		pAK4114->GetWideWireIn( &bWideWireIn );
	}

	switch( *plSource )
	{
	case MIXVAL_L2_CLKSRC_DIGITAL:
		// if we are requesting the clock source to switch to Digital, make sure the Digital Input is locked
		if( pCS8420 )
		{
			// make sure the sample rate matches the digital input rate (Normalize gets called for us here...)
			pCS8420->GetInputSampleRate( &lDigitalInRate );

			if( !lDigitalInRate )
			{
				DPF(("CHalSampleClock::Set: Digital In not locked!\n")); 
				return( HSTATUS_INVALID_MODE );
			}
			
			// force the sample rate to the digital input rate
			*plRate = lDigitalInRate;
		}
		break;

	case MIXVAL_AES16_CLKSRC_DIGITAL_0:
	case MIXVAL_AES16_CLKSRC_DIGITAL_1:
	case MIXVAL_AES16_CLKSRC_DIGITAL_2:
	case MIXVAL_AES16_CLKSRC_DIGITAL_3:
		// if we are requesting the clock source to switch to Digital, make sure the Digital Input is locked
		if( pAK4114 )
		{
			// make sure the sample rate matches the digital input rate (Normalize gets called for us here...)
			pAK4114->GetInputRate( (*plSource - MIXVAL_AES16_CLKSRC_DIGITAL_0), &lDigitalInRate );
			
			if( !lDigitalInRate )
			{
				DPF(("CHalSampleClock::Set: Digital In not locked!\n")); 
				return( HSTATUS_INVALID_MODE );
			}

			// wire wire has already been read above
			if( bWideWireIn )
			{
				//DPF(("WideWire is on, doubling the lDigitalInRate %ld to %ld\n", lDigitalInRate, lDigitalInRate*2 )); 
				lDigitalInRate *= 2;
			}

			// force the sample rate to the digital input rate
			*plRate = lDigitalInRate;
		}
		break;
	
	case MIXVAL_L2_CLKSRC_EXTERNAL:
	case MIXVAL_L2_CLKSRC_HEADER:
	case MIXVAL_AES16_CLKSRC_EXTERNAL:
	case MIXVAL_AES16_CLKSRC_HEADER:
		// External or Internal Clock
		switch( *plSource )
		{
		case MIXVAL_L2_CLKSRC_EXTERNAL:		usRegister = L2_FREQCOUNTER_EXTERNAL;		break;
		case MIXVAL_L2_CLKSRC_HEADER:		usRegister = L2_FREQCOUNTER_HEADER;			break;
		case MIXVAL_AES16_CLKSRC_EXTERNAL:	usRegister = AES16_FREQCOUNTER_EXTERNAL;	break;
		case MIXVAL_AES16_CLKSRC_HEADER:	usRegister = AES16_FREQCOUNTER_HEADER;		break;
		}

		// get the current clock rate of that port
		m_pHalAdapter->GetFrequencyCounter( usRegister, &ulFrequency );

		// normalize the frequency
		m_pHalAdapter->NormalizeFrequency( ulFrequency, &lDigitalInRate, plReference );

		// only if the reference is WORD or WORD256 can we determine the correct sample rate
		if( (*plReference == MIXVAL_CLKREF_WORD) || (*plReference == MIXVAL_CLKREF_WORD256) )
		{
			if( !lDigitalInRate )
			{
				DPF(("CHalSampleClock::Set: External or Header Port not locked!\n")); 
				return( HSTATUS_INVALID_MODE );
			}

			// If we are on an AES16 & WideWire is on (it has already been read above) double the rate
			if( pAK4114 && (*plSource == MIXVAL_AES16_CLKSRC_EXTERNAL) && bWideWireIn )
			{
				//DPF(("WideWire is on, doubling the lDigitalInRate %ld to %ld\n", lDigitalInRate, lDigitalInRate*2 )); 
				lDigitalInRate *= 2;
			}
			
			// force the sample rate to the measured clock rate
			*plRate = lDigitalInRate;
		}
		break;

	case MIXVAL_L2_CLKSRC_LSTREAM_PORT1:
	case MIXVAL_L2_CLKSRC_LSTREAM_PORT2:
	case MIXVAL_AES16_CLKSRC_LSTREAM:
		// if we are requesting the clock source to switch to LStream 1 or 2, check the rates to make sure they are valid
		ULONG	ulPort = (*plSource == MIXVAL_L2_CLKSRC_LSTREAM_PORT1) ? LSTREAM_BRACKET : LSTREAM_HEADER;
		ULONG	ulLStreamDeviceID;
		
		switch( *plSource )
		{
		case MIXVAL_L2_CLKSRC_LSTREAM_PORT1:	usRegister = L2_FREQCOUNTER_LSTREAM1;	ulPort = LSTREAM_BRACKET;	break;
		case MIXVAL_L2_CLKSRC_LSTREAM_PORT2:	usRegister = L2_FREQCOUNTER_LSTREAM2;	ulPort = LSTREAM_HEADER;	break;
		case MIXVAL_AES16_CLKSRC_LSTREAM:		usRegister = AES16_FREQCOUNTER_LSTREAM;	ulPort = LSTREAM_HEADER;	break;
		}
		// go see what is plugged into the requested LStream port
		ulLStreamDeviceID = m_pHalAdapter->GetLStream()->GetDeviceID( ulPort );

		// NOTE: If there is no LStream device ID, we go ahead and let things get set - even though we probably shouldn't
		if( ulLStreamDeviceID )
		{
			if( ulLStreamDeviceID == REG_LSDEVID_LSAES )
			{
				// Change the source to HEADER and measure the frequency from the header
				if( *plSource == MIXVAL_AES16_CLKSRC_LSTREAM )
				{
					*plSource		= MIXVAL_AES16_CLKSRC_HEADER;
					*plReference	= MIXVAL_CLKREF_WORD;
					usRegister		= AES16_FREQCOUNTER_HEADER;
				}
				else
				{
					*plSource		= MIXVAL_L2_CLKSRC_HEADER;
					*plReference	= MIXVAL_CLKREF_WORD;
					usRegister		= L2_FREQCOUNTER_HEADER;
				}
			}
			
			// get the current clock rate of that port
			m_pHalAdapter->GetFrequencyCounter( usRegister, &ulFrequency );

			// normalize the frequency (we don't care about the reference because we know this is a word clock)
			m_pHalAdapter->NormalizeFrequency( ulFrequency, &lDigitalInRate );
			
			// if we measured a rate
			if( lDigitalInRate )
			{
				// if there is an LS-ADAT connected, allow 2X & 4X rates to pass
				if( ulLStreamDeviceID == REG_LSDEVID_LSADAT )
				{
					if( *plRate != (lDigitalInRate * 2) )
					{
						if( *plRate != (lDigitalInRate * 4) )
						{
							*plRate = lDigitalInRate;
						}
					}
				}
				else
				{
					// force the sample rate to the LStream rate
					*plRate = lDigitalInRate;
				}
			}
		}
		break;
	} // switch

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT CHalSampleClock::GetMinMax( long *plMin, long *plMax )
/////////////////////////////////////////////////////////////////////////////
{
	if( m_pHalAdapter->HasP16() )
		*plMin	= MIN_SAMPLE_RATE;
	else
		*plMin	= 11025;

	*plMax	= MAX_SAMPLE_RATE;

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalSampleClock::GetClockInfo( long *plRate, PSRREGS pSRRegs, PPLLCLOCKINFO pClockInfo, int ulNumberOfEntires )
// private
/////////////////////////////////////////////////////////////////////////////
{
	int	i;

	//DPF(("CHalSampleClock::GetClockInfo\n"));

	ulNumberOfEntires--;	// last entry in table is always the M value to use for the non-table based sample rates

	// search for the sample rate in our table
	for( i=0; i<ulNumberOfEntires; i++ )
	{
		// if this firmware doesn't support P16, and this table entry specifies P16, skip it
		if( !m_pHalAdapter->HasP16() && (pSRRegs[i].usP == SR_P16)  )
			continue;

		if( *plRate == pSRRegs[i].lSRate )
		{
			pClockInfo->ulM		= pSRRegs[i].usM;
			pClockInfo->ulN		= pSRRegs[i].usN;
			pClockInfo->ulP		= pSRRegs[i].usP;
			break;	// done
		}
	}

	// if we didn't find a rate in the table
	if( i==ulNumberOfEntires )
	{
		pClockInfo->ulM		= pSRRegs[i].usM;	// get the special value at the end of the table
		
		if( *plRate > 100000 )		//1000 Hz resolution
		{
			pClockInfo->ulN		= *plRate / 1000;
			pClockInfo->ulP		= SR_P2;	// SPEED bits makes this P1
			*plRate				= pClockInfo->ulN * 1000;
		}	
		else if( *plRate > 50000 )		//500 Hz resolution
		{
			pClockInfo->ulN		= *plRate / 500;
			pClockInfo->ulP		= SR_P2;
			*plRate				= pClockInfo->ulN * 500;
		}				
		else if( *plRate > 25000 )		//250 Hz resolution
		{
			pClockInfo->ulN		= *plRate / 250;
			pClockInfo->ulP		= SR_P4;
			*plRate				= pClockInfo->ulN * 250;
		}
		else if( *plRate > 12500 )	//125 Hz resolution
		{
			pClockInfo->ulN		= *plRate / 125;
			pClockInfo->ulP		= SR_P8;
			*plRate				= pClockInfo->ulN * 125;
		}
		else // Samples Rates 0 - 15kHz  - 62.5 Hz resoluion
		{
			if( m_pHalAdapter->HasP16() )
			{
				pClockInfo->ulN	= (*plRate * 2) / 125;
				pClockInfo->ulP	= SR_P16;	//works with FW with 4 bit P counter
				*plRate			= (pClockInfo->ulN * 125) / 2;
			}
			else	// lowest sample rate is limited in SetSampleRate to 11025
			{
				pClockInfo->ulN	= *plRate / 125;
				pClockInfo->ulP	= SR_P8;
				*plRate			= pClockInfo->ulN * 125;
			}
		}
	}
	return( HSTATUS_OK );
}
