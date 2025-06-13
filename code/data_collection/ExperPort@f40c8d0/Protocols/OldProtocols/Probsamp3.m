function [out] = Probsamp3(varargin)

global exper

if nargin > 0 
    action = lower(varargin{1});
else
    action = lower(get(gcbo,'tag'));
end

out=1;  
switch action
    
    case 'init'
        ModuleNeeds(me,{'rpbox'});
        
        SetParam(me,'priority','value',GetParam('rpbox','priority')+1);
        fig = ModuleFigure(me,'visible','off');	
        
        hs = 100;
        h = 5;
        vs = 20;
        n = 0;

        Blnk = 0;
        Ch_A= 2^3;
        Ch_B= 2^4;
       
        LeftSound = 1; % First  sound defined below is the one for the left port. ALWAYS 
        RightSound= 2; % Second sound defined below is the one for the left port. ALWAYS 
        FreqStart = [5000   8000]*2;  %Hz
        FreqEnd   = [7000   6000]*2;  %Hz
        Dur       = [200    200];  %msec
        SPL       = [70     70];  %Max=PPdB SPL
        RampDur   = [50     50];  %edge ramp duration, ms
        Str       = {'sweep 5k to 7k 65dB 250 ms', 'sweep 8k to 6k 75dB 250 ms'};
        OdorCh    = [0     0];
        
        InitParam(me,'ToneFreqStart','value',FreqStart);
        InitParam(me,'ToneFreqEnd',  'value',FreqEnd);
        InitParam(me,'ToneDur','value',Dur/1000);
        InitParam(me,'ToneSPL','value',SPL);
        InitParam(me,'RampDur','value',RampDur);
        InitParam(me,'OdorChannel','value',OdorCh);
        InitParam(me,'LeftSound','value',LeftSound);
        InitParam(me,'RightSound','value',RightSound);
        
        VPS_Freq=[  -1    -1    -1     -1     -1];  %Hz
        VPS_Dur =[  10    10    10     25     25];  %msec
        VPS_SPL =[ -10    65    55     65     55];  %Max=PPdB SPL
        VPS_Str ={'silence'}; %  '10ms-65dBwn' '10ms-55dBwn' '25ms-65dBwn' '25ms-55dBwn'}; 
        InitParam(me,'VPS_Freq','value',VPS_Freq);
        InitParam(me,'VPS_Dur','value',VPS_Dur);
        InitParam(me,'VPS_SPL','value',VPS_SPL);
        TimeOutStrings = {'silence' 'boop-boop'};
        
        n=n+.2;
        InitParam(me,'TotalTrial','value',2000);
        TotalTrial=GetParam(me,'TotalTrial');
        InitParam(me,'Tone_Select','ui','popupmenu','list',Str,'value',1,'user',1,'pos',[h n*vs hs*.85 vs]); 
        SetParamUI(me,'Tone_Select','label','Tone/OdorCh');
        InitParam(me,'Tone_Start','ui','edit','value',0,'pos',[h+hs*1.8 n*vs hs*.6 vs]); % n=n+1;
        SetParamUI(me,'Tone_Start','label','Tone Start');    
        InitParam(me,'ValidTnPoke','ui','edit','value',200,'pos',[h+hs*1.8 n*vs hs*.6 vs],'range',[min(Dur) 2000]); n=n+1;
        SetParamUI(me,'ValidTnPoke','label','ValidTnPoke');    
        % g = exper.probsamp3.param.validtnpoke.range
        InitParam(me,'WaterPort','ui','popupmenu','list',{'Left';'Right';'Both'},'value',1,'user',1,'pos',[h n*vs hs*.85 vs]);
        SetParamUI(me,'WaterPort','label','Water Port');
        InitParam(me,'DirectDeliv','ui','edit','value',0,'pos',[h+hs*1.8 n*vs hs*.6 vs]); % n=n+1;
        SetParamUI(me,'DirectDeliv','label','DirectDeliv');    
        InitParam(me,'LeftProb','ui','edit','value',0.5,'pos',[h+hs*1.8 n*vs hs*.6 vs], 'range', [0 1],'user',1); n=n+1;
        SetParamUI(me,'LeftProb','label','LeftProb');   
        % g = exper.probsamp3.param.leftprob.range
        % InitParam(me,'Schedule','ui','popupmenu','list',{'0' '1' '2' '3' '4' '150 ms' '200 ms' '250ms' '300 ms' '350ms' '400 ms' '450ms' '500ms'},'value',2,'user',2,'pos',[h n*vs hs*.85 vs]);
        % SetParamUI(me,'Schedule','label','Schedule');
        InitParam(me,'RewardAvail','ui','edit','value',5,'pos',[h n*vs hs*.85 vs]);
        SetParamUI(me,'RewardAvail','label','RewardAvail');
        InitParam(me,'LeftWaterValveDur','ui','edit','value',.15,'pos',[h+hs*1.8 n*vs hs*.6 vs]); n=n+1;
        SetParamUI(me,'LeftWaterValveDur','label','LWtrV_Dur');  
        InitParam(me,'TimeOutSound','ui','popupmenu','list',TimeOutStrings,'value',2,'user',1,'pos',[h n*vs hs*0.85 vs]);
        SetParamUI(me,'TimeOutSound', 'label', 'TimeOutSound');
        InitParam(me,'RightWaterValveDur','ui','edit','value',.15,'pos',[h+hs*1.8 n*vs hs*.6 vs]); n=n+1;
        SetParamUI(me,'RightWaterValveDur','label','RWtrV_Dur');    
      
        InitParam(me,'VP_Signal','ui','popupmenu','list',VPS_Str,'value',1,'user',1,'pos',[h n*vs hs*.85 vs]);
        SetParamUI(me,'VP_Signal','label','VP_Signal');
        InitParam(me,'TimeOut','ui','edit','value',2,'pos',[h+hs*1.8 n*vs hs*.6 vs]); n=n+1;
        SetParamUI(me,'TimeOut','label','Time Out');    
        InitParam(me,'TonePokeDur','ui','disp','value',0,'user1',0,'user2',0,'pref',0,'pos',[h n*vs hs*.85 vs]); 
        SetParamUI(me,'TonePokeDur','label','TnPokeDur (ms)');
        InitParam(me,'nTonePoke','ui','disp','value',0,'pref',1,'pos',[h+hs*1.8 n*vs hs*.6 vs]);
        SetParamUI(me,'nTonePoke','label','#TonePoke');
        n=n+1; 
        InitParam(me,'Rewards','ui','disp','value',0,'pos',[h+hs*1.8 n*vs hs*.6 vs]);
        SetParamUI(me,'Rewards','label','Rewards');
        
        InitParam(me,'Schedule','value',1);

        
        % message box
        uicontrol(fig,'tag','message','style','edit',...
            'enable','inact','horiz','left','pos',[h n*vs hs*1.7 vs]); n = n+1;

        % Further controls;
        InitParam(me,'Trials','ui','disp','value',0,'pos',[h+hs*1.8 n*vs hs*.6 vs]); n = n+1;
        SetParamUI(me,'Trials','label','Trials');
        InitParam(me,'Stubbornness','ui','popupmenu','list', {'0' '1'},'value',2,'user',1,'pos',[h n*vs hs*.85 vs]);
        SetParamUI(me,'Stubbornness','label','Stubbornness');
        InitParam(me, 'InterTrial','ui','edit','value',0.25,'pos',[h+hs*1.8 n*vs hs*.6 vs], 'range', [0.1 10]); n=n+1;
        SetParamUI(me,'InterTrial','label','InterTrial');    
        % g = exper.probsamp3.param.intertrial.range

