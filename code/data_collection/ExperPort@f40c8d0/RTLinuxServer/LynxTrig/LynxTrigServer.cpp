#include "LynxTrig.h"
#include "rtos_utility.h"

#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/time.h>
#include <string.h>
#include <errno.h>
#include <netinet/in.h>
#include <netinet/ip.h> /* superset of previous */
#include <netinet/tcp.h> 
#include <signal.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <ctype.h>

#include <cstdlib>
#include <iostream>
#include <sstream>
#include <string>
#include <cstring>
#include <list>
#include <map>
#include <vector>
#include <memory>

class ConnectedProcess;

volatile struct Shm *shm = 0;
int fifo_in[MAX_CARDS], fifo_out[MAX_CARDS];
int listen_fd = -1; /* Our listen socket.. */
unsigned short listenPort = 3334;

typedef std::list<ConnectedProcess> ChildProcs;
ChildProcs *childProcs = 0;

static std::ostream & log(int ignored = 0)
{
  (void)ignored;
  return std::cerr;
}

struct Matrix;
struct SoundBuffer;

class ConnectedProcess
{
public:
  ConnectedProcess();
  ~ConnectedProcess();

  pid_t start(int socket_fd, const std::string & remoteHost = "unknown");
  void stop();
  pid_t pid() const { return myid; }

private:
  int sock, myid, mycard;
  bool running;
  std::string remoteHost;

  std::ostream &log(int i = -1) 
  { 
    if (i == 0) return ::log(i); // unlock, so don't output anything extra...
    return ::log(i) << "[Process " << myid << " (" << remoteHost << ")] "; 
  }

  int doConnection();

  // Functions to send commands to the realtime process via the rt-fifos
  void sendToRT(FifoMsgID cmd); // send a simple command, one of RESET, PAUSEUNPAUSE, INVALIDATE. Upon return we know the command completed.
  void sendToRT(FifoMsg & msg); // send a complex command, wait for a reply which gets put back into 'msg'.  Upon return we know the command completed.
  int sockSend(const std::string & str) ;
  int sockSend(const void *buf, size_t len, bool is_binary = false, int flags = 0);
  int sockReceiveData(void *buf, int size, bool is_binary = true);
  std::string sockReceiveLine();
  bool uploadSound(const SoundBuffer & m);

};

ConnectedProcess::ConnectedProcess() : sock(-1), myid(0), mycard(0), running(false), remoteHost("Unknown") {}
ConnectedProcess::~ConnectedProcess()
{ 
  if (running) {
  	stop();	
  	log(1) <<  "deleted." << std::endl;
  	log(0);
    running = false;
  }
}

void ConnectedProcess::stop()
{
  if (sock > -1)  ::shutdown(sock, SHUT_RDWR), ::close(sock), sock = -1;
  if (pid() > 0) ::kill(pid(), SIGKILL);  
}

pid_t ConnectedProcess::start(int sock_fd, const std::string & rhost)
{
  sock = sock_fd;  
  remoteHost = rhost;
  pid_t ret = ::fork();
  if (ret > -1) running = true, myid = ret;
  if (ret == 0) {
    // child
    myid = ::getpid();


    // install our default signal handlers
    ::signal(SIGINT, 0);
    ::signal(SIGQUIT, 0);
    ::signal(SIGHUP, 0);
    ::signal(SIGTERM, 0);
    ::signal(SIGCHLD, 0);

    int ret = doConnection();
    std::exit(ret);
  }
  return ret;
}

/* NOTE that all functions in this program have the potential to throw
 * Exception on failure (which is why they seem not to haev error status return values) */
class Exception
{
public:
  Exception(const std::string & reason = "") : reason(reason) {}
  virtual ~Exception() {}

  const std::string & why() const { return reason; }

private:
  std::string reason;
};

static unsigned nCards()
{
  if (shm) return shm->num_cards;
  return 0;
}

