%% DMS History Section 
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
        
        %%% info about last trial
        DispParam(obj, 'prev_result','', x, y, 'labelfraction', 0.50,...  
             'TooltipString', 'what happened on prev trial'); next_row(y, 1.1);

        DispParam(obj, 'prev_sa',0, x, y, 'labelfraction', 0.55,...
             'position', [x y 100 20],...
             'TooltipString', 'previous trial sa in kHz');
        DispParam(obj, 'prev_sb',0, x, y, 'labelfraction', 0.55,...
             'position', [x+100 y 100 20],...
             'TooltipString', 'previous trial sa in kHz');next_row(y);

        %%% number of match/nonmatch trials given
        DispParam(obj, 'n_match',0, x, y, 'labelfraction', 0.55,...
            'label','n match','position', [x y 100 20],...
            'TooltipString', 'number of match trials given');
        DispParam(obj, 'n_nonmatch',0, x, y, 'labelfraction', 0.55,...
            'label','n nmatch','position', [x+100 y 100 20],...
            'TooltipString', 'number of nonmatch trials given');
        next_row(y);

        %%% fraction temp error
        DispParam(obj, 'frac_temp_error',0, x, y, 'labelfraction', 0.55,...
            'label','/terror','position', [x y 100 20],...
            'TooltipString', 'frac of valid trials w/ temp error retry -> hit');
    
        %%% fraction error (no retry)
        DispParam(obj, 'frac_error',0, x, y, 'labelfraction', 0.55,...
            'label','/error','position', [x+100 y 100 20],...
            'TooltipString', 'frac of valid trials incorrect, incl incorrect retry');
        next_row(y,1.1);

        %%% fraction correct
        DispParam(obj, 'frac_correct',0, x, y, 'labelfraction', 0.55,...
            'label','/hit','position', [x y 100 20],...
            'TooltipString', 'frac of valid trials correct');

        %%% fraction violations
        DispParam(obj, 'frac_violations',0, x, y, 'labelfraction', 0.55,...
            'label','/viol','position', [x+100 y 100 20],...
            'TooltipString', 'frac of nonvalid trials');next_row(y,1.1);

        %%% number of valid trials
        DispParam(obj, 'n_valid',0, x, y, 'labelfraction', 0.55,...
            'position', [x y 100 20],...
            'TooltipString', 'number of trials w/o violation');
        
        %%% number of early spoke trials
        DispParam(obj, 'n_early',0, x, y, 'labelfraction', 0.55,...
            'position', [x+100 y 100 20],...
            'TooltipString', 'number of trails would be violations, but viol is off');
        next_row(y);
        
        %%% total number of trials
        DispParam(obj, 'n_trials',0, x, y, 'labelfraction', 0.50,...
            'position', [x y 200 20],...
            'TooltipString', 'total number of trials in a session'); next_row(y);

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
        SoloParamHandle(obj, 'violation_history', 'value',[]);
        SoloParamHandle(obj, 'temp_error_history', 'value', []);
        SoloParamHandle(obj, 'timeout_history', 'value', []);
        SoloParamHandle(obj, 'result_history', 'value', []);  
        SoloParamHandle(obj, 'side_history', 'value',[]);
        SoloParamHandle(obj, 'sa_history', 'value',[]);
        SoloParamHandle(obj, 'sb_history', 'value',[]);
        SoloParamHandle(obj, 'match_history', 'value', []); 
        SoloParamHandle(obj, 'delay_history', 'value', []);
        SoloParamHandle(obj, 'fixation_history', 'value', []);
        SoloParamHandle(obj, 'helper_history', 'value', []);
        SoloParamHandle(obj, 'stage_history', 'value',[]);
        SoloParamHandle(obj, 'early_spoke_history', 'value', []);
        % water_history used for Adlibgui becasue want to track
        % temperror water consumption and hit history marks as 0
        SoloParamHandle(obj, 'water_history', 'value', []); 

        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%    SEND OUT VARS    %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        DeclareGlobals(obj, 'ro_args', {'last10trialperf','last25trialperf',...
                                        'last50trialperf', 'last75trialperf',...
                                        'last100trialperf', 'last150trialperf',...
                                        'prev_result', 'prev_sa', 'prev_sb',...
                                        'frac_temp_error', 'frac_error',...
                                        'frac_correct', 'frac_violations',...
                                        'n_trials', 'n_valid', 'was_hit',...
                                        'was_error', 'was_violation', 'was_temp_error',...
                                        'result', 'hit_history',...
                                        'violation_history', 'temp_error_history',...
                                        'timeout_history', 'result_history',...
                                        'side_history', 'sa_history',...
                                        'sb_history',...
                                        'delay_history', 'fixation_history',...
                                        'helper_history',... 
                                        'stage_history','match_history',...
                                        'n_match', 'n_nonmatch',...
                                        'n_early', 'early_spoke_history',...
                                        'water_history'});

        
    % ------------------------------------------------------------------
    %              PREPARE NEXT TRIAL
    % ------------------------------------------------------------------
        
    case 'prepare_next_trial'

        %%% if we haven't done any trials yet, skip this case
        if(length(value(n_done_trials))==0 || isempty(parsed_events) || ~isfield(parsed_events,'states'))
            return;
        end

        %%% Binary variables about trial result
        % clear results from last trial
        was_hit.value = 0; was_error.value = 0; 
        was_violation.value = 0; was_temp_error.value = 0;
       
        try
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
            elseif ~isempty(parsed_events.states.temp_error_state) && ~isempty(parsed_events.states.hit_state)
                was_temp_error.value = 1;
                result.value         = 4; 
                prev_result.value    = 'TempError';
            else
                error('Result of trial unknown, crash was not detected, trial counts will be off');
            end
        catch
            % if in SMA spoke, you can only get it 'right' and peh is
            % different 
            was_hit.value        = 1;
            result.value         = 1;
            prev_result.value    = 'Hit';

        end
        % check validity
        if value(was_hit) + value (was_error) + value(was_violation) + value(was_temp_error) ~=1
            error('Multiple results found for single trial!');
        end
        
        % check for early spoke (can only happen in viol penalty is off)
        if isfield(parsed_events.states, 'early_spoke_state') && ...
                ~isempty(parsed_events.states.early_spoke_state)
            n_early.value = value(n_early) + 1;
            early_spoke_history.value = [value(early_spoke_history) 1];
               
        else
            early_spoke_history.value = [value(early_spoke_history) 0];
                
        end

        %%% History Variables
        % animal performance
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
        end

        % side history
        if strcmp(value(current_side), 'LEFT'); s = 'l'; else; s = 'r'; end
        side_history.value       = [value(side_history) s];
        
        %delay & fixation info 
        delay_history.value      = [value(delay_history) round(value(delay_dur),2)];
        fixation_history.value   = [value(fixation_history) round(value(cp_fixation_dur),2)];
        
        % sound info
        sa_history.value         = [value(sa_history) value(current_sa)];
        prev_sa.value            = value(sa_history(end)) / 1000; % kHz
        sb_history.value         = [value(sb_history) value(current_sb)];
        prev_sb.value            = value(sb_history(end)) / 1000; % kHz
        
        % DMS info
        if value(prev_sa) == value(prev_sb)
            match_history.value  = [value(match_history) 1];
        else
            match_history.value  = [value(match_history) 0]; 
        end
        
        % Helper info
        if strcmp(value(in_helper_block), 'TRUE')
            helper_history.value = [value(helper_history) 1];
        else
            helper_history.value = [value(helper_history) 0];
        end
        
        % Stage info
        stage_history.value      = [value(stage_history) stage_number];

        %%% Ongoing Session Performance
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

        % fraction match
        vec_match        = value(match_history);
        n_match.value    = length(vec_match(vec_match==1));
        n_nonmatch.value = length(vec_match(vec_match==0));

        % subtrial performance hits
        if value(n_trials_stage) >= 10;   Last10TrialPerf.value = mean(hit_history(end-9:end), 'omitnan');   else  Last10TrialPerf.value = 0; end %#ok<NODEF>
        if value(n_trials_stage) >= 25;   Last25TrialPerf.value = mean(hit_history(end-24:end), 'omitnan');  else  Last25TrialPerf.value = 0; end 
        if value(n_trials_stage) >= 50;   Last50TrialPerf.value = mean(hit_history(end-49:end), 'omitnan');  else  Last50TrialPerf.value = 0; end    
        if value(n_trials_stage) >= 75;   Last75TrialPerf.value = mean(hit_history(end-74:end), 'omitnan');  else  Last75TrialPerf.value = 0; end
        if value(n_trials_stage) >= 100;  Last100TrialPerf.value = mean(hit_history(end-99:end), 'omitnan');  else Last100TrialPerf.value = 0; end
        if value(n_trials_stage) >= 150;  Last150TrialPerf.value = mean(hit_history(end-149:end), 'omitnan'); else Last150TrialPerf.value = 0; end
        
        % subtrial performance violations
        if value(n_trials_stage) >= 10;   Last10TrialViol.value = mean(violation_history(end-9:end), 'omitnan');   else  Last10TrialViol.value = 0; end %#ok<NODEF>
        if value(n_trials_stage) >= 25;   Last25TrialViol.value = mean(violation_history(end-24:end), 'omitnan');  else  Last25TrialViol.value = 0; end 
        if value(n_trials_stage) >= 50;   Last50TrialViol.value = mean(violation_history(end-49:end), 'omitnan');  else  Last50TrialViol.value = 0; end    
        if value(n_trials_stage) >= 75;   Last75TrialViol.value = mean(violation_history(end-74:end), 'omitnan');  else  Last75TrialViol.value = 0; end
        if value(n_trials_stage) >= 100;  Last100TrialViol.value = mean(violation_history(end-99:end), 'omitnan');  else Last100TrialViol.value = 0; end
        if value(n_trials_stage) >= 150;  Last150TrialViol.value = mean(violation_history(end-149:end), 'omitnan'); else Last150TrialViol.value = 0; end

    % ------------------------------------------------------------------
    %              END SESSION
    % ------------------------------------------------------------------
    case 'end_session'  

        %%% append comments for sessions table
        CommentsSection(obj, 'append_line', [value(curriculum) ' ; ']);
        CommentsSection(obj, 'append_line', [value(stage_name_persist) ' ; ']);
        CommentsSection(obj, 'append_line', ['days stage: ' num2str(value(n_days_stage)) ' ; ']);
        CommentsSection(obj, 'append_line', ['days training: ' num2str(value(n_days_training)) ' ; ']);
        CommentsSection(obj, 'append_line', ['valid: ' num2str(value(n_valid)) ' ; ']);
        CommentsSection(obj, 'append_line', ['early: ' num2str(value(n_early)) ' ; ']);
        CommentsSection(obj, 'append_line', ['match: ' num2str(value(n_match)) ' ; ']);
        CommentsSection(obj, 'append_line', ['nonmatch: ' num2str(value(n_nonmatch)) ' ; ']);
        CommentsSection(obj, 'append_line', ['delay: ' num2str(max(value(delay_history))) ' ; ']);
        CommentsSection(obj, 'append_line', ['fixation: ' num2str(max(value(fixation_history(2:end)))) ' ; ']);

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
        result.value         = 5; 
        prev_result.value    = 'Crash'; 
        prev_sa.value        = nan;
        prev_sb.value        = nan;
        n_trials.value       = value(n_trials) + 1;
        n_trials_stage.value = value(n_trials_stage) + 1;

        % session history
        hit_history.value        = [value(hit_history) nan];
        violation_history.value  = [value(violation_history) nan];
        temp_error_history.value = [value(temp_error_history) nan];
        result_history.value     = [value(result_history) value(result)];
        timeout_history.value    = [value(timeout_history) nan];
        sa_history.value         = [value(sa_history) value(prev_sa)];
        sb_history.value         = [value(sb_history) value(prev_sb)];
        delay_history.value      = [value(delay_history) nan];
        fixation_history.value   = [value(fixation_history) nan];
        match_history.value      = [value(match_history) nan];
        helper_history.value     = [value(helper_history) nan];
        stage_history.value      = [value(stage_history) nan];

        x = rand; if x > 0.5; s = 'l'; else; s = 'r'; end
        side_history.value       = [value(side_history) s];

    % ------------------------------------------------------------------
    %              MAKE AND SEND SUMMARY
    % ------------------------------------------------------------------
        
    case 'make_and_send_summary'
        
        %%% update protocol data (pd) struct that is saved in sessions table
        pd.hits            = value(hit_history);
        pd.temperror       = value(temp_error_history);
        pd.sides           = value(side_history);
        pd.result          = value(result_history);
        pd.sa              = value(sa_history);
        pd.sb              = value(sb_history);
        pd.dms_type        = value(match_history);
        pd.delay           = value(delay_history);
        pd.fixation        = value(fixation_history);
        pd.timeouts        = value(timeout_history);
        pd.helper          = value(helper_history);
        pd.stage           = value(stage_history);

        sendsummary(obj, 'sides', pd.sides, 'protocol_data', pd); 

    % ------------------------------------------------------------------
    %              SHOW HIDE
    % ------------------------------------------------------------------
    
    case 'show_hide'
        if HistoryShow == 0 set(value(myfig), 'Visible', 'off');
        else                set(value(myfig), 'Visible', 'on');
        end
end
