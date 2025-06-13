% @PBups/RewardsSection.m
% Bing, March 2008


% [x, y] = YOUR_SECTION_NAME(obj, action, x, y)
%
% Section that takes care of YOUR HELP DESCRIPTION
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%            'init'      To initialise the section and set up the GUI
%                        for it
%
%            'reinit'    Delete all of this section's GUIs and data,
%                        and reinit, at the same position on the same
%                        figure as the original section GUI was placed.
%
% x, y     Relevant to action = 'init'; they indicate the initial
%          position to place the GUI at, in the current figure window
%
% RETURNS:
% --------
%
% [x, y]   When action == 'init', returns x and y, pixel positions on
%          the current figure, updated after placing of this section's GUI.
%


function [x, y] = RewardsSection(obj, action, x, y)

GetSoloFunctionArgs;

switch action
    case 'init',
        % Save the figure and the position in the figure where we are
        % going to start adding GUI elements:
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);
        
        
        NumeditParam(obj, 'error_delay', 0.001, x, y, ...
            'TooltipString', sprintf(['The time (in sec) between answer poke and the initiation of the error feedback sound' ...
            '\nnote that once the rat has made the answer poke, his response is locked in' ...
            '\nand he cannot go to the other side' ...
            '\nThis function does not apply in the temporary_punishment schedule'])); next_row(y);
        
        ToggleParam(obj, 'locked_in_sound', 0, x, y, 'position', [x y 100 20], ...
            'OnString', 'lock sound ON', 'OffString', 'lock sound OFF', ...
            'TooltipString', sprintf(['\nsound that is triggered at end of wait_for_spoke ' ...
            '\nto help the rat realize he has locked in an answer poke']));
        ToggleParam(obj, 'locked_in_sound_show', 0, x, y, 'position', [x+101 y 100 20], ...
            'OnString', 'lock sound showing', 'OffString', 'lock sound hidden', ...
            'TooltipString', sprintf('\nshow or hide the interface for the locked_in_sound'));
        set_callback(locked_in_sound_show, {mfilename 'locked_in_sound_show'}); %#ok<NODEF>
        next_row(y);
        % Put up the little figure for the locked_in_sound, set up the SoundUI,
        % then close the figure:
        currfig = double(gcf); cfpos = get(currfig, 'Position');
        SoloParamHandle(obj, 'locked_in_sound_fig', 'saveable', 0,'value', ...
            double(figure('Position', [cfpos(1)+487 cfpos(2)+289 218 170], 'Name', 'locked_in_sound', ...
            'CloseRequestFcn', [mfilename '(' class(obj) ', ''locked_in_sound_hide'')'])));
        myx = 10; myy = 10;
        SoundInterface(obj, 'add', 'locked_in_sound', myx, myy);
        SoundInterface(obj, 'set', 'locked_in_sound', 'Style', 'Tone', 'Vol', 0.004, ...
            'Freq1', 6000, 'Dur1', 0.05, 'Loop', 0, 'Bal', 0);
        locked_in_sound_show.value = 0;
        set(value(locked_in_sound_fig), 'Visible', 'off');
        figure(currfig);
        
        
        NumeditParam(obj, 'reward_delay', 0.001, x, y, ...
            'TooltipString', sprintf('if reward_timing is from spoke, delay between correct side choice and reward delivery;')); next_row(y);
        MenuParam(obj, 'reward_timing', {'from spoke'}, 1, x, y, ...
            'labelfraction', 0.4, ...
            'TooltipString', 'from when the reward_delay timer is set, from side or 1st center poke'); next_row(y);
        MenuParam(obj, 'reward_type', {'gamma'; 'delta clicks';'free_choice'}, 2, x, y, ...
            'labelfraction', 0.4, ...
            'TooltipString', 'Reward based on generative gamma or actual click difference. \nFor the latter, it is best to fixed T stimulus timing.'); next_row(y);
        NumeditParam(obj, 'left_wtr_mult', 1, x, y, ...
            'position', [x y 100 20], ...
            'labelfraction', 0.7, ...
            'TooltipString', 'all left reward times are multiplied by this number');
        NumeditParam(obj, 'right_wtr_mult', 1, x, y, ...
            'position', [x+100 y 100 20], ...
            'labelfraction', 0.7, ...
            'TooltipString', 'all right reward times are multiplied by this number');
        
        next_row(y, 1.25);
        
        DispParam(obj, 'n_left_pokes', 0, x, y,...
            'position', [x y 100 20], ...
            'labelfraction', 0.7);
        DispParam(obj, 'n_right_pokes', 0, x, y,...
            'position', [x+100 y 100 20], ...
            'labelfraction', 0.7); next_row(y);
        DispParam(obj, 'n_center_pokes', 0, x, y); next_row(y);
        DispParam(obj, 'hit_streak', 0, x, y, ...
            'TooltipString', 'number of continuous hit trials (2 hit strials -> 1 hit_streak)');
        next_row(y);
        DispParam(obj, 'Last150Perf', 0, x, y, ...
            'TooltipString', 'average hit frac in the last 150 trials ignoring violations'); next_row(y);
        DispParam(obj, 'Last50Perf', 0, x, y, ...
            'TooltipString', 'average hit frac in the last 50 trials ignoring violations'); next_row(y);
        DispParam(obj, 'Last30Perf', 0, x, y, ...
            'TooltipString', 'average hit frac in the last 30 trials ignoring violations'); next_row(y);
        DispParam(obj, 'mean_hitfrac', 0, x, y, ...
            'TooltipString', 'average hit frac, ignoring violation trials'); next_row(y);
        DispParam(obj, 'cpoke_violations', 0, x, y, ...
            'TooltipString', 'number of cpoke violations (where the rat did not complete cpokes within wait_for_cpoke_grace)');  next_row(y);
        DispParam(obj, 'nWaitViol', 0, x, y, ...
            'position', [x y 100 20], ...
            'labelfraction', 0.7, ...
            'TooltipString', 'number of wait violations (where the rat chose correct port but left for longer than LegalWaitBreak');
        DispParam(obj, 'nWaitViolTrials', 0, x, y, ...
            'position', [x+100 y 100 20], ...
            'labelfraction', 0.7, ...
            'TooltipString', 'number of trials where rat had wait violation (where the rat chose correct port but left for longer than LegalWaitBreak'); next_row(y);
        
        DispParam(obj, 'nRewarded', 0, x, y, ...
            'position', [x y 100 20], ...
            'labelfraction', 0.7, ...
            'TooltipString', 'number of trials for which water was dispensed');
        DispParam(obj, 'nCorrect', 0, x, y, ...
            'position', [x+100 y 100 20], ...
            'labelfraction', 0.7, ...
            'TooltipString', 'number of trials where the response was correct'); next_row(y);
        DispParam(obj, 'nTrials',  0, x, y); next_row(y);
        
        SoloFunctionAddVars('StateMatrixSection', 'ro_args', ...
            {'hit_streak'; ...
            'reward_delay'; 'reward_timing'; ...
            'error_delay'; 'locked_in_sound'; ...
            'left_wtr_mult'; 'right_wtr_mult';...
            });
        
        %   Let SidesSection have read access to the reware type
        SoloFunctionAddVars('SidesSection', 'ro_args', {'reward_type'});
        
        
        SubheaderParam(obj, 'title', mfilename, x, y);
        next_row(y, 1.25);
        
        feval(mfilename, obj, 'locked_in_sound_show');
        
        
    case 'next_trial',
        % update information for the PREVIOUS trial (since we are preparing
        % the next trial before the current trial finishes)
        if n_done_trials > 1,
            feval(mfilename,obj,'update_trial_info',parsed_events_history{end});
        end
    case 'update'
        
        if n_done_trials > 0,
            n_right_pokes.value  = n_right_pokes + size(latest_parsed_events.pokes.R, 1);
            n_left_pokes.value   = n_left_pokes + size(latest_parsed_events.pokes.L, 1);
            n_center_pokes.value = n_center_pokes + size(latest_parsed_events.pokes.C, 1);
        end;
        
        
    case 'end_session' % check the current trial
        
        prepNextTrialReached = rows(parsed_events.states.prep_next_trial_state) > 0;
        
        if prepNextTrialReached % then previous trial was recorded, so record info about this trial
            feval(mfilename,obj,'update_trial_info',parsed_events);
        elseif n_done_trials > 1 % record previous trial
            feval(mfilename,obj,'update_trial_info',parsed_events_history{end});
        end
        
    case 'update_trial_info'
        trialEvents = x;
        
        wasTempPun = isfield(trialEvents.states, 'temporary_punishment') && ...
            rows(trialEvents.states.temporary_punishment) > 0;
        
        wasCorrect = (isfield(trialEvents.states, 'wait_wave_trig') &&...
            rows(trialEvents.states.wait_wave_trig) > 0) || ...
            (rows(trialEvents.states.hit_state) > 0);
        
        wasViolState = isfield(trialEvents.states, 'violation_state') &&...
            rows(trialEvents.states.violation_state) > 0;
        
        wasRewarded = rows(trialEvents.states.hit_state) > 0; %  only rewarded if gets past wait_state to hit_state
        
        wasWaitViol = isfield(trialEvents.waves, 'wait_viol_wave');
        
        wasCpokeViol = (isfield(trialEvents.states, 'cpoke1') &&...
            rows(parsed_events.states.cpoke1) > 1) ...
            || ~isfield(trialEvents.states, 'cpoke1')...
            || (isfield(trialEvents.states, 'temp_violation') && ...
            rows(trialEvents.states.temp_violation>0)) ...
            || (isfield(trialEvents.states, 'violation_state') && ...
            rows(trialEvents.states.violation_state>0));
        
        wasCorrectWait = isfield(trialEvents.states, 'wait_state') && ...
            rows(trialEvents.states.wait_state);
        wasErrorWait = isfield(trialEvents.states, 'incorrect_wait_state') && ...
            rows(trialEvents.states.incorrect_wait_state);
        
        if wasTempPun,
            hit_history.value = [hit_history(:) ; 0];
        elseif wasCorrect,
            hit_history.value = [hit_history(:) ; 1];
        elseif wasViolState,
            hit_history.value = [hit_history(:) ; NaN];
        else
            hit_history.value = [hit_history(:) ; 0];
        end;
        
        if wasCpokeViol, % in one cpoke w/ legal cbreaks mode, more than one cpoke1 state means there was a violation that had a temp pun
            cpoke_violations.value = cpoke_violations + 1;
            violation_history.value = [violation_history(:) ; 1];
        else
            violation_history.value = [violation_history(:) ; 0];
        end;
        
        if wasRewarded,
            nRewarded.value = nRewarded + 1;
            rew_history.value = [rew_history(:); 1];
        else
            rew_history.value = [rew_history(:); 0];
        end
        
        if wasWaitViol,
            nWaitViol.value = nWaitViol + rows(trialEvents.waves.wait_viol_wave);
            nWaitViolTrials.value = nWaitViolTrials + ~isempty(trialEvents.waves.wait_viol_wave);
        end;
        
        if wasCorrectWait
            wait_time_history.value = [wait_time_history(:); trialEvents.states.wait_state(end,end)-trialEvents.states.wait_state(1,1)];
        elseif wasErrorWait
            wait_time_history.value = [wait_time_history(:); trialEvents.states.incorrect_wait_state(end,end)-trialEvents.states.incorrect_wait_state(1,1)];
        else
            wait_time_history.value = [wait_time_history(:); nan];
        end
        
        if hit_history(length(hit_history)) == 1, nCorrect.value = nCorrect + 1; end;
        if nTrials > 0, mean_hitfrac.value = nanmean(hit_history(:)); end;
        if nTrials > 15, Last15Perf.value = nansum(hit_history(end-14:end))/15; end;
        if nTrials > 30, Last30Perf.value = nansum(hit_history(end-29:end))/30; end;
        if nTrials > 50, Last50Perf.value = nansum(hit_history(end-49:end))/50; end;
        if nTrials > 150, Last150Perf.value = nansum(hit_history(end-149:end))/150; end;
        
        if n_done_trials > 2,
            if hit_history(end)==1 && hit_history(end-1)==1,
                hit_streak.value = hit_streak + 1;
            else
                hit_streak.value = 0;
            end;
        end;
        
        nTrials.value = nTrials + 1;
        
        
    case 'locked_in_sound_hide'
        locked_in_sound_show.value = 0;
        set(value(locked_in_sound_fig), 'Visible', 'off');
        
        
    case 'locked_in_sound_show'
        if locked_in_sound_show==1, %#ok<NODEF>
            set(value(locked_in_sound_fig), 'Visible', 'on');
        else
            set(value(locked_in_sound_fig), 'Visible', 'off');
        end;
        
    case 'close'
        if exist('locked_in_sound_fig', 'var'),
            delete(value(locked_in_sound_fig));
        end;
        
    case 'reinit',
        currfig = double(gcf);
        
        % Get the original GUI position and figure:
        x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));
        
        % Delete all SoloParamHandles who belong to this object and whose
        % fullname starts with the name of this mfile:
        delete_sphandle('owner', ['^@' class(obj) '$'], ...
            'fullname', ['^' mfilename]);
        
        % Reinitialise at the original GUI position and figure:
        [x, y] = feval(mfilename, obj, 'init', x, y);
        
        % Restore the current figure:
        figure(currfig);
        
        
end;

        
        
    

end




