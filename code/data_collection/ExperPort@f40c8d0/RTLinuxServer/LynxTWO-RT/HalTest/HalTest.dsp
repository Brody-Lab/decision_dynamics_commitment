# Microsoft Developer Studio Project File - Name="HalTest" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Application" 0x0101

CFG=HalTest - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "HalTest.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "HalTest.mak" CFG="HalTest - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "HalTest - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE "HalTest - Win32 Debug" (based on "Win32 (x86) Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/Lynx/HalTest", XOBAAAAA"
# PROP Scc_LocalPath "."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "HalTest - Win32 Release"

# PROP BASE Use_MFC 6
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 6
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MD /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_AFXDLL" /Yu"stdafx.h" /FD /c
# ADD CPP /nologo /MD /W3 /GX /O2 /I "..\Include" /I "..\LynxTWO" /D "NDEBUG" /D "WIN32" /D "_WINDOWS" /D "_AFXDLL" /D "_MBCS" /D "WIN32USER" /D "DEBUG" /FR /Yu"StdAfx.h" /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG" /d "_AFXDLL"
# ADD RSC /l 0x409 /d "NDEBUG" /d "_AFXDLL"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 /nologo /subsystem:windows /machine:I386
# ADD LINK32 winmm.lib /nologo /subsystem:windows /machine:I386

!ELSEIF  "$(CFG)" == "HalTest - Win32 Debug"

# PROP BASE Use_MFC 6
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 6
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MDd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_AFXDLL" /Yu"stdafx.h" /FD /GZ /c
# ADD CPP /nologo /MDd /W3 /Gm /GX /ZI /Od /I "..\LynxTWO" /I "..\Include" /I "\NTDDK\Inc" /D "_DEBUG" /D "WIN32" /D "_WINDOWS" /D "_AFXDLL" /D "_MBCS" /D "WIN32USER" /D "DEBUG" /FR /Yu"StdAfx.h" /FD /GZ /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG" /d "_AFXDLL"
# ADD RSC /l 0x409 /d "_DEBUG" /d "_AFXDLL"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 /nologo /subsystem:windows /debug /machine:I386 /pdbtype:sept
# ADD LINK32 winmm.lib /nologo /subsystem:windows /profile /debug /machine:I386

!ENDIF 

# Begin Target

# Name "HalTest - Win32 Release"
# Name "HalTest - Win32 Debug"
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=.\AdapterPage.h
# End Source File
# Begin Source File

SOURCE=.\Callback.h
# End Source File
# Begin Source File

SOURCE=..\Include\DrvDebug.h
# End Source File
# Begin Source File

SOURCE=.\Fader.h
# End Source File
# Begin Source File

SOURCE=.\HalTest.h
# End Source File
# Begin Source File

SOURCE=.\HalTestDlg.h
# End Source File
# Begin Source File

SOURCE=.\MediaFile.h
# End Source File
# Begin Source File

SOURCE=..\Include\MixStrID.h
# End Source File
# Begin Source File

SOURCE=.\OutputsPage.h
# End Source File
# Begin Source File

SOURCE=.\OutSourceSelect.h
# End Source File
# Begin Source File

SOURCE=.\PCIBios.h
# End Source File
# Begin Source File

SOURCE=.\PlayPage.h
# End Source File
# Begin Source File

SOURCE=.\RecordPage.h
# End Source File
# Begin Source File

SOURCE=.\Resource.h
# End Source File
# Begin Source File

SOURCE=.\StdAfx.h
# End Source File
# Begin Source File

SOURCE=.\TestPage.h
# End Source File
# Begin Source File

SOURCE=.\VendorID.h
# End Source File
# Begin Source File

SOURCE=.\VUMeter.h
# End Source File
# Begin Source File

SOURCE=.\WaveFile.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# Begin Source File

SOURCE=.\res\Fader.bmp
# End Source File
# Begin Source File

SOURCE=.\res\Forward.bmp
# End Source File
# Begin Source File

SOURCE=.\res\ForwardOff.bmp
# End Source File
# Begin Source File

SOURCE=.\res\ForwardOn.bmp
# End Source File
# Begin Source File

SOURCE=.\res\Gradient.bmp
# End Source File
# Begin Source File

SOURCE=.\res\HalTest.ico
# End Source File
# Begin Source File

SOURCE=.\res\HandPoint.cur
# End Source File
# Begin Source File

SOURCE=.\res\LEDGreen.bmp
# End Source File
# Begin Source File

SOURCE=.\res\LEDOff.bmp
# End Source File
# Begin Source File

SOURCE=.\res\LEDRed.bmp
# End Source File
# Begin Source File

SOURCE=.\res\LEDYellow.bmp
# End Source File
# Begin Source File

SOURCE=.\res\Mixer.ico
# End Source File
# Begin Source File

SOURCE=.\res\ReverseOff.bmp
# End Source File
# Begin Source File

SOURCE=.\res\ReverseOn.bmp
# End Source File
# Begin Source File

SOURCE=.\res\VUOff.bmp
# End Source File
# Begin Source File

SOURCE=.\res\VUOn.bmp
# End Source File
# End Group
# Begin Group "LynxTWO"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\LynxTWO\Hal.h
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\Hal8420.cpp
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\Hal8420.h
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\HalAdapter.cpp
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\HalAdapter.h
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\HalDevice.cpp
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\HalDevice.h
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\HalDMA.cpp
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\HalDMA.h
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\HalEEPROM.cpp
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\HalEnv.h
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\HalLStream.cpp
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\HalLStream.h
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\HalMIDIDevice.cpp
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\HalMIDIDevice.h
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\HalMixer.cpp
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\HalMixer.h
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\HalPlayMix.cpp
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\HalPlayMix.h
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\HalRecordMix.cpp
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\HalRecordMix.h
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\HalRegister.cpp
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\HalRegister.h
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\HalSampleClock.cpp
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\HalSampleClock.h
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\HalTimecode.cpp
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\HalTimecode.h
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\HalWaveDevice.cpp
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\HalWaveDevice.h
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\HalWaveDMADevice.cpp
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\HalWaveDMADevice.h
# End Source File
# Begin Source File

SOURCE=..\LynxTWO\LynxTWO.h
# End Source File
# Begin Source File

SOURCE=..\Include\SharedControls.h
# End Source File
# End Group
# Begin Source File

SOURCE=.\AdapterPage.cpp
# End Source File
# Begin Source File

SOURCE=.\Callback.cpp
# End Source File
# Begin Source File

SOURCE=.\Debug.cpp
# End Source File
# Begin Source File

SOURCE=.\Fader.cpp
# End Source File
# Begin Source File

SOURCE=.\HalTest.cpp
# End Source File
# Begin Source File

SOURCE=.\HalTest.rc
# End Source File
# Begin Source File

SOURCE=.\HalTestDlg.cpp
# End Source File
# Begin Source File

SOURCE=.\MediaFile.cpp
# End Source File
# Begin Source File

SOURCE=.\OutputsPage.cpp
# End Source File
# Begin Source File

SOURCE=.\OutSourceSelect.cpp
# End Source File
# Begin Source File

SOURCE=.\PCIBios.cpp
# End Source File
# Begin Source File

SOURCE=.\RecordPage.cpp
# End Source File
# Begin Source File

SOURCE=.\StdAfx.cpp
# ADD CPP /Yc"stdafx.h"
# End Source File
# Begin Source File

SOURCE=.\TestPage.cpp
# End Source File
# Begin Source File

SOURCE=.\VUMeter.cpp
# End Source File
# Begin Source File

SOURCE=.\WaveFile.cpp
# End Source File
# End Target
# End Project
