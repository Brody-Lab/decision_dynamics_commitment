function output = WM_assign_rats_to_snugs

disp('Pulling rat water lists...');
RWL = cell(0);
RatWaterList = WM_rat_water_list([],[],'all');
for i=1:numel(RatWaterList)
    temp = unique(RatWaterList{i}(:));
    temp(strcmp(temp,'')) = [];
    RWL{i} = temp; 
end

for i=1:numel(RWL)
    RWL{i}(strcmp(RWL{i},'')) = [];
    RWL{i} = unique(RWL{i});
end

disp('Determining current session...');
[ST,ED,PBM,RAT] = bdata(['select starttime, stoptime, percent_bodymass, rat from ratinfo.water where date="',datestr(now,'yyyy-mm-dd'),'"']);

comp = ones(1,9);
for i=1:numel(RWL)
    comptemp = [];
    for j=1:numel(RWL{i})
        if strcmp(RWL{i}{j},''); continue; end
        temp = find(strcmp(RAT,RWL{i}{j})==1);
        st = ST(temp);
        ed = ED(temp);
        pbm = PBM(temp);
        if isempty(st) || isempty(ed) 
            %no watering time logged, session isn't complete
            %comp(i) = 0;
            comptemp(end+1)=0;  %#ok<AGROW>
        else
            d = 0;
            for k = 1:numel(st)
                d = d + ((datenum(ed(k),'HH:MM:SS') - datenum(st(k),'HH:MM:SS')) * 24);
            end
            if d < 0.95 && max(pbm) < 3 %value(MinWaterPerent)
                %Rat had less than 1 hour and drank less than required % body
                %mass water, so his session isn't complete
                %comp(i) = 0;
                comptemp(end+1) = 0;  %#ok<AGROW>
            else
                comptemp(end+1) = 1;  %#ok<AGROW>
            end
        end

    end
    if isempty(comptemp) || mean(comptemp) < 0.5
        comp(i) = 0;
    end
end

currsess = 1;
for i=1:8
    if comp(i) == 1 && comp(i+1) == 0; currsess = i+1; break; end
end

if all(comp(1:9)==1); currsess = 9; end

%The rats we expect to water this session
currrats = RWL{currsess};

disp('Determining which rats are excluded from the pub...');
%These are rats that absolutely must NOT be watered in the pub
hard_exclude = zeros(size(currrats));
for i = 1:numel(currrats)

    comments = bdata(['select comments from ratinfo.rats where ratname="',currrats{i},'"']);
    comments = comments{1};
    if ~isempty(comments)
        x = strfind(comments,'Water Pub ');
        if ~isempty(x) && numel(comments) >= x+16 && strcmpi(comments(x+10:x+16),'exclude')
            hard_exclude(i) = 1;
        end
    end

    ndt = bdata(['select n_done_trials from sessions where ratname="',currrats{i},'"']);
    if numel(ndt(ndt~=0)) < 7 || max(ndt) < 50
        hard_exclude(i) = 1;
    end
end

disp('Determining rat training rigs...')
%find the last rig each rat on the current list to water was trained in
[ratname, rigid, starttime] = bdata(['select ratname, rigid, starttime ',...
    'from sess_started where sessiondate>="',datestr(now,'yyyy-mm-dd'),'"']);

currrigs = zeros(size(currrats));
for i = 1:numel(currrats)
    pos = find(strcmp(ratname,currrats{i}));
    if isempty(pos); continue; end
    
    rig_temp = rigid(pos);
    stt_temp = starttime(pos);

    x = zeros(size(stt_temp));
    for t = 1:numel(stt_temp)
        x(t) = datenum(stt_temp{t},'HH:MM:SS');
    end

    last_rig = rig_temp(find(x == max(x),1,'first'));
    currrigs(i) = last_rig;
end
    
%do not water rats in the pub that did not train
hard_exclude(currrigs == 0) = 1;

disp('Determining broken snugs...')
%identify the broken snugs
broken_snugs = bdata('select rigid from ratinfo.rig_maintenance where isbroken = 1');

is_rat_rig = bSettings('get', 'RIGS', 'ratrig');
if is_rat_rig == 1; firstsnug = 301;
else,               firstsnug = 501;
end
    
broken_snugs(broken_snugs < firstsnug)    = [];
broken_snugs(broken_snugs > firstsnug+99) = [];
broken_snugs = unique(broken_snugs);

%open snugs = 0; occupied;
%open snugs = 1; open and working;
%open snugs = 2; open but broken;

open_snugs = ones(38,1);
open_snugs(broken_snugs - 300) = 2;

%now we start assigning rats to snugs
snugs = zeros(size(currrats));

output = currrats;
for i = 1:numel(output); output{i,2} = currrigs(i); end

