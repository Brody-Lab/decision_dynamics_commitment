

function [obj] = TowerWaterDelivery(varargin)

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
  else action = varargin{2}; varargin = varargin(3:end); 
  end;
else % Ok, regular call with first param being the action string.
       action = varargin{1}; varargin = varargin(2:end); 
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
      
    SoloParamHandle(obj,'HardPause',    'value',1);
    SoloParamHandle(obj,'WaterPause',   'value',5);    %Time in minutes between training end and watering start
    SoloParamHandle(obj,'MinWaterPause','value',1);    %Time in minutes wait for rats that didn't train. Gives tech time to get rat in box
    SoloParamHandle(obj,'MaxWaterDur',  'value',60);   %Max time in minutes was is available for
    SoloParamHandle(obj,'WaterDropVol', 'value',36);   %Volume in ul of each water drop
    SoloParamHandle(obj,'WaterPulse',   'value',3);    %Time in seconds between successive water drops
    SoloParamHandle(obj,'CycleDur',     'value',0.1);  %Duration of watering cycle in seconds
    SoloParamHandle(obj,'TrialDur',     'value',10);   %Duration of watering trial in seconds
    SoloParamHandle(obj,'ForceWaterVal','value',[]);   %Percent target all rats in this rig are offered.    
    
    if exist('C:\ratter\Protocols\@TowerWaterDelivery\pub_settings.mat','file')
        load('C:\ratter\Protocols\@TowerWaterDelivery\pub_settings.mat');
        if exist('parameters','var') && isfield(parameters,'ForceWaterVal')
            ForceWaterVal.value = parameters.ForceWaterVal;
        end
    end
    
    %Let's ensure water rigs are added to the riginfo table too
    rigid = bSettings('get','RIGS','Rig_ID');
    if ~isnan(rigid)
        [ip,ma,hn]=get_network_info;
        steMS = bSettings('get','RIGS','state_machine_server');
        vidS='';
        bdata('call ratinfo.update_riginfo("{S}","{S}","{S}","{S}","{S}","{S}","{S}")',rigid,ip,steMS,ma,hn,isunix,vidS)
        fprintf('Rig Info updated successfully.\nRig %d: IP=%s, MAC=%s, Hostname=%s\n',rigid,ip,ma,hn);
    end

    SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = figure;

    name = mfilename;
    set(value(myfig), 'Name', name, 'Tag', name, ...
      'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');

    MP = get(0,'MonitorPositions');
    set(value(myfig), 'Position', [1 (MP(4)/2)-150 MP(3) 415]);
    
    W = MP(3)/6;
    F = W/320;
    SoloParamHandle(obj,'FontScale','value',F);
    
    
    for i=1:5
        SubheaderParam(obj,['Line',num2str(i)],'',0,0,'position',[(W*i)-1, 1, 2, 335]);
        set(get_ghandle(eval(['Line',num2str(i)])),'BackgroundColor',[0.7 0.7 0.7]);
    end
    SubheaderParam(obj,'LineTop','',0,0,'position',[1, 335, MP(3), 2]);
    set(get_ghandle(eval('LineTop')),'BackgroundColor',[0.7 0.7 0.7]);
    
    
    RatWaterList = WM_rat_water_list([],[],'all');
    for i=1:numel(RatWaterList)
        temp = unique(RatWaterList{i}(:));
        temp(strcmp(temp,'')) = [];
        RWL{i} = temp; %#ok<AGROW>
    end
        
    for i=1:numel(RWL)
        RWL{i}(strcmp(RWL{i},'')) = []; %#ok<AGROW>
        RWL{i} = unique(RWL{i}); %#ok<AGROW>
    end
    
    SoloParamHandle(obj,'RatWaterList','value',RWL);
    
    AllRats = bdata('select ratname from ratinfo.rats where extant=1');
    AllRats = unique(AllRats);
    AllRats(2:numel(AllRats)+1) = AllRats;
    AllRats{1} = '';
    
    allexp = bdata('select experimenter from ratinfo.contacts where is_alumni=0');
    allexp = unique(allexp);
    allexp(2:numel(allexp)+1) = allexp;
    allexp{1} = '';
    SoloParamHandle(obj,'AllExp','value',allexp);
    for i = 1:6
        
        
        SubheaderParam(obj,['WaterRig',num2str(i)],num2str(i),0,0,'position',[(W*(i-1))+10 295 W-20 35]);
        set(get_ghandle(eval(['WaterRig',num2str(i)])),'Fontsize',20*F,'BackgroundColor',[1 1 1]);
        
        SubheaderParam(obj,['Rat',num2str(i)],['X00',num2str(i)],0,0,'position',[(W*(i-1))+35 150 W-70 140]);
        set(get_ghandle(eval(['Rat',num2str(i)])),'Fontsize',68*F,'BackgroundColor',[1 0.8 0.8]);
       
        SubheaderParam(obj,['NewRat',num2str(i)],'Water In Homecage',0,0,'position',[(W*(i-1))+35 150 W-70 35])
        set(get_ghandle(eval(['NewRat',num2str(i)])),'Fontsize',18*F,'BackgroundColor',[0 0 0.8],'ForegroundColor',[1 1 1],'visible','off');
        
        SubheaderParam(obj,['Box',num2str(i),'a'],'',0,0,'position',[(W*(i-1))+10 150 25 140]);
        set(get_ghandle(eval(['Box',num2str(i),'a'])),'BackgroundColor',[0.5 0.5 0.5]);
        
        SubheaderParam(obj,['Box',num2str(i),'b'],'',0,0,'position',[(W*i)-35 150 25 140]);
        set(get_ghandle(eval(['Box',num2str(i),'b'])),'BackgroundColor',[0.5 0.5 0.5]);
        
        MenuParam(obj,['Menu',num2str(i)], AllRats, 1,0,0,'position',[(W*(i-1))+10 10 (W/2)-10 40],'labelfraction',0.02);
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
        
        if i == 6
            MenuParam(obj,'TechMenu',allexp,1,0,0,'position',[(W*(i-1))+(W/2) 345 (W/2)-10 35],'labelfraction',0.02);   
            set(get_ghandle(TechMenu),'Fontsize',16*F,'BackgroundColor',[1 1 1]); %#ok<NODEF>
        end
    end
      
