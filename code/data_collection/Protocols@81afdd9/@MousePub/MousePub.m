

function [obj] = MousePub(varargin)

obj = class(struct, mfilename, water, sqlsummary);

%---------------------------------------------------------------
%   BEGIN SECTION COMMON TO ALL PROTOCOLS, DO NOT MODIFY
%---------------------------------------------------------------

% If creating an empty object, return without further ado:
if nargin==0 || (nargin==1 && ischar(varargin{1}) && strcmp(varargin{1}, 'empty')), 
   return; 
end;

if isa(varargin{1}, mfilename), % If first arg is an object of this class itself, we are 
                                % Most likely responding to a callback from  
                                % a SoloParamHandle defined in this mfile.
  if length(varargin) < 2 || ~ischar(varargin{2}), 
    error(['If called with a "%s" object as first arg, a second arg, a ' ...
      'string specifying the action, is required\n']);
  else action = varargin{2}; varargin = varargin(3:end); %#ok<NASGU>
  end;
else % Ok, regular call with first param being the action string.
       action = varargin{1}; varargin = varargin(2:end); %#ok<NASGU>
end;
if ~ischar(action), error('The action parameter must be a string'); end;

GetSoloFunctionArgs(obj);

%---------------------------------------------------------------
%   END OF SECTION COMMON TO ALL PROTOCOLS, MODIFY AFTER THIS LINE
%---------------------------------------------------------------


% ---- From here on is where you can put the code you like.
%
% Your protocol will be called, at the appropriate times, with the
% following possible actions:
%
%   'init'     To initialize -- make figure windows, variables, etc.
%
%   'update'   Called periodically within a trial
%
%   'prepare_next_trial'  Called when a trial has ended and your protocol
%              is expected to produce the StateMachine diagram for the next
%              trial; i.e., somewhere in your protocol's response to this
%              call, it should call "dispatcher('send_assembler', sma,
%              prepare_next_trial_set);" where sma is the
%              StateMachineAssembler object that you have prepared and
%              prepare_next_trial_set is either a single string or a cell
%              with elements that are all strings. These strings should
%              correspond to names of states in sma.
%                 Note that after the 'prepare_next_trial' call, further
%              events may still occur in the RTLSM while your protocol is thinking,
%              before the new StateMachine diagram gets sent. These events
%              will be available to you when 'trial_completed' is called on your
%              protocol (see below).
%
%   'trial_completed'   Called when 'state_0' is reached in the RTLSM,
%              marking final completion of a trial (and the start of 
%              the next).
%
%   'close'    Called when the protocol is to be closed.
%
%
% VARIABLES THAT DISPATCHER WILL ALWAYS INSTANTIATE FOR YOU IN YOUR 
% PROTOCOL:
%
% (These variables will be instantiated as regular Matlab variables, 
% not SoloParamHandles. For any method in your protocol (i.e., an m-file
% within the @your_protocol directory) that takes "obj" as its first argument,
% calling "GetSoloFunctionArgs(obj)" will instantiate all the variables below.)
%
%
% n_done_trials     How many trials have been finished; when a trial reaches
%                   one of the prepare_next_trial states for the first
%                   time, this variable is incremented by 1.
%
% n_started trials  How many trials have been started. This variable gets
%                   incremented by 1 every time the state machine goes
%                   through state 0.
%
% parsed_events     The result of running disassemble.m, with the
%                   parsed_structure flag set to 1, on all events from the
%                   start of the current trial to now.
%
% latest_events     The result of running disassemble.m, with the
%                   parsed_structure flag set to 1, on all new events from
%                   the last time 'update' was called to now.
%
% raw_events        All the events obtained in the current trial, not parsed
%                   or disassembled, but raw as gotten from the State
%                   Machine object.
%
% current_assembler The StateMachineAssembler object that was used to
%                   generate the State Machine diagram in effect in the
%                   current trial.
%
% Trial-by-trial history of parsed_events, raw_events, and
% current_assembler, are automatically stored for you in your protocol by
% dispatcher.m. See the wiki documentation for information on how to access
% those histories from within your protocol and for information.
%
% 


switch action,

  %---------------------------------------------------------------
  %          CASE INIT
  %---------------------------------------------------------------
%% INIT 
  case 'init'
    %hide dispatcher
    %set(1,'visible','off')

    % TODO long term make these editable via a settings window
    SoloParamHandle(obj,'WaterPause',   'value',0.1);    %Time in minutes between training end and watering start
    SoloParamHandle(obj,'MinWaterPause','value',1);    %Time in minutes wait for mice that didn't train. Gives tech time to get mouse in box
    SoloParamHandle(obj,'MaxWaterDur',  'value',60);   %Max time in minutes water is available for
    SoloParamHandle(obj,'WaterDropVol', 'value',20);   %Volume in ul of each water drop
    SoloParamHandle(obj,'WaterPulse',   'value',1);    %Time in seconds between successive water drops
    SoloParamHandle(obj,'CycleDur',     'value',0.1);  %Duration of watering cycle in seconds
    SoloParamHandle(obj,'TrialDur',     'value',10);   %Duration of watering trial in seconds
        
    SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = double(figure);

    name = mfilename;
    set(value(myfig), 'Name', name, 'Tag', name, ...
      'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');

    MP = get(0,'MonitorPositions');
    set(value(myfig), 'Position', [1 (MP(4)/2)-150 MP(3) 415]);
    
    W = MP(3)/4;
    F = W/320;
    SoloParamHandle(obj,'FontScale','value',F);
    
    
    for i=1:4
        SubheaderParam(obj,['Line',num2str(i)],'',0,0,'position',[(W*i)-1, 1, 2, 335]);
        set(get_ghandle(eval(['Line',num2str(i)])),'BackgroundColor',[0.7 0.7 0.7]);
    end
    SubheaderParam(obj,'LineTop','',0,0,'position',[1, 335, MP(3), 2]);
    set(get_ghandle(eval('LineTop')),'BackgroundColor',[0.7 0.7 0.7]);
    
    
    MouseWaterList = WM_rat_water_list([],[],'all');

    for i=1:numel(MouseWaterList)
        temp = unique(MouseWaterList{i}(:));
        temp(strcmp(temp,'')) = [];
        MWL{i} = temp; %#ok<AGROW>
    end
        
    for i=1:numel(MWL)
        MWL{i}(strcmp(MWL{i},'')) = [];
        MWL{i} = unique(MWL{i});
    end
    
    SoloParamHandle(obj,'MouseWaterList','value',MWL);
    
    AllMice = bdata('select ratname from ratinfo.rats where extant=1 & israt=0');
    AllMice = unique(AllMice);
    AllMice(2:numel(AllMice)+1) = AllMice;
    AllMice{1} = '';
    
    allexp = bdata('select experimenter from ratinfo.contacts where is_alumni=0');
    allexp = unique(allexp);
    allexp(2:numel(allexp)+1) = allexp;
    allexp{1} = '';
    SoloParamHandle(obj,'AllExp','value',allexp);
    
    for i = 1:4
        
        SubheaderParam(obj,['WaterRig',num2str(i)],num2str(i),0,0,'position',[(W*(i-1))+10 295 W-20 35]);
        set(get_ghandle(eval(['WaterRig',num2str(i)])),'Fontsize',20*F,'BackgroundColor',[1 1 1]);
        
        SubheaderParam(obj,['Mouse',num2str(i)],['X00',num2str(i)],0,0,'position',[(W*(i-1))+35 150 W-70 140]);
        set(get_ghandle(eval(['Mouse',num2str(i)])),'Fontsize',68*F,'BackgroundColor',[1 0.8 0.8]);
       
        SubheaderParam(obj,['NewMouse',num2str(i)],'Water In Homecage',0,0,'position',[(W*(i-1))+35 150 W-70 35])
        set(get_ghandle(eval(['NewMouse',num2str(i)])),'Fontsize',18*F,'BackgroundColor',[0 0 0.8],'ForegroundColor',[1 1 1],'visible','off');
        
        SubheaderParam(obj,['Box',num2str(i),'a'],'',0,0,'position',[(W*(i-1))+10 150 25 140]);
        set(get_ghandle(eval(['Box',num2str(i),'a'])),'BackgroundColor',[0.5 0.5 0.5]);
        
        SubheaderParam(obj,['Box',num2str(i),'b'],'',0,0,'position',[(W*i)-35 150 25 140]);
        set(get_ghandle(eval(['Box',num2str(i),'b'])),'BackgroundColor',[0.5 0.5 0.5]);
        
        MenuParam(obj,['Menu',num2str(i)], AllMice, 1,0,0,'position',[(W*(i-1))+10 10 (W/2)-10 40],'labelfraction',0.02);
        set(get_ghandle(eval(['Menu',num2str(i)])),'Fontsize',20*F,'BackgroundColor',[1 1 1]);
        set_callback(eval(['Menu',num2str(i)]),{mfilename,['set_slot',num2str(i),'_callback']});
        
        NumeditParam(obj,['Water',num2str(i)],20,0,0,'position',[(W*(i-1))+(W/2) 10 (W/2)-10 40],'labelfraction',0.02);
        set(get_ghandle(eval(['Water',num2str(i)])),'Fontsize',20*F,'BackgroundColor',[1 1 1]);
        
        SubheaderParam(obj,['Status',num2str(i)],'Waiting...',0,0,'position',[(W*(i-1))+10 85 W-20 60]);
        set(get_ghandle(eval(['Status',num2str(i)])),'Fontsize',30*F,'BackgroundColor',[1 1 1]);
        
        SubheaderParam(obj,['StatusBarBack',num2str(i)],'',0,0,'position',[(W*(i-1))+10 60 W-20 25]);
        set(get_ghandle(eval(['StatusBarBack',num2str(i)])),'BackgroundColor',[0.5 0.5 0.5]);
        
        SubheaderParam(obj,['StatusBarFree',num2str(i)],'',0,0,'position',[(W*(i-1))+10 60 W-20 25]);
        set(get_ghandle(eval(['StatusBarFree',num2str(i)])),'BackgroundColor',[0 1 1]);
        
        SubheaderParam(obj,['StatusBarRig',num2str(i)],'',0,0,'position',[(W*(i-1))+10 60 W-20 25]);
        set(get_ghandle(eval(['StatusBarRig',num2str(i)])),'BackgroundColor',[0 0 1]);
        
        SubheaderParam(obj,['StatusBarThree',num2str(i)],'',0,0,'position',[(W*(i-1))+20 60 2 25]);
        set(get_ghandle(eval(['StatusBarThree',num2str(i)])),'BackgroundColor',[0 0 0]);
        
        PushbuttonParam(obj,['Fix',num2str(i)],0,0,'label','Click when fixed','position',[(W*(i-1))+10 10 W-20 40]);
        set(get_ghandle(eval(['Fix',num2str(i)])),'Fontsize',20*F,'BackgroundColor',[1 1 1],'visible','off');
        set_callback(eval(['Fix',num2str(i)]),{mfilename,['Fix',num2str(i),'_callback']});
        
    end


