function out = matt_operant(varargin)

global exper

if nargin > 0 
    action = lower(varargin{1});
else
    action = lower(get(gcbo,'tag'));
end





switch action
    
    case 'init'
        ModuleNeeds(me,{'rpbox'});
        
        SetParam(me,'priority','value',GetParam('rpbox','priority')+1);
        fig = ModuleFigure(me,'visible','off');	
        
        exper.rpbox.now.calc.LeftPoke = 0;
        exper.rpbox.now.calc.RightPoke = 0;
        exper.rpbox.now.calc.LeftReward = 0;
        exper.rpbox.now.calc.RightReward = 0;
        exper.rpbox.now.calc.Reward = 0;
        exper.rpbox.now.calc.OdorPoke = 0;
        
        hs = 100;
        h = 5;
        vs = 20;
        n = 0;
        
        n=n+1;

        InitParam(me,'WaterValveDur','ui','edit','value',0.2,'user',0.2,'pos',[h n*vs hs*.7 vs]); n=n+1;
        SetParamUI(me,'WaterValveDur','label','WaterValvDur');
        InitParam(me,'ValidPokeDur','ui','edit','value',0.1,'user',0.1,'pos',[h n*vs hs*.7 vs]);
        SetParamUI(me,'ValidPokeDur','label','ValidPokeDur');
        InitParam(me,'LeftPort','ui','pushbutton','value',0,'Enable','on','pref',0,'pos',[h+hs*1.6 n*vs hs*.65 vs]);
        SetParamUI(me,'LeftPort','String','Left Port','label','');
        InitParam(me,'CenterPort','ui','pushbutton','value',0,'Enable','on','pref',0,'pos',[h+hs*2.25 n*vs hs*.65 vs]);
        SetParamUI(me,'CenterPort','String','Center Port','label','');    
        InitParam(me,'RightPort','ui','pushbutton','value',0,'Enable','on','pref',0,'pos',[h+hs*2.9 n*vs hs*.65 vs]);
        SetParamUI(me,'RightPort','String','Right Port','label',''); n=n+1.4;
        
        InitParam(me,'Rewards','ui','disp','value',0,'pos',[h n*vs hs*.7 vs]); 
        SetParamUI(me,'Rewards','label','Rewards');
        % message box
        uicontrol(fig,'tag','message','style','edit',...
            'enable','inact','horiz','left','pos',[h+hs*1.6 n*vs hs*1.95 vs]); n = n+1.4;
        
        TotalReward=80;
        InitParam(me,'TotalReward','value',TotalReward);
        
        % reward schedule (determines ratio that rat can get reward for water pokes)
        ratio = [1 1 1 1 1 1 2 2 2 2 2 3 3 3 3 4 4 4 5 5]; % 'progressive fixed ratio'
        for i = 21: TotalReward 
            ratio(i) = ceil(rand*1);						% 'random ratio'
        end
        
        trial = rem((GetParam('RPBox','trial')-20),60)+21;
        next_ratio=1;
        InitParam(me,'RewardRatio','value',next_ratio,'list',ratio);
        plot_ratio;
