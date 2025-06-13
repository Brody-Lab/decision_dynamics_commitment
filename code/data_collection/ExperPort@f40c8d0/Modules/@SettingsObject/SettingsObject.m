%     .../Modules/@SettingsObject/SettingsObject.m, constructor
%     SettingsObject constructor; BControl system;
%     this file written by Sebastien Awwad, 2007
%
%     The interface to the Settings object is Modules/Settings.m, and so is
%       its documentation. The documentation here is specifically for the
%       constructor.
%
%     At the present, only two argument sets are acceptable:
%       0 ARGUMENTS:
%           Returns a SettingsObject that is ready to load settings but
%             has not yet loaded any settings.
%
%       1 ARGUMENT:   a SettingsObject
%           Returns (a copy of) the passed-in SettingsObject.
%
%       Calling this constructor with any other argument set results in an
%         error.
%
%
%     The internal representation of settings is as follows:
%     The SettingsObject object (SO here) contains a struct SO.settings.
%     Each settings group is a struct within the struct SO.settings.
%     Settings are fields within the settings group structs.
%     Example SO.settings (not real settings):
%          SO.settings.MAIN:
%               SO.settings.MAIN.bcontrol_directory = '/ratter/ExperPort'
%          SO.settings.CVS:
%               SO.settings.CVS.cvs_username = 'brodyrigxp01'
%               SO.settings.CVS.cvs_commitflag = 0
%          SO.settings.SOLO:
%               SO.settings.VIDEO.video_flag = 1
%               SO.settings.VIDEO.video_script = 'video_start.bat'
%
function SO = SettingsObject(varargin)



%     ---------------------------------------------------------------
%     -------  Argument Number Check
%     ---------------------------------------------------------------
%     If new non-varargin arguments have been added,
%       this function must then be revised.
if nargin ~= length(varargin)
    error('    PROGRAMMING ERROR: SettingsObject.m has been changed, but code needs to be adjusted to handle the new potential arguments.');
end;
%     Generate an error iff* we have n args where n>1.
error(nargchk(0, 1, nargin, 'struct'));


%     ---------------------------------------------------------------
%     -------  Special Case Handling
%     ---------------------------------------------------------------
%     Special cases (required by MATLAB)
if nargin
    if nargin~=1, error('     PROGRAMMING ERROR. Impossible condition. Argument checking has been muddled by changes to the code.');
    end;
    if isa(varargin{1},mfilename)       %     1st arg is SettingsObject?
        SO = varargin{1};               %     return it (a copy)
        return;
    else
        error('     Modules/SettingsObject/SettingsObject.m constructor only accepts: 0 arguments or 1 argument (another SettingsObject to copy)');
    end;
    error('     PROGRAMMING ERROR. Not possible to reach this line. Code changes have broken something.');
end;   %     end if-we-have-arguments



%     ---------------------------------------------------------------
%     -------  Standard Case - create object and return
%     ---------------------------------------------------------------
%     No arguments. Handle normally.
%     Create the empty object and return.
SO          = struct;               %     Create the empty SettingsObject.
SO.settings = struct;               %     Internal data struct. See below.
SO          = class(SO,mfilename);  %     Assign the SO object its class.
return;