static void attachShm()
{
  // first, connect to the shm buffer..
  RTOS::ShmStatus shmStatus;
  void *shm_notype = RTOS::shmAttach(SHM_NAME, SHM_SIZE, &shmStatus);

  if (!shm_notype)
    throw Exception(std::string("Cannot connect to ") + SHM_NAME
                    + ", error was: " + RTOS::statusString(shmStatus));
  shm = const_cast<volatile Shm *>(static_cast<Shm *>(shm_notype));

  if (shm->magic != SHM_MAGIC) {
    std::stringstream s;
    s << "Attached to shared memory buffer at " << shm_notype << " but the magic number is invaid! (" << reinterpret_cast<void *>(shm->magic) << " != " << reinterpret_cast<void *>(SHM_MAGIC) << ")\n";
    s << "Shm Dump:\n";
    char *ptr = reinterpret_cast<char *>(shm_notype);
    for (unsigned i = 0; i < 16; ++i) {
      s << reinterpret_cast<void *>(ptr[i]) << " ";
      if (i && !(i%30)) s << "\n";
    }
    s << "\n";
    throw Exception(s.str());
  }
}

static void openFifos()
{
  /* first clear the fifos fd's.. */
  memset(fifo_in, -1, sizeof(fifo_in));
  memset(fifo_out, -1, sizeof(fifo_out));

  for (unsigned i = 0; i < shm->num_cards; ++i) {
    fifo_in[i] = RTOS::openFifo(shm->fifo_out[i]);
    if (fifo_in[i] < 0) throw Exception ("Could not open RTF fifo_in for reading");
    fifo_out[i] = RTOS::openFifo(shm->fifo_in[i], RTOS::Write);
    if (fifo_out[i] < 0) throw Exception ("Could not open RTF fifo_in for writing");
  }
}

static void init()
{
    attachShm();
    openFifos();
    //sendToRT(RESET);
}

static void cleanup(void)
{
  for (unsigned i = 0; i < shm->num_cards; ++i) {
    if (fifo_in[i] >= 0) ::close(fifo_in[i]); fifo_in[i] = -1;
    if (fifo_out[i] >= 0) ::close(fifo_out[i]); fifo_out[i] = -1;
  }
  if (shm) { RTOS::shmDetach((void *)shm); shm = 0; }
  if (listen_fd >= 0) ::close(listen_fd);
  listen_fd = -1;
  if (childProcs) { childProcs->clear(); delete childProcs; childProcs = 0; }
}


static void handleArgs(int argc, const char *argv[])
{
    if (argc == 2) {
      // listenport override
      listenPort = atoi(argv[1]);
      if (! listenPort) throw Exception ("Could not parse listen port.");
    } else if (argc != 1) {
      throw Exception(std::string("Unknown command line parameters.  Usage: ")
                      + argv[0] + " [listenPort]"); 
      
    }
}

struct WaitPIDNoError // Unary Functor, returns true if a waidpid with WNOHANG was successful for pid
{
  bool operator()(const ConnectedProcess & proc) const {    
    if (proc.pid() <= 0) return false;
    int status, retval = ::waitpid(proc.pid(), &status, WNOHANG);
    return retval > 0;
  }
};

extern "C" void sighandler(int sig)
{
  
  switch (sig) {

  case SIGPIPE: 
    //std::cerr << "PID " << ::getpid() << " GOT SIGPIPE" << std::endl;
    break; // ignore SIGPIPE..

  case SIGCHLD: 
    // reap dead children...
    if (childProcs) childProcs->remove_if(WaitPIDNoError());
    break;

  default:
    log() << "Caught signal " << sig << " cleaning up..." << std::endl;     
    cleanup();    
    std::exit(1);
    break;
  }
}

struct Matrix
{
public:
  Matrix(int m, int n) : m(m), n(n) { d = new double[m*n]; }
  ~Matrix() { delete [] d; }
  double & at(int r, int c, bool = false)  { return *const_cast<double *>(d + c*m + r); }
  const double & at(int r, int c) const { return const_cast<Matrix *>(this)->at(r,c, true); }
  int rows() const { return m; }
  int cols() const { return n; }
  unsigned bufSize() const { return sizeof(*d)*m*n; }
  void * buf() const { return static_cast<void *>(const_cast<Matrix *>(this)->d); }
private:
  double *d;
  int m, n;
};