%%%MCS whitenoise code from josh
        if isequal(GetParam('RPBox','trial'), 1)
        freq = 200;
        coeff = 5000/freq;
        csnd = (1:4000000);
        csnd = .0005*sin((pi/coeff)*csnd);
        for x = 1 : 4000000
             csnd(x) = csnd(x) + sin(rand);
        end
            %upload sounds to state machine

        rpbox('InitRP3StereoSound');
        sm = rpbox('getsoundmachine');
        sm = SetSampleRate(sm, 200000);
        sm = LoadSound(sm, 1, csnd, 'both', 0, 0); %white noise
        sm = rpbox('setsoundmachine', sm);
 
        out=1;  
        end
        %END OF NOISES
        rpbox('send_matrix',state_transition_matrix(next_ratio));
        set(fig,'pos',[140 461-n*vs hs*4+8 (n+10)*vs],'visible','on');
        
    case 'trialend'
      
    case 'reset'
        next_ratio=NextRewardRatio;
        rpbox('send_matrix',state_transition_matrix(next_ratio));
        SetParam(me,'Rewards',0);
        plot_ratio;
        update_ratio_plot;
        
    case 'update'
        Event=Getparam('rpbox','event','user');
        for i=1:size(Event,1)
            if Event(i,2)==1
                SetParamUI(me,'CenterPort','BackgroundColor',[0 1 0]);
            elseif Event(i,2)==2
                SetParamUI(me,'CenterPort','BackgroundColor',[0.8 0.8 0.8]);
            elseif Event(i,2)==3
                SetParamUI(me,'LeftPort','BackgroundColor',[0 1 0]);
            elseif Event(i,2)==4
                SetParamUI(me,'LeftPort','BackgroundColor',[0.8 0.8 0.8]);
            elseif Event(i,2)==5
                SetParamUI(me,'RightPort','BackgroundColor',[0 1 0]);
            elseif Event(i,2)==6
                SetParamUI(me,'RightPort','BackgroundColor',[0.8 0.8 0.8]);
            else
            end
        end
    case 'state35'
        SetParam(me,'Rewards',GetParam(me,'Rewards')+1);
        update_ratio_plot;
        next_ratio=NextRewardRatio;
        rpbox('send_matrix',state_transition_matrix(next_ratio));
        update_ratio_plot;
        
    case 'leftport'
        if existparam('rpbox', 'RP')
            RP=GetParam('rpbox', 'RP');
            wvd=GetParam(me,'WaterValveDur');
            invoke(RP,'SetTagVal','Dio_Hi_Bits',bin2dec('00000001'));
            invoke(RP,'SetTagVal','Dio_Hi_Dur',wvd*6000);
            invoke(RP,'SoftTrg',5);
        end
        message(me,['Left Valve Opened ' num2str(wvd) ' Sec'],'cyan');
        
    case 'rightport'
        if existparam('rpbox', 'RP')
            RP=GetParam('rpbox', 'RP');
            wvd=GetParam(me,'WaterValveDur');
            invoke(RP,'SetTagVal','Dio_Hi_Bits',bin2dec('00000010'));
            invoke(RP,'SetTagVal','Dio_Hi_Dur',wvd*6000);
            invoke(RP,'SoftTrg',5);
        end
        message(me,['Right Valve Opened '  num2str(wvd)  ' Sec'],'cyan');
        
    case 'close'
        SetParam('rpbox','protocols',1);
    otherwise
        out=0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function out=NextRewardRatio
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
Reward = GetParam(me,'Rewards');
TotalReward=GetParam(me,'TotalReward');
ratio = GetParam(me,'RewardRatio','list');

if Reward >= TotalReward
    next_ratio=ratio(rem((Reward-20),60)+20);
else
    next_ratio=1;
end

out=next_ratio;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function out=state_transition_matrix(RewardRatio)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% the columns of the transition matrix represent inputs
% Cin,Cout,Lin,Lout,Rin, Rout, Times-up
% The rows are the states (from Staet 0 upto 32)
% The timer is in unit of seconds, # of columns >= # of states
% DIO output in "word" format, 1=DIO-0_ON, 8=DIO-3_ON (DIO-0~8) 
% AO output in "word" format, 1=AO-1_ON, 3=AO-1,2_ON,  (AO-1,2)
vpd=GetParam(me,'ValidPokeDur');
wvd=GetParam(me,'WaterValveDur');
rtm=floor(10+(rand*10))
global left1water;
global right1water;
lvid = left1water;
rvid = right1water;
state_transition_matrix{1}=[ ...
%  Cin Cout Lin Lout Rin Rout TimeUp Timer DIO AO  
    0    0   1    0   2    0    0     20   0   1;  % State 0 "Pre-State"
    1    0   1    0   2    0    3     vpd   0   0;  % State 1 "Left Poke in"
    2    0   1    0   2    0    4     vpd   0   0;  % State 2 "Right Poke in"    
    3    3   3    3   3    3    5     wvd   lvid  -1; % State 3 "Valid Poke ==> Water!!! :)"
    4    4   4    4   4    4    5     wvd   rvid  -1;% State 4 "Valid Poke ==> Water!!! :)"
    5    5   5    5   5    5   35     rtm   0   0;];  % State 5 "post-State"

out=state_transition_matrix{RewardRatio};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_ratio
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prepare axis to plot score
fig=findobj('tag','matt_operant');
figure(fig);
ax = findobj(fig,'tag','score_ratio');
if ~isempty(ax)
    axes(ax);
    set(ax,'pos',[.15 .45 .75 .5]);
else
    ax = axes('tag','score_ratio','pos',[.15 .45 .75 .5]);    
end
plot(GetParam(me,'RewardRatio','list'),'.'); hold on
plot(1,NextRewardRatio,'or');
xlabel('rewards');
ylabel('reward ratio');
set(ax,'tag','score_ratio');

% --------------------------------------------------------------------
function update_ratio_plot
global exper

Reward = GetParam(me,'Rewards');
RewardRatio=GetParam(me,'RewardRatio','list');
fig=findobj('tag','matt_operant');
a = findobj(fig,'tag','score_ratio');
if ~isempty(a)
    axes(a);
    plot(RewardRatio,'.');
    hold on;
    plot(Reward+1,NextRewardRatio,'or');
    hold off;
    xlabel('rewards');
    ylabel('reward ratio');
    set(a,'tag','score_ratio');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=me
% Simple function for getting the name of this m-file.
out=lower(mfilename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = callback
out = [lower(mfilename) ';'];