%     for i = 1:6
%         A(i) = axes;
%         set(A(i),'units','pixels','position',[(W*(i-1))+10,150,W-20,140])
%         uistack(A(i),'top')
%         
%         %L1(i) = line([(W*(i-1))+10,W-20],[150,290]);
%         L1(i) = line([0 1],[0 1]);
%         set(L1(i),'color','r','linewidth',5);
%         
%         %L2(i) = line([(W*(i-1))+10,W-20],[290,150]);
%         L2(i) = line([0 1],[1 0]);
%         set(L2(i),'color','r','linewidth',5);
%         
%         set(A(i),'visible','off') 
%     end
    
    for i=1:9
        PushbuttonParam(obj,['Session',num2str(i)],0,0,'label',num2str(i),'position',[((MP(3)/12)*(i-1))+10 350 (MP(3)/12)-20 60]);
        set(get_ghandle(eval(['Session',num2str(i)])),'Fontsize',24*F,'BackgroundColor',[1 1 1]);
        set_callback(eval(['Session',num2str(i)]),{mfilename,['Session',num2str(i),'_callback']});
        
        SubheaderParam(obj,['SessionBox',num2str(i)],'',0,0,'position',[((MP(3)/12)*(i-1))+10 342 (MP(3)/12)-20 7]);
        set(get_ghandle(eval(['SessionBox',num2str(i)])),'BackgroundColor',[1 1 1]);
    end
    
    %Make the Main GUI background white
    c = get(value(myfig),'children');
    for i=1:length(c); 
        t=get(c(i),'type'); 
        if strcmp(t,'uipanel'); set(c(i),'backgroundcolor',[1 1 1]); end
    end    
    
    SoloParamHandle(obj,'LineOrder','value',{'left1','center1','right1','left2','center2','right2'});
    SoloParamHandle(obj,'PokeOrder','value',{'L','C','R','l','c','r','X'});
    
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
    
    if numel(waterdio) < 6; waterdio(end+1:6) = nan; end
    if numel(leddio)   < 6; leddio(end+1:6)   = nan; end
    
    SoloParamHandle(obj,'WaterDIO','value',waterdio);
    SoloParamHandle(obj,'LEDDIO','value',leddio);
    
    %WM = init_check([]);
    %currsess = find(WM.comp == 0,1,'first');
    
    [ST,ED,PBM,RAT] = bdata(['select starttime, stoptime, percent_bodymass, rat from ratinfo.water where date="',datestr(now,'yyyy-mm-dd'),'"']);
    
    comp = ones(1,9);
    for i=1:numel(RWL);
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
                comptemp(end+1)=0; %#ok<AGROW>
            else
                d = 0;
                for k = 1:numel(st)
                    d = d + ((datenum(ed(k),'HH:MM:SS') - datenum(st(k),'HH:MM:SS')) * 24);
                end
                if d < 0.95 && max(pbm) < 3
                    %Rat had less than 1 hour and drank less than 3% body
                    %mass water, so his session isn't complete
                    %comp(i) = 0;
                    comptemp(end+1) = 0; %#ok<AGROW>
                else
                    comptemp(end+1) = 1; %#ok<AGROW>
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
    currrats = RWL{currsess};
    
    %Let's move any rats not getting watered in the pub to the end of the
    %list
    newcurrratsorder = currrats;
    for i = 1:numel(currrats)
        exclude = 0;
        
        comments = bdata(['select comments from ratinfo.rats where ratname="',currrats{i},'"']);
        comments = comments{1};
        if ~isempty(comments)
            x = strfind(comments,'Water Pub ');
            if ~isempty(x) && numel(comments) >= x+16 && strcmpi(comments(x+10:x+16),'exclude')
                exclude = 1;
            end
        end
        
        ndt = bdata(['select n_done_trials from sessions where ratname="',currrats{i},'"']);
        if numel(ndt(ndt~=0)) < 7 || max(ndt) < 50
            exclude = 1;
        end
        
        rg = bdata(['select hostname from sess_started where ratname="',currrats{i},...
                    '" and sessiondate="',datestr(now,'yyyy-mm-dd'),'"']);
        if isempty(rg)
            %This may cause a problem moving rats down who haven't started
            %yet if the pub is started before the session goes in.
            exclude = 1;
        end
                
        if exclude == 1
            newcurrratsorder{i} = '';
            newcurrratsorder{end+1} = currrats{i}; %#ok<AGROW>
        end
    end
    newcurrratsorder(strcmp(newcurrratsorder,'')) = [];
    currrats = newcurrratsorder;
        
    
    for i=1:9;
        if comp(i) == 1; set(get_ghandle(eval(['Session',num2str(i)])),'BackgroundColor',[0 1 1]); end
    end
    set(get_ghandle(eval(['SessionBox',num2str(currsess)])),'BackgroundColor',[0 0 0]);
        
        
    WRIGS = str2num(bSettings('get','WATERRIG','water_rig_ids')); %#ok<ST2NM>
    if numel(WRIGS) < 6; WRIGS(end+1:6) = nan; end
    SoloParamHandle(obj,'WaterRigIDs','value',WRIGS);
    for i = 1:6
        eval(['WaterRig',num2str(i),'.value = WRIGS(i);']);
    end
    
    brk = bdata('select rigid from ratinfo.rig_maintenance where isbroken=1 and rigid>300');
    brk = unique(brk);
    BRK = zeros(1,numel(waterdio));  BRK(:) = nan;  
    BRK(~isnan(WRIGS)) = 0;
    
    for i = 1:numel(brk)
        temp = find(WRIGS == brk(i));
        if numel(temp) == 1
            BRK(temp) = 1;
        end
    end
    
    brkcnt = 0;
    temp = (WRIGS(1)-301) - sum(brk < WRIGS(1)) + 1:(WRIGS(1)-301) - sum(brk < WRIGS(1)) + sum(~isnan(waterdio));
    for i = 1:numel(WRIGS)
        if sum(brk == WRIGS(i)) ~= 0
            brkcnt = brkcnt + 1;
        end
    end
    ratlistpos = min(temp):min(temp)+(6-brkcnt)-1;
    SoloParamHandle(obj,'RatListPosition','value',ratlistpos);
    
    temp(temp > numel(currrats)) = [];
    temprats = currrats(temp);
    
    activerats = cell(1,6);
    c=0;
    for i = 1:6
        if BRK(i) == 0
            c=c+1;
            if c > numel(temprats)
                activerats{i} = '';
            else
                activerats{i} = temprats{c};
            end
        end
    end
    
    if currsess == 9 && str2num(datestr(now,'HH')) > 12 %#ok<ST2NM>
        %Session 9 gets loaded before midnight but watered after therefore
        %those rats by definition will have complete=1 from when they were
        %watered earlier today.  We should therefore check for an entry 
        %with tomorrow's date.
        comprats = bdata(['select ratname from ratinfo.rigwater where complete=1 and dateval="',datestr(now+1,'yyyy-mm-dd'),'"']);
    else
        %If it's before noon we may be watering 9 a little late, i.e. load
        %after midnight, therefore we should check if there's a complete=1
        %for today's date. All other sessions get watered the day they
        %train so just do this.
        comprats = bdata(['select ratname from ratinfo.rigwater where complete=1 and dateval="',datestr(now,'yyyy-mm-dd'),'"']);
    end
    SoloParamHandle(obj,'CompRats','value',comprats);
    
    SoloParamHandle(obj,'RatMass',        'value',zeros(1,6));
    SoloParamHandle(obj,'WaterEarned',    'value',zeros(1,6));
    SoloParamHandle(obj,'WaterEarnedHere','value',zeros(1,6));
    SoloParamHandle(obj,'DropsRemaining', 'value',zeros(1,6));
    SoloParamHandle(obj,'WaterStartTime', 'value',  nan(1,6));
    SoloParamHandle(obj,'TrainingEndTime','value',  nan(1,6));
    SoloParamHandle(obj,'CurrSess',       'value',currsess);
    SoloParamHandle(obj,'IsBroken',       'value',BRK);
    SoloParamHandle(obj,'Complete','value',zeros(1,6));
   
    SoloParamHandle(obj,'TechInitials','value','');
    
    TowerWaterDelivery(obj,'set_tech')
    
    for i = 1:6
        if BRK(i) == 1
            %Rig is broken, mark as such
            set(get_ghandle(eval(['Rat',num2str(i)])),'string','BROKEN','fontsize',32,'foregroundcolor',[1 0 0]);
            set(get_ghandle(eval(['Water',num2str(i)])),'visible','off');
            set(get_ghandle(eval(['Status',num2str(i)])),'visible','off');
            set(get_ghandle(eval(['Box',num2str(i),'a'])),'visible','off');
            set(get_ghandle(eval(['Box',num2str(i),'b'])),'visible','off');
            set(get_ghandle(eval(['Menu',num2str(i)])),'value',1,'visible','off');
            set(get_ghandle(eval(['Fix',num2str(i)])),'visible','on');
                
        elseif ~isnan(waterdio(i)) && ~isempty(activerats{i})
            %Rig is good with a rat to water in it, mark as such
            TowerWaterDelivery(obj,'set_slot',{i,activerats{i}});
            x = find(strcmp(AllRats,activerats(i))==1);
            set(get_ghandle(eval(['Menu',num2str(i)])),'value',x);
           
        elseif isnan(waterdio(i))
            %Rig does not have a water line, hide it
            set(get_ghandle(eval(['Rat',num2str(i)])),'string','');
            set(get_ghandle(eval(['Water',num2str(i)])),'visible','off');
            set(get_ghandle(eval(['Status',num2str(i)])),'visible','off');
            set(get_ghandle(eval(['Box',num2str(i),'a'])),'visible','off');
            set(get_ghandle(eval(['Box',num2str(i),'b'])),'visible','off');
            set(get_ghandle(eval(['Menu',num2str(i)])),'value',1,'visible','off');
        else
            %Rig has water line but no rat to water right now, leave
            %menu open
            set(get_ghandle(eval(['Rat',num2str(i)])),'string','');
            set(get_ghandle(eval(['Water',num2str(i)])),'value',[]);
            set(get_ghandle(eval(['Status',num2str(i)])),'string','');
            set(get_ghandle(eval(['Box',num2str(i),'a'])),'visible','off');
            set(get_ghandle(eval(['Box',num2str(i),'b'])),'visible','off');
            set(get_ghandle(eval(['Menu',num2str(i)])),'value',1,'visible','on');
        end
    end
    
    
    
    for i = 1:6
        if ~isempty(activerats{i})
            TowerWaterDelivery(obj,'get_rat_data',i);
        end
    end
    
    %Let's determine the valve open times to dispense WaterDropVol ul of water
    SoloParamHandle(obj,'RigID','value',bSettings('get','RIGS','Rig_ID'));
    [V,T,D] = bdata(['select valve, timeval, dispense from calibration_info_tbl where rig_id=',num2str(value(RigID)),' and isvalid=1']);
    vlvs = unique(V);
    DUR = zeros(1,6);
    for i = 1:numel(vlvs)
        p = polyfit(D(strcmp(V,vlvs{i})),T(strcmp(V,vlvs{i})),1);
        dur = (p(1) * value(WaterDropVol)) + p(2);
        
        DUR(find(value(WaterDIO) == alldio{strcmp(alldio(:,1),vlvs{i}),2})) = dur; %#ok<FNDSB>
    end
    SoloParamHandle(obj,'ValveOpenTimes','value',DUR);    
    
    SoloParamHandle(obj,'ActiveWater',   'value',value(DropsRemaining)>0); %#ok<NODEF>
    SoloParamHandle(obj,'ActiveRats',    'value',activerats);
    
    
    SoloFunctionAddVars('SMASection', 'ro_args', {'WaterDIO','LEDDIO','ActiveWater','ValveOpenTimes','WaterPulse','CycleDur','TrialDur','IsBroken'});
    
    SoloParamHandle(obj,'DoneReboot',     'value',0);
    SoloParamHandle(obj,'DoneTraining',   'value',0);
    SoloParamHandle(obj,'FinalCheck',     'value',zeros(1,6));
    SoloParamHandle(obj,'UpdatedRigwater','value',zeros(1,6));
    SoloParamHandle(obj,'PokeDetected',   'value',zeros(1,6));
    
    
    for i = 1:6
        if ~isnan(waterdio(i)) && BRK(i) == 0 %~isempty(activerats{i})
            %Let's now do manual test on all unbroken units regardless if
            %they are scheduled to water a rat this session
            set(get_ghandle(eval(['Status',num2str(i)])),'string','Manual Test','fontsize',24*value(FontScale));
        end
    end
    
    scr = timer;
    set(scr,'Period', 0.2,'ExecutionMode','FixedRate','TasksToExecute',Inf,...
        'BusyMode','drop','TimerFcn',[mfilename,'(''end_continued'')']);
    SoloParamHandle(obj, 'stopping_complete_timer', 'value', scr);
    
    
    SoloParamHandle(obj,'WateringIDs','value',zeros(1,6)*nan);
    
    update_riginfo;
    
    TowerWaterDelivery(obj,'manual_test');


