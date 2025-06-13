function [out] = LocSamp3(varargin)

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
    case 'init',
        ModuleNeeds(me, {'rpbox'});
        SetParam(me,'priority','value',GetParam('rpbox','priority')+1);       
        InitParam(me, 'object', 'value', locsamp3obj(mfilename));
        
    case 'update',
        my_obj = GetParam(me, 'object');
        update(my_obj);

    case 'close',
        if ExistParam(me, 'object'),
            my_obj = GetParam(me, 'object');
            close(my_obj);
        end;    
        SetParam('rpbox','protocols',1);
        return;
        
    case 'state35',
        my_obj = GetParam(me, 'object');
        state35(my_obj);
        
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
    tdur = GetParam(me, 'SoundDur');
    vlst = GetParam(me, 'ValidSoundTime');
    
    change_flag = 0;
    if mn   <  0,        mn = 0.01;      change_flag = 1; end;
    if mn   < vlst+0.02, mn = vlst+0.02; change_flag = 1; end;

    if mx   < mn,        mx = mn;        change_flag = 1; end;
    
    if tdur < vlst,      tdur = vlst;    change_flag = 0; end;      
    SetParam(me, 'MinValidPokeDur', mn);
    SetParam(me, 'MaxValidPokeDur', mx);
    SetParam(me, 'SoundDur', tdur);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         set_future_sides(starting_at_trial_number)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = set_future_sides(starting_at);
    maxtrials = GetParam(me, 'MaxTrials');
    side_list = GetParam(me, 'SideList');
    maxsame   = GetParam(me, 'MaxSame');
    side_list(starting_at:maxtrials)   = rand(1,maxtrials-starting_at+1)>=GetParam(me, 'LeftProb');
    if maxsame < 10,
        seg_starts  = find(diff([-Inf side_list -1]));
        seg_lengths = diff(seg_starts);
        long_segs   = find(seg_lengths > maxsame);
        while ~isempty(long_segs),
            switch_point = seg_starts(long_segs(1)) + ceil(seg_lengths(long_segs(1))/2);
            side_list(switch_point) = 1 - side_list(switch_point);
            seg_starts  = find(diff([-Inf side_list]));
            seg_lengths = diff(seg_starts);
            long_segs   = find(seg_lengths > maxsame);
        end;
    end;
    
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
%         update_meanhits
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = update_meanhits();

guys = [10 20 40 80];
Trials = GetParam(me, 'Trials');
Hits   = GetParam(me, 'RewardHistory') == 'h';
for i=1:length(guys),
    trials = max(Trials-guys(i)+1, 1):Trials;
    SetParam(me, ['Last' num2str(guys(i))], mean(Hits(trials)));
end;    




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
    axis([0 91 0.5 2.5]);
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
    axis([0 91 min(vpds_list-0.01) max(vpds_list)+0.01]);
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
        axmin = max(ntrials-60,0);
        axmax = axmin+91;
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
        axmin = max(ntrials-60, 0);
        axmax = axmin+91;
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
    h = axes('Position', [0.25 0.6 0.67 0.12]);
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
    set(h, 'YAxisLocation', 'right');
    
    h2 = axes('Position', [0.05 0.6 0.175 0.12]);
    set(h2, 'Tag', 'CenterPokesHist', 'XLim', [0 0.95], 'YLim', [0 1]);
    return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         update_centerpokes_plot
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = update_centerpokes_plot

    fig   = findobj('Tag', me);
    h     = findobj(fig, 'Tag', 'CenterPokesPlot');
    h2    = findobj(fig, 'Tag', 'CenterPokesHist');
 
    if ~isempty(h) | ~isempty(h2),
        nCenterPokes        = GetParam(me, 'nCenterPokes');
        CenterPokeTimes     = GetParam(me, 'CenterPokeTimes');
        CenterPokeDurations = GetParam(me, 'CenterPokeDurations');
        CenterPokeStateHist = GetParam(me, 'CenterPokeStateHist');
        
        u = find(CenterPokeTimes(nCenterPokes) - CenterPokeTimes < GetParam(me, 'LastCpokeMins')*60  &  ...
            CenterPokeDurations>0); 
    end;
    
    if ~isempty(h),
        vline = findobj(h, 'Tag', 'vpdline');
        pline = findobj(h, 'Tag', 'pdline');
        rline = findobj(h, 'Tag', 'rline');
        
        if length(u)>0,
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
        set(h, 'YAxisLocation', 'right');    
    end;    
    
    if ~isempty(h2) & length(u) > 1,
        axes(h2);
        n = CenterPokeDurations(u);  [n, x] = hist(n, 0:0.001:max(n)); n = 100*cumsum(n)/length(u);
        plot(n, x); set(h2, 'Tag', 'CenterPokesHist');
        gridpts = [0 25 50 75 95]; % must always contain 0
        set(gca, 'XTick', gridpts, 'XGrid', 'on', 'Xlim', gridpts([1 end])); 
        
        p = zeros(size(gridpts)); p(1) = 1; empty_flag = 0;
        for i=2:length(gridpts),
            z = max(find(n <= gridpts(i)));
            if isempty(z), empty_flag = 1;
            else p(i) = z; 
            end;
        end;
        if ~empty_flag,
            if min(diff(x(p)))>0, set(gca, 'YTick', x(p), 'Ygrid', 'on', 'YLim', x(p([1 end]))); end;
        end;
    end;
    return;
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         InitializeUIPushParam
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = InitializeUIPushParam(parname, rownum, colnum)

    InitParam(me, parname, 'ui', 'pushbutton', 'pos', position(rownum, colnum));
    SetParamUI(me, parname, 'label', parname);
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
%         InitializeUIEditHalfLeftParam
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = InitializeUIEditHalfLeftParam(parname, parval, rownum, colnum)
    
    pos = position(rownum, colnum); pos(3) = pos(3)/2;
    InitParam(me, parname, 'ui', 'edit', 'value', parval, 'pos', pos, 'user', 1);
    SetParamUI(me, parname, 'label', '');
    return;
    


    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         InitializeUIEditHalfRightParam
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = InitializeUIEditHalfRightParam(parname, parval, rownum, colnum)
    
    pos = position(rownum, colnum); pos(1) = pos(1) + pos(3)/2; pos(3) = pos(3)/2;
    InitParam(me, parname, 'ui', 'edit', 'value', parval, 'pos', pos, 'user', 1);
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

