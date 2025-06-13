function S=psychoplot_delori(varargin)
% [s]=psychoplot_delori(sessid,nonmemaxh, memaxh)
% [s]=psychoplot_delori(ratname,experimenter, date,nonmemaxh, memaxh)
% [s]=psychoplot_delori(ratname,experimenter, daterange,nonmemaxh, memaxh)
%
% sessid can be a single sessid or a vector of sessids
% date should be of the form "YYYY-MM-DD" or a relative date like -5
% daterange should be a numeric vector in relative form like -10:-1 or a
% cell array of date string of the from "YYYY-MM-DD"
%

%% parse inputs
if ischar(varargin{1})
    ratname=varargin{1};
else
    ratname='';
end
[S, varargin]=get_sessdata(varargin);
sessid=1; % THIS IS A HACK TO AVOID THE COMPLAINT ON LINE 33.  jce.
fields_to_vars(S);

pairs={'linestyle','-';...
    'marker','o';...
    'markersize',9;...
    'memax', [];...
    'nonmemax',[];...
    'cpvax',[0 0];...
    'rtax',[0 0];...
    'confints',0;...
    'do_cpv', 0;...
    'do_rt',0;...
    'memclr',[249 76 0]/255;...
    'nonclr',[0 0.45 0];...
    'indif_line',0};

parseargs(varargin, pairs);

if isempty(memax)
    f1=figure;
    memax=axes;
    nonmemax=memax;
end

if cpvax(1)==0 && do_cpv
    f2=figure;
    cpvax=axes;
elseif cpvax(1)>0
    do_cpv=1;
end

if rtax(1)==0 && do_rt
    f3=figure;
    rtax=[axes axes];
elseif rtax(1)>0
    do_rt=1;
end
% try to figure out whether fsd or ssd is the relevant variable for
% mem/non-mem
mem_f='stim_start_delay';

%% compile data across sessions.

hits=[];
sides=[];
sounds=[];
mem=[];
cout=[];
cpv=[];

for sx=1:numel(sessid);
    t_mem=pd{sx}.ssd;
    t_hits=pd{sx}.hits;
    t_sides=pd{sx}.sides;
    t_sounds=pd{sx}.sounds;
    t_cpv=pd{sx}.cpv;
    try
        t_cout=pd{sx}.cout;
    catch
        t_cout=extract_event(peh{sx},'wait_for_center_nose_out(end,1)');
    end
    cin=extract_event(peh{sx},'cpoke1(end,1)');
    t_cout=t_cout-cin;
    % make sure all vecs are the same length.
    trial_n=min([numel(t_hits) numel(t_mem) numel(t_sides) numel(t_sounds) numel(t_cpv) numel(t_cout)]);
    
    t_mem=t_mem(1:trial_n);
    t_hits=t_hits(1:trial_n);
    t_sides=t_sides(1:trial_n);
    t_sounds=t_sounds(1:trial_n);
    t_cpv=t_cpv(1:trial_n);
    t_cout=t_cout(1:trial_n);
    
    gd_trials=~isnan(t_hits); % & t_cpv==0;
    
    hits=[hits ; t_hits(gd_trials(:))];
    sides=[sides; t_sides(gd_trials(:))];
    sounds=[sounds; t_sounds(gd_trials(:))];
    mem=[mem; t_mem(gd_trials(:))];
    cout=[cout; t_cout(gd_trials(:))];
    cpv=[cpv; t_cpv(gd_trials(:))];
    
end

%% Reassign sound values
o_sounds=sounds; % this is used to calculate the n later on.

% Try to figure out whether the rat is a freq rat or a pro rat - note some
% rats may have changed... this one is tricky
if pd{end}.soundtable{1,4}.Bal==0
    for sx=1:size(pd{end}.soundtable,1)
        n_sounds(sounds==sx)=pd{end}.soundtable{sx,4}.Freq1;
        s_side(sx)=pd{end}.soundtable{sx,2};
        s_sound(sx)=pd{end}.soundtable{sx,4}.Freq1;
    end
    freq_flag=1;
    n_sounds=log(n_sounds);
    L_mid_point=sqrt(s_sound(1)*s_sound(end));
    mid_point=log(L_mid_point);
    x_label='Clicks/Sec';
