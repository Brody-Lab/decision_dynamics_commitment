// HalRegister.h: interface for the CHalRegister class.
//
//////////////////////////////////////////////////////////////////////

#ifndef _HALREGISTER_H
#define _HALREGISTER_H

#include "Hal.h"

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

enum
{
	REG_READONLY=1,
	REG_WRITEONLY=2,
	REG_READWRITE=3
};

class CHalRegister  
{
public:
	CHalRegister();
	CHalRegister( PULONG pAddress, ULONG ulType = REG_READWRITE, ULONG ulValue = 0 );
	virtual ~CHalRegister();
	// overload of the assignment operator
	void	operator= (ULONG ulValue)		{ Write(ulValue);	}
			operator ULONG()				{ return Read();	}

	void	Init( PULONG pAddress, ULONG ulType = REG_READWRITE, ULONG ulValue = 0 );
	ULONG	Read();
	void	Write( ULONG ulValue );
	void	Write( ULONG ulValue, ULONG ulMask );
	void	BitSet( ULONG ulBitMask, BOOLEAN bValue );

private:
	PULONG	m_pAddress;
	ULONG	m_ulType;
	ULONG	m_ulValue;
};

#endif // _HALREGISTER_H

