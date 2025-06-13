
#include <math.h>
#include <string>
#include <string.h>
#include <mex.h>
#include <matrix.h>
#include <limits>
#include <stdio.h>
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
    mexWarnMsgTxt("Invalid or unknown handle passed to TCPClient MapDestroy!");
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
  if (!nc) mexErrMsgTxt("INTERNAL ERROR -- Cannot find the NetClient for the specified handle in TCPClient!");
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

void readLinesAndSplitToCellMatrix(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  int m = 0, n = 0;
  //if(nlhs < 1) mexErrMsgTxt("One output argument required.");
  if (nrhs < 2) mexErrMsgTxt("Two args required: handle, delimiter_chars.");
  if (nrhs >= 3) n = static_cast<int>(*mxGetPr(prhs[2]));

  if(mxGetClassID(prhs[1]) != mxCHAR_CLASS) 
	  mexErrMsgTxt("Argument 2 must be a string.");

  char *tmp = mxArrayToString(prhs[1]);
  std::string delims (tmp);
  mxFree(tmp);

  NetClient *nc = GetNetClient(nrhs, prhs);

  try {
    char **lines = nc->receiveLines();
    for (m = 0; lines[m]; m++) {} // count number of lines to determine rows
    if (m && n <= 0) {
      // count cols if they weren't specified
      char *s = new char[strlen(lines[0])+1], *sp = s;
      strcpy(s, lines[0]);
      for (n = 0; strtok(sp, delims.c_str()); ++n) sp = 0;
      delete [] s;
    }
    mxArray *cell = plhs[0] = mxCreateCellMatrix(m, n);
    int subs[2] = {0,0};
    for (subs[0] = 0; subs[0] < m; ++subs[0]) {
      for (subs[1] = 0; subs[1] < n; ++subs[1]) {
        int idx = mxCalcSingleSubscript(cell, 2, subs);
        char *s = subs[1] == 0 ? lines[subs[0]] : 0;
        char *token = strtok(s, delims.c_str());
        if (token) {
          double d = 0.;
          if (sscanf(token, "%lf", &d) == 1) {
            // it's numeric..
            mxSetCell(cell, idx, mxCreateDoubleScalar(d));
          } else { 
            // not numeric, just copy the string verbatim
            mxSetCell(cell, idx, mxCreateString(token));
          }
        }
      }
    }
    NetClient::deleteReceivedLines(lines);  
  } catch (const SocketException &e) {
    mexWarnMsgTxt(e.why().c_str());
    RETURN_NULL(); // empty return set
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
        { "readString", readString },
        { "readLines",  readLines},
        { "readLinesAndSplitToCellMatrix",  readLinesAndSplitToCellMatrix},
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
	  std::string errString = "Unrecognized TCPClient command.  Must be one of: ";
	  for (int i = 0; i < n_functions; ++i)
        errString += std::string(i ? ", " : "") + functions[i].name;
	  mexErrMsgTxt(errString.c_str());
  }
}
