/*
 * MATLAB Compiler: 4.10 (R2009a)
 * Date: Thu Aug 04 15:26:41 2011
 * Arguments: "-B" "macro_default" "-o" "RatMassPlotter" "-W" "main" "-d"
 * "C:\ratter\ExperPort\Utility\RatMassPlotter\RatMassPlotter\src" "-T"
 * "link:exe" "C:\ratter\ExperPort\Utility\RatMassPlotter\RatMassPlotter.m"
 * "-a" "C:\ratter\ExperPort\Utility\RatMassPlotter\update_xlim.m" "-a"
 * "C:\ratter\ExperPort\Utility\RatMassPlotter\RatMassPlotter.fig" "-a"
 * "C:\ratter\ExperPort\Utility\RatMassPlotter\update_plot.m" "-a"
 * "C:\ratter\ExperPort\Utility\AutomatedEmails\plot_rat_mass.m" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\bdata.p" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\LIBMYSQL.dll" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.m" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexw32" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexa64" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexa64.phenom" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexa64cuda" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexglx" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexmaci" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexmaci64" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexmaci.tiger" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\zlibwapi.dll" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\win64\mym.mexw64" 
 */

#include <stdio.h>
#include "mclmcrrt.h"
#ifdef __cplusplus
extern "C" {
#endif

extern mclComponentData __MCC_RatMassPlotter_component_data;

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
#ifndef LIB_RatMassPlotter_C_API 
#define LIB_RatMassPlotter_C_API /* No special import/export declaration */
#endif

LIB_RatMassPlotter_C_API 
bool MW_CALL_CONV RatMassPlotterInitializeWithHandlers(
    mclOutputHandlerFcn error_handler,
    mclOutputHandlerFcn print_handler
)
{
  if (_mcr_inst != NULL)
    return true;
  if (!mclmcrInitialize())
    return false;
  if (!mclInitializeComponentInstanceWithEmbeddedCTF(&_mcr_inst,
                                                     &__MCC_RatMassPlotter_component_data,
                                                     true, NoObjectType,
                                                     ExeTarget, error_handler,
                                                     print_handler, 1292229, NULL))
    return false;
  return true;
}

LIB_RatMassPlotter_C_API 
bool MW_CALL_CONV RatMassPlotterInitialize(void)
{
  return RatMassPlotterInitializeWithHandlers(mclDefaultErrorHandler,
                                              mclDefaultPrintHandler);
}

LIB_RatMassPlotter_C_API 
void MW_CALL_CONV RatMassPlotterTerminate(void)
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
  __MCC_RatMassPlotter_component_data.path_to_component = path_to_component; 
  if (!RatMassPlotterInitialize()) {
    return -1;
  }
  argc = mclSetCmdLineUserData(mclGetID(_mcr_inst), argc, argv);
  _retval = mclMain(_mcr_inst, argc, argv, "RatMassPlotter", 1);
  if (_retval == 0 /* no error */) mclWaitForFiguresToDie(NULL);
  RatMassPlotterTerminate();
  mclTerminateApplication();
  return _retval;
}

int main(int argc, const char **argv)
{
  if (!mclInitializeApplication(
    __MCC_RatMassPlotter_component_data.runtime_options,
    __MCC_RatMassPlotter_component_data.runtime_option_count))
    return 0;
  
  return mclRunMain(run_main, argc, argv);
}
