// MatlabEngine.cpp: implementation of the CMatlabEngine class.
//
//////////////////////////////////////////////////////////////////////

#include "MatlabEngine.h"
//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////


CMatlabEngine::CMatlabEngine(bool bDedicated)
: m_bInitialized(false)
{
#ifndef _UNICODE
	m_pBuffer=new WCHAR[1024];
	m_uBufferSize=1024;
#endif
	m_pMtlbDispApp = 0;

	m_bstrWorkspace = ::SysAllocString( L"base" );

	m_dpNoArgs.cArgs=0;
	m_dpNoArgs.cNamedArgs=0;
	m_dpNoArgs.rgdispidNamedArgs=NULL;
	m_dpNoArgs.rgvarg=NULL;

	// Get the Class Identifier for Matlab Application Object,
	// which is a globally unique identifier (GUID)
	OLECHAR FAR* szFunction;

	CLSID clsid;
	if (bDedicated)
		m_hr=::CLSIDFromProgID(OLESTR("Matlab.Application.Single"), &clsid);
	else
		m_hr=::CLSIDFromProgID(OLESTR("Matlab.Application"), &clsid);

	if (FAILED(m_hr))
		return;

	
	// Create an instance of the Matlab application and obtain the pointer
	// to the application's IUnknown interface
	
	IUnknown* pUnk;
	
	InitCom();  // just in case client code neglected to call CoInitialize()

//	m_hr = ::CoCreateInstance(clsid, NULL, CLSCTX_SERVER,IID_IUnknown,(void**) &pUnk);
	m_hr = ::CoCreateInstance(clsid, NULL, CLSCTX_ALL, IID_IUnknown, (void**) &pUnk);
	if (FAILED(m_hr))
		return;

	// Query IUnknown to retrieve a pointer to the application IDispatch
	// interface
	m_hr = pUnk ->QueryInterface(IID_IDispatch, (void**)&m_pMtlbDispApp);
	if (FAILED(m_hr))
		return;

	// Get the Dispatch Identifiers
	szFunction = OLESTR("GetFullMatrix");
	m_hr = m_pMtlbDispApp ->GetIDsOfNames(IID_NULL, &szFunction, 1, LOCALE_USER_DEFAULT, &m_dispid_GetFullMatrix);
	if (FAILED(m_hr))
		return;
	
	
	szFunction = OLESTR("PutFullMatrix");
	m_hr = m_pMtlbDispApp ->GetIDsOfNames(IID_NULL, &szFunction, 1, LOCALE_USER_DEFAULT, &m_dispid_PutFullMatrix);
	if (FAILED(m_hr))
		return;
	
	
	szFunction = OLESTR("Execute");
	m_hr = m_pMtlbDispApp ->GetIDsOfNames(IID_NULL, &szFunction, 1, LOCALE_USER_DEFAULT, &m_dispid_Execute);
	if (FAILED(m_hr))
		return;

	
	szFunction = OLESTR("MinimizeCommandWindow");
	m_hr = m_pMtlbDispApp ->GetIDsOfNames(IID_NULL, &szFunction, 1, LOCALE_USER_DEFAULT, &m_dispid_MinimizeCommandWindow);
	if (FAILED(m_hr))
		return;

	szFunction = OLESTR("MaximizeCommandWindow");
	m_hr = m_pMtlbDispApp ->GetIDsOfNames(IID_NULL, &szFunction, 1, LOCALE_USER_DEFAULT, &m_dispid_MaximizeCommandWindow);
	if (FAILED(m_hr))
		return;

#ifdef MATLAB_VERSION_6
	szFunction = OLESTR("GetCharArray");
	m_hr = m_pMtlbDispApp ->GetIDsOfNames(IID_NULL, &szFunction, 1, LOCALE_USER_DEFAULT, &m_dispid_GetCharArray);
	if (FAILED(m_hr))
		return;
	
	szFunction = OLESTR("PutCharArray");
	m_hr = m_pMtlbDispApp ->GetIDsOfNames(IID_NULL, &szFunction, 1, LOCALE_USER_DEFAULT, &m_dispid_PutCharArray);
	if (FAILED(m_hr))
		return;
	
	szFunction = OLESTR("Visible");
	m_hr = m_pMtlbDispApp ->GetIDsOfNames(IID_NULL, &szFunction, 1, LOCALE_USER_DEFAULT, &m_dispid_Visible);
	if (FAILED(m_hr))
		return;
#endif

	szFunction = OLESTR("Quit");
	m_hr = m_pMtlbDispApp ->GetIDsOfNames(IID_NULL, &szFunction, 1, LOCALE_USER_DEFAULT, &m_dispid_Quit);
	if (FAILED(m_hr))
		return;

	m_bInitialized = true;
}

