%% DMS2 History Section 
% Written by Jess Breda January 2023
% 
% Overview: this section will keep track of the things that have happened on
% previous trials in a session and this information will be used to decide
% what to do on current trial t in future scrips (e.g. ShapingSection)
%
% Inspiration: Primarily from Marino's TaskSwitch6 HistorySection with 
%              some verification from ProAnti3.m. 
%
% Case Info:  
%     init : 
%           gui creation & solovariable creation
%
%     prepare_next_trial: 
%           where history information for previous
%           trials is found & saved
%
%     end_session: 
%           update the comments section for the session table w/
%           current session history
%
%     crash_cleanup : 
%           if dispatcher detected a crash, this case updates all
%           the history variables to make sure lengths are kept
%           constant before resending the same SMA for the next trial
%
%     make_and_send_summary : 
%           used to update protocol data (pd) bdata blob with history
%           information for current session once session ends
% 
%   show_hide :
%           case for opening/closing subwindows creted in history section

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
        
        SoloParamHandle(obj, 'myfig', 'value', double(figure('Position', [250 450 320 200], 'closerequestfcn',...
            [mfilename '(' class(obj) ', ''hide'');'], 'MenuBar', 'none','Name', mfilename)), 'saveable', 0);
        set(gcf, 'Visible', 'off');
        x=10;y=10;
        
        %%% sub session history
        DispParam(obj, 'Last150TrialPerf',0, x, y, 'labelfraction', 0.6,...
            'position', [x y 140 20]);
        DispParam(obj, 'Last150TrialViol',0, x, y, 'labelfraction', 0.6,...
            'position', [x+150 y 140 20]);next_row(y, 1.1);            
        
        DispParam(obj, 'Last100TrialPerf',0, x, y, 'labelfraction', 0.6,...
            'position', [x y 140 20]);
        DispParam(obj, 'Last100TrialViol',0, x, y, 'labelfraction', 0.6,...
            'position', [x+150 y 140 20]);next_row(y, 1.1); 

        DispParam(obj, 'Last75TrialPerf',0, x, y, 'labelfraction', 0.6,...
            'position', [x y 140 20]);
        DispParam(obj, 'Last75TrialViol',0, x, y, 'labelfraction', 0.6,...
            'position', [x+150 y 140 20]);next_row(y, 1.1); 
        
        DispParam(obj, 'Last50TrialPerf',0, x, y, 'labelfraction', 0.6,...
            'position', [x y 140 20]);
        DispParam(obj, 'Last50TrialViol',0, x, y, 'labelfraction', 0.6,...
            'position', [x+150 y 140 20]);next_row(y, 1.1); 
        
        DispParam(obj, 'Last25TrialPerf',0, x, y, 'labelfraction', 0.6,...
            'position', [x y 140 20]);
        DispParam(obj, 'Last25TrialViol',0, x, y, 'labelfraction', 0.6,...
            'position', [x+150 y 140 20]);next_row(y, 1.1);
        
        DispParam(obj, 'Last20TrialPerf',0, x, y, 'labelfraction', 0.6,...
            'position', [x y 140 20]);
        DispParam(obj, 'Last20TrialViol',0, x, y, 'labelfraction', 0.6,...
            'position', [x+150 y 140 20]);next_row(y, 1.1);
                                                
        DispParam(obj, 'Last10TrialPerf',0, x, y, 'labelfraction', 0.6,...
            'position', [x y 140 20]);
        DispParam(obj, 'Last10TrialViol',0, x, y, 'labelfraction', 0.6,...
            'position', [x+150 y 140 20]);next_row(y, 1.1); 
        
        % SMA subwindow, Header
        SubheaderParam(obj,'lab1', 'Hits',x,y,'position', [x y 150 20]);
        SubheaderParam(obj,'lab2', 'Viols', x,y, 'position', [x+150 y 150 20]);
        
        %%% back to main window
        x=oldx; y=oldy;
        figure(parentfig);
        
        %% ROW 10
        DispParam(obj, 'prev_result','', x, y, 'labelfraction', 0.50,...  
             'TooltipString', 'what happened on prev trial'); 
        next_row(y, 1.1);

        %% ROW 9
        DispParam(obj, 'prev_sa',0, x, y, 'labelfraction', 0.55,...
             'position', [x y 100 20],...
             'TooltipString', 'previous trial sa in kHz');
        DispParam(obj, 'prev_sb',0, x, y, 'labelfraction', 0.55,...
             'position', [x+100 y 100 20],...
             'TooltipString', 'previous trial sa in kHz');
        next_row(y,1.1);

        %% ROW 8
        DispParam(obj, 'n_match',0, x, y, 'labelfraction', 0.55,...
            'label','n match','position', [x y 100 20],...
            'TooltipString', 'number of match trials given');
        DispParam(obj, 'n_nonmatch',0, x, y, 'labelfraction', 0.55,...
            'label','n nmatch','position', [x+100 y 100 20],...
            'TooltipString', 'number of nonmatch trials given');
        next_row(y);

       %% ROW 7 
        DispParam(obj, 'frac_correct_pro',0, x, y, 'labelfraction', 0.55,...
            'label','/hit pro','position', [x y 100 20],...
            'TooltipString', 'frac of valid trials that were pro & correct');
        DispParam(obj, 'frac_correct_anti',0, x, y, 'labelfraction', 0.55,...
            'label','/hit anti','position', [x+100 y 100 20],...
            'TooltipString', 'frac of valid trials that were anti & correct');
        next_row(y);
        
       %% ROW 6
        DispParam(obj, 'frac_correct_no_give',0, x, y, 'labelfraction', 0.55,...
            'label','/hit ~give','position', [x y 100 20],...
            'TooltipString', 'frac of valid trials that were non-give & correct');
        DispParam(obj, 'frac_no_answer',0, x, y, 'labelfraction', 0.55,...
            'label','/noans','position', [x+100 y 100 20],...
            'TooltipString', 'frac of trials that were no answer');
        next_row(y);
        
        %% ROW 5
        DispParam(obj, 'frac_temp_error',0, x, y, 'labelfraction', 0.55,...
            'label','/terror','position', [x y 100 20],...
            'TooltipString', 'frac of valid trials w/ temp error retry -> hit');
        DispParam(obj, 'frac_error',0, x, y, 'labelfraction', 0.55,...
            'label','/error','position', [x+100 y 100 20],...
            'TooltipString', 'frac of valid trials incorrect, incl incorrect retry');
        next_row(y);

        %% ROW 4
        DispParam(obj, 'frac_correct',0, x, y, 'labelfraction', 0.55,...
            'label','/hit','position', [x y 100 20],...
            'TooltipString', 'frac of valid trials correct');
        DispParam(obj, 'frac_violations',0, x, y, 'labelfraction', 0.55,...
            'label','/viol','position', [x+100 y 100 20],...
            'TooltipString', 'frac of nonvalid trials');
        next_row(y,1.1);

        %% ROW 3
        DispParam(obj, 'n_give',0, x, y, 'labelfraction', 0.55,...
            'position', [x y 100 20],...
            'TooltipString', 'number of trials where give was on an used');
        DispParam(obj, 'n_early',0, x, y, 'labelfraction', 0.55,...
            'position', [x+100 y 100 20],...
            'TooltipString', 'number of trails would be violations, but viol is off');
        next_row(y);
        
        %% ROW 2
        DispParam(obj, 'n_no_answer',0, x, y, 'labelfraction', 0.55,...
            'position', [x y 100 20], 'label', 'n_noans',...
            'TooltipString', 'number of trials w/ no answer given');     
        DispParam(obj, 'n_valid',0, x, y, 'labelfraction', 0.55,...
            'position', [x+100  y 100 20],...
            'TooltipString', 'number of trials w/o violation'); 
        next_row(y);

        %% ROW 1
        DispParam(obj, 'n_trials',0, x, y, 'labelfraction', 0.50,...
            'position', [x y 200 20],...
            'TooltipString', 'total number of trials in a session');
        next_row(y);

        %% Headers 
        SubheaderParam(obj,'title',mfilename,x,y); next_row(y);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% SETUP INTERNAL VARS %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%% binary & int variables
        SoloParamHandle(obj, 'was_hit',               'value', 0);
        SoloParamHandle(obj, 'was_error',             'value', 0);
        SoloParamHandle(obj, 'was_violation',         'value', 0);
        SoloParamHandle(obj, 'was_temp_error',        'value', 0);
        SoloParamHandle(obj, 'was_no_answer',         'value', 0);
        SoloParamHandle(obj, 'result',                'value', 0);
        
        %%% session history
        SoloParamHandle(obj, 'hit_history',           'value', []);
        SoloParamHandle(obj, 'violation_history',     'value', []);
        SoloParamHandle(obj, 'temp_error_history',    'value', []);
        SoloParamHandle(obj, 'no_answer_history',     'value', []); 
        SoloParamHandle(obj, 'timeout_history',       'value', []);
        SoloParamHandle(obj, 'result_history',        'value', []); 

        SoloParamHandle(obj, 'SMA_implemented',       'value', []);
        SoloParamHandle(obj, 'SMA_hist',              'value', []);
        SoloParamHandle(obj, 'side_history',          'value', []);
        SoloParamHandle(obj, 'sa_history',            'value', []);
        SoloParamHandle(obj, 'sb_history',            'value', []);
        SoloParamHandle(obj, 'is_match_history',      'value', []);
        SoloParamHandle(obj, 'give_use_history',      'value', []);
        SoloParamHandle(obj, 'incorr_spokes_during_give_del_history', 'value', []);
        
        SoloParamHandle(obj, 'valid_early_spoke_history', 'value', []);
        SoloParamHandle(obj, 'first_spoke_history',       'value', []);
        SoloParamHandle(obj, 'first_lpoke_history',       'value', []);
        SoloParamHandle(obj, 'first_rpoke_history',       'value', []);  
        
        SoloParamHandle(obj, 'n_settling_ins_history',    'value', []);
        SoloParamHandle(obj, 'avg_settling_in_history',   'value', []);
        SoloParamHandle(obj, 'cpoke_dur_history',          'value', []);
        SoloParamHandle(obj, 'wf_cpoke_dur_history',       'value', []);
        
        SoloParamHandle(obj, 'trial_start_time_history', 'value', []);
        SoloParamHandle(obj, 'trial_dur_history',        'value', []);
        SoloParamHandle(obj, 'n_lpokes_history',         'value', []);
        SoloParamHandle(obj, 'n_cpokes_history',         'value', []);
        SoloParamHandle(obj, 'n_rpokes_history',         'value', []);
        
        SoloParamHandle(obj, 'water_delivered_history',       'value', []); % used to account for give water in total amt
        SoloParamHandle(obj, 'give_water_not_drunk',          'value', false);
        SoloParamHandle(obj, 'port_with_give_reward',         'value', 'L'); 
        SoloParamHandle(obj, 'give_water_not_drunk_history',  'value', []);
        SoloParamHandle(obj, 'water_history',                 'value', []); % given to adlib gui 
        SoloParamHandle(obj, 'stage_history',                 'value', []);
        SoloParamHandle(obj, 'stage_name_hist',               'value', {});
        
        SoloParamHandle(obj, 'n_pro',                    'value', 0);
        SoloParamHandle(obj, 'n_anti',                   'value', 0);
         

        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%    SEND OUT VARS    %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        history_section_vars = get_name(get_sphandle('owner', '@DMS2', 'funcowner', 'HistorySection'));
        DeclareGlobals(obj, 'ro_args', history_section_vars)
        
    % ------------------------------------------------------------------
    %              PREPARE NEXT TRIAL
    % ------------------------------------------------------------------
        
    case 'prepare_next_trial'

        %%% if we haven't done any trials yet, skip this case
        if(length(value(n_done_trials))==0 || isempty(parsed_events) || ~isfield(parsed_events,'states'))
            return;
        end
        
        %% check
        % this should never happen and we should break the session if it
        % does because the data will be saved wonky
        if (length(parsed_events_history)+ 1) ~= n_done_trials
            result.value = 5;
            error('peh and n_done trials off! broke before updating history vars');
        end

        %% Binary variables about trial result
        % clear results from last trial
        was_hit.value = 0; was_error.value = 0; 
        was_violation.value = 0; was_temp_error.value = 0;
        was_no_answer.value = 0;

        %% SMA 
        % Determine which SMA was in used based off of the parsed events
        % states. This is necessary because sometimes when a stage switch
        % happens in the middle of the trial via the user, things get
        % misassigned to the new stage SMA.
        if isfield(parsed_events.states, 'wait_for_cpoke')
            SMA_implemented.value = 'cpoke'; 
        elseif isfield(parsed_events.states, 'spoke_t_start')
            SMA_implemented.value = 'spoke';
        elseif isfield(parsed_events.states, 'left_hit_state')
            SMA_implemented.value = 'habitution';
        else
            error('parsed events does not map to an SMA!')
        end

        %% Determine previous trial result
        if strcmp(value(SMA_implemented), 'cpoke')
            % hit (if they got it correct first try)
            if ~isempty(parsed_events.states.hit_state) && ...
                    isempty(parsed_events.states.temp_error_state)
                was_hit.value        = 1;
                result.value         = 1;
                prev_result.value    = 'Hit';
            % error
            elseif ~isempty(parsed_events.states.error_state)
                was_error.value      = 1;
                result.value         = 2;
                prev_result.value    = 'Error';     
            % violation
            elseif ~isempty(parsed_events.states.violation_state) 
                was_violation.value  = 1;
                result.value         = 3;
                prev_result.value    = 'Violation';
            % temp error (if they got it correct on retry)
            elseif ~isempty(parsed_events.states.temp_error_state) && ...
                    ~isempty(parsed_events.states.terror_hit_state)
                was_temp_error.value = 1;
                result.value         = 4; 
                prev_result.value    = 'TempError';
            % no answer (wait_for_spoke Tuped)
            elseif ~isempty(parsed_events.states.no_answer_state)
                was_no_answer.value  = 1;
                result.value         = 6; %crashes are 5
                prev_result.value    = 'NoAnswer';
            else
                warning('Result of trial unknown, crash was not detected, trial counts will be off');
            end
           
        elseif strcmp(value(SMA_implemented), 'habituation')
            % if in SMA_habiutation the animal can only get it correct
            was_hit.value        = 1;
            result.value         = 1;
            prev_result.value    = 'Hit';

        elseif strcmp(value(SMA_implemented), 'spoke')
            % in SMA_spoke there is no violation (could combine this with
            % the cpoke above eventually to make it cleaner)
            if ~isempty(parsed_events.states.hit_state) && ...
                    isempty(parsed_events.states.temp_error_state)
                was_hit.value        = 1;
                result.value         = 1;
                prev_result.value    = 'Hit';
            % error
            elseif ~isempty(parsed_events.states.error_state)
                was_error.value      = 1;
                result.value         = 2;
                prev_result.value    = 'Error'; 
            % temp error (if they got it correct on retry)
            elseif ~isempty(parsed_events.states.temp_error_state) && ...
                    ~isempty(parsed_events.states.hit_state)
                was_temp_error.value = 1;
                result.value         = 4; 
                prev_result.value    = 'TempError';
            % no answer (wait_for_spoke Tuped)
            elseif ~isempty(parsed_events.states.no_answer_state)
                was_no_answer.value  = 1;
                result.value         = 6; %crashes are 5
                prev_result.value    = 'NoAnswer';
            end
        else
            error('History variables not mapped to a specific SMA!');
        end

        % test validity 
        if value(was_hit) + value(was_error) + value(was_violation) +...
             value(was_temp_error) + value(was_no_answer) ~=1
            error('Multiple results found for single trial!');
        end
        
        %%% History Variables
        %% animal performance
        res                          = value(result);
        result_history.value         = [value(result_history) res];

        if (res==1) % hit
            hit_history.value        = [value(hit_history) 1];
            violation_history.value  = [value(violation_history) 0];
            temp_error_history.value = [value(temp_error_history) 0];
            timeout_history.value    = [value(timeout_history) NaN];
            water_history.value      = [value(water_history) 1];
            n_trials.value           = value(n_trials) + 1;
            n_valid.value            = value(n_valid) + 1;
        elseif (res==2) % error
            hit_history.value        = [value(hit_history) 0];
            violation_history.value  = [value(violation_history) 0];
            temp_error_history.value = [value(temp_error_history) 0];
            timeout_history.value    = [value(timeout_history) value(error_dur)];
            water_history.value      = [value(water_history) 0];
            n_trials.value           = value(n_trials) + 1;
            n_valid.value            = value(n_valid) + 1;
        elseif (res==3) % violation
            hit_history.value        = [value(hit_history) NaN];
            violation_history.value  = [value(violation_history) 1];
            temp_error_history.value = [value(temp_error_history) NaN];
            timeout_history.value    = [value(timeout_history) value(violation_dur)];
            water_history.value      = [value(water_history) 0];
            n_trials.value           = value(n_trials) + 1;
        elseif (res==4) % temp error (miss --> hit)
            hit_history.value        = [value(hit_history) 0];
            violation_history.value  = [value(violation_history) 0];
            temp_error_history.value = [value(temp_error_history) 1];
            timeout_history.value    = [value(timeout_history) value(temp_error_dur)];
            water_history.value      = [value(water_history) 1];
            n_trials.value           = value(n_trials) + 1;
            n_valid.value            = value(n_valid) + 1;
        elseif (res==6) % no answer
            hit_history.value        = [value(hit_history) NaN];
            violation_history.value  = [value(violation_history) NaN];
            temp_error_history.value = [value(temp_error_history) NaN];
            timeout_history.value    = [value(timeout_history) NaN];
            water_history.value      = [value(water_history) 0];
            n_trials.value           = value(n_trials) + 1;
            n_no_answer.value         = value(n_no_answer) + 1;

        end

        %% side 
        if strcmp(value(current_side), 'LEFT'); side = 'l'; else; side = 'r'; end
        side_history.value       = [value(side_history) side];

        %% match/nonmatch
        if value(current_sa) == value(current_sb)
            is_match_history.value  = [value(is_match_history) 1];
        else
            is_match_history.value  = [value(is_match_history) 0]; 
        end
        
        %% give implemented & if used
          if contains(value(give_type_implemented), 'water')
              water_give = 1;
          else
              water_give = 0;
          end

        % determine if give was used (will be empty if give is none)
        if contains(value(SMA_implemented), 'poke') &&...  % not in SMA_habiutation 
            isfield(parsed_events.states, 'give_state') % give not off
            if ~isempty(parsed_events.states.give_state)
                was_give = 1;
                n_give.value = value(n_give) + 1;
                give_use_history.value = [value(give_use_history) 1];
            else
                was_give = 0;
                give_use_history.value = [value(give_use_history) 0];
            end  
        else
            was_give = 0;
            give_use_history.value = [value(give_use_history) 0];
        end   

        
        %% water 
        [LeftWValveVol, RightWValveVol] = WaterValvesSection(obj, 'get_water_volumes');

        if strcmp(value(current_side), 'LEFT');
            hit_water_volume = LeftWValveVol;
        else
            hit_water_volume = RightWValveVol;
        end

        % Determine if give water was drunk (applied for SMA_spoke only!)
        % TODO think about applying to cpoke_SMA too. Could be simple check if there
        % TODO was an error, did animal poke in give port after to retreive? Wouldnt
        % TODO anly toggling on whether to deliver again or not in ShSection
        if strcmp(value(SMA_implemented), 'spoke') && water_give && was_no_answer
            port_with_give_reward.value = upper(side);
            pokes_in_reward_port = parsed_events.pokes.(value(port_with_give_reward));
            if isempty(pokes_in_reward_port)
                give_water_not_drunk.value = true;
            end
        end
        
        % If there is give water waiting for the animal, check to see if
        % they have drunk it yet. Once they do, we can give them more.
        if ~strcmp(value(SMA_implemented), 'spoke')
            give_water_not_drunk.value = nan;
        % this happens if we move from cpoke -> spoke sma, just skip over
        % the logic for the transition trial and assume false
        elseif n_done_trials > 1 && isnan(give_water_not_drunk_history(end))
            give_water_not_drunk.value = false;
        elseif n_done_trials > 1 && give_water_not_drunk_history(end) && give_water_not_drunk
            pokes_in_reward_port = parsed_events.pokes.(value(port_with_give_reward));
            if ~isempty(pokes_in_reward_port)
                give_water_not_drunk.value = false;
            end
        end

        give_water_not_drunk_history.value = ...
            [value(give_water_not_drunk_history) value(give_water_not_drunk)];

        % determine how much water was delivered to the animal
        if was_hit % full reward delivered
            water_delivered_history.value = [value(water_delivered_history) hit_water_volume];
        elseif was_temp_error
            terror_water_volume = hit_water_volume * terror_water_frac;
            water_delivered_history.value = [value(water_delivered_history) terror_water_volume];
        elseif (was_error && was_give && water_give) || (was_no_answer && was_give && water_give) % give only delivered
            give_water_volume = hit_water_volume * give_water_frac;
            water_delivered_history.value = [value(water_delivered_history) give_water_volume];
        else % no water delivered
            water_delivered_history.value = [value(water_delivered_history) 0];
        end

        %% N Pokes in L,C,R 
        % calculated for previous trial because a pokes after a state
        % that causes a prepare next trial call (hit_cleanup) will not 
        % be documented in parsed_events, but will be doucmented in 
        % parsed_events_history
        
        if isempty(parsed_events_history)
            disp('') % do nothing, cant calculate t-1 info on t_1
        else
            [n_lpokes, ~] = size(parsed_events_history{end}.pokes.L);
            [n_cpokes, ~] = size(parsed_events_history{end}.pokes.C);
            [n_rpokes, ~] = size(parsed_events_history{end}.pokes.R);
            
            n_lpokes_history.value = [value(n_lpokes_history) n_lpokes];
            n_cpokes_history.value = [value(n_cpokes_history) n_cpokes];
            n_rpokes_history.value = [value(n_rpokes_history) n_rpokes];  
        end
     
        %% Side  Pokes
        % determine if a early (but valid) spoke happened. This means the
        % animal poked after viol_off wave and before the go cue.
        if strcmp(value(SMA_implemented), 'cpoke')
            if ~isempty(parsed_events.states.early_spoke_wait_for_go)
                n_early.value = value(n_early) + 1;
                valid_early_spoke_history.value = [value(valid_early_spoke_history) 1];      
            else
                valid_early_spoke_history.value = [value(valid_early_spoke_history) 0]; 
            end
        else
            valid_early_spoke_history.value = [value(valid_early_spoke_history) 0];
        end
        
        % determine spoke timing info see case for more details on how
        % this is handled for each SMA
        HistorySection(obj, 'calculate_spoke_info');
        HistorySection(obj, 'calculate_cpoke_info');
        HistorySection(obj, 'calculate_spoke_during_give_del_info');
          
          