%% prepare_next_trial    
  case 'prepare_next_trial'
    
    if n_done_trials > 0
        %We've done something, let's check if we hit the reset button, if
        %so reset the program and skip all the code below
        
        s = fields(parsed_events.states);
        if sum(strcmp(s,'reset_state')) > 0 && ~isempty(parsed_events.states.reset_state)
            [sma, prepare_next_trial_states] = SMASection(obj, 'final');
            dispatcher('send_assembler', sma, prepare_next_trial_states);
            pause(1)
            TowerWaterDelivery(obj,'end_session');
            return;
        end
        
        %The new manual test doesn't require the techs to poke so we're
        %going to use the rat's poking to ensure the rig is working. If a
        %poke is detected let's make a color change on the snug
        if n_done_trials > 2
            line_names = 'LCRlcrX';
            pd = value(PokeDetected); %#ok<NODEF>
            for i = 1:6
                if pd(i) == 0
                    %We haven't detected a poke in this snug yet
                    if ~isempty(eval(['parsed_events.pokes.',line_names(i)]));
                        set(get_ghandle(eval(['Rat',num2str(i)])),'BackgroundColor',[0.8 1 1]);
                        pd(i) = 1;
                    end 
                end
            end
            PokeDetected.value = pd;
        end
        
        %It's also possible that the system thinks a rat is still training
        %but his training rig has crashed.  Let's check for a poke in his
        %watering port, if we see one and his TrainingEndTime is nan then
        %set his training end time to now.
        if n_done_trials > 2
            ET = value(TrainingEndTime); %#ok<NODEF>
            line_names = 'LCRlcrX';
            for i = 1:6
                activerat = get(get_ghandle(eval(['Rat',num2str(i)])),'string');
                if ~isempty(activerat) && strcmp(activerat,'BROKEN')==0 && isnan(ET(i))
                    if ~isempty(eval(['parsed_events.pokes.',line_names(i)]))
                        %Training hasn't ended for this rat but someone has
                        %poked in his water port after red button start
                        
                        ET(i) = now;
                        TrainingEndTime.value = ET;
                        set(get_ghandle(eval(['Status',num2str(i)])),'string','Done Training','fontsize',24*value(FontScale));
                        TowerWaterDelivery(obj,'get_rat_data',i);
                    end
                end
            end
        end    
    end
      
    if n_done_trials == 1
        %Done with manual test, wait for red button press
        
        WRIGS = str2num(bSettings('get','WATERRIG','water_rig_ids')); %#ok<NASGU,ST2NM>
        comp = value(Complete); %#ok<NODEF>
        for i=1:6
            activerat = get(get_ghandle(eval(['Rat',num2str(i)])),'string');
            if ~isempty(activerat) && strcmp(activerat,'BROKEN')==0
                
                if comp(i)==0
                    set(get_ghandle(eval(['Status',num2str(i)])),'string','Red button start','ForegroundColor',[1 0 0],'BackgroundColor',[1 1 1]);
                else
                    %Rats that have complete=1 in ratinfo.rigwater do not
                    %need to be loaded. Tell the tech now before red button
                    %start.
                    set(get_ghandle(eval(['Status',num2str(i)])),'string','COMPLETE','ForegroundColor',[0 0 0],'BackgroundColor',[1 1 1]);
                end
                
                %Now we tell the tech were to get the rat from
                rg = bdata(['select hostname from sess_started where ratname="',activerat,...
                    '" and sessiondate="',datestr(now,'yyyy-mm-dd'),'"']);
                if isempty(rg); rig = 'homecage'; %#ok<NASGU>
                else            rig = rg{1}; %#ok<NASGU>
                end
                
                eval(['WaterRig',num2str(i),'.value = [num2str(WRIGS(i)),''  '',rig];']);
            end
        end
                        
        [sma, prepare_next_trial_states] = SMASection(obj, 'wait_for_reboot');
        dispatcher('send_assembler', sma, prepare_next_trial_states);
    else
        %We must be past red button press so we're running
        
        %Disable the session buttons so you can't change it
        for i = 1:9
            set(get_ghandle(eval(['Session',num2str(i)])),'enable','off')
        end
        
        if value(DoneReboot) == 0 %#ok<NODEF>
            if value(DoneTraining) == 0;  %#ok<NODEF>
                %This is no longer a loop that traps you, we just pass
                %through once even if training isn't over for all rats
                TowerWaterDelivery(obj,'wait_for_training_end'); 
            end
            dr      = value(DropsRemaining); %#ok<NODEF>
            we      = value(WaterEarned); %#ok<NODEF>
            weh     = value(WaterEarnedHere); %#ok<NODEF>
            rm      = value(RatMass); %#ok<NODEF>
            WID     = value(WateringIDs); %#ok<NODEF>
            comp    = value(Complete); %#ok<NODEF>
            aw_old  = value(ActiveWater); %#ok<NODEF>
            finalcheck = value(FinalCheck); %#ok<NODEF>
            updated_rigwater = value(UpdatedRigwater); %#ok<NODEF>

            if n_done_trials == 2
                %We're done with manual test and button press now preparing first real trial
                
                %As a hack to ensure the rigs are done saving the rats'
                %data and writting all necessary info to MySQL tables we
                %need to build in a hard pause.
                hardpausestart = now;
                for i = 1:6
                    currstatus{i} = get(get_ghandle(eval(['Status',num2str(i)])),'string'); %#ok<AGROW>
                    if ~strcmp(currstatus{i},'COMPLETE') && ~strcmp(currstatus{i},'BROKEN');
                        set(get_ghandle(eval(['Status',num2str(i)])),'string','Wait 05:00');
                    end
                end
                w = value(HardPause);
                while w > 0
                    loopstart = now;
                    w = value(HardPause) - ((now - hardpausestart) * 24 * 60);
                    m = floor(w);
                    s = floor((w - m)*60);
                    
                    if m < 0; m = 0; end
                    if s < 0; s = 0; end
                    
                    for i = 1:6
                        if ~strcmp(currstatus{i},'COMPLETE') && ~strcmp(currstatus{i},'BROKEN');
                            set(get_ghandle(eval(['Status',num2str(i)])),'string',['Wait ',sprintf('%02.0f',m),':',sprintf('%02.0f',s)]);
                        end
                    end
                    pause(1 - ((now - loopstart) * 24 * 3600));
                end
                for i = 1:6
                    set(get_ghandle(eval(['Status',num2str(i)])),'string',currstatus{i});
                    activerat = get(get_ghandle(eval(['Rat',num2str(i)])),'string');
                    if ~isempty(activerat) && strcmp(activerat,'BROKEN')==0
                        %If the tech was slow in loading the pub there's a
                        %chance the 5 minute hard pause will run past the
                        %20 minute post training pause, therefore we should
                        %do a check here just to be sure we get the data
                        TowerWaterDelivery(obj,'get_rat_data',i);
                    end
                end
                %We may have updated things in the last call to
                %get_rat_data so let's repull these values
                dr      = value(DropsRemaining);
                we      = value(WaterEarned);
                rm      = value(RatMass);
                comp    = value(Complete);
                %end of 5 minute hard pause
                
                
                for i=1:6
                    activerat = get(get_ghandle(eval(['Rat',num2str(i)])),'string');
                    if ~isempty(activerat) && strcmp(activerat,'BROKEN')==0
                        if value(CurrSess) == 9 && str2num(datestr(now,'HH'))>=16 %#ok<ST2NM,NODEF>
                            %If we're watering session 9 and it's after 4pm
                            %but before midnight let's only check for
                            %watering that's happened after 8pm
                            vol= bdata(['select volume from ratinfo.water where rat="',...
                                activerat,'" and date="',datestr(now,'yyyy-mm-dd'),...
                                '" and stoptime>"16:00:00"']);
                        else
                            vol= bdata(['select volume from ratinfo.water where rat="',...
                                activerat,'" and date="',datestr(now,'yyyy-mm-dd'),'"']);
                        end
                        if ~isempty(vol)
                            %Here we add to the rat's water earned any water
                            %drunk during previous waterings this day.
                            we(i)  = we(i)  + sum(vol);
                        end
                    end
                end


            elseif n_done_trials > 2
                %manual test and button press count as the first two trials
                
                %For now we're going to set complete to 1 in rigwater so WaterMeister puts an X over the rat's name.
                %Now I'm changing this behavior. The protocol will only set
                %complete=1 when the rat reaches COMPLETE in the pub.
                %We've only just started watering but let's assume it's all going well.  
                
                for i = 1:6
                    currstr   = get(get_ghandle(eval(['Status',num2str(i)])),'string');
                    activerat = get(get_ghandle(eval(['Rat',num2str(i)])),'string');
                    if ~strcmp(currstr,'Still Training') && ~strcmp(currstr,'COMPLETE') && ~strcmp(activerat,'BROKEN') &&...
                            ~strcmp(activerat,'') && updated_rigwater(i) == 0
                        %Only do this for rats that are not "Still Training", not "COMPLETE", 
                        %rigs that are not "BROKEN", and only do it once.
                        id = bdata(['select id from ratinfo.rigwater where ratname="',activerat,'" and dateval="',datestr(now,'yyyy-mm-dd'),'"']);
                        if isempty(id)
                            %The rat doesn't have an entry in rigwater so
                            %we will add once just incase not having one
                            %breaks things later however we are now setting
                            %complete=0 as of 2017-4-27
                            bdata(['insert into ratinfo.rigwater set ratname="',activerat,'", dateval="',datestr(now,'yyyy-mm-dd'),'", totalvol=0, complete=0']);
                        %else
                        %    bdata('describe ratinfo.rigwater'); %hack
                        %    mym(bdata,['update ratinfo.rigwater set complete=1 where id=',num2str(id(end))]);
                        end
                        updated_rigwater(i) = 1;
                    end
                end
                UpdatedRigwater.value = updated_rigwater;
                
                
                for i = 1:6
                    drops = size(eval(['parsed_events.waves.water',num2str(i),'_wave']),1);
                    we(i)  = we(i)  + (drops * (value(WaterDropVol)/1000));
                    weh(i) = weh(i) + (drops * (value(WaterDropVol)/1000));

                    P = value(eval(['Water',num2str(i)]))/100;
                    dr(i) = ((rm(i) * P) - we(i)) / (value(WaterDropVol)/1000);
                end

                if rem(n_done_trials,10) == 0
                    %Every 10th trial let's update with water table in case
                    %things crash we don't want to lose data
                    bdata('describe ratinfo.water')
                    for i = 1:6
                        if aw_old(i) == 1 && comp(i) == 0
                            target = value(eval(['Water',num2str(i)]));
                            %Replace this with MySQL protocol
