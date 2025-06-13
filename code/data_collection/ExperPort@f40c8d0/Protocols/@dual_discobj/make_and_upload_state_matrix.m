function make_and_upload_state_matrix(obj, action)


DeadTimeReinitPenalty = 6;  % not set by user

global fake_rp_box;

GetSoloFunctionArgs;

% Read-write:'RealTimeStates', 'super'
%
% Read-only:
%   'n_done_trials'
%   'side_list', 'vpd_list'
%   'chord_sound_len', 'error_sound_len', 'go_dur',
%   'WaterDelivery', 'RewardPorts', 'DrinkTime', 'LeftWValve', 'RightWValve'
%   'ITISound', 'ITILength', 'ITIReinitPenalty', 'ExtraITIonError'
%   'TimeOutSound', 'TimeOutLength', 'TimeOutReinitPenalty', 'BadBoySound', 'BadBoySPL'

% RealTimeStates:
%   'wait_for_cpoke', 0, ...  % Waiting for initial center poke
%   'pre_chord',      % Silent period preceeding GO signal
%   'chord',          % GO signal
%   'wait_for_apoke', % Waiting for an answer poke (after GO signal)
%   'left_dirdel',    % Direct delivery on LHS
%   'right_dirdel',   % Direct delivery on RHS
%   'left_reward',    % Reward obtained on LHS
%   'right_reward',   % Reward obtained on RHS
%   'drink_time',     % Silent time to permit drinking
%   'timeout',        % Penalty state
%   'iti',            % Intertrial interval
%   'dead_time',      % 'Filler' state needed because of Matlab lag in sending next state machine
%   'state35',        % End-of-trial state (the state number is an ancient convention)
%   'extra_iti',      % State of penalty within ITI (occurs if rat pokes
%   during ITI - usually longer than ITI)

% stm_ctr.value = value(stm_ctr) + 1;
% sprintf('Called: %s', num2str(value(stm_ctr)))

% IDs by which sounds are uploaded
stne  = 1; % sample tone - here, the prolonged tone + silence before GO + and GO signal
whsd  = 2; % white noise sound
bbsd  = 3; % bad boy sound
errsd = 4; % error sound
gcsd  = 5; % drinking grace sound
itibbsd = 6; % set to something distinct if louder sound desired
wakesd = 7; % sound to wake rat up if trial isn't initiated in sleepln seconds