CMatlabEngine::~CMatlabEngine()
{
	if (m_pMtlbDispApp)
		m_pMtlbDispApp->Release();

	::SysFreeString(m_bstrWorkspace);

#ifndef _UNICODE
	if (m_pBuffer)
		delete[] m_pBuffer;
#endif
}
	
void CMatlabEngine::SetWorkspace(LPCTSTR szWorkspace)
{
	ProcessString( szWorkspace, m_bstrWorkspace);
}


void CMatlabEngine::ErrHandler(HRESULT hr, EXCEPINFO excep, UINT uArgErr)
{
  if (hr == DISP_E_EXCEPTION)
  {
    TCHAR errDesc[512];
    TCHAR errMsg[512];
    ::sprintf(errMsg, TEXT("Run-time error %d:\n\n %s"),
            excep.scode & 0x0000FFFF,  //Lower 16-bits of SCODE
            errDesc);                  //Text error description
    ::MessageBox(NULL, errMsg, TEXT("Automation Server Error"),
                MB_SETFOREGROUND | MB_OK);
  }
  else
  {
    LPVOID lpMsgBuf;
    ::FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER |
                    FORMAT_MESSAGE_FROM_SYSTEM |
                    FORMAT_MESSAGE_IGNORE_INSERTS, NULL, hr,
                    MAKELANGID(LANG_NEUTRAL,
                    SUBLANG_DEFAULT),(LPTSTR) &lpMsgBuf,
                    0, NULL);
    if ((hr == DISP_E_TYPEMISMATCH ) ||
        (hr == DISP_E_PARAMNOTFOUND))
    {
      TCHAR extMess[512];
      ::_tprintf(extMess, TEXT("%s Position of incorrect argument is %u.\n"), (LPCTSTR) lpMsgBuf, uArgErr);
      ::MessageBox(NULL, extMess, TEXT("COM Error"), MB_OK | MB_SETFOREGROUND);
    }
    else
    {
      ::MessageBox(NULL, (LPCTSTR)lpMsgBuf, TEXT("COM Error"),MB_OK | MB_SETFOREGROUND);
    }
    ::LocalFree(lpMsgBuf);
  }
}

HRESULT CMatlabEngine::Execute(LPCTSTR szCode)
{
	VARIANT vArgsTypeText[1];
	DISPPARAMS dpTypeText;
	BSTR bstrName=NULL;

	if (!m_bInitialized || !m_pMtlbDispApp)
		return m_hr=S_FALSE;

	ProcessString(szCode, bstrName);
	
	vArgsTypeText [0].vt = VT_BSTR;
	vArgsTypeText [0].bstrVal = bstrName;	
	
	dpTypeText.cArgs = 1;
	dpTypeText.cNamedArgs = 0;
	dpTypeText.rgvarg = vArgsTypeText;
		
	m_hr = m_pMtlbDispApp ->Invoke(m_dispid_Execute, IID_NULL, LOCALE_USER_DEFAULT, DISPATCH_METHOD, &dpTypeText, &m_vResult, &m_excep, &m_uArgErr);

	if (FAILED(m_hr))
		goto Exit;

// Cleaning memory...		
Exit:
	::SysFreeString(bstrName);

	return m_hr;
}

#ifdef MATLAB_VERSION_6
HRESULT CMatlabEngine::Show(bool bShow)
{
	VARIANT vArgsTypeLong[1];

	if (!m_bInitialized || !m_pMtlbDispApp)
		return m_hr=S_FALSE;

	::VariantInit(vArgsTypeLong);
	
	vArgsTypeLong[0].vt = VT_I4;
	vArgsTypeLong[0].lVal = (bShow) ? 1 : 0; // Visible = 1; Invisible = 0
	
	DISPID dispidNamed = DISPID_PROPERTYPUT;
		
	DISPPARAMS dpVisible;
	dpVisible.cArgs = 1;
	dpVisible.cNamedArgs = 1;
	dpVisible.rgvarg = vArgsTypeLong;
	dpVisible.rgdispidNamedArgs = &dispidNamed;
		
	return m_hr = m_pMtlbDispApp ->Invoke(m_dispid_Visible, IID_NULL,LOCALE_USER_DEFAULT, DISPATCH_PROPERTYPUT, &dpVisible, NULL, &m_excep, &m_uArgErr);
}

