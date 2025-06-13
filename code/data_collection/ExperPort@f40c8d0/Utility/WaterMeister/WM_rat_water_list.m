function currrats = WM_rat_water_list(session,handles,output_type,day,lookforward,ratrig,varargin)

if nargin < 3; output_type = 'regular'; end
if nargin < 4; day = datestr(now,'yyyy-mm-dd'); end
if nargin < 5; lookforward = 0; end

if nargin < 6;
    if isfield(handles,'ratrig'); ratrig = handles.ratrig;
    else ratrig = bSettings('get','RIGS','ratrig');
    end
    if isnan(ratrig); ratrig = 1; end
end

[RatSch,rigs,timeslots] = bdata(['select ratname, rig, timeslot from ratinfo.schedule where date="',day,'"']);
if ratrig < 2
    [RatReg,forcedeps,forcefrees,cagemates] = bdata(['select ratname, forcedepwater, forcefreewater, cagemate from ratinfo.rats where extant=1 and israt=',num2str(ratrig)]);
else
    [RatReg,forcedeps,forcefrees,cagemates] = bdata('select ratname, forcedepwater, forcefreewater, cagemate from ratinfo.rats where extant=1');
end
    
CompRats = bdata(['select ratname from ratinfo.rigwater where dateval="',datestr(now,'yyyy-mm-dd'),'" and complete=1']);
    
%Remove rats from the schedule and completed lists depending on if it's a
%rat rig and they're mice, or it's a mouse rig and they're rats.
remSch = [];
for i = 1:numel(RatSch)
    if sum(strcmp(RatSch{i},RatReg)) == 0
        remSch(end+1) = i; %#ok<AGROW>
    end
end
RatSch(remSch)    = [];
rigs(remSch)      = []; %#ok<NASGU>
timeslots(remSch) = [];

remComp = [];
for i = 1:numel(CompRats)
    if sum(strcmp(CompRats{i},RatReg)) == 0
        remComp(end+1) = i; %#ok<AGROW>
    end
end
CompRats(remComp) = [];


