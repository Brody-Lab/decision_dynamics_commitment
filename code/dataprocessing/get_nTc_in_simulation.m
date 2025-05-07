original_path = path; % so that original search path can be restored
scriptpath = fileparts(matlab.desktop.editor.getActiveFilename);
repo_root = fileparts(fileparts(scriptpath));
addpath(genpath(repo_root))

filepath = fullfile(common.analyses_path, 'analysis_2023_05_26b_recovery', 'options.csv');
T = readtable(filepath, 'delimiter', ',');
T.outputpath = common.cup2windows(string(T.outputpath));
T.fit_beta = string(T.fit__)=="TRUE";
T = T(T.fit_beta,:);
nTc = readtable(fullfile(common.locatedata, 'processed_data', 'common', 'nTc'), 'Delimiter',',');
nTc_simulated = nTc;
nTc_simulated.commitment_timestep(:) = nan;
nTc_simulated.commitment_time_s(:) = NaN;
thresh = 0.8;
for i = [1:107, 109:size(T,1)]
    D = load(fullfile(T.outputpath{i}, 'sample1', 'trialsets.mat'));
    stereoclick_time_s = cellfun(@(trial) trial.stereoclick_time_s, D.trialsets{1}.trials);
    [~, ia, ib] = intersect(nTc.stereoclick_time_s, stereoclick_time_s);
    assert(all(ib==sort(1:numel(stereoclick_time_s))'))
    nTc_simulated.choice(ia) = cellfun(@(trial) trial.choice, D.trialsets{1}.trials);
    nTc_simulated.Deltaclicks(ia) = cellfun(@(trial) ...
        numel(trial.clicktimes.R) - numel(trial.clicktimes.L), ...
        D.trialsets{1}.trials);
    S = load(fullfile(T.outputpath{i}, 'sample1', 'recovery', 'paccumulator_choicespikes.mat'));
    P = S.paccumulator_choicespikes{1};
    for j = 1:numel(P)
        pcommit_L = cellfun(@(x) x(1), P{j});
        pcommit_R = cellfun(@(x) x(end), P{j});
        idxL = find(pcommit_L >= thresh,1);
        idxR = find(pcommit_R >= thresh,1);
        if ~isempty(idxL) & isempty(idxR)
            commitment_timestep = idxL;
        elseif isempty(idxL) & ~isempty(idxR)
            commitment_timestep = idxR;
        elseif ~isempty(idxL) & ~isempty(idxR)
            commitment_timestep = min(idxL,idxR);
        else
            commitment_timestep = NaN;
        end
        if ~isnan(commitment_timestep)
            trialindex = ia(j);
            nTc_simulated.commitment_timestep(trialindex) = commitment_timestep;
            nTc_simulated.commitment_time_s(trialindex) = ...
                nTc_simulated.stereoclick_time_s(trialindex) + ...
                commitment_timestep*0.01;
        end
    end
    fprintf('\n%i',i)
end
indices = nTc_simulated.recording_id == "T274_2020_12_20";
nTc_simulated(indices,:) = [];
writetable(nTc_simulated, fullfile(common.locatedata, 'processed_data', 'common', 'nTc_simulated.csv'), ...
    'Delimiter',',');

rmpath(genpath(repo_root)) % restore search path