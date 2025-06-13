#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif
#ifndef _REENTRANT
#define _REENTRANT
#endif
#include "RatExpFSM.h"
#include "rtos_utility.h"

#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/ioctl.h>
#include <string.h>
#include <errno.h>
#include <netinet/in.h>
#include <netinet/ip.h> /* superset of previous */
#include <netinet/tcp.h> 
#include <netdb.h> /* for gethostbyname, etc */
#include <signal.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <ctype.h>
#include <pthread.h>
#include <limits.h>

#include <cstdlib>
#include <iostream>
#include <iomanip>
#include <sstream>
#include <string>
#include <cstring>
#include <list>
#include <map>
#include <vector>
#include <memory>

#define MIN(a,b) ( (a) < (b) ? (a) : (b) )

class ConnectionThread;

template <class T> struct CircBuf
{
  CircBuf(size_t n_elems) : n(n_elems ? n_elems : 1), ct(0) { buf.resize(n_elems); }
  ~CircBuf() { buf.clear(); }
  T & operator[](unsigned long long i) { return buf[(unsigned)(i%n)]; }
  void push(const T & t) { (*this)[ct++] = t;  }
  // use this to increment counter with the data already in the buf
  void push() { ct++; }
  T & next() { return (*this)[count()]; }
  unsigned long long count() const { return ct; }
  unsigned long countNormalized() const { return ct > n ? ct%n : ct; }
  size_t size() const { return n; }
  void clear() { ct = 0; }
private:
  std::vector<T> buf;
  size_t n;
  unsigned long long ct;
};

namespace 
{ // anonymous namespaced globales
  volatile struct Shm *shm = 0;
  int listen_fd = -1; /* Our listen socket.. */
  unsigned short listenPort = 3333;
  typedef std::map<ConnectionThread *, ConnectionThread *> ConnectedThreadsList;
  unsigned n_threads;
  ConnectedThreadsList connectedThreads;
  pthread_mutex_t connectedThreadsLock = PTHREAD_MUTEX_INITIALIZER;

  std::string UrlEncode(const std::string &);
  std::string UrlDecode(const std::string &);
  std::string FormatPacketText(const std::string &, const NRTOutput *);
};  

struct DAQScanVec : public DAQScan
{
  std::vector<double> samples;
    
  void assign(const DAQScan *ds, unsigned maxData, double rangeMin, double rangeMax) { 
    static_cast<DAQScan &>(*this) = *ds; 
    samples.resize(nsamps);
    for (unsigned i = 0; i < nsamps; ++i)
      samples[i] = (ds->samps[i]/double(maxData) * (rangeMax-rangeMin)) + rangeMin;
  }
};

struct MutexLocker
{
  MutexLocker(pthread_mutex_t *m) : mut(*m) { pthread_mutex_lock(&mut); }
  MutexLocker(pthread_mutex_t  & m) : mut(m) { pthread_mutex_lock(&mut); }
  ~MutexLocker() { pthread_mutex_unlock(&mut); }
  pthread_mutex_t & mut;
};


struct Matrix;

struct FSMSpecific
{
  FSMSpecific() 
    : fifo_in(-1), fifo_out(-1), fifo_trans(-1), fifo_daq(-1), fifo_nrt_output(-1),
    transBuf(2048), // store 2048 strate transitions in memory from transNotify thread
      daqBuf(128*2048), // store 128000 scans in memory from daq thread
      transNotifyThread(0), daqReadThread(0),
      daqNumChans(0), daqMaxData(1), aoMaxData(1),
      daqRangeMin(0.), daqRangeMax(5.)
  {
    pthread_mutex_init(&msgFifoLock, 0);
    pthread_mutex_init(&transNotifyLock, 0);
    pthread_mutex_init(&daqLock, 0);
    pthread_cond_init(&transNotifyCond, 0);
  }
  ~FSMSpecific() 
  {
    pthread_cond_destroy(&transNotifyCond);
    pthread_mutex_destroy(&transNotifyLock);
    pthread_mutex_destroy(&daqLock);
    pthread_mutex_destroy(&msgFifoLock);
  }

  Matrix getDAQScans(); /**< returns an MxN matrix, where each row is a scan 
                           ideal for sending to Matlab.. */


  volatile int fifo_in, fifo_out, fifo_trans, fifo_daq, fifo_nrt_output;
  pthread_mutex_t msgFifoLock, transNotifyLock, daqLock;
  pthread_cond_t transNotifyCond;
  CircBuf<StateTransition> transBuf;
  CircBuf<DAQScanVec> daqBuf;
  pthread_t transNotifyThread, daqReadThread, nrtReadThread;
  unsigned daqNumChans, daqMaxData, aoMaxData;
  double daqRangeMin, daqRangeMax;

  void *transNotifyThrFun();
  void *daqThrFun();
  void *nrtThrFun();
  void doNRT_IP(const NRTOutput *, bool isUDP) const;
};

static void *transNotifyThrWrapper(void *);
static void *daqThrWrapper(void *);
static void *nrtThrWrapper(void *);
  
static FSMSpecific fsms[NUM_STATE_MACHINES];

static std::vector<double> splitNumericString(const std::string & str,
                                              const std::string &delims = ",");
  
static std::ostream *logstream = 0; // in case we want to log stuff later..

static std::ostream & log(int lock_unlock = -1)
{
  static pthread_mutex_t mut = PTHREAD_MUTEX_INITIALIZER;
  std::ostream *ret;
  if (logstream)
    ret = logstream;
  else 
    ret = &std::cerr;
    
  if (lock_unlock > -1) {
    if (lock_unlock == 1) pthread_mutex_lock(&mut);
    else pthread_mutex_unlock(&mut);
  }
  return *ret;
}

extern "C" { static void * threadfunc_wrapper(void *arg); }

class ConnectionThread
{
public:
  ConnectionThread();
  ~ConnectionThread();
  bool isRunning() const {return thread_running;}
  bool hasRun() const {return thread_ran;}
  bool start(int socket_fd, const std::string & remoteHost = "unknown");
private:
  static int id;

  // FSM/Globals mutex lock around global data so threads don't stomp on each other
  pthread_t handle;
  int sock, myid, fsm_id;
  std::string remoteHost;
  volatile bool thread_running, thread_ran;

  std::ostream &log(int i = -1) 
  { 
    if (i == 0) return ::log(i); // unlock, so don't output anything extra...
    return ::log(i) << "[Thread " << myid << " (" << remoteHost << ")] "; 
  }


  ShmMsg msg; //< needed to put this in class data because it broke the stack it's so freakin' big now

  // Functions to send commands to the realtime process via the rt-fifos
  void sendToRT(ShmMsgID cmd); // send a simple command, one of RESET, PAUSEUNPAUSE, INVALIDATE. Upon return we know the command completed.
  void sendToRT(ShmMsg & msg); // send a complex command, wait for a reply which gets put back into 'msg'.  Upon return we know the command completed.
  void getFSMSizeFromRT(unsigned & rows_out, unsigned & cols_out);
  unsigned getNumInputEventsFromRT(void);
  int sockSend(const std::string & str) ;
  int sockSend(const void *buf, size_t len, bool is_binary = false, int flags = 0);
  int sockReceiveData(void *buf, int size, bool is_binary = true);
  std::string sockReceiveLine();
  bool uploadMatrix(const Matrix & m, unsigned numEvents, unsigned numSchedWaves, const std::string & inChanType, unsigned readyForTrialState,  const std::string & outputSpecStr, unsigned wait_for_state0_crossing_to_do_fsm_swap_flg);

  bool downloadMatrix(Matrix & m);
  void doNotifyEvents(bool full = false); ///< if in full mode, actually write out the text of the event, one per line, otherwise write only the character 'e' with no newline
  std::vector<OutputSpec> parseOutputSpecStr(const std::string & str);

  
  // the extern "C" wrapper func passed to pthread_create
  friend void *threadfunc_wrapper(void *);
  void *threadFunc();
};

