/*
 * MATLAB Compiler: 4.9 (R2008b)
 * Date: Thu Aug 24 13:22:00 2017
 * Arguments: "-B" "macro_default" "-o" "GCS_receiver" "-W" "main" "-d"
 * "C:\ratter\ExperPort\Utility\GlobalControlSystem\GCS_receiver_compiled\src"
 * "-T" "link:exe"
 * "C:\ratter\ExperPort\Utility\GlobalControlSystem\GCS_receiver.m" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\win64\libmysql.dll" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\win64\mym.mexw64" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\zlibwapi.dll" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\bdata.p" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\LIBMYSQL.dll" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexw32" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexa64" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexmaci" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexmaci64" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexmaci.tiger" "-a"
 * "C:\ratter\ExperPort\Utility\GlobalControlSystem\GCS_Message.m" "-a"
 * "C:\ratter\ExperPort\Utility\GlobalControlSystem\GCS_Message.fig" "-a"
 * "C:\ratter\ExperPort\Utility\GlobalControlSystem\GCS_checkcode.p" "-a"
 * "C:\ratter\ExperPort\Utility\AutomatedEmails\senderror_report.m" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\get_network_info.m" "-a"
 * "C:\ratter\ExperPort\newstartup.m" "-a"
 * "C:\ratter\ExperPort\Modules\bSettings.m" "-a"
 * "C:\ratter\ExperPort\Settings\Settings_BrodylabRig.conf" "-a"
 * "C:\ratter\ExperPort\Settings\Settings_Custom.conf" "-a"
 * "C:\ratter\ExperPort\Settings\Settings_Default.conf" 
 */

#include "mclmcrrt.h"

