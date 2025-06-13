#ifndef NETCLIENT_H
#define NETCLIENT_H

#include <string>
#include "Socket.h"

class NetClient : public Socket
{
public:
  NetClient(const std::string & host = "localhost", unsigned short port = 0);
  virtual ~NetClient();

  unsigned sendString(const std::string &) throw(const SocketException &);
  std::string receiveString(int desired_size=-1) throw(const SocketException &);
  // trailing newlines are stripped
  std::string receiveLine() throw(const SocketException &);  

  // trailing newlines are stripped -- note that char * pointers need to be deleted, as well as the char ** pointer!  This array is NULL terminated..
  // NB: tried to use std::list<> but VC98 got an internal error.. :(
  char ** receiveLines() throw (const SocketException &);

  static void deleteReceivedLines(char ** ptr_from_receiveLines);

  // overrides parent class
  virtual unsigned sendData(const void *d, unsigned dataSize) throw (const SocketException &);
  virtual unsigned receiveData(void *buf, unsigned bufSize, bool require_full_buf = true) throw (const SocketException &);

};

#endif
