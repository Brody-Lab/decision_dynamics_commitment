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
% Modified by Adrian Bondy 2017 to correctly calculate hit_streak



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
    NumeditParam(obj, 'reward_delay', 0.001, x, y, ...
        'TooltipString', sprintf(['if reward_timing is from spoke, delay between correct side choice and reward delivery;' ...
                                  '\nif reward_timing is from cpoke, delay between 1st cpoke and reward delivery'])); next_row(y);
    MenuParam(obj, 'reward_timing', {'from spoke'; 'from cpoke'}, 1, x, y, ...
        'labelfraction', 0.4, ...
        'TooltipString', 'from when the reward_delay timer is set, from side or 1st center poke'); next_row(y);
    MenuParam(obj, 'reward_type', {'gamma'; 'delta clicks';'free_choice'}, 1, x, y, ...
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
    next_row(y, 1.5);
    
    DispParam(obj, 'n_right_pokes', 0, x, y); next_row(y);
    DispParam(obj, 'n_left_pokes', 0, x, y); next_row(y);
    DispParam(obj, 'hit_streak', 0, x, y, ...
        'TooltipString', 'number of continuous hit trials');
    next_row(y);
    DispParam(obj, 'last60_hitfrac', 0, x, y, ...
        'TooltipString', 'average hit frac in the last 60 trials ignoring violations'); next_row(y);
    DispParam(obj, 'last30_hitfrac', 0, x, y, ...
        'TooltipString', 'average hit frac in the last 30 trials ignoring violations'); next_row(y);
    DispParam(obj, 'last15_hitfrac', 0, x, y, ...
        'TooltipString', 'average hit frac in the last 10 trials ignoring violations'); next_row(y);
    DispParam(obj, 'mean_hitfrac', 0, x, y, ...
        'TooltipString', 'average hit frac, ignoring violation trials'); next_row(y);
    DispParam(obj, 'nTrials',  0, x, y); next_row(y);
    DispParam(obj, 'nTimeout', 0, x, y, ...
        'TooltipString', 'number of trials where no response was given before timeout'); next_row(y); 
    DispParam(obj, 'nViolation', 0, x, y, ...
        'TooltipString', 'number of trials where mouse licked during stim (with viol on)'); next_row(y); 
    DispParam(obj, 'nRewarded', 0, x, y, ...
        'TooltipString', 'number of trials for which water was dispensed'); next_row(y);
    DispParam(obj, 'nCorrect', 0, x, y, ...
        'TooltipString', 'number of trials where the response was correct'); next_row(y);

    SoloFunctionAddVars('StateMatrixSection', 'ro_args', ...
        {'hit_streak';  ...
        'reward_delay'; 'reward_timing'; ...
		'error_delay'; ...
        'left_wtr_mult'; 'right_wtr_mult'});
    
    SoloFunctionAddVars('AdLibGUISection', 'ro_args', ...
        {'hit_streak'});    
    
    SoloFunctionAddVars('PBupsFixed', 'rw_args',{'nTrials'});
    
     %   Let SidesSection have read access to the reward type
     SoloFunctionAddVars('SidesSection','ro_args', {'reward_type'});
     SoloFunctionAddVars('PBupsSection', 'ro_args', {'reward_type'});    

     for i = 1:numel(value(active_curricula))
        % Construct the function call with the updated curriculum name
        current_curricula = value(active_curricula{i});
        function_call = sprintf("SoloFunctionAddAllVars(obj, 'TS_%s', 'ro_args');", current_curricula);
        eval(function_call);

     end 
    SubheaderParam(obj, 'title', mfilename, x, y);
    next_row(y, 1.5);
    

    
  case 'next_trial',
    if n_done_trials > 0,
        if isfield(parsed_events.states, 'temp_error_state') && rows(parsed_events.states.temp_error_state) > 0,
            hit_history.value = [hit_history(:) ; 0];
            nRewarded.value = nRewarded + 1;
        elseif isfield(parsed_events.states, 'side_tup') && rows(parsed_events.states.side_tup) > 0,
            nTimeout.value = nTimeout + 1;
            timeout_history.value = [timeout_history(:) ; 1];
            hit_history.value = [hit_history(:) ; NaN];
        elseif isfield(parsed_events.states, 'stim_pun') && rows(parsed_events.states.stim_pun) > 0,
            nViolation.value = nViolation + 1;
            timeout_history.value = [violation_history(:) ; 1];
            hit_history.value = [hit_history(:) ; NaN];
        elseif rows(parsed_events.states.hit_state) > 0, 
            hit_history.value = [hit_history(:) ; 1]; 
            nRewarded.value = nRewarded + 1;
            timeout_history.value = [timeout_history(:) ; 0];
        else
            hit_history.value = [hit_history(:) ; 0];
            timeout_history.value = [timeout_history(:) ; 0];
        end;
        
%         if isfield(parsed_events.states, 'side_tup') && rows(parsed_events.states.side_tup) > 0,
%             nTimeout.value = nTimeout + 1;
%             timeout_history.value = [timeout_history(:) ; 1];
%         else
%             timeout_history.value = [timeout_history(:) ; 0];
%         end;        
    
        nTrials.value = nTrials + 1;
        if hit_history(length(hit_history)) == 1, nCorrect.value = nCorrect + 1; end;    
        if nTrials > 0, mean_hitfrac.value = nanmean(hit_history(:)); end;
        if nTrials > 15, last15_hitfrac.value = nanmean(hit_history(end-14:end)); end;
        if nTrials > 30, last30_hitfrac.value = nanmean(hit_history(end-29:end)); end;
        if nTrials > 60, last60_hitfrac.value = nanmean(hit_history(end-59:end)); end;
        
    end;
    
    if n_done_trials ,
        if hit_history(end)==1, hit_streak.value = hit_streak + 1;
        else                                       hit_streak.value = 0;
        end;
    end;
    
%% update
  case 'update'
    
    if n_done_trials > 0,
        n_right_pokes.value  = n_right_pokes + size(latest_parsed_events.pokes.R, 1);
        n_left_pokes.value   = n_left_pokes + size(latest_parsed_events.pokes.L, 1);
    end;

        
%% close
  case 'close'   
    if exist('locked_in_sound_fig', 'var'),
      delete(value(locked_in_sound_fig));
    end;  
    
%% reinit
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


