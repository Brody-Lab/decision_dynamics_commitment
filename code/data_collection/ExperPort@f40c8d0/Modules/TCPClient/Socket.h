#ifndef SOCKET_H
#define SOCKET_H

#include <string>

struct sockaddr_in;

class SocketException
{
 public:
  SocketException(const std::string & reason = "") : reason(reason) {}
  std::string why() const { return reason; }

 private:
  std::string reason;
};

class ConnectionClosed : public SocketException
{
public:
  ConnectionClosed(const std::string & reason = "Connection closed by peer.") : SocketException(reason) {}
};

class HostNotFound : public SocketException
{
public:
  HostNotFound(const std::string & reason = "Host not found.") : SocketException(reason) {}
};

/** NB: UDP is untested and probably doesn't work */
class Socket
{
public:
  enum SocketType { TCP, UDP };
  enum SocketOption { TCPNoDelay, ReuseAddr };

  typedef int Sock_t;
  
  Socket(int = TCP);
  virtual ~Socket();

  bool bind(const std::string & iface = "0.0.0.0", unsigned short port = 0);

  void setSocketOption(int option, bool enable);

  void setPort(unsigned short port);
  void setHost(const std::string & host);  
  const std::string & host() const;
  unsigned short port() const;

  bool isValid() const;

  // the below two only appy to TCP sockets
  bool connect(const std::string & host = "", unsigned short port = 0);  
  void disconnect();

  // if connect fails above, errorReason can give a descriptive string
  std::string errorReason() const;


  virtual unsigned sendData(const void *d, unsigned dataSize) throw(const SocketException &);
  virtual unsigned receiveData(void *buf, unsigned bufSize) throw(const SocketException &);
  
protected:
  bool hasData(unsigned waitMS = 10);

private:
  Sock_t m_sock;
  int m_type;
  std::string m_host, m_error;
  unsigned short m_port;
  bool m_tcpNDelay, m_reuseAddr;

  struct sockaddr_in *m_addr;
  void resolveHostAddr();
  static void resolveHostAddr(struct sockaddr_in &, const std::string &, unsigned short);
  void setTCPNDelay() const;
  void setReuseAddr() const;

};

#endif