%         %% Helper info- NOT IN USE JUST AN EXAMPLE
%         if strcmp(value(in_helper_block), 'TRUE')
%             helper_history.value = [value(helper_history) 1];
%         else
%             helper_history.value = [value(helper_history) 0];
%         end
% 
        %% Stage info
        stage_history.value      = [value(stage_history) value(stage_number)];
        
        % multicharacter arrays are easier to append to cells
        stage_name_hist{end+1}   = value(stage_name_persist); 
        
        %% trial start time (raw value)
        try
            start_time = parsed_events_history{end}.states.state_0(1,2);
        catch
            start_time = nan;
            disp('***state_0 not accessible for trial start calculation');
        end
        trial_start_time_history.value = [value(trial_start_time_history) start_time];
        
        %% trial duration
        % if there is no error/crash, state 0 indicates trial transitions 
        % with the same structure each trial.
        if isempty(parsed_events_history)
            disp('') % do nothing, cant calculate t-1 info on t_1
        else
            try
                start_time = parsed_events_history{end}.states.state_0(1,2);
                end_time = parsed_events_history{end}.states.state_0(2,1);
                trial_dur = end_time - start_time;
            catch
                trial_dur = nan;
                disp('***state_0 not accessible for trial dur calculation');
            end

            trial_dur_history.value = [value(trial_dur_history) trial_dur];
        end
        
        %% wait for cpoke duration
        if isfield(parsed_events.states, 'wait_for_cpoke') && ...
                ~isempty(parsed_events.states.cpoke)            
            try
                wf_cpoke_start = parsed_events.states.wait_for_cpoke(1,1);
                wf_cpoke_end = parsed_events.states.wait_for_cpoke(end,2);
                wf_cpoke_dur = wf_cpoke_end - wf_cpoke_start;
                wf_cpoke_dur_history.value = [value(wf_cpoke_dur_history), wf_cpoke_dur];
                
            catch
                disp('***wf cpoke info not available');
            end
        end
        
        

        %% Ongoing Session Performance
        % fraction correct
        vec_hit                = value(hit_history);
        frac_correct.value     = round(mean(vec_hit, 'omitnan'), 2);

        % fraction violations
        vec_violation          = value(violation_history);
        frac_violations.value  = round(mean(vec_violation, 'omitnan'), 2);

        % fraction temp error
        vec_temp_error         = value(temp_error_history);
        frac_temp_error.value  = round(mean(vec_temp_error, 'omitnan'), 2);

        % fraction error
        vec_res                = value(result_history);
        num_errors             = length(find(vec_res == 2));
        frac_error.value       = round((num_errors/value(n_valid)), 2);

        % fracction no answer
        frac_no_answer.value   = value(n_no_answer) / n_done_trials;
        
        % fraction correct on non-give
        valid_indices          = ~isnan(value(hit_history)); 
        valid_give_imp         = value(give_type_implemented_history(valid_indices)).';
        valid_hit              = value(hit_history(valid_indices));
        none_indices           = find(strcmp(valid_give_imp, 'none'));
        num_none_and_hit       = sum(valid_hit(none_indices) == 1);
        frac_correct_no_give.value = num_none_and_hit / length(none_indices);
        
        % fraction correct on pro-anti
        if value(pro_anti_on)
            valid_pro_anti_type = value(pro_anti_block_type_history(valid_indices)).';
            
            pro_indices = find(strcmp(valid_pro_anti_type, 'pro'));
            n_pro.value = length(pro_indices);
            num_pro_and_hit = sum(valid_hit(pro_indices) == 1);
            frac_correct_pro.value = num_pro_and_hit / length(pro_indices);
            
            anti_indices = find(strcmp(valid_pro_anti_type, 'anti'));
            n_anti.value = length(anti_indices);
            num_anti_and_hit = sum(valid_hit(anti_indices) == 1);
            frac_correct_anti.value = num_anti_and_hit / length(anti_indices);
            
        else
            frac_correct_pro.value = nan;
            frac_correct_anti.value = nan;
        end
        
        
        % number of match/nonmatch
        vec_match        = value(is_match_history);
        n_match.value    = length(vec_match(vec_match==1));
        n_nonmatch.value = length(vec_match(vec_match==0));

        % update sa-sb pair performance on the stim table
        StimulusSection(obj, 'update_performance', result);

        %% subtrial performance hits & viols
        if value(n_trials_stage) >= 10;   Last10TrialPerf.value = mean(hit_history(end-9:end), 'omitnan');   else  Last10TrialPerf.value = 0; end %#ok<NODEF>
        if value(n_trials_stage) >= 20;   Last20TrialPerf.value = mean(hit_history(end-19:end), 'omitnan');  else  Last20TrialPerf.value = 0; end        
        if value(n_trials_stage) >= 25;   Last25TrialPerf.value = mean(hit_history(end-24:end), 'omitnan');  else  Last25TrialPerf.value = 0; end 
        if value(n_trials_stage) >= 50;   Last50TrialPerf.value = mean(hit_history(end-49:end), 'omitnan');  else  Last50TrialPerf.value = 0; end    
        if value(n_trials_stage) >= 75;   Last75TrialPerf.value = mean(hit_history(end-74:end), 'omitnan');  else  Last75TrialPerf.value = 0; end
        if value(n_trials_stage) >= 100;  Last100TrialPerf.value = mean(hit_history(end-99:end), 'omitnan');  else Last100TrialPerf.value = 0; end
        if value(n_trials_stage) >= 150;  Last150TrialPerf.value = mean(hit_history(end-149:end), 'omitnan'); else Last150TrialPerf.value = 0; end
        
        if value(n_trials_stage) >= 10;   Last10TrialViol.value = mean(violation_history(end-9:end), 'omitnan');   else  Last10TrialViol.value = 0; end %#ok<NODEF>
        if value(n_trials_stage) >= 20;   Last20TrialViol.value = mean(violation_history(end-19:end), 'omitnan');  else  Last20TrialViol.value = 0; end 
        if value(n_trials_stage) >= 25;   Last25TrialViol.value = mean(violation_history(end-24:end), 'omitnan');  else  Last25TrialViol.value = 0; end 
        if value(n_trials_stage) >= 50;   Last50TrialViol.value = mean(violation_history(end-49:end), 'omitnan');  else  Last50TrialViol.value = 0; end    
        if value(n_trials_stage) >= 75;   Last75TrialViol.value = mean(violation_history(end-74:end), 'omitnan');  else  Last75TrialViol.value = 0; end
        if value(n_trials_stage) >= 100;  Last100TrialViol.value = mean(violation_history(end-99:end), 'omitnan');  else Last100TrialViol.value = 0; end
        if value(n_trials_stage) >= 150;  Last150TrialViol.value = mean(violation_history(end-149:end), 'omitnan'); else Last150TrialViol.value = 0; end

    %% spoke information
    case 'calculate_spoke_info'
        % function to calculate the time to the first spoke given 
        % the SMA in use and the crash history
        %
        % if cpoke or spoke SMA, will look for both the first l and r poke 
        % times and report which one (if any) was first
        %
        % in habituation SMA, or if recovering from a crash, everything is 
        % set to nans

        % check to see if in cpoke or spoke sma, the state we need to use
        % for determining trial start exists
        if ( (strcmp(value(SMA_implemented), 'cpoke') && ...
                ~isempty(parsed_events.states.cpoke)) || ...
                (strcmp(value(SMA_implemented), 'spoke') && ...
                ~isempty(parsed_events.states.spoke_t_start)) )

            %%% trial start is indicated by cpoke state entrance
            if strcmp(value(SMA_implemented), 'cpoke')
                t_start = parsed_events.states.cpoke(1);
                
            elseif strcmp(value(SMA_implemented), 'spoke')
                t_start = parsed_events.states.spoke_t_start(1);
            end
            
            %%% get first Left poke after t start, if no answer occured
            %%% will be an nan
            L_pokes = [parsed_events.pokes.L(:,1) - t_start];
            L_pokes = L_pokes(L_pokes > 0); % if less than 0, happened before t_start
            if isempty(L_pokes); first_L_poke_time= nan; 
            else; first_L_poke_time = L_pokes(1); end
            
            %%% repeat exact same thing for right pokes
            R_pokes = [parsed_events.pokes.R(:,1) - t_start];
            R_pokes = R_pokes(R_pokes > 0);
            if isempty(R_pokes); first_R_poke_time= nan; 
            else; first_R_poke_time = R_pokes(1); end
            
            poke_times = [first_L_poke_time, first_R_poke_time];
            
            %%% determine which side was poked first
            % no spokes for trial
            if sum(isnan(poke_times)) == 2
                side = 'n';
            % only one side poked- figure out wich one
            elseif sum(isnan(poke_times)) == 1
                if isnan(poke_times(1)); side = 'r'; else; side = 'l'; end 
            % if both are valid, take the minimum
            elseif poke_times(1) > poke_times(2)
                side = 'r';
            else
                side = 'l';
            end
            
            %%% send out summary
            first_spoke_history.value = [value(first_spoke_history) side]; % l, r or n
            first_lpoke_history.value = [value(first_lpoke_history) first_L_poke_time]; % time float or nan
            first_rpoke_history.value = [value(first_rpoke_history) first_R_poke_time]; % time float or nan
        
        %%% in SMA habiutation, or coming back from a crash just pack
        % with nans to keep lengths correct
        else 
            first_spoke_history.value = [value(first_spoke_history) side];
            first_lpoke_history.value = [value(first_lpoke_history) nan];
            first_rpoke_history.value = [value(first_rpoke_history) nan];
        end
        
    case 'calculate_cpoke_info'
        
        % only calculate if in cpoke SMA & there is data in the field
        if isfield(parsed_events.states, 'cpoke') && ...
                ~isempty(parsed_events.states.cpoke)
               
            % get the settling in state entries
            settling_ins = parsed_events.states.settling_in;
            
            % subtract off the valid poke
            n_settling_ins = size(parsed_events.states.settling_in, 1);
                    
            % calcualte the average length of failed settling in
            if n_settling_ins == 1
                avg_settling_in = NaN;
            else
                cpoke_durs = settling_ins(:, 2) - settling_ins(:, 1);
                avg_settling_in = mean(cpoke_durs(1:end-1), 'omitnan');
            end
            
            % gather cpoke data
            c_in = settling_ins(end,1);
            c_outs = parsed_events.pokes.C(:,2);
            c_outs = c_outs(c_outs > c_in);
                 
            %% calculate the length of the valid cpoke
            if ~value(fixation_required)
                % no fixation, not calculating c poke dur bc it's too messy
                % and not currently in use
                c_out = nan;        
            else
                % animal left c port before go state, but it's valid
                % NOTE: not in use, just dealing with edge case
                if ~isempty(parsed_events.states.cout_wait_for_go)
                    % assume that the last c out before the first c out
                    % wait for go is the end of the cpoke_dur
                    cout_wfg_time = min(parsed_events.states.cout_wait_for_go(:));
                    c_out =  max(c_outs(c_outs <= min(cout_wfg_time)));
                    
                % animal left c port after go state    
                elseif isempty(parsed_events.states.violation_state)        
                    % assume that the first c out after the go time
                    % is the end of the cpoke_dur
                    go_time = parsed_events.states.go_state(1);
                    c_out = min(c_outs(c_outs >= go_time));
               
                % animal left c port early and it was not valid
                else
                    % assume that the last c out before the violation state
                    % is the end of the cpoke_dur
                    violation_time = parsed_events.states.violation_state(1);
                    c_out = max(c_outs(c_outs < violation_time));
                end
            end

            % calculate cpoke dur given c_out
            cpoke_dur = c_out - c_in;
            if isempty(cpoke_dur)
                disp('cpoke empty!!!!!')
                cpoke_dur = nan;
            end
            
        else
            % spoke SMA or crashed trial
            n_settling_ins = nan;
            avg_settling_in = nan;
            cpoke_dur = nan;
        end
        
        n_settling_ins_history.value = [value(n_settling_ins_history) n_settling_ins];
        avg_settling_in_history.value = [value(avg_settling_in_history) avg_settling_in];
        cpoke_dur_history.value = [value(cpoke_dur_history) cpoke_dur];
        
       
    case 'calculate_spoke_during_give_del_info'
        %%
        % case that locates and sums number of incorrect pokes that occur
        % during pre-give delay. This can happen when
        % give_delay_strict_mode is off and animals have no penalty for
        % answering incorrectly.
        
        if isfield(parsed_events.states, 'cpoke') && ...
                ~isempty(parsed_events.states.go_state) && ...
                ~strcmp(value(give_type_implemented), 'none')
            
            % determine which side is the incorrect side
            if strcmp(value(current_side), 'LEFT')
                incorrect_side = "R"; 
            else
                incorrect_side = "L";
            end
            
            % determine start and end of pre give delay
            start_time =  parsed_events.states.go_state(1);
            end_time = parsed_events.states.pre_give_delay(2);
            
            % get all incorrect spokes and filter fone ones only contained
            % in pre give delay
            incorrect_poke_times = parsed_events.pokes.(incorrect_side)(:,1);
            incorrect_during_delay = incorrect_poke_times(incorrect_poke_times > start_time & incorrect_poke_times < end_time);
            
            if isempty(incorrect_during_delay)
                n_incorrect_spokes = 0;
            else
                n_incorrect_spokes = length(incorrect_during_delay(:,1));
            end
        else
            
            n_incorrect_spokes = nan;
        end
        
        incorr_spokes_during_give_del_history.value = [value(incorr_spokes_during_give_del_history) n_incorrect_spokes];
         

    % ------------------------------------------------------------------
    %              END SESSION
    % ------------------------------------------------------------------
    case 'end_session'  
        % TODO edit this
        %%% append comments for sessions table
        CommentsSection(obj, 'append_line', [value(curriculum) ' ; ']);
        CommentsSection(obj, 'append_line', [value(stage_name_persist) ' ; ']);
        CommentsSection(obj, 'append_line', ['days stage: ' num2str(value(n_days_stage)) ' ; ']);
        CommentsSection(obj, 'append_line', ['days training: ' num2str(value(n_days_training)) ' ; ']);
        CommentsSection(obj, 'append_line', ['valid: ' num2str(value(n_valid)) ' ; ']);
        CommentsSection(obj, 'append_line', ['early: ' num2str(value(n_early)) ' ; ']);
        CommentsSection(obj, 'append_line', ['match: ' num2str(value(n_match)) ' ; ']);
        CommentsSection(obj, 'append_line', ['nonmatch: ' num2str(value(n_nonmatch)) ' ; ']);