%%         
    % make the session bar in the GUI
    for i=1:9
        PushbuttonParam(obj,['Session',num2str(i)],0,0,'label',num2str(i),'position',[((MP(3)/13)*(i-1))+10 350 (MP(3)/13)-20 60]);
        set(get_ghandle(eval(['Session',num2str(i)])),'Fontsize',24*F,'BackgroundColor',[1 1 1]);
        set_callback(eval(['Session',num2str(i)]),{mfilename,['Session',num2str(i),'_callback']});
        
        SubheaderParam(obj,['SessionBox',num2str(i)],'',0,0,'position',[((MP(3)/13)*(i-1))+10 342 (MP(3)/13)-20 7]);
        set(get_ghandle(eval(['SessionBox',num2str(i)])),'BackgroundColor',[1 1 1]);
    end
    i = 10;
        PushbuttonParam(obj,'REBOOT',0,0,'label','REBOOT','position',[((MP(3)/13)*(i-1))+10 350 (MP(3)/13)-20 60]);
        set(get_ghandle(eval('REBOOT')),'Fontsize',5*F,'BackgroundColor',[1 0 0]);
        set_callback(eval('REBOOT'),{mfilename,'REBOOT_callback'});  

    i = 11;
        PushbuttonParam(obj,'END',0,0,'label','END','position',[((MP(3)/13)*(i-1))+10 350 (MP(3)/13)-20 60]);
        set(get_ghandle(eval('END')),'Fontsize',5*F,'BackgroundColor',[1 0 0]);
        set_callback(eval('END'),{mfilename,'END_callback'});   
  
    i =12;
    ToggleParam(obj,'start',0,0,0,...
        'position',[((MP(3)/13)*(i-1))+10 350 (MP(3)/13)-20 60],...
        'OnString','-',...
        'OffString','start');
    if value(start) == 0
        set(get_ghandle(eval('start')),'Fontsize',5*F,'BackgroundColor',[0 1 0]);
    else 
        set(get_ghandle(eval('start')),'Fontsize',5*F,'BackgroundColor',[1 1 1]);
    end
    
    i = 13;
    MenuParam(obj,'TechMenu',allexp,1,0,0,...
        'position',[((MP(3)/13)*(i-1))+10 350 (MP(3)/13)-20 60]);   
            set(get_ghandle(TechMenu),'Fontsize',16*F,'BackgroundColor',[1 1 1]); %#ok<NODEF>
