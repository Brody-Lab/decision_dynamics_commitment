function [out] = Probsamp9(varargin)

% - implement changing dot color as soon as we have an answer, not only at
% - the end of the trial...

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
        InitializeUIEditParam('TimeOutLength',                           0, rownum, colnum);   rownum = rownum+1;
        InitializeUIMenuParam('TimeOutSound',{'silence', 'white noise'}, 2, rownum, colnum);   rownum = rownum+1;
        rownum = rownum+0.5; % Blank row
        InitializeUIEditParam('MaxValidPokeDur',                       0.32, rownum, colnum);   rownum = rownum+1;
        InitializeUIEditParam('MinValidPokeDur',                       0.22, rownum, colnum);   rownum = rownum+1;
        InitializeUIEditParam('VpdsHazardRate',                        0.01, rownum, colnum);   rownum = rownum+1;
        InitializeUIEditParam('DrinkTime',                              1.5, rownum, colnum);   rownum = rownum+1;
        rownum = rownum+0.5; % Blank row
        InitializeUIMenuParam('LeftSound',  {'silence', '5k->10k', '2.5k->10k', '2.5k'},3, rownum, colnum);  rownum = rownum+1;
        InitializeUIMenuParam('RightSound', {'silence', '10k->5k', '10k->2.5k', '10k'}, 3, rownum, colnum);  rownum = rownum+1;
        InitializeUIEditParam('ValidSoundTime',                       0.11, rownum, colnum);   rownum = rownum+1;
        InitializeUIEditParam('ToneDur',                              0.22, rownum, colnum);   rownum = rownum+1; 
        InitializeUIEditParam('RampDur',                             0.005, rownum, colnum);   rownum = rownum+1; 
        rownum = rownum+0.5; % Blank row
        InitializeUIEditParam('LastCpokeMins',                           5, rownum, colnum);   rownum = rownum+1;
        
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
       
        InitParam(me, 'LrwS',   'value', 0); InitParam(me, 'RrwS', 'value', 0); % state #'s for Left  and Right  reward
        InitParam(me, 'LddS',   'value', 0); InitParam(me, 'RddS', 'value', 0); % state #'s for Left  and Right  direct del
        InitParam(me, 'pstart', 'value', 2); InitParam(me, 'WpkS', 'value', 0);
        
        % ------ Schedule ---------
        maxtrials = 1000; InitParam(me, 'MaxTrials',     'value', maxtrials);
        InitParam(me, 'SideList', 'value', zeros(1, maxtrials));
        set_future_sides(1);
        InitParam(me, 'VpdsList', 'value', zeros(1, maxtrials));
        set_future_vpds(1);
        InitParam(me, 'RewardHistory',       'value', []);  % defined in terms of first sideport response 'hm'
        InitParam(me, 'RewardPortsHistory',  'value', []);  % trial-by-trial history of the value of RewardPort 'cb'
        InitParam(me, 'WaterDeliveryHistory','value', []);  % trial-by-trial history of water deliver method 'dno'
        initialize_plot;

        InitParam(me, 'CenterPokeTimes',     'value', zeros(1,20000)); % start times of center pokes
        InitParam(me, 'CenterPokeDurations', 'value', zeros(1,20000)); % How long each of the above was
        InitParam(me, 'CenterPokeStateHist', 'value', zeros(1,20000)); % State number in which each center poke was initiated
        InitParam(me, 'nCenterPokes',   'value', 0); InitParam(me, 'CPokeState', 'value', 0);
        InitParam(me, 'LastPokeInTime', 'value', 0); InitParam(me, 'LastPokeOutTime');
        initialize_centerpokes_plot;
        
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
                SetParam(me, 'CPokeState', Event(i,1));
                
            elseif Event(i,2)==2
                SetParamUI(me,'CenterPort','BackgroundColor',[0.8 0.8 0.8]);
                SetParam(me, 'LastPokeOutTime', Event(i,3));
                lastpokeouttime = Event(i,3);
            elseif Event(i,2)==3
                SetParamUI(me,'LeftPort','BackgroundColor',[0 1 0]);
                SetParam(me, 'LeftPokes', GetParam(me, 'LeftPokes')+1);
            elseif Event(i,2)==4
                SetParamUI(me,'LeftPort','BackgroundColor',[0.8 0.8 0.8]);
            elseif Event(i,2)==5
                SetParamUI(me,'RightPort','BackgroundColor',[0 1 0]);
                SetParam(me, 'RightPokes', GetParam(me, 'RightPokes')+1);
            elseif Event(i,2)==6
                SetParamUI(me,'RightPort','BackgroundColor',[0.8 0.8 0.8]);
            else
            end
            
            current_side = GetParam(me, 'CurrentSide'); current_hit = GetParam(me, 'CurrentHit');
            if isempty(current_hit),  % haven't figured out yet if this trial was a hit
                if Event(i,1)==WpkS,  % we're in the post-sample tone, wait for poke act state
                    if     ( (Event(i,2)==3 & current_side=='l') | (Event(i,2)==5 & current_side=='r') ),
                        SetParam(me, 'CurrentHit', 'h');
                        SetParam(me, 'RewardHistory', [GetParam(me, 'RewardHistory') ; 'h']);
                        SetParam(me, 'Rewards',        GetParam(me, 'Rewards') +1);
                        if Event(i,2)==3,    SetParam(me, 'LeftRewards',  GetParam(me, 'LeftRewards') +1);
                        else                 SetParam(me, 'RightRewards', GetParam(me, 'RightRewards')+1);
                        end;
                    elseif ( (Event(i,2)==3 & current_side=='r') | (Event(i,2)==5 & current_side=='l') ),
                        SetParam(me, 'CurrentHit', 'm');
                        SetParam(me, 'RewardHistory', [GetParam(me, 'RewardHistory') ; 'm']);
                    end;
                end;
            end;
                        
            if ismember(Event(i,2), [2]), % it was a center poke out
                nCenterPokes        = GetParam(me, 'nCenterPokes')+1;
                CenterPokeTimes     = GetParam(me, 'CenterPokeTimes');
                CenterPokeDurations = GetParam(me, 'CenterPokeDurations');
                CenterPokeStateHist = GetParam(me, 'CenterPokeStateHist');
                LastPokeInTime      = GetParam(me, 'LastPokeInTime');
                state               = GetParam(me, 'CPokeState');
                
                CenterPokeTimes(nCenterPokes) = LastPokeInTime;
                CenterPokeDurations(nCenterPokes) = lastpokeouttime - LastPokeInTime;
                CenterPokeStateHist(nCenterPokes) = state;
                SetParam(me, 'nCenterPokes', nCenterPokes);       SetParam(me, 'CenterPokeStateHist', CenterPokeStateHist);
                SetParam(me, 'CenterPokeTimes', CenterPokeTimes); SetParam(me, 'CenterPokeDurations', CenterPokeDurations);
                update_centerpokes_plot;    
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
        
        
    case 'reset'
        
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
        
    case {'vpdshazardrate', 'minvalidpokedur', 'maxvalidpokedur', 'ValidSoundTime'}
        check_legal_valid_poke_durs;
        set_future_vpds(GetParam(me, 'Trials')+2);
        update_plot;
   
    case 'tonedur'
        tdur = GetParam(me, 'ToneDur');
        if tdur < 0.04, tdur = 0.04; end;
        SetParam(me, 'ToneDur', tdur);
        if check_legal_valid_poke_durs,
            set_future_vpds(GetParam(me, 'Trials')+2);
            update_plot;
        end;
        
    case 'lastcpokemins'
        update_centerpokes_plot;
        
    otherwise
        out = 0;
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         check_legal_valid_pokes()
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [change_flag] = check_legal_valid_poke_durs()
    mn   = GetParam(me, 'MinValidPokeDur');
    mx   = GetParam(me, 'MaxValidPokeDur');
    tdur = GetParam(me, 'ToneDur');
    vlst = GetParam(me, 'ValidSoundTime');
    
    change_flag = 0;
    if mn   <  0,        mn = 0.01;      change_flag = 1; end;
    if mn   < vlst+0.02, mn = vlst+0.02; change_flag = 1; end;

    if mx   < mn,        mx = mn;        change_flag = 1; end;
    
    if tdur < vlst,      tdur = vlst;    change_flag = 0; end;      
    SetParam(me, 'MinValidPokeDur', mn);
    SetParam(me, 'MaxValidPokeDur', mx);
    SetParam(me, 'ToneDur', tdur);

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
%         set_future_vpds(starting_at_trial_number)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = set_future_vpds(starting_at);
    maxtrials  = GetParam(me, 'MaxTrials');
    vpds_list  = GetParam(me, 'VpdsList');
    hazardrate = GetParam(me, 'VpdsHazardRate');
    min_vpd    = GetParam(me, 'MinValidPokeDur');
    max_vpd    = GetParam(me, 'MaxValidPokeDur');
    
    vpds = min_vpd:0.010:max_vpd;
    
    prob       = hazardrate*((1-hazardrate).^(0:length(vpds)-1));
    cumprob    = cumsum(prob/sum(prob));
    for i=starting_at:length(vpds_list), vpds_list(i) = vpds(min(find(rand(1)<=cumprob))); end;
    SetParam(me, 'VpdsList', 'value', vpds_list);
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
   
    % First plot rewards
    h     = findobj(fig, 'Tag', 'plot_sides');
    if ~isempty(h), delete(h); end
    
    h = axes('Position', [0.15 0.9 0.8 0.09]);
    side_list = GetParam(me, 'SideList');
    side_list = 2-side_list; % so 2 means left, 1 means right
    plot(side_list,'b.'); hold on
    plot(1,side_list(1),'or');
    axis([0 61 0.5 2.5]);
    ylabel('Port'); xlabel('');
    set(h, 'YTick', [1 2], 'YTickLabel', {'Rt' 'Lt'}, 'XTickLabel', '');
    set(h,'tag','plot_sides');
   
    
    % Now central valid poke durations
    h     = findobj(fig, 'Tag', 'plot_vpds');
    if ~isempty(h), delete(h); end;

    h = axes('Position', [0.15 0.75 0.8 0.14]);
    vpds_list = GetParam(me, 'VpdsList');
    plot(vpds_list,'k.'); hold on
    plot(1,vpds_list(1),'or');
    axis([0 61 min(vpds_list-0.01) max(vpds_list)+0.01]);
    xlabel('trials'); ylabel('VPD (secs)');
    set(h,'tag','plot_vpds');
    
    
    
    return;
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         update_plot
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function [] = update_plot

    fig   = findobj('Tag', me);
    h     = findobj(fig, 'Tag', 'plot_sides');
    if ~isempty(h),
        axes(h); cla;
    
        ntrials        = GetParam(me, 'Trials');  % These are # of already finished trials
        maxtrials      = GetParam(me, 'MaxTrials');
        side_list      = GetParam(me, 'SideList'); side_list = 2 - side_list; % 2==left,  1==right
        reward_history = GetParam(me, 'RewardHistory');
        wd_history     = GetParam(me, 'WaterDeliveryHistory');
        rp_history     = GetParam(me, 'RewardPortsHistory');
        % fprintf(1, 'Here 1 update_plot_sides\n');
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
        % fprintf(1, 'Here 2 update_plot_sides\n');
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
        % fprintf(1, 'Here 3 update_plot_sides\n');
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
        set(h,'tag','plot_sides');
        % fprintf(1, 'Ending update_plot_sides\n\n');
    end;
    
    h     = findobj(fig, 'Tag', 'plot_vpds');
    if ~isempty(h),
        axes(h); cla;
    
        ntrials        = GetParam(me, 'Trials');  % These are # of already finished trials
        vpds_list      = GetParam(me, 'VpdsList'); 
        plot(vpds_list,'k.'); hold on
        plot(ntrials+1,vpds_list(ntrials+1),'or');
        axmin = max(ntrials-30, 0);
        axmax = axmin+61;
        axis([axmin axmax min(vpds_list(max(1,axmin):axmax))-0.01 max(vpds_list(max(1,axmin):axmax))+0.01]);
        xlabel('trials'); ylabel('VPD (secs)');
        set(h,'tag','plot_vpds');
    end;
    
    return
    
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         initialize_centerpokes_plot
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = initialize_centerpokes_plot
    h = axes('Position', [0.15 0.6 0.8 0.12]);
    set(h, 'Tag', 'CenterPokesPlot');
    xlabel('secs');
    ylabel('CPokeDur');
    vpds_list = GetParam(me, 'VpdsList'); 
    ntrials   = GetParam(me, 'Trials');
    vpd = vpds_list(ntrials+1);
    l = line([0 100], [vpd vpd]);
    set(l, 'Color', 0.8*[1 1 1], 'Tag', 'vpdline');
    pd = line([0], [0]);
    set(pd, 'Color', 'k', 'Marker', '.', 'LineStyle', '-', 'Tag', 'pdline');

    r = line([0], [0]);
    set(r, 'Color', 'r', 'Marker', '.', 'LineStyle', 'none', 'Tag', 'rline');
    axis([0 100 0 1.5*vpd]);
    return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         update_centerpokes_plot
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = update_centerpokes_plot

    fig   = findobj('Tag', me);
    h     = findobj(fig, 'Tag', 'CenterPokesPlot');
    if ~isempty(h),
        vline = findobj(h, 'Tag', 'vpdline');
        pline = findobj(h, 'Tag', 'pdline');
        rline = findobj(h, 'Tag', 'rline');
        
        nCenterPokes        = GetParam(me, 'nCenterPokes');
        CenterPokeTimes     = GetParam(me, 'CenterPokeTimes');
        CenterPokeDurations = GetParam(me, 'CenterPokeDurations');
        CenterPokeStateHist = GetParam(me, 'CenterPokeStateHist');
        
        if nCenterPokes > 0,
            u = find(CenterPokeTimes(nCenterPokes) - CenterPokeTimes < GetParam(me, 'LastCpokeMins')*60); 
            set(pline, 'XData', CenterPokeTimes(u), 'YData', CenterPokeDurations(u));
            from = min(CenterPokeTimes(u))-1;       to  = max(CenterPokeTimes(u))+1;
            bot  = min(CenterPokeDurations(u))*0.9; top = max(CenterPokeDurations(u))*1.1;
            set(h, 'XLim', [from to], 'YLim', [bot top]);
        
            red_u = find(CenterPokeStateHist(u) == GetParam(me, 'pstart'));
            set(rline, 'XData', CenterPokeTimes(u(red_u)), 'YData', CenterPokeDurations(u(red_u)));
            
            vpds_list = GetParam(me, 'VpdsList'); 
            ntrials   = GetParam(me, 'Trials');
            vpd = vpds_list(ntrials+1);
            set(vline, 'XData', [from to], 'YData', [vpd vpd]);
        end;
    end;    
    return;
    

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

