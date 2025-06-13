% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%
%            'prepare_next_trial'   Returns a @StateMachineAssembler
%                        object, ready to be sent to dispatcher, and a cell
%                        of strings containing the 'prepare_next_trial'
%                        states.
%
%            'get_state_colors'     Returns a structure where each
%                        fieldname is a state name, and each field content
%                        is a color for that state.
%
%
% RETURNS:
% --------
%
% [sma, prepstates]      When action == 'prepare_next_trial', sma is a
%                        @StateMachineAssembler object, ready to be sent to
%                        dispatcher, and prepstates is a a cell
%                        of strings containing the 'prepare_next_trial'
%                        states.
%
% state_colors           When action == 'get_state_colors', state_colors is
%                        a structure where each fieldname is a state name,
%                        and each field content is a color for that state.
%
%
%
% 
%



function [varargout] = SMASection(obj, action) %#ok<FNDEF>
   
GetSoloFunctionArgs(obj);

switch action
    
%% prepare_next_trial
% -----------------------------------------------------------------------
%
%         PREPARE_NEXT_TRIAL
%
% -----------------------------------------------------------------------

  case 'prepare_next_trial',

    left1led           = bSettings('get', 'DIOLINES', 'left1led'); %#ok<NASGU>
    center1led         = bSettings('get', 'DIOLINES', 'center1led');
    right1led          = bSettings('get', 'DIOLINES', 'right1led'); %#ok<NASGU>
    left1water         = bSettings('get', 'DIOLINES', 'left1water'); %#ok<NASGU>
    right1water        = bSettings('get', 'DIOLINES', 'right1water'); %#ok<NASGU>
    [LtValve, RtValve] = WaterValvesSection(obj, 'get_water_times'); %#ok<NASGU,NASGU>

    side = Sides3waySection(obj, 'get_current_side');
    
    sma = StateMachineAssembler('full_trial_structure');
    
    if ~exist('flash_time', 'var'), flash_time = .3; end;
    
    details = struct;
    
    if      (anti == 0 && side == 'l') || (anti ==1 && side == 'r'), sound_name = 'LeftSnd';   led_name = left1led; %#ok<ALIGN>
    else if (anti == 0 && side == 'r') || (anti ==1 && side == 'l'), sound_name = 'RightSnd';  led_name = right1led;
         else if side == 'c', if anti ==0,                           sound_name = 'CenterSnd'; led_name = center1led; end; %#ok<ALIGN>
              if anti ==1, error(mfilename + 'Anti requires left and right only trials') ; end;
    end; end; end;
    
    details.flash_time     = flash_time;
    details.n_center_pokes = n_center_pokes;
    details.delay_light    = delay_light;
    details.centerlight    = centerlight;
    details.soundcue       = soundcue;
    details.side           = side;
    details.anti           = anti;
    details.center_punish  = center_punish;
    details.nowrong        = nowrong;
    details.nolate         = nolate;
    details.sroverlap      = sroverlap;
    details.ROverlap       = ROverlap;
    details.lightstim      = lightstim;
    details.soundstim      = soundstim;
    details.sound_name     = sound_name;
    details.led_name       = led_name;
    
    
%Center Poke(s) to initiate Trial
    if value(n_center_pokes) >= 1,  ...
       if value(n_center_pokes) == 1, action_state  = 'wait_for_light'; else action_state  = 'wait_centerpoke2'; end;
        flashchanges1 = {'self_timer', flash_time, 'input_to_statechange', {'Tup', 'current_state+1', 'Cin', action_state}};
        flashchanges2 = {'self_timer', flash_time, 'input_to_statechange', {'Tup', 'current_state-1', 'Cin', action_state}};
       sma = add_state(sma, 'name', 'wait_centerpoke1', 'output_actions', {'DOut', center1led}, flashchanges1{1:end});
       sma = add_state(sma,                                                                     flashchanges2{1:end});
       if value(details.n_center_pokes) == 2, sma = add_state(sma, 'name', 'wait_centerpoke2', 'input_to_statechange', {'Cin', 'wait_for_light'}); end;
    end;
    
%Delay before stimulus
    [delayout, delaystatechanges] = delayaction(obj, details);
    sma = add_state(sma, 'name', 'wait_for_light',...
            'self_timer', delay_time, ...
            'output_actions', delayout,...
            'input_to_statechange', delaystatechanges);
    