switch action,
    case 'next_matrix',  % serves only to skip the 'init' section
    case 'init'
        
       SoloParamHandle(obj, 'tup_flag', 'value', 0, 'saveable', 0);
        
        % FIRST: Set up sounds ---------------------------------
        amp = get_generic('amp');
        srate = get_generic('sampling_rate');

        % 1. White noise
        white_noise_factor = value(WN_SPL);
        white_noise_len = get_generic( 'white_noise_len');
        SoloParamHandle(obj, 'white_noise_sound', 'value', ...
            volume_factor*white_noise_factor*randn(1,floor(white_noise_len*srate)), 'saveable',0);
        
        % 7. Louder longer White noise - WAKE UP
        [wake_sound, wakeln] = Make_badboy_sound('generic', 0, 0, 'volume', 'LOUDEST');
        SoloParamHandle(obj, 'wakeup_sound', 'value', ...
            wake_sound, 'saveable',0);        

        % 2. Badboy Sound
        [bb_sound, bb_len] = Make_badboy_sound('generic', 0, 0, 'volume', BadBoySPL,'volume_factor',volume_factor);
        SoloParamHandle(obj, 'badboy_sound', 'value', bb_sound,'saveable',0);
        SoloParamHandle(obj, 'badboy_len', 'value', bb_len);

        % 3. Harsher version of badboy sound:
        h_bb_unit = MakeChord2( srate, 70-67, 20*1000, 4, 850, 'RiseFall',0.005*1000,'volume_factor',volume_factor );
        SoloParamHandle(obj, 'harsher_badboy_sound','saveable',0);
        partial_bb = [volume_factor*amp*rand(1, floor(0.8*srate)) zeros(1, floor(0.050*srate))];
        harsher_badboy_sound.value = [ h_bb_unit+partial_bb h_bb_unit+partial_bb ];
        SoloParamHandle(obj, 'harsher_badboy_len', 'value', ...
            length(value(harsher_badboy_sound))/floor(srate));
        
                 % ITI-special badboy sound
        [iti_bb_sound, iti_bb_len] = Make_badboy_sound('generic', 0, 0, 'volume', 'LOUDEST_PLUS');
        SoloParamHandle(obj, 'iti_badboy_sound', 'value', iti_bb_sound,'saveable',0);
        SoloParamHandle(obj, 'iti_badboy_len', 'value', iti_bb_len);        

        % Grace period for drinking
        gclen = 2; % seconds
        [snd] = MakeWNRamp(gclen*1000, srate, 0.005, 0.3);
        SoloParamHandle(obj,'grace_drink_sound', 'value', snd,'saveable',0);
        SoloParamhandle(obj,'grace_drink_len', 'value', gclen);        
        
        % Now load the sounds
        if fake_rp_box == 2 % for RTLinux
            LoadSound(rpbox('getsoundmachine'),whsd, value(white_noise_sound),'both',3,0);
            LoadSound(rpbox('getsoundmachine'),bbsd, value(badboy_sound),'both',3,0);
            LoadSound(rpbox('getsoundmachine'),itibbsd, value(iti_bb_sound),'both',3,0);
            LoadSound(rpbox('getsoundmachine'),gcsd, value(grace_drink_sound),'both',3,0);                        
            LoadSound(rpbox('getsoundmachine'),wakesd, value(wakeup_sound),'both',3,0);            
        else  % for simulator
            rpbox('loadrp3stereosound__withid', value(white_noise_sound), whsd);
            rpbox('loadrp3stereosound__withid', value(badboy_sound), bbsd);
            rpbox('loadrp3stereosound__withid', value(iti_bb_sound), itibbsd);
            rpbox('loadrp3stereosound__withid', value(grace_drink_sound), gcsd);
            rpbox('loadrp3stereosound__withid', value(wakeup_sound), wakesd);               
        end;

        % max stm row tracker
         SoloParamHandle(obj, 'stm_max_row', 'value', NaN(1,1000));       
        
    case 'update_bb_sound',
        [bb_sound, bb_len] = Make_badboy_sound('generic', 0,0, 'volume', BadBoySPL,'volume_factor',volume_factor);
        badboy_sound.value = bb_sound;
        badboy_len.value = bb_len;
        if fake_rp_box == 2
            LoadSound(rpbox('getsoundmachine'), bbsd, value(badboy_sound), 'both', 3, 0);
        else
            rpbox('loadrp3stereosound__withid', value(badboy_sound), bbsd);
        end;
        return;
        
    case 'update_wn_sound',
        amp = get_generic('amp');
        srate = get_generic('sampling_rate');
        white_noise_factor = value(WN_SPL);
        white_noise_len = get_generic('white_noise_len');
        white_noise_sound.value = volume_factor*white_noise_factor*amp*rand(1,floor(white_noise_len*srate));
        if fake_rp_box ==2
            LoadSound(rpbox('getsoundmachine'), whsd, value(white_noise_sound), 'both', 3, 0);
        else
            rpbox('loadrp3stereosound2', {[]; value(white_noise_sound)});
        end;
        return;
        
   case 'check_tup' % called every 300ms to see if session time limit has been reached.
     if value(tup_flag) == 0 && (etime(clock, value(protocol_start_time))/60 > MaxMins),

       h=figure;
       PushbuttonParam(obj,'savetom_mak', 200, 15,'label','MANUALLY SAVE DATA & SETTINGS'); 
       set_callback(savetom_mak, {'make_and_upload_state_matrix', 'save_evs_and_eodsave'});
       
       b=uicontrol('Style','text','String', sprintf('Session time is up.\n\nSave data manually\nOR\nwait for next trial to finish.'), ...
       'FontSize', 20, 'FontWeight','bold', ...
           'Position',[20 60 500 120],'BackgroundColor','y' );       
       
       c = get(gcf,'Children');
       % button
       set(c(2),'Position',[120 20 300 30],'FontSize', 14,'BackgroundColor','r');
       % uipanel
       set(c(3),'BackgroundColor','y');
       
       set(gcf,'Position', [300 300 500 200],'Name', 'Session time up','Color',[1 1 0],'Tag','tup_fig','Menubar','none','Toolbar','none');
              
       refresh;
       tup_flag.value = 1;
end;
 return;        

   case 'save_evs_and_eodsave'
        push_history(RealTimeStates);
        push_history(LastTrialEvents);
        SessionDefinition(obj,'eod_save');        
        return;
 
    otherwise,
        error(['Don''t know how to handle action ' action]);
end;

% -------------------------------------------------- End of switch-case
% statement

% my cap on state matrix size
STM_SIZE = 1000;
    
% length of sounds
wnln = get_generic('white_noise_len');
bbln     = value(badboy_len);
itibbln = bbln;
gcln = value(grace_drink_len);
sleepln = 60 * 5; % time to hang around in pstart state before playing a bbsound
wakeln = bbln;


% Assign shorter names for states to use in matrix
iti      = value(ITILength);
tout     = value(TimeOutLength);
lwpt     = value(LeftWValve);
rwpt     = value(RightWValve);
drkt     = value(DrinkTime);
ntrials  = value(n_done_trials);

if ~is_multiple(ITILength, wnln) | ~is_multiple(ExtraITIonError, wnln) | ~is_multiple(ITIReinitPenalty, wnln) | ...
        ~is_multiple(TimeOutLength, wnln) | ~is_multiple(TimeOutReinitPenalty, wnln)
    error(sprintf('ITI, ExtraITI, Timeout, Reinit penalties must be multiples of %g',wnln));
