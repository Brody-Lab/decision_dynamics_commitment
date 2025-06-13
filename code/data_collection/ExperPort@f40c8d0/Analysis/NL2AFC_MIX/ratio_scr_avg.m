function [ratio_scr] = ratio_scr_avg(ratname, mix_diff, exclude, varargin)
% Calculate the mean block score for a particular mixture ratio of one rat 
% across different sessions.
% Input: ratname,
%        mix_diff, trials of specified mixture difference
%        exclude, number of first blocks to be excluded in averaging.
%        varargin{1}, 1st session, varargin{2}, last session.
% if no varargin, ask input session names in a cell.
% Output: 
filenames = {};
file_path = 'c:\Home\RatExper\SoloData\Data\NL_Analysis\nl2afc_mix\';
if isempty(varargin)
    ses_names = input('Input session names: {a,b,c...} ');
    for i = 1:length(ses_names)
        filenames = [filenames; {[ratname ses_names{i}]}];
    end;
else
    u = dir([file_path ratname '*.mat']);
    [all_filenames{1:length(u)}] = deal(u.name);
    all_filenames = sort(all_filenames');
    f1 = find(strcmp(all_filenames(:),[ratname '_' varargin{1} '.mat']));
    if length(varargin) == 1
        filenames = all_filenames(f1:end);
    else
        f2 = find(strcmp(all_filenames(:),[ratname '_' varargin{2} '.mat']));
        filenames = all_filenames(f1:f2);
    end;
end
ratio_scr = {};
for i = 1: length(filenames),
    load([file_path filenames{i}]);
    ratio = [num2str(50+ mix_diff/2) '/' num2str(50- mix_diff/2)];
    blks = find(strcmp(score_blk(:,1), ratio));
    if isempty(blks),
        continue;
    end;
    if exclude > 0 && length(blks)>exclude,
        blks(1:exclude) = [];
    end
    ses_name = filenames{i}(7:13); % session name as the first column
    blkscr_mean = mean(cell2mat(score_blk(blks, 3)));
    blkscr_se = std(cell2mat(score_blk(blks, 3)))/sqrt(length(blks));
    ratio_scr = [ratio_scr; {ses_name, blkscr_mean, blkscr_se}];
end;
errorbar((1:size(ratio_scr,1)),cell2mat(ratio_scr(:,2)), cell2mat(ratio_scr(:,3)),'-o','MarkerSize', 8);
set(gca, 'YLim', [20 100], 'YGrid', 'on', 'XTickLabel','');
for i = 1:size(ratio_scr,1), text(i, 20, ratio_scr(i,1),'Rotation',-30); end;
title([ratname ' Session Avg on ', ratio], 'FontSize', 15);
    