function out=RPbox_5port(varargin)
global exper fake_rp_box;

if nargin > 0
    if isobject(varargin{1}) && strcmp(varargin{1}.Type,'Analog Input')
        action = 'RPtrig';
    else
        action = lower(varargin{1});
    end
else
    action = lower(get(gcbo,'tag'));
end

switch action

    case 'init'
        message('control','Initializing rpbox_5port');
        fig = ModuleFigure(me,'visible','off');

        hs = 100;
        h = 5;
        vs = 20;
        n = 0;

        n=n+.5;
        InitParam(me,'protocol_path','value',[pwd filesep 'Protocols']);
        InitParam(me,'LastTrialEventCounter','value',0);
        Initparam(me,'Trial_Events','value',[],'save',1);
        InitParam(me,'NewEvent','value',0);

        InitParam(me,'UpdatePeriod','ui','edit','value',350,'pref',0,'pos',[h n*vs hs*.7 vs]); n=n+1;
        SetParamUI(me,'UpdatePeriod','label','Update (ms)');
        % rpTimer=timer('TimerFcn','rpbox_5port(''update'');','StopFcn','rpbox_5port(''update'');','Period',GetParam(me,'UpdatePeriod')/1000,'ExecutionMode','fixedDelay','TasksToExecute',Inf);
        % InitParam(me,'rpTimer','value',rpTimer);
        InitParam(me, 'last_flush_time', 'value', clock);
        InitParam(me, 'last_update_time', 'value', clock);
        InitParam(me,'EventTime','ui','disp','value',0,'pref',0,'pos',[h n*vs hs*.7 vs]); n=n+1;
        SetParamUI(me,'EventTime','label','Event Time');
        InitParam(me,'RunRPx','value',0,'ui','togglebutton','pref',0,'units','normal','pos',[hs*1.5 (n-2)*vs hs*.7 vs*2]);
        SetParamUI(me,'RunRPx','string','RunRPx','backgroundcolor',[0 .9 0],'fontweight','bold','fontsize',10,'fontname','Arial','label','');
        InitParam(me,'Run','value',0);

        InitParam(me,'Event','ui','disp','value',0,'pref',0,'pos',[h n*vs hs*.7 vs]); n=n+1;
        SetParamUI(me,'Event','label','State/Chan');
        InitParam(me,'EventCounter','ui','disp','value',0,'pref',0,'pos',[h n*vs hs*.7 vs]); n=n+1;
        SetParamUI(me,'EventCounter','label','Event Counter');
        InitParam(me,'LastEventCounter','Value',0);
        InitParam(me,'Clock','ui','disp','value',0,'pref',0,'pos',[h n*vs hs*.7 vs]); n=n+1;
        SetParamUI(me,'Clock','label','Clock');
        InitParam(me,'State','ui','disp','value',0,'pref',0,'pos',[h n*vs hs*.7 vs]); n=n+1;
        SetParamUI(me,'State','label','State');
        InitParam(me,'Trial','ui','disp','value',1,'pref',0,'pos',[h n*vs hs*.7 vs]); n=n+1;
        SetParamUI(me,'Trial','label','Trial');
        InitParam(me, 'ProcessingState512', 'value', 0);
        InitParam(me,'RPDevice','value','');
        InitParam(me,'RPBitsOut','vlaue',[]);
        InitParam(me,'RPBitsAva','vlaue',[]);
        InitParam(me,'RP_AO_Out','value',[0 0 0]);
        InitParam(me, 'RunStartEnabled', 'value', 1);
        InitSoftTrg;
        InitRP;
        InitAO;
        InitBits; n=n+3.5;
        UpdateBits;
        InitParam(me,'Protocols','ui','popupmenu','list',{' '},'value',1,'user',1,'pos',[h n*vs hs*1.5 vs]); n=n+1;
        pMenu;    % setup menu for protocols

        % message box
        uicontrol(fig,'tag','message','style','edit',...
            'enable','inact','horiz','left','pos',[h n*vs hs*2+56 vs]); n = n+1;

        set(fig,'pos',[65 461-n*vs hs*2+60 n*vs],'visible','on');
        message('control','');

    case 'trialready'
        message(me,'');

    case 'update'
        if existparam(me, 'RP')
            RP=GetParam(me, 'RP');
            SetParam(me,'NewEvent',0);
            LastEventCounter= GetParam(me,'LastEventCounter');
            machine         = GetMachine(RP);
            State           = GetState(machine);
            EventCounter    = GetEventCounter(machine);
            Clock           = GetTime(machine);
            SetParam(me,'State',State);
            SetParam(me,'Clock',Clock);
            nInputCols = length(GetInputEvents(machine))+1;
            localProcessingState512 = GetParam(me, 'ProcessingState512');
            localFoundState512Flag  = 0;

            if EventCounter>LastEventCounter
                % not backwards compatible with the old state machines under RP boxes by Tucker Davis Technologies.
                % Events = [state, chan, time, new_state]
                Events = GetEvents(machine, LastEventCounter+1, EventCounter);
                % Input columns sometimes include SchedWaves, so it isn't
                % always 1:11. so we do this (the extra one is for Tup):
                SetParam(me,'NewEvent',1);
                SetParam(me,'EventCounter',EventCounter);
                n_event=EventCounter-LastEventCounter;
                state    =zeros(1,n_event)*NaN;
                chan     =state;
                evnt_t   =state;
                new_state=state;
                event_n=1;

                for i=1:n_event
                    chan_chk = find(bitget(Events(i,2), 1:nInputCols));
                    state(event_n)  = Events(i,1);
                    evnt_t(event_n) = Events(i,3);
                    new_state(event_n) = Events(i,4);
                    if new_state(event_n) == 512
                        if localProcessingState512==0,
                            localFoundState512Flag = 1;
                        else
                        end
                    elseif new_state(event_n) == 0
                        if localProcessingState512==1,
                            localProcessingState512 = 0;
                            SetParam(me, 'ProcessingState512', 0);
                        end;
                    end;
                    if length(chan_chk)>1
                        message(me,'more than one input at the same time');
                        for j=1:length(chan_chk)
                            state(event_n)     = Events(i,1);
                            chan(event_n)      = chan_chk(j);
                            evnt_t(event_n)    = Events(i,3);
                            new_state(event_n) = Events(i,4);
                            event_n=event_n+1;
                        end
                    elseif chan_chk
                        chan(event_n)=chan_chk(1);
                        event_n=event_n+1;
                    else
                        % message(me,'event too fast to be detected','error');
                        chan(event_n)=0;
                        event_n=event_n+1;
                    end
                end
                SetParam(me,'Event','value',[num2str(state(end)) ' / ' num2str(chan(end))],'user',[state',chan',evnt_t',new_state']);
                SetParam(me,'EventTime','value',evnt_t(end));
                SetParam(me,'LastEventCounter',EventCounter);
            else
                SetParam(me,'Event','user',[]);
            end
            list=getparam(me,'protocols','list');
            CallModules(list(getparam(me,'protocols')),'update');

            if localFoundState512Flag
                if localProcessingState512==0,
                    SetParam(me, 'ProcessingState512', 1);
                    rpbox_5port('state512');
                else
                end;
            elseif State == 0
                if localProcessingState512==1,
                    SetParam(me, 'ProcessingState512', 0);
                end;
            end;
        end

    case 'state512'
        RP      =   GetParam(me, 'RP');
        Trial   =   GetParam(me,'Trial');
        machine =   GetMachine(RP);
        Trial_Events          = GetParam(me,'Trial_Events');
        LastTrialEventCounter = GetParam(me,'LastTrialEventCounter');
        EventCounter          = GetEventCounter(machine);
        SetParam(me,'LastTrialEventCounter',EventCounter);
        n_events              = EventCounter-LastTrialEventCounter;
        nInputCols            = length(GetInputEvents(machine))+1;
        tevent = zeros(n_events,5)*NaN;
        event_n=1;
        TrialEvent       = GetEvents(machine,max(1,LastTrialEventCounter), EventCounter);
        for i=1:n_events
            tevent(event_n,1)=Trial;            %trial
            tevent(event_n,2)=TrialEvent(i,3);  %event time
            tevent(event_n,3)=TrialEvent(i,1);  %state
            tevent(event_n,5)=TrialEvent(i,4);  %new_state
            event_chan=find(bitget(TrialEvent(i,2),1:nInputCols));
            if length(event_chan)>1
                message(me,'more than one input at the same time');
                for j=1:length(event_chan)
                    tevent(event_n,1)=Trial;            %trial
                    tevent(event_n,2)=TrialEvent(i,3);  %event time
                    tevent(event_n,3)=TrialEvent(i,1);  %state
                    tevent(event_n,4)=event_chan(j);    %chan
                    tevent(event_n,5)=TrialEvent(i,4);  %new_state
                    event_n=event_n+1;
                end
            elseif event_chan
                tevent(event_n,4)=event_chan(1);        %chan
                event_n=event_n+1;
            else
                % message(me,'event too fast to be detected','error');
                tevent(event_n,4)=0;                    %chan
                event_n=event_n+1;
            end
        end
        SetParam(me,'Trial_Events',[Trial_Events ;tevent]);

        %         SaveParamsTrial(me);
        protocols=GetParam('rpbox_5port','protocols','list');
        CallModule(protocols{GetParam('rpbox_5port','protocols')},'state512');
        ReadyToStartTrial(machine);
        SetParam(me,'Trial',Trial+1);

    case 'close'
        SetParam('Control','Run',0);
        Control('Run');
        RP=GetParam(me, 'RP');
        machine =   GetMachine(RP);
        Halt(machine);
        if ~isempty(fake_rp_box) && ismember(fake_rp_box, [3 4]),
            % If we have an @softsm or @SoftSMMarkII State Machine, close
            % it so its window goes away:
            Close(machine);
        end;

    case 'reset'
        set(GetParam(me,'RunRpx','h'),'enable','inactive');
        Message(me,'RP reseting');
        Message('control','wait for RP (RP2/RM1) reseting');
        InitRP;
        UpdateBits;
        SetParam(me,'Trial',0);
        SetParam(me,'State',0);
        SetParam(me,'Clock',0);
        SetParam(me,'EventCounter',0);
        SetParam(me,'Event',0);
        SetParam(me,'EventTime',0);
        SetParam(me,'LastEventCounter',0);
        SetParam(me,'LastTrialEventCounter',0);
        SetParam(me,'Trial_Events',[]);
        Message(me,'RP reseted');
        Message('control','');
        ClearParamTrials(me);
        set(GetParam(me,'RunRPx','h'),'enable','on');

    case 'trigger'
        if existparam(me, 'RP')
            RP=GetParam(me, 'RP');
            machine =   GetMachine(RP);
            Run(machine);
            if Getparam('control','trial')==1 && Getparam('control','slice')==1
                ForceTimeUp(machine);    % Trigger to generate a timeup event to go back to state 0
            end
        end

    case 'runstart_enable',  SetParam(me, 'RunStartEnabled', 1);

    case 'runstart_disable', SetParam(me, 'RunStartEnabled', 0);

    case 'runrpx'
        rehash;
        if GetParam(me,'RunRPx') && GetParam(me, 'RunStartEnabled')
            SetParamUI(me,'RunRPx','backgroundcolor',[0.9 0 0],'string','Running...');
            SetParam(me,'Run','value',1);
            rpbox_5port('trigger');
            rpbox_5port('manual_rpbox_5port_timer');
        else
            SetParamUI(me,'RunRPx','backgroundcolor',[0 0.9 0],'string','RunRPx');
            rpbox_5port('pause');
            SetParam(me,'Run','value',0);
            % auto_save
            filename = sprintf('%s_autosave.mat',GetParam('control','expid'));
            pathname = GetParam('control','datapath');
            save([pathname '\' filename], 'exper');
        end

    case 'manual_rpbox_5port_timer',
        if ismember(fake_rp_box, [3 4]),
            SetParam(me, 'last_flush_time', clock);
            invokeWrapper(GetParam(me, 'RP'), 'FlushQueue');
        end;

        SetParam(me, 'last_update_time', clock);
        rpbox_5port('update');

        while( GetParam(me, 'Run') ),
            if ismember(fake_rp_box, [3 4]), % We drive state machine AND 'update'
                elapsed = etime(clock, GetParam(me, 'last_flush_time'));
                pause_time = 0.08 - elapsed;
                pause(pause_time); drawnow;
                invokeWrapper(GetParam(me, 'RP'), 'FlushQueue');

                elapsed = etime(clock, GetParam(me, 'last_update_time'));
                if elapsed > GetParam('rpbox_5port', 'UpdatePeriod')/1000,
                    SetParam(me,'last_update_time',clock); rpbox_5port('update');
                end;

            else % state mach drives itself; we just worry about 'update'
                elapsed = etime(clock, GetParam(me, 'last_update_time'));
                pause_time = GetParam('rpbox_5port', 'UpdatePeriod')/1000 - elapsed;
                pause(pause_time);
                SetParam(me,'last_update_time',clock); rpbox_5port('update');
            end;
        end;


    case {'halt_RP','pause'}
        if existparam(me, 'RP')
            RP=GetParam(me, 'RP');
            invokeWrapper(RP,'SoftTrg',4);
        end

    case 'send_matrix'
        if nargin==2,     send_matrix(varargin{2});
        elseif nargin==3, send_matrix(varargin{2}, varargin{3});
        else              error('rp_box send_matrix needs one or two args, not more')
        end;

    case 'send_statenames'
        send_statenames(varargin{2});

    case {'loadrpsound' 'loadrp3stereosound'}
        LoadRPSound(varargin{2});

    case {'loadrpsound1' 'loadrp3stereosound1'}
        LoadRPSound(varargin{2}, 1);

    case {'loadrpsound2' 'loadrp3stereosound2'}
        LoadRPSound(varargin{2}, 2);

    case {'loadrpsound3' 'loadrp3stereosound3'}
        LoadRPSound(varargin{2}, 3);

        % ---

    case 'setsamplerate'
        SetSampleRate(varargin{2});

    case 'bit'
        % handle callback from the status panel or called with syntax:
        % rpbox_5port('bit',value);       % 	value is 0 or 1
        % rpbox_5port('bit',bits,value);  % 	bit is from 0 to 7
        if nargin <2
            % called from the object
            val = get(gcbo,'Value');
            h = gcbo;
            bit = get(h,'user');
        else
            % called from a function
            if nargin < 3
                val = varargin{2};
                bit = find(ones(size(val)))-1;
                h   = exper.rpbox_5port.bit_h(bit+1);
            else
                bit = varargin{2};
                val = varargin{3};
                h   = exper.rpbox_5port.bit_h(bit+1);
            end
        end

        RPBitsOut=GetParam(me,'RPBitsOut');
        for i=1:length(val)
            if RPBitsOut(bit(i)+1)>=0
                %change the color of the button
                if val(i)
                    if mod(bit(i),2)
                        set(h(i),'BackgroundColor',[1 1 0],'value',1);
                        RPBitsOut(bit(i)+1)=1;
                    else
                        set(h(i),'BackgroundColor',[1 0 0],'value',1);
                        RPBitsOut(bit(i)+1)=1;
                    end
                else
                    set(h(i),'BackgroundColor',get(gcf,'color'),'value',0);
                    RPBitsOut(bit(i)+1)=0;
                end
                % set the bit
                Bits_HighVal=bin2dec(sprintf('%d%d%d%d%d%d%d%d',RPBitsOut(31:-1:1).*RPBitsOut(31:-1:1)>0));
                if existparam('rpbox_5port', 'RP')
                    RP=GetParam('rpbox_5port', 'RP');
                    invokeWrapper(RP,'SetTagVal','Bits_HighVal',Bits_HighVal);
                    invokeWrapper(RP,'SoftTrg',6);
                end
            end
        end
        SetParam(me,'RPBitsOut',RPBitsOut);

    case 'ao_out'
        % handle callback from the status panel or called with syntax:
        % rpbox_5port('ao_out',value);       % 	value is 0 or 1
        % rpbox_5port('ao_out',bits,value);  % 	bit is from 1 to 3
        if nargin <2
            % called from the object
            val = get(gcbo,'Value'); h = gcbo; AO = get(h,'user');
        else
            % called from a function
            if nargin < 3, val = varargin{2}; AO  = find(ones(size(val)));
            else          AO  = varargin{2}; val = varargin{3};
            end
        end
        RP_AO_Out=GetParam(me,'RP_AO_Out'); RP_AO_Out(AO) = val;
        h = exper.rpbox_5port.AO_h;
        for i=1:3
            if RP_AO_Out(i),  set(h(i),'BackgroundColor',[0 1 0],'value',1);
            else              set(h(i),'BackgroundColor',get(gcf,'color'),'value',0);
            end
        end;
        % set the AO_Out
        if existparam('rpbox_5port', 'RP')
            RP=GetParam('rpbox_5port', 'RP');
            machine=GetMachine(RP);
            for i=1:length(AO)
                if RP_AO_Out(AO(i))
                    Trigger(machine,AO(i));
                else
                    Trigger(machine,-1*AO(i));
                end
            end
        end
%         AOBits_HighVal=bin2dec(sprintf('%d%d%d',RP_AO_Out(3:-1:1).*RP_AO_Out(3:-1:1)>0));
%             invokeWrapper(RP,'SetTagVal','AOBits_HighVal',AOBits_HighVal);
        SetParam(me,'RP_AO_Out',RP_AO_Out);

    case 'soft_trg'
        % handle callback from the status panel or called with syntax:
        % rpbox_5port('soft_trg',value);       % 	value is 1 to 4
        % soft_trg1 : time up, next state
        % soft_trg2 : reset counter
        % soft_trg3 : running
        % soft_trg4 : stop running

        if nargin <2
            % called from the object
            h = gcbo;
            val = get(h,'user');
        else
            % called from a function
            val = varargin{2};
        end


        % set the SoftTrg
        if existparam('rpbox_5port', 'RP')
            RP=GetParam('rpbox_5port', 'RP');
            for i=1:length(val)
                invokeWrapper(RP,'SoftTrg',val);
            end
        end


    case 'forcestate0',
        invokeWrapper(GetParam(me, 'RP'), 'ForceState0');

    case 'protocols'
        pID         = GetParam(me,'protocols');
        pList       = GetParam('rpbox_5port','protocols','list');

        % Sometimes the saved preferences muck with this thing, and it
        % has the wrong value on startup-- let's make sure that it is
        % in range:
        userID      = GetParam(me,'protocols','user');
        if userID > length(pList), userID = 1; end;

        LastProtocol= lower(pList{userID});
        NewProtocol = lower(pList{pID});
        if ~strcmpi(LastProtocol,'')
            if isfield(exper, LastProtocol),
                ModuleClose(LastProtocol);
            end;
        end
        if ~strcmpi(NewProtocol,'')
            if ismember(fake_rp_box, [2 3 4]),
                invokeWrapper(GetParam(me, 'RP'), 'Initialize');
                invokeWrapper(GetParam(me, 'RP'), 'Run');
                invokeWrapper(GetParam(me, 'RP'), 'ForceState0');
                SetParam(me,'EventCounter',0);
                SetParam(me,'Event',0);
                SetParam(me,'EventTime',0);
                SetParam(me,'LastEventCounter',0);
                SetParam(me,'LastTrialEventCounter',0);
                SetParam(me,'Trial_Events',[]);
            end;
            ModuleInit(NewProtocol);
        end
        SetParam(me, 'ProcessingState512', 0);
        SetParam(me,'protocols','value',pID,'user',pID);
        message(me,'load protocol');


    case {'initrpsound' 'initrp3stereosound'}
        InitRPSound;

    case 'getsoundmachine'
        RPS = GetParam(me, 'RPSound');
        out = GetMachine(RPS);

    case 'getstatemachine'
        RP = GetParam(me, 'RP');
        out = GetMachine(RP);

    case 'setsoundmachine'
        RPS = GetParam(me, 'RPSound');
        out = invokeWrapper(RPS, 'SetMachine', varargin{2});

    case 'setstatemachine'
        RP = GetParam(me, 'RP');
        out = invokeWrapper(RP, 'SetMachine', varargin{2});

    case 'get_state_matrix_nrows',
        if fake_rp_box ==0, out = 512; else out = 513; end;


end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function send_statenames(theStruct)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(isa(theStruct,'SoloParamHandle')),
    theStruct = value(theStruct);
end;
if (~isa(theStruct, 'struct')),
    error('Expected struct for state names!');
end;
RP=GetParam(me, 'RP');
fields=fieldnames(theStruct);
mapping=cell(0,2);
for i=1:length(fields),
    mapping{i, 1} = fields{i};
    mapping{i, 2} = eval(sprintf('theStruct.%s', fields{i}));
end;
invokeWrapper(RP, 'SetStateNames', mapping);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function send_matrix(m, flag)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% m is the state matrix including timer, dio and ao values
% each row has:
%  Cin Cout Lin Lout Rin Rout TimeUp Timer DIO AO
% there can be 1 to 512 rows, the 513th row is end of trial, added here
if size(m,1) > 512
    message(me,'Warning: state 512 will be overwritten!','error');
end

if nargin<2, flag=0; end;
nrows = rpbox_5port('get_state_matrix_nrows');

% fill out the full state matrix into 513 rows
M=zeros(nrows,14); % nrows states and 11 input,1 timer, 2 output
[rows columns]=size(m);
M(1:rows,1:columns)=m;

if flag==0,
    M(513,:)= [ ...
     %  Cin Cout Lin1 Lout1 Rin1 Rout1 Lin2 Lout2 Rin2 Rout2 TimeUp Timer DIO AO
        512  512  512  512   512   512  512  512   512   512    0   99999  0  0]; % State 512 "End Of Trial"
    % Send AO2 after handling parameters ==>Next trial"
else
    % M(51,:)= [ ...
    %  Cin Cout Lin Lout Rin Rout TimeUp Timer DIO AO
    %     1   1    1   1    1   1     0    999   0  0]; % State 512 "End Of Trial"
    % Send AO2 after handling parameters ==>Next trial"
    % message(me, 'Remember to define and return to state 512 in your matrix!', 'error');
end;

RP=GetParam(me, 'RP');

global fake_rp_box;
if fake_rp_box >= 2,
    invokeWrapper(RP, 'WriteTagV', 'StateMatrix', M);
else
    error('5port exp doesn''t work on old RPx machine/FakeRP-lunghao1/2');
end;



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function x = CallProtocol(protocol,func)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % this is the function that calls the correct protocol
% global exper;
% feval(protocol,func);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pMenu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
w=dir([GetParam('rpbox_5port','protocol_path') '\*_5port.m']);
wpn{1}='';
for n=1:length(w)
    wpn{n+1} = w(n).name(1:end-2);
end
SetParam(me,'Protocols','value',1,'list',wpn);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function SetTrigger
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Set AI trigger Function and Trigger repeat
% global exper
%
% if isfield(exper.ai,'daq')
%     ai = exper.ai.daq;
%     if strcmp(ai.running,'On')
%         stop(ai);
%     end
%     set(ai,'TriggerRepeat',Inf);
%     set(ai,'TriggerFcn',{'rpbox_5port'});
%     start(ai);
% end
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function StopTrigger
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Set AI trigger Function and Trigger repeat
% global exper
%
% if isfield(exper.ai,'daq')
%     ai = exper.ai.daq;
%     if strcmp(ai.running,'On')
%         stop(ai);
%     end
%     set(ai,'TriggerRepeat',0);
%     set(ai,'TriggerFcn',{'ai_trig_handler'});
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitRP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Initialize RP and load the finite state machine
%   If an RP object already exists; make sure it's done playing & def writing

currfig = double(gcf);
global exper fake_rp_box state_machine_server FakeActiveXObjects
if existparam(me, 'RP')
    RP=GetParam(me, 'RP');
else
    %create activex object and hidden figure
    RPh=figure('visible','off');
    RP=actxcontrolWrapper('RPco.x',[20 20 60 60],RPh);
    InitParam(me,'RP','value',RP); %param to hold the RP activex object
    InitParam(me,'RPh','value',RPh); %hidden figure for the RP activex object
end
machine = GetMachine(RP);
if isempty(machine)
    if fake_rp_box == 2, % RT-Linux State Machine
        machine = RTLSM(state_machine_server);
        SetParam(me,'RPDevice','value','RTLSM','user',1);
    elseif fake_rp_box == 3, % SoftSMMarkII
        machine = SoftSMMarkII;
        SetParam(me,'RPDevice','value','SoftSMMarkII','user',1);        
        % Look for a sound machine to connect to
        allmachines = ...
            FakeActiveXObjects(2:end, findRnum(FakeActiveXObjects, ...
            'rp_machine'));
        for othermachine = allmachines',
            if isa(othermachine{1}, 'softsound')
                machine = ...
                    SetTrigoutCallback(machine,@playsound,othermachine{1});
            end;
        end;
    end
    mid = find(strcmp(FakeActiveXObjects(:,findRnum(FakeActiveXObjects, ...
        'xhandle')), RP));
    FakeActiveXObjects{mid,findRnum(FakeActiveXObjects,'rp_machine')} =...
        machine;
    SetParam(me,'RPBitsOut',zeros(1,31));
    machine = SetInputEvents(machine, 10, 'ai');
    output_routing = { struct('type', 'dout', ...
        'data', '0-30') ; ...
        struct('type', 'sound', ...
        'data', sprintf('%d',0)) };
    machine = SetOutputRouting(machine, output_routing);
    machine = SetJumpstate(machine,512);
    machine = rpbox_5port('setstatemachine', machine);
else
    machine = Initialize(machine);
end

% invokeWrapper(RP,'Run');
% reset the event counter.
invokeWrapper(RP,'SoftTrg',2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitBits
%setup corresponding DIO out GUI buttons according to RPDevice
global exper

RPDevice=GetParam(me,'RPDevice');
fig=findobj('type','figure','tag','rpbox_5port');
if ~isempty(fig)
    for i=2:2:31 % Max # of Dio outs
        name = sprintf('%d', i-1);
        % status panel
        h = uicontrol(fig,'string',name,'style','toggle','pos',[((i/2-1)*16)+5 155 16 16], ...
            'value', 0, 'tag', 'Bit', 'user', i-1, 'callback', callback, ...
            'BackgroundColor', get(fig,'color'));

        % save a set of handles to the toggles, which in turn
        % reference the bits
        exper.rpbox_5port.bit_h(i) = h;
    end
    for i=1:2:31 % Max # of Dio outs
        name = sprintf('%d', i-1);
        % status panel
        h = uicontrol(fig,'string',name,'style','toggle','pos',[(((i-1)/2)*16)+5 175 16 16], ...
            'value', 0, 'tag', 'Bit', 'user', i-1, 'callback', callback, ...
            'BackgroundColor', get(fig,'color'));

        % save a set of handles to the toggles, which in turn
        % reference the bits
        exper.rpbox_5port.bit_h(i) = h;
    end
    uicontrol(fig,'string','BitsOut','style','text','tag','RPDeviceBits',...
        'pos',[15 193 60 16],'BackgroundColor', get(fig,'color'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateBits
%Update corresponding DIO out GUI buttons according to RPDevice
global exper

RPDevice=GetParam(me,'RPDevice');
BitsAvailable=ones(1,31);
BitsAvailable(find(GetParam(me,'RPBitsOut')==-1))=0;
enable_str={'off','on'};
fig=findobj('type','figure','tag','rpbox_5port');
if ~isempty(fig)
    for i=1:31 % Max # of Dio outs
        set(exper.rpbox_5port.bit_h(i),'enable',enable_str{BitsAvailable(i)+1});
    end
    set(findobj(fig,'tag','RPDeviceBits'),'string',[RPDevice ' BitsOut'])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitAO
%setup corresponding DIO out GUI buttons according to RPDevice
global exper

RPDevice=GetParam(me,'RPDevice');
fig=findobj('type','figure','tag','rpbox_5port');
if ~isempty(fig)
    uicontrol(fig,'string','AO Out','style','text','tag','RPDeviceAO',...
        'pos',[190 135 60 16],'BackgroundColor', get(fig,'color'));
    for i=1:3 % Max # of AO outs
        name = sprintf('%d', i);
        % status panel
        h = uicontrol(fig,'string',name,'style','toggle','pos',[((i-1)*16)+150 135 16 16], ...
            'value', 0, 'tag', 'AO_out', 'user', i, 'callback', callback, ...
            'BackgroundColor', get(fig,'color'));

        % save a set of handles to the toggles, which in turn
        % reference the bits
        exper.rpbox_5port.AO_h(i) = h;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitSoftTrg
%setup corresponding DIO out GUI buttons according to RPDevice
global exper

RPDevice=GetParam(me,'RPDevice');
fig=findobj('type','figure','tag','rpbox_5port');
if ~isempty(fig)
    uicontrol(fig,'string','Soft_Trg','style','text','tag','RPDeviceAO',...
        'pos',[174 119 60 16],'BackgroundColor', get(fig,'color'));
    % status panel
    h = uicontrol(fig,'string','1','style','push','pos',[150 119 16 16], ...
        'value', 0, 'tag', 'Soft_Trg', 'user', 1, 'callback', callback, ...
        'BackgroundColor', get(fig,'color'));

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	Initialize RP and load the finite state machine
%   If an RP object already exists; make sure it's done playing & def
%   writing
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitRPSound

currfig = double(gcf);
global exper fake_rp_box sound_machine_server FakeActiveXObjects
if existparam(me, 'RPSound')
    RPS=GetParam(me, 'RPSound');
else
    %create activex object and hidden figure
    RPSh=figure('visible','off');
    RPS=actxcontrolWrapper('RPco.x',[20 20 60 60],RPSh);
    InitParam(me,'RPSound','value',RPS); %param to hold the RP activex object
    InitParam(me,'RPSh','value',RPSh); %hidden figure for the RP activex object
end
machine = GetMachine(RPS);
if isempty(machine)
    if fake_rp_box == 2,
        machine = RTLSoundMachine(sound_machine_server);
    elseif fake_rp_box==3 | fake_rp_box==4, %state machine is object-based
        machine = softsound;
        if (fake_rp_box == 3),
            % in SoftSMMarkII we allow all trigs in the range
            % [-127,127]
            machine = SetAllowedTrigs(machine, [ -127:127 ]);
        end;
        % Look for a state machine to connect to
        rnum = findRnum(FakeActiveXObjects, 'rp_machine');
        allmachines = FakeActiveXObjects(2:end, rnum);
        for i=1:length(allmachines),
            if (isa(allmachines{i}, 'softsm') | isa(allmachines{i}, 'SoftSMMarkII')),
                allmachines{i} = ...
                    SetTrigoutCallback(allmachines{i},@playsound,machine);
                FakeActiveXObjects{i+1,rnum} = allmachines{i};
            end;
        end;
    end;
    mid = find(strcmp(FakeActiveXObjects(:,findRnum(FakeActiveXObjects, ...
        'xhandle')), RPS));
    FakeActiveXObjects{mid,findRnum(FakeActiveXObjects,'rp_machine')} =...
        machine;
else
    machine = Initialize(machine);
end

if ismember(fake_rp_box, 2)
    invokeWrapper(RPS, 'SetSampleRate', 200000);
elseif ismember(fake_rp_box, [3 4]), % if using the object software
    % sound, or RT Linux sound, set
    % samprate
    invokeWrapper(RPS, 'SetSampleRate', 48828);
end;
% invokeWrapper(RPS,'Run');
figure(currfig);

% invokeWrapper(RPS,'SoftTrg',6);    %disable trigger to prevent unwanted trigger
% invokeWrapper(RPS,'SoftTrg',2);    % Stop and Reset

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%    LoadRPSound
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function LoadRPSound(beep, id)   % loads beep(id) sounds. id is an optional param and may be a vector

RPS=GetParam('rpbox_5port', 'RPSOund');
machine=GetMachine(RPS);
if size(beep{1},2)==2, beep{1} = beep{1}'; end; % turn it into a rows matrix
if length(beep)>=2 && rows(beep{2})>cols(beep{2}), beep{2} = beep{2}'; end;
if length(beep)>=3 && rows(beep{3})>cols(beep{3}), beep{3} = beep{3}'; end;
if nargin<2, id = 1:length(beep); end;

global fake_rp_box;
for i=1:length(id)
    if id(i)==1 && ismember(fake_rp_box, [0 1 3 4]),
        machine = LoadSound(machine, 1, beep{1}(1,:), 'left');
        if size(beep{1},1)>1
            machine = LoadSound(machine, 1, beep{1}(2,:), 'right');
        end
    else
        machine = LoadSound(machine, id(i), beep{id(i)});
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function machine=GetMachine(RP)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global FakeActiveXObjects
if nargin==0
    RP = GetParam(me, 'RP');
end
id = find(strcmp(FakeActiveXObjects(1,:), 'xhandle'));
mid = find(strcmp(FakeActiveXObjects(:,id), RP));
machine = FakeActiveXObjects{mid,  find(strcmp(FakeActiveXObjects(1,:), 'rp_machine'))};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=me
% Simple function for getting the name of this m-file.
out=lower(mfilename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = callback
out = [lower(mfilename) ';'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [id] = findRnum(cellname, str)
id = find(strcmp(cellname(1,:), str));
return;