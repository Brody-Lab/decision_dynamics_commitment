
#include "stdafx.h"
#include "HalTest.h"
#include "PCIBios.h"
#include "LynxTWO.h"

#define DIOC_MAP_ADDRESS		0x1002
#define DIOC_DMA_SCATTER_LOCK	0x1003
#define DIOC_DMA_SCATTER_UNLOCK	0x1004

typedef struct 
{
	PULONG	pAddress;
	PULONG	pBuffer;
	ULONG	ulData;
	ULONG	ulLength;
} LYNXMEMBUFFER, *PLYNXMEMBUFFER;

extern HANDLE ghDriver;

/////////////////////////////////////////////////////////////////////////////
ULONG	VxDMapAddress( ULONG pAddress, ULONG ulSize )
/////////////////////////////////////////////////////////////////////////////
{
	LYNXMEMBUFFER	MemBuf;
	ULONG	ulBytesReturned;

	if( !pAddress )
	{
		DPF(("VxDMapAddress cannot map NULL pointer!\n"));
		return( 0 );
	}

	MemBuf.pAddress	= (PULONG)pAddress;
	MemBuf.ulLength	= ulSize;

	if( !DeviceIoControl( ghDriver, DIOC_MAP_ADDRESS, 
		&MemBuf, sizeof( LYNXMEMBUFFER ), 
		&MemBuf, sizeof( LYNXMEMBUFFER ), 
		&ulBytesReturned, NULL ) )
	{
		DPF(("DIOC_MAP_ADDRESS Failed!\n"));
	}

	//DPF(("VxDMapAddress returning [%08lx]\n", (ULONG)MemBuf.pAddress ));

	return( (ULONG)MemBuf.pAddress );
}

typedef struct
{
	ULONG	ulSize;			// Size in bytes of the of the DMA region. 
	PVOID	pLinear;		// Linear address of the DMA region. 
	USHORT	usSeg;			// Segment or selector of the DMA region. 
	USHORT	usReserved;
	USHORT	usAvailable;	// The number of physical regions/page table 
							// entries that immediately follows the 
							// Extended_DDS_Struc structure. 
	USHORT	usUsed;			// The number of table entries filled in with 
							// physical regions information. 
	PHYSICALREGION	PhysicalRegion[1];
} EXTENDED_DMA_DESCRIPTOR, *PEXTENDED_DMA_DESCRIPTOR;

typedef struct 
{
	PEXTENDED_DMA_DESCRIPTOR	pDDS;
	ULONG	ucFlags;
	ULONG	ulReturn;
} LYNXDDSBUFFER, *PLYNXDDSBUFFER;

// DDS_linear and DDS_seg specify a 48-bit segment:offset pointer for virtual 
// 8086 mode, or a selector:offset pointer for protected mode programs. Note 
// that if the linear address has already been determined then you may set the 
// DDS_seg to 0 and place the linear address in the linear offset field. It is 
// possible to specify 32-bit offsets, even with real mode segment values; this 
// makes it much easier for device drivers to split up DMA transfers, by simply 
// modifying the offset without having to modify the segment/selector. 

/////////////////////////////////////////////////////////////////////////////
ULONG	VDMAD_Scatter_Lock( PEXTENDED_DMA_DESCRIPTOR pDDS, BYTE ucFlags )
/////////////////////////////////////////////////////////////////////////////
{
	LYNXDDSBUFFER	DDSBuf;
	ULONG	ulBytesReturned;

	DDSBuf.pDDS		= pDDS;
	DDSBuf.ucFlags	= ucFlags;
	DDSBuf.ulReturn	= 0;

	if( !DeviceIoControl( ghDriver, DIOC_DMA_SCATTER_LOCK, 
		&DDSBuf, sizeof( LYNXDDSBUFFER ), 
		&DDSBuf, sizeof( LYNXDDSBUFFER ), 
		&ulBytesReturned, NULL ) )
	{
		DPF(("DIOC_DMA_SCATTER_LOCK Failed!\n"));
	}

	return( DDSBuf.ulReturn );
}