else
    for sx=1:size(pd{end}.soundtable,1)
        n_sounds(sounds==sx)=pd{end}.soundtable{sx,4}.Bal;
        s_side(sx)=pd{end}.soundtable{sx,2};
        s_sound(sx)=pd{end}.soundtable{sx,4}.Bal;
    end
    freq_flag=0;
    x_label='Balance (-1=left, 0=stereo, 1=ipsi)';
    mid_point=0;
    L_mid_point=0;
end

sounds=n_sounds;

%% clean up the data a bit
mem=mem<0.5;

gd=~isnan(hits);
hits=hits(gd);
sides=sides(gd);
sounds=sounds(gd);
cpv=cpv(gd);
cout=cout(gd);
o_sounds=o_sounds(gd);
mem=mem(gd);

if isnumeric(sides(1))
    went_ipsi=(hits==1 & sides==1) | (hits==0 & sides==-1);
else
    sides=lower(sides);
    went_ipsi=(hits==1 & sides=='r') | (hits==0 & sides=='l');
end

% do we need to reverse the x-axis?
[s_sound,sidx]=sort(s_sound);
s_side=s_side(sidx);
if s_side(1)=='r'
    reverse_flag=1;
else
    reverse_flag=0;
end
%% CPV plot
if do_cpv
    S.data={sounds mem hits cpv sides};
S.cpv1=plot_sig(cpvax(1), sounds(mem & hits==1), cpv(mem & hits==1),memclr,reverse_flag,linestyle,marker,markersize,confints);
S.cpv2=plot_sig(cpvax(2), sounds(~mem & hits==1), cpv(~mem & hits==1),nonclr,reverse_flag,linestyle,marker,markersize,confints);
end

%% RT Plot
if do_rt
cout(cout>1.2)=nan;
S.rt1=plot_meta(rtax(1), sounds(mem & hits==1),cout(mem & hits==1),memclr,reverse_flag,linestyle,marker,markersize,confints);
S.rt2=plot_meta(rtax(2), sounds(~mem & hits==1),cout(~mem & hits==1),nonclr,reverse_flag,linestyle,marker,markersize,confints);
end
%%	call the sigplot

% if freq_flag
% 	set(ax,'XScale','log');
% end
S.memh=plot_sig(memax, sounds(mem)+0.005*range(sounds), went_ipsi(mem),memclr,reverse_flag,linestyle,marker,markersize,confints);
S.nonmemh=plot_sig(nonmemax, sounds(~mem), went_ipsi(~mem),nonclr,reverse_flag,linestyle,marker,markersize,confints);
% we do 3.5-sounds because there are 6 sounds going from right to left,
% by doing 3.5- we make them go from left to right and also make it zero
% centered, which is a bit easier for interpreting bias.

%% axes and labels

allax=[memax nonmemax];
if do_cpv
    allax=[allax cpvax];
end

if do_rt
    allax=[allax rtax];
end

for ax=allax
    if freq_flag
        set(ax,'XTick',sort([log(unique(s_sound(:))); mid_point]));
        set(ax,'XTickLabel',sort([s_sound(:); L_mid_point]));
    else
        set(ax,'XTick',sort([unique(s_sound(:)); mid_point]));
    end
    
    switch ax
        case {memax,nonmemax}
            ylim([0 100]);
            set(ax,'YTick',[0:25:100]);
            ylabel(ax,'% went right')
        case {rtax(1), rtax(2)}
            ylabel(ax,'Reaction Time (s)')
        case {cpvax(1),cpvax(2)}
            
            ylim(ax,[0 100]);
            set(ax,'YTick',[0:25:100]);
            ylabel(ax,'% Break Fixation trials')
    end
    
    
    set(ax,'Position',[0.2 0.2 0.6 0.6])
    xlim(ax,[min(sounds)-abs(0.01*min(sounds))  max(sounds)+abs(0.01*max(sounds))]);
    xlabel(ax,x_label)
%    title(unique(ratname));
    set(ax,'YGrid','on')
    
end

memn=hist(o_sounds(mem),1:6);
nmemn=hist(o_sounds(~mem),1:6);
if reverse_flag
    memn=memn(end:-1:1);
    nmemn=nmemn(end:-1:1);
end

%% legend
if memax==nonmemax
    legend([S.memh.fit S.nonmemh.fit], {sprintf(['mem,     \t n=[' num2str(memn) ']']) sprintf(['non-mem,\t n=[' num2str(nmemn) ']'])},'Location',[0.15 0.02 0.7 0.1])