tdur = GetParam(me, 'SoundDur');
wdel = GetParam(me, 'WaterDelivery'); % 1=direct        2=next correct poke     3=only if next poke correct
rwps = GetParam(me, 'RewardPorts');   % 1=correct port  2=both ports

pstart      = 40;   % start of main program
rewardstart = 60;  % start of reward states program
itistart    = 100;  % start of iti and timeout parts of program

b  = pstart;      % base state for main program

%        Cin    Cout    Lin    Lout     Rin     Rout    Tup    Timer    Dout   Aout
stm = [ pstart pstart  pstart pstart   pstart  pstart  pstart   0.01     0       0 ; ... % go to start of program
    ];

stm = [stm ; zeros(pstart-size(stm,1),10)];
   
% Now to work
WpkS = pstart+5;  % state in which we're waiting for a R or L poke

LrwS = rewardstart+0;  % state that gives water on left  port
RrwS = rewardstart+2;  % state that gives water on right port
LddS = rewardstart+4;  % state for left  direct water delivery
RddS = rewardstart+6;  % state for right direct water delivery

ItiS = itistart+16;  % intertrial interval state
TouS = itistart+19;  % penalty timeout state
if tout < 0.001, TouS = pstart; end;  % timeouts of zero mean just skip that state

if     wdel==3, % only water if next poke is correct
    punish = ItiS - 2*(GetParam(me, 'ExtraITIonError')-1);
    ptnA = WpkS; % post-tone act here is to go to waiting for a R or L poke
    if     this_side==0, lpkA = LrwS;   rpkA = punish;  % lpkA and rpkA are acts (states to go to) on L and R pokes, respectively 
    elseif this_side==1, lpkA = punish; rpkA = RrwS;
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

vlst = GetParam(me, 'ValidSoundTime');

prst = vpd - vlst; % presound time
if prst < 0.02, prst = 0.02; end; % Hack for when tdur changes in the middle of a trial
if vlst < 0.02, vlst = 0.02; end; % Equal hack

fprintf(1, 'prst=%g  vlst=%g\n', prst, vlst);
global fake_rp_box;

if isempty(fake_rp_box) | fake_rp_box ~= 1,
    %      Cin    Cout    Lin    Lout    Rin    Rout   Tup    Timer   Dout    Aout
    stm = [stm ; ...
           1+b     b      b      b       b      b       b      100      0       0 ; ... %0 : Pre-state: wait for C poke
           1+b     b      b      b       b      b      2+b     0.01     0       0 ; ... %1 : if pk<10 ms, doesn't count
           TouS   TouS   TouS   TouS    TouS   TouS    3+b     prst     0       0 ; ... %2 : pre sound time
           3+b    3+b    3+b    3+b     3+b    3+b     ptnA    vlst     0    stne ; ... %3 : trigger sample sound
           TouS   TouS   TouS   TouS    TouS   TouS    ptnA    0.01     0       0 ; ... %4 : UNUSED
           WpkS   WpkS   lpkA   WpkS    rpkA   WpkS    WpkS    100      0       0 ; ... %5 : wait for r/l poke act
       ];
