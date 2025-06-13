% [success, filename] = load_solouiparamvalues(obj, ratname, {'experimenter', ''}, {'interactive', 1}, ...
%                               {'owner', ''}, {'child_protocol', []})
% Loads a 'settings' file, which contains the value of all UI SoloParamHandles
% for the calling object, and sets the values of those SPHs to the value in
% the save file. Then calls all the callbacks for SPHs that had values that
% were loaded up.
%
% If the obj parameter is ommitted, then the object for which SPHs will be
% loaded is defined using the optional parameter 'owner'. If that is empty,
% then determine_owner.m is called; this will return the class of the
% object that called load_solouiparamvalues.m. For backwards compatibility,
% the optional parameter 'child_protocol' can be an object, and the class
% of child_protocol is used; but 'child_protocol' is deprecated and will be
% phased out.
%
% PARAMETERS:
% -----------
%
% obj      The object that owns all the SoloParamHandles for which values
%          are now being loaded. For backwards compatibility, this
%          parameter is optional-- see comments on optional param 'owner'
%          below.
%
% ratname  A string identifying a rat for which the settings are being
%          loaded. This string is used to identify the default
%          directory and filenames in which to look, but the user is free
%          to use the interactive chooser to decide to load a different
%          file.
%
%
% OPTIONAL PARAMETERS:
% --------------------
%
% experimenter   A string identifying th experimenter for which the
%          settings are being loaded. This string is used to identify the
%          default directory and filenames in which to look, but the user
%          is free to use the interactive chooser to decide to load a
%          different file.
%
% interactive   By default 1: a value of 1 in this flag indicates that an
%          interactive file chooser menu will be displayed, and the user
%          can browse through the file tree and decide which file to load.
%          If this flag is passed as zero, then no chooser is displayed,
%          and the default file is loaded. The default file is
%             MainDataDir/Settings/experimenter/ratname/settings_@owner_experimenter_ratname_YYMMDDc.mat
%          where "YYMMDD" refers to the year, month, and day of the latest
%          such file that exists (but not later than today), and c is the
%          latest one-letter extension ('a', 'b', 'c', 'd', etc.);
%          "experimenter" is determined by the optional pararmeter above;
%          "ratname" is the parameter above; @owner is typically a
%          protocol: e.g., "@Classical", determined by either the obj
%          parameter or the optional parameter "owner" below (see full
%          comments below); and MainDataDir is obtained from the Settings.m
%          system under the 'GENERAL'  'Main_Data_Directory' entry.
%
% owner    A string identifying the owner of the SoloParamHandles that will
%          have their values loaded from the settings file. This owner is
%          determined in the following way: First, if the param obj (see
%          above) is passed in, then owner = ['@' class(obj)]. Second, if
%          obj is not passed in, but the optional param 'child_protocol' is
%          passed, then owner = ['@' class(child_protocol)]. This
%          child_protocol param approach is deprecated and will be phased out.
%          Third, if the above fail, and the optional param owner was
%          passed in as a string, that string is used as the owner. An
%          initial '@' is prepended to it if it doesn't have one. Fourth,
%          if none of the above produced a string, determine_owner.m is
%          called to determine the class of the function that called
%          load_solouiparamvalues.m, and that is used as the owner string
%          (with a '@' at the front).
%
% child_protocol   See comments for optional param 'owner' above
%
% rescan_during_load     By default empty matrix. If instead of empty we're
%          passed a cell (which should contain a list of SoloParamHandles),
%          then it means "IF you're in the middle of a load, check for
%          values of these guys only, then return. If you're not in the
%          middle of a load, just return."
%
%
%
% RETURNS:
% --------
%
% success  This is retured as 1 if the settings were loaded, and as 0 if
%          they were not loaded (e.g., user hit cancel, or file not found,
%          or any other reason).
%
% filename The full filename, including full path, of the file that was
%          loaded.
%
%
% EXAMPLES:
% ---------
%
%  load_solouiparamvalues('B004', 'experimenter', 'Bing');
%
%  load_solouiparamvalues('Lupin', 'experimenter', 'Shraddha', 'owner', 'duration_disc');
%
%  load_solouiparamvalues(obj, 'B004', 'experimenter', 'Bing', 'interactive', 0);
%



