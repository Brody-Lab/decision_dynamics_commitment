function out = OperantTone4(varargin)


if nargin > 0, action = lower(varargin{1});
else action = lower(get(gcbo, 'tag')); % If called without args, must have been some callback
end;

out = 1;
switch action
    
    case 'init',
        ModuleNeeds(me, {'rpbox'});
        SetParam(me,'priority','value',GetParam('rpbox','priority')+1);
        fig = ModuleFigure(me,'visible','on');	
            
        rownum = 1; colnum = 1;

        InitializeUIEditParam('ITILength',                               2, rownum, colnum);   rownum = rownum+1;
        InitializeUIMenuParam('ITISound',  {'silence', 'white noise'},   2, rownum, colnum);   rownum = rownum+1;
        rownum = rownum+0.5; % Blank row
        InitializeUIEditParam('TimeOutLength',                           2, rownum, colnum);   rownum = rownum+1;
        InitializeUIMenuParam('TimeOutSound', {'silence'},               1, rownum, colnum);   rownum = rownum+1;
        rownum = rownum+0.5; % Blank row
        InitializeUIMenuParam('ForceSide',  {'R/L' 'R only' 'L only'},   1,rownum, colnum);rownum=rownum+1;
        InitializeUIMenuParam('LeftSound',  {'silence', '5k->10k', '2.5k->10k', '2.5k'},2, rownum, colnum);   rownum = rownum+1;
        InitializeUIMenuParam('RightSound', {'silence', '10k->5k', '10k->2.5k', '10k'}, 2, rownum, colnum);   rownum = rownum+1;
        InitializeUIEditParam('WaterBfrSoundTm',                       0.2, rownum, colnum);   rownum = rownum+1;
        InitializeUIEditParam('ToneDur',                               0.4, rownum, colnum);   rownum = rownum+1; 
        InitializeUIEditParam('RampDur',                             0.005, rownum, colnum);   rownum = rownum+1; 
        rownum = rownum+0.5; % Blank row
        InitializeUIEditParam('ValidPokeDur',                          0.1, rownum, colnum);   rownum = rownum+1; 
        InitializeUIEditParam('ValidInterPoke',                        0.5, rownum, colnum);   rownum = rownum+1; 
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
        InitializeUIMenuParam('MaxPokes', {'1' '2' '3' '4' '5' '6' '7' '8' '9' '10' '11' '12'}, 6, rownum,colnum);rownum=rownum+1;
        InitializeUIEditParam('HazardRate',                           0.16, rownum, colnum);   rownum = rownum+1;
        rownum = rownum+0.5; % Blank row
        InitializeUIDispParam('CenterPokes',                             0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('LeftPokes',                               0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('RightPokes',                              0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('LeftRewards',                             0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('RightRewards',                            0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('Rewards',                                 0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('Trials',                                  0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('CenterPortTrials',                        0, rownum, colnum);   rownum = rownum+1;
        
        rownum = rownum+0.5;
        InitParam(me,  'LeftPort',   'ui', 'togglebutton', 'pref', 0, 'enable', 'inact', 'pos', position(rownum, colnum, 0.4));
        SetParamUI(me, 'LeftPort',   'label', '', 'enable', 'inact', 'String', 'Left');
        InitParam(me,  'CenterPort', 'ui', 'togglebutton', 'pref', 0, 'enable', 'inact', 'pos', position(rownum, colnum+0.5, 0.4));
        SetParamUI(me, 'CenterPort', 'label', '', 'enable', 'inact', 'String', 'Center');
        InitParam(me,  'RightPort',  'ui', 'togglebutton', 'pref', 0, 'enable', 'inact', 'pos', position(rownum, colnum+1, 0.4));
        SetParamUI(me, 'RightPort',  'label', '', 'enable', 'inact', 'String', 'Right'); rownum = rownum+1;
        InitializeUIDispParam('PokeState',                               0, rownum, colnum);   rownum = rownum+1;
        
       
        InitParam(me, 'LastPokeInTime', 'value', 0); InitParam(me, 'LastPokeOutTime');
        InitParam(me, 'LrwS',   'value', 0); InitParam(me, 'RrwS', 'value', 0); % state #'s for Left  and Right  reward
        InitParam(me, 'pstart', 'value', 2); InitParam(me, 'states_per_poke', 'value', 4);
        
        % ------ Schedule ---------
        maxrewards = 1000; InitParam(me, 'MaxRewards',     'value', maxrewards);
        ppr_list   = zeros(1,maxrewards);
        ppr_list(1:20)   = [1 1 1 1 1 1 2 2 2 2 2 3 2 3 3 4 3 3 1 2];
        InitParam(me, 'PPRList', 'value', ppr_list);
        set_future_pokes_per_reward(21);
        InitParam(me, 'RewardHistory', 'value', '');
        
        initialize_plot;
        
        InitParam(me, 'Sounds',       'value', MakeSounds);
        InitParam(me, 'StateMatrix',  'value', state_transition_matrix);
        rpbox('InitRPSound');
        rpbox('LoadRPSound', GetParam(me,'Sounds'));
        rpbox('send_matrix', GetParam(me, 'StateMatrix'));
        
        
        return;
        
    case 'update',
        LrwS   = GetParam(me, 'LrwS'); % Get the state numbers that correspond to Left Reward and Right Reward States
        RrwS   = GetParam(me, 'RrwS');
        pstart = GetParam(me, 'pstart'); states_per_poke = GetParam(me, 'states_per_poke');
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
            
            if     Event(i,1)==LrwS & Event(i,2)==7, 
                SetParam(me, 'LeftRewards',    GetParam(me, 'LeftRewards') +1);
                SetParam(me, 'RewardHistory', [GetParam(me, 'RewardHistory') ; 'l']);
            elseif Event(i,1)==RrwS & Event(i,2)==7, 
                SetParam(me, 'RightRewards',   GetParam(me, 'RightRewards')+1);
                SetParam(me, 'RewardHistory', [GetParam(me, 'RewardHistory') ; 'r']);
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
            SetParam(me, 'PokeState', max(floor((laststate-pstart)/states_per_poke),0));
        end;
        
        return;
        
    case 'close',
        SetParam('rpbox','protocols',1);
        return;
        
    case 'state35',
        GetParam(me, 'Rewards'),
        SetParam(me, 'Rewards', GetParam(me, 'Rewards')+1);
        update_plot;
        SetParam(me, 'Sounds', MakeSounds); rpbox('LoadRPSound', GetParam(me, 'Sounds')); 
        SetParam(me, 'StateMatrix', state_transition_matrix);
        rpbox('send_matrix', GetParam(me, 'StateMatrix'));
        
        
    case 'hazardrate'
        set_future_pokes_per_reward(max(21,GetParam(me, 'Rewards')+2));
        update_plot;
        
    case 'maxpokes'
        set_future_pokes_per_reward(max(21,GetParam(me, 'Rewards')+2));
        update_plot;
        
    case {'tonedur,' 'waterbfrsoundtm'},
        wbst = GetParam(me, 'WaterBfrSoundTm');
        tndr = GetParam(me, 'ToneDur');
        if tndr < wbst + 0.04, tndr = wbst+0.04; end;
        SetParam(me, 'ToneDur', tndr);
        
    otherwise
        out = 0;
end;





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         set_future_pokes_per_reward(starting_at_reward_number)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = set_future_pokes_per_reward(starting_at);
    ppr_list   = GetParam(me, 'PPRList');
    hazardrate = GetParam(me, 'HazardRate'); maxpokes = GetParam(me, 'MaxPokes');
    prob       = hazardrate*((1-hazardrate).^(0:maxpokes-1));
    cumprob    = cumsum(prob/sum(prob));
    for i=starting_at:length(ppr_list), ppr_list(i) = min(find(rand(1)<=cumprob)); end;
    SetParam(me, 'PPRList', ppr_list);
    return;
        


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         initialize_plot
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = initialize_plot
    
    fig = findobj('Tag', me);
    figure(fig);
    
    h = axes('Position', [0.1 0.7 0.85 0.25]);
    ppr_list = GetParam(me, 'PPRList');
    plot(1:80, ppr_list(1:80), 'b.');
    
    nrewards = GetParam(me, 'Rewards')+1;
    hold on; plot(nrewards, ppr_list(nrewards), 'ro'); hold off;
    axis([0 81 0.5 max(ppr_list)+0.5]);
    xlabel('rewards'); ylabel('pokes per reward');
    set(h, 'Tag', 'plot_schedule');
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
        axes(h); cla;
    
        nrewards = GetParam(me, 'Rewards')+1;
        ppr_list = GetParam(me, 'PPRList');
        reward_history = GetParam(me, 'RewardHistory');
        th = text(1:length(reward_history), ppr_list(1:length(reward_history)), reward_history);
        set(th, 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'middle', 'FontSize', 8, 'FontWeight', 'bold', ...
            'Color', 'b', 'FontName', 'Helvetica');
        hold on; plot(length(reward_history)+1:length(ppr_list), ppr_list(length(reward_history)+1:end), 'b.'); 
        plot(nrewards, ppr_list(nrewards), 'ro'); hold off;
        axmin = max(nrewards-40,0);
        axmax = axmin+81;
        axis([axmin axmax 0.5 max(ppr_list)+0.5]);
        xlabel('rewards'); ylabel('pokes per reward');
        set(h, 'Tag', 'plot_schedule');
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

vpd  = GetParam(me, 'ValidPokeDur');
vnpd = GetParam(me, 'ValidInterPoke');
iti  = GetParam(me, 'ITILength')-0.1; if iti<0.1, iti=0.1; SetParam(me, 'ITILength', 0.2); end;
tout = GetParam(me, 'TimeOutLength');
lwpt = GetParam(me, 'LeftWValveTime');
rwpt = GetParam(me, 'RightWValveTime');
wbst = GetParam(me, 'WaterBfrSoundTm');

pprlist = GetParam(me, 'PPRList');
rewards = GetParam(me, 'Rewards'),
N       = pprlist(rewards+1);
tdur = GetParam(me, 'ToneDur');
fsde = GetParam(me, 'ForceSide');     % 1=r/l    2=right only  3=left only


states_per_poke  = 7;
ItiS             = 0;                    % InterTrialInterval state
pstart           = 40;                    % state at which program starts
LrwS             = N*states_per_poke + pstart;    % Left  Reward state
RrwS             = N*states_per_poke + pstart+3;  % Right Reward state

SetParam(me, 'LrwS',   LrwS);   SetParam(me, 'RrwS', RrwS);
SetParam(me, 'pstart', pstart); 
SetParam(me, 'states_per_poke', states_per_poke);
 
global fake_rp_box;
if ~isempty(fake_rp_box) & fake_rp_box==1,  % The fake rp_box crashes if a sound is triggered twice, so we must wait
    %          Cin    Cout    Lin    Lout    Rin    Rout    Tup    Timer    Dout    Aout
    stm =     [ 1      1       1      1       1      1     pstart   iti      0       4]; % ITI : play sound
    stm=[stm;   1      1       1      1       1      1       0      iti      0       0]; % Bad boy: wait for iti and go again 
else
    %          Cin    Cout    Lin    Lout    Rin    Rout    Tup    Timer    Dout    Aout
    stm =     [ 1      1       1      1       1      1     pstart   iti      0       4]; % ITI : trigger and play sound
    stm=[stm;   0      0       0      0       0      0       0      0.01     0       0]; % something happened; lower trigger and go back to set it off anew     
end;    

stm = [stm ; zeros(pstart-size(stm,1),10)];

for i=0:N-1, 
    b  = i*states_per_poke + pstart;      % base state for having poked i times
    nb = (i+1)*states_per_poke + pstart;  % same for having poked i+1 times
    
    if i<N-1,           lp = nb;   rp = nb;   cp = nb; % Even if good poke, not enough pokes for reward yet
    else
        if     fsde==1, lp = LrwS; rp = RrwS; % rewards on R/L only
        elseif fsde==2, lp = b;    rp = RrwS; % rewards on R only
        elseif fsde==3, lp = LrwS; rp = b;    % rewards on L only
        else            lp = LrwS; rp = RrwS; % this line should never get executed
        end;
        cp = b; % center pokes don't give reward in final block
    end;

    if i==0,
        %      Cin    Cout    Lin    Lout    Rin    Rout    Tup    Timer   Dout    Aout
        stm = [stm ; ...
                1+b     b     2+b     b      3+b     b       b      100      0       0 ; ... %0: Have poked i times already
                1+b     b      b      b       b      b       cp     vpd      0       0 ; ... %1: vpd   elapsed = real  Cpoke
                 b      b     2+b     b       b      b       lp     vpd      0       0 ; ... %2: vpd   elapsed = valid Lpoke
                 b      b      b      b      3+b     b       rp     vpd      0       0 ; ... %3: vpd   elapsed = valid Rpoke
                 0      0      0      0       0      0       0      0.1      0       0 ; ... %4: padding, never reached
                 0      0      0      0       0      0       0      0.1      0       0 ; ... %5: padding, never reached
                 0      0      0      0       0      0       0      0.1      0       0 ; ... %6: padding, never reached
            ];
    else
        if fake_rp_box==1, bstm = 0.05; else bstm = 0.01; end; % Back to school time in state 2 below: fake_rp_box doesn't like to rish things...
        %      Cin    Cout    Lin    Lout    Rin    Rout    Tup    Timer   Dout    Aout
        stm = [stm ;  ...
                 b     1+b     b     1+b      b     1+b      b      100      0       0 ; ... %0: came from poke; wait for outpoke
                2+b    2+b    2+b    2+b     2+b    2+b     3+b     vnpd     0       0 ; ... %1: must stay non-poking for vnpd
                1+b    1+b    1+b    1+b     1+b    1+b     1+b     bstm     0       0 ; ... %2: any act? back to school!
                4+b    3+b    5+b    3+b     6+b    3+b     3+b     100      0       0 ; ... %3: Have poked i times already
                4+b    3+b    3+b    3+b     3+b    3+b      cp     vpd      0       0 ; ... %4: vpd   elapsed = real  Cpoke
                3+b    3+b    5+b    3+b     3+b    3+b      lp     vpd      0       0 ; ... %5: vpd   elapsed = valid Lpoke
                3+b    3+b    3+b    3+b     6+b    3+b      rp     vpd      0       0 ; ... %6: vpd   elapsed = valid Rpoke
            ];
    end;
 end;
    
rmsdt = tdur - 0.02 - wbst,

 %      Cin    Cout    Lin    Lout    Rin    Rout    Tup    Timer   Dout    Aout
 stm = [stm ; ...
        LrwS   LrwS   LrwS   LrwS    LrwS   LrwS    1+LrwS   0.02     0       2 ; ... % trigger off sound #2 for LReward
       1+LrwS 1+LrwS 1+LrwS 1+LrwS  1+LrwS 1+LrwS   2+LrwS   rmsdt    0       0 ; ... % part of sound that is before water 
       2+LrwS 2+LrwS 2+LrwS 2+LrwS  2+LrwS 2+LrwS     35     lwpt     1       0 ; ... % Left Water
        RrwS   RrwS   RrwS   RrwS    RrwS   RrwS    1+RrwS   0.02     0       1 ; ... % trigger off sound #2 for LReward
       1+RrwS 1+RrwS 1+RrwS 1+RrwS  1+RrwS 1+RrwS   2+RrwS   rmsdt    0       0 ; ... % part of sound that is before water 
       2+RrwS 2+RrwS 2+RrwS 2+RrwS  2+RrwS 2+RrwS     35     lwpt     2       0 ; ... % Left Water
   ];

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

% ---- Sound 1 ------

switch GetParam(me, 'RightSound'),
    case 1, Sweepdir = 'up';   HiFreq = 1000;  LoFreq = 1000; % dummies, this'll be silence
    case 2, Sweepdir = 'down'; HiFreq = 10000; LoFreq = 5000; 
    case 3, Sweepdir = 'down'; HiFreq = 10000; LoFreq = 2500;
    case 4, Sweepdir = 'down'; HiFreq = 10000; LoFreq = 10000;
end;

FreqMean = exp((log(LoFreq) + log(HiFreq))/2);
if isempty(PP), 
    ToneAttenuation_adj = ToneAttenuation;
else 
    ToneAttenuation_adj = ToneAttenuation - ppval(PP, log10(FreqMean));
    ToneAttenuation_adj = ToneAttenuation_adj .* (ToneAttenuation_adj > 0);
end;

sounds{1}  = MakeSwoop2(50e6/1024, ToneAttenuation_adj, LoFreq, HiFreq, Sweepdir, ToneDur*1000, RampDur*1000);


% ---- Sound 2 ------

switch GetParam(me, 'LeftSound'),
    case 1, Sweepdir = 'up'; HiFreq = 1000;  LoFreq = 1000; % dummies, this'll be silence
    case 2, Sweepdir = 'up'; HiFreq = 10000; LoFreq = 5000; 
    case 3, Sweepdir = 'up'; HiFreq = 10000; LoFreq = 2500;
    case 4, Sweepdir = 'up'; HiFreq = 2500;  LoFreq = 2500;
end;

FreqMean = exp((log(LoFreq) + log(HiFreq))/2);
if isempty(PP), 
    ToneAttenuation_adj = ToneAttenuation;
else 
    ToneAttenuation_adj = ToneAttenuation - ppval(PP, log10(FreqMean));
    ToneAttenuation_adj = ToneAttenuation_adj .* (ToneAttenuation_adj > 0);
end;

sounds{2}  = MakeSwoop2(50e6/1024, ToneAttenuation_adj, LoFreq, HiFreq, Sweepdir, ToneDur*1000, RampDur*1000);



itidur = GetParam(me, 'ITILength');
itisound = 0.13*rand(1,floor(itidur*50e6/1024));
sounds{3}= itisound;

if GetParam(me, 'RightSound')==1, sounds{1} = zeros(size(sounds{2})); end;
if GetParam(me, 'LeftSound') ==1, sounds{2} = zeros(size(sounds{1})); end;
if GetParam(me, 'ITISound')  ==1, sounds{3} = zeros(size(sounds{3})); end;

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
    
   
    