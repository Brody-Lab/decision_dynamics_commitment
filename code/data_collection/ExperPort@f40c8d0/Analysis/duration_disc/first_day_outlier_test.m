function [] = first_day_outlier_test(ratlist, varargin)
% compares session hit rate on the first day post-recovery to the week of
% training before surgery.
% Is the performance an outlier?
pairs =  { ...
    'experimenter','Shraddha'; ...
    'brainarea', 'mPFC';...
    };
parse_knownargs(varargin, pairs);

figure;
for r = 1:length(ratlist)
    ratname = ratlist{r};
    [pre post] = sub__get_prepost_avgs(ratname, experimenter);

    mean_pre = mean(pre);
    sd_pre = std(pre);

    if post(1) < (mean_pre - sd_pre),
        patch([r-0.2 r-0.2 r+0.2 r+0.2], [0.55 0.95 0.95 0.55], [1 0.8 0.8],'EdgeColor','none');
        hold on;
    end;

    l=plot(ones(length(pre), 1) * r, pre, '.b');
    set(l,'MarkerSize',20);
    hold on;
    line([r-0.2 r+0.2], [mean_pre mean_pre], 'Color','k','LineWidth',2);
    line([r-0.2 r+0.2], [mean_pre-sd_pre mean_pre-sd_pre], 'Color',[0.3 0.3 0.3]);
    line([r-0.2 r+0.2], [mean_pre+sd_pre mean_pre+sd_pre], 'Color',[0.3 0.3 0.3]);

    l=plot(ones(length(post),1) * r, post,'.r'); set(l,'Color',[1 0.5 0],'MarkerSize',20);
    l=plot(r, post(1),'.r'); set(l,'MarkerSize',20);

end;

set(gca,'XTick', 1:length(ratlist), 'XTickLabel', ratlist,'XLim', [0 length(ratlist)+1]);
set(gca,'YTick', 0.5:0.05:1, 'YTickLabel', 50:5:100,'YLim',[0.5 1], 'FontSize',12, 'FontWeight','bold');
xlabel('Rat name');
ylabel('Session average (%)');
set(gcf,'Position',[440   434   150*length(ratlist)   300]);

title(sprintf('Session avgs. before & after lesion: %s', brainarea));

function [pre_out post_out] = sub__get_prepost_avgs(ratname,experimenter)

% prepare incase file needs to be loaded
global Solo_datadir;
if isempty(Solo_datadir), mystartup; end;
outdir = [Solo_datadir filesep 'Data' filesep experimenter filesep ratname filesep];

% retrieve before/after data
last_few_pre = 7;
first_few_post = 3;

% before
infile = 'psych_before';
fname = [outdir infile '.mat'];
load(fname);

% save only data from the last session
cumtrials = cumsum(numtrials);
fnames = {'hit_history', 'side_list', ...
    'left_tone','right_tone', ...
    'logdiff','logflag', 'psychflag'};
for f = 1:length(fnames)
    if length(cumtrials) <= last_few_pre
        str=['pre_' fnames{f} ' = ' fnames{f} ';'];
    else
        str=['pre_' fnames{f} ' = ' fnames{f} '((cumtrials(end-last_few_pre))+1:cumtrials(end));'];
    end;
    eval(str);
end;
lf = last_few_pre-1;
if length(cumtrials) <= last_few_pre
    pre_dates = dates;
    pre_numtrials = numtrials;
else
    pre_dates = dates(end-lf:end);
    pre_numtrials = numtrials(end-lf:end);
end;

% now load 'after' data
infile = 'psych_after';
fname = [outdir infile '.mat'];
load(fname);

fnames = {'hit_history', 'side_list', ...
    'left_tone','right_tone', ...
    'logdiff','logflag', 'psychflag'};

cumtrials = cumsum(numtrials);
for f = 1:length(fnames)
    str=[fnames{f} ' = ' fnames{f} '(1:cumtrials(first_few_post));'];
    eval(str);
end;

dates = dates(1:first_few_post);
numtrials = numtrials(1:first_few_post);
[pre_out pre_tallies]= sub__chunk_session_hrate(pre_dates, pre_numtrials, pre_psychflag, pre_hit_history);
post_out = sub__chunk_session_hrate(dates, numtrials, psychflag, hit_history);

function [set_out tallies] = sub__chunk_session_hrate(dates, numtrials, psych, hit_history)
trials_so_far = 0;
mean_hh=[]; tallies = [];

cumtrials = cumsum(numtrials);
for s = 1:length(dates)
    if s == 1, sidx = 1; else sidx = cumtrials(s-1)+1; end;
    eidx = cumtrials(s);

    % use only vars from current session before filtering
    curr_psych = psych(sidx:eidx);
    curr_hh = hit_history(sidx:eidx);
    %
    %     if psych_only == 1
    %         idx = find(curr_psych > 0);
    %     elseif psych_only == 2
    %         idx = 1:length(curr_psych);
    %     elseif psych_only == 0
    %         idx = find(curr_psych < 1);
    %     else
    %         error('psych_only can only be: 0, 1 or 2.');
    %     end;

    %  idx = 1:length(curr_psych);
    mean_hh =  vertcat(mean_hh, mean(curr_hh));
    tallies = vertcat(tallies, length(curr_hh));
end;

set_out = mean_hh;