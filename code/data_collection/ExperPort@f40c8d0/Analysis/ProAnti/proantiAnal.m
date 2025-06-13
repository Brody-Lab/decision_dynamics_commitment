function proantiAnal(fname)

FIRST_REAL=2;
% For reasons to complicated to explain here, the first trial in any
% protocol is a throw away trial.  If this changes, change this constant.

if ~exist('fname','var')
    [fname, pathname, filterindex] = uigetfile('*.mat', 'Pick an data file');
	if fname==0
	warning('no file chosen')
	return
end
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

ntrials=saved.ProtocolsSection_n_done_trials;
loc=cell2mat(saved_history.PerformanceSection_pro_trial);
loc=col(loc(FIRST_REAL:ntrials));
try
    hit=saved.PerformanceSection_gotit_history;
catch
    hit=saved.PerformanceSection_hit_history;
end
hit=col(hit(FIRST_REAL:ntrials));
anthit=hit(loc==-1);
prohit=hit(loc==1);

% RT=saved.quadsamp3obj_reaction_times(FIRST_REAL:ntrials);;
all_events=saved_history.ProtocolsSection_parsed_events;

for aex=1:numel(all_events)
	try
    ce=all_events{aex};
    t1=ce.states.wait_for_poke2(2);
    t2=ce.states.wait_for_poke3(2);

    if ~isempty(t1) && ~isempty(t2)
        RT(aex)=t2-t1;
    else
        RT(aex)=nan;
	end
	catch
		RT(aex)=nan;
	end
end


ratname=saved.SavingSection_ratname;
onrig=saved.SavingSection_hostname;
rundate=saved.SavingSection_SaveTime;


%% Some basic stats

totPerf=mean(hit);
proPerf=mean(prohit);
antPerf=mean(anthit);

%these are used for plotting.
if sum(loc==1)>5
pro1RTind=find(loc.*hit==1);
pro0RTind=find(loc.*(1-hit)==1);
pro1RT=RT(loc.*hit==1);
pro0RT=RT(loc.*(1-hit)==1);
pro1CI=bootci(1000, @nanmean, pro1RT);
pro0CI=bootci(1000, @nanmean, pro0RT);
line3=['pro RT corr: ' num2str(nanmean(pro1RT),3) ' [' num2str(pro1CI(1),3) '-' num2str(pro1CI(2),3) ']    ' ...
       'pro RT wrng: ' num2str(nanmean(pro0RT),3) ' [' num2str(pro0CI(1),3) '-' num2str(pro0CI(2),3) ']    '];

else
    line3='No Pro Trials';
    pro1RT=-1;
	pro0RT=-1;
end

if sum(loc==-1)>5

ant1RTind=find(loc.*hit==-1);
ant0RTind=find(loc.*(1-hit)==-1);
ant1RT=RT(loc.*hit==-1);
ant0RT=RT(loc.*(1-hit)==-1);

ant1CI=bootci(1000, @nanmean, ant1RT);
ant0CI=bootci(1000, @nanmean, ant0RT);
line4=['ant RT corr: ' num2str(nanmean(ant1RT),3) ' [' num2str(ant1CI(1),3) '-' num2str(ant1CI(2),3) ']    ' ...
       'ant RT wrng: ' num2str(nanmean(ant0RT),3) ' [' num2str(ant0CI(1),3) '-' num2str(ant0CI(2),3) ']'];
else
    		ant1RT=-1;
	ant0RT=-1;
    line4='No Anti Trials';
end

%% Print some info
figure;
h=annotation('textbox',[.07 .8 .8 .15]);
line1=[ratname sprintf('\t') rundate sprintf('\t') onrig];
line2=['Overall Perf: ' num2str(totPerf*100,3) '%' sprintf('\t') 'Pro Perf: ' num2str(proPerf*100,3) '%' sprintf('\t') 'Anti Perf: ' num2str(antPerf*100,3) '%'];
set(h,'String',{line1, line2, line3, line4});

%% Now plot the busy plot
subplot('position',[.07 .48 .8 .3])
[a, h1, h2]=plotyy([1,100],[0 1],[1 100],[0 8]);
hold(a(2),'on');
hold(a(1),'on');

h=bar(a(1),loc);

set(h,'FaceColor',[0.7 .7 .7]);
set(h,'EdgeColor',[0.7 .7 .7]);

%krn=1.618.^[0:10];  % make the exponential smoothing kernel
%krn=[ krn/sum(krn)] ;
krn=normpdf(-5:5,0,1.5); 

smhit=jconv(krn, hit'); 
plot(a(1),smhit,'k-') ;

delete(h1)
delete(h2)


set(a(2), 'YLim',[0 nanmean(RT)+nanstd(RT)*2])
set(a(2), 'YTickMode','auto')
% plot(hit/2+.2,'ko')  this is redundant.


if sum(loc==1)>5
plot(a(2),pro1RTind, pro1RT,'g.');
plot(a(2),pro0RTind, pro0RT,'r.');
end
if sum(loc==-1)>5
plot(a(2),ant1RTind, ant1RT,'g.');
plot(a(2),ant0RTind, ant0RT,'r.');
end
xlabel('Trials');
set(a(1),'XLim',[1 length(smhit)])
set(a(2),'XLim',[1 length(smhit)])



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
trncRT=RT(RT<(mnRT+2*stdRT));

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
