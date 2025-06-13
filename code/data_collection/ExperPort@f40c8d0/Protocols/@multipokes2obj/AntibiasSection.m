% [x, y] = AntibiasSection(obj, action, x, y)
%
% Section that calculates biases and calculates probability of choosing a stimulus
% given the previous history. 
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%            'init'      To initialise the section and set up the GUI
%                        for it; also calls 'choose_next_side' and
%                        'update_plot' (see below)
%
%            'reinit'    Delete all of this section's GUIs and data,
%                        and reinit, at the same position on the same
%                        figure as the original section GUI was placed.
%
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
% x        When action = 'get_next_side', x will be either 'l' for
%          left or 'r' for right.
%

function [x, y] = AntibiasSection(obj, action, x, y)
   
GetSoloFunctionArgs;
   
switch action
    
  case 'init',   % ------------ CASE INIT ----------------
    % Save the figure and the position in the figure where we are
    % going to start adding GUI elements:
    SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);

    LogsliderParam(obj, 'HitFracTau', 30, 10, 400, x, y, 'label', 'hits frac tau', ...
      'TooltipString', ...
      sprintf(['\nnumber of trials back over which to compute fraction of correct trials.\n' ...
      'This is just for displaying info-- for the bias calculation, see BiasTau above']));
    set_callback(HitFracTau, {mfilename, 'update_hitfrac'});
    next_row(y);
    DispParam(obj, 'LtHitFrac', 0, x, y); next_row(y);
    DispParam(obj, 'RtHitFrac', 0, x, y); next_row(y);
    DispParam(obj, 'HitFrac',   0, x, y); next_row(y);
    
    next_row(y, 0.5);
    LogsliderParam(obj, 'BiasTau', 30, 10, 400, x, y, 'label', 'antibias tau', ...
      'TooltipString', ...
      sprintf(['\nnumber of trials back over\nwhich to compute fraction of correct trials\n' ...
      'for the antibias function.'])); next_row(y);
    NumeditParam(obj, 'Beta', 0, x, y, ...
      'TooltipString', ...
      sprintf(['When this is 0, past performance doesn''t affect choice\n' ...
      'of next trial. When this is large, the next trial is ' ...
      'almost guaranteed\nto be the one with smallest %% correct'])); next_row(y);
    set_callback({BiasTau, Beta}, {mfilename, 'update_biashitfrac'});
    DispParam(obj, 'LtProb', 0, x, y); next_row(y);
    DispParam(obj, 'RtProb', 0, x, y); next_row(y);
    SoloParamHandle(obj, 'BiasLtHitFrac', 'value', 0);
    SoloParamHandle(obj, 'BiasRtHitFrac', 'value', 0);
        
    
   
  case 'update_biashitfrac',     % ------- CASE UPDATE_BIASHITFRAC -------------
    kernel = exp(-[0:length(hit_history)-1]/BiasTau)';
    kernel = kernel(end:-1:1);
    
    prevs = previous_sides(1:length(hit_history))';
    ul = find(prevs == 'l');
    if isempty(ul), BiasLtHitFrac.value = 1;
    else            BiasLtHitFrac.value = sum(hit_history(ul) .* kernel(ul))/sum(kernel(ul));
    end;
        
    ur = find(prevs == 'r');
    if isempty(ur), BiasRtHitFrac.value = 1;
    else            BiasRtHitFrac.value = sum(hit_history(ur) .* kernel(ur))/sum(kernel(ur));
    end;
    
    if isempty(ul) & ~isempty(ur), BiasLtHitFrac.value = value(BiasRtHitFrac); end;
    if isempty(ur) & ~isempty(ul), BiasRtHitFrac.value = value(BiasLtHitFrac); end;

    x = SidesSection(obj, 'get_LeftProb');
    choices = feval(mfilename, obj, 'get_posterior_probs', x);
    LtProb.value = choices(1);
    RtProb.value = choices(2);

    
  case 'get_posterior_probs',      % ------- CASE GET_POSTERIOR_PROBS -------------
    choices = probabilistic_trial_selector([value(BiasLtHitFrac), value(BiasRtHitFrac)], ...
      [x, 1-x], value(Beta));
    x = choices;
    
  
  case 'update_hitfrac',     % ------- CASE UPDATE_HITFRAC -------------
    if length(hit_history)>0, 
      kernel = exp(-[0:length(hit_history)-1]/HitFracTau)';
      kernel = kernel(end:-1:1);
      HitFrac.value = sum(hit_history .* kernel)/sum(kernel);
    
      prevs = previous_sides(1:length(hit_history))';
      u = find(prevs == 'l');
      if isempty(u), LtHitFrac.value = NaN;
      else           LtHitFrac.value = sum(hit_history(u) .* kernel(u))/sum(kernel(u));
      end;
        
      u = find(prevs == 'r');
      if isempty(u), RtHitFrac.value = NaN;
      else           RtHitFrac.value = sum(hit_history(u) .* kernel(u))/sum(kernel(u));
      end;
    end;
    
            
  case 'reinit',   % ------- CASE REINIT -------------
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
end;
   
   
      