end;
if ~is_multiple(DeadTimeReinitPenalty, wnln)
    error(sprintf(['DeadTimeReinit penalties must be multiples of %g\n ' ...
        'Correct this within @%s/%s'], wnln, class(obj), mfilename));
end;

ExtraITIReinitPenalty = ITIReinitPenalty;

side = side_list(n_done_trials+1);
left = get_generic('side_list_left');

vpd  = vpd_list(n_done_trials+1);

% Calculations for time before GO signal
tdur = chord_sound_len;                         % Actual length of tones (here, prolonged tone + silence + GO)
vlst = ChordSection(obj, 'get_ValidSoundTime'); % Time after GO onset that Cout may occur sans penalty
%snd_stay_time = (chord_sound_len - go_dur) + vlst; % Time during main sound during which a Cout is penalised
%snd_leave_time = chord_sound_len - snd_stay_time; % After vlst seconds of GO signal, Cout will not be penalised

% Assemble all the times
prst  = vpd_list(n_done_trials+1);               % pre-sound
% relevant cue
if side == left, cue = tone1_list(n_done_trials+1); else cue = tone2_list(n_done_trials+1); end;
pre_chord = prechord_list(n_done_trials+1);
go_stay = vlst;
go_leave = go_dur - vlst;
%snd_stay_time =  go_dur) + vlst; % Time during main sound during which a Cout is penalised
%snd_leave_time = chord_sound_len - snd_stay_time; % After vlst seconds of GO signal, Cout will not be penalised
if go_stay < 0.02, go_stay = 0.02; end;
if go_leave < 0.02, go_leave = 0.02; end;
if prst < 0.02, prst = 0.02; end; % Hack for when tdur changes in the middle of a trial

if value(Blocks_Switch) > 0 && cue < 0.2
      h=figure;
          set(h,'Position',[300 300 500 75],'Color',[1 0 0],'Menubar','none','Toolbar','none');           
       uicontrol('Style','text', 'Position',[80 10 300 50],'BackgroundColor',[1 0 0], 'Fontsize', 14, 'FontWeight','bold', 'String', sprintf('Cue value should be greater than 0.2s!!\nPlease notify Shraddha of bad settings.\nEnding protocol now...'));
    error('BAD SETTINGS! Cue value should be > 0.2s! Please notify Shraddha of this bug!');
end;

% fprintf(1,'%s: trial-phase durations >>>>>>>>>\n', mfilename);
% fprintf(1,'pre-sound: %3.2f ms\ncue: %3.2f ms\npre-go: %3.2f ms\n, go-stay: %3.2f ms\n', ...
%     prst*1000, cue*1000, pre_chord*1000, go_stay*1000);
% fprintf(1,'go-leave: %3.2f ms, go dur: %3.2f ms\n', go_leave*1000, go_dur*1000);
% fprintf(1,'<<<<<<<<<<< %s: trial-phase durations \n', mfilename);


% This next section assigns NUMBERS for each state
% -----------------------------------------------------------

% Major hard-coded states in the state machine
pstart      = 40;   % start of main program
%rewardstart = 47;   % start of reward states program

% Get all the granular sections done here
temp1=[];temp2=[];temp3=[];temp4=[];
if prst > 0,temp1 = granular_section(0, 0, prst, Granularity/1000, LegalSkipOut/1000);end;
temp2 = granular_section(0, 0, cue, Granularity/1000, LegalSkipOut/1000);
if pre_chord > 0,temp3 = granular_section(0, 0, pre_chord, Granularity/1000, LegalSkipOut/1000);end;
temp4 = granular_section(0, 0, vlst, Granularity/1000, LegalSkipOut/1000);

rewardstart = 40 + 2 + ...
    rows(temp1) + rows(temp2) + rows(temp3) + rows(temp4) ...
    + 2;

%itistart    = 100;  % start of iti and timeout parts of program
itistart = rewardstart + 40;

% Reward states
%WpkS = pstart+5;  % state in which we're waiting for a R or L poke
WpkS = rewardstart - 1;
RealTimeStates.wait_for_cpoke = pstart;
RealTimeStates.wait_for_apoke = WpkS;

LrwS = rewardstart+ 0;  % state that gives water on left  port
RrwS = rewardstart+ 2;  % state that gives water on right port
LddS = rewardstart+ 4;  % state for left  direct water delivery
RddS = rewardstart+ 4 + 3;  % state for right direct water delivery
gc_state_len = sub__drinkgrace('state_length'); gc_eachside = gc_state_len / 2;
LgcS = rewardstart+ 7 + 3;  % drinking grace state -- left reward
RgcS = rewardstart+ 7 + 3 + gc_eachside; % drinking grace state -- right reward

