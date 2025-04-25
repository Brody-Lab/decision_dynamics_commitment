analysispath = 'V:\Documents\tzluo\analyses\analysis_2023_02_28b_fitB';
T = FHMDDM.tabulateoptions(analysispath);
%% specify model
modelindex = find(T.fitname=="T176_2018_05_03_dynamic");
resultsfolder = fullfile(T.fitpath{modelindex}, 'cvresults');
%% load PSTH
PSTH = load(fullfile(resultsfolder, 'pethsets_stereoclick.mat'));
%% compute engagement indices
load(fullfile(resultsfolder, 'trainingsummaries.mat'), 'trainingsummaries')
nfolds = numel(trainingsummaries);
EI = cell(1,nfolds);
for i = 1:nfolds
    wEA = cellfun(@(x) x.v{1}(1), trainingsummaries{i}.thetaglm{1});
    wCM = cellfun(@(x) x.beta{1}(1), trainingsummaries{i}.thetaglm{1});
    EI{i} = (abs(wEA)-abs(wCM))./(abs(wEA)+abs(wCM));
end
EI = mean(cell2mat(EI),2);
%%
neuronindices = [20,38,3];
nneurons = numel(neuronindices);
figure('pos', [100 100 1100 325])
time_s = PSTH.time_s;
time_s = time_s(time_s<=1);
for n = 1:nneurons
    subplot(1,nneurons,n)
    neuronindex = neuronindices(n);
    FHMDDM.plot_peth(PSTH.pethsets{1}{neuronindex}, "leftchoice", time_s, ...
        'linestyle_observed_mean', '')
    FHMDDM.plot_peth(PSTH.pethsets{1}{neuronindex}, "rightchoice", time_s,  ...
        'linestyle_observed_mean', '')
    title(sprintf('EI = %0.2f', EI(neuronindex)))
    if n>1
        xlabel(' ')
        ylabel(' ')
        ylim([0 15])
    end
    xticks(xlim)
    yticks(ylim)
    M23a.stylizeaxes
end
[scriptfolder, scriptname] = fileparts(matlab.desktop.editor.getActiveFilename);
[~, foldername] = fileparts(scriptfolder);
M23a.savegraphic(scriptname, foldername);