#define DMAFLAGS_PHYSICAL_ADDRESS			0x00
#define DMAFLAGS_PAGE_TABLE					0x01
#define DMAFLAGS_PREVENT_NOT_PRESENT_LOCK	0x02
#define DMAFLAGS_PREVENT_MARK_AS_DIRTY		0x04

/////////////////////////////////////////////////////////////////////////////
ULONG	VDMAD_Scatter_Unlock( PEXTENDED_DMA_DESCRIPTOR pDDS, BYTE ucFlags )
/////////////////////////////////////////////////////////////////////////////
{
	LYNXDDSBUFFER	DDSBuf;
	ULONG	ulBytesReturned;

	DDSBuf.pDDS		= pDDS;
	DDSBuf.ucFlags	= ucFlags;
	DDSBuf.ulReturn	= 0;

	if( !DeviceIoControl( ghDriver, DIOC_DMA_SCATTER_UNLOCK, 
		&DDSBuf, sizeof( LYNXDDSBUFFER ), 
		&DDSBuf, sizeof( LYNXDDSBUFFER ), 
		&ulBytesReturned, NULL ) )
	{
		DPF(("DIOC_DMA_SCATTER_UNLOCK Failed!\n"));
	}

	return( DDSBuf.ulReturn );
}

/////////////////////////////////////////////////////////////////////////////
USHORT	GetNumberOfPhysicalPages( PVOID pAddress, ULONG ulSize )
/////////////////////////////////////////////////////////////////////////////
{
	EXTENDED_DMA_DESCRIPTOR	DDS;
	ULONG	ulReturn;

	//DPF(("GetNumberOfPhysicalPages\n"));

	RtlZeroMemory( &DDS, sizeof( EXTENDED_DMA_DESCRIPTOR ) );

	DDS.ulSize		= ulSize;			// Size in bytes of the of the DMA region. 
	DDS.pLinear		= pAddress;			// Linear address of the DMA region. 
	DDS.usSeg		= 0;				// Segment or selector of the DMA region. 
	DDS.usAvailable	= 1;
	DDS.usUsed		= 0;

	// if there is only one page, this will work, otherwise it will fail, which is OK (I think!)
	ulReturn = VDMAD_Scatter_Lock( &DDS, DMAFLAGS_PHYSICAL_ADDRESS );
	if( ulReturn == 1 )
	{
		DPF(("VDMAD_Scatter_Lock failed %08lx\n", ulReturn ));
	}
	ulReturn = VDMAD_Scatter_Unlock( &DDS, DMAFLAGS_PHYSICAL_ADDRESS );
	if( ulReturn )
	{
		DPF(("VDMAD_Scatter_Unlock failed %08lx\n", ulReturn ));
	}

	return( DDS.usUsed ); 
}

/////////////////////////////////////////////////////////////////////////////
ULONG	GetPhysicalPages( PVOID pAddress, ULONG ulSize, PULONG pulNumPages, PPHYSICALREGION pPages )
/////////////////////////////////////////////////////////////////////////////
{
	// make a buffer on the stack big enough for 16 entries
	BYTE	Buffer[ sizeof( EXTENDED_DMA_DESCRIPTOR ) + (sizeof( PHYSICALREGION ) * 15) ];
	PEXTENDED_DMA_DESCRIPTOR	pDDS;
	ULONG	ulReturn;
	ULONG	i;

	pDDS = (PEXTENDED_DMA_DESCRIPTOR)Buffer;

	RtlZeroMemory( pDDS, sizeof( Buffer ) );

	pDDS->ulSize		= ulSize;			// Size in bytes of the of the DMA region. 
	pDDS->pLinear		= pAddress;			// Linear address of the DMA region. 
	pDDS->usSeg			= 0;				// Segment or selector of the DMA region. 
	pDDS->usAvailable	= 16;
	pDDS->usUsed		= 0;

	ulReturn = VDMAD_Scatter_Lock( pDDS, DMAFLAGS_PHYSICAL_ADDRESS );	// Get the physical regions

	DPF(("Address %08lx uses %u pages:\n", pAddress, pDDS->usUsed ));
	
	if( ulReturn )
	{
		DPF(("VDMAD_Scatter_Lock failed %08lx\n", ulReturn ));
		return( ulReturn );
	}

	if( pDDS->usUsed < *pulNumPages )
		*pulNumPages = pDDS->usUsed;

	for( i=0; i<*pulNumPages; i++ )
	{
		pPages[i] = pDDS->PhysicalRegion[i];
		DPF(("Page %d is at %08lx size %lu\n", i, pPages[i].pPhysical, pPages[i].ulSize ));
	}
	return( 0 );
}