iti      = GetParam(me, 'ITILength'); 
tout     = GetParam(me, 'TimeOutLength');
lwpt     = GetParam(me, 'LeftWValveTime');
rwpt     = GetParam(me, 'RightWValveTime');
drkt     = GetParam(me, 'DrinkTime');
ntrials   = GetParam(me, 'Trials');

side_list = GetParam(me, 'SideList');
this_side = side_list(ntrials+1); 
if this_side==0, SetParam(me, 'CurrentSide', 'l');
else             SetParam(me, 'CurrentSide', 'r');
end;

vpds_list = GetParam(me, 'VpdsList'); 
vpd = vpds_list(ntrials+1);

tdur = GetParam(me, 'ToneDur');
wdel = GetParam(me, 'WaterDelivery'); % 1=direct        2=next correct poke     3=only if next poke correct
rwps = GetParam(me, 'RewardPorts');   % 1=correct port  2=both ports

pstart      = 40;   % start of main program
rewardstart = 120;  % start of reward states program
itistart    = 240;  % start if ITI and TimeOut states program

b  = pstart;      % base state for main program

%        Cin    Cout    Lin    Lout     Rin     Rout    Tup    Timer    Dout   Aout
stm = [ pstart pstart  pstart pstart   pstart  pstart  pstart   0.01     0       0 ; ... % go to start of program
    ];

