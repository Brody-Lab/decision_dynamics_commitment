function [x, y] = TimesSection(obj, action, x, y)
     
   GetSoloFunctionArgs;
   
   switch action
    case 'init',
      % Save the figure and the position in the figure where we are
      % going to start adding GUI elements:
      SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);
      
      NumeditParam(obj, 'water_wait', 0.15, x, y, ...
        'TooltipString', ['How long to wait, in secs, after a correct' ...
                          'poke and before giving water']); next_row(y);
      NumeditParam(obj, 'hit_state_duration', 2.5, x, y, ...
        'TooltipString', 'Hit state duration, secs -- like drinktime'); next_row(y, 1.5);
      SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', ...
                          {'hit_state_duration' ; 'water_wait'});

      NumeditParam(obj, 'mu_ITI', 20, x, y, 'position', [x y 100 20], ...
        'labelfraction', 0.7, 'TooltipString', 'mean ITI, in secs');
      NumeditParam(obj, 'sd_ITI', 8, x, y, 'position', [x+100 y 100 20], ...
        'labelfraction', 0.7, 'TooltipString', 'st dev ITI, in secs');
      next_row(y);
      
      DispParam(obj, 'ITI',           4, x, y, ...
        'TooltipString', 'secs before trial end signal is sent'); next_row(y, 1.5);
      MenuParam(obj, 'BadPokeSoundType', {'silence', 'white noise'}, 'white noise', x, y, ...
        'TooltipString', 'Type of sound in response to pokes when no light is on'); next_row(y);
      NumeditParam(obj, 'BadPokeSoundDuration', 1, x, y, 'labelfraction', 0.55, ...
        'TooltipString', 'Duration in secs of sound in response to bad poke');
      set(get_ghandle({BadPokeSoundType ; BadPokeSoundDuration}), 'Enable', 'off');
      set_callback({BadPokeSoundType; BadPokeSoundDuration}, {mfilename, 'make_bad_poke_sound'});
      SoundManager(obj, 'declare_new_sound', 'bad_poke_sound');
      feval(mfilename, obj, 'make_bad_poke_sound');      
      SoundManager(obj, 'send_not_yet_uploaded_sounds');
      next_row(y, 1.5);
      
      NumeditParam(obj, 'ExtraITIOnError', 3, x, y, ...
        'TooltipString', 'extra secs pause if error trial'); next_row(y);
      next_row(y, 0.5);
      
      SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', ...
                          {'ITI', 'ExtraITIOnError'});
      
      SubheaderParam(obj, 'title', 'Times', x, y);
      next_row(y, 1.5);
      

    case 'make_bad_poke_sound',
      amp = 0.1;
      switch value(BadPokeSoundType),
        case 'silence',
          SoundManager(obj, 'set_sound', 'bad_poke_sound', ...
            zeros(1, BadPokeSoundDuration*SoundManager(obj, 'get_sample_rate')));
        case 'white noise',
          SoundManager(obj, 'set_sound', 'bad_poke_sound', ...
            amp*0.01*randn(1, BadPokeSoundDuration*SoundManager(obj, 'get_sample_rate')));
        otherwise,
          error('Which kind of bad poke sound???');
      end;
      
      
    case 'compute_iti',
      ITI.value = mu_ITI + sd_ITI*randn(1);
      if ITI < 0.5, ITI.value = 0.5; end;
      
      
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
   
   
      