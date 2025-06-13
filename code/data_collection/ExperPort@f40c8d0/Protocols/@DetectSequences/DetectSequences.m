% This protocol should work as an example on how to start writing protocols.
%
% You first need to start dispatcher:
% >> flush; newstartup; dispatcher('init')
% And run the protocol, either from the menu or with:
% >> dispatcher('close_protocol'); dispatcher('set_protocol','saja_simplest');


function [obj] = DM2S(varargin)

% Default object is of our own class (mfilename);
% We inherit from Plugins/@pluginname

obj = class(struct, mfilename, saveload, water, soundmanager);

%---------------------------------------------------------------
%   BEGIN SECTION COMMON TO ALL PROTOCOLS, DO NOT MODIFY
%---------------------------------------------------------------

% If creating an empty object, return without further ado:
if nargin==0 || (nargin==1 && ischar(varargin{1}) && strcmp(varargin{1}, 'empty')), 
   return; 
end;

if isa(varargin{1}, mfilename), % If first arg is an object of this class itself, we are 
                                % Most likely responding to a callback from  
                                % a SoloParamHandle defined in this mfile.
  if length(varargin) < 2 || ~isstr(varargin{2}), 
    error(['If called with a "%s" object as first arg, a second arg, a ' ...
      'string specifying the action, is required\n']);
  else action = varargin{2}; varargin = varargin(3:end);
  end;
else % Ok, regular call with first param being the action string.
       action = varargin{1}; varargin = varargin(2:end);
end;
if ~isstr(action), error('The action parameter must be a string'); end;

GetSoloFunctionArgs(obj);


%---------------------------------------------------------------
%   END OF SECTION COMMON TO ALL PROTOCOLS, MODIFY AFTER THIS LINE
%---------------------------------------------------------------

% ---- From here on is where you can put the code you like.
%
% Your protocol will be called, at the appropriate times, with the
% following possible actions:
%
%   'init'     To initialize -- make figure windows, variables, etc.
%
%   'update'   Called periodically within a trial
%
%   'prepare_next_trial'  Called when a trial has ended and your protocol
%              is expected to produce the StateMachine diagram for the next
%              trial; i.e., somewhere in your protocol's response to this
%              call, it should call "dispatcher('send_assembler', sma,
%              prepare_next_trial_set);" where sma is the
%              StateMachineAssembler object that you have prepared and
%              prepare_next_trial_set is either a single string or a cell
%              with elements that are all strings. These strings should
%              correspond to names of states in sma.
%                 Note that after the 'prepare_next_trial' call, further
%              events may still occur in the RTLSM while your protocol is thinking,
%              before the new StateMachine diagram gets sent. These events
%              will be available to you when 'trial_completed' is called on your
%              protocol (see below).
%
%   'trial_completed'   Called when 'state_0' is reached in the RTLSM,
%              marking final completion of a trial (and the start of 
%              the next).
%
%   'close'    Called when the protocol is to be closed.
%
%
% VARIABLES THAT DISPATCHER WILL ALWAYS INSTANTIATE FOR YOU IN YOUR 
% PROTOCOL:
%
% (These variables will be instantiated as regular Matlab variables, 
% not SoloParamHandles. For any method in your protocol (i.e., an m-file
% within the @your_protocol directory) that takes "obj" as its first argument,
% calling "GetSoloFunctionArgs(obj)" will instantiate all the variables below.)
%
%
% n_done_trials     How many trials have been finished; when a trial reaches
%                   one of the prepare_next_trial states for the first
%                   time, this variable is incremented by 1.
%
% n_started trials  How many trials have been started. This variable gets
%                   incremented by 1 every time the state machine goes
%                   through state 0.
%
% parsed_events     The result of running disassemble.m, with the
%                   parsed_structure flag set to 1, on all events from the
%                   start of the current trial to now.
%
% latest_events     The result of running disassemble.m, with the
%                   parsed_structure flag set to 1, on all new events from
%                   the last time 'update' was called to now.
%
% raw_events        All the events obtained in the current trial, not parsed
%                   or disassembled, but raw as gotten from the State
%                   Machine object.
%
% current_assembler The StateMachineAssembler object that was used to
%                   generate the State Machine diagram in effect in the
%                   current trial.
%
% Trial-by-trial history of parsed_events, raw_events, and
% current_assembler, are automatically stored for you in your protocol by
% dispatcher.m. See the wiki documentation for information on how to access
% those histories from within your protocol and for information.

