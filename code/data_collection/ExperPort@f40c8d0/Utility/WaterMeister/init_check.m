function handles = init_check(handles)

global comp

GUI = 1;
if isempty(handles); GUI = 0; end

if GUI == 1; oldname = get(gcf,'name');
             set(gcf,'name','Updating');
             pause(0.1);
end

handles.starttime = zeros(1,10); handles.starttime(:) = nan;
handles.stoptime  = handles.starttime;
handles.start     = zeros(1,10);
comp              = zeros(1,10);

if ~isfield(handles,'waittime')
    try load('C:\ratter\ExperPort\Utility\WaterMeister\waittimes.mat'); %#ok<LOAD>
    catch; WT = [3600 3600 3600 3600 3600 3600 3600 3600 3600 1]; %#ok<CTCH>
    end
    handles.waittime = WT;
end

if GUI == 1; RatList = WM_rat_water_list(1,handles,'all',datestr(now,'yyyy-mm-dd'),1);
else         RatList = WM_rat_water_list(0,0,      'all',datestr(now,'yyyy-mm-dd'),1);
end

date_temp = datestr(now,'yyyy-mm-dd');    

[all_rats, all_strt, all_stop]=bdata(['select rat, starttime, stoptime from ratinfo.water where date = "',date_temp,'" order by watering']); 
[yes_rats, yes_strt, yes_stop]=bdata(['select rat, starttime, stoptime from ratinfo.water where date = "',datestr(now-1,'yyyy-mm-dd'),'"']);

for s = 1:10
    if GUI == 1
        if s < 10
            disp(['Importing Data for Session ',num2str(s),'...']);
        else
            disp('Importing Data for Free Water Rats...');
        end
    end
    ratnames = unique(RatList{s}(:));
    ratnames(strcmp(ratnames,'')) = [];
    
    STRT = cell(0); STP = cell(0);
    for r = 1:length(ratnames)
        if sum(strcmp(all_rats,ratnames{r})) > 0
            STRT{r} = all_strt{find(strcmp(all_rats,ratnames{r})==1,1,'last')};
            STP{r}  = all_stop{find(strcmp(all_rats,ratnames{r})==1,1,'last')};
        else
            STRT{r} = '';
            STP{r}  = '';
        end
    end
    
    strt = unique(STRT);
    stp  = unique(STP);
    
    %strt(strcmp(strt,'')) = [];
    %stp( strcmp(stp, '')) = [];
    
    if length(strt) > 1
        S = [];
        for i=1:length(strt)
            S(i)=sum(strcmp(STRT,strt{i})); %#ok<AGROW>
        end
        con_strt = strt{find(S == max(S),1,'first')};
    end
    
    if length(stp) > 1
        S = [];
        for i=1:length(stp)
            S(i)=sum(strcmp(STP,stp{i})); %#ok<AGROW>
        end
        con_stp = stp{find(S == max(S),1,'first')};
    end
    
    
    if length(strt) == 1 && ~isempty(strt{1})
        handles.starttime(s) = datenum([date_temp,' ',strt{1}]);
    elseif length(strt) > 1 && ~isempty(con_strt)
        handles.starttime(s) = datenum([date_temp,' ',con_strt]);
    end
    handles.stoptime(s) = handles.starttime(s) + (handles.waittime(s) / (3600 * 24));
    
    gettingwater = 0;
    if length(stp) == 1 && ~isempty(stp{1}) && strcmp(strt{1},stp{1})
        %It appears the rats are currently being watered so it's not yet
        %completed.
        gettingwater = 1;
        wt = (datenum(datestr(now,'HH:MM:SS'),'HH:MM:SS') - datenum(strt{1},'HH:MM:SS')) * 24;
        if GUI == 1; disp(['Getting watered for ',num2str(wt),' hours.']); end
        
    elseif length(stp) == 1 && ~isempty(stp{1}) && ~strcmp(strt{1},stp{1})
        %There is one stop time for this group of rats, it's not empty, and
        %the start and stop time aren't the same if so mark complete
        
        %Free water rats will have a stop time of 23:59:00 if they are
        %confirmed for one day only
        comp(s) = 1;
        
    elseif length(strt) > 1 && ~isempty(con_strt) && length(stp) > 1 && ~isempty(con_stp) && ~strcmp(con_strt,con_stp)
        %consensus start and stop are not the same, session watered
        comp(s) = 1;
        
    elseif length(strt) == 1 && length(stp) > 1 && ~isempty(con_stp) && ~strcmp(strt{1},con_stp)
        %one start time, multiple stop times, but consensus stop not same
        %as start, session watered
        comp(s) = 1;
        
    elseif length(strt) > 1 && ~isempty(con_strt) && length(stp) == 1 && ~strcmp(con_strt,stp{1})
        %multiple start times, one stop time, but consensus start not same
        %as stop, session watered
        comp(s) = 1;
        
    elseif length(stp) > 1 && ~isempty(con_stp)
        
        %comp(s) = 1;
    end 
    
    %If the session is not completed but it got water with the past 8
    %hours it should continue to be marked as completed
    %Free water rats stay completed for only 3 hours
    if gettingwater == 1
        comp(s) = 0;
        
    elseif comp(s) == 0 && ~isempty(ratnames)
        STP = cell(0);
        for r = 1:length(ratnames)
            if sum(strcmp(yes_rats,ratnames{r})) > 0
                STP{r} = yes_stop{find(strcmp(yes_rats,ratnames{r})==1,1,'first')};
            else
                STP{r}  = '';
            end
        end
        stp  = unique(STP);    
        if isempty(stp); continue; end
        
        for i = 1:length(stp)
            try    lastwater(i) = (now - datenum([datestr(now-1,'yyyy-mm-dd'),' ',stp{i}],'yyyy-mm-dd HH:MM:SS')) * 24; %#ok<AGROW>
            catch; lastwater(i) = 24; %#ok<CTCH,AGROW>
            end
        end
        lastwater = max(lastwater);
        
        if GUI == 1; disp(['Last watered ',num2str(lastwater),' hours ago.']); end
        if ~isempty(stp) && lastwater < 8 && s ~= 10
            comp(s) = 1;
        elseif ~isempty(stp) && lastwater < 3 && s == 10
            comp(s) = 1;
        end
    else
        comp(s) = 1;
    end
    
    if GUI == 1
        str1 = 'BackgroundColor'; %#ok<NASGU>
        if comp(s) == 1
            eval(['set(handles.session',num2str(s),'_toggle,str1,[0 1 1]);']);
        elseif ~isnan(handles.starttime(s))
            eval(['set(handles.session',num2str(s),'_toggle,str1,[1 1 0]);']);
            handles.start(s) = 1;
        else
            eval(['set(handles.session',num2str(s),'_toggle,str1,[1 1 1]);']);
        end
    end
end

if GUI == 1
    set(handles.date_text,'string',datestr(now,29));
    handles.lastupdate = now;

    set(gcf,'name',oldname);
else
    handles.comp = comp;
end