%         InitParam(me,'LeftProb','ui','edit','value',0.5,'pos',[h+hs*1.8 n*vs hs*.6 vs], 'range', [0 1]); n=n+1;
%         SetParamUI(me,'LeftProb','label','LeftProb');   
        
        InitParam(me,'Beep','value',[]);
        beep=InitTones;
        InitParam(me,'vp_sound','value',[]);        
        vp_sound=InitVP_Sound;
        rpbox('InitRPSound');
        % rpbox('LoadRPSound',{beep{GetParam(me,'Tone_Select')},vp_sound{GetParam(me,'VP_Signal')}});
        rpbox('LoadRPSound',{beep{GetParam(me,'Tone_Select')}, make_timeout_sound});
        
        ValidTonePokeDur = ones(1,TotalTrial)*GetParam(me,'ValidTnPoke');
        InitParam(me,'ValidTonePokeDur','value',ValidTonePokeDur);
        RewardAvailDur = ones(1,TotalTrial)*GetParam(me,'RewardAvail');
        InitParam(me,'RewardAvailDur','value',RewardAvailDur);
        PortNumber = double(rand(1,TotalTrial)<=GetParam(me,'LeftProb')); 
        lefts = find(PortNumber); rights = find(~PortNumber);
        PortNumber(lefts) = LeftSound; PortNumber(rights) = RightSound;
        InitParam(me, 'PortNumber', 'value', PortNumber);
        
        InitParam(me,'HitHistory','value',zeros(1,TotalTrial));
        
        change_schedule(GetParam(me,'Schedule'));        
        rpbox('send_matrix', [0 0 0 0 0 0 0 180 0 0]);
        rpbox('send_matrix',state_transition_matrix(NextParam));
        
        set(fig,'pos',[140 461-n*vs hs*3.2 (n+16)*vs],'visible','on');
        plot_schedule;

    case 'trialready'
