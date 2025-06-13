function [] = savefig(h, name, rat, varargin)
% Saves a figure in .gif format in the 'graphs' subdirectory of a given
% rat's data directory.
% Input arguments:
% 1. Figure handle to be saved
% 2. Name for final file (no extensions)
% 3. Rat name: 'cuauhtemoc', 'Aldo', etc.,
% 4. Type of graphic: Provides preset height and width values
% for common types of analyses
%   a. vanilla_view 4:1 width-to-height ratio
%   b. singlehist: A single histogram
%   c. composite: 11:9 width:height; useful for figures that have more than one plot (subplots)
%   d. raw_hits: 9:2 ratio that is longer in the y-direction than vanilla_view.
% (leave blank if specifying custom width and height
%
% Output
% name.gif file in SoloData/Data/(ratdirectory)/graphs/


pairs = {  ...
    'width', 11 ; ...
    'height', 7 ; ...
    'basepath', pwd ; ...
    'outdir', ['graphics_dump' filesep]; ...
    'rm_path', 'ExperPort/../'; ...
    'preset', ''; ...
    };
parse_knownargs(varargin, pairs);

if ~strcmp(basepath(end), filesep), basepath = [basepath filesep];end;
if ~exist([basepath outdir], 'dir')
    mkdir(basepath, outdir);
    if ~strcmp(outdir(end), filesep), outdir = [outdir filesep];end;
end;

if ~strcmpi(rat, 'none')
    global Solo_datadir;
    if isempty(Solo_datadir), mystartup; end;
    pos = findstr(Solo_datadir, rm_path);
    new_path = [Solo_datadir(1:pos-1) Solo_datadir(pos+length(rm_path):end)];
    outdir = [new_path filesep 'data' filesep rat filesep];
    if ~exist(outdir, 'dir'), error('Invalid output directory %s', outdir); end;
    gdir = [outdir 'graphs' filesep];
    if ~exist(gdir, 'dir'), success = mkdir(outdir, 'graphs'); if ~success, error('Unable to make graphs directory!'); end; end;
    outdir = gdir;
end;

p = find(name == '.'); if ~isempty(p), error('No extensions to the filename, please!'); end;
name = [name '.eps'];
fullname = [outdir name];

switch preset
    case 'vanilla_view'
        width = 12; height = 3;
    case 'singlehist'
        width = 7; height = 1;
    case 'composite'
        width = 11; height = 9;
    case 'singlepsych'
        width = 7; height=5;
    case 'raw_hits'
        width = 9; height=2;
 case 'weekly_logdiff'
        width = 11; height = 5; 
    otherwise
        % do nothing.
end;

dot = find(fullname == '.');
% if strcmpi(fullname(dot+1:end), 'jpeg') || strcmpi(fullname(dot+1:end), 'jpg')
%     exportfig(h, fullname, 'color','cmyk', 'Width', width, 'Height', height, 'Format', 'jpeg');
% else

exportfig(h, fullname, 'color','cmyk', 'Width', width, 'Height', height);
% cmd = ['cd ' basepath outdir]; eval(cmd);
ext = find(fullname == '.'); prefix = fullname(1:ext-1);
cmd = ['! convert ' fullname ' ' prefix '.gif']; eval(cmd);
cmd = ['! rm ' fullname ]; eval(cmd);

% end;