RealTimeStates.left_reward    = LrwS;
RealTimeStates.right_reward   = RrwS;
RealTimeStates.drink_time     = [LrwS+1 RrwS+1];
RealTimeStates.left_dirdel    = [LddS:LddS+2];
RealTimeStates.right_dirdel   = [RddS:RddS+2];
RealTimeStates.drink_grace    = [LgcS:LgcS+gc_state_len]; 

bbfg = ~strcmp(BadBoySound, 'off');

global fake_rp_box;

% Penalty and ITI states
%
% Note: The lengths used for state i's offset
% actually correspond to the number of substates in state (i-1).
%ITI_state = 55;
%ITI_state = rewardstart + 10;
ITI_state = RgcS + gc_eachside;
ITIReinit_state      = ITI_state            + max(2*ITILength/wnln, 1); % no bb in ITI
ExtraITI_state       = ITIReinit_state      + max(2*ITIReinitPenalty/wnln + 2*bbfg, 1);
ExtraITIReinit_state = ExtraITI_state       + max(2*ExtraITIonError/wnln  + 2*bbfg, 1);
TimeOut_state        = ExtraITIReinit_state + max(2*ITIReinitPenalty/wnln + 2*bbfg, 1);
TimeOutReinit_state  = TimeOut_state        + max(2*TimeOutLength/wnln    + 2*bbfg, 1);
%if fake_rp_box == 2
    TimeOutReinit_state = TimeOutReinit_state + 1;
%end;
TimeOutReinit_endstate = TimeOutReinit_state + max(2*TimeOutReinitPenalty/wnln + 2*bbfg, 1);



%         dbstop if error;
%     if TimeOutReinit_endstate > 512,    % check for overflow
% 
%     fprintf(2, ['The reinits and timeouts and ITIs are too long! Reducing\n' ...
%         'them and trying them again. This will *not* be reflected\n' ...
%         'in the GUI.\n']);
%     [trash, u] = max([TimeOutReinitPenalty ITIReinitPenalty ITILength ...
%         TimeOutLength]);
%     
%     switch u(1),
%         case 1, TimeOutReinitPenalty = TimeOutReinitPenalty - wnln;
%         case 2, ITIReinitPenalty     = ITIReinitPenalty - wnln;
%         case 3, ITILength            = ITILength - wnln;
%         case 4, TimeOutLength        = TimeOutLength - wnln;
%     end;
% figure;
%     b=uicontrol('Style','text','String', sprintf('Program has crashed.\nPlease take out rat and notify Shraddha.\nPlease leave the protocol as-is.'), ...
%                 'FontSize', 20, 'FontWeight','bold', ...
%                 'Position',[10 60 520 120],'BackgroundColor','y' );
%             set(gcf,'Position', [300 300 500 200],'Name', 'Unexpected crash!','Color',[1 1 0],'Menubar','none','Toolbar','none');
%             refresh; 
%             error('Error in program. Please notify Shraddha.');
%             
%    % make_and_upload_state_matrix(obj, 'next_matrix');
% end;

% --- End of state number assignments

ItiS = ITI_state;
TouS = TimeOut_state;
if tout < 0.001, TouS = WpkS; end;  % timeouts of zero mean just skip that state

%        Cin    Cout    Lin    Lout     Rin     Rout    Tup    Timer    Dout   Aout
stm = [ pstart pstart  pstart pstart   pstart  pstart  pstart   0.01     0       0 ; ... % go to start of program
    ];

% Set up no-dead-time technology -------------------------########
DeadTimeReinit_state = 3;
% what to do when starting deadtime
stm = sub__noise_section(stm, ...
    'startstate', 1, ...
    'pokestate', DeadTimeReinit_state, ...
    'donestate', 35, ...
    'BadBoySound', 'off', ...
    'state_len', wnln, ...
    'bb_len', 0, ...
    'bb_sound', 0, ...
    'state_sound_len', wnln, ...
    'state_sound', whsd);
% what to do when reinitializing deadtime ( on poke )
[stm, DeadTime_endstate] = ...
    sub__noise_section(stm, ...
    'startstate', DeadTimeReinit_state, ...
    'pokestate', DeadTimeReinit_state, ...
    'donestate', 35, ...
    'BadBoySound', BadBoySound, ...
    'state_len', DeadTimeReinitPenalty, ...
    'bb_len', itibbln, ...
    'bb_sound', itibbsd, ...
    'state_sound_len', wnln, ...
    'state_sound', whsd);
RealTimeStates.dead_time = [1:DeadTime_endstate 35];

stm = [stm ; zeros(pstart-size(stm,1),10)]; % PAD till start state (pstart)

% State 35 for no-dead-time technology -------------------########
stm(36,:) = [35 35   35 35   35 35    1  0.01 0 0];
RealTimeStates.state35 = 36;


% -----------------------------------------------------------
%
% Case where we've reached trial limit
%
% -----------------------------------------------------------

