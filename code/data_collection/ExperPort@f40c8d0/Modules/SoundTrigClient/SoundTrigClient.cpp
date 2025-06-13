
#include <math.h>
#include <string>
#include <string.h>
#include <mex.h>
#include <matrix.h>
#include <limits>

#include <map>

#include "NetClient.h"

typedef std::map<int, NetClient *> NetClientMap;
typedef signed int int32;
typedef unsigned int uint32;
typedef signed short int16;
typedef unsigned short uint16;
typedef signed char int8;
typedef unsigned char uint8;

#ifndef WIN32
#define strcmpi strcasecmp
#endif

static NetClientMap clientMap;
static int handleId = 0; // keeps getting incremented..

static NetClient * MapFind(int handle)
{
  NetClientMap::iterator it = clientMap.find(handle);
  if (it == clientMap.end()) return NULL;
  return it->second;
}

static void MapPut(int handle, NetClient *client)
{
  NetClient *old = MapFind(handle);
  if (old) delete old; // ergh.. this shouldn't happen but.. oh well.
  clientMap[handle] = client;
}

static void MapDestroy(int handle)
{
  NetClientMap::iterator it = clientMap.find(handle);
  if (it != clientMap.end()) {
    delete it->second;  
    clientMap.erase(it);
  } else {
    mexWarnMsgTxt("Invalid or unknown handle passed to SoundTrigClient MapDestroy!");
  }
}

static int GetHandle(int nrhs, const mxArray *prhs[])
{
  if (nrhs < 1) 
    mexErrMsgTxt("Need numeric handle argument!");

  const mxArray *handle = prhs[0];

  if ( !mxIsDouble(handle) || mxGetM(handle) != 1 || mxGetN(handle) != 1) 
    mexErrMsgTxt("Handle must be a single double value.");

  return static_cast<int>(*mxGetPr(handle));
}

static NetClient * GetNetClient(int nrhs, const mxArray *prhs[])
{
  int handle =  GetHandle(nrhs, prhs);
  NetClient *nc = MapFind(handle);
  if (!nc) mexErrMsgTxt("INTERNAL ERROR -- Cannot find the NetClient for the specified handle in SoundTrigClient!");
  return nc;
}

#define RETURN(x) do { (plhs[0] = mxCreateDoubleScalar(static_cast<double>(x))); return; } while (0)
#define RETURN_NULL() do { (plhs[0] = mxCreateDoubleMatrix(0, 0, mxREAL)); return; } while(0)

void createNewClient(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  if (nlhs != 1) mexErrMsgTxt("Cannot create a client since no output (lhs) arguments were specified!");
  if (nrhs != 2) mexErrMsgTxt("Need two input arguments: Host, port!");
  const mxArray *host = prhs[0], *port = prhs[1];
  if ( !mxIsChar(host) || mxGetM(host) != 1 ) mexErrMsgTxt("Hostname must be a string row vector!");
  if ( !mxIsDouble(port) || mxGetM(port) != 1 || mxGetN(port) != 1) mexErrMsgTxt("Port must be a single numeric value.");
  
  char *hostStr = mxArrayToString(host);
  unsigned short portNum = static_cast<unsigned short>(*mxGetPr(port));
  NetClient *nc = new NetClient(hostStr, portNum);
  mxFree(hostStr);
  nc->setSocketOption(Socket::TCPNoDelay, true);
  int h = handleId++;
  MapPut(h, nc);
  RETURN(h);
}

void destroyClient(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  MapDestroy(GetHandle(nrhs, prhs));
  RETURN(1);
}

void tryConnection(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  NetClient *nc = GetNetClient(nrhs, prhs);
  //if(nlhs < 1) mexErrMsgTxt("One output argument required.");
  bool ok = false;
  try {
    ok = nc->connect();
  } catch (const SocketException & e) {
    mexWarnMsgTxt(e.why().c_str());
    RETURN_NULL();
  }

  if (!ok) {
    mexWarnMsgTxt(nc->errorReason().c_str());
    RETURN_NULL();
  }

  RETURN(1);
}
 
void closeSocket(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  NetClient *nc = GetNetClient(nrhs, prhs);
  nc->disconnect();
  RETURN(1);
}