%                             mym(bdata,['update ratinfo.water set stoptime="',datestr(now,'HH:MM:SS'),...
%                                    '", volume=',num2str(weh(i)),', percent_bodymass=',...
%                                    num2str((we(i)/rm(i))*100),', percent_target=',...
%                                    num2str(target),' where watering=',num2str(WID(i))]);
                            bdata('call ratinfo.update_water_all("{S}","{S}","{S}","{S}","{S}")',...
                                datestr(now,'HH:MM:SS'),num2str(weh(i)),num2str((we(i)/rm(i))*100),num2str(target),num2str(WID(i)));
                        end
                    end
                end
            end
            WaterEarned.value     = we;
            WaterEarnedHere.value = weh;
            DropsRemaining.value  = dr;
            aw = dr > 0;
            
            if n_done_trials > 2
                %Let's check that the rat is actively poking, if not, let's
                %turn off his water for one trial. This is to ensure he
                %didn't fall asleep with his butt in the poke and all the
                %water spills out.
                sps = parsed_events.pokes.starting_state; %#ok<NASGU>
                eps = parsed_events.pokes.ending_state; %#ok<NASGU>
                
                pks = value(PokeOrder);
                for i=1:numel(pks)
                    if strcmp(eval(['sps.',pks{i}]),'in') &&...
                       strcmp(eval(['eps.',pks{i}]),'in') &&...
                       isempty(eval(['parsed_events.pokes.',pks{i}]))
                        %Rat started in and ended in but never left,
                        %deactivate for one trial
                        %aw(i) = 0; %turn this off to ensure rats constantly have water available
                    end
                end
            end
                

            wst = value(WaterStartTime); %#ok<NODEF>
            for i = 1:numel(wst)
                if ~isnan(wst(i)) && wst(i) ~= 0 && (now - wst(i)) * 24 * 60 > value(MaxWaterDur)
                    %water has been active for more than one hour
                    dr(i) = 0;
                end
            end

            ET = value(TrainingEndTime);
            for i = 1:numel(value(WaterDIO))
                if isnan(ET(i)) && ~isempty(get(get_ghandle(eval(['Rat',num2str(i)])),'string')) &&...
                        strcmp(get(get_ghandle(eval(['Rat',num2str(i)])),'string'),'BROKEN') == 0 && comp(i)==0
                    %Rat is still training let's check if he's done
                    TowerWaterDelivery(obj,'get_rat_data',i);
                    
                    set(get_ghandle(eval(['Status',num2str(i)])),'string','Still Training');
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
                        TowerWaterDelivery(obj,'get_rat_data',i);
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
                        TowerWaterDelivery(obj,'get_rat_data',i);
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

                elseif ~isempty(get(get_ghandle(eval(['Rat',num2str(i)])),'string')) &&...
                        strcmp(get(get_ghandle(eval(['Rat',num2str(i)])),'string'),'BROKEN')==0

                    %complete
                    set(get_ghandle(eval(['Status',num2str(i)])),'string','COMPLETE','ForegroundColor',[0 0 0],'BackgroundColor',[1 1 1]);

                    if comp(i) == 0 || isnan(WID(i))
                        %We just finished, do final update of table. In the
                        %case that the rat was flagged as complete=1 in
                        %rigwater table comp(i)=1 but there should not yet
                        %be an entry in the water table hence WID should =nan
                        activerat = get(get_ghandle(eval(['Rat',num2str(i)])),'string');
                        
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
                            tech_initials = value(TechInitials);     %#ok<NODEF>
                            target = value(eval(['Water',num2str(i)]));

                            pbm = (we(i)/rm(i))*100;
                            if pbm > 100 || pbm < 0 || isnan(pbm); pbm=0; end
                            
                            bdata('describe ratinfo.water'); %hack
                            mym(bdata,['insert into ratinfo.water set date="',wdate,...
                                       '", rat="',activerat,'", tech="',tech_initials,...
                                       '", starttime="',stime,'", stoptime="',etime,...
                                       '", volume=0, percent_bodymass=',num2str(pbm),...
                                       ', percent_target=',num2str(target)]);   

                            temp = bdata(['select watering from ratinfo.water where rat="',activerat,...
                                          '" and starttime="',stime,'" and date="',wdate,'"']);
                            
                            if numel(temp) == 1
                                WID(i) = temp;
                            end
                        end
                        
                        try
                            if ~isnan(WID(i))
                                bdata('describe ratinfo.water'); %hack
                                target = value(eval(['Water',num2str(i)]));
                                %replace this with a MYSQL protocol