%             set_callback(eval('TechMenu'),{mfilename,'TechMenu_callback'});
            
    %Make the Main GUI background white
    c = get(value(myfig),'children');
    for i=1:length(c); 
        t=get(c(i),'type'); 
        if strcmp(t,'uipanel'); set(c(i),'backgroundcolor',[1 1 1]); end
    end    
    
    SoloParamHandle(obj,'LineOrder','value',{'left1','center1','right1','right2'});
    SoloParamHandle(obj,'PokeOrder','value',{'L','C','R','F'});
    
    alldio=bSettings('get','DIOLINES','ALL');
    waterdio = [];
    leddio   = [];
    order = value(LineOrder);
    for j = 1:numel(order)
        for i=1:size(alldio,1)
            if ~isempty(strfind(lower(alldio{i}),order{j}));
                if ~isempty(strfind(lower(alldio{i}),'water'))
                    waterdio(end+1) = alldio{i,2}; %#ok<AGROW>
                end
                if ~isempty(strfind(lower(alldio{i}),'led'))
                    leddio(end+1) = alldio{i,2}; %#ok<AGROW>
                end
            end
        end
    end
    waterdio(isnan(waterdio)) = [];
    leddio(  isnan(leddio))   = [];
    
    if numel(waterdio) < 4; waterdio(end+1:4) = nan; end
    if numel(leddio)   < 4; leddio(end+1:4)   = nan; end
    
    SoloParamHandle(obj,'WaterDIO','value',waterdio);
    SoloParamHandle(obj,'LEDDIO','value',leddio);
    
    [ST,ED,PBM,MOUSE] = bdata(['select starttime, stoptime, percent_bodymass, rat from ratinfo.water where date="',datestr(now,'yyyy-mm-dd'),'"']);

    
    comp = ones(1,9);
    for i=1:numel(MWL);
        comptemp = [];
        for j=1:numel(MWL{i})
            if strcmp(MWL{i}{j},''); continue; end
            temp = find(strcmp(MOUSE,MWL{i}{j})==1);
            st = ST(temp);
            ed = ED(temp);
            pbm = PBM(temp);
            if isempty(st) || isempty(ed) 
                %no watering time logged, session isn't complete
                %comp(i) = 0;
                comptemp(end+1)=0;
            else
                d = 0;
                for k = 1:numel(st)
                    d = d + ((datenum(ed(k),'HH:MM:SS') - datenum(st(k),'HH:MM:SS')) * 24);
                end
                if d < 0.95 && max(pbm) < 3
                    %Mouse had less than 1 hour and drank less than 3% body
                    %mass water, so his session isn't complete
                    %comp(i) = 0;
                    comptemp(end+1) = 0;
                else
                    comptemp(end+1) = 1;
                end
            end
                
        end
        if isempty(comptemp) || mean(comptemp) < 0.5
            comp(i) = 0;
        end
    end
    %currsess = find(comp == 0,1,'first');
    currsess = 1;
    for i=1:8
        if comp(i) == 1 && comp(i+1) == 0; currsess = i+1; break; end
    end
    %All sessions were watered today so let's prep for 9 to get watered
    %which won't start until after midnight.
    if all(comp(1:9)==1); currsess = 9; end
    currmice = MWL{currsess};
        if ~bSettings('get','RIGS','ratrig')
        listofmice = bdata('select ratname from ratinfo.rats where extant=1 && israt=0');
        idx=find(ismember(currmice,listofmice));
        currmice=currmice(idx);
        end
    %Let's move any mice not getting watered in the pub to the end of the
    %list
    newcurrmiceorder = currmice;
    
    for i = 1:numel(currmice)
        exclude = 0;
        
        comments = bdata(['select comments from ratinfo.rats where ratname="',currmice{i},'"']);
        comments = comments{1};
        if ~isempty(comments)
            x = strfind(comments,'Water Pub ');
            if ~isempty(x) && numel(comments) >= x+16 && strcmpi(comments(x+10:x+16),'exclude')
                exclude = 1;
            end
        end
        
        ndt = bdata(['select n_done_trials from sessions where ratname="',currmice{i},'"']);
        if numel(ndt(ndt~=0)) < 7 || max(ndt) < 50
            exclude = 1;
        end
        
        rg = bdata(['select hostname from sess_started where ratname="',currmice{i},...
                    '" and sessiondate="',datestr(now,'yyyy-mm-dd'),'"']);
        if isempty(rg)
            %This may cause a problem moving mice down who haven't started
            %yet if the pub is started before the session goes in.
            exclude = 1;
        end
                
        if exclude == 1
            newcurrmiceorder{i} = '';
            newcurrmiceorder{end+1} = currmice{i};
        end
    end
    newcurrmiceorder(strcmp(newcurrmiceorder,'')) = [];
    currmice = newcurrmiceorder;
        
    
    for i=1:9;
        if comp(i) == 1; set(get_ghandle(eval(['Session',num2str(i)])),'BackgroundColor',[0 1 1]); end
    end
    set(get_ghandle(eval(['SessionBox',num2str(currsess)])),'BackgroundColor',[0 0 0]);
        
        
    WRIGS = str2num(bSettings('get','WATERRIG','water_rig_ids')); %#ok<ST2NM>
    if numel(WRIGS) < 4; WRIGS(end+1:4) = nan; end
    SoloParamHandle(obj,'WaterRigIDs','value',WRIGS);
    for i = 1:4
        eval(['WaterRig',num2str(i),'.value = WRIGS(i);']);
    end
    
    brk = bdata('select rigid from ratinfo.rig_maintenance where isbroken=1 and rigid>500');
    brk = unique(brk);
    BRK = zeros(1,numel(waterdio));  
    BRK(:) = nan;  
    BRK(~isnan(WRIGS)) = 0;
    
    for i = 1:numel(brk)
        temp = find(WRIGS == brk(i));
        if numel(temp) == 1
            BRK(temp) = 1;
        end
    end
    
    brkcnt = 0;
    temp = (WRIGS(1)-501) - sum(brk < WRIGS(1)) + 1:(WRIGS(1)-501) - sum(brk < WRIGS(1)) + sum(~isnan(waterdio));
    for i = 1:numel(WRIGS)
        if sum(brk == WRIGS(i)) ~= 0
            brkcnt = brkcnt + 1;
        end
    end
    mouselistpos = min(temp):min(temp)+(4-brkcnt)-1;
    SoloParamHandle(obj,'MouseListPosition','value',mouselistpos);
    
    temp(temp > numel(currmice)) = [];
    tempmice = currmice(temp);
    
    activemice = cell(1,4);
    c=0;
    for i = 1:4
        if BRK(i) == 0
            c=c+1;
            if c > numel(tempmice)
                activemice{i} = '';
            else
                activemice{i} = tempmice{c};
            end
        end
    end
    
    if currsess == 9 && str2num(datestr(now,'HH')) > 12 %#ok<ST2NM>
        %Session 9 gets loaded before midnight but watered after therefore
        %those mice by definition will have complete=1 from when they were
        %watered earlier today.  We should therefore check for an entry 
        %with tomorrow's date.
        compmice = bdata(['select ratname from ratinfo.rigwater where complete=1 and dateval="',datestr(now+1,'yyyy-mm-dd'),'"']);
    else
        %If it's before noon we may be watering 9 a little late, i.e. load
        %after midnight, therefore we should check if there's a complete=1
        %for today's date. All other sessions get watered the day they
        %train so just do this.
        compmice = bdata(['select ratname from ratinfo.rigwater where complete=1 and dateval="',datestr(now,'yyyy-mm-dd'),'"']);
    end
    SoloParamHandle(obj,'CompMice','value',compmice);
    
    SoloParamHandle(obj,'MouseMass',        'value',zeros(1,4));
    SoloParamHandle(obj,'WaterEarned',    'value',zeros(1,4));
    SoloParamHandle(obj,'WaterEarnedHere','value',zeros(1,4));
    SoloParamHandle(obj,'DropsRemaining', 'value',zeros(1,4));
    SoloParamHandle(obj,'WaterStartTime', 'value',  nan(1,4));
    SoloParamHandle(obj,'TrainingEndTime','value',  nan(1,4));
    SoloParamHandle(obj,'CurrSess',       'value',currsess);
    SoloParamHandle(obj,'IsBroken',       'value',BRK);
    SoloParamHandle(obj,'Complete','value',zeros(1,4));
   
    SoloParamHandle(obj,'TechInitials','value','');
    
    MousePub(obj,'set_tech')
    
    for i = 1:4
        if BRK(i) == 1
            %Rig is broken, mark as such
            set(get_ghandle(eval(['Mouse',num2str(i)])),'string','BROKEN','fontsize',32,'foregroundcolor',[1 0 0]);
            set(get_ghandle(eval(['Water',num2str(i)])),'visible','off');
            set(get_ghandle(eval(['Status',num2str(i)])),'visible','off');
            set(get_ghandle(eval(['Box',num2str(i),'a'])),'visible','off');
            set(get_ghandle(eval(['Box',num2str(i),'b'])),'visible','off');
            set(get_ghandle(eval(['Menu',num2str(i)])),'value',1,'visible','off');
            set(get_ghandle(eval(['Fix',num2str(i)])),'visible','on');
                
        elseif ~isnan(waterdio(i)) && ~isempty(activemice{i})
            %Rig is good with a mouse to water in it, mark as such
            MousePub(obj,'set_slot',{i,activemice{i}});
            x = find(strcmp(AllMice,activemice(i))==1);
            set(get_ghandle(eval(['Menu',num2str(i)])),'value',x);
           
        elseif isnan(waterdio(i))
            %Rig does not have a water line, hide it
            set(get_ghandle(eval(['Mouse',num2str(i)])),'string','');
            set(get_ghandle(eval(['Water',num2str(i)])),'visible','off');
            set(get_ghandle(eval(['Status',num2str(i)])),'visible','off');
            set(get_ghandle(eval(['Box',num2str(i),'a'])),'visible','off');
            set(get_ghandle(eval(['Box',num2str(i),'b'])),'visible','off');
            set(get_ghandle(eval(['Menu',num2str(i)])),'value',1,'visible','off');
        else
            %Rig has water line but no mouse to water right now, leave
            %menu open
            set(get_ghandle(eval(['Mouse',num2str(i)])),'string','');
            set(get_ghandle(eval(['Water',num2str(i)])),'value',[]);
            set(get_ghandle(eval(['Status',num2str(i)])),'string','');
            set(get_ghandle(eval(['Box',num2str(i),'a'])),'visible','off');
            set(get_ghandle(eval(['Box',num2str(i),'b'])),'visible','off');
            set(get_ghandle(eval(['Menu',num2str(i)])),'value',1,'visible','on');
        end
    end
    
    
    
    for i = 1:4
        if ~isempty(activemice{i})
            MousePub(obj,'get_mouse_data',i);
        end
    end
    
    %Let's determine the valve open times to dispense WaterDropVol ul of water
    SoloParamHandle(obj,'RigID','value',bSettings('get','RIGS','Rig_ID'));
    [V,T,D] = bdata(['select valve, timeval, dispense from calibration_info_tbl where rig_id=',num2str(value(RigID)),' and isvalid=1']);
    vlvs = unique(V);
    DUR = zeros(1,4);
    for i = 1:numel(vlvs)
        p = polyfit(D(strcmp(V,vlvs{i})),T(strcmp(V,vlvs{i})),1);
        dur = (p(1) * value(WaterDropVol)) + p(2);
        
        DUR(find(value(WaterDIO) == alldio{strcmp(alldio(:,1),vlvs{i}),2})) = dur; %#ok<FNDSB>
    end
    if sum(DUR)==0
        DUR = [.1 .1 .1 .1];
    end
    SoloParamHandle(obj,'ValveOpenTimes','value',DUR);    
    
    SoloParamHandle(obj,'ActiveWater',   'value',value(DropsRemaining)>0); %#ok<NODEF>
    SoloParamHandle(obj,'ActiveMice',    'value',activemice);
    
    
    SoloFunctionAddVars('MousePubSMA', 'ro_args', {'WaterDIO','LEDDIO','ActiveWater','ValveOpenTimes','WaterPulse','CycleDur','TrialDur','IsBroken'});
    
    SoloParamHandle(obj,'DoneReboot',     'value',0);
    SoloParamHandle(obj,'DoneTraining',   'value',0);
    SoloParamHandle(obj,'FinalCheck',     'value',zeros(1,4));
    SoloParamHandle(obj,'UpdatedRigwater','value',zeros(1,4));
    SoloParamHandle(obj,'PokeDetected',   'value',zeros(1,4));
    
    
    for i = 1:4
        if ~isnan(waterdio(i)) && BRK(i) == 0 %~isempty(activemice{i})
            %Let's now do manual test on all unbroken units regardless if
            %they are scheduled to water a mouse this session
            set(get_ghandle(eval(['Status',num2str(i)])),'string','Manual Test','fontsize',24*value(FontScale));
        end
    end
    
    scr = timer;
    set(scr,'Period', 0.2,'ExecutionMode','FixedRate','TasksToExecute',Inf,...
        'BusyMode','drop','TimerFcn',[mfilename,'(''end_continued'')']);
    SoloParamHandle(obj, 'stopping_complete_timer', 'value', scr);
    
    SoloParamHandle(obj,'WateringIDs','value',zeros(1,4)*nan);

