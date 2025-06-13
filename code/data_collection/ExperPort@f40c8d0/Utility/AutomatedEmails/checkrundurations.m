function output = checkrundurations(startdate,enddate,excludesundays,dsp,varargin)

if nargin < 1; startdate = yearmonthday; end
if nargin < 2; enddate   = yearmonthday; end
if nargin < 3; excludesundays = 0;       end
if nargin < 4; dsp            = 1;       end

allin = bdata('select initials from ratinfo.contacts where is_alumni=0');

numdays = ceil(datenum(enddate,'yymmdd') - datenum(startdate,'yymmdd')) + 2;

StartTime  = zeros(38,9,numdays); StartTime(:)  = nan;
EndTime    = zeros(38,9,numdays); EndTime(:)    = nan;
TotalTime  = zeros(38,9,numdays); TotalTime(:)  = nan;

WaterStart = zeros(38,9,numdays); WaterStart(:) = nan;
WaterEnd   = zeros(38,9,numdays); WaterEnd(:)   = nan;
WaterTotal = zeros(38,9,numdays); WaterTotal(:) = nan;
WaterBreak = zeros(38,9,numdays); WaterBreak(:) = nan;
WaterTech  = cell(38,9,numdays);

WeighTime  = zeros(38,9,numdays); WeighTime(:)  = nan;
WeighTech  = cell(38,9,numdays);

%TECH = cell(3,1,numdays);

dt = changedate(startdate,-2);

