include /usr/rtlinux/rtl.mk

COMEDI_DIR=/usr/src/comedi
MODULE_COMPILE_FLAGS := $(CFLAGS) -I$(COMEDI_DIR)/include

SRC_C = RatExpFSM.c softtask.c
SRC_CXX = RatExpFSMServer.cpp rtos_utility.cpp
PRG_OBJS = RatExpFSMServer.o rtos_utility.o
MOD_OBJS = RatExpFSM.o softtask.o
MOD = RatExpFSM
PRG = RatExpFSMServer
CXX=g++
CXXFLAGS=-W -Wall -g

.c.o:
	$(CC) ${MODULE_COMPILE_FLAGS} -c  $<

.cpp.o:
	$(CXX) $(CXXFLAGS) -c $<

all: .deps $(MOD) $(PRG) 

$(MOD): $(MOD_OBJS)
	ld -r -o $(MOD) $(MOD_OBJS)

$(PRG): $(PRG_OBJS)
	$(CXX) $(CXXFLAGS) -lpthread -o $@ $(PRG_OBJS)

.deps: 
	-makedepend -- ${MODULE_COMPILE_FLAGS} -I../LynxTrig -- $(SRC_C) $(SRC_CXX)
	touch .deps

clean:
	rm -f *~ *.o Makefile.bak .deps $(PRG)

