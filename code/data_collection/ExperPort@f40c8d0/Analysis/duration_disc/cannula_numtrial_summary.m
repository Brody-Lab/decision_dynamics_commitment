function [] = cannula_numtrial_summary(ratname,mkover)

if nargin < 2, mkover = 1; end;

    global Solo_datadir;
    if isempty(Solo_datadir), mystartup; end;
    outdir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep ratname filesep];
    outfile = [outdir 'cannula_numtrials.mat'];

if mkover > 0

    salinedays = rat_task_table(ratname, 'action', 'cannula__saline'); salinedays = salinedays(:,1);
    muscdays = rat_task_table(ratname, 'action', 'cannula__muscimol'); muscdays = muscdays(:,1);
    nondays = rat_task_table(ratname, 'action', 'cannula__nondays');  nondays = nondays(:,1);

    ratrow = rat_task_table(ratname);
    basedate = ratrow{1, rat_task_table('','action', 'get_prepsych_col')};

    get_fields(ratname, 'use_dateset', 'given', 'given_dateset', salinedays);
    numt_saline = numtrials;

    get_fields(ratname, 'use_dateset', 'given', 'given_dateset', muscdays);
    numt_musc = numtrials;

    get_fields(ratname, 'use_dateset', 'given', 'given_dateset', nondays);
    numt_nond = numtrials;

    get_fields(ratname, 'use_dateset', 'range', 'from', basedate{1}, 'to', basedate{2});
    numt_base = numtrials;

    avgt = [mean(numt_base), mean(numt_nond), mean(numt_saline), mean(numt_musc)];
    vart = [std(numt_base), std(numt_nond), std(numt_saline), std(numt_musc)];

    save(outfile, 'salinedays', 'numt_saline','muscdays', 'numt_musc', 'nondays','numt_nond','basedate','numt_base', 'avgt', 'vart');
else
    load(outfile);
end;

% order is : baseline, nondays, saline, muscimol
clrs = {[1 0 0]*0.2,[0 1 0]*0.2,[0.3 0.3 1],[1 1 1]*0.3}; % colours go in reverse order of series
ptclrs = {[1 0 0],[0 1 0],[0 0 0.5],[1 1 1]*0.5}; % colours go in reverse order of series
% now plot bars
barweb(avgt, vart);

xpos = barweb_change_colour(gca,clrs, 'none',1); % xpos is in reverse order of series
series_order = {'base', 'nond','saline','musc'};
for k = 1:length(series_order)
    hold on;
    currser = eval(['numt_' series_order{k} ';']);
    mypos = length(series_order)-(k-1);
    plot(ones(size(currser))*xpos(mypos), currser,'.k','MarkerSize',15,'Color', ptclrs{mypos},'LineWidth',2);
end;
ylabel('Trials in a session');
set(gca,'XTick',[]);
set(gcf,'Color',[1 1 1]*0.8);

title(ratname);
axes__format(gca);