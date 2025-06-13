% <~> .../Modules/@SettingsObject/LoadSettings.m
%     Load settings from file; BControl system;
%     this file written by Sebastien Awwad, 2007
%
%     The interface to the Settings object is Modules/Settings.m, and so is
%       its documentation. The documentation here is specifically for this
%       method.
%
%
%     LoadSettings reads the settings values in from a settings file.
%
%     Settings are saved as strings, unless a str2double call on them does
%       not return NaN, in which case they are saved, retrieved, etc. as
%       doubles.
%
%
%     The specification for settings file format is available in the file
%       Settings/Settings_Default.conf
%     and also in the BControl wiki at
%       http://brodylab.princeton.edu:/bcontrol
%
%     Here is a quick example:
%          <setting1 group name>;  <setting1 name>; <setting1 value>;
%          <setting1 group name>;  <setting1 name>; <setting1 value>;
%
%
%
%   ARGUMENTS:
%       2 arguments:
%           1st: a SettingsObject to load values into
%           2nd: filename of settings file to load values from
%
%   RETURNS:        [SO errID errmsg]
%       SO:       the SettingsObject, with settings loaded in
%       errID:       (** indicates that an error is thrown in this case)
%         0:      no problem
%         1:      file string empty or file does not exist
%         2:      file could not be: either [found], [opened], [read from],
%                   or [parsed as a correctly-formatted settings file].
%         -1:     LOGICAL ERROR IN THIS CODE (Review recent changes!)
%     **  10:     Bad call (wrong arguments - THROWS AN ERROR)
%       errmsg:
%         '' if OK, else an informative error message
%
%
%
%      HELPER FUNCTIONS at the end of this file:
%           err_and_errdlg
%
function [SO errID errmsg] = LoadSettings(SO, filename)
errID = -1; errmsg = ''; %#ok<NASGU> (errID=-1 OK despite unused)
errorlocation = 'ERROR in Modules/@SettingsObject/LoadSettings.m';


%     -------------------------------------------------------------
%     -------  Incorrect number or type of arguments handling
%     -------------------------------------------------------------
%     Generate an error iff* we have n args where n~=2.
error(nargchk(2, 2, nargin, 'struct'));

if ~ischar(filename),
    errmsg = [errorlocation ': Second argument is not a string. It must be a string specifying the filename of the settings file to load.'];
    errID = 10;
    err_and_errdlg(errmsg);
    return;
end;


%     -------------------------------------------------------------
%     -------  Normal Error Handling
%     -------------------------------------------------------------
%     Bad filename.
if isempty(filename) || ~exist(filename, 'file'),
    errmsg = [errorlocation ': Unable to load settings file - filename given (' filename ') is blank or refers to a file that does not exist.'];
    errID = 1;
    return;
end;



%     -------------------------------------------------------------
%     -------  READING SETTINGS FILE: Notes
%     -------------------------------------------------------------
%     Settings are first loaded into three vectors:
%           Three tokens per line in the settings file.
%           Three vectors: <Group Name>, <Setting Name>, <Setting Value>.
%           One token assigned to each vector per line.
%     Values in the file must be delimited by the
%       delimiter character above. The intent is to have three
%       values in the settings file on each line, so that the left
%       value is the setting's name and the right value the setting's
%       value.
%     Group name / setting name tokens: longest non-empty strings that
%       do not include spaces or selected delimiters.


%     -------------------------------------------------------------
%     -------  READING SETTINGS FILE: Parameters for file reading
%     -------------------------------------------------------------
%     Any text after this character and on the same line will be entirely
%       ignored. !! Note - because we're using textread again, this cannot
%       be changed to any arbitrary value, but MUST be %, and only the
%       commentstyle parameter in the textread call MUST be 'matlab'.
commentcharacter                = '%';

%     A set of characters, any one of which will separate elements in the
%       settings file.
%     Obviously, the comment character cannot be used as a delimiter, even
%       though it is included in this string.
%     Believe me when I say that the delimiter-commentcharacter-whitespace
%       interaction is BIZARRE and required a lot of testing and tweaking.
%       I've tested lots of unusual circumstances and I'm happy with the
%       way it stands now; please take care to test thoroughly when
%       changing format code.
delimiter                       = [';' commentcharacter];