%         rpbox('send_matrix',state_transition_matrix(NextParam));
        
    case 'trialend'
        
    case 'reset'
        Message('control','wait for RP (RP2/RM1) reseting');
        SetParam(me,'Rewards',0);
        SetParam(me,'nTonePoke',0);
        update_plot;   
        rpbox('InitRPSound');
        rpbox('send_matrix', [0 0 0 0 0 0 0 180 0 0]);
        rpbox('send_matrix',state_transition_matrix(NextParam));
        beep=GetParam(me,'beep');
        vp_sound=GetParam(me,'vp_sound');
        rpbox('LoadRPSound',{beep{GetParam(me,'Tone_Select')},make_timeout_sound});
        Message('control','');
        
    case 'update'
        Event=Getparam('rpbox','event','user'); % [state,chan,event time]
        for i=1:size(Event,1)
            if Event(i,2)==1        %tone poke in
                TonePokeDurUser1=GetParam(me,'TonePokeDur','user1');
                SetParam(me,'TonePokeDur','user1',Event(i,3));
                SetParam(me,'nTonePoke',GetParam(me,'nTonePoke')+1);
            elseif Event(i,2)==2    %tone poke out
                TonePokeDurUser1=GetParam(me,'TonePokeDur','user1');
                SetParam(me,'TonePokeDur','user2',Event(i,3));
                TonePokeDur=(Event(i,3)-TonePokeDurUser1)*1000;
                SetParam(me,'TonePokeDur',TonePokeDur);
            end
            if Event(i,1)==5        %Valid poke
                message(me,'Valid Poke','cyan');                
            elseif Event(i,1)==6    %time out
                message(me,'Time Out');
            end
        end

    case 'init_schedule'
    change_schedule(1);

    case 'schedule'
        change_schedule(get(gcbo,'value'));
        rpbox('send_matrix',state_transition_matrix(NextParam));
        update_plot;
        
    case {'directdeliv','tone_start'}
        rpbox('send_matrix',state_transition_matrix(NextParam));
        update_plot;
        
    case {'waterport','watervalvedur'}
        rpbox('send_matrix',state_transition_matrix(NextParam));
    
    case 'tone_select'
        beep=GetParam(me,'beep');
        rpbox('LoadRPSound',{beep{GetParam(me,'Tone_Select')}});
        
    case 'vp_signal'
        beep=GetParam(me,'beep');
        vp_sound=GetParam(me,'vp_sound');
        rpbox('LoadRPSound',{beep{GetParam(me,'Tone_Select')},make_timeout_sound});
        
    case 'leftprob'
        LeftProb = GetParam(me, 'LeftProb');
        Trials   = GetParam(me, 'Trials');
        PortNumber = GetParam(me, 'PortNumber');
        new_portnumber = double(rand(1,GetParam(me,'TotalTrial')-Trials)<=GetParam(me,'LeftProb')); 
        lefts = find(new_portnumber); rights = find(~new_portnumber);
        PortNumber(lefts +Trials) = GetParam(me, 'LeftSound');
        PortNumber(rights+Trials) = GetParam(me, 'RightSound');
        SetParam(me, 'PortNumber', 'value', PortNumber);
        update_plot;
        
    case 'timeoutsound',
        beep = GetParam(me, 'beep');
        rpbox('LoadRPSound',{beep{GetParam(me,'Tone_Select')}, make_timeout_sound});

    case 'timeout',