bool CMatlabEngine::IsVisible()
{
	VARIANT vArgsTypeLong[1];
	if (!m_bInitialized || !m_pMtlbDispApp)
	{
		m_hr = S_FALSE;
		return false;
	}

	::VariantInit(vArgsTypeLong);
	
	vArgsTypeLong[0].vt = VT_I4;
	vArgsTypeLong[0].lVal = 0; // Visible = 1; Invisible = 0
	
	DISPID dispidNamed = DISPID_PROPERTYPUT;
	
	DISPPARAMS dpVisible;
	dpVisible.cArgs = 1;
	dpVisible.cNamedArgs = 1;
	dpVisible.rgvarg = vArgsTypeLong;
	dpVisible.rgdispidNamedArgs = &dispidNamed;


	m_hr = m_pMtlbDispApp ->Invoke(m_dispid_Visible, IID_NULL,
		LOCALE_USER_DEFAULT,
		DISPATCH_PROPERTYGET, &m_dpNoArgs, &m_vResult, &m_excep, &m_uArgErr);

	return m_vResult.lVal != 0;
}
#endif

void CMatlabEngine::GetLastErrorMessage() const
{
	if(FAILED(m_hr))
		ErrHandler(m_hr, m_excep, m_uArgErr);
}


HRESULT CMatlabEngine::MaximiseWidow()
{
	if (!m_bInitialized || !m_pMtlbDispApp)
		return m_hr=S_FALSE;

	return m_hr = m_pMtlbDispApp->Invoke(m_dispid_MaximizeCommandWindow,
		IID_NULL,
		LOCALE_USER_DEFAULT, DISPATCH_METHOD, &m_dpNoArgs, NULL,
		&m_excep, &m_uArgErr);
}

HRESULT CMatlabEngine::MinimizeWindow()
{
	if (!m_bInitialized || !m_pMtlbDispApp)
		return m_hr=S_FALSE;

	return m_hr = m_pMtlbDispApp ->Invoke(m_dispid_MinimizeCommandWindow,
		IID_NULL,
		LOCALE_USER_DEFAULT, DISPATCH_METHOD, &m_dpNoArgs, NULL,
		&m_excep, &m_uArgErr);
}


HRESULT CMatlabEngine::PutMatrix( LPCTSTR szName, const std::vector<double>& vRealArray, const std::vector<double>& vImgArray, UINT nRows, UINT nCols)
{
	BSTR bstrName=NULL;

	if (!m_bInitialized || !m_pMtlbDispApp || (vRealArray.size() != vImgArray.size()) || (nRows*nCols > vRealArray.size()) )
		return m_hr=S_FALSE;

	ProcessString(szName, bstrName);

	SAFEARRAYBOUND realPartDims[2];
	realPartDims[0].lLbound = 0;     // Lower bound of the first dimension
	realPartDims[0].cElements = nRows;
	realPartDims[1].lLbound = 0;     // Lower bound of the second dimension
	realPartDims[1].cElements = nCols;


	SAFEARRAY *realPart = ::SafeArrayCreate(VT_R8, 2, realPartDims);
	SAFEARRAY *imgPart = ::SafeArrayCreate(VT_R8, 2, realPartDims);

	long lIndex[2];
	UINT k;
	double val;

	for (int i = 0; i < nRows; i++)
	{
		lIndex[0] = i;

		for (int j = 0; j < nCols; j++)
		{
			lIndex[1] = j;
			
			k=i*nCols+j;
			val=vRealArray[k];
			m_hr = ::SafeArrayPutElement(realPart, lIndex, &val);
			if (FAILED(m_hr))
				goto Exit;

			val=vImgArray[k];
			m_hr = ::SafeArrayPutElement(imgPart, lIndex, &val);
			if (FAILED(m_hr))
				goto Exit;
		}
	}


	VARIANT vArgPutFullMatrix[4];
	for (i = 0; i < 4; ++i)
		::VariantInit(&vArgPutFullMatrix[i]);


	V_VT(&vArgPutFullMatrix[0]) = VT_ARRAY | VT_R8;
	V_ARRAY(&vArgPutFullMatrix[0]) = imgPart; // do set to NULL when not complex
	V_VT(&vArgPutFullMatrix[1]) = VT_ARRAY | VT_R8;
	V_ARRAY(&vArgPutFullMatrix[1]) = realPart;
	V_VT(&vArgPutFullMatrix[2]) = VT_BSTR;
	V_BSTR(&vArgPutFullMatrix[2]) = m_bstrWorkspace;
	V_VT(&vArgPutFullMatrix[3]) = VT_BSTR;
	V_BSTR(&vArgPutFullMatrix[3])= bstrName;


	DISPPARAMS dpPutFullMatrix;
	dpPutFullMatrix.cArgs = 4;
	dpPutFullMatrix.cNamedArgs = 0;
	dpPutFullMatrix.rgvarg = vArgPutFullMatrix;


	m_hr = m_pMtlbDispApp ->Invoke(m_dispid_PutFullMatrix, IID_NULL,
    LOCALE_USER_DEFAULT, DISPATCH_METHOD, &dpPutFullMatrix, NULL, &m_excep, &m_uArgErr);

	if (FAILED(m_hr))
		goto Exit;

Exit:
	::SysFreeString(bstrName);
	m_hr = ::SafeArrayDestroy(realPart);
	m_hr = ::SafeArrayDestroy(imgPart);

	return m_hr;
}