%                                 mym(bdata,['update ratinfo.water set stoptime="',datestr(now,'HH:MM:SS'),...
%                                            '", volume=',num2str(weh(i)),', percent_bodymass=',...
%                                            num2str((we(i)/rm(i))*100),', percent_target=',...
%                                            num2str(target),' where watering=',num2str(WID(i))]);
                                bdata('call ratinfo.update_water_all("{S}","{S}","{S}","{S}","{S}")',...
                                    datestr(now,'HH:MM:SS'),num2str(weh(i)),num2str((we(i)/rm(i))*100),num2str(target),num2str(WID(i)));
    
                            else
                                disp('Table entry not made.  NaN for watering id!!');
                                disp(WID)
                            end
                        catch
                            disp('Table entry not made.  NaN for watering id!!');
                            disp(WID)
                        end
                        
                        %Now that everything is done we will set complete=1
                        %in ratinfo.rigwater. This ensures if the session
                        %is reloaded the rat will not get another hour of
                        %water.
                        try %#ok<TRYNC>
                            id = bdata(['select id from ratinfo.rigwater where ratname="',activerat,'" and dateval="',datestr(now,'yyyy-mm-dd'),'"']);
                            if isempty(id)
                                %This is odd since we should have added an
                                %entry earlier with complete=0
                                bdata(['insert into ratinfo.rigwater set ratname="',activerat,'", dateval="',datestr(now,'yyyy-mm-dd'),'", totalvol=0, complete=1']);
                            else
                                bdata('describe ratinfo.rigwater'); %hack
                                %replace this with MYSQL protocol
