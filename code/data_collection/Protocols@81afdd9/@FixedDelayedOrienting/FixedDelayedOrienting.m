function [obj] = FixedDelayedOrienting(varargin)

% Default object is of our own class (mfilename); in this simplest of
% protocols, we inherit only from Plugins/@pokesplot

obj = class(struct, mfilename, pokesplot2, saveload, sessionmodel, ...
    soundmanager, soundui, water, distribui, comments, sqlsummary);

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
        SoloParamHandle(obj, 'previous_sides', 'value', []);
        SoloParamHandle(obj, 'RT_history', 'value', []);
        SoloParamHandle(obj, 'Delay_history', 'value', []);
        
        DeclareGlobals(obj, 'ro_args', {'hit_history','previous_sides'});
        
        
        SoundManagerSection(obj, 'init');
        
        x = 5; y = 5;             % Initial position on main GUI window
        
        [x, y] = SavingSection(obj,       'init', x, y);
        [x, y] = WaterValvesSection(obj,  'init', x, y);
        
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
        
        [x, y] = CommentsSection(obj, 'init', x, y);
        SessionDefinition(obj, 'init', x, y, value(myfig));
        % make the default be new style parsing:
        SessionDefinition(obj, 'set_old_style_parsing_flag', 0);
        next_column(x,1); y=5;
        
        NumeditParam(obj, 'delaymult', 0.2, x, y, 'TooltipString', 'Probability that the Left side holds reward. SHOULD BE A NUMBER in [0, 1]');
        next_row(y, 1);
        NumeditParam(obj, 'pressure', 0, x, y, 'TooltipString', 'PistonPressure; should be [0 90]');  %pisotns actuate beginning at about 20psi
        next_row(y, 1);
        NumeditParam(obj, 'prestim', 0.4, x, y, 'TooltipString', 'Increase to NosPos on each completed trial');
        next_row(y,1);
        NumeditParam(obj, 'NosPos', 5000, x, y, 'TooltipString', 'Lick Tube Position')
        next_row(y,2);
        
        [x,y]=SoundInterface(obj,'add','NICSound',x,y,'Style','AMTone','Volume',0.004,'Duration',20);
        [x,y]=SoundInterface(obj,'add','GoSound',x,y,'Style','Tone','Volume',0.001,'Freq',3000,'Duration',0.1);
        
        
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
        
        % OUTPUT LINES
        
        left1water           = bSettings('get', 'DIOLINES', 'left1water');      %Ch2 12V
        right1water          = bSettings('get', 'DIOLINES', 'right1water');     %Ch3 12V
        
        left1led             = bSettings('get', 'DIOLINES', 'left1led');        %Ch2  5V
        right1led            = bSettings('get', 'DIOLINES', 'right1led');       %Ch3  5V
        
        CW                   = bSettings('get', 'DIOLINES', 'A5');              %Ch4  5V
        CCW                  = bSettings('get', 'DIOLINES', 'B5');              %Ch5  5V
        
        % INPUT LINES
        sma = StateMachineAssembler('full_trial_structure', 'use_happenings', 1,'n_input_lines', 6); %
        
        % REWARDS
        [LeftWValveTime RightWValveTime] = WaterValvesSection(obj, 'get_water_times');
        
        % SOUNDS
        Fs=SoundManagerSection(obj, 'get_sample_rate' ); sound_dur=0.2; sound_vol=0.005;
        SoundManagerSection(obj, 'set_sound', 'Chirp2', sound_vol*chirp(linspace(0,sound_dur,round(sound_dur*Fs)),8000,1,400) );
        SoundInterface(obj, 'set','NICSound','Duration',2);
        InPokeSound=SoundManagerSection(obj, 'get_sound_id', 'NICSound');
        OutPokeSound=SoundManagerSection(obj, 'get_sound_id', 'Chirp2' );
        GoCueSound=SoundManagerSection(obj, 'get_sound_id', 'GoSound' );
        SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
        
        % SCHEDULED WAVES
        
        %----------------Auditory Stimuli--------------------------------------
        sma = add_scheduled_wave(sma, 'name', 'Cue',                'preamble',  0, 'sustain', 2, 'sound_trig', value(InPokeSound));
        sma = add_scheduled_wave(sma, 'name', 'Cue2',               'preamble',  0, 'sustain', sound_dur, 'sound_trig', value(OutPokeSound));
        sma = add_scheduled_wave(sma, 'name', 'GoCue',              'preamble',  0, 'sustain', .2, 'sound_trig', value(GoCueSound));
        
        %----------------Stage Commands--------------------------------------
        sma = add_scheduled_wave(sma, 'name', 'forward',            'preamble', 0, 'sustain', .001,'DOut', CW, 'loop', -1 );
        sma = add_scheduled_wave(sma, 'name', 'backward',           'preamble', 0, 'sustain', .001,'DOut', CCW, 'loop', Value(NosPos));
        
        %----------------Piston Commands--------------------------------------
        
        if n_done_trials<10
            waveform=ones(1,2*1000)*value(pressure)*n_done_trials/10; %1000 = 1sec on this rig
        else
            waveform=ones(1,2*1000)*value(pressure); %1000 = 1sec on this rig
        end
        
           if n_done_trials<50
            delaymult=n_done_trials/50; %1000 = 1sec on this rig
        else
            delaymult=1; %1000 = 1sec on this rig
        end
        
        
        if round(rand)>0.5
            LeftTrial=1;
        else
            LeftTrial=0;
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
            
            sma = add_state(sma, 'name', 'MoveBack', 'self_timer', Value(NosPos)*0.001, ...
                'output_actions', {'SchedWaveTrig','+backward'}, ...
                'input_to_statechange', {'Tup', 'OutOfPoke'});
        end
        
        %Behavioral trial states
        sma = add_state(sma, 'name', 'OutOfPoke',...
            'input_to_statechange', {'Dhi','InSlot'});
        
        sma = add_state(sma, 'name', 'InSlot','self_timer',value(prestim),...
            'output_actions', {'SchedWaveTrig', '+Cue+pistons'}, ...
            'input_to_statechange', {'Dlo','ViolationState',...
            'Tup','current_state+1'});
        
        if LeftTrial==1
            sma = add_state(sma, 'name', 'LeftLED', 'self_timer',0.1, ...
                'output_actions', {'DOut', left1led}, ..., ...
                'input_to_statechange', {'Dlo','ViolationState',...
                'Tup','Delay'});
        else
            sma = add_state(sma, 'name', 'RightLED', 'self_timer',0.1, ...
                'output_actions', {'DOut', right1led}, ..., ...
                'input_to_statechange', {'Dlo','ViolationState',...
                'Tup','Delay'});
        end
        
        sma = add_state(sma, 'name', 'Delay', 'self_timer',(0.4+rand*0.2)*delaymult, ...
            'input_to_statechange', {'Dlo','ViolationState',...
            'Tup','Retract_Pistons'});
        
        sma = add_state(sma, 'name', 'Retract_Pistons', 'self_timer', 0.001,...
            'output_actions', {'SchedWaveTrig', '-pistons-Cue'}, ...
            'input_to_statechange', {'Tup','current_state+1'});
        
        sma = add_state(sma, 'name', 'Go', 'self_timer', 0.001,...
            'output_actions', {'SchedWaveTrig', '+GoCue'}, ...
            'input_to_statechange', {'Tup','current_state+1'});
        
        if LeftTrial==1
            sma = add_state(sma, 'name', 'LeftChoice', 'self_timer', 25,...
                'input_to_statechange', {'Lhi','Lt',...
                'Rhi','Error',...
                'Tup','TimeOut'});
        else
            sma = add_state(sma, 'name', 'RightChoice', 'self_timer', 25,...
                'input_to_statechange', {'Lhi','Error',...
                'Rhi','Rt',...
                'Tup','TimeOut'});
        end
        
          sma = add_state(sma, 'name', 'Rt', 'self_timer', 0.001, ...
            'output_actions', {'SchedWaveTrig', '+GoCue'}, ...
            'input_to_statechange', {'Tup', 'RightReward'});
        
           sma = add_state(sma, 'name', 'Lt', 'self_timer', 0.001, ...
            'output_actions', {'SchedWaveTrig', '+GoCue'}, ...
            'input_to_statechange', {'Tup', 'LeftReward'});
        
        
        sma = add_state(sma, 'name', 'RightReward', 'self_timer', RightWValveTime, ...
            'output_actions', {'DOut', right1water+right1led}, ...
            'input_to_statechange', {'Tup', 'iti'});
        
        sma = add_state(sma, 'name', 'LeftReward', 'self_timer', LeftWValveTime, ...
            'output_actions', {'DOut', left1water+left1led}, ...
            'input_to_statechange', {'Tup', 'iti'});
        
        sma = add_state(sma, 'name', 'Error', 'self_timer', 3.5, ...
            'output_actions', {'SchedWaveTrig', 'Cue2'}, ...
            'input_to_statechange', {'Tup', 'iti'});
        
        sma = add_state(sma, 'name', 'ViolationState', 'self_timer', 0.001, ...
            'output_actions', {'SchedWaveTrig', '-Cue-pistons'}, ...
            'input_to_statechange', {'Tup', 'current_state+1'});
        
        sma = add_state(sma, 'name', 'pause', 'self_timer', 0.001, ...
            'output_actions', {'SchedWaveTrig', 'Cue2'}, ...
            'input_to_statechange', {'Tup', 'iti'});
        
        sma = add_state(sma, 'name', 'TimeOut', 'self_timer', .1, ...
            'input_to_statechange', {'Tup', 'iti'});
        
        sma = add_state(sma, 'name', 'iti', 'self_timer', 0.5, ...
            'input_to_statechange', {'Tup', 'check_next_trial_ready'});
        
        dispatcher('send_assembler', sma, {'iti'});
        
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
            RT_history.value=0;
            Delay_history.value=0;
            previous_sides.value=0;
            
        elseif n_done_trials > 0
            
            %Calculate Delay Time
            if ~isempty(parsed_events.states.delay)
                thisDelay=parsed_events.states.delay(2)-parsed_events.states.delay(1);
            else
                thisDelay=NaN;
            end
            
            %Calculate Reaction Time
            %             if ~isempty(parsed_events.states.leftchoice)
            %                 thisRT=parsed_events.states.leftchoice(2)-parsed_events.states.leftchoice(1);
            %             elseif ~isempty(parsed_events.states.rightchoice)
            %                 thisRT=parsed_events.states.rightchoice(2)-parsed_events.states.rightchoice(1);
            %             else
            %                 thisRT=NaN;
            %             end
            
            %Calculate Hits & Increase Delay
            if ~isempty(parsed_events.states.leftreward) || ~isempty(parsed_events.states.rightreward)
                thishit=1;
                delaymult.value=value(delaymult)+0.001;
                if value(prestim)<0.6
                    prestim.value=value(prestim)+0.001;
                end
            elseif ~isempty(parsed_events.states.error)
                thishit=0;
                delaymult.value=value(delaymult)+0.001;
            else
                thishit=NaN;
            end
            
            %Calculate Sides
            if isfield(parsed_events.states,'leftled')
                thisside='l';
            elseif isfield(parsed_events.states,'rightled')
                thisside='r';
            end
            
            previous_sides.value=[previous_sides(:); thisside];
            hit_history.value = [hit_history(:); thishit];
            RT_history.value = [hit_history(:); NaN];
            Delay_history.value=[Delay_history(:); thisDelay];
        end
        
        if n_done_trials==1,
            CommentsSection(obj, 'append_date');
            CommentsSection(obj, 'append_line', '');
        end;
        CommentsSection(obj, 'clear_history'); % Make sure we're not storing unnecessary history
        
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
        
        
        %---------------------------------------------------------------
        %          CASE PRE_SAVING_SETTINGS
        %---------------------------------------------------------------
    case 'pre_saving_settings'
        
        pd.hits=value(hit_history);
        pd.sides=value(previous_sides);
        pd.RT=value(RT_history);
        pd.Delay=value(Delay_history);
        
        sendsummary(obj,'sides',pd.sides,'protocol_data',pd);
        
        
        %---------------------------------------------------------------
        %          CASE CLOSE
        %---------------------------------------------------------------
    case 'close'
        PokesPlotSection(obj, 'close');
        if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)), %#ok<NODEF>
            delete(value(myfig));
        end;
        delete_sphandle('owner', ['^@' class(obj) '$']);
        
    otherwise,
        warning('Unknown action! "%s"\n', action); %#ok<WNTAG>
end;

return;