struct SoundBuffer : public std::vector<char>
{
  SoundBuffer(unsigned long size,
              int id, int n_chans, int sample_size, int rate, int stop_ramp_tau_ms = 0, int loop_flg = 0) 
    : std::vector<char>(size),
      id(id), chans(n_chans), sample_size(sample_size), rate(rate), stop_ramp_tau_ms(stop_ramp_tau_ms), loop_flg(loop_flg)
  { resize(size); }
  int id, chans, sample_size, rate, stop_ramp_tau_ms, loop_flg;
};

class Timer
{
public:
  Timer() { reset(); }
  void reset();
  double elapsed() const; // returns number of seconds since ctor or reset() was called 
private:
  struct timeval ts;
};

void Timer::reset()
{
  ::gettimeofday(&ts, NULL);
}

double Timer::elapsed() const
{
  if (ts.tv_sec == 0) return 0.0;
  struct timeval tv;
  ::gettimeofday(&tv, NULL);
  return tv.tv_sec - ts.tv_sec + (tv.tv_usec - ts.tv_usec)/1000000.0;
}

void doServer(void)
{
  //do the server listen, etc..
    
  listen_fd = ::socket(PF_INET, SOCK_STREAM, 0);

  if (listen_fd < 0) 
    throw Exception(std::string("socket: ") + strerror(errno));

  struct sockaddr_in inaddr;
  socklen_t addr_sz = sizeof(inaddr);
  inaddr.sin_family = AF_INET;
  inaddr.sin_port = htons(listenPort);
  inet_aton("0.0.0.0", &inaddr.sin_addr);

  log() << "Listening for connections on port: " << listenPort << std::endl; 

  int parm = 1;
  if (::setsockopt(listen_fd, SOL_SOCKET, SO_REUSEADDR, &parm, sizeof(parm)) )
    log() << "Error: setsockopt returned " << ::strerror(errno) << std::endl; 
  
  if ( ::bind(listen_fd, (struct sockaddr *)&inaddr, addr_sz) != 0 ) 
    throw Exception(std::string("bind: ") + strerror(errno));
  
  if ( ::listen(listen_fd, 1) != 0 ) 
    throw Exception(std::string("listen: ") + strerror(errno));

  childProcs = new ChildProcs;

  while (1) {
    int sock;
    if ( (sock = ::accept(listen_fd, (struct sockaddr *)&inaddr, &addr_sz)) < 0 ) 
      throw Exception(std::string("accept: ") + strerror(errno));

    if (::setsockopt(sock, IPPROTO_TCP, TCP_NODELAY, &parm, sizeof(parm)) )
      log() << "Error: setsockopt returned " << ::strerror(errno) << std::endl; 
    
    childProcs->push_back(ConnectedProcess());
    ConnectedProcess & conn = childProcs->back();
    if ( conn.start(sock, inet_ntoa(inaddr.sin_addr)) > 0 ) {
      log(1) << "Started new process, now have " << childProcs->size() << " total." 
             << std::endl; log(0);
    } else {
      childProcs->pop_back();
    }
  }
}

int main(int argc, const char *argv[]) 
{
  int ret = 0;

  // install our signal handler that tries to pause the rt-process and quit the program 
  signal(SIGINT, sighandler);
  signal(SIGPIPE, sighandler);
  signal(SIGQUIT, sighandler);
  signal(SIGHUP, sighandler);
  signal(SIGTERM, sighandler);
  signal(SIGCHLD, sighandler);

  try {
  
    init();

    handleArgs(argc, argv);
  
    // keeps listening on a port, waiting for commands to give to the rt-proc
    doServer();    

  } catch (const Exception & e) {

    log(1) << e.why() << std::endl; log(0);
    ret = 1;

  }

  cleanup();

  return ret;
}