if n_done_trials == 1
 h=msgbox('Please confirm speaker is in place, then click OK.', 'Speaker Check');
        set(h,'Position',[300 300 500 75],'Color',[1 1 0]);           
        c = get(h,'Children');  
        b = get(c(1),'Children'); 
        set(b,'FontSize', 14, 'FontWeight','bold');
        for k = 1:length(c),set(c(k),'FontSize',14);end;
        refresh;
  protocol_start_time.value = clock;
end;


if n_done_trials >= Max_Trials || etime(clock, value(protocol_start_time))/60 > MaxMins,
    
    t = findobj('Tag','tup_fig');
    if ~isempty(t),close(t); end;    

   srate = get_generic('sampling_rate');
   white_noise_len   = 2;
   white_noise_sound = 0.1*0.095*randn(1,floor(white_noise_len*srate));
   whln = white_noise_len;
   
   rpbox('loadrp3stereosound2', {[]; 0.3*value(white_noise_sound)});

   RealTimeStates.dead_time = 1:pstart-1;
   RealTimeStates.timeout   = pstart:pstart+2;
   %% HACK -- removed state pre_Go.
   if isfield(value(RealTimeStates),'pre_go'), 
       RealTimeStates.value = rmfield(value(RealTimeStates), 'pre_go');
   end;
   b = rows(stm);
   stm = [stm ; 
           b   b     b   b     b   b   b+1  0.03   0 0 ; ...
          b+1 b+1   b+1 b+1   b+1 b+1   b   whln   0 2];

   stm = [stm ; zeros(STM_SIZE-size(stm,1),10)];
   state_matrix.value = stm;
   rpbox('send_matrix', stm, 1, 1);   % <~> added another arg (value 1) to the call to employ Carlos's fix for long deadtimes (See comment at beginning of .../Modules/RPbox.m.).
   rpbox('send_statenames', RealTimeStates);

 
    make_and_upload_state_matrix(obj,'save_evs_and_eodsave');   
   return;
end;

% ptnA - post-tone action
% lpkA - left-poke action

% Post GO signal responses to pokes
% Defines state transitions depending on schedule
switch WaterDelivery,
    case 'only if nxt pke corr',
        punish = ExtraITI_state;
        ptnA = WpkS; % post-tone act here is to go to waiting for a R or L poke
        if     side==left, lpkA = LrwS;   rpkA = punish;  % lpkA and rpkA are acts (states to go to) on L and R pokes, respectively
        elseif side==1-left, lpkA = punish; rpkA = RrwS;
        end;

    case 'next corr poke',
        ptnA = WpkS; % post-tone act here is to go to waiting for a R or L poke
        if     side==left, lpkA = LrwS; rpkA = WpkS;
        elseif side==1-left, lpkA = WpkS; rpkA = RrwS;
        end;

    case 'direct',
        if     side==left, ptnA = LddS; % post-tone act is either the Left or Right direct water delivery
        elseif side==1-left, ptnA = RddS;
        end;
        lpkA = LrwS; rpkA = RrwS; % doesn't really matter, we won't reach them

    otherwise,
        error(['Don''t know how to do this WaterDelivery: ' WaterDelivery]);
end;

if strcmp(RewardPorts, 'both ports'),  % Override punishments, reward on both sides
    ptnA = WpkS;
    lpkA = LrwS;
    rpkA = RrwS;
end;


% Behaviour from Cin (start of trial) to GO sound --------- ###############
%
b  = pstart;        % base state for main program

%      Cin    Cout    Lin    Lout    Rin    Rout   Tup    Timer   Dout    Aout
stm = [stm ; ...
       2+b     b       b      b       b      b     1+b  sleepln      0       0 ; ...   %0 : b     Pre-state: wait for C poke
       1+b    1+b    1+b    1+b     1+b    1+b      b    wakeln      0    wakesd ];    
   
% Granularity needs to be created for a single state which has the pre-sound
% state, relevant tones, gaps, and the final GO chord

% Version 1: Everything from the starting cluck sound, pre-sound time
% right up to 'GO' signal used to be in 2+b:left_over_state. The new
% version will create separate chunks of states for each of these extents
% to cleanly separate their analysis.
% [stm_sstay, left_over_state] = granular_section(2+b, TouS, snd_stay_time, Granularity/1000, LegalSkipOut/1000, stne);


% Version 4: Revived as of Oct 2007
% NOTE: However, that the *sound* itself is still one and is only triggered
% during the pre-sound state (so that we may begin with a "Cluck")
if prst > 0,
    [stm_presound, cue_start_state] = granular_section(2+pstart, TouS, prst, Granularity/1000, LegalSkipOut/1000, stne);
    RealTimeStates.pre_chord = pstart+2:cue_start_state-1;
else
    stm_presound=[];
    cue_start_state = pstart + 2;
    RealTimeStates.pre_chord=[];
end;

[stm_cue, prego_start_state] = granular_section(cue_start_state, TouS, cue, Granularity/1000, LegalSkipOut/1000);
RealTimeStates.cue = cue_start_state:prego_start_state-1;

