function [] = save_data(protocol, ratname)



    global exper;

    

    

    fnames = fieldnames(exper.(protocol).param);

    

    saved = struct;

    for i=1:length(fnames),

        saved.(fnames{i}) = exper.(protocol).param.(fnames{i}).value;

    end;

    saved.trial_events = exper.rpbox.param.trial_events.value;

    

    datapath = exper.control.param.datapath.value;

    if datapath(end) ~= filesep, datapath = [datapath filesep]; end;

    

    u = dir([datapath ratname '_data_' yearmonthday '*.mat']);

    if ~isempty(u),
        [filenames{1:length(u)}] = deal(u.name); filenames = sort(filenames');
        fullname = [datapath filenames{end}]; 
        fullname = fullname(1:end-4); % chop off .mat
        fullname(end) = fullname(end)+1;

    else

        fullname = [datapath ratname '_data_' yearmonthday 'a'];

    end;
   
    [fname, pname] = uiputfile({[ratname '*data*.mat'], [ratname ' data files (' ratname '*data*.mat)'] ; ...
            '*.mat',  'All .mat files (*.mat)'}, ...
        'Save data', fullname);

    if fname == 0, return; end;

    

    save([pname fname], 'saved');

    

    