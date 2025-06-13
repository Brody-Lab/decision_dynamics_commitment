function [] = surgery_effect_trials_till_psych()
% loads before/after file for ACx lesion and for each session, plots number
% of trials till the first psychometric trial.

array_name = 'pitch_psych';
area_filter = 'mPFC';
ratlist = rat_task_table('','action',['get_' array_name],'area_filter',area_filter);

for r = 1:length(ratlist)

    [c n] = sub__tr2psych(ratlist{r}, 'psych_before');
    [c2 n2] = sub__tr2psych(ratlist{r}, 'psych_after');
    sub__plotoutput(ratlist{r}, c,n,c2,n2)
end;



function [chg numtrials] = sub__tr2psych(ratname, fname)

global Solo_datadir;
indir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep ratname filesep];
load([indir fname '.mat']);

cumtrials = cumsum(numtrials);
chg = NaN(size(cumtrials));

for k = 1:length(cumtrials)
    if k > 1, sidx = cumtrials(k-1)+1; else sidx = 1;end;
    eidx = cumtrials(k);

    ps = psychflag(sidx:eidx);
    p = find(ps > 0);
    if ~isempty(p), chg(k) =  p(1); end;
end;


function [] = sub__plotoutput(ratname, c,n,c2,n2)
figure;
plot(1:length(c), c, '.b');
hold on;
plot(1:length(n), n, '.k');
offset = length(c);
line([offset offset], [0 250], 'LineStyle',':');


plot(offset+(1:length(c2)), c2, '.r');
plot(offset+(1:length(n2)), n2, '.k');

line([0 offset+length(n2)], [100 100], 'LineStyle',':','Color', [1 1 1]*0.5);
ylabel('First psych trial');
xlabel('Session #');
title(ratname);

axes__format(gca);

set(gcf,'Position',[200 200 800 300]);
set(gca,'YLim',[0 300], 'XLim', [max(1, offset-9) min(offset+10, offset+length(n2))] );
set(gca,'XTick', 1:offset+length(n2), 'XTickLabel', [-1*offset:-1 1:length(n2)]);
sign_fname(gcf,mfilename);
