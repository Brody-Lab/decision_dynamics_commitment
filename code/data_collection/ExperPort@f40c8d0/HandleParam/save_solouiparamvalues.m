% [] = save_solouiparamvalues(ratname, varargin)
%
% Opens up interactive filename chooser and then saves all
% GUI soloparamvalues (but no non-GUI values). Doesn't save histories.
% First arg is a string identifying the rat.
%
% PARAMETERS:
% ----------
%
% ratname     This will determine which directory the file goes into.
%
% OPTIONAL PARAMETERS:
% --------------------
%
% child_protocol     by default, empty. If non-empty, should be an SPH
%                    that holds an object whose class will indicate the
%                    class of the child protocol who is the real
%                    owner of the vars to be saved.
%
% asv                by default, zero. If 1, this is an non-interactive
%                    autosave, and the file will end in _ASV.mat. If 0,
%                    this is a normal file.
%
% interactive        by default 1; dialogues with the user to determine
%                    the file in which the data will be saved. If 0,
%                    the default suggested filename is used, with
%                    possible overwriting and no questions asked.
%
% commit             by default, 0; if 1, tries to add and commit to CVS
%                    the recently saved file.
%
% tomorrow           by default, 0; if 1, saves setting file with the next
%                    day's date (if today is 070424, setting 'tomorrow' to
%                    1 would save settings file as 070425a)
%
% <~> experimenter   If not provided (''), settings path is of the form:
%                      .../SoloData/Settings/ratname/
%                    If provided, settings path is of the form:
%                      .../SoloData/Settings/experimentername/ratname/
%                    The former is old behavior, the latter new.
%
% fullfilename       Default, empty. If empty a file is chosen as before.
%                    If non-empty this file name is used. This must be a
%                    full path and file name;

function varargout = save_solouiparamvalues(ratname, varargin)
 global Solo_datadir;
 
pairs = { ...
    'child_protocol', [] ; ...
    'asv', 0; ...
    'interactive'      1 ; ...
    'commit'           0 ; ...
    'tomorrow'         0 ; ...
    'owner'           '' ; ...
    'experimenter'    '' ; ... % <~> added for new directory hierarchy
    'fullfilename'    '' ; ...
    };
parseargs(varargin, pairs);

% <~> There was a hole in the case handling before that resulted in
%       owner and child_protocol being treated differently.
%     I've shuffled things around and made small changes such that
%       child_protocol overrides owner, THEN checking is done.
%     All files will now be saved and loaded with '@' included;
%       @protocolobj-inherited saving/loading is no longer different.
%     Please be careful in the future when adding code.     

if      ~isempty(child_protocol), owner = class(value(child_protocol)); end; % the child protocol owns all vars

if      isempty(owner), owner = determine_owner;
elseif  ~ischar(owner), error('optional param owner must be a string');
end;

if      owner(1) ~= '@', owner = ['@' owner]; end;

if isempty(ratname)
    warning('Ratname is empty.  Filename will be malformed.')
end

% <~> added experimenter
if ~isempty(experimenter) && ~ischar(experimenter),  error('optional param experimenter must be a string'); end;
% <~> end added experimenter

owner = owner;

if isempty(Solo_datadir),
     Solo_datadir=bSettings('get','GENERAL','Main_Data_Directory');
     if isnan(Solo_datadir) || isempty(Solo_datadir)
          Solo_datadir=[pwd filesep '..' filesep 'SoloData'];
     end
end

settings_path = [Solo_datadir filesep 'Settings'];

% <~> Added experimenter here instead of later on to reduce
%       probability of break.
%     Note that organization of filesep applications don't always match
%       for the load and save fns. :P
if ~isempty(experimenter)
    settings_path = [settings_path filesep experimenter];
end;
% <~> end Added experimenter
   

if ~exist(settings_path, 'dir'),
    success = mkdir(Solo_datadir, 'Settings');
    if ~success, error(['Couldn''t make directory ' settings_path]); end;