void sendString(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  NetClient *nc = GetNetClient(nrhs, prhs);
  
  if(nrhs != 2)		mexErrMsgTxt("Two arguments required: handle, string.");
  //if(nlhs < 1) mexErrMsgTxt("One output argument required.");
  if(mxGetClassID(prhs[1]) != mxCHAR_CLASS) 
	  mexErrMsgTxt("Argument 2 must be a string.");

  char *tmp = mxArrayToString(prhs[1]);
  std::string theString (tmp);
  mxFree(tmp);

  try {
    nc->sendString(theString);
  } catch (const SocketException & e) {
    mexWarnMsgTxt(e.why().c_str());
    RETURN_NULL();
  }  
  RETURN(1);
}

void sendMatrix(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  NetClient *nc = GetNetClient(nrhs, prhs);

  if(nrhs != 2)		mexErrMsgTxt("Two arguments required: handle, matrix.");
  //if(nlhs < 1) mexErrMsgTxt("One output argument required.");
  if(mxGetClassID(prhs[0]) != mxDOUBLE_CLASS) 
	  mexErrMsgTxt("Argument 2 must be a matrix of doubles.");

  double *theMatrix = mxGetPr(prhs[1]);
  int msglen = mxGetN(prhs[1]) * mxGetM(prhs[1]) * sizeof(double);

  try {
    nc->sendData(theMatrix, msglen);
  } catch (const SocketException & e) {
    mexWarnMsgTxt(e.why().c_str());
    RETURN_NULL();
  }
  
  RETURN(1);
}

void sendInt32Matrix(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  NetClient *nc = GetNetClient(nrhs, prhs);

  if(nrhs != 2)		mexErrMsgTxt("Two arguments required: handle, vector.");
  if(mxGetClassID(prhs[0]) != mxDOUBLE_CLASS) 
	  mexErrMsgTxt("Argument 2 must be a 1x1 scalar of doubles.");
  if(mxGetClassID(prhs[1]) != mxINT32_CLASS) 
	  mexErrMsgTxt("Argument 3 must be a matrix of int32s.");

  int32 *theInts = reinterpret_cast<int32 *>(mxGetData(prhs[1]));
  int msglen = mxGetN(prhs[1]) * mxGetM(prhs[1]) * sizeof(int32);

  try {
    nc->sendData(theInts, msglen);
  } catch (const SocketException & e) {
    mexWarnMsgTxt(e.why().c_str());
    RETURN_NULL();
  }
  
  RETURN(1);
}

void readString(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  //if(nlhs < 1) mexErrMsgTxt("One output argument required.");
  NetClient *nc = GetNetClient(nrhs, prhs);

  try {
    std::string theString ( nc->receiveString() );
    plhs[0] = mxCreateString(theString.c_str());
  } catch (const SocketException & e) {
    mexWarnMsgTxt(e.why().c_str());
    RETURN_NULL(); // note empty return..
  }
}

void readLines(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  //if(nlhs < 1) mexErrMsgTxt("One output argument required.");

  NetClient *nc = GetNetClient(nrhs, prhs);
  try {
    char **lines = nc->receiveLines();
    int m;
    for (m = 0; lines[m]; m++) {} // count number of lines
    plhs[0] = mxCreateCharMatrixFromStrings(m, const_cast<const char **>(lines));
    NetClient::deleteReceivedLines(lines);
  } catch (const SocketException &e) {
    mexWarnMsgTxt(e.why().c_str());
    RETURN_NULL(); // empty return set
  }
}


void readMatrix(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  NetClient *nc = GetNetClient(nrhs, prhs);
  if(nrhs != 3 || !mxIsDouble(prhs[1]) || !mxIsDouble(prhs[2]) ) mexErrMsgTxt("Output matrix size M,N as 2 real arguments are required.");
  //if(nlhs < 1) mexErrMsgTxt("One output argument required.");
  
  int m = static_cast<int>(*mxGetPr(prhs[1])),
	  n = static_cast<int>(*mxGetPr(prhs[2]));
  
  int dataLen = m*n*sizeof(double);
  
  
  plhs[0] = mxCreateDoubleMatrix(m, n, mxREAL);
  
  try {
    nc->receiveData(mxGetPr(plhs[0]), dataLen, true);
  } catch (const SocketException & e) {
    mexWarnMsgTxt(e.why().c_str());
    mxDestroyArray(plhs[0]);
    plhs[0] = 0;  // nullify (empty) return..
    RETURN_NULL();
  }
}  

