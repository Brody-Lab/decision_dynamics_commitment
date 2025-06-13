/*
 * MATLAB Compiler: 4.9 (R2008b)
 * Date: Thu Aug 22 12:01:38 2019
 * Arguments: "-B" "macro_default" "-o" "ShiftChecker" "-W" "main" "-d"
 * "C:\ratter\ExperPort\Utility\AutomatedEmails\ShiftChecker\src" "-T"
 * "link:exe" "-v"
 * "C:\ratter\ExperPort\Utility\AutomatedEmails\ShiftChecker2.m" "-a"
 * "C:\ratter\ExperPort\Utility\AutomatedEmails\checkshift.m" "-a"
 * "C:\ratter\ExperPort\Utility\check_calibration.m" "-a"
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
 * "C:\ratter\ExperPort\MySQLUtility\LIBMYSQL.dll" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\win64\zlibwapi.dll" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\win64\libmysql.dll" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\win64\mym.mexw64" "-a"
 * "C:\ratter\ExperPort\Modules\Settings.m" "-a"
 * "C:\ratter\ExperPort\Settings\Settings_Custom.conf" "-a"
 * "C:\ratter\Protocols\@WaterCalibration\custom_preferences.mat" "-a"
 * "C:\ratter\ExperPort\Utility\AutomatedEmails\SC_running.m" "-a"
 * "C:\ratter\ExperPort\Modules\bSettings.m" "-a"
 * "C:\ratter\ExperPort\Utility\AutomatedEmails\shiftchecker_status.mat" "-a"
 * "C:\ratter\ExperPort\Settings\Settings_Default.conf" "-a"
 * "C:\ratter\ExperPort\Settings\Settings_Template.conf" "-a"
 * "C:\ratter\ExperPort\Utility\AutomatedEmails\SC_determine_color.m" "-a"
 * "C:\ratter\ExperPort\Utility\AutomatedEmails\SC_update_tech.m" "-a"
 * "C:\ratter\ExperPort\Utility\AutomatedEmails\SC_check_next_tech.m" 
 */

#include "mclmcrrt.h"

