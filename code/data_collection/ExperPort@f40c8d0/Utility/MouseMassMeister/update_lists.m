function handles = update_lists(handles,pos,varargin)

if nargin < 2; pos = 1; end

GUI = 1;
if isempty(handles); GUI = 0; end

if GUI == 1; handles = get_newrats(handles); end
if GUI == 1; handles = get_movedrats(handles); end

if     strcmp(datestr(now,'ddd'),'Mon'); dayltr = 'm';
elseif strcmp(datestr(now,'ddd'),'Tue'); dayltr = 't';
elseif strcmp(datestr(now,'ddd'),'Wed'); dayltr = 'w';
elseif strcmp(datestr(now,'ddd'),'Thu'); dayltr = 'r';
elseif strcmp(datestr(now,'ddd'),'Fri'); dayltr = 'f';
elseif strcmp(datestr(now,'ddd'),'Sat'); dayltr = 's';
else   strcmp(datestr(now,'ddd'),'Sun'); dayltr = 'u';
end
    
try
    [ratsR recov cagemate forcedep bringup bringupday] = bdata('select ratname, recovering, cagemate, forceDepWater, bringUpAt, bringupday from ratinfo.rats where extant=1');
    [ratsS slot] = bdata(['select ratname, timeslot from ratinfo.schedule where date="',datestr(now,29),'"']);
catch %#ok<CTCH>
    handles.mass = cell(8,1);
    handles.rats = cell(8,1);
    set(handles.status_text,'string','ERROR: Unable to connect to network.',...
        'backgroundcolor',[1 0 0]);
    return;
end
    
emptyslots = strcmp(ratsS,'');
ratsS(emptyslots) = [];
slot(emptyslots) = [];

%These are the sessions rats get watered in
WaterList = WM_rat_water_list(0,0,'all',datestr(now,'yyyy-mm-dd'),1);
    
