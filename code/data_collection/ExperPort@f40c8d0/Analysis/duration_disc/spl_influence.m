function [sigleft sigright] = spl_influence(ratname, varargin)

pairs = { ...
    'action', 'run' ; ... % [save | save_both | load | run ]
    % Which dates to use? ---------------------
    'use_dateset', 'psych_before' ; ... % [psych_before | psych_after | given | span_surgery | range]
    'given_dateset', {} ; ... % when 'use_dateset' = given_set, this cell array should contain a set of dates (yymmdd) for which superimposed graphs will be plotted
    'from','000000';...
    'to', '999999';...
    'dstart', 1; ... % option to plot only session A to session B; this is where you set value for A...
    'dend', 1000; ... % and this is where you set value for B
    'lastfew', 1000; ... % option to plot only last X sessions
    % Options for filtering data --------------
    'psych_level', 2 ; ... % 0 - psych == 0, 1 - psych == 1, 2 -- use all trials
    'sig_firstlast', 1 ; ... % when set, tests if, for a given side (left or right), the last binned value is significantly GREATER than the first.
    'alphaval', 0.05; ... % alpha value for significance test.
    'typeoftest', 'twotailed' ; ... % see monotonicity_test
    'num_bins', 8; ...
    % Appearance -----------------------------
    'fsize',16; ...
%    'leftcolour', [0.7 0.5 0]; ...
%    'rightcolour', [ 0 0.5 0];...
   'leftcolour', [0.4 0.4 1]; ...
    'rightcolour', [ 0 0 0.5];...
    };
parse_knownargs(varargin,pairs);

global Solo_datadir;
outdir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep ratname filesep ];
if ~exist(outdir, 'dir'), error('Directory does not exist!:\n%s\n', outdir); end;


sigleft = 0; sigright=0;

ratrow =rat_task_table(ratname);

psychf = 'psych';
task = ratrow{1,2};
if strcmpi(task(1:3), 'dua'), psychf= 'pitch_psych'; end;
fields = {'tone_spl','sides',psychf};

switch action
    case 'save'
        fname = [outdir 'spl_' use_dateset '.mat'];
        fprintf(1,'Saving trial length info in:\n%s\n', fname);

        get_fields(ratname, 'use_dateset', use_dateset, ...
            'given_dateset',given_dateset, 'from', from, 'to',to, ...
            'datafields', fields);

        save(fname, 'tone_spl','sides',psychf,'numtrials','hit_history','dates');
        return;

    case 'save_both'
        spl_influence(ratname, 'action', 'save', 'use_dateset','psych_before');
        spl_influence(ratname, 'action', 'save', 'use_dateset','psych_after');
        return;

    case 'load'
        fname = [outdir 'spl_' use_dateset '.mat'];
        fprintf(1,'Loading from:\n%s\n', fname);
        load(fname);
    case 'run'
        get_fields(ratname, 'use_dateset', use_dateset, ...
            'given_dateset',given_dateset, 'from', from, 'to',to, ...
            'datafields', fields);

    otherwise error('Invalid action');
end;

from = dates{1}; to = dates{end};

psychf = 'psych';

if exist('pitch_psych','var'), psych = pitch_psych; end;

if psych_level == 0, idx = find(psych == 0);
elseif psych_level == 1, idx = find(psych > 0);
elseif psych_level == 2, idx = 1:length(psych);
else error('psych_level must be either 0, 1, or 2.');
end;

sides = sides(idx);
tone_spl = tone_spl(idx);
hit_history = hit_history(idx);

left_idx = find(sides > 0);
right_idx = find(sides < 1);

sc = side_choice(hit_history, sides); % 1 - went left, 0 - went right

fprintf(1,'Range of SPL: %if to %i\n', round(min(tone_spl)), round(max(tone_spl)));

% run LHS trials through analysis
[left_spl_bins, avg_left_hr, sem_left] = bin_hits(tone_spl(left_idx), num_bins, sc(left_idx));
% now repeat for RHS
[right_spl_bins, avg_right_hr, sem_right] = bin_hits(tone_spl(right_idx), num_bins, sc(right_idx));

% classify 'hit' as "went left". We want to know
% what
% proportion of
% time for a
% given SPL
% bin, the rat
% went left.

figure;

