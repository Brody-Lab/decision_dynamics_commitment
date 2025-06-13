include /usr/rtlinux/rtl.mk

COMEDI_DIR=/usr/src/comedi
MODULE_COMPILE_FLAGS := $(CFLAGS) -I$(COMEDI_DIR)/include -DLINUX

# comment this out to disable debug
#DEBUG = -DDEBUG
DEBUG = -DNDEBUG
#DEBUG = -DDEBUG -DTIME_ISR
#DEBUG = -DNDEBUG -DTIME_ISR
# comment this out to disable Realtime
RTL = -DRTLINUX -D__RTL__ -I/usr/rtlinux/include
#RTL = -URTLINUX -U__RTL__

SRC_C = LinuxModule.c
SRC_CXX = \
	  LinuxGlue.cpp \
	  Hal4114.cpp     HalDevice.cpp      HalMixer.cpp      HalSampleClock.cpp \
          Hal8420.cpp     HalEEPROM.cpp      HalPlayMix.cpp    HalTimecode.cpp \
          HalAdapter.cpp  HalLStream.cpp     HalRecordMix.cpp  HalWaveDMADevice.cpp \
          HalDMA.cpp      HalMIDIDevice.cpp  HalRegister.cpp   HalWaveDevice.cpp
MOD_OBJS = \
	  LinuxModule.o \
	  LinuxGlue.o \
          Hal4114.o     HalDevice.o      HalMixer.o      HalSampleClock.o \
          Hal8420.o     HalEEPROM.o      HalPlayMix.o    HalTimecode.o \
          HalAdapter.o  HalLStream.o     HalRecordMix.o  HalWaveDMADevice.o \
          HalDMA.o      HalMIDIDevice.o  HalRegister.o   HalWaveDevice.o 
CC=gcc
CXX=g++
CFLAGS=-Wall -g
CXXFLAGS=-W -Wall -g -fno-rtti -nostdinc -fno-exceptions -nostdinc++ -fms-extensions
TARGET=LynxTWO-RT.o
DIV64_STUFF= _divdi3.oS _udivdi3.oS _moddi3.oS

.c.o:
	$(CC) -I../ ${MODULE_COMPILE_FLAGS} $(RTL) $(DEBUG) -c  $<

.cpp.o:
	$(CXX) -I../ -I. -I../Include ${MODULE_COMPILE_FLAGS} $(RTL) $(CXXFLAGS) $(DEBUG) -c $<

all: .deps $(TARGET) 

_divdi3.oS: 
	ar x `gcc -print-libgcc-file-name` _divdi3.oS

_udivdi3.oS:
	ar x `gcc -print-libgcc-file-name` _udivdi3.oS

_moddi3.oS:
	ar x `gcc --print-libgcc-file-name` _moddi3.oS

.deps: 
	-makedepend -- ${MODULE_COMPILE_FLAGS} $(RTL) $(DEBUG) -I. -I../include -- $(SRC_C) $(SRC_CXX)
	touch .deps

clean:
	rm -f *~ *.o *.oS Makefile.bak \*# .deps $(PRG)

$(TARGET): $(MOD_OBJS) $(DIV64_STUFF)
	ld -r -o $(TARGET) $(MOD_OBJS) $(DIV64_STUFF)