HRESULT CMatlabEngine::PutMatrix( LPCTSTR szName, const std::vector<double>& vArray, UINT nRows, UINT nCols)
{
	BSTR bstrName=NULL;

	if (!m_bInitialized || !m_pMtlbDispApp || (nRows*nCols > vArray.size()) )
		return m_hr=S_FALSE;

	ProcessString(szName, bstrName);

	SAFEARRAYBOUND realPartDims[2];
	realPartDims[0].lLbound = 0;     // Lower bound of the first dimension
	realPartDims[0].cElements = nRows;
	realPartDims[1].lLbound = 0;     // Lower bound of the second dimension
	realPartDims[1].cElements = nCols;


	SAFEARRAY *realPart = ::SafeArrayCreate(VT_R8, 2, realPartDims);

	long lIndex[2];
	double val;

	for (int i = 0; i < nRows; i++)
	{
		lIndex[0] = i;

		for (int j = 0; j < nCols; j++)
		{
			lIndex[1] = j;

			val=vArray[i*nCols+j];
			m_hr = ::SafeArrayPutElement(realPart, lIndex, &val);
			if (FAILED(m_hr))
				goto Exit;
		}
	}


	VARIANT vArgPutFullMatrix[4];
	for (i = 0; i < 4; ++i)
		::VariantInit(&vArgPutFullMatrix[i]);


	V_VT(&vArgPutFullMatrix[0]) = VT_ARRAY | VT_R8;
	V_ARRAY(&vArgPutFullMatrix[0]) = NULL; // do set to NULL when not complex
	V_VT(&vArgPutFullMatrix[1]) = VT_ARRAY | VT_R8;
	V_ARRAY(&vArgPutFullMatrix[1])= realPart;
	V_VT(&vArgPutFullMatrix[2]) = VT_BSTR;
	V_BSTR(&vArgPutFullMatrix[2]) = m_bstrWorkspace;
	V_VT(&vArgPutFullMatrix[3]) = VT_BSTR;
	V_BSTR(&vArgPutFullMatrix[3]) = bstrName;


	DISPPARAMS dpPutFullMatrix;
	dpPutFullMatrix.cArgs = 4;
	dpPutFullMatrix.cNamedArgs = 0;
	dpPutFullMatrix.rgvarg = vArgPutFullMatrix;

	m_hr = m_pMtlbDispApp ->Invoke(m_dispid_PutFullMatrix, IID_NULL,
		LOCALE_USER_DEFAULT, DISPATCH_METHOD, &dpPutFullMatrix, NULL, &m_excep, &m_uArgErr);

	if (FAILED(m_hr))
		goto Exit;

Exit:
	::SysFreeString(bstrName);
	m_hr = ::SafeArrayDestroy(realPart);

	return m_hr;
}