switch action,

  %---------------------------------------------------------------
  %          CASE INIT
  %---------------------------------------------------------------
  
  case 'init'

    % Make default figure. We remember to make it non-saveable; on next run
    % the handle to this figure might be different, and we don't want to
    % overwrite it when someone does load_data and some old value of the
    % fig handle was stored as SoloParamHandle "myfig"
    SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = figure;

    % Make the title of the figure be the protocol name, and if someone tries
    % to close this figure, call dispatcher's close_protocol function, so it'll know
    % to take it off the list of open protocols.
    name = mfilename;
    set(value(myfig), 'Name', name, 'Tag', name, ...
      'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');

    % At this point we have one SoloParamHandle, myfig
    % Let's put the figure where we want it and give it a reasonable size:
    set(value(myfig), 'Position', [300   200   650   500]);
    
    MaxTrials = 1500;

    xpos = 5; ypos = 5; maxypos=5;            % Initial position on main GUI window


    % --------------  Initialize Save/Load and Water ----------------

    % From Plugins/@saveload:
    [xpos, ypos] = SavingSection(obj, 'init', xpos, ypos);
    SavingSection(obj,'set_autosave_frequency',10);
    
    % From Plugins/@water:
    [xpos, ypos] = WaterValvesSection(obj, 'init', xpos, ypos);
    
    xpos = 220;ypos = 5;
    




    NumeditParam(obj, 'Error_ITI', 10, xpos, ypos, 'TooltipString',...
    'Forced Delay Longest'); next_row(ypos,1.5);
    NumeditParam(obj, 'Impatient_ITI', 5, xpos, ypos, 'TooltipString',...
    'Forced Delay Longest'); next_row(ypos,1.5);
    NumeditParam(obj, 'TimeForResponse', 2, xpos, ypos, 'TooltipString',...
    'Forced Delay Longest'); next_row(ypos,1.5);
    NumeditParam(obj, 'DelayTillResponse', 1, xpos, ypos, 'TooltipString',...
    'Forced Delay Longest'); next_row(ypos,1.5);
    NumeditParam(obj, 'InterStimDelayHi', 3, xpos, ypos, 'TooltipString',...
    'Forced Delay Shortest'); next_row(ypos,1.5);
    NumeditParam(obj, 'InterStimDelayLo', 2, xpos, ypos, 'TooltipString',...
    'Forced Delay Longest'); next_row(ypos,1.5);
    NumeditParam(obj, 'Match_Probability', 0.5, xpos, ypos, 'TooltipString',...
    'Forced Delay Longest'); next_row(ypos,1.0);
    SubheaderParam(obj, 'title', 'Sequence Parameters', xpos, ypos);
    next_row(ypos, 1.5);
    
    
    
    
    xpos = 430;ypos = 5;
    
    NumeditParam(obj, 'SoundDuration', 0.5, xpos, ypos, 'TooltipString',...
    'Forced Delay Longest'); next_row(ypos,1.0);
    SubheaderParam(obj, 'title', 'Sound Parameters', xpos, ypos);
    next_row(ypos, 1.5);
    
    
    MenuParam(obj, 'Task_Phase', {'Lick4Sound', 'AllMatches', 'DetectSeq'}, 'DetectSeq', xpos, ypos); next_row(ypos);
    SubheaderParam(obj, 'title', 'Task Phase', xpos, ypos); next_row(ypos, 1.5);
    
        if  (strcmp(value(Task_Phase),'DetectSeq')) 
        
            Match_Probability.value = 0.5;
        else
            Match_Probability.value = 1;
        end
        
        
    
    SoloFunctionAddVars('StateMatrixSection', 'rw_args',...
                        {'InterStimDelayHi','InterStimDelayLo'...
                        'SoundDuration', 'TimeForResponse', 'DelayTillResponse', 'Impatient_ITI', 'Error_ITI', 'Task_Phase'});
                    

                    
    SoloParamHandle(obj, 'TrialTypeList', 'value', ceil(4.*rand(value(MaxTrials),1))); 
    
    SoloParamHandle(obj, 'First_Sound', 'value', 'Sound_A');
    
    SoloParamHandle(obj, 'Second_Sound', 'value', 'Sound_B');
    
    SoloParamHandle(obj, 'Match_Action1', 'value', 'iti');
    
    SoloParamHandle(obj, 'Match_Action2', 'value', 'iti');
    
    SoloParamHandle(obj, 'HitHistory','value', nan(value(MaxTrials),1));
    

    
    
        %         Initialize Trial Outcome Plot

    SoloParamHandle(obj, 'RewardSideList','value', nan(value(MaxTrials),1));

    
    RewardSideList.labels.poke  = 1;
    RewardSideList.labels.nopoke = 2;
    RewardSideList.values = nan(value(MaxTrials),1);
    
    
    %  --- Make Trial Type List ---
     
    Matches =  ceil(3.*rand(value(MaxTrials),1)); 
    Mismatches = ceil(3.*rand(value(MaxTrials),1)); 
    for x = 1:MaxTrials
    Mismatches(x) = Mismatches(x) + 3;
    end
    for x = 1:MaxTrials
    if rand < value(Match_Probability)
        TrialTypeList(x) = Matches(x);
        RewardSideList.values(x) = 'm';
    else
        TrialTypeList(x) = Mismatches(x);
        RewardSideList.values(x) = 'x';
    end
    end
    
  
    
    SoloFunctionAddVars('SidesPlotSection', 'rw_args',...
                        {'TrialTypeList', 'RewardSideList', 'Match_Probability', 'HitHistory', 'Task_Phase'});
    
    
    [xpos, ypos] = SidesPlotSection(obj, 'init', xpos, ypos, ...
                                    TrialTypeList);
    next_row(ypos);
    
    
    set_callback(Task_Phase, {'SidesPlotSection', 'update_changed_settings'});                
                    
    
    % --- Define sounds ---
    SoundManagerSection(obj, 'init');
    SoundManagerSection(obj, 'declare_new_sound', 'Sound_A', [0]);
    SoundManagerSection(obj, 'declare_new_sound', 'Sound_B', [0]);  
    SoundManagerSection(obj, 'declare_new_sound', 'Sound_C', [0]);  
    SoundManagerSection(obj, 'declare_new_sound', 'error_sound',  [0]);
    
    sf = SoundManagerSection(obj, 'get_sample_rate');

    
        %Temporary Sound Data Override



