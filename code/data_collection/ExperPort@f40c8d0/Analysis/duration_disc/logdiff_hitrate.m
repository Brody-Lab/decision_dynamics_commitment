function [dates hh_cell] = logdiff_hitrate(ratname, varargin)

% Shows performance metrics for sharpening stage
% Specifically, shows average & sem success rate for each stimulus pair
% presented during sharpening

pairs =  { ...
  %    'from', '000000'; ...  
  %'to', '999999'; ...
    'jumpoffset', 5 ; ...
    'infile' , 'logdiff' ; ...
    'experimenter','Shraddha' ; ...
    };
parse_knownargs(varargin, pairs);

fields = {'logdiff','logflag','psych'};

global Solo_rootdir;
global Solo_datadir;
if isempty(Solo_rootdir), mystartup; end;
stat_dir = [Solo_rootdir filesep 'Analysis' filesep 'duration_disc' filesep 'stat_sandbox'];
event_analysis_dir = [Solo_rootdir filesep 'Analysis' filesep 'duration_disc' filesep 'Event_Analysis'];

if ~is_in_path(stat_dir)
    fprintf(1,'Adding stat_sandbox to path ...\n');
    addpath(stat_dir);
    addpath(event_analysis_dir);
end;
outdir = [Solo_datadir filesep 'Data' filesep experimenter filesep ratname filesep];
fname = [outdir  infile '.mat'];

load(fname);

% For those cases where we don't have enough sessions
jumpoffset = min(jumpoffset, length(numtrials));

% only those trials where sharpening is going on
[lds means_hh sem_hh] = calc_hrates(1, sum(numtrials), hit_history, logdiff, logflag, psychflag);

figure;
[h xpos]=barweb(means_hh', sem_hh', 0.5, [], [],ratname,'Avg. hit rate (%) (SEM)');
t=ylabel('Avg. hit rate (%) (SEM)'); set(t,'FontSize',14, 'FontWeight','bold');
t=xlabel(ratname); set(t,'FontSize',14, 'FontWeight','bold');

minld = min(logdiff); maxld = max(logdiff);
numrows = ceil(length(numtrials) / jumpoffset);

set(gca,'YLim',[0.5 1], 'YTick',0.5:0.1:1, 'YTickLabel',50:10:100,'XTick',xpos, 'XTickLabel', lds);
title(sprintf('%s (%s-%s)\nOverall success rate',ratname, dates{1}, dates{end}));

% ----------------------------------------------
% Calculate weekly heat map
% ----------------------------------------------
min_tr = 1;
max_tr = sum(numtrials(1:jumpoffset));

logdiff = round(logdiff*10)/10;
all_lds = 0.2:0.1:1;
hh_cell = {};
for k = 1:length(all_lds),
    hh_cell{end+1,1} = all_lds(k);
    hh_cell{end,2} = ones(1,numrows) .* -1;
    hh_cell{end,3} = ones(1,numrows) .* -1;
end;

maxidx = min(jumpoffset,length(numtrials));
fprintf(1,'Grouping index %i to %i: (%i to %i) trials\n',1, maxidx, min_tr, max_tr);
[lds means_hh sem_hh] = calc_hrates(min_tr, max_tr, hit_history, logdiff, logflag, psychflag);

for k = 1:length(lds)
    idx = find(cell2mat(hh_cell(:,1)) == lds(k));
    if ~isempty(idx)
        tmp = hh_cell{idx,2}; tmp(1) = means_hh(k); hh_cell{idx,2} = tmp;
        tmp = hh_cell{idx,3}; tmp(1) = sem_hh(k); hh_cell{idx,3} = tmp;
    end;
end;

