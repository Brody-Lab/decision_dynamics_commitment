function rat_bringup_list(session,displaytype,day,varargin)

try
    
    if     strcmp(datestr(now,'ddd'),'Mon'); dayltr = 'm';
    elseif strcmp(datestr(now,'ddd'),'Tue'); dayltr = 't';
    elseif strcmp(datestr(now,'ddd'),'Wed'); dayltr = 'w';
    elseif strcmp(datestr(now,'ddd'),'Thu'); dayltr = 'r';
    elseif strcmp(datestr(now,'ddd'),'Fri'); dayltr = 'f';
    elseif strcmp(datestr(now,'ddd'),'Sat'); dayltr = 's';
    else   strcmp(datestr(now,'ddd'),'Sun'); dayltr = 'u';
    end
    
    if nargin < 1; session     = 1:9;     end
    if nargin < 2; displaytype = 'print'; end
    if nargin < 3; day         = floor(now);     end

    [RatSch1,SesSch1] = bdata(['select ratname, timeslot from ratinfo.schedule where date="',datestr(day,29),  '"']);
    [RatReg,bringupats,bringupday,cagemates,recovering,forcedep] = bdata('select ratname, bringupat, bringupday, cagemate, recovering, forceDepWater from ratinfo.rats where extant=1');    

    bringupats(bringupats == 0) = nan;

    emptyslots = strcmp(RatSch1,'');
    RatSch1(emptyslots == 1) = [];
    SesSch1(emptyslots == 1) = [];
    
    recovrats = cell(0,2);
    for r = 1:length(RatReg)
        if recovering(r) == 1
            %This is a recovering rat
            cm = cagemates{r};
            if sum(strcmp(RatSch1,RatReg{r})) == 0
                %He is not training
                if isempty(cm) || sum(strcmp(RatSch1,cm)) == 0  
                    %He doesn't have a cagemate or his cagemate isn't training
                    recovrats(end+1,:) = {RatReg{r},cm}; %#ok<AGROW>
                    recovrats(end,:) = sortrows(recovrats(end,:)');
                end
            end
        end
    end
    recovrats = sortrows(recovrats,2);
    recovrats = remove_duprats(recovrats);
    

    for s = 1:9
        %RT is the list of training rats
        RT = RatSch1(SesSch1 == s);
        for r = 1:length(RT)
            temp1 = strcmp(RatReg,RT{r,1});
            if sum(temp1 > 0); cm = cagemates{strcmp(RatReg,RT{r,1})}; else cm = ''; end
            if ~isempty(cm); RT{r,2} = cm;
            else             RT{r,2} = '';
            end
            RT(r,:) = sortrows(RT(r,:)');
        end
        if ~isempty(RT)
            RT = sortrows(RT,2);
            RT = remove_duprats(RT);
        else
            RT = cell(0,2);
        end
        
        %RN is the list of non-training rats
        RN = cell(0,2);
        temp = RatReg(forcedep == s);
        RN(end+1:end+length(temp),1) = temp;
        
        %if ~strcmp(datestr(now,'ddd'),'Sat') && ~strcmp(datestr(now,'ddd'),'Sun')
            temp = RatReg(    bringupats == s);
            days = bringupday(bringupats == s);
            
            for i = 1:size(temp,1)
                if (isempty(days{i}) && (~strcmp(datestr(now,'ddd'),'Sat') && ~strcmp(datestr(now,'ddd'),'Sun'))) ||...
                    ~isempty(strfind(lower(days{i}),dayltr))
                    RN(end+1,1) = temp(i);
                end
            end
                    
                    
        %end
        for r = 1:size(RN,1)
            cm = cagemates{strcmp(RatReg,RN{r,1})};
            if ~isempty(cm); RN{r,2} = cm;
            else             RN{r,2} = '';
            end
            RN(r,:) = sortrows(RN(r,:)');
        end
        if s == 5
            %add nontraining recovering rats to bringup list 5
            RN(end+1:end+size(recovrats,1),:) = recovrats;
        end
        
        RN = sortrows(RN,2);    
        RN = remove_duprats(RN);
        
        duprats = [];
        for r = 1:size(RN,1)
            if sum(strcmp(RT(:,2),RN{r,2})) > 0; duprats(end+1) = r; end %#ok<AGROW>
        end
        RN(duprats,:) = [];

        RatList{s} = [RT; RN]; %#ok<AGROW>
        LastTraining(s) = size(RT,1); %#ok<AGROW>
    end

    for s = 2:9
        duprats = [];
        for r = 1:size(RatList{s},1)
            for p = 1:s-1
                if sum(strcmp(RatList{p}(:,2),RatList{s}{r,2})) > 0; duprats(end+1)=r; end %#ok<AGROW>
            end
        end
        RatList{s}(duprats,:) = []; %#ok<AGROW>
        LastTraining(s) = LastTraining(s) - sum(duprats <= LastTraining(s));     %#ok<AGROW>
    end

    if floor(now) == day; WaterList = WM_rat_water_list(0,0,'all',datestr(now,'yyyy-mm-dd'),1);
    else                  WaterList = WM_rat_water_list(0,0,'all',datestr(day,'yyyy-mm-dd'),0);
    end
    
    if numel(WaterList) == 7
        WaterList{10} = WaterList{7};
        WaterList{7} = cell(0,2);
        WaterList{8} = cell(0,2);
        WaterList{9} = cell(0,2);
    end
    WL = cell(0); RL = cell(0);
    for i = 1:9
        WL(end+1:end+size(WaterList{i},1),:) = WaterList{i};
        RL(end+1:end+size(RatList{i},  1),:) = RatList{i};
    end
    WL = WL(:); RL = RL(:);
    RL(strcmp(RL,'')) = [];
    WL(strcmp(WL,'')) = [];

    %Find rats that are to be watered but are not so far on the bringuplist
    %meaning they and or their cage mate does not train and is not
    %specified to be brought up.
    missingrats = WL(~ismember(WL,RL));
    for s = 1:9
        for i = 1:length(missingrats)
            if sum(strcmp(WaterList{s}(:),missingrats{i})) > 0
                try %#ok<TRYNC>
                    cm = cagemates{strcmp(RatReg,missingrats{i})};
                    temp = sortrows({missingrats{i};cm})';

                    RatList{s}(end+1,:) = temp; %#ok<AGROW>
                end
            end
        end
        RT = RatList{s}(1:LastTraining(s),:);
        
        RN = RatList{s}(LastTraining(s)+1:end,:);
        RN = sortrows(RN,2);
        RN = remove_duprats(RN);
        
        duprats = [];
        for r = 1:size(RN,1)
            if sum(strcmp(RT(:,2),RN{r,2})) > 0; duprats(end+1) = r; end %#ok<AGROW>
        end
        RN(duprats,:) = [];

        RatList{s} = [RT; RN]; %#ok<AGROW>
    end
    
    %Find rats that are on the watering list twice and make sure they're on
    %both appropriate bringuplists
    for s = 2:9
        waterearly = cell(0);
        for i = 1:s-1
            x = WaterList{i}(:);
            x(strcmp(x,'')) = [];
            waterearly(end+1:end+numel(x),1) = x;
        end
        waternow = WaterList{s}(:);
        waternow(strcmp(waternow,'')) = [];
        
        extra = cell(0);
        for i = 1:numel(waternow)
            if sum(strcmp(waterearly,waternow{i})) > 0
                extra{end+1} = waternow{i}; %#ok<AGROW>
            end
        end
        
        for i = 1:numel(extra)
            cm = cagemates{strcmp(RatReg,extra{i})};
            RatList{s}(end+1,:) = sortrows({extra{i},cm}'); %#ok<AGROW>
        end
        
        if ~isempty(RatList{s})
            if size(RatList{s},1) > LastTraining(s)
                temp = RatList{s}(LastTraining(s)+1:end,:);
                temp = sortrows(temp,2);
                RatList{s}(LastTraining(s)+1:end,:) = temp; %#ok<AGROW>
            end
        end
            
    end
    
    for s = 1:9
        RatList{s} = remove_duprats(RatList{s}); %#ok<AGROW>
    end
    
    %Now we loop through the requested session and draw the sheets
    for s = session
        F = ratsheet(RatList{s},s,LastTraining(s),day);
        for f = F
            figure(f);
            if strcmp(displaytype,'print')
                orient landscape
                pause(0.1);
                print;
                pause(0.1);
                close(f);
            else
                x = get(0,'MonitorPosition');
                set(gcf,'position',x);
                C = get(gca,'children');
                for c = 1:length(C)
                    try set(C(c),'fontsize',40); end %#ok<TRYNC>
                end
            end
        end
    end
catch %#ok<CTCH>
    senderror_report;
end



function ratlist = remove_duprats(ratlist)

duprats = [];
for r = 1:size(ratlist,1)-1
    if strcmp(ratlist{r,2},ratlist{r+1,2}); duprats(end+1) = r; end %#ok<AGROW>
end
ratlist(duprats,:) = [];


