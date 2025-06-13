/*
 * MATLAB Compiler: 4.9 (R2008b)
 * Date: Fri Mar 01 11:03:03 2019
 * Arguments: "-B" "macro_default" "-o" "GlobalControlSystem" "-W" "main" "-d"
 * "C:\ratter\ExperPort\Utility\GlobalControlSystem\GlobalControlSystem\src"
 * "-T" "link:exe" "-v"
 * "C:\ratter\ExperPort\Utility\GlobalControlSystem\GlobalControlSystem.m" "-a"
 * "C:\ratter\ExperPort\Utility\GlobalControlSystem\warn_running.m" "-a"
 * "C:\ratter\ExperPort\Utility\GlobalControlSystem\activate_buttons.m" "-a"
 * "C:\ratter\ExperPort\Utility\GlobalControlSystem\check_running.m" "-a"
 * "C:\ratter\ExperPort\Utility\GlobalControlSystem\GCS_Confirm.fig" "-a"
 * "C:\ratter\ExperPort\Utility\GlobalControlSystem\GCS_Confirm.m" "-a"
 * "C:\ratter\ExperPort\Utility\GlobalControlSystem\GCS_Message.fig" "-a"
 * "C:\ratter\ExperPort\Utility\GlobalControlSystem\GCS_Message.m" "-a"
 * "C:\ratter\ExperPort\Utility\GlobalControlSystem\GlobalControlSystem.fig"
 * "-a" "C:\ratter\ExperPort\Utility\GlobalControlSystem\GlobalControlSystem.m"
 * "-a" "C:\ratter\ExperPort\Utility\GlobalControlSystem\send_job.m" "-a"
 * "C:\ratter\ExperPort\Utility\GlobalControlSystem\update_status.m" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\LIBMYSQL.dll" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexw32" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexa64" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexa64.phenom" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexa64cuda" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexglx" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexmaci" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexmaci64" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexmaci.tiger" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\zlibwapi.dll" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\bdata.p" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\win64\libmysql.dll" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\win64\mym.mexw64" "-a"
 * "C:\ratter\ExperPort\Utility\GlobalControlSystem\GCS_Script.m" "-a"
 * "C:\ratter\ExperPort\Utility\GlobalControlSystem\GCS_Script.fig" "-a"
 * "C:\ratter\ExperPort\Utility\GlobalControlSystem\GCS_makecode.p" "-a"
 * "C:\ratter\ExperPort\Utility\GlobalControlSystem\GCS_checkcode.p" "-a"
 * "C:\ratter\ExperPort\Utility\GlobalControlSystem\GCS_checkpassword.p" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\get_network_info.m" "-a"
 * "C:\ratter\ExperPort\Utility\GlobalControlSystem\send_emergency_alert.m"
 * "-a" "C:\Program Files\Matlab\R2008b\toolbox\matlab\iofun\sendmail.m" "-a"
 * "C:\Program Files\Matlab\R2008b\toolbox\matlab\uitools\setpref.m" "-a"
 * "C:\Program Files\Matlab\R2008b\toolbox\matlab\general\java.m" "-a"
 * "C:\ratter\ExperPort\Utility\AutomatedEmails\set_email_sender.p" "-a"
 * "C:\ratter\ExperPort\Utility\GlobalControlSystem\GCS_live_update.m" 
 */

#include <stdio.h>
#include "mclmcrrt.h"
#ifdef __cplusplus
extern "C" {
#endif

extern mclComponentData __MCC_GlobalControlSystem_component_data;

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
#ifndef LIB_GlobalControlSystem_C_API 
#define LIB_GlobalControlSystem_C_API /* No special import/export declaration */
#endif

LIB_GlobalControlSystem_C_API 
bool MW_CALL_CONV GlobalControlSystemInitializeWithHandlers(
    mclOutputHandlerFcn error_handler,
    mclOutputHandlerFcn print_handler
)
{
  if (_mcr_inst != NULL)
    return true;
  if (!mclmcrInitialize())
    return false;
  if (!mclInitializeComponentInstanceWithEmbeddedCTF(&_mcr_inst,
                                                     &__MCC_GlobalControlSystem_component_data,
                                                     true, NoObjectType,
                                                     ExeTarget, error_handler,
                                                     print_handler, 11532033, NULL))
    return false;
  return true;
}

LIB_GlobalControlSystem_C_API 
bool MW_CALL_CONV GlobalControlSystemInitialize(void)
{
  return GlobalControlSystemInitializeWithHandlers(mclDefaultErrorHandler,
                                                   mclDefaultPrintHandler);
}

LIB_GlobalControlSystem_C_API 
void MW_CALL_CONV GlobalControlSystemTerminate(void)
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
  __MCC_GlobalControlSystem_component_data.path_to_component = path_to_component; 
  if (!GlobalControlSystemInitialize()) {
    return -1;
  }
  argc = mclSetCmdLineUserData(mclGetID(_mcr_inst), argc, argv);
  _retval = mclMain(_mcr_inst, argc, argv, "GlobalControlSystem", 1);
  if (_retval == 0 /* no error */) mclWaitForFiguresToDie(NULL);
  GlobalControlSystemTerminate();
  mclTerminateApplication();
  return _retval;
}

int main(int argc, const char **argv)
{
  if (!mclInitializeApplication(
    __MCC_GlobalControlSystem_component_data.runtime_options,
    __MCC_GlobalControlSystem_component_data.runtime_option_count))
    return 0;
  
  return mclRunMain(run_main, argc, argv);
}
