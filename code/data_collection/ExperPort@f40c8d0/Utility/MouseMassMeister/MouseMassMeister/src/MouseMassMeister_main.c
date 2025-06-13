/*
 * MATLAB Compiler: 4.9 (R2008b)
 * Date: Wed Jan 23 10:28:11 2019
 * Arguments: "-B" "macro_default" "-o" "MouseMassMeister" "-W" "main" "-d"
 * "C:\ratter\ExperPort\Utility\MouseMassMeister\MouseMassMeister\src" "-T" "link:exe"
 * "-v" "C:\ratter\ExperPort\Utility\MouseMassMeister\MouseMassMeister.m" "-a"
 * "C:\ratter\ExperPort\Utility\MouseMassMeister\update_ratname.m" "-a"
 * "C:\ratter\ExperPort\Utility\MouseMassMeister\get_colors.m" "-a"
 * "C:\ratter\ExperPort\Utility\MouseMassMeister\get_newrats.m" "-a"
 * "C:\ratter\ExperPort\Utility\MouseMassMeister\jump_to_empty.m" "-a"
 * "C:\ratter\ExperPort\Utility\MouseMassMeister\load_settings.m" "-a"
 * "C:\ratter\ExperPort\Utility\MouseMassMeister\MouseMassMeister.fig" "-a"
 * "C:\ratter\ExperPort\Utility\MouseMassMeister\MouseMassMeister_Properties.fig" "-a"
 * "C:\ratter\ExperPort\Utility\MouseMassMeister\MouseMassMeister_Properties.m" "-a"
 * "C:\ratter\ExperPort\Utility\MouseMassMeister\Properties.mat" "-a"
 * "C:\ratter\ExperPort\Utility\MouseMassMeister\update_lists.m" "-a"
 * "C:\ratter\ExperPort\Utility\MouseMassMeister\update_names.m" "-a"
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
 * "C:\ratter\ExperPort\Utility\MouseMassMeister\send_massdrop_text.m" "-a"
 * "C:\Program Files\Matlab\R2008b\toolbox\matlab\iofun\sendmail.m" "-a"
 * "C:\Program Files\Matlab\R2008b\toolbox\matlab\uitools\setpref.m" "-a"
 * "C:\Program Files\Matlab\R2008b\toolbox\matlab\general\java.m" "-a"
 * "C:\ratter\ExperPort\Utility\AutomatedEmails\set_email_sender.p" "-a"
 * "C:\ratter\ExperPort\Utility\MouseMassMeister\get_movedrats.m" "-a"
 * "C:\ratter\Rigscripts\startup.m" "-a"
 * "C:\ratter\ExperPort\Utility\MouseMassMeister\MM_get_tech_instructions.m" 
 */

#include <stdio.h>
#include "mclmcrrt.h"
#ifdef __cplusplus
extern "C" {
#endif

extern mclComponentData __MCC_MouseMassMeister_component_data;

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
#ifndef LIB_MouseMassMeister_C_API 
#define LIB_MouseMassMeister_C_API /* No special import/export declaration */
#endif

LIB_MouseMassMeister_C_API 
bool MW_CALL_CONV MouseMassMeisterInitializeWithHandlers(
    mclOutputHandlerFcn error_handler,
    mclOutputHandlerFcn print_handler
)
{
  if (_mcr_inst != NULL)
    return true;
  if (!mclmcrInitialize())
    return false;
  if (!mclInitializeComponentInstanceWithEmbeddedCTF(&_mcr_inst,
                                                     &__MCC_MouseMassMeister_component_data,
                                                     true, NoObjectType,
                                                     ExeTarget, error_handler,
                                                     print_handler, 8525317, NULL))
    return false;
  return true;
}

LIB_MouseMassMeister_C_API 
bool MW_CALL_CONV MouseMassMeisterInitialize(void)
{
  return MouseMassMeisterInitializeWithHandlers(mclDefaultErrorHandler,
                                           mclDefaultPrintHandler);
}

LIB_MouseMassMeister_C_API 
void MW_CALL_CONV MouseMassMeisterTerminate(void)
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
  __MCC_MouseMassMeister_component_data.path_to_component = path_to_component; 
  if (!MouseMassMeisterInitialize()) {
    return -1;
  }
  argc = mclSetCmdLineUserData(mclGetID(_mcr_inst), argc, argv);
  _retval = mclMain(_mcr_inst, argc, argv, "MouseMassMeister", 1);
  if (_retval == 0 /* no error */) mclWaitForFiguresToDie(NULL);
  MouseMassMeisterTerminate();
  mclTerminateApplication();
  return _retval;
}

int main(int argc, const char **argv)
{
  if (!mclInitializeApplication(
    __MCC_MouseMassMeister_component_data.runtime_options,
    __MCC_MouseMassMeister_component_data.runtime_option_count))
    return 0;
  
  return mclRunMain(run_main, argc, argv);
}