function [outflag, varargout] = load_solouiparamvalues(ratname, varargin)
global     Solo_datadir;
persistent loaded_data;

% First test to see whether first param was an object:
if isobject(ratname),
    obj = ratname; ratname = varargin{1}; varargin = varargin(2:end);
else
    obj = '';
end;

pairs = { ...
    'child_protocol',     [] ; ...
    'owner',              '' ; ...
    'experimenter'  ,     '' ; ...
    'interactive',         1 ; ...
    'rescan_during_load', [] ; ...
    'settings_file', ''; ...
    'require_success', 0 };
parse_knownargs(varargin, pairs);

% If we're passed a list of SoloParamHandles in optional param
% rescan_during_load, it means "IF you're in the middle of a load, check
% for values of these guys only, then return. If you're not in the middle
% of a load, just return."
if iscell(rescan_during_load)
    if ~isempty(loaded_data),
        owner = ['@' class(obj)];
        outflag = loading_core_load_sequence(rescan_during_load, owner, loaded_data, 'settings');
    else
        outflag = 0;
    end;
    return;
end;
if      ~isempty(child_protocol), owner = class(value(child_protocol)); end; % the child protocol owns all vars
if      isempty(owner), owner = determine_owner;
elseif  ~ischar(owner), error('optional param owner must be a string');
end;
if      owner(1) ~= '@', owner = ['@' owner]; end;
% However, the obj param, if it was passed, trumps all:
if ~isempty(obj), owner = ['@' class(obj)]; end;

if isempty(settings_file) % if you pass in the filename just load it
    
    if ~isempty(experimenter) && ~ischar(experimenter),  error('optional param experimenter must be a string'); end;
    
    settings_path = loading_define_sets_or_data_directory(Solo_datadir, experimenter, 'settings');
    
    [fullname, no_settings_flag] = loading_latest_filename_matching_experimenter_and_rat(settings_path, ...
        owner, experimenter, ratname, 'settings');
    if nargout>=2, varargout{1}=fullname; end;
    
    % ------- Confirm the filename to be loaded
    if interactive
        fullname = loading_interactive_choose_fileandpath(fullname, owner, experimenter, ratname, 'settings');
        if nargout>=2, varargout{1}=fullname; end;
        if isequal(fullname, 0), outflag = 0; return; end;  % if user cancels load, do nothing
    else % non-interactive case:
        if no_settings_flag
            warnDLG('No Settings for this rat, using protocol defaults','NO SETTINGS!');
            outflag=0;
            return;
        end;
    end;
    % ------- End of confirm the filename to be loaded, now to load it:
else
    fullname=settings_file;
end
try  loaded_data = load(fullname);
catch
    errordlg(lasterr)
    outflag=0;
    return;
end

% If there was a figure position loaded, then set the main fig position:
if exist('fig_position', 'var'),
    loading_set_main_figure_position(owner, loaded_data.fig_position);
end;


% Ok, data file has beed loaded, and structs named saved, etc. now exist
% in the current workspace. Now, to set the appropriate values of
% SoloParamHandles.

% Determine all handles whose values should be set when loading settings:
handles = find_all_settings_loadable_handles(owner);

outflag = loading_core_load_sequence(handles, owner, loaded_data, 'settings');
loaded_data = [];
if ~outflag && require_success
    error('Failed to load settings');
end
return;






%% find_all_settings_loadable_handles

function [handles] = find_all_settings_loadable_handles(owner)
%
% owner should be a string, first char '@'.
%
% This function returns a cell vector with entries being all the handles
% whose values should be obtained when loading a settings file.
%

handles = get_sphandle('owner', owner);
k = false(size(handles));
for i=1:length(handles),
    % If you're not a display, pushbutton, header, or subheader; and
    % you're a GUI SoloParamHandle (i.e., your type isn't empty) or you were marked
    % to be save with settings; then you will get loaded up.
    if (~isempty(get_type(handles{i})) || get_save_with_settings(handles{i}))  &&  ...
            ~ismember(get_type(handles{i}), {'disp' 'pushbutton' 'header' 'subheader'}),
        k(i) = true;
    end;
end;
handles = handles(k);


