
function [x, y] = RewardsSection(obj, action, x, y)
   
GetSoloFunctionArgs;

switch action

%% init  
  case 'init',
      
      SoloParamHandle(obj,'Last25TrialPerf', 'value',0);
      SoloParamHandle(obj,'Last50TrialPerf', 'value',0);
      SoloParamHandle(obj,'Last75TrialPerf', 'value',0);
      SoloParamHandle(obj,'Last100TrialPerf','value',0);
      SoloParamHandle(obj,'StageTrialCount', 'value',0);
    
%% prepare_next_trial    
% -----------------------------------------------------------------------
%
%         PREPARE_NEXT_TRIAL
%
% -----------------------------------------------------------------------

  case 'prepare_next_trial',
    if n_done_trials >= 1,
      if size(parsed_events.states.wrong_punish,1) >= 1  || size(parsed_events.states.late_punish,1)>=1
        hit_history.value = [hit_history(:) ; 0]; %#ok<NODEF>
      else
        hit_history.value = [hit_history(:) ; 1]; %#ok<NODEF>
      end;
    else
      hit_history.value = [];
    end;    

    if n_done_trials >= 1,
      if size(parsed_events.states.wrong_punish,1) >= 1 || size(parsed_events.states.light_on2,1) >= 1
        wrong_history.value = [wrong_history(:) ; 1]; %#ok<NODEF>
      else
        wrong_history.value = [wrong_history(:) ; 0]; %#ok<NODEF>
      end;
    else
      wrong_history.value = [];
    end;    
    
    if n_done_trials >= 1,
      if size(parsed_events.states.late_punish,1)>=1,
        late_history.value = [late_history(:) ; 1]; %#ok<NODEF>
      else
        late_history.value = [late_history(:) ; 0]; %#ok<NODEF>
      end;
    else
      late_history.value = [];
    end;
      
    if value(StageTrialCount) >= 25;   Last25TrialPerf.value = mean(hit_history(end-24:end)); else  Last25TrialPerf.value  = 0; end %#ok<NODEF>
    if value(StageTrialCount) >= 50;   Last50TrialPerf.value = mean(hit_history(end-49:end)); else  Last50TrialPerf.value  = 0; end    
    if value(StageTrialCount) >= 75;   Last75TrialPerf.value = mean(hit_history(end-74:end)); else  Last75TrialPerf.value  = 0; end
    if value(StageTrialCount) >= 100; Last100TrialPerf.value = mean(hit_history(end-99:end)); else  Last100TrialPerf.value = 0; end
    
    if n_done_trials > 0
        StageTrialCount.value = StageTrialCount + 1;
    end
    
    
%% reinit      
% -----------------------------------------------------------------------
%
%         REINIT
%
% -----------------------------------------------------------------------

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
end;

