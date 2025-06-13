
#include "stdafx.h"
#include "HalTest.h"
#include "Callback.h"
#include "PCIBios.h"

#include <LynxTWO.h>
#include <HalWaveDMADevice.h>

/////////////////////////////////////////////////////////////////////////////
USHORT	FindAdapter( PVOID pContext, PPCI_CONFIGURATION pPCI )
// Called from the Hal
/////////////////////////////////////////////////////////////////////////////
{
#ifdef USEHARDWARE
	// Start with the LynxTWO-A
	pPCI->usDeviceID = PCIDEVICE_LYNXTWO_A;

	if( !FindPCIDevice( pPCI ) )
	{
		pPCI->usDeviceID = PCIDEVICE_LYNXTWO_B;
		if( !FindPCIDevice( pPCI ) )
		{
			pPCI->usDeviceID = PCIDEVICE_LYNXTWO_C;
			if( !FindPCIDevice( pPCI ) )
			{
				pPCI->usDeviceID = PCIDEVICE_LYNX_L22;
				if( !FindPCIDevice( pPCI ) )
				{
					DPF(("FindPCIDevice Failed!"));
					return( HSTATUS_CANNOT_FIND_ADAPTER );
				}
			}
		}
	}
#endif
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT MapAdapter( PVOID pContext, PPCI_CONFIGURATION pPCI )
// Called from the Hal
/////////////////////////////////////////////////////////////////////////////
{
#ifdef USEHARDWARE
	GetPCIConfiguration( pPCI );
#else
	pPCI->Base[ PCI_REGISTERS_INDEX ].ulAddress = (ULONG)malloc( BAR0_SIZE );	// BUGBUG
	pPCI->Base[ PCI_REGISTERS_INDEX ].ulSize = BAR0_SIZE;

	pPCI->Base[ AUDIO_DATA_INDEX ].ulAddress = (ULONG)malloc( BAR1_SIZE );		// BUGBUG
	pPCI->Base[ AUDIO_DATA_INDEX ].ulSize = BAR1_SIZE;
#endif
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT UnmapAdapter( PVOID pContext, PPCI_CONFIGURATION pPCI )
// Called from the Hal
/////////////////////////////////////////////////////////////////////////////
{
#ifdef USEHARDWARE

#else
	free( (PVOID)pPCI->Base[ PCI_REGISTERS_INDEX ].ulAddress );	// BUGBUG
	free( (PVOID)pPCI->Base[ AUDIO_DATA_INDEX ].ulAddress );	// BUGBUG
#endif
	return( HSTATUS_OK );
}

// PCIBios.cpp
PVOID	GetPhysicalAddress( PVOID pAddress, ULONG ulSize );

/////////////////////////////////////////////////////////////////////////////
USHORT AllocateMemory( PVOID *pObject, PVOID *pVAddr, PVOID *pPAddr, ULONG ulLength, ULONG ulAddressMask )
// Allocates Non-Paged Memory and returns both the virtual address and physical address
// Allows the caller to specify an address mask so the memory is aligned as required
// by the caller
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulAddress;
	
	// this code won't work for DOS as it gives addresses in SEG:OFFSET instead of linear address space

	*pObject	= (PVOID)malloc( ulLength * 2 );	// allocate twice as much as requested
	ulAddress	= ((ULONG)*pObject) + ulLength;		// move the address to the half way point in the buffer
	ulAddress	&= ulAddressMask;					// apply the requested mask, this gives a perfectly aligned buffer
	*pVAddr		= (PVOID)ulAddress;					// 
	*pPAddr		= GetPhysicalAddress( (PVOID)ulAddress, ulLength );	// call the VxD to get the physical address
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
USHORT FreeMemory( PVOID pObject, PVOID pVAddr )
// Free memory allocated with above procedure
/////////////////////////////////////////////////////////////////////////////
{
	ReleasePhysicalPages( pVAddr, 2048, 1 );
	free( pObject );
	return( HSTATUS_OK );
}

/////////////////////////////////////////////////////////////////////////////
PHALADAPTER	GetAdapter( PVOID pContext, ULONG ulAdapterNumber )
/////////////////////////////////////////////////////////////////////////////
{
	CHalTestApp *pApp = (CHalTestApp *)pContext;

	if( !pApp )
		return( NULL );

	return( pApp->m_pHalAdapter );
}

