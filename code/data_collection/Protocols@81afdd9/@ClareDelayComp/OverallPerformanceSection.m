% [x, y] = OverallPerformanceSection(obj, action, x,y)
%
% Reports overall performance. Uses training_stage from SideSection.
%
% PARAMETERS:
% -----------
%
% action   One of:
%            'init'      To initialise the section and set up the GUI
%                        for it
%
%            'close'     Delete all of this section's GUIs and data
%
%            'reinit'    Delete all of this section's GUIs and data,
%                        and reinit, at the same position on the same
%                        figure as the original section GUI was placed.
%
%            'evalueta'  Look at history and compute hit fraction, etc.
%
% x, y     Only relevant to action = 'init'; they indicate the initial
%          position to place the GUI at, in the current figure window
%
% RETURNS:
% --------
%
% perf  When action == 'init', returns x and y, pixel positions on
%          the current figure, updated after placing of this section's GUI.
%       When action == 'evaluate', returns a vector with elements
%          [ntrials, violation_rate, left_hit_frac, right_hit_frac, hit_frac]
%
%

% CDB, 23-March-2013

function [x, y] = OverallPerformanceSection(obj, action, x,y)

GetSoloFunctionArgs(obj);

switch action,
	
	% ------------------------------------------------------------------
	%              INIT
	% ------------------------------------------------------------------
	
	case 'init'
		
		SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)], 'saveable', 0);

		DispParam(obj, 'ntrials', 0, x, y); next_row(y);
		DispParam(obj, 'violation_rate', 0, x, y, 'TooltipString', ...
			'Fraction of trials with a center poke violation'); next_row(y);
        DispParam(obj, 'timeout_rate', 0, x, y, 'TooltipString', ...
			'Fraction of trials with timeout'); next_row(y);
		DispParam(obj, 'Left_hit_frac', 0, x, y, 'TooltipString', ...
			'Fraction of correct Left trials'); next_row(y);
		DispParam(obj, 'Right_hit_frac', 0, x, y, 'TooltipString', ...
			'Fraction of correct Right trials'); next_row(y);
		DispParam(obj, 'hit_frac', 0, x, y, 'TooltipString', ...
			'Fraction of correct trials'); next_row(y);
		
		SubheaderParam(obj, 'title', 'Overall Performance', x, y);
		next_row(y, 1.5);
		SoloParamHandle(obj, 'previous_parameters', 'value', []);
		
	% ------------------------------------------------------------------
	%              evaluate
	% ------------------------------------------------------------------

	case 'evaluate'
		
		switch value(training_stage)
			case 1,                  %%  center led on -> poke in the center -> go cue -> reward light and sound
				if n_done_trials > 1,
					ntrials.value        = n_done_trials;
					%violation_rate.value = numel(find(isnan(hit_history)))/n_done_trials;
					violation_rate.value = numel(find(violation_history))/n_done_trials;
                    timeout_rate.value = numel(find(timeout_history))/n_done_trials;
                    goods  = ~isnan(hit_history)';
					lefts  = previous_sides(1:n_done_trials)=='l';
					rights = previous_sides(1:n_done_trials)=='r';
					Left_hit_frac.value  = mean(hit_history(goods & lefts));
					Right_hit_frac.value = mean(hit_history(goods & rights));
					hit_frac.value       = mean(hit_history(goods));
				end;
		end
		
		if nargout > 0,
			x = [n_done_trials, value(violation_rate), value(timeout_rate), value(Left_hit_frac), ...
				value(Right_hit_frac), value(hit_frac)];
		end;

		
	% ------------------------------------------------------------------
	%              close
	% ------------------------------------------------------------------

	case 'close',
		% Delete all SoloParamHandles who belong to this object and whose
		% fullname starts with the name of this mfile:
		delete_sphandle('owner', ['^@' class(obj) '$'], ...
			'fullname', ['^' mfilename]);

		
	% ------------------------------------------------------------------
	%              reinit
	% ------------------------------------------------------------------

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
		
end


