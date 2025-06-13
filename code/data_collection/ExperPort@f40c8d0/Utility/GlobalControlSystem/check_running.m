function handles = check_running(handles)

ratrig = bSettings('get','RIGS','ratrig');
if isnan(ratrig); ratrig = 1; end

if ratrig == 1; rigrange = [1,   399]; 
else            rigrange = [400, 999]; %#ok<SEPEX>
end

[ratS,rigS,slot]      = bdata(['select ratname, rig, timeslot from ratinfo.schedule where date="',datestr(now,29),...
    '" and rig<=',num2str(rigrange(2)),' and rig >=',num2str(rigrange(1))]);

[ratname,rigname,ended,starttime,sessiondate,crashed] = bdata(['select ratname, hostname, was_ended, starttime, sessiondate, crashed',...
    ' from sess_started where sessiondate="',datestr(now,'yyyy-mm-dd'),'" order by sessid desc']);
[RATS,RIGS,STS,EDS]   = bdata(['select ratname, hostname, starttime, endtime from sessions where sessiondate="',datestr(now,'yyyy-mm-dd'),'"']); %#ok<ASGLU>
[ratM,tech]           = bdata(['select ratname, tech from ratinfo.mass where date="',datestr(now,29),'"']);
[name,initials,email] = bdata('select experimenter, initials, email from ratinfo.contacts where is_alumni=0');
[rigid,isbroken]      = bdata('select rigid, isbroken from ratinfo.rig_maintenance order by broke_date desc');
[rigtr,ndt,perf]      = bdata('select rigid, n_done_trials, performance from ratinfo.rigtrials');
[ratR,owner]         = bdata('select ratname, contact from ratinfo.rats where extant=1');
[ratN,rigN,noteN]   = bdata(['select ratname, rigid, note from ratinfo.technotes where datestr="',datestr(now,29),'"']); %#ok<ASGLU>

GUI = 1;
if isempty(handles); GUI = 0; end

if GUI==1; set(handles.now_text,'string',datestr(now,'mmmm dd, yyyy:  HH:MM:SS')); end

NOW = datestr(now,'yymmdd');

if GUI==1; allnames = get(handles.name_menu,'string');
else       allnames = {''}; %#ok<SEPEX>
end

if GUI==0; handles.compnames = get_compnames; end 
rigbroken = zeros(size(handles.compnames,1),1);

for i = 1:numel(rigbroken)
    temp = find(rigid == i & isbroken == 1,1,'first');
    if isempty(temp); continue; end
    rigbroken(i) = isbroken(temp);
end

for i = 1:length(email); email{i} = email{i}(1:find(email{i}=='@')-1); end

if GUI == 1
    pp = strcmp(name,allnames{get(handles.name_menu,'value')});
    if sum(pp) == 1
        person = email{pp};
    else
        person = '';
    end
else
    person = '';
end

