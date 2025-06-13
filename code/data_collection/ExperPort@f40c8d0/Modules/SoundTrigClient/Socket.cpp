#include "Socket.h"

#ifdef WIN32 /* WINDOWS */

#  include <winsock.h>
#  include <io.h>
#  define SHUT_RDWR 2
#  include <stdlib.h>

typedef int socklen_t;

static bool StartupCalled = false;
static WSADATA wsaData;

extern "C" {
  static  void DoCleanup(void)
  {
    if (StartupCalled) WSACleanup();
    StartupCalled = false;
  }
}

static inline void DO_STARTUP()
{
  if (!StartupCalled) {
    if ( WSAStartup(1<<8|1, &wsaData) ) 
      throw SocketException("Could not start up winsock dll, WSAStartup() failed!");    
    ::atexit(DoCleanup);
    StartupCalled = true;
  }
}

static const char *WSAGetLastErrorMessage(const char *prefix = "", 
                                          int errorid = 0);

#  define LASTERROR_STR() WSAGetLastErrorMessage()
#  define LASTERROR_IS_CONNCLOSED() (WSAGetLastError() == WSAENETRESET || WSAGetLastError() == WSAECONNABORTED || WSAGetLastError() == WSAECONNRESET)

#else /* UNIX */

#  include <sys/socket.h>
#  include <netinet/in.h>
#  include <netinet/tcp.h>
#  include <arpa/inet.h>
#  include <netdb.h>
#  include <errno.h>
#  include <sys/select.h>
#  define LASTERROR_STR() std::strerror(errno)
#  define DO_STARTUP() do { } while (0)
#  define LASTERROR_IS_CONNCLOSED() (errno == ECONNRESET || errno == ENOTCONN || errno == EPIPE)

#endif /* WIN32 or UNIX */

#include <cstring>
#include <cstdlib>

Socket::Socket(int type)
  : m_sock(-1), m_type(type), m_host("localhost"), m_error("Success"), 
    m_port((unsigned short)-1), m_tcpNDelay(false), m_reuseAddr(true), 
    m_sendBuf(65536), m_recvBuf(65536), m_addr(0)
{
  DO_STARTUP();
  m_addr = new struct sockaddr_in;
  m_addr->sin_family = AF_INET;
}

Socket::~Socket()
{
  disconnect();
  delete m_addr;
  m_addr = 0;
}

void Socket::disconnect()
{
  if (isValid())  ::shutdown(m_sock, SHUT_RDWR);
  m_sock = -1;
}

bool Socket::isValid() const
{
  return m_sock > -1;
}

void Socket::setPort(unsigned short port)
{
  m_port = port;
}

void Socket::setHost(const std::string & h)
{
  m_host = h;
}

void Socket::setSocketOption(int option, int arg)
{
  switch(option) {
  case TCPNoDelay:
    m_tcpNDelay = arg ? true : false;
    if (isValid()) setTCPNDelay();
    break;
  case ReuseAddr:
    m_reuseAddr = arg ? true : false;
    if (isValid()) setReuseAddr();
    break;
  case SendBuf:
    m_sendBuf = arg >= 0 ? arg : m_sendBuf;
    if (isValid()) setSendBuf();
    break;
  case RecvBuf:
    m_recvBuf = arg >= 0 ? arg : m_recvBuf;
    if (isValid()) setRecvBuf();
    break;
  }
}

const std::string & Socket::host() const { return m_host; }
unsigned short Socket::port() const { return m_port; }

std::string Socket::errorReason() const
{
  return m_error;
}


bool Socket::connect(const std::string & host, unsigned short port)
{
  disconnect();

  if (host.length()) setHost(host);
  if (port) setPort(port);
  
  switch(m_type) {
  case UDP:
    m_sock = ::socket(PF_INET, SOCK_DGRAM, IPPROTO_IP);
    break;
  default:
    m_sock = ::socket(PF_INET, SOCK_STREAM, IPPROTO_IP);
    break;
  }
  if (m_sock < 0) {
    m_error = LASTERROR_STR();
    return false;
  }

  setSendBuf();
  setRecvBuf();

  if (m_type == TCP) {
    setTCPNDelay();    
    resolveHostAddr();
    if ( ::connect(m_sock, reinterpret_cast<struct sockaddr *>(m_addr), sizeof(*m_addr)) ) {
      m_error = LASTERROR_STR();
      ::close(m_sock);
      m_sock = -1;
      return false;
    }
  }

  return true;
}