disp('Assigning 1st priority rats...');
%first priority is rats not excluded go into matched snugs that are working
for i = 1:numel(currrats)
    if hard_exclude(i) == 0
        currrig = currrigs(i);
        match_snug = currrig + 300;
        
        if sum(broken_snugs == match_snug) == 0
            snugs(i) = match_snug;
            open_snugs(currrig) = 0;
        end
    end
end
for i = 1:size(output,1); output{i,3} = snugs(i); end%; disp(output)

disp('Assigning 2nd priority rats...');
%second priority is rats not excluded go into nearest working snug if
%matched_snug was broken
for i = 1:numel(currrats)
    if hard_exclude(i) == 0
        currrig = currrigs(i);
        match_snug = currrig + 300;
        
        if sum(broken_snugs == match_snug) == 1
            open_snug_temp = find(open_snugs == 1);
            snug_dist = abs(open_snug_temp - currrig);
            closest_snug = find(snug_dist == min(snug_dist),1,'first');
            
            snugs(i) = open_snug_temp(closest_snug) + 300;
            open_snugs(open_snug_temp(closest_snug)) = 0;
        end
    end
end
for i = 1:size(output,1); output{i,3} = snugs(i); end%; disp(output)

disp('Assigning 3rd priority rats...');
%third priority is rats that did train but are excluded, 
%these show up on matched snugs not already taken
for i = 1:numel(currrats)
    if snugs(i) == 0 && currrigs(i) ~= 0
        
        currrig = currrigs(i);
        match_snug = currrig + 300;
        
        if sum(snugs == match_snug) == 0
            snugs(i) = match_snug;
            open_snugs(currrig) = 0;
        end
    end
end
for i = 1:size(output,1); output{i,3} = snugs(i); end%; disp(output)

disp('Assigning 4th priority rats...');
%fourth priority is rats that did train but are excluded,
%these show up on nearest snug not already taken
for i = 1:numel(currrats)
    if snugs(i) == 0 && currrigs(i) ~= 0
        
        currrig = currrigs(i);
        
        open_snug_temp = find(open_snugs ~= 0);
        snug_dist = abs(open_snug_temp - currrig);
        closest_snug = find(snug_dist == min(snug_dist),1,'first');

        snugs(i) = open_snug_temp(closest_snug) + 300;
        open_snugs(open_snug_temp(closest_snug)) = 0;
    end
end
for i = 1:size(output,1); output{i,3} = snugs(i); end%; disp(output)

disp('Assigning 5th priority rats...');
%fifth priority are training rats that did not train,
%these show up on the matched snug based on training schedule
for i = 1:numel(currrats)
    if snugs(i) == 0
        sched_rig = bdata(['select rig from ratinfo.schedule where ratname="',...
            currrats{i},'" and date="',datestr(now,'yyyy-mm-dd'),'"']);
        
        if ~isempty(sched_rig)
            match_snug = sched_rig + 300;
            if sum(snugs == match_snug) == 0
                snugs(i) = match_snug;
                open_snugs(sched_rig) = 0;
            end
        end
    end
end
for i = 1:size(output,1); output{i,3} = snugs(i); end%; disp(output)

disp('Assigning 6th priority rats...');
%sixth priority are training rats that did not train,
%these show up on the nearest open snug based on training schedule
for i = 1:numel(currrats)
    if snugs(i) == 0
        sched_rig = bdata(['select rig from ratinfo.schedule where ratname="',...
            currrats{i},'" and date="',datestr(now,'yyyy-mm-dd'),'"']);
        
        if ~isempty(sched_rig)
            open_snug_temp = find(open_snugs ~= 0);
            snug_dist = abs(open_snug_temp - sched_rig);
            closest_snug = find(snug_dist == min(snug_dist),1,'first');

            snugs(i) = open_snug_temp(closest_snug) + 300;
            open_snugs(open_snug_temp(closest_snug)) = 0;
        end
    end
end
for i = 1:size(output,1); output{i,3} = snugs(i); end%; disp(output)

disp('Assigning 7th priority rats...');
%seventh priority are non-training rats,
%these show up on open snugs in order
for i = 1:numel(currrats)
    if snugs(i) == 0
        first_open_snug = find(open_snugs ~= 0,1,'first');

        if ~isempty(first_open_snug)
            snugs(i) = first_open_snug + 300;
            open_snugs(first_open_snug) = 0;
        end
    end
end
for i = 1:size(output,1); output{i,3} = snugs(i); end; disp(output)

newoutput = cell(38,3);
for i = 301:338
    for j = 1:size(output,1)
        if output{j,3} == i
            newoutput{i-300,1} = output{j,1};
            newoutput{i-300,2} = output{j,2};
            newoutput{i-300,3} = i;
        end
    end
end
output = [];

output.assignments  = newoutput;
output.currsess     = currsess;
output.RWL          = RWL;
output.currrats     = currrats;
output.comp         = comp;
output.broken_snugs = broken_snugs; 