/////////////////////////////////////////////////////////////////////////////
ULONG	ReleasePhysicalPages( PVOID pAddress, ULONG ulSize, ULONG ulNumPages )
/////////////////////////////////////////////////////////////////////////////
{
	EXTENDED_DMA_DESCRIPTOR	DDS;
	ULONG	ulReturn;

	DPF(("ReleasePhysicalPages\n"));

	RtlZeroMemory( &DDS, sizeof( EXTENDED_DMA_DESCRIPTOR ) );

	DDS.ulSize		= ulSize;			// Size in bytes of the of the DMA region. 
	DDS.pLinear		= pAddress;			// Linear address of the DMA region. 
	DDS.usSeg		= 0;				// Segment or selector of the DMA region. 
	DDS.usAvailable	= 0;
	DDS.usUsed		= (USHORT)ulNumPages;

	ulReturn = VDMAD_Scatter_Unlock( &DDS, DMAFLAGS_PAGE_TABLE | DMAFLAGS_PREVENT_NOT_PRESENT_LOCK );	// Release the physical regions
	if( ulReturn )
	{
		DPF(("VDMAD_Scatter_Unlock failed %08lx\n", ulReturn ));
	}

	return( ulReturn );
}

/////////////////////////////////////////////////////////////////////////////
PVOID	GetPhysicalAddress( PVOID pAddress, ULONG ulSize )
/////////////////////////////////////////////////////////////////////////////
{
	PHYSICALREGION	Page;
	ULONG	ulNumPages = 1;

	GetPhysicalPages( pAddress, ulSize, &ulNumPages, &Page );

	return( Page.pPhysical );
}

/////////////////////////////////////////////////////////////////////////////
DWORD	ReadDWORD( PULONG pAddress )
/////////////////////////////////////////////////////////////////////////////
{
	return( *pAddress );
}

/////////////////////////////////////////////////////////////////////////////
VOID	ReadDWORDBuffer( PULONG pAddress, PULONG pBuffer, ULONG ulLength )
/////////////////////////////////////////////////////////////////////////////
{
	while( ulLength-- )
		*pBuffer++ = *pAddress++;
}

/////////////////////////////////////////////////////////////////////////////
VOID	WriteDWORD( PULONG pAddress, ULONG ulData )
/////////////////////////////////////////////////////////////////////////////
{
	*pAddress = ulData;
}

/////////////////////////////////////////////////////////////////////////////
VOID	WriteDWORDBuffer( PULONG pAddress, PULONG pBuffer, ULONG ulLength )
/////////////////////////////////////////////////////////////////////////////
{
	while( ulLength-- )
		*pAddress++ = *pBuffer++;
}

