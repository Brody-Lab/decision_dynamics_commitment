/****************************************************************************
 HalDMA.cpp

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
****************************************************************************/

#ifndef LINUX
#include <StdAfx.h>
#endif

#include "HalAdapter.h"

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalDMA::Open( PHALADAPTER pHalAdapter, ULONG ulDeviceNumber )
/////////////////////////////////////////////////////////////////////////////
{
	//DPF(("CHalDMA::Open\n"));

	// set defaults values for member variables
	m_pHalAdapter		= pHalAdapter;
	m_pWaveDMADevice	= m_pHalAdapter->GetWaveDMADevice( ulDeviceNumber );
	m_ulDeviceNumber	= ulDeviceNumber;
	
	// play devices are after record devices so this will work for both
	m_pBufferBlock		= &m_pHalAdapter->GetDMABufferList()->Record[ ulDeviceNumber ];
	m_pRegStreamControl	= m_pWaveDMADevice->GetStreamControl();

	m_ulPCBufferIndex	= 0;
	m_lEntriesInList	= 0;
	m_ulLastBufferIndex = 0xFFFFFFFF;	// Invalid
	m_ulPreloadSize		= 0;

	// make sure the DMA buffer block gets cleared
	RtlZeroMemory( m_pBufferBlock, sizeof( DMABUFFERBLOCK ) );

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalDMA::Close()
/////////////////////////////////////////////////////////////////////////////
{
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalDMA::StartPlayPreload()
// DMA Buffer List should have at least one entry already.
/////////////////////////////////////////////////////////////////////////////
{
	if( !m_pWaveDMADevice->IsRecord() )
	{
#ifdef DEBUG
		// make sure there is at least one buffer in the DMA buffer list
		if( !m_lEntriesInList )
		{
			DPF(("CHalDMA::StartPlayPreload called when NO buffers have been added!\n"));
		}
#endif
		m_ulPreloadSize = (m_pBufferBlock->Entry[ 0 ].ulControl & DMACONTROL_BUFLEN_MASK);

		//DPF(("StartPlayPreload\n"));
		DB('P',COLOR_UNDERLINE);
		// DAH 08/13/2003 Turned DMASINGLE back on so 1024 buffer size in ASIO will playback both channels.
		// we just read from this register in Start, so no extra read is needed here to update the shadow register.
		m_pRegStreamControl->BitSet( (REG_STREAMCTL_DMAEN | REG_STREAMCTL_DMAHST | REG_STREAMCTL_DMASINGLE), TRUE );
	}

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
BOOLEAN	CHalDMA::IsPreloadComplete()
// Returns TRUE immediately if this is a record device
/////////////////////////////////////////////////////////////////////////////
{
	BOOLEAN	bComplete = TRUE;

	if( !m_pWaveDMADevice->IsRecord() )
	{
		// DAH 09/10/2004 changed to waiting on DMA entry 0 having its length set to 0 to keep
		// the driver from accessing the PCI bus in such a tight loop while in preload mode.
		// This was causing audio break-up on other devices that were already running.
		if( !m_ulPreloadSize )
		{
			bComplete = TRUE;
		}
		else
		{
			bComplete = (m_pBufferBlock->Entry[ 0 ].ulControl & DMACONTROL_BUFLEN_MASK) != m_ulPreloadSize;
		}
		//bComplete = (m_pRegStreamControl->Read() & REG_STREAMCTL_DMAHST) ? FALSE : TRUE;
	}

	return( bComplete );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalDMA::WaitForPreloadToComplete()
// return value is ignored
/////////////////////////////////////////////////////////////////////////////
{
	int nCounter;
#define PRELOAD_TIMEOUT	1000000
	// wait for the preload to complete
	for( nCounter=0; nCounter < PRELOAD_TIMEOUT; nCounter++ )
		if( IsPreloadComplete() )
			break;

#ifdef DEBUG
	if( nCounter > (PRELOAD_TIMEOUT-1) )
	{
		DPF(("CHalDMA::Start: Preload Counter Timeout!\n"));
		return( HSTATUS_TIMEOUT );
	}
#endif

	//DPS(("C[%ld]", nCounter));
	//DPF(("PreloadCounter[%d] FinalLen[%u]\n", nCounter, (unsigned)m_pBufferBlock->Entry[ 0 ].ulControl & DMACONTROL_BUFLEN_MASK));

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalDMA::Start( BOOLEAN bDoPreload /* = TRUE */ )
// Puts this DMA channel into RUN mode.  DMA Buffer List should have at 
// least one entry already.
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulStreamControl	= m_pRegStreamControl->Read();	// make sure we start with the current contents of the hardware register

	DPF(("CHalDMA::Start %ld\n", m_ulDeviceNumber ));
	//DS(" DMAStart ",COLOR_BOLD);	DX8( (BYTE)m_ulDeviceNumber, COLOR_BOLD );	//DC(' ');
	
	m_ulLastBufferIndex = 0xFFFFFFFF;	// Invalid

	// if this is a play device, start the preload process
	// the StartPlayPreload only does something for play devices

	// NB Calin made preload optional: what's the point of preload?
	if ( bDoPreload ) StartPlayPreload();
	
	// Turn off DMA Host Start and make sure all the optional stuff is cleared out
	CLR( ulStreamControl, (REG_STREAMCTL_DMAHST | REG_STREAMCTL_LIMIE | REG_STREAMCTL_OVERIE | REG_STREAMCTL_DMASINGLE | REG_STREAMCTL_DMADUALMONO) );
	
	// Enable the DMA Engine
	SET( ulStreamControl, REG_STREAMCTL_DMAEN );
	
	// Check to see if the app needs any of the extra bits turned on (these all get reset to OFF upon stop)
	if( m_pWaveDMADevice->GetLimitIE() )
		SET( ulStreamControl, REG_STREAMCTL_LIMIE );
	
	if( m_pWaveDMADevice->GetOverrunIE() )
		SET( ulStreamControl, REG_STREAMCTL_OVERIE );
	
	if( m_pWaveDMADevice->GetDMASingle() )
		SET( ulStreamControl, REG_STREAMCTL_DMASINGLE );
	
	if( m_pWaveDMADevice->GetDualMono() )
		SET( ulStreamControl, REG_STREAMCTL_DMADUALMONO );

	if( m_pWaveDMADevice->m_bSyncStartEnabled )
	{
		// only firmware 16 & above has sync start enabled
		if( m_pHalAdapter->HasGlobalSyncStart() )
		{
			SET( ulStreamControl, REG_STREAMCTL_MODE_SYNCREADY );
			DPF(("MODE_SYNCREADY\n"));
			DS(" SYNCREADY ",COLOR_NORMAL);
		}
		else
		{
			SET( ulStreamControl, REG_STREAMCTL_MODE_RUN );
			DPF(("MODE_RUN\n"));
			DS(" RUN ",COLOR_NORMAL);
		}

		m_pHalAdapter->SyncStartReady( m_ulDeviceNumber, ulStreamControl );
		// reset the sync start enabled status for next time.
		m_pWaveDMADevice->m_bSyncStartEnabled = FALSE;
	}
	else
	{
		// NB Calin made preload optional: what's the point of preload?
	  	if ( bDoPreload ) WaitForPreloadToComplete();
		
		// must re-read PCPTR so this write to the stream control register doesn't clear it...
		CLR( ulStreamControl, REG_STREAMCTL_PCPTR_MASK );
		ulStreamControl |= (m_pRegStreamControl->Read() & REG_STREAMCTL_PCPTR_MASK);

		DPF(("Starting DMA Device...\n"));
		// Write the control register to the hardware
		SET( ulStreamControl, REG_STREAMCTL_MODE_RUN );
		m_pRegStreamControl->Write( ulStreamControl );
	}

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalDMA::Stop()
// Puts this DMA channel into IDLE mode
/////////////////////////////////////////////////////////////////////////////
{
	//DPF(("CHalDMA::Stop %ld\n", m_ulDeviceNumber ));

	m_ulLastBufferIndex = GetDMABufferIndex();	// Save this off to a shadow register for use later...

	// Disable the IO Processor & the DMA Engine
	m_pRegStreamControl->BitSet( (REG_STREAMCTL_MODE_MASK | REG_STREAMCTL_DMAEN | REG_STREAMCTL_OVERIE | REG_STREAMCTL_LIMIE), FALSE );

	m_ulPCBufferIndex	= 0;
	m_lEntriesInList	= 0;
	
	// make sure the DMA buffer block gets cleared
	RtlZeroMemory( m_pBufferBlock, sizeof( DMABUFFERBLOCK ) );

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalDMA::AddEntry( PVOID pBuffer, ULONG ulSize, BOOLEAN bInterrupt )
// Make sure the Control DWORD is written LAST as this is what the DMA 
// engine is looking see change to begin the next transfer when in DMAEN is high
// NOTE ulSize is in DWORDs
/////////////////////////////////////////////////////////////////////////////
{
	//DB('a',COLOR_BOLD_U);

	//DX32( m_pBufferBlock->Entry[ m_ulPCBufferIndex-1 ].ulHostPtr, COLOR_UNDERLINE );

	if( !ulSize || !pBuffer )
	{
		DPF(("CHalDMA::AddEntry: Invalid Parameter!\n"));
		return( HSTATUS_INVALID_PARAMETER );
	}

	//DX8((BYTE)m_lEntriesInList, COLOR_BOLD_U);

	// first determine if there is room in the buffer block for another entry (this allows all 16 entires to be used)
	if( m_lEntriesInList >= NUM_BUFFERS_PER_STREAM )
	{
		// This should never happen!
		DB('F',COLOR_BOLD);
		DPF(("CHalDMA::AddEntry: DMA Buffer List Full!\n"));
		return( HSTATUS_BUFFER_FULL );
	}

#ifdef DEBUG
	if( !pBuffer )
	{
		DPF(("CHalDMA::AddEntry: pBuffer is NULL!\n"));
	}
	if( !ulSize )
	{
		DPF(("CHalDMA::AddEntry: ulSize is ZERO!\n"));
	}
#endif

	m_pBufferBlock->Entry[ m_ulPCBufferIndex ].ulHostPtr = (ULONG)pBuffer;	// this must be a physical address
	if( bInterrupt )
	{
		//DC('i');
		m_pBufferBlock->Entry[ m_ulPCBufferIndex ].ulControl = (ulSize | DMACONTROL_HBUFIE);
	}
	else
	{
		//DC('n');
		m_pBufferBlock->Entry[ m_ulPCBufferIndex ].ulControl = ulSize;
	}
	
	m_lEntriesInList++;	// update the entry count
	m_ulPCBufferIndex++;
	m_ulPCBufferIndex &= 0xF;

	//DC('+');
	//DX8(m_lEntriesInList,COLOR_NORMAL);
	
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	CHalDMA::FreeEntry()
// Called at interrupt time to inform the DMA manager that an entry has been completed
/////////////////////////////////////////////////////////////////////////////
{
	//DB('f',COLOR_UNDERLINE);

	// make sure we don't free an entry that doesn't exist
	if( m_lEntriesInList > 0 )
	{
		m_lEntriesInList--;
		//DC('-');
		//DX8(m_lEntriesInList,COLOR_NORMAL);
	}
	else
	{
		DB('0',COLOR_UNDERLINE);
		DPF(("CHalDMA::FreeEntry: No Entries In List!\n"));
		return( HSTATUS_INVALID_PARAMETER );	// never checked
	}

	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
ULONG	CHalDMA::GetDMABufferIndex()
/////////////////////////////////////////////////////////////////////////////
{
	if( m_pWaveDMADevice->IsDMAActive() )
		return( (m_pRegStreamControl->Read() & REG_STREAMCTL_DMABINX_MASK) >> REG_STREAMCTL_DMABINX_OFFSET );
	else
		return( m_ulLastBufferIndex );
}

/////////////////////////////////////////////////////////////////////////////
ULONG	CHalDMA::GetEntriesInHardware()
/////////////////////////////////////////////////////////////////////////////
{
	LONG	lEntries;
	
	// NOTE: DMA index is always the tail for record and play
	lEntries = (LONG)m_ulPCBufferIndex - (LONG)GetDMABufferIndex();

	if( lEntries < 0 )
		lEntries += NUM_BUFFERS_PER_STREAM;
	return( (ULONG)lEntries );
}

/////////////////////////////////////////////////////////////////////////////
ULONG	CHalDMA::GetBytesRemaining( ULONG ulIndex )
/////////////////////////////////////////////////////////////////////////////
{
	return( (m_pBufferBlock->Entry[ ulIndex ].ulControl & DMACONTROL_BUFLEN_MASK) << 2);
}

/////////////////////////////////////////////////////////////////////////////
BOOLEAN	CHalDMA::IsDMAStarved()
/////////////////////////////////////////////////////////////////////////////
{
	return( m_pRegStreamControl->Read() & REG_STREAMCTL_DMASTARV ? TRUE : FALSE );
}
