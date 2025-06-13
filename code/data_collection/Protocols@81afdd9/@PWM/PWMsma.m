%@PWM/PWMsma
% modified November 2018 by Emily, from AthenaSMA
% major overhaul February 2019 for automating
%
% [x, y] = StateMatrixSection(obj, action, x, y)
%
% HELP HERE
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%            'init'         To initialise the section
%
%            'next_trial'   To set up the state matrix for the next trial
%
%            'reinit'       Delete all of this section's GUIs and data,p[]
%                           and reinit, at the sameFakeShow position on the same
%                           figure as the original section GUI was placed.
%
% x, y     Relevant to action = 'init'; they indicate the initial
%          position to place the GUI at, in the current figure window
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
% [x, y]   When action == 'init', returns x and y, pixel positions on
%          the current figure, updated after placing of this section's GUI. 
%
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

function  [varargout] =  PWMsma(obj, action)

GetSoloFunctionArgs;

switch action
    
    %---------------------------------------------------------------%
    %          init                                                 %
    %---------------------------------------------------------------%
    case 'init'

        % ASKCHUCK - AFAIK this first non-trial isn't necessary so moved to Sound
        % Section BUT caused errors because sounds are made in prepare_next_trial
        % not init

        srate=SoundManagerSection(obj,'get_sample_rate');
        freq1=5;
        dur1=1.5*1000;
        Vol=1;
        tw=Vol*(MakeBupperSwoop(srate,0, freq1 , freq1 , dur1/2 , dur1/2,0,0.1));

        if SoundManagerSection(obj, 'sound_exists','RRewardSound') == 0
            SoundManagerSection(obj, 'declare_new_sound', 'RRewardSound', [zeros(1, length(tw));tw])
        end
        
        if SoundManagerSection(obj, 'sound_exists','LRewardSound') == 0
                    SoundManagerSection(obj, 'declare_new_sound', 'LRewardSound', [tw ; zeros(1, length(tw))])
        end
            
        SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');

        % feval(mfilename, obj, 'prepare_next_trial');
    
    %---------------------------------------------------------------%
    %          prepare_next_trial                                   %
    %---------------------------------------------------------------%
    case 'prepare_next_trial',
        
        % assemble structure so we can add stuff to it
        sma = StateMachineAssembler('full_trial_structure','use_happenings', 1);

        % Setup DIOLINES
        min_time= 2.5E-4;  % This is less than the minumum time allowed for a state transition.
                            % ASKCHUCK
        left1led           = bSettings('get', 'DIOLINES', 'left1led');
        center1led         = bSettings('get', 'DIOLINES', 'center1led');
        right1led          = bSettings('get', 'DIOLINES', 'right1led');
        left1water         = bSettings('get', 'DIOLINES', 'left1water');
        right1water        = bSettings('get', 'DIOLINES', 'right1water');
        stim               = bSettings('get', 'DIOLINES', 'LASER');
        mask               = bSettings('get', 'DIOLINES', 'MASK');
        trigscope = bSettings('get','DIOLINES','scope');
        
        % %for ephys syncing
        % start_stop  = bSettings('get', 'DIOLINES', 'start_stop');
        % trialnum_indicator  = bSettings('get', 'DIOLINES', 'trialnum_indicator');
        
        if isnan(stim), stim = 0; end
        if isnan(mask), mask = 0; end
        if isnan(trigscope), trigscope=0; end
                            

        %% Setup sounds
        SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');        
        AUD1_sound_id     = SoundManagerSection(obj, 'get_sound_id', 'StimAUD1');
        AUD2_sound_id     = SoundManagerSection(obj, 'get_sound_id', 'StimAUD2');
        % sone_sound_id     = SoundManagerSection(obj, 'get_sound_id', 'SOneSound');
        % stwo_sound_id     = SoundManagerSection(obj, 'get_sound_id', 'STwoSound');
        go_sound_id       = SoundManagerSection(obj, 'get_sound_id', 'GoSound');
        go_cue_duration   = SoundManagerSection(obj, 'get_sound_duration', 'GoSound');
        reward_sound_id = SoundManagerSection(obj, 'get_sound_id', 'RewardSound');
 
        err_sound_id      = SoundManagerSection(obj, 'get_sound_id', 'ErrorSound');
        viol_sound_id     = SoundManagerSection(obj, 'get_sound_id', 'ViolationSound');
        viol_snd_duration = SoundManagerSection(obj, 'get_sound_duration', 'ViolationSound');
        to_sound_id       = SoundManagerSection(obj, 'get_sound_id', 'TimeoutSound');
        timeout_duration  = SoundManagerSection(obj, 'get_sound_duration', 'TimeoutSound');


        %% set up water valves and timing       
        %         WaterAmount=maxasymp + (minasymp./(1+(n_done_trials/inflp).^slp).^assym);
        %         WaterValvesSection(obj, 'set_water_amounts', WaterAmount, WaterAmount);
        %         [LeftWValveTime RightWValveTime] = WaterValvesSection(obj, 'get_water_times');
        %       [LeftWMult RightWMult] = SideSection(obj, 'get_water_mult');
        %       LeftWValveTime=LeftWValveTime*LeftWMult;
        %       RightWValveTime=RightWValveTime*RightWMult;
        [LeftWValveTime,RightWValveTime] = WaterValvesSection(obj, 'get_water_times');

        
        %% set up correct responses and LED state       
        side = SideSection(obj, 'get_current_side');
        if side == 'l'
            HitEvent = 'Lin';
            ErrorEvent = 'Rin'; 
            HitState = 'lefthit';
            SecondHitState = 'secondlefthit';
            
            switch value(side_lights)
                case 'correct side',      LEDOn =1;SideLight = left1led;
                case 'both',              LEDOn =1;SideLight = left1led+right1led;
                case 'none',              LEDOn =0;SideLight = 0;
                case 'anti side',         LEDOn =1;SideLight = right1led;
            end
            switch value(ControlTask)
                case 'none',              ControlLight = 0;
                case 'light chasing',     ControlLight = left1led;
                case 'no 1st sound',      ControlLight = 0;
                case 'fixed 1st sound',   ControlLight = 0;
            end
            
        else %if RIGHT is correct%
            HitEvent = 'Rin';      
            ErrorEvent = 'Lin'; 
            HitState = 'righthit';
            SecondHitState = 'secondrighthit';
            switch value(side_lights)
                case 'correct side',     LEDOn =1;SideLight = right1led;
                case 'both',             LEDOn =1;SideLight = left1led+right1led;
                case 'none',             LEDOn =0;SideLight = 0;
                case 'anti side',        LEDOn =1;SideLight = left1led;
            end
            switch value(ControlTask)
                case 'none',              ControlLight = 0;
                case 'light chasing',     ControlLight = right1led;
                case 'no 1st sound',      ControlLight = 0;
                case 'fixed 1st sound',   ControlLight = 0;
            end
        end;
        