%         beep = GetParam(me, 'beep');
%         rpbox('LoadRPSound',{beep{GetParam(me,'Tone_Select')}, make_timeout_sound});
        
    case 'state35'
        % First, find out whether this trial was a hit or a miss.
        trial_events = GetParam('rpbox', 'trial_events');
        trialnum = trial_events(end,1);
        trial_events = trial_events(find(trial_events(:,1)==trialnum),:);
        u = find(trial_events(:,3)==5);
        if isempty(u), hit=0; else hit = 1; end;
        HitHistory = GetParam(me, 'HitHistory');
        Trials     = GetParam(me, 'Trials');
        HitHistory(Trials+1) = hit;
        % g = HitHistory(1:Trials+1),
        SetParam(me,'HitHistory',HitHistory);
        
        if hit, SetParam(me,'Rewards',GetParam(me,'Rewards')+1); end;
        Stubbornness = GetParam(me, 'Stubbornness');
        if Stubbornness==2 & ~hit,
            PortNumber = GetParam(me, 'PortNumber');
            PortNumber(Trials+2:end) = PortNumber(Trials+1:end-1);
            SetParam(me, 'PortNumber', PortNumber);
        end;
        
        SetParam(me,'Trials',GetParam(me,'Trials')+1);
        rpbox('send_matrix',state_transition_matrix(NextParam));
        update_plot;
        
    case 'close'
        SetParam('rpbox','protocols',1);
    otherwise
        out=0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function out=NextParam
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
Reward = GetParam(me,'Rewards');
Trial  = GetParam(me,'Trials');
TotalTrial=GetParam(me,'TotalTrial');
dd = 2; % -(GetParam(me,'DirectDeliv')>Reward);

% if Reward >= TotalTrial
%     Reward=rem((Reward-dd),TotalTrial)+dd;
% else
    Trial=Trial+1;
% end

effective_trial=min(Reward,TotalTrial);
vpd=GetParam(me,'ValidTnPoke')/1000;
% vpd=vpd(effective_trial);
if vpd < 0.001 % vpd has to be larger than the sampling reate of RPDevice
    vpd=0.001;  % sec
end

leftnum  = GetParam(me, 'LeftSound');
rightnum = GetParam(me, 'RightSound');
PortNumber = GetParam(me, 'PortNumber');
if PortNumber(Trial)==leftnum, 
    SetParamUI(me, 'Tone_Select', 'value', leftnum); SetParam(me, 'Tone_Select', 'value', leftnum);
    SetParamUI(me, 'WaterPort',   'value', leftnum); SetParam(me, 'WaterPort',   'value', leftnum);
    fprintf(1, 'Going for left...\n');
else
    SetParamUI(me, 'Tone_Select', 'value', rightnum); SetParam(me, 'Tone_Select', 'value', rightnum);
    SetParamUI(me, 'WaterPort',   'value', rightnum); SetParam(me, 'WaterPort',   'value', rightnum);
    fprintf(1, 'Going for right...\n');
end;

beep=GetParam(me,'beep');
rpbox('LoadRPSound',{beep{GetParam(me,'Tone_Select')}, make_timeout_sound});

rad=GetParam(me,'RewardAvail');
% rad=rad(effective_trial);
wpt=GetParam(me,'WaterPort');   %1:Left, 2:Right, 3:Both
tns=GetParam(me,'Tone_Start');
tns=(tns<=Reward);

tnd=GetParam(me,'ToneDur');
tnd=tnd(GetParam(me,'Tone_Select'));
tmo=GetParam(me,'TimeOut');

