function [avg_rand, avg_regu] = avg_rat(date_ses, varargin)
% This function works after 'bgodor_plot.m' processed data of each rat, and
% saved the variables containing the FIRST block scores and background odor names. 
% This function load the block scores then separate them according to random or
% non-random trials, and average them across rats for each odor.
% 
% Output are variables with odor names, average scores with Standard Errors.
% varargin should be the ratnames to be averaged
cd('C:\Home\RatExper\ExperPort\');
%close all;
ratnames = varargin;
bgname_regu = {}; bgname_rand = {}; bks_regu=[]; bks_rand=[];
blk_rand = {}; blk_regu = {}; % to parse score_blk into random and regular block data.
for i = 1: length(ratnames)
    data_path = [pwd filesep '..' filesep 'SoloData' filesep 'data' filesep ratnames{i} filesep 'analyse'];
    load([data_path filesep date_ses]);
    tmpnames = {}; tmpscore = []; % to store bgnames and blkscores of each rat
    if size(score_blk,2) > 3
        t_rand = find([score_blk{:,4}]); % find blks of random trials
        t_regu = find([score_blk{:,4}] == 0); % find blks of non-random trials
        blk_rand = score_blk(t_rand, :);
    else
        t_regu = (1: size(score_blk,1));
    end;
    blk_regu = score_blk(t_regu,:);
    if ~isempty(blk_regu) && nargout>1
        for j = 1:size(blk_regu)
            % eliminate "Pure" and the second duplicated odornames
            if strcmpi(score_blk(j,1),'Pure')
                continue;
            end
            % Only choose the first block of a bg odor
            if j>1 && ismember(blk_regu(j,1),blk_regu(1:j-1,1))
                continue;
            end;
            tmpnames = [tmpnames; blk_regu(j)];
            tmpscore = [tmpscore; blk_regu{j, 3}]; % Block score of rat i.
        end
        bks_regu = [bks_regu tmpscore];
        if isempty(bgname_regu) % to make sure odor names are the same across rats
            bgname_regu = tmpnames; % Store bgnames of the first rat
        elseif strcmp([bgname_regu(:)],[tmpnames(:)]) % Then compare all of them for each rat
            bgname_regu = tmpnames;
        else
            keyboard; % if detected different odor name, break.
        end;
    end; 
    tmpnames = {}; tmpscore = []; % to store bgnames and blkscores of each rat
    if ~isempty(blk_rand)
        for j = 1:size(blk_rand)
            % eliminate "Pure" and the second duplicated odornames
            if strcmpi(blk_rand(j,1),'Pure')
                continue;
            end
            % Only choose the first block of a bg odor
            if j>1 && ismember(blk_rand(j,1),blk_rand(1:j-1,1))
                continue;
            end;
            tmpnames = [tmpnames; blk_rand(j)];
            tmpscore = [tmpscore; blk_rand{j, 3}]; % Block score of rat i.
        end
        bks_rand = [bks_rand tmpscore];
        if isempty(bgname_rand)
            bgname_rand = tmpnames;
        elseif strcmp([bgname_rand(:)],[tmpnames(:)])
            bgname_rand = tmpnames;
        else
            keyboard;
        end;
    end;
end;
% bg_names = bgnames(:,1);
se1 = std(bks_regu,0,2)/sqrt(length(ratnames));
avg1 = mean(bks_regu,2);
avg_regu = {bgname_regu avg1 se1};
if ~isempty([avg_regu{:,2}])
    figure; errorbar(avg1, se1, '-o');
    title('Average score of for odors (Regular Trials)', 'FontSize', 12);
end;
se2 = std(bks_rand, 0 ,2)/sqrt(length(ratnames));
avg2 = mean(bks_rand,2);
avg_rand = {bgname_rand avg2 se2};
if ~isempty([avg_rand{:,2}])
    figure; errorbar(avg2, se2,'-o');
    set(gca, 'YGrid','on','XTickLabel','');
    title('Average score for odors (Random interleaved Trials)', 'FontSize', 12);
    ylim([30 100]);
    for i = 1: size(avg2,1)
        text(i, avg2(i)-5, bgname_rand{i},'FontSize', 11, 'Rotation', 330);
    end;
end