%% set up reward option dependencies on training stage
        if strcmp(reward_type, 'NoReward')
            % if in never, do not wait for a second hit
            AnyReward=0;
            wait_for_second_hit=0.0001;
        else %this is the DelayReward and Always cases
            AnyReward=1;
            % this is the amoutnt of time the animal has to enter
            % second_hit_state in seconds
            wait_for_second_hit=5;
        end;

%% make waves

        % add wave: after cpoke, wait until CP_duration elapses, play GO CUE
        sma = add_scheduled_wave(sma,   'name', 'center_poke',...
                                        'preamble', CP_duration, ...
                                        'sustain', 0.001);
        
        % add wave that defines the settling in period
        sma = add_scheduled_wave(sma,   'name', 'settling_period',...
                                        'preamble', SettlingIn_time);

        % make wave for control lights
        sma = add_scheduled_wave(sma,   'name', 'ControlLight',...
                                        'preamble', 0, ...
                                        'sustain', CP_duration,... 
                                        'DOut', ControlLight);
                                    
        % make waves for sounds
        sma = add_scheduled_wave(sma,   'name', 'stimAUD1',...
                                        'preamble', PreStim_time, ...
                                        'sustain', AUD1_length,... 
                                        'sound_trig', AUD1_sound_id);
            
        %second sound should start after the first sound and delay
        sma = add_scheduled_wave(sma,   'name', 'stimAUD2',...
                                        'preamble', PreStim_time+AUD1_time+Del_time, ...
                                        'sustain', AUD2_length,...
                                        'sound_trig', AUD2_sound_id);       

        % add wave for wide-field imaging
        if value(imaging)==1
            sma = add_scheduled_wave(sma,   'name', 'TrigScope',...
                                            'preamble', 0,...
                                            'sustain', 0.05,...
                                            'DOut', trigscope,...
                                            'loop', 0);
        else
            sma = add_scheduled_wave(sma,   'name', 'TrigScope',...
                                            'preamble', 0,...
                                            'sustain', 0); %dummy wave.
        end
        
