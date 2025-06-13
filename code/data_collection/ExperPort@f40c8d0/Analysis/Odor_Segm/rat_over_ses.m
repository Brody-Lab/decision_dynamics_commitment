function [] = rat_over_ses (ratname, taskname, varargin);
% input ratname, e.g., xu1_2, taskname, e.g., 'nl2afc', session name, e.g.,
% '060927a'. 
% You can input more than one session. 
% Here is an example:
%    rat_over_ses('xu1_2', 'nl2afc', '060926a', 060927a')
% it will plot the results of the two sessions of this rat, with moving
% average. The block size is 20 trials. 

cd('C:\Home\RatExper\ExperPort\');
close all;
taskname_l = ['@' taskname 'obj'];
date_ses = varargin;
n = length(date_ses);
scrsz = get(0, 'ScreenSize');
lft = 1; btm = scrsz(4)/2; wd = scrsz(3)/round(n/2); ht = scrsz(4)/2;
for i = 1: n,
    if i<= round(n/2),
        lft = (i-1)*wd +1;
    else
        lft = (i-round(n/2)-1)*wd + 1;
        btm = scrsz(2);
    end
    figure('Position', [lft btm wd ht]); hold on;
    load_datafile(ratname, taskname_l, date_ses{i});
    Title = [ratname ' ' taskname ' ' date_ses{i}];
    if strncmpi(taskname, 'odorsegm',8)
        Title = [Title saved.OdorSection_target_frac];
    end
    title(Title, 'FontSize', 20);
    
    [L_Score, R_Score, Score, score_blk] = rat_perform(saved,saved_history,taskname,1);
    save_dir = [pwd filesep '..' filesep 'SoloData' filesep 'data' filesep ratname filesep 'analyse'];
    if ~exist(save_dir)
        mkdir(save_dir);
    end
    save_result_file = [save_dir filesep date_ses{i}];
    save(save_result_file, 'L_Score', 'R_Score', 'Score','score_blk');
    saveas(gcf, save_result_file, 'tif');
end
    