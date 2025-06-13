function [obj] = headfixeddiscCMC(varargin)

% Default object is of our own class (mfilename); in this simplest of
% protocols, we inherit only from Plugins/@pokesplot

% obj = class(struct, mfilename, pokesplot2, saveload, sessionmodel, ...
%     soundmanager, soundui, HFwateradaptor, water, distribui, comments, sqlsummary);
obj = class(struct, mfilename, pokesplot2, saveload, sessionmodel, ...
    soundmanager, soundui, water, distribui, comments, sqlsummary, AdLibGUI);

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
    if length(varargin) < 2 || ~ischar(varargin{2}),
        error(['If called with a "%s" object as first arg, a second arg, a ' ...
            'string specifying the action, is required\n']);
    else action = varargin{2}; varargin = varargin(3:end); %#ok<NASGU>
    end;
else % Ok, regular call with first param being the action string.
    action = varargin{1}; varargin = varargin(2:end); %#ok<NASGU>
end;
if ~ischar(action), error('The action parameter must be a string'); end;

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
%


switch action,
    
    %---------------------------------------------------------------
    %         CASE INIT
    %---------------------------------------------------------------
    % init
    case 'init'
        
        hackvar = 10; SoloFunctionAddVars('SessionModel', 'ro_args', 'hackvar'); %#ok<NASGU>
        
        SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = double(figure);
        
        % Make the title of the figure be the protocol name, and if someone tries
        % to close this figure, call dispatcher's close_protocol function, so it'll know
        % to take it off the list of open protocols.
        name = mfilename;
        set(value(myfig), 'Name', name, 'Tag', name, ...
            'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
        
        
        
        % At this point we have one SoloParamHandle, myfig
        % Let's put the figure where we want it and give it a reasonable size:
        set(value(myfig), 'Position', [485   144   850   550]);
        
        % ----------
        
        SoloParamHandle(obj, 'nsessions_healthy_number_of_pokes', 'value', 0, 'save_with_settings', 1);
        SoloParamHandle(obj, 'post_classical_protocol', 'value', '', 'save_with_settings', 1);
        SoloParamHandle(obj, 'post_classical_settings_filename', 'value', '', 'save_with_settings', 1);
        SoloParamHandle(obj, 'hit_history', 'value', []);
        SoloParamHandle(obj, 'violation_history', 'value', []);
        SoloParamHandle(obj, 'thisside', 'value', []);
        SoloParamHandle(obj, 'thisdelay', 'value', []);
        SoloParamHandle(obj, 'previous_sides', 'value', []);
        SoloParamHandle(obj, 'RT_history', 'value', []);
        SoloParamHandle(obj, 'RandomizePressure', 'value', []);
        SoloParamHandle(obj, 'thispressure', 'value', []);
        SoloParamHandle(obj, 'ProbMaxPressure', 'value', []);
        SoloParamHandle(obj, 'ReleaseSwitch', 'value', []);
        %SoloParamHandle(obj, 'PSI_history', 'value', []);
        
        DeclareGlobals(obj, 'ro_args', {'hit_history','violation_history','previous_sides',...
            'thisside', 'thisdelay', 'RandomizePressure', 'thispressure', 'ProbMaxPressure',...
            'ReleaseSwitch'});
        
        
        SoundManagerSection(obj, 'init');
        
        x = 5; y = 5;             % Initial position on main GUI window
        
        [x, y] = SavingSection(obj,       'init', x, y);
        [x, y] = WaterValvesSection(obj,  'init', x, y);
        [x, y] = AdLibGUISection(obj, 'init', x, y);
        
        % For plotting with the pokesplot plugin, we need to tell it what
        % colors to plot with:
        my_state_colors =  struct( ...
            'OutofPoke',             [0  0   1]);
        %
        %     % In pokesplot, the poke colors have a default value, so we don't need
        %     % to specify them, but here they are so you know how to change them.
        my_poke_colors = struct( 'C',                      [0 0 1]);
        
        [x, y] = PokesPlotSection(obj,    'init', x, y, ...
            struct()); next_row(y);
        
        [x, y] = CommentsSection(obj, 'init', x, y); %#ok<NASGU>
        SessionDefinition(obj, 'init', x, y, value(myfig));
        % make the default be new style parsing:
        SessionDefinition(obj, 'set_old_style_parsing_flag', 0);
        next_column(x,1); y=5;
        
        DispParam(obj, 'thisside', 'left ', x, y, 'TooltipString','thisside');
        next_row(y, 1);
        DispParam(obj, 'trial', 0 , x, y, 'TooltipString','trial');
        next_row(y, 1);
        NumeditParam(obj, 'violationtimeout', 2, x, y, 'TooltipString', 'Violation Time Out');
        next_row(y, 1);
        NumeditParam(obj, 'LeftProb', 0.5, x, y, 'TooltipString', 'Probability that the Left side holds reward. SHOULD BE A NUMBER in [0, 1]');
        next_row(y, 1);
        NumeditParam(obj, 'maxpressure', .9, x, y, 'TooltipString', 'maxpressure');
        next_row(y, 1);
        DispParam(obj, 'thispressure', 0, x, y, 'TooltipString', 'thispressure');
        next_row(y, 1);
        NumeditParam(obj, 'ProbMaxPressure', 0.5, x, y, 'TooltipString', 'Prob Max Pressure');
        next_row(y, 1);
        NumeditParam(obj, 'RandomizePressure', 0, x, y, 'TooltipString', 'Randomize Pressure');
        next_row(y, 1);
%         NumeditParam(obj, 'PSI_Step', .0, x, y, 'TooltipString', 'PistonPressure; should be [0 90]');
%         next_row(y, 1);
        NumeditParam(obj, 'pressure', 0, x, y, 'TooltipString', 'PistonPressure; should be [0 90]');  %pisotns actuate beginning at about 20psi
        next_row(y, 1);
        NumeditParam(obj, 'DeployPistons', 0, x, y, 'TooltipString', 'Deploy Pistons');  
        next_row(y, 1);
        NumeditParam(obj, 'LegalCBreak', 0.05, x, y, 'TooltipString', 'Legal C Break');  %pistons actuate beginning at about 20psi
        next_row(y, 1);
        NumeditParam(obj, 'WaitStepSize', 0, x, y, 'TooltipString', 'Increase to FixationDuration on each completed trial');
        next_row(y,1);
        NumeditParam(obj, 'Warmuptrials', 15, x, y, 'TooltipString', 'Warm up trials');
        next_row(y,1);
        NumeditParam(obj, 'thisdelay', .30, x, y, 'TooltipString', 'thisdelay');
        next_row(y,1);
        NumeditParam(obj, 'FixationDuration', .60, x, y, 'TooltipString', 'Minimum time at center port');
        next_row(y,1);
        NumeditParam(obj, 'StepSize', 50, x, y, 'TooltipString', 'Increase to NosPos on each completed trial');
        next_row(y,1);
        NumeditParam(obj, 'NosPos', 0, x, y, 'TooltipString', 'Lick Tube Position')
        next_row(y,1);
        NumeditParam(obj, 'ReleaseSwitch', 0, x, y, 'TooltipString', 'Use Release Switch');
        next_row(y,1);
        NumeditParam(obj, 'microswitch_counter', 0, x, y, 'TooltipString', 'Microswitch Counter');
        next_row(y,1);
        NumeditParam(obj, 'Automate_Training', 1, x, y, 'TooltipString', 'Automate Training');
        next_row(y,1);
        
        %[x, y] = HFWaterAdaptorSection(obj, 'init', x, y);

        
        [x,y]=SoundInterface(obj,'add','NICSound',x,y,'Style','AMTone','Volume',0.004,'Duration',20);
        
        figpos = get(gcf, 'Position');
        [expmtr, rname]=SavingSection(obj, 'get_info');
        HeaderParam(obj, 'prot_title', [mfilename ': ' expmtr ', ' rname], ...
            x, y, 'position', [10 figpos(4)-25, 800 20]);
        
        SoundManagerSection(obj, 'declare_new_sound', 'Chirp', 0 );
        SoundManagerSection(obj, 'declare_new_sound', 'Chirp2', 0 );
        
 
        feval(mfilename, obj, 'prepare_next_trial');
        
        %---------------------------------------------------------------
        %          CASE PREPARE_NEXT_TRIAL
        %---------------------------------------------------------------
        % prepare_next_trial
    case 'prepare_next_trial'
        
        SessionDefinition(obj, 'next_trial');
        
        try send_n_done_trials(obj); 
        end
        
        % OUTPUT LINES
        C12                  = bSettings('get', 'DIOLINES', 'C12');             %Ch1 12V
        left1water           = bSettings('get', 'DIOLINES', 'left1water');      %Ch2 12V 
        right1water          = bSettings('get', 'DIOLINES', 'right1water');     %Ch3 12V
        center1led           = bSettings('get', 'DIOLINES', 'center1led');      %Ch1  5V 
        left1led             = bSettings('get', 'DIOLINES', 'left1led');        %Ch2  5V 
        right1led            = bSettings('get', 'DIOLINES', 'right1led');       %Ch3  5V 
        CW                   = bSettings('get', 'DIOLINES', 'A5');              %Ch4  5V
        B12                  = bSettings('get', 'DIOLINES', 'B12');             %Ch5 12V 
        CCW                  = bSettings('get', 'DIOLINES', 'B5');              %Ch5  5V 
        
        % INPUT LINES
        sma = StateMachineAssembler('full_trial_structure', 'use_happenings', 1,'n_input_lines', 6); %
        
        % REWARDS
        [LeftWValveTime RightWValveTime] = WaterValvesSection(obj, 'get_water_times');

        % SOUNDS
        Fs=SoundManagerSection(obj, 'get_sample_rate' ); sound_dur=0.2; sound_vol=0.005;
        SoundManagerSection(obj, 'set_sound', 'Chirp2', sound_vol*chirp(linspace(0,sound_dur,round(sound_dur*Fs)),8000,1,400) );
        SoundInterface(obj, 'set','NICSound','Duration',value(FixationDuration));
        InPokeSound=SoundManagerSection(obj, 'get_sound_id', 'NICSound');
        OutPokeSound=SoundManagerSection(obj, 'get_sound_id', 'Chirp2' );
        SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
        
        % SCHEDULED WAVES
        
        %----------------Behavior Commands--------------------------------------
        sma = add_scheduled_wave(sma, 'name', 'Cue',                'preamble',  0, 'sustain', value(thisdelay), 'sound_trig', value(InPokeSound));
        sma = add_scheduled_wave(sma, 'name', 'Cue2',               'preamble',  0, 'sustain', sound_dur, 'sound_trig', value(OutPokeSound));
        sma = add_scheduled_wave(sma, 'name', 'centerreward',       'preamble', value(thisdelay), 'sustain', 0.01,'DOut', C12);
        
        %----------------Stage Commands--------------------------------------
        sma = add_scheduled_wave(sma, 'name', 'forward',            'preamble', 0, 'sustain', .001,'DOut', CW, 'loop', -1 );
        %sma = add_scheduled_wave(sma, 'name', 'backward',           'preamble', 0, 'sustain', .001,'DOut', CCW, 'loop', 1);
        sma = add_scheduled_wave(sma, 'name', 'backward',           'preamble', 0, 'sustain', .001,'DOut', CCW, 'loop', value(NosPos));
        %sma = add_scheduled_wave(sma, 'name', 'step',               'preamble', 0, 'sustain', .001,'DOut', CCW, 'loop', 0);
        sma = add_scheduled_wave(sma, 'name', 'step',               'preamble', 0, 'sustain', .001,'DOut', CCW, 'loop', value(StepSize));
        
        %----------------Piston Commands--------------------------------------
        
        
       if value(thisdelay) > .6;
           early = [0:600];
           early = early.*(value(thispressure)/600);
           late = (value(thisdelay)-0.6)*1000;
           latewaveform=ones(1,late)*value(thispressure);
           waveform = [early, latewaveform];%1000 = 1sec on this rig
       else
           waveform = ones(1,value(thisdelay)*1000)*value(thispressure);
       end
        
       
        sma = add_scheduled_wave(sma, 'name', 'pistons','ao_line', 2, 'analog_waveform', waveform, 'loop', 0);
        
        % STATES
        
        %Initialization state for moving the center poke stage
        if n_done_trials==0
            sma = add_state(sma, 'name', 'MoveForward', ...
                'output_actions', {'SchedWaveTrig', '+forward'}, ...
                'input_to_statechange', {'Ahi', 'Stop'});
            
            sma = add_state(sma, 'name', 'Stop', 'self_timer', 0.001, ...
                'output_actions', {'SchedWaveTrig', '-forward'}, ...
                'input_to_statechange', {'Tup', 'MoveBack'});
            
            sma = add_state(sma, 'name', 'MoveBack', 'self_timer', value(NosPos)*0.002, ...
                'output_actions', {'SchedWaveTrig','+backward'}, ...
                'input_to_statechange', {'Tup', 'OutOfPoke'});
        end  %End of move stage, begining of behavioral trial
        
        sma = add_state(sma, 'name', 'OutOfPoke',...
            'input_to_statechange', {'Chi','InPoke',...
            'Dhi','InSlotOnly'});
        
        if value(DeployPistons)==1
            sma = add_state(sma, 'name', 'InPoke',...
                'output_actions', {'SchedWaveTrig', '+Cue+centerreward+pistons'}, ...
                'input_to_statechange', {'Clo','Pause',...
                'Dhi','InSlot',...
                'centerreward_Out','SideReward'});
        else
            sma = add_state(sma, 'name', 'InPoke',...
                'output_actions', {'SchedWaveTrig', '+Cue+centerreward'}, ...
                'input_to_statechange', {'Clo','Pause',...
                'Dhi','InSlot',...
                'centerreward_Out','SideReward'});
        end
        
        if value(ReleaseSwitch) == 0
            
            sma = add_state(sma, 'name', 'InSlotOnly',...
                'output_actions', {'SchedWaveTrig', '+Cue+centerreward+pistons'}, ...
                'input_to_statechange', {'Dlo','PrePause',...
                'centerreward_Out','SideRewardSlot'});
            
        elseif value(ReleaseSwitch)==1
            
            sma = add_state(sma, 'name', 'InSlotOnly',...
                'output_actions', {'SchedWaveTrig', '+Cue+centerreward+pistons'}, ...
                'input_to_statechange', {'Dlo','PrePause',...
                'centerreward_Out','SideRewardSlot', 'Ahi', 'Abort'});
        end
        
        sma = add_state(sma, 'name', 'InSlot',...
            'output_actions', {'SchedWaveTrig', '+pistons'}, ...
            'input_to_statechange', {'Clo','Pause',...
            'centerreward_Out','Retract_Pistons'});
        
        sma = add_state(sma, 'name', 'Retract_Pistons', 'self_timer', 0.001,...
            'output_actions', {'SchedWaveTrig', '-pistons'}, ...
            'input_to_statechange', {'Tup','SideRewardSlot'});
        
        sma = add_state(sma, 'name', 'PrePause', 'self_timer', value(LegalCBreak),...
            'input_to_statechange', {'Dhi', 'MonitorCpoke','Tup','Pause'});
        
        sma = add_state(sma, 'name', 'MonitorCpoke', 'self_timer', 10000,...
            'input_to_statechange', {'Dlo', 'PrePause','centerreward_Out', 'Retract_Pistons'});
        
        sma = add_state(sma, 'name', 'Pause', 'self_timer', 0.001,...
            'output_actions', {'SchedWaveTrig', '-Cue-centerreward-pistons'},...
            'input_to_statechange', {'Tup','Pause2'});
        
        sma = add_state(sma, 'name', 'Pause2', 'self_timer', value(violationtimeout),...
            'output_actions', {'SchedWaveTrig', '+Cue2'},...
            'input_to_statechange', {'Tup','nomove'});
        
        sma = add_state(sma, 'name', 'Abort', 'self_timer', 0.001, 'output_actions', ...
            {'SchedWaveTrig', '-Cue-centerreward-pistons'}, 'input_to_statechange', ...
            {'Tup', 'Abort2'});
        
        sma = add_state(sma, 'name', 'Abort2', 'self_timer', value(violationtimeout),...
            'output_actions', {'SchedWaveTrig', '+Cue2'}, 'input_to_statechange', ...
            {'Tup', 'nomove'});
        
        if rand(1) < value(LeftProb),
            sma = add_state(sma, 'name', 'SideRewardSlot', 'self_timer', 1000,...
                'output_actions', {'DOut', left1led}, ...
                'input_to_statechange', {'Tup','nomove',...
                'Lhi','LeftRewardSlot'});
            thisside.value = 'L';
        else
            sma = add_state(sma, 'name', 'SideRewardSlot', 'self_timer', 1000,...
                'output_actions', {'DOut', right1led}, ...
                'input_to_statechange', {'Tup','nomove',...
                'Rhi','RightRewardSlot'});
            thisside.value = 'R';
        end
        
        if rand(1) < value(LeftProb),
            sma = add_state(sma, 'name', 'SideReward', 'self_timer', 1000,...
                'output_actions', {'DOut', left1led}, ...
                'input_to_statechange', {'Tup','movestage',...
                'Lhi','LeftReward'});
            thisside.value = 'L';
        else
            sma = add_state(sma, 'name', 'SideReward', 'self_timer', 1000,...
                'output_actions', {'DOut', right1led}, ...
                'input_to_statechange', {'Tup','movestage',...
                'Rhi','RightReward'});
            thisside.value = 'R';
        end
        
        sma = add_state(sma, 'name', 'RightReward', 'self_timer', RightWValveTime, ...
            'output_actions', {'DOut', right1water}, ...
            'input_to_statechange', {'Tup', 'movestage'});
        
        sma = add_state(sma, 'name', 'LeftReward', 'self_timer', LeftWValveTime, ...
            'output_actions', {'DOut', left1water}, ...
            'input_to_statechange', {'Tup', 'movestage'});
        
        sma = add_state(sma, 'name', 'LeftRewardSlot', 'self_timer', LeftWValveTime, ...
            'output_actions', {'DOut', left1water},...
            'input_to_statechange', {'Tup', 'nomove'});
        
        sma = add_state(sma, 'name', 'RightRewardSlot', 'self_timer', RightWValveTime, ...
            'output_actions', {'DOut', right1water},...
            'input_to_statechange', {'Tup', 'nomove'});
        
        sma = add_state(sma, 'name', 'movestage', 'self_timer', value(StepSize)*.001, ...
            'input_to_statechange', {'Tup', 'check_next_trial_ready'}, ...
            'output_actions', {'SchedWaveTrig', '+step'});
        
        sma = add_state(sma, 'name', 'nomove', 'self_timer', 0.001, ...
            'input_to_statechange', {'Tup', 'check_next_trial_ready'});
        
        %%%%WORKING ON THIS
        state_names = get_labels(sma); state_names = state_names(:,1);
        prepare_next_trial_states = {'OutOfPoke', 'InPoke','InSlotOnly', 'InSlot',...
            'Retract_Pistons','Pause','Pause2','Abort', 'Abort2','SideRewardSlot','SideReward','RightReward',...
            'LeftReward','LeftRewardSlot','RightRewardSlot','movestage','nomove'};
        
        dispatcher('send_assembler', sma, intersect(state_names, prepare_next_trial_states));    
        
        if n_done_trials==1
            [expmtr, rname]=SavingSection(obj, 'get_info');
            prot_title.value=[mfilename ' on rig ' get_hostname ' : ' expmtr ', ' rname  '.  Started at ' datestr(now, 'HH:MM')];
        end
        
        
        %---------------------------------------------------------------
        %          CASE TRIAL_COMPLETED
        %---------------------------------------------------------------
        % trial_completed
    case 'trial_completed'
        % Do any updates in the protocol that need doing:
        feval(mfilename, 'update');
        
        % And PokesPlot needs completing the trial:
        PokesPlotSection(obj, 'trial_completed');
        
        if n_done_trials == 0,
            hit_history.value=0;
            violation_history.value=0;
            RT_history=0;
            previous_sides.value=0;
            trial.value = 0;
            %PSI_history.value=0;
        elseif n_done_trials > 0,  
            if ~isempty(parsed_events.states.siderewardslot)
                thishit=1;
                thisviolation=0;
                %FixationDuration.value=value(FixationDuration)+value(WaitStepSize);
            elseif ~isempty(parsed_events.states.sidereward)
                thishit=1;
                thisviolation=0;
                %FixationDuration.value=value(FixationDuration)+value(WaitStepSize);
            elseif ~isempty(parsed_events.states.pause2)
                thishit=NaN;
                thisviolation = 1;
            else
                thishit=0;
                thisviolation=0;
            end
            hit_history.value = [hit_history(:); thishit];
            violation_history.value = [violation_history(:); thisviolation];
            previous_sides.value = [previous_sides(:); value(thisside)];
            trial.value = n_done_trials;
            %PSI_history.value = [PSI_history(:); value(pressure)];
            if ~isempty(parsed_events.states.movestage)
                NosPos.value=value(NosPos)+value(StepSize);
            end
            if value(thisside)=='L';
                x = 'l';
            elseif value(thisside)=='R';
                x = 'r';
            end 
            y = thishit;
            %AdLibGUISection(obj, 'update_water_volume', x, y);
        end
        
        if n_done_trials < value(Warmuptrials)
            thisdelay.value = n_done_trials*(value(FixationDuration)/value(Warmuptrials));
        elseif n_done_trials == value(Warmuptrials)
            thisdelay.value = value(FixationDuration);
        elseif n_done_trials > value(Warmuptrials)
            if ~isempty(parsed_events.states.siderewardslot)
                thisdelay.value = value(FixationDuration) + value(WaitStepSize);
                FixationDuration.value = value(thisdelay);
            elseif ~isempty(parsed_events.states.sidereward)
                thisdelay.value = value(FixationDuration) + value(WaitStepSize);
                FixationDuration.value = value(thisdelay);
            end       
        end
        
        if n_done_trials==1,
            %HFWaterAdaptorSection(obj, 'set_first_trial_time_stamp');
            CommentsSection(obj, 'append_date');
            CommentsSection(obj, 'append_line', '');
            %AdLibGUISection(obj, 'set_first_trial_time_stamp');
        end;
        CommentsSection(obj, 'clear_history'); % Make sure we're not storing unnecessary history
        
%         if value(thisside) == 'L'
%             x = 'l';
%         elseif value(thisside) == 'R'
%             x = 'r';
%         end;
%         HFWaterAdaptorSection(obj, 'update_water_volume', x);
        
        if value(RandomizePressure)==1
            if n_done_trials <= 24
                thispressure.value = 0;
            elseif n_done_trials > 24 && n_done_trials <= 30
                thispressure.value = value(pressure);
            elseif n_done_trials > 30
                if rand(1) > value(ProbMaxPressure),
                    thispressure.value = value(pressure);
                else
                    thispressure.value = value(maxpressure);
                end
            end
        elseif value(RandomizePressure)==0
            thispressure.value = value(pressure);
        end
        
        
        if value(Automate_Training)==1
            if value(StepSize)>0
                if ~isempty(parsed_events.states.inslotonly)
                    microswitch_counter.value = value(microswitch_counter)+1;
                end
                if value(microswitch_counter)>20
                    StepSize.value = 0;
                    WaitStepSize.value = 0.001;
                end
            end
            if value(FixationDuration) > 1
                Warmuptrials.value = 20;
            end
            if value(FixationDuration) > 1.7 && value(FixationDuration) < 2.8
                WaitStepSize.value = 0.002;
            elseif value(FixationDuration) >= 2.8
                WaitStepSize.value = 0.003;
            end  
        end
        
        
        
        %end
        
        %---------------------------------------------------------------
        %          CASE UPDATE
        %---------------------------------------------------------------
    case 'update'
        PokesPlotSection(obj, 'update');
        
        %if hepoked
        %  PokesPlotSection(obj, 'trial_completed');
        %end
        
        %---------------------------------------------------------------
        %          CASE END_SESSION
        %---------------------------------------------------------------
    case 'end_session'
        prot_title.value = [value(prot_title) ', Ended at ' datestr(now, 'HH:MM')]; %#ok<NODEF>
        AdLibGUISection(obj, 'evaluate_outcome');
        %HFWaterAdaptorSection(obj, 'end_session_report');
        
        %---------------------------------------------------------------
        %          CASE PRE_SAVING_SETTINGS
        %---------------------------------------------------------------
    case 'pre_saving_settings'
        
        pd.hits=value(hit_history);
        nt=numel(pd.hits);
        pd.sides=value(previous_sides);
        pd.RT=value(RT_history);
        pd.violations=value(violation_history);
        %pd.PSI = value(PSI_history);

        dur=get_history(FixationDuration);
        pd.dur=cell2mat(dur(1:nt));
        
        PSI = get_history(thispressure);
        pd.PSI = cell2mat(PSI(1:nt));
        nospos=get_history(NosPos);
        pd.nospos=cell2mat(nospos(1:nt));
        
        sendsummary(obj,'sides',repmat('r',size(pd.hits)),'protocol_data',pd);
        
        
        %---------------------------------------------------------------
        %          CASE CLOSE
        %---------------------------------------------------------------
    case 'close'
        PokesPlotSection(obj, 'close');
        if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)), %#ok<NODEF>
            delete(value(myfig));
        end;
        delete_sphandle('owner', ['^@' class(obj) '$']);
        AdLibGUISection(obj, 'close');
       % HFWaterAdaptorSection(obj, 'close');
        
    otherwise,
        warning('Unknown action! "%s"\n', action); %#ok<WNTAG>
end;

return;