/* virtual */
unsigned Socket::sendData(const void *d, unsigned dataSize) throw(const SocketException &)
{
  int count = 0;

  // TODO: non-blocking IO here?

  if (m_type == UDP) {
    // Datagram/UDP
    resolveHostAddr();
    count = ::sendto(m_sock, static_cast<const char *>(d), dataSize, 0, reinterpret_cast<struct sockaddr *>(m_addr), sizeof(*m_addr));
  } else {
    // Stream/TCP
    count = ::send(m_sock, static_cast<const char *>(d), dataSize, 0);
  }
  

  if (count < 0) {
    if (LASTERROR_IS_CONNCLOSED())  throw ConnectionClosed();
    /* else.. */
    m_error = LASTERROR_STR();
    throw SocketException(m_error);
  } else if (count == 0 && dataSize > 0) {
    throw ConnectionClosed(std::string("EOF on socket to ") + m_host);
  }
  return count;
}

/* virtual */
unsigned Socket::receiveData(void *buf, unsigned bufSize) throw(const SocketException &)
{
  int count = 0;
    
  // TODO: non-blocking IO here!?

  if (m_type == UDP) {
    // Datagram/UDP
    resolveHostAddr();
    socklen_t fromlen = sizeof(*m_addr);
    count = ::recvfrom(m_sock, static_cast<char *>(buf), bufSize, 0, reinterpret_cast<struct sockaddr *>(m_addr), &fromlen);
  } else {
    // Stream/TCP
    count = ::recv(m_sock, static_cast<char *>(buf), bufSize, 0);
  }
  
  if (count < 0) {
    if (LASTERROR_IS_CONNCLOSED())  throw ConnectionClosed();
    /* else.. */
    m_error = LASTERROR_STR();
    throw SocketException(m_error);
  } else if (count == 0 && bufSize > 0) {
    throw ConnectionClosed(std::string("EOF on socket to ") + m_host);
  }
  return count;
}

void Socket::resolveHostAddr() 
{
  resolveHostAddr(*m_addr, m_host, m_port);
}

void Socket::resolveHostAddr(struct sockaddr_in & addr, 
                             const std::string & host, 
                             unsigned short port) 
{
  struct hostent *he = gethostbyname(host.c_str());
  if (!he) 
    throw HostNotFound(host + " is not found by the resolver (" + LASTERROR_STR() + ").");

  ::memcpy(&addr.sin_addr.s_addr, he->h_addr, sizeof(addr.sin_addr.s_addr));
  addr.sin_port = htons(port);
  addr.sin_family = AF_INET;
}

void Socket::setTCPNDelay() const
{
#ifdef WIN32
  BOOL flag = m_tcpNDelay;
  int ret = ::setsockopt(m_sock, IPPROTO_TCP, TCP_NODELAY, reinterpret_cast<char *>(&flag), sizeof(flag));
#else
  long flag = m_tcpNDelay;
  int ret = ::setsockopt(m_sock, SOL_SOCKET, TCP_NODELAY, &flag, sizeof(flag));
#endif
  if (ret != 0) throw SocketException("Could not set TCP No Delay!");
}

void Socket::setReuseAddr() const
{
#ifdef WIN32
  BOOL flag = m_reuseAddr;
  int ret = ::setsockopt(m_sock, SOL_SOCKET , SO_REUSEADDR, reinterpret_cast<char *>(&flag), sizeof(flag));
#else
  long flag = m_reuseAddr;
  int ret = ::setsockopt(m_sock, SOL_SOCKET, SO_REUSEADDR, &flag, sizeof(flag));
#endif
  if (ret != 0) throw SocketException("Could not set SO_REUSEADDR!");
}