void readInt32Matrix(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  NetClient *nc = GetNetClient(nrhs, prhs);
  if(nrhs != 3 || !mxIsDouble(prhs[1]) || !mxIsDouble(prhs[2]) ) mexErrMsgTxt("Output matrix size M, N as 2 real argument are required.");
  //if(nlhs < 1) mexErrMsgTxt("One output argument required.");
  
  const int m = static_cast<int>(*mxGetPr(prhs[1])), 
            n = static_cast<int>(*mxGetPr(prhs[2]));  
  const int dataLen = m*n*sizeof(int32);
  const int dims[] = { m, n };
  
  plhs[0] = mxCreateNumericArray(2, dims, mxINT32_CLASS, mxREAL);
  
  try {
    nc->receiveData(mxGetData(plhs[0]), dataLen, true);
  } catch (const SocketException & e) {
    mexWarnMsgTxt(e.why().c_str());
    mxDestroyArray(plhs[0]);
    plhs[0] = 0;  // nullify (empty) return..
    RETURN_NULL();
  }
}

class GenericMatrix
{
public:
  GenericMatrix(void *ptr, unsigned elem_size, unsigned m, unsigned n)
    : p(reinterpret_cast<char *>(ptr)), p_ret(p), elem_size(elem_size), m(m), n(n),
      first_index(-1) {}
  GenericMatrix & operator[](int i);
  operator void *() { return p_ret; }
  GenericMatrix & operator=(void *in);
private:
  char *p, *p_ret;  
  unsigned elem_size, m, n;
  int first_index;
  GenericMatrix(const GenericMatrix &) {}
  GenericMatrix & operator=(const GenericMatrix &) { return *this; }
};

GenericMatrix & GenericMatrix::operator=(void *in) 
{ memcpy(p_ret, in, elem_size); return *this; }

GenericMatrix & GenericMatrix::operator[](int i)
{
  if ( first_index >= 0 ) {
    p_ret += i*elem_size;
    first_index = -1;
  } else {
    first_index = i;
    p_ret = p + n*elem_size*first_index;
  }
  return *this;
}

// returns a 1x(m*n) vector that is an interleaving of the rows of the input matrix.. useful for sending 2-channel sound files as 1 interleaved channel to the sound server...
void interleaveMatrix(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  const mxArray *inArray;
  if(nrhs != 1 || !prhs || !(inArray = *prhs) || !mxIsNumeric(inArray) || mxIsSparse(inArray)) 
    mexErrMsgTxt("Input matrix must be a non-sparse numeric array!");
  //if(nlhs < 1) mexErrMsgTxt("One output argument required.");

  mxArray * & outArray = plhs[0];
  
  const int m = mxGetM(inArray), 
            n = mxGetN(inArray);  
  const int dims[] = { 1, m*n };
  
  outArray = mxCreateNumericArray(2, dims, mxGetClassID(inArray), mxREAL);
  const unsigned elem_size = mxGetElementSize(inArray);
  /*  GenericMatrix 
    in(mxGetData(inArray), elem_size, m, n), 
    out(mxGetData(outArray), elem_size, 1, m*n);
  for (int i = 0; i < m; ++i)
    for (int j = 0; j < n; j++) 
    out[0][i*n + j] = static_cast<void *>( in[i][j] );*/

  // NB: you can just do a memcpy since all matrices are stored in column-major order anyway..
  ::memcpy(mxGetData(outArray), mxGetData(inArray), elem_size*m*n);
}

