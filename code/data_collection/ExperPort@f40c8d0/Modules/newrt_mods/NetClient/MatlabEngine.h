// MatlabEngine.h: interface for the CMatlabEngine class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_MATLABENGINE_H__68399C4F_F2D7_4111_B685_0B4778EE6F16__INCLUDED_)
#define AFX_MATLABENGINE_H__68399C4F_F2D7_4111_B685_0B4778EE6F16__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

// you may want to move these includes to your StdAfx.h
#include <objbase.h>
#include <comdef.h>
#include <vector>
#include <tchar.h>
#include <stdio.h>
#include <windows.h>

//! Undefine this if you don't have Matlab 6 or higher (will disable some functions)
#define MATLAB_VERSION_6


/*! \brief A class wrapper for the Matlab COM interface.

<p>This class wraps the Matlab COM interfaces and eases up the integration of Matlab in any Windows program. With this class, 
you can access Matlab engine in a few lines and without playing with the ugly COM syntax or linking with the Matlab libraries.</p>
<p><b>Initialization:</b>Each MatlabEngine object creates an instance of the Matlab engine (this is done automatically in the constructor).
The user can check that initialization has successed by calling IsInited.
Do not forget to initialize COM in the application thread by calling CoInitialize.</p>
<p>The users with Matlab version earlier than 6.0 should undefine the constant MATLAB_VERSION_6.</p>
<p><b>Example of use:</b></p>
\code
CMatlabEngine matlab; \endcode
<ul>
<li>Using matlab command line:
\code 
// showing a classic Matlab example:
matlab.Execute(_T("surf(peaks);"));
\endcode
</li>
<li>Sending a matrix of data to Matlab:
\code
int m,n;
vector<double> vMatrix(m*n);
// filling vMatrix with elements, line by line : vMatrix(i,j) = vMatrix[i * n + j]
...

matlab.PutMatrix(_T("matrix"), vMatrix, m, n); 
\endcode
</li>
<li>Sending a string to Matlab:
\code 
matlab.PutString(_T("string"),_T("This is a test string"));
\endcode 
</li>
<li>Retreiving a matrix from Matlab:
\code
vector<double> vMatrix;
UINT nRows, nCols;

// suppose that v is a matrix in the matlab workspace
matlab.GetMatrix(_T("v"), nRows, nCols, vMatrix);
// vMatrix now contains v, nRows the number of rows of v and nCols the number of columns of v...
\endcode
</li>
<li>Sending a string to Matlab
\code
matlab.PutString("text","This is a string");
\endcode
</li>
<li>Retreiving a string from Matlab
\code
LPTSTR szText;
matlab.GetString("text",szText);
\endcode
Note that szText is allocated on the head and must be delete by the user.
</li>
</ul>
<p><b>Requisites:</b> 
<ul>
<li>Matlab ActiveX control installed on your machine to make it work.</li>
<li>Does not need MFC</li>
</ul>
</p>
<p><b>Licensing:</b></p>This code is totally free. Just don't forget to add the authors name in the credits...</p>

	\author Jonathan de Halleux, dehalleux@auto.ucl.ac.be
<p><b>Revision history</b></p>
<ul>
<li><b>10-09-2002</b>, GetString is now working!
<li><b>10-08-2002</b>, Fixed bug in GetResult, GetMatrix. Found by Juan Carlos Cobas.
<li><b>09-25-2002</b>, GetMatrix is now working !</li>
<li><b>09-23-2002</b>, Added MATLAB_VERSION_6 constant to disable features.
Undefine the constant if your Matlab version is < 6. This solution was found by ZHANG Yan.
Added PutString
</li>
</ul>

\par Reference
Matlab COM documentation: http://www.mathworks.com/access/helpdesk/help/pdf_doc/matlab/apiext.pdf
*/
class CMatlabEngine  
{
public:
	//! \name Constructors
	//@{
	/*! \brief Default constructor

	This constructor initializes the Matlab Engine. Successfull initialization can be checked with IsInited .
	\param bDedicated true if the Matlab engine instance has to be unique, false otherwize (default is false)
	\sa IsInitialized
	*/
	CMatlabEngine(bool bDedicated = false);
	virtual ~CMatlabEngine();
	//@}

	//! \name Engine Initialization checkers
	//@{
	//! returns true if the matlab engine has been properly initialized
	bool IsInitialized() const	{ return m_bInitialized;};
	//@}

	//! \name Matlab window handling
	//@{
#ifdef MATLAB_VERSION_6
	/*! \brief  returns true if matlab is visible

	\warning Supported for Matlab >= 6 
	*/
	bool IsVisible();
	/*! \brief show / hide matlab console

	\warning Supported for Matlab >= 6 
	*/
	HRESULT Show(bool bShow = true);
#endif
	//! minimize matlab console
	HRESULT MinimizeWindow();
	//! maximize matlab console
	HRESULT MaximiseWidow();
	//! Quit console
	HRESULT Quit();
	//@}

	//! \name Engine Kernel
	//@{
	/*! \brief Execute matlab instructions

	\param szCode string containing the matlab code to execute

	Here's an example of use:
	\code 
	CMatlabEngine mt;
	...
	mt.Execute(_T("surf(peaks)"));
	mt.Execute(_T("title('demo of use')"));
	\endcode
	*/
	HRESULT Execute( LPCTSTR szCode);

	//! Get the latest string result of Execute...
	const BSTR& GetResult() const	{	return m_vResult.bstrVal;};

