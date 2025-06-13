function [hlist havg] = firstday_postlesion(ttype, area_filter,numt)

global Solo_datadir;
indir=[Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Set_Analysis' filesep 'psych_compiles' filesep];
hrate_buffer={};


sm=1000;
d=dbstack;
if strcmpi(ttype,'both') % recursive case
    isbasecase=1;
    
    figure;
    l1=line([1 numt],[0.8 0.8],'LineStyle',':','Color',[1 1 1]*0.5);
    hold on;
    l2=line([1 numt],[0.5 0.5],'LineStyle',':','Color',[1 0 0]);
    
    durclr = group_colour('durlite');
    freqclr= group_colour('freqlite');

    [hlist_d havg]=firstday_postlesion('d',area_filter,numt);
    hg_dur=hggroup;
    for h=1:length(hlist_d)
        set(hlist_d(h),'Parent',hg_dur,'Color',durclr);
    end;
    set(havg,'Color',group_colour('duration'));

    [hlist_f havg]=firstday_postlesion('p',area_filter,numt);
    hg_freq=hggroup;
    for h=1:length(hlist_f)
        set(hlist_f(h),'Parent',hg_freq,'Color',freqclr);
    end;
    set(havg,'Color',group_colour('frequency'));

elseif strcmpi(ttype,'d'),
    str='get_duration_psych';
    if rows(d) > 1
        if strcmpi(d(2).name,'firstday_postlesion')
            isbasecase=1;
        else
            isbasecase=0;
        end;
    else
        isbasecase=0;
    end;
else
    str='get_pitch_psych';
    if rows(d) > 1
        if strcmpi(d(2).name,'firstday_postlesion')
            isbasecase=1;
        else
            isbasecase=0;
        end;
    else
        isbasecase=0;
    end;

end;

if isbasecase == 0
    figure;
    l1=line([1 numt],[0.8 0.8],'LineStyle',':','Color',[1 1 1]*0.5);
    hold on;
    l2=line([1 numt],[0.5 0.5],'LineStyle',':','Color',[1 0 0]);
end;

if ~strcmpi(ttype,'both')
    ratlist = rat_task_table('','action', str, 'area_filter',area_filter);
hlist=NaN(size(ratlist));
for r=1:length(ratlist)
    infile = [indir ratlist{r} '_psych_after'];
    load(infile);

    currt = min(numt, numtrials(1));
    clr=rand(1,3);
    num=sub__kernalize(hit_history(1:currt));

    sm = min(sm, currt);

    hlist(r)=plot(num, '.-','Color',clr);
    hold on;

    hrate_buffer{end+1}=hit_history;
    clear hit_history;
end;

hrate=NaN(1,numt);
for r=1:length(ratlist)
    ln = length(hrate_buffer{r});
    ln=min(ln, numt);
    hrate(r,1:ln)=hrate_buffer{r}(1:ln);
end;

% plot average
num=sub__kernalize(nanmean(hrate,1));
havg=plot(num,'.-','Color','k','LineWidth',2);
end;

if strcmpi(ttype,'both')
elseif isbasecase==0
    legend(hlist,ratlist);
end;

title(sprintf('%s (%s)', area_filter, ttype));
ylabel('Accuracy (%)');
xlabel('Trial number (1st postlesion session)');

set(gca,'YLim',[0.3 1.2],'YTick',0.3:0.1:1,'YTickLabel',30:10:100);
set(gcf,'Position',[1 1 1109 304]);


function [a] = sub__kernalize(hh)

running_avg=20;

nums=[];
t = (1:length(hh))';
a = zeros(size(t));
for i=1:length(hh),
    x = 1:i;
    kernel = exp(-(i-t(1:i))/running_avg);
    kernel = kernel(1:i) / sum(kernel(1:i));

    a(i) = sum(hh(x)' .*kernel);
end;
num = a;

