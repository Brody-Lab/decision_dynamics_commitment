function [PSTHs, brainareas] = gather_PSTHs_for_PCA(varargin)
% Load peri-stimulus time histograms (PSTHs) to perform principal component analysis (PCA)
    parser = inputParser;
    addParameter(parser, 'sessionindices', [], @(x) isnumeric(x))
    parse(parser, varargin{:});
    P = parser.Results; 
    Specs = M23a.specify_PSTH_PCA;
    settings = M23a.get_data_settings(Specs.settingsname);
    sessions = M23a.tabulate_recording_sessions;
    if ~isempty(P.sessionindices)
        sessions = sessions(P.sessionindices,:);
    end
    nsessions = size(sessions,1);
    PSTHs = struct; 
    [PSTHs.dynamic, PSTHs.static] = deal(cell(nsessions,1));
    brainareas = cell(nsessions,1);
    for i = 1:nsessions
        for couplingmodel = ["dynamic", "static"]
            filepath = [Specs.outputfolder,'\' sessions.recording_id{i}, '_' char(couplingmodel) ...
                '\crossvalidation\pethsets_stereoclick.mat'];
            clear pethsets
            load(filepath, 'pethsets')
            nneurons = numel(pethsets{1});
            for n = 1:nneurons
                PSTHs.(couplingmodel){i} = pethsets{1};
            end
        end
        filepath = fullfile(settings.folderpath, sessions.recording_id{i});
        S = load(filepath);
        brainareas{i} = cellfun(@(x) string(x.brainarea), S.neurons);
        disp(i)
    end
    for couplingmodel = ["dynamic", "static"]
        PSTHs.(couplingmodel) = vertcat(PSTHs.(couplingmodel){:});
    end
    brainareas = vertcat(brainareas{:});
end