#ifdef __cplusplus
extern "C" {
#endif
const unsigned char __MCC_GCS_receiver_session_key[] = {
    '9', 'B', '4', '0', 'A', '5', 'A', '5', '1', '1', '8', '9', 'B', '8', '5',
    'C', '6', '1', '9', '7', '8', '3', '0', '4', '3', '3', '9', 'A', '7', '4',
    '1', '5', 'B', '0', '3', '8', '4', '2', '8', '9', 'D', '6', '3', '6', 'F',
    'C', '9', '6', '1', 'B', 'B', '1', '7', '6', '0', 'A', '2', 'E', '5', '8',
    '5', '0', 'D', '3', '3', '8', '9', '2', '6', 'D', '4', '9', 'B', 'D', 'D',
    'A', 'B', '2', '2', '6', 'F', '7', '9', '8', '0', '2', 'A', '0', '5', '8',
    '0', '6', 'A', '3', '2', 'F', '9', 'F', '5', '7', '1', '8', '2', '3', '6',
    '8', '9', 'D', '5', 'F', '2', 'A', 'E', '1', '6', '0', '3', 'B', 'B', 'B',
    '3', '4', '6', '5', 'F', '8', 'F', '3', '2', 'F', '8', 'F', 'E', '6', '4',
    '3', 'C', 'E', '4', '2', '2', '2', 'B', '1', 'C', '4', 'E', '6', 'C', '1',
    'F', '8', 'E', '7', 'C', 'D', '0', '2', '3', 'F', '4', '7', '6', 'A', '7',
    'E', 'F', '9', '4', '4', 'A', 'B', '3', 'D', 'B', '4', '1', 'B', '3', 'A',
    'A', '2', '1', 'A', '1', 'D', 'C', '2', '2', '1', '1', '2', 'F', '3', '8',
    '1', '3', 'F', 'A', 'F', '1', '1', 'B', '9', '6', '8', '3', 'D', '4', '8',
    '1', '2', 'F', 'B', '1', '7', '3', '3', 'A', '0', 'A', 'E', '1', 'B', '9',
    '2', '7', 'F', 'D', '4', '7', 'E', '7', '2', '0', 'B', 'C', 'A', '1', '4',
    '1', 'D', '6', '0', '5', '1', '8', '1', '1', '4', 'C', '0', '1', '0', 'B',
    'A', '\0'};

const unsigned char __MCC_GCS_receiver_public_key[] = {
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

static const char * MCC_GCS_receiver_matlabpath_data[] = 
  { "GCS_receiver/", "$TOOLBOXDEPLOYDIR/",
    "ratter/ExperPort/MySQLUtility/win64/", "ratter/ExperPort/MySQLUtility/",
    "ratter/ExperPort/Utility/AutomatedEmails/", "ratter/ExperPort/",
    "ratter/ExperPort/Modules/", "ratter/ExperPort/Settings/",
    "ratter/ExperPort/bin/", "ratter/ExperPort/HandleParam/",
    "ratter/ExperPort/Utility/", "ratter/Rigscripts/",
    "ratter/ExperPort/FakeRP/", "ratter/ExperPort/Utility/provisional/",
    "$TOOLBOXMATLABDIR/general/", "$TOOLBOXMATLABDIR/ops/",
    "$TOOLBOXMATLABDIR/lang/", "$TOOLBOXMATLABDIR/elmat/",
    "$TOOLBOXMATLABDIR/randfun/", "$TOOLBOXMATLABDIR/elfun/",
    "$TOOLBOXMATLABDIR/specfun/", "$TOOLBOXMATLABDIR/matfun/",
    "$TOOLBOXMATLABDIR/datafun/", "$TOOLBOXMATLABDIR/polyfun/",
    "$TOOLBOXMATLABDIR/funfun/", "$TOOLBOXMATLABDIR/sparfun/",
    "$TOOLBOXMATLABDIR/scribe/", "$TOOLBOXMATLABDIR/iofun/",
    "$TOOLBOXMATLABDIR/graph2d/", "$TOOLBOXMATLABDIR/graph3d/",
    "$TOOLBOXMATLABDIR/specgraph/", "$TOOLBOXMATLABDIR/graphics/",
    "$TOOLBOXMATLABDIR/uitools/", "$TOOLBOXMATLABDIR/strfun/",
    "$TOOLBOXMATLABDIR/imagesci/", "$TOOLBOXMATLABDIR/audiovideo/",
    "$TOOLBOXMATLABDIR/timefun/", "$TOOLBOXMATLABDIR/datatypes/",
    "$TOOLBOXMATLABDIR/verctrl/", "$TOOLBOXMATLABDIR/codetools/",
    "$TOOLBOXMATLABDIR/helptools/", "$TOOLBOXMATLABDIR/winfun/",
    "$TOOLBOXMATLABDIR/demos/", "$TOOLBOXMATLABDIR/timeseries/",
    "$TOOLBOXMATLABDIR/hds/", "$TOOLBOXMATLABDIR/guide/",
    "$TOOLBOXMATLABDIR/plottools/", "toolbox/local/",
    "toolbox/shared/dastudio/", "$TOOLBOXMATLABDIR/datamanager/",
    "toolbox/compiler/" };

static const char * MCC_GCS_receiver_classpath_data[] = 
  { "" };

static const char * MCC_GCS_receiver_libpath_data[] = 
  { "" };

static const char * MCC_GCS_receiver_app_opts_data[] = 
  { "" };

static const char * MCC_GCS_receiver_run_opts_data[] = 
  { "" };

static const char * MCC_GCS_receiver_warning_state_data[] = 
  { "off:MATLAB:dispatcher:nameConflict" };


mclComponentData __MCC_GCS_receiver_component_data = { 

  /* Public key data */
  __MCC_GCS_receiver_public_key,

  /* Component name */
  "GCS_receiver",

  /* Component Root */
  "",

  /* Application key data */
  __MCC_GCS_receiver_session_key,

  /* Component's MATLAB Path */
  MCC_GCS_receiver_matlabpath_data,

  /* Number of directories in the MATLAB Path */
  51,

  /* Component's Java class path */
  MCC_GCS_receiver_classpath_data,
  /* Number of directories in the Java class path */
  0,

  /* Component's load library path (for extra shared libraries) */
  MCC_GCS_receiver_libpath_data,
  /* Number of directories in the load library path */
  0,

  /* MCR instance-specific runtime options */
  MCC_GCS_receiver_app_opts_data,
  /* Number of MCR instance-specific runtime options */
  0,

  /* MCR global runtime options */
  MCC_GCS_receiver_run_opts_data,
  /* Number of MCR global runtime options */
  0,
  
  /* Component preferences directory */
  "GCS_receiver_DF06217FE08BFC1302DC0555579D6447",

  /* MCR warning status data */
  MCC_GCS_receiver_warning_state_data,
  /* Number of MCR warning status modifiers */
  1,

  /* Path to component - evaluated at runtime */
  NULL

};

#ifdef __cplusplus
}
#endif


