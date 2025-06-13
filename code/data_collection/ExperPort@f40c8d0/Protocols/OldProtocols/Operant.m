function out = operant(varargin)

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
            ratio(i) = ceil(rand*6);						% 'random ratio'
        end
        
        trial = rem((GetParam('Control','trial')-20),60)+20;
        next_ratio=ratio(trial);
        InitParam(me,'RewardRatio','value',next_ratio,'list',ratio);
        plot_ratio;
        
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
    next_ratio=ratio(Reward+1);
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

state_transition_matrix{1}=[ ...
%  Cin Cout Lin Lout Rin Rout TimeUp Timer DIO AO  
    0    0   1    0   2    0    0     180   0   0;  % State 0 "Pre-State"
    1    0   1    0   2    0    3     vpd   0   0;  % State 1 "Left Poke in"
    2    0   1    0   2    0    4     vpd   0   0;  % State 2 "Right Poke in"    
    3    3   3    3   3    3   35     wvd   1   0;  % State 3 "Valid Poke ==> Water!!! :)"
    4    4   4    4   4    4   35     wvd   2   0;];% State 4 "Valid Poke ==> Water!!! :)"

state_transition_matrix{2}=[ ...
%  Cin Cout Lin Lout Rin Rout TimeUp Timer DIO AO  
    1    0   1    0   1    0    0     180   0   0;  % State 0 "Pre-State"
    1    0   1    0   1    0    2     vpd   0   0;  % State 1 "1st Poke in"
    2    3   2    3   2    3    2     180   0   0;  % State 2 "pre 1st Poke out"

    3    3   4    3   5    3    3     180   0   0;  % State 3 "pre 2nd Poke in"
    4    3   4    3   5    3    6     vpd   0   0;  % State 4 "Left 2nd Poke in"
    5    3   4    3   5    3    7     vpd   0   0;  % State 5 "Right 2nd Poke in"
    6    6   6    6   6    6   35     wvd   1   0;  % State 6 "Valid Poke ==> Water!!! :)"
    7    7   7    7   7    7   35     wvd   2   0;];% State 7 "Valid Poke ==> Water!!! :)"

state_transition_matrix{3}=[ ...
%  Cin Cout Lin Lout Rin Rout TimeUp Timer DIO AO  
    1    0   1    0   1    0    0     180   0   0;  % State 0
    1    0   1    0   1    0    2     vpd   0   0;  % State 1
    2    3   2    3   2    3    2     180   0   0;  % State 2
    4    3   4    3   4    3    3     180   0   0;  % State 3
    4    3   4    3   4    3    5     vpd   0   0;  % State 4
    5    6   5    6   5    6    5     180   0   0;  % State 5
    
    6    6   7    6   8    6    6     180   0   0;  % State 6
    7    6   7    6   8    6    9     vpd   0   0;  % State 7
    8    6   7    6   8    6   10     vpd   0   0;  % State 8    
    9    9   9    9   9    9   35     wvd   1   0;  % State 9    
   10   10  10   10  10   10   35     wvd   2   0;];% State 10

state_transition_matrix{4}=[ ...
%  Cin Cout Lin Lout Rin Rout TimeUp Timer DIO AO  
    1    0   1    0   1    0    0     180   0   0;  % State 0
    1    0   1    0   1    0    2     vpd   0   0;  % State 1
    2    3   2    3   2    3    2     180   0   0;  % State 2   
    4    3   4    3   4    3    3     180   0   0;  % State 3
    4    3   4    3   4    3    5     vpd   0   0;  % State 4
    5    6   5    6   5    6    5     180   0   0;  % State 5
    7    6   7    6   7    6    6     180   0   0;  % State 6   
    7    6   7    6   7    6    8     vpd   0   0;  % State 7
    8    9   8    9   8    9    8     180   0   0;  % State 8

    9    9  10    9  11    9    9     180   0   0;  % State 9
   10    9  10    9  11    9   12     vpd   0   0;  % State 10
   11    9  10    9  11    9   13     vpd   0   0;  % State 11   
   12   12  12   12  12   12   35     wvd   1   0;  % State 12   
   13   13  13   13  13   13   35     wvd   2   0;];% State 13

state_transition_matrix{5}=[ ...
%  Cin Cout Lin Lout Rin Rout TimeUp Timer DIO AO  
    1    0   1    0   1    0    0     180   0   0;  % State 0
    1    0   1    0   1    0    2     vpd   0   0;  % State 1
    2    3   2    3   2    3    2     180   0   0;  % State 2   
    4    3   4    3   4    3    3     180   0   0;  % State 3
    4    3   4    3   4    3    5     vpd   0   0;  % State 4
    5    6   5    6   5    6    5     180   0   0;  % State 5
    7    6   7    6   7    6    6     180   0   0;  % State 6   
    7    6   7    6   7    6    8     vpd   0   0;  % State 7
    8    9   8    9   8    9    8     180   0   0;  % State 8
   10    9   10   9   10   9    9     180   0   0;  % State 9   
   10    9   10   9   10   9   11     vpd   0   0;  % State 10
   11   12   11   12  11   12  11     180   0   0;  % State 11

   12   12   13   12  14   12  12     180   0   0;  % State 12
   13   12   13   12  14   12  15     vpd   0   0;  % State 13
   14   12   13   12  14   12  16     vpd   0   0;  % State 14   
   15   15   15   15  15   15  35     wvd   1   0;  % State 15   
   16   16   16   16  16   16  35     wvd   2   0;];% State 16
   
state_transition_matrix{6}=[ ...
%  Cin Cout Lin Lout Rin Rout TimeUp Timer DIO AO  
    1    0   1    0   1    0    0     180   0   0;  % State 0
    1    0   1    0   1    0    2     vpd   0   0;  % State 1
    2    3   2    3   2    3    2     180   0   0;  % State 2   
    4    3   4    3   4    3    3     180   0   0;  % State 3
    4    3   4    3   4    3    5     vpd   0   0;  % State 4
    5    6   5    6   5    6    5     180   0   0;  % State 5
    7    6   7    6   7    6    6     180   0   0;  % State 6   
    7    6   7    6   7    6    8     vpd   0   0;  % State 7
    8    9   8    9   8    9    8     180   0   0;  % State 8
   10    9   10   9   10   9    9     180   0   0;  % State 9   
   10    9   10   9   10   9   11     vpd   0   0;  % State 10
   11   12   11   12  11   12  11     180   0   0;  % State 11
   13   12   13   12  13   12  12     180   0   0;  % State 12   
   13   12   13   12  13   12  14     vpd   0   0;  % State 13
   14   15   14   15  14   15  14     180   0   0;  % State 14

   15   15   16   15  17   15  15     180   0   0;  % State 15
   16   15   16   15  17   15  18     vpd   0   0;  % State 16
   17   15   16   15  17   15  19     vpd   0   0;  % State 17   
   18   18   18   18  18   18  35     wvd   1   0;  % State 18   
   19   19   19   19  19   19  35     wvd   2   0;];% State 19

out=state_transition_matrix{RewardRatio};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_ratio
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prepare axis to plot score
fig=findobj('tag','operant');
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
fig=findobj('tag','operant');
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