if pre_chord> 0, 
    [stm_prego, go_start_state] = granular_section(prego_start_state, TouS, pre_chord, Granularity/1000, LegalSkipOut/1000);
    RealTimeStates.pre_go = prego_start_state:go_start_state-1;
else
    stm_prego = [];
    go_start_state = prego_start_state;
    RealTimeStates.pre_go=[];
end;

[stm_sstay, go_leave_state] = granular_section(go_start_state, TouS, go_stay, Granularity/1000, LegalSkipOut/1000);
RealTimeStates.chord = go_start_state:go_leave_state;

stm = [stm; stm_presound];
stm = [stm; stm_cue];
stm = [stm; stm_prego];
stm = [stm; stm_sstay];

b = size(stm,1);
if ptnA == WpkS
    stm = [stm ; ...
        WpkS   WpkS    WpkS    WpkS    WpkS    WpkS  WpkS  go_leave  0   0];
elseif ptnA == LddS
    stm = [stm ; ...
        b   b   LddS    LddS    LddS    LddS	LddS  go_leave  0   0];
elseif ptnA == RddS
    stm = [stm ; ...
        b   b   RddS    RddS    RddS    RddS	RddS go_leave  0   0];
else
    error('Invalid value for ptnA; (must be WpkS, LddS or RddS)');
end;

stm = [stm ; ...
    WpkS   WpkS   lpkA   WpkS    rpkA   WpkS    WpkS    100      0       0 ; ...   %5 : 5+b   wait for r/l poke act
    ];

%RealTimeStates.pre_chord = pstart + 2:left_over_state;
%RealTimeStates.chord     = pstart + 2:left_over_state;

stm = [stm ; zeros(rewardstart-size(stm,1),10)];       % PAD till next hard-coded point (rewardstart)

global left1water;  lvid = left1water;
global right1water; rvid = right1water;

% Note: Although states for all trial types and schedules are defined, lpkA
% and rpkA (above) control which of these states left and right pokes
% transition to.
%      Cin    Cout    Lin    Lout    Rin    Rout   Tup    Timer   Dout    Aout
stm = [stm ; ...
    LrwS   LrwS   LrwS   LrwS    LrwS   LrwS   1+LrwS   lwpt     lvid       0 ; ... %0 : Left reward: give water
    1+LrwS 1+LrwS 1+LrwS 1+LrwS  1+LrwS 1+LrwS   LgcS    drkt     0       0 ; ... %1 : free time to enjoy water
    RrwS   RrwS   RrwS   RrwS    RrwS   RrwS   1+RrwS   rwpt     rvid       0 ; ... %2 : Right reward: give water
    1+RrwS 1+RrwS 1+RrwS 1+RrwS  1+RrwS 1+RrwS   RgcS    drkt     0       0 ; ... %3 : free time to enjoy water
    LddS   LddS   LddS   LddS    LddS   LddS   1+LddS   lwpt     lvid       0 ; ... %4 : Left direct w delivery
    1+LddS 1+LddS  2+LddS  1+LddS  1+LddS 1+LddS  1+LddS   100      0       0 ; ... %5 : Wait for L water collection
    2+LddS 2+LddS  2+LddS  2+LddS  2+LddS 2+LddS  ItiS   drkt+2      0       0 ; ... %5 : Wait for L water collection
    RddS   RddS   RddS   RddS    RddS   RddS   1+RddS   rwpt     rvid       0 ; ... %6 : Left direct w delivery
    1+RddS 1+RddS 1+RddS 1+RddS  2+RddS    1+RddS  1+RddS   100      0       0 ; ... %7 : Wait for R water collection
    2+RddS 2+RddS 2+RddS 2+RddS  2+RddS    2+RddS  ItiS   drkt+2      0       0 ; ... %7 : Wait for R water collection
    ];

RealTimeStates.left_dirdel = LddS:LddS+2;
RealTimeStates.right_dirdel = RddS:RddS+2;

% Drinking grace period
ministm = sub__drinkgrace(LgcS, value(grace_drink_len), gcsd, itibbsd, itibbln, ItiS);
stm = [stm ; ministm ]; 


% Set after sound trig, before sound end state to hold contingencies
% that the post tone Act (ptnA) state holds:
%stm(4+b+1, 1:6) = stm(ptnA+1,1:6);

% Behaviour during ITI states ----------------------------- ###############
% (regular, reinit-ed and penalty)
bbfg = ~strcmp(BadBoySound, 'off');

stm = [stm ; zeros(ITI_state-size(stm,1),10)];

[stm, ITI_endstate] = ...
    sub__noise_section(stm, ...
    'startstate', ITI_state, ...
    'pokestate', ITIReinit_state, ...
    'donestate', 35, ...
    'BadBoySound', 'off', ...
    'state_len', ITILength, ...
    'bb_len', 0, ...
    'bb_sound', 0, ...
    'state_sound_len', wnln, ...
    'state_sound', whsd);