stm = [stm ; zeros(pstart-size(stm,1),10)];

vlst = GetParam(me, 'ValidSoundTime');

prst = vpd - vlst; % presound time
if prst < 0.02, prst = 0.02; end; % Hack for when tdur changes in the middle of a trial
if vlst < 0.02, vlst = 0.02; end; % Equal hack

deltat = 0.02;
nvunits = 50; % measure pokes with 20 ms accuracy up to 1-sec long pokes

% Now to work
WpkS = pstart+5+nvunits;  % state in which we're waiting for a R or L poke

LrwS = rewardstart+3;            % state that gives water on left  port
RrwS = rewardstart+3+   nvunits;  % state that gives water on right port
LddS = rewardstart+3+ 2*nvunits;  % state for left  direct water delivery
RddS = rewardstart+3+ 3*nvunits;  % state for right direct water delivery
ItiS = itistart  ;  % intertrial interval state
TouS = itistart+2; % penalty timeout state
if tout < 0.001, TouS = pstart; end;  % timeouts of zero mean just skip that state

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

fprintf(1, 'prst=%g  vlst=%g\n', prst, vlst);
global fake_rp_box;

if isempty(fake_rp_box) | fake_rp_box ~= 1,
    %      Cin    Cout    Lin    Lout    Rin    Rout   Tup    Timer   Dout    Aout
    stm = [stm ; ...
           1+b     b      b      b       b      b       b      100      0       0 ; ... %0 : Pre-state: wait for C poke
           1+b     b      b      b       b      b      2+b     0.01     0       0 ; ... %1 : if pk<10 ms, doesn't count
           TouS   TouS   TouS   TouS    TouS   TouS    3+b     prst     0       0 ; ... %2 : pre sound time
           TouS   TouS   TouS   TouS    TouS   TouS    ptnA    vlst     0    stne ; ... %3 : trigger sample sound
           WpkS   WpkS   lpkA   WpkS    rpkA   WpkS    WpkS    100      0       0 ; ... %4 : wait for r/l poke act
       ];
