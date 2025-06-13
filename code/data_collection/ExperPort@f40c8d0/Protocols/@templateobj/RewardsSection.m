function [] = RewardsSection(obj, action)
   
   GetSoloFunctionArgs;
   
   switch action
    case 'init',
      SoloParamHandle(obj, 'pstruct');
      SoloParamHandle(obj, 'LastTrialEvents', 'value', []);
      
    case 'trial_finished',
      % Make sure we've collected up to the latest events from the RT machine:  
      RewardsSection(obj, 'update');
      
      % Parse the events from the last trial:
      pstruct.value = parse_trial(value(LastTrialEvents), RealTimeStates);

      % Take the current raw events and push them into the history:
      push_history(LastTrialEvents); LastTrialEvents.value = [];
      
      if rows(pstruct.extra_iti)>0, hit = 0;
      else                          hit = 1;
      end;
      
      hit_history.value = [hit_history(:) ; hit];
      
      
    case 'update',
      Event = GetParam('rpbox', 'event', 'user');
      LastTrialEvents.value = [value(LastTrialEvents) ; Event];
        
    case 'reinit',

      % Delete all SoloParamHandles who belong to this object and whose
      % fullname starts with the name of this mfile:
      delete_sphandle('owner', ['^@' class(obj) '$'], ...
                      'fullname', ['^' mfilename]);

      % Reinitialise 
      feval(mfilename, obj, 'init');
   end;
   
   
      