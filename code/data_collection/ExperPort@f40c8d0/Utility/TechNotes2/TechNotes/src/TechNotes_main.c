/*
 * MATLAB Compiler: 4.9 (R2008b)
 * Date: Thu Jul 25 17:23:14 2019
 * Arguments: "-B" "macro_default" "-o" "TechNotes" "-W" "main" "-d"
 * "C:\ratter\ExperPort\Utility\TechNotes2\TechNotes\src" "-T" "link:exe" "-v"
 * "C:\ratter\ExperPort\Utility\TechNotes2\TechNotes.m" "-a"
 * "C:\ratter\ExperPort\Utility\TechNotes2\TN_viewold.m" "-a"
 * "C:\ratter\ExperPort\Utility\TechNotes2\TechNotes.fig" "-a"
 * "C:\ratter\ExperPort\Utility\TechNotes2\TN_clear.m" "-a"
 * "C:\ratter\ExperPort\Utility\TechNotes2\TN_emergency.m" "-a"
 * "C:\ratter\ExperPort\Utility\TechNotes2\TN_general.m" "-a"
 * "C:\ratter\ExperPort\Utility\TechNotes2\TN_listexperimenters.m" "-a"
 * "C:\ratter\ExperPort\Utility\TechNotes2\TN_listrats.m" "-a"
 * "C:\ratter\ExperPort\Utility\TechNotes2\TN_listrigs.m" "-a"
 * "C:\ratter\ExperPort\Utility\TechNotes2\TN_listsessions.m" "-a"
 * "C:\ratter\ExperPort\Utility\TechNotes2\TN_listtowers.m" "-a"
 * "C:\ratter\ExperPort\Utility\TechNotes2\TN_submit.m" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexmaci64" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\zlibwapi.dll" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\bdata.p" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\LIBMYSQL.dll" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexw32" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexa64" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexmaci" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\win64\mym.mexw64" "-a"
 * "C:\ratter\ExperPort\Utility\TechNotes2\TN_removetraining.m" "-a"
 * "C:\ratter\ExperPort\Utility\ratinfo\put_rat_on_recovery.m" "-a"
 * "C:\ratter\ExperPort\Utility\TechNotes2\TN_cagemate.m" "-a"
 * "C:\ratter\ExperPort\Utility\AutomatedEmails\set_email_sender.p" "-a"
 * "C:\Program Files\Matlab\R2008b\toolbox\matlab\iofun\sendmail.m" "-a"
 * "C:\Program Files\Matlab\R2008b\toolbox\matlab\uitools\setpref.m" "-a"
 * "C:\ratter\ExperPort\Utility\TechNotes2\TN_determine_experimenters.m" "-a"
 * "C:\ratter\ExperPort\Utility\AutomatedEmails\send_text_message.m" 
 */

#include <stdio.h>
#include "mclmcrrt.h"
#ifdef __cplusplus
extern "C" {
#endif

extern mclComponentData __MCC_TechNotes_component_data;

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
#ifndef LIB_TechNotes_C_API 
#define LIB_TechNotes_C_API /* No special import/export declaration */
#endif

LIB_TechNotes_C_API 
bool MW_CALL_CONV TechNotesInitializeWithHandlers(
    mclOutputHandlerFcn error_handler,
    mclOutputHandlerFcn print_handler
)
{
  if (_mcr_inst != NULL)
    return true;
  if (!mclmcrInitialize())
    return false;
  if (!mclInitializeComponentInstanceWithEmbeddedCTF(&_mcr_inst,
                                                     &__MCC_TechNotes_component_data,
                                                     true, NoObjectType,
                                                     ExeTarget, error_handler,
                                                     print_handler, 1166676, NULL))
    return false;
  return true;
}

LIB_TechNotes_C_API 
bool MW_CALL_CONV TechNotesInitialize(void)
{
  return TechNotesInitializeWithHandlers(mclDefaultErrorHandler,
                                         mclDefaultPrintHandler);
}

LIB_TechNotes_C_API 
void MW_CALL_CONV TechNotesTerminate(void)
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
  __MCC_TechNotes_component_data.path_to_component = path_to_component; 
  if (!TechNotesInitialize()) {
    return -1;
  }
  argc = mclSetCmdLineUserData(mclGetID(_mcr_inst), argc, argv);
  _retval = mclMain(_mcr_inst, argc, argv, "TechNotes", 1);
  if (_retval == 0 /* no error */) mclWaitForFiguresToDie(NULL);
  TechNotesTerminate();
  mclTerminateApplication();
  return _retval;
}

int main(int argc, const char **argv)
{
  if (!mclInitializeApplication(
    __MCC_TechNotes_component_data.runtime_options,
    __MCC_TechNotes_component_data.runtime_option_count))
    return 0;
  
  return mclRunMain(run_main, argc, argv);
}
