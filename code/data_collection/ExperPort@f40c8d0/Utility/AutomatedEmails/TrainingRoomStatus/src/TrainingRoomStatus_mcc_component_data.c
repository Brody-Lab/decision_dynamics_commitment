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

#include "mclmcrrt.h"

#ifdef __cplusplus
extern "C" {
#endif
const unsigned char __MCC_TrainingRoomStatus_session_key[] = {
    'A', '8', 'B', 'D', '1', '6', 'F', '3', 'B', 'D', 'A', '1', '2', '0', 'B',
    '0', 'A', '4', '7', '1', '0', 'C', 'D', '5', '6', 'F', '7', '5', '1', 'C',
    '1', '8', 'D', '3', 'C', '5', '2', 'C', '8', '4', '8', 'D', '1', '4', 'E',
    '4', '3', 'E', 'B', '1', '7', '9', '8', '0', '1', '0', '6', 'D', 'B', '3',
    'A', '9', '7', '5', 'E', '9', '1', 'F', 'D', 'B', '3', '4', '6', '4', '0',
    '6', 'D', 'F', 'A', '3', 'E', '8', 'A', 'D', '4', '5', '7', '4', '7', 'C',
    'B', '8', '3', 'A', '9', '8', '3', 'F', '4', 'D', '8', '5', 'B', '0', 'D',
    '7', '6', 'C', 'D', 'F', 'B', 'F', '2', '0', '8', '2', '5', '4', 'E', '2',
    '0', '7', '8', 'F', 'D', 'D', '2', '3', '3', 'E', 'F', '3', '8', '9', 'F',
    '2', 'C', '3', '6', '7', '0', '2', '3', '0', '1', 'C', '1', 'C', '0', '8',
    'D', 'A', '6', '6', '0', 'D', '2', 'E', 'F', 'F', 'F', '3', '0', 'B', 'D',
    '5', '5', 'E', '8', '2', '8', '1', '7', 'F', 'E', '3', '7', '3', 'B', 'D',
    'A', '6', '2', '8', 'A', '2', '2', 'A', 'A', 'F', 'A', '3', '4', '0', '8',
    'E', '1', '8', 'D', 'E', '7', '4', '7', '3', '7', '4', '3', 'A', '9', '3',
    '5', 'E', 'C', '6', 'A', '9', '9', 'B', 'D', '4', '1', 'D', 'F', 'A', '1',
    '0', 'A', 'F', '3', '6', '3', '1', 'B', '9', '7', '1', 'D', '5', 'F', 'C',
    '8', '4', '0', 'C', '5', '2', 'A', 'E', '9', '9', '3', 'F', 'B', 'D', 'F',
    'B', '\0'};

const unsigned char __MCC_TrainingRoomStatus_public_key[] = {
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

static const char * MCC_TrainingRoomStatus_matlabpath_data[] = 
  { "TrainingRoom/", "$TOOLBOXDEPLOYDIR/",
    "ratter/ExperPort/Utility/GlobalControlSystem/",
    "ratter/ExperPort/Utility/MassMeister/",
    "ratter/ExperPort/Utility/WaterMeister/", "ratter/ExperPort/MySQLUtility/",
    "ratter/ExperPort/Modules/", "ratter/ExperPort/Settings/",
    "ratter/ExperPort/", "ratter/ExperPort/bin/",
    "ratter/ExperPort/HandleParam/", "ratter/ExperPort/Utility/",
    "ratter/Rigscripts/", "ratter/ExperPort/FakeRP/",
    "ratter/ExperPort/Utility/provisional/", "$TOOLBOXMATLABDIR/general/",
    "$TOOLBOXMATLABDIR/ops/", "$TOOLBOXMATLABDIR/lang/",
    "$TOOLBOXMATLABDIR/elmat/", "$TOOLBOXMATLABDIR/randfun/",
    "$TOOLBOXMATLABDIR/elfun/", "$TOOLBOXMATLABDIR/specfun/",
    "$TOOLBOXMATLABDIR/matfun/", "$TOOLBOXMATLABDIR/datafun/",
    "$TOOLBOXMATLABDIR/polyfun/", "$TOOLBOXMATLABDIR/funfun/",
    "$TOOLBOXMATLABDIR/sparfun/", "$TOOLBOXMATLABDIR/scribe/",
    "$TOOLBOXMATLABDIR/iofun/", "$TOOLBOXMATLABDIR/graph2d/",
    "$TOOLBOXMATLABDIR/graph3d/", "$TOOLBOXMATLABDIR/specgraph/",
    "$TOOLBOXMATLABDIR/graphics/", "$TOOLBOXMATLABDIR/uitools/",
    "$TOOLBOXMATLABDIR/strfun/", "$TOOLBOXMATLABDIR/imagesci/",
    "$TOOLBOXMATLABDIR/audiovideo/", "$TOOLBOXMATLABDIR/timefun/",
    "$TOOLBOXMATLABDIR/datatypes/", "$TOOLBOXMATLABDIR/verctrl/",
    "$TOOLBOXMATLABDIR/codetools/", "$TOOLBOXMATLABDIR/helptools/",
    "$TOOLBOXMATLABDIR/winfun/", "$TOOLBOXMATLABDIR/demos/",
    "$TOOLBOXMATLABDIR/timeseries/", "$TOOLBOXMATLABDIR/hds/",
    "$TOOLBOXMATLABDIR/guide/", "$TOOLBOXMATLABDIR/plottools/",
    "toolbox/local/", "toolbox/shared/dastudio/",
    "$TOOLBOXMATLABDIR/datamanager/", "toolbox/compiler/" };

static const char * MCC_TrainingRoomStatus_classpath_data[] = 
  { "" };

static const char * MCC_TrainingRoomStatus_libpath_data[] = 
  { "" };

static const char * MCC_TrainingRoomStatus_app_opts_data[] = 
  { "" };

static const char * MCC_TrainingRoomStatus_run_opts_data[] = 
  { "" };

static const char * MCC_TrainingRoomStatus_warning_state_data[] = 
  { "off:MATLAB:dispatcher:nameConflict" };


mclComponentData __MCC_TrainingRoomStatus_component_data = { 

  /* Public key data */
  __MCC_TrainingRoomStatus_public_key,

  /* Component name */
  "TrainingRoomStatus",

  /* Component Root */
  "",

  /* Application key data */
  __MCC_TrainingRoomStatus_session_key,

  /* Component's MATLAB Path */
  MCC_TrainingRoomStatus_matlabpath_data,

  /* Number of directories in the MATLAB Path */
  52,

  /* Component's Java class path */
  MCC_TrainingRoomStatus_classpath_data,
  /* Number of directories in the Java class path */
  0,

  /* Component's load library path (for extra shared libraries) */
  MCC_TrainingRoomStatus_libpath_data,
  /* Number of directories in the load library path */
  0,

  /* MCR instance-specific runtime options */
  MCC_TrainingRoomStatus_app_opts_data,
  /* Number of MCR instance-specific runtime options */
  0,

  /* MCR global runtime options */
  MCC_TrainingRoomStatus_run_opts_data,
  /* Number of MCR global runtime options */
  0,
  
  /* Component preferences directory */
  "TrainingRoom_32674D5E78E09F730D8273CFA6FF1113",

  /* MCR warning status data */
  MCC_TrainingRoomStatus_warning_state_data,
  /* Number of MCR warning status modifiers */
  1,

  /* Path to component - evaluated at runtime */
  NULL

};

#ifdef __cplusplus
}
#endif


