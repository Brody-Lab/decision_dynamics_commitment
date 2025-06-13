function out = tonelocsamp(varargin)

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
        
        Freq=[1000 2500 5000 7000 13000 15000 17000 23000  -1  -1    1   2];  %Hz
        Dur =[ 100  100  100  100   100   100   100   100 100 1000 100 100];  %msec
        SPL =[  70   70   70   70    70    70    70    70  45  40   70  70];  %Max=PPdB SPL
        Str ={'1k 70dB 100ms','2.5k 70dB 100ms','5k 70dB 100ms','7k 70dB 100ms','13k 70dB 100ms',...
                '15k 70dB 100ms','17k 70dB 100ms','23k 70dB 100ms','wn 25dB atn 100ms','wn 30dB atn 100ms',...
                'Low-Chord','Hi-Chord','Silence','Random'}; 
        InitParam(me,'ToneFreq','value',Freq);
        InitParam(me,'ToneDur','value',Dur/1000);
        InitParam(me,'ToneSPL','value',SPL);
        
        n=n+.2;
        InitParam(me,'DirectDeliver1','ui','edit','value',0,'user',0,'pos',[h n*vs hs*.85 vs]);
        SetParamUI(me,'DirectDeliver1','label','DirectDeliver 1','enable','on');
        InitParam(me,'DirectDeliver2','ui','edit','value',20,'user',20,'pos',[h+hs*1.8 n*vs hs*.85 vs]);
        SetParamUI(me,'DirectDeliver2','label','DirectDeliver 2','enable','on');
        InitParam(me,'WaterValveDur','ui','edit','value',.15,'pos',[h+hs*3.6 n*vs hs*.85 vs]);
        SetParamUI(me,'WaterValveDur','label','WaterV_Dur');
        InitParam(me,'Abort','ui','disp','value',0,'pref',0,'pos',[h+hs*5.5 n*vs hs*.85 vs]);
        SetParamUI(me,'Abort','label','Abort (short poke)');
        n=n+1;
        
        InitParam(me,'Tn1_Right_Ch','ui','popupmenu','list',Str,'value',length(Str)-1,'user',length(Str)-1,'user2',length(Str)-1,'pos',[h n*vs hs*.85 vs]); 
        SetParamUI(me,'Tn1_Right_Ch','label','Tone 1: Right','enable','off','UserData',length(Str)-1);
        InitParam(me,'Tn2_Right_Ch','ui','popupmenu','list',Str,'value',2,'user',2,'user2',length(Str)-1,'pos',[h+hs*1.8 n*vs hs*.85 vs]); 
        SetParamUI(me,'Tn2_Right_Ch','label','Tone 2: Right','enable','off','UserData',2);
        InitParam(me,'ValidPokeDur','ui','edit','value',.01,'pos',[h+hs*3.6 n*vs hs*.85 vs]);
        SetParamUI(me,'ValidPokeDur','label','ValidPoke_Dur');
        InitParam(me,'rightFalse','ui','disp','value',0,'pref',0,'pos',[h+hs*5.5 n*vs hs*.85 vs]);
        SetParamUI(me,'rightFalse','label','False right poke');
        n=n+1;

        InitParam(me,'Tn1_Left_Ch','ui','popupmenu','list',Str,'value',2,'user',2,'user2',length(Str)-1,'pos',[h n*vs hs*.85 vs]); 
        SetParamUI(me,'Tn1_Left_Ch','label','Tone 1: Left','enable','on','UserData',2);
        InitParam(me,'Tn2_Left_Ch','ui','popupmenu','list',Str,'value',2,'user',2,'user2',length(Str)-1,'pos',[h+hs*1.8 n*vs hs*.85 vs]); 
        SetParamUI(me,'Tn2_Left_Ch','label','Tone 2: Left','enable','on','UserData',2);
        InitParam(me,'RewardAvailDur','ui','edit','value',5,'pos',[h+hs*3.6 n*vs hs*.85 vs]);
        SetParamUI(me,'RewardAvailDur','label','RewardAvail_Dur');
        InitParam(me,'leftFalse','ui','disp','value',0,'pref',0,'pos',[h+hs*5.5 n*vs hs*.85 vs]);
        SetParamUI(me,'leftFalse','label','False left poke');
        n=n+1;
        
        InitParam(me,'Tone1_Src','ui','popupmenu','list',{'Left';'Right';'Both/same';'Both/indp'},'value',1,'user',1,'user2',0,'pos',[h n*vs hs*.85 vs]); 
        SetParamUI(me,'Tone1_Src','label','Tone 1 Source','enable','off');
        InitParam(me,'Tone2_Src','ui','popupmenu','list',{'Left';'Right';'Both/same';'Both/indp';'None'},'value',3,'user',3,'user2',0,'pos',[h+hs*1.8 n*vs hs*.85 vs]); 
        SetParamUI(me,'Tone2_Src','label','Tone 2 Source','enable','on');
        InitParam(me,'TimeOut','ui','edit','value',2,'pos',[h+hs*3.6 n*vs hs*.85 vs]);
        SetParamUI(me,'TimeOut','label','Time Out (sec)');
        InitParam(me,'Miss','ui','disp','value',0,'pref',0,'pos',[h+hs*5.5 n*vs hs*.85 vs]);
        SetParamUI(me,'Miss','label','Missed reward');
        n=n+1;

        InitParam(me,'CueSourceTone','ui','popupmenu','list',{'1','2','both'},'value',1,'user',1,'pos',[h n*vs hs*.85 vs]);
        SetParamUI(me,'CueSourceTone','label','CueSourceTone');
        InitParam(me,'WaterPort','ui','popupmenu','list',{'Left';'Right';'Both'},'value',1,'user',1,'pos',[h+hs*1.8 n*vs hs*.85 vs]);
        SetParamUI(me,'WaterPort','label','Water Port');
        InitParam(me,'Tone_Start','ui','edit','value',1,'pos',[h+hs*3.6 n*vs hs*.85 vs]);
        SetParamUI(me,'Tone_Start','label','Tone Start');
        InitParam(me,'Valid2nd','ui','disp','value',0,'pref',0,'pos',[h+hs*5.5 n*vs hs*.85 vs]);
        SetParamUI(me,'Valid2nd','label','Valid 2nd poke');
        n=n+1;

        InitParam(me,'Schedule','ui','popupmenu','list',{'custom setting','1st tone: Left','1st tone: Right','2nd tone: Left',...
                '2nd tone: Right','Both Tn: 10L-10R','Both Tn: Random','1st Tn: 10L-10R','1st tn: Random'},'value',1,'user',1,'pos',[h n*vs hs*.85 vs]);
        SetParamUI(me,'Schedule','label','Schedule');
        InitParam(me,'MinIPI','ui','edit','value',0.5,'pos',[h+hs*1.8 n*vs hs*.85 vs]); 
        SetParamUI(me,'MinIPI','label','Min. IPI (sec)');
        InitParam(me,'nTonePoke','ui','disp','value',0,'pref',1,'pos',[h+hs*3.6 n*vs hs*.85 vs]);
        SetParamUI(me,'nTonePoke','label','#TonePoke');    
        InitParam(me,'Valid1st','ui','disp','value',0,'pref',0,'pos',[h+hs*5.5 n*vs hs*.85 vs]);
        SetParamUI(me,'Valid1st','label','Valid 1st poke');
        n=n+1
        
        InitParam(me,'TotalReward','ui','edit','value',250,'pos',[h n*vs hs*.85 vs]); 
        SetParamUI(me,'TotalReward','label','Total Reward');    
        TotalReward=GetParam(me,'TotalReward'); 
        InitParam(me,'MaxIPI','ui','edit','value',2,'pos',[h+hs*1.8 n*vs hs*.85 vs]); 
        SetParamUI(me,'MaxIPI','label','Max. IPI (sec)');
        InitParam(me,'TonePokeDur','ui','disp','value',0,'pref',0,'pos',[h+hs*3.6 n*vs hs*.85 vs]); 
        SetParamUI(me,'TonePokeDur','label','TnPokeDur (ms)');        
        InitParam(me,'Rewards','ui','disp','value',0,'pos',[h+hs*5.5 n*vs hs*.85 vs]);
        SetParamUI(me,'Rewards','label','Rewards');        
        n=n+1; 
        
        % message box
        uicontrol(fig,'tag','message','style','edit',...
            'enable','inact','horiz','left','pos',[h n*vs hs*2.4 vs]);
        InitParam(me,'ClearScore','ui','checkbox','value',1,'pref',0,'pos',[h+hs*5.5 n*vs hs*.8 vs]);
        SetParamUI(me,'ClearScore','label','','string','Clear Score'); 
         n = n+1;
        
        InitParam(me,'rBeep','value',[]);
        InitParam(me,'lBeep','value',[]);        
        InitTones;
        rpbox('InitRPStereoSound');
