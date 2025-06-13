function [outflag] = load_uiparamvalues(protocol, ratname)

    global exper;

    datapath = exper.control.param.datapath.value;
    if datapath(end) ~= filesep, datapath = [datapath filesep]; end;
    
    u = dir([datapath protocol '_' ratname '*.mat']);
    if ~isempty(u),
        [fnames{1:length(u)}] = deal(u.name); fnames = sort(fnames');
        fullname = [datapath fnames{end}];
    else
        fullname = [datapath protocol '_' ratname];
    end;
    
    % [fname, pname] = uigetfile({[protocol '*' ratname '*.mat'], [protocol ' ' ratname ' files (' protocol '*' ratname '*.mat)'] ; ...
    %            ['*' ratname '*.mat'], [ratname ' files (*' ratname '*.mat)'] ; ...
    %            '*.mat',  'All .mat files (*.mat)'}, ...
    %        'Pick a file', fullname);
    [fname, pname] = uigetfile('*.mat', 'Pick a file', fullname);
    
    if fname == 0, outflag = 0; return; end;
    
    load([pname fname]);
    
    fnames = fieldnames(saved);
    for i=1:length(fnames),
        SetParam(protocol, fnames{i}, saved.(fnames{i}));    
    end;

    if exist('fig_position', 'var'),
        set(findobj(get(0, 'Children'), 'Tag', protocol), 'Position', fig_position)
    end;
    
    outflag = 1;
    return;
    