/////////////////////////////////////////////////////////////////////////////
BOOLEAN IsPCIBiosPresent( VOID )
//	Returns
//		TRUE if BIOS is present
//		FALSE if Error or no PCI BIOS
/////////////////////////////////////////////////////////////////////////////
{
	ULONG	ulPCISignature;
	USHORT	rAX, rFlags;
	OSVERSIONINFO	VersionInfo;

	// First determine if this is Windows NT or Windows 2000
	VersionInfo.dwOSVersionInfoSize = sizeof( OSVERSIONINFO );
	if( !GetVersionEx( &VersionInfo ) )
	{
		MessageBox( NULL, TEXT("GetVersionEx Failed!"), NULL, MB_OK | MB_ICONEXCLAMATION );
		return( FALSE );
	}

	if( VersionInfo.dwPlatformId == VER_PLATFORM_WIN32_NT )
	{
		MessageBox( NULL, TEXT("This application can only be used on Windows 95/98/ME"), NULL, MB_OK | MB_ICONEXCLAMATION );
		return( FALSE );
	}

	_asm	mov	ah, PCI_FUNCTION_ID;
	_asm	mov	al, PCI_BIOS_PRESENT;

	_asm	int	0x1a;

	_asm	mov	rAX, ax;
	_asm	pushf;
	_asm	pop	ax;
	_asm	mov	rFlags, ax;
#ifdef BORLAND
	ulPCISignature	= _EDX;
#else
	_asm	mov	ulPCISignature, edx;
#endif

	// First check if CARRY FLAG Set, if so, BIOS not present
	if( rFlags & CARRY_FLAG )
	{
		DPF(("\nIsPCIBiosPresent: CF Set. BIOS Failure!\n"));
		return( FALSE );
	}

	// Next, must check that AH (BIOS Present Status) == 0
	if( HIBYTE( rAX ) != SUCCESSFUL )
	{
		DPF(("\nIsPCIBiosPresent: "));
		switch( HIBYTE( rAX ) )
		{
		case FUNC_NOT_SUPPORTED:	DPF(("Function Not Supported!\n"));	break;
		case BAD_VENDOR_ID:			DPF(("Bad Vendor ID!\n"));			break;
		case DEVICE_NOT_FOUND:		DPF(("Device Not Found!\n"));		break;
		case BAD_REGISTER_NUMBER:	DPF(("Bad Register Number!\n"));	break;
		case SET_FAILED:			DPF(("Set Failed!\n"));				break;
		case BUFFER_TOO_SMALL:		DPF(("Buffer Too Small!\n"));		break;
		}
		return( FALSE );
	}

#define MAKEQUAD(hh,hl,lh,ll)	MAKELONG(MAKEWORD(hh,hl),MAKEWORD(lh,ll))
#define PCISIGNATURE			MAKEQUAD('P','C','I',' ')

	// Check BYTEs in ulPCISignature for PCI Signature
	if( ulPCISignature != PCISIGNATURE )
	{
		DPF(("\nPCI BIOS Signature Not Found! %08lx\n", ulPCISignature ));
		return( FALSE );
	}

	return( TRUE );
}

