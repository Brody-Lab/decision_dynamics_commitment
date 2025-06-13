#include <Hal.h>

USHORT	FindAdapter( PVOID pContext, PPCI_CONFIGURATION pPCI );
USHORT	MapAdapter( PVOID pContext, PPCI_CONFIGURATION pPCI );
USHORT	UnmapAdapter( PVOID pContext, PPCI_CONFIGURATION pPCI );
USHORT	AllocateMemory( PVOID *pObject, PVOID *pVAddr, PVOID *pPAddr, ULONG ulLength, ULONG ulAddressMask );
USHORT	FreeMemory( PVOID pObject, PVOID pVAddr );
USHORT	InterruptCallback( ULONG ulReason, PVOID pvContext1, PVOID pvContext2 );
PHALADAPTER	GetAdapter( PVOID pContext, ULONG ulAdapterNumber );
