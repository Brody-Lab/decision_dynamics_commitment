/*
 * MATLAB Compiler: 4.9 (R2008b)
 * Date: Fri May 04 15:11:58 2018
 * Arguments: "-B" "macro_default" "-o" "Room_Turnover_Indicator" "-W"
 * "WinMain:Room_Turnover_Indicator" "-d"
 * "C:\ratter\ExperPort\Utility\Room_Turnover_Indicator\src" "-T" "link:exe"
 * "-v" "C:\ratter\ExperPort\Utility\room_turnover_indicator.m" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\bdata.p" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\LIBMYSQL.dll" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\libmysqlclient.15.dylib" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\libmysqlclient.dylib" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\libmysqlclient.so.15" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\libmysqlclient.so.16" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.cpp" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.h" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.m" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexa64" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexa64.phenom" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexa64cuda" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexglx" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexmaci" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexmaci.tiger" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexmaci64" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexw32" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\zlibwapi.dll" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\win64\libmysql.dll" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\win64\mym.mexw64" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\win64\zlibwapi.dll" 
 */

#include <stdio.h>
#include "mclmcrrt.h"
#ifdef __cplusplus
extern "C" {
#endif

extern mclComponentData __MCC_Room_Turnover_Indicator_component_data;

#ifdef __cplusplus
}
#endif

static HMCRINSTANCE _mcr_inst = NULL;


#ifdef __cplusplus
extern "C" {
#endif

static int mclDefaultPrintHandler(const char *s)
{
  return mclWrite(1 /* stdout */, s, sizeof(char)*strlen(s));
}

#ifdef __cplusplus
} /* End extern "C" block */
#endif

#ifdef __cplusplus
extern "C" {
#endif

static int mclDefaultErrorHandler(const char *s)
{
  int written = 0;
  size_t len = 0;
  len = strlen(s);
  written = mclWrite(2 /* stderr */, s, sizeof(char)*len);
  if (len > 0 && s[ len-1 ] != '\n')
    written += mclWrite(2 /* stderr */, "\n", sizeof(char));
  return written;
}

#ifdef __cplusplus
} /* End extern "C" block */
#endif

/* This symbol is defined in shared libraries. Define it here
 * (to nothing) in case this isn't a shared library. 
 */
#ifndef LIB_Room_Turnover_Indicator_C_API 
#define LIB_Room_Turnover_Indicator_C_API /* No special import/export declaration */
#endif

LIB_Room_Turnover_Indicator_C_API 
bool MW_CALL_CONV Room_Turnover_IndicatorInitializeWithHandlers(
    mclOutputHandlerFcn error_handler,
    mclOutputHandlerFcn print_handler
)
{
  if (_mcr_inst != NULL)
    return true;
  if (!mclmcrInitialize())
    return false;
  if (!mclInitializeComponentInstanceWithEmbeddedCTF(&_mcr_inst,
                                                     &__MCC_Room_Turnover_Indicator_component_data,
                                                     true, NoObjectType,
                                                     ExeTarget, error_handler,
                                                     print_handler, 4388214, NULL))
    return false;
  return true;
}

LIB_Room_Turnover_Indicator_C_API 
bool MW_CALL_CONV Room_Turnover_IndicatorInitialize(void)
{
  return Room_Turnover_IndicatorInitializeWithHandlers(mclDefaultErrorHandler,
                                                       mclDefaultPrintHandler);
}

LIB_Room_Turnover_Indicator_C_API 
void MW_CALL_CONV Room_Turnover_IndicatorTerminate(void)
{
  if (_mcr_inst != NULL)
    mclTerminateInstance(&_mcr_inst);
}

int run_main(int argc, const char **argv)
{
  int _retval;
  /* Generate and populate the path_to_component. */
  char path_to_component[(PATH_MAX*2)+1];
  separatePathName(argv[0], path_to_component, (PATH_MAX*2)+1);
  __MCC_Room_Turnover_Indicator_component_data.path_to_component = path_to_component; 
  if (!Room_Turnover_IndicatorInitialize()) {
    return -1;
  }
  argc = mclSetCmdLineUserData(mclGetID(_mcr_inst), argc, argv);
  _retval = mclMain(_mcr_inst, argc, argv, "room_turnover_indicator", 0);
  if (_retval == 0 /* no error */) mclWaitForFiguresToDie(NULL);
  Room_Turnover_IndicatorTerminate();
#if defined( _MSC_VER)
  PostQuitMessage(0);
#endif
  mclTerminateApplication();
  return _retval;
}

#if defined( _MSC_VER)

#define argc __argc
#define argv __argv

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPTSTR lpCmdLine, int nCmdShow)
#else
int main(int argc, const char **argv)

#endif
{
  if (!mclInitializeApplication(
    __MCC_Room_Turnover_Indicator_component_data.runtime_options,
    __MCC_Room_Turnover_Indicator_component_data.runtime_option_count))
    return 0;
  
  return mclRunMain(run_main, argc, argv);
}