[stm, ITIReinit_endstate] = ...
    sub__noise_section(stm, ...
    'startstate', ITIReinit_state, ...
    'pokestate', ITIReinit_state, ...
    'donestate', 35, ...
    'BadBoySound', BadBoySound, ...
    'state_len', ITIReinitPenalty, ...
    'bb_len', itibbln, ...
    'bb_sound', itibbsd, ...
    'state_sound_len',  wnln, ...
    'state_sound', whsd);
[stm, ExtraITI_endstate] = ...
    sub__noise_section(stm, ...
    'startstate', ExtraITI_state, ...
    'pokestate', ExtraITIReinit_state, ...
    'donestate', ITI_state, ...
    'BadBoySound', BadBoySound, ...
    'state_len', ExtraITIonError, ...
    'bb_len', error_sound_len, ...
    'bb_sound', errsd, ...
    'state_sound_len', wnln, ...
    'state_sound', whsd);

if ExtraITIonError == 0, donestate = ITI_state;
else                     donestate = ExtraITI_state+2*bbfg;
end;
[stm, ExtraITIReinit_endstate] = ...
    sub__noise_section(stm, ...
    'startstate', ExtraITIReinit_state, ...
    'pokestate', ExtraITIReinit_state, ...
    'donestate', ITI_state, ...
    'BadBoySound', BadBoySound, ...
    'state_len', ExtraITIReinitPenalty, ...
    'bb_len', error_sound_len, ...
    'bb_sound', errsd, ...
    'state_sound_len', wnln, ...
    'state_sound', whsd);

RealTimeStates.iti       = ...
    [ITI_state     :ITI_endstate           ITIReinit_state:ITIReinit_endstate];
RealTimeStates.extra_iti = ...
    [ExtraITI_state:ExtraITI_endstate ExtraITIReinit_state:ExtraITIReinit_endstate];

% Behaviour during TimeOut states ----------------------------- ############
%if fake_rp_box == 2
    stm = [stm; ...
        TouS    TouS    TouS    TouS    TouS    TouS    TouS+1  0.02 0 -1*stne];
    [stm, TimeOut_endstate] = ...
        sub__noise_section(stm, ...
        'startstate', TimeOut_state+1, ...
        'pokestate', TimeOutReinit_state, ...
        'donestate', pstart, ...
        'BadBoySound', BadBoySound, ...
        'state_len', TimeOutLength, ...
        'bb_len', bbln, ...
        'bb_sound', bbsd, ...
        'state_sound_len', wnln, ...
        'state_sound', whsd);
% else
%     [stm, TimeOut_endstate] = ...
%         sub__noise_section(stm, ...
%         'startstate', TimeOut_state, ...
%         'pokestate', TimeOutReinit_state, ...
%         'donestate', pstart, ...
%         'BadBoySound', BadBoySound, ...
%         'state_len', TimeOutLength, ...
%         'bb_len', bbln, ...
%         'bb_sound', bbsd, ...
%         'state_sound_len', wnln, ...
%         'state_sound', whsd);
% end;

if TimeOutLength == 0, donestate = pstart;
else                   donestate = TimeOut_state+2*bbfg;
end;
[stm, TimeOutReinit_endstate] = ...
    sub__noise_section(stm, ...
    'startstate', TimeOutReinit_state, ...
    'pokestate', TimeOutReinit_state, ...
    'donestate', pstart, ...
    'BadBoySound', BadBoySound, ...
    'state_len', TimeOutReinitPenalty, ...
    'bb_len', itibbln, ...
    'bb_sound', itibbsd, ...
    'state_sound_len', wnln, ...
    'state_sound', whsd);

RealTimeStates.timeout   = ...
    [TimeOut_state :TimeOut_endstate   TimeOutReinit_state:TimeOutReinit_endstate];

% Wrap-up ... and add a pretty bow! -------------------------- ############

% PAD with zeros up to a 512 size (fixed size of stm matrix):
tmp = value(stm_max_row);
tmp(n_done_trials+1) = rows(stm);
stm_max_row.value = tmp;

stm = [stm ; zeros(STM_SIZE-size(stm,1),10)];

% store for posterity
if ~exist('state_matrix', 'var'),
    SoloParamHandle(obj, 'state_matrix');
end;
state_matrix.value = stm;

rpbox('send_matrix', stm, 1, 1);   % <~> added another arg (value 1) to the call to employ Carlos's fix for long deadtimes (See comment at beginning of .../Modules/RPbox.m.).

% Store the latest RealTimeStates
push_history(RealTimeStates);
SavingSection(value(super),'autosave_data');

return;

function [stm, endstate] = sub__noise_section(stm, varargin)

if nargin < 2
    error('empty noise section passed in');
end;

pairs = { ...
      'startstate', NaN;  ...
    'pokestate', NaN; ...
    'donestate', NaN; ...
    'BadBoySound', NaN; ...
    'state_len', NaN; ...
    'bb_len', NaN; ...
    'bb_sound', NaN; ...
    'state_sound_len', NaN; ...
    'state_sound', NaN ; ...
    };