%         beep=CurrentTones;        
%         rpbox('LoadRPStereoSound',beep);

        ValidPokeNum = zeros(1,TotalReward);
        InitParam(me,'ValidPokeNum','value',ValidPokeNum);
        WaterPort_Schedule = zeros(1,TotalReward);
        InitParam(me,'WaterPort_Schedule','value',WaterPort_Schedule);
        DirectDeliver_Schedule = zeros(1,TotalReward);
        InitParam(me,'DirectDeliver_Schedule','value',DirectDeliver_Schedule);        
        eval([me '(''Schedule'')']);
%         id=GetParam(me,'Schedule');
%         change_schedule(id);
%         check_tone1_src;
%         check_tone2_src;
%         update_new_schedule(id)

        rpbox('send_matrix', [0 0 0 0 0 0 0 180 0 0]);
        rpbox('send_matrix',state_transition_matrix(NextParam));
        
        set(fig,'pos',[140 461-n*vs hs*7.6 (n+16)*vs],'visible','on');
        plot_schedule;

    case 'trialready'
% %         rpbox('send_matrix',state_transition_matrix(NextParam));
        
    case 'trialend'
       
    case 'reset'
        Message(me,'');
        Message('control','wait for RP (RP2/RM1) reseting');
        if Getparam(me,'ClearScore')
            SetParam(me,'Rewards',0);
            SetParam(me,'nTonePoke',0);            

            SetParam(me,'Abort',0); 
            SetParam(me,'rightFalse',0); 
            SetParam(me,'leftFalse',0); 
            SetParam(me,'Miss',0); 
            SetParam(me,'Valid2nd',0); 
            SetParam(me,'Valid1st',0);     
        end
        TotalReward=GetParam(me,'TotalReward'); 
        ValidPokeNum = zeros(1,TotalReward);
        SetParam(me,'ValidPokeNum','value',ValidPokeNum);
        WaterPort_Schedule = zeros(1,TotalReward);
        SetParam(me,'WaterPort_Schedule','value',WaterPort_Schedule);
        DirectDeliver_Schedule = zeros(1,TotalReward);
        SetParam(me,'DirectDeliver_Schedule','value',DirectDeliver_Schedule);        
        eval([me '(''Schedule'')']);

        update_plot;   
        rpbox('InitRPStereoSound');
        rpbox('send_matrix', [0 0 0 0 0 0 0 180 0 0]);
        rpbox('send_matrix',state_transition_matrix(NextParam));
        beep=CurrentTones;
        rpbox('LoadRPStereoSound',beep);
        Message('control','');
        
    case {'directdeliver1','directdeliver2'}
        if strcmp(get(gcbo,'tag'),'directdeliver1')
            SetParam(me,'DirectDeliver1','user',GetParam(me,'DirectDeliver1'));
        elseif strcmp(get(gcbo,'tag'),'directdeliver2')
            SetParam(me,'DirectDeliver2','user',GetParam(me,'DirectDeliver2'));
        end
        eval([me '(''Schedule'')']);