for s = 1:10
    R = cell(0);
    C = [];
    if s < 10
        R = RatSch(timeslots == s); R(strcmp(R,'')) = [];
        fd = RatReg(forcedeps == s);
        R(end+1:end+length(fd)) = fd;
    elseif s == 10
        R = RatReg(forcefrees == 1);
        nd = RatReg(forcedeps == 0);
        temp = nd(~ismember(nd,RatSch));
        R(end+1:end+length(temp)) = temp;        
    end
        
    R = R(:); % Make R into a column if it isn't already (This line is a bug-fix by Kevin on 7/25/2013)
    
    for r = 1:length(R)
        temp = strcmp(RatReg,R{r,1});
        if sum(temp) ~= 0; R{r,2} = cagemates{temp};
        else               R{r,2} = '';
        end
        R(r,:) = sortrows(R(r,:)');
    end
    
    if ~isempty(R)
        R = sortrows(R,2);
        duprats = [];
        for r = 1:size(R,1)-1
            if strcmp(R{r,2},R{r+1,2}); duprats(end+1) = r; end %#ok<AGROW>
        end
        R(duprats,:) = [];
        C = zeros(size(R,1),1);
        
        %Let's remove any rats that have earned all their water in the rig
        comp = zeros(size(R));
        for r = 1:numel(R)
            if sum(strcmp(CompRats,R{r})) > 0; comp(r) = 1; end
        end
        for i = 1:size(R,1)
            if     (~isempty(R{i,1}) && ~isempty(R{i,2})) && sum(comp(i,:)) < 2; comp(i,:) = 0;
            elseif ( isempty(R{i,1}) && ~isempty(R{i,2})) && sum(comp(i,:)) > 0; comp(i,:) = 1;
            end
        end
        
        %Turn this line on to simply erase completed rats
        %R(sum(comp,2)==2,:) = [];
        C(sum(comp,2)==2) = 1;
    else
        R = cell(0,2);
        
    end
    
    RatList{s} = R; %#ok<AGROW>
    CompList{s} = C; %#ok<AGROW>
end

for s = 8:-1:1
    duprats = [];
    for r = 1:size(RatList{s},1)
        for p = 9:-1:s+1
            if ~isempty(RatList{p}) && sum(strcmp(RatList{p}(:,2),RatList{s}{r,2})) > 0; duprats(end+1)=r; end %#ok<AGROW>
        end
    end
    RatList{s}(duprats,:) = []; 
    CompList{s}(duprats)  = [];
end

duprats = [];
for r = 1:size(RatList{10},1)
    for p = 1:9
        if sum(strcmp(RatList{p}(:,2),RatList{10}{r,2})) > 0; duprats(end+1)=r; end %#ok<AGROW>
    end
end
RatList{10}(duprats,:) = [];
CompList{10}(duprats)  = [];

for s = 1:10
    badrat = [];
    for r = 1:size(RatList{s},1)
        if (~isempty(RatList{s}{r,1}) && ~isempty(str2num(RatList{s}{r,1}))) ||...
           (~isempty(RatList{s}{r,2}) && ~isempty(str2num(RatList{s}{r,2})))    %#ok<ST2NM>
            badrat(end+1) = r; %#ok<AGROW>
        end
        if ~isempty(RatList{s}{r,1}) 
            if     length(RatList{s}{r,1}) ~= 4;       badrat(end+1) = r; %#ok<AGROW>
            elseif strcmp(RatList{s}{r,1}(1)  ,'0');   badrat(end+1) = r; %#ok<AGROW>
            elseif strcmp(RatList{s}{r,1}(1:3),'sen'); badrat(end+1) = r; %#ok<AGROW>
            end
        end
        if ~isempty(RatList{s}{r,2}) 
            if     length(RatList{s}{r,2}) ~= 4;       badrat(end+1) = r; %#ok<AGROW>
            elseif strcmp(RatList{s}{r,2}(1)  ,'0');   badrat(end+1) = r; %#ok<AGROW>
            elseif strcmp(RatList{s}{r,2}(1:3),'sen'); badrat(end+1) = r; %#ok<AGROW>
            end
        end
    end
    RatList{s}(badrat,:) = []; %#ok<AGROW>
    CompList{s}(badrat)  = []; %#ok<AGROW>
end
for s = 1:10
    if isempty(RatList{s}); 
        RatList{s} = cell(0,2);  %#ok<AGROW>
        CompList{s} = []; %#ok<AGROW>
    end
end

if lookforward == 1
    WL2 = WM_rat_water_list(0,0,'all',datestr(now+1,'yyyy-mm-dd'),0,ratrig);
    
    for i = 3:numel(WL2)-1
        earlyrats = cell(0,2);
        for j = 1:i-2
            if ~isempty(RatList{j})
                earlyrats(end+1:end+size(RatList{j},1),:) = RatList{j};
            end
        end
        earlyrats = earlyrats(:);
        earlyrats(strcmp(earlyrats,'')) = [];
        earlyrats = sortrows(earlyrats);

        tomorrow = WL2{i}(:);
        tomorrow(strcmp(tomorrow,'')) = [];
        tomorrow = sortrows(tomorrow);

        extrawater = cell(0);
        for j = 1:numel(tomorrow)
            if sum(strcmp(earlyrats,tomorrow{j})) > 0
                extrawater{end+1} = tomorrow{j}; %#ok<AGROW>
            end
        end

        for j = 1:numel(extrawater)
            cm = cagemates{strcmp(RatReg,extrawater{j})};
            RatList{i}(end+1,:) = sortrows({extrawater{j},cm}'); %#ok<AGROW>
            CompList{i}(end+1,:) = 0; %#ok<AGROW>
        end
        
        if ~isempty(RatList{i}); 
            [RatList{i},order] = sortrows(RatList{i},2);  %#ok<AGROW>
            CompList{i} = CompList{i}(order); %#ok<AGROW>
        
        end 
    end
end

for s = 1:10
    duprats = [];
    ratlist = RatList{s};
    for r = 1:size(ratlist,1)-1
        if strcmp(ratlist{r,2},ratlist{r+1,2}); duprats(end+1) = r; end %#ok<AGROW>
    end
    ratlist(duprats,:) = [];
    RatList{s} = ratlist; %#ok<AGROW>
    CompList{s}(duprats) = []; %#ok<AGROW>
end

currrats = cell(0);
currcomp = [];
for s = session
    if s == 0; break; end
    currrats(end+1:end+size(RatList{s},1),:) = RatList{s};
    currcomp(end+1:end+size(CompList{s},1),:)= CompList{s};
    if strcmp(output_type,'regular'); 
        WM_ratsheet(RatList{s},handles,CompList{s}); 
    end
end

currrats = unique(currrats(:));
if isempty(currrats) || isempty(currrats(1)); currrats{1} = []; end

if strcmp(output_type,'all'); currrats = RatList; end