cnt = 0;
while strcmp(dt,enddate) == 0
    dt = changedate(dt,1);
    DT = datestr(datenum(dt,'yymmdd'),'yyyy-mm-dd');
    if dsp == 1; disp(['Analyzing: ',DT]); end
    
    [rigs,rats1,slots]    = bdata(['select rig, ratname, timeslot from ratinfo.schedule where date="',DT,'" and rig<91']);
    [STs,ETs,rats2]       = bdata(['select starttime, endtime, ratname from sessions where sessiondate="',DT,'"']);
    [Wst,Wet,rats3,WTech] = bdata(['select starttime, stoptime, rat, tech from ratinfo.water where date="',DT,'"']);
    [Mt,Mr,Mi]            = bdata(['select timeval, ratname, tech from ratinfo.mass where date="',DT,'"']);
    
    if excludesundays == 1 && strcmp(datestr(datenum(dt,'yymmdd'),'ddd'),'Sun'); 
        if dsp == 1; disp(['Skipping Sunday ',dt]); end 
        continue; 
    end

    cnt = cnt+1;

    for slot = 1:9
        for rig = 1:38  
            temp = slots == slot & rigs == rig;
            if sum(temp) == 0; continue; end
            ratname = rats1{temp};
            if isempty(ratname); continue; end
            
            temp = strcmp(Mr,ratname) == 1;
            if sum(temp) == 1
                wt = Mt{temp};
                wt = (str2num(wt(1:2)) * 3600) + (str2num(wt(4:5)) * 60) + str2num(wt(7:8)); %#ok<ST2NM>

                WeighTime(rig,slot,cnt) = wt;
                WeighTech{rig,slot,cnt} = Mi{temp};
            end
            
            temp = strcmp(rats2,ratname) == 1;
            if sum(temp) == 1
                Ts = STs{temp};
                Te = ETs{temp};

                d = timediff(Ts,Te,2);
                st = (str2num(Ts(1:2)) * 3600) + (str2num(Ts(4:5)) * 60) + str2num(Ts(7:8)); %#ok<ST2NM>
                et = (str2num(Te(1:2)) * 3600) + (str2num(Te(4:5)) * 60) + str2num(Te(7:8)); %#ok<ST2NM>

                StartTime(rig,slot,cnt) = st;
                EndTime(rig,slot,cnt)   = et;
                TotalTime(rig,slot,cnt) = d;
            end
            
            %if slot == 1 && isempty(TECH{1})
            %    tech = bdata(['select tech from ratinfo.mass where ratname="',ratname,'" and date="',DT,'"']);
            %    if ~isempty(tech) && ~isempty(tech{1}); TECH{1} = lower(tech{1}); end
            %elseif slot == 5 && isempty(TECH{2})
            %    tech = bdata(['select tech from ratinfo.mass where ratname="',ratname,'" and date="',DT,'"']);
            %    if ~isempty(tech) && ~isempty(tech{1}); TECH{2} = lower(tech{1}); end
            %elseif slot == 8 && isempty(TECH{3})
            %    tech = bdata(['select tech from ratinfo.mass where ratname="',ratname,'" and date="',DT,'"']);
            %    if ~isempty(tech) && ~isempty(tech{1}); TECH{3} = lower(tech{1}); end    
            %end
            
            temp = strcmp(rats3,ratname);
            if sum(temp) > 0
                Ws = Wst(temp); if length(Ws) > 1; Ws = findtime(Ws,'min'); else Ws = Ws{1}; end
                We = Wet(temp); if length(We) > 1; We = findtime(We,'max'); else We = We{1}; end

                if ~isempty(Ws) && ~isempty(We); 
                    d = timediff(Ws,We,2); if d < 0; d = d + (3600 * 24); end; 
                    wst = (str2num(Ws(1:2)) * 3600) + (str2num(Ws(4:5)) * 60) + str2num(Ws(7:8)); %#ok<ST2NM>
                    wet = (str2num(We(1:2)) * 3600) + (str2num(We(4:5)) * 60) + str2num(We(7:8)); %#ok<ST2NM>
                else
                    d = nan; wst = nan; wet = nan;
                end

                if isempty(d);     d = nan; end
                if isempty(wst); wst = nan; end
                if isempty(wet); wet = nan; end

                WaterStart(rig,slot,cnt) = wst;
                WaterEnd(  rig,slot,cnt) = wet;
                WaterTotal(rig,slot,cnt) = d;
                %WaterBreak(rig,slot,cnt) = wst - et;
                WaterTech{ rig,slot,cnt} = WTech{find(temp == 1,1,'first')}; 
            end
        end
    end
    
    if cnt == 1; continue; end
    
    medrundur = (nanmedian(TotalTime(:,:,cnt))) / 3600;
    
    et9 = sortrows(EndTime( :,9,cnt-1)); et9(isnan(et9)) = []; if numel(et9)>3; et9 = et9(4) / 3600; else et9=nan; end
    %ew2 = sortrows(WaterEnd(:,2,cnt));   ew2(isnan(ew2)) = []; if numel(ew2)>3; ew2 = ew2(end-4) / 3600; else ew2=nan; end
    ew3 = sortrows(WaterEnd(:,3,cnt));   ew3(isnan(ew3)) = []; if numel(ew3)>3; ew3 = ew3(end-4) / 3600; else ew3=nan; end
    output.A.rundur(cnt) = mean(medrundur(1:2));
    
    et3 = sortrows(EndTime(   :,3,cnt)); et3(isnan(et3)) = []; if numel(et3)>3; et3 = et3(4) / 3600; else et3=nan; end
    wt4 = sortrows(WeighTime( :,4,cnt)); wt4(isnan(wt4)) = []; if numel(wt4)>3; wt4 = wt4(4) / 3600; else wt4=nan; end
    ew5 = sortrows(WaterEnd(:,5,cnt));   ew5(isnan(ew5)) = []; if numel(ew5)>3; ew5 = ew5(end-4) / 3600; else ew5=nan; end
    output.B.rundur(cnt) = mean(medrundur(4:5));
    
    et6 = sortrows(EndTime( :,6,cnt));   et6(isnan(et6)) = []; if numel(et6)>3; et6 = et6(4) / 3600; else et6=nan; end
    wt7 = sortrows(WeighTime( :,7,cnt)); wt7(isnan(wt7)) = []; if numel(wt7)>3; wt7 = wt7(4) / 3600; else wt7=nan; end
    ew8 = sortrows(WaterEnd(:,8,cnt));   ew8(isnan(ew8)) = []; if numel(ew8)>3; ew8 = ew8(end-4) / 3600; else ew8=nan; end
    output.C.rundur(cnt) = mean(medrundur(7:8));
    
    output.A.day{cnt} = DT;
    output.B.day{cnt} = DT;
    output.C.day{cnt} = DT; 
    
    tech1 = {WaterTech{:,1,cnt},WaterTech{:,2,cnt},WeighTech{:,1,cnt},WeighTech{:,2,cnt},WeighTech{:,3,cnt}};
    tech2 = {WaterTech{:,4,cnt},WaterTech{:,5,cnt},WeighTech{:,4,cnt},WeighTech{:,5,cnt},WeighTech{:,6,cnt}};
    tech3 = {WaterTech{:,7,cnt},WaterTech{:,8,cnt},WeighTech{:,7,cnt},WeighTech{:,8,cnt},WeighTech{:,9,cnt}};
    
    for i = 1:numel(allin)
        for j = 1:3
            N(i,j) = sum(strcmp(eval(['tech',num2str(j)]),allin{i}));
        end
    end
    
    output.A.tech{cnt} = allin{find(N(:,1) == max(N(:,1)),1,'first')};
    output.B.tech{cnt} = allin{find(N(:,2) == max(N(:,2)),1,'first')};
    output.C.tech{cnt} = allin{find(N(:,3) == max(N(:,3)),1,'first')};
    
    noteA = bdata(['select timestr from ratinfo.technotes where datestr="',dt,'" and techinitials="',output.A.tech{cnt},'"']);
    noteB = bdata(['select timestr from ratinfo.technotes where datestr="',dt,'" and techinitials="',output.B.tech{cnt},'"']);
    noteC = bdata(['select timestr from ratinfo.technotes where datestr="',dt,'" and techinitials="',output.C.tech{cnt},'"']);
    
    if ~isempty(noteA); timeA = str2num(noteA{end}(1:2)) + (str2num(noteA{end}(4:5))/60); else timeA=0; end
    if ~isempty(noteB); timeB = str2num(noteB{end}(1:2)) + (str2num(noteB{end}(4:5))/60); else timeB=0; end
    if ~isempty(noteC); timeC = str2num(noteC{end}(1:2)) + (str2num(noteC{end}(4:5))/60); else timeC=0; end
    
    %dur1 = max([ew2,timeA]) + (24 - et9);
    dur1 = max([ew3,timeA]) + (24 - et9);
    output.A.length(cnt) = dur1;
    
    dur2 = max([ew5,timeB]) - min([et3,wt4]);
    output.B.length(cnt) = dur2;
    
    dur3 = max([ew8,timeC]) - min([et6,wt7]);
    output.C.length(cnt) = dur3;
    
    %if ew2 - ed3 > 2; endovernight = ed3; else endovernight =  max([ed3 ew2]); end
    %output.overnight.length(cnt) = endovernight - st1; %in hours
    
    %if ew5 - ed6 > 2; endmorning = ed6; else endmorning =  max([ed6 ew5]); end
    %output.morning.length(cnt) = endmorning - st4; %in hours
    
    %if ew8 - ed9 > 2; endevening = ed9; else endevening =  max([ed9 ew8]); end
    %output.evening.length(cnt) = endevening - st7; %in hours
    
    if dsp == 1; disp(['A ',num2str(dur1),' by ',output.A.tech{cnt}]); end
    if dsp == 1; disp(['B ',num2str(dur2),' by ',output.B.tech{cnt}]); end
    if dsp == 1; disp(['C ',num2str(dur3),' by ',output.C.tech{cnt}]); end
    
    %average_length = nanmedian(TotalTime) / 60; %in minutes
    
    %output.overnight.average(cnt) = nanmean(average_length(1:3));
    %output.morning.average(cnt)   = nanmean(average_length(4:6)); 
    %output.evening.average(cnt)   = nanmean(average_length(7:9));
    
    %clawback = zeros(size(StartTime,1),3); clawback(:) = nan;
    %clawback(:,1) = StartTime(:,2) - (StartTime(:,1) + 7200);
    %clawback(:,2) = StartTime(:,3) - (StartTime(:,2) + 7200);
    %clawback(:,3) = EndTime(:,3)   - (EndTime(:,2) + 7200);
    
    %output.overnight.clawback(cnt) = nanmedian(clawback(:)) / 60; %in minutes
    
    %clawback = zeros(size(StartTime,1),3); clawback(:) = nan;
    %clawback(:,1) = StartTime(:,5) - (StartTime(:,4) + 7200);
    %clawback(:,2) = StartTime(:,6) - (StartTime(:,5) + 7200);
    %clawback(:,3) = EndTime(:,6)   - (EndTime(:,5) + 7200);
    
    %output.morning.clawback(cnt) = nanmedian(clawback(:)) / 60; %in minutes
    
    %clawback = zeros(size(StartTime,1),3); clawback(:) = nan;
    %clawback(:,1) = StartTime(:,8) - (StartTime(:,7) + 7200);
    %clawback(:,2) = StartTime(:,9) - (StartTime(:,8) + 7200);
    %clawback(:,3) = EndTime(:,9)   - (EndTime(:,8) + 7200);
    
    %output.evening.clawback(cnt) = nanmedian(clawback(:)) / 60; %in minutes
    
    %output.overnight.water(cnt,:) = mode(WaterTotal(:,[1:2,9])) / 3600;
    %output.morning.water(cnt,:)   = mode(WaterTotal(:,3:5))     / 3600;
    %output.evening.water(cnt,:)   = mode(WaterTotal(:,6:8))     / 3600;
    
    %temp = WaterBreak(:,1) > 0;
    %if sum(temp) > 0; output.overnight.minbreak(cnt,1) = min(WaterBreak(temp,1)) / 60;
    %else              output.overnight.minbreak(cnt,1) = nan;
    %end
    
    %temp = WaterBreak(:,2) > 0;
    %if sum(temp) > 0; output.overnight.minbreak(cnt,2) = min(WaterBreak(temp,2)) / 60;
    %else              output.overnight.minbreak(cnt,2) = nan;
    %end
    
    %temp = WaterBreak(:,4) > 0;
    %if sum(temp) > 0; output.morning.minbreak(cnt,1) = min(WaterBreak(temp,4)) / 60;
    %else              output.morning.minbreak(cnt,1) = nan;
    %end
    
    %temp = WaterBreak(:,5) > 0;
    %if sum(temp) > 0; output.morning.minbreak(cnt,2) = min(WaterBreak(temp,5)) / 60;
    %else              output.morning.minbreak(cnt,2) = nan;
    %end
        
    %temp = WaterBreak(:,7) > 0;
    %if sum(temp) > 0; output.evening.minbreak(cnt,1) = min(WaterBreak(temp,7)) / 60;
    %else              output.evening.minbreak(cnt,1) = nan;
    %end
    
    %temp = WaterBreak(:,8) > 0;
    %if sum(temp) > 0; output.evening.minbreak(cnt,2) = min(WaterBreak(temp,8)) / 60;
    %else              output.evening.minbreak(cnt,2) = nan;
    %end
    
    %temp = WaterBreak(:,1:2);
    %temp = temp(:) / 60;
    %output.overnight.goodbreak(cnt) = sum(temp > 30) / sum(~isnan(temp));
    %output.overnight.badbreak(cnt)  = nanmedian(temp(temp < 30));
    
    %temp = WaterBreak(:,4:5);
    %temp = temp(:) / 60;
    %output.morning.goodbreak(cnt) = sum(temp > 30) / sum(~isnan(temp));
    %output.morning.badbreak(cnt)  = nanmedian(temp(temp < 30));
    
    %temp = WaterBreak(:,7:8);
    %temp = temp(:) / 60;
    %output.evening.goodbreak(cnt) = sum(temp > 30) / sum(~isnan(temp));
    %output.evening.badbreak(cnt)  = nanmedian(temp(temp < 30));
    
    %output.morning.freewater{cnt} = '';
    %freewatertemp = cell(0);
    %for r = 1:length(rats3)
    %    if sum(strcmp(rats1,rats3{r})) == 0 && strcmp(Wst{r},Wet{r}) == 1 && ~strcmp(rats3{r},' ')
    %        %This is a free water rat that was confirmed via WaterMeister
    %        freewatertemp{end+1} = lower(WTech{r}); %#ok<AGROW>
    %        %output.morning.freewater{cnt} = WTech{r};
    %    end
    %end
    %UFW = unique(freewatertemp);
    %if length(UFW) == 1;                        output.morning.freewater{cnt} = UFW{1}; 
    %elseif sum(strcmp(UFW,lower(TECH{1}))) > 0; output.morning.freewater{cnt} = lower(TECH{1}); %#ok<STCI>
    %else                                        output.morning.freewater{cnt} = UFW;
    %end
    %output.evening.freewater{cnt} = '';
    %output.overnight.freewater{cnt} = '';
    
    TECH{1} = output.A.tech{end};
    TECH{2} = output.B.tech{end};
    TECH{3} = output.C.tech{end};
    
    for i = 1:3
        if ~isfield(output,TECH{i})
            clear temp;
            temp.day       = cell(0);
            temp.length    = [];
            temp.rundur    = [];
            %temp.average   = [];
            %temp.clawback  = [];
            %temp.water     = [];
            %temp.minbreak  = [];
            %temp.goodbreak = [];
            %temp.badbreak  = [];
            %temp.freewater = cell(0);
            %temp.totalmornings = 0;
            %temp.freeconfirms  = 0;
            if ~isempty(TECH{i}); eval(['output.',TECH{i},' = temp;']); end
        end
    end
    
    
    for i = 1:3
        if     i == 1; sh = 'A';
        elseif i == 2; sh = 'B';
        else           sh = 'C';
        end
        
        if ~isempty(TECH{i});
            eval(['output.',TECH{i},'.day{end+1}        = [output.',sh,'.day{cnt},sh];']);
            eval(['output.',TECH{i},'.length(end+1)     = output.',sh,'.length(cnt);']);
            eval(['output.',TECH{i},'.rundur(end+1)     = output.',sh,'.rundur(cnt);']);
            %eval(['output.',TECH{i},'.average(end+1)    = output.',sh,'.average(cnt);']);
            %eval(['output.',TECH{i},'.clawback(end+1)   = output.',sh,'.clawback(cnt);']);
            %eval(['output.',TECH{i},'.water(end+1,:)  = output.',sh,'.water(cnt,:);']);
            %eval(['output.',TECH{i},'.minbreak(end+1,:) = output.',sh,'.minbreak(cnt,:);']);
            %eval(['output.',TECH{i},'.goodbreak(end+1)  = output.',sh,'.goodbreak(cnt);']);
            %eval(['output.',TECH{i},'.badbreak(end+1)   = output.',sh,'.badbreak(cnt);']);
            %eval(['output.',TECH{i},'.freewater{end+1}  = output.',sh,'.freewater{cnt};']);
        end
    end
end

%for i = 1:length(output.morning.tech)
%    if isempty(output.morning.tech{i}); continue; end
%    eval(['output.',output.morning.tech{i},'.totalmornings = output.',output.morning.tech{i},'.totalmornings + 1;']);
%    if sum(strcmp(output.morning.tech{i},output.morning.freewater{i}))>0
%       eval(['output.',output.morning.tech{i},'.freeconfirms = output.',output.morning.tech{i},'.freeconfirms + 1;']);
%    end
%end





function T = findtime(times,fun)

for i = 1:length(times)
    t(i) = datenum(times{i},'hh:mm:ss'); %#ok<NASGU,AGROW>
end

str = 'first'; %#ok<NASGU>
T = eval(['times{find(t == ',fun,'(t),1,str)}']);