% This is currently only used for stages 1-3 (learn light = go l/r)
        if side=='l',
            sma = add_scheduled_wave(sma,   'name', 'reward_delivery',...
                                            'preamble', reward_delay, ...
                                            'sustain', LeftWValveTime, ...
                                            'DOut', left1water);
            
        else
            sma = add_scheduled_wave(sma,   'name', 'reward_delivery',...
                                            'preamble', reward_delay, ...
                                            'sustain', RightWValveTime,...
                                            'DOut', right1water);
           
        end;

        % END stages 1-3
                
        %% FROM ADC END

        %% making states 

        % GOAL:
        % turn on center LED light and wait for cpoke
        % cpoke triggers delay
        %   if stages 1-2, add a tiny delay, light shows side NO NOISES
        %   if stage 3, add a tiny delay, light shows side ADD REWARD NOISES
        %   if stage 4, grow the delay, light shows side 
        %   if stage 5, use full structure while growing delay, light shows side
        %   if stage 6, use full structure, with variable delays, light shows side
        %   if stage 7-end, use full structure with variable delays
        % IF CONTROLS
        %       light chasing
        %       no first sound
        %       fixed first sound
        % if still cpoke after delay, play reward cue and wait for spoke
        %   implement rule and training stage: side LED should be on for stages 1-6
        % spoke triggers next trial, delay, water alone, water + reward sound
        % end of trial triggers next trial

        %% for stages 1-3, based on ProAnti3's version of 'classical'
        if strcmp(RewardFromPoke, 'spoke');

                
            sma = add_state(sma,    'name', 'wait_for_collecting_reward',...
                                    'output_actions', {'DOut', SideLight}, ...
                                    'input_to_statechange',{HitEvent,'hit_state'});
                
                
            if RewardSound==1;    % for stage 3, switching blocks + reward sound
                sma = add_state(sma,'name','hit_state',...
                                    'self_timer',0.001,...
                                    'output_actions', {'DOut', SideLight,...
                                                        'SchedWaveTrig','reward_delivery',...
                                                        'SoundOut',reward_sound_id},...
                                    'input_to_statechange',{'Tup','drink_state'});
            elseif RewardSound==0; % for stages 1-2, learning reward association.    
                sma = add_state(sma,'name','hit_state',...
                                    'self_timer',0.001,...
                                    'output_actions', {'DOut', SideLight,...
                                                        'SchedWaveTrig','reward_delivery'},...
                                                        'input_to_statechange',{'Tup','drink_state'});      
            end

        %% for stages 4+ (nose grow through psychometrics)
        elseif strcmp(RewardFromPoke, 'cpoke');
            sma = add_state(sma,'name','wait_for_cpoke',...
                'output_actions', {'SchedWaveTrig','+TrigScope'...
                                    'DOut', center1led}, ...
                'input_to_statechange', {'Cin','cp'});

            % center poke starts: trigger center_poke scheduled wave,
            % and when that ends go to side_led_on
            sma = add_state(sma,'name','cp','self_timer', SettlingIn_time+0.00001, ...
                'output_actions', {'SchedWaveTrig', 'center_poke + settling_period +stimAUD1+stimAUD2+ControlLight'}, ...
                'input_to_statechange',{'Tup', 'cp_legal_cbreak_period', ...
                                        'Cout','current_state+1', ...
                                        'center_poke_Out', 'wait_for_collecting_reward', ...
                                        'Rin',  'violation_cleanup_state', ...
                                        'Rout', 'violation_cleanup_state', ...
                                        'Lin', 'violation_cleanup_state', ...
                                        'Lout', 'violation_cleanup_state'});      
              
            % nose is out and we're in "SettlingIn_time"
            sma = add_state(sma, 'self_timer', settling_legal_cbreak+0.00001, ...
                'output_actions', {'DOut', center1led*LED_during_settling_legal_cbreak}, ...
                'input_to_statechange', {'Tup', 'violation_cleanup_state', ...
                                        'Cin', 'current_state+1', ...
                                        'settling_period_In', 'cp_legal_cbreak_period', ...
                                        'center_poke_Out', 'wait_for_collecting_reward', ...
                                        'Rin',  'violation_cleanup_state', ...
                                        'Rout', 'violation_cleanup_state', ...
                                        'Lin', 'violation_cleanup_state', ...
                                        'Lout', 'violation_cleanup_state'});
                
            % if animal re-center pokes during SettlingIn_time pretend
            % it didn't happen
            sma = add_state(sma, 'self_timer', 10000, ...
                'input_to_statechange', {'Cout', 'current_state-1', ...
                                        'settling_period_In','cp_legal_cbreak_period', ...
                                        'center_poke_Out', 'wait_for_collecting_reward', ...
                                        'Rin',  'violation_cleanup_state', ...
                                        'Rout', 'violation_cleanup_state', ...
                                        'Lin', 'violation_cleanup_state', ...
                                        'Lout', 'violation_cleanup_state'});
                    
            % after SettlingIn_time elapses Cout are treated given legal_cbreaks    
            sma = add_state(sma,'name','cp_legal_cbreak_period', 'self_timer', 10000, ...
                'input_to_statechange', {'Cout', 'current_state+1', ...
                    'Clo', 'current_state+1', ...
                    'center_poke_Out', 'wait_for_collecting_reward', ...
                    'Rin',  'violation_cleanup_state', ...
                    'Rout', 'violation_cleanup_state', ...
                    'Lin', 'violation_cleanup_state', ...
                    'Lout', 'violation_cleanup_state'});
                    
            % if legal_cbreak time elapses, go to violation_cleanup_state, 
            % if nose is put back in, go to copy of cp start & pretend
            % the Cout didn't happen
            sma = add_state(sma, 'self_timer', legal_cbreak+0.00001, ...
                'output_actions', {'DOut', center1led*LED_during_legal_cbreak}, ...
                'input_to_statechange', {'Tup', 'violation_cleanup_state', ...
                    'Cin', 'current_state+1', ...
                    'center_poke_Out', 'wait_for_collecting_reward', ...
                    'Rin',  'violation_cleanup_state', ...
                    'Rout', 'violation_cleanup_state', ...
                    'Lin', 'violation_cleanup_state', ...
                    'Lout', 'violation_cleanup_state'});
            
            % if the animal re-pokes during legal_break pretend it
            % didn't happen
            sma = add_state(sma, 'self_timer', 10000, ...
                'input_to_statechange', {'Cout', 'current_state-1', ...
                                        'center_poke_Out', 'wait_for_collecting_reward', ...
                                        'Rin',  'violation_cleanup_state', ...
                                        'Rout', 'violation_cleanup_state', ...
                                        'Lin', 'violation_cleanup_state', ...
                                        'Lout', 'violation_cleanup_state'});
        
            %wait_for_collecting_reward turns on the side light (if the settings say so)
            % for a predetermined amount of time (30000)
            %and waits for animal to side poke
            sma = add_state(sma, 'name', 'wait_for_collecting_reward', 'self_timer', 5000, ...
                'output_actions', {'DOut', LEDOn*SideLight,... 
                                   'SoundOut', go_sound_id}, ...
                'input_to_statechange',{HitEvent, HitState, ...
                                        ErrorEvent, 'second_hit_state', ...
                                        'Tup', 'second_hit_state'});
                
            if RewardSound == 0;
                % lefthit without reward sound
                sma = add_state(sma,'name', 'lefthit','self_timer', reward_delay, ...
                    'output_actions', {'DOut', LEDOn*SideLight}, ...                  
                    'input_to_statechange', {'Tup', 'current_state+1'});

                sma = add_state(sma, 'self_timer', LeftWValveTime, ...
                    'output_actions', {'DOut', SideLight+left1water,},...
                    'input_to_statechange',{'Tup','hit_state'});
                % RightHit without reward sound
                sma = add_state(sma,'name', 'righthit','self_timer', reward_delay, ...
                    'output_actions', {'DOut', LEDOn*SideLight}, ...                  
                    'input_to_statechange', {'Tup', 'current_state+1'});

                sma = add_state(sma, 'self_timer', RightWValveTime, ...
                    'output_actions', {'DOut', SideLight+right1water,},...
                    'input_to_statechange',{'Tup','hit_state'});

            elseif RewardSound==1;
                %LeftHit with reward sound
                sma = add_state(sma,...
                    'name', 'lefthit',...
                    'self_timer', reward_delay, ...
                    'output_actions', {'DOut', LEDOn*SideLight, ...
                                       'SoundOut', reward_sound_id}, ...                   
                    'input_to_statechange', {'Tup', 'current_state+1'});
                sma = add_state(sma, 'self_timer', LeftWValveTime, ...
                    'output_actions', {'DOut', SideLight+left1water,},...
                    'input_to_statechange',{'Tup','hit_state'});
                %RightHit with reward sound
                sma = add_state(sma,'name', 'righthit',...
                    'self_timer', reward_delay, ...
                    'output_actions', {'DOut', LEDOn*SideLight, 'SoundOut', reward_sound_id}, ...                    
                    'input_to_statechange', {'Tup', 'current_state+1'});
                sma = add_state(sma, 'self_timer', RightWValveTime, ...
                    'output_actions', {'DOut', SideLight+right1water,},...
                    'input_to_statechange',{'Tup','hit_state'});
            end
               
            if AnyReward == 0 %last training stages, in ADC called "Never"
                sma = add_state(sma,...
                    'name','second_hit_state',...
                    'self_timer', wait_for_second_hit,...
                    'output_actions',{'DOut', LEDOn*SideLight},...
                    'input_to_statechange',{'Tup', 'error_state'});
                
            elseif AnyReward ==1 % for ADC "Always" and "Delayed"
                                
                sma = add_state(sma,...
                    'name','second_hit_state',...
                    'self_timer', wait_for_second_hit,...
                    'output_actions',{'DOut', LEDOn*SideLight},...
                    'input_to_statechange',{HitEvent, SecondHitState,'Tup','error_state'});

            end
            if RewardSound ==1;
                % The two states that make a SecondLeftHit:
                % This first state makes it so that the sound plays at
                % begining of secondhitdelay and then the second state is
                % when the water is delivered

                sma = add_state(sma,'name', 'secondlefthit','self_timer', secondhit_delay, ...  
                    'output_actions', {'DOut', LEDOn*SideLight, 'SoundOut', reward_sound_id}, ...
                    'input_to_statechange', {'Tup', 'current_state+1'});
                
                sma = add_state(sma, 'self_timer', LeftWValveTime, ...
                    'output_actions', {'DOut', (SideLight+left1water)},...
                    'input_to_statechange',{'Tup','error_drink_state'});

                % The two states that make a SecondRightHit:
                sma = add_state(sma,'name', 'secondrighthit','self_timer', secondhit_delay, ...
                    'output_actions',   {'DOut', LEDOn*SideLight, 'SoundOut', reward_sound_id}, ...
                    'input_to_statechange', {'Tup', 'current_state+1'});    
             
                sma = add_state(sma, 'self_timer', RightWValveTime, ...
                    'output_actions', {'DOut', (SideLight+right1water)},...
                    'input_to_statechange',{'Tup','error_drink_state'});
                

            elseif RewardSound==0;
                sma = add_state(sma,'name', 'secondlefthit','self_timer', secondhit_delay, ...  
                    'input_to_statechange', {'Tup', 'current_state+1'});    
                sma = add_state(sma, 'self_timer', reward_delay, ...
                    'output_actions', {'DOut', LEDOn*SideLight}, ...  
                    'input_to_statechange', {'Tup', 'current_state+1'});
                sma = add_state(sma, 'self_timer', LeftWValveTime, ...
                    'output_actions', {'DOut', (SideLight+left1water)},...
                    'input_to_statechange',{'Tup','error_drink_state'});

                % The two states that make a SecondRightHit:
                sma = add_state(sma,'name', 'secondrighthit','self_timer', secondhit_delay, ... 
                    'input_to_statechange', {'Tup', 'current_state+1'});    
                sma = add_state(sma, 'self_timer', reward_delay, ...
                    'output_actions', {'DOut', LEDOn*SideLight, 'SoundOut'}, ...  
                    'input_to_statechange', {'Tup', 'current_state+1'});
                sma = add_state(sma, 'self_timer', RightWValveTime, ...
                    'output_actions', {'DOut', (SideLight+right1water)},...
                    'input_to_statechange',{'Tup','error_drink_state'});
            end
           
           % add an error_drink_state if the animal gets a second hit so
           % they have time to drink before moving into error_state and
           % won't pass through drink_state without a firsthit
           sma = add_state(sma,...
               'name', 'error_drink_state',...
               'self_timer', drink_time,...
               'input_to_statechange', {'Tup', 'error_state'});
           
           % add a common error_state we flick through (regardless if
           % animal gets second hit) & implment error penalty
           sma = add_state(sma,...
               'name', 'error_state',...
               'self_timer', error_iti,...
               'input_to_statechange', {'Tup', 'final_state'});
                
            % and a common hit_state that we flick through
            sma = add_state(sma,...
                'name', 'hit_state',...
                'self_timer', 0.0001,...
                'input_to_statechange', {'Tup', 'drink_state'});
                                
        end %end of if else for different training_stages
        
        % if the animal is drinking after a first hit, get the next trial ready
        sma = add_state(sma,'name','drink_state','self_timer',drink_time,...
            'input_to_statechange',{'Tup','preclean_up_state'});
        
        % trigger different violation sounds depending on if stimuli are on or off
        sma = add_state(sma,'name','violation_cleanup_state','self_timer',0.001,...
            'output_actions',{'SchedWaveTrig', '-center_poke-stimAUD1-stimAUD2', ...
                              'SoundOut',-AUD1_sound_id},...
            'input_to_statechange',{'Tup','current_state+1'});
        sma = add_state(sma,'self_timer',0.001,...
            'output_actions',{'SoundOut',-AUD2_sound_id},...
            'input_to_statechange',{'Tup','current_state+1'});
        sma = add_state(sma,'self_timer',0.001,...
            'output_actions',{'SoundOut',-go_sound_id},...
            'input_to_statechange',{'Tup','current_state+1'});
        sma = add_state(sma,'self_timer',0.001,...
            'output_actions',{'SoundOut',-reward_sound_id},...
            'input_to_statechange',{'Tup','current_state+1'});
        
        sma = add_state(sma,'name','violation_state','self_timer',viol_snd_duration,...
            'output_actions',{'SoundOut',viol_sound_id,...
                              'DOut', center1led},...
            'input_to_statechange', {'Tup', 'current_state+1'});

        %add a state for timing while drinking
        sma = add_state(sma, 'self_timer', max(0.001, violation_iti-viol_snd_duration), ...
            'input_to_statechange',{'Tup','preclean_up_state'});

        % removed a state to trigger scope while drinking
        sma = add_state(sma,'name','preclean_up_state','self_timer',0.001,...
            'input_to_statechange',{'Tup','final_state'});
                        
        %% set up laser waves
        % the stimulator channel to activate, if any
        if StimulatorSpecs.ison > 0, this_stim = stim(1);
        else                         this_stim = 0;
        end;
        laser_status = 'off';
        if StimulatorSpecs.ison > 0
            if StimulatorSpecs.freq == 0 || StimulatorSpecs.pulse == 0
                laser_status = 'digital_continuous';
            else
                laser_status = 'digital_pulsed';
            end
        end
    
        switch laser_status
            case 'digital_pulsed'
                sma = add_scheduled_wave(sma, 'name', 'laser_stim_on', ...
                                              'preamble', StimulatorSpecs.pre, ...
                                              'trigger_on_up', 'laser_stim_pulse');

                sma = add_scheduled_wave(sma, 'name', 'laser_stim_pulse', ...
                                              'preamble', (1/StimulatorSpecs.freq)-(StimulatorSpecs.pulse/1000), ...
                                              'sustain', StimulatorSpecs.pulse/1000, ...
                                              'loop', floor(StimulatorSpecs.dur * StimulatorSpecs.freq) - 1, ...
                                              'DOut', this_stim);
            otherwise
                % for historical reasons, we add a wave even if the laser is
                % off this trial
                sma = add_scheduled_wave(sma, 'name', 'laser_stim_on', ...
                                              'preamble', StimulatorSpecs.pre, ...
                                              'sustain', StimulatorSpecs.dur, ...
                                              'DOut', this_stim);
        end                             
    
        %added final_state hack to try to make Bpod happy -Chuck 2021-03-03
        sma = add_state(sma,'name','final_state','self_timer',0.01,...
                'input_to_statechange',{'Tup','check_next_trial_ready'});
        
        varargout{2} = {'wait_for_cpoke'};
        
        varargout{1} = sma;
        
        % Not all 'prepare_next_trial_states' are defined in all training
        % stages. So we send to dispatcher only those states that are
        % defined.
        state_names = get_labels(sma); state_names = state_names(:,1);
        prepare_next_trial_states = {'lefthit', 'righthit', 'hit_state','second_hit_state', 'error_state', 'violation_state'};
        


        dispatcher('send_assembler', sma, intersect(state_names, prepare_next_trial_states));


    %---------------------------------------------------------------%
    %          get_state_colors                                     %
    %---------------------------------------------------------------%
    case 'get_state_colors',

        varargout{1} = struct( ...
            'wait_for_cpoke',               [170  170 170]/255, ...     %light gray
            'cp',                           [1  168   87]/255, ...      %green
            'cp_legal_cbreak_period',       [131  188   79]/255, ...    %light green
            'sideled_on',                   [1   1  1], ...             %white
            'wait_for_collecting_reward',   [244    234 33]/255,...     %yellow
            'righthit',                     [217    111 39]/255, ...    %orange
            'lefthit',                      [233    160 36]/255, ...    %light orange
            'hit_state',                    [102    187 218]/255, ...   %blue
            'second_hit_state',             [137    209 227]/255, ...   %light blue
            'drink_state',                  [55 66  134]/255,    ...    %indigo
            'error_state',                  [188    36  51]/255, ...    %red
            'violation_state',              [155    27  44]/255, ...    %dark red
            'secondlefthit',                [233 160 35]/255,    ...
            'secondrighthit',               [217 111 39]/255,    ...
            'violation_cleanup_state',      [111 111 111]/255,   ...
            'preclean_up_state',            [100 100 100]/255,   ...
            'final_state',                  [90 90 90]/255);
    

    %---------------------------------------------------------------%
    %          reinit                                                 %
    %---------------------------------------------------------------%
    case 'reinit',
        currfig = double(gcf);
        
        % Delete all SoloParamHandles who belong to this object and whose
        % fullname starts with the name of this mfile:
        delete_sphandle('owner', ['^@' class(obj) '$'], ...
            'fullname', ['^' mfilename]);
        
        % Reinitialise at the original GUI position and figure:
        feval(mfilename, obj, 'init');
        
        % Restore the current figure:
        figure(currfig);
        

    %---------------------------------------------------------------%
    %          otherwise                                            %
    %---------------------------------------------------------------%
    otherwise
        warning('do not know how to do %s',action);

end

