#ifndef _PCIBIOS_H
#define _PCIBIOS_H

#include "Hal.h"

#define CARRY_FLAG				0x01         /* 80x86 Flags Register Carry Flag bit */

// PCI BIOS Functions
#define PCI_FUNCTION_ID			0xb1
#define PCI_BIOS_PRESENT		0x01
#define FIND_PCI_DEVICE			0x02
#define FIND_PCI_CLASS_CODE		0x03
#define GENERATE_SPECIAL_CYCLE	0x06
#define READ_CONFIG_BYTE		0x08
#define READ_CONFIG_WORD		0x09
#define READ_CONFIG_DWORD		0x0a
#define WRITE_CONFIG_BYTE		0x0b
#define WRITE_CONFIG_WORD		0x0c
#define WRITE_CONFIG_DWORD		0x0d
#define	SET_PCI_IRQ				0x0f

// PCI BIOS Return Codes
#define	SUCCESSFUL				0x00
#define FUNC_NOT_SUPPORTED		0x81
#define BAD_VENDOR_ID			0x83
#define DEVICE_NOT_FOUND		0x86
#define BAD_REGISTER_NUMBER		0x87
#define SET_FAILED				0x88
#define BUFFER_TOO_SMALL		0x89

// PCI Configuration Space Registers
#define PCI_CS_VENDOR_ID         0x00	// 2 bytes, Read Only
#define PCI_CS_DEVICE_ID         0x02	// 2 bytes, Read Only
#define PCI_CS_COMMAND           0x04	// 2 bytes
#define PCI_CS_STATUS            0x06	// 2 bytes, Read Only
#define PCI_CS_REVISION_ID       0x08	// 1 byte,  Read Only
#define PCI_CS_CLASS_CODE        0x09	// 3 bytes, Read Only
#define PCI_CS_CACHE_LINE_SIZE   0x0c	// 1 byte
#define PCI_CS_MASTER_LATENCY    0x0d	// 1 byte
#define PCI_CS_HEADER_TYPE       0x0e	// 1 byte,  Read Only
#define PCI_CS_BIST              0x0f	// 1 byte,  Read Only (Built In Self Test)
#define PCI_CS_BASE_ADDRESS_0    0x10	// 4 bytes
#define PCI_CS_BASE_ADDRESS_1    0x14	// 4 bytes
#define PCI_CS_BASE_ADDRESS_2    0x18	// 4 bytes
#define PCI_CS_BASE_ADDRESS_3    0x1c	// 4 bytes
#define PCI_CS_BASE_ADDRESS_4    0x20	// 4 bytes
#define PCI_CS_BASE_ADDRESS_5    0x24	// 4 bytes
#define PCI_CS_CARDBUS_CIS_PTR	 0x28	// 4 bytes
#define PCI_CS_SUBSYS_VENDOR_ID	 0x2c	// 2 bytes, Read Only
#define PCI_CS_SUBSYS_DEVICE_ID	 0x2e	// 2 bytes, Read Only
#define PCI_CS_EXPANSION_ROM     0x30	// 4 bytes
#define PCI_CS_CAPABILITIES_PTR	 0x34	// 1 byte
#define PCI_CS_RESERVED1		 0x35	// 3 bytes
#define PCI_CS_RESERVED2		 0x38	// 4 bytes
#define PCI_CS_INTERRUPT_LINE    0x3c	// 1 byte 
#define PCI_CS_INTERRUPT_PIN     0x3d	// 1 byte,  Read Only
#define PCI_CS_MIN_GNT           0x3e	// 1 byte,  Read Only
#define PCI_CS_MAX_LAT           0x3f	// 1 byte,  Read Only

BOOLEAN IsPCIBiosPresent( VOID );
BOOLEAN	FindPCIDevice( PPCI_CONFIGURATION pPCI );
BOOLEAN	GetPCIConfiguration( PPCI_CONFIGURATION pPCI );
BOOLEAN	ReadConfigurationArea( BYTE ucFunction, BYTE ucBusNumber, BYTE ucDeviceFunction, BYTE ucRegisterNumber, PVOID pulData );
BOOLEAN WriteConfigurationArea( BYTE ucFunction, BYTE ucBusNumber, BYTE ucDeviceFunction, BYTE ucRegisterNumber, ULONG ulData );

typedef struct
{
	PVOID	pPhysical;
	ULONG	ulSize;
} PHYSICALREGION, *PPHYSICALREGION;

USHORT	GetNumberOfPhysicalPages( PVOID pAddress, ULONG ulSize );
ULONG	GetPhysicalPages( PVOID pAddress, ULONG ulSize, PULONG pulNumPages, PPHYSICALREGION pPages );
ULONG	ReleasePhysicalPages( PVOID pAddress, ULONG ulSize, ULONG ulNumPages );
PVOID	GetPhysicalAddress( PVOID pAddress, ULONG ulSize );

#endif //_PCIBIOS_H