	/*! \brief Add a matrix to matlab workspace

	\param szName name of the variable in matlab 
	\param vArray vector of data, filled line by lines
	\param nRows number of rows in array
	\param nCols number of columns in array
	
	If nRows * nCols is greater than the size of vArray, nothing is done.

	Here's an example of use: plotting a 2 columns vector
	\code 
	CMatlabEngine mt;
	...
	vector<double> v(200);
	... // v[i] =... etc
	mt.PutMatrix(_T("v"), v, 100, 2);
	mt.Execute(_T("plot(v)"));
	\endcode
	*/
	HRESULT PutMatrix( LPCTSTR szName, const std::vector<double>& vArray, UINT nRows, UINT nCols);

	/*! \brief Add a complexmatrix to matlab workspace

	\param szName name of the variable in matlab 
	\param vRealArray vector of data (real part), filled line by lines
	\param vImgArray vector of data (real part), filled line by lines
	\param nRows number of rows in array
	\param nCols number of columns in array

	If nRows * nCols is greater than the size of vArray, nothing is done.
	*/
	HRESULT PutMatrix( LPCTSTR szName, const std::vector<double>& vRealArray, const std::vector<double>& vImgArray, UINT nRows, UINT nCols);

	/*! \brief Retreives a matrix from matlab 

	\param szName name of the variable in matlab 
	\param nRows number of rows in matrix 
	\param nCols number of columns in matrix
	\param vRealArray vector of data (real part), filled line by lines
	\param pImgArray pointer to vector of data (optional)

	Put a pointer to a vector pImgArray to retreive a complex matrix.
	*/
	HRESULT GetMatrix( LPCTSTR szName,  UINT& nRows, UINT& nCols, std::vector<double>& vRealArray, std::vector<double>* pImgArray = NULL);


#ifdef MATLAB_VERSION_6
	/*! \brief Adds a string to matlab
	
	\param szName name of the string in matlab
	\param szString string

	\warning Supported for Matlab >= 6 
	*/
	HRESULT PutString( LPCTSTR szName, LPCTSTR szString);

	/*! \brief Retreives a string from Matlab
	
	\param szName name of the string in matlab
	\param szString NULL pointer of type LPTSTR

	szString is allocated on the heap and must be cleaned by the user.

	\warning Supported for Matlab >= 6 
	*/
	HRESULT GetString( LPCTSTR szName, LPTSTR& szString);
#endif
	//@}

	//! \name Workspace
	//@{
	//! sets the current workspace,  (default is "base")
	void SetWorkspace(LPCTSTR szWorkspace);
	//@}

	//! \name Error handling
	//@{
	//! Displays a message box with error description
	void GetLastErrorMessage() const;
	//! Returns last HRESULT
	HRESULT GetLastHResult() const	{	return m_hr;};
	//! returns last VARIANT result
	const VARIANT& GetLastVResult() const	{	return m_vResult;};
	//! returns last EXECPINFO
	const EXCEPINFO& GetLastExcep() const	{	return m_excep;};
	//! returns last ArgErr
	UINT GetLastArgErr() const		{	return m_uArgErr;};
	//@}

	//! \name Misc init
	// @{
	//! Call this once to initialize COM/DCOM (or you can call CoInitialize yourself!)
	static void InitCom();
	//@}

protected:
	//! \name Internal methods
	//@{
	//! Display a error message defined by hr, excep and uArgErr
	static void ErrHandler(HRESULT hr, EXCEPINFO excep, UINT uArgErr);
	//! Allocates bstrName and transforms / copy szName to bstrName
	void ProcessString( LPCTSTR szName, BSTR& bstrName);
	//! Retreives a matrix from matlab (you must know the size of the matrix)
	HRESULT GetMatrixKnownSize( LPCTSTR szName,  UINT nRows, UINT nCols, std::vector<double>& vArray);
	//! Retreives a complex matrix from matlab (you must know the size of the matrix)
	HRESULT GetMatrixKnownSize( LPCTSTR szName,  UINT nRows, UINT nCols, std::vector<double>& vRealArray, std::vector<double>& vImgArray);
	//@}

private:
	bool m_bInitialized;
	BSTR m_bstrWorkspace;

	IDispatch* m_pMtlbDispApp;
	
	DISPID m_dispid_GetFullMatrix;
	DISPID m_dispid_PutFullMatrix;
	DISPID m_dispid_Execute;
	DISPID m_dispid_MinimizeCommandWindow;
	DISPID m_dispid_MaximizeCommandWindow;
#ifdef MATLAB_VERSION_6
	DISPID m_dispid_GetCharArray;
	DISPID m_dispid_PutCharArray;
	DISPID m_dispid_Visible;
#endif
	DISPID m_dispid_Quit;

	HRESULT m_hr;
	VARIANT m_vResult;
	EXCEPINFO m_excep;
	UINT m_uArgErr;
	DISPPARAMS m_dpNoArgs;

// non unicode handling...
#ifndef _UNICODE
	void AllocateBuffer(UINT uSize)
	{
		if (uSize <= m_uBufferSize-1) 
			return;
		if (m_pBuffer) 
			delete[] m_pBuffer;
		m_pBuffer = new WCHAR[m_uBufferSize = uSize+1];
	};
	WCHAR* m_pBuffer;
	UINT m_uBufferSize;
#endif
};

#endif // !defined(AFX_MATLABENGINE_H__68399C4F_F2D7_4111_B685_0B4778EE6F16__INCLUDED_)
