/*
 * MATLAB Compiler: 4.9 (R2008b)
 * Date: Thu Aug 22 11:52:17 2019
 * Arguments: "-B" "macro_default" "-o" "MassMeister" "-W" "main" "-d"
 * "C:\ratter\ExperPort\Utility\MassMeister\MassMeister\src" "-T" "link:exe"
 * "-v" "C:\ratter\ExperPort\Utility\MassMeister\MassMeister.m" "-a"
 * "C:\ratter\ExperPort\Utility\MassMeister\update_ratname.m" "-a"
 * "C:\ratter\ExperPort\Utility\MassMeister\get_colors.m" "-a"
 * "C:\ratter\ExperPort\Utility\MassMeister\get_newrats.m" "-a"
 * "C:\ratter\ExperPort\Utility\MassMeister\jump_to_empty.m" "-a"
 * "C:\ratter\ExperPort\Utility\MassMeister\load_settings.m" "-a"
 * "C:\ratter\ExperPort\Utility\MassMeister\MassMeister.fig" "-a"
 * "C:\ratter\ExperPort\Utility\MassMeister\MassMeister_Properties.fig" "-a"
 * "C:\ratter\ExperPort\Utility\MassMeister\MassMeister_Properties.m" "-a"
 * "C:\ratter\ExperPort\Utility\MassMeister\Properties.mat" "-a"
 * "C:\ratter\ExperPort\Utility\MassMeister\update_lists.m" "-a"
 * "C:\ratter\ExperPort\Utility\MassMeister\update_names.m" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\zlibwapi.dll" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\bdata.p" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\LIBMYSQL.dll" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.m" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexw32" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexa64" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexmaci" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexmaci64" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexmaci.tiger" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\win64\libmysql.dll" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\win64\mym.mexw64" "-a"
 * "C:\ratter\ExperPort\Modules\Settings.m" "-a"
 * "C:\ratter\ExperPort\Settings\Settings_Default.conf" "-a"
 * "C:\ratter\ExperPort\Settings\Settings_BrodylabRig.conf" "-a"
 * "C:\ratter\ExperPort\Settings\Settings_Custom.conf" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexa64.phenom" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexa64cuda" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexglx" "-a"
 * "C:\ratter\ExperPort\Utility\MassMeister\send_massdrop_text.m" "-a"
 * "C:\Program Files\Matlab\R2008b\toolbox\matlab\iofun\sendmail.m" "-a"
 * "C:\Program Files\Matlab\R2008b\toolbox\matlab\uitools\setpref.m" "-a"
 * "C:\Program Files\Matlab\R2008b\toolbox\matlab\general\java.m" "-a"
 * "C:\ratter\ExperPort\Utility\AutomatedEmails\set_email_sender.p" "-a"
 * "C:\ratter\ExperPort\Utility\MassMeister\get_movedrats.m" "-a"
 * "C:\ratter\Rigscripts\startup.m" "-a"
 * "C:\ratter\ExperPort\Utility\MassMeister\MM_get_tech_instructions.m" "-a"
 * "C:\ratter\ExperPort\Modules\bSettings.m" 
 */

#include <stdio.h>
#include "mclmcrrt.h"
#ifdef __cplusplus
extern "C" {
#endif

extern mclComponentData __MCC_MassMeister_component_data;

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
#ifndef LIB_MassMeister_C_API 
#define LIB_MassMeister_C_API /* No special import/export declaration */
#endif

LIB_MassMeister_C_API 
bool MW_CALL_CONV MassMeisterInitializeWithHandlers(
    mclOutputHandlerFcn error_handler,
    mclOutputHandlerFcn print_handler
)
{
  if (_mcr_inst != NULL)
    return true;
  if (!mclmcrInitialize())
    return false;
  if (!mclInitializeComponentInstanceWithEmbeddedCTF(&_mcr_inst,
                                                     &__MCC_MassMeister_component_data,
                                                     true, NoObjectType,
                                                     ExeTarget, error_handler,
                                                     print_handler, 8539352, NULL))
    return false;
  return true;
}

LIB_MassMeister_C_API 
bool MW_CALL_CONV MassMeisterInitialize(void)
{
  return MassMeisterInitializeWithHandlers(mclDefaultErrorHandler,
                                           mclDefaultPrintHandler);
}

LIB_MassMeister_C_API 
void MW_CALL_CONV MassMeisterTerminate(void)
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
  __MCC_MassMeister_component_data.path_to_component = path_to_component; 
  if (!MassMeisterInitialize()) {
    return -1;
  }
  argc = mclSetCmdLineUserData(mclGetID(_mcr_inst), argc, argv);
  _retval = mclMain(_mcr_inst, argc, argv, "MassMeister", 1);
  if (_retval == 0 /* no error */) mclWaitForFiguresToDie(NULL);
  MassMeisterTerminate();
  mclTerminateApplication();
  return _retval;
}

int main(int argc, const char **argv)
{
  if (!mclInitializeApplication(
    __MCC_MassMeister_component_data.runtime_options,
    __MCC_MassMeister_component_data.runtime_option_count))
    return 0;
  
  return mclRunMain(run_main, argc, argv);
}