%         CommentsSection(obj, 'append_line', ['delay: ' num2str(max(value(delay_dur_history))) ' ; ']);
        
    % ------------------------------------------------------------------
    %              CRASH CLEANUP
    % ------------------------------------------------------------------
    case 'crash_cleanup'
        % last trial was a crash, keep dimensions constant but
        % fill with nans or clear variables
        warning('crash detected from bpod, running history clean up');

        % binary & single trial variables
        was_hit.value = 0; was_error.value = 0; 
        was_violation.value = 0; was_temp_error.value = 0;
        was_no_answer.value = 0; result.value = 5; 
        was_give = 0;
        prev_result.value    = 'Crash'; 
        
        n_trials.value       = value(n_trials) + 1;
        n_trials_stage.value = value(n_trials_stage) + 1;

        % session history
        hit_history.value         = [value(hit_history) nan];
        violation_history.value   = [value(violation_history) nan];
        temp_error_history.value  = [value(temp_error_history) nan];
        result_history.value      = [value(result_history) value(result)];
        timeout_history.value     = [value(timeout_history) nan];
        water_history.value       = [value(water_history) 0];

        x = rand; if x > 0.5; s = 'l'; else; s = 'r'; end
        side_history.value        = [value(side_history) s];
        
        is_match_history.value          = [value(is_match_history) nan];
        give_use_history.value          = [value(give_use_history) nan];
        water_delivered_history.value      = [value(water_delivered_history) 0]; 
        give_water_not_drunk_history.value = [value(give_water_not_drunk_history) false];
        trial_start_time_history.value  = [value(trial_start_time) nan];
        trial_dur_history.value         = [value(trial_dur_history) nan];
        wf_cpoke_dur_history.value      = [value(wf_cpoke_dur_history) nan];
        n_lpokes_history.value          = [value(n_lpokes_history) nan];
        n_cpokes_history.value          = [value(n_cpokes_history) nan];
        n_rpokes_history.value          = [value(n_rpokes_history) nan];
        valid_early_spoke_history.value = [value(valid_early_spoke_history) nan];
        first_spoke_history.value       = [value(first_spoke_history) s];
        first_lpoke_history.value       = [value(first_lpoke_history) nan];
        first_rpoke_history.value       = [value(first_rpoke_history) nan];
        n_settling_ins_history.value    = [value(n_settling_ins_history) nan];
        avg_settling_in_history.value   = [value(avg_settling_in_history) nan];
        cpoke_dur_history.value         = [value(cpoke_dur_history) nan];
        stage_history.value             = [value(stage_history) nan];
        stage_name_hist{end+1}          = nan; 
       
        % TODO - add in new vars related to pro anti
        incorr_spokes_during_give_del_history.value = [value(incorr_spokes_during_give_del_history) nan];
