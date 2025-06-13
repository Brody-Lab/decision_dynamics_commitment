function [varargout]=quadsamp_switch(fname, varargin)

pairs={...
	'FIRST_REAL'	2;
	'doplot'		0;
	'wndw'			10;
	};
parseargs(varargin,pairs);
% For reasons to complicated to explain here, the first trial in any
% protocol is a throw away trial.  If this changes, change this constant.

if ~exist('fname','var')
    [fname, pathname, filterindex] = uigetfile('*.mat', 'Pick an data file');
    fname=[pathname filesep fname];
end
   
% Loading data can take a while, so if you want to keep the cell loaded in
% matlab you can pass it in as a cell
if iscell(fname)
    saved=fname{1};
    saved_history=fname{2};
else
    load(fname);
end

%% move relavent info from saved structs to local variables.

ntrials=saved.quadsamp3obj_n_done_trials;
loc=cell2mat(saved_history.ChordSection_Loc_Factor);
loc=col(loc(FIRST_REAL:ntrials));
hit=saved.quadsamp3obj_hit_history;
hit=col(hit(FIRST_REAL:ntrials));
anthit=hit(loc==-1);
prohit=hit(loc==1);

RT=saved.quadsamp3obj_reaction_times(FIRST_REAL:ntrials);

ratname=saved.SavingSection_ratname;
onrig=saved.SavingSection_hostname;
rundate=saved.SavingSection_SaveTime;


%% Some basic stats

totPerf=mean(hit);
proPerf=mean(prohit);
antPerf=mean(anthit);

%these are used for plotting.
pro1RTind=find(loc.*hit==1);
pro0RTind=find(loc.*(1-hit)==1);
ant1RTind=find(loc.*hit==-1);
ant0RTind=find(loc.*(1-hit)==-1);


pro1RT=RT(loc.*hit==1);
pro0RT=RT(loc.*(1-hit)==1);
ant1RT=RT(loc.*hit==-1);
ant0RT=RT(loc.*(1-hit)==-1);

pro1CI=bootci(1000, @mean, pro1RT);
pro0CI=bootci(1000, @mean, pro0RT);
ant1CI=bootci(1000, @mean, ant1RT);
ant0CI=bootci(1000, @mean, ant0RT);



%% Print some info
if doplot

figure;
h=annotation('textbox',[.07 .8 .8 .15]);
line1=[ratname sprintf('\t') rundate sprintf('\t') onrig];
line2=['Overall Perf: ' num2str(totPerf*100,3) '%' sprintf('\t') 'Pro Perf: ' num2str(proPerf*100,3) '%' sprintf('\t') 'Anti Perf: ' num2str(antPerf*100,3) '%'];
line3=['pro RT corr: ' num2str(mean(pro1RT),3) ' [' num2str(pro1CI(1),3) '-' num2str(pro1CI(2),3) ']    ' ...
       'pro RT wrng: ' num2str(mean(pro0RT),3) ' [' num2str(pro0CI(1),3) '-' num2str(pro0CI(2),3) ']    '];
line4=['ant RT corr: ' num2str(mean(ant1RT),3) ' [' num2str(ant1CI(1),3) '-' num2str(ant1CI(2),3) ']    ' ...
       'ant RT wrng: ' num2str(mean(ant0RT),3) ' [' num2str(ant0CI(1),3) '-' num2str(ant0CI(2),3) ']'];
set(h,'String',{line1, line2, line3, line4});

%% Now plot the busy plot
subplot('position',[.07 .48 .8 .3])

h=bar(loc*4);
set(h,'FaceColor',[0.7 .7 .7]);
set(h,'EdgeColor',[0.7 .7 .7]);

hold on
set(gca, 'YLim',[.1 3.9])
% plot(hit/2+.2,'ko')  this is redundant.

krn=1.618.^[0:10];  % make the exponential smoothing kernel
krn=[krn/sum(krn) zeros(1,10)] ;
smhit=jconv(krn, hit');
plot(smhit,'k-') ;
plot(pro1RTind, pro1RT,'g.');
plot(ant1RTind, ant1RT,'g.');
plot(pro0RTind, pro0RT,'r.');
plot(ant0RTind, ant0RT,'r.');
xlabel('Trials');

tts=['Gray bars are pro blocks, white bars are anti blocks. ' sprintf('\n') ...
     'Open circles indicate whether a trial was correct (high row) or not.  ' sprintf('\n') ...
     'The black line is a exp running avg. of the performance.' sprintf('\n') ...
     'Green and Red dots are the reaction times on correct and incorrect trials respectively'];


hu=uicontrol('Style', 'text', 'String', 'explain','Units','normalized', ...
    'Position', [.9 .6 .08 .02], 'TooltipString', tts);

%% Now plot the reaction time historgrams


subplot('position',[.07 .08 .8 .3])


tts=['Histogram of Reaction Time. ' sprintf('\n') ...
     'Pro trials are in blue.  Anti trials are in pink.  ' sprintf('\n') ...
     'Correct trials are ''up-going'' and incorrect are ''down-going''.' sprintf('\n') ...
     'Reaction times outside 3 standard deviations of the dist. of all RTs are excluded' sprintf('\n') ...
     'from this graph but are included in the confidence intervals posted at the top of this figure'];


hu=uicontrol('Style', 'text', 'String', 'explain','Units','normalized', ...
    'Position', [.9 .2 .08 .02], 'TooltipString', tts);


%find RT outliers.
mnRT=mean(RT);
stdRT=std(RT);
trncRT=RT(RT<(mnRT+3*stdRT));

edg=0.3:.1:max(trncRT);  % This should be dynamic or an option but i wanted to include only most of the trials.

hp1=col(histc(pro1RT, edg));
hp0=col(histc(pro0RT, edg)*-1);
ha1=col(histc(ant1RT, edg));
ha0=col(histc(ant0RT, edg)*-1);

h=bar(edg,[hp1 hp0 ha1 ha0]);
set(gca,'XLim', [0.25 max(trncRT)+0.5]);
set(h(3),'EdgeColor',[.8 .5 .5])
set(h(3),'FaceColor',[.8 .5 .5])
set(h(4),'FaceColor',[.8 .5 .5])
set(h(4),'EdgeColor',[.8 .5 .5])
set(h(1),'EdgeColor','b')
set(h(1),'FaceColor','b')
set(h(2),'FaceColor','b')
set(h(2),'EdgeColor','b')
xlabel('Reaction Time (sec)');

end

function y=col(x)

s=size(x);

if s(1)<s(2)
    y=x.';
else
    y=x;
end

function y=jconv(krn,x)
%function y=jconv(krn,x);
% give data and a kernel, and return data of the same size but smooth.

if mod(length(krn),2)==1
    
    b=(length(krn)-1)/2;
    y=conv(krn,x);
    y=y(b+1:end-b);
else
    
    b=(length(krn))/2;
    y=conv(krn,x);
    y=y(b+1:end-b);
    
end
     
 fl=floor(sum(krn>0.001)/2);
 if fl
 y(1:fl)=y(fl);
 y(end-fl:end)=y(end-fl);
 end
% NOTE: this is a bit of a hack
