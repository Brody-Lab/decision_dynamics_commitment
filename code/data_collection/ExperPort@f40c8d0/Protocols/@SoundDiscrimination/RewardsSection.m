
function [x, y] = RewardsSection(obj, action, x, y)
   
GetSoloFunctionArgs;

switch action

%% init  
  case 'init',
      
      SoloParamHandle(obj,'Last10TrialPerf', 'value',0);
      SoloParamHandle(obj,'Last25TrialPerf', 'value',0);
      SoloParamHandle(obj,'Last50TrialPerf', 'value',0);
      SoloParamHandle(obj,'Last75TrialPerf', 'value',0);
      SoloParamHandle(obj,'Last100TrialPerf','value',0);
      SoloParamHandle(obj,'Last150TrialPerf','value',0);
      SoloParamHandle(obj,'StageTrialCount', 'value',0);

    
%% prepare_next_trial    
% -----------------------------------------------------------------------
%
%         PREPARE_NEXT_TRIAL
%
% -----------------------------------------------------------------------

  case 'prepare_next_trial',
    if n_done_trials >= 1,
      if size(parsed_events.states.error_state,1) >= 1  || size(parsed_events.states.temperror,1)>=1,
        hit_history.value   = [hit_history(:) ; 0]; %#ok<NODEF>
      else
        hit_history.value   = [hit_history(:) ; 1]; %#ok<NODEF>
      end;
    else
      hit_history.value = [];
    end;    
    
    if value(StageTrialCount) >= 10;   Last10TrialPerf.value = mean(hit_history(end-9:end));   else  Last10TrialPerf.value = 0; end %#ok<NODEF>
    if value(StageTrialCount) >= 25;   Last25TrialPerf.value = mean(hit_history(end-24:end));  else  Last25TrialPerf.value = 0; end 
    if value(StageTrialCount) >= 50;   Last50TrialPerf.value = mean(hit_history(end-49:end));  else  Last50TrialPerf.value = 0; end    
    if value(StageTrialCount) >= 75;   Last75TrialPerf.value = mean(hit_history(end-74:end));  else  Last75TrialPerf.value = 0; end
    if value(StageTrialCount) >= 100; Last100TrialPerf.value = mean(hit_history(end-99:end));  else Last100TrialPerf.value = 0; end
    if value(StageTrialCount) >= 150; Last150TrialPerf.value = mean(hit_history(end-149:end)); else Last150TrialPerf.value = 0; end
    
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

