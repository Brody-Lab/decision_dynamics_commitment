function out=RPbox(varargin)
global exper

if nargin > 0 
    if isobject(varargin{1}) & strcmp(varargin{1}.Type,'Analog Input')
        action = 'RPtrig';
    else
        action = lower(varargin{1});
    end
else
    action = lower(get(gcbo,'tag'));
end




switch action
    
    case 'init'
        message('control','Initializing RPBox');
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
        % rpTimer=timer('TimerFcn','rpbox(''update'');','StopFcn','rpbox(''update'');','Period',GetParam(me,'UpdatePeriod')/1000,'ExecutionMode','fixedDelay','TasksToExecute',Inf);
        % InitParam(me,'rpTimer','value',rpTimer);
        InitParam(me, 'last_time', 'value', clock);
        InitParam(me,'EventTime','ui','disp','value',0,'pref',0,'pos',[h n*vs hs*.7 vs]); n=n+1; 
        SetParamUI(me,'EventTime','label','Event Time');    
        InitParam(me,'RunRPx','value',0,'ui','togglebutton','pref',0,'units','normal','pos',[hs*1.45 (n-2)*vs hs*.7 vs*2]);
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
        InitParam(me, 'ProcessingState35', 'value', 0);
        InitParam(me,'RPDevice','value','');
        InitParam(me,'RPBitsOut','vlaue',[]);
        InitParam(me,'RPBitsAva','vlaue',[]);
        InitParam(me,'RP_AO_Out','value',[0 0 0]);
        InitSoftTrg;
        InitRP;
        InitAO;
        InitBits; n=n+1.5;
        UpdateBits;
        InitParam(me,'Protocols','ui','popupmenu','list',{' '},'value',1,'user',1,'pos',[h n*vs hs*1.5 vs]); n=n+1;
        pMenu;    % setup menu for protocols
        
        % message box
        uicontrol(fig,'tag','message','style','edit',...
            'enable','inact','horiz','left','pos',[h n*vs hs*2 vs]); n = n+1;
        
        set(fig,'pos',[65 461-n*vs hs*2+10 n*vs],'visible','on');
        message('control','');
        
        
    case 'trialready'
        message(me,'');
        
    case 'update'
        if existparam(me, 'RP')
            RP=GetParam(me, 'RP');
            SetParam(me,'NewEvent',0);
            LastEventCounter=GetParam(me,'LastEventCounter');
            State   =       invokeWrapper(RP,'GetTagVal','State');
            EventCounter=   invokeWrapper(RP,'GetTagVal','EventCounter');
            Event       =   invokeWrapper(RP,'ReadTagVex','Event',LastEventCounter,EventCounter-LastEventCounter,'F32','F64',1);
            EventTime  =   invokeWrapper(RP,'ReadTagVex','EventTime',LastEventCounter,EventCounter-LastEventCounter,'F32','F64',1);
            Clock   =       invokeWrapper(RP,'GetTagVal','Clock');

            localProcessingState35 = GetParam(me, 'ProcessingState35');
            localFoundState35Flag  = 0; 

            SetParam(me,'State',State);
            SetParam(me,'Clock',Clock);
            if EventCounter>LastEventCounter
                SetParam(me,'NewEvent',1);
                SetParam(me,'EventCounter',EventCounter);
                n_event=EventCounter-LastEventCounter;
                state=[];
                chan=[];
                evnt_t=[];
                event_n=1;
                for i=1:n_event
                    chan_chk=find(bitget(Event(i),1:7));
                    state(event_n)=floor(Event(i)/(2^7));
                    evnt_t(event_n)=EventTime(i);
                    if debugging, ch_chan_chk = chan_chk; if isempty(chan_chk), ch_chan_chk=0; end; fp = fopen('debug_out.txt', 'a'); fprintf(fp, '   State is %d, Channel is %d  (ProcessingState35 is %d; id=%d, time=%g)\n', state(event_n), ch_chan_chk, localProcessingState35, LastEventCounter+i, EventTime(i)); fclose(fp); end;
                    if state(event_n) == 35  
                        if localProcessingState35==0,
                            if debugging, fp = fopen('debug_out.txt', 'a'); fprintf(fp, 'Found a state 35 and ProcessingState35==0! Setting local flag.\n'); fclose(fp); end;
                            localFoundState35Flag = 1;    
                        else
                            if debugging, fp = fopen('debug_out.txt', 'a'); fprintf(fp, 'Found a state 35 but ProcessingState35==1. NOT setting local flag.\n'); fclose(fp); end;
                        end                            
                    elseif state(event_n) == 0
                        if debugging, fp = fopen('debug_out.txt', 'a'); fprintf(fp, 'Found a state 0! setting ProcessingState35 to 0.\n'); fclose(fp); end;
                        if localProcessingState35==1,
                            localProcessingState35 = 0;
                            SetParam(me, 'ProcessingState35', 0);
                        end;
                    end;
                    if length(chan_chk)>1
                        message(me,'more than one input at the same time');
                        for j=1:length(chan_chk)
                            state(event_n)=floor(Event(i)/(2^7));
                            chan(event_n)=chan_chk(j);
                            evnt_t(event_n)=EventTime(i);
                            event_n=event_n+1;
                        end
                    elseif chan_chk
                        chan(event_n)=chan_chk(1);
                        event_n=event_n+1;
                    else
                        message(me,'event too fast to be detected','error');
                        chan(event_n)=0;
                        event_n=event_n+1;
                    end
                end
                SetParam(me,'Event','value',[state(end),chan(end)],'user',[state',chan',evnt_t']);
                SetParam(me,'EventTime','value',EventTime(end));
                SetParam(me,'LastEventCounter',EventCounter);
            else
                SetParam(me,'Event','user',[]);
            end
            list=getparam(me,'protocols','list');
            CallModules(list(getparam(me,'protocols')),'update');

            RefreshedEventCounter=   invokeWrapper(RP,'GetTagVal','EventCounter');
            if debugging,
                if RefreshedEventCounter ~= EventCounter,
                    fp = fopen('debug_out.txt', 'a'); fprintf(fp, '\nEventCounter=%d RefreshedEventCounter=%d State=%g\n\n', EventCounter, RefreshedEventCounter, State); fclose(fp);
                end;
            end;
            % if (RefreshedEventCounter==EventCounter & State == 35)  |  localFoundState35Flag
            if localFoundState35Flag
                if debugging, 
                    fp = fopen('debug_out.txt', 'a'); 
                    fprintf(fp, '\nCurrent clock is %g\n', invokeWrapper(RP, 'GetTagVal', 'Clock'));
                    if State==35, fprintf(fp, 'Current state, not in event queue yet, is state 35.\n');
                    else          fprintf(fp, 'Flag indicating a find of state 35 was found.\n');  
                    end;
                    fclose(fp);
                end;
                if localProcessingState35==0, 
                    if debugging, fp = fopen('debug_out.txt', 'a'); fprintf(fp, '   ProcessingState35 was 0, setting ProcessingState35 to 1 and proceeding\n'); fclose(fp); end;
                    SetParam(me, 'ProcessingState35', 1); localProcessingState35 = 1;
                    rpbox('state35'); 
                    if debugging, fp = fopen('debug_out.txt', 'a'); fprintf(fp, '   Finished state35 routine in Protocol, set SoftTrg10\n\n'); fclose(fp); end;
                else
                    if debugging, fp = fopen('debug_out.txt', 'a'); fprintf(fp, '   ProcessingState35 was 1, doing nothing.\n'); fclose(fp); end;
                end;
            elseif State == 0
                if debugging, fp = fopen('debug_out.txt', 'a'); fprintf(fp, 'Outside queue, but found a state 0: setting ProcessingState35 to 0.\n'); fclose(fp); end;
                if localProcessingState35==1, SetParam(me, 'ProcessingState35', 0); localProcessingState35 = 0; end;
            end;
            
            % if ismember(State,[35]), rpbox('state35'); end
        end
        
        
    case 'state35'
        RP      =   GetParam(me, 'RP');
        Trial   =   GetParam(me,'Trial');
        State   =   invokeWrapper(RP,'GetTagVal','State');
        Trial_Events            = GetParam(me,'Trial_Events');
        LastTrialEventCounter   = GetParam(me,'LastTrialEventCounter');
        EventCounter            = invokeWrapper(RP,'GetTagVal','EventCounter');
        SetParam(me,'LastTrialEventCounter',EventCounter);
        n_events = EventCounter-LastTrialEventCounter;
        
        TrialEvent       = invokeWrapper(RP,'ReadTagVex','Event',LastTrialEventCounter,n_events,'F32','F64',1);
        TrialEventTimer  = invokeWrapper(RP,'ReadTagVex','EventTime',LastTrialEventCounter,n_events,'F32','F64',1);
        tevent = [];
        event_n=1;
        for i=1:n_events
            tevent(event_n,1)=Trial;      %trial
            tevent(event_n,2)=TrialEventTimer(i);               %event time
            tevent(event_n,3)=floor(TrialEvent(i)/(2^7));       %state

            event_chan=find(bitget(TrialEvent(i),1:7));
            if length(event_chan)>1
                message(me,'more than one input at the same time');
                for j=1:length(event_chan)
                    tevent(event_n,1)=Trial;      %trial
                    tevent(event_n,2)=TrialEventTimer(i);               %event time
                    tevent(event_n,3)=floor(TrialEvent(i)/(2^7));       %state
                    tevent(event_n,4)=event_chan(j);                    %chan
                    event_n=event_n+1;
                end
            elseif event_chan
                tevent(event_n,4)=event_chan(1);                   %chan
                event_n=event_n+1;
            else
                message(me,'event too fast to be detected','error');
                tevent(event_n,4)=0;                    %chan
                event_n=event_n+1;
            end            
        end
        SetParam(me,'Trial_Events',[Trial_Events ;tevent]);
        
%         SaveParamsTrial(me);
        protocols=GetParam('rpbox','protocols','list');
        CallModule(protocols{GetParam('rpbox','protocols')},'state35') 
        invokeWrapper(RP,'SoftTrg',10);    % Trigger to generate a timeup event to go back to state 0
        SetParam(me,'Trial',Trial+1);

        
    case 'close'
        SetParam('Control','Run',0);
        Control('Run');
        RP=GetParam(me, 'RP');
        invokeWrapper(RP,'SoftTrg',4);
        invokeWrapper(RP,'SoftTrg',7);
        invokeWrapper(RP,'SoftTrg',9);
        
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
        set(GetParam(me,'RunRPx','h'),'enable','on');
        Message(me,'RP reseted');
        Message('control','');
        
        ClearParamTrials(me);
        
    case 'trigger'
        if existparam(me, 'RP')
            RP=GetParam(me, 'RP');
            State   =    invokeWrapper(RP,'GetTagVal','State');
            invokeWrapper(RP,'SoftTrg',3);
            if Getparam('control','trial')==1 & Getparam('control','slice')==1
                invokeWrapper(RP,'SoftTrg',1);    % Trigger to generate a timeup event to go back to state 0
            end
        end
  
    case 'runrpx'
        if GetParam(me,'RunRPx')
            SetParamUI(me,'RunRPx','backgroundcolor',[0.9 0 0],'string','Running...');
            SetParam(me,'Run','value',1);
            rpbox('trigger');            
            rpbox('manual_rpbox_timer');
        else
            SetParamUI(me,'RunRPx','backgroundcolor',[0 0.9 0],'string','RunRPx');
            rpbox('pause');
            SetParam(me,'Run','value',0);
        end

    case 'manual_rpbox_timer',
        SetParam(me, 'last_time', clock); rpbox('update');
        while( GetParam(me, 'Run') ),
            elapsed = etime(clock, GetParam(me, 'last_time'));
            pause_time = GetParam('rpbox', 'UpdatePeriod')/1000 - elapsed;
            % fprintf(1, 'Pause time = %g\n', pause_time);
            pause(pause_time);
            SetParam(me,'last_time',clock); rpbox('update');
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
        
    case 'loadrpsound'
        LoadRPSound(varargin{2});

    case 'loadrpsound1'
        LoadRPSound(varargin{2}, 1);

    case 'loadrpsound2'
        LoadRPSound(varargin{2}, 2);

    case 'loadrpsound3'
        LoadRPSound(varargin{2}, 3);
        
        % ---
        
    case 'loadrp3stereosound'
        LoadRP3StereoSound(varargin{2});

    case 'loadrp3stereosound1'
        LoadRP3StereoSound(varargin{2}, 1);

    case 'loadrp3stereosound2'
        LoadRP3StereoSound(varargin{2}, 2);

    case 'loadrp3stereosound3'
        LoadRP3StereoSound(varargin{2}, 3);

       % ---
       
    case 'loadrpstereosound'
        LoadRPStereoSound(varargin{2});
        
    case 'bit'
        % handle callback from the status panel or called with syntax:
        % rpbox('bit',value);       % 	value is 0 or 1        
        % rpbox('bit',bits,value);  % 	bit is from 0 to 7
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
                h   = exper.rpbox.bit_h(bit+1);
            else
                bit = varargin{2};
                val = varargin{3};
                h   = exper.rpbox.bit_h(bit+1);                
            end
        end
        
        RPBitsOut=GetParam(me,'RPBitsOut');
        for i=1:length(val)
            if RPBitsOut(bit(i)+1)>=0
                %change the color of the button 
                if val(i)
                    set(h(i),'BackgroundColor',[0 1 0],'value',1);
                    RPBitsOut(bit(i)+1)=1;
                else
                    set(h(i),'BackgroundColor',get(gcf,'color'),'value',0);
                    RPBitsOut(bit(i)+1)=0;
                end
                % set the bit
                Bits_HighVal=bin2dec(sprintf('%d%d%d%d%d%d%d%d',RPBitsOut(8:-1:1).*RPBitsOut(8:-1:1)>0));
                if existparam('rpbox', 'RP')
                    RP=GetParam('rpbox', 'RP');
                    invokeWrapper(RP,'SetTagVal','Bits_HighVal',Bits_HighVal);
                    invokeWrapper(RP,'SoftTrg',6);            
                end
            end
        end
        SetParam(me,'RPBitsOut',RPBitsOut);
        
    case 'ao_out'
        % handle callback from the status panel or called with syntax:
        % rpbox('ao_out',value);       % 	value is 0 or 1        
        % rpbox('ao_out',bits,value);  % 	bit is from 1 to 3
        if nargin <2 
            % called from the object
            val = get(gcbo,'Value'); h = gcbo; AO = get(h,'user');
        else
            % called from a function
            if nargin < 3 val = varargin{2}; AO  = find(ones(size(val))); 
            else          AO  = varargin{2}; val = varargin{3};
            end
        end
        
        RP_AO_Out=GetParam(me,'RP_AO_Out'); RP_AO_Out(AO) = val; 
        if RP_AO_Out(1), RP_AO_Out(3) = 0; end; % sounds 1 and 3 share the same analog channel
        h = exper.rpbox.AO_h;
        
        for i=1:3
            if RP_AO_Out(i),  set(h(i),'BackgroundColor',[0 1 0],'value',1);
            else              set(h(i),'BackgroundColor',get(gcf,'color'),'value',0);
            end
            % set the AO_Out
            AOBits_HighVal=bin2dec(sprintf('%d%d%d',RP_AO_Out(3:-1:1).*RP_AO_Out(3:-1:1)>0));
            if existparam('rpbox', 'RP')
                RP=GetParam('rpbox', 'RP');
                invokeWrapper(RP,'SetTagVal','AOBits_HighVal',AOBits_HighVal);
                invokeWrapper(RP,'SoftTrg',8); 
            end
        end
        SetParam(me,'RP_AO_Out',RP_AO_Out);

    case 'soft_trg'
        % handle callback from the status panel or called with syntax:
        % rpbox('soft_trg',value);       % 	value is 1 to 4
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
        if existparam('rpbox', 'RP')
            RP=GetParam('rpbox', 'RP');
            for i=1:length(val)
                invokeWrapper(RP,'SoftTrg',val);
            end
        end
    

    case 'protocols'
        pID         = GetParam(me,'protocols');
        pList       = GetParam('rpbox','protocols','list');
        LastProtocol= lower(pList{GetParam(me,'protocols','user')});
        NewProtocol = lower(pList{pID});        
        if ~strcmpi(LastProtocol,'')
            if isfield(exper, LastProtocol),
                ModuleClose(LastProtocol);
            end;
        end
        if ~strcmpi(NewProtocol,'')
            ModuleInit(NewProtocol);
        end
        SetParam(me, 'ProcessingState35', 0);
        SetParam(me,'protocols','value',pID,'user',pID)
        message(me,'load protocol');
        
    case 'initrpsound'
        InitRPSound;
        
    case 'initrp3stereosound'
        InitRP3StereoSound;
        
    case 'initrpstereosound'
        InitRPStereoSound;        
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function send_matrix(m, flag)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% m is the state matrix including timer, dio and ao values
% each row has:
%  Cin Cout Lin Lout Rin Rout TimeUp Timer DIO AO  
% there can be 1 to 35 rows, the 36th row is end of trial, added here
if size(m,1) > 35
    message(me,'Warning: state 35 will be overwritten!','error');
end

if nargin<2, flag=0; end;

% fill out the full state matrix into 36 rows
M=zeros(128,10); % 128 states and 7 input,1 timer, 2 output
[rows columns]=size(m);
M(1:rows,1:columns)=m;

if flag==0,
    M(36,:)= [ ...
     %  Cin Cout Lin Lout Rin Rout TimeUp Timer DIO AO  
        35  35   35  35   35   35    0    999   0  0]; % State 35 "End Of Trial"
    % Send AO2 after handling parameters ==>Next trial"
else
     % M(36,:)= [ ...
     %  Cin Cout Lin Lout Rin Rout TimeUp Timer DIO AO  
     %     1   1    1   1    1   1     0    999   0  0]; % State 35 "End Of Trial"
    % Send AO2 after handling parameters ==>Next trial"
    message(me, 'Remember to define and return to state 35 in your matrix!', 'error');
end;

state = M(:,1:end-3);
state_addr = state_to_state_addr(state); % convert to address table used by RP
timedur = M(:,end-2)';
dio_out = M(:,end-1)';
ao_out = M(:,end)';

RP=GetParam(me, 'RP');

global fake_rp_box;
if fake_rp_box == 2,
   invokeWrapper(RP, 'WriteTagV', 'StateMatrix', M);
else
   invokeWrapper(RP,'WriteTagV','StateMatrix',0,state_addr);
   invokeWrapper(RP,'WriteTagV','TimDurMatrix',0,timedur);
   invokeWrapper(RP,'WriteTagVEX','DIO_Out',0,'I32',dio_out); % 'I32' uses Word(32bit) format for DIO-Out to Word-Out
   invokeWrapper(RP,'WriteTagVEX','AO_Out',0,'I32',ao_out); % 'I32' uses Word(32bit) format for AO-Out to Word-Out
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function state_addr = state_to_state_addr(state)    % made by Gonzalo

% takes the normal state matrix and expands it into the full state addresss
% matrix 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%create matrix of indexes
columns = 7;
rows=size(state,1);  % number of states (rows)

% we now define the ram matrix
state_addr=zeros(1,rows*128);

% The matrix should be "stable", if no input , it should stay in the same state
state_addr(1:128:(rows*128))=(1:rows)-1;

%             Cin Cout Lin Lout Rin Rout TimeUp
channel_value=[1    2   4    8   16  32   64];

for i=1:rows
    for j=1:columns
        if j==7
            addr_index=[1    2   4    8   16  32 0]+channel_value(j)+(i-1)*128; 
        else
            addr_index=(i-1)*128+channel_value(j); 
        end
        state_addr(addr_index+1)=state(i,j);        
    end
end




% 
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
global exper

w=what(GetParam(me,'protocol_path'));
wp = w.m;
wpn{1}='';
for n=1:length(wp)
    wpn{n+1} = wp{n}(1:end-2);
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
%     set(ai,'TriggerFcn',{'RPbox'});
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
global exper
if existparam(me, 'RP')
    RP=GetParam(me, 'RP');
    if ~isempty(RP)
        if existparam(me, 'DefID')
            DefID=GetParam(me, 'DefID');
            while invokeWrapper(RP,'DefStatus',DefID)>0  %% wait for def write 
                Message(me, sprintf('waiting for def write...'));
                pause( .1 );
            end
        end
    end
end



%create activex object and hidden figure
RPh=figure('visible','off');
RP=actxcontrolWrapper('RPco.x',[20 20 60 60],RPh);

%store these in params
InitParam(me,'RP','value',RP); %param to hold the RP activex object
InitParam(me,'RPh','value',RPh); %hidden figure for the RP activex object

invokeWrapper(RP,'Halt');
invokeWrapper(RP,'ClearCOF');
if invokeWrapper(RP,'ConnectRP2','GB',1)         %default use RP2
    if ~invokeWrapper(RP,'LoadCOF',[GetParam('rpbox','protocol_path') filesep 'RP2Box.rco']);
        Message(me, 'LoadCOF Failure');
        error('failed to load RP2 control object file. Power cycle RP2 and try again.')
    else
        SetParam(me,'RPDevice','value','RP2','user',1);
        SetParam(me,'RPBitsOut',[0 0 0 0 0 0 0 0]);
    end
elseif invokeWrapper(RP,'ConnectRP2','USB',1)     % connect to RP2 using 'USB' method
    if ~invokeWrapper(RP,'LoadCOF',[GetParam('rpbox','protocol_path') filesep 'RP2Box.rco']);
        Message(me, 'LoadCOF Failure');
        error('failed to load RP2 control object file. Power cycle RP2 and try again.')
    else
        SetParam(me,'RPDevice','value','RP2','user',1);
        SetParam(me,'RPBitsOut',[0 0 0 0 0 0 0 0]);
    end
elseif invokeWrapper(RP,'ConnectRM1','USB',1)     % connect to RM1 using 'USB' method
    if ~invokeWrapper(RP,'LoadCOF',[GetParam('rpbox','protocol_path') filesep 'RM1Box.rco']);
        Message(me, 'LoadCOF Failure');
        error('failed to load RM1 control object file. Power cycle RM1 and try again.')
    else
        SetParam(me,'RPDevice','value','RM1','user',1);
        SetParam(me,'RPBitsOut',[0 0 0 0 0 -1 -1 -1]);
    end
else
    Message(me, 'Connection Failure');
    error('failed to establish RP2/RM1 connection. Power cycle RP2/RM1 and try again.')
    return;
end
invokeWrapper(RP,'Run');

% reset the event counter.
invokeWrapper(RP,'SoftTrg',2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitBits
%setup corresponding DIO out GUI buttons according to RPDevice
global exper

RPDevice=GetParam(me,'RPDevice');
fig=findobj('type','figure','tag','rpbox');
if ~isempty(fig)
    for i=1:8 % Max # of Dio outs
        name = sprintf('%d', i-1);
        % status panel
        h = uicontrol(fig,'string',name,'style','toggle','pos',[((i-1)*16)+5 155 16 16], ...
            'value', 0, 'tag', 'Bit', 'user', i-1, 'callback', callback, ...
            'BackgroundColor', get(fig,'color'));
        
        % save a set of handles to the toggles, which in turn
        % reference the bits
        exper.rpbox.bit_h(i) = h;
    end
    uicontrol(fig,'string',[RPDevice ' BitsOut'],'style','text','tag','RPDeviceBits',...
        'pos',[((i)*16)+15 155 60 16],'BackgroundColor', get(fig,'color'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateBits
%Update corresponding DIO out GUI buttons according to RPDevice
global exper

RPDevice=GetParam(me,'RPDevice');
BitsAvailable=ones(1,8);
BitsAvailable(find(GetParam(me,'RPBitsOut')==-1))=0;
enable_str={'off','on'};
fig=findobj('type','figure','tag','rpbox');
if ~isempty(fig)
    for i=1:8 % Max # of Dio outs
        set(exper.rpbox.bit_h(i),'enable',enable_str{BitsAvailable(i)+1});
    end
    set(findobj(fig,'tag','RPDeviceBits'),'string',[RPDevice ' BitsOut'])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitAO
%setup corresponding DIO out GUI buttons according to RPDevice
global exper

RPDevice=GetParam(me,'RPDevice');
fig=findobj('type','figure','tag','rpbox');
if ~isempty(fig)
    uicontrol(fig,'string','AO Out','style','text','tag','RPDeviceAO',...
        'pos',[172 135 60 16],'BackgroundColor', get(fig,'color'));
    for i=1:3 % Max # of AO outs
        name = sprintf('%d', i);
        % status panel
        h = uicontrol(fig,'string',name,'style','toggle','pos',[((i-1)*16)+132 135 16 16], ...
            'value', 0, 'tag', 'AO_out', 'user', i, 'callback', callback, ...
            'BackgroundColor', get(fig,'color'));
        
        % save a set of handles to the toggles, which in turn
        % reference the bits
        exper.rpbox.AO_h(i) = h;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitSoftTrg
%setup corresponding DIO out GUI buttons according to RPDevice
global exper

RPDevice=GetParam(me,'RPDevice');
fig=findobj('type','figure','tag','rpbox');
if ~isempty(fig)
    uicontrol(fig,'string','Soft_Trg','style','text','tag','RPDeviceAO',...
        'pos',[156 119 60 16],'BackgroundColor', get(fig,'color'));
    % status panel
    h = uicontrol(fig,'string','1','style','push','pos',[132 119 16 16], ...
        'value', 0, 'tag', 'Soft_Trg', 'user', 1, 'callback', callback, ...
        'BackgroundColor', get(fig,'color'));
    
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function InitRPSound
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%	Initialize RP and load the finite state machine
%   If an RP object already exists; make sure it's done playing & def writing
global exper
if existparam(me, 'RPSound')
    RPS=GetParam(me, 'RPSound');
    if ~isempty(RPS)
        if existparam(me, 'DefID')
            DefID=GetParam(me, 'DefID');
            while invokeWrapper(RP,'DefStatus',DefID)>0  %% wait for def write 
                Message(me, sprintf('waiting for def write...'));
                pause( .1 );
            end
        end
    end
end



%create activex object and hidden figure
RPSh=figure('visible','off');
RPS=actxcontrolWrapper('RPco.x',[20 20 60 60],RPSh);

%store these in params
InitParam(me,'RPSound','value',RPS); %param to hold the RP activex object
InitParam(me,'RPSh','value',RPSh); %hidden figure for the RP activex object

% invokeWrapper(RPS,'Halt');
% invokeWrapper(RPS,'ClearCOF');
if invokeWrapper(RPS,'ConnectRP2','GB',2)         %default use second RP2
    if ~invokeWrapper(RPS,'LoadCOF',[GetParam('rpbox','protocol_path') filesep '2SoundRP2_2.rco']);
        Message(me, 'LoadCOF Failure');
        error('failed to load RP2 control object file. Power cycle RP2 and try again.')
    else
        InitParam(me,'RPSDevice','value','RP2','user',2);
%         InitParam(me,'RPSBitsOut',[0 0 0 0 0 0 0 0]);
    end
elseif invokeWrapper(RPS,'ConnectRP2','USB',2)     %connect to RP2 using 'USB' method
    if ~invokeWrapper(RPS,'LoadCOF',[GetParam('rpbox','protocol_path') filesep '2SoundRP2_2.rco']);
        Message(me, 'LoadCOF Failure');
        error('failed to load RP2 control object file. Power cycle RP2 and try again.')
    else
        InitParam(me,'RPSDevice','value','RP2','user',2);
%         InitParam(me,'RPSBitsOut',[0 0 0 0 0 0 0 0]);
    end
elseif invokeWrapper(RPS,'ConnectRM1','USB',2)     %connect to RM1 using 'USB' method
    if ~invokeWrapper(RPS,'LoadCOF',[GetParam('rpbox','protocol_path') filesep '2SoundRM1_2.rco']);
        Message(me, 'LoadCOF Failure');
        error('failed to load RM1 control object file. Power cycle RM1 and try again.')
    else
        InitParam(me,'RPSDevice','value','RM1','user',2);
%         InitParam(me,'RPSBitsOut',[0 0 0 0 0 0 0 0]);
    end
else
    Message(me, 'Connection Failure');
    error('failed to establish RP2/RM1 connection. Power cycle RP2/RM1 and try again.')
    return;
end
invokeWrapper(RPS,'Run');


% invokeWrapper(RPS,'SoftTrg',6);    %disable trigger to prevent unwanted trigger
invokeWrapper(RPS,'SoftTrg',2);    % Stop and Reset




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%
%	Initialize RP and load the finite state machine
%   If an RP object already exists; make sure it's done playing & def writing
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

function InitRP3StereoSound



global exper
if existparam(me, 'RPSound')
    RPS=GetParam(me, 'RPSound');
    if ~isempty(RPS)
        if existparam(me, 'DefID')
            DefID=GetParam(me, 'DefID');
            while invokeWrapper(RP,'DefStatus',DefID)>0  %% wait for def write 
                Message(me, sprintf('waiting for def write...'));
                pause( .1 );
            end
        end
    end
end



%create activex object and hidden figure
RPSh=figure('visible','off');
RPS=actxcontrolWrapper('RPco.x',[20 20 60 60],RPSh);

%store these in params
InitParam(me,'RPSound','value',RPS); %param to hold the RP activex object
InitParam(me,'RPSh','value',RPSh); %hidden figure for the RP activex object

% invokeWrapper(RPS,'Halt');
% invokeWrapper(RPS,'ClearCOF');
if invokeWrapper(RPS,'ConnectRM1','USB',2)     %connect to RM1 using 'USB' method
    if ~invokeWrapper(RPS,'LoadCOF',[GetParam('rpbox','protocol_path') filesep '3StereoSoundRM1.rco']);
        Message(me, 'LoadCOF Failure');
        error('failed to load RM1 control object file. Power cycle RM1 and try again.')
    else
        InitParam(me,'RPSDevice','value','RM1','user',2);
%         InitParam(me,'RPSBitsOut',[0 0 0 0 0 0 0 0]);
    end
elseif invokeWrapper(RPS,'ConnectRP2','USB',2)     %connect to RP2 using 'USB' method
    if ~invokeWrapper(RPS,'LoadCOF',[GetParam('rpbox','protocol_path') filesep '2SoundRP2_2.rco']);
        Message(me, 'LoadCOF Failure');
        error('failed to load RP2 control object file. Power cycle RP2 and try again.')
    else
        InitParam(me,'RPSDevice','value','RP2','user',2);
%         InitParam(me,'RPSBitsOut',[0 0 0 0 0 0 0 0]);
    end
elseif invokeWrapper(RPS,'ConnectRP2','GB',2)         %default use second RP2
    if ~invokeWrapper(RPS,'LoadCOF',[GetParam('rpbox','protocol_path') filesep '2SoundRP2_2.rco']);
        Message(me, 'LoadCOF Failure');
        error('failed to load RP2 control object file. Power cycle RP2 and try again.')
    else
        InitParam(me,'RPSDevice','value','RP2','user',2);
%         InitParam(me,'RPSBitsOut',[0 0 0 0 0 0 0 0]);
    end
else
    Message(me, 'Connection Failure');
    error('failed to establish RP2/RM1 connection. Power cycle RP2/RM1 and try again.')
    return;
end
invokeWrapper(RPS,'Run');


% invokeWrapper(RPS,'SoftTrg',6);    %disable trigger to prevent unwanted trigger
% invokeWrapper(RPS,'SoftTrg',2);    % Stop and Reset







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%
%    LoadRP3Stereoound
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

function LoadRP3StereoSound(beep, id)   % loads beep(id) sounds. id is an optional param and may be a vector 

RPS=GetParam('rpbox', 'RPSOund');
RP2_ready=strcmp(GetParam('rpbox','RPSDevice'),'RP2');
if size(beep{1},2)==2, beep{1} = beep{1}'; end; % turn it into a rows matrix
if nargin<2, id = 1:length(beep); end;

for i=1:length(id)  
    if id(i)==1,
        datain_chk = invokeWrapper(RPS,'WriteTagV', 'datain1a', 0, beep{1}(1,:)); %when use with regular speaker
        datain_chk = invokeWrapper(RPS,'WriteTagV', 'datain1b', 0, beep{1}(2,:)); %when use with regular speaker
    else
        datain_chk=invokeWrapper(RPS,'WriteTagV',['datain' num2str(id(i))],0,beep{id(i)}); %when use with regular speaker
        %         datain_chk=invokeWrapper(RPS,'WriteTagV',['datain' num2str(i)],0,beep{i}*10); %when use with sound amplifier
	end
	datalngth_chk=invokeWrapper(RPS,'SetTagVal',['datalngth' num2str(id(i))],length(beep{id(i)}));
end






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%
%    LoadRPSound
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

function LoadRPSound(beep, id)   % loads beep(id) sounds. id is an optional param and may be a vector 

RPS=GetParam('rpbox', 'RPSOund');
RP2_ready=strcmp(GetParam('rpbox','RPSDevice'),'RP2');
if nargin<2, id = 1:length(beep); end;
for i=1:length(id) 
	if RP2_ready
        datain_chk=invokeWrapper(RPS,'WriteTagV',['datain' num2str(id(i))],0,beep{id(i)}*1); %when use with regular speaker
%         datain_chk=invokeWrapper(RPS,'WriteTagV',['datain' num2str(i)],0,beep{i}*10); %when use with sound amplifier
	else
        datain_chk=invokeWrapper(RPS,'WriteTagV',['datain' num2str(id(i))],0,beep{id(i)});
	end
	datalngth_chk=invokeWrapper(RPS,'SetTagVal',['datalngth' num2str(id(i))],length(beep{id(i)}));
end










%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function InitRPStereoSound
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%	Initialize RP and load the finite state machine
%   If an RP object already exists; make sure it's done playing & def writing
global exper
if existparam(me, 'RPStereoSound')
    RPSS=GetParam(me, 'RPStereoSound');
    if ~isempty(RPSS)
        if existparam(me, 'DefID')
            DefID=GetParam(me, 'DefID');
            while invokeWrapper(RP,'DefStatus',DefID)>0  %% wait for def write 
                Message(me, sprintf('waiting for def write...'));
                pause( .1 );
            end
        end
    end
end



%create activex object and hidden figure
RPSSh=figure('visible','off');
RPSS=actxcontrolWrapper('RPco.x',[20 20 60 60],RPSSh);

%store these in params
InitParam(me,'RPStereoSound','value',RPSS); %param to hold the RP activex object
InitParam(me,'RPSSh','value',RPSSh); %hidden figure for the RP activex object

% invokeWrapper(RPSS,'Halt');
% invokeWrapper(RPSS,'ClearCOF');
if invokeWrapper(RPSS,'ConnectRP2','GB',2)         %default use second RP2
    if ~invokeWrapper(RPSS,'LoadCOF',[GetParam('rpbox','protocol_path') filesep 'SSoundRP2_2.rco']);
        Message(me, 'LoadCOF Failure');
        error('failed to load RP2 control object file. Power cycle RP2 and try again.')
    else
        InitParam(me,'RPSSDevice','value','RP2','user',2);
%         InitParam(me,'RPSBitsOut',[0 0 0 0 0 0 0 0]);
    end
elseif invokeWrapper(RPSS,'ConnectRP2','USB',2)     %connect to RP2 using 'USB' method
    if ~invokeWrapper(RPSS,'LoadCOF',[GetParam('rpbox','protocol_path') filesep 'SSoundRP2_2.rco']);
        Message(me, 'LoadCOF Failure');
        error('failed to load RP2 control object file. Power cycle RP2 and try again.')
    else
        InitParam(me,'RPSSDevice','value','RP2','user',2);
%         InitParam(me,'RPSBitsOut',[0 0 0 0 0 0 0 0]);
    end
elseif invokeWrapper(RPSS,'ConnectRM1','USB',2)     %connect to RM1 using 'USB' method
    if ~invokeWrapper(RPSS,'LoadCOF',[GetParam('rpbox','protocol_path') filesep 'SSoundRM1_2.rco']);
        Message(me, 'LoadCOF Failure');
        error('failed to load RM1 control object file. Power cycle RM1 and try again.')
    else
        InitParam(me,'RPSSDevice','value','RM1','user',2);
%         InitParam(me,'RPSBitsOut',[0 0 0 0 0 0 0 0]);
    end
else
    Message(me, 'Connection Failure');
    error('failed to establish RP2/RM1 connection. Power cycle RP2/RM1 and try again.')
    return;
end
invokeWrapper(RPSS,'Run');

invokeWrapper(RPSS,'SoftTrg',2);    % Stop and Reset
invokeWrapper(RPSS,'SoftTrg',4);    % Stop and Reset

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function LoadRPStereoSound(beep)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
RPSS=GetParam('rpbox', 'RPStereoSound');
if strcmp(GetParam('rpbox','RPSSDevice'),'RP2')
    invokeWrapper(RPSS,'WriteTagV','datain1',0,beep{1}*1); %when use with regular speaker
    invokeWrapper(RPSS,'WriteTagV','datain2',0,beep{2}*1); %when use with regular speaker
    invokeWrapper(RPSS,'WriteTagV','datain3',0,beep{3}*1); %when use with regular speaker
    invokeWrapper(RPSS,'WriteTagV','datain4',0,beep{4}*1); %when use with regular speaker
%     invokeWrapper(RPSS,'WriteTagV','datain1',0,beep{1}*10); %when use with sound amplifier
%     invokeWrapper(RPSS,'WriteTagV','datain2',0,beep{2}*10); %when use with sound amplifier
%     invokeWrapper(RPSS,'WriteTagV','datain3',0,beep{3}*10); %when use with sound amplifier
%     invokeWrapper(RPSS,'WriteTagV','datain4',0,beep{4}*10); %when use with sound amplifier
else
    invokeWrapper(RPSS,'WriteTagV','datain1',0,beep{1});
    invokeWrapper(RPSS,'WriteTagV','datain2',0,beep{2});
    invokeWrapper(RPSS,'WriteTagV','datain3',0,beep{3});
    invokeWrapper(RPSS,'WriteTagV','datain4',0,beep{4});
end
invokeWrapper(RPSS,'SetTagVal','datalngth1',length(beep{1}));
invokeWrapper(RPSS,'SetTagVal','datalngth2',length(beep{2}));
invokeWrapper(RPSS,'SetTagVal','datalngth3',length(beep{3}));
invokeWrapper(RPSS,'SetTagVal','datalngth4',length(beep{4}));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=me
% Simple function for getting the name of this m-file.
out=lower(mfilename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = callback
out = [lower(mfilename) ';'];