%     ------Sound 1------- 


cf = 			3000.000;                  % carrier frequency (Hz)
%sf = 200000;                 % sample frequency (Hz)
d = value(SoundDuration);                    % duration (s)
n = sf * d;                 % number of samples
s = (0:n) / sf;             % sound data preparation
s = .02*sin(2 * pi * cf * s);   % sinusoidal modulation

cff = 			3100.000;                  % carrier frequency (Hz)
dd = value(SoundDuration);                     % duration (s)
ss = (0:n) / sf;             % sound data preparation
ss = .02*sin(2 * pi * cff * ss);   % sinusoidal modulation


cfff = 			2900.000;                  % carrier frequency (Hz)
ddd = value(SoundDuration);                     % duration (s)
sss = (0:n) / sf;             % sound data preparation
sss = .02*sin(2 * pi * cfff * sss);   % sinusoidal modulation

cffff = 			3200.000;                  % carrier frequency (Hz)
dddd = value(SoundDuration);                     % duration (s)
ssss = (0:n) / sf;             % sound data preparation
ssss = .02*sin(2 * pi * cffff * ssss);   % sinusoidal modulation


cfffff = 			2800.000;                  % carrier frequency (Hz)
ddddd = value(SoundDuration);                     % duration (s)
sssss = (0:n) / sf;             % sound data preparation
sssss = .02*sin(2 * pi * cfffff * sssss);   % sinusoidal modulation
% 
% for x = 1:n
%     FirstSound(x) = s(x) + ss(x) + sss(x) + ssss(x) + sssss(x);  
% end
Sound_A = s + ss + sss + ssss + sssss;


%     ------Sound 2------- 


%sf = 41500;                 % sample frequency (Hz)
d = value(SoundDuration);                     % duration (s)
n = sf * d;                 % number of samples
s = (0:n) / sf;             % sound data preparation

for x = 1:n
s(x) =  2.2*rand;   % random noise
end


% Band Pass Filter
n=2;      % 2nd order butterworth filter
fnq=1/(2*(1/sf));  % Nyquist frequency
Wn=[2800/fnq 3200/fnq];    % butterworth bandpass non-dimensional frequency
[b,a]=butter(n,Wn); % construct the filter
Sound_B = filtfilt(b,a,s); % zero phase filter the data
    

% %     ------Sound 3------- 
% 
% % This makes a phase-modulated warble in the same frequency space
% %sf = 41500;                 % sample frequency (Hz)
% d = value(SoundDuration);                     % duration (s)
% n = sf * d;                 % number of samples
% TimeVec = (0:n) / sf;             % sound data preparation
% % TimeVec = (0:1/sf:d)';
% SoundModulatory = 15 *...
% sin(2*pi*30*TimeVec);
% Waveform = .2*sin(2*pi*3000*TimeVec + SoundModulatory);
% 
% % Band Pass Filter
% n=2;      % 2nd order butterworth filter
% fnq=1/(2*(1/41500));  % Nyquist frequency
% Wn=[2800/fnq 3200/fnq];    % butterworth bandpass non-dimensional frequency
% [b,a]=butter(n,Wn); % construct the filter
% Sound_C = filtfilt(b,a,Waveform); % zero phase filter the data

%  ----Temporary Sound 3 for Dev -----


%sf = 41500;                 % sample frequency (Hz)
d = value(SoundDuration);                     % duration (s)
n = sf * d;                 % number of samples
s = (0:n) / sf;             % sound data preparation
%s = .02*sin(2 * pi * cf * s);   % sinusoidal modulation



