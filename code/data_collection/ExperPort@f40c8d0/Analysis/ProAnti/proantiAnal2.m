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

gotit_history=saved.PerformanceSection_gotit_history;
hit=gotit_history;
hit_history=saved.PerformanceSection_hit_history;
block_history=saved.PerformanceSection_block_history;
hit=col(hit(FIRST_REAL:ntrials));
block_history=col(block_history(FIRST_REAL:ntrials));
anthit=hit(loc==-1);
prohit=hit(loc==1);
b0hit=hit(block_history==0);
b1hit=hit(block_history==1);

ratname=saved.SavingSection_ratname;
onrig=saved.SavingSection_hostname;
rundate=saved.SavingSection_SaveTime;


%% Some basic stats

totPerf=nanmean(hit);
proPerf=nanmean(prohit);
antPerf=nanmean(anthit);
b0_Perf=nanmean(b0hit);
b1_Perf=nanmean(b1hit);
b0_trials=sum(~isnan(b0hit));
b1_trials=sum(~isnan(b1hit));

%% Print some info
fh=figure;
set(fh,'Name',ratname);
h=annotation('textbox',[.1 .8 .8 .14]);
line1=[ratname sprintf('\t') rundate sprintf('\t') onrig];
line2=['# Completed Trials: ' num2str(saved.PerformanceSection_n_good_trials)  sprintf('\t') 'Overall Perf: ' num2str(totPerf*100,3) '%' sprintf('\t') 'Pro Perf: ' num2str(proPerf*100,3) '%' sprintf('\t') 'Anti Perf: ' num2str(antPerf*100,3) '%'];
line3=['# of trials block0: ' num2str(b0_trials)  ', block1: ' num2str(b1_trials) sprintf('\t') 'Block0 Perf : ' num2str(b0_Perf*100,3) '%' sprintf('\t')  'Block1 : ' num2str(b1_Perf*100,3) '%'];
set(h,'String',{line1, line2, line3});

%% Now plot the busy plot
subplot('position',[.1 .15 .8 .6])
myaxes=gca;
previous_sides=saved.PerformanceSection_previous_sides;
previous_cntxt=saved.PerformanceSection_previous_cntxt;
    ps = value(previous_sides);
    if ps(end)==-1, 
        hb = line(length(previous_sides), 2, 'Parent', myaxes);
    else                         
        hb = line(length(previous_sides), 1, 'Parent', myaxes);
    end;
    set(hb, 'Color', 'b', 'Marker', '.', 'LineStyle', 'none');

    xgreen = find(gotit_history==1);
    ygreen = previous_sides(xgreen).*(1-0.2*previous_cntxt(xgreen));
    hg = line(xgreen, ygreen, 'Parent', value(myaxes));
    set(hg, 'Color', 'g', 'Marker', '.', 'LineStyle', 'none'); 

    xred  = find(value(gotit_history)==0);
    yred = previous_sides(xred).*(1-0.2*previous_cntxt(xred));  
	hr = line(xred, yred, 'Parent', value(myaxes));
    set(hr, 'Color', 'r', 'Marker', '.', 'LineStyle', 'none'); 
	
	
    xblack  = find(isnan(value(hit_history)));
    yblack = previous_sides(xblack).*(1-0.2*previous_cntxt(xblack));  
	   hk = line(xblack, yblack, 'Parent', value(myaxes));
    set(hk, 'Color', 'k', 'Marker', '.', 'LineStyle', 'none'); 

    if ~isscalar(ntrials+0)
		minx=min(ntrials+0);
		maxx=max(ntrials+0);
	else
		
   end
	set(value(myaxes), 'YGrid','On','YTick', [-1.2 -0.8  0.8 1.2 ], 'YLim', [-1.5 1.5], 'YTickLabel', ...
                        {'AntiLeft', 'ProLeft', 'ProRight','AntiRight'});
  
    drawnow;
%% Now plot the reaction time historgrams

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
