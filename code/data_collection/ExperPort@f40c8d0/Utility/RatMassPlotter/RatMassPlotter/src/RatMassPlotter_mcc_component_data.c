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

#include "mclmcrrt.h"

#ifdef __cplusplus
extern "C" {
#endif
const unsigned char __MCC_RatMassPlotter_session_key[] = {
    '2', '5', '0', '9', 'D', '4', '9', '9', 'A', '8', '5', 'B', '5', '6', 'B',
    '1', 'E', '7', '7', 'C', 'C', 'A', 'E', 'F', '0', '1', 'E', 'E', 'C', '9',
    '4', 'E', 'D', '4', '8', '7', '3', '4', 'D', '5', '7', '1', '8', '4', 'A',
    '5', 'F', 'B', '9', '0', 'E', '9', '0', 'D', '0', '9', '3', 'A', '5', '3',
    'A', 'B', 'D', 'E', '6', '2', '1', 'D', 'C', 'C', 'B', '7', '1', '5', '6',
    'C', '6', '3', '8', 'B', '5', 'F', '6', '5', 'E', 'E', '6', '1', '5', 'A',
    'B', 'F', '6', '6', '0', 'F', 'C', '2', '9', 'B', '9', '8', '3', '1', 'F',
    '5', '1', '3', '9', 'A', 'E', 'D', 'A', '5', '1', '6', '6', 'C', '6', 'B',
    '3', '5', 'D', '3', '0', '6', '1', '5', 'F', '2', '2', '6', '8', '9', 'E',
    '8', '1', '4', 'B', 'A', 'E', '6', 'A', '9', 'A', '5', '0', '0', '2', '8',
    'A', '3', '3', 'F', '1', '8', '4', 'D', '9', '8', 'B', '5', '2', '4', '5',
    '1', '9', '5', 'D', '0', '1', 'A', '3', '3', 'B', '9', 'C', 'F', 'D', '6',
    'D', 'E', 'B', '7', 'B', '8', 'E', 'F', '2', 'C', '9', '3', 'D', '6', '9',
    '2', '8', '6', '2', '7', '9', '6', 'F', '2', 'E', '5', '6', 'F', 'A', 'D',
    '3', '7', '9', 'D', 'F', 'B', '7', 'A', 'A', '7', '8', 'B', 'D', '8', 'D',
    'D', '7', 'A', 'C', '7', '1', '9', '4', '8', 'C', '7', 'B', '8', '0', '6',
    '8', '9', 'E', 'E', '6', '1', 'D', '5', '4', '3', '7', '0', '4', '9', 'F',
    '2', '\0'};

const unsigned char __MCC_RatMassPlotter_public_key[] = {
    '3', '0', '8', '1', '9', 'D', '3', '0', '0', 'D', '0', '6', '0', '9', '2',
    'A', '8', '6', '4', '8', '8', '6', 'F', '7', '0', 'D', '0', '1', '0', '1',
    '0', '1', '0', '5', '0', '0', '0', '3', '8', '1', '8', 'B', '0', '0', '3',
    '0', '8', '1', '8', '7', '0', '2', '8', '1', '8', '1', '0', '0', 'C', '4',
    '9', 'C', 'A', 'C', '3', '4', 'E', 'D', '1', '3', 'A', '5', '2', '0', '6',
    '5', '8', 'F', '6', 'F', '8', 'E', '0', '1', '3', '8', 'C', '4', '3', '1',
    '5', 'B', '4', '3', '1', '5', '2', '7', '7', 'E', 'D', '3', 'F', '7', 'D',
    'A', 'E', '5', '3', '0', '9', '9', 'D', 'B', '0', '8', 'E', 'E', '5', '8',
    '9', 'F', '8', '0', '4', 'D', '4', 'B', '9', '8', '1', '3', '2', '6', 'A',
    '5', '2', 'C', 'C', 'E', '4', '3', '8', '2', 'E', '9', 'F', '2', 'B', '4',
    'D', '0', '8', '5', 'E', 'B', '9', '5', '0', 'C', '7', 'A', 'B', '1', '2',
    'E', 'D', 'E', '2', 'D', '4', '1', '2', '9', '7', '8', '2', '0', 'E', '6',
    '3', '7', '7', 'A', '5', 'F', 'E', 'B', '5', '6', '8', '9', 'D', '4', 'E',
    '6', '0', '3', '2', 'F', '6', '0', 'C', '4', '3', '0', '7', '4', 'A', '0',
    '4', 'C', '2', '6', 'A', 'B', '7', '2', 'F', '5', '4', 'B', '5', '1', 'B',
    'B', '4', '6', '0', '5', '7', '8', '7', '8', '5', 'B', '1', '9', '9', '0',
    '1', '4', '3', '1', '4', 'A', '6', '5', 'F', '0', '9', '0', 'B', '6', '1',
    'F', 'C', '2', '0', '1', '6', '9', '4', '5', '3', 'B', '5', '8', 'F', 'C',
    '8', 'B', 'A', '4', '3', 'E', '6', '7', '7', '6', 'E', 'B', '7', 'E', 'C',
    'D', '3', '1', '7', '8', 'B', '5', '6', 'A', 'B', '0', 'F', 'A', '0', '6',
    'D', 'D', '6', '4', '9', '6', '7', 'C', 'B', '1', '4', '9', 'E', '5', '0',
    '2', '0', '1', '1', '1', '\0'};

static const char * MCC_RatMassPlotter_matlabpath_data[] = 
  { "RatMassPlott/", "$TOOLBOXDEPLOYDIR/",
    "ratter/ExperPort/Utility/AutomatedEmails/",
    "ratter/ExperPort/MySQLUtility/", "ratter/ExperPort/MySQLUtility/win64/",
    "ratter/ExperPort/", "ratter/ExperPort/Analysis/",
    "ratter/ExperPort/FakeRP/", "ratter/ExperPort/HandleParam/",
    "ratter/ExperPort/Utility/", "ratter/ExperPort/Utility/provisional/",
    "ratter/ExperPort/bin/", "ratter/Rigscripts/",
    "$TOOLBOXMATLABDIR/general/", "$TOOLBOXMATLABDIR/ops/",
    "$TOOLBOXMATLABDIR/lang/", "$TOOLBOXMATLABDIR/elmat/",
    "$TOOLBOXMATLABDIR/randfun/", "$TOOLBOXMATLABDIR/elfun/",
    "$TOOLBOXMATLABDIR/specfun/", "$TOOLBOXMATLABDIR/matfun/",
    "$TOOLBOXMATLABDIR/datafun/", "$TOOLBOXMATLABDIR/polyfun/",
    "$TOOLBOXMATLABDIR/funfun/", "$TOOLBOXMATLABDIR/sparfun/",
    "$TOOLBOXMATLABDIR/scribe/", "$TOOLBOXMATLABDIR/graph2d/",
    "$TOOLBOXMATLABDIR/graph3d/", "$TOOLBOXMATLABDIR/specgraph/",
    "$TOOLBOXMATLABDIR/graphics/", "$TOOLBOXMATLABDIR/uitools/",
    "$TOOLBOXMATLABDIR/strfun/", "$TOOLBOXMATLABDIR/imagesci/",
    "$TOOLBOXMATLABDIR/iofun/", "$TOOLBOXMATLABDIR/audiovideo/",
    "$TOOLBOXMATLABDIR/timefun/", "$TOOLBOXMATLABDIR/datatypes/",
    "$TOOLBOXMATLABDIR/verctrl/", "$TOOLBOXMATLABDIR/codetools/",
    "$TOOLBOXMATLABDIR/helptools/", "$TOOLBOXMATLABDIR/winfun/",
    "$TOOLBOXMATLABDIR/winfun/net/", "$TOOLBOXMATLABDIR/demos/",
    "$TOOLBOXMATLABDIR/timeseries/", "$TOOLBOXMATLABDIR/hds/",
    "$TOOLBOXMATLABDIR/guide/", "$TOOLBOXMATLABDIR/plottools/",
    "toolbox/local/", "toolbox/shared/dastudio/",
    "$TOOLBOXMATLABDIR/datamanager/", "toolbox/compiler/" };

static const char * MCC_RatMassPlotter_classpath_data[] = 
  { "" };

static const char * MCC_RatMassPlotter_libpath_data[] = 
  { "" };

static const char * MCC_RatMassPlotter_app_opts_data[] = 
  { "" };

static const char * MCC_RatMassPlotter_run_opts_data[] = 
  { "" };

static const char * MCC_RatMassPlotter_warning_state_data[] = 
  { "off:MATLAB:dispatcher:nameConflict" };


mclComponentData __MCC_RatMassPlotter_component_data = { 

  /* Public key data */
  __MCC_RatMassPlotter_public_key,

  /* Component name */
  "RatMassPlotter",

  /* Component Root */
  "",

  /* Application key data */
  __MCC_RatMassPlotter_session_key,

  /* Component's MATLAB Path */
  MCC_RatMassPlotter_matlabpath_data,

  /* Number of directories in the MATLAB Path */
  51,

  /* Component's Java class path */
  MCC_RatMassPlotter_classpath_data,
  /* Number of directories in the Java class path */
  0,

  /* Component's load library path (for extra shared libraries) */
  MCC_RatMassPlotter_libpath_data,
  /* Number of directories in the load library path */
  0,

  /* MCR instance-specific runtime options */
  MCC_RatMassPlotter_app_opts_data,
  /* Number of MCR instance-specific runtime options */
  0,

  /* MCR global runtime options */
  MCC_RatMassPlotter_run_opts_data,
  /* Number of MCR global runtime options */
  0,
  
  /* Component preferences directory */
  "RatMassPlott_94385C10DB10C3AA49009C99999B4D26",

  /* MCR warning status data */
  MCC_RatMassPlotter_warning_state_data,
  /* Number of MCR warning status modifiers */
  1,

  /* Path to component - evaluated at runtime */
  NULL

};

#ifdef __cplusplus
}
#endif