%Early Punish for Poke during delay
    if noearly == 0, sma = PunishInterface(obj, 'add_sma_states', 'early_punish', sma, 'exitstate', 'wait_for_light');                                                       
    else sma = WarnDangerInterface(obj, 'add_sma_states', 'early_punish', sma, 'exitstate', 'wait_for_light', 'on_poke_when_danger_state', 'warndanger');
    end;
    
%Stimulus & Response period
    [strout, strstatechanges] = stimactions(obj, details);        
    sma = add_state(sma, 'name', 'light_on', ...
            'self_timer', stim_time,...
            'output_actions', strout,...
            'input_to_statechange', strstatechanges);
        
%New State for wrong poke without punish
    [str2out, str2statechanges] = stim2actions(obj, details);        
    sma = add_state(sma, 'name', 'light_on2', ...
            'self_timer', stim_time,...
            'output_actions', str2out,...
            'input_to_statechange', str2statechanges);
    
%Sound Ending States Before Punishments
    turnoffsoundcue  = {'SoundOut', -SoundManagerSection(obj, 'get_sound_id', 'CueSound')};
    turnoffsoundstim = {'SoundOut', -SoundManagerSection(obj, 'get_sound_id', sound_name)};
    if (value(soundcue) == 1) && (value(soundstim) == 1)
        sound1 = turnoffsoundcue;  afterlate  = 'soundoff2late';
        sound2 = turnoffsoundstim; afterwrong = 'soundoff2wrong';
    elseif value(soundcue)  == 1, sound1 = turnoffsoundcue;  afterlate = 'late_punish'; afterwrong = 'wrong_punish';
    elseif value(soundstim) == 1, sound1 = turnoffsoundstim; afterlate = 'late_punish'; afterwrong = 'wrong_punish';
    end;
    
    if (value(soundcue) == 1 || value(soundstim) == 1)
        sma = add_state(sma, 'name', 'soundoffwrong', ...
                        'self_timer', 0.001, ...
                        'input_to_statechange', {'Tup', afterwrong},...
                        'output_actions', sound1);
        sma = add_state(sma, 'name', 'soundofflate', ...
                        'self_timer', 0.001, ...
                        'input_to_statechange', {'Tup', afterlate},...
                        'output_actions', sound1);
    end;
    if value(soundcue) == 1 && value(soundstim) == 1
        sma = add_state(sma, 'soundoff2wrong', ...
                        'self_timer', 0.001, ...
                        'input_to_statechange', {'Tup', 'wrong_punish'},...
                        'output_actions', sound2);
        sma = add_state(sma, 'soundoff2late', ...
                        'self_timer', 0.001, ...
                        'input_to_statechange', {'Tup', 'late_punish'},...
                        'output_actions', sound2);
    end;
    
%Wrong Punishment
    sma = PunishInterface(obj, 'add_sma_states', 'wrong_punish', sma, 'exitstate', 'warndanger');  

%Late Punishment
    sma = PunishInterface(obj, 'add_sma_states', 'late_punish',  sma, 'exitstate', 'warndanger');
    
%Soft Poke Stay Reward Period
    softpokeinput = rewactions(obj, details);
    sma = SoftPokeStayInterface(obj, 'add_sma_states', 'reward', sma, softpokeinput{1:end});

%Soft Poke Stay Reward Period
    softpokeinput = rew2actions(obj, details);
    sma = SoftPokeStayInterface(obj, 'add_sma_states', 'reward2', sma, softpokeinput{1:end});
    
%Trial End WarnDanger
    sma = WarnDangerInterface(obj, 'add_sma_states', 'warndanger', sma, 'exitstate', 'check_next_trial_ready', 'on_poke_when_danger_state', 'warndanger');
    
    
    
    varargout{1} = sma;
    varargout{2} = {'warndanger'};
    
%% get_state_colors
% ----------------------------------------------------------------
%
%       CASE GET_STATE_COLORS
%
% ----------------------------------------------------------------
  
    case 'get_state_colors'

        varargout{1} = struct( ...
            'wait_centerpoke1',           [132 161 137]/255, ...  % sage
            'wait_centerpoke2',           [61  131 157]/255, ...  % aqua teal
            'wait_for_light',             [129  77 110]/255, ...  % plum
            'light_on',                   [255 236 139]/255, ...  % light goldenrod
            'light_on2',                  [255 200 139]/255, ...  % light goldenrod - green
            'early_punish',               [255 161 137]/255, ...  % peach 
            'wrong_punish',               [255   0   0]/255, ...  % red
            'late_punish',                [188  77 110]/255, ...  % fuscia
            'reward',                     [50  255  50]/255, ...  % green
            'reward2',                    [100 255  50]/255, ...  % green + red
            'warndanger_warning',         [0.3   0   0],     ...  % dark maroon
            'warndanger_danger',          [0.5 .05 .05],     ...  % lighter maroon
            'state_0',                    [1    1    1],     ...
            'check_next_trial_ready',     [0.7 0.7 0.7]);
 
