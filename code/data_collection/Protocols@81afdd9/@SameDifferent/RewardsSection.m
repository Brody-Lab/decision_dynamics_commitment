% @SameDifferent/RewardsSection.m
% Bing, May 2008


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

    NumeditParam(obj, 'reward_delay', 0.001, x, y, ...
        'TooltipString', sprintf(['if reward_timing is from spoke, delay between correct side choice and reward delivery;' ...
                                  '\nif reward_timing is from cpoke, delay between 1st cpoke and reward delivery'])); next_row(y);
    MenuParam(obj, 'reward_timing', {'from spoke'; 'from cpoke'}, 1, x, y, ...
        'labelfraction', 0.4, ...
        'TooltipString', 'from when the reward_delay timer is set, from side or 1st center poke'); next_row(y);
    NumeditParam(obj, 'left_wtr_mult', 1, x, y, ...
        'position', [x y 75 20], ...
        'labelfraction', 0.7, ...
        'TooltipString', 'all left reward times are multiplied by this number'); 
    NumeditParam(obj, 'right_wtr_mult', 1, x, y, ...
        'position', [x+76 y 75 20], ...
        'labelfraction', 0.7, ...
        'TooltipString', 'all right reward times are multiplied by this number');
    ToggleParam(obj, 'antibias_wtr_mult', 0, x,y,...
        'position',[x+150 y 50 20], ...
        'OnString', 'AB ON',...
        'OffString', 'AB OFF',...
        'TooltipString', sprintf(['If on (black) then it disables the wtr_mult entries\n'...
            'and uses hitfrac to adjust the water times']));
    % add a callback that disables the right & left params.
          set_callback(antibias_wtr_mult, {mfilename, 'antibias_wtr_mult'});
%     NumeditParam(obj, 'left_preward', 1, x, y, ...
%         'position', [x y 100 20], ...
%         'labelfraction', 0.7, ...
%         'TooltipString', 'probability of reward on left'); 
%     NumeditParam(obj, 'right_preward', 1, x, y, ...
%         'position', [x+100 y 100 20], ...
%         'labelfraction', 0.7, ...
%         'TooltipString', 'probability of reward on right');    
%     next_row(y);
    next_row(y, 2);
    
    DispParam(obj, 'n_right_pokes', 0, x, y); next_row(y);
    DispParam(obj, 'n_left_pokes', 0, x, y); next_row(y);
    DispParam(obj, 'n_center_pokes', 0, x, y); next_row(y);
    DispParam(obj, 'hit_streak', 0, x, y, ...
        'TooltipString', 'number of continuous hit trials (2 hit strials -> 1 hit_streak)');
    next_row(y);
    DispParam(obj, 'last60_hitfrac', 0, x, y, ...
        'TooltipString', 'average hit frac in the last 60 trials ignoring violations'); next_row(y);
    DispParam(obj, 'last30_hitfrac', 0, x, y, ...
        'TooltipString', 'average hit frac in the last 30 trials ignoring violations'); next_row(y);
    DispParam(obj, 'last15_hitfrac', 0, x, y, ...
        'TooltipString', 'average hit frac in the last 10 trials ignoring violations'); next_row(y);
    DispParam(obj, 'mean_hitfrac', 0, x, y, ...
        'TooltipString', 'average hit frac, ignoring violation trials'); next_row(y);
    DispParam(obj, 'cpoke_violations', 0, x, y, ...
        'TooltipString', 'number of cpoke violations (where the rat did not complete cpokes within wait_for_cpoke_grace)'); next_row(y);
    DispParam(obj, 'spoke_violations', 0, x, y, ...
        'TooltipString', 'number of spoke violations (where the rat did not complete cpokes within wait_for_spoke_grace)'); next_row(y);
    DispParam(obj, 'nTrials',  0, x, y); next_row(y);
    DispParam(obj, 'nRewarded', 0, x, y, ...
        'TooltipString', 'number of trials for which water was dispensed'); next_row(y);
    DispParam(obj, 'nCorrect', 0, x, y, ...
        'TooltipString', 'number of trials where the response was correct'); next_row(y);

    SoloFunctionAddVars('StateMatrixSection', 'ro_args', ...
        {'hit_streak'; ...
        'reward_delay'; 'reward_timing'; ...
        'left_wtr_mult'; 'right_wtr_mult'});
    
    SoloFunctionAddVars('CpokeEODSection', 'ro_args', {'cpoke_violations'});
    
    SubheaderParam(obj, 'title', mfilename, x, y);
    next_row(y, 1.5);
    