end
%legend([S.memh.fit S.nonmemh.fit], {'memory' 'non-memory'},'Location','Best')

%% plot_sig

function S=plot_sig(ax, x_vals, went_ipsi,clr,reverse_flag,linestyle,marker,markersize,confints)


went_ipsi=went_ipsi*100; % puts everything in percentile


trial_types = unique(x_vals);

%% mean and binomial error bars.
meanD=zeros(size(trial_types));
seD=meanD;
for tx = 1:numel(trial_types),
    meanD(tx) = mean(went_ipsi(x_vals == trial_types(tx)));
    %seD(tx) = stderr(went_ipsi(x_vals == trial_types(tx)));
    % it doesn't make sense to take the stderr of a bernoulli variable.
    % instead , just make the error bars 1/sqrt(n);
    seD(tx) = sqrt(meanD(tx)*(100-meanD(tx))/sum(x_vals == trial_types(tx)));
    
end;

eh=errorplot(ax, trial_types, meanD,seD,'LineStyle','none','Marker',marker);

set(eh(1),'MarkerSize', markersize,'MarkerEdgeColor','k');
set(eh(1),'MarkerFaceColor',clr);
set(eh, 'Color',clr);

if reverse_flag
    rev=-1;
    y0=meanD(end);
    set(ax,'XDir','reverse');
else
    rev=1;
    y0=meanD(1);
end

S.errorbars=eh;


%% nlinfit
try
    [beta,resid,jacob,sigma,mse] = nlinfit(x_vals(:),went_ipsi(:),@sig4,[y0 rev*range(meanD) mean(x_vals) 0.2*range(x_vals)]);
    
    x_s=linspace(min(x_vals), max(x_vals), 100);
    [y_s,delta] = nlpredci(@sig4,x_s,beta,resid,'covar',sigma);
    
    betaci = nlparci(beta,resid,'covar',sigma);
    S.beta=beta;
    S.resid=resid;
    S.jacob=jacob;
    S.sigma=sigma;
    S.mse=mse;
    axes(ax);
    h1=line(x_s, y_s);
    S.fit=h1;
    set(h1,'Color',clr);
    set(h1,'LineStyle',linestyle);
    if confints
        h1=line(x_s,y_s-delta');
        set(h1,'Color',clr, 'LineStyle',':');
        h1=line(x_s,y_s+delta');
        set(h1,'Color',clr, 'LineStyle',':');
    end
    
    %% indifference point.
%     x_50=isig4(beta,50);
%     if isreal(x_50)
%         bl=line([x_50 x_50],[0 100]);
%         set(bl, 'LineStyle','--','Color',clr)
%     end
    
    %% fitting functions
    
catch
    showerror
end

function y=sig4(beta,x)
%%
y0=beta(1);
a=beta(2);
x0=beta(3);
b=beta(4);

y=y0+a./(1+ exp(-(x-x0)./b));

function x=isig4(beta,y)

y0=beta(1);
a=beta(2);
x0=beta(3);
b=beta(4);

x=-(b.*log(a./(y-y0)-1)-x0);

function S=plot_meta(ax,x_s,y_s,clr,reverse_flag,linestyle,marker,markersize,confints)

gd=~isnan(y_s);
x_s=x_s(gd);
y_s=y_s(gd);

trial_types = unique(x_s);

%% mean and binomial error bars.
meanD=zeros(size(trial_types));
seD=meanD;
for tx = 1:numel(trial_types),
    meanD(tx) = nanmean(y_s(x_s == trial_types(tx)));
    %seD(tx) = stderr(went_ipsi(x_vals == trial_types(tx)));
    % it doesn't make sense to take the stderr of a bernoulli variable.
    % instead , just make the error bars 1/sqrt(n);
    seD(tx) = nanstderr(y_s(x_s == trial_types(tx)));
    
end;

eh=errorplot(ax, trial_types, meanD,seD,'LineStyle','none','Marker',marker);

set(eh(1),'MarkerSize', markersize);
set(eh(1),'MarkerFaceColor',clr);
set(eh, 'Color',clr);

if reverse_flag
    rev=-1;
    y0=meanD(end);
    set(ax,'XDir','reverse');
else
    rev=1;
    y0=meanD(1);
end

S.errorbars=eh;