%         id=GetParam(me,'Schedule');
%         change_schedule(id);
%         check_tone1_src;
%         check_tone2_src;
%         update_new_schedule(id)        
        
        
    case {'schedule'}
        id=GetParam(me,'Schedule');
        change_schedule(id);
        check_tone1_src;
        check_tone2_src;
        update_new_schedule(id)

        beep=CurrentTones;
        rpbox('LoadRPStereoSound',beep);
        rpbox('send_matrix',state_transition_matrix(NextParam));
        update_plot;
        
    case {'tone_start'}
        rpbox('send_matrix',state_transition_matrix(NextParam));
        update_plot;
        
    case {'waterport','cuesourcetone'}
        if strcmp(get(gcbo,'tag'),'waterport')
            SetParam(me,'waterport','user',get(gcbo,'value'));
        elseif strcmp(get(gcbo,'tag'),'cuesourcetone')
            SetParam(me,'cuesourcetone','user',get(gcbo,'value'));
        end
        id=GetParam(me,'Schedule');
        change_schedule(id);
        check_tone1_src;
        check_tone2_src;
        update_new_schedule(id)

        beep=CurrentTones;
        rpbox('LoadRPStereoSound',beep);
        rpbox('send_matrix',state_transition_matrix(NextParam));
        update_plot;
        
    case {'watervalvedur'}
        rpbox('send_matrix',state_transition_matrix(NextParam));
    
    case 'tone1_src'            %{'Left';'Right';'Both/same';'Both/indp'}
        check_tone1_src;
        beep=CurrentTones;
        rpbox('LoadRPStereoSound',beep);
        
    case 'tone2_src'            %{'Left';'Right';'Both/same';'Both/indp';'None'}
        check_tone2_src;
        update_new_schedule(GetParam(me,'Schedule'));
        beep=CurrentTones;
        rpbox('LoadRPStereoSound',beep);
        rpbox('send_matrix',state_transition_matrix(NextParam));
        update_plot;
        
    case {'tn1_right_ch','tn1_left_ch','tn2_right_ch','tn2_left_ch'}
        set(gcbo,'UserData',get(gcbo,'value'));
        if GetParam(me,'Tone1_src')==3 & ismember(get(gcbo,'tag'),['tn1_right_ch','tn1_left_ch'])
            SetParam(me,'Tn1_Right_Ch',GetParam(me,'Tn1_Left_Ch'));
        elseif GetParam(me,'Tone2_src')==3 & ismember(get(gcbo,'tag'),['tn2_right_ch','tn2_left_ch'])            
            SetParam(me,'Tn2_Right_Ch',GetParam(me,'Tn2_Left_Ch'));
        end
        beep=CurrentTones;
        rpbox('LoadRPStereoSound',beep);
        
    case 'update'
   
        Abort   =[1 2;5 2;8 2;13 2;19 2;24 2];
        lFalse  =[29 7];
        rFalse  =[30 7];
        Miss    =[3 7;10 7;15 7;26 7];
        Valid1st=[2 7;5 7;13 7;19 7];
        Valid2nd=[8 7;24 7];
        
        Event=Getparam('rpbox','event','user'); % [state,chan,event time]
        for i=1:size(Event,1)
            if Event(i,2)==1        %tone poke in
                SetParam(me,'TonePokeDur','user1',Event(i,3));
                SetParam(me,'nTonePoke',GetParam(me,'nTonePoke')+1);                
            elseif Event(i,2)==2    %tone poke out
                SetParam(me,'TonePokeDur','user2',Event(i,3));
                TonePokeDur=(Event(i,3)-GetParam(me,'TonePokeDur','user1'))*1000;
                SetParam(me,'TonePokeDur',TonePokeDur);
                if sum(prod(repmat(Event(i,1:2),size(Abort,1),1)==Abort,2))
                    message(me,'ShortPoke','green');    % ShortPoke => Abort 
                    SetParam(me,'Abort',GetParam(me,'Abort')+1);
                end
            elseif Event(i,2)==3    %left poke in
            elseif Event(i,2)==4    %left poke out
            elseif Event(i,2)==5    %right poke in
            elseif Event(i,2)==6    %right poke out
            elseif Event(i,2)==7    %time out
                if sum(prod(repmat(Event(i,1:2),size(Miss,1),1)==Miss,2))
                    message(me,'Missed reward');
                    SetParam(me,'miss',GetParam(me,'miss')+1);
                end
                if sum(prod(repmat(Event(i,1:2),size(Valid1st,1),1)==Valid1st,2))
                    message(me,'Valid 1st Poke','cyan');
                    SetParam(me,'valid1st',GetParam(me,'valid1st')+1);
                end
                if sum(prod(repmat(Event(i,1:2),size(Valid2nd,1),1)==Valid2nd,2))
                    message(me,'Valid 2nd Poke','cyan');
                    SetParam(me,'valid2nd',GetParam(me,'valid2nd')+1);
                end
                if sum(prod(repmat(Event(i,1:2),size(lFalse,1),1)==lFalse,2))
                    message(me,'leftFalse','red');    % FalsePoke => Abort 
                    SetParam(me,'leftFalse',GetParam(me,'leftFalse')+1);
                end
                if sum(prod(repmat(Event(i,1:2),size(rFalse,1),1)==rFalse,2))
                    message(me,'rightFalse','red');    % FalsePoke => Abort 
                    SetParam(me,'rightFalse',GetParam(me,'rightFalse')+1);
                end
            end
        end

    case 'state35'
        Reward = GetParam(me,'Rewards')+1;
        SetParam(me,'Rewards',Reward);        
        TotalReward=GetParam(me,'TotalReward');
        DD1=GetParam(me,'DirectDeliver1');
        DD2=GetParam(me,'DirectDeliver2');
        
        if Reward >= TotalReward
            effective_trial=rem((Reward-DD1-DD2),TotalReward)+DD1+DD2;
        else
            effective_trial=Reward;
        end

        id=GetParam(me,'Schedule');
        change_schedule(id);
        check_tone1_src;
        check_tone2_src;
        update_new_schedule(id)

        beep=CurrentTones;
        rpbox('LoadRPStereoSound',beep);
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
TotalReward=GetParam(me,'TotalReward');
DD1=GetParam(me,'DirectDeliver1');
DD2=GetParam(me,'DirectDeliver2');

Reward=Reward+1;
if Reward >= TotalReward
    effective_trial=rem((Reward-DD1-DD2),TotalReward)+DD1+DD2;
else
    effective_trial=Reward;
end

dd=GetParam(me,'DirectDeliver_Schedule');
dd=dd(effective_trial);

vpn=GetParam(me,'ValidPokeNum');
vpn=vpn(effective_trial);

vpd=GetParam(me,'ValidPokeDur');
if vpd < 0.001 % vpd has to be larger than the sampling reate of RPDevice
    vpd=0.001;  % sec
end

rad=GetParam(me,'RewardAvailDur');
wpt=GetParam(me,'WaterPort_Schedule');
wpt=wpt(effective_trial);   %1:Left, 2:Right, 3:Both

tns=GetParam(me,'Tone_Start');
tns=(tns<=Reward);

dur=GetParam(me,'ToneDur')
dur=[dur 0 max(dur)];
td1=max(dur([GetParam(me,'tn1_Right_ch'),GetParam(me,'tn1_left_ch')]));
td2=max(dur([GetParam(me,'tn2_Right_ch'),GetParam(me,'tn2_left_ch')]));

tmo=GetParam(me,'TimeOut');

min_ipi=GetParam(me,'MinIPI');
max_ipi=GetParam(me,'MaxIPI');

out=[dd,vpn,vpd,rad,wpt,tns,td1,td2,tmo,min_ipi,max_ipi];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function out=state_transition_matrix(varargin)
% varargin={dd,vpd,rad,wpt,tns,td1,td2,tmo,min_ipi,max_ipi}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% the columns of the transition matrix represent inputs
% Cin,Cout,Lin,Lout,Rin, Rout, Times-up
% The rows are the states (from Staet 0 upto 32)
% The timer is in unit of seconds, # of columns >= # of states
% DIO output in "word" format, 1=DIO-0_ON, 8=DIO-3_ON (DIO-0~8) 
% AO output in "word" format, 1=AO-1_ON, 3=AO-1,2_ON,  (AO-1,2)
if nargin<2
    dd =varargin{1}(1);
    vpn=varargin{1}(2);
    vpd=varargin{1}(3);
    rad=varargin{1}(4);
    wpt=varargin{1}(5);
    tns=varargin{1}(6);
    td1=varargin{1}(7);
    td2=varargin{1}(8);
    tmo=varargin{1}(9);
    min_ipi=varargin{1}(10);
    max_ipi=varargin{1}(11);
elseif nargin>8
    dd =varargin{1};
    vpn=varargin{2};
    vpd=varargin{3};
    rad=varargin{4};
    wpt=varargin{5};
    tns=varargin{6};
    td1=varargin{7};    
    td2=varargin{8};
    tmo=varargin{9};
    min_ipi=varargin{10};
    max_ipi=varargin{11};    
else
    error('wrong input format ');
    return
end 
wvd=GetParam(me,'WaterValveDur');
if bitget(wpt,1)
    Lin=35;
else
    Lin=29;
end
if bitget(wpt,2)
    Rin=35;
else
    Rin=30;
end

if dd==1
    state_transition_matrix=[ ...
     %  Cin Cout Lin Lout Rin Rout TimeUp Timer DIO   AO  
        1    0   0    0   0    0    0     180   0      0;  % State 0 "Pre-State"
        1    4   4    4   4    4    2     vpd   0  1*tns;  % State 1 "Center Poke in"
        2    2   2    2   2    2    3     wvd  wpt 1*tns;  % State 2 "Valid Poke ==> Water!!! :)"
        1    3  Lin  Lin Rin  Rin   0     rad   0      0;  % State 3 "End trial when the rat finds water within rad"
        4    4   4    4   4    4    0     tmo   0      0;  % State 4 "TimeOut "
        zeros(24,10);
       29   29  29   29  29   29    0     .01   0      0;  % State 29 "False Left Poke "
       30   30  30   30  30   30    0     .01   0      0;];% State 30 "False Right Poke "   
