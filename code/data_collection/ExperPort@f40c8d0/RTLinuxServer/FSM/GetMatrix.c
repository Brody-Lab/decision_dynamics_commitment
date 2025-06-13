#define _GNU_SOURCE
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <sys/fcntl.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/ip.h>
#include <netinet/tcp.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <errno.h>
#include <ctype.h>

static const char *host = "localhost";
static unsigned short port = 3333;

static void usage(const char *prg)
{
  printf("Usage: %s: [host:port] CMD\n", prg);
}

static int parseHostPort(char *arg)
{
  char *portStr;

  host = arg;

  if ( (portStr = strchr(arg, ':')) ) {
    unsigned short p;
    *portStr++ = 0;
    if ( sscanf(portStr, "%hu", &p) )
      port = p;
  }
    
  return 1;
}

struct Matrix
{
  double *d;
  unsigned int n, m;  
};

static double *at(struct Matrix *m, int row, int col)
{
  return m->d + m->m*col + row;
}

void matrixInit(struct Matrix *m)
{
  m->d = 0;
  m->n = m->m = 0;
}


static ssize_t receiveData(void *d, size_t dataSize, FILE *f)
{  
  char *data = (char *)d;
  size_t nread = 0;
  ssize_t ret = 0;
  
  while ( nread < dataSize ) {
    ret = fread(data+nread, 1, dataSize-nread, f);
    if ( ret <= 0 ) return -1;
    nread += ret;
  }
  return nread;
}

int main(int argc, char *argv[])
{
  int sd;
  struct hostent *h;
  struct sockaddr_in sa;
  FILE *sock = 0;
  char *line = 0, *cmd = 0;
  size_t linelen = 0;
  unsigned int i, j;
  size_t dataSize;
  struct Matrix matrix;


  if (argc > 3 || argc < 2) {
    usage(argv[0]);
    exit(1);
  } else if (argc == 3) {
    if (!parseHostPort(argv[1]))
      exit(1);
    cmd = argv[2];
  } else 
    cmd = argv[1];

  if ( !(h = gethostbyname(host)) ) {
    herror("gethostbyname");
    exit(1);
  }
  
  if ( (sd = socket(PF_INET, SOCK_STREAM, 0)) < 0 ) {
    perror("socket");
    exit(1);
  }

  sa.sin_family = AF_INET;
  sa.sin_port = htons(port);
  memcpy(&sa.sin_addr, h->h_addr_list[0], sizeof(struct in_addr));
  
  fprintf(stderr, "Connecting to %s port %hu\n", inet_ntoa(sa.sin_addr), port);

  if ( connect(sd, (struct sockaddr *)&sa, sizeof(sa)) ) {
    perror("connect");
    exit(1);
  }  
  
  if ( !(sock = fdopen(sd, "r+")) ) {
    perror("fdopen");
    exit(1);
  }
  
  fprintf(stderr, "Connected, sending '%s'\n", cmd);
  fprintf(sock, "%s\n", cmd);
  fflush(sock);
  
  matrixInit(&matrix);
  
  if ( getline(&line, &linelen, sock) == -1 
       || sscanf(line, "MATRIX %u %u", &matrix.m, &matrix.n) != 2) {
    if (strstr(line, "ERROR") == line) 
      fprintf(stderr, "Got ERROR response.. check the command and try again!\n");
    else
      fprintf(stderr, "Cannot parse matrix dimensions, bailing.\n");
    exit(1);
  }
  
  fprintf(stderr, "Ok, matrix is %ux%u.  Reading matrix data...\n", matrix.m, matrix.n);
  matrix.d = calloc(matrix.m*matrix.n, sizeof(double));  
  
  if (!matrix.d) {
    fprintf(stderr, "Cannot allocate memory.\n");
    exit(1);
  }

  fprintf(sock, "READY\n");
  fflush(sock);
  dataSize = matrix.m*matrix.n*sizeof(double);  
  
  if ( receiveData(matrix.d, dataSize, sock) != (ssize_t)dataSize )  {
    fprintf(stderr, "receive error when reading matrix data, bailing\n");
    exit(1);
  }

  fprintf(stderr, "%u bytes read, OK.\n", dataSize);
  
  if ( getline(&line, &linelen, sock) == -1 ) {
    fprintf(stderr, "Did not receive any response, exiting.\n");
    exit(1);
  } else if (strcmp(line, "OK\n")) {
    fprintf(stderr, "Got OK.\n");
    exit(1);
  }

  for(i = 0; i < matrix.m; ++i ) {
    for (j = 0; j < matrix.n; ++j) 
      fprintf(stdout, "%lf ", *at(&matrix, i, j));
    fprintf(stdout, "\n");
  }
 
  fprintf(sock, "EXIT\n");
  fflush(sock);
  free(line);
  free(matrix.d);
  shutdown(sd, SHUT_RDWR);
  fclose(sock);
  return 0;
}