for j =2:numrows
    min_tr = max_tr + 1;
    maxidx = min(jumpoffset*j,length(numtrials));
    max_tr = max_tr + sum(numtrials( (jumpoffset*(j-1))+1 :maxidx));
    fprintf(1,'Grouping index %i to %i: (%i to %i) trials\n',(jumpoffset*(j-1))+1, maxidx, min_tr, max_tr);
    [lds means_hh sem_hh] = calc_hrates(min_tr, max_tr, hit_history, logdiff, logflag, psychflag);
    for k = 1:length(lds)
        idx = find(cell2mat(hh_cell(:,1)) == lds(k));
        if ~isempty(idx)
            tmp = hh_cell{idx,2}; tmp(j) = means_hh(k); hh_cell{idx,2} = tmp;
            tmp = hh_cell{idx,3}; tmp(j) = sem_hh(k); hh_cell{idx,3} = tmp;
        end;
    end;
end;

cmap = colormap;
%cmap = cmap(floor(length(cmap)/2):end,:);

figure;
for k = 1:rows(hh_cell)
    rnum = rows(hh_cell)-(k-1); %flip it
    tmp = hh_cell{rnum,2};
    for j = 1:numrows
        idx = numrows-(j-1);
        if tmp(idx) == -1, c = [0 0 0];
        else 
            c = cmap(floor(tmp(idx)*length(cmap)),:);            
        end;
        
    p=patch([k-1 k-1 k k], [j j+1 j+1 j], c);
    set(p,'EdgeColor','none');
    end;
end;
xlabel('Logdiffs');
ylabel(sprintf('Sets of %i sessions',jumpoffset));
hold on; b=colorbar;
set(b,'YLim',[0.5 1], 'YTick', 0.5:0.1:1);

lbls = {}; for k = 1:numrows, lbls{k} = sprintf('Wk%i',numrows-(k-1)); end;
tmp = hh_cell(:,1); tmp = tmp(end:-1:1);
set(gca,'YLim',[1 numrows+1], 'XLim', [0 rows(hh_cell)], ...
    'YTick',1.5:1:numrows+0.5,'YTickLabel', lbls, 'XTick', 0.5:1:rows(hh_cell)-0.5,'XTickLabel', tmp);
set(gcf,'Position',[100   300   665   138]);
title(sprintf('%s (%s to %s):\nPerformance progress on sharpening',ratname, dates{1}, dates{end}));

% Summary printout
b='-'; llen =100;
fprintf(1,'%s\n',repmat(b,1,llen));
fprintf(1,'%s: %i sessions\n',ratname,length(dates));
fprintf(1,'%s\n',repmat(b,1,llen));

% pretty-print the hit_rate table
ldiffs = cell2mat(hh_cell(:,1)); 
fprintf(1,'Logdiff\t');
for r = 1:length(hh_cell{1,2}), fprintf(1,'Wk_%i\t', r); end;
fprintf(1,'\n');

for k = 1:length(ldiffs), 
    m=length(ldiffs)-(k-1); 
    fprintf(1,'%1.2f:\t', ldiffs(m)); 
    fprintf(1,'%1.2f\t',hh_cell{m,2}); 
    fprintf(1,'\n'); 
end;

function [lds means_hh sem_hh] = calc_hrates(mintr, maxtr, hit_history, logdiff, logflag, psychflag)
hit_history = hit_history(mintr:maxtr);
logdiff = logdiff(mintr:maxtr);
logflag = logflag(mintr:maxtr);
psychflag = psychflag(mintr:maxtr);

idx = find(logflag > 0);
idx2 = find(psychflag < 1);
idx = intersect(idx, idx2);
hit_history = hit_history(idx);
logdiff = logdiff(idx);

unld = unique(logdiff);
lds = [];
means_hh = [];
sem_hh = [];
for g = 1:length(unld)
    idx = find(logdiff == unld(g));
    if length(idx) > 5
        hh = hit_history(idx);

        lds = horzcat(lds, unld(g));
        means_hh = horzcat(means_hh, mean(hh));
        sem_hh =horzcat(sem_hh, std(hh)/length(hh));
    end;
end;