out=[dd,vpd,rad,wpt,tns,tnd,tmo];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function out=state_transition_matrix(varargin)
% varargin={dd,vpd,rad,wpt,tns,tnd,tmo}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% the columns of the transition matrix represent inputs
% Cin,Cout,Lin,Lout,Rin, Rout, Times-up
% The rows are the states (from Staet 0 upto 32)
% The timer is in unit of seconds, # of columns >= # of states
% DIO output in "word" format, 1=DIO-0_ON, 8=DIO-3_ON (DIO-0~8) 
% AO output in "word" format, 1=AO-1_ON, 3=AO-1,2_ON,  (AO-1,2)
if nargin<2
    dd =varargin{1}(1);
    vpd=varargin{1}(2);
    rad=varargin{1}(3);
    wpt=varargin{1}(4);
    tns=varargin{1}(5);
    tnd=varargin{1}(6);
    tmo=varargin{1}(7);    
elseif nargin>6
    dd =varargin{1};
    vpd=varargin{2};
    rad=varargin{3};
    wpt=varargin{4};
    tns=varargin{5};
    tnd=varargin{6};
    tmo=varargin{7};    
else
    error('wrong input format ');
    return
end 

dd = 2;
lwvd=GetParam(me,'LeftWaterValveDur');
rwvd=GetParam(me,'RightWaterValveDur');
iti =GetParam(me,'InterTrial');

ltd=(tnd-vpd);  %leftover tone duration
ltd=ltd*(ltd>0);
if ltd < 0.001 % ltd has to be larger than the sampling reate of RPDevice
    ltd=0.001;  % sec
end
och=GetParam(me,'OdorChannel');
och=och(GetParam(me,'Tone_Select'));
odr=och + (2^2)*(och>0)

if     bitget(wpt,1) & bitget(wpt,2), error('Need water ports to be either 1 OR 2!');
elseif bitget(wpt,1), wvd = lwvd;
elseif bitget(wpt,2), wvd = rwvd;
else   error('Need water ports to be either 1 OR 2!');
end;

state_transition_matrix{1}=[ ...
%  Cin Cout Lin Lout Rin Rout TimeUp Timer DIO   AO  
    1    0   0    0   0    0    0     180   0      0;  % State 0 "Pre-State"
    1    4   4    4   4    4    2     vpd  odr tns+0;  % State 1 "Center Poke in"
    2    2   2    2   2    2    3     wvd  wpt tns+2;  % State 2 "Valid Poke ==> Water!!! :)"
    1    3  35   35  35   35    0     rad   0      0;  % State 3 "End trial when the rat finds water within rad"
    4    4   4    4   4    4    0     tmo   0      0;];% State 4 "TimeOut ==> House Light "

if bitget(wpt,1)
    LinS=5;
else
    LinS=6;
end

if bitget(wpt,2)
    RinS=5;
else
    RinS=6;
end


state_trans=[ ...
%  Cin Cout Lin   Lout Rin   Rout TimeUp        Timer DIO  AO  
    1    0   0      0   0      0    0           180   0      0;  % State 0 "Pre-State"
    1    0   1      1   1      1    2           .01   0      0;  % State 1 "Center Poke in, before tone on"
    2    8   2      2   2      2    3+(ltd==0)  vpd  odr tns+0;  % State 2 "Tone On"
    3    3  LinS    0  RinS    0    4           ltd  odr tns+0;  % State 3 "pre- Center Poke out"
    4    4  LinS    0  RinS    0    0           rad   0  tns+0;  % State 4 "Reward Avaiable Dur"
    5    5   5      5   5      5    7           wvd  wpt     0;  % State 5 "Valid Poke ==> Water!!! then ITI :)"
    6    6   6      6   6      6    7           tmo   0      2;  % State 6 "Error: TimeOut ==> House Light "
    7    7   7      7   7      7    35          iti   0      0;  % State 7  Intertrial interval
    8    8   8      8   8      8    0           tmo   0      2;];% State 8 Abort: TimeOut, go back to state 0

out=state_trans;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_schedule
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prepare axis to plot schedule
fig=findobj('tag',me);
figure(fig);
h = findobj(fig,'tag','plot_schedule');
if ~isempty(h)
    axes(h);
    set(h,'pos',[0.15 0.72 0.8 0.25]);
else
    h = axes('tag','plot_schedule','pos',[0.15 0.72 0.8 0.25]);    