set(gcf,'Position', [200   346   878   297],'Toolbar','none');
% Left plot: plot histogram of spl distribution
%axes('position',[0.8 0.2 0.2 0.5]);
overlap_hist(tone_spl(left_idx), tone_spl(right_idx), leftcolour, rightcolour,num_bins);
     uicontrol('Tag', 'figname', 'Style','text', 'String', sprintf('%s_%s_spl',ratname,use_dateset), 'Visible','off');

% axes('Position',[0.05 0.15 0.3 0.7]);
% hist(bin_nos);
xl=xlabel('SPL bins');
yl=ylabel('# trials');
t=title('SPL distribution');

[nshort xshort] = hist(tone_spl(left_idx), num_bins);
[nlong xlong] = hist(tone_spl(right_idx), num_bins);
%xidx = unique(union(xshort, xlong));
xidx = xshort;
set(gca,'XTickLabel', round(xidx), 'XTick', xidx, 'XLim', [min(xidx)-3 max(xidx)+3],...
    'FontWeight','bold','FontSize',16);
set(yl,'FontWeight','bold','FontSize',fsize);
set(xl,'FontSize',fsize,'FontWeight','bold');
set(t,'FontSize',fsize,'FontWeight','bold');

if sig_firstlast > 0
    % first do left
    ltones = tone_spl(left_idx);
    lsides = sc(left_idx);
    first_idx = find(ltones < xshort(1));
    last_idx = find(ltones > xshort(end));
    % sigleft = permutationtest_diff(lsides(first_idx), lsides(last_idx), 'alphaval', alphaval/2, 'typeoftest', 'onetailed_ls0');
    [slope dist sigleft] = monotonicity_test(left_spl_bins, avg_left_hr,'graphic',0,...
        'typeoftest', typeoftest);

    % then do right
    rtones = tone_spl(right_idx);
    rsides = sc(right_idx);
    first_idx = find(rtones < xlong(1));
    last_idx = find(rtones > xlong(end));
    % sigright = permutationtest_diff(rsides(first_idx), rsides(last_idx), 'alphaval', alphaval/2, 'typeoftest', 'onetailed_ls0');
    [slope dist sigright] = monotonicity_test(right_spl_bins, avg_right_hr,'graphic',0,...
        'typeoftest',typeoftest);

    fprintf(1,'%s:\tLeft sig?: %i\tRight sig?: %i\n',ratname, sigleft, sigright);

end;
% plot "% went left" as fn of spl bin
msize=24;
figure;
%axes('position',[0.06 0.15 0.65 0.7]);
l=errorbar(left_spl_bins,avg_left_hr, sem_left, sem_left, '.b'); % plot left

set(l,'MarkerSize',msize,'LineWidth',2,'Color',leftcolour);
hold on;

l=errorbar(right_spl_bins, avg_right_hr, sem_right, sem_right,'.r');
set(l,'MarkerSize',msize,'LineWidth',2,'Color',rightcolour);
line([min(tone_spl) max(tone_spl)],[80 80],'LineStyle',':','Color',leftcolour,'LineWidth',2);
line([min(tone_spl) max(tone_spl)], [20 20],'LineStyle',':','Color',rightcolour,'LineWidth',2);

legend({'L','R'});

xl=xlabel('Bins of intensity (spl)');
yl=ylabel('% reported "Short" (%)');
set(gca,'YLim',[0 100],'YTick',0:20:100,'XLim',[min(tone_spl) max(tone_spl)],...
    'FontSize',18,'FontWeight','bold');
str = sprintf('%s (%s-%s):\nInfluence of tone intensity on side choice', ratname, from, to);
t=title(str);

set(yl,'FontWeight','bold','FontSize',fsize);
set(xl,'FontSize',fsize,'FontWeight','bold');
set(t,'FontSize',fsize,'FontWeight','bold');

set(gcf,'Position',[264   367   1200   450]);


function [] = overlap_hist(x,y,xc, yc,num_bins)

hist(x,num_bins);
p=findobj(gca,'Type','patch'); 
set(p,'FaceColor', xc,'EdgeColor',xc,'facealpha',0.75);
hold on;
hist(y,num_bins);
set(gca,'XTick',[]);

p_all=findobj(gca,'Type','patch');
new_hist = setdiff(p_all,p);

set(new_hist,'facealpha',0.25, 'EdgeColor','none','FaceColor', yc );

