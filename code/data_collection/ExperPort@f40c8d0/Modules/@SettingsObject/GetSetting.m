%     .../Modules/@SettingsObject/GetSetting.m
%     Get a loaded setting; BControl system;
%     this file written by Sebastien Awwad, 2007
%
%     The interface to the Settings object is Modules/Settings.m, and so is
%       its documentation. The documentation here is specifically for this
%       method.
%
%
%     GetSetting returns the value of the setting whose group name and
%       setting name match the strings passed in.
%
%
%     ARGUMENTS:
%       - N=3 args, 1ST ARG = SettingsObject object,
%                   2ND ARG = string, the setting group name
%                   3RD ARG = string, the setting name or "all" to retrieve
%                                       all settings in a group
%
%     RETURNS:          [settingvalue errID errmsg]
%         settingvalue:   the requested setting, or NaN on error;
%                         can also be cell array that is an entire setting
%                           group if the reserved word "all" (case
%                           insensitive) is used in place of a setting name
%                           (cell format e.g.
%                               {setting1name, setting1val, setting1group;
%                                setting2name, setting2val; setting2group...}
%                            and in this case, all setting groups will be
%                            the same)
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
%       [main_directory errID errmsg] = ...
%           GetSetting(BControl_Settings, 'MAIN', 'Main_Directory');
%       [dioline_names errID errmsg] = ...
%           GetSetting(BControl_Settings, 'DIOLINES', 'all');
%
%
%
% % %      HELPER FUNCTIONS at the end of this file:
% % %           err_and_errdlg
% % %
function [setting_value errID errmsg] = GetSetting(SO, setting_group, setting_name)
errID = -1; errmsg = ''; %#ok<NASGU> (errID=-1 OK despite unused)
errorlocation = 'ERROR in Modules/@SettingsObject/GetSetting.m';
setting_value = NaN;

%     -------------------------------------------------------------
%     -------  Incorrect number or type of arguments cases
%     -------------------------------------------------------------
%     Generate an error iff* we have n args where n~=3.
error(nargchk(3, 3, nargin, 'struct'));

%     Is this even possible without foolishly
%       changing path/directory structure?
%     This will probably only be seen when the class's name is changed and
%       this use of it is missed. Hello.
if ~isa(SO,'SettingsObject')
    errID = 10;
    errmsg = [errorlocation ': First argument is not a SettingsObject. Has SettingsObject class name changed recently?'];
    
elseif ~ischar(setting_name) || ~ischar(setting_group),
    errID = 10;
    errmsg = [errorlocation ': Must have 3 args, the first being the SettingsObject object, the second being the name of a settings group, and the third being the name of a setting in that group.'];
    
elseif isempty(setting_name)
    errID = 10;
    errmsg = [errorlocation ': Now what sense does it make to try to retrieve an empty-name setting?'];

elseif NoSettingsLoaded(SO)==1,
    errID = 7;
    errmsg = [errorlocation ': No settings have been loaded at all, so none can be retrieved....'];
    
elseif ~isfield(SO.settings,setting_group),
    errID = 3;
    errmsg = [errorlocation ': No setting group with the given name ("' setting_group '") exists.'];

elseif ~strcmpi(setting_name,'all') && ~isfield(SO.settings.(setting_group),setting_name),
    errID = 1;
    errmsg = [errorlocation ': No setting with the given name ("' setting_name '") exists in the group "' setting_group '".'];

else   %     NORMAL CASE
    setting_group_struct = SO.settings.(setting_group); %get group struct
    %     First, check to see if a reserved word is used instead of a
    %       setting. For now, we only recognize "all" (case insensitive).
    if strcmpi(setting_name,'all'),
        setting_value = {};
        f = fields(setting_group_struct);
        for i = 1:length(f),
            setting_value{i,1} = f{i};
            setting_value{i,2} = setting_group_struct.(f{i});
            setting_value{i,3} = setting_group;
        end;
        errID = 0;
    else    %     otherwise, we're just fetching one setting
        setting_value = setting_group_struct.(setting_name);
        errID = 0;
        return;
    end;        %end if/else reserved word and retrieval
    
end;

%     Can only reach this point if there WAS an error.

%err_and_errdlg(errmsg); %     For now, we halt (debugging).

return;







% % 
% % %     REDUNDANT BELOW
% % %     must decide where to put them in the end
% % 
% % % <~> Helper function that simply prints a string in an error dialog and
% % %       also calls error(<that string>).
% % function [] = err_and_errdlg(error_string)
% % errordlg(error_string);
% % error(error_string);