MousePub(obj,'manual_test');    


%% prepare_next_trial    
  case 'prepare_next_trial'
%     s = fields(parsed_events.states);
%     if ~isempty(parsed_events.states.reset_state)
%             [sma, prepare_next_trial_states] = SMASection(obj, 'final');
%             dispatcher('send_assembler', sma, prepare_next_trial_states);
%             pause(1)
%             MousePub(obj,'end_session');
%             return;
%     end
     if n_done_trials == 1
        
%         %Disable the session buttons so you can't change it
        for i = 1:9
            set(get_ghandle(eval(['Session',num2str(i)])),'enable','off')
        end
%         
            if value(DoneTraining) == 0; 
                %This is no longer a loop that traps you, we just pass
                %through once even if training isn't over for all rats
                MousePub(obj,'wait_for_training_end'); 
            end
            dr      = value(DropsRemaining); %#ok<NODEF>
            we      = value(WaterEarned);
            weh     = value(WaterEarnedHere);
            rm      = value(MouseMass);
            WID     = value(WateringIDs);
            comp    = value(Complete);
            aw_old  = value(ActiveWater);
            finalcheck = value(FinalCheck);
            updated_rigwater = value(UpdatedRigwater);
% 
%                 %We're done with manual test and button press now preparing first real trial
%                 
%                 %As a hack to ensure the rigs are done saving the rats'
%                 %data and writting all necessary info to MySQL tables we
%                 %need to build in a hard pause.
%                 hardpausestart = now;
                for i = 1:4
                    set(get_ghandle(eval(['Status',num2str(i)])),'string','wait for START','fontsize',24*value(FontScale));

                    currstatus{i} = get(get_ghandle(eval(['Status',num2str(i)])),'string'); %#ok<AGROW>

                    set(get_ghandle(eval(['Status',num2str(i)])),'string',currstatus{i});
                    activemouse = get(get_ghandle(eval(['Mouse',num2str(i)])),'string');
                    if ~isempty(activemouse) && strcmp(activemouse,'BROKEN')==0
                        %If the tech was slow in loading the pub there's a
                        %chance the 2 minute hard pause will run past the
                        %20 minute post training pause, therefore we should
                        %do a check here just to be sure we get the data
                        MousePub(obj,'get_mouse_data',i);
                    end
                end
%                 %We may have updated things in the last call to
                %get_mouse_data so let's repull these values
        while value(start)==0
                 pause(1);
             
             %continue
         end
         MousePub(obj,'start_callback');
     end
     
             
    if n_done_trials >1

            waterdio = value(WaterDIO);
            leddio   = value(LEDDIO);
            actwater = value(ActiveWater);
            actleds  = sum(leddio(actwater == 1));
            waterdur = value(ValveOpenTimes);
            waterpas = value(WaterPulse);
            cycledur = value(CycleDur);
            trialdur = value(TrialDur);
            %% TODO SICK EMILY STOPPED HERE and was adding bits from MousePubSMA first trial to here 
            %each of the four ports in a BPod Pub needs a name
            % so I made them Left Center Right FarRight
                line_names = 'LCRF';
         
        WRIGS = str2num(bSettings('get','WATERRIG','water_rig_ids')); %#ok<ST2NM>
        comp = value(Complete); %#ok<NODEF>

                        
%         [sma, prepare_next_trial_states] = SMASection(obj, 'wait_for_reboot');
%         dispatcher('send_assembler', sma, prepare_next_trial_states);
%         %We must be past red button press so we're running
%            dr      = value(DropsRemaining); %#ok<NODEF>
            we      = value(WaterEarned);
            weh     = value(WaterEarnedHere);
            rm      = value(MouseMass);
            WID     = value(WateringIDs);
            aw_old  = value(ActiveWater);
            finalcheck = value(FinalCheck);
            updated_rigwater = value(UpdatedRigwater);
                dr      = value(DropsRemaining);
                we      = value(WaterEarned);
                rm      = value(MouseMass);
                %end of 2 minute hard pause

% 
%                 %We've only just started watering but let's assume it's all going well.  
                

                aw=dr;
             if n_done_trials < 3
                    for i = 1:4
                        drops = 0;
                        we(i)  = we(i)  + (drops * (value(WaterDropVol)/1000));
                        weh(i) = weh(i) + (drops * (value(WaterDropVol)/1000));

                        P = value(eval(['Water',num2str(i)]))/100;
                        dr(i) = ((rm(i) * P) - we(i)) / (value(WaterDropVol)/1000);
                    end
             else 
                    for i = 1:4
                        drops = size(eval(['parsed_events.waves.water',num2str(i),'_wave']),1);
                        we(i)  = we(i)  + (drops * (value(WaterDropVol)/1000));
                        weh(i) = weh(i) + (drops * (value(WaterDropVol)/1000));

                        P = value(eval(['Water',num2str(i)]))/100;
                        dr(i) = ((rm(i) * P) - we(i)) / (value(WaterDropVol)/1000);
                    end

             end
                    if rem(n_done_trials,10) == 0
                        %Every 10th trial let's update with water table in case
                        %things crash we don't want to lose data
                        bdata('describe ratinfo.water');
                        for i = 1:4
                            if aw_old(i) == 1 && comp(i) == 0
                                target = value(eval(['Water',num2str(i)]));
                                mym(bdata,['update ratinfo.water set stoptime="',datestr(now,'HH:MM:SS'),...
                                       '", volume=',num2str(weh(i)),', percent_bodymass=',...
                                       num2str((we(i)/rm(i))*100),', percent_target=',...
                                       num2str(target),' where watering=',num2str(WID(i))]);
                            end
                        end
                    end
                    WaterEarned.value     = we;
                    WaterEarnedHere.value = weh;
                    DropsRemaining.value  = dr;
                    aw = dr > 0;
                  
%             if n_done_trials > 2
%                 %Let's check that the rat is actively poking, if not, let's
%                 %turn off his water for one trial. This is to ensure he
%                 %didn't fall asleep with his butt in the poke and all the
%                 %water spills out.
%                 sps = parsed_events.pokes.starting_state; %#ok<NASGU>
%                 eps = parsed_events.pokes.ending_state; %#ok<NASGU>
%                 
%                 pks = value(PokeOrder);
%                 for i=1:numel(pks)
%                     if strcmp(eval(['sps.',pks{i}]),'in') &&...
%                        strcmp(eval(['eps.',pks{i}]),'in') &&...
%                        isempty(eval(['parsed_events.pokes.',pks{i}]))
%                         %Rat started in and ended in but never left,
%                         %deactivate for one trial
%                         aw(i) = 0;
%                     end
%                 end
%             end
%                 

            wst = value(WaterStartTime); %#ok<NODEF>
            for i = 1:numel(wst)
                if ~isnan(wst(i)) && wst(i) ~= 0 && (now - wst(i)) * 24 * 60 > value(MaxWaterDur)
                    %water has been active for more than one hour
                    dr(i) = 0;
                end
            end
