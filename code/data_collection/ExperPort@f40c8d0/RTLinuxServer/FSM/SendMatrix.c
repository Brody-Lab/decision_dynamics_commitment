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
  printf("Usage: %s: [host:port]\n", prg);
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

int main(int argc, char *argv[])
{
  int sd;
  struct hostent *h;
  struct sockaddr_in sa;
  FILE *sock = 0;
  char *line = 0;
  size_t linelen = 0;
  unsigned int i, j, num;

  if (argc > 2) {
    usage(argv[0]);
    exit(1);
  } else if (argc == 2) {
    if (!parseHostPort(argv[1]))
      exit(1);
  }

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
  
  fprintf(stderr, "Connected, enter matrix MxN dimensions, ie \"128 10\" for 128x10\n");

  struct Matrix matrix;
  matrixInit(&matrix);

  if ( fscanf(stdin, "%u %u", &matrix.m, &matrix.n) != 2) {
    fprintf(stderr, "Cannot parse matrix dimensions, bailing.\n");
    exit(1);
  }
  
  fprintf(stderr, "Ok, matrix is %ux%u.  Enter matrix\n", matrix.m, matrix.n);
  matrix.d = calloc(matrix.m*matrix.n, sizeof(double));  

  if (!matrix.d) {
    fprintf(stderr, "Cannot allocate memory.\n");
    exit(1);
  }

  for(i = 0; i < matrix.m; ++i ) {
    for (j = 0; j < matrix.n; ++j) 
      if ( !fscanf(stdin, "%lf", at(&matrix, i, j)) ) break;
    if (j != matrix.n) break;
  }
  
  if (i != matrix.m || j != matrix.n) {
    fprintf(stderr, "Error reading matrix data at %d,%d .. bailing.\n",i,j);
    exit(1);
  }

  fprintf(stderr, "Sending %ux%u matrix...\n", matrix.m, matrix.n);
  
  if ( fprintf(sock, "SET STATE MATRIX %u %u\n", matrix.m, matrix.n) <= 0 ) {
    fprintf(stderr, "Error writing to socket\n");
    exit(1);
  }
  
  /* Grab the 'READY' */
  if ( getline(&line, &linelen, sock) == -1 ) {
    perror("getline");
    exit(1);
  }

  num = matrix.m*matrix.n;
  if ( fwrite(matrix.d, sizeof(*matrix.d), num, sock) != num ) {
    perror("fwrite");
    exit(1);
  }
  if ( getline(&line, &linelen, sock) == -1 ) {
    fprintf(stderr, "Did not receive any response, exiting.\n");
    exit(1);
  } else if (strcmp(line, "OK\n")) {
    fprintf(stderr, "Matrix rejected.\n");
    exit(1);
  }

  fprintf(stderr, "%d bytes sent, OK.\n", num*sizeof(*matrix.d));
  fprintf(sock, "EXIT\n");
  fflush(sock);
  free(line);
  free(matrix.d);
  shutdown(sd, SHUT_RDWR);
  fclose(sock);
  return 0;
}