for s = 1:9
    %R1 is the list of training rats
    R1 = ratsS(slot == s);
    for r = 1:length(R1)
        temp1 = strcmp(ratsR,R1{r,1});
        if sum(temp1 > 0); temp = cagemate{strcmp(ratsR,R1{r,1})}; else temp = ''; end
        if ~isempty(temp); R1{r,2} = temp;
        else               R1{r,2} = '';
        end
        R1(r,:) = sortrows(R1(r,:)');
    end
    if ~isempty(R1)
        R1 = sortrows(R1,2);
        duprats = [];
        for r = 1:size(R1,1)-1
            if strcmp(R1{r,2},R1{r+1,2}); duprats(end+1) = r; end %#ok<AGROW>
        end
        R1(duprats,:) = [];
    end
    
    %R2 is the list of rats with bring up times
    R2 = cell(0,2);
    %if ~strcmp(datestr(now,'ddd'),'Sat') && ~strcmp(datestr(now,'ddd'),'Sun')
        temp = ratsR(     bringup == s);
        days = bringupday(bringup == s);
        %Let's remove any rats that are free water and not recovering
        remove = [];
        for i = 1:length(temp)
            temp2 = find(strcmp(ratsR,temp{i})==1,1,'first');
            if ~isempty(temp2) && recov(temp2)==0 && forcedep(temp2)==0
                remove(end+1) = i; %#ok<AGROW>
            end
        end
        temp(remove) = [];   
        days(remove) = [];
        
        %Let's remove any rats who have a specified bring up day that is
        %not today
        remove = [];
        for i = 1:length(temp)
            if (~isempty(days{i}) && isempty(strfind(lower(days{i}),dayltr))) ||...
               ( isempty(days{i}) && (strcmp(datestr(now,'ddd'),'Sat') || strcmp(datestr(now,'ddd'),'Sun')))   
                remove(end+1) = i; %#ok<AGROW>
            end
        end
        temp(remove) = [];
        
        R2(end+1:end+length(temp),1) = temp;
    %end
    for r = 1:size(R2,1)
        temp = cagemate{strcmp(ratsR,R2{r,1})};
        if ~isempty(temp); R2{r,2} = temp;
        else               R2{r,2} = '';
        end
        R2(r,:) = sortrows(R2(r,:)');
    end

    %Let's remove any duplicate entries from this list
    R2 = sortrows(R2,2);    
    duprats = [];
    for r = 1:size(R2,1)-1
        if strcmp(R2{r,2},R2{r+1,2}); duprats(end+1) = r; end %#ok<AGROW>
    end
    R2(duprats,:) = [];
    
    %Let's combine the lists and remove any duplicate entries
    R3 = [R1; R2; WaterList{s}];
    R3 = sortrows(R3,2);    
    duprats = [];
    for r = 1:size(R3,1)-1
        if strcmp(R3{r,2},R3{r+1,2}); duprats(end+1) = r; end %#ok<AGROW>
    end
    R3(duprats,:) = [];

    %We no longer care about cage assignments so let's discard that info
    %and throw away any '' entries
    R3 = R3(:);
    R3(strcmp(R3,'')) = [];
    R3 = sortrows(R3);
    
    RatList{s} = R3; %#ok<AGROW>
end

%Let's add in the recovering rats at the end of the list
recovrats = ratsR(recov == 1);
RatList{10} = sortrows(recovrats);

%Let's delete all the duplicate entries from the later session
for s = 2:10
    duprats = [];
    for r = 1:size(RatList{s},1)
        for p = 1:s-1
            if sum(strcmp(RatList{p},RatList{s}{r})) > 0; duprats(end+1)=r; end %#ok<AGROW>
        end
    end
    RatList{s}(duprats) = []; %#ok<AGROW>
end

%The last group is all the extant rats;
RatList{11} = sortrows(ratsR);
handles.rats = RatList;


%Now let's get the weights for the rats
[ratM mass] = bdata(['select ratname, mass from ratinfo.mass where date="',datestr(now,29),'" order by weighing desc']);

handles.mass     = cell(0);
handles.masscomp = cell(0);
for i = 1:length(RatList);
    handles.masscomp{i} = zeros(1,numel(RatList{i}));
    for j = 1:length(RatList{i})
        temp = strcmp(ratM,RatList{i}{j});
            
        if GUI == 1
            if (sum(temp) > 0 && get(handles.session_list,'value') ~= 11 && mass(find(temp == 1,1,'first')) ~= 0 ) ||...
               (sum(temp) > 0 && get(handles.session_list,'value') == 11)  
                %We only display the mass if it's not 0 for sessions 1-9 and
                %recovery rats. 0 will be displayed in All Rats list since that
                %includes free water
                handles.mass{i}{j} = num2str(mass(find(temp == 1,1,'first')));
                handles.masscomp{i}(j) = 1;
            else
                x = find(strcmp(handles.movedrats,RatList{i}{j})==1,1,'first');

                if GUI == 1 && ~isempty(x)
                    %If the rat has been moved from a different tower notify tech
                    if handles.movedfrom(x) == 10
                        handles.mass{i}{j} = ['T FW'];
                    else
                        handles.mass{i}{j} = ['T ',num2str(handles.movedfrom(x))];
                    end
                elseif GUI == 1 && sum(strcmp(handles.newrats,RatList{i}{j})) > 0
                    %If the rat is on the new rat list notify the tech
                    handles.mass{i}{j} = 'New!!';
                else
                    handles.mass{i}{j} = '';
                end
            end
        else
            if sum(temp) > 0
                handles.mass{i}{j} = num2str(mass(find(temp == 1,1,'first')));
                handles.masscomp{i}(j) = 1;
            else
                handles.mass{i}{j} = '';
            end
        end
    end
end

if GUI == 1; active = get(handles.session_list,'value');
else         active = 1;
end

temp = RatList{active};
for i = 1:length(temp)
    temp{i} = sprintf('%4s  %5s',temp{i},handles.mass{active}{i});
end

if pos > length(temp); pos = length(temp); end
if GUI == 1; set(handles.ratname_list,'string',temp,'value',pos); end


%Finally let's check to see which weighing groups are completed
completed = ones(length(handles.masscomp),1);
for i = 1:length(handles.masscomp)
    if any(handles.masscomp{i} == 0)
        completed(i) = 0;
    end
end
% completed = ones(length(handles.mass),1);
% for i = 1:length(handles.mass)
%     for j = 1:length(handles.mass{i})
%         if isempty(handles.mass{i}{j}) || strcmp(handles.mass{i}{j},'New!!');
%             completed(i) = 0;
%             break;
%         end
%     end
% end

if GUI == 1
    for i = 1:length(completed)
        if completed(i) == 1
            comp = 'X';
        else 
            comp = '';
        end
        groups{i} = sprintf('%-10s  %1s',handles.groups{i},comp); %#ok<AGROW>
    end

    set(handles.session_list,'string',groups);
else
    handles.completed = completed;
end
    