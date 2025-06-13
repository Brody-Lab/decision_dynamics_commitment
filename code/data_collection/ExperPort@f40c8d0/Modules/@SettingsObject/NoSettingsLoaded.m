%     .../Modules/@SettingsObject/NoSettingsLoaded.m
%     SettingsObject method; BControl system;
%     this file written by Sebastien Awwad, 2007
%
%     The interface to the Settings object is Modules/Settings.m, and so is
%       its documentation. The documentation here is specifically for this
%       method.
%
%     The only argument must be the SettingsObject to check for settings
%       in.
%
%     Returns:
%           1  if there are no settings found in the SettingsObject
%           0  if there are settings loaded from some settings file
%           -1 if programming error: return value not set (code changed)
%
function emptiness = NoSettingsLoaded(SO)
emptiness = -1;

%     Generate an error iff* we have n args where n~=1.
error(nargchk(1, 1, nargin, 'struct'));

if isempty(SO.settings) || isempty(fields(SO.settings)),
    emptiness = 1;
else
    emptiness = 0;
end;
    return;