
#include "NetClient.h"


NetClient::NetClient(const std::string & h, unsigned short p)
  : Socket(TCP)
{
  setHost(h);
  setPort(p);
}

NetClient::~NetClient() {}

unsigned NetClient::sendData(const void *d, unsigned dataSize) throw (const SocketException &)
{
  unsigned sent = 0;
  const char *dataBuf = static_cast<const char *>(d);
  bool prev_tcpNDelay = m_tcpNDelay;
  
  // turn on nagle for large transfers
  if (dataSize > (unsigned)m_sendBuf) {
    prev_tcpNDelay = m_tcpNDelay;
    setSocketOption(TCPNoDelay, false); // modifies m_tcpNDelay
  }

  while (sent < dataSize)
    sent += Socket::sendData(dataBuf + sent, dataSize - sent);

  // reenable previous no nagle if required
  if (prev_tcpNDelay != m_tcpNDelay) 
    setSocketOption(TCPNoDelay, prev_tcpNDelay);  


  return sent;
}

unsigned NetClient::receiveData(void *d, unsigned dataSize, bool require_full) throw (const SocketException &)
{
  unsigned recvd = 0;
  char *dataBuf = static_cast<char *>(d);

  while ( (require_full && recvd < dataSize) || !recvd) {
    recvd += Socket::receiveData(dataBuf + recvd, dataSize - recvd);
    if (recvd == 0 && dataSize == 0) break; // force break from loop
  }
  return recvd;
}

std::string NetClient::receiveString(int desired_sz) throw (const SocketException &)
{
  unsigned sz = 2048;
  if (desired_sz > 0)
    sz = desired_sz;
  std::string ret;
  ret.reserve(sz);
  // HACK
  char *data = const_cast<char *>(ret.data());
  unsigned read = receiveData(data, sz, false);
  if (read >= sz) read--;
  data[read] = 0;
  return ret;
}

std::string NetClient::receiveLine() throw(const SocketException &)
{
  // sub-optimal implementation grabs one character at a time..
  char c;
  int num;
  std::string ret = "";

  while(1) {
    num = receiveData(&c, 1);
    if (!num) break;
    if (c == '\n') break;
    ret += c;
  }
  return ret;
}


char ** NetClient::receiveLines() throw(const SocketException &)
{
  static const int NLINES = 255;
  char **lines = new char *[NLINES+1];
  int i = 0;
  do {
    std::string str = receiveLine();
    int len = str.length()+1;
    char *pcstr = new char [len];
    ::strncpy(pcstr, str.c_str(), len);
    pcstr[len-1] = 0;
    lines[i++] = pcstr;
  } while(hasData() && i < NLINES);
  lines[i] = 0;
  return lines;
}

/* static */
void NetClient::deleteReceivedLines(char ** ptr_from_receiveLines)
{
  char **cur = ptr_from_receiveLines;
  while (*cur) delete [] *cur++;
  delete [] ptr_from_receiveLines;
}

unsigned NetClient::sendString(const std::string &s) throw(const SocketException &)
{
  return sendData(s.data(), s.length());
}

#ifdef TESTNETCLIENT

#ifdef WIN32
#  include <io.h>
#endif

#include <stdio.h>

#include <string>

int main(void)
{
  char buf[2048];
  int nread;
  unsigned nsent;

  try {

    NetClient c("10.10.10.87", 3333);
    c.setSocketOption(Socket::TCPNoDelay, true);

    if (!c.connect()) { 
      std::string err = c.errorReason();
      fprintf(stderr, "Error connecting: %s\n", err.c_str());
      return 1;
    }
    
    while ( ( nread = ::read(::fileno(stdin), buf, sizeof(buf)) ) >= 0 ) {
      if (nread >= (int)sizeof(buf)) nread = sizeof(buf)-1;
      buf[nread] = 0;
      nsent = c.sendString(buf);
      fprintf(stderr, "Sent %u\n", nsent);
      char **lines = c.receiveLines(), **cur;
      for (cur = lines; *cur; cur++) 
        fprintf(stderr, "got: %s\n", *cur);
      NetClient::deleteReceivedLines(lines);
    }
  } catch (const ConnectionClosed & e) {
    fprintf(stderr, "Connection closed. (%s)\n", e.why().c_str());
    return 2;    
  } catch (const SocketException & e) {
    fprintf(stderr, "Caught exception.. (%s)\n", e.why().c_str());
    return 1;
  }

  return 0;
}

#endif