%Let's figure out what the rigs are doing
current_slot = [];
current_tech = cell(0);
startedat    = [];
for i = 1:size(handles.compnames,1)
    temp = find(strcmp(rigname,['Rig',sprintf('%02i',str2num(handles.compnames{i,2}))]) == 1,1,'first'); %#ok<ST2NM>
    
    if rigbroken(i) == 1
        if GUI == 1
            set(eval(['handles.status',handles.compnames{i,2}]),'string','BROKEN',...
                'foregroundcolor',[1 0 0]);
            if get(handles.fix_button,'value') == 0
                set(eval(['handles.rig',handles.compnames{i,2}]),'value',1);
            end
        else
            state = 'BROKEN'; %#ok<NASGU>
            eval(['handles.status',handles.compnames{i,2},'=state;']);
        end
    elseif isempty(temp) || ended(temp) == 1
        %Either no rats have started in this rig or the last rat to run was
        %ended.  If that rat ran for more than 1 minute we will mark the
        %rig as free.  If he ran less than 1 minute it might have been an
        %accidental double click, so let's notify the user of that.
        
        temp2 = find(strcmp(RIGS,['Rig',sprintf('%02i',str2num(handles.compnames{i,2}))]) == 1,1,'last'); %#ok<ST2NM>
        if ~isempty(temp2)
            if (datenum(EDS(temp2),'HH:MM:SS') - datenum(STS(temp2),'HH:MM:SS')) * 24 * 60 < 1
                
                if GUI == 1
                    set(eval(['handles.status',handles.compnames{i,2}]),'string','DOUBLE CLICK','foregroundcolor',[1 0 0]);
                else
                    state = 'DOUBLE CLICK'; %#ok<NASGU>
                    eval(['handles.status',handles.compnames{i,2},'=state;']);
                end
                continue;
            end
        end
        
        if GUI == 1 
            if sum(handles.ignore == i) > 0; continue; end
        
            if get(handles.fix_button,'value') == 0
                set(eval(['handles.rig',handles.compnames{i,2}]),'value',1);
            end
            set(eval(['handles.status',handles.compnames{i,2}]),'string','');
        else
            state = '';
            eval(['handles.status',handles.compnames{i,2},'=state;']);
        end
        
        
    else
        if GUI == 1 
            if get(handles.fix_button,'value') == 0
                set(eval(['handles.rig',handles.compnames{i,2}]),'value',0);
            end
        
            weight = 'normal';
            tempr  = strcmp(ratR,ratname{temp});
            if sum(tempr) == 1
                if ~isempty(person) && ~isempty(strfind(owner{tempr},person))
                    weight = 'bold';
                end
            end
        end
        
        if crashed(temp) == 0
            temp2 = rigtr == str2num(handles.compnames{i,2}); %#ok<ST2NM>
            if sum(temp2) == 1
                p = round(perf(temp2)*100); if p < 0; p = 0; end
                d = round((now - datenum([NOW,' ',starttime{temp}],'yymmdd HH:MM:SS')) * 24 * 60);
                state = [ratname{temp},'',sprintf('%4i',ndt(temp2)),'@',sprintf('%3i',p),'% ',sprintf('%3i',d),'m'];
                if GUI == 1
                    set(eval(['handles.status',handles.compnames{i,2}]),'string',state,...
                    'foregroundcolor',[0 0.6 0.2],'fontweight',weight);
                else
                    eval(['handles.status',handles.compnames{i,2},'=state;']);
                end
            else
                state = ['Running ',ratname{temp}];
                if GUI == 1
                    set(eval(['handles.status',handles.compnames{i,2}]),'string',state,...
                    'foregroundcolor',[0 0.6 0.2],'fontweight',weight);
                else
                    eval(['handles.status',handles.compnames{i,2},'=state;']);
                end
            end
            
            startedat(end+1) = datenum([sessiondate{temp},' ',starttime{temp}],'yyyy-mm-dd HH:MM:SS'); %#ok<AGROW>

            if GUI==1 && sum(handles.ignore == i) > 0; continue; end
            tempS = find(strcmp(ratS,ratname{temp}) == 1,1,'first');
            if ~isempty(tempS); current_slot(end+1) = slot(tempS); end %#ok<AGROW>

            tempM = find(strcmp(ratM,ratname{temp}) == 1,1,'first');
            if ~isempty(tempM); current_tech{end+1} = tech{tempM}; end %#ok<AGROW>
        else
            state = ['Crashed ',ratname{temp}];
            if GUI == 1
                set(eval(['handles.status',handles.compnames{i,2}]),'string',state,...
                'foregroundcolor',[1 0 0],'fontweight',weight);
            else
                eval(['handles.status',handles.compnames{i,2},'=state;']);
            end
        end
        
    end
end

uCT = unique(current_tech); if isempty(uCT); uCT{1} = ''; end
if length(uCT) > 1
    for i=1:length(uCT); n(i) = sum(strcmp(current_tech,uCT{i})); end %#ok<AGROW>
    activetech_initials = uCT{find(n == max(n),1,'first')};
else
    activetech_initials = uCT;
end

tempC = find(strcmp(initials,activetech_initials) == 1,1,'first');
if ~isempty(tempC); activetech = name{tempC}; else activetech = 'I do not know who'; end %#ok<SEPEX>
if GUI == 0; handles.activetech = activetech; end