elseif dd==2
    state_transition_matrix=[ ...
     %  Cin Cout Lin Lout Rin Rout TimeUp Timer DIO   AO  
        5    0   0    0   0    0    0     180   0      0;  % State  0 "Pre-State"
        zeros(4,10);
        5   11  11   11  11   11    6     vpd   0  1*tns;  % State  5 "Center Poke in"
        6    6   0    0   0    0    7 min_ipi   0  1*tns;  % State  6 "IPI"    
        8    7   0    0   0    0    0       2   0      0;  % State  7 "2nd Pre-State"
        8   11  11   11  11   11    9     vpd   0  2*tns;  % State  8 "2nd Center Poke in"    
        9    9   9    9   9    9   10     wvd  wpt 2*tns;  % State  9 "Valid Poke ==> Water!!! :)"
        8   10  Lin  Lin Rin  Rin   0     rad   0      0;  % State 10 "End trial when the rat finds water within rad"
       11   11  11   11  11   11    0     tmo   0      0;  % State 11 "TimeOut ==> House Light "
       zeros(17,10);
       29   29  29   29  29   29    0     .01   0      0;  % State 29 "False Left Poke "
       30   30  30   30  30   30    0     .01   0      0;];% State 30 "False Right Poke "   
   
elseif vpn==1
    if bitget(wpt,1)
        LinS=16;
    else
        LinS=29;
    end
    if bitget(wpt,2)
        RinS=16;
    else
        RinS=30;
    end
    ltd=(td1-vpd);  %leftover tone duration
    ltd=ltd*(ltd>0);
    if ltd < 0.001 % ltd has to be larger than the sampling reate of RPDevice
        ltd=0.001;  % sec
    end
    
    state_transition_matrix=[ ...
    %  Cin Cout Lin   Lout Rin   Rout TimeUp        Timer DIO  AO  
        12   0   0      0   0      0    0           180   0      0;  % State  0 "Pre-State"
        zeros(11,10);
        12   0   12    12   12    12   13           .01   0      0;  % State 12 "Center Poke in, delay before tone on"
        13  17   13    13   13    13   14+(ltd==0)  vpd   0    tns;  % State 13 "Tone On"
        14  14  LinS    0  RinS    0   15           ltd   0    tns;  % State 14 "pre- Center Poke out"
        15  15  LinS    0  RinS    0    0           rad   0    tns;  % State 15 "Reward Avaiable Dur"
        16  16   16    16   16    16   35           wvd  wpt     0;  % State 16 "Valid Poke ==> Water!!! :)"
        17  17   17    17   17    17    0           tmo   0      0;  % State 17 "TimeOut ==> House Light "
        zeros(11,10);    
        29  29   29    29   29    29   17           .01   0      0;  % State 29 "False Left Poke "
        30  30   30    30   30    30   17           .01   0      0;];% State 30 "False Right Poke "   
    
elseif vpn==2
    if bitget(wpt,1)
        Lin2=27;
    else
        Lin2=29;
    end
    if bitget(wpt,2)
        Rin2=27;    
    else
        Rin2=30;
    end
    ltd1=(td1-vpd);  %leftover tone duration
    ltd1=ltd1*(ltd1>0);
    if ltd1 < 0.001 % ltd has to be larger than the sampling reate of RPDevice
        ltd1=0.001;  % sec
    end
    ltd2=(td2-vpd);  %leftover tone duration
    ltd2=ltd2*(ltd2>0);
    if ltd2 < 0.001 % ltd has to be larger than the sampling reate of RPDevice
        ltd2=0.001;  % sec
    end

    state_transition_matrix=[ ...
    %  Cin Cout Lin   Lout Rin   Rout TimeUp        Timer DIO  AO  
       18    0   0      0   0      0    0           180   0      0;  % State  0 "Pre-State"
       zeros(17,10);
       18    0   18    18   18    18   19           .01   0      0;  % State 18 "Center Poke in, delay before tone on"
       19   28   19    19   19    19   20+(ltd1==0) vpd   0  1*tns;  % State 19 "Tone On"
       20   20   20    20   20    20   21          ltd1   0  1*tns;  % State 20 "pre- Center Poke out"
       21   21   28    28   28    28   22  min_ipi-ltd1   0  1*tns;  % State 21 "IPI"
       23   22   0      0   0      0    0       max_ipi   0      0;  % State 22 "2nd Pre-State"
       23   22   23    23   23    23   24           .01   0      0;  % State 23 "Center Poke in, delay before tone on"
       24   28   24    24   24    24   25+(ltd2==0) vpd   0  2*tns;  % State 24 "Tone On"
       25   25  Lin2   22  Rin2   22   26          ltd2   0  2*tns;  % State 25 "pre- Center Poke out"
       26   26  Lin2   22  Rin2   22    0           rad   0  2*tns;  % State 26 "Reward Avaiable Dur"
       27   27   27    27   27    27   35           wvd  wpt     0;  % State 27 "Valid Poke ==> Water!!! :)"
       28   28   28    28   28    28    0           tmo   0      0;  % State 28 "TimeOut ==> House Light "
       29   29   29    29   29    29   28           .01   0      0;  % State 29 "False Left Poke "
       30   30   30    30   30    30   28           .01   0      0;];% State 30 "False Right Poke "   
end
out=state_transition_matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_schedule
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prepare axis to plot schedule
fig=findobj('tag',me);
figure(fig);
h = findobj(fig,'tag','plot_schedule');
if ~isempty(h)
    axes(h);
    set(h,'pos',[0.15 0.78 0.8 0.19]);
else
    h = axes('tag','plot_schedule','pos',[0.15 0.78 0.8 0.19]);
end
ValidPokeNum=GetParam(me,'ValidPokeNum');
plot(ValidPokeNum,'.'); hold on
plot(1,ValidPokeNum(1),'or');
ax = axis;
os = GetParam(me,'tone_start');
plot([os os],[0,3],':k');
ax(1) = 1; ax(2) = GetParam(me,'TotalReward');
axis([ax(1) ax(2) 0 3]);
xlabel('rewards');
ylabel('Valid Poke #');
set(h,'tag','plot_schedule');

h = findobj(fig,'tag','plot_WaterPort_Schedule');
if ~isempty(h)
    axes(h);
    set(h,'pos',[0.15 0.50 0.8 0.20]);
else
    h = axes('tag','plot_WaterPort_Schedule','pos',[0.15 0.50 0.8 0.20]);
end
WaterPort_Schedule=mod(GetParam(me,'WaterPort_Schedule'),2)+1;

plot(WaterPort_Schedule,'.'); hold on
dd1 = GetParam(me,'DirectDeliver1');
dd2 = GetParam(me,'DirectDeliver2');
if dd2
    plot(1:dd1,WaterPort_Schedule(1:dd1),'.g');
    plot(dd1+1:dd1+dd2,WaterPort_Schedule(dd1+1:dd1+dd2),'.c');
else
    plot(1:dd1,WaterPort_Schedule(1:dd1),'.c');