else 
    WtoS = pstart+1; % wait for sound over before going to the timeout state
    WcoS = pstart+5; % wait for center-out after the valid sound time
    %      Cin    Cout    Lin    Lout    Rin    Rout   Tup    Timer   Dout    Aout
    stm = [stm ; ...
           2+b     b      b      b       b      b       b      100      0       0 ; ... %0 : Pre-state: wait for C poke
           WtoS   WtoS   WtoS   WtoS    WtoS   WtoS    TouS    tdur     0       0 ; ... %1 : wait for sound over bf timeout      
           2+b     b      b      b       b      b      3+b     0.01     0       0 ; ... %2 : if pk<10 ms, doesn't count
           TouS   TouS   TouS   TouS    TouS   TouS    4+b     prst     0       0 ; ... %3 : pre sound time
           WtoS   WtoS   WtoS   WtoS    WtoS   WtoS    WcoS    vlst     0     stne; ... %4 : trigger sound, wait vlst
        ];
    for i=0:nvunits-1,  stm = [stm ; ... 
          i+WcoS  i+ptnA i+WcoS i+WcoS  i+WcoS i+WcoS 1+i+WcoS deltat   0       0]; %5:  measure time to center out 
    end; stm(end,7) = size(stm,1); % in the last one, just wait for the center out indefinitely
    for i=0:nvunits-1,    stm = [stm ; ...
          i+WpkS i+WpkS i+lpkA  i+WpkS i+rpkA i+WpkS  i+WpkS   100      0       0];     % wait for poke
    end; 
    