end
PortNumber=3-GetParam(me,'PortNumber');
plot(PortNumber,'b.'); hold on
plot(1,PortNumber(1),'or');
axis([0 40 0.5 2.5]);
xlabel('trials'); ylabel('Port');
set(h, 'YTick', [1 2], 'YTickLabel', {'Rt' 'Lt'});
set(h,'tag','plot_schedule');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function update_plot
global exper

trialnum = GetParam(me,'Trials');

fig = findobj('tag',me);

h = findobj(fig,'tag','plot_schedule');
TotalTrial=GetParam(me,'TotalTrial');
HitHistory=GetParam(me,'HitHistory');
axmin = max(trialnum+1-30,0);
axmax = axmin+50;
if ~isempty(h)
    axes(h);
    cla;
    PortNumber=3-GetParam(me,'PortNumber');
    plot(PortNumber,'b.'); hold on
    plot(trialnum+1,PortNumber(trialnum+1),'or');
    oldtrials = 1:trialnum; oldhits = find(HitHistory(oldtrials)==1); oldmisses = find(HitHistory(oldtrials)==0);
    plot(oldtrials(oldhits),   PortNumber(oldtrials(oldhits)),   'g.');
    plot(oldtrials(oldmisses), PortNumber(oldtrials(oldmisses)), 'r.');
    axis([axmin axmax 0.5 2.5]);
    xlabel('trials'); ylabel('Port');
    set(h, 'YTick', [1 2], 'YTickLabel', {'Rt' 'Lt'});
    set(h,'tag','plot_schedule');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function change_schedule(id)
global exper

tr = GetParam(me,'TotalTrial');
ValidTonePokeDur = [];
RewardAvailDur = [];

switch id
case 1
    % TonePokeValidDuration was progressively increased
    ValidTonePokeDur(1:ceil(tr/6))  = 0;
    ValidTonePokeDur(ceil(tr/6)+1:ceil(tr/3)*2) = 0.1;
    ValidTonePokeDur(ceil(tr/3)*2+1 : tr) = 0.2;
    
    % The rat has to go to the water port in 'RewardAvailDur' after he get out of the Tone port.
    % 'RewardAvailDur' is progressively decreased
    RewardAvailDur(1:ceil(tr/3))  = 10;
    RewardAvailDur(ceil(tr/3)+1:ceil(tr/3)*2) = 8;
    RewardAvailDur(ceil(tr/3)*2+1:tr) = 5;
    
case 2
    % TonePokeValidDuration was progressively increased
    ValidTonePokeDur(1:ceil(tr/6))  = 0;
    ValidTonePokeDur(ceil(tr/6)+1:ceil(tr/6)*2) = 0.1;
    ValidTonePokeDur(ceil(tr/6)*2+1:ceil(tr/6)*3) = 0.2;
    ValidTonePokeDur(ceil(tr/6)*3+1:tr) = 0.3;
    
    % The rat has to go to the water port in 'RewardAvailDur' after he get out of the Tone port.
    % 'RewardAvailDur' is progressively decreased
    RewardAvailDur(1:ceil(tr/3))  = 10;
    RewardAvailDur(ceil(tr/3)+1:ceil(tr/3)*2) = 8;
    RewardAvailDur(ceil(tr/3)*2+1:tr) = 5;
    
case 3
    ValidTonePokeDur(1:ceil(tr/6)*2)  = 0.1;
    ValidTonePokeDur(ceil(tr/6)*2+1:tr) = 0.2;
    RewardAvailDur(1:tr)  = 3;
case 4
    ValidTonePokeDur(1:tr)  = 0.3;
    RewardAvailDur(1:tr)  = 2;
case 5
    ValidTonePokeDur(1:tr)  = 0.4;
    RewardAvailDur(1:tr)  = 2;
case 6
    ValidTonePokeDur(1:tr)  = 0.15;
    RewardAvailDur(1:tr)  = 2;
case 7
    ValidTonePokeDur(1:tr)  = 0.20;
    RewardAvailDur(1:tr)  = 2;
case 8
    ValidTonePokeDur(1:tr)  = 0.25;
    RewardAvailDur(1:tr)  = 2;
case 9
    ValidTonePokeDur(1:tr)  = 0.30;
    RewardAvailDur(1:tr)  = 2;
