#include <windows.h>
#include <string>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include "MatlabEngine.h"
#include "NetClient.h"

int main(int argc, char *argv[])
{
  if (argc < 3) {
    std::cerr <<  "Usage: " << argv[0] << " host:port matlab_callback [matlab_callback_on_connection_failure]\n";
    return 1;
  }
  char *colon = 0;
  unsigned short port = 0;
  if ( (colon = ::strchr(argv[1], ':')) ) {
    *colon++ = 0;
    port = atoi(colon);
  }
  if (!port) port = 3333;
  std::string host = argv[1];
  std::string cb = argv[2], cb_connfail = "";
  CMatlabEngine matlab;
  try {
    NetClient nc(host, port);
    if (!nc.connect()) {
      std::cerr << "Could not connect to " << host << ":" << port << std::endl;
      return 2;
    }
    if (!matlab.IsInitialized()) {
      std::cerr <<  "Could not initialize COM: " << matlab.GetLastHResult() << "\n";
      return 3;
    }
    if (argc > 3) cb_connfail = argv[3];
    
    nc.sendString(std::string("NOTIFY EVENTS VERBOSE\n"));
    std::string tmp = nc.receiveLine();
    if (tmp.find("OK") != 0) {
      std::cerr << "NOTIFY EVENTS got result " << tmp << "\n";      
      return 4;
    }
    for (;;) {
      if (nc.waitData(5000)) {
        char **lines = nc.receiveLines();
        tmp = "[ ";
        for (int i = 0; lines[i]; ++i) 
          tmp += std::string("") + lines[i] + "; ";
        tmp += "]; " + cb;
        NetClient::deleteReceivedLines(lines);
        HRESULT res = matlab.Execute(tmp.c_str());
        if (FAILED(res)) {
          std::cerr << "Matlab execute command failed: HRESULT is " << res << "\n";      
          return 5;
        }
      }
    }
  } catch (const SocketException & e) {
    std::cerr << "Socket Exception: " << e.why() << "\n"; 
    if (!cb_connfail.empty()) matlab.Execute(cb_connfail.c_str());
    return 6;
  }
  return 0;
}

#include <shellapi.h>

int __stdcall WinMain( 
    HINSTANCE hInstance,
    HINSTANCE hPrevInstance,
    LPSTR lpCmdLine,
    int nCmdShow
    )
{  
   LPWSTR *szArglist;
   int nArgs, ret = -1;
   int i;

   // the below code is necessary because stupid windows' WinMain doesn't 
   // break up command-line arguments for us, so we have to ask 'the shell' 
   // to do it.  And by shell windows means its retarded UI and associated 
   // libs..

   szArglist = CommandLineToArgvW(GetCommandLineW(), &nArgs);
   if( NULL == szArglist )
   {
      wprintf(L"CommandLineToArgvW failed\n");
      return -1;
   }
   else {
     // now the freaking list of args is in wide-string format.  we like chars
     // so force a conversion to char * from unsigned short *...
     char **argv = new char *[nArgs+1];     
     for ( i = 0; i < nArgs; ++i) {
       std::wstring w(szArglist[i]);
       std::string s = "";
       for (std::wstring::iterator it = w.begin(); it != w.end(); ++it)
         s += char(*it);
       argv[i] = strdup(s.c_str());
     }
     argv[nArgs] = 0;
     // Free memory allocated for CommandLineToArgvW arguments.
     LocalFree(szArglist);     
     // call main, let it do it's job
     int ret = main(nArgs, argv);
     // Free memory allocated for CommandLineToArgvW arguments.
     for ( i = 0; i < nArgs; ++i) 
       free(argv[i]);
     delete [] argv;
   }
   return ret;
}
