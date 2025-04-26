function options = tabulateoptions(analysispath)
    % tabulate the settings of all models fitted in analysis
    %
    % ARGUMENT
    % -'analysispath': absolute path of the folder containing the code and output of the
    % analysis
    %
    % RETURN
    % -`option`: a table
    [~, analysisname] = fileparts(analysispath);
    fitpath = M23a.find_fit_paths(analysisname); 
    options = readtable(fullfile(analysispath, 'options.csv'), 'Delimiter', ',');
    if ~contains(options.Properties.VariableNames, 'outputpath')
        options.outputpath = cellfun(@(x,y) string([x '/' y]), options.outputfolder, options.fitname);
    else
        options.outputpath = string(options.outputpath);
    end
    if ~contains(options.Properties.VariableNames, 'datapath')
        options.datapath = cellfun(@(x,y) string([x '/' y '.mat']), options.datafolder, options.recording_id);
    else
        options.datapath = string(options.datapath);
    end
    for i = 1:size(options,1)
        options.datapath{i} = strrep(options.datapath{i}, '/mnt/cup/labs/brody', 'X:');
        options.datapath{i} = strrep(options.datapath{i}, '/', '\');
    end
    [~, fitnames] = cellfun(@(x) fileparts(char(x)), fitpath, 'uni', 0);
    fitnames = string(fitnames);
    [~, options.fitname] = cellfun(@(x) fileparts(char(x)), options.outputpath, 'uni', 0);
    options.fitname = string(options.fitname);
    [~,~,sortindex] = intersect(fitnames, options.fitname);
    options = options(sortindex, :);
    options.fitpath = fitpath;
end