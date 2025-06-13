function [] = save_uiparamvalues(protocol, ratname)



    global exper;

    

    

    fnames = fieldnames(exper.(protocol).param);

    k = zeros(length(fnames), 1);

    for i=1:length(fnames),

        ui = exper.(protocol).param.(fnames{i}).ui;

        if ~isempty(ui) & ~strcmp(ui, 'disp'),

            k(i) = 1;

        end;

    end;

    fnames = fnames(find(k));

    

    saved = struct;

    for i=1:length(fnames),

        saved.(fnames{i}) = exper.(protocol).param.(fnames{i}).value;

    end;

    

    fig_position = get(findobj(get(0, 'Children'), 'Tag', protocol), 'Position');

    datapath = exper.control.param.datapath.value;

    if datapath(end) ~= filesep, datapath = [datapath filesep]; end;

    

    u = dir([datapath protocol '_' ratname '_' yearmonthday '*.mat']);

    if ~isempty(u),

        [filenames{1:length(u)}] = deal(u.name); filenames = sort(filenames');

        fullname = [datapath filenames{end}]; 

        fullname = fullname(1:end-4); % chop off .mat

        fullname(end) = fullname(end)+1;

    else

        fullname = [datapath protocol '_' ratname '_' yearmonthday 'a'];

    end;

    

    [fname, pname] = uiputfile({[protocol '*' ratname '*.mat'], [protocol ' ' ratname ' files (' protocol '*' ratname '*.mat)'] ; ...
            ['*' ratname '*.mat'], [ratname ' files (*' ratname '*.mat)'] ; ...
            '*.mat',  'All .mat files (*.mat)'}, ...
        'Save settings', fullname);

    if fname == 0, return; end;

    

    save([pname fname], 'saved', 'fig_position');

    

    