case 10
    ValidTonePokeDur(1:tr)  = 0.35;
    RewardAvailDur(1:tr)  = 2;
case 11
    ValidTonePokeDur(1:tr)  = 0.40;
    RewardAvailDur(1:tr)  = 2;
case 12
    ValidTonePokeDur(1:tr)  = 0.45;
    RewardAvailDur(1:tr)  = 2;
case 13
    ValidTonePokeDur(1:tr)  = 0.50;
    RewardAvailDur(1:tr)  = 2;
end

SetParam(me,'ValidTonePokeDur',ValidTonePokeDur);
SetParam(me,'RewardAvailDur',RewardAvailDur);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=InitTones

FilterPath=[GetParam('rpbox','protocol_path') '\PPfilter.mat'];
if ( size(dir(FilterPath),1) == 1 )
    PP=load(FilterPath);
    PP=PP.PP;
    message(me,'Generating Calibrated Tones');
else
    PP=[];
    message(me,'Generating Non-calibrated Tones');
end

FreqStart=GetParam(me,'ToneFreqStart');
FreqEnd  =GetParam(me,'ToneFreqEnd');
FreqMean = exp((log(FreqStart) + log(FreqEnd))/2);
Dur=GetParam(me,'ToneDur')*1000;
SPL=GetParam(me,'ToneSPL');
RampDur=GetParam(me,'RampDur');
n_tones=length(FreqStart);
ToneAttenuation = ones(1,n_tones)*70 -SPL;

for tn=1:n_tones
    if isempty(PP) | FreqStart(tn)== -1
        ToneAttenuation_adj = ToneAttenuation(tn);
    else
        ToneAttenuation_adj = ToneAttenuation(tn) - ppval(PP, log10(FreqMean(tn)));
        % Remove any negative attenuations and replace with zero attenuation.
        ToneAttenuation_adj = ToneAttenuation_adj .* (ToneAttenuation_adj > 0);
    end
    beep{tn}  = 1 * MakeSwoop(50e6/1024, ToneAttenuation_adj ,FreqStart(tn), FreqEnd(tn), Dur(tn), RampDur(tn));
end
SetParam(me,'beep',beep);
out=beep;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%      make_timeout_sound
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [snd] = make_timeout_sound()
    sound_selection = GetParam(me, 'TimeOutSound');
    timeoutdur = GetParam(me, 'TimeOut');
    
    if sound_selection == 1,
        snd = zeros(1, floor((50e6/1024)*timeoutdur));
        return;
    end;
    
    time = zeros(1, floor(timeoutdur*50e6/1024));
    time = timeoutdur*(0:length(time))/length(time);
    
    snd  = 0.05*sin(2*pi*3000*time);
    grid = sin(2*pi*10*time);
    snd(grid>0) = 0;
    % snd = 0.25*rand(size(snd));

    




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=InitVP_Sound

FilterPath=[GetParam('rpbox','protocol_path') '\PPfilter.mat'];
if ( size(dir(FilterPath),1) == 1 )
    PP=load(FilterPath);
    PP=PP.PP;
    message(me,'Generating Calibrated Tones');
else
    PP=[];
    message(me,'Generating Non-calibrated Tones');
end

Freq=GetParam(me,'VPS_Freq');
Dur=GetParam(me,'VPS_Dur');
SPL=GetParam(me,'VPS_SPL');

n_tones=length(Freq);
ToneAttenuation = ones(1,n_tones)*70 -SPL;

for tn=1:n_tones
    if isempty(PP) | Freq(tn)== -1
        ToneAttenuation_adj = ToneAttenuation(tn);
    else
        ToneAttenuation_adj = ToneAttenuation(tn) - ppval(PP, log10(Freq(tn)));
        % Remove any negative attenuations and replace with zero attenuation.
        ToneAttenuation_adj = ToneAttenuation_adj .* (ToneAttenuation_adj > 0);
    end
    vp_sound{tn}  = 1 * makebeep(50e6/1024, ToneAttenuation_adj ,Freq(tn), Dur,3);
end
SetParam(me,'vp_sound',vp_sound);
out=vp_sound;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=me
% Simple function for getting the name of this m-file.
out=lower(mfilename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = callback
out = [lower(mfilename) ';'];