int ConnectionThread::id = 0;

ConnectionThread::ConnectionThread() : sock(-1), thread_running(false), thread_ran(false) { myid = id++; fsm_id = 0; }
ConnectionThread::~ConnectionThread()
{ 
  if (sock > -1)  ::shutdown(sock, SHUT_RDWR), ::close(sock), sock = -1;
  if (isRunning())  pthread_join(handle, NULL), thread_running = false;
  log(1) <<  "deleted." << std::endl;
  log(0);
}
extern "C" 
{
  static void * threadfunc_wrapper(void *arg)   
  { 
    pthread_detach(pthread_self());
    ConnectionThread *me = static_cast<ConnectionThread *>(arg);
    void * ret = me->threadFunc();  
    // now, try and reap myself..
    if (0 == pthread_mutex_lock(&connectedThreadsLock)) {
      ConnectedThreadsList::iterator it;
      if ( (it = connectedThreads.find(me)) != connectedThreads.end() ) {
        delete me;
        connectedThreads.erase(it);
        n_threads--;
        log(1) << "Auto-reaped dead thread, have " << n_threads << " still running." << std::endl; log(0);
      }
      pthread_mutex_unlock(&connectedThreadsLock);
    }
    return ret;
  }
}
bool ConnectionThread::start(int sock_fd, const std::string & rhost)
{
  if (isRunning()) return false;
  sock = sock_fd;  
  remoteHost = rhost;
  return 0 == pthread_create(&handle, NULL, threadfunc_wrapper, static_cast<void *>(this));
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

static void attachShm()
{
  // first, connect to the shm buffer..
  RTOS::ShmStatus shmStatus;
  void *shm_notype = RTOS::shmAttach(SHM_NAME, SHM_SIZE, &shmStatus);
    
  if (!shm_notype)
    throw Exception(std::string("Cannot connect to ") + SHM_NAME
                    + ", error was: " + RTOS::statusString(shmStatus));
  shm = const_cast<volatile Shm *>(static_cast<Shm *>(shm_notype));
    
  if (shm->magic != SHM_MAGIC)
    throw Exception("Attached to shared memory buffer, but the magic number is invalid!\n");
}
  
static void fifoReadAllAvail(int f)
{
  int numStale = 0, numLeft = 0, err;
  err = ::ioctl(f, FIONREAD, &numStale); // how much data is there?
  if (err)  // argh, ioctl returned error!
    throw Exception(std::string("fifoReadAllAvail: ") + strerror(errno));
    
  numLeft = numStale;
  while (numLeft > 0) { // keep consuming up to 1kb of data per iteration..
    char dummyBuf[1024];
    int nread = ::read(f, dummyBuf, MIN(sizeof(dummyBuf), (unsigned)numLeft));
    if (nread <= 0)
      throw Exception(std::string("fifoReadAllAvail: ") + strerror(errno));
    numLeft -= nread;
  }
    
  if (numStale) 
    log() << "Cleared " << numStale << " old bytes from input fifo " 
           << f << "." << std::endl; 
}

static void openFifos()
{
  for (int f = 0; f < NUM_STATE_MACHINES; ++f) {
    FSMSpecific & fsm = fsms[f];
    fsm.fifo_in = RTOS::openFifo(shm->fifo_out[f]);
    if (fsm.fifo_in < 0) throw Exception ("Could not open RTF fifo_in for reading");
    // Clear any pending/stale data in case we crashed last time and
    // couldn't read all data off reply fifo
    fifoReadAllAvail(fsm.fifo_in);
    fsm.fifo_out = RTOS::openFifo(shm->fifo_in[f], RTOS::Write);
    if (fsm.fifo_out < 0) throw Exception ("Could not open RTF fifo_out for writing");
    fsm.fifo_trans = RTOS::openFifo(shm->fifo_trans[f], RTOS::Read);
    if (fsm.fifo_trans < 0) throw Exception ("Could not open RTF fifo_trans for reading");
    fsm.fifo_daq = RTOS::openFifo(shm->fifo_daq[f], RTOS::Read);
    if (fsm.fifo_daq < 0) throw Exception ("Could not open RTF fifo_daq for reading");
    fsm.fifo_nrt_output = RTOS::openFifo(shm->fifo_nrt_output[f], RTOS::Read);
    if (fsm.fifo_nrt_output < 0) throw Exception ("Could not open RTF fifo_nrt_output for reading");
  }
}

static void closeFifos()
{
  for (int f = 0; f < NUM_STATE_MACHINES; ++f) {
    FSMSpecific & fsm = fsms[f];
    if (fsm.fifo_in >= 0) ::close(fsm.fifo_in);
    if (fsm.fifo_out >= 0) ::close(fsm.fifo_out);
    if (fsm.fifo_trans >= 0) ::close(fsm.fifo_trans);
    if (fsm.fifo_daq >= 0) ::close(fsm.fifo_daq);
    if (fsm.fifo_nrt_output >= 0) ::close(fsm.fifo_nrt_output);
    fsm.fifo_nrt_output = fsm.fifo_daq = fsm.fifo_trans = fsm.fifo_in = fsm.fifo_out = -1;
  }
}

static void createTransNotifyThreads()
{
  for (int f = 0; f < NUM_STATE_MACHINES; ++f) {
    int ret = pthread_create(&fsms[f].transNotifyThread, NULL, transNotifyThrWrapper, reinterpret_cast<void *>(f));
    if (ret) 
      throw Exception("Could not create a required thread, 'state transition notify thread'!");
  }
}
  
static void createDAQReadThreads()
{
  for (int f = 0; f < NUM_STATE_MACHINES; ++f) {
    int ret = pthread_create(&fsms[f].daqReadThread, NULL, daqThrWrapper, reinterpret_cast<void *>(f));
    if (ret) 
      throw Exception("Could not create a required thread, 'daq fifo read thread'!");
  }
}

static void createNRTReadThreads()
{
  for (int f = 0; f < NUM_STATE_MACHINES; ++f) {
    int ret = pthread_create(&fsms[f].nrtReadThread, NULL, nrtThrWrapper, reinterpret_cast<void *>(f));
    if (ret) 
      throw Exception("Could not create a required thread, 'nrt output fifo read thread'!");
  }
}

static void init()
{
  attachShm();
  openFifos();
  createTransNotifyThreads();
  createDAQReadThreads();
  createNRTReadThreads();
}
  
static void cleanup(void)
{
  if (listen_fd >= 0) { ::close(listen_fd);  listen_fd = -1; }
  closeFifos();
  if (shm) { RTOS::shmDetach((void *)shm); shm = 0; }
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

static void sighandler(int sig)
{
    
  if (sig == SIGPIPE) return; // ignore SIGPIPE..
    
  /*try {
    sendToRT(PAUSEUNPAUSE);
    } catch (...) {}*/
    
  log() << "Caught signal " << sig << " cleaning up..." << std::endl; 
    
  cleanup();
    
  //::kill(0, SIGKILL); /* suicide!! this is to avoid other threads from getting this signal */
  _exit(1);
}

struct Matrix
{
public:
  Matrix(const Matrix & mat) : d(0) { *this = mat; }
  Matrix(int m, int n) : m(m), n(n) { d = new double[m*n]; }
  ~Matrix() { delete [] d; }
  Matrix & operator=(const Matrix &rhs);
  Matrix & vertCat(const Matrix &rhs); // modified this
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

Matrix & Matrix::operator=(const Matrix &rhs)
{
  if (d) delete [] d;
  m = rhs.m; n = rhs.n;
  d = new double[m*n];
  std::memcpy(d, rhs.d, m*n*sizeof(double));
  return *this;
}

Matrix & Matrix::vertCat(const Matrix &rhs)
{
  Matrix mat(m+rhs.m, n);
  int i, j, i_rhs;
  for (i_rhs = 0, i = 0; i < mat.rows(); ++i) {
    for (j = 0; j < mat.cols(); ++j)
      if (i < rows() && j < cols()) 
        mat.at(i,j) = at(i,j);  
      else if (i >= rows() && i_rhs < rhs.rows() && j < rhs.cols())
        mat.at(i,j) = rhs.at(i_rhs, j);
      else 
        mat.at(i,j) = 0; // pad with zeroes?
    if (i >= rows()) ++i_rhs;
  }  
  return *this = mat;  
}

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

static void doServer(void)
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

  while (1) {
    int sock;
    if ( (sock = ::accept(listen_fd, (struct sockaddr *)&inaddr, &addr_sz)) < 0 ) 
      throw Exception(std::string("accept: ") + strerror(errno));

    if (::setsockopt(sock, IPPROTO_TCP, TCP_NODELAY, &parm, sizeof(parm)) )
      log() << "Error: setsockopt returned " << ::strerror(errno) << std::endl; 
    
    ConnectionThread *conn = new ConnectionThread;
    pthread_mutex_lock(&connectedThreadsLock);
    if ( conn->start(sock, inet_ntoa(inaddr.sin_addr)) ) {
      ++n_threads;
      connectedThreads[conn] = conn;
      log(1) << "Started new thread, now have " << n_threads << " total." 
             << std::endl; log(0);
    } else 
      delete conn;
    pthread_mutex_unlock(&connectedThreadsLock);
  }
}

int main(int argc, const char *argv[])
{
  int ret = 0;

  // install our signal handler that tries to pause the rt-process and
  // quit the program
  signal(SIGINT, sighandler);
  signal(SIGPIPE, sighandler);
  signal(SIGQUIT, sighandler);
  signal(SIGHUP, sighandler);
  signal(SIGTERM, sighandler);

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

void *ConnectionThread::threadFunc(void)
{
  Timer connectionTimer;

  log(1) << "Connection received from host " << remoteHost << std::endl; log(0);

  thread_running = true;
  thread_ran = true;
    
  std::string line;
  int count;

  while ( (line = sockReceiveLine()).length() > 0) {
      
    bool cmd_error = true;

    if (line.find("SET STATE MATRIX") == 0) {
      /* FSM Upload.. */
        
      // determine M and N
      std::string::size_type pos = line.find_first_of("0123456789");

      if (pos != std::string::npos) {
        unsigned m = 0, n = 0, num_Events = 0, num_SchedWaves = 0, readyForTrialState = 0, num_ContChans = 0, num_TrigChans = 0, num_Vtrigs = 0, pend_sm_swap_flg = 0;
        std::string outputSpecStr = "";
        std::string inChanType = "ERROR";
        std::stringstream s(line.substr(pos));
        s >> m >> n >> num_Events >> num_SchedWaves >> inChanType >> readyForTrialState >> num_ContChans >> num_TrigChans >> num_Vtrigs >> outputSpecStr >> pend_sm_swap_flg;
        if (m && n) {
          if (outputSpecStr.length() == 0 && (num_ContChans || num_TrigChans || num_Vtrigs || num_SchedWaves)) {
            // old FSM client, so build an output spec string for them
            log(1) << "Client appears to use old SET STATE MATRIX interface, trying to create an output spec string that matches.\n"; log(0);
            std::stringstream s("");
            if (num_ContChans+num_TrigChans) 
              s << "\1" << "dout" << "\2" << "0-" << (num_ContChans+num_TrigChans);
            if (num_Vtrigs)
              s << "\1" << "sound" << "\2" << fsm_id;
            if (num_SchedWaves)
              s << "\1" << "sched_wave" << "\2" << "Ignored";
            outputSpecStr = s.str();
          } else
            outputSpecStr = UrlDecode(outputSpecStr);

          // guard against memory hogging DoS
          if (m*n > FSM_FLAT_SIZE) {
            log(1) << "Error, incoming matrix would exceed cell limit of " << FSM_FLAT_SIZE << std::endl; log(0);
            break;
          }
          if ( (count = sockSend("READY\n")) <= 0 ) {
            log(1) << "Send error..." << std::endl; log(0);
            break;
          }
          log(1) << "Getting ready to receive matrix of  " << m << "x" << n << " with one row for (" << num_Events << ") event mapping and row(s) for " <<  num_SchedWaves << " scheduled waves " << std::endl; log(0);
            
          Matrix mat (m, n);
          count = sockReceiveData(mat.buf(), mat.bufSize());
          if (count == (int)mat.bufSize()) {
            cmd_error = !uploadMatrix(mat, num_Events, num_SchedWaves, inChanType, readyForTrialState, outputSpecStr, pend_sm_swap_flg);
          } else if (count <= 0) {
            break;
          }
        } 
      }
    } else if (line.find("GET STATE MATRIX") == 0) {
      unsigned rows, cols;
      getFSMSizeFromRT(rows, cols);
      Matrix m(rows, cols);
      if (downloadMatrix(m)) {
        std::stringstream s;
          
        s << "MATRIX " << m.rows() << " " << m.cols() << std::endl;
        sockSend(s.str());
          
        line = sockReceiveLine(); // wait for "READY" from client
          
        if (line.find("READY") != std::string::npos) {
          count = sockSend(m.buf(), m.bufSize(), true);
          if (count == (int)m.bufSize()) 
            cmd_error = false;
        }
      }
    } else if (line.find("INITIALIZE") == 0) {
      sendToRT(RESET);
      cmd_error = false;
    } else if (line.find("HALT") == 0) {
      msg.id = GETPAUSE;
      sendToRT(msg);
      if ( ! msg.u.is_paused ) 
        sendToRT(PAUSEUNPAUSE);
      cmd_error = false;
    } else if (line.find("RUN") == 0) {
      msg.id = GETPAUSE;
      sendToRT(msg);
      if ( msg.u.is_paused ) 
        sendToRT(PAUSEUNPAUSE);
      cmd_error = false;        
    } else if (line.find("FORCE TIME UP") == 0 ) { 
      sendToRT(FORCETIMESUP);
      cmd_error = false;
    } else if (line.find("READY TO START TRIAL") == 0 ) { 
      sendToRT(READYFORTRIAL);
      cmd_error = false;
    } else if (line.find("TRIGSOUND") == 0 ) { 
      int trigmask = 0;
      std::string::size_type pos = line.find_first_of("-0123456789");
      if (pos != std::string::npos) {
        std::stringstream s(line.substr(pos));
        s >> trigmask;
        msg.id = FORCESOUND;
        msg.u.forced_triggers = trigmask;
        sendToRT(msg);
        cmd_error = false;
      }
    } else if (line.find("BYPASS DOUT") == 0) {
      int bypassmask = 0;
      std::string::size_type pos = line.find_first_of("-0123456789");
      if (pos != std::string::npos) {
        std::stringstream s(line.substr(pos));
        s >> bypassmask;
        msg.id = FORCEOUTPUT;
        msg.u.forced_outputs = bypassmask;
        sendToRT(msg);
        cmd_error = false;
      }
    } else if (line.find("FORCE STATE") == 0 ) { 
      unsigned forced_state = 0;
      std::string::size_type pos = line.find_first_of("0123456789");
      if (pos != std::string::npos) {
        unsigned rows, cols;
        getFSMSizeFromRT(rows, cols);
        std::stringstream s(line.substr(pos));
        s >> forced_state;
        if (forced_state < rows) { // ensure legal state here..
          msg.id = FORCESTATE;
          msg.u.forced_state = forced_state;
          sendToRT(msg);
          cmd_error = false;
        }
      }
    } else if (line.find("GET EVENT COUNTER") == 0) {
      msg.id = TRANSITIONCOUNT;
      sendToRT(msg);
      std::stringstream s;
      s << msg.u.transition_count << std::endl;
      sockSend(s.str());
      cmd_error = false;
    } else if (line.find("IS RUNNING") == 0) {
      msg.id = GETPAUSE;
      sendToRT(msg);
      std::stringstream s;
      s << !msg.u.is_paused << std::endl;
      sockSend(s.str());
      cmd_error = false;
    } else if (line.find("GET TIME") == 0) {
      msg.id = GETRUNTIME;
      sendToRT(msg);
      std::stringstream s;
      s << static_cast<double>(msg.u.runtime_us)/1000000.0 << std::endl;
      sockSend(s.str());
      cmd_error = false;        
    } else if (line.find("GET CURRENT STATE") == 0) {
      msg.id = GETCURRENTSTATE;
      sendToRT(msg);
      std::stringstream s;
      s << msg.u.current_state << std::endl;
      sockSend(s.str());
      cmd_error = false;        
    } else if (line.find("GET EVENTS") == 0) {
      std::string::size_type pos = line.find_first_of("0123456789");
      if (pos != std::string::npos) {
        std::stringstream s(line.substr(pos));
        int first = -1, last = -1, n_trans = 0;
        s >> first >> last;

        // query the count first to check sanity
        msg.id = TRANSITIONCOUNT;
        sendToRT(msg);
          
        n_trans = msg.u.transition_count;
          
        if (first > -1 && first <= last && last < n_trans) {
          unsigned num_input_events = getNumInputEventsFromRT();
          int desired = last-first+1, received = 0, ct = 0;
          Matrix mat(desired, 5);
            

          // keep 'downloading' the matrix from RT until we get all the transitions we require
          while (received < desired) {
            msg.id = TRANSITIONS;
            msg.u.transitions.num = desired - received;
            msg.u.transitions.from = first + received;
            sendToRT(msg);
            received += (int)msg.u.transitions.num;              
            for (int i = 0; i < (int)msg.u.transitions.num; ++i, ++ct) {
              struct StateTransition & t = msg.u.transitions.transitions[i];
              mat.at(ct, 0) = t.previous_state;
              mat.at(ct, 1) = t.event_id > -1 ? 0x1 << t.event_id : 0x1<<num_input_events;
              mat.at(ct, 2) = static_cast<double>(t.ts/1000) / 1000000.0; /* convert us to seconds */
              mat.at(ct, 3) = t.state;
              mat.at(ct, 4) = static_cast<double>(t.ext_ts/1000) / 1000000.0;
            }
          }
          std::ostringstream os;
          os << "MATRIX " << mat.rows() << " " << mat.cols() << std::endl; 
          sockSend(os.str());

          line = sockReceiveLine(); // wait for "READY" from client
            
          if (line.find("READY") != std::string::npos) {
            sockSend(mat.buf(), mat.bufSize(), true);
            cmd_error = false;
          }
        }
      }
    } else if ( line.find("EXIT") == 0 || line.find("BYE") == 0 || line.find("QUIT") == 0) {
      log(1) << "Graceful exit requested." << std::endl; log(0);
      break;
    } else if (line.find("NOTIFY EVENTS") == 0) {
      std::string::size_type pos = line.find("VERBOSE");
      bool verbose = pos != std::string::npos;
      sockSend("OK\n"); // tell them we accept the command..
      doNotifyEvents(verbose); // this doesn't return for a LONG time normally..
      break; // if we return from the above, means there is a socket error
    } else if (line.find("NOOP") == 0) {
      // noop is just used to test the connection, keep it alive, etc
      // it doesn't touch the shm...
      cmd_error = false;        
    } else if (line.find("START DAQ") == 0) { // START DAQ
      // determine chans and range
      std::string::size_type pos = line.find_first_of("0123456789");

      if (pos != std::string::npos) {
        std::string chanstr, rangestr;
        std::stringstream s(line.substr(pos));
        s >> chanstr >> rangestr;
        std::vector<double> chans = splitNumericString(chanstr);
        std::vector<double> ranges = splitNumericString(rangestr);
        unsigned chanMask = 0, nChans = 0;
        for (unsigned i = 0; i < chans.size(); ++i) {
          unsigned ch = i;
          if (ch < sizeof(int)*8 && !(chanMask&(0x1<<ch)))
            (chanMask |= 0x1<<ch), nChans++;
        }
        if (!chanMask || !nChans || ranges.size() != 2) {
          log(1) << "Chan or range spec for START DAQ has invalid chanspec or rangespec" << std::endl; log(0); 
        } else {
          msg.id = STARTDAQ;
          msg.u.start_daq.chan_mask = chanMask;
          msg.u.start_daq.range_min = int(ranges[0]*1e6);
          msg.u.start_daq.range_max = int(ranges[1]*1e6);
          msg.u.start_daq.started_ok = 0;
          sendToRT(msg);
          if (msg.u.start_daq.started_ok) {
            cmd_error = false;        
            pthread_mutex_lock(&fsms[fsm_id].daqLock);
            fsms[fsm_id].daqNumChans = nChans;
            fsms[fsm_id].daqMaxData = msg.u.start_daq.maxdata;
            //fsms[fsm_id].daqRangeMin = msg.u.start_daq.range_min/1e6;
            //fsms[fsm_id].daqRangeMax = msg.u.start_daq.range_max/1e6;
            pthread_mutex_unlock(&fsms[fsm_id].daqLock);
          } else { 
            log(1) << "RT Task refused to do start a DAQ task -- probably invalid parameters are to blame" << std::endl; log(0); 
          }
        }
      }
    } else if (line.find("STOP DAQ") == 0) { // STOP DAQ
      sendToRT(STOPDAQ);
      //fifoReadAllAvail(fifo_daq); // discard fifo data for stopped scan
      // FIXME avoid race coditions with daq thread
      pthread_mutex_lock(&fsms[fsm_id].daqLock);
      fsms[fsm_id].daqBuf.clear();
      pthread_mutex_unlock(&fsms[fsm_id].daqLock);
      cmd_error = false;        
    } else if (line.find("GET DAQ SCANS") == 0) { // GET DAQ SCANS

      Matrix mat = fsms[fsm_id].getDAQScans();
      std::ostringstream os;
      os << "MATRIX " << mat.rows() << " " << mat.cols() << std::endl; 
      sockSend(os.str());

      line = sockReceiveLine(); // wait for "READY" from client
            
      if (line.find("READY") != std::string::npos) {
        sockSend(mat.buf(), mat.bufSize(), true);
        cmd_error = false;
      }
 
    } else if (line.find("SET AO WAVE") == 0) { // SET AO WAVE

      // determine M N id aoline loop
      std::string::size_type pos = line.find_first_of("0123456789");

      if (pos != std::string::npos) {
        unsigned m = 0, n = 0, id = 0, aoline = 0, loop = 0;
        std::stringstream s(line.substr(pos));
        s >> m >> n >> id >> aoline >> loop;
        if (m && n) {
          // guard against memory hogging DoS
          if (m*n > FSM_FLAT_SIZE) {
            log(1) << "Error, incoming matrix would exceed cell limit of " << FSM_FLAT_SIZE << std::endl; log(0);
            break;
          }
          if ( (count = sockSend("READY\n")) <= 0 ) {
            log(1) << "Send error..." << std::endl; log(0);
            break;
          }
          log(1) << "Getting ready to receive AO wave matrix sized " << m << "x" << n << std::endl; log(0);
            
          Matrix mat (m, n);
          count = sockReceiveData(mat.buf(), mat.bufSize());
          if (count == (int)mat.bufSize()) {
            msg.id = GETAOMAXDATA;
            sendToRT(msg);
            fsms[fsm_id].aoMaxData = msg.u.ao_maxdata;
            msg.id = AOWAVE;
            msg.u.aowave.id = id;
            msg.u.aowave.aoline = aoline;
            msg.u.aowave.loop = loop;
            // scale data from [-1,1] -> [0,aoMaxData]
            for (unsigned i = 0; i < n && i < AOWAVE_MAX_SAMPLES; ++i) {
              msg.u.aowave.samples[i] = static_cast<unsigned short>(((mat.at(0, i) + 1.0) / 2.0) * fsms[fsm_id].aoMaxData);
              if (m > 1)
                msg.u.aowave.evt_cols[i] = static_cast<signed char>(mat.at(1, i));
              else
                msg.u.aowave.evt_cols[i] = -1;
            }
            msg.u.aowave.nsamples = n;
            // send to kernel
            sendToRT(msg);
          } else if (count <= 0) {
            break;
          }
        } else {
          // indicates we are clearing an existing wave
          msg.id = AOWAVE;
          msg.u.aowave.id = id;
          msg.u.aowave.nsamples = 0;
          sendToRT(msg);
        }
        cmd_error = false;        
      }
    } else if (line.find("GET STATE MACHINE") == 0) { // GET STATE MACHINE
      std::ostringstream s;
      s << fsm_id << "\n";      
      sockSend(s.str());
      cmd_error = false;
    } else if (line.find("GET NUM STATE MACHINES") == 0) { // GET NUM STATE MACHINES
      std::ostringstream s;
      s << NUM_STATE_MACHINES << "\n";      
      sockSend(s.str());
      cmd_error = false;
    } else if (line.find("SET STATE MACHINE") == 0) { // SET STATE MACHINE
      // determine param
      std::string::size_type pos = line.find_first_of("0123456789");
      if (pos != std::string::npos) {
        std::istringstream s(line.substr(pos));
        unsigned in_id = NUM_STATE_MACHINES;
        s >> in_id;
        if (in_id < NUM_STATE_MACHINES) {
          cmd_error = false;
          fsm_id = in_id;
        }
      }
    }

    if (cmd_error) {
      sockSend("ERROR\n"); 
    } else {
      sockSend("OK\n"); 
    }

  }
    
  log(1) << "Connection to host " << remoteHost << " ended after " << connectionTimer.elapsed() << " seconds." << std::endl; log(0);
    

  ::shutdown(sock, SHUT_RDWR);
  ::close(sock);
  sock = -1;
  thread_running = false;
  log(1) << " thread exit." << std::endl; log(0);
  return 0;
}

void ConnectionThread::sendToRT(ShmMsg & msg) // note param name masks class member
{
  MutexLocker locker(fsms[fsm_id].msgFifoLock);

  std::memcpy(const_cast<ShmMsg *>(&shm->msg[fsm_id]), &msg, sizeof(msg));

  FifoNotify_t dummy = 1;    
    
  if ( ::write(fsms[fsm_id].fifo_out, &dummy, sizeof(dummy)) != sizeof(dummy) )
    throw Exception("INTERNAL ERROR: Could not write a complete message to the fifo!");

  int err; 
  // now wait synchronously for a reply from the rt-process.. 
  if ( (err = ::read(fsms[fsm_id].fifo_in, &dummy, sizeof(dummy))) == sizeof(dummy) ) { 
    /* copy the reply from the shm back to the user-supplied msg buffer.. */
    std::memcpy(&msg, const_cast<struct ShmMsg *>(&shm->msg[fsm_id]), sizeof(msg));
  } else if (err < 0) { 
    throw Exception(std::string("INTERNAL ERROR: Reading of input fifo got an error: ") + strerror(errno));
  } else {
    throw Exception("INTERNAL ERROR: Could not read a complete message from the fifo!");
  }
  // NB: mutex locker destructor unlocks msgFifoLock here..
}

void ConnectionThread::sendToRT(ShmMsgID cmd)
{
  switch (cmd) {
  case RESET:
  case PAUSEUNPAUSE:
  case INVALIDATE:
  case READYFORTRIAL:
  case FORCETIMESUP:
  case STOPDAQ:
    msg.id = cmd;
    sendToRT(msg);
    break;
  default:
    throw Exception("INTERNAL ERRROR: sendToRT(ShmMsgID) called with an inappropriate command ID!");
    break;
  }
}

void ConnectionThread::getFSMSizeFromRT(unsigned & r, unsigned & c)
{
  msg.id = GETFSMSIZE;
  sendToRT(msg);
  r = msg.u.fsm_size[0];
  c = msg.u.fsm_size[1];
}

unsigned ConnectionThread::getNumInputEventsFromRT(void)
{
  msg.id = GETNUMINPUTEVENTS;
  sendToRT(msg);
  return msg.u.num_input_events;
}

int ConnectionThread::sockSend(const std::string & str) 
{
  return sockSend(str.c_str(), str.length());
}

int ConnectionThread::sockSend(const void *buf, size_t len, bool is_binary, int flags)
{
  const char *charbuf = static_cast<const char *>(buf);
  if (!is_binary) {
    std::stringstream ss;
    ss << "Sending: " << charbuf; 
    if (charbuf[len-1] != '\n') ss << std::endl;
    log(1) << ss.str() << std::flush; log(0);
  } else {
    log(1) << "Sending binary data of length " << len << std::endl; log(0);  
  }
  int ret = ::send(sock, buf, len, flags);
  if (ret < 0) {
    log(1) << "ERROR returned from send: " << strerror(errno) << std::endl; log(0);
  } else if (ret != (int)len) {
    log(1) << "::send() returned the wrong size; expected " << len << " got " << ret << std::endl; log(0);
  }
  return ret;
}

// Note: trims trailing whitespace!  If string is empty, connection error!
std::string ConnectionThread::sockReceiveLine()
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


int ConnectionThread::sockReceiveData(void *buf, int size, bool is_binary)
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

bool ConnectionThread::uploadMatrix(const Matrix & m, 
                                    unsigned numEvents, 
                                    unsigned numSchedWaves, 
                                    const std::string & inChanType,
                                    unsigned readyForTrialJumpState,
                                    const std::string & outputSpecStr,
                                    unsigned state0_fsm_swap)
{
  // Matrix is XX rows by num_input_evts+4(+1) columns, cols 0-num_input_evts are inputs (cin, cout, lin, lout, rin, rout), 6 is timeout-state,  7 is a 14DIObits mask, 8 is a 7AObits, 9 is timeout-time, and 10 is the optional sched_wave
  log(1) << "Matrix is:" << std::endl; log(0);
  int i,j;
  for (i = 0; i < m.rows(); ++i) {
    log(1);
    for (j = 0; j < m.cols(); ++j)
      ::log() << m.at(i,j) << " " ;
    ::log() << std::endl; 
    log(0);
  }
  
  std::vector<OutputSpec> outSpec = parseOutputSpecStr(outputSpecStr);

  const int numFixedCols = 2; // timeout_state and timeout_us

  if (m.rows() == 0 || m.cols() < numFixedCols || m.rows()*m.cols() > (int)FSM_FLAT_SIZE) {
    log(1) << "Matrix needs to be at least 1x2 and no larger than " << FSM_FLAT_SIZE << " total elements! Error!" << std::endl; log(0);
    return false;
  }
  const unsigned requiredCols = numEvents + numFixedCols + outSpec.size();
  if (m.cols() < (int)requiredCols ) {
    log(1) << "Matrix has the wrong number of columns: " << m.cols() << " when it actually needs events(" << numEvents << ") + fixed(" << numFixedCols << ") + outputs(" <<  outSpec.size() << ") = " << requiredCols << " columns! Error!" << std::endl; log(0);
    return false;    
  }
  if (outSpec.size() > FSM_MAX_OUT_EVENTS) {
    log(1) << "Matrix has too many output columns (" << outSpec.size() << ").  The maximum number of output columns is " << FSM_MAX_OUT_EVENTS << "\n"; log(0);
    return false;
  }
  msg.id = FSM;
  ::memset(&msg.u.fsm, 0, sizeof(msg.u.fsm)); // zero memory since some code assumes unset values are zero?
  
  // setup matrix here..
  msg.u.fsm.n_rows = m.rows(); // note this will get set to inpRow later in this function via the alias nRows...
  msg.u.fsm.n_cols = m.cols();
  unsigned short & nRows = msg.u.fsm.n_rows; // alias used for below code, will get decremented once we pop out the sched wave spec that is in our matrix and the input event spec that is in our matrix..

  // seetup in_chan_type
  if ( (msg.u.fsm.routing.in_chan_type = (inChanType == "ai" ? AI_TYPE : (inChanType == "dio" ? DIO_TYPE : UNKNOWN_TYPE))) == UNKNOWN_TYPE ) {
    log(1) << "Matrix specification is using an unknown in_chan_type of " << inChanType << "! Error!" << std::endl; log(0);
    return false;        
  }
  
  msg.u.fsm.ready_for_trial_jumpstate = readyForTrialJumpState;
  
  msg.u.fsm.routing.num_evt_cols = numEvents;
  msg.u.fsm.routing.num_out_cols = outSpec.size();
  for (unsigned it = 0; it < msg.u.fsm.routing.num_out_cols; ++it) {
    // put output spec into fsm blob..
    memcpy(reinterpret_cast<void *>(&msg.u.fsm.routing.output_routing[it]),
           reinterpret_cast<void *>(&outSpec[it]),
           sizeof(struct OutputSpec));
  }

  // compute scheduled waves cells used
  int swCells = numSchedWaves * 7; // each sched wave uses 7 cells.
  int swRows = (swCells / m.cols()) + (swCells % m.cols() ? 1 : 0);
  int swFirstRow = (int)nRows - swRows;
  int inpRow = swFirstRow - 1;
  if (inpRow < 0 || swFirstRow < 0 || inpRow < 0) {
    log(1) << "Matrix specification has invalid number of rows! Error!" << std::endl; log(0);
    return false;            
  }
  
  // first clear the input routing array, by setting mappings to null (-1)
  for (i = 0; i < FSM_MAX_IN_EVENTS; ++i) msg.u.fsm.routing.input_routing[i] = -1;
  // compute input mapping from input spec vector
  int maxChan = -1, minChan = INT_MAX;
  for (i = 0; i < (int)numEvents && i < (int)m.cols() && i < FSM_MAX_IN_EVENTS; ++i) {
    int chan = static_cast<int>(m.at(inpRow, i));
    if (!chan) continue; // 0 == ignored column, no mapping
    int falling_offset = chan < 0 ? 1 : 0; // if we are falling edge, index +1 into mapping array (see below)
    if (chan < 0) chan = -chan; // make it abs(chan)
    --chan; // remap it to 0-indexed channel
    maxChan = maxChan < chan ? chan : maxChan;
    minChan = minChan > chan ? chan : minChan;
    if (chan >= FSM_MAX_IN_CHANS) {
      log(1) << "Matrix specification is using a channel id of " << chan << " which is out of range!  We only support up to " << FSM_MAX_IN_CHANS << " channels! Error!" << std::endl; log(0);
      return false;
    }
    msg.u.fsm.routing.input_routing[chan*2 + falling_offset] = i;
  }
  if (!numEvents) minChan = 0, maxChan = -1;
  msg.u.fsm.routing.num_in_chans = maxChan-minChan+1;
  msg.u.fsm.routing.first_in_chan = minChan;
  
  // rip out the sched wave spec in the matrix, use it to
  // populate fields in FSMBlob::Routing  
  int row = swFirstRow, col = -1;
  for (i = 0; i < (int)numSchedWaves; ++i) {
#define NEXT_COL() do { if (++col >= m.cols()) { ++row; col = 0; } } while (0)
    NEXT_COL();
    int id = (int)m.at(row, col);
    if (id >= (int)FSM_MAX_SCHED_WAVES || id < 0) {
      log(1) << "Alarm/Sched Wave specification has invalid id: " << id <<"! Error!" << std::endl; log(0);
      return false;
    }
    SchedWave &w = msg.u.fsm.sched_waves[id];
    NEXT_COL();
    int in_evt_col = (int)m.at(row, col);
    if (in_evt_col >= 0) {
      if (in_evt_col >= (int)numEvents) {
        log(1) << "Alarm/Sched Wave specification has invalid IN event column routing: " << in_evt_col <<"! Error!" << std::endl; log(0);
        return false;
      }
      msg.u.fsm.routing.sched_wave_input[id*2] = in_evt_col;
    } else {
      msg.u.fsm.routing.sched_wave_input[id*2] = -1;
    }
    NEXT_COL();
    int out_evt_col = (int)m.at(row, col);
    if (out_evt_col >= 0) {
      if (out_evt_col >= (int)numEvents) {
        log(1) << "Alarm/Sched Wave specification has invalid OUT event column routing: " << out_evt_col <<"! Error!" << std::endl; log(0);
        return false;
      }
      msg.u.fsm.routing.sched_wave_input[id*2+1] = out_evt_col;
    } else {
      msg.u.fsm.routing.sched_wave_input[id*2+1] = -1;
    }
    NEXT_COL();
    int dio_line = (int)m.at(row, col);
    if (dio_line >= 0 && dio_line >= FSM_MAX_OUT_CHANS) {
      log(1) << "Alarm/Sched Wave specification has invalid DIO line: " << dio_line <<"! Error!" << std::endl; log(0);
      return false;      
    }
    msg.u.fsm.routing.sched_wave_output[id] = dio_line;
    NEXT_COL();
    w.preamble_us = static_cast<uint64>(m.at(row,col)*1e6);
    NEXT_COL();
    w.sustain_us = static_cast<uint64>(m.at(row,col)*1e6);
    NEXT_COL();
    w.refraction_us = static_cast<uint64>(m.at(row,col)*1e6);
    w.enabled = true;
  }
#undef NEXT_COL

  nRows = inpRow;
  for (i = 0; i < (int)nRows; ++i) {
    struct State state;
    GET_STATE(&msg.u.fsm, &state, i);
    for (j = 0; j < m.cols(); ++j) {
      // While appearing like we are breaking the input array with 
      // indices greater than state->n_inputs, this actually works due to:
      // since we break it by the remainder of the unsigneds  in the actual 
      // FSMBlob row..
      //
      // Note also how we don't even bother to set the other fields in struct
      // State as they wouldn't affect the real msg.u.fsm anyway, only
      // State::column (and State::input) does point to the actual memory 
      // (the other fields in struct state merely store copies).
      //
      if (j == (int)numEvents+1) state.column[j] = static_cast<unsigned>(m.at(i,j)*1000000.0); // handle timeout_s and convert it to timeout_us
      else state.column[j] = static_cast<unsigned>(m.at(i,j));
    }
  }

  msg.u.fsm.wait_for_jump_to_state_0_to_swap_fsm = state0_fsm_swap;

  sendToRT(msg);

  return true;
}

bool ConnectionThread::downloadMatrix(Matrix & m)
{
  msg.id = GETVALID;

  sendToRT(msg);

  if (!msg.u.is_valid) {
    int i,j;
    for (i = 0; i < m.rows(); ++i)  
      for (j = 0; j < m.cols(); ++j) 
        m.at(i,j) = 0;
    log(1) << "FSM is invalid, so sending empty matrix for GET STATE MATRIX request." << std::endl; log(0);
    return true; // no valid matrix defined  
  }
  
  msg.id = GETFSM;
  sendToRT(msg);

  // Matrix is ?? rows by ??' columns, cols 0-? are inputs (cin, cout, lin, lout, rin, rout, etc), cols-4 is timeout-state, cols-3 is timeout-time, cols-2 is a 14DIObits mask, and cols-1 is a 7AObits
  
  if (m.rows() != msg.u.fsm.n_rows || m.cols() != msg.u.fsm.n_cols) {
    log(1) << "Matrix needs to be " << msg.u.fsm.n_rows << " x " << msg.u.fsm.n_cols << "! Error!" << std::endl << log(0);
    return false;
  }

  // setup matrix here..
  int i,j;

  for (i = 0;  i < m.rows(); ++i) {
    struct State state;
    GET_STATE(&msg.u.fsm, &state, i);
    for (j = 0; j < m.cols(); ++j)
      m.at(i, j) = static_cast<double>(state.input[j]);    

    // Convert the 2 timeout_state and timeout_us columns -- this code assumes there are 2 more columns after all the input cols
    m.at(i, state.n_inputs) = static_cast<double>(state.timeout_state);
    m.at(i, state.n_inputs+1) = static_cast<double>(state.timeout_us/1000000.0);
  }
  
  log(1) << "Matrix from RT is:" << std::endl; log(0);
  for (i = 0; i < m.rows(); ++i) {
    log(1);
    for (j = 0; j < m.cols(); ++j)
      ::log() << m.at(i,j) << " ";
    ::log() << std::endl; log(0);
  }
      
  return true;
}

static void *transNotifyThrWrapper(void *arg)
{
  pthread_detach(pthread_self());
  int myfsm = reinterpret_cast<int>(arg);
  if (myfsm < 0 || myfsm >= NUM_STATE_MACHINES) return 0;
  return fsms[myfsm].transNotifyThrFun();
}

static void *daqThrWrapper(void *arg)
{
  pthread_detach(pthread_self());
  int myfsm = reinterpret_cast<int>(arg);
  if (myfsm < 0 || myfsm >= NUM_STATE_MACHINES) return 0;
  return fsms[myfsm].daqThrFun();
}

static void *nrtThrWrapper(void *arg)
{
  pthread_detach(pthread_self());
  int myfsm = reinterpret_cast<int>(arg);
  if (myfsm < 0 || myfsm >= NUM_STATE_MACHINES) return 0;
  return fsms[myfsm].nrtThrFun();
}

void *FSMSpecific::transNotifyThrFun()
{
  static const unsigned n_buf = FIFO_TRANS_SZ/sizeof(struct StateTransition), bufsz = FIFO_TRANS_SZ;
  struct StateTransition *buf = new StateTransition[n_buf];
  int nread = 0;

  while(nread >= 0 && fifo_trans >= 0) {
    nread = ::read(fifo_trans, buf, bufsz);
    if (nread > 0) {
      unsigned num = nread / sizeof(*buf), i;
      pthread_mutex_lock(&transNotifyLock);
      for (i = 0; i < num; ++i) {
        transBuf.push(buf[i]);
        // DEBUG...
        //::log() << "Got transition: " << 
        //    buf[i].previous_state << " " << buf[i].state << " " << buf[i].event_id << " " << buf[i].ts/1000000000.0 << std::endl; ::log(0);
      }
      pthread_cond_broadcast(&transNotifyCond);
      pthread_mutex_unlock(&transNotifyLock);
    }
  }
  delete [] buf;
  return 0;
}

void ConnectionThread::doNotifyEvents(bool verbose)
{
  unsigned long long lastct = 0, ct;
  bool err = false;
  FSMSpecific & f = fsms[fsm_id];
  pthread_mutex_lock(&f.transNotifyLock);
  lastct = f.transBuf.count();
  pthread_mutex_unlock(&f.transNotifyLock);
  while (sock > -1 && !err) {
    int nready;
    ::ioctl(sock, FIONREAD, &nready);
    if (nready > 0) {
      // socket got data! abort it all since this is outside of protocol spec!
      char buf[nready > 1024 ? 1024 : nready];
      sockReceiveData(buf, nready, true); // consume data..
      sockSend("BYE\n");
      return;
    }
    pthread_mutex_lock(&f.transNotifyLock);
    while ((ct = f.transBuf.count()) == lastct && sock > -1) {
      struct timeval now;
      struct timespec timeout;
      ::gettimeofday(&now, NULL);
      // wait 1 second on the condition
      timeout.tv_sec = now.tv_sec + 1;
      timeout.tv_nsec = now.tv_usec * 1000;
      int ret = pthread_cond_timedwait(&f.transNotifyCond, &f.transNotifyLock, &timeout);
      if (ret == ETIMEDOUT) continue;
    }
    // handle overflow condition..
    if (ct - lastct > f.transBuf.size())  lastct = ct - f.transBuf.size();
    CircBuf<StateTransition> tb(f.transBuf); // copy the tranition events locally
    pthread_mutex_unlock(&f.transNotifyLock);  // release the lock
    if (verbose) { // process each event in verbose mode
      // operate on local transition events
      std::stringstream ss;
      for (unsigned long long i = lastct; i < ct; i++) {
        struct StateTransition & t = tb[i];
        ss << t.previous_state << " " << t.state << " " << int(t.event_id) << " " << std::setprecision(12) << std::setw(12) << (static_cast<double>(t.ts)/(double)1000000000.0) << " " << (static_cast<double>(t.ext_ts)/(double)1000000000.0) << std::endl;
      }
      err = sockSend(ss.str()) < 0;
    } else {
      // do a bulk notify that an event occurred in  no-verbose mode
      err = sockSend("e") < 0;
    }
    lastct = ct;
  }
}

void *FSMSpecific::daqThrFun()
{
  std::vector<char> buf(FIFO_DAQ_SZ);
  struct DAQScan *sc;
  int nread = 0;
  
  while(nread >= 0 && fifo_daq >= 0) {
    nread = ::read(fifo_daq, &buf[0], FIFO_DAQ_SZ);
    int nproc = 0;
    sc = reinterpret_cast<DAQScan *>(&buf[nproc]);
    while (nread > 0 && nread-nproc >= int(sizeof(*sc)) && sc->magic == DAQSCAN_MAGIC) {
      pthread_mutex_lock(&daqLock);
      DAQScanVec & vec = daqBuf.next();
      vec.assign(sc, daqMaxData, daqRangeMin, daqRangeMax);
      daqBuf.push();
      nproc += sizeof(DAQScan) + sizeof(sc->samps[0])*sc->nsamps;
      sc = reinterpret_cast<DAQScan *>(&buf[nproc]);
      pthread_mutex_unlock(&daqLock);
    }
  }
  return 0;
}

void *FSMSpecific::nrtThrFun()
{
  std::auto_ptr<struct NRTOutput> nrt(new NRTOutput);
  int nread = 0;
  
  while(nread >= 0 && fifo_nrt_output >= 0) {
    nread = ::read(fifo_nrt_output, nrt.get(), sizeof(*nrt));
    if (nread == sizeof(*nrt) && nrt->magic == NRTOUTPUT_MAGIC) {
      switch (nrt->type) {
      case NRT_TCP: 
        doNRT_IP(nrt.get(), false);
        break;
      case NRT_UDP: 
        doNRT_IP(nrt.get(), true);
        break;
      default:
        log(1) << "ERROR In nrtThrFun() got unknown NRT output type " 
               << int(nrt->type) << "\n"; log(0);
        break;
      }
    } else {
        log(1) << "ERROR In nrtThrFun() read invalid struct NRTOutput from fifo!\n"; log(0);
    }
  }
  return 0;
}

static
std::vector<double> splitNumericString(const std::string &str,
                                       const std::string &delims)
{
  std::vector<double> ret;
  if (!str.length() || !delims.length()) return ret;
  std::string::size_type pos;
  for ( pos = 0; pos < str.length() && pos != std::string::npos; pos = str.find_first_of(delims, pos) ) {
    if (pos) ++pos;
    if (pos > str.length()) break;
    std::stringstream s(str.substr(pos));
    double d;
    if ((s >> d).fail()) break;
    ret.push_back(d);
  }
  return ret;
}

Matrix FSMSpecific::getDAQScans()
{
  pthread_mutex_lock(&daqLock);
  Matrix mat(daqBuf.countNormalized(), daqNumChans+1);
  for (unsigned i = 0; i < daqBuf.countNormalized(); ++i) {
    mat.at(i, 0) = daqBuf[i].ts_nanos / 1e9;
    for (unsigned j = 0; j < daqNumChans; ++j)
      if (j < daqBuf[i].samples.size())
        mat.at(i, j+1) = daqBuf[i].samples[j];
      else 
        mat.at(i, j+1) = 0.;
  }
  daqBuf.clear();
  pthread_mutex_unlock(&daqLock);
  return mat;
}

void FSMSpecific::doNRT_IP(const NRTOutput *nrt, bool isUDP) const
{  
        struct hostent he, *he_result;
        int h_err;
        char hostEntAux[32768];
        std::string packetText = FormatPacketText(nrt->ip_packet_fmt, nrt);
        int ret = ::gethostbyname2_r(nrt->ip_host, AF_INET, &he, hostEntAux, sizeof(hostEntAux),&he_result, &h_err);
        if (ret) {
          log(1) << "ERROR In doNRT_IP() got error (ret=" << ret << ") in hostname lookup for " << nrt->ip_host << ": h_errno=" << h_err << "\n"; log(0);
          return;
        }
        int theSock;
        if (isUDP) theSock = socket(PF_INET, SOCK_DGRAM, 0);
        else theSock = socket(PF_INET, SOCK_STREAM, 0);
        if (theSock < 0) {
          log(1) << "ERROR In doNRT_IP() got error (errno=" << strerror(errno) << ") in socket() call\n"; log(0);
          return; 
        }
        if (!isUDP) {
          long flag = 1;
          setsockopt(theSock, SOL_TCP, SO_REUSEADDR, &flag, sizeof(flag));
          flag = 1;
          // turn off nagle for less latency
          setsockopt(theSock, SOL_TCP, TCP_NODELAY, &flag, sizeof(flag));
        }
        struct sockaddr_in addr;
        addr.sin_family = AF_INET;
        addr.sin_port = htons(nrt->ip_port);
        memcpy(&addr.sin_addr.s_addr, he.h_addr, sizeof(addr.sin_addr.s_addr));
        ret = connect(theSock, (struct sockaddr *)&addr, sizeof(addr)); // this call is ok for UDP as well
        if (ret) {
          log(1) << "ERROR In doNRT_IP() could not connect to " << nrt->ip_host << ":" << nrt->ip_port << " got error (errno=" << strerror(errno) << ") in connect() call\n"; log(0);
          ::close(theSock);
          return;
        }
        int datalen = packetText.length();
        if (isUDP)
          // UDP
          ret = sendto(theSock, packetText.c_str(), datalen, 0, (const struct sockaddr *)&addr, sizeof(addr));
        else
          // TCP
          ret = send(theSock, packetText.c_str(), datalen, MSG_NOSIGNAL);
        if (ret != datalen) {
          log(1) << "ERROR In doNRT_IP() sending " << datalen << " bytes to " << nrt->ip_host << ":" << nrt->ip_port << " got error (errno=" << strerror(errno) << ") in send() call\n"; log(0);
        }
        ::close(theSock);
}

namespace {

  std::string UrlEncode(const std::string & str)
  {
	std::string ret = "";
    const int len = str.length();
	for (int i = 0; i < len; ++i) {
      char c = str[i];
      if ( ((c >= 65) && (c <= 90)) || ((c <= 57) && (c >= 48)) || ((c <= 122) && (c >= 97)) ) {
        ret +=  c;
      } else {
        char buf[64];
        sprintf(buf, "%%%02X", unsigned(c));
        ret += buf;
      }
	}
	return ret;
  }

  std::string UrlDecode(const std::string & str)
  {
    std::string ret = "";
    const int len = str.length();
	for (int i = 0; i < len; ++i) {      
      if (str[i] == '%' && i+2 < len && isxdigit(str[i+1]) && isxdigit(str[i+2]) ) {
        ret += char('\0' + strtol(str.substr(i+1, 2).c_str(), 0, 16)); // parse the hex number 
        i+=2; // consume %XX
      } else {
        ret += str[i]; 
      }
    }
	return ret;
  }

  std::string FormatPacketText(const std::string & str, const NRTOutput *nrt)
  {
    std::ostringstream out;
    const int len = str.length();
    for (int i = 0; i < len; ++i) {
      if (str[i] == '%') { // check for '%' format specifier
        if (i+1 < len 
            && (str[i+1] == '%' || str[i+1] == 'v' || str[i+1] == 't' ||
                str[i+1] == 'T' || str[i+1] == 's' || str[i+1] == 'c')) {    
          switch(str[i+1]) {          
          case '%':  out << '%';  break;
          case 'v':  out << nrt->trig; break;
          case 't':  out << double(nrt->ts_nanos)/1e9; break;
          case 'T':  out << nrt->ts_nanos; break;
          case 's':  out << nrt->state; break;
          case 'c':  out << unsigned(nrt->col); break;
          }
        } // else do nothing, has the effect of consuming %anychar
        ++i; // need to consume %anychar regardless
      } else { // not %, so just copy the data
        out << str[i];
      }
    }
    return out.str();
  }

};

std::vector<OutputSpec> ConnectionThread::parseOutputSpecStr(const std::string & str)
{
  // format of output string is \1TYPE_STR\2DATA_STR...

  std::string::size_type pos = 0, pos2 = 0;
  std::vector<OutputSpec> ret;
  while ( (pos = str.find('\1', pos)) != std::string::npos
          && (pos2 = str.find('\2', pos)) != std::string::npos
          && pos2 > pos ) {
    ++pos; // consume \1
    std::string type = str.substr(pos, pos2-pos);
    ++pos2; // consume \2
    std::string data = str.substr(pos2, str.find('\1', pos2)-pos2);
    std::string typeData = type + "::" + data;
    struct OutputSpec spec;
    if (type == "dout") {
      spec.type = OSPEC_DOUT;
    } else if (type == "trig") {
      spec.type = OSPEC_TRIG;
    } else if (type == "sound") {
      spec.type = OSPEC_SOUND;
    } else if (type == "sched_wave") {
      spec.type = OSPEC_SCHED_WAVE;
    } else if (type == "tcp") {
      spec.type = OSPEC_TCP;
    } else if (type == "udp") {
      spec.type = OSPEC_UDP;
    } else if (type == "noop") {
      spec.type = OSPEC_NOOP;
    } else {
      log(1) << "Parse error for output spec \"" << typeData << "\" (ignoring matrix column! Argh!)\n"; log(0);
      spec.type = OSPEC_NOOP;
    }
    // spec.data
    if (type == "dout" || type == "trig") {
      // parse data range
      if (sscanf(data.c_str(), "%u-%u", &spec.from, &spec.to) != 2) {
        log(1) << "Could not parse channel range from output spec \"" << typeData << "\" assuming 0-1! Argh!\n"; log(0);
        spec.from = 0;
        spec.to = 1;
      }
    } else if (type == "sound") {
      // parse data range
      if (sscanf(data.c_str(), "%u", &spec.sound_card) != 1) {
        log(1) << "Could not parse sound card from output spec \"" << typeData << "\" assuming same as fsm id " << fsm_id << "!\n"; log(0);
        spec.sound_card = fsm_id;
      }
    } else if (type == "udp" || type == "tcp") {
      // parse host:port:
      memset(spec.data, 0, sizeof(spec.data));
      if (sscanf(data.c_str(), "%79[0-9a-zA-Z.]:%hu:%942c", spec.host, &spec.port, spec.fmt_text) != 3) {
        log(1) << "Could not parse host:port:packet from output spec \"" << typeData << "\"!  Suppressing column! Argh!\n"; log(0);
        spec.type = OSPEC_NOOP;
      }
    } else {
      strncpy(spec.data, data.c_str(), OUTPUT_SPEC_DATA_SIZE);
      spec.data[OUTPUT_SPEC_DATA_SIZE-1] = 0;
    }
    ret.push_back(spec);
  }
  return ret;
}