////////////////////////////////////////////////////////////////////////////
BOOLEAN	FindPCIDevice( PPCI_CONFIGURATION pPCI )
////////////////////////////////////////////////////////////////////////////
{
	USHORT	rAX, rBX, rCX, rDX, rSI, rFlags; // Temporary variables to hold register values

	rDX = pPCI->usVendorID;
	rCX = pPCI->usDeviceID;
	rSI = (USHORT)pPCI->ulDeviceNode;
	
	pPCI->ulDeviceNode++;	// increment for next time around

	//printf("\nLooking for LynxONE #%d: ", (USHORT)pPCI->ulDeviceNode );

	_asm	mov cx, rCX;
	_asm	mov dx, rDX;
	_asm	mov	si, rSI;	// start index
	_asm	mov	ah, PCI_FUNCTION_ID;
	_asm	mov	al, FIND_PCI_DEVICE;

	_asm	int	0x1a;

	_asm	mov	rAX, ax;
	_asm	mov	rBX, bx;
	_asm	pushf;
	_asm	pop	ax;
	_asm	mov	rFlags, ax;

	// First check if CARRY FLAG Set, if so, error has occurred
	if( rFlags & CARRY_FLAG )
	{
		DPF(("FindPCIDevice: CF Set. BIOS Failure!\n"));
		//return( FALSE );	// fail
	}

	// Get Return code from BIOS
	if( HIBYTE( rAX ) != SUCCESSFUL )
	{
		switch( HIBYTE( rAX ) )
		{
		case FUNC_NOT_SUPPORTED:	DPF(("Function Not Supported!\n"));	break;
		case BAD_VENDOR_ID:			DPF(("Bad Vendor ID!\n"));			break;
		case DEVICE_NOT_FOUND:		DPF(("Device Not Found!\n"));		break;
		case BAD_REGISTER_NUMBER:	DPF(("Bad Register Number!\n"));	break;
		case SET_FAILED:			DPF(("Set Failed!\n"));				break;
		case BUFFER_TOO_SMALL:		DPF(("Buffer Too Small!\n"));		break;
		default:					DPF(("Unknown Error!\n"));			break;
		}
		return( FALSE );
	}

	// Assign Bus Number, Device & Function if successful
	pPCI->usBusNumber		= HIBYTE( rBX );
	// Device Number in upper 5 bits, Function Number in lower 3 bits
	pPCI->usDeviceFunction	= LOBYTE( rBX );

	//printf("Found on Bus %d Device %d\n", pPCI->usBusNumber, pPCI->usDeviceFunction >> 3 );

	return( TRUE );			// success
}

////////////////////////////////////////////////////////////////////////////
BOOLEAN	GetPCIConfiguration( PPCI_CONFIGURATION pPCI )
////////////////////////////////////////////////////////////////////////////
{
	int		i;

	// Go get all of the base address registers
	for( i=0; i<PCI_TYPE0_ADDRESSES; i++ )
	{
		ReadConfigurationArea( READ_CONFIG_DWORD, (BYTE)pPCI->usBusNumber, (BYTE)pPCI->usDeviceFunction,
			PCI_CS_BASE_ADDRESS_0+(i*sizeof(ULONG)), &pPCI->Base[ i ].ulAddress );

		if( pPCI->Base[ i ].ulAddress & 0x1 )
		{
			pPCI->Base[ i ].ulAddress &= 0xFFFFFFFCL;
			pPCI->Base[ i ].usType = PCI_BARTYPE_IO;
		}
		else
		{
			pPCI->Base[ i ].ulAddress &= 0xFFFFFFF0L;
			pPCI->Base[ i ].usType = PCI_BARTYPE_MEM;
		}

		//DPF(("BAR%d %08lx ", i, pPCI->Base[ i ].ulAddress ));

		// set the size of the base address region
		switch( i )
		{
		case PCI_REGISTERS_INDEX:
			pPCI->Base[ i ].ulSize = BAR0_SIZE;
			pPCI->Base[ i ].ulAddress = VxDMapAddress( pPCI->Base[ i ].ulAddress, pPCI->Base[ i ].ulSize );
			DPF(("PCI_REGISTERS_INDEX %08lx\n", pPCI->Base[ i ].ulAddress ));
			break;
		case AUDIO_DATA_INDEX:
			pPCI->Base[ i ].ulSize = BAR1_SIZE;
			pPCI->Base[ i ].ulAddress = VxDMapAddress( pPCI->Base[ i ].ulAddress, pPCI->Base[ i ].ulSize );
			DPF(("AUDIO_DATA_INDEX %08lx\n", pPCI->Base[ i ].ulAddress ));
			break;
		case 2:
			//pPCI->Base[ i ].ulSize = BAR1_SIZE;
			//pPCI->Base[ AUDIO_DATA_INDEX ].ulAddress = VxDMapAddress( pPCI->Base[ i ].ulAddress, pPCI->Base[ i ].ulSize );
			//DPF(("LynxONE %08lx\n", pPCI->Base[ AUDIO_DATA_INDEX ].ulAddress ));
			break;
		default:
			break;
		}
		//DPF(("\n"));
	}

	// Get the interrupt line
	ReadConfigurationArea( READ_CONFIG_BYTE, 
		(BYTE)pPCI->usBusNumber, (BYTE)pPCI->usDeviceFunction, 
		PCI_CS_INTERRUPT_LINE, (PVOID)&pPCI->usInterruptLine );

	// Get the interrupt pin
	ReadConfigurationArea( READ_CONFIG_BYTE,
		(BYTE)pPCI->usBusNumber, (BYTE)pPCI->usDeviceFunction,
		PCI_CS_INTERRUPT_PIN, (PVOID)&pPCI->usInterruptPin );

	return( TRUE );
}