#ifdef __cplusplus
extern "C" {
#endif
const unsigned char __MCC_ShiftChecker_session_key[] = {
    '6', '9', 'C', '0', '3', 'C', '3', '8', 'B', 'F', 'F', '3', '2', '9', 'E',
    '2', '4', 'B', '1', '0', 'D', '5', '4', 'E', '7', '0', 'B', 'C', '5', '8',
    'B', 'E', '4', 'F', 'C', 'D', '6', 'F', '4', '1', 'C', '0', '6', '6', 'E',
    '6', '9', 'B', '5', 'F', 'D', '3', 'A', 'E', 'C', '7', 'A', '9', 'E', '3',
    '9', 'E', '9', '9', 'C', '7', '9', 'E', '0', '5', '3', 'C', 'B', 'B', 'E',
    'E', 'E', '0', 'A', 'C', 'D', '7', '7', '7', '0', '9', '4', '1', 'C', '5',
    '3', '5', '1', '5', '3', '5', '9', '8', '3', '6', 'B', 'B', '6', '6', '7',
    'C', '2', '7', 'D', 'E', '2', 'D', 'B', '8', 'B', '9', 'B', 'C', '7', 'F',
    '9', '0', '3', 'D', '3', '0', '6', 'C', 'F', 'B', '4', 'A', '0', '9', '9',
    'C', '3', '1', 'F', '2', '0', '7', '9', 'C', '3', '8', 'E', '2', '5', '7',
    '4', 'A', '8', 'C', '2', '3', '8', '0', '5', '0', '4', '6', '7', 'A', '6',
    'C', 'A', 'E', 'F', '6', '7', '1', '1', '0', 'F', 'F', '6', 'B', '9', '7',
    '2', '2', '2', '8', '6', '8', 'D', '2', '5', '1', 'D', '7', '5', '1', '5',
    'D', 'C', 'A', 'C', '8', '4', '9', 'F', '2', 'E', '5', 'E', '5', 'E', 'F',
    'B', '9', 'C', 'A', '6', 'C', 'C', '9', '6', 'C', 'A', 'D', 'C', 'A', '7',
    '8', '4', '6', '2', '7', '0', '7', '7', 'C', '6', '4', '6', 'D', 'B', '5',
    'F', '2', '3', '5', '0', '0', '6', '3', '2', '1', '6', '5', '5', '0', '3',
    'E', '\0'};

const unsigned char __MCC_ShiftChecker_public_key[] = {
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

static const char * MCC_ShiftChecker_matlabpath_data[] = 
  { "ShiftChecker/", "$TOOLBOXDEPLOYDIR/", "ratter/ExperPort/Utility/",
    "ratter/ExperPort/MySQLUtility/", "ratter/ExperPort/MySQLUtility/win64/",
    "ratter/ExperPort/Modules/", "ratter/ExperPort/Settings/",
    "ratter/Protocols/", "ratter/ExperPort/",
    "ratter/ExperPort/Modules/newrt_mods/NetClient/", "ratter/ExperPort/bin/",
    "ratter/ExperPort/HandleParam/", "ratter/ExperPort/Analysis/",
    "ratter/ExperPort/Modules/SoundTrigClient/",
    "ratter/ExperPort/Utility/Zut/", "ratter/ExperPort/Plugins/",
    "ratter/ExperPort/SoloUtility/", "ratter/Rigscripts/",
    "ratter/ExperPort/FakeRP/", "ratter/ExperPort/Utility/TechNotes2/",
    "ratter/ExperPort/Utility/WaterMeister/",
    "ratter/ExperPort/Utility/WeighAllRats/",
    "ratter/ExperPort/Utility/provisional/",
    "ratter/ExperPort/Utility/ratinfo/", "$TOOLBOXMATLABDIR/general/",
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
    "toolbox/local/", "toolbox/shared/controllib/",
    "toolbox/shared/dastudio/", "$TOOLBOXMATLABDIR/datamanager/",
    "toolbox/compiler/", "toolbox/control/control/",
    "toolbox/control/ctrlguis/", "toolbox/control/ctrlobsolete/",
    "toolbox/control/ctrlutil/", "toolbox/shared/slcontrollib/",
    "toolbox/daq/daq/", "toolbox/finance/finance/", "toolbox/ident/ident/",
    "toolbox/ident/nlident/", "toolbox/ident/idobsolete/",
    "toolbox/ident/idutils/", "toolbox/shared/spcuilib/",
    "toolbox/instrument/instrument/", "toolbox/signal/signal/",
    "toolbox/signal/sigtools/", "toolbox/stats/" };

static const char * MCC_ShiftChecker_classpath_data[] = 
  { "java/jar/toolbox/control.jar", "java/jar/toolbox/instrument.jar",
    "java/jar/toolbox/testmeas.jar" };

static const char * MCC_ShiftChecker_libpath_data[] = 
  { "bin/win32/" };

static const char * MCC_ShiftChecker_app_opts_data[] = 
  { "" };

static const char * MCC_ShiftChecker_run_opts_data[] = 
  { "" };

static const char * MCC_ShiftChecker_warning_state_data[] = 
  { "off:MATLAB:dispatcher:nameConflict" };


mclComponentData __MCC_ShiftChecker_component_data = { 

  /* Public key data */
  __MCC_ShiftChecker_public_key,

  /* Component name */
  "ShiftChecker",

  /* Component Root */
  "",

  /* Application key data */
  __MCC_ShiftChecker_session_key,

  /* Component's MATLAB Path */
  MCC_ShiftChecker_matlabpath_data,

  /* Number of directories in the MATLAB Path */
  78,

  /* Component's Java class path */
  MCC_ShiftChecker_classpath_data,
  /* Number of directories in the Java class path */
  3,

  /* Component's load library path (for extra shared libraries) */
  MCC_ShiftChecker_libpath_data,
  /* Number of directories in the load library path */
  1,

  /* MCR instance-specific runtime options */
  MCC_ShiftChecker_app_opts_data,
  /* Number of MCR instance-specific runtime options */
  0,

  /* MCR global runtime options */
  MCC_ShiftChecker_run_opts_data,
  /* Number of MCR global runtime options */
  0,
  
  /* Component preferences directory */
  "ShiftChecker_3E3DD622566D4168C5B8922004CC5B30",

  /* MCR warning status data */
  MCC_ShiftChecker_warning_state_data,
  /* Number of MCR warning status modifiers */
  1,

  /* Path to component - evaluated at runtime */
  NULL

};

#ifdef __cplusplus
}
#endif


