% Typical section code-- this file may be used as a template to be added 
% on to. The code below stores the current figure and initial position when
% the action is 'init'; and, upon 'reinit', deletes all SoloParamHandles 
% belonging to this section, then calls 'init' at the proper GUI position 
% again.


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

function [x, y] = SidesSection(obj, action, x, y)
   
GetSoloFunctionArgs; % put this in every section

% ok, let's figure out a unified approach:
% requirements:
% probability of left side sound if one-sided
% left/right/both flag(s)
% probability of 2-sided vs. 1-sided?
% actual distributions over stimuli and associated rewards for each side
% 
%%%%%%%% !!!

% ref: SidesSection:get_current_side()
% function used to get parameters from SidesSection
% check order of initialization -- make sure stuff is defined/assigned a
% value before calling it.


switch action
 case 'init',
  % Save the figure and the position in the figure where we are
  % going to start adding GUI elements:
  SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);
  
  SoloParamHandle(obj, 'stim_choices', 'value', [1 1]);
  SoloParamHandle(obj, 'water_flags', 'value', [0 0]);
  
  % Max times same side can appear -- re-interpreted to be side offering best
  % reward
  % MenuParam(obj, 'MaxSameBest', {'1', '2', '3', '4', '5', '6', '7', 'inf'}, ...
  % 3, x, y, 'TooltipString', ['Maximum number of times the same ' ...
  % 'best side can appear']);
  next_row(y);
  
  % Prob of left side giving the best and/or only reward
  NumeditParam(obj, 'LeftProb', 0.5, x, y); next_row(y);
  set_callback(LeftProb, {mfilename, 'new_leftprob'});
  
  % trial type: one-sided, two-sided; also, left/right best or only
  MenuParam(obj, 'TrialType', {'ONESIDED', 'TWOSIDED'}, 'ONESIDED', x, y, ...
            'TooltipString', 'Stimuli per trial');
  next_row(y);
  MenuParam(obj, 'ThisTrial', {'LEFT', 'RIGHT'}, 'LEFT', x, y, 'TooltipString', ...
            'Side of the best (2-sided trial) or only (1-sided) stimulus');
  next_row(y);
  SoloParamHandle(obj, 'previous_best_sides', 'value', 'l');
  SubheaderParam(obj, 'title', 'Sides Section', x, y);
  next_row(y, 1.5);
  
  % plot of side choices history at top of window
  pos = get(gcf, 'Position');
  SoloParamHandle(obj, 'myaxes', 'saveable', 0, 'value', axes);
  set(value(myaxes), 'Units', 'pixels');
  set(value(myaxes), 'Position', [90 pos(4)-140 pos(3)-130 100]);
  set(value(myaxes), 'YTick', [1 2], 'YLim', [0.5 2.5], 'YTickLabel', ...
                    {'Right', 'Left'});
  NumeditParam(obj, 'ntrials', 20, x, y, ...
               'position', [5 pos(4)-100 40 40], 'labelpos', 'top', ...
               'TooltipString', 'How many trials to show in plot');
  set_callback(ntrials, {mfilename, 'update_plot'});      
  xlabel('trial number');
  SoloParamHandle(obj, 'previous_plot', 'saveable', 0);
  feval(mfilename, obj, 'update_plot');
  
  SoloFunctionAddVars('StateMatrixSection', 'ro_args', {'stim_choices' ...
                      'water_flags', 'TrialType', 'ThisTrial'});
  
  SoloFunctionAddVars('util_compare', 'ro_args', {'LeftProb', 'previous_best_sides'});
  
 case 'new_leftprob',
  AntibiasSection(obj, 'update_biashitfrac', value(LeftProb), ...
                  value(hit_history), previous_best_sides);

 case 'next_trial',
  choiceprobs = AntibiasSection(obj, 'get_posterior_probs');

  % (best or only) side? may be meaningless if all payoffs the same
  if rand(1) <= choiceprobs(1)
    ThisTrial.value = 'LEFT';
  else
    ThisTrial.value = 'RIGHT';
  end
  
  % stimulus choice should be reasonably random
  % payoff probability should be determined from stimulus->payoff mapping?
  
  % trial type
  if strcmp(TrialType, 'TWOSIDED')
    stim_choices.value = ceil(rand(1,2)*num_stims); % choose stims randomly
    if ((stim_probs(stim_choices(1)) <= stim_probs(stim_choices(2))) && ...
        strcmp(ThisTrial, 'LEFT')) || ((stim_probs(stim_choices(1)) >= ...
                                       stim_probs(stim_choices(2))) && ...
                                      strcmp(ThisTrial, 'RIGHT'))
      stim_choices.value = ceil(rand(1,2)*num_stims);
    end
  else % ONESIDED trial -- just assign choices and use only the relevant side
    stim_choices.value = ceil(rand(1,2)*num_stims); % 0 = null/no stim
  end
  
  % instantiation of water
  water_flags.value = double(rand(1,2) <= stim_probs(value(stim_choices)));
    
  if n_done_trials > 0,
    if strcmp(ThisTrial, 'LEFT')
      previous_best_sides.value = [previous_best_sides(:) ; 'l'];
    else
      previous_best_sides.value = [previous_best_sides(:) ; 'r'];
    end
  end
  
 case 'update_plot',
  if ~isempty(value(previous_plot)), delete(previous_plot(:)); end
  if isempty(previous_best_sides), return; end
  
  ps = value(previous_best_sides);
  if ps(end)=='l', 
    hb = line(length(previous_best_sides), 2, 'Parent', value(myaxes));
  else                         
    hb = line(length(previous_best_sides), 1, 'Parent', value(myaxes));
  end
  set(hb, 'Color', 'b', 'Marker', '.', 'LineStyle', 'none');
  
  xgreen = find(hit_history);
  lefts  = find(previous_best_sides(xgreen) == 'l');
  rghts  = find(previous_best_sides(xgreen) == 'r');
  ygreen = zeros(size(xgreen)); ygreen(lefts) = 2; ygreen(rghts) = 1;
  hg = line(xgreen, ygreen, 'Parent', value(myaxes));
  set(hg, 'Color', 'g', 'Marker', '.', 'LineStyle', 'none'); 
  
  xred  = find(~hit_history);
  lefts = find(previous_best_sides(xred) == 'l');
  rghts = find(previous_best_sides(xred) == 'r');
  yred = zeros(size(xred)); yred(lefts) = 2; yred(rghts) = 1;
  hr = line(xred, yred, 'Parent', value(myaxes));
  set(hr, 'Color', 'r', 'Marker', '.', 'LineStyle', 'none'); 
  
  previous_plot.value = [hb ; hr; hg];
  % testing...
  disp(value(previous_plot))
  
  
  
  minx = n_done_trials - ntrials; if minx < 0, minx = 0; end
  maxx = n_done_trials + 2; if maxx <= ntrials, maxx = ntrials+2; end
  set(value(myaxes), 'Xlim', [minx, maxx]);
  drawnow;
  
 case 'reinit',
  currfig = gcf;
  
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