HRESULT CMatlabEngine::GetMatrix( LPCTSTR szName,  UINT& nRows, UINT& nCols, std::vector<double>& vRealArray, std::vector<double>* pImgArray)
{
	if (!m_bInitialized || !m_pMtlbDispApp)
		return m_hr=S_FALSE;

	static TCHAR tzBuffer[512];
	std::vector<double> vSize;
	BSTR bstrName=NULL;

	ProcessString(szName, bstrName);

	// computing size of matrix
	_stprintf(tzBuffer, _T("%sSize=size(%s);"), szName, szName);
	m_hr = Execute(tzBuffer);
	if (FAILED(m_hr))
		goto Exit;

	_stprintf(tzBuffer, _T("%sSize"), szName);
	m_hr = GetMatrixKnownSize( tzBuffer, 1,2, vSize);
	if (FAILED(m_hr))
		goto Exit;

	nRows = vSize[0];
	nCols = vSize[1];

	// getting matrix...
	if (pImgArray)
		m_hr = GetMatrixKnownSize( szName, nRows,nCols, vRealArray, *pImgArray);
	else
		m_hr = GetMatrixKnownSize( szName, nRows,nCols, vRealArray);

	if (FAILED(m_hr))
		goto Exit;
	

Exit:
	::SysFreeString(bstrName);

	return m_hr;
}

HRESULT CMatlabEngine::GetMatrixKnownSize( LPCTSTR szName,  UINT nRows, UINT nCols, std::vector<double>& vArray)
{
	if (!m_bInitialized || !m_pMtlbDispApp)
		return m_hr=S_FALSE;

	BSTR bstrName=NULL;
	UINT i,j;
	SAFEARRAY *realPart=NULL;
	SAFEARRAY *imgPart=NULL;
	double*		pDummy = NULL ;						// for access to the data
	VARIANT vArgGetFullMatrix[4];


	// Preparing name
	ProcessString(szName, bstrName);

	SAFEARRAYBOUND realPartDims[2];
	realPartDims[0].lLbound = 1;     // Lower bound of the first dimension
	realPartDims[0].cElements = nRows;
	realPartDims[1].lLbound = 1;     // Lower bound of the second dimension
	realPartDims[1].cElements = nCols;
	realPart=::SafeArrayCreate(VT_R8, 2, realPartDims);

	SAFEARRAYBOUND imgPartDims[1] = { {0,0}};
	imgPart=::SafeArrayCreate(VT_R8, 1, imgPartDims);


	//loading data...
	for (i = 0; i < 4; ++i)
		::VariantInit(&vArgGetFullMatrix[i]);

	V_VT(&vArgGetFullMatrix[0]) = VT_ARRAY | VT_R8 | VT_BYREF;
	vArgGetFullMatrix[0].pparray = &imgPart; // do set to NULL when not complex
	V_VT(&vArgGetFullMatrix[1]) = VT_ARRAY | VT_R8 | VT_BYREF;
	vArgGetFullMatrix[1].pparray = &realPart;
	V_VT(&vArgGetFullMatrix[2]) = VT_BSTR;
	V_BSTR(&vArgGetFullMatrix[2]) = m_bstrWorkspace;
	V_VT(&vArgGetFullMatrix[3]) = VT_BSTR;
	V_BSTR(&vArgGetFullMatrix[3]) = bstrName;

	DISPPARAMS dpGetFullMatrix;
	dpGetFullMatrix.cArgs = 4;
	dpGetFullMatrix.cNamedArgs = 0;
	dpGetFullMatrix.rgvarg = vArgGetFullMatrix;

	m_hr = m_pMtlbDispApp ->Invoke(m_dispid_GetFullMatrix, IID_NULL,
		LOCALE_USER_DEFAULT, DISPATCH_METHOD, &dpGetFullMatrix, NULL, &m_excep, &m_uArgErr);

	if (FAILED(m_hr))
		goto Exit;


	if (::SafeArrayGetDim(realPart) != 2)
	{
		m_hr = S_FALSE;
		goto Exit;
	}

	vArray.resize(nRows*nCols);

	SafeArrayAccessData(realPart, (void HUGEP **)(&pDummy)) ;	// dummy now points to the data
	
	// copy each element across into the matrix to return
	for (i = 0; i < nRows ; ++i)
	{
		for (j = 0; j < nCols ; ++j)
		{
			vArray[i*nCols+j]=pDummy[i*nCols+j] ;
		}
	}
	pDummy = NULL ;									// no longer valid

Exit:
	::SysFreeString(bstrName);
	::SafeArrayUnaccessData(realPart) ;					// release the safe array data pointer
	::SafeArrayDestroy(realPart);
	::SafeArrayDestroy(imgPart);

	return m_hr;
}