%% next_trial    
  case 'next_trial',
    x = 0; % assume trial is not a violation
    if n_done_trials > 0,
        if isfield(parsed_events.states, 'temporary_punishment') && rows(parsed_events.states.temporary_punishment) > 0,
            hit_history.value = [hit_history(:) ; 0];
            nRewarded.value = nRewarded + 1;
        elseif rows(parsed_events.states.hit_state) > 0, 
            hit_history.value = [hit_history(:) ; 1]; 
            nRewarded.value = nRewarded + 1;
        elseif rows(parsed_events.states.violation_state) > 0,
            hit_history.value = [hit_history(:) ; NaN];
            x = 1;
        else
            hit_history.value = [hit_history(:) ; 0];
        end;
        % Count the number of cpoke1 states and put that into n_cpoke1s and
        % cpoke1_history:
        n_cpoke1s.value       = rows(parsed_events.states.cpoke1);
        cpoke1_history.value  = [cpoke1_history(:) ; value(n_cpoke1s)]; %#ok<NODEF,NASGU>
        
        nTrials.value = nTrials + 1;
        if hit_history(length(hit_history)) == 1, nCorrect.value = nCorrect + 1; end;    
        if nTrials > 0, mean_hitfrac.value = nanmean(hit_history(:)); end;
        if nTrials > 15, last15_hitfrac.value = nansum(hit_history(end-14:end))/15; end;
        if nTrials > 30, last30_hitfrac.value = nansum(hit_history(end-29:end))/30; end;
        if nTrials > 60, last60_hitfrac.value = nansum(hit_history(end-59:end))/60; end;
        
        if isfield(parsed_events.states, 'violation_state') && rows(parsed_events.states.violation_state) > 0,
            if rows(parsed_events.states.wait_for_spoke) > 0,
                spoke_violations.value = spoke_violations + 1;
            else
                cpoke_violations.value = cpoke_violations + 1;
            end
        end
        
        % in one cpoke w/ legal cbreaks mode, more than one cpoke1 state
        % means there was a violation that was had a temp pun
        if isfield(parsed_events.states, 'cpoke1') && rows(parsed_events.states.cpoke1) > 1,
            cpoke_violations.value = cpoke_violations + 1;
        end;
    end;
    
    if n_done_trials > 1,
        if hit_history(end)==1 && hit_history(end-1)==1, hit_streak.value = hit_streak + 1;
        else                                       hit_streak.value = 0;
        end;
   end; 
	
    % Update the water multipliers
    if antibias_wtr_mult==1  && n_done_trials>25
		% Let the rat do 25 trials before we try to correct biases. 
        mx=4; mn=0.3;
        RL_frac=SidesSection(obj,'get_current_hitfrac');
        right_hf=RL_frac(1);
        left_hf=RL_frac(2);
        right_wtr_mult.value=max(mn, min(mx,left_hf/right_hf));
        left_wtr_mult.value=max(mn, min(mx,right_hf/left_hf));
    else
        right_wtr_mult.value=1;
        left_wtr_mult.value=1;
    end
        
        
    
	% if we're going to generate a new trial after violation trials, 
	% then there's no need to set the violation flag
	if ~repeat_trial_after_violation,
		x = 0;
	end;
%% update    
  case 'update'
    
    if n_done_trials > 0,
        n_right_pokes.value  = n_right_pokes + size(latest_parsed_events.pokes.R, 1);
        n_left_pokes.value   = n_left_pokes + size(latest_parsed_events.pokes.L, 1);
        n_center_pokes.value = n_center_pokes + size(latest_parsed_events.pokes.C, 1);
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
%% antibias_wtr_mult
    case 'antibias_wtr_mult',
        if antibias_wtr_mult==0
            enable(left_wtr_mult);
            enable(right_wtr_mult);
        else    
            disable(left_wtr_mult);
            disable(right_wtr_mult);
		end
		
%% 	antibias_wtr_mult	
	case 'reset_wtr_antibias',
		left_wtr_mult.value=1;
		right_wtr_mult.value=1;
%% get_send_summary_info
case 'get_send_summary_info',
		upto=x;
        clear x;
		cpv=get_history(cpoke_violations);
        cpv=diff([cell2mat(cpv(:))]); % since this is a display param it has a leading 0 which is matched to trial_n
        x.cpv=cpv(1:upto);
end;
		
		

