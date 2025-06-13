function [out] = Probsamp4(varargin)

% - Implement time out sound
% - Make sure sounds are as in Operant3.m
% - water: direct delivery, next correct poke, only if correct poke
% - water delivery to both ports (only if not direct delivery) | correct port
% - sounds: the two swoops + constant tone
% - LeftProb

global exper

if nargin > 0 
    action = lower(varargin{1});
else
    action = lower(get(gcbo,'tag'));
end

out=1;  
switch action
    
    case 'init'
        ModuleNeeds(me, {'rpbox'});
        SetParam(me,'priority','value',GetParam('rpbox','priority')+1);
        fig = ModuleFigure(me,'visible','off');	
            
        rownum = 1; colnum = 1;

        InitializeUIEditParam('ITILength',                             0.2, rownum, colnum);   rownum = rownum+1;
        InitializeUIMenuParam('ITISound',    {'silence', 'white noise'}, 2, rownum, colnum);   rownum = rownum+1;
        InitializeUIEditParam('TimeOutLength',                         0.2, rownum, colnum);   rownum = rownum+1;
        InitializeUIMenuParam('TimeOutSound',{'silence', 'white noise'}, 2, rownum, colnum);   rownum = rownum+1;
        InitializeUIEditParam('DrinkTime',                               1, rownum, colnum);   rownum = rownum+1;
        rownum = rownum+0.5; % Blank row
        InitializeUIMenuParam('LeftSound',  {'silence', '5k->10k', '7.5k->7.5k'}, 2, rownum, colnum);  rownum = rownum+1;
        InitializeUIMenuParam('RightSound', {'silence', '10k->5k', '7.5k->7.5k'}, 2, rownum, colnum);  rownum = rownum+1;
        InitializeUIEditParam('ToneDur',                               0.4, rownum, colnum);   rownum = rownum+1; 
        InitializeUIEditParam('RampDur',                             0.005, rownum, colnum);   rownum = rownum+1; 
        rownum = rownum+0.5; % Blank row
        InitializeUIEditParam('ValidPokeDur',                         0.15, rownum, colnum);   rownum = rownum+1; 
        InitializeUIDispParam('ValidInterPoke',                        NaN, rownum, colnum);   rownum = rownum+1; 
        InitializeUIDispParam('Poke4',                                   0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('InterPoke3',                              0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('Poke3',                                   0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('InterPoke2',                              0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('Poke2',                                   0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('InterPoke1',                              0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('Poke1',                                   0, rownum, colnum);   rownum = rownum+1;
        % rownum = rownum+0.5; % Blank row    
        % InitializeUIMenuParam('PokesPerReward', {'1' '2' '3' '4' '5' '6'},1,rownum, colnum);   rownum = rownum+1; 
        
        rownum = 1; colnum = 3;
        InitializeUIEditParam('LeftWValveTime',                        0.2, rownum, colnum);   rownum = rownum+1;
        InitializeUIEditParam('RightWValveTime',                      0.14, rownum, colnum);   rownum = rownum+1;
        InitializeUIEditParam('LeftProb',                              0.5, rownum, colnum);   rownum = rownum+1;
        rownum = rownum+0.5; % Blank row
        InitializeUIDispParam('CenterPokes',                             0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('LeftPokes',                               0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('RightPokes',                              0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('LeftRewards',                             0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('RightRewards',                            0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('Rewards',                                 0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('Trials',                                  0, rownum, colnum);   rownum = rownum+1;
        InitializeUIMenuParam('WaterDelivery', {'direct', 'next correct poke', 'only if next poke correct'}, 2, rownum, colnum); rownum = rownum+1;
        InitializeUIMenuParam('RewardPorts',   {'correct port', 'both ports'},1,rownum,colnum);rownum = rownum+1;
        
        rownum = rownum+0.5;
        InitParam(me,  'LeftPort',   'ui', 'togglebutton', 'pref', 0, 'enable', 'inact', 'pos', position(rownum, colnum, 0.4));
        SetParamUI(me, 'LeftPort',   'label', '', 'enable', 'inact', 'String', 'Left');
        InitParam(me,  'CenterPort', 'ui', 'togglebutton', 'pref', 0, 'enable', 'inact', 'pos', position(rownum, colnum+0.5, 0.4));
        SetParamUI(me, 'CenterPort', 'label', '', 'enable', 'inact', 'String', 'Center');
        InitParam(me,  'RightPort',  'ui', 'togglebutton', 'pref', 0, 'enable', 'inact', 'pos', position(rownum, colnum+1, 0.4));
        SetParamUI(me, 'RightPort',  'label', '', 'enable', 'inact', 'String', 'Right'); rownum = rownum+1;
        
        rownum = rownum+0.5;
        InitializeUIMenuParam('Stubbornness', {'off', 'on'},             1, rownum, colnum);   rownum = rownum + 1;
       
        InitParam(me, 'LastPokeInTime', 'value', 0); InitParam(me, 'LastPokeOutTime');
        InitParam(me, 'LrwS',   'value', 0); InitParam(me, 'RrwS', 'value', 0); % state #'s for Left  and Right  reward
        InitParam(me, 'LddS',   'value', 0); InitParam(me, 'RddS', 'value', 0); % state #'s for Left  and Right  direct del
        InitParam(me, 'pstart', 'value', 2); InitParam(me, 'WpkS', 'value', 0);
        
        % ------ Schedule ---------
        maxtrials = 1000; InitParam(me, 'MaxTrials',     'value', maxtrials);
        InitParam(me, 'SideList', 'value', zeros(1, maxtrials));
        set_future_sides(1);
        InitParam(me, 'RewardHistory',       'value', []);  % defined in terms of first sideport response 'hm'
        InitParam(me, 'RewardPortsHistory',  'value', []);  % trial-by-trial history of the value of RewardPort 'cb'
        InitParam(me, 'WaterDeliveryHistory','value', []);  % trial-by-trial history of water deliver method 'dno' 
        initialize_plot;
        
        % ------ Sounds ----------
        FreqStart = [10000    5000    7500];  % Hz
        FreqEnd   = [ 5000   10000    7500];  % Hz
        SPL       = 70;                       % Max=PPdB SPL
        
        InitParam(me, 'ToneFreqStart','value', FreqStart);
        InitParam(me, 'ToneFreqEnd',  'value', FreqEnd);
        InitParam(me, 'ToneSPL',      'value', SPL);

        InitParam(me, 'CurrentSide',  'value', []); InitParam(me, 'CurrentHit', 'value', []);
        InitParam(me, 'Sounds',       'value', MakeSounds);
        InitParam(me, 'StateMatrix',  'value', state_transition_matrix);
        update_settings_histories;
        rpbox('InitRPSound');
        rpbox('LoadRPSound', GetParam(me,'Sounds'));
        rpbox('send_matrix', GetParam(me, 'StateMatrix'));
        set(fig, 'Visible', 'on');
        
        return;
        
    case 'update',
        LrwS   = GetParam(me, 'LrwS'); % Get the state numbers that correspond to Left Reward and Right Reward States
        RrwS   = GetParam(me, 'RrwS');
        WpkS   = GetParam(me, 'WpkS'); LddS = GetParam(me, 'LddS'); RddS = GetParam(me, 'RddS');
        pstart = GetParam(me, 'pstart'); 
        Event = Getparam('rpbox','event','user');
        
        for i=1:size(Event,1)
            if     Event(i,2)==1
                SetParamUI(me,'CenterPort','BackgroundColor',[0 1 0]);
                SetParam(me, 'LastPokeInTime', Event(i,3));
                SetParam(me, 'CenterPokes', GetParam(me, 'CenterPokes')+1);
            elseif Event(i,2)==2
                SetParamUI(me,'CenterPort','BackgroundColor',[0.8 0.8 0.8]);
                SetParam(me, 'LastPokeOutTime', Event(i,3));
                lastpokeouttime = Event(i,3);
            elseif Event(i,2)==3
                SetParamUI(me,'LeftPort','BackgroundColor',[0 1 0]);
                SetParam(me, 'LastPokeInTime', Event(i,3));
                SetParam(me, 'LeftPokes', GetParam(me, 'LeftPokes')+1);
            elseif Event(i,2)==4
                SetParamUI(me,'LeftPort','BackgroundColor',[0.8 0.8 0.8]);
                SetParam(me, 'LastPokeOutTime', Event(i,3));
                lastpokeouttime = Event(i,3);
            elseif Event(i,2)==5
                SetParamUI(me,'RightPort','BackgroundColor',[0 1 0]);
                SetParam(me, 'LastPokeInTime', Event(i,3));
                SetParam(me, 'RightPokes', GetParam(me, 'RightPokes')+1);
            elseif Event(i,2)==6
                SetParamUI(me,'RightPort','BackgroundColor',[0.8 0.8 0.8]);
                SetParam(me, 'LastPokeOutTime', Event(i,3));
                lastpokeouttime = Event(i,3);
            else
            end
            
            current_side = GetParam(me, 'CurrentSide'); current_hit = GetParam(me, 'CurrentHit');
            if isempty(current_hit),  % haven't figured out yet if this trial was a hit
                if Event(i,1)==WpkS,  % we're in the post-sample tone, wait for poke act state
                    if     ( (Event(i,2)==3 & current_side=='l') | (Event(i,2)==5 & current_side=='r') ),
                        SetParam(me, 'CurrentHit', 'h');
                        SetParam(me, 'RewardHistory', [GetParam(me, 'RewardHistory') ; 'h']);
                    elseif ( (Event(i,2)==3 & current_side=='r') | (Event(i,2)==5 & current_side=='l') ),
                        SetParam(me, 'CurrentHit', 'm');
                        SetParam(me, 'RewardHistory', [GetParam(me, 'RewardHistory') ; 'm']);
                    end;
                end;
            end;
            
            if     Event(i,1)==LrwS  |  Event(i,1)==1+LddS,
                SetParam(me, 'LeftRewards',    GetParam(me, 'LeftRewards') +1);
                SetParam(me, 'Rewards',        GetParam(me, 'Rewards') +1);
            elseif Event(i,1)==RrwS  |  Event(i,1)==RddS, 
                SetParam(me, 'RightRewards',   GetParam(me, 'RightRewards')+1);
                SetParam(me, 'Rewards',        GetParam(me, 'Rewards') +1);
            end;
            
            if ismember(Event(i,2), [2 4 6]), % it was a poke out
                SetParam(me, 'Poke4', GetParam(me, 'Poke3'));
                SetParam(me, 'Poke3', GetParam(me, 'Poke2'));
                SetParam(me, 'Poke2', GetParam(me, 'Poke1'));
                SetParam(me, 'Poke1', lastpokeouttime - GetParam(me, 'LastPokeInTime'));
            elseif ismember(Event(i,2), [1 3 5]), % it was a poke in
                SetParam(me, 'InterPoke3', GetParam(me, 'InterPoke2'));
                SetParam(me, 'InterPoke2', GetParam(me, 'InterPoke1'));
                SetParam(me, 'InterPoke1', GetParam(me, 'LastPokeInTime') - GetParam(me, 'LastPokeOutTime'));               
            end;
        end
        if size(Event,1)>0,
            laststate = Event(end,1);
        end;
        
        return;
        
    case 'close',
        SetParam('rpbox','protocols',1);
        return;
        
    case 'state35',
        Trials       = GetParam(me, 'Trials');
        Stubbornness = GetParam(me, 'Stubbornness');
        if Stubbornness==2 & GetParam(me, 'CurrentHit')=='m',
            side_list = GetParam(me, 'SideList');
            side_list(Trials+2:end) = side_list(Trials+1:end-1);
            SetParam(me, 'SideList', side_list);
        end;
        SetParam(me, 'Trials', GetParam(me, 'Trials')+1);
        SetParam(me, 'Sounds', MakeSounds); rpbox('LoadRPSound', GetParam(me, 'Sounds')); 
        SetParam(me, 'StateMatrix', state_transition_matrix);     
        Stubbornness = GetParam(me, 'Stubbornness');

        SetParam(me, 'CurrentHit',  []);

        update_plot;
        update_settings_histories;
        rpbox('send_matrix', GetParam(me, 'StateMatrix'));
        
        
    case 'leftprob'
        if GetParam('rpbox', 'state')==35, set_future_sides(GetParam(me, 'Trials')+1);
        else                               set_future_sides(GetParam(me, 'Trials')+2);
        end;
        update_plot;
                
    case 'rewardports'
        if GetParam(me, 'RewardPorts') == 1,  
            SetParamUI(me, 'WaterDelivery', 'enable', 'on',  'backgroundcolor', 'w');
        else                                  
            SetParamUI(me, 'WaterDelivery', 'enable', 'off', 'backgroundcolor', [0.8 0.8 0.8]);
            SetParam(me, 'RightSound', 3);
            SetParam(me, 'LeftSound',  3);
        end;
        
    case 'rightsound'
        if GetParam(me, 'RightSound') == 3,
            SetParam(me, 'LeftSound', 'value', 3); SetParam(me, 'RewardPorts', 2); probsamp4('rewardports');
        end;
        
    case 'leftsound'
        if GetParam(me, 'LeftSound') == 3,
            SetParam(me, 'RightSound', 'value', 3); SetParam(me, 'RewardPorts', 2); probsamp4('rewardports');
        end;
        
    case 'reset'
        SetParam(me, 'Poke1', 0); SetParam(me, 'InterPoke1', 0); 
        SetParam(me, 'Poke2', 0); SetParam(me, 'InterPoke2', 0); 
        SetParam(me, 'Poke3', 0); SetParam(me, 'InterPoke3', 0); 
        SetParam(me, 'Poke4', 0);
        
        SetParam(me, 'Trials', 0); SetParam(me, 'Rewards', 0); SetParam(me, 'RightRewards', 0);
        SetParam(me, 'LeftRewards', 0); SetParam(me, 'RightPokes', 0); SetParam(me, 'LeftPokes', 0);
        SetParam(me, 'CenterPokes', 0);
        
        SetParam(me, 'LastPokeInTime', 'value', 0); SetParam(me, 'LastPokeOutTime', 'value', 0);
        set_future_sides(1);
        SetParam(me, 'RewardHistory',       'value', []);  % defined in terms of first sideport response 'hm'
        SetParam(me, 'RewardPortsHistory',  'value', []);  % trial-by-trial history of the value of RewardPort 'cb'
        SetParam(me, 'WaterDeliveryHistory','value', []);  % trial-by-trial history of water deliver method 'dno' 
        initialize_plot;
        
        SetParam(me, 'CurrentSide',  'value', []); SetParam(me, 'CurrentHit', 'value', []);
        SetParam(me, 'Sounds',       'value', MakeSounds);
        SetParam(me, 'StateMatrix',  'value', state_transition_matrix);
        update_settings_histories;
        rpbox('InitRPSound');
        rpbox('LoadRPSound', GetParam(me,'Sounds'));
        rpbox('send_matrix', GetParam(me, 'StateMatrix'));
        
    otherwise
        out = 0;
end;





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         set_future_sides(starting_at_trial_number)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = set_future_sides(starting_at);
    maxtrials = GetParam(me, 'MaxTrials');
    side_list = GetParam(me, 'SideList');
    side_list(starting_at:maxtrials)   = rand(1,maxtrials-starting_at+1)>=GetParam(me, 'LeftProb');
    SetParam(me, 'SideList', 'value', side_list);
  return;
        



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         update_settings_histories
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = update_settings_histories();
    ntrials = GetParam(me, 'Trials');
    rewardports   = GetParam(me, 'RewardPorts');   rpmap = 'cb';
    waterdelivery = GetParam(me, 'WaterDelivery'); wdmap = 'dno';
    SetParam(me, 'RewardPortsHistory',   [GetParam(me, 'RewardPortsHistory')   ; rpmap(rewardports)]);
    SetParam(me, 'WaterDeliveryHistory', [GetParam(me, 'WaterDeliveryHistory') ; wdmap(waterdelivery)]);
    return;
        


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         initialize_plot
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = initialize_plot
    
    fig = findobj('Tag', me);
    figure(fig);
    h     = findobj(fig, 'Tag', 'plot_schedule');
    if ~isempty(h), delete(h); end
    
    h = axes('Position', [0.1 0.7 0.85 0.25]);
    side_list = GetParam(me, 'SideList');
    side_list = 2-side_list; % so 2 means left, 1 means right
    plot(side_list,'b.'); hold on
    plot(1,side_list(1),'or');
    axis([0 61 0.5 2.5]);
    xlabel('trials'); ylabel('Port');
    set(h, 'YTick', [1 2], 'YTickLabel', {'Rt' 'Lt'});
    set(h,'tag','plot_schedule');
   
    return;
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         update_plot
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function [] = update_plot

    fig   = findobj('Tag', me);
    h     = findobj(fig, 'Tag', 'plot_schedule');
    if ~isempty(h),
        fprintf(1, 'Starting update_plot\n');
        axes(h); cla;
    
        ntrials        = GetParam(me, 'Trials');  % These are # of already finished trials
        maxtrials      = GetParam(me, 'MaxTrials');
        side_list      = GetParam(me, 'SideList'); side_list = 2 - side_list; % 2==left,  1==right
        reward_history = GetParam(me, 'RewardHistory');
        wd_history     = GetParam(me, 'WaterDeliveryHistory');
        rp_history     = GetParam(me, 'RewardPortsHistory');
        wd_history = wd_history(1:ntrials); % if called in the middle of a trial, just look at past trials
        rp_history = rp_history(1:ntrials);
        
        if isempty(reward_history), reward_history = zeros(0,1); end;
        
        hold on;
        % First the future
        plot(ntrials+1:maxtrials, side_list(ntrials+1:maxtrials), 'b.');
        
        % Next the both-ports-reward trials-- no hit or miss defined here, what matters is just r and l
        u      = find(rp_history == 'b');
        lefts  = find((side_list(u)==2 & reward_history(u)'=='h')  |  (side_list(u)==1 & reward_history(u)'=='m'));
        rights = find((side_list(u)==1 & reward_history(u)'=='h')  |  (side_list(u)==2 & reward_history(u)'=='m'));
        if ~isempty(lefts),  thl    = text(u(lefts),  1.5*ones(size(u(lefts))),  'l'); else thl = []; end;
        if ~isempty(rights), thr    = text(u(rights), 1.5*ones(size(u(rights))), 'r'); else thr = []; end;
        set([thl;thr], 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'middle', ...
            'FontSize', 8, 'FontWeight', 'bold', 'Color', 'b', 'FontName', 'Helvetica', 'Clipping', 'on');
        
        % Next the guys with direct water delivery or next correct poke: rat *always* gets water in these
        u  = find(wd_history ~= 'o' & rp_history == 'c');
        if ~isempty(u), th = text(u, side_list(u), reward_history(u)); else th = []; end;
        set(th, 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'middle', ...
            'FontSize', 8, 'FontWeight', 'bold', 'Color', 'b', 'FontName', 'Helvetica', 'Clipping', 'on');
        
        % Now the ones where hit or miss makes affects whether the rat gets water; these'll be green and red dots, resp.
        u  = find(wd_history == 'o' & rp_history == 'c');
        hits = find(reward_history(u) == 'h'); misses = find(reward_history(u) == 'm');
        plot(u(hits),   side_list(u(hits)),   'g.');
        plot(u(misses), side_list(u(misses)), 'r.');

        plot(ntrials+1, side_list(ntrials+1), 'ro'); hold off;
        axmin = max(ntrials-30,0);
        axmax = axmin+61;
        axis([axmin axmax 0.5 2.5]);

        xlabel('trials'); ylabel('Port');
        set(h, 'YTick', [1 2], 'YTickLabel', {'Rt' 'Lt'});
        set(h,'tag','plot_schedule');
        fprintf(1, 'Ending update_plot\n\n');
    end;
    return
    
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         InitializeUIEditParam
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = InitializeUIEditParam(parname, parval, rownum, colnum)
    
    InitParam(me, parname, 'ui', 'edit', 'value', parval, 'pos', position(rownum, colnum), 'user', 1);
    SetParamUI(me, parname, 'label', parname);
    return;
    


    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         InitializeUIMenuParam
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = InitializeUIMenuParam(parname, parlist, parval, rownum, colnum)

InitParam(me, parname, 'ui', 'popupmenu', 'list', parlist, 'value', parval, 'pos', position(rownum, colnum), 'user', 1);
    SetParamUI(me, parname, 'label', parname);
    return;
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         InitializeUIDispParam
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = InitializeUIDispParam(parname, parval, rownum, colnum)

InitParam(me, parname, 'ui', 'disp', 'value', parval, 'pos', position(rownum, colnum));
    SetParamUI(me, parname, 'label', parname);
    return;
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         state_transition_matrix
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [stm] = state_transition_matrix

stne  = 1; % sample tone
itne  = 2; % interstim interval tone
totne = 4; % timeout tone

vpd  = GetParam(me, 'ValidPokeDur');
iti  = GetParam(me, 'ITILength'); 
tout = GetParam(me, 'TimeOutLength');
lwpt = GetParam(me, 'LeftWValveTime');
rwpt = GetParam(me, 'RightWValveTime');
drkt = GetParam(me, 'DrinkTime');

side_list = GetParam(me, 'SideList');
ntrials   = GetParam(me, 'Trials');
this_side = side_list(ntrials+1); 
if this_side==0, SetParam(me, 'CurrentSide', 'l');
else             SetParam(me, 'CurrentSide', 'r');
end;

tdur = GetParam(me, 'ToneDur');
wdel = GetParam(me, 'WaterDelivery'); % 1=direct        2=next correct poke     3=only if next poke correct
rwps = GetParam(me, 'RewardPorts');   % 1=correct port  2=both ports

pstart = 40;
b  = pstart;      % base state for main program

% First, the intertrial interval and TimeOut states
global fake_rp_box;
if ~isempty(fake_rp_box) & fake_rp_box==1,  % The fake rp_box crashes if a sound is triggered twice, so we must wait
    %        Cin    Cout    Lin    Lout     Rin     Rout    Tup    Timer    Dout   Aout
    stm = [   1      1       1      1        1       1     pstart   iti      0     itne ; ... % ITI : play sound
              1      1       1      1        1       1       0      iti      0       0  ; ... % Bad boy: wait for iti and go again 
              3      3       3      3        3       3     pstart   tout     0     totne; ... % timeout : play sound
              3      3       3      3        3       3       2      tout     0       0  ; ... % Bad boy: wait for iti and go again 
          ]; 
else
    %        Cin    Cout    Lin    Lout     Rin     Rout    Tup    Timer    Dout   Aout
    stm = [ pstart pstart  pstart pstart   pstart  pstart  pstart   0.01     0       0 ; ... % go to start of program
          ];        
end;    
stm = [stm ; zeros(pstart-size(stm,1),10)];

if tout>0.001, ToutS = 2; else ToutS = pstart; end;
   
% Now to work

WpkS = pstart+4;  % state in which we're waiting for a R or L poke
LrwS = pstart+5;  % state that gives water on left  port
RrwS = pstart+7;  % state that gives water on right port
LddS = pstart+9;  % state for left  direct water delivery
RddS = pstart+11;  % state for right direct water delivery
ItiS = pstart+13; % intertrial interval state
TouS = pstart+15; % penalty timeout state

if     wdel==3, % only water if next poke is correct
    ptnA = WpkS; % post-tone act here is to go to waiting for a R or L poke
    if     this_side==0, lpkA = LrwS; rpkA = ItiS;      % lpkA and rpkA are acts (states to go to) on L and R pokes, respectively 
    elseif this_side==1, lpkA = ItiS; rpkA = RrwS;
    else   error([me ': state_matrix: this_side has weird value!']);
    end;
    
elseif wdel==2, % water on next correct poke, diregarding intervening incorrects
    ptnA = WpkS; % post-tone act here is to go to waiting for a R or L poke
    if     this_side==0, lpkA = LrwS; rpkA = WpkS;
    elseif this_side==1, lpkA = WpkS; rpkA = RrwS;
    else   error([me ': state_matrix: this_side has weird value!']);
    end;
    
elseif wdel==1, % direct delivery
    if     this_side==0, ptnA = LddS; % post-tone act is either the Left or Right direct water delivery
    elseif this_side==1, ptnA = RddS; 
    else   error([me ': state_matrix: this_side has weird value!']);
    end;
    lpkA = LrwS; rpkA = RrwS; % doesn't really matter, we won't reach them
end;

if rwps==2, % Both ports are reward ports! Override wdel stuff above. In particular, no direct delivery
    ptnA = WpkS;
    lpkA = LrwS;
    rpkA = RrwS;
end;

%      Cin    Cout    Lin    Lout    Rin    Rout   Tup    Timer   Dout    Aout
stm = [stm ; ...
       1+b     b      b      b       b      b       b      100      0       0 ; ... %0 : Pre-state: wait for C poke
       1+b     b      b      b       b      b      2+b     0.01     0       0 ; ... %1 : if pk<10 ms, doesn't count
      ToutS  ToutS  ToutS  ToutS   ToutS  ToutS    3+b     vpd      0       0 ; ... %2 : vpd   elapsed ==> valid poke
       3+b    3+b    3+b    3+b     3+b    3+b     ptnA    0.01     0    stne ; ... %3 : Vld poke: Play sample tone
       4+b    4+b    lpkA   4+b     rpkA   4+b     4+b     100      0       0 ; ... %4 : wait for r/l poke act
       LrwS   LrwS   LrwS   LrwS    LrwS   LrwS   1+LrwS   lwpt     1       0 ; ... %5 : Left reward: give water
      1+LrwS 1+LrwS 1+LrwS 1+LrwS  1+LrwS 1+LrwS   ItiS    drkt     0       0 ; ... %6 : free time to enjoy water
       RrwS   RrwS   RrwS   RrwS    RrwS   RrwS   1+RrwS   rwpt     2       0 ; ... %7 : Right reward: give water
      1+RrwS 1+RrwS 1+RrwS 1+RrwS  1+RrwS 1+RrwS   ItiS    drkt     0       0 ; ... %8 : free time to enjoy water
       LddS   LddS   LddS   LddS    LddS   LddS   1+LddS   lwpt     1       0 ; ... %9 : Left direct w delivery
      1+LddS 1+LddS  ItiS  1+LddS  1+LddS 1+LddS  1+LddS   100      0       0 ; ... %10: Wait for L water collection 
       RddS   RddS   RddS   RddS    RddS   RddS   1+RddS   rwpt     2       0 ; ... %11: Left direct w delivery
      1+RddS 1+RddS 1+RddS 1+RddS    35   1+RddS  1+RddS   100      0       0 ; ... %12: Wait for R water collection 
      1+ItiS 1+ItiS 1+ItiS 1+ItiS  1+ItiS 1+ItiS    35     iti      0     itne; ... %13: ITI, trigger and play sound
       ItiS   ItiS   ItiS   ItiS    ItiS   ItiS    ItiS    0.02     0       0 ; ... %14: happening: lower trigger and go back to set it off anew     
      1+TouS 1+TouS 1+TouS 1+TouS  1+TouS 1+TouS  pstart   tout     0     totne; ...%15: timeout, trig and play sound
       TouS   TouS   TouS   TouS    TouS   TouS    TouS    0.02     0       0 ; ... %16: Bad boy: go again 
   ];

    

SetParam(me, 'LrwS', LrwS); SetParam(me, 'RrwS', RrwS); SetParam(me, 'pstart', pstart);
SetParam(me, 'LddS', LddS); SetParam(me, 'RddS', RddS); SetParam(me, 'WpkS',   WpkS);
SetParam(me, 'rpkA', rpkA); SetParam(me, 'lpkA', lpkA); SetParam(me, 'ptnA',   ptnA);

out = stm;

return;
        
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         MakeSounds
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sounds] = MakeSounds()

FilterPath=[GetParam('rpbox','protocol_path') '\PPfilter.mat'];
if ( size(dir(FilterPath),1) == 1 )
    PP=load(FilterPath);
    PP=PP.PP;
    % message(me,'Generating Calibrated Tones');
else
    PP=[];
    % message(me,'Generating Non-calibrated Tones');
end

FreqStart=GetParam(me,'ToneFreqStart');
FreqEnd  =GetParam(me,'ToneFreqEnd');
FreqMean = exp((log(FreqStart) + log(FreqEnd))/2);
ToneDur=GetParam(me,'ToneDur');
SPL=GetParam(me,'ToneSPL');
RampDur=GetParam(me,'RampDur');
n_tones=length(FreqStart);
ToneAttenuation = ones(1,n_tones)*70 -SPL;

swoops = cell(n_tones,1);

for tn=1:n_tones
    if isempty(PP) | FreqStart(tn)== -1
        ToneAttenuation_adj = ToneAttenuation(tn);
    else
        ToneAttenuation_adj = ToneAttenuation(tn) - ppval(PP, log10(FreqMean(tn)));
        % Remove any negative attenuations and replace with zero attenuation.
        ToneAttenuation_adj = ToneAttenuation_adj .* (ToneAttenuation_adj > 0);
    end
    % FreqStart, FreqEnd,
    swoops{tn}  = 1 * MakeSwoop(50e6/1024, ToneAttenuation_adj ,FreqStart(tn), FreqEnd(tn), ToneDur*1000, RampDur*1000);
end

side_list  = GetParam(me, 'SideList');
ntrials    = GetParam(me, 'Trials');
leftsound  = GetParam(me, 'LeftSound');
rightsound = GetParam(me, 'RightSound');

sounds = cell(3,1);
% gu = side_list(ntrials+1),
if side_list(ntrials+1) == 0, 
    if     leftsound==1,  sounds{1} = zeros(size(swoops{1}));
    elseif leftsound==2,  sounds{1} = swoops{2};
    elseif leftsound==3,  sounds{1} = swoops{3};
    end;
else
    if     rightsound==1, sounds{1} = zeros(size(swoops{1}));
    elseif rightsound==2, sounds{1} = swoops{1};
    elseif rightsound==3, sounds{1} = swoops{3};
    end;
end;
    
itisound  = 0.145*rand(1,floor(GetParam(me, 'ITILength')*50e6/1024));
if GetParam(me, 'ITISound')==1,     sounds{2} = zeros(size(itisound)); 
else                                sounds{2} = itisound;
end;

toutsound = 0.145*rand(1,floor(GetParam(me, 'TimeOutLength')*50e6/1024));
if GetParam(me, 'TimeOutSound')==1, sounds{3} = zeros(size(toutsound));
else                                sounds{3} = toutsound;
end;

return;





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         position -- for putting items in a figure
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [pos] = position(rownum, colnum, mywidth)

if nargin<3, mywidth = 1; end;

itemwidth = 100; itemheight = 20;
pos = [(colnum-1)*itemwidth+1 (rownum-1)*itemheight mywidth*itemwidth itemheight];
return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                me  : returns name of current mfile
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [myname] = me
    myname = lower(mfilename);
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       callback  : returns name of current mfile followed by
%                semicolon
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [myname] = callback
    myname = [me ';'];
    
   
    