int ConnectedProcess::doConnection(void)
{
    Timer connectionTimer;

    log(1) << "Connection received from host " << remoteHost << std::endl; log(0);
   
    std::string line;
    int count;

    while ( (line = sockReceiveLine()).length() > 0) {
      
      bool cmd_error = true;

      if (line.find("SET SOUND") == 0) {
        /* Sound Upload.. */
        
        // determine bytes chans samplesize(in bytes) rate 
        
        std::string::size_type pos = line.find_first_of("0123456789");
        int id = 0, bytes = 0, chans = 0, samplesize = 0, rate = 0, stop_ramp_tau_ms = 0, loop = 0;
        double bytes_dbl = 0.0, rate_dbl = 0.0;

        if (pos != std::string::npos) {
          std::stringstream s(line.substr(pos));
          s >> id >> bytes_dbl >> chans >> samplesize >> rate_dbl >> stop_ramp_tau_ms >> loop;
          bytes = static_cast<int>(bytes_dbl);
          rate = static_cast<int>(rate_dbl);
          if (id && bytes && chans && samplesize && rate) {
            if ( (count = sockSend("READY\n")) <= 0 ) {
              log(1) << "Send error..." << std::endl; log(0);
              break;
            }
            if (bytes > (128*1024*1024) && (bytes = (128*1024*1024)) )
              log(1) << "Warning soundfile of " << bytes << " truncated to 128MB!" << std::endl; log(0);

            SoundBuffer sound(bytes, id, chans, samplesize, rate, stop_ramp_tau_ms, loop);

            log(1) << "Getting ready to receive sound  " << sound.id << " length " << sound.size() << std::endl; log(0);
            Timer xferTimer;
            count = sockReceiveData(&sound[0], sound.size());	    
            double xt = xferTimer.elapsed();
            if (count == (int)sound.size()) {
              log(1) << "Received " << count << " bytes in " << xt << " seconds (" << ((count*8)/1e6)/xt << " mbit/s)" << std::endl; log(0);
              cmd_error = !uploadSound(sound);
            } else if (count <= 0) {
              break;
            }
          }
        }
      } else if (line.find("INITIALIZE") == 0) {
        sendToRT(RESET);
        cmd_error = false;
      } else if (line.find("HALT") == 0) {
        std::auto_ptr<FifoMsg> msg(new FifoMsg);
        msg->id = GETPAUSE;
        sendToRT(*msg);
        if ( ! msg->u.is_paused ) 
          sendToRT(PAUSEUNPAUSE);
        cmd_error = false;
      } else if (line.find("RUN") == 0) {
        std::auto_ptr<FifoMsg> msg(new FifoMsg);
        msg->id = GETPAUSE;
        sendToRT(*msg);
        if ( msg->u.is_paused ) 
          sendToRT(PAUSEUNPAUSE);
        cmd_error = false;        
      } else if (line.find("TRIGGER") == 0 ) { 
        int trigmask = 0;
        std::string::size_type pos = line.find_first_of("0123456789-");
        if (pos != std::string::npos) {
          std::stringstream s(line.substr(pos));
          s >> trigmask;
          std::auto_ptr<FifoMsg> msg(new FifoMsg);
          msg->id = FORCEEVENT;
          msg->u.forced_event = trigmask;
          sendToRT(*msg);
          cmd_error = false;
        }
      } else if (line.find("IS RUNNING") == 0) {
        std::auto_ptr<FifoMsg> msg(new FifoMsg);
        msg->id = GETPAUSE;
        sendToRT(*msg);
        std::stringstream s;
        s << !msg->u.is_paused << std::endl;
        sockSend(s.str());
        cmd_error = false;
      } else if (line.find("GET TIME") == 0) {
        std::auto_ptr<FifoMsg> msg(new FifoMsg);
        msg->id = GETRUNTIME;
        sendToRT(*msg);
        std::stringstream s;
        s << static_cast<double>(msg->u.runtime_us)/1000000.0 << std::endl;
        sockSend(s.str());
        cmd_error = false;        
      } else if (line.find("GET LAST EVENT") == 0) {
        std::auto_ptr<FifoMsg> msg(new FifoMsg);
        msg->id = GETLASTEVENT;
        sendToRT(*msg);
        std::stringstream s;
        s << msg->u.last_event << std::endl;
        sockSend(s.str());
        cmd_error = false;        
      } else if (line.find("GET NCARDS") == 0) {
        std::stringstream s;
        s << nCards() << std::endl;
        sockSend(s.str());
        cmd_error = false;        
      } else if (line.find("GET CARD") == 0) {
        std::stringstream s;
        s << mycard << std::endl;
        sockSend(s.str());
        cmd_error = false;        
      } else if (line.find("SET CARD") == 0) {
        std::string::size_type pos = line.find_first_of("0123456789");
        if (pos != std::string::npos) {
          int c = -1;
          std::stringstream s(line.substr(pos));
          s >> c;
          if (c >= 0) {
            mycard = c;
            cmd_error = false;
          }
        }
      } else if ( line.find("EXIT") == 0 || line.find("BYE") == 0 || line.find("QUIT") == 0) {
        log(1) << "Graceful exit requested." << std::endl; log(0);
        break;
      } else if (line.find("NOOP") == 0) {
        // noop is just used to test the connection, keep it alive, etc
        // it doesn't touch the shm...
        cmd_error = false;        
      }

      if (cmd_error) {
        const char *s = "ERROR\n";
        sockSend(s, std::strlen(s)); 
      } else {
        const char *s = "OK\n";
        sockSend(s, std::strlen(s)); 
      }

    }
    
    log(1) << "Connection to host " << remoteHost << " ended after " << connectionTimer.elapsed() << " seconds." << std::endl; log(0);
    
    log(1) << " process exit." << std::endl; log(0);
    return 0;
}