HRESULT CMatlabEngine::GetMatrixKnownSize( LPCTSTR szName,  UINT nRows, UINT nCols, std::vector<double>& vRealArray, std::vector<double>& vImgArray)
{
	if (!m_bInitialized || !m_pMtlbDispApp)
		return m_hr=S_FALSE;

	BSTR bstrName=NULL;
	UINT i,j;
	SAFEARRAY *realPart=NULL;
	SAFEARRAY *imgPart=NULL;
	double*		pRealDummy = NULL ;						// for access to the data
	double*		pImgDummy = NULL ;						// for access to the data
	VARIANT vArgGetFullMatrix[4];


	// Preparing name
	ProcessString(szName, bstrName);

	SAFEARRAYBOUND realPartDims[2];
	realPartDims[0].lLbound = 1;     // Lower bound of the first dimension
	realPartDims[0].cElements = nRows;
	realPartDims[1].lLbound = 1;     // Lower bound of the second dimension
	realPartDims[1].cElements = nCols;
	realPart=::SafeArrayCreate(VT_R8, 2, realPartDims);

	SAFEARRAYBOUND imgPartDims[2];
	imgPartDims[0].lLbound = 1;     // Lower bound of the first dimension
	imgPartDims[0].cElements = nRows;
	imgPartDims[1].lLbound = 1;     // Lower bound of the second dimension
	imgPartDims[1].cElements = nCols;
	imgPart=::SafeArrayCreate(VT_R8, 2, imgPartDims);


	//loading data...
	for (i = 0; i < 4; ++i)
		::VariantInit(&vArgGetFullMatrix[i]);

	V_VT(&vArgGetFullMatrix[0]) = VT_ARRAY | VT_R8 | VT_BYREF;
	vArgGetFullMatrix[0].pparray = &imgPart; // do set to NULL when not complex
	V_VT(&vArgGetFullMatrix[1]) = VT_ARRAY | VT_R8 | VT_BYREF;
	vArgGetFullMatrix[1].pparray = &realPart;
	V_VT(&vArgGetFullMatrix[2]) = VT_BSTR;
	V_BSTR(&vArgGetFullMatrix[2]) = m_bstrWorkspace;
	V_VT(&vArgGetFullMatrix[3]) = VT_BSTR;
	V_BSTR(&vArgGetFullMatrix[3]) = bstrName;

	DISPPARAMS dpGetFullMatrix;
	dpGetFullMatrix.cArgs = 4;
	dpGetFullMatrix.cNamedArgs = 0;
	dpGetFullMatrix.rgvarg = vArgGetFullMatrix;

	m_hr = m_pMtlbDispApp ->Invoke(m_dispid_GetFullMatrix, IID_NULL,
		LOCALE_USER_DEFAULT, DISPATCH_METHOD, &dpGetFullMatrix, NULL, &m_excep, &m_uArgErr);

	if (FAILED(m_hr))
		goto Exit;


	if (::SafeArrayGetDim(realPart) != 2)
	{
		m_hr = S_FALSE;
		goto Exit;
	}

	vRealArray.resize(nRows*nCols);
	vImgArray.resize(nRows*nCols);

	SafeArrayAccessData(realPart, (void HUGEP **)(&pRealDummy)) ;	// dummy now points to the data
	SafeArrayAccessData(imgPart, (void HUGEP **)(&pImgDummy)) ;	// dummy now points to the data
	
	// copy each element across into the matrix to return
	for (i = 0; i < nRows ; ++i)
	{
		for (j = 0; j < nCols ; ++j)
		{
			vRealArray[i*nCols+j]=pRealDummy[i*nCols+j] ;
			vImgArray[i*nCols+j]=pImgDummy[i*nCols+j] ;
		}
	}
	pRealDummy = NULL ;									// no longer valid
	pImgDummy = NULL ;									// no longer valid

Exit:
	::SysFreeString(bstrName);
	::SafeArrayUnaccessData(realPart) ;					// release the safe array data pointer
	::SafeArrayUnaccessData(imgPart) ;					// release the safe array data pointer
	::SafeArrayDestroy(realPart);
	::SafeArrayDestroy(imgPart);

	return m_hr;
}


