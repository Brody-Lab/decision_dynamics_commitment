%% TS_JB_r_classic_rule_experiments
% Training Section; Jess Breda; Rats ; Classic Rule Experiments
%
% This curriculum builds off of JB_r_classic and is specific to rule
% learning. It is assumed when an animal is swtiched to this curriculum
% that the following has happened
%
% 1. they are center poking with 2 discrete sounds play and fixation end
% triggered by a go cue
% 2. they are capable of an sb dependent rule indicating they can use the
% sounds (as of 2023-10-26, this may change)
%
% There are ~2.5 ideas. the first is similar to what worked with mouse
% cohort 1, the second is pro-anti inspired. The third is a potential blend
% between the two and likely wont be implemented initially.
%
% Initial ideas 
% 1. XOR progressive add in
% 11.1.1: add in 12-12 stim with give frac 1.0 for that stim
% 11.1.2 decrease give frac rate for that stim
% 11.1.3 add in the 12-3 stim with give frac 1.0
% 11.1.4 decrease give frac rate for that stim
% 
% 2. Pro-anti style (full set)
% 11.2.1 Add in other sb rule pair in blocks style (e.g. anti) with give on 100%. block logic is always starting w/ pro and then after minimum 30 trials and 70% threshold, swtich to anti
% 11.2.2 Reduce give frac on anti trials
% 11.2.3 randomly interleve
% 
% 3. Pro-anti style (1/2XOR)
% 11.3.1 add in the 1/2 XOR in blocks where 12-12 only gets give
% 11.3.2 remove the give
% 11.3.3 add in last pair? idk
function varargout = TS_JB_r_classic_rule_experiments(obj, action, varargin)


GetSoloFunctionArgs(obj);

