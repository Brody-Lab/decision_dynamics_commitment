function out = OperantTone(varargin)

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
        InitializeUIMenuParam('ForceSide',  {'None' 'Right', 'Left'},    1, rownum, colnum);   rownum = rownum+1;
        InitializeUIMenuParam('LeftSound',  {'silence', '5k->10k'},      2, rownum, colnum);   rownum = rownum+1;
        InitializeUIMenuParam('RightSound', {'silence', '10k->5k'},      2, rownum, colnum);   rownum = rownum+1;
        InitializeUIEditParam('ToneDur',                               0.4, rownum, colnum);   rownum = rownum+1; 
        InitializeUIEditParam('RampDur',                             0.005, rownum, colnum);   rownum = rownum+1; 
        rownum = rownum+0.5; % Blank row
        InitializeUIEditParam('ValidPokeDur',                            1, rownum, colnum);   rownum = rownum+1; 
        InitializeUIDispParam('Poke3',                                   0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('Poke2',                                   0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('Poke1',                                   0, rownum, colnum);   rownum = rownum+1;
        % rownum = rownum+0.5; % Blank row    
        % InitializeUIMenuParam('PokesPerReward', {'1' '2' '3' '4' '5' '6'},1,rownum, colnum);   rownum = rownum+1; 
        
        rownum = 1; colnum = 3;
        InitializeUIEditParam('LeftWValveTime',                        0.2, rownum, colnum);   rownum = rownum+1;
        InitializeUIEditParam('RightWValveTime',                      0.14, rownum, colnum);   rownum = rownum+1;
        rownum = rownum+0.5; % Blank row
        InitializeUIDispParam('CenterPokes',                             0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('LeftPokes',                               0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('RightPokes',                              0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('LeftRewards',                             0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('RightRewards',                            0, rownum, colnum);   rownum = rownum+1;
        InitializeUIDispParam('Rewards',                                 0, rownum, colnum);   rownum = rownum+1;
     
        rownum = rownum+0.5;
        InitParam(me,  'LeftPort',   'ui', 'togglebutton', 'pref', 0, 'enable', 'inact', 'pos', position(rownum, colnum, 0.4));
        SetParamUI(me, 'LeftPort',   'label', '', 'enable', 'inact', 'String', 'Left');
        InitParam(me,  'CenterPort', 'ui', 'togglebutton', 'pref', 0, 'enable', 'inact', 'pos', position(rownum, colnum+0.5, 0.4));
        SetParamUI(me, 'CenterPort', 'label', '', 'enable', 'inact', 'String', 'Center');
        InitParam(me,  'RightPort',  'ui', 'togglebutton', 'pref', 0, 'enable', 'inact', 'pos', position(rownum, colnum+1, 0.4));
        SetParamUI(me, 'RightPort',  'label', '', 'enable', 'inact', 'String', 'Right'); rownum = rownum+1;
        InitializeUIDispParam('PokeState',                               0, rownum, colnum);   rownum = rownum+1;
        
       
        InitParam(me, 'LastPokeInTime', 'value', 0);
        InitParam(me, 'LrwS', 'value', 0); InitParam(me, 'RrwS', 'value', 0); % state #'s for Left and Right reward
        
        % ------ Schedule ---------
        maxrewards = 1000; InitParam(me, 'MaxRewards',     'value', 1000);
        ppr_list   = zeros(1,maxrewards);
        ppr_list(1:20)   = [1 1 1 1 1 1 2 2 2 2 2 3 3 3 3 4 4 4 5 5];
        ppr_list(21:end) = ceil(6*rand(1,maxrewards-20));
        InitParam(me, 'PPRList', 'value', ppr_list);
        
        initialize_plot;
        
        % ------ Sounds ----------
        FreqStart = [10000    5000];  % Hz
        FreqEnd   = [ 5000   10000];  % Hz
        SPL       = 70;               % Max=PPdB SPL
        
        InitParam(me, 'ToneFreqStart','value', FreqStart);
        InitParam(me, 'ToneFreqEnd',  'value', FreqEnd);
        InitParam(me, 'ToneSPL',      'value', SPL);

        InitParam(me, 'Sounds',       'value', MakeSounds);
        InitParam(me, 'StateMatrix',  'value', state_transition_matrix);
        rpbox('InitRPSound');
        rpbox('LoadRPSound', GetParam(me,'Sounds'));
        rpbox('send_matrix', state_transition_matrix);
        
        
        return;
        
    case 'update',
        LrwS  = GetParam(me, 'LrwS'); % Get the state numbers that correspond to Left Reward and Right Reward States
        RrwS  = GetParam(me, 'RrwS');
        Event = Getparam('rpbox','event','user');
        
        for i=1:size(Event,1)
            if     Event(i,2)==1
                SetParamUI(me,'CenterPort','BackgroundColor',[0 1 0]);
                SetParam(me, 'LastPokeInTime', Event(i,3));
                SetParam(me, 'CenterPokes', GetParam(me, 'CenterPokes')+1);
            elseif Event(i,2)==2
                SetParamUI(me,'CenterPort','BackgroundColor',[0.8 0.8 0.8]);
                lastpokeouttime = Event(i,3);
            elseif Event(i,2)==3
                SetParamUI(me,'LeftPort','BackgroundColor',[0 1 0]);
                SetParam(me, 'LastPokeInTime', Event(i,3));
                SetParam(me, 'LeftPokes', GetParam(me, 'LeftPokes')+1);
            elseif Event(i,2)==4
                SetParamUI(me,'LeftPort','BackgroundColor',[0.8 0.8 0.8]);
                lastpokeouttime = Event(i,3);
            elseif Event(i,2)==5
                SetParamUI(me,'RightPort','BackgroundColor',[0 1 0]);
                SetParam(me, 'LastPokeInTime', Event(i,3));
                SetParam(me, 'RightPokes', GetParam(me, 'RightPokes')+1);
            elseif Event(i,2)==6
                SetParamUI(me,'RightPort','BackgroundColor',[0.8 0.8 0.8]);
                lastpokeouttime = Event(i,3);
            else
            end
            
            if     Event(i,1)==LrwS & Event(i,2)==7, SetParam(me, 'LeftRewards',  GetParam(me, 'LeftRewards') +1);
            elseif Event(i,1)==RrwS & Event(i,2)==7, SetParam(me, 'RightRewards', GetParam(me, 'RightRewards')+1);
            end;
            
            if ismember(Event(i,2), [2 4 6]), % it was a poke out
                SetParam(me, 'Poke3', GetParam(me, 'Poke2'));
                SetParam(me, 'Poke2', GetParam(me, 'Poke1'));
                SetParam(me, 'Poke1', lastpokeouttime - GetParam(me, 'LastPokeInTime'));
            end;
        end
        if size(Event,1)>0,
            laststate = Event(end,1);
            SetParam(me, 'PokeState', max(floor((laststate-1)/4),0));
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
        rpbox('send_matrix', state_transition_matrix);
        
    otherwise
        out = 0;
end;

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
    
    nrewards =- GetParam(me, 'Rewards')+1;
    hold on; plot(nrewards, ppr_list(nrewards), 'ro'); hold off;
    axis([0 81 0.9 6.1]);
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
        axes(h);
    
        nrewards = GetParam(me, 'Rewards')+1;
        ppr_list = GetParam(me, 'PPRList');
        plot(ppr_list, 'b.'); 
        hold on; plot(nrewards, ppr_list(nrewards), 'ro'); hold off;
        axmin = max(nrewards-40,0);
        axmax = axmin+80;
        axis([axmin axmax 0.9 6.1]);
        xlabel('rewards'); ylabel('pokes per reward');
        set(h, 'Tag', 'plot_schedule');
    end;
    return;
    
    



function [] = InitializeUIEditParam(parname, parval, rownum, colnum)
    
    InitParam(me, parname, 'ui', 'edit', 'value', parval, 'pos', position(rownum, colnum));
    SetParamUI(me, parname, 'label', parname);
    return;
    


    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         InitializeUIMenuParam
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = InitializeUIMenuParam(parname, parlist, parval, rownum, colnum)

InitParam(me, parname, 'ui', 'popupmenu', 'list', parlist, 'value', parval, 'pos', position(rownum, colnum));
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
iti  = GetParam(me, 'ITILength');
tout = GetParam(me, 'TimeOutLength');
lwpt = GetParam(me, 'LeftWValveTime');
rwpt = GetParam(me, 'RightWValveTime');

pprlist = GetParam(me, 'PPRList');
rewards = GetParam(me, 'Rewards'),
N       = pprlist(rewards+1);
tdur = GetParam(me, 'ToneDur');
fsde = GetParam(me, 'ForceSide');  % 1 = normal  2 = rewards only on left   3 = rewards only on right

states_per_poke = 4;
ItiS1            = 1;                    % InterTrialInterval state
ItiS2            = 2;                    % InterTrialInterval state
LrwS             = N*states_per_poke+2;  % Left  Reward state
RrwS             = N*states_per_poke+4;  % Right Reward state

SetParam(me, 'LrwS', LrwS); SetParam(me, 'RrwS', RrwS);

%          Cin    Cout    Lin    Lout    Rin    Rout    Tup    Timer    Dout    Aout
stm =     [ItiS2  ItiS2  ItiS2  ItiS2   ItiS2  ItiS2     2      iti      0       4] ; % InterTrial Interval State
stm=[stm;  ItiS1  ItiS1  ItiS1  ItiS1   ItiS1  ItiS1     2      iti      0       4] ; % InterTrial Interval State

for i=0:N-1, 
    b  = i*states_per_poke+2;      % base state for having poked i times
    nb = (i+1)*states_per_poke+2;  % same for having poked i+1 times
    
    if i<N-1,           lp = nb;   rp = nb;   cp = nb; % Even if good poke, not enough pokes for reward yet
    else
        if     fsde==1, lp = LrwS; rp = RrwS; cp = b;  % If good poke, it's the one that gives reward (except for Center)
        elseif fsde==2, lp = b;    rp = RrwS; cp = b;  % rewards only on Right
        elseif fsde==3, lp = LrwS; rp = b;    cp = b;  % rewards only on Left
        else            lp = LrwS; rp = RrwS; cp = b;  % this line should never get executed
        end;
    end;
  
    %      Cin    Cout    Lin    Lout    Rin    Rout    Tup    Timer    Dout    Aout
    stm = [stm ;  ...
            b+1     b     b+2     b      b+3     b       b      100      0       0 ; ... %b: Have poked i times already
            b+1     b      b      b       b      b       cp     vpd      0       0 ; ... %b+1: vpd   elapsed = real  Cpoke
             b      b     b+2     b       b      b       lp     vpd      0       0 ; ... %b+2: vpd   elapsed = valid Lpoke
             b      b      b      b      b+3     b       rp     vpd      0       0 ; ... %b+3: vpd   elapsed = valid Rpoke
         ];
 end;
 if 1,
     stm = [stm ; ...
           LrwS   LrwS   LrwS   LrwS    LrwS   LrwS    LrwS+1   tdur     0       2 ; ... % play sound #2 for LReward   
          LrwS+1 LrwS+1 LrwS+1 LrwS+1  LrwS+1 LrwS+1     35     lwpt     1       0 ; ... % Left Water
           RrwS   RrwS   RrwS   RrwS    RrwS   RrwS    RrwS+1   tdur     0       1 ; ... % play sound #1 for RReward   
          RrwS+1 RrwS+1 RrwS+1 RrwS+1  RrwS+1 RrwS+1     35     rwpt     2       0 ; ... % Rightt Water
       ];
end;


%     %      Cin    Cout    Lin    Lout    Rin    Rout    Tup    Timer    Dout    Aout
%     stm = [stm ;  ...
%             b+1     b     b+3     b      b+5     b       b      100      0       0 ; ... %b: Have poked i times already
%             b+1     b      b      b       b      b      b+2     0.01     0       0 ; ... %b+1: 10 ms elapsed = real  Cpoke
%             b+2     b      b      b       b      b       cp     vpd      0       0 ; ... %b+2: vpd   elapsed = valid Cpoke
%              b      b     b+3     b       b      b      b+4     0.01     0       0 ; ... %b+3: 10 ms elapsed = real  Lpoke
%              b      b     b+4     b       b      b       lp     vpd      0       0 ; ... %b+4: vpd   elapsed = valid Lpoke
%              b      b      b      b      b+5     b      b+6     0.01     0       0 ; ... %b+5: 10 ms elapsed = real  Rpoke
%              b      b      b      b      b+6     b       rp     vpd      0       0 ; ... %b+6: vpd   elapsed = valid Rpoke
%          ];
         
         
%       %Cin Cout Lin Lout Rin Rout Tup Timer Dout Aout
% stm = [ ...
%         1   0    3    0   6   0    0   100    0   0  ; ...   % 0: Pre-start state
%         1  10   10   10  10  10    2   0.01   0   0  ; ...   % 1: if 10 ms elapse, count as real C poke: go to state 2
%         2  10   10   10  10  10    9 vpd-0.01 0   0  ; ...   % 2: if stayed for vpd, valid poke: go to state 9
%        10  10    3   10  10  10    4   0.01   0   0  ; ...   % 3: if 10 ms elapse, count as real L poke: go to state 4
%        10  10    4   10  10  10    5 vpd-0.01 0   0  ; ...   % 4: if stayed for vpd, valid poke: go to state 5
%         5   5    5    5   5   5    9   lwpt   1   0  ; ...   % 5: LeftReward
%        10  10   10   10   6  10    7   0.01   0   0  ; ...   % 6: if 10 ms elapse, count as real R poke: go to state 7
%        10  10   10   10   7  10    8 vpd-0.01 0   0  ; ...   % 7: if stayed for vpd, valid poke: go to state 8
%         8   8    8    8   8   8    9   rwpt   2   0  ; ...   % 8: RightReward
%         9   9    9    9   9   9   35   iti    0   1  ; ...   % 9: Post-reward: stay for iti then end of trial 
%        10  10   10   10  10  10    9   tout   0   1  ; ...   %10: Time out, stay for tout then iti
%     ];
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

sounds = cell(n_tones,1);

for tn=1:n_tones
    if isempty(PP) | FreqStart(tn)== -1
        ToneAttenuation_adj = ToneAttenuation(tn);
    else
        ToneAttenuation_adj = ToneAttenuation(tn) - ppval(PP, log10(FreqMean(tn)));
        % Remove any negative attenuations and replace with zero attenuation.
        ToneAttenuation_adj = ToneAttenuation_adj .* (ToneAttenuation_adj > 0);
    end
    % FreqStart, FreqEnd,
    sounds{tn}  = 1 * MakeSwoop(50e6/1024, ToneAttenuation_adj ,FreqStart(tn), FreqEnd(tn), ToneDur*1000, RampDur*1000);
end

itidur = GetParam(me, 'ITILength');
itisound = 0.1*rand(1,itidur*50e6/1024);
sounds = [sounds ; {itisound}];

if GetParam(me, 'LeftSound') ==1, sounds{1} = zeros(size(sounds{1})); end;
if GetParam(me, 'RightSound')==1, sounds{2} = zeros(size(sounds{2})); end;
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
    
   
    