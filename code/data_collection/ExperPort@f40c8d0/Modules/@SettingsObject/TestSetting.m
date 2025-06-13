%     .../Modules/@SettingsObject/TestSetting.m
%     Compare a loaded setting to given value; BControl system;
%     this file written by Sebastien Awwad, 2007
%
%     The interface to the Settings object is Modules/Settings.m, and so is
%       its documentation. The documentation here is specifically for this
%       method.
%
%
%     TestSetting returns true (1) if the given setting has the given
%       value, otherwise it returns false (0). Explicitly:
%     TestSetting returns either true or false as its primary return value,
%       always returning false unless the given setting ...
%           -     exists (was loaded into this setting object)
%           - AND an isequal call on the two values returns true
%         ... in which case TestSetting returns true.
%
%     If this function is not called with the proper arguments, it throws
%       an error.
%     Please note that if the given comparison value is logical, it will
%       not be considered to match the setting, which is never stored as a
%       logical (but instead as a double).
%
%
%     ARGUMENTS:
%       - N=4 args, 1ST ARG = SettingsObject object,
%                   2ND ARG = string, the setting group name
%                   3RD ARG = string, the setting name
%                   4TH ARG = any type, the value to which to compare the
%                                         loaded setting's value
%
%     RETURNS:          [are_equal errID errmsg]
%         are_equal: logical true(1) for same and false (0) for not same
%                    See above.
%         errID:
%           0:      no problem
%           1:      setting does not exist
%           3:      group does not exist
%           7:      no settings loaded
%           -1:     LOGICAL ERROR IN THIS CODE (e.g. errID never set)
%           10:     Bad call (wrong arguments - may error out)
%         errmsg:
%           '' if OK, else an informative error message
%
%
%     EXAMPLE CALL:
%       [main_dir_is_ratter errID errmsg] = ...
%           TestSetting(BControl_Settings, 'Main_Settings', 'Main_Directory', '/ratter');
%
%
%
%      HELPER FUNCTIONS at the end of this file:
%           err_and_errdlg
%
function [are_equal errID errmsg] = TestSetting(SO, setting_group, setting_name, comparison_value)
errID = -1; errmsg = ''; %#ok<NASGU> (errID=-1 OK despite unused)
errorlocation = 'ERROR in Modules/@SettingsObject/TestSetting.m';
are_equal = false;

%     -------------------------------------------------------------
%     -------  Incorrect number or type of arguments cases
%     -------------------------------------------------------------
%     Generate an error iff* we have n args where n~=4.
error(nargchk(4, 4, nargin, 'struct'));

if ~ischar(setting_name) || ~ischar(setting_group),
    errID = 10;
    errmsg = [errorlocation ': Must have 4 args, the first being the SettingsObject object, the second being the name of a settings group, the third being the name of a setting in that group, and the fourth being a value to compare the loaded value to.'];
    err_and_errdlg(errmsg);
    
elseif isempty(setting_name)
    errID = 10;
    errmsg = [errorlocation ': Now what sense does it make to try to compare to a namelesa setting?'];
    err_and_errdlg(errmsg);
    
elseif NoSettingsLoaded(SO)==1,
    errID = 7;
    errmsg = [errorlocation ': No settings have been loaded at all, so none can be compared....'];
    
elseif ~isfield(SO.settings,setting_group),
    errID = 3;
    errmsg = [errorlocation ': No setting group with the given name ("' setting_group '") exists.'];

elseif ~isfield(SO.settings.(setting_group),setting_name),
    errID = 1;
    errmsg = [errorlocation ': No setting with the given name ("' setting_name '") exists in the group "' setting_group '".'];

else   %     NORMAL CASE
    setting_value = SO.settings.(setting_group).(setting_name);
    are_equal = isequal(comparison_value,setting_value);
    errID = 0;
end;  %end if-various-mistakes-else-normal-case


%     Can only reach this point if there WAS an error.

%err_and_errdlg(errmsg); %     For now, we halt (debugging).

return;








%     REDUNDANT BELOW
%     must decide where to put them in the end

% <~> Helper function that simply prints a string in an error dialog and
%       also calls error(<that string>).
function [] = err_and_errdlg(error_string)
errordlg(error_string);
error(error_string);

