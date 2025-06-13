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

static void trimTrailingSpaces(char *str)
{
  int last = strlen(str)-1;
  while (last > -1 && isspace(str[last])) str[last--] = 0;
}

int main(int argc, char *argv[])
{
  int sd;
  struct hostent *h;
  struct sockaddr_in sa;
  FILE *sock = 0;
  char *line = 0, *cmd = 0;
  size_t linelen = 0;


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
  
  if ( getline(&line, &linelen, sock) == -1 ) {
    fprintf(stderr, "Cannot parse result, bailing.\n");
    exit(1);
  }

  trimTrailingSpaces(line);

  fprintf(stderr, "Got:\n");
  fprintf(stdout, "%s\n", line);

  fprintf(sock, "EXIT\n");
  fflush(sock);

  free(line);
  shutdown(sd, SHUT_RDWR);
  fclose(sock);
  return 0;
}
