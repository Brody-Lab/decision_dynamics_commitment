/****************************************************************************
 HalMixer.h

 Description:	Lynx Application Programming Interface Header File

 Created: David A. Hoatson, September 2000
	
 Copyright © 2000-2003 Lynx Studio Technology, Inc.

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
 May 19 03 DAH	Added MIXER_CONTROL_TYPE_xxx enums
****************************************************************************/

#ifndef _HALMIXER_H
#define _HALMIXER_H

#include "Hal.h"
#include "HalPlayMix.h"	// Includes LynxTWO.h
#include "HalRecordMix.h"

#include <SharedControls.h>
#include <ControlList.h>

/////////////////////////////////////////////////////////////////////////////
// Control Values
/////////////////////////////////////////////////////////////////////////////

enum
{
	MIXER_CONTROL_TYPE_VOLUME=0,
	MIXER_CONTROL_TYPE_PAN,
	MIXER_CONTROL_TYPE_PEAKMETER,
	MIXER_CONTROL_TYPE_MUTE,
	MIXER_CONTROL_TYPE_MUX,
	MIXER_CONTROL_TYPE_MIXER,
	MIXER_CONTROL_TYPE_BOOLEAN,
	MIXER_CONTROL_TYPE_UNSIGNED
};

#define LEFT	0
#define	RIGHT	1

enum
{
	MIXVAL_TRIM_PLUS4=0,
	MIXVAL_TRIM_MINUS10,
	MIXVAL_TRIM_COUNT
};

enum
{
	MIXVAL_DF_AESEBU=0,
	MIXVAL_DF_SPDIF,
	MIXVAL_DF_COUNT
};

enum
{
	MIXVAL_TCFRAMERATE_24FPS=0,
	MIXVAL_TCFRAMERATE_25FPS,
	MIXVAL_TCFRAMERATE_2997FPS,
	MIXVAL_TCFRAMERATE_30FPS,
	MIXVAL_TCFRAMERATE_COUNT
};

enum
{
	MIXVAL_TCSYNCSOURCE_INTERNAL=0,
	MIXVAL_TCSYNCSOURCE_VIDEOIN,
	MIXVAL_TCSYNCSOURCE_COUNT
};

// Values for CONTROL_DITHER
enum
{
	MIXVAL_DITHER_NONE=0,
	MIXVAL_DITHER_TRIANGULAR_PDF,
	MIXVAL_DITHER_TRIANGULAR_NS_PDF,		// noise shaped triangular
	MIXVAL_DITHER_RECTANGULAR_PDF,
	MIXVAL_DITHER_COUNT
};

enum
{
	MIXVAL_DITHERDEPTH_AUTO=0,
	MIXVAL_DITHERDEPTH_8BIT,
	MIXVAL_DITHERDEPTH_16BIT,
	MIXVAL_DITHERDEPTH_20BIT,
	MIXVAL_DITHERDEPTH_24BIT,
	MIXVAL_DITHERDEPTH_COUNT
};

#define NOT_CONNECTED	0xFFFF

class CHalMixer  
{
public:
	CHalMixer()		{	m_bOpen = FALSE;	}
	~CHalMixer()	{}

	USHORT	Open( PHALADAPTER pHalAdapter );
	USHORT	Close();
	
	USHORT	RegisterCallbacks( PMIXERCONTROLCHANGEDCALLBACK pControlChangedCallback, PMIXERSCENECALLBACK pRestoreSceneCallback, PMIXERSCENECALLBACK pSaveSceneCallback, PVOID pContext );
	USHORT	ControlChanged( USHORT usDstLine, USHORT usSrcLine, USHORT usControl );
	
	USHORT	SetDefaults( BOOLEAN bDriverLoading = FALSE );

	BOOLEAN	IsOpen()						{	return( m_bOpen );			}

	USHORT	GetFirstMatchingLine( USHORT usSource, PUSHORT pusDstLine, PUSHORT pusSrcLine );

	USHORT	GetSharedControls( USHORT usControl, PSHAREDCONTROLS pShared );
	ULONG	GetControlType( USHORT usControl );
	BOOLEAN	IsControlWriteable( USHORT usControl );
	USHORT	GetControl( USHORT usDstLine, USHORT usSrcLine, USHORT usControl, USHORT usChannel, PULONG pulValue, ULONG ulSize = 4 );
	USHORT	SetControl( USHORT usDstLine, USHORT usSrcLine, USHORT usControl, USHORT usChannel, ULONG ulValue );

	CHalPlayMix *GetPlayMix( USHORT usChannel )		{	return( &m_aPlayMix[ usChannel ] );		}

private:
	BOOLEAN			m_bOpen;
	PHALSAMPLECLOCK m_pSampleClock;
	PHAL8420		m_pCS8420;
	PHAL4114		m_pAK4114;
	PHALADAPTER		m_pHalAdapter;
	PHALLSTREAM		m_pLStream;
	PHALTIMECODE	m_pTCTx;
	PHALTIMECODE	m_pTCRx;

	USHORT			m_usDeviceID;		// from HalAdapter.cpp

	CHalPlayMix		m_aPlayMix[ NUM_WAVE_PHYSICAL_OUTPUTS ];
	CHalRecordMix	m_aRecordMix[ NUM_WAVE_PHYSICAL_INPUTS ];
	//CHalMonitorMix	m_aMonitorMix[ NUM_WAVE_DEVICES ];

	PMIXERCONTROLCHANGEDCALLBACK	m_pControlChangedCallback;
	PMIXERSCENECALLBACK				m_pSaveSceneCallback;
	PMIXERSCENECALLBACK				m_pRestoreSceneCallback;
	PVOID							m_pContext;

	BOOLEAN			m_bMixerLock;
};

#endif // _HALMIXER_H
