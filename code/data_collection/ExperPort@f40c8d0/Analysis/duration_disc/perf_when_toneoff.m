function [] = perf_when_toneoff(ratset, from, to,action,infile)

% Duration rats as of 10th March 09
%perf_when_toneoff({'S042','S029','S038','S048','S049','S051','S033'},'090310a','load')

global Solo_datadir;
indir = [ Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Set_Analysis' filesep];
if isempty(infile),
    infile = 'spl_removed_data_dur.mat';
end;

clrset(1,:) = [1 1 1] * 0.3;
clrset(2,:) = [0.5 0 0.5];

switch action
    case 'runsingle'
       [hb hnb] = sub__oneratdate(ratset, indate);                
    case 'save'
        data=cell(length(ratset), 4);
        for r=1:length(ratset)
            [hb hnb tob tonob] = sub__oneratdate(ratset{r}, from,to);
            data{r,1} = hb;
            data{r,2} = hnb;
            data{r,3} = ratset{r};
            data{r,4} = from;
            
            todata{r,1} = tob;
            todata{r,2} = tonob;
            todata{r,3} = ratset{r};
            todata{r,4} = from;
            
        end;

        datadesc='each row is a rat/session. hb is hh for trials where cue was blank; hnb is where cue had >0 intensity.';
        save([indir infile], 'data','todata', 'datadesc');

    case 'load'
        load([indir infile]);
        % hit rate
        newdata=data(:,1:2);
        makebargroups(newdata, clrset);
        set(gca,'XTickLabel', data(:,3), 'YTick',0:0.25:1,'YTickLabel',0:25:100);
        xl = get(gca,'XLim');
        line(xl, [50 50]/100,'LineStyle',':','LineWidth',2,'Color', [1 1 1]*0.4);
        ylabel('Average hit rate');
        axes__format(gca);
        set(gcf,'Position',[155   557   900   339]);
        
        % now TO
        newdata=todata(:,1:2);
        makebargroups(newdata, clrset);
        set(gca,'XTickLabel', todata(:,3)); %, 'YTick',0:0.25:1,'YTickLabel',0:25:100);
%        xl = get(gca,'XLim');
%        line(xl, [50 50]/100,'LineStyle',':','LineWidth',2,'Color', [1 1 1]*0.4);
        ylabel('TO count (average)');
        axes__format(gca);
        set(gcf,'Position',[155   557   900   339]);        
        
    otherwise
        error('invalid action');
end;


function [hhblank hhnonblank toblank tononblank] =sub__oneratdate(ratname, from,to)

data_fields={'tone_spl','pstruct'};
get_fields(ratname, 'from', from,'to',to, 'datafields', data_fields);

% load_datafile(ratname, indate);
task = rat_task_table(ratname); task=task{1,2};
%spl_list =saved.ChordSection_spl_list;
hh = hit_history; %eval(['saved.' task '_hit_history']);
n= numtrials; %eval(['saved.' task '_n_done_trials']);

to_count=NaN(size(pstruct));
for k=1:rows(pstruct)
    to_count(k)=rows(pstruct{k}.timeout);
end;

% figure;plot(spl_list,'.r');
spl_list=tone_spl;
blank=find(spl_list==0);
fprintf(1,'%s:(%s to %s):%i of %i blank\n', ratname, from,to,length(blank), length(spl_list));

nonblank = find(spl_list>0);
hhblank = hh(blank);
hhnonblank = hh(nonblank);
toblank = to_count(blank);
tononblank=to_count(nonblank);

fprintf(1,'Blank=%2.0f %%\n', round(mean(hhblank)*100));
fprintf(1,'Non-blank=%2.0f %%\n', round(mean(hhnonblank)*100));
fprintf(1,'TO count blank - %2.1f - and non-blank - %2.1f\n', mean(toblank), mean(tononblank));
