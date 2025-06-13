// HalWaveDMADevice.h: interface for the HalWaveDMADevice class.
//
//////////////////////////////////////////////////////////////////////

#ifndef _HALWAVEDMADEVICE_H
#define _HALWAVEDMADEVICE_H

#include "Hal.h"
#include "HalDMA.h"

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "HalWaveDevice.h"

class CHalWaveDMADevice : public CHalWaveDevice  
{
public:
	CHalWaveDMADevice()		{}
	~CHalWaveDMADevice()	{}

	USHORT	Open( PHALADAPTER pHalAdapter, ULONG ulDeviceNumber );
	USHORT	Close();

	USHORT	Start(BOOLEAN bDoPreload = TRUE);
	USHORT	Stop();

	PHALDMA	GetDMA()					{ return( &m_DMA );			}

	USHORT	Service( BOOLEAN bDMABufferComplete = FALSE );

	void	SetAutoFree( BOOLEAN bAutoFree )	{ m_bAutoFree = bAutoFree;		}
	void	SetOverrunIE( BOOLEAN bOverrunIE )	{ m_bOverrunIE = bOverrunIE;	}
	void	SetLimitIE( BOOLEAN bLimitIE )		{ m_bLimitIE = bLimitIE;		}
	void	SetDMASingle( BOOLEAN bDMASingle )	{ m_bDMASingle = bDMASingle;	}
	void	SetDualMono( BOOLEAN bDualMono )	{ m_bDualMono = bDualMono;		}

	BOOLEAN	IsDMAActive()				{ return( m_bIsDMAActive );	}
	BOOLEAN	GetOverrunIE()				{ return( m_bOverrunIE );	}
	BOOLEAN	GetLimitIE()				{ return( m_bLimitIE );		}
	BOOLEAN	GetDMASingle()				{ return( m_bDMASingle );	}
	BOOLEAN	GetDualMono()				{ return( m_bDualMono );	}

private:
	CHalDMA m_DMA;
	
	BOOLEAN	m_bAutoFree;
	BOOLEAN	m_bIsDMAActive;
	BOOLEAN	m_bOverrunIE;
	BOOLEAN	m_bLimitIE;
	BOOLEAN	m_bDMASingle;
	BOOLEAN	m_bDualMono;
};

#endif // _HALWAVEDMADEVICE_H