// returns a matrix that is the int32 conversion of the input matrix.  This should be faster than the matlab internal int32, right?  
// Note: this scales input doubles from -1 -> 1 over MIN_INT to MAX_INT
void toInt32(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  const mxArray *inArray;
  if(nrhs != 1 || !prhs || !(inArray = *prhs) || !mxIsNumeric(inArray) || mxIsSparse(inArray)) 
    mexErrMsgTxt("Input matrix must be a non-sparse numeric array!");
  //if(nlhs < 1) mexErrMsgTxt("One output argument required.");

  mxArray * & outArray = plhs[0];
  
  const int m = mxGetM(inArray), 
            n = mxGetN(inArray);  
  const int dims[] = { m, n };
  
  outArray = mxCreateNumericArray(2, dims, mxINT32_CLASS, mxREAL);
  const unsigned elem_size = mxGetElementSize(inArray);
  GenericMatrix 
    in(mxGetData(inArray), elem_size, m, n), 
    out(mxGetData(outArray), mxGetElementSize(outArray), m, n);
  int class_id = mxGetClassID(inArray);
  for (int i = 0; i < m; ++i) {
    for (int j = 0; j < n; j++) {      
      void *inptr = static_cast<void *>( in[i][j] );
      int32 & outval = *reinterpret_cast<int32 *>(static_cast<void *>(out[i][j]));
      switch(class_id) {
      case mxINT8_CLASS:	
	outval = *reinterpret_cast<int8 *>(inptr);
	break;
      case mxUINT8_CLASS:	
	outval = *reinterpret_cast<uint8 *>(inptr);
	break;
      case mxINT16_CLASS:	
	outval = *reinterpret_cast<int16 *>(inptr);
	break;
      case mxUINT16_CLASS:	
	outval = *reinterpret_cast<uint16 *>(inptr);
	break;
      case mxINT32_CLASS:	
	outval = *reinterpret_cast<int32 *>(inptr);
	break;
      case mxUINT32_CLASS:	
	outval = *reinterpret_cast<uint32 *>(inptr);
	break;
      default: /* assume double.. */
	outval = static_cast<int32>(*reinterpret_cast<double *>(inptr) * std::numeric_limits<int32>::max());
	break;
      }
    }
  }
}

struct CommandFunctions
{
	const char *name;
	void (*func)(int, mxArray **, int, const mxArray **);
};

static struct CommandFunctions functions[] = 
{
        { "create", createNewClient },
        { "destroy", destroyClient },
	{ "connect", tryConnection },
	{ "disconnect", closeSocket },
	{ "sendString", sendString },
	{ "sendMatrix", sendMatrix },
	{ "sendInt32Matrix", sendInt32Matrix },
	{ "readString", readString },
	{ "readLines",  readLines},
        { "readMatrix", readMatrix },
        { "readInt32Matrix", readInt32Matrix },
        { "interleaveMatrix", interleaveMatrix }, 
        { "interlaceMatrix", interleaveMatrix }, 
        { "flattenMatrix", interleaveMatrix },
	{ "toInt32", toInt32 }
};

static const int n_functions = sizeof(functions)/sizeof(struct CommandFunctions);

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
  const mxArray *cmd;
  int i;
  std::string cmdname;

  /* Check for proper number of arguments. */
  if(nrhs < 2) 
    mexErrMsgTxt("At least two input arguments are required.");
  else 
    cmd = prhs[0];
  
  if(!mxIsChar(cmd)) mexErrMsgTxt("COMMAND argument must be a string.");
  if(mxGetM(cmd) != 1)   mexErrMsgTxt("COMMAND argument must be a row vector.");
  char *tmp = mxArrayToString(cmd);
  cmdname = tmp;
  mxFree(tmp);
  for (i = 0; i < n_functions; ++i) {
	  // try and match cmdname to a command we know about
    if (::strcmpi(functions[i].name, cmdname.c_str()) == 0 ) { 
         // a match.., call function for the command, popping off first prhs
		functions[i].func(nlhs, plhs, nrhs-1, prhs+1); // call function by function pointer...
		break;
	  }
  }
  if (i == n_functions) { // cmdname didn't match anything we know about
	  std::string errString = "Unrecognized SoundTrigClient command.  Must be one of: ";
	  for (int i = 0; i < n_functions; ++i)
        errString += std::string(i ? ", " : "") + functions[i].name;
	  mexErrMsgTxt(errString.c_str());
  }
}



