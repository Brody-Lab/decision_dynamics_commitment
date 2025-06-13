%% PWM 2 History Section 
% Written by Jess Breda March 2022
% 
% Overview: this section will keep track of the things that have happened on
% previous trials in a session and this information will be used to decide
% what to do on current trial t in future scrips (e.g. ShapingSection)
%
% Inspiration: Primarily from Marino's TaskSwitch6 HistorySection with 
%              some verification from ProAnti3.m. 
%
% Case Info:  
%     init: gui creation & solovariable creation
%
%     prepare_next_trial: where history information for previous
%                         trials is found & saved
%
%     end_session: update the comments section for the session table w/
%                  current session history
%
%     get : ? 'reinit' for the figure
%
%     make_and_send_summary : used to update protocol data (pd) bdata blob 
%                             with history information for current session
%                             once session ends

% TODO- add task_mode variable somewhere if keeping DMS/PWM under the same thing

%% CODE
function [x, y] = HistorySection(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action,

    % ------------------------------------------------------------------
    %              INIT
    % ------------------------------------------------------------------
    
    case 'init'
        % grab x and y positions from what has already been created
        x=varargin{1}; % x = 5
        y=varargin{2}; % y = 405
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% SETUP DISPLAY VARS %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%% separate window for sub session performance history
        ToggleParam(obj, 'HistoryShow', 0, x,y, 'OnString', 'subsession history',...
            'OffString', 'Subsession Perf History', 'TooltipString', 'Show/hide subsession performance');
        set_callback(HistoryShow, {mfilename, 'show_hide'});
        next_row(y);
        oldx=x; oldy=y; parentfig=double(gcf);
        
        SoloParamHandle(obj, 'myfig', 'value', double(figure('Position', [250 450 150 150], 'closerequestfcn',...
            [mfilename '(' class(obj) ', ''hide'');'], 'MenuBar', 'none','Name', mfilename)), 'saveable', 0);
        set(gcf, 'Visible', 'off');
        x=10;y=10;
        
        %%% sub session history
        DispParam(obj, 'last150trialperf',0, x, y, 'labelfraction', 0.70,...
            'position', [x y 130 20]);next_row(y, 1.1);
        DispParam(obj, 'last100trialperf',0, x, y, 'labelfraction', 0.70,...
            'position', [x y 130 20]);next_row(y, 1.1);
        DispParam(obj, 'last75trialperf',0, x, y, 'labelfraction', 0.70,...
            'position', [x y 130 20]);next_row(y, 1.1);
        DispParam(obj, 'last50trialperf',0, x, y, 'labelfraction', 0.70,...
            'position', [x y 130 20]);next_row(y, 1.1);
        DispParam(obj, 'last25trialperf',0, x, y, 'labelfraction', 0.70,...
            'position', [x y 130 20]);next_row(y, 1.1);
        DispParam(obj, 'last10trialperf',0, x, y, 'labelfraction', 0.70,...
            'position', [x y 130 20]); next_row(y, 1.1);
        
        %%% back to main window
        x=oldx; y=oldy;
        figure(parentfig);
        
        %%% info about last trial(s)
        DispParam(obj, 'prev_result_list', '', x, y, 'labelfraction', 0.3, ...
            'label', 'prev res list', 'TooltipString', ...
            'What happened on previous 18 trials'); next_row(y,1.1)
        DispParam(obj, 'prev_result','', x, y, 'labelfraction', 0.50,...  
             'TooltipString', 'what happened on prev trial'); next_row(y, 1.1);

        DispParam(obj, 'prev_sa',0, x, y, 'labelfraction', 0.55,...
             'position', [x y 100 20]);
        DispParam(obj, 'prev_sb',0, x, y, 'labelfraction', 0.55,...
             'position', [x+100 y 100 20]);next_row(y);

        %%% fraction correct left/right
        DispParam(obj, 'left_correct',0, x, y, 'labelfraction', 0.55,...
            'label','/hit left','position', [x y 100 20]);
        DispParam(obj, 'right_correct',0, x, y, 'labelfraction', 0.55,...
            'label','/hit right','position', [x+100 y 100 20]);next_row(y);

        %%% fraction temp error
        DispParam(obj, 'frac_temp_error',0, x, y, 'labelfraction', 0.55,...
            'label','/terror','position', [x y 100 20]);
    
        %%% fraction error (no retry)
            DispParam(obj, 'frac_error',0, x, y, 'labelfraction', 0.55,...
            'label','/error','position', [x+100 y 100 20]);next_row(y,1.1);

        %%% fraction correct
        DispParam(obj, 'frac_correct',0, x, y, 'labelfraction', 0.55,...
            'label','/hit','position', [x y 100 20]);

        %%% fraction violations
        DispParam(obj, 'frac_violations',0, x, y, 'labelfraction', 0.55,...
            'label','/viol','position', [x+100 y 100 20]);next_row(y,1.1);

        %%% number of valid trials
        DispParam(obj, 'n_valid',0, x, y, 'labelfraction', 0.55,...
            'position', [x y 100 20]);

        %%% number of early spoke trials
        DispParam(obj, 'n_early',0, x, y, 'labelfraction', 0.55,...
            'position', [x+100 y 100 20]);next_row(y);

        %%% total number of trials
        DispParam(obj, 'n_trials',0, x, y, 'labelfraction', 0.55,...
            'position', [x y 200 20]); next_row(y);

        %%% section title
        SubheaderParam(obj,'title',mfilename,x,y); next_row(y);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% SETUP INTERNAL VARS %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%% binary variables
        SoloParamHandle(obj, 'was_hit', 'value', 0);
        SoloParamHandle(obj, 'was_error', 'value', 0);
        SoloParamHandle(obj, 'was_violation', 'value', 0);
        SoloParamHandle(obj, 'was_temp_error', 'value', 0);
        SoloParamHandle(obj, 'result', 'value', 0);
        
        %%% session history
        SoloParamHandle(obj, 'hit_history', 'value',[]);
        SoloParamHandle(obj, 'reward_history', 'value', []);
        SoloParamHandle(obj, 'violation_history', 'value',[]);
        SoloParamHandle(obj, 'temp_error_history', 'value', []);
        SoloParamHandle(obj, 'timeout_history', 'value', []);
        SoloParamHandle(obj, 'result_history', 'value', []);
        SoloParamHandle(obj, 'response_history', 'value', []);
        SoloParamHandle(obj, 'side_history', 'value',[]);
        SoloParamHandle(obj, 'sa_history', 'value',[]);
        SoloParamHandle(obj, 'sb_history', 'value',[]);
        SoloParamHandle(obj, 'delay_history', 'value', []);
        SoloParamHandle(obj, 'fixation_history', 'value', []);
        SoloParamHandle(obj, 'give_history', 'value', []);
        SoloParamHandle(obj, 'guide_history', 'value', []);
        SoloParamHandle(obj, 'extrafix_history', 'value', []);
        SoloParamHandle(obj, 'previous_stage', 'value',[]);
        SoloParamHandle(obj, 'stage_history', 'value', []);
        SoloParamHandle(obj, 'early_spoke_history', 'value', []);
        SoloParamHandle(obj, 'stim_table_history', 'value', {});
        SoloParamHandle(obj, 'water_vol_history', 'value', []); % How much did the animal receive? (include give) 


        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%    SEND OUT VARS    %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        DeclareGlobals(obj, 'ro_args', {'last10trialperf','last25trialperf',...
                                        'last50trialperf', 'last75trialperf',...
                                        'last100trialperf', 'last150trialperf',...
                                        'prev_result', 'prev_sa', 'prev_sb',...
                                        'left_correct', 'right_correct',...
                                        'frac_temp_error', 'frac_error',...
                                        'frac_correct', 'frac_violations',...
                                        'n_trials', 'n_valid', 'was_hit',...
                                        'was_error', 'was_violation', 'was_temp_error',...
                                        'result', 'hit_history', 'reward_history',...
                                        'violation_history', 'temp_error_history',...
                                        'timeout_history', 'result_history',...
                                        'give_history', 'guide_history',...
                                        'side_history', 'sa_history',...
                                        'sb_history','stage_history'...
                                        'delay_history', 'fixation_history',...
                                        'n_early', 'early_spoke_history',...
                                        'previous_stage', 'extrafix_history'});
        
        SoloFunctionAddVars('TrainingSection',   'rw_args', {'previous_stage'});
        SoloFunctionAddVars('TS_JY_spoke_fix',   'rw_args', {'previous_stage'});
        SoloFunctionAddVars('TS_JY_rulefirst',   'rw_args', {'previous_stage'});
        SoloFunctionAddVars('TS_JB_cpoke_fix',   'rw_args', {'previous_stage'});
        SoloFunctionAddVars('TS_PWM_classical',  'rw_args', {'previous_stage'});
        SoloFunctionAddVars('TS_LG_GNP_snds',    'rw_args', {'previous_stage'});
        SoloFunctionAddVars('TS_classicv2_full', 'rw_args', {'previous_stage'});
        SoloFunctionAddVars('TS_LGS_v2',         'rw_args', {'previous_stage'});

    % ------------------------------------------------------------------
    %              PREPARE NEXT TRIAL
    % ------------------------------------------------------------------
        
    case 'prepare_next_trial',

        %%% if we haven't done any trials yet, skip this case
        if(n_done_trials==0 || isempty(parsed_events) || ~isfield(parsed_events,'states'))
            return;
        end


        %%% Binary variables about trial result
        % clear results from last trial
        was_hit.value = 0; was_error.value = 0; 
        was_violation.value = 0; was_temp_error.value = 0;

        % hit (if they got it correct first try)
        if (~isempty(parsed_events.states.hit_state) || ~isempty(parsed_events.states.hit_state_scaled)) && ...
                isempty(parsed_events.states.temp_error_state)
            was_hit.value     = 1;
            result.value      = 1;
            prev_result.value = 'Hit';
        % error
        elseif ~isempty(parsed_events.states.error_state)
            was_error.value   = 1;
            result.value      = 2;
            prev_result.value = 'Error';     
        % violation
        elseif ~isempty(parsed_events.states.violation_state)
            was_violation.value = 1;
            result.value        = 3;
            prev_result.value   = 'Violation';
        % temp error (if they got it correct on retry)
        elseif ~isempty(parsed_events.states.temp_error_state) && (~isempty(parsed_events.states.hit_state) || ~isempty(parsed_events.states.hit_state_scaled))
            was_temp_error.value = 1;
            result.value         = 4; 
            prev_result.value    = 'TempError';
        else
            warning('Result of trial unknown, crash was not detected, trial counts will be off');
        end
        if length(value(prev_result_list)) >= 18
            prev_result_list.value = eraseBetween(value(prev_result_list), 1, 1);
        end
        pr = value(prev_result);
        prev_result_list.value = [value(prev_result_list) , pr(1)];

        % check validity
        if value(was_hit) + value (was_error) + value(was_violation) + value(was_temp_error) ~=1
            warning('Multiple results found for single trial!');
        end

        % check for early spoke
        if isfield(parsed_events.states, 'early_spoke_state') && ...
                ~isempty(parsed_events.states.early_spoke_state)
            n_early.value = value(n_early) + 1;
            early_spoke_history.value = [value(early_spoke_history) 1];
        else
            early_spoke_history.value = [value(early_spoke_history) 0];
        end

        %%% History Variables
        % animal performance
        res = value(result);
        result_history.value         = [value(result_history) res];

        % side history
        if strcmp(value(current_side), 'LEFT')
            corr_side = 'l'; incorr_side = 'r';
        else
            corr_side = 'r'; incorr_side = 'l';
        end
        side_history.value           = [value(side_history) corr_side];

        if (res==1) % hit
            hit_history.value        = [value(hit_history) 1];
            reward_history.value     = [value(reward_history) 1];
            violation_history.value  = [value(violation_history) 0];
            temp_error_history.value = [value(temp_error_history) 0];
            timeout_history.value    = [value(timeout_history) NaN];
            response_history.value   = [value(response_history) corr_side];
            n_trials.value           = value(n_trials) + 1;
            n_valid.value            = value(n_valid) + 1;
        elseif (res==2) % error
            hit_history.value        = [value(hit_history) 0];
            violation_history.value  = [value(violation_history) 0];
            reward_history.value     = [value(reward_history) 0];
            temp_error_history.value = [value(temp_error_history) 0];
            timeout_history.value    = [value(timeout_history) value(error_dur)];
            response_history.value   = [value(response_history) incorr_side];
            n_trials.value           = value(n_trials) + 1;
            n_valid.value            = value(n_valid) + 1;
        elseif (res==3) % violation
            hit_history.value        = [value(hit_history) NaN];
            reward_history.value     = [value(reward_history) NaN];
            violation_history.value  = [value(violation_history) 1];
            temp_error_history.value = [value(temp_error_history) NaN];
            timeout_history.value    = [value(timeout_history) value(violation_dur)];
            response_history.value   = [value(response_history) 'v'];
            n_trials.value           = value(n_trials) + 1;
        elseif (res==4) % temp error (miss --> hit)
            hit_history.value        = [value(hit_history) 0];
            reward_history.value     = [value(reward_history) 1];
            violation_history.value  = [value(violation_history) 0];
            temp_error_history.value = [value(temp_error_history) 1];
            timeout_history.value    = [value(timeout_history) value(temp_error_dur)];
            response_history.value   = [value(response_history) incorr_side]
            n_trials.value           = value(n_trials) + 1;
            n_valid.value            = value(n_valid) + 1;  
        end


        % task history 
        delay_history.value    = [value(delay_history) value(delay_dur)];
        fixation_history.value = [value(fixation_history) value(cp_fixation_dur)];

        sa_history.value       = [value(sa_history) value(current_sa)];
        prev_sa.value          = value(sa_history(end)) / 1000; % kHz

        sb_history.value       = [value(sb_history) value(current_sb)];
        prev_sb.value          = value(sb_history(end)) / 1000; % kHz

        give_history.value  = [value(give_history) strcmp(reward_type, 'give')];
        guide_history.value = [value(guide_history) value(guide_toggle)];

        if ~isempty(parsed_events.states.hit_state_scaled)
            extrafix_history.value = [value(extrafix_history) 1];
        else
            extrafix_history.value = [value(extrafix_history) 0];
        end

        % stage history
        stage_history.value   = [value(stage_history) value(stage_number)];

        %%% Ongoing Session Performance
        % fraction correct
        vec_hit               = value(hit_history);
        frac_correct.value    = round(mean(vec_hit, 'omitnan'), 2);

        % fraction violations
        vec_res               = value(result_history);
        num_violations        = length(find(vec_res==3));
        num_total             = length(vec_res);
        frac_violations.value = round((num_violations/num_total), 2);

        % fraction temp error
        vec_temp_error        = value(temp_error_history);
        frac_temp_error.value = round(mean(vec_temp_error, 'omitnan'), 2);

        % fraction error 
        num_errors            = length(find(vec_res ==2));
        frac_error.value      = round((num_errors/num_total), 2);

        % left/right fraction correct
        vec_side              = value(side_history);        
        left_correct.value    = round(mean(vec_hit(vec_side=='l'), 'omitnan'), 2);
        right_correct.value   = round(mean(vec_hit(vec_side=='r'), 'omitnan'), 2);

        % stim table history
        st_hist = value(stim_table_history); st_hist{end+1} = value(stim_table);
        stim_table_history.value = st_hist;

        % subtrial performance
        if value(n_trials_stage) >= 10;   Last10TrialPerf.value = mean(hit_history(end-9:end), 'omitnan');   else  Last10TrialPerf.value = 0; end %#ok<NODEF>
        if value(n_trials_stage) >= 25;   Last25TrialPerf.value = mean(hit_history(end-24:end), 'omitnan');  else  Last25TrialPerf.value = 0; end 
        if value(n_trials_stage) >= 50;   Last50TrialPerf.value = mean(hit_history(end-49:end), 'omitnan');  else  Last50TrialPerf.value = 0; end    
        if value(n_trials_stage) >= 75;   Last75TrialPerf.value = mean(hit_history(end-74:end), 'omitnan');  else  Last75TrialPerf.value = 0; end
        if value(n_trials_stage) >= 100;  Last100TrialPerf.value = mean(hit_history(end-99:end), 'omitnan');  else Last100TrialPerf.value = 0; end
        if value(n_trials_stage) >= 150;  Last150TrialPerf.value = mean(hit_history(end-149:end), 'omitnan'); else Last150TrialPerf.value = 0; end

        % update stim_table in StimulusSection
        StimulusSection(obj, 'update_performance', result);


    % ------------------------------------------------------------------
    %              END SESSION
    % ------------------------------------------------------------------
    case 'end_session',  

        %%% append comments for sessions table
        CommentsSection(obj, 'append_line', [value(curriculum) ' ; ']);
        CommentsSection(obj, 'append_line', [value(stage_name_persist) ' ; ']);
        CommentsSection(obj, 'append_line', ['days stage: ' num2str(value(n_days_stage)) ' ; ']);
        CommentsSection(obj, 'append_line', ['days training: ' num2str(value(n_days_training)) ' ; ']);
        CommentsSection(obj, 'append_line', ['valid: ' num2str(value(n_valid)) ' ; ']);
        CommentsSection(obj, 'append_line', ['early: ' num2str(value(n_early)) ' ; ']);
        CommentsSection(obj, 'append_line', ['delay: ' num2str(max(value(delay_history))) ' ; ']);
        if strcmp(delay_growth_type, 'discrete')
            CommentsSection(obj, 'append_line', ['fixation: ' array_to_str(delay_discrete_values) ' ; ']);
        else
            CommentsSection(obj, 'append_line', ['fixation: ' num2str(fixation_history(end)) ' ; ']);
        end

        
    % ------------------------------------------------------------------
    %              CRASH CLEANUP
    % ------------------------------------------------------------------
    case 'crash_cleanup',
        % last trial was a crash, keep dimensions constant but
        % fill with nans or clear variables
        warning('crash detected from bpod, running history clean up');

        % binary & single trial variables
        was_hit.value = 0; was_error.value = 0; 
        was_violation.value = 0; was_temp_error.value = 0;
        result.value = 5; 
        prev_result.value = 'Crash'; 
        prev_result_list.value = [value(prev_result_list), 'C'];
        prev_sa.value = nan;
        prev_sb.value = nan;
        n_trials.value  = value(n_trials) + 1;
        n_trials_stage.value = value(n_trials_stage) + 1;

        % session history
        hit_history.value        = [value(hit_history) nan];
        violation_history.value  = [value(violation_history) nan];
        temp_error_history.value = [value(temp_error_history) nan];
        give_history.value       = [value(give_history) nan];
        guide_history.value      = [value(guide_history) nan];
        extrafix_history.value   = [value(extrafix_history) nan];
        result_history.value     = [value(result_history) value(result)];
        timeout_history.value    = [value(timeout_history) nan];
        sa_history.value         = [value(sa_history) value(prev_sa)];
        sb_history.value         = [value(sb_history) value(prev_sb)];
        delay_history.value      = [value(delay_history) nan];
        fixation_history.value   = [value(fixation_history) nan];
        response_history.value   = [value(response_history) nan];
        st_hist = value(stim_table_history); st_hist{end+1} = {};
        stim_table_history.value = st_hist;

        x = rand; if x > 0.5; s = 'l'; else; s = 'r'; end
        side_history.value       = [value(side_history) s];

    % ------------------------------------------------------------------
    %              MAKE AND SEND SUMMARY
    % ------------------------------------------------------------------
        
    case 'make_and_send_summary',

        % TODO determine if we want to add trial by trial water timing for easier video sync from PWM
        % TODO determine if this is just for len(ntrial) variables, or if additional stage info should be stored
        
        %%% update protocol data (pd) struct that is saved in sessions table
        pd.hits            = value(hit_history);
        pd.rewards         = value(reward_history);
        pd.temperror       = value(temp_error_history);
        pd.viols           = value(violation_history);
        pd.sides           = value(side_history);
        pd.responses       = value(response_history);
        pd.result          = value(result_history);
        pd.sa              = value(sa_history);
        pd.sb              = value(sb_history);
        pd.stim_table      = value(stim_table);
        pd.stim_table_history = value(stim_table_history);
        pd.give_history    = value(give_history);
        pd.guide_history   = value(guide_history);
        pd.extrafix_history = value(extrafix_history);
        pd.delay           = value(delay_history);
        pd.fixation        = value(fixation_history);
        pd.timeouts        = value(timeout_history);
        pd.stage           = value(stage_history);

        sendsummary(obj, 'sides', pd.sides, 'protocol_data', pd); 


    case 'show_hide'
        if HistoryShow == 0 set(value(myfig), 'Visible', 'off');
        else                set(value(myfig), 'Visible', 'on');
        end

    end % end switch
end


function str = array_to_str(arr)
    str = '[ ';
    for i = 1 : length(arr) - 1
        str = [str , num2str(arr(i)), ' '];
    end
    str = [str , num2str(arr(i)), ']'];
end
