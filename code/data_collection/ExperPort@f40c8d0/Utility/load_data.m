function [outflag] = load_data(protocol, ratname)

    global exper;

    datapath = exper.control.param.datapath.value;
    if datapath(end) ~= filesep, datapath = [datapath filesep]; end;
    
    u = dir([datapath ratname '*data*.mat']);
    if ~isempty(u),
        [fnames{1:length(u)}] = deal(u.name); fnames = sort(fnames');
        fullname = [datapath fnames{end}];
    else
        fullname = '';
    end;
    
    % rratname = ratname; ratname = '';
    % [fname, pname] = uigetfile({[ratname '*data*.mat'], [ratname ' data files (' ratname '*data*.mat)'] ; ...
    %        '*.mat',  'All .mat files (*.mat)'}, ...
    %    'Pick a file', fullname);
    % [fname, pname] = uigetfile({'*.mat', 'All .mat files (*.mat)'}, ...
    %    'Pick a file', fullname);
    [fname, pname] = uigetfile('*.mat', 'Pick a file', fullname);
    
    
    if fname == 0, outflag = 0; return; end;
    
    load([pname fname]);
    
    fnames = fieldnames(saved);
    for i=1:length(fnames),
        if ~strcmp(fnames{i}, 'trial_events'),
            SetParam(protocol, fnames{i}, saved.(fnames{i}));    
        end;
    end;

    outflag = 1; 
    return;
    