switch action,

    %---------------------------------------------------------------%
    %          get_stage_list                                       %
    %---------------------------------------------------------------%
    % Called by `create_stage_list` in `TrainingSection.m and these values 
    % are used to create the stage name menu param in the GUI

    case 'get_stage_list'
        varargout{1} = {...
            '11.11: 1/2 XOR with specific give',...
            '11.12: 1/2 XOR decrease give',...
            '11.13: Full XOR with specific give',...
            '11.14: Full XOR decrease give',...
            '11.21: Add in anti',...
            '11.22: Decrease anti give',...
            '11.23: Interleve pro & anti',...
        };

    %---------------------------------------------------------------%
    %          get_update                                           %
    %---------------------------------------------------------------%

    % If this curriculum is selected, this is called during init and on
    % each trial to determine the settings for the given trial in Training
    % Section `get_curriculum_update`.

    % This is this case that is synonyms to a SessionDefinition. End of 
    % stage logic occurs within the case for the stage number, end of day 
    % logic occurs in the `get_eod_logic` case.
    
    case 'get_update'
        curriculum_stage_number = value(varargin{1});
        switch curriculum_stage_number
        
        case 1
            %%
            stage_description.value = 'add in 12-12';

            %%% init
            if value(n_trials_stage) == 0 % session init

                % Trial Structure- move to cpoke SMA 
                % and set stimulus to off because cpoke sma will send 
                % stimuli if on (spoke sma does not)
                SMA_set.value = 'cpoke';
                stimuli_on.value = 1;
                LeftProb.value = 0.5;

                if value(n_days_stage) <= 1 % stage init 
                    
                    % get correct stim pair
                    presets.value = 'Sb L to 1/2 XOR';
                    StimulusSection(obj, 'set_preset');
                    
                    % when give is on, make sure it's always given
                    give_frac.value = 1;
                    
                                
                    % set up distribui for exp delay for overnight sample
                    % if it is selected, but defualt is a stable, short delay
                    delay_growth.value = 'none';
                    delay_dur.value = 0.15;
                    DistribInterface(obj, 'set', 'exp_delay', 'Min',   0.1);
                    DistribInterface(obj, 'set', 'exp_delay', 'Max',   0.6);
                    DistribInterface(obj, 'set', 'exp_delay', 'Tau',   0.2);
                    
                    % errors have time out penalty
                    error_dur.value = 4;
                    
                    % iti
                    inter_trial_dur_type.value = 'sampled'; % gaussain
                    inter_trial_min.value = 0.25; % seconds
                    inter_trial_sample_mean.value = 1; 
                    inter_trial_max.value = 5; 
                    inter_trial_sample_std.value = 0.5; 
    
                end    
            end
            
            %%% Stage Algorithim
            if value(current_sa) == 12000 && value(current_sb) == 12000
                give_type_set.value = 'water';
            else
                give_type_set.value = 'none';
            end
            
            %%% EOD logic
            % based on 12-12 performance (about 70%), overall performance
            % (should be about 75%) and n_trials move into next stage
            
          
            
            
            if value(n_trials_stage) > 50 && value(give_frac) < 0.25 &&...
                    value(frac_correct_no_give) > 0.75 &&...
                    value(frac_violations) < 0.3
                TrainingSection(obj, 'increment_stage');
            end
        
        case 10
            %%
            stage_description.value = 'timings stable, decrease give';

            %%% init
            if value(n_trials_stage) == 0 % session init

                % Trial Structure- move to cpoke SMA 
                % and set stimulus to off because cpoke sma will send 
                % stimuli if on (spoke sma does not)
                SMA_set.value = 'cpoke';
                stimuli_on.value = 1;
                LeftProb.value = 0.5;

                if value(n_days_stage) <= 1 % stage init 
                    
                    % modify stimulus growth and timing from previous stage
                    % where the sounds were growing in duration & volume
                    % volume multiplier ensure full
                    volume_multiplier.value = 0.85;
                    stimulus_dur.value = 0.4;
                    stimulus_min.value = 0.2;
                    stimulus_growth.value = 'none';
                    
                    % initialize give frac (probabilistic) at full value
                    give_type_set.value = 'water_and_light';
                    give_frac.value = 1;
                    inital_give_frac.value = 0.60; % after day 1, what will the give frac drop to from 1
                    give_frac_decrease_rate.value = 0.15; % what will inital give frac decreae by
                    no_give_perf_threshold.value = 0.70; % threshold to decrease give frac                     
                    
                    % set up distribui for exp delay for overnight sample
                    % if it is selected, but defualt is a stable, short delay
                    delay_growth.value = 'none';
                    delay_dur.value = 0.15;
                    DistribInterface(obj, 'set', 'exp_delay', 'Min',   0.1);
                    DistribInterface(obj, 'set', 'exp_delay', 'Max',   0.6);
                    DistribInterface(obj, 'set', 'exp_delay', 'Tau',   0.2);
                    
                    % errors have time out penalty
                    error_dur.value = 4;
    
                end    
            end
            
            %%% Stage Algorithim -
            % nothing happening here that isn't controlled by the GUI/SMA.
            % L/R trials are random, give is inited to water, repaly is on.
            % delay between sounds is short & stable on init. can be
            % switched to jitter overnight. give frac will change overnight
            % is performance on non-give trials is good enough. After day 1
            % the give rate dops to the init value (%60)
            
            %%% EOD logic
            if value(n_trials_stage) > 50 && value(give_frac) < 0.25 &&...
                    value(frac_correct_no_give) > 0.75 &&...
                    value(frac_violations) < 0.3
                TrainingSection(obj, 'increment_stage');
            end
            

        case 11
            %%
            % TBD- stimulus may need to be modified in previous stage to be
            % a smaller subset
            stage_description.value = 'give off';
            %%% init
            if value(n_trials_stage) == 0 % session init

                % Trial Structure- move to cpoke SMA 
                % and set stimulus to off because cpoke sma will send 
                % stimuli if on (spoke sma does not)
                SMA_set.value = 'cpoke';
                stimuli_on.value = 1;
                LeftProb.value = 0.5;

                if value(n_days_stage) <= 1 % stage init 
                    
                    give_type_set.value = 'none';
                end    
            end
            
 
        end %stage number

       
    %---------------------------------------------------------------%
    %          get_eod_logic                                        %
    %---------------------------------------------------------------%
    % If this curriculum is selected, this is run during the `end_session`
    % case from TrainingSection. This is where you put stage specific end
    % of day logic.
    %
    % For example, if you want an animal to move to a stage only at the end
    % of the day, rather than within a session, you would put that here.
    %
    case 'get_eod_logic'
        curriculum_stage_number = value(varargin{1});
        switch curriculum_stage_number
        case 10
            % if animal does above chance on no-give trials, decrease the
            % number of no-give trials
            if value(give_frac) == 1 % first day in stage
                give_frac.value = value(inital_give_frac);
            elseif value(frac_correct_no_give) > value(no_give_perf_threshold)
                give_frac.value = value(give_frac) - value(give_frac_decrease_rate);
            end
            
            % select a new delay value for tomorrow given params 
            if strcmp(value(delay_growth), 'overnight_sampled')
                randvalue = DistribInterface(obj, 'get_new_sample', 'exp_delay');
                delay_dur.value = randvalue;
            end
            
            
        end % switch get_eod_logic curriculum_stage_number

    end % switch action

end % function