end;



stm = [stm ; zeros(rewardstart-size(stm,1),10)];
WtlS = rewardstart; WtrS = rewardstart+1; DrkS = rewardstart+2;

%      Cin    Cout    Lin    Lout    Rin    Rout   Tup    Timer   Dout    Aout
stm = [stm ; ...
       WtlS   WtlS   DrkS   WtlS    WtlS   WtlS    WtlS    100      0       0 ; ... %0 : Wait for L water collection (DD) 
       WtrS   WtrS   WtrS   WtrS    DrkS   WtrS    WtrS    100      0       0 ; ... %1 : Wait for R water collection (DD)
       DrkS   DrkS   DrkS   DrkS    DrkS   DrkS    ItiS    drkt     0       0 ; ... %2 : free time to enjoy water 
   ];
for i=1:nvunits, stm = [stm ; ...
       LrwS   LrwS   LrwS   LrwS    LrwS   LrwS    DrkS    lwpt     1       0] ;    %3 : Left reward: give water
end;
for i=1:nvunits, stm = [stm ; ...
       RrwS   RrwS   RrwS   RrwS    RrwS   RrwS    DrkS    rwpt     2       0] ;    %4 : Right reward: give water
end;
for i=1:nvunits, stm = [stm ; ...
       LddS   LddS   LddS   LddS    LddS   LddS    WtlS    lwpt     1       0] ;    %5 : Left direct w delivery