%                                mym(bdata,['update ratinfo.rigwater set complete=1 where id=',num2str(id(end))]);
                                bdata('call ratinfo.update_rigwater_complete("{S}","{S}")',1,num2str(id(end)));
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
                    TowerWaterDelivery(obj,'update_bars',{i,'rig_water'});

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
                    activerat = get(get_ghandle(eval(['Rat',num2str(i)])),'string');
                    target = value(eval(['Water',num2str(i)]));
                    
                    if ~isempty(activerat) && ~strcmp(activerat,'BROKEN')
                        bdata('describe ratinfo.water'); %hack
                        mym(bdata,['insert into ratinfo.water set date="',wdate,...
                               '", rat="',activerat,'", tech="',tech_initials,...
                               '", starttime="',stime,'", stoptime="',etime,...
                               '", volume=0, percent_bodymass=0, percent_target=',num2str(target)]);   

                        temp = bdata(['select watering from ratinfo.water where rat="',activerat,...
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

            for i = 1:6
                TowerWaterDelivery(obj,'update_bars',{i,''});
            end

            if all(dr <= 0); 
                %RunningSection(dispatcher,'RunButtonCallback');
                TowerWaterDelivery(obj,'wait_for_reboot');

            else
                [sma, prepare_next_trial_states] = SMASection(obj, 'prepare_next_trial');
                dispatcher('send_assembler', sma, prepare_next_trial_states);
            end    
        else
            [sma, prepare_next_trial_states] = SMASection(obj, 'final');
            dispatcher('send_assembler', sma, prepare_next_trial_states);
            pause(1)
            TowerWaterDelivery(obj,'end_session');
        end
    end
    
    
%% trial_completed    
  case 'trial_completed'
    % Do any updates in the protocol that need doing:
    feval(mfilename, 'update');
  
    
%% manual_test    
  case 'manual_test'
    %Do special manual test

    [sma, prepare_next_trial_states] = SMASection(obj, 'manual_test');
    dispatcher('send_assembler', sma, prepare_next_trial_states);
    
    if dispatcher('is_running') == 0
        dispatcher('Run');
    end
    
    
%% send_empty_state_machine
case 'send_empty_state_machine'
        state_machine_server = bSettings('get','RIGS','state_machine_server');
        
        server_slot = bSettings('get','RIGS','server_slot');
        if isnan(server_slot); server_slot = 0; end
        
        card_slot = bSettings('get', 'RIGS', 'card_slot');
        if isnan(card_slot); card_slot = 0; end
        
        sm = RTLSM2(state_machine_server, 3333,server_slot);
        sm = Initialize(sm);
        
        [inL,outL] = MachinesSection(dispatcher,'determine_io_maps');
        
        sma = StateMachineAssembler('full_trial_structure');
        sma = add_state(sma,'name','vapid_state_in_vapid_matrix');
        
        send(sma,sm,'run_trial_asap',0,'input_lines',inL,'dout_lines',outL,'sound_card_slot', int2str(card_slot));
            
    
%% get_rat_data
  case 'get_rat_data'
    %Here we get the rat's mass and water earned in training info
    
    ratmass        = value(RatMass); %#ok<NODEF>
    waterearned    = value(WaterEarned); %#ok<NODEF>
    dropsremaining = value(DropsRemaining); %#ok<NODEF>
    ET             = value(TrainingEndTime); %#ok<NODEF>
    comp           = value(Complete); %#ok<NODEF>
    comprats       = value(CompRats); %#ok<NODEF>
    
    i = varargin{1};
    activerat = get(get_ghandle(eval(['Rat',num2str(i)])),'string');
    if ~isempty(activerat) && ~strcmp(activerat,'BROKEN')
        
        %Let's get the rat's mass
        if value(CurrSess) == 9 && str2num(datestr(now,'HH'))<14 %#ok<ST2NM,NODEF>
            %Get yesterday's mass for session 9 if it's after midnight but
            %before 2pm
            m = bdata(['select mass from ratinfo.mass where ratname="',activerat,'" and date="',datestr(now-1,'yyyy-mm-dd'),'"']);
        else
            m = bdata(['select mass from ratinfo.mass where ratname="',activerat,'" and date="',datestr(now,'yyyy-mm-dd'),'"']);
        end
        if isempty(m) || mean(m)<=0; m = 999; end
        ratmass(i) = mean(m);

        %Get percent water for this rat
        ptemp = [];
        exclude = 0;
        comments = bdata(['select comments from ratinfo.rats where ratname="',activerat,'"']);
        comments = comments{1};
        if ~isempty(comments);
            x = strfind(comments,'Water Pub ');
            if ~isempty(x) && numel(comments) >= x+10
                %User may have entered an amount
                if numel(comments) >= x+12 && comments(x+11)=='.' && ~isempty(str2num(comments(x+12))) %#ok<ST2NM>
                    %decimal value < 10 like 5.3
                    ptemp = str2num(comments(x+10:x+12)); %#ok<ST2NM>
                elseif numel(comments) >= x+13 && comments(x+12)=='.' && ~isempty(str2num(comments(x+13))) %#ok<ST2NM>
                    %decimal value > 10 like 11.3
                    ptemp = str2num(comments(x+10:x+13)); %#ok<ST2NM>
                elseif numel(comments) >= x+11 && ~isempty(str2num(comments(x+11))) %#ok<ST2NM>
                    %integer value > 10
                    ptemp = str2num(comments(x+10:x+11)); %#ok<ST2NM>
                elseif numel(comments) >= x+10 && ~isempty(str2num(comments(x+10))) %#ok<ST2NM>
                    %integer value < 10
                    ptemp = str2num(comments(x+10)); %#ok<ST2NM>
                elseif numel(comments) >= x+16 && strcmpi(comments(x+10:x+16),'exclude')
                    %Exclude from pub
                    ptemp = 99;
                    exclude = 1;
                else
                    %Cannot interpret instructions, set to default
                    ptemp = 20;
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
        
        %if a default water value has been set override the value here
        if ~isempty(value(ForceWaterVal))
            P = value(ForceWaterVal);
        end
        
        disp(P);
        eval(['Water',num2str(i),'.value = P;']);
        
        %Let's determined how much the rat has drunk while training
        if value(CurrSess) == 9 && str2num(datestr(now,'HH'))<14 %#ok<ST2NM>
            %If we're watering session 9 and it's after midnight but before
            %2pm let's get yesterday's water volume
            temp = bdata(['select totalvol from ratinfo.rigwater where ratname="',...
                activerat,'" and dateval="',datestr(now-1,'yyyy-mm-dd'),'"']);
        else
            temp = bdata(['select totalvol from ratinfo.rigwater where ratname="',...
                activerat,'" and dateval="',datestr(now,'yyyy-mm-dd'),'"']);
        end
        if isempty(temp); waterearned(i) = 0;
        else              waterearned(i) = sum(temp);
        end
        
        %Compute drops remaining
        dropsremaining(i) = ceil((((P/100) * ratmass(i)) - waterearned(i)) / (value(WaterDropVol) / 1000));
        
        %Now let's determine when the rat finished training if we haven't
        %already done so
        if isnan(ET(i))
            if value(CurrSess) == 9 && str2num(datestr(now,'HH'))<14 %#ok<ST2NM>
                %If we're watering session 9 and it's after midnight but before
                %2pm let's get yesterday's was ended flag
                we = bdata(['select was_ended from sess_started where ratname="',activerat,...
                            '" and sessiondate="',datestr(now-1,'yyyy-mm-dd'),'" order by sessid desc']);
            else
                we = bdata(['select was_ended from sess_started where ratname="',activerat,...
                            '" and sessiondate="',datestr(now,'yyyy-mm-dd'),'" order by sessid desc']);
            end

            if ~isempty(we) && we(1) == 1
                %Rat was ended
                if value(CurrSess) == 9 && str2num(datestr(now,'HH'))<14 %#ok<ST2NM>
                    %If we're watering session 9 and it's after midnight but before
                    %2pm let's get yesterday's end time
                    et = bdata(['select endtime from sessions where ratname="',activerat,...
                                '" and sessiondate="',datestr(now-1,'yyyy-mm-dd'),'" order by sessid desc']);
                else
                    et = bdata(['select endtime from sessions where ratname="',activerat,...
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
                %Rat was never started today. Thinking we should bypass
                %the wait since rat likely not training. Impose a
                %minimum break
                ET(i) = now - ((value(WaterPause) - value(MinWaterPause)) / (24 * 60));
                currstr = get(get_ghandle(eval(['Status',num2str(i)])),'string');
                if ~strcmp(currstr,'Manual Test') && ~strcmp(currstr,'Red button start')
                    %If we're still doing manual test or waiting for red button start, we should keep that up
                    set(get_ghandle(eval(['Status',num2str(i)])),'string','Did Not Train','fontsize',24*value(FontScale));
                end
            else
                %Rat has not ended training, we need to loop back somehow
                ET(i) = nan;
            end
        end
        
        %Finally let's see if this rat is new and therefore shouldn't be
        %watered in the Pub or if the experimenter wants to exclude him
        ndt = bdata(['select n_done_trials from sessions where ratname="',activerat,'"']);
        rg = bdata(['select hostname from sess_started where ratname="',activerat,...
                    '" and sessiondate="',datestr(now,'yyyy-mm-dd'),'"']);
        
        if numel(ndt(ndt~=0)) > 7 && max(ndt) > 50 && exclude == 0 && ~isempty(rg)
            %This rat isn't new and knows how to drink.
            set(get_ghandle(eval(['NewRat',num2str(i)])),'visible','off');
        else
            %The rat is new or has never done many trials or the experimenter
            %wants him excluded from the pub or he didn't train today, 
            %best not to water him in the pub for now
            set(get_ghandle(eval(['NewRat',num2str(i)])),'visible','on');
        end
    
    else
        waterearned(i) = 0;
        dropsremaining(i) = 0;
        ratmass(i) = 0;
        ET(i) = nan;
        
        %Likely the snug is empty or broken so turn off instructions
        set(get_ghandle(eval(['NewRat',num2str(i)])),'visible','off');
    end
    
    %If a rat has complete=1 in ratinfo.rigwater we will mark him as
    %complete here and ensure water is off in the pub.
    if sum(strcmp(comprats,activerat))>0
        comp(i) = 1;
    else
        %Pretty sure we don't want to else set comp=0 since the rat may be
        %marked as complete because he finished his watering in the pub and
        %this case may be called
        %comp(i) = 0;
    end
    
    Complete.value        = comp;
    TrainingEndTime.value = ET;
    RatMass.value         = ratmass;
    WaterEarned.value     = waterearned;
    DropsRemaining.value  = dropsremaining;
    
    TowerWaterDelivery(obj,'update_bars',{i,'rig_water'});

    
%% update_bars
  case 'update_bars'
      %Let's update the status bars
        
      i = varargin{1}{1};
      x = varargin{1}{2};
      
      ratmass     = value(RatMass); %#ok<NODEF>
      waterearned = value(WaterEarned); %#ok<NODEF>
      P           = value(eval(['Water',num2str(i)]));
      activerat   = get(get_ghandle(eval(['Rat',num2str(i)])),'string');
    
      if ~isempty(activerat) && ~strcmp(activerat,'BROKEN')
          totalw(i) = ratmass(i) * (P/100);
          sbp = get(get_ghandle(eval(['StatusBarBack',num2str(i)])),'position');

          if strcmp(x,'rig_water')
              if value(CurrSess) == 9 && str2num(datestr(now,'HH'))<14 %#ok<ST2NM,NODEF>
                  %If we're watering session 9 and it's after midnight but before
                  %2pm let's get yesterday's water volume
                  temp = bdata(['select totalvol from ratinfo.rigwater where ratname="',...
                      activerat,'" and dateval="',datestr(now-1,'yyyy-mm-dd'),'"']);
              else
                  temp = bdata(['select totalvol from ratinfo.rigwater where ratname="',...
                      activerat,'" and dateval="',datestr(now,'yyyy-mm-dd'),'"']);
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
      pause(0.1);
      disp(['updated bars for ',num2str(i)]);
      

%% wait_for_training_end
  case 'wait_for_training_end'
    %Now we enter a loop and wait for those rats to finish training
    
    %This used to be a loop that would trap us until all rats were done.
    %This would prevent some rats from starting water if other rats were
    %delayed.  Let's jsut pass through
    
    for i = 1:6
        activerat = get(get_ghandle(eval(['Rat',num2str(i)])),'string');
        if ~isempty(activerat) && ~strcmp(activerat,'BROKEN')
            currstr = get(get_ghandle(eval(['Status',num2str(i)])),'string');
            if ~strcmp(currstr,'Manual Test') && ~strcmp(currstr,'Red button start')
                %If we're still doing manual test or waiting for red button start, we should keep that up
                set(get_ghandle(eval(['Status',num2str(i)])),'string','Still Training','fontsize',24*value(FontScale));
            end
        end
    end
    
    %activerats = value(ActiveRats);
    
    done = zeros(1,6); done(:) = nan;
    for i=1:6
        activerat = get(get_ghandle(eval(['Rat',num2str(i)])),'string');
        if ~isempty(activerat) && strcmp(activerat,'BROKEN') == 0 
            done(i) = 0; 
        end
    end
    %ET = zeros(1,6); ET(:) = nan;
    ET = value(TrainingEndTime); %#ok<NODEF>
    done(~isnan(ET)) = 1;
    
    %while nansum(done) < sum(~isnan(done))
        
        for i=1:6
            if done(i) == 0
                activerat = get(get_ghandle(eval(['Rat',num2str(i)])),'string');
                we = bdata(['select was_ended from sess_started where ratname="',activerat,...
                    '" and sessiondate="',datestr(now,'yyyy-mm-dd'),'" order by sessid desc']);
                if ~isempty(we) && we(1) == 1
                    %Rat was ended
                    done(i) = 1;
                    et = bdata(['select endtime from sessions where ratname="',activerat,...
                        '" and sessiondate="',datestr(now,'yyyy-mm-dd'),'" order by sessid desc']);
                    ET(i) = datenum([datestr(now,'yyyy-mm-dd'),' ',et{1}],'yyyy-mm-dd HH:MM:SS');
                    
                    currstr = get(get_ghandle(eval(['Status',num2str(i)])),'string');
                    if ~strcmp(currstr,'Manual Test') && ~strcmp(currstr,'Red button start')
                        %If we're still doing manual test or waiting for red button start, we should keep that up
                        set(get_ghandle(eval(['Status',num2str(i)])),'string','Done Training','fontsize',24*value(FontScale));
                    end
                elseif isempty(we)
                    %Rat was never started today. Thinking we should bypass
                    %the wait since rat likely not training. Impose a
                    %minimum break
                    ET(i) = now - ((value(WaterPause) - value(MinWaterPause)) / (24 * 60));
                    currstr = get(get_ghandle(eval(['Status',num2str(i)])),'string');
                    if ~strcmp(currstr,'Manual Test') && ~strcmp(currstr,'Red button start')
                        %If we're still doing manual test or waiting for red button start, we should keep that up
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
        
    
%% wait_for_reboot    
  case 'wait_for_reboot'
    %Reboot trial
    DoneReboot.value = 1; %#ok<STRNU>
    
    [sma, prepare_next_trial_states] = SMASection(obj, 'wait_for_reboot');
    dispatcher('send_assembler', sma, prepare_next_trial_states);
    
    
%% update    
  case 'update'
    
      %Flicker the colors if we're waiting or watering, hold fixed when complete
      for i = 1:6
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
        
%% fix5_callback
    case 'Fix5_callback'
        fix_waterrig(5,value(WaterRigIDs))
        
%% fix6_callback
    case 'Fix6_callback'
        fix_waterrig(6,value(WaterRigIDs))

%% set_slot1_callback
    case 'set_slot1_callback'
        TowerWaterDelivery(obj,'set_slot',1);
        
%% set_slot2_callback
    case 'set_slot2_callback'
        TowerWaterDelivery(obj,'set_slot',2);
        
%% set_slot3_callback
    case 'set_slot3_callback'
        TowerWaterDelivery(obj,'set_slot',3);
        
%% set_slot4_callback
    case 'set_slot4_callback'
        TowerWaterDelivery(obj,'set_slot',4);
        
%% set_slot5_callback
    case 'set_slot5_callback'
        TowerWaterDelivery(obj,'set_slot',5);

%% set_slot6_callback
    case 'set_slot6_callback'
        TowerWaterDelivery(obj,'set_slot',6);

%% set_slot        
    case 'set_slot'
        
        
        if numel(varargin{1}) == 2
            %We are being told wich rat to set
            i = varargin{1}{1};
            activerat = varargin{1}{2};
        else
            %Set to the rat selected from the menu
            i       = varargin{1};
            x       = get(get_ghandle(eval(['Menu',num2str(i)])),'value');
            allrats = get(get_ghandle(eval(['Menu',num2str(i)])),'string');
            activerat = allrats{x};
        end
        
        if ~isempty(activerat)
            set(get_ghandle(eval(['Rat',num2str(i)])),'string',activerat);

            rgb = bdata(['select tag_RGB from ratinfo.contacts where tag_letter="',...
                         activerat(1),'" order by is_alumni']);
            if ~isempty(rgb)
                rgb = rgb{1};
                if ~isempty(rgb)
                    RGB = str2num(rgb); %#ok<ST2NM>
                else
                    RGB = [255 255 255];
                end
            else
                RGB = [255 255 255];
            end
            set(get_ghandle(eval(['Box',num2str(i),'a'])),'backgroundcolor',RGB/255,'visible','on');
            set(get_ghandle(eval(['Box',num2str(i),'b'])),'backgroundcolor',RGB/255,'visible','on');
        else
            set(get_ghandle(eval(['Rat',num2str(i)])),'string','');
            set(get_ghandle(eval(['Box',num2str(i),'a'])),'visible','off');
            set(get_ghandle(eval(['Box',num2str(i),'b'])),'visible','off');
        end
        
        wst = value(WaterStartTime); %#ok<NODEF>
        wst(i) = nan;
        WaterStartTime.value = wst;
        
        %Reset snug i to complete=0. ret_rat_data will set back to 1 if rat
        %is already marked as complete in the rig_water table
        comp = value(Complete); %#ok<NODEF>
        comp(i) = 0;
        Complete.value = comp;
        
        TowerWaterDelivery(obj,'get_rat_data',i);
        
%% session1
  case 'Session1_callback'
      TowerWaterDelivery(obj,'update_session',1);  
        
%% session1
  case 'Session2_callback'
      TowerWaterDelivery(obj,'update_session',2);  
        
%% session1
  case 'Session3_callback'
      TowerWaterDelivery(obj,'update_session',3);  
        
%% session1
  case 'Session4_callback'
      TowerWaterDelivery(obj,'update_session',4);  
        
%% session1
  case 'Session5_callback'
      TowerWaterDelivery(obj,'update_session',5);  
        
%% session1
  case 'Session6_callback'
      TowerWaterDelivery(obj,'update_session',6);
        
%% session1
  case 'Session7_callback'
      TowerWaterDelivery(obj,'update_session',7);  
        
%% session1
  case 'Session8_callback'
      TowerWaterDelivery(obj,'update_session',8);  
        
%% session1
  case 'Session9_callback'
      TowerWaterDelivery(obj,'update_session',9);  
        
%% update_session
  case 'update_session'
        
  i = varargin{1};
  RWL = value(RatWaterList); %#ok<NODEF>
  currrats = RWL{i};
  currrats(strcmp(currrats,'')) = [];
  
  ratlistpos = value(RatListPosition);
  ratlistpos(ratlistpos > numel(currrats)) = [];
  currrats = currrats(ratlistpos);
  
  activerats = cell(1,6);
  activewater = zeros(1,6);
  Complete.value = zeros(1,6); %#ok<STRNU> %need to reset this for new session
  
  c = 0;
  for j = 1:6
      if strcmp(get(get_ghandle(eval(['Menu',num2str(j)])),'visible'),'on')
          c = c+1;
          if c <= numel(currrats)
              AllRats = get(get_ghandle(eval(['Menu',num2str(j)])),'String');
              newval  = find(strcmp(AllRats,currrats{c})==1,1,'first'); %#ok<NASGU>
              eval(['Menu',num2str(j),'.value_callback = newval;']);
              activerats{j} = currrats{c};
              activewater(j) = 1;
          else
              eval(['Menu',num2str(j),'.value_callback = 1;']);
              activerats{j} = '';
              activewater(j) = 0;
          end
      end
      TowerWaterDelivery(obj,'get_rat_data',j);
  end
  
  for j = 1:9
      set(get_ghandle(eval(['SessionBox',num2str(j)])),'BackgroundColor',[1 1 1]);
  end
  set(get_ghandle(eval(['SessionBox',num2str(i)])),'BackgroundColor',[0 0 0]);
  
  ActiveWater.value = activewater; %#ok<STRNU>
  ActiveRats.value = activerats;  %#ok<STRNU>
  CurrSess.value   = i;  %#ok<STRNU>
  
  if i == 9 && str2num(datestr(now,'HH')) > 12 %#ok<ST2NM>
      comprats = bdata(['select ratname from ratinfo.rigwater where complete=1 and dateval="',datestr(now+1,'yyyy-mm-dd'),'"']);
  else
      comprats = bdata(['select ratname from ratinfo.rigwater where complete=1 and dateval="',datestr(now,'yyyy-mm-dd'),'"']);
  end
  CompRats.value = comprats; %#ok<STRNU>
  TowerWaterDelivery(obj,'set_tech');
  
  %TowerWaterDelivery(obj,'send_empty_state_machine');
  %TowerWaterDelivery(obj,'manual_test');
  
%% set_tech
  case 'set_tech'
    if value(CurrSess) <= 2 %#ok<NODEF>
        tech = bdata(['select overnight from ratinfo.tech_schedule where date="',datestr(now,'yyyy-mm-dd'),'"']);
    elseif value(CurrSess) <=5
        tech = bdata(['select morning from ratinfo.tech_schedule where date="',datestr(now,'yyyy-mm-dd'),'"']);
    elseif value(CurrSess) <=8
        tech = bdata(['select evening from ratinfo.tech_schedule where date="',datestr(now,'yyyy-mm-dd'),'"']);
    else
        tech = bdata(['select overnight from ratinfo.tech_schedule where date="',datestr(now+1,'yyyy-mm-dd'),'"']);
    end
    
    if ~isempty(tech)
        tech = tech{1};
        b = find(tech == ' ' | tech == ',' | tech == '[' | tech == ';',1,'first');
        if ~isempty(b) && b > 1; tech = tech(1:b-1); end
        
        initials = bdata(['select initials from ratinfo.contacts where experimenter="',tech,'"']);
        if isempty(initials); initials = {''}; end
    else
        initials = {''};
    end
    TechInitials.value = initials{1}; %#ok<STRNU>
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
          
          %This is where we should restart matlab with TowerWaterDelivery
          %running
          cd('C:\ratter\RigScripts');
          
          if value(CurrSess) == 8 %#ok<NODEF>
              %Here we reboot the computer after session 8 is done
              %watering. The computer will restart protocol after boot
              pause(1)
              system('shutdown -r -f -t 1');
              pause(20);
          else
              %For all other sessions we simply kill matlab and restart the
              %protocol
              !restart_towerwaterdelivery.bat
          end
      end
      
    
%% pre_saving_settings
  case 'pre_saving_settings'

        
    
%% after_load_callbacks
  case 'after_load_callbacks'

    
    
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
%Replace this with MySQL protocol
%mym(bdata,['update ratinfo.rig_maintenance set isbroken=0, fix_date="',datestr(now,'yyyy-mm-dd HH:MM:SS'),...
%    '" where rigid=',num2str(rigids(rigpos)),' and isbroken=1'])

id = bdata(['select maintenance_id from ratinfo.rig_maintenance where rigid=',num2str(rigids(rigpos)),' and isbroken=1']);
if ~isempty(id)
    bdata('call ratinfo.mark_rigfixed("{S}","{S}","{S}","{S}")',id(end),' ',datestr(now,'yyyy-mm-dd HH:MM'),'snug fixed');
end

