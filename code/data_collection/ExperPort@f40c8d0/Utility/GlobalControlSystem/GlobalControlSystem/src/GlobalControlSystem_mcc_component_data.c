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

#include "mclmcrrt.h"

#ifdef __cplusplus
extern "C" {
#endif
const unsigned char __MCC_GlobalControlSystem_session_key[] = {
    '4', 'E', '6', '1', '3', '5', 'C', '8', '6', 'B', 'A', '2', '6', 'F', '2',
    '2', 'B', '8', 'C', '0', '7', 'C', '6', 'C', '6', '2', '9', 'A', 'A', '2',
    'A', '3', '9', '4', '2', 'F', '4', '6', '1', 'D', '8', 'E', '2', '8', 'D',
    '2', '0', '4', '2', '2', 'C', '6', '2', '2', '1', '7', 'F', '4', 'C', 'D',
    '3', '4', '6', '2', '5', '8', '3', '4', '3', 'F', 'E', '2', '0', '7', 'D',
    'C', '0', 'B', '6', '1', '9', 'D', '2', '1', '3', 'A', 'A', 'C', 'D', '3',
    'D', 'B', 'B', '2', 'A', '5', '0', 'E', '4', '6', '9', 'B', 'E', '2', 'C',
    'D', 'F', 'E', 'C', '4', '3', '0', '8', 'D', '5', 'F', '5', '6', 'D', '7',
    'C', '8', '4', '2', 'D', 'A', '2', '3', 'F', '3', 'C', 'A', 'A', 'F', '7',
    '6', 'D', '0', '6', '9', 'C', '0', '3', 'D', '9', '1', '0', '9', '5', '6',
    'B', 'C', '2', 'B', '4', '9', 'F', 'B', '5', '5', '5', '4', '2', '1', '4',
    'A', '2', '8', 'D', '6', 'D', '0', '8', 'B', '1', '7', 'E', '9', '6', 'C',
    '7', 'B', '2', '0', 'A', '3', '7', '7', '9', '9', 'C', 'F', '0', '0', '2',
    '1', '0', '2', '4', '7', '3', '0', '3', '4', '5', 'B', '5', '4', '5', '5',
    '7', '1', '2', '1', '0', 'A', 'D', '0', 'B', 'E', '2', '0', 'E', 'A', 'B',
    'C', '2', '6', '5', '8', 'C', 'B', '2', 'E', 'D', 'F', 'D', '9', 'A', '3',
    '5', 'F', '0', '7', '0', 'A', 'A', 'D', '1', 'E', '5', 'D', 'A', '8', '4',
    '4', '\0'};

const unsigned char __MCC_GlobalControlSystem_public_key[] = {
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

static const char * MCC_GlobalControlSystem_matlabpath_data[] = 
  { "GlobalContro/", "$TOOLBOXDEPLOYDIR/", "ratter/ExperPort/MySQLUtility/",
    "ratter/ExperPort/MySQLUtility/win64/", "$TOOLBOXMATLABDIR/iofun/",
    "$TOOLBOXMATLABDIR/uitools/", "$TOOLBOXMATLABDIR/general/",
    "ratter/ExperPort/Utility/AutomatedEmails/", "ratter/ExperPort/",
    "ratter/ExperPort/Modules/newrt_mods/NetClient/", "ratter/ExperPort/bin/",
    "ratter/ExperPort/HandleParam/", "ratter/ExperPort/Analysis/NeuraLynx/",
    "ratter/ExperPort/Analysis/Video_Tracker/", "ratter/ExperPort/Analysis/",
    "ratter/ExperPort/Modules/SoundTrigClient/", "ratter/ExperPort/Modules/",
    "ratter/ExperPort/Utility/", "ratter/ExperPort/Utility/Zut/",
    "ratter/ExperPort/Plugins/", "ratter/ExperPort/SoloUtility/",
    "ratter/Rigscripts/", "ratter/ExperPort/Analysis/jce_helpers/",
    "ratter/ExperPort/FakeRP/", "ratter/ExperPort/Utility/MassMeister/",
    "ratter/ExperPort/Utility/RatMassPlotter/",
    "ratter/ExperPort/Utility/TechNotes2/",
    "ratter/ExperPort/Utility/WaterMeister/",
    "ratter/ExperPort/Utility/WeighAllRats/",
    "ratter/ExperPort/Utility/ratinfo/", "$TOOLBOXMATLABDIR/ops/",
    "$TOOLBOXMATLABDIR/lang/", "$TOOLBOXMATLABDIR/elmat/",
    "$TOOLBOXMATLABDIR/randfun/", "$TOOLBOXMATLABDIR/elfun/",
    "$TOOLBOXMATLABDIR/specfun/", "$TOOLBOXMATLABDIR/matfun/",
    "$TOOLBOXMATLABDIR/datafun/", "$TOOLBOXMATLABDIR/polyfun/",
    "$TOOLBOXMATLABDIR/funfun/", "$TOOLBOXMATLABDIR/sparfun/",
    "$TOOLBOXMATLABDIR/scribe/", "$TOOLBOXMATLABDIR/graph2d/",
    "$TOOLBOXMATLABDIR/graph3d/", "$TOOLBOXMATLABDIR/specgraph/",
    "$TOOLBOXMATLABDIR/graphics/", "$TOOLBOXMATLABDIR/strfun/",
    "$TOOLBOXMATLABDIR/imagesci/", "$TOOLBOXMATLABDIR/audiovideo/",
    "$TOOLBOXMATLABDIR/timefun/", "$TOOLBOXMATLABDIR/datatypes/",
    "$TOOLBOXMATLABDIR/verctrl/", "$TOOLBOXMATLABDIR/codetools/",
    "$TOOLBOXMATLABDIR/helptools/", "$TOOLBOXMATLABDIR/winfun/",
    "$TOOLBOXMATLABDIR/demos/", "$TOOLBOXMATLABDIR/timeseries/",
    "$TOOLBOXMATLABDIR/hds/", "$TOOLBOXMATLABDIR/guide/",
    "$TOOLBOXMATLABDIR/plottools/", "toolbox/local/",
    "toolbox/shared/controllib/", "toolbox/shared/dastudio/",
    "$TOOLBOXMATLABDIR/datamanager/", "toolbox/compiler/",
    "toolbox/control/control/", "toolbox/control/ctrlguis/",
    "toolbox/control/ctrlobsolete/", "toolbox/control/ctrlutil/",
    "toolbox/shared/slcontrollib/", "toolbox/daq/daq/",
    "toolbox/finance/finance/", "toolbox/ident/ident/",
    "toolbox/ident/nlident/", "toolbox/ident/idobsolete/",
    "toolbox/ident/idutils/", "toolbox/images/colorspaces/",
    "toolbox/images/images/", "toolbox/images/imuitools/",
    "toolbox/images/iptformats/", "toolbox/images/iptutils/",
    "toolbox/shared/imageslib/", "toolbox/shared/spcuilib/",
    "toolbox/instrument/instrument/", "toolbox/signal/signal/",
    "toolbox/signal/sigtools/", "toolbox/stats/" };

static const char * MCC_GlobalControlSystem_classpath_data[] = 
  { "java/jar/toolbox/control.jar", "java/jar/toolbox/images.jar",
    "java/jar/toolbox/instrument.jar", "java/jar/toolbox/testmeas.jar" };

static const char * MCC_GlobalControlSystem_libpath_data[] = 
  { "bin/win32/" };

static const char * MCC_GlobalControlSystem_app_opts_data[] = 
  { "" };

static const char * MCC_GlobalControlSystem_run_opts_data[] = 
  { "" };

static const char * MCC_GlobalControlSystem_warning_state_data[] = 
  { "off:MATLAB:dispatcher:nameConflict" };


mclComponentData __MCC_GlobalControlSystem_component_data = { 

  /* Public key data */
  __MCC_GlobalControlSystem_public_key,

  /* Component name */
  "GlobalControlSystem",

  /* Component Root */
  "",

  /* Application key data */
  __MCC_GlobalControlSystem_session_key,

  /* Component's MATLAB Path */
  MCC_GlobalControlSystem_matlabpath_data,

  /* Number of directories in the MATLAB Path */
  87,

  /* Component's Java class path */
  MCC_GlobalControlSystem_classpath_data,
  /* Number of directories in the Java class path */
  4,

  /* Component's load library path (for extra shared libraries) */
  MCC_GlobalControlSystem_libpath_data,
  /* Number of directories in the load library path */
  1,

  /* MCR instance-specific runtime options */
  MCC_GlobalControlSystem_app_opts_data,
  /* Number of MCR instance-specific runtime options */
  0,

  /* MCR global runtime options */
  MCC_GlobalControlSystem_run_opts_data,
  /* Number of MCR global runtime options */
  0,
  
  /* Component preferences directory */
  "GlobalContro_C8FBA39BB5D2D2A2E4F79CBB0205BCC0",

  /* MCR warning status data */
  MCC_GlobalControlSystem_warning_state_data,
  /* Number of MCR warning status modifiers */
  1,

  /* Path to component - evaluated at runtime */
  NULL

};

#ifdef __cplusplus
}
#endif