%     The following names cannot be used as setting groups (and neither can
%       MATLAB reserved variable names - i.e. neither can anything that
%       would fail isvariable().
%     They will eventually be used for advanced setting retrieval.
reserved_names            = ['all', 'none'];

%     We treat NAMES (group name, setting name) differently from setting
%       VALUES.
%     NAMETOKEN will be part of the format string to restrict group and
%       setting name reading. For the value, we just use '%s' in the format
%       string.
%     The nametoken format string basically stops the token when a space is
%       encountered, which is not the usual behavior when the delimiter
%       is not a space.... Listing the delimiter is necessary because the
%       format string '%[^...]' apparently overrides the delimiter
%       selection....
%     This odd arrangement cannot be avoided by special delimiter
%       selection, the whitespace characters are required here because \b
%       or \n or something of that sort is included in certain tokens
%       otherwise, and we also include the comment character (which is in
%       the delimiter string) for safety.
nametoken       = ['%[^ \b\t\n' delimiter ']'];

%     We permit spaces in the settings VALUES. Spaces preceding the first
%       non-whitespace character in the value are excluded, as with other
%       tokens, and terminal whitespace for the values is shaved off
%       afterwards using strtrim, instead of beforehand, so that we can
%       include internal spaces.
formatstring    = [nametoken ' ' nametoken ' %s'];


%     -------------------------------------------------------------
%     -------  READING SETTINGS FILE: Read Code
%     -------------------------------------------------------------
try
    %     Read the group/name/value tokens into three vectors.
    [setting_groups setting_names setting_values] = ...
        textread(filename                           ...
        ,    formatstring                           ...
        ,    'commentstyle',     'matlab'           ...
        ,    'delimiter',        delimiter          ...
        );
catch
    lasterror_temp = lasterror; %     We have to copy lasterror to use it.
    errmsg = [errorlocation ': settings file specified ("' filename '") is not a properly formatted settings file (or file open/reading failed or was interrupted). See sample settings file Settings_Custom_Sample.conf. Error received from textread:  ' lasterror_temp.message];
    errID = 2;
    return;
end; %     end try/catch read in settings


%     If there isn't a setting_group, setting_name, and setting_value
%       component to each entry, return with an error.
if length(setting_names)~=length(setting_values) || length(setting_names)~=length(setting_groups),
    errID = 2;
    errmsg = [errorlocation ': settings file specified (' filename ') does not have a group, setting name, and setting value component for each setting entry. Are there extra semicolons? Is each setting on one line?'];
    return;
end;



%     -------------------------------------------------------------
%     -------  Verification and Loading into SettingsObject
%     -------------------------------------------------------------
%     Iterate through the settings to:
%       - add them into a structure heirarchy
%           wherein every settings group is a structure that is a field of
%           the settings object and every setting is a field of the
%           structure of the settings group it belongs to.
%       - check for invalid names for settings or settings groups
%       - shave off trailing whitespace in tokens
%       - if the value is numeric, save it as such
j = 1;
while j <= length(setting_names),
    groupname       = strtrim(setting_groups{j});
    settingname     = strtrim(setting_names{j});
    settingvalue    = strtrim(setting_values{j});
    settingvalueNum = str2double(settingvalue);
    if ~isnan(settingvalueNum) || strcmpi(settingvalue,'NaN'),
        settingvalue = settingvalueNum;
    end;
    if ~isvarname(groupname) || ~isvarname(settingname),
        errID = 2;
        errmsg = [errorlocation ': Setting NAME strings and setting group NAME strings must be valid as MATLAB variables - i.e. no INTERNAL spaces, no special characters, no starting with numbers, etc. Found bad name/group string in settings file "' filename '", Setting #' int2str(j) ' --- group name string: "' groupname '", setting name string: "' settingname '", setting value string: "' settingvalue '".'];
        return;
    elseif strcmpi(groupname,reserved_names) || strcmpi(settingname,reserved_names),
        errID = 2;
        errmsg = [errorlocation ': Setting name strings and setting group strings must not clash with certain SettingsObject reserved names (like "any" or "all"). Found bad name/group string in settings file "' filename '", Setting #' int2str(j) ' --- group name string: "' groupname '", setting name string: "' settingname '", setting value string: "' settingvalue '".'];
        return;
    elseif strcmpi(groupname,'DO_'),
        %     If the "groupname" is _DO, this line of the settings file is
        %       a command we are to interpret, not a setting to be saved.
        %     Right now, the only option is the command "include".
        if strcmpi('INCLUDE',settingname),
            display([' Modules/@SettingsObject/LoadSettings executing DO_ INCLUDE command: ' filename ' is including ' settingvalue '. (Beware of infinite include loops.)']);
            [SO e m] = LoadSettings(SO,settingvalue);
            if e,
                errID = e;
                errmsg = [errorlocation ': Attempt to load settings file in response to DO_ INCLUDE returned the following error:   ' m];
                return;
            end;
            %     display(['      DO_ INCLUDE command (including "' settingvalue '" into "' filename '") seems to have worked. Now continuing loading of "' filename '" from the line after the DO_ INCLUDE.']);
            j = j + 1; %     THIS LINE IS BAD FORM! I should restructure this next time so that it only happens in one place. /:
            continue;
        elseif strcmpi('ECHO',settingname),
            display(['@SettingsObject/LoadSetting reports: DO_ ECHO command in ' filename '; echoing:    ' settingvalue]);
            j = j + 1; %     THIS LINE IS BAD FORM! I should restructure this next time so that it only happens in one place. /:
            continue;
        else
            errID = 2;
            errmsg = [errorlocation ': Command in settings file was not recognized. "DO_" indicated a command line, but the command itself is incorrectly written. Example command: "include". Example line: "DO_; INCLUDE; somefile.conf;". Bad string was in settings file "' filename '", Setting #' int2str(j) ' --- group name string: "' groupname '", COMMAND string: "' settingname '", COMMAND argument: "' settingvalue '".'];
            return;
        end;
    end;
    %     Create the structure for the settings group if it does not
    %       already exist.
    if ~isfield(SO.settings,groupname),
        SO.settings.(groupname) = struct;
    end;
    
    
    %     Finally, assign the setting value to the field matching the
    %     setting name in the struct matching the group name.
    %     TRIM OFF trailing (and leading, though that shouldn't exist)
    %       whitespace.
    SO.settings.(groupname).(settingname) = settingvalue;

    j = j + 1;
end; %     end while (iterate over setting names/groups)


errID = 0;
return;








%     REDUNDANT BELOW
%     must decide where to put them in the end

%     Helper function that simply prints a string in an error dialog and
%       also calls error(<that string>).
function [] = err_and_errdlg(error_string)
errordlg(error_string);
error(error_string);
