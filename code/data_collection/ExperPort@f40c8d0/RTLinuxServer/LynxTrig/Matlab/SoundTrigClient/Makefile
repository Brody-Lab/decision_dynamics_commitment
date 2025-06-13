
CFLAGS = -W -Wall -g
CXXFLAGS = ${CFLAGS} -D TESTNETCLIENT
CC = gcc
CXX = g++

OBJS = Socket.o NetClient.o

all: $(OBJS) TestNetClient

.cpp.o: 
	$(CXX) $(CXXFLAGS) -c $<

TestNetClient: $(OBJS)
	g++ -o TestNetClient -g $(OBJS)

clean:
	rm -f *~ *.o TestNetClient