end
plot(1,WaterPort_Schedule(1),'or');
ax = axis;
plot([os os],[0,3],':k');
ax(1) = 1; ax(2) = GetParam(me,'TotalReward');
axis([ax(1) ax(2) 0 3]);
set(gca,'yTick',[1 2]);
set(gca,'yTicklabel',[]);
xlabel('rewards');
ylabel(['WaterPort' sprintf('\n') 'Right<== ==>Left']);
set(h,'tag','plot_WaterPort_Schedule');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function update_plot
global exper

reward = GetParam(me,'Rewards');

fig = findobj('tag',me);

a = findobj(fig,'tag','plot_schedule');
os = GetParam(me,'tone_start');
ValidPokeNum=GetParam(me,'ValidPokeNum');
WaterPort_Schedule=mod(GetParam(me,'WaterPort_Schedule'),2)+1;
dd = GetParam(me,'DirectDeliver1');
TotalReward=GetParam(me,'TotalReward');
eff_reward=min(reward+1,TotalReward);
ax_range=max(reward+1,TotalReward);
if ~isempty(a)
    axes(a);
    cla;
    plot(ValidPokeNum,'.'); hold on
    plot(reward+1,ValidPokeNum(eff_reward),'or');
    ax = axis;
    plot([os os],[0,3],':k');
    ax(1) = 1; ax(2) =ax_range;
    axis([ax(1) ax(2) 0 3]);
    xlabel('rewards');
    ylabel('Valid Poke #');
    set(a,'tag','plot_schedule');
end

b = findobj(fig,'tag','plot_WaterPort_Schedule');
if ~isempty(b)
    axes(b);
    cla;
    plot(WaterPort_Schedule,'.'); hold on
    dd1 = GetParam(me,'DirectDeliver1');
    dd2 = GetParam(me,'DirectDeliver2');
    if dd2
        plot(1:dd1,WaterPort_Schedule(1:dd1),'.g');
        plot(dd1+1:dd1+dd2,WaterPort_Schedule(dd1+1:dd1+dd2),'.c');
    else
        plot(1:dd1,WaterPort_Schedule(1:dd1),'.c');
    end
    plot(reward+1,WaterPort_Schedule(eff_reward),'or');
    ax = axis;
    plot([os os],[0,3],':k');
    ax(1) = 1; ax(2) = ax_range;
    axis([ax(1) ax(2) 0 3]);
    set(gca,'yTick',[1 2]);
    set(gca,'yTicklabel',[]);
    xlabel('rewards');
    ylabel(['WaterPort' sprintf('\n') 'Right<== ==>Left']);
    set(b,'tag','plot_WaterPort_Schedule');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function change_schedule(id)
global exper
id=GetParam(me,'Schedule');
Reward = GetParam(me,'Rewards');
TotalReward = GetParam(me,'TotalReward');
DD1=GetParam(me,'DirectDeliver1');
DD2=GetParam(me,'DirectDeliver2');
WaterPort_Schedule=GetParam(me,'WaterPort_Schedule');

Reward=Reward+1;
if Reward >= TotalReward
    effective_trial=rem((Reward-DD1-DD2),TotalReward)+DD1+DD2;
else
    effective_trial=Reward;