%         helper_history.value      = [value(helper_history) nan];


    % ------------------------------------------------------------------
    %              MAKE AND SEND SUMMARY
    % ------------------------------------------------------------------
        
    case 'make_and_send_summary'
        
        % this is the table that I (JRB) use to import trial level data
        % into datajoint. It's important that everything is the same 
        % length so that it can be converted into a data frame

        % the history variables I create (e.g. hit_history) are 
        % n trials x 1 doubles. The history varibles tracked via Bcontrol
        % (e.g. current_sa_history) are 1 x n trial cell arrays. 

        % Because I know the doubles work well w/ datajoint, I'm converting
        % all the saved out data to a double and transposing it to match dims 
        % I also use get_history to grab variables from plugins that are 
        % outside the scope of my protocol.

        %% animal performance
        pd.result           = value(result_history);
        pd.hits             = value(hit_history);
        pd.violations       = value(violation_history);
        pd.temperror        = value(temp_error_history);
        
        % performance metrics over session cell -> double
        pd.hit_rate         = cell2mat(frac_correct_history(1:n_done_trials).');
        pd.error_rate       = cell2mat(frac_error_history(1:n_done_trials).');
        pd.violation_rate   = cell2mat(frac_violations_history(1:n_done_trials).');
        pd.temp_error_rate  = cell2mat(frac_temp_error_history(1:n_done_trials).');
        
        % caluclations for n_done_trials - 1, need to append
        pd.n_lpokes         = [value(n_lpokes_history) nan];
        pd.n_cpokes         = [value(n_cpokes_history) nan];
        pd.n_rpokes         = [value(n_rpokes_history) nan];
        pd.trial_dur        = [value(trial_dur_history) nan];
        
        % start time is calculated on trial n
        pd.trial_start      = value(trial_start_time_history);
        
        % important to note these are *valid* early spokes not violations!
        pd.valid_early_spoke = value(valid_early_spoke_history);
        
        pd.first_spoke       = value(first_spoke_history);
        pd.first_lpoke       = value(first_lpoke_history);
        pd.first_rpoke       = value(first_rpoke_history);
        
        % cpoke duration (fixation must be required)
        pd.n_settling_ins    = value(n_settling_ins_history);
        pd.avg_settling_in   = value(avg_settling_in_history);
        pd.cpoke_dur         = value(cpoke_dur_history);
        % pd.wf_cpoke_dur      = value(wf_cpoke_dur_history);
        
        % poking during give delay (when strict mode is off)
        pd.n_incorr_spokes_during_give_del = value(incorr_spokes_during_give_del_history);

        %% trial structure & results
        pd.stage            = value(stage_history);
        pd.stage_name       = value(stage_name_hist(1:n_done_trials));
        pd.curriculum       = curriculum_history(1:n_done_trials).';
        pd.fix_experiment   = fixation_experiment_condition_history(1:n_done_trials).';
        pd.sides            = value(side_history);
        pd.SMA_set          = SMA_set_history(1:n_done_trials).'; % cell, not double!
        pd.is_match         = value(is_match_history);
        pd.auto_spoke_to_cpoke = get_history('owner', 'DMS2', 'name','auto_advance_spoke_to_cpoke', 'return_n_done_trials', 1).';

        % convert sound values to Khz and go from cell -> double
        pd.sa               = cell2mat(current_sa_history(1:n_done_trials).') / 1000;
        pd.sb               = cell2mat(current_sb_history(1:n_done_trials).') / 1000;
        % adding the double call bc cell -> logical -> double
        pd.stimuli_on       = double(cell2mat(stimuli_on_history(1:n_done_trials).'));
        
        % get trial duration variables
        pd.settling_in_dur  = cell2mat(settling_in_dur_history(1:n_done_trials).');
        pd.legal_cbreak_dur = cell2mat(legal_cbreak_dur_history(1:n_done_trials).');
        pd.pre_dur          = cell2mat(pre_dur_history(1:n_done_trials).');
        pd.adj_pre_dur      = cell2mat(adjusted_pre_dur_history(1:n_done_trials).');
        pd.stimulus_dur     = cell2mat(stimulus_dur_history(1:n_done_trials).');
        pd.delay_dur        = cell2mat(delay_dur_history(1:n_done_trials).');
        pd.post_dur         = cell2mat(post_dur_history(1:n_done_trials).');
        pd.sb_extra_dur     = cell2mat(sb_extra_history(1:n_done_trials).');
        pd.viol_off_dur     = cell2mat(viol_off_dur_history(1:n_done_trials).');
        pd.pre_go_dur       = cell2mat(pre_go_dur_history(1:n_done_trials).');
        pd.inter_trial_dur  = cell2mat(inter_trial_dur_history(1:n_done_trials).');

        % go and reward info. Some are SPH history vars, others are made in
        % this script because they are implemented at strings and I want them
        % to be coded as ints. E.g. give_type = 'water' --> 1
        pd.go_type          = go_type_history(1:n_done_trials).';
        pd.go_dur           = cell2mat(go_dur_history(1:n_done_trials).');
        pd.give_type_set    = give_type_set_history(1:n_done_trials).';
        pd.give_type_imp    = give_type_implemented_history(1:n_done_trials).';
        pd.give_frac        = cell2mat(give_frac_history(1:n_done_trials).');
        pd.give_delay_dur   = cell2mat(give_del_dur_history(1:n_done_trials).');
        pd.give_xtra_light_delay_dur = cell2mat(extra_give_light_del_dur_history(1:n_done_trials).');
        pd.give_use         = value(give_use_history);
        
        pd.give_del_growth_type              = value(give_del_growth_history(1:n_done_trials)).';
        pd.give_del_adagrow_trial_subset     = value(give_del_growth_trial_subset_history(1:n_done_trials)).';
        pd.give_del_adagrow_alpha_plus       = cell2mat(give_del_adaptive_alpha_plus_history(1:n_done_trials).');
        pd.give_del_adagrow_alpha_minus      = cell2mat(give_del_adaptive_alpha_minus_history(1:n_done_trials).');
        pd.give_del_adagrow_threshold        = cell2mat(give_del_adaptive_threshold_history(1:n_done_trials).');
        pd.give_del_adagrow_subset_prev_perf = cell2mat(give_del_perf_trial_subset_history(1:n_done_trials).');
        pd.give_del_adagrow_step_size        = cell2mat(give_del_adaptive_step_sec_history(1:n_done_trials).');
        pd.give_del_adagrow_window_size      = cell2mat(give_del_perf_trial_window_history(1:n_done_trials).');
        
        pd.replay_on        = cell2mat(replay_on_history(1:n_done_trials).');
        pd.timeouts         = value(timeout_history);
        pd.water_delivered      = value(water_delivered_history);
        pd.give_water_not_drunk = value(give_water_not_drunk_history);
%         pd.helper           = value(helper_history);

        % get crashed history information. Note the length of this variable
        % is only update after a crash, not every trial.
        if isempty(crashed_history) % no crashes
            pd.crash_hist = zeros(1, n_done_trials);
        % crash happened, but not on last trial
        elseif length(crashed_history) < n_done_trials 
            last_idx = length(crashed_history); 
            ch = value(crashed_history);
            ch(last_idx+1:n_done_trials) = 0;
            pd.crash_hist = ch;
        % crash happened on last trial, truncate if needed
        else
            pd.crash_hist = crashed_history(1:n_done_trials);
        end
        
        % pro anti vars
        pd.pro_stim_set          = value(pro_preset_history(1:n_done_trials)).';
        pd.anti_stim_set         = value(anti_preset_history(1:n_done_trials)).';
        pd.pro_anti_block_type   = value(pro_anti_block_type_history(1:n_done_trials)).';
        pd.block_switch_type     = value(block_switch_type_history(1:n_done_trials)).';
        pd.pro_hit_rate          = cell2mat(frac_correct_pro_history(1:n_done_trials).');
        pd.anti_hit_rate         = cell2mat(frac_correct_anti_history(1:n_done_trials).');
        
        pd.block_switch_sound_on   = cell2mat(block_switch_sound_history(1:n_done_trials).');
        pd.block_swtich_sound_type = value(block_switch_sound_type_history(1:n_done_trials)).';
        pd.block_switch_sound_dur  =  cell2mat(block_switch_sound_dur_history(1:n_done_trials).');
        
        % fetch variables outside the scope of our functions and note that this
        % only works for GUI vars if no overlapping names are found
        pd.stim_set          = get_history('owner', 'DMS2', 'name', 'presets','return_n_done_trials', 1).';
        pd.was_block_swtich  = get_history('owner', 'DMS2', 'name', 'was_block_switch','return_n_done_trials', 1).';
        pd.n_blocks          = get_history('owner', 'DMS2', 'name', 'n_blocks','return_n_done_trials', 1).';
        pd.block_size        = get_history('owner', 'DMS2', 'name', 'block_size','return_n_done_trials', 1).';
        pd.pro_anti_on       = get_history('owner', 'DMS2', 'name', 'pro_anti_on','return_n_done_trials', 1).';
        pd.give_delay_strict = get_history('owner', 'DMS2', 'name', 'give_delay_strict_mode','return_n_done_trials', 1).';
        pd.pro_prob          = get_history('owner', 'DMS2', 'name', 'pro_prob','return_n_done_trials', 1).';
        pd.pro_anti_hit_thresh     = get_history('owner', 'DMS2', 'name', 'pro_anti_hit_threshold','return_n_done_trials', 1).';
        pd.pro_anti_viol_thresh    = get_history('owner', 'DMS2', 'name', 'pro_anti_viol_threshold','return_n_done_trials', 1).';
        pd.max_blocks        =   get_history('owner', 'DMS2', 'name', 'max_blocks','return_n_done_trials', 1).';
        pd.volume_multiplier = get_history('owner', 'DMS2', 'name', 'volume_multiplier', 'return_n_done_trials',1).';
        pd.l_water_vol       = get_history('owner', 'DMS2', 'name', 'Left_volume','return_n_done_trials', 1).';
        pd.r_water_vol       = get_history('owner', 'DMS2', 'name', 'Right_volume','return_n_done_trials', 1).';
        pd.ab_l_prob         = get_history('owner', 'DMS2', 'name', 'LtProb', 'return_n_done_trials', 1).';
        pd.ab_r_prob         = get_history('owner', 'DMS2', 'name', 'RtProb', 'return_n_done_trials', 1).';
        pd.ab_beta           = get_history('owner', 'DMS2', 'name', 'LocalBeta', 'return_n_done_trials', 1).';
        pd.ab_tau            = get_history('owner', 'DMS2', 'name', 'BiasTau', 'return_n_done_trials', 1).';
        pd.exp_del_tau       = get_history('owner', 'DMS2', 'name','exp_delay_Tau', 'return_n_done_trials', 1).';
        pd.exp_del_min       = get_history('owner', 'DMS2', 'name','exp_delay_Min', 'return_n_done_trials', 1).';
        pd.exp_del_max       = get_history('owner', 'DMS2', 'name','exp_delay_Max', 'return_n_done_trials', 1).';

        % test lengths are correct
        lens = structfun(@length, pd);
        if ~all(lens == n_done_trials)
            warning('!!! pd lengths are off !!!');
            CommentsSection(obj, 'append_line', 'pd lens off');
        end
        sendsummary(obj, 'sides', pd.sides, 'protocol_data', pd);% DB
    
    % ------------------------------------------------------------------
    %              SHOW HIDE
    % ------------------------------------------------------------------
    
    case 'show_hide'
        if HistoryShow == 0 set(value(myfig), 'Visible', 'off');
        else                set(value(myfig), 'Visible', 'on');
        end
end
