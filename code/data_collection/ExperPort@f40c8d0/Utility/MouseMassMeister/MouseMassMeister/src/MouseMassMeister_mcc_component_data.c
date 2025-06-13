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

#include "mclmcrrt.h"

#ifdef __cplusplus
extern "C" {
#endif
const unsigned char __MCC_MouseMassMeister_session_key[] = {
    '9', 'A', '5', '7', 'B', '8', '6', 'B', 'C', 'A', '4', '8', '4', 'F', '1',
    'B', 'A', '6', 'C', '1', '7', '5', '6', '0', 'B', '6', '0', 'F', 'E', 'C',
    '7', '6', '0', '1', '3', '6', '6', 'A', 'F', 'E', 'E', '0', '8', 'F', '6',
    'C', '7', 'C', 'A', '0', 'B', 'F', '2', '8', '3', '4', '2', '0', '0', 'A',
    'A', 'C', '6', '6', 'F', '0', 'B', '2', 'A', '2', '8', '8', 'F', 'C', 'D',
    'D', '5', 'D', '1', 'C', '0', 'D', 'A', '4', '8', '9', '3', '4', '4', '6',
    '8', '2', '9', '0', 'F', '7', '6', '2', '4', '6', '8', '4', 'B', 'A', '6',
    'B', '3', '0', '9', 'D', '2', '1', '8', '9', 'F', '9', 'A', '3', 'E', 'D',
    '3', '3', '3', '9', 'F', 'D', '2', '1', 'D', '2', '2', '8', '7', 'F', '4',
    '9', '1', 'A', '3', '8', '3', '7', '8', 'B', '1', '8', '7', 'E', 'D', '1',
    'F', '5', '7', '0', 'C', '8', 'C', '3', 'F', 'D', '0', 'D', 'B', '0', 'E',
    '2', '4', '3', '8', '0', '8', 'F', '3', '3', '0', 'B', '0', 'D', '0', 'C',
    'E', 'B', '4', 'A', 'F', '3', '7', 'D', '6', 'A', '6', 'A', 'E', '0', '6',
    '6', 'C', '5', 'C', '2', '2', 'E', 'E', 'D', '0', 'D', 'C', '3', '2', 'B',
    'C', '5', '7', 'F', '6', '3', '7', 'D', 'E', '1', '6', '1', 'F', '3', 'A',
    'B', '2', '2', 'B', 'A', '1', '7', '6', '8', '0', '8', 'C', '3', '9', '1',
    '6', 'D', 'B', '6', '2', 'F', 'E', '1', 'B', 'A', 'B', '5', 'C', '1', '5',
    '9', '\0'};

const unsigned char __MCC_MouseMassMeister_public_key[] = {
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

static const char * MCC_MouseMassMeister_matlabpath_data[] = 
  { "MouseMassMeister/", "$TOOLBOXDEPLOYDIR/", "ratter/ExperPort/MySQLUtility/",
    "ratter/ExperPort/MySQLUtility/win64/", "ratter/ExperPort/Modules/",
    "ratter/ExperPort/Settings/", "$TOOLBOXMATLABDIR/iofun/",
    "$TOOLBOXMATLABDIR/uitools/", "$TOOLBOXMATLABDIR/general/",
    "ratter/ExperPort/Utility/AutomatedEmails/", "ratter/Rigscripts/",
    "ratter/ExperPort/", "ratter/ExperPort/bin/",
    "ratter/ExperPort/HandleParam/", "ratter/ExperPort/Utility/",
    "ratter/ExperPort/FakeRP/", "ratter/ExperPort/Utility/WaterMeister/",
    "ratter/ExperPort/Utility/WeighAllRats/", "$TOOLBOXMATLABDIR/ops/",
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
    "toolbox/shared/slcontrollib/", "toolbox/finance/finance/",
    "toolbox/ident/ident/", "toolbox/ident/nlident/",
    "toolbox/ident/idobsolete/", "toolbox/ident/idutils/",
    "toolbox/shared/spcuilib/", "toolbox/instrument/instrument/",
    "toolbox/signal/signal/", "toolbox/signal/sigtools/" };

static const char * MCC_MouseMassMeister_classpath_data[] = 
  { "java/jar/toolbox/control.jar", "java/jar/toolbox/instrument.jar",
    "java/jar/toolbox/testmeas.jar" };

static const char * MCC_MouseMassMeister_libpath_data[] = 
  { "bin/win32/" };

static const char * MCC_MouseMassMeister_app_opts_data[] = 
  { "" };

static const char * MCC_MouseMassMeister_run_opts_data[] = 
  { "" };

static const char * MCC_MouseMassMeister_warning_state_data[] = 
  { "off:MATLAB:dispatcher:nameConflict" };


mclComponentData __MCC_MouseMassMeister_component_data = { 

  /* Public key data */
  __MCC_MouseMassMeister_public_key,

  /* Component name */
  "MouseMassMeister",

  /* Component Root */
  "",

  /* Application key data */
  __MCC_MouseMassMeister_session_key,

  /* Component's MATLAB Path */
  MCC_MouseMassMeister_matlabpath_data,

  /* Number of directories in the MATLAB Path */
  67,

  /* Component's Java class path */
  MCC_MouseMassMeister_classpath_data,
  /* Number of directories in the Java class path */
  3,

  /* Component's load library path (for extra shared libraries) */
  MCC_MouseMassMeister_libpath_data,
  /* Number of directories in the load library path */
  1,

  /* MCR instance-specific runtime options */
  MCC_MouseMassMeister_app_opts_data,
  /* Number of MCR instance-specific runtime options */
  0,

  /* MCR global runtime options */
  MCC_MouseMassMeister_run_opts_data,
  /* Number of MCR global runtime options */
  0,
  
  /* Component preferences directory */
  "MouseMassMeister_46A42F87BBA1886FD57D6B0E6233B7E2",

  /* MCR warning status data */
  MCC_MouseMassMeister_warning_state_data,
  /* Number of MCR warning status modifiers */
  1,

  /* Path to component - evaluated at runtime */
  NULL

};

#ifdef __cplusplus
}
#endif