% 
            ET = value(TrainingEndTime);
            for i = 1:numel(value(WaterDIO))
                if isnan(ET(i)) && ~isempty(get(get_ghandle(eval(['Mouse',num2str(i)])),'string')) &&...
                        strcmp(get(get_ghandle(eval(['Mouse',num2str(i)])),'string'),'BROKEN') == 0 && comp(i)==0
                    %Rat is still training let's check if he's done
                    MousePub(obj,'get_mouse_data',i);
                    
                    set(get_ghandle(eval(['Status',num2str(i)])),'string',['Still Training']);
                    aw(i) = 0;

                elseif value(CurrSess)==9 && datenum(datestr(now,'HH:MM:SS'),'HH:MM:SS') > datenum(datestr('22:30:00','HH:MM:SS'),'HH:MM:SS') && comp(i)==0
                    %Currently waiting to water session 9 and it's after
                    %10:30pm, we don't have time to water the session
                    %before midnight so let's wait until after.  I'm
                    %putting this before the elseif WaterPause so this
                    %takes priority. Once we make it to midnight then we
                    %check if we've paused long enough, if so we'll start
                    %watering immediately.
                    
                    set(get_ghandle(eval(['Status',num2str(i)])),'string','Wait for Midnight');
                    aw(i) = 0;
                    if value(WaterPause) - ((now - ET(i)) * 24 * 60) < 1 && finalcheck(i) == 0
                        MousePub(obj,'get_mouse_data',i);
                        finalcheck(i) = 1;
                    end
                    
                elseif (now - ET(i)) * 24 * 60 < value(WaterPause) && comp(i)==0
                    %Still waiting for pause to be over
                    w = value(WaterPause) - ((now - ET(i)) * 24 * 60);
                    m = floor(w);
                    s = floor((w - m)*60);
                    set(get_ghandle(eval(['Status',num2str(i)])),'string',['Water In ',sprintf('%02.0f',m),':',sprintf('%02.0f',s)]);
                    aw(i) = 0;
                    if value(WaterPause) - ((now - ET(i)) * 24 * 60) < 1 && finalcheck(i) == 0
                        %We have less than 1 minute before watering starts
                        %time to do the final check
                        MousePub(obj,'get_mouse_data',i);
                        finalcheck(i) = 1;
                    end
                elseif dr(i) > 0 && comp(i)==0
                    %watering 
                    w = value(MaxWaterDur) - ((now - wst(i)) * 24 * 60);
                    m = floor(w);
                    s = floor((w - m)*60);

                    if isnan(m) || isnan(s)
                        m = value(MaxWaterDur);
                        s = 0;
                    end
                    
                    if aw(i) == 0
                        %This is weird if we're watering this rig but
                        %active_water is set to 0 for it.  This can happen
                        %if the port starts and ends a trial in the in
                        %state. If the port is broken it will be stuck in
                        %the in state and active_water will remain 0. We
                        %need to indicate there's a problem potentially
                        m = 99;
                        s = 99;
                    end

                    set(get_ghandle(eval(['Status',num2str(i)])),'string',...
                        [sprintf('%2.2f',dr(i)*value(WaterDropVol)/1000),'ml | ',sprintf('%02.0f',m),':',sprintf('%02.0f',s)],...
                        'fontsize',28*value(FontScale),'ForegroundColor',[0 0.8 0.8],'BackgroundColor',[1 1 1]);

                    %Let's update his water earned volume
                    %bdata(['update ratinfo.water set volume=',num2str(we(i)),' where watering=',num2str(WID(i))]);

                elseif ~isempty(get(get_ghandle(eval(['Mouse',num2str(i)])),'string')) &&...
                        strcmp(get(get_ghandle(eval(['Mouse',num2str(i)])),'string'),'BROKEN')==0

                    %complete
                    set(get_ghandle(eval(['Status',num2str(i)])),'string',['COMPLETE ',...
                     sprintf('%2.2f',dr(i)*value(WaterDropVol)/1000),'ml'],'ForegroundColor',[0 0 0],'BackgroundColor',[1 1 1]);

                    if comp(i) == 0 || isnan(WID(i))
                        %We just finished, do final update of table. In the
                        %case that the rat was flagged as complete=1 in
                        %rigwater table comp(i)=1 but there should not yet
                        %be an entry in the water table hence WID should =nan
                        activemouse = get(get_ghandle(eval(['Mouse',num2str(i)])),'string');
                        
                        if isnan(WID(i))
                            %We never even started, rat drank all water in rig
                            wst(i) = now;

                            %Let's also inactivate the menu so you can't change the rat
                            %at this time
                            set(get_ghandle(eval(['Menu',num2str(i)])),'enable','off');

                            %Let's insert a new watering into the MySQL table
                            wdate = datestr(now,'yyyy-mm-dd');
                            stime = datestr(now,'HH:MM:SS');
                            etime = datestr(now + (10/(24*3600)),'HH:MM:SS');
                            tech_initials = value(TechInitials);    
                            target = value(eval(['Water',num2str(i)]));

                            pbm = (we(i)/rm(i))*100;
                            if pbm > 100 || pbm < 0 || isnan(pbm); pbm=0; end
                            
                            bdata('describe ratinfo.water'); %hack
                            mym(bdata,['insert into ratinfo.water set date="',wdate,...
                                       '", rat="',activemouse,'", tech="',tech_initials,...
                                       '", starttime="',stime,'", stoptime="',etime,...
                                       '", volume=0, percent_bodymass=',num2str(pbm),...
                                       ', percent_target=',num2str(target)]);   

                            temp = bdata(['select watering from ratinfo.water where rat="',activemouse,...
                                          '" and starttime="',stime,'" and date="',wdate,'"']);
                            
                            if numel(temp) == 1
                                WID(i) = temp;
                            end
                        end
                        
                        try
                            if ~isnan(WID(i))
                                bdata('describe ratinfo.water'); %hack
                                target = value(eval(['Water',num2str(i)]));
                                mym(bdata,['update ratinfo.water set stoptime="',datestr(now,'HH:MM:SS'),...
                                           '", volume=',num2str(weh(i)),', percent_bodymass=',...
                                           num2str((we(i)/rm(i))*100),', percent_target=',...
                                           num2str(target),' where watering=',num2str(WID(i))]);
                            else
                                disp('Table entry not made.  NaN for watering id!!');
                                disp(WID)
                            end
                        end
%                         
%                         %Now that everything is done we will set complete=1
%                         %in ratinfo.rigwater. This ensures if the session
%                         %is reloaded the rat will not get another hour of
                        %water.
                        try
                            id = bdata(['select id from ratinfo.rigwater where ratname="',activemouse,'" and dateval="',datestr(now,'yyyy-mm-dd'),'"']);
                            if isempty(id)
                                %This is odd since we should have added an
                                %entry earlier with complete=0
                                bdata(['insert into ratinfo.rigwater set ratname="',activemouse,'", dateval="',datestr(now,'yyyy-mm-dd'),'", totalvol=0, complete=1']);
                            else
                                bdata('describe ratinfo.rigwater'); %hack
                                mym(bdata,['update ratinfo.rigwater set complete=1 where id=',num2str(id(end))]);
                            end
                        end
                        comp(i) = 1;
                    end
                    aw(i) = 0;
                    dr(i) = 0; %Added this 2017-04-26 just to be safe
                else
                    set(get_ghandle(eval(['Status',num2str(i)])),'string','','ForegroundColor',[0 0 0],'BackgroundColor',[1 1 1]);

                end
            end            


            for i = 1:numel(wst)
                if isnan(wst(i)) && aw(i) == 1

                    bdata('describe ratinfo.water'); %hack keep this here
                    MousePub(obj,'update_bars',{i,'rig_water'});

                    %first trial watering this port, start the 1 hour timer
                    wst(i) = now;

                    %Let's also inactivate the menu so you can't change the rat
                    %at this time
                    set(get_ghandle(eval(['Menu',num2str(i)])),'enable','off');

                    %Let's insert a new watering into the MySQL table
                    wdate = datestr(now,'yyyy-mm-dd');
                    stime = datestr(now,'HH:MM:SS');
                    etime = datestr(now+(1/(24*3600)),'HH:MM:SS');
                    tech_initials = value(TechInitials);
                    activemouse = get(get_ghandle(eval(['Mouse',num2str(i)])),'string');
                    target = value(eval(['Water',num2str(i)]));
                    
                    if ~isempty(activemouse) && ~strcmp(activemouse,'BROKEN')
                        bdata('describe ratinfo.water'); %hack
                        mym(bdata,['insert into ratinfo.water set date="',wdate,...
                               '", rat="',activemouse,'", tech="',tech_initials,...
                               '", starttime="',stime,'", stoptime="',etime,...
                               '", volume=0, percent_bodymass=0, percent_target=',num2str(target)]);   

                        temp = bdata(['select watering from ratinfo.water where rat="',activemouse,...
                                      '" and starttime="',stime,'" and date="',wdate,'"']);
                        if numel(temp) == 1
                            WID(i) = temp;
                        end
                    end
                end
            end
            WateringIDs.value    = WID;
            WaterStartTime.value = wst;
            Complete.value       = comp;
            ActiveWater.value    = aw;
            FinalCheck.value     = finalcheck;

            for i = 1:4
                MousePub(obj,'update_bars',{i,''});
            end

            %if all(dr <= 0); 
            %    %RunningSection(dispatcher,'RunButtonCallback');
            %    pause(1)
            %
            %else
                [sma, prepare_next_trial_states] = MousePubSMA(obj, 'prepare_next_trial');
                dispatcher('send_assembler', sma, prepare_next_trial_states);
             
            %end
     end