end;
for i=1:nvunits, stm = [stm ; ...
       RddS   RddS   RddS   RddS    RddS   RddS    WtrS    rwpt     2       0] ;    %6 : Right direct w delivery
end;


stm = [stm ; zeros(itistart-size(stm,1),10)];

% setup independent Itistart number
if ~isempty(fake_rp_box) & fake_rp_box==1,  % The fake rp_box crashes if a sound is triggered twice, so we must wait
    itwt = iti;  towt = tout;                % Time to wait for unriggering of the sounds
else
    itwt = 0.02; towt = 0.02;       
end;

stm = [stm ; ...
      1+ItiS 1+ItiS 1+ItiS 1+ItiS  1+ItiS 1+ItiS    35     iti      0     itne; ... %8 : ITI, trigger and play sound
       ItiS   ItiS   ItiS   ItiS    ItiS   ItiS    ItiS    itwt     0       0 ; ... %9 : happening: lower trigger and go back to set it off anew     
       TouS   TouS   TouS   TouS    TouS   TouS   1+TouS   0.02     0       0 ; ... %10: lower all sound trigs first
      2+TouS 2+TouS 2+TouS 2+TouS  2+TouS 2+TouS  pstart   tout     0     totne; ...%11: timeout, trig and play sound
       TouS   TouS   TouS   TouS    TouS   TouS    TouS    towt     0       0 ; ... %12: Bad boy: go again 
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

SPL       = 70;               % Max=PPdB SPL
ToneDur=GetParam(me,'ToneDur');
RampDur=GetParam(me,'RampDur');
ToneAttenuation = 70 -SPL;
        
sounds = cell(3,1);

% ---- Sample Sound ------

side_list  = GetParam(me, 'SideList');
ntrials    = GetParam(me, 'Trials');

if side_list(ntrials+1)==1,
    switch GetParam(me, 'RightSound'),
        case 1, Sweepdir = 'down'; HiFreq = 1000;  LoFreq = 1000;  amp = 0; % dummies, this'll be silence
        case 2, Sweepdir = 'down'; HiFreq = 10000; LoFreq = 5000;  amp = 1;
        case 3, Sweepdir = 'down'; HiFreq = 10000; LoFreq = 2500;  amp = 1;
        case 4, Sweepdir = 'down'; HiFreq = 10000; LoFreq = 10000; amp = 1;
    end;
else
    switch GetParam(me, 'LeftSound'),
        case 1, Sweepdir = 'up'; HiFreq = 1000;  LoFreq = 1000; amp = 0;% dummies, this'll be silence
        case 2, Sweepdir = 'up'; HiFreq = 10000; LoFreq = 5000; amp = 1;
        case 3, Sweepdir = 'up'; HiFreq = 10000; LoFreq = 2500; amp = 1;
        case 4, Sweepdir = 'up'; HiFreq = 2500;  LoFreq = 2500; amp = 1;
    end;
end;

FreqMean = exp((log(LoFreq) + log(HiFreq))/2);
if isempty(PP), 
    ToneAttenuation_adj = ToneAttenuation;
else 
    ToneAttenuation_adj = ToneAttenuation - ppval(PP, log10(FreqMean));
    ToneAttenuation_adj = ToneAttenuation_adj .* (ToneAttenuation_adj > 0);
end;

sounds{1}  = amp*MakeSwoop2(50e6/1024, ToneAttenuation_adj, LoFreq, HiFreq, Sweepdir, ToneDur*1000, RampDur*1000);


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
    
   
    