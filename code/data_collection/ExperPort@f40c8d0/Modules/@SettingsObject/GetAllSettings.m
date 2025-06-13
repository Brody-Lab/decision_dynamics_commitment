%     .../Modules/@SettingsObject/GetAllSettings.m
%     SettingsObject method; BControl system;
%     this file written by Sebastien Awwad, 2007
%
%     The interface to the Settings object is Modules/Settings.m, and so is
%       its documentation. The documentation here is specifically for this
%       method.
%
%     The only argument must be the SettingsObject to read settings from.
%
%
%
%     Returns:          [settings errID errmsg]
%
%           settings:     a struct with format:
%             settings.groupname.settingname = settingval
%             (fieldless struct if the SettingsObject contains no settings)
%
%           errID:           
%             1  if the SettingsObject contains no settings
%             0  if there are settings loaded from some settings file
%             -1 if programming error: return value not set (code changed)
%
%           errmsg:
%             always '' currently
%
function [settings errID errmsg] = GetAllSettings(SO)
errID = -1; errmsg = ''; %#ok<NASGU> (errID=-1 OK despite unused)

%     Generate an error iff* we have n args where n~=1.
error(nargchk(1, 1, nargin, 'struct'));

if NoSettingsLoaded(SO)==1,
    errID = 1; settings = struct; errmsg = 'No settings loaded.';
else
    errID = 0; settings = SO.settings;
end;
return;