%      else 
%             [sma, prepare_next_trial_states] = SMASection(obj, 'final');
%             dispatcher('send_assembler', sma, prepare_next_trial_states);
%             pause(1)
%             MousePub(obj,'end_session');	
         
     
%% start
    case 'start_callback'
        
                [sma, prepare_next_trial_states] = MousePubSMA(obj, 'start_callback');    
                dispatcher('send_assembler', sma, prepare_next_trial_states);
%% start
    case 'start_wait'
        
                [sma, prepare_next_trial_states] = MousePubSMA(obj, 'start_wait');    
                dispatcher('send_assembler', sma, prepare_next_trial_states);

      
%% REBOOT
    case 'REBOOT_callback'
        pause(10);PORT=bSettings('get','RIGS','bpodcom');fclose(serial(PORT));flush;Bpod;newstartup;dispatcher('init');dispatcher('set_protocol','MousePub');
%% REBOOT
    case 'END_callback'
        pause(2);PORT=bSettings('get','RIGS','bpodcom');fclose(serial(PORT));flush;
%% trial_completed    
  case 'trial_completed'
    % Do any updates in the protocol that need doing:
    feval(mfilename, 'update');
  
    
        
%% start the actual pub program    
        %% get_mouse_data
  case 'get_mouse_data'
    %Here we get the mouse's mass and water earned in training info
    
    mousemass        = value(MouseMass);
    waterearned    = value(WaterEarned);
    dropsremaining = value(DropsRemaining);
    ET             = value(TrainingEndTime);
    comp           = value(Complete);
    compmice       = value(CompMice);
    
    i = varargin{1};
    activemouse = get(get_ghandle(eval(['Mouse',num2str(i)])),'string');
    if ~isempty(activemouse) && ~strcmp(activemouse,'BROKEN')
        
        %Let's get the mouse's mass
        if value(CurrSess) == 9 && str2num(datestr(now,'HH'))<14
            %Get yesterday's mass for session 9 if it's after midnight but
            %before 2pm
            m = bdata(['select mass from ratinfo.mass where ratname="',activemouse,'" and date="',datestr(now-1,'yyyy-mm-dd'),'"']);
        else
            m = bdata(['select mass from ratinfo.mass where ratname="',activemouse,'" and date="',datestr(now,'yyyy-mm-dd'),'"']);
        end
        %if there is no entry, assume the mouse is 50g
        if isempty(m) || mean(m)<=0; m = 40; end
        mousemass(i) = mean(m);

        %Get percent water for this mouse
        ptemp = [];
        exclude = 0;
        comments = bdata(['select comments from ratinfo.rats where ratname="',activemouse,'"']);
        comments = comments{1};
        if ~isempty(comments);
            x = strfind(comments,'Water Pub ');
            if ~isempty(x) && numel(comments) >= x+10
                %User may have entered an amount
                if numel(comments) >= x+12 && comments(x+11)=='.' && ~isempty(str2num(comments(x+12)))
                    %decimal value < 10 like 5.3
                    ptemp = str2num(comments(x+10:x+12));
                elseif numel(comments) >= x+13 && comments(x+12)=='.' && ~isempty(str2num(comments(x+13)))
                    %decimal value > 10 like 11.3
                    ptemp = str2num(comments(x+10:x+13));
                elseif numel(comments) >= x+11 && ~isempty(str2num(comments(x+11)))
                    %integer value > 10
                    ptemp = str2num(comments(x+10:x+11));
                elseif numel(comments) >= x+10 && ~isempty(str2num(comments(x+10)))
                    %integer value < 10
                    ptemp = str2num(comments(x+10));
                elseif numel(comments) >= x+16 && strcmpi(comments(x+10:x+16),'exclude')
                    %Exclude from pub
                    ptemp = 99;
                    exclude = 1;
                else
                    %Cannot interpret instructions, set to default
                    ptemp = 10;
                end
            end
        end
        if isempty(ptemp)
            P = value(eval(['Water',num2str(i)]));
        elseif ptemp < 3
            %This value is the minimum. To adjust it you must change the
            %value here AND where the Water# variables are created in init
            P = 3;
        else
            P = ptemp;
        end
%         disp(P);
        eval(['Water',num2str(i),'.value = P;']);
        
        %Let's determined how much the mouse has drunk while training
            temp = bdata(['select totalvol from ratinfo.rigwater where ratname="',...
                activemouse,'" and dateval="',datestr(now,'yyyy-mm-dd'),'"']);
        
        if isempty(temp); waterearned(i) = 0;
        else              waterearned(i) = sum(temp);
        end
        
        %Compute drops remaining
        dropsremaining(i) = ceil((((P/100) * mousemass(i)) - waterearned(i)) / (value(WaterDropVol) / 1000));
        
        %Now let's determine when the mouse finished training if we haven't
        %already done so
        if isnan(ET(i))
                we = bdata(['select was_ended from sess_started where ratname="',activemouse,...
                            '" and sessiondate="',datestr(now,'yyyy-mm-dd'),'" order by sessid desc']);


            if ~isempty(we) && we(1) == 1
                %Rat was ended
                if value(CurrSess) == 9 && str2num(datestr(now,'HH'))<14
                    %If we're watering session 9 and it's after midnight but before
                    %2pm let's get yesterday's end time
                    et = bdata(['select endtime from sessions where ratname="',activemouse,...
                                '" and sessiondate="',datestr(now-1,'yyyy-mm-dd'),'" order by sessid desc']);
                else
                    et = bdata(['select endtime from sessions where ratname="',activemouse,...
                                '" and sessiondate="',datestr(now,'yyyy-mm-dd'),'" order by sessid desc']);
                end
                
                if isempty(et)
                    %something broke since sess_started says was ended but
                    %no entry in sessions table
                    
                    ET(i) = now - ((value(WaterPause) - value(MinWaterPause)) / (24 * 60));
                    currstr = get(get_ghandle(eval(['Status',num2str(i)])),'string');
                    if ~strcmp(currstr,'Manual Test') && ~strcmp(currstr,'Red button start')
                        %If we're still doing manual test or waiting for red button start, we should keep that up
                        set(get_ghandle(eval(['Status',num2str(i)])),'string','Did Not Train','fontsize',24*value(FontScale));
                    end
                else
                    ET(i) = datenum([datestr(now,'yyyy-mm-dd'),' ',et{1}],'yyyy-mm-dd HH:MM:SS');

                    currstr = get(get_ghandle(eval(['Status',num2str(i)])),'string');
                    if ~strcmp(currstr,'Manual Test') && ~strcmp(currstr,'Red button start')
                        %If we're still doing manual test or waiting for red button start, we should keep that up
                        set(get_ghandle(eval(['Status',num2str(i)])),'string','Done Training','fontsize',24*value(FontScale));
                    end
                end
  
             elseif isempty(we)
                %Mouse was never started today. Thinking we should bypass
                %the wait since mouse likely not training. Impose a
                %minimum break
                ET(i) = now - ((value(WaterPause) - value(MinWaterPause)) / (24 * 60));
                currstr = get(get_ghandle(eval(['Status',num2str(i)])),'string');
                if ~strcmp(currstr,'Manual Test')
                    %If we're still doing manual test we should keep that up
                    set(get_ghandle(eval(['Status',num2str(i)])),'string','Did Not Train','fontsize',24*value(FontScale));
                end
        else
                %Mouse has not ended training, we need to loop back somehow
                ET(i) = nan;
            end
        end
        %Finally let's see if this mouse is new and therefore shouldn't be
        %watered in the Pub or if the experimenter wants to exclude him
        ndt = bdata(['select n_done_trials from sessions where ratname="',activemouse,'"']);
        rg = bdata(['select hostname from sess_started where ratname="',activemouse,...
                    '" and sessiondate="',datestr(now,'yyyy-mm-dd'),'"']);
        
        if numel(ndt(ndt~=0)) > 7 && max(ndt) > 50 && exclude == 0 && ~isempty(rg)
            %This mouse isn't new and knows how to drink.
            set(get_ghandle(eval(['NewMouse',num2str(i)])),'visible','off');
        else
            %The mouse is new or has never done many trials or the experimenter
            %wants him excluded from the pub or he didn't train today, 
            %best not to water him in the pub for now
            set(get_ghandle(eval(['NewMouse',num2str(i)])),'visible','on');
        end
    
    else
        waterearned(i) = 0;
        dropsremaining(i) = 0;
        mousemass(i) = 0;
        ET(i) = nan;
        
        %Likely the snug is empty or broken so turn off instructions
        set(get_ghandle(eval(['NewMouse',num2str(i)])),'visible','off');
    end
    
    %If a Mouse has complete=1 in ratinfo.rigwater we will mark him as
    %complete here and ensure water is off in the pub.
    if sum(strcmp(compmice,activemouse))>0
        comp(i) = 1;
    else
        %Pretty sure we don't want to else set comp=0 since the mouse may be
        %marked as complete because he finished his watering in the pub and
        %this case may be called
        %comp(i) = 0;
    end
    
    Complete.value        = comp;
    TrainingEndTime.value = ET;
    MouseMass.value         = mousemass;
    WaterEarned.value     = waterearned;
    DropsRemaining.value  = dropsremaining;
    
    MousePub(obj,'update_bars',{i,'rig_water'});

    