else 
    WtoS = pstart+6; % wait for sound over before going to the timeout state
    lost = tdur - vlst; if lost < 0.02, lost = 0.02; end; 
    
    %      Cin    Cout    Lin    Lout    Rin    Rout   Tup    Timer   Dout    Aout
    stm = [stm ; ...
           1+b     b      b      b       b      b       b      100      0       0 ; ... %0 : Pre-state: wait for C poke
           1+b     b      b      b       b      b      2+b     0.01     0       0 ; ... %1 : if pk<10 ms, doesn't count
           TouS   TouS   TouS   TouS    TouS   TouS    3+b     prst     0       0 ; ... %2 : pre sound time
           3+b    3+b    3+b    3+b     3+b    3+b     ptnA    vlst     0    stne ; ... %3 : trigger sample sound
           WtoS   WtoS   WtoS   WtoS    WtoS   WtoS    ptnA    lost     0       0 ; ... %4 : UNUSED
           WpkS   WpkS   lpkA   WpkS    rpkA   WpkS    WpkS    100      0       0 ; ... %5 : wait for r/l poke act
           WtoS   WtoS   WtoS   WtoS    WtoS   WtoS    TouS    tdur     0       0 ; ... %6 : wait for sound over bf timeout      
   ];
end;



stm = [stm ; zeros(rewardstart-size(stm,1),10)];

%      Cin    Cout    Lin    Lout    Rin    Rout   Tup    Timer   Dout    Aout
stm = [stm ; ...
       LrwS   LrwS   LrwS   LrwS    LrwS   LrwS   1+LrwS   lwpt     1       0 ; ... %0 : Left reward: give water
      1+LrwS 1+LrwS 1+LrwS 1+LrwS  1+LrwS 1+LrwS   ItiS    drkt     0       0 ; ... %1 : free time to enjoy water
       RrwS   RrwS   RrwS   RrwS    RrwS   RrwS   1+RrwS   rwpt     2       0 ; ... %2 : Right reward: give water
      1+RrwS 1+RrwS 1+RrwS 1+RrwS  1+RrwS 1+RrwS   ItiS    drkt     0       0 ; ... %3 : free time to enjoy water
       LddS   LddS   LddS   LddS    LddS   LddS   1+LddS   lwpt     1       0 ; ... %4 : Left direct w delivery
      1+LddS 1+LddS  ItiS  1+LddS  1+LddS 1+LddS  1+LddS   100      0       0 ; ... %5 : Wait for L water collection 
       RddS   RddS   RddS   RddS    RddS   RddS   1+RddS   rwpt     2       0 ; ... %6 : Left direct w delivery
      1+RddS 1+RddS 1+RddS 1+RddS    35   1+RddS  1+RddS   100      0       0 ; ... %7 : Wait for R water collection 
   ];

if ~isempty(fake_rp_box) & fake_rp_box==1,  % The fake rp_box crashes if a sound is triggered twice, so we must wait
    itwt = iti;  towt = tout;                % Time to wait for unriggering of the sounds
else
    itwt = 0.03; towt = 0.03;       
end;

stm = [stm ; zeros(itistart-size(stm,1),10)];

for i=1:8,  % Extra Iti states: lower trig and play sound...
    b = size(stm,1);
    stm = [stm ; ...
         b     b      b      b       b      b      1+b     0.03     0       0  ; ... 
        1+b   1+b    1+b    1+b     1+b    1+b     2+b     iti      0     itne];
end;
        
stm = [stm ; ...
       ItiS   ItiS   ItiS   ItiS    ItiS   ItiS   1+ItiS   0.03     0       0 ; ... %6 : lower trigs first
      2+ItiS 2+ItiS 2+ItiS 2+ItiS  2+ItiS 2+ItiS    35     iti      0     itne; ... %7 : ITI, trigger and play sound
       ItiS   ItiS   ItiS   ItiS    ItiS   ItiS    ItiS    itwt     0       0 ; ... %8 : happening: lower trigger and go back to set it off anew     
       TouS   TouS   TouS   TouS    TouS   TouS   1+TouS   0.03     0       0 ; ... %9 : lower all sound trigs first
      2+TouS 2+TouS 2+TouS 2+TouS  2+TouS 2+TouS  pstart   tout     0     totne; ...%10: timeout, trig and play sound
       TouS   TouS   TouS   TouS    TouS   TouS    TouS    towt     0       0 ; ... %11: Bad boy: go again 
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

FilterPath=[GetParam('rpbox','protocol_path') filesep 'PPfilter.mat'];
if ( size(dir(FilterPath),1) == 1 )
    PP=load(FilterPath);
    PP=PP.PP;
    % message(me,'Generating Calibrated Tones');
else
    PP=[];
    % message(me,'Generating Non-calibrated Tones');
end

sounds = cell(3,1);

SoundDur =GetParam(me,'SoundDur');
RampDur  =GetParam(me,'RampDur');
SPL      =GetParam(me,'SoundSPL');
BaseFreq =GetParam(me,'BaseFreq') * 1000;
NTones   =GetParam(me,'NTones');

sounds = cell(3,1);
chord = MakeChord( 50e6/1024, 70-SPL, BaseFreq, NTones, SoundDur*1000, RampDur*1000 );

ntrials    = GetParam(me, 'Trials'); 
side_list  = GetParam(me, 'SideList');
if side_list(ntrials+2)==1,
	sounds{1} = [zeros(length(chord),1) chord'];
else
	sounds{1} = [chord' zeros(length(chord),1)];
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
    
   
    