void Socket::setSendBuf() const
{
#ifdef WIN32
  int arg = m_sendBuf;
  int ret = ::setsockopt(m_sock, SOL_SOCKET, SO_SNDBUF, reinterpret_cast<char *>(&arg), sizeof(arg));
#else
  long arg = m_sendBuf;
  int ret = ::setsockopt(m_sock, SOL_SOCKET, SO_SNDBUF, &arg, sizeof(arg));
#endif
  if (ret != 0) throw SocketException("Could not set TCP Send Buf!");
}

void Socket::setRecvBuf() const
{
#ifdef WIN32
  int arg = m_recvBuf;
  int ret = ::setsockopt(m_sock, SOL_SOCKET, SO_RCVBUF, reinterpret_cast<char *>(&arg), sizeof(arg));
#else
  long arg = m_recvBuf;
  int ret = ::setsockopt(m_sock, SOL_SOCKET, SO_RCVBUF, &arg, sizeof(arg));
#endif
  if (ret != 0) throw SocketException("Could not set TCP Recv Buf!");
}

bool Socket::bind(const std::string & iface /*= "0.0.0.0"*/, unsigned short port/* = 0*/)
{
  setReuseAddr();

  struct sockaddr_in addr;
  addr.sin_addr.s_addr = inet_addr(iface.c_str());
  addr.sin_port = htons(port);
  addr.sin_family = AF_INET;
  if ( ::bind(m_sock, reinterpret_cast<struct sockaddr *>(&addr), sizeof(addr)) != 0 ) {
    m_error = LASTERROR_STR();
    return false;
  }
  return true;
}

bool Socket::hasData(unsigned waitMS)
{
  if (!isValid()) return false;
  struct timeval tv;
  tv.tv_sec = 0;
  tv.tv_usec = 1000*waitMS;
  fd_set readfds;
  FD_ZERO(&readfds);
  FD_SET(m_sock, &readfds);
  return select(m_sock+1, &readfds, 0, 0, &tv) > 0;
}

#ifdef WIN32

//// Statics ///////////////////////////////////////////////////////////

// List of Winsock error constants mapped to an interpretation string.
// Note that this list must remain sorted by the error constants'
// values, because we do a binary search on the list when looking up
// items.
static struct ErrorEntry {
    int nID;
    const char* pcMessage;

  ErrorEntry(int id, const char* pc = 0) :  nID(id),  pcMessage(pc)  {}