%      'wait_for_spoke',             [132 161 137]/255, ...  % sage
%      'temperror',                  [61  131 157]/255, ...  % aqua teal


%% reinit

% ----------------------------------------------------------------
%
%       CASE REINIT
%
% ----------------------------------------------------------------

  case 'reinit',
    currfig = gcf;

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);

    % Reinitialise at the original GUI position and figure:
    feval(mfilename, obj, 'init');

    % Restore the current figure:
    figure(currfig);
end;
end

%% Delayaction

function [output, statechanges] = delayaction(obj, details)

  delay_light = value(details.delay_light);
  centerlight = value(details.centerlight);
  soundcue    = value(details.soundcue   );

  left1led           = bSettings('get', 'DIOLINES', 'left1led');
  center1led         = bSettings('get', 'DIOLINES', 'center1led');
  right1led          = bSettings('get', 'DIOLINES', 'right1led');

  if delay_light == 0
        if centerlight == 0, DL = 0; %No Centerlight, No Delaylight
        else                 DL = center1led; end;
   else                      DL = right1led+center1led+left1led;
   end;
   
   if soundcue == 0, output = {'DOut', DL};
   else              output = {'DOut', DL, 'SoundOut', SoundManagerSection(obj, 'get_sound_id', 'CueSound')};
   end;
 
   statechanges = {'Tup', 'light_on', 'Lin', 'early_punish', 'Rin', 'early_punish'};

end

%% Stimactions

function [output, statechanges] = stimactions(obj, details) %#ok<INUSL>
    
    side          = value(details.side         );
    centerlight   = value(details.centerlight  );
    soundcue      = value(details.soundcue     );
    nowrong       = value(details.nowrong      );
    nolate        = value(details.nolate       );
    center_punish = value(details.center_punish);
    lightstim     = value(details.lightstim    );
    soundstim     = value(details.soundstim    );
    led_name      =       details.led_name      ;
    sound_name    =       details.sound_name    ;
        
    %No lights if lightstim off
    if lightstim == 0, led_name = 0; end;

    %Add centerlight if on (bitor adds the bitstrings without messing up if a stimulus is already on)
    if centerlight == 1, led_name = bitor(led_name, center1led); end;
    
    if soundstim == 0, output = {'DOut', led_name};
    else               output = {'DOut', led_name, 'SoundOut', SoundManagerSection(obj, 'get_sound_id', sound_name)}; end; %#ok<ALIGN>
        
    %Determine correct poke
    if side == 'l', correct_poke = 'Lin'; incorrect_poke1 = 'Rin'; incorrect_poke2 = 'Cin'; end;
    if side == 'r', correct_poke = 'Rin'; incorrect_poke1 = 'Lin'; incorrect_poke2 = 'Cin'; end;
    if side == 'c', correct_poke = 'Cin'; incorrect_poke1 = 'Rin'; incorrect_poke2 = 'Lin'; end;
    statechanges = {correct_poke, 'reward'};
    
    %Determine whether sound needs to be turned off before punishments
    if soundcue == 0 && soundstim == 0,  wrongstate = 'wrong_punish';  latestate  = 'late_punish';
    else 	                             wrongstate = 'soundoffwrong'; latestate  = 'soundofflate'; end;

    %Add late state if on, or timeout
    if nolate == 0, statechanges(end+1, :) = {'Tup', latestate };
    else                    statechanges(end+1, :) = {'Tup', warndanger}; end;
    
    %Add wrong punish if on
    if nowrong == 0,                           statechanges(end+1, :) = {incorrect_poke1, wrongstate};
        if (side == 'c'|| center_punish == 1), statechanges(end+1, :) = {incorrect_poke2, wrongstate}; end;
    else                                       statechanges(end+1, :) = {incorrect_poke1, 'light_on2'};
        if (side == 'c'|| center_punish == 1), statechanges(end+1, :) = {incorrect_poke2, 'light_on2'};end;
    end;

