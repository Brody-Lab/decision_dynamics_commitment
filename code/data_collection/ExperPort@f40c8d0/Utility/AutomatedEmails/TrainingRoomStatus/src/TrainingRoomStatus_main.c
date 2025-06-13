/*
 * MATLAB Compiler: 4.9 (R2008b)
 * Date: Tue Aug 20 11:41:38 2019
 * Arguments: "-B" "macro_default" "-o" "TrainingRoomStatus" "-W" "main" "-d"
 * "C:\ratter\ExperPort\Utility\AutomatedEmails\TrainingRoomStatus\src" "-T"
 * "link:exe" "-v"
 * "C:\ratter\ExperPort\Utility\AutomatedEmails\training_room_status_wrapper.m"
 * "-a" "C:\ratter\ExperPort\Utility\AutomatedEmails\training_room_status.m"
 * "-a" "C:\ratter\ExperPort\Utility\GlobalControlSystem\check_running.m" "-a"
 * "C:\ratter\ExperPort\Utility\MassMeister\update_lists.m" "-a"
 * "C:\ratter\ExperPort\Utility\WaterMeister\init_check.m" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\bdata.p" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexw32" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\LIBMYSQL.dll" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\zlibwapi.dll" "-a"
 * "C:\ratter\ExperPort\Modules\bSettings.m" "-a"
 * "C:\ratter\ExperPort\Settings\Settings_Custom.conf" 
 */

#include <stdio.h>
#include "mclmcrrt.h"
#ifdef __cplusplus
extern "C" {
#endif

extern mclComponentData __MCC_TrainingRoomStatus_component_data;

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
#ifndef LIB_TrainingRoomStatus_C_API 
#define LIB_TrainingRoomStatus_C_API /* No special import/export declaration */
#endif

LIB_TrainingRoomStatus_C_API 
bool MW_CALL_CONV TrainingRoomStatusInitializeWithHandlers(
    mclOutputHandlerFcn error_handler,
    mclOutputHandlerFcn print_handler
)
{
  if (_mcr_inst != NULL)
    return true;
  if (!mclmcrInitialize())
    return false;
  if (!mclInitializeComponentInstanceWithEmbeddedCTF(&_mcr_inst,
                                                     &__MCC_TrainingRoomStatus_component_data,
                                                     true, NoObjectType,
                                                     ExeTarget, error_handler,
                                                     print_handler, 1108268, NULL))
    return false;
  return true;
}

LIB_TrainingRoomStatus_C_API 
bool MW_CALL_CONV TrainingRoomStatusInitialize(void)
{
  return TrainingRoomStatusInitializeWithHandlers(mclDefaultErrorHandler,
                                                  mclDefaultPrintHandler);
}

LIB_TrainingRoomStatus_C_API 
void MW_CALL_CONV TrainingRoomStatusTerminate(void)
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
  __MCC_TrainingRoomStatus_component_data.path_to_component = path_to_component; 
  if (!TrainingRoomStatusInitialize()) {
    return -1;
  }
  argc = mclSetCmdLineUserData(mclGetID(_mcr_inst), argc, argv);
  _retval = mclMain(_mcr_inst, argc, argv, "training_room_status_wrapper", 0);
  if (_retval == 0 /* no error */) mclWaitForFiguresToDie(NULL);
  TrainingRoomStatusTerminate();
  mclTerminateApplication();
  return _retval;
}

int main(int argc, const char **argv)
{
  if (!mclInitializeApplication(
    __MCC_TrainingRoomStatus_component_data.runtime_options,
    __MCC_TrainingRoomStatus_component_data.runtime_option_count))
    return 0;
  
  return mclRunMain(run_main, argc, argv);
}
