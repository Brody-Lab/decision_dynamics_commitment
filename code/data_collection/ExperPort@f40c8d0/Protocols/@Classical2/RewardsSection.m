% Typical section code-- this file may be used as a template to be added 
% on to. The code below stores the current figure and initial position when
% the action is 'init'; and, upon 'reinit', deletes all SoloParamHandles 
% belonging to this section, then calls 'init' at the proper GUI position 
% again.
%
%
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
%            'get_stimulus'   Returns either (1) a structure with fields 'type'
%                        and 'duration', with the contents of 'type' being
%                        'lights' and the contents of 'duration' the
%                        maximum duration, in secs, of the stimulus; or (2) a
%                        structure with the fields 'type', 'duration', and
%                        'id', with contents 'sounds', duration of sound in
%                        secs, and integer sound_id, respectively.
%
%            'get_poked_trials'   Returns a double, number of trials in
%                        which subject poked in the appropriate poke at
%                        some point.
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
%
% x        When action == 'get_current_side', returns either the string 'l'
%          or the string 'r', for Left and Right, respectively.
%


function [x, y] = RewardsSection(obj, action, x, y)
   
GetSoloFunctionArgs(obj);

switch action
  case 'init',
    % Save the figure and the position in the figure where we are
    % going to start adding GUI elements:
    SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);

    MenuParam(obj, 'WaterDelivery', {'direct', 'on correct poke', 'on correctly timed poke'}, ...
      'direct', x, y, 'labelfraction', 0.35, 'TooltipString', sprintf(['\ndirect means deliver water together with CS,\n' ...
      '"on correct poke" means any time during trial when correct side port is poked,\n' ...
      '"on correctly timed poke" means on correct side port poked within RewardTime secs of CS onset'])); next_row(y, 1.3);
    set_callback(WaterDelivery, {mfilename, 'WaterDelivery'});
    NumeditParam(obj, 'RewardTime', 6, x, y, 'TooltipString', ...
      sprintf('\nTime after CS onset that reward is available. Inf means whole trial')); next_row(y);
    NumeditParam(obj, 'PokeMeasureTime', 2, x, y, 'TooltipString', ...
      sprintf('\nNumber of seconds of pre CS and post CS onset to use for computing PokeRatio')); next_row(y);
    DispParam(obj, 'PokeRatio', NaN, x, y, 'TooltipString', ...
      sprintf('\n# post CS onset pokes/# of pre CS onset pokes, in PokeMeasureTime seconds')); next_row(y);
    NumeditParam(obj, 'PokeRatioThreshold', NaN, x, y, 'TooltipString', ...
      sprintf('\nA PokeRatio over this Threshold defines a "good"trial')); next_row(y);
    
    
    DispParam(obj, 'n_trials',           0, x, y, ...
      'TooltipString', 'total # of elapsed trials'); next_row(y);
    DispParam(obj, 'poked_trials',    0, x, y, ...
      'TooltipString', '# of trials in which subject poked in the appropriate poke at some point'); next_row(y);
    DispParam(obj, 'consec_p_trials',    0, x, y, ...
      'TooltipString', '# of consecutive "poked_trials"'); next_row(y);
    DispParam(obj, 'consec_up_trials',    0, x, y, ...
      'TooltipString', '# of consecutive UN"poked_trials"'); 
    ToggleParam(obj, 'WaterBlock',       0, x, y, 'position', [x+185 y 15 15], 'label', '', 'TooltipString', ...
      sprintf('\nif BLACK, no water delivery, in "direct" mode. If BROWN, normal water delivery'), ...
      'OnString', '', 'OffString', ''); next_row(y); 
    DispParam(obj, 'rewarded_trials',    0, x, y, ...
      'TooltipString', '# of trials in which subject poked and got water'); next_row(y);
    DispParam(obj, 'consec_r_trials',    0, x, y, ...
      'TooltipString', '# of consecutive trials, ending in last trial, in which subject poked and got water'); next_row(y);
    DispParam(obj, 'rt',    0, x, y, ...
      'TooltipString', 'reaction time'); next_row(y);
    NumeditParam(obj, 'rtThreshold', 4, x, y, 'TooltipString', ...
      sprintf('\nrt less than this defines a "quick" trial')); next_row(y);
    DispParam(obj, 'consec_q_trials',    0, x, y, ...
      'TooltipString', '# of consecutive trials with rt less than rtThreshold'); next_row(y);
    DispParam(obj, 'good_trials',    0, x, y, ...
      'TooltipString', '# of trials in which subject exceeded post CS/pre CS poke ratio'); next_row(y);
    DispParam(obj, 'consec_g_trials',    0, x, y, ...
      'TooltipString', '# of consecutive  trials, ending in last trial, in which subject exceeded post CS/pre CS poke ratio'); next_row(y);

    % -------
    
    SoloParamHandle(obj, 'r_trials', 'value', []);
    SoloParamHandle(obj, 'q_trials', 'value', []);
    SoloParamHandle(obj, 'g_trials', 'value', []);
    
    SubheaderParam(obj, 'title', 'Rewards Section', x, y);
    next_row(y, 1.5);
    
    SoloFunctionAddVars('SMASection', ...
      'ro_args', {'WaterDelivery', 'RewardTime', 'PokeMeasureTime', 'WaterBlock'});
    feval(mfilename, obj, 'WaterDelivery');  % Set whatever is appropriate for current WaterDelivery
    
    
    % ---------------------------------------------------------------------
    % 
    %   CASE WATERDELIVERY
    % 
    % ---------------------------------------------------------------------

  case 'WaterDelivery'
    if strcmp(WaterDelivery, 'direct'),
      disable(rt); disable(rtThreshold); disable(consec_q_trials); enable(WaterBlock); %#ok<NODEF>
    else
      enable(rt);  enable(rtThreshold);  enable(consec_q_trials);  disable(WaterBlock); %#ok<NODEF>
    end;
    
    
    % ---------------------------------------------------------------------
    % 
    %   CASE GET_POKED_TRIALS 
    % 
    % ---------------------------------------------------------------------

    
  case 'get_poked_trials',
    x = value(poked_trials); %#ok<NODEF>
    return;

    
    
    % ---------------------------------------------------------------------
    % 
    %   CASE PREPARE_NEXT_TRIAL 
    % 
    % ---------------------------------------------------------------------

    
  case 'prepare_next_trial',
    if isempty(parsed_events), return; end;    
    if ~isempty(previous_sides), %#ok<NODEF>          
      previous_sides = previous_sides(:);
      wdh = get_history(WaterDelivery); 
	  if isempty(wdh), wdh{1}='direct'; end; % fix for wierd bug
      switch value(wdh{end}),
        case 'direct',                  csstate = 'direct_cs';
        case 'on correct poke',         csstate = 'cs';
        case 'on correctly timed poke', csstate = 'rewardable_cs';
        otherwise
          error('huh?');
      end;
      cs_onset = parsed_events.states.(csstate)(1,1);
      if isequal(StimulusSection(obj, 'get_last_stimulus_loc'), 'anti-loc'),
        if previous_sides(end)=='l', poke = 'R'; else poke = 'L'; end;
      else
        if previous_sides(end)=='l', poke = 'L'; else poke = 'R'; end;
      end;
      mypokes = parsed_events.pokes.(poke)(:,1);
      
      if ~isempty(find(mypokes > cs_onset,1))
        poked_trials.value = poked_trials+1; %#ok<NODEF>
        consec_p_trials.value  = consec_p_trials+1; %#ok<NODEF>
        consec_up_trials.value = 0;
      else
        consec_p_trials.value  = 0;
        consec_up_trials.value = consec_up_trials+1; %#ok<NODEF>
      end
    end;
    
    if rows(parsed_events.states.lefthit)>0 || rows(parsed_events.states.righthit)>0,
      r_trials.value = [r_trials(1:n_done_trials-1) 1]; %#ok<NODEF>
      rewarded_trials.value = rewarded_trials+1; %#ok<NODEF>
      consec_r_trials.value = consec_r_trials+1; %#ok<NODEF>
    else
      r_trials.value = [r_trials(1:n_done_trials-1) 0]; %#ok<NODEF>
      consec_r_trials.value = 0;
    end;
    
    hit_history.value = value(r_trials);
    
    n_trials.value = n_trials+1; %#ok<NODEF>

    
    % Compute reaction times only for non-direct delivery modes:
    if strcmp(csstate, 'direct_cs'),
      consec_q_trials.value = 0;
    else
      if rows(parsed_events.states.lefthit>0)
        rt.value = parsed_events.states.lefthit(1,1)  - parsed_events.states.(csstate)(1,1);
      elseif rows(parsed_events.states.righthit>0)
        rt.value = parsed_events.states.righthit(1,1) - parsed_events.states.(csstate)(1,1);
      else
        warning('CLASSICAL:No_hit_state', 'No lefthit or righthit -- not computing rt!');
      end;

      if rt < rtThreshold, consec_q_trials.value = consec_q_trials + 1; %#ok<NODEF>
      else                 consec_q_trials.value = 0;
      end;
    end;
    
    % Now compute the good poke ratio stuff
    if ~isempty(previous_sides),
      preCSonset_pokes = ...
        length(find(parsed_events.states.(csstate)(1,1)-PokeMeasureTime < mypokes & ...
        mypokes < parsed_events.states.(csstate)(1,1)));
      postCSonset_pokes = ...
        length(find(parsed_events.states.(csstate)(1,1) < mypokes & ...
        mypokes < parsed_events.states.(csstate)(1,1)+PokeMeasureTime));
      if preCSonset_pokes > 0,      PokeRatio.value = postCSonset_pokes / preCSonset_pokes;
      elseif postCSonset_pokes > 0, PokeRatio.value = Inf;
      else                          PokeRatio.value = 0;
      end;
      if PokeRatio > PokeRatioThreshold,
        good_trials.value = good_trials+1; %#ok<NODEF>
        consec_g_trials.value = consec_g_trials+1; %#ok<NODEF>
      else
        consec_g_trials.value = 0;
      end;      
    end;
      
    
    
    
    % ---------------------------------------------------------------------
    % 
    %   CASE REINIT 
    % 
    % ---------------------------------------------------------------------

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