end

%% Stim2actions

function [output, statechanges] = stim2actions(obj, details) %#ok<INUSL>
    
    side          = value(details.side         );
    centerlight   = value(details.centerlight  );
    soundcue      = value(details.soundcue     );
    nowrong       = value(details.nowrong      ); %#ok<NASGU>
    nolate        = value(details.nolate       );
    center_punish = value(details.center_punish);
    led_name      =       details.led_name      ;
    
    %Add centerlight if on (bitor adds the bitstrings without messing up if a stimulus is already on)
    if centerlight == 1, led_name = bitor(led_name,center1led); end;
    
    output = {'DOut', led_name, 'SoundOut', SoundManagerSection(obj, 'get_sound_id', 'WrongSound')};
    
    %Determine correct poke
    if side == 'l', correct_poke = 'Lin'; incorrect_poke2 = 'Cin'; end;
    if side == 'r', correct_poke = 'Rin'; incorrect_poke2 = 'Cin'; end;
    if side == 'c', correct_poke = 'Cin'; incorrect_poke2 = 'Lin'; end;
    statechanges = {correct_poke, 'reward'};
    
    %Determine whether sound needs to be turned off before punishments
    if soundcue ==0, wrongstate = 'wrong_punish';  latestate  = 'late_punish';
    else 	         wrongstate = 'soundoffwrong'; latestate  = 'soundofflate'; end;

    %Add late state if on, or timeout
    if nolate == 0, statechanges(end+1, :) = {'Tup', latestate };
    else            statechanges(end+1, :) = {'Tup', warndanger}; end;
    
    %Add wrong punish if on
    if (side == 'c'|| center_punish == 1), statechanges(end+1, :) = {incorrect_poke2, wrongstate}; end;

end

%% Rewactions
function [softpokeinput] = rewactions(obj, details)
    
    side         = value(details.side        );
    centerlight  = value(details.centerlight );
    sroverlap    = value(details.sroverlap   );
    soundcue     = value(details.soundcue    );
    ROverlap     = value(details.ROverlap    );
    soundstim    = value(details.soundstim   );
    led_name      =       details.led_name    ;
    sound_name    =       details.sound_name  ;
    
    %Get values for output lines
    left1water         = bSettings('get', 'DIOLINES', 'left1water');
    right1water        = bSettings('get', 'DIOLINES', 'right1water');
    [LtValve, RtValve] = WaterValvesSection(obj, 'get_water_times');

    %Determine the correvt poke and water valves
    if side == 'l', correct_poke = 'L'; rew_dout = left1water;  rew_t = LtValve; end;
    if side == 'r', correct_poke = 'R'; rew_dout = right1water; rew_t = RtValve; end;
    if side == 'c', correct_poke = 'C'; rew_dout = 0;           rew_t = 0;       end;
    
    if centerlight == 0, ConstantDOut = 0;
    else                 ConstantDOut = center1led;
    end;
        
    %Add centerlight if on (bitor adds the bitstrings without messing up if a stimulus is already on)
    if centerlight == 1, led_name = bitor(led_name,center1led); ConstantDOut = center1led; end;

    if soundcue == 1 && soundstim == 1, sound1 = 'CueSound'; sound2 = sound_name;
    elseif soundstim == 1, sound = sound_name;
    elseif soundcue  == 1, sound = 'CueSound';
    end;
    
    %Output as determined by whether soundcue needs to be turned off
	if soundcue == 0 && soundstim == 0;
        softpokeinput = {'pokeid', correct_poke, 'DOut', rew_dout, 'DOutStartTime', 0, 'DOutOnTime', rew_t, ...
            'DOut2', led_name, 'DOut2StartTime', 0, 'DOut2OnTime', sroverlap, 'ConstantDOut', ConstantDOut, ...
            'success_exitstate_name', 'warndanger', 'abort_exitstate_name', 'warndanger'};
    elseif ~(soundcue == 1 && soundstim ==1)
        softpokeinput = {'pokeid', correct_poke, 'DOut', rew_dout, 'DOutStartTime', 0, 'DOutOnTime', rew_t, ...
            'DOut2', led_name, 'DOut2StartTime', 0, 'DOut2OnTime', sroverlap, 'ConstantDOut', ConstantDOut, ...
            'Sound1TrigTime', ROverlap+0.01, 'Sound1Id', -SoundManagerSection(obj, 'get_sound_id', sound), ...
            'success_exitstate_name', 'warndanger', 'abort_exitstate_name', 'warndanger'};
    else
        softpokeinput = {'pokeid', correct_poke, 'DOut', rew_dout, 'DOutStartTime', 0, 'DOutOnTime', rew_t, ...
            'DOut2', led_name, 'DOut2StartTime', 0, 'DOut2OnTime', sroverlap, 'ConstantDOut', ConstantDOut, ...
            'Sound1TrigTime', ROverlap+0.01, 'Sound1Id', -SoundManagerSection(obj, 'get_sound_id', sound1), ...
            'Sound2TrigTime', ROverlap+0.02, 'Sound2Id', -SoundManagerSection(obj, 'get_sound_id', sound2), ...
            'success_exitstate_name', 'warndanger', 'abort_exitstate_name', 'warndanger'};
	end;

    
    