HRESULT CMatlabEngine::Quit()
{
	if (!m_bInitialized || !m_pMtlbDispApp)
	{
		
		m_bInitialized = false;
		return S_FALSE;
	}

	return m_hr = m_pMtlbDispApp ->Invoke(m_dispid_Quit, IID_NULL,
		LOCALE_USER_DEFAULT,
		DISPATCH_METHOD, &m_dpNoArgs, NULL, &m_excep, &m_uArgErr);
}

void CMatlabEngine::ProcessString( LPCTSTR szName, BSTR& bstrName)
{
	::SysFreeString(bstrName);

#ifndef _UNICODE
	int nChar;
	AllocateBuffer(_tcslen(szName));
	nChar=MultiByteToWideChar(CP_ACP,MB_PRECOMPOSED,szName,-1,m_pBuffer,m_uBufferSize);
	bstrName = ::SysAllocString(m_pBuffer);
#else
	bstrName = ::SysAllocString(OLESTR(szName));
#endif
}

#ifdef MATLAB_VERSION_6
HRESULT CMatlabEngine::PutString(LPCTSTR szName, LPCTSTR szString)
{
	BSTR bstrName=NULL;
	BSTR bstrString=NULL;
	UINT i;

	if (!m_bInitialized || !m_pMtlbDispApp)
		return S_FALSE;

	ProcessString(szName, bstrName);
	ProcessString(szString, bstrString);


	VARIANT vArgPutString[3];
	for (i = 0; i < 3; ++i)
		::VariantInit(&vArgPutString[i]);


	V_VT(&vArgPutString[0]) = VT_BSTR;
	V_BSTR(&vArgPutString[0]) = bstrString;
	V_VT(&vArgPutString[1]) = VT_BSTR;
	V_BSTR(&vArgPutString[1]) = m_bstrWorkspace;
	V_VT(&vArgPutString[2]) = VT_BSTR;
	V_BSTR(&vArgPutString[2]) = bstrName;


	DISPPARAMS dpPutString;
	dpPutString.cArgs = 3;
	dpPutString.cNamedArgs = 0;
	dpPutString.rgvarg = vArgPutString;

	m_hr = m_pMtlbDispApp ->Invoke(m_dispid_PutCharArray, IID_NULL,
		LOCALE_USER_DEFAULT, DISPATCH_METHOD, &dpPutString, NULL, &m_excep, &m_uArgErr);

	if (FAILED(m_hr))
		goto Exit;

Exit:
	::SysFreeString(bstrName);
	::SysFreeString(bstrString);

	return m_hr;
}

HRESULT CMatlabEngine::GetString(LPCTSTR szName, LPTSTR& szString)
{
	static TCHAR tzBuffer[512];
	BSTR bstrName=NULL;
	UINT i;
	std::vector<double> vSize;

	if (!m_bInitialized || !m_pMtlbDispApp)
		return S_FALSE;

	ProcessString(szName, bstrName);


	// preparing argumetns
	VARIANT vArgGetString[2];
	for (i = 0; i < 1; ++i)
		::VariantInit(&vArgGetString[i]);

	V_VT(&vArgGetString[0]) = VT_BSTR;
	V_BSTR(&vArgGetString[0]) = m_bstrWorkspace;
	V_VT(&vArgGetString[1]) = VT_BSTR;
	V_BSTR(&vArgGetString[1]) = bstrName;


	DISPPARAMS dpGetString;
	dpGetString.cArgs = 2;
	dpGetString.cNamedArgs = 0;
	dpGetString.rgvarg = vArgGetString;

	m_hr = m_pMtlbDispApp ->Invoke(m_dispid_GetCharArray, IID_NULL,
		LOCALE_USER_DEFAULT, DISPATCH_METHOD, &dpGetString, &m_vResult, &m_excep, &m_uArgErr);

	if (FAILED(m_hr))
		goto Exit;

	// process back to szString...
	{
		_bstr_t s(m_vResult);
		szString=new TCHAR[s.length()+1];
		_tcscpy( szString, (LPCTSTR)s);
	}

Exit:
	::SysFreeString(bstrName);

	return m_hr;

}

//	static 
void CMatlabEngine::InitCom()
{
	static int bDidInit = false;
	if (!bDidInit) CoInitialize(0), bDidInit = true;
}

#endif