parse_knownargs(varargin,pairs);

Len = state_len;
bbln = bb_len;
bbsd = bb_sound;
wnln = state_sound_len;
whsd = state_sound;

if sum([isnan(startstate) isnan(pokestate) isnan(donestate)  ...
        isnan(BadBoySound)  isnan(state_len)  isnan(bb_len) ...
        isnan(bb_sound)  isnan(state_sound_len)  isnan(state_sound)]) > 0
    error('Sorry, not all the arguments were received.');
end;

%     sub__noise_section(stm,startstate,pokestate,donestate,...
%     BadBoySound,Len, ...
%     bbln, bbsd, wnln, whsd)
%
% General:
% Given a state matrix (stm), creates a reinit-able penalty/ITI state. In
% case of reinitialisation, prefaces the penalty state with a
% 'BadBoySound'.
%
% Details:
% Pads with zeros up to startstate; then puts in a BadBoySound (if
% 'on'), followed by Len secs of white noise (Len must be a multiple of
% wnln). On poke, goes to pokestate; at end, goes to donestate. wnln is
% the length, in secs, of the white noise signal
%
% Params:
% bbln : bad boy length, in sec
% bbsd : trigger for bad boy sound (i.e., column 10 of stm
% wnln : white noise length in sec
% whsd : trigger for white noise

trg = get_generic('trigger_time');

% NOTE !!! Len must be a multiple of wnln !!!!
if ~is_multiple(Len, wnln)
    error('Len should be a multiple of wnln!');
end;

if strcmp(BadBoySound, 'off') && Len==0
    % There is nothing to do here-- go to your done state asap
    c = size(stm,1);
    stm = [stm ; ...
        c      c       c       c        c     c    donestate 0.001 0 0];
    endstate = c;
    return
end;

stm = [stm ; zeros(startstate-size(stm,1),10)];
b0 = pokestate; c = size(stm,1);
%if strcmp(BadBoySound, 'on')
if ~strcmp(BadBoySound, 'off')
    % Start with bad boy sound, then go to white noises..
    stm = [stm ; ...
        b0     b0      b0      b0       b0    b0      c+1      trg     0       0 ; ...
        b0     b0      b0      b0       b0    b0      c+2      bbln     0    bbsd];
end

% If done with the white noises, go to the done state
if Len==0, stm(end,7) = donestate; end

for i=1:Len/wnln
    c = size(stm, 1);
    stm = [stm ; ...
        b0    b0       b0      b0       b0    b0      c+1      trg     0       0 ; ...
        b0    b0       b0      b0       b0    b0      c+2      wnln     0    whsd];
    % If done with the white noises, go to the done state
    if i==Len/wnln, stm(end,7) = donestate; end
end;

endstate = c+1;
return

function [ministm rgrace donestate] = sub__drinkgrace(x, gclen, gcsd, bbsd, bblen, ItiS)
% Creates a grace drinking period that should be appended after 'drkt'
% state matrix. 
% 1. If rat is still drinking, play grace sound (id = gcsd, dur = gclen (seconds)).
%       (if not, goto ITI)
% 2. After grace sound, if rat is still drinking, play bbsd 
%       (if not, goto ITI)
% (id = bbsd, dur = bblen (seconds)). 
% 3. Finally transition to ITI.
% -----
% x is the state number of the first stat
% Output params:
% 1. ministm: piece of state matrix implementing drinking grace period
% 2. rgrace: index for grace period for right drinking port

if nargin == 1
    if strcmpi(x,'state_length')
        ministm = 8;
        return;
    else
        error('invalid argument');
    end;
end;

rgrace = x+4;
%  Cin    Cout    Lin    Lout    Rin    Rout   Tup    Timer   Dout    Aout
ministm = [ ...
    x       x     x+1     x+1     x      x     ItiS    0.5      0      0 ; ...    % done drinking left?
    x+1     x+1   x+1     x+1     x+1    x+1   x+2     gclen    0      gcsd ; ... % grace period
    x+2     x+2   x+3     x+3     x+2    x+2   ItiS    0.5      0      0 ; ...    % done drinking?
    x+3     x+3   x+3     x+3     x+3    x+3   ItiS    bblen    0      bbsd ];

x = x+4;
mini_right = [...
    x       x      x      x       x+1    x+1   ItiS    0.5      0      0 ; ...    % done drinking left?
    x+1     x+1   x+1     x+1     x+1    x+1   x+2     gclen    0      gcsd ; ... % grace period
    x+2     x+2   x+2     x+2     x+3    x+3   ItiS    0.5      0      0 ; ...    % done drinking?
    x+3     x+3   x+3     x+3     x+3    x+3   ItiS    bblen    0      bbsd ];

donestate = x+3;

ministm = [ministm; mini_right];
    