end
SetParam(me,'Tone1_Src','user2',0);     % Default is no distractor from the silent channel
SetParam(me,'Tone2_Src','user2',0);     
switch id   % 1:'custom setting',2:'Left',3:'Right',4:'10L-10R',5:'Random'
    case 1
        SetParam(me,'waterport',GetParam(me,'waterport','user'));
        SetParam(me,'cuesourcetone',GetParam(me,'cuesourcetone','user'));
        SetParamUI(me,'WaterPort','enable','on');
        SetParamUI(me,'CueSourceTone','enable','on');
        WaterPort=GetParam(me,'WaterPort');
        WaterPort_Schedule(1:TotalReward)  = WaterPort;
    case {2,4}
        SetParam(me,'WaterPort',1);         %left
        SetParamUI(me,'WaterPort','enable','inactive');
        SetParam(me,'CueSourceTone',id/2);     %location cue from 1st tone
        SetParamUI(me,'CueSourceTone','enable','inactive');
        WaterPort_Schedule(1:TotalReward)  = 1;
        
    case {3,5}
        SetParam(me,'WaterPort',2);         %right
        SetParamUI(me,'WaterPort','enable','inactive');
        SetParam(me,'CueSourceTone',(id-1)/2);     %location cue from 1st tone
        SetParamUI(me,'CueSourceTone','enable','inactive');
        WaterPort_Schedule(1:TotalReward)  = 2;
    case {6,8}
        if id==6
            SetParam(me,'CueSourceTone',3);     %location cue from BOTH tone
        elseif id==8
            SetParam(me,'CueSourceTone',1);     %location cue from 1st tone
        end
        SetParamUI(me,'CueSourceTone','enable','off');
        SetParamUI(me,'WaterPort','enable','inactive');
        WaterPort_Schedule(1:TotalReward)  = ceil(mod((((1:TotalReward)-.5)./10),2));
        if ismember(get(gcbo,'tag'),{'schedule','reset'})
            v1=0;   v2=0;
            while v1*v2==0
                [s1 v1]=listdlg('PromptString','Select Tone 1 Left Chanel:','InitialValue',2,'SelectionMode','single','ListSize',[160 160],'ListString',getparam(me,'Tn1_Left_ch','list'));
                [s2 v2]=listdlg('PromptString','Select Tone 1 Right Channel:','InitialValue',2,'SelectionMode','single','ListSize',[160 160],'ListString',getparam(me,'Tn1_Right_ch','list'));                
            end
            SetParamUI(me,'Tn1_Left_ch','UserData',s1);
            SetParamUI(me,'Tn1_Right_ch','UserData',s2);
        end
        SetParam(me,'WaterPort',WaterPort_Schedule(effective_trial));
    case 7
        SetParam(me,'CueSourceTone',3);     %location cue from BOTH tone
        SetParam(me,'Tone1_Src','user2',1);     % enable distractor from the silent channel
        SetParam(me,'Tone2_Src','user2',1);     % enable distractor from the silent channel
        SetParamUI(me,'WaterPort','enable','off');
        SetParamUI(me,'CueSourceTone','enable','off');
        if ismember(get(gcbo,'tag'),{'schedule','reset'})
            WaterPort_Schedule(1:TotalReward)  = ceil(rand(1,TotalReward)*2);
            ToneSelectFig=figure('windowstyle','normal','position',[200 200 600 100],'name','Select Tone Settings:','resize','off','numbertitle','off','menubar','none');
            tsfig=ToneSelectFig;
            tl   = uicontrol('parent',tsfig,'string','Left','style','text','horiz','center','position',[40 60 60 20]);
            tr   = uicontrol('parent',tsfig,'string','Right','style','text','horiz','center','position',[40 40 60 20]);
            t1c  = uicontrol('parent',tsfig,'string','Tone 1 Cue','style','text','horiz','center','position',[100 80 120 20]);
            ht1cl= uicontrol('style','popupmenu','background',[1 1 1],'string',getparam(me,'Tn1_Left_ch' ,'list'),'position',[100 60 120 20],'value',GetParamUI(me,'Tn1_Left_Ch', 'UserData'),'callback',['SetParamUI(''' me ''',''Tn1_Left_Ch'',''UserData'',get(gcbo,''value''));']);
            ht1cr= uicontrol('style','popupmenu','background',[1 1 1],'string',getparam(me,'Tn1_Right_ch','list'),'position',[100 40 120 20],'value',GetParamUI(me,'Tn1_Right_Ch','UserData'),'callback',['SetParamUI(''' me ''',''Tn1_Right_Ch'',''UserData'',get(gcbo,''value''));']);
            t1d  = uicontrol('parent',tsfig,'string','Tone 1 distractor','style','text','horiz','center','position',[220 80 120 20]);
            ht1dl= uicontrol('style','popupmenu','background',[1 1 1],'string',getparam(me,'Tn1_Left_ch' ,'list'),'position',[220 60 120 20],'value',GetParam(me,'Tn1_Left_Ch','user2'),'callback',['SetParam(''' me ''',''Tn1_Left_Ch'',''user2'',get(gcbo,''value''));']);
            ht1dr= uicontrol('style','popupmenu','background',[1 1 1],'string',getparam(me,'Tn1_Right_ch','list'),'position',[220 40 120 20],'value',GetParam(me,'Tn1_Right_Ch','user2'),'callback',['SetParam(''' me ''',''Tn1_Right_Ch'',''user2'',get(gcbo,''value''));']);
            t2c  = uicontrol('parent',tsfig,'string','Tone 2 Cue','style','text','horiz','center','position',[360 80 120 20]);
            ht2cl= uicontrol('style','popupmenu','background',[1 1 1],'string',getparam(me,'Tn2_Left_ch' ,'list'),'position',[360 60 120 20],'value',GetParamUI(me,'Tn2_Left_Ch','UserData'),'callback',['SetParamUI(''' me ''',''Tn2_Left_Ch'',''UserData'',get(gcbo,''value''));']);
            ht2cr= uicontrol('style','popupmenu','background',[1 1 1],'string',getparam(me,'Tn2_Right_ch','list'),'position',[360 40 120 20],'value',GetParamUI(me,'Tn2_Right_Ch','UserData'),'callback',['SetParamUI(''' me ''',''Tn2_Right_Ch'',''UserData'',get(gcbo,''value''));']);
            t2d  = uicontrol('parent',tsfig,'string','Tone 2 distractor','style','text','horiz','center','position',[480 80 120 20]);
            ht2dl= uicontrol('style','popupmenu','background',[1 1 1],'string',getparam(me,'Tn2_Left_ch' ,'list'),'position',[480 60 120 20],'value',GetParam(me,'Tn2_Left_Ch','user2'),'callback',['SetParam(''' me ''',''Tn2_Left_Ch'',''user2'',get(gcbo,''value''));']);
            ht2dr= uicontrol('style','popupmenu','background',[1 1 1],'string',getparam(me,'Tn2_Right_ch','list'),'position',[480 40 120 20],'value',GetParam(me,'Tn2_Right_Ch','user2'),'callback',['SetParam(''' me ''',''Tn2_Right_Ch'',''user2'',get(gcbo,''value''));']);
            finish_btn = uicontrol('style','pushbutton','string','Finish','position',[480 10 120 20],'callback',['delete(' num2str(tsfig) ')']);
            
            try
                set(ToneSelectFig, 'visible','on');
                uiwait(ToneSelectFig);
            catch
                if ishandle(ToneSelectFig)
                    delete(ToneSelectFig)
                end
            end
        end
        SetParam(me,'WaterPort',WaterPort_Schedule(effective_trial));
    case 9
        SetParam(me,'CueSourceTone',1);     %location cue from 1st tone
        SetParam(me,'Tone1_Src','user2',1);     % enable distractor from the silent channel
%         SetParam(me,'Tone2_Src','user2',1);     % enable distractor from the silent channel
        SetParamUI(me,'WaterPort','enable','off');
        SetParamUI(me,'CueSourceTone','enable','off');
        if ismember(get(gcbo,'tag'),{'schedule','reset'})
            WaterPort_Schedule(1:TotalReward)  = ceil(rand(1,TotalReward)*2);
            ToneSelectFig=figure('windowstyle','normal','position',[200 200 400 100],'name','Select Tone Settings:','resize','off','numbertitle','off','menubar','none');
            tsfig=ToneSelectFig;
            tl   = uicontrol('parent',tsfig,'string','Left','style','text','horiz','center','position',[40 60 60 20]);
            tr   = uicontrol('parent',tsfig,'string','Right','style','text','horiz','center','position',[40 40 60 20]);
            t1c  = uicontrol('parent',tsfig,'string','Tone 1 Cue','style','text','horiz','center','position',[100 80 120 20]);
            ht1cl= uicontrol('style','popupmenu','background',[1 1 1],'string',getparam(me,'Tn1_Left_ch' ,'list'),'position',[100 60 120 20],'value',GetParamUI(me,'Tn1_Left_Ch', 'UserData'),'callback',['SetParamUI(''' me ''',''Tn1_Left_Ch'',''UserData'',get(gcbo,''value''));']);
            ht1cr= uicontrol('style','popupmenu','background',[1 1 1],'string',getparam(me,'Tn1_Right_ch','list'),'position',[100 40 120 20],'value',GetParamUI(me,'Tn1_Right_Ch','UserData'),'callback',['SetParamUI(''' me ''',''Tn1_Right_Ch'',''UserData'',get(gcbo,''value''));']);
            t1d  = uicontrol('parent',tsfig,'string','Tone 1 distractor','style','text','horiz','center','position',[220 80 120 20]);
            ht1dl= uicontrol('style','popupmenu','background',[1 1 1],'string',getparam(me,'Tn1_Left_ch' ,'list'),'position',[220 60 120 20],'value',GetParam(me,'Tn1_Left_Ch','user2'),'callback',['SetParam(''' me ''',''Tn1_Left_Ch'',''user2'',get(gcbo,''value''));']);
            ht1dr= uicontrol('style','popupmenu','background',[1 1 1],'string',getparam(me,'Tn1_Right_ch','list'),'position',[220 40 120 20],'value',GetParam(me,'Tn1_Right_Ch','user2'),'callback',['SetParam(''' me ''',''Tn1_Right_Ch'',''user2'',get(gcbo,''value''));']);
            finish_btn = uicontrol('style','pushbutton','string','Finish','position',[280 10 120 20],'callback',['delete(' num2str(tsfig) ')']);
            
            try
                set(ToneSelectFig, 'visible','on');
                uiwait(ToneSelectFig);
            catch
                if ishandle(ToneSelectFig)
                    delete(ToneSelectFig)
                end
            end
        end
        SetParam(me,'WaterPort',WaterPort_Schedule(effective_trial));
end
SetParam(me,'WaterPort_Schedule',WaterPort_Schedule);

if GetParam(me,'CueSourceTone')==1
    SetParam(me,'Tone1_src',GetParam(me,'WaterPort'));
    SetParamUI(me,'Tone1_src','enable','off');
    SetParam(me,'Tone2_src',GetParam(me,'Tone2_src','user'));
    SetParamUI(me,'Tone2_src','enable','on');
elseif GetParam(me,'CueSourceTone')==2
    SetParam(me,'Tone2_src',GetParam(me,'WaterPort'));
    SetParamUI(me,'Tone2_src','enable','off');
    SetParam(me,'Tone1_src',GetParam(me,'Tone1_src','user'));
    SetParamUI(me,'Tone1_src','enable','on');
elseif GetParam(me,'CueSourceTone')==3
    SetParam(me,'Tone1_src',GetParam(me,'WaterPort'));            
    SetParam(me,'Tone2_src',GetParam(me,'WaterPort'));
    SetParamUI(me,'Tone1_src','enable','off');
    SetParamUI(me,'Tone2_src','enable','off');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function check_tone1_src
global exper

tone1_src=GetParam(me,'tone1_src'); %{'Left';'Right';'Both/same';'Both/indp'}        
if strcmp(get(gcbo,'tag'),'tone1_src')
    SetParam(me,'Tone1_src','user',get(gcbo,'value'));
end
Freq=GetParam(me,'ToneFreq');
n_tones=length(Freq);
if tone1_src==1
    if GetParam(me,'Tone1_Src','user2')
        SetParam(me,'Tn1_Right_Ch',GetParam(me,'Tn1_Right_Ch','user2'));      % enable distractor from the silent channel
    else
        SetParam(me,'Tn1_Right_Ch',n_tones+1);
    end
    SetParamUI(me,'Tn1_Right_Ch','enable','off');
    SetParam(me,'Tn1_Left_Ch',GetParamUI(me,'Tn1_Left_Ch','UserData'));
    SetParamUI(me,'Tn1_Left_Ch','enable','on');
elseif tone1_src==2
    SetParam(me,'Tn1_Right_Ch',GetParamUI(me,'Tn1_Right_Ch','UserData'));            
    SetParamUI(me,'Tn1_Right_Ch','enable','on');
    if GetParam(me,'Tone1_Src','user2')
        SetParam(me,'Tn1_Left_Ch',GetParam(me,'Tn1_Left_Ch','user2'));      % enable distractor from the silent channel
    else
        SetParam(me,'Tn1_Left_Ch',n_tones+1);            
    end
    SetParamUI(me,'Tn1_Left_Ch','enable','off');
elseif tone1_src==3
    SetParamUI(me,'Tn1_Right_Ch','enable','off');
    SetParamUI(me,'Tn1_Left_Ch','enable','on');
    SetParam(me,'Tn1_Left_Ch',GetParamUI(me,'Tn1_Left_Ch','UserData'));
    SetParam(me,'Tn1_Right_Ch',GetParam(me,'Tn1_Left_Ch'));
elseif tone1_src==4
    SetParamUI(me,'Tn1_Right_Ch','enable','on');
    SetParam(me,'Tn1_Right_Ch',GetParamUI(me,'Tn1_Right_Ch','UserData'));
    SetParamUI(me,'Tn1_Left_Ch','enable','on');
    SetParam(me,'Tn1_Left_Ch',GetParamUI(me,'Tn1_Left_Ch','UserData'));            
end        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function check_tone2_src
global exper
        
tone2_src=GetParam(me,'tone2_src');  %{'Left';'Right';'Both/same';'Both/indp';'None'}
if strcmp(get(gcbo,'tag'),'tone2_src')
    SetParam(me,'Tone2_src','user',get(gcbo,'value'));
end

Freq=GetParam(me,'ToneFreq');
n_tones=length(Freq);
if tone2_src==1
    if GetParam(me,'Tone2_Src','user2')
        SetParam(me,'Tn2_Right_Ch',GetParam(me,'Tn2_Right_Ch','user2'));      % enable distractor from the silent channel
    else
        SetParam(me,'Tn2_Right_Ch',n_tones+1);  %silence
    end
    SetParamUI(me,'Tn2_Right_Ch','enable','off');
    SetParam(me,'Tn2_Left_Ch',GetParamUI(me,'Tn2_Left_Ch','UserData'));
    SetParamUI(me,'Tn2_Left_Ch','enable','on');
    SetParam(me,'DirectDeliver2',GetParam(me,'DirectDeliver2','user'));
    SetParamUI(me,'DirectDeliver2','enable','on');
elseif tone2_src==2
    SetParam(me,'Tn2_Right_Ch',GetParamUI(me,'Tn2_Right_Ch','UserData'));
    SetParamUI(me,'Tn2_Right_Ch','enable','on');
    if GetParam(me,'Tone2_Src','user2')
        SetParam(me,'Tn2_Left_Ch',GetParam(me,'Tn2_Left_Ch','user2'));      % enable distractor from the silent channel
    else
        SetParam(me,'Tn2_Left_Ch',n_tones+1);  %silence
    end
    SetParamUI(me,'Tn2_Left_Ch','enable','off');
    SetParam(me,'DirectDeliver2',GetParam(me,'DirectDeliver2','user'));
    SetParamUI(me,'DirectDeliver2','enable','on');
elseif tone2_src==3
    SetParamUI(me,'Tn2_Right_Ch','enable','off');
    SetParamUI(me,'Tn2_Left_Ch','enable','on');
    SetParam(me,'Tn2_Left_Ch',GetParamUI(me,'Tn2_Left_Ch','UserData'));
    SetParam(me,'Tn2_Right_Ch',GetParam(me,'Tn2_Left_Ch'));
    SetParam(me,'DirectDeliver2',GetParam(me,'DirectDeliver2','user'));
    SetParamUI(me,'DirectDeliver2','enable','on');
elseif tone2_src==4
    SetParamUI(me,'Tn2_Right_Ch','enable','on');
    SetParam(me,'Tn2_Right_Ch',GetParamUI(me,'Tn2_Right_Ch','UserData'));            
    SetParamUI(me,'Tn2_Left_Ch','enable','on');
    SetParam(me,'Tn2_Left_Ch',GetParamUI(me,'Tn2_Left_Ch','UserData'));
    SetParam(me,'DirectDeliver2',GetParam(me,'DirectDeliver2','user'));
    SetParamUI(me,'DirectDeliver2','enable','on');
elseif tone2_src==5
    SetParam(me,'Tn2_Right_Ch',n_tones+1);      %silence
    SetParamUI(me,'Tn2_Right_Ch','enable','off');
    SetParam(me,'Tn2_Left_Ch',n_tones+1);       %silence
    SetParamUI(me,'Tn2_Left_Ch','enable','on');
    SetParam(me,'DirectDeliver2',0);
    SetParamUI(me,'DirectDeliver2','enable','off'); 
end        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function update_new_schedule(id)
global exper

tr = GetParam(me,'TotalReward');
ValidPokeNum = [];
DirectDeliver_Schedule = [];

DD1=GetParam(me,'DirectDeliver1');
DD2=GetParam(me,'DirectDeliver2');
Tone2_Src=GetParam(me,'Tone2_Src');

% 1:'custom setting',2:'Left',3:'Right',4:'10L-10R',5:'Random'


ValidPokeNum(1:DD1)  = 1;
DirectDeliver_Schedule(1:DD1)=1;
if Tone2_Src==5
    ValidPokeNum(DD1+1:tr) = 1;
    DirectDeliver_Schedule(DD1+1:tr)=0;    
elseif DD2
    ValidPokeNum(DD1+1:tr) = 2;
    DirectDeliver_Schedule(DD1+1:DD1+DD2)=2;
    DirectDeliver_Schedule(DD1+DD2:tr)=0;        
else
    ValidPokeNum(DD1+1:tr) = 2;
    DirectDeliver_Schedule(DD1+1:tr)=0;
end


SetParam(me,'ValidPokeNum',ValidPokeNum);
SetParam(me,'DirectDeliver_Schedule',DirectDeliver_Schedule);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=InitTones

Freq=GetParam(me,'ToneFreq');
Dur=GetParam(me,'ToneDur')*1000;
SPL=GetParam(me,'ToneSPL');
n_tones=length(Freq);
ToneAttenuation = ones(1,n_tones)*70 -SPL;

ppfilter={'\PPfilter_right.mat' '\PPfilter_left.mat'};
for i=1:2
    FilterPath=[GetParam('rpbox','protocol_path') ppfilter{i}];
    if ( size(dir(FilterPath),1) == 1 )
        PP=load(FilterPath);
        PP=PP.PP;
        message(me,'Generating Calibrated Tones');
    else
        PP=[];
        message(me,'Generating Non-calibrated Tones');
    end
    
    for tn=1:n_tones
        if isempty(PP) | Freq(tn)== -1
            ToneAttenuation_adj = ToneAttenuation(tn);
            beep{tn}  = 1 * makebeep(50e6/1024, ToneAttenuation_adj ,Freq(tn), Dur(tn),3);
        elseif Freq(tn)== 1
            Low_Chord_freq=[3000 4000 5000 6000];
            for j=1:4
                ToneAttenuation_adj(j) = ToneAttenuation(tn) - ppval(PP, log10(Low_Chord_freq(j)));
                % Remove any negative attenuations and replace with zero attenuation.
                ToneAttenuation_adj(j) = ToneAttenuation_adj(j) .* (ToneAttenuation_adj(j) > 0);
            end
            beep{tn}  = 1/4 * (makebeep(50e6/1024, ToneAttenuation_adj(1) ,Low_Chord_freq(1), Dur(tn),3)+...
                makebeep(50e6/1024, ToneAttenuation_adj(2) ,Low_Chord_freq(2), Dur(tn),3)+...
                makebeep(50e6/1024, ToneAttenuation_adj(3) ,Low_Chord_freq(3), Dur(tn),3)+...
                makebeep(50e6/1024, ToneAttenuation_adj(4) ,Low_Chord_freq(4), Dur(tn),3));
        elseif Freq(tn)== 2 
            Hi_Chord_freq=[5000 10000 15000 20000];
            for j=1:4
                ToneAttenuation_adj(j) = ToneAttenuation(tn) - ppval(PP, log10(Hi_Chord_freq(j)));
                % Remove any negative attenuations and replace with zero attenuation.
                ToneAttenuation_adj(j) = ToneAttenuation_adj(j) .* (ToneAttenuation_adj(j) > 0);
            end
            beep{tn}  = 1/4 * (makebeep(50e6/1024, ToneAttenuation_adj(1) ,Hi_Chord_freq(1), Dur(tn),3)+...
                makebeep(50e6/1024, ToneAttenuation_adj(2) ,Hi_Chord_freq(2), Dur(tn),3)+...
                makebeep(50e6/1024, ToneAttenuation_adj(3) ,Hi_Chord_freq(3), Dur(tn),3)+...
                makebeep(50e6/1024, ToneAttenuation_adj(4) ,Hi_Chord_freq(4), Dur(tn),3));
        else
            ToneAttenuation_adj = ToneAttenuation(tn) - ppval(PP, log10(Freq(tn)));
            % Remove any negative attenuations and replace with zero attenuation.
            ToneAttenuation_adj = ToneAttenuation_adj .* (ToneAttenuation_adj > 0);
            beep{tn}  = 1 * makebeep(50e6/1024, ToneAttenuation_adj ,Freq(tn), Dur(tn),3);
        end
    end

    [mxDur idx]=max(Dur);
    beep{tn+1} = beep{idx}*0;
    Beep{i}=beep;
end
    
SetParam(me,'rbeep',Beep{1});
SetParam(me,'lbeep',Beep{2});
out=beep;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=CurrentTones
rbeep=GetParam(me,'rbeep');
lbeep=GetParam(me,'lbeep');
Freq=GetParam(me,'ToneFreq');
Dur=GetParam(me,'ToneDur')*1000;
n_tones=length(Freq);
SPL=GetParam(me,'ToneSPL');
ToneAttenuation = ones(1,n_tones)*70 -SPL;
rand_tn=n_tones+2;

Tn1_Right_Ch = GetParam(me,'Tn1_Right_Ch');
if Tn1_Right_Ch== rand_tn
    Tn1_Right_Ch=ceil(rand*n_tones);
end
if Tn1_Right_Ch <= n_tones & Freq(Tn1_Right_Ch)==-1
    r_beep1  = 1 * makebeep(50e6/1024, ToneAttenuation(Tn1_Right_Ch) ,Freq(Tn1_Right_Ch), Dur(Tn1_Right_Ch),3);
else
    r_beep1=rbeep{Tn1_Right_Ch};
end

Tn1_Left_Ch=GetParam(me,'Tn1_Left_Ch');
Tone1_Src=GetParam(me,'Tone1_Src');
if Tn1_Left_Ch== rand_tn & Tone1_Src==3
    Tn1_Left_Ch=Tn1_Right_Ch;
elseif Tn1_Left_Ch== rand_tn
    Tn1_Left_Ch=ceil(rand*n_tones);        
end
if Tn1_Left_Ch <= n_tones &Freq(Tn1_Left_Ch)==-1
    l_beep1  = 1 * makebeep(50e6/1024, ToneAttenuation(Tn1_Left_Ch) ,Freq(Tn1_Left_Ch), Dur(Tn1_Left_Ch),3);
else
    l_beep1=lbeep{Tn1_Left_Ch};
end


Tn2_Right_Ch=GetParam(me,'Tn2_Right_Ch');
if Tn2_Right_Ch== rand_tn
    Tn2_Right_Ch=ceil(rand*n_tones);
end
if Tn2_Right_Ch <= n_tones &Freq(Tn2_Right_Ch)==-1
    r_beep2  = 1 * makebeep(50e6/1024, ToneAttenuation(Tn2_Right_Ch) ,Freq(Tn2_Right_Ch), Dur(Tn2_Right_Ch),3);
else
    r_beep2=rbeep{Tn2_Right_Ch};
end

Tn2_Left_Ch=GetParam(me,'Tn2_Left_Ch');
Tone2_Src=GetParam(me,'Tone2_Src');
if Tn2_Left_Ch== rand_tn & Tone2_Src==3
    Tn2_Left_Ch=Tn2_Right_Ch;
elseif Tn2_Left_Ch== rand_tn
    Tn2_Left_Ch=ceil(rand*n_tones);
end
if Tn2_Left_Ch <= n_tones &Freq(Tn2_Left_Ch)==-1
    l_beep2  = 1 * makebeep(50e6/1024, ToneAttenuation(Tn2_Left_Ch) ,Freq(Tn2_Left_Ch), Dur(Tn2_Left_Ch),3);
else
    l_beep2=lbeep{Tn2_Left_Ch};
end

out={r_beep1;l_beep1;...
     r_beep2;l_beep2};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=me
% Simple function for getting the name of this m-file.
out=lower(mfilename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = callback
out = [lower(mfilename) ';'];