end

%% Rew2actions

function [softpokeinput] = rew2actions(obj, details)
    
    side         = value(details.side        );
    centerlight  = value(details.centerlight );
    sroverlap    = value(details.sroverlap   );
    soundcue     = value(details.soundcue    );
    ROverlap     = value(details.ROverlap    );
    soundstim    = value(details.soundstim   );
    sound_name   =       details.sound_name  ;
    led_name     =       details.led_name    ;

    %Get values for output lines
    left1water         = bSettings('get', 'DIOLINES', 'left1water');
    right1water        = bSettings('get', 'DIOLINES', 'right1water');
    [LtValve, RtValve] = WaterValvesSection(obj, 'get_water_times');
    
    %Determine the correvt poke and water valves
    if side == 'l', correct_poke = 'L'; rew_dout = left1water;  rew_t = LtValve/2; end;
    if side == 'r', correct_poke = 'R'; rew_dout = right1water; rew_t = RtValve/2; end;
    if side == 'c', correct_poke = 'C'; rew_dout = 0;             rew_t = 0;       end;
    
    if centerlight == 0, ConstantDOut = 0;
    else                 ConstantDOut = center1led;
    end;
    
    %Add centerlight if on (bitor adds the bitstrings without messing up if a stimulus is already on)
    if centerlight == 1, led_name = bitor(led_name,center1led); ConstantDOut = center1led; end;
        
    %Output as determined by whether soundcue needs to be turned off
    if soundcue == 1 && soundstim == 1, sound1 = 'CueSound'; sound2 = sound_name;
    elseif soundstim == 1, sound = sound_name;
    elseif soundcue  == 1, sound = 'CueSound';
    end;
    
    %Output as determined by whether soundcue needs to be turned off
	if soundcue == 0 && soundstim == 0;
        softpokeinput = {'pokeid', correct_poke, 'DOut', rew_dout, 'DOutStartTime', 0, 'DOutOnTime', rew_t, ...
            'DOut2', led_name, 'DOut2StartTime', 0, 'DOut2OnTime', sroverlap, 'ConstantDOut', ConstantDOut, ...
            'success_exitstate_name', 'warndanger', 'abort_exitstate_name', 'warndanger'};
    elseif ~(soundcue == 1 && soundstim ==1)
        softpokeinput = {'pokeid', correct_poke, 'DOut', rew_dout, 'DOutStartTime', 0, 'DOutOnTime', rew_t, ...
            'DOut2', led_name, 'DOut2StartTime', 0, 'DOut2OnTime', sroverlap, 'ConstantDOut', ConstantDOut, ...
            'Sound1TrigTime', ROverlap+0.01, 'Sound1Id', -SoundManagerSection(obj, 'get_sound_id', sound), ...
            'success_exitstate_name', 'warndanger', 'abort_exitstate_name', 'warndanger'};
    else
        softpokeinput = {'pokeid', correct_poke, 'DOut', rew_dout, 'DOutStartTime', 0, 'DOutOnTime', rew_t, ...
            'DOut2', led_name, 'DOut2StartTime', 0, 'DOut2OnTime', sroverlap, 'ConstantDOut', ConstantDOut, ...
            'Sound1TrigTime', ROverlap+0.01, 'Sound1Id', -SoundManagerSection(obj, 'get_sound_id', sound1), ...
            'Sound2TrigTime', ROverlap+0.02, 'Sound2Id', -SoundManagerSection(obj, 'get_sound_id', sound2), ...
            'success_exitstate_name', 'warndanger', 'abort_exitstate_name', 'warndanger'};
	end;

    
    
end