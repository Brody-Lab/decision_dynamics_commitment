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

static const char *host = "localhost", *filename = "";
static unsigned short port = 3334;
int id, chans, bits, rate, bytes;
FILE *f = 0;

static void usage(const char *prg)
{
  printf("Usage: %s: filename id chans bits rate [host:port]\n", prg);
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

static int parseParms(char **argv)
{
  struct stat statbuf;

  filename = *argv++;
  id = atoi(*argv++);
  chans = atoi(*argv++);
  bits = atoi(*argv++);
  rate = atoi(*argv++);
  if (!id || !chans || !bits || !rate || stat(filename, &statbuf) || !(f = fopen(filename, "r")))
    return 0;
  bytes = statbuf.st_size;
  return 1;
}

int main(int argc, char *argv[])
{
  int sd;
  struct hostent *h;
  struct sockaddr_in sa;
  FILE *sock = 0;
  char *line = 0;
  size_t linelen = 0;
  unsigned int num, sent = 0;

  if (argc < 6 || argc > 7) {
    usage(argv[0]);
    exit(1);
  } else if (argc == 7) {
    if (!parseHostPort(argv[6]) || !parseParms(argv+1)) {
      usage(argv[0]);
      exit(1);
    }
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
  
  fprintf(stderr, "Connected sending file %s size: %d as id: %d\n", filename, bytes, id);

  
  if ( fprintf(sock, "SET SOUND %u %u %u %u %u\n", id, bytes, bits, chans, rate) <= 0 ) {
    fprintf(stderr, "Error writing to socket\n");
    exit(1);
  }
  
  /* Grab the 'READY' */
  if ( getline(&line, &linelen, sock) == -1 ) {
    perror("getline");
    exit(1);
  }
  
  while (!feof(f)) {
    char buf[4096];
    num = fread(buf, 1, sizeof(buf), f);
    if ( fwrite(buf, 1, num, sock) != num ) {
      perror("fwrite");
      exit(1);
    }
    sent += num;
  }

  if ( getline(&line, &linelen, sock) == -1 ) {
    fprintf(stderr, "Did not receive any response, exiting.\n");
    exit(1);
  } else if (strcmp(line, "OK\n")) {
    fprintf(stderr, "Sound rejected.\n");
    exit(1);
  }

  fprintf(stderr, "%u bytes sent, OK.\n", sent);
  fprintf(sock, "EXIT\n");
  fflush(sock);
  free(line);
  shutdown(sd, SHUT_RDWR);
  fclose(sock);
  return 0;
}
