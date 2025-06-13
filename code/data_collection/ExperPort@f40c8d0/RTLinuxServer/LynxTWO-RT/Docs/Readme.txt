                HAL DEVELOPMENT KIT
             Lynx Studio Technology, Inc.
                  Version 1.00.01
             Release Date May 16, 2003

               C O N F I D E N T I A L



HISTORY

Date	  Version Description
------------------------------------------------------------------------
Oct 19 04 1.00.02 Added AES16 support
May 16 03 1.00.01 Added missing Include folder, refreshed with current source
Mar  4 03 1.00.00 Initial Release


The Hal Development Kit provides source code, documentation, and a
demonstration program for the development of drivers and low-level
applications for the LynxTWO/L22 digital audio cards.

The kit is based on the hardware abstraction layer (HAL) module which
provides an API function set for communcation and control of the LynxTWO.

A Windows 95/98/ME demonstration program, HalTest, is included to illustrate
the methods and the sequence of function calls required for proper operation.
The source to HalTest is supplied as example code, but could be part of any
driver or application. 

This version of HalTest does not use interrupts for audio transfers, but
instead polls status bits. In most cases, drivers and other real-time
applications mandate the use of interrupts to insure continuous audio. 

Refer to the function, CTestPage::StartPlayback(), for an example
of how to transfer audio using the polling method.


The kit includes the following files:

NAME			
------------------------------------------------------------------------
Readme.txt		    This file
LynxTWO Interface.doc       Description of LynxTWO registers.  Not really
                            needed for writing a driver, but can be
                            helpful.
AES16 Interface.doc			Description of AES16 registers.

LynxTWO Folder
--------------
Hal8420.cpp
HalAdapter.cpp
HalDevice.cpp
HalDMA.cpp
HalEEPROM.cpp
HalLStream.cpp
HalMIDIDevice.cpp
HalMixer.cpp
HalPlayMix.cpp
HalRecordMix.cpp
HalRegister.cpp
HalSampleClock.cpp
HalTimecode.cpp
HalWaveDevice.cpp
HalWaveDMADevice.cpp
Hal.h
Hal8420.h
HalAdapter.h
HalDevice.h
HalDMA.h
HalEnv.h
HalLStream.h
HalMIDIDevice.h
HalMixer.h
HalPlayMix.h
HalRecordMix.h
HalRegister.h
HalSampleClock.h
HalTimecode.h
HalWaveDevice.h
HalWaveDMADevice.h
LynxTWO.h

HalTest Folder
--------------
AdapterPage.cpp
Callback.cpp
Debug.cpp
Fader.cpp
HalTest.cpp
HalTestDlg.cpp
MediaFile.cpp
OutputsPage.cpp
OutSourceSelect.cpp
PCIBios.cpp
RecordPage.cpp
StdAfx.cpp
TestPage.cpp
VUMeter.cpp
WaveFile.cpp
HalTest.dsp
HalTest.dsw
AdapterPage.h
Callback.h
Fader.h
HalTest.h
HalTestDlg.h
MediaFile.h
OutputsPage.h
OutSourceSelect.h
PCIBios.h
RecordPage.h
resource.h
StdAfx.h
TestPage.h
VendorID.h
VUMeter.h
WaveFile.h
resource.hm
HalTest.rc
LynxMem.VxD                 No source code included.

Include Folder
--------------
DrvDebug.h
MMReg.h                     Latest version of the standard Microsoft file
SharedControls.h

Compiling HalTest
-----------------
The HalTest program can be compiled under Windows 95/98/ME using the 
Microsoft Visual C++ 6.0 compiler and linker.  All C source and header files
are required to build the executable.

- end -
