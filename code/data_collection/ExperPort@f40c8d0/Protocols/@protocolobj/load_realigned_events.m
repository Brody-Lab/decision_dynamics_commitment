function [] = load_realignedfile(obj, ratname, child_protocol)

owner = class(value(child_protocol));   % the child protocol owns all vars

% ---  DEFINE THE DATA DIRECTORY  ---------
global Solo_datadir;
if isempty(Solo_datadir),
    Solo_datadir=[pwd filesep '..' filesep 'SoloData'];
end;
data_path = [Solo_datadir filesep 'Data'];
if ~exist(data_path, 'dir'),
    success = mkdir(Solo_datadir, 'Data');
    if ~success, error(['Couldn''t make directory ' data_path]); end;
end;
if data_path(end)~=filesep, data_path=[data_path filesep]; end;

% --- FIND FULLNAME, THE LATEST FILENAME THAT MATCHES THE OWNER AND THE RAT
rat_dir = [data_path ratname filesep 'Realigned' filesep];
if ~exist(rat_dir, 'dir')
    error(['Couldn''t find Realigned directory for: ' ratname]);
end;
if rat_dir(end)~=filesep, rat_dir=[rat_dir filesep]; end;
u = dir([rat_dir 'data_' owner '_' ratname '*.mat']);
if ~isempty(u),
    [filenames{1:length(u)}] = deal(u.name); filenames = sort(filenames');
    fullname = [rat_dir filenames{end}];
else
    fullname = [rat_dir 'data_' owner '_' ratname '_' yearmonthday 'a'];
end;

% --- USER DIALOG TO CHOOSE FILE TO LOAD; DEFAULT IS FULLNAME
rn = ratname;
[fname, pname] = ...
    uigetfile({['data_' owner '*' rn '*.mat'], ...
    ['data_' owner ' ' rn ' files (' owner '*' rn '*.mat)'] ; ...
    ['*' rn '*.mat'], [rn ' files (*' rn '*.mat)'] ; ...
    ['*' owner '*.mat'], [owner ' files (*' owner '*.mat)'] ; ...
    '*.mat',  'All .mat files (*.mat)'}, ...
    'Load data', fullname);
if fname == 0, outflag = 0; return; end; drawnow;

load([pname fname]);