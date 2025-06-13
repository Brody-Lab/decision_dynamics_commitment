function [blks_all, blks_mean, blks_se] = blks_to_cri_rats_avg(varargin)
% This function find the number of blocks needed to reach the criterion of
% each odor, averaged across rats.
% varargin is the ratnames
load('c:\Home\RatExper\SoloData\Data\bgnames');
blks_all = []; %zeros(length(names),length(varargin));
for i = 1: length(varargin)
    blks = blks_to_cri(varargin{i});
    blks_all = [blks_all blks];
end;
blks_mean = []; blks_se = [];
for i = 1: size(blks_all,1)
    blks_row = blks_all(i,:);
    blks_row(blks_row == 0)=[];
    row_mean = mean(blks_row);
    row_se = std(blks_row)/sqrt(length(blks_row));
    blks_mean = [blks_mean; row_mean];
    blks_se = [blks_se; row_se];
end;
figure; errorbar((1:length(names)),blks_mean,blks_se, 'o');
ylim([1 7]);

function [blks] = blks_to_cri(ratname)
% this function find the number of blocks needed to reach criterion of each
% odor for each rat. Then corresponds these numbers to a common odor
% name set.
cri = 80; % Set the criterion
bgs = [];
load(['c:\Home\RatExper\SoloData\Data\' ratname '\analyse\odorsegm_bgodor_score']);
bgs = [bgs; bg_score];
load(['c:\Home\RatExper\SoloData\Data\' ratname '\analyse\odorsegm2_bgodor_score']);
bgs = [bgs; bg_score];
load('c:\Home\RatExper\SoloData\Data\bgnames');
blks = zeros(length(names),1);
never = [];
for i = 1:length(bgs), 
    m = find(bgs(i).blkscr_ses1>= cri); 
    if isempty(m), 
        % This is a tricky part, when the rat never reached criterion for
        % that bg odor. If it already took more than 2 blocks, which gives
        % the information that this odor is pretty difficult, the total
        % block number is counted in. Otherwise, if the score reached 80,
        % this number is als counted in.
        if length(bgs(i).blkscr_ses1) > 2 || max(bgs(i).blkscr_ses1)>= 80
            reach_cri(i) = length(bgs(i).blkscr_ses1);
        else
            reach_cri(i) = 0;
        end;
        never = [never;[i reach_cri(i)]];
    else
        reach_cri(i) = m(1);
    end;
    blks(strcmpi(names,bgs(i).bg_name)) = reach_cri(i);
    % Note that the numbers in cases where rats never reached the criterion
    % are also included.
end;
figure; 
plot(reach_cri,'o');hold on;
plot(never(:,1),never(:,2),'r*');
ylim([1 12]);
title(['Number of blocks to reach criterion ' ratname]);