void ConnectedProcess::sendToRT(FifoMsg & msg)
{
  // lock SHM here??

  std::memcpy(const_cast<FifoMsg *>(&shm->msg[mycard]), &msg, sizeof(FifoMsg));

  FifoNotify_t dummy = 1;    
    
  if ( ::write(fifo_out[mycard], &dummy, sizeof(dummy)) != sizeof(dummy) )
    throw Exception("INTERNAL ERROR: Could not write a complete message to the fifo!");
    
  int err; 
  // now wait synchronously for a reply from the rt-process.. 
  if ( (err = ::read(fifo_in[mycard], &dummy, sizeof(dummy))) == sizeof(dummy) ) { 
    /* copy the reply from the shm back to the user-supplied msg buffer.. */
    std::memcpy(&msg, const_cast<struct FifoMsg *>(&shm->msg[mycard]), sizeof(FifoMsg));
  } else if (err < 0) { 
    throw Exception(std::string("INTERNAL ERROR: Reading of input fifo got an error: ") + strerror(errno));
  } else {
    throw Exception("INTERNAL ERROR: Could not read a complete message from the fifo!");
  }

  // unlock SHM here??
}

void ConnectedProcess::sendToRT(FifoMsgID cmd)
{
  std::auto_ptr<FifoMsg> msg(new FifoMsg);

  switch (cmd) {
  case RESET:
  case PAUSEUNPAUSE:
  case INVALIDATE:
    msg->id = cmd;
    sendToRT(*msg);
    break;
  default:
    throw Exception("INTERNAL ERRROR: sendToRT(FifoMsgID) called with an inappropriate command ID!");
    break;
  }
}

int ConnectedProcess::sockSend(const std::string & str) 
{
  return sockSend(str.c_str(), str.length());
}

int ConnectedProcess::sockSend(const void *buf, size_t len, bool is_binary, int flags)
{
  const char *charbuf = static_cast<const char *>(buf);
  if (!is_binary) {
    std::stringstream ss;
    ss << "Sending: " << charbuf; 
    if (charbuf[len-1] != '\n') ss << std::endl;
    log(1) << ss.str() << std::flush;
  } else
    log(1) << "Sending binary data of length " << len << std::endl; log(0);  

  int ret = ::send(sock, buf, len, flags);
  if (ret < 0) {
    log(1) << "ERROR returned from send: " << strerror(errno) << std::endl; log(0);
  } else if (ret != (int)len) {
    log(1) << "::send() returned the wrong size; expected " << len << " got " << ret << std::endl; log(0);
  }
  return ret;
}

// Note: trims trailing whitespace!  If string is empty, connection error!
std::string ConnectedProcess::sockReceiveLine()
{
#define MAX_LINE 2048
  char buf[MAX_LINE] = { 0 };
  int ret, slen = 0;
  std::string rets = "";

  // keep looping until we fill the buffer, or we get a \n
  // eg: slen < MAXLINE and (if nread then buf[slen-1] must not equal \n)
  while ( slen < MAX_LINE && (!slen || buf[slen-1] != '\n') ) {
    ret = ::recv(sock, buf+slen, MAX_LINE-slen, 0);
    if (ret <= 0) break;
    slen += ret;
  }
  if (slen >= MAX_LINE) slen = MAX_LINE-1;
  if (slen) buf[slen] = 0; // add NUL
  // now, trim trailing spaces
  while(slen && ::isspace(buf[slen-1])) { buf[--slen] = 0; }
  rets = buf;
  log(1) << "Got: " << rets << std::endl; log(0);
  return rets;
}


int ConnectedProcess::sockReceiveData(void *buf, int size, bool is_binary)
{
  int nread = 0;

  while (nread < size) {
    int ret = ::recv(sock, (char *)(buf) + nread, size - nread, 0);
    
    if (ret < 0) {
      log(1) << "ERROR returned from recv: " << strerror(errno) << std::endl; log(0);
      return ret;
    } else if (ret == 0) {
      log(1) << "ERROR in recv, connection probably closed." << std::endl; log(0);
      return ret;
    } 
    nread += ret;
    if (!is_binary) break;
  }

  if (!is_binary) {
    char *charbuf = static_cast<char *>(buf);
    charbuf[size-1] = 0;
    log(1) << "Got: " << charbuf << std::endl; log(0);
  } else {
    log(1) << "Got: " << nread << " bytes." << std::endl; log(0);
    if (nread != size) {
      log(1) << "INFO ::recv() returned the wrong size; expected " << size << " got " << nread << std::endl; log(0);
    }
  }
  return nread;
}

bool ConnectedProcess::uploadSound(const SoundBuffer & s)
{
  log(1) << "Soundfile is: bytes: " << s.size() << " chans: " << s.chans << "  sample_size: " << s.sample_size << "  rate: " << s.rate << std::endl; log(0);

  std::auto_ptr<FifoMsg> msg(new FifoMsg);
  msg->id = SOUND;

  
  struct timeval tv;
  unsigned long long start, end;
  
  ::gettimeofday(&tv, 0);
  start = tv.tv_sec * 1000000 + tv.tv_usec;
  
  unsigned long sent = 0;
  while(sent < s.size()) {

    // setup matrix here..
    msg->u.sound.bits_per_sample = s.sample_size;
    msg->u.sound.id = s.id;
    msg->u.sound.chans = s.chans;
    msg->u.sound.rate = s.rate;
    msg->u.sound.total_size = s.size();
    msg->u.sound.stop_ramp_tau_ms = s.stop_ramp_tau_ms;
    msg->u.sound.is_looped = s.loop_flg;

    unsigned bytes = s.size() - sent;
    msg->u.sound.append = sent ? 1 : 0;
    if (bytes > MSG_SND_SZ) bytes = MSG_SND_SZ;
    msg->u.sound.size = bytes;
    memcpy(msg->u.sound.snd, &s[0] + sent, bytes);

    sendToRT(*msg);

    // todo: check msg->u.transfer_ok and report errors..
    if (!msg->u.sound.transfer_ok) return false;

    sent += bytes;
  }

  ::gettimeofday(&tv, 0);
  end = tv.tv_sec * 1000000 + tv.tv_usec;

  log(1) << "Sent sound to kernel in " << (static_cast<unsigned long>(end-start)/1000) << " millisecs." << std::endl; log(0);

  return true;
}