end;

handles = get_sphandle('owner', owner);
k = zeros(size(handles));
for i=1:length(handles),
  k(i) = gets_saved_with_settings(handles{i});
end;
handles = handles(find(k));

saved         = struct;
saved_autoset = struct;
for i=1:length(handles),
    saved.(get_fullname(handles{i}))        = value(handles{i});
    saved_autoset.(get_fullname(handles{i}))= get_autoset_string(handles{i});
end;

protocol_name = get_sphandle('owner', owner, 'name', 'protocol_name');
if ~isempty(protocol_name),
   protocol_name = protocol_name{1};
   fig_position = get(findobj(get(0, 'Children'), ...
                              'Name', value(protocol_name)), 'Position');
else
   fig_position = [];
end;

% Load Settings directory to save in

if settings_path(end)~=filesep, settings_path=[settings_path filesep]; end;
rat_dir = [settings_path ratname];
if ~exist(rat_dir)
    success = mkdir(settings_path, ratname);
    if ~success, error(['Couldn''t make directory ' rat_dir]); end;
end;
if rat_dir(end)~=filesep, rat_dir=[rat_dir filesep]; end;

% <~> Added conditional handling for new filename format.
%     When experimenter is non-empty, filenames will be of the form
%       settings_@protocolobj_experimentername_ratname_YYMMDDz
%     Otherwise (if experimenter is empty), they will be of the old form:
%       settings_@protocolobj_ratname_YYMMDDz
experimenter_ = '';
if ~isempty(experimenter), experimenter_ = [experimenter '_']; end;
% <~> end Added conditional handling for new filename format.

if asv > 0
    pname = rat_dir;
    fname = ['settings_' owner '_' experimenter_ ratname '_' ... % <~> added experimenter_
        yearmonthday(now+tomorrow) '_ASV.mat'];
else
    u = dir([rat_dir 'settings_' owner '_' experimenter_ ratname '_' ... % <~> added experimenter_
        yearmonthday(now+tomorrow) '*.mat']);

    if ~isempty(u),
        [filenames{1:length(u)}] = deal(u.name); filenames = sort(filenames');
        fullname = [rat_dir filenames{end}];
        fullname = fullname(1:end-4); % chop off .mat
        if strcmpi(fullname(end-3:end),'_ASV')
          fullname = [fullname(1:end-4) 'a'];
      else
          fullname(end) = fullname(end)+1;
      end;
    else
        fullname = [rat_dir 'settings_' owner '_' experimenter_ ratname '_' ... % <~> added experimenter_
            yearmonthday(now+tomorrow) 'a'];
    end;

    rn = [experimenter_ ratname]; % <~> added experimenter_
    if interactive && isempty(fullfilename),
       [fname, pname] = ...
           uiputfile({['*' owner '*' rn '*.mat'], ...
                      [owner ' ' rn ' files (' owner '*' rn '*.mat)'] ; ...
                      ['*' rn '*.mat'], [rn ' files (*' rn '*.mat)'] ; ...
                      '*.mat',  'All .mat files (*.mat)'}, ...
                     'Save settings', fullname);
       if fname == 0, return; end;
    else
       fname = fullname; pname = '';
    end;
end;

if isempty(fullfilename)
    save([pname fname], 'saved', 'saved_autoset', 'fig_position');
else
    save(fullfilename,  'saved', 'saved_autoset', 'fig_position');
end
if nargout>=1
    if isempty(fullfilename)
        varargout{1}=[pname fname];
    else
        varargout{1}=fullfilename;
    end
end

if isempty(fullfilename)
    % Make sure it is a .mat extension:
    [path, name, ext] = fileparts([pname fname]); 
    if ~strcmp('.mat', ext), fname = [name '.mat']; end;
    % Then add and commit if necessary:
    if commit, add_and_commit([path filesep fname]); end;
else
    if commit, add_and_commit(fullfilename); end;
end
