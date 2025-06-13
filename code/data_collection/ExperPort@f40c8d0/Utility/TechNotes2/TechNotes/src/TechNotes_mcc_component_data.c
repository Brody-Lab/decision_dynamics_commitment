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

#include "mclmcrrt.h"

#ifdef __cplusplus
extern "C" {
#endif
const unsigned char __MCC_TechNotes_session_key[] = {
    'B', '0', '1', '2', '1', 'A', '6', '2', 'C', 'F', 'E', '3', 'B', 'F', 'C',
    '5', 'F', '3', '7', '6', '0', 'C', '6', 'B', 'B', '3', 'C', 'A', 'F', '0',
    'E', 'A', 'F', '8', 'A', '1', '0', '5', 'A', 'F', '3', '6', 'C', '2', '8',
    '4', '5', '0', '6', 'B', 'C', '1', '2', 'B', '0', '2', 'F', '4', 'D', 'C',
    '8', '5', 'D', 'D', 'C', '4', 'B', '0', '7', 'B', '9', '7', 'E', 'A', '5',
    '1', '2', 'D', '3', '0', 'F', '2', 'E', '5', '5', '9', 'A', 'B', '5', '2',
    '6', '1', '0', 'B', 'E', '3', 'F', '9', '3', '1', '4', '3', '1', '2', '9',
    '1', 'B', '2', 'E', '4', '3', '7', '0', 'F', 'E', '1', '8', '3', '1', '8',
    '9', 'C', 'F', 'C', '1', 'C', '3', 'E', '6', 'E', '1', '8', 'A', '5', '1',
    'C', '0', '0', '7', '1', '6', 'C', 'A', '3', '0', 'C', 'E', '8', '6', '8',
    '8', '5', 'D', '2', 'B', 'C', '1', '8', 'A', '6', '9', '4', '1', '1', '3',
    '8', 'F', '6', 'B', '4', '5', 'B', 'B', 'C', '5', '1', 'C', '4', '9', '9',
    'A', '8', '7', '5', 'A', '1', '7', 'A', 'B', '2', 'A', '9', '6', 'C', 'C',
    '4', 'C', '4', '9', 'E', '4', '3', '6', '7', 'C', 'E', '3', 'C', 'D', '9',
    'B', 'F', 'F', 'E', 'E', 'E', 'E', '8', 'B', 'C', 'F', 'C', 'B', '7', '3',
    '3', 'B', '6', '0', '8', 'F', '4', 'C', 'F', 'B', 'E', 'D', '7', '6', 'E',
    'A', '2', '9', 'A', '0', 'F', 'F', '1', 'E', '2', '1', '8', '5', '8', 'C',
    '7', '\0'};

const unsigned char __MCC_TechNotes_public_key[] = {
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

static const char * MCC_TechNotes_matlabpath_data[] = 
  { "TechNotes/", "$TOOLBOXDEPLOYDIR/", "ratter/ExperPort/MySQLUtility/",
    "ratter/ExperPort/MySQLUtility/win64/", "ratter/ExperPort/Utility/ratinfo/",
    "ratter/ExperPort/Utility/AutomatedEmails/", "$TOOLBOXMATLABDIR/iofun/",
    "$TOOLBOXMATLABDIR/uitools/", "ratter/ExperPort/",
    "ratter/ExperPort/HandleParam/", "ratter/ExperPort/Utility/",
    "ratter/ExperPort/Utility/Zut/", "ratter/Rigscripts/",
    "ratter/ExperPort/FakeRP/", "$TOOLBOXMATLABDIR/general/",
    "$TOOLBOXMATLABDIR/ops/", "$TOOLBOXMATLABDIR/lang/",
    "$TOOLBOXMATLABDIR/elmat/", "$TOOLBOXMATLABDIR/randfun/",
    "$TOOLBOXMATLABDIR/elfun/", "$TOOLBOXMATLABDIR/specfun/",
    "$TOOLBOXMATLABDIR/matfun/", "$TOOLBOXMATLABDIR/datafun/",
    "$TOOLBOXMATLABDIR/polyfun/", "$TOOLBOXMATLABDIR/funfun/",
    "$TOOLBOXMATLABDIR/sparfun/", "$TOOLBOXMATLABDIR/scribe/",
    "$TOOLBOXMATLABDIR/graph2d/", "$TOOLBOXMATLABDIR/graph3d/",
    "$TOOLBOXMATLABDIR/specgraph/", "$TOOLBOXMATLABDIR/graphics/",
    "$TOOLBOXMATLABDIR/strfun/", "$TOOLBOXMATLABDIR/imagesci/",
    "$TOOLBOXMATLABDIR/audiovideo/", "$TOOLBOXMATLABDIR/timefun/",
    "$TOOLBOXMATLABDIR/datatypes/", "$TOOLBOXMATLABDIR/verctrl/",
    "$TOOLBOXMATLABDIR/codetools/", "$TOOLBOXMATLABDIR/helptools/",
    "$TOOLBOXMATLABDIR/winfun/", "$TOOLBOXMATLABDIR/demos/",
    "$TOOLBOXMATLABDIR/timeseries/", "$TOOLBOXMATLABDIR/hds/",
    "$TOOLBOXMATLABDIR/guide/", "$TOOLBOXMATLABDIR/plottools/",
    "toolbox/local/", "toolbox/shared/dastudio/",
    "$TOOLBOXMATLABDIR/datamanager/", "toolbox/compiler/" };

static const char * MCC_TechNotes_classpath_data[] = 
  { "" };

static const char * MCC_TechNotes_libpath_data[] = 
  { "" };

static const char * MCC_TechNotes_app_opts_data[] = 
  { "" };

static const char * MCC_TechNotes_run_opts_data[] = 
  { "" };

static const char * MCC_TechNotes_warning_state_data[] = 
  { "off:MATLAB:dispatcher:nameConflict" };


mclComponentData __MCC_TechNotes_component_data = { 

  /* Public key data */
  __MCC_TechNotes_public_key,

  /* Component name */
  "TechNotes",

  /* Component Root */
  "",

  /* Application key data */
  __MCC_TechNotes_session_key,

  /* Component's MATLAB Path */
  MCC_TechNotes_matlabpath_data,

  /* Number of directories in the MATLAB Path */
  49,

  /* Component's Java class path */
  MCC_TechNotes_classpath_data,
  /* Number of directories in the Java class path */
  0,

  /* Component's load library path (for extra shared libraries) */
  MCC_TechNotes_libpath_data,
  /* Number of directories in the load library path */
  0,

  /* MCR instance-specific runtime options */
  MCC_TechNotes_app_opts_data,
  /* Number of MCR instance-specific runtime options */
  0,

  /* MCR global runtime options */
  MCC_TechNotes_run_opts_data,
  /* Number of MCR global runtime options */
  0,
  
  /* Component preferences directory */
  "TechNotes_98E8858245D3B69C513282FB537C049F",

  /* MCR warning status data */
  MCC_TechNotes_warning_state_data,
  /* Number of MCR warning status modifiers */
  1,

  /* Path to component - evaluated at runtime */
  NULL

};

#ifdef __cplusplus
}
#endif