%% update_bars
  case 'update_bars'
      %Let's update the status bars
        
      i = varargin{1}{1};
      x = varargin{1}{2};
      
      mousemass     = value(MouseMass);
      waterearned = value(WaterEarned);
      P           = value(eval(['Water',num2str(i)]));
      activemouse   = get(get_ghandle(eval(['Mouse',num2str(i)])),'string');
    
      if ~isempty(activemouse) && ~strcmp(activemouse,'BROKEN')
          totalw(i) = mousemass(i) * (P/100);
          sbp = get(get_ghandle(eval(['StatusBarBack',num2str(i)])),'position');

          if strcmp(x,'rig_water')
              if value(CurrSess) == 9 && str2num(datestr(now,'HH'))<14
                  %If we're watering session 9 and it's after midnight but before
                  %2pm let's get yesterday's water volume
                  temp = bdata(['select totalvol from ratinfo.rigwater where ratname="',...
                      activemouse,'" and dateval="',datestr(now-1,'yyyy-mm-dd'),'"']);
              else
                  temp = bdata(['select totalvol from ratinfo.rigwater where ratname="',...
                      activemouse,'" and dateval="',datestr(now,'yyyy-mm-dd'),'"']);
              end              
          
              if isempty(temp); rigwaterearned(i) = 0;
              else              rigwaterearned(i) = sum(temp);
              end
              temp = (rigwaterearned(i) / totalw(i)) * sbp(3);
              if     temp <= 0;      temp = 1; 
              elseif temp >  sbp(3); temp = sbp(3);
              elseif isnan(temp);    temp = 1;
              end
              set(get_ghandle(eval(['StatusBarRig',  num2str(i)])),'position',[sbp(1),sbp(2),temp,sbp(4)]);
          end

          temp = (waterearned(i) / totalw(i)) * sbp(3);
          if     temp <= 0;      temp = 1; 
          elseif temp >  sbp(3); temp = sbp(3);
          elseif isnan(temp);    temp = 1;
          end
          set(get_ghandle(eval(['StatusBarFree', num2str(i)])),'position',[sbp(1),sbp(2),temp,sbp(4)]);    

          temp = sbp(1) + ((0.03 / (P/100)) * sbp(3)) - 1;
          set(get_ghandle(eval(['StatusBarThree',num2str(i)])),'position',[temp,  sbp(2),1   ,sbp(4)]);
      end
%       disp(['updated bars for ',num2str(i)]);
      

%% wait_for_training_end
  case 'wait_for_training_end'
    %Now we enter a loop and wait for those mice to finish training
    
    %This used to be a loop that would trap us until all mice were done.
    %This would prevent some mice from starting water if other mice were
    %delayed.  Let's jsut pass through
    
    for i = 1:4
        activemouse = get(get_ghandle(eval(['Mouse',num2str(i)])),'string');
        if ~isempty(activemouse) && ~strcmp(activemouse,'BROKEN')
            currstr = get(get_ghandle(eval(['Status',num2str(i)])),'string');
            if ~strcmp(currstr,'Manual Test') 
                %If we're still doing manual test we should keep that up
                set(get_ghandle(eval(['Status',num2str(i)])),'string','Still Training','fontsize',24*value(FontScale));
            end
        end
    end
    
    %activemice = value(ActiveMice);
    
    done = zeros(1,4); done(:) = nan;
    for i=1:4
        activemouse = get(get_ghandle(eval(['Mouse',num2str(i)])),'string');
        if ~isempty(activemouse) && strcmp(activemouse,'BROKEN') == 0 
            done(i) = 0; 
        end
    end
    %ET = zeros(1,4); ET(:) = nan;
    ET = value(TrainingEndTime); %#ok<NODEF>
    done(~isnan(ET)) = 1;
    
    %while nansum(done) < sum(~isnan(done))
        
        for i=1:4
            if done(i) == 0
                activemouse = get(get_ghandle(eval(['Mouse',num2str(i)])),'string');
                we = bdata(['select was_ended from sess_started where ratname="',activemouse,...
                    '" and sessiondate="',datestr(now,'yyyy-mm-dd'),'" order by sessid desc']);
                if ~isempty(we) && we(1) == 1
                    %Mouse was ended
                    done(i) = 1;
                    et = bdata(['select endtime from sessions where ratname="',activemouse,...
                        '" and sessiondate="',datestr(now,'yyyy-mm-dd'),'" order by sessid desc']);
                    ET(i) = datenum([datestr(now,'yyyy-mm-dd'),' ',et{1}],'yyyy-mm-dd HH:MM:SS');
                    
                    currstr = get(get_ghandle(eval(['Status',num2str(i)])),'string');
                    if ~strcmp(currstr,'Manual Test') 
                        %If we're still doing manual test we should keep that up
                        set(get_ghandle(eval(['Status',num2str(i)])),'string','Done Training','fontsize',24*value(FontScale));
                    end
                elseif isempty(we)
                    %Mouse was never started today. Thinking we should bypass
                    %the wait since Mouse likely not training. Impose a
                    %minimum break
                    ET(i) = now - ((value(WaterPause) - value(MinWaterPause)) / (24 * 60));
                    currstr = get(get_ghandle(eval(['Status',num2str(i)])),'string');
                    if ~strcmp(currstr,'Manual Test')
                        %If we're still doing manual test we should keep that up
                        set(get_ghandle(eval(['Status',num2str(i)])),'string','Did Not Train','fontsize',24*value(FontScale));
                    end
                    done(i) = 1;
                %else
                %    %Still waiting for training to end, flicker status
                %    h = get_ghandle(eval(['Status',num2str(i)]));
                %    if all(get(h,'foregroundcolor')==0)
                %        set(h,'foregroundcolor',[1 1 1],'backgroundcolor',[0 0 0]);
                %    else
                %        set(h,'foregroundcolor',[0 0 0],'backgroundcolor',[1 1 1]);
                %    end
                end
            end
        end
     %   if nansum(done) < sum(~isnan(done))
     %       pause(10); 
     %   end
    %end
    
    TrainingEndTime.value = ET;
    DoneTraining.value    = 1; %#ok<STRNU>
    
    scr = timer;
    set(scr,'Period', 0.2,'ExecutionMode','FixedRate','TasksToExecute',Inf,...
        'BusyMode','drop','TimerFcn',[mfilename,'(''End_Continued'')']);
    SoloParamHandle(obj, 'stopping_complete_timer', 'value', scr);
        
    

%% update    
  case 'update'
    
      %Flicker the colors if we're waiting or watering, hold fixed when complete
      for i = 1:4
          temp = get(get_ghandle(eval(['Status',num2str(i)])),'String');
          if ~strcmp(temp,'COMPLETE') && ~isempty(temp)
                  
              tempf = get(get_ghandle(eval(['Status',num2str(i)])),'ForegroundColor');
              tempb = get(get_ghandle(eval(['Status',num2str(i)])),'BackgroundColor');

              if all(tempb == 1); tempb = tempf; tempf(:) = 1;
              else                tempf = tempb; tempb(:) = 1;
              end

              set(get_ghandle(eval(['Status',num2str(i)])),'ForegroundColor',tempf,'BackgroundColor',tempb);
          end
      end
      