/////////////////////////////////////////////////////////////////////////////
BOOLEAN ReadConfigurationArea( BYTE ucFunction, BYTE ucBusNumber, BYTE ucDeviceFunction, BYTE ucRegisterNumber, PVOID pvData )
/////////////////////////////////////////////////////////////////////////////
{
	USHORT	rDI;
	USHORT	rAX, rFlags;
	ULONG	rECX;
	
	rDI = ucRegisterNumber;

	_asm	mov bh, ucBusNumber;
	_asm	mov bl, ucDeviceFunction;
	_asm	mov di, rDI;
	_asm	mov	ah, PCI_FUNCTION_ID;
	_asm	mov	al, ucFunction;

	_asm	int	0x1a;

	_asm	mov	rAX, ax;
	_asm	pushf;
	_asm	pop	ax;
	_asm	mov	rFlags, ax;
#ifdef BORLAND
	rECX = _ECX;
#else
	_asm	mov	rECX, ecx;
#endif

	// First check if CARRY FLAG Set, if so, error has occurred
	if( rFlags & CARRY_FLAG )
	{
		DPF(("\nCF Set. BIOS Failure!\n"));
		return( FALSE );
	}

	// Get Return code from BIOS
	if( HIBYTE( rAX ) != SUCCESSFUL )
	{
		DPF(("\nBIOS Error %d!\n", HIBYTE( rAX ) ));
		return( FALSE );
	}

	switch( ucFunction )
	{
	case READ_CONFIG_BYTE:
		*(PBYTE)pvData = (BYTE)rECX;
		break;
	case READ_CONFIG_WORD:
		*(PUSHORT)pvData = (USHORT)rECX;
		break;
	case READ_CONFIG_DWORD:
		*(PULONG)pvData = rECX;
		break;
	}

	return( TRUE );
}

/////////////////////////////////////////////////////////////////////////////
BOOLEAN WriteConfigurationArea( BYTE ucFunction, BYTE ucBusNumber, BYTE ucDeviceFunction, BYTE ucRegisterNumber, ULONG ulData )
/////////////////////////////////////////////////////////////////////////////
{
	USHORT	rDI;
	USHORT	rAX, rFlags;
	
	rDI = ucRegisterNumber;
	
	// Load entry registers for PCI BIOS
	_asm	mov bh, ucBusNumber;
	_asm	mov bl, ucDeviceFunction;
	_asm	mov di, rDI;
	_asm	mov	ah, PCI_FUNCTION_ID;
	_asm	mov	al, ucFunction;
#ifdef BORLAND
	_ECX = ulData;
#else
	_asm	mov	ecx, ulData;
#endif

	_asm	int	0x1a;

	_asm	mov	rAX, ax;
	_asm	pushf;
	_asm	pop	ax;
	_asm	mov	rFlags, ax;
	
	// First check if CARRY FLAG Set, if so, error has occurred
	if( rFlags & CARRY_FLAG )
	{
		DPF(("\nCF Set. BIOS Failure!\n"));
		return( FALSE );
	}

	// Get Return code from BIOS
	if( HIBYTE( rAX ) != SUCCESSFUL )
	{
		DPF(("\nBIOS Error %d!\n", HIBYTE( rAX ) ));
		return( FALSE );
	}
		
	return( TRUE );
}