if isempty(current_slot)
    %No one is running who is on the schedule, let's find the last session
    %that was finished
    comprats = ratname(ended==1);
    compslot = [];
    for i=1:length(comprats)
        tempS = find(strcmp(ratS,comprats{i})==1,1,'first');
        if ~isempty(tempS); compslot(end+1) = slot(tempS); end %#ok<AGROW>
    end
    
    sched = slot(~strcmp(ratS,''));
    completed = zeros(1,9);
    
    for i = 1:9
        if sum(compslot == i) / sum(sched == i) > 0.5; completed(i) = 1; end
    end
    lastcomp = find(completed == 1,1,'last');
    
    if isempty(lastcomp)
        str = 'Training has not yet started today.';
        if GUI == 0; handles.session = str; end
    else
        sess = ratS(slot == lastcomp);
        sess(strcmp(sess,'')) = [];
        last_tech = cell(0);
        for i = 1:length(sess)
            tempM = find(strcmp(ratM,sess{i}) == 1,1,'first');
            if ~isempty(tempM); last_tech{end+1} = tech{tempM}; end %#ok<AGROW>
        end

        uCT = unique(last_tech); if isempty(uCT); uCT{1} = ''; end
        if length(uCT) > 1
            for i=1:length(uCT); n(i) = sum(strcmp(last_tech,uCT{i})); end
            lasttech_initials = uCT{find(n == max(n),1,'first')};
        else
            lasttech_initials = uCT;
        end

        tempC = find(strcmp(initials,lasttech_initials) == 1,1,'first');
        if ~isempty(tempC); lasttech = name{tempC}; else lasttech = 'I do not know who'; end %#ok<SEPEX>

        str = [lasttech,' completed Session ',num2str(lastcomp)];
        if GUI == 0; handles.activetech = lasttech; 
                     handles.session    = ['completed ',num2str(lastcomp)];
                     handles.duration   = '';
        end
    end
else
    CS = mode(current_slot);
    str = [activetech,' is running Session ',num2str(CS),...
        ' for ',num2str(round((now - mean(startedat)) * 24 * 60)),' minutes'];
    if GUI == 0; handles.session = ['Session ',num2str(CS)];
                 handles.duration = [num2str(round((now - mean(startedat)) * 24 * 60)),' minutes'];
    end
    
    rs = ratS(slot == CS);
    gs = rigS(slot == CS);
    
    gs(strcmp(rs,'')) = [];
    rs(strcmp(rs,'')) = [];
    
    rr = {};
    for i = 1:38
        if sum(strcmp(handles.compnames(:,2),num2str(i))) == 1
            if GUI == 1; temp = get(eval(['handles.status',num2str(i)]),'string');
            else         temp =     eval(['handles.status',num2str(i)]);
            end
            if ~isempty(temp) && numel(temp) >= 4; rr{i} = temp(1:4); 
            else                                   rr{i} = '';
            end
        else
            rr{i} = '';
        end
    end
    for i = 1:numel(rs)
        if sum(strcmp(rr,rs{i})) == 0 && isempty(rr{gs(i)})
            if sum(rigN == gs(i)) > 0 || sum(strcmp(ratN,rs{i})) > 0; ex = '*';
            else                                                      ex = '';
            end
            state = [rs{i},ex];
            if GUI == 1
                set(eval(['handles.status',num2str(gs(i))]),'string',state,'foregroundcolor',[0 0 1]);
            else
                 eval(['handles.status',num2str(gs(i)),'=state;']);
            end
        end
    end
end

if GUI == 1; set(handles.tech_session_text,'string',str);
else         handles.tech = str;
             handles.time = datestr(now,'mmm dd, yyyy HH:MM:SS'); 
             return;
end


%Now let's try to figure out what the tech computer is doing
weighing = 0;
watering = 0;

id = bdata(['select max(weighing) from ratinfo.mass where date="',datestr(now,'yyyy-mm-dd'),'"']);
if ~isnan(id)
    tm = bdata(['select timeval from ratinfo.mass where weighing=',num2str(id)]);
else
    tm = {};
end

if ~isempty(tm) && ((datenum(datestr(now,'HH:MM:SS'),'HH:MM:SS') - datenum(tm{1},'HH:MM:SS')) * 24 * 60) < 2
    %The last weighing was within the last 5 minutes
    weighing = 1;
end

id = bdata(['select max(watering) from ratinfo.water where date="',datestr(now,'yyyy-mm-dd'),'"']);
if ~isnan(id)
    st = bdata(['select starttime from ratinfo.water where watering=',num2str(id)]);
else
    st = {};
end

if ~isempty(st) && ((datenum(datestr(now,'HH:MM:SS'),'HH:MM:SS') - datenum(st{1},'HH:MM:SS')) * 24 * 60) <= 60
    %Watering has started within the last 65 minutes
    watering = 1;
end

if     weighing == 1 && watering == 1; message = 'Weighing and Watering Rats';
elseif weighing == 1 && watering == 0; message = 'Weighing Rats';
elseif weighing == 0 && watering == 1; message = 'Watering Rats';
elseif weighing == 0 && watering == 0; message = '';
end

set(handles.status70,'string',message,'foregroundcolor',[0 0 0]);

handles.lastrefresh = now;




