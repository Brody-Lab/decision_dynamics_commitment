MODULE_COMPILE_FLAGS=-DMODULE -D__KERNEL__ -I/lib/modules/`uname -r`/build/include -Wno-system-headers  -Wall -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -pipe -mpreferred-stack-boundary=2 -D_LOOSE_KERNEL_NAMES -O2

SRC_C = LynxTWO-RT.c
SRC_CXX = 
PRG_OBJS = 
MOD_OBJS = LynxTWO-RT.o
PRG = 
CC=gcc
CXX=g++
CXXFLAGS=-W -Wall -g

.c.o:
	$(CC) ${MODULE_COMPILE_FLAGS} -c  $<

.cpp.o:
	$(CXX) $(CXXFLAGS) -c $<

all: .deps $(MOD_OBJS) $(PRG) 

$(PRG): $(PRG_OBJS)
	$(CXX) $(CXXFLAGS) -lpthread -o $@ $(PRG_OBJS)

.deps: 
	-makedepend -- ${MODULE_COMPILE_FLAGS} -- $(SRC_C)
#	-makedepend $(SRC_CXX)
	touch .deps

clean:
	rm -f *~ *.o Makefile.bak .deps $(PRG)

