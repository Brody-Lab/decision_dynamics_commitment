function [] = psych_trialtype(area_filter)

infile = 'psych_after';
experimenter='Shraddha';
numsess=3; % examine first 3 sessions only

freqset = rat_task_table('','action','get_pitch_psych','area_filter',area_filter);
durset = rat_task_table('','action','get_duration_psych','area_filter',area_filter);

ratset = [durset freqset];

global Solo_datadir;
if isempty(Solo_datadir), mystartup; end;
%outdir = [Solo_datadir filesep 'Data' filesep experimenter filesep ratname filesep];
outdir = [Solo_datadir filesep 'Data' filesep experimenter filesep 'Set_Analysis' filesep 'psych_compiles' filesep];

ptrials=NaN(size(ratset)); % psych trials
ttrials=NaN(size(ratset)); % total trials

for r=1:length(ratset)
    ratname=ratset{r};    
    fname = [outdir ratname '_' infile '.mat'];
    load(fname);
    
    cumtrials=cumsum(numtrials);
    eidx = cumtrials(3);
    
    ptrials(r) = sum(psychflag(1:eidx));
    ttrials(r) = eidx; % ntrials=eidx-ptrials(r);
end;

sub__barpairs(ptrials, ttrials, ratset);

2;


function [] = sub__barpairs(seta, setb,rn)
figure;
x = 1;
ncolor=[1 1 1]*0.5;
pcolor='r';
for r=1:length(seta)
    patch([x x x+0.5 x+0.5],[0 seta(r) seta(r) 0],pcolor); hold on;
    patch([x+0.5 x+0.5 x+1 x+1], [0 setb(r)-seta(r) setb(r)-seta(r) 0], ncolor); 
    x=x+2;
end;

x=x+2;
set(gca,'XTick', 1.5:2:(2*length(seta))+1.5, 'XTickLabel',rn);

set(gca,'XLim',[-1 x]);

xlabel('Rat');
ylabel('Psych(blue)-Non(grey)');
