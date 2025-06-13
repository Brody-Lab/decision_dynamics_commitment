include /usr/rtlinux/rtl.mk

COMEDI_DIR=/usr/src/comedi
MODULE_COMPILE_FLAGS := $(CFLAGS) -I$(COMEDI_DIR)/include

TLSF = libtlsf/src
TLSFLIB = $(TLSF)/tlsf.o

LYNX_TWO_RT = ../LynxTWO-RT
SRC_C = LynxTrig.c ChanMapper.c 
SRC_CXX = LynxTrigServer.cpp rtos_utility.cpp
PRG_OBJS = LynxTrigServer.o rtos_utility.o
MOD_OBJS = LynxTrig.o ChanMapper.o 
MOD = LynxTrig-RT.o
PRG = LynxTrigServer
CXX=g++
CXXFLAGS:= -W -Wall -g
CFLAGS:= -Wall -g
COSINE = s_cos.o

.c.o:
	$(CC) $(CFLAGS) ${MODULE_COMPILE_FLAGS} -I$(LYNX_TWO_RT) -c  $<

.cpp.o:
	$(CXX) $(CXXFLAGS) -c $<

all: .deps $(MOD) $(PRG) 

$(COSINE): /usr/lib/libm.a
	ar x /usr/lib/libm.a $(COSINE)

$(MOD):	$(MOD_OBJS) $(TLSFLIB) $(COSINE)
	ld -r -o $(MOD) $(MOD_OBJS) $(TLSFLIB) $(COSINE)

$(TLSFLIB):
	make -C $(TLSF)

$(PRG): $(PRG_OBJS)
	$(CXX) $(CXXFLAGS) -o $@ $(PRG_OBJS)

.deps: 
	-makedepend -- ${MODULE_COMPILE_FLAGS} -I$(LYNX_TWO_RT) -- $(SRC_C) $(SRC_CXX)
	touch .deps

clean:
	rm -f *~ *.o Makefile.bak .deps $(PRG)
	make -C $(TLSF) clean