SoundModulatory = 5 *...
sin(2*pi*30*s);
s = .1*sin(2*pi*3000*s + SoundModulatory);



% Band Pass Filter
n=2;      % 2nd order butterworth filter
fnq=1/(2*(1/sf));  % Nyquist frequency
Wn=[2800/fnq 3200/fnq];    % butterworth bandpass non-dimensional frequency
[b,a]=butter(n,Wn); % construct the filter
Sound_C = filtfilt(b,a,s); % zero phase filter the data



%     ------Error Sound------- 


error_sound = 0.1*(rand(1, 200000)-0.5);

    

    
    SoundManagerSection(obj, 'set_sound', 'Sound_A', Sound_A);
    SoundManagerSection(obj, 'set_sound', 'Sound_B', Sound_B);
    SoundManagerSection(obj, 'set_sound', 'Sound_C', Sound_C);
    SoundManagerSection(obj, 'set_sound', 'error_sound', error_sound);
    SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');

    % ----------------------  Prepare first (empty) trial ---------------------
    sma = StateMachineAssembler('full_trial_structure');
    sma = add_state(sma, 'name', 'final_state', ...
      'self_timer', 2, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
    dispatcher('send_assembler', sma, 'check_next_trial_ready');
     
    
  %---------------------------------------------------------------
  %          CASE PREPARE_NEXT_TRIAL
  %---------------------------------------------------------------
  case 'prepare_next_trial'
      
      

    my_parsed_events = disassemble(current_assembler, raw_events, 'parsed_structure', 1);

    if(n_done_trials>1)
        if(~isempty(my_parsed_events.states.reward))
            HitHistory(n_done_trials) = 1;   % Correct Lick
        elseif(~isempty(my_parsed_events.states.punishment_iti)) 
            HitHistory(n_done_trials) = 0;   % Incorrect Lick
        elseif(~isempty(my_parsed_events.states.iti)) 
            HitHistory(n_done_trials) = -1;   % Correct No-Lick 
        elseif(~isempty(my_parsed_events.states.mismatch_iti)) 
            HitHistory(n_done_trials) = 2;   % Mismatch iti 
        else
            HitHistory(n_done_trials) = -1;   % Otherwise
        end        
    end
      
    
    
    
    SidesPlotSection(obj, 'update', n_done_trials + 1, ...
                     TrialTypeList,...
                     HitHistory);
      
   if(n_done_trials>1)

         switch TrialTypeList(n_done_trials + 1)
     
         case 1
             First_Sound.value = 'Sound_A';
             Second_Sound.value = 'Sound_B';
             Match_Action1.value = 'reward';
             Match_Action2.value = 'iti'; 
         case 2

             First_Sound.value = 'Sound_B';
             Second_Sound.value = 'Sound_C';
             Match_Action1.value = 'reward';
             Match_Action2.value = 'iti'; 
             
         case 3
             First_Sound.value = 'Sound_C';
             Second_Sound.value = 'Sound_A';
             Match_Action1.value = 'reward';
             Match_Action2.value = 'iti'; 

             
         case 4
             
             First_Sound.value = 'Sound_A';
             Second_Sound.value = 'Sound_C';
             Match_Action1.value = 'punishment_iti';
             Match_Action2.value = 'mismatch_iti'; 
         
         case 5
             
             First_Sound.value = 'Sound_C';
             Second_Sound.value = 'Sound_B';
             Match_Action1.value = 'punishment_iti';
             Match_Action2.value = 'mismatch_iti'; 
         
         case 6
             
             First_Sound.value = 'Sound_B';
             Second_Sound.value = 'Sound_A';
             Match_Action1.value = 'punishment_iti';
             Match_Action2.value = 'mismatch_iti'; 
         end

   end
      
          SoloFunctionAddVars('StateMatrixSection', 'rw_args',...
                        {'First_Sound','Second_Sound'...
                        'Match_Action1', 'Match_Action2'});
                    
                    
    
    % -- Create and send state matrix for next trial (includes generating sounds) --
    StateMatrixSection(obj,'update');
    
    
  %---------------------------------------------------------------
  %          CASE TRIAL_COMPLETED
  %---------------------------------------------------------------
  case 'trial_completed'
    
    SavingSection(obj,'autosave_data');
    
  %---------------------------------------------------------------
  %          CASE UPDATE
  %---------------------------------------------------------------
  case 'update'
    
    
  %---------------------------------------------------------------
  %          CASE CLOSE
  %---------------------------------------------------------------
  case 'close'
    if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)),
      delete(value(myfig));
    end;
    delete_sphandle('owner', ['^@' class(obj) '$']);
    
  otherwise,
    warning('Unknown action! "%s"\n', action);
end

return

    
