function [x, y] = RewardsSection(obj, action, x, y)
   
   GetSoloFunctionArgs;
   
   switch action
    case 'init',
      SoloParamHandle(obj, 'my_xyfig', 'value', [x y gcf]);

      SoloParamHandle(obj, 'pstruct');
      SoloParamHandle(obj, 'LastTrialEvents', 'value', []);
      SoloFunctionAddVars('PokesPlotSection', 'ro_args', 'LastTrialEvents');
      SoloParamHandle(obj, 'RawEvents', 'value', []);
      SoloParamHandle(obj, 'RawEventCounter', 'value', 0);
      
      DispParam(obj, 'nRewards', 0, x, y); next_row(y);
      DispParam(obj, 'nTrials', 0, x, y); next_row(y);
      next_row(y, 0.5);
      
      
    case 'trial_finished',
      % Make sure we've collected up to the latest events from the RT machine:  
      RewardsSection(obj, 'update');
      
      % Parse the events from the last trial:
      pstruct.value = parse_trial(value(LastTrialEvents), RealTimeStates);

      % Take the current raw events and push them into the history:
      push_history(LastTrialEvents); LastTrialEvents.value = [];
      
      % Get some truly raw events, in the native state machine format:
      smach = rpbox('getstatemachine');
      if GetEventCounter(smach) > RawEventCounter,
        RawEvents.value = GetEvents(smach, RawEventCounter(1)+1, GetEventCounter(smach));
        RawEventCounter.value = RawEventCounter + size(RawEvents(:,:), 1);
      end;
      push_history(RawEvents); RawEvents.value = [];
      
      
      if     rows(pstruct.error_state)>0 | rows(pstruct.temporary_punishment)>0,  hit = 0;
      elseif rows(pstruct.hit_state)  >0,                                         hit = 1; 
        nRewards.value = nRewards+1;
      else   warning('no error_state nor temporary_punishment nor hit_state ??'); hit = 0;
      end;
      nTrials.value = nTrials + 1;
      
      hit_history.value = [hit_history(:) ; hit];
      
      if n_done_trials == 1, porotocol_start_time.value = clock; end;
      
    case 'update',
      Event = GetParam('rpbox', 'event', 'user');
      LastTrialEvents.value = [value(LastTrialEvents) ; Event];
        
    case 'reinit',
      
      x = my_xyfig(1); y = my_xyfig(2); fig = my_xyfig(3);

      % Delete all SoloParamHandles who belong to this object and whose
      % fullname starts with the name of this mfile:
      delete_sphandle('owner', ['^@' class(obj) '$'], ...
                      'fullname', ['^' mfilename]);

      % Reinitialise 
      figure(fig);
      feval(mfilename, obj, 'init');
   end;
   
   
      