%% fix1_callback
    case 'Fix1_callback'
        fix_waterrig(1,value(WaterRigIDs))

%% fix2_callback
    case 'Fix2_callback'
        fix_waterrig(2,value(WaterRigIDs))
        
%% fix3_callback
    case 'Fix3_callback'
        fix_waterrig(3,value(WaterRigIDs))
        
%% fix4_callback
    case 'Fix4_callback'
        fix_waterrig(4,value(WaterRigIDs))
        

%% set_slot1_callback
    case 'set_slot1_callback'
        MousePub(obj,'set_slot',1);
        
%% set_slot2_callback
    case 'set_slot2_callback'
        MousePub(obj,'set_slot',2);
        
%% set_slot3_callback
    case 'set_slot3_callback'
        MousePub(obj,'set_slot',3);
        
%% set_slot4_callback
    case 'set_slot4_callback'
        MousePub(obj,'set_slot',4);
        
%% set_slot        
    case 'set_slot'
        
        
        if numel(varargin{1}) == 2
            %We are being told wich mouse to set
            i = varargin{1}{1};
            activemouse = varargin{1}{2};
        else
            %Set to the mouse selected from the menu
            i       = varargin{1};
            x       = get(get_ghandle(eval(['Menu',num2str(i)])),'value');
            allmice = get(get_ghandle(eval(['Menu',num2str(i)])),'string');
            activemouse = allmice{x};
        end
        
        if ~isempty(activemouse)
            set(get_ghandle(eval(['Mouse',num2str(i)])),'string',activemouse);

            rgb = bdata(['select tag_RGB from ratinfo.contacts where tag_letter="',...
                         activemouse(1),'" order by is_alumni']);
            if ~isempty(rgb)
                RGB = str2num(rgb{1}); %#ok<ST2NM>
            else
                RGB = [255 255 255];
            end
            set(get_ghandle(eval(['Box',num2str(i),'a'])),'backgroundcolor',RGB/255,'visible','on');
            set(get_ghandle(eval(['Box',num2str(i),'b'])),'backgroundcolor',RGB/255,'visible','on');
        else
            set(get_ghandle(eval(['Mouse',num2str(i)])),'string','');
            set(get_ghandle(eval(['Box',num2str(i),'a'])),'visible','off');
            set(get_ghandle(eval(['Box',num2str(i),'b'])),'visible','off');
        end
        
        wst = value(WaterStartTime);
        wst(i) = nan;
        WaterStartTime.value = wst;
        
        %Reset snug i to complete=0. ret_mouse_data will set back to 1 if mouse
        %is already marked as complete in the rig_water table
        comp = value(Complete);
        comp(i) = 0;
        Complete.value = comp;
        
        MousePub(obj,'get_mouse_data',i);
        
%% session1
  case 'Session1_callback'
      MousePub(obj,'update_session',1);  
        
%% session1
  case 'Session2_callback'
      MousePub(obj,'update_session',2);  
        
%% session1
  case 'Session3_callback'
      MousePub(obj,'update_session',3);  
        
%% session1
  case 'Session4_callback'
      MousePub(obj,'update_session',4);  
        
%% session1
  case 'Session5_callback'
      MousePub(obj,'update_session',5);  
        
%% session1
  case 'Session6_callback'
      MousePub(obj,'update_session',6);
        
%% session1
  case 'Session7_callback'
      MousePub(obj,'update_session',7);  
        
%% session1
  case 'Session8_callback'
      MousePub(obj,'update_session',8);  
        
%% session1
  case 'Session9_callback'
      MousePub(obj,'update_session',9);  
        
%% update_session
  case 'update_session'
        
  i = varargin{1};
  MWL = value(MouseWaterList); %#ok<NODEF>
  currmice = MWL{i};
  currmice(strcmp(currmice,'')) = [];
  
  mouselistpos = value(MouseListPosition);
  mouselistpos(mouselistpos > numel(currmice)) = [];
  currmice = currmice(mouselistpos);
  
  activemice = cell(1,4);
  activewater = zeros(1,4);
  Complete.value = zeros(1,4); %need to reset this for new session
  
  c = 0;
  for j = 1:4
      if strcmp(get(get_ghandle(eval(['Menu',num2str(j)])),'visible'),'on')
          c = c+1;
          if c <= numel(currmice)
              AllMice = get(get_ghandle(eval(['Menu',num2str(j)])),'String');
              newval  = find(strcmp(AllMice,currmice{c})==1,1,'first'); %#ok<NASGU>
              eval(['Menu',num2str(j),'.value_callback = newval;']);
              activemice{j} = currmice{c};
              activewater(j) = 1;
          else
              eval(['Menu',num2str(j),'.value_callback = 1;']);
              activemice{j} = '';
              activewater(j) = 0;
          end
      end
      MousePub(obj,'get_mouse_data',j);
  end
  
  for j = 1:9
      set(get_ghandle(eval(['SessionBox',num2str(j)])),'BackgroundColor',[1 1 1]);
  end
  set(get_ghandle(eval(['SessionBox',num2str(i)])),'BackgroundColor',[0 0 0]);
  
  ActiveWater.value = activewater;
  ActiveMice.value = activemice; 
  CurrSess.value   = i;
  
  if i == 9 && str2num(datestr(now,'HH')) > 12
      compmice = bdata(['select ratname from ratinfo.rigwater where complete=1 and dateval="',datestr(now+1,'yyyy-mm-dd'),'"']);
  else
      compmice = bdata(['select ratname from ratinfo.rigwater where complete=1 and dateval="',datestr(now,'yyyy-mm-dd'),'"']);
  end
  CompMice.value = compmice;
  MousePub(obj,'TechMenu_callback');
  
  %MousePub(obj,'send_empty_state_machine');
  %MousePub(obj,'manual_test');

%% TechMenu_callback
%     case TechMenu_callback
% %         
% tech_name = value(TechInitials);
% tech_initials = bdata(['select initials from ratinfo.contacts where experimenter="',tech_name,'"']);

%% set_tech     
case 'set_tech'
    
    if ~isempty(TechInitials)
        tech = tech{1};
        b = find(tech == ' ' | tech == ',' | tech == '[' | tech == ';',1,'first');
        if ~isempty(b) && b > 1; tech = tech(1:b-1); end
        
        initials = bdata(['select initials from ratinfo.contacts where experimenter="',tech,'"']);
        if isempty(initials); initials = {''}; end
    else
        initials = {''};
    end
    TechInitials.value = initials{1};
    if ~isempty(initials{1})
        TechMenu.value = find(strcmp(value(AllExp),tech)==1,1,'first');
    end



%% end_session    
  case 'end_session'

      %Stop dispatcher and wait for it to respond
      dispatcher('Stop');
        
      %Let's pause until we know dispatcher is done running
      set(value(stopping_complete_timer),'TimerFcn',[mfilename,'(''end_continued'');']);
      start(value(stopping_complete_timer));
        
        
  case 'end_continued'
      %% end_continued
      if value(stopping_process_completed) %This is provided by dispatcher
          stop(value(stopping_complete_timer));
          


      end
      
    
%% pre_saving_settings
 % case 'pre_saving_settings'

        
    
%% after_load_callbacks
%  case 'after_load_callbacks'



%% manual_test               
	case 'manual_test'

    [sma, prepare_next_trial_states] = MousePubSMA(obj, 'manual_test');
        dispatcher('send_assembler', sma, prepare_next_trial_states);
        
    if dispatcher('is_running') == 0
        dispatcher('Run');
    end
 
    
%% close    
  case 'close'

    if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)), %#ok<NODEF>
      delete(value(myfig));
    end;
    delete_sphandle('owner', ['^@' class(obj) '$']);

  otherwise,
    warning('Unknown action! "%s"\n', action); %#ok<WNTAG>
end;

return;

function fix_waterrig(rigpos,rigids)

bdata('describe ratinfo.rig_maintenance'); %hack
mym(bdata,['update ratinfo.rig_maintenance set isbroken=0, fix_date="',datestr(now,'yyyy-mm-dd HH:MM:SS'),...
    '" where rigid=',num2str(rigids(rigpos)),' and isbroken=1'])