  bool operator<(const ErrorEntry& rhs)  {  return nID < rhs.nID;  }
} gaErrorList[] = {
    ErrorEntry(0,                  "No error"),
    ErrorEntry(WSAEINTR,           "Interrupted system call"),
    ErrorEntry(WSAEBADF,           "Bad file number"),
    ErrorEntry(WSAEACCES,          "Permission denied"),
    ErrorEntry(WSAEFAULT,          "Bad address"),
    ErrorEntry(WSAEINVAL,          "Invalid argument"),
    ErrorEntry(WSAEMFILE,          "Too many open sockets"),
    ErrorEntry(WSAEWOULDBLOCK,     "Operation would block"),
    ErrorEntry(WSAEINPROGRESS,     "Operation now in progress"),
    ErrorEntry(WSAEALREADY,        "Operation already in progress"),
    ErrorEntry(WSAENOTSOCK,        "Socket operation on non-socket"),
    ErrorEntry(WSAEDESTADDRREQ,    "Destination address required"),
    ErrorEntry(WSAEMSGSIZE,        "Message too long"),
    ErrorEntry(WSAEPROTOTYPE,      "Protocol wrong type for socket"),
    ErrorEntry(WSAENOPROTOOPT,     "Bad protocol option"),
    ErrorEntry(WSAEPROTONOSUPPORT, "Protocol not supported"),
    ErrorEntry(WSAESOCKTNOSUPPORT, "Socket type not supported"),
    ErrorEntry(WSAEOPNOTSUPP,      "Operation not supported on socket"),
    ErrorEntry(WSAEPFNOSUPPORT,    "Protocol family not supported"),
    ErrorEntry(WSAEAFNOSUPPORT,    "Address family not supported"),
    ErrorEntry(WSAEADDRINUSE,      "Address already in use"),
    ErrorEntry(WSAEADDRNOTAVAIL,   "Can't assign requested address"),
    ErrorEntry(WSAENETDOWN,        "Network is down"),
    ErrorEntry(WSAENETUNREACH,     "Network is unreachable"),
    ErrorEntry(WSAENETRESET,       "Net connection reset"),
    ErrorEntry(WSAECONNABORTED,    "Software caused connection abort"),
    ErrorEntry(WSAECONNRESET,      "Connection reset by peer"),
    ErrorEntry(WSAENOBUFS,         "No buffer space available"),
    ErrorEntry(WSAEISCONN,         "Socket is already connected"),
    ErrorEntry(WSAENOTCONN,        "Socket is not connected"),
    ErrorEntry(WSAESHUTDOWN,       "Can't send after socket shutdown"),
    ErrorEntry(WSAETOOMANYREFS,    "Too many references, can't splice"),
    ErrorEntry(WSAETIMEDOUT,       "Connection timed out"),
    ErrorEntry(WSAECONNREFUSED,    "Connection refused"),
    ErrorEntry(WSAELOOP,           "Too many levels of symbolic links"),
    ErrorEntry(WSAENAMETOOLONG,    "File name too long"),
    ErrorEntry(WSAEHOSTDOWN,       "Host is down"),
    ErrorEntry(WSAEHOSTUNREACH,    "No route to host"),
    ErrorEntry(WSAENOTEMPTY,       "Directory not empty"),
    ErrorEntry(WSAEPROCLIM,        "Too many processes"),
    ErrorEntry(WSAEUSERS,          "Too many users"),
    ErrorEntry(WSAEDQUOT,          "Disc quota exceeded"),
    ErrorEntry(WSAESTALE,          "Stale NFS file handle"),
    ErrorEntry(WSAEREMOTE,         "Too many levels of remote in path"),
    ErrorEntry(WSASYSNOTREADY,     "Network system is unavailable"),
    ErrorEntry(WSAVERNOTSUPPORTED, "Winsock version out of range"),
    ErrorEntry(WSANOTINITIALISED,  "WSAStartup not yet called"),
    ErrorEntry(WSAEDISCON,         "Graceful shutdown in progress"),
    ErrorEntry(WSAHOST_NOT_FOUND,  "Host not found"),
    ErrorEntry(WSANO_DATA,         "No host data of that type was found")
};

static const int kNumMessages = sizeof(gaErrorList) / sizeof(ErrorEntry);

//// WSAGetLastErrorMessage ////////////////////////////////////////////
// A function similar in spirit to Unix's perror() that tacks a canned 
// interpretation of the value of WSAGetLastError() onto the end of a
// passed string, separated by a ": ".  Generally, you should implement
// smarter error handling than this, but for default cases and simple
// programs, this function is sufficient.
//
// This function returns a pointer to an internal static buffer, so you
// must copy the data from this function before you call it again.  It
// follows that this function is also not thread-safe.
#include <strstream>
#include <algorithm>
const char* WSAGetLastErrorMessage( const char* pcMessagePrefix /* = 0 */,
                                    int nErrorID /* = 0 */)
{
    // Build basic error string
    static char acErrorBuffer[256];
    std::ostrstream outs(acErrorBuffer, sizeof(acErrorBuffer));
    if (pcMessagePrefix && *pcMessagePrefix)
      outs << pcMessagePrefix << ": ";

    // Tack appropriate canned message onto end of supplied message 
    // prefix. Note that we do a binary search here: gaErrorList must be
	// sorted by the error constant's value.
	ErrorEntry* pEnd = gaErrorList + kNumMessages;
    ErrorEntry Target(nErrorID ? nErrorID : WSAGetLastError());
    ErrorEntry* it = std::lower_bound(gaErrorList, pEnd, Target);
    if ((it != pEnd) && (it->nID == Target.nID)) {
        outs << it->pcMessage;
    }
    else {
        // Didn't find error in list, so make up a generic one
        outs << "unknown error";
    }
    outs << " (" << Target.nID << ")";

    // Finish error message off and return it.
    outs << std::ends;
    acErrorBuffer[sizeof(acErrorBuffer) - 1] = '\0';
    return acErrorBuffer;
}



#endif
