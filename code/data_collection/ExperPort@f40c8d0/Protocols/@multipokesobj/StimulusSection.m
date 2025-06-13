% [x, y] = StimulusSection(obj, action, x, y)
%
% Section that takes care of defining and uploading sounds
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
%           'make_sounds'   Use the current GUI params to make the
%                        sounds. Does not upload sounds.
%
%           'upload_sounds' If new sounds have been made since last
%                        upload, uploads them to the sounds machine.
%
%           'get_tone_duration'  Returns length, in milliseconds, of
%                        the sounds the rat should discriminate
%
%           'get_sound_ids'      Returns a structure with two
%                        fieldnames, 'right' and 'left'; the values of
%                        these fieldnames will be the sound numbers of
%                        the tone loaded as the Right sound and of the
%                        tone loaded as the Left sound, respectively.
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
% x        When action == 'get_tone_duration', x is length, in
%          milliseconds, of the sounds the rat should discriminate.
%
% x        When action == 'get_sound_ids', x is a structure with two
%          fieldnames, 'right' and 'left'; the values of these fieldnames
%          will be the sound numbers of the tone loaded as the Right sound
%          and of the tone loaded as the Left sound, respectively.
%           


function [x, y] = StimulusSection(obj, action, x, y)
   
   GetSoloFunctionArgs;
   amp = 0.05;
   
   switch action
    case 'init',   % ---------- CASE INIT -------------
      
      % Save the figure and the position in the figure where we are
      % going to start adding GUI elements:
      SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);
      
      MenuParam(obj, 'n_center_pokes', {'1' '2'}, 1, x, y, 'TooltipString', ...
        'Number of required center pokes before reward-giving side poke'); next_row(y, 1.2);   
      set_callback(n_center_pokes, {mfilename, 'n_center_pokes'});
      ToggleParam(obj, 'PunishITIBadPokes', 0, x, y, ...
        'OffString', 'do not punish bad pokes in ITI', 'OnString', 'punish bad pokes in iti', ...
        'TooltipString', ...
        sprintf(['\nIf brown, poking during ITI has no effect;\nif black, bad poke sound ' ...
        'is emitted and ITI reinits'])); next_row(y);
      NumeditParam(obj, 'iti_bpdur', 3, x, y); next_row(y);
      
      % ======== POKE 1 BUTTONS ======================
      SubheaderParam(obj, 'separator1', ' ', x, y, 'position', [x y+4 200 7]); y = y+14;

      NumeditParam(obj, 'Pk1LightDuration', 'Inf', x, y, 'TooltipString', ...
        'Length of time light will stay on, waiting for animal to poke'); next_row(y);
      set(get_glhandle(Pk1LightDuration), 'Enable', 'off'); % For now, Inf only handled value
      ToggleParam(obj, 'PunishLight1BadPokes', 0, x, y, ...
        'OffString', 'do not punish wrong port pokes in light1', 'OnString', 'punish wrong port pokes in light1', ...
        'TooltipString', ...
        sprintf(['\nIf brown, poking in a bad port during light1 has no effect;\nif black, bad poke sound ' ...
        'is emitted and light1 reinits'])); next_row(y);
      NumeditParam(obj, 'Pk1_light_bpdur', 3, x, y); next_row(y);
      ToggleParam(obj, 'Pk1SoundType', 0, x, y, 'position', [x y 80 20], ...
        'OffString', 'bups', 'OnString', 'pure tones', ...
        'TooltipString', 'Type of sound in response to first poke');
      NumeditParam(obj, 'Pk1SoundDuration', 0.5, x, y, 'position', ...
        [x+80 y 120 20], 'labelfraction', 0.65, ...
        'TooltipString', 'Duration in secs of sound in response to first poke');
      next_row(y);
      NumeditParam(obj, 'Pk1LeftFrequ', 25, x, y, 'position', [x y 100 20], ...
        'labelfraction', 0.7, 'TooltipString', 'Sound frequency when correct response is Left');
      NumeditParam(obj, 'Pk1RightFrequ', 100, x, y, 'position', [x+100 y 100 20], ...
        'labelfraction', 0.7, 'TooltipString', 'Sound frequency when correct response is Right');
      next_row(y);
      set_callback(Pk1LeftFrequ,  {mfilename, 'make_Poke1_Left_sound'});
      set_callback(Pk1RightFrequ, {mfilename, 'make_Poke1_Right_sound'});
      set_callback({Pk1SoundType;Pk1SoundDuration}, ...
        {mfilename, 'make_Poke1_Left_sound' ; mfilename, 'make_Poke1_Right_sound'});
      
      % ======= NOW INTER-LIGHT GAP BUTTONS ==============
      SubheaderParam(obj, 'separator2', ' ', x, y, 'position', [x y+4 200 7]); y = y+14;

      NumeditParam(obj, 'ILGapMin', 1, x, y, 'position', [x y 100 20], ...
        'labelfraction', 0.65, 'TooltipString', 'Minimum InterLightGap, in secs');
      NumeditParam(obj, 'ILGapMax', 1, x, y, 'position', [x+100 y 100 20], ...
        'labelfraction', 0.65, 'TooltipString', 'Maximum InterLightGap, in secs');
      next_row(y);
      NumeditParam(obj, 'ILGapTau', 1, x, y, 'position', [x y 100 20], ...
        'labelfraction', 0.65, 'TooltipString', ...
        'Decay time constant defining hazard rate for InterLightGap');
      DispParam(obj, 'InterLightGap', 1, x, y, 'position', [x+100 y 100 20], ...
        'labelfraction', 0.65, 'TooltipString', ...
        'Gap (in secs) between end of last center light and start of side light');
      next_row(y);
      set_callback({ILGapMin;ILGapMax;ILGapTau}, {mfilename, 'compute_gap_durations'});

      ToggleParam(obj, 'PunishInterLightBadPokes', 1, x, y, ...
        'OffString', 'do not punish bad pokes in IL Gap', 'OnString', 'punish bad pokes in IL Gap', ...
        'TooltipString', ...
        sprintf(['\nIf brown, poking during inter-light gap has no effect;\nif black, bad poke sound ' ...
        'is emitted and inter-light gap reinits'])); next_row(y);   
      NumeditParam(obj, 'IL_bpdur', 3, x, y); next_row(y);
      
      % ======== NOW POKE 2 BUTTONS ======================
      SubheaderParam(obj, 'separator2b', ' ', x, y, 'position', [x y+4 200 7]); y = y+14;
      
      NumeditParam(obj, 'Pk2LightDuration', 'Inf', x, y, 'TooltipString', ...
        'Length of time light will stay on, waiting for animal to poke'); next_row(y);
      set(get_glhandle(Pk2LightDuration), 'Enable', 'off'); % For now, Inf only handled value
      ToggleParam(obj, 'PunishLight2BadPokes', 0, x, y, ...
        'OffString', 'do not punish wrong port pokes in light2', 'OnString', 'punish wrong port pokes in light2', ...
        'TooltipString', ...
        sprintf(['\nIf brown, poking in a bad port during light2 has no effect;\nif black, bad poke sound ' ...
        'is emitted and light2 reinits'])); next_row(y);
      NumeditParam(obj, 'Pk2_light_bpdur', 3, x, y); next_row(y);
      ToggleParam(obj, 'Pk2SoundType', 0, x, y, 'position', [x y 80 20], ...
        'OffString', 'bups', 'OnString', 'pure tones', ...
        'TooltipString', 'Type of sound in response to second poke');
      NumeditParam(obj, 'Pk2SoundDuration', 0.5, x, y, 'position', ...
        [x+80 y 120 20], 'labelfraction', 0.65, ...
        'TooltipString', 'Duration in secs of sound in response to second poke');
      next_row(y);
      NumeditParam(obj, 'Pk2LeftFrequ', 100, x, y, 'position', [x y 100 20], ...
        'labelfraction', 0.7, 'TooltipString', 'Sound frequency when correct response is Left');
      NumeditParam(obj, 'Pk2RightFrequ', 25, x, y, 'position', [x+100 y 100 20], ...
        'labelfraction', 0.7, 'TooltipString', 'Sound frequency when correct response is Right');
      next_row(y);
      set_callback(Pk2LeftFrequ,  {mfilename, 'make_Poke2_Left_sound'});
      set_callback(Pk2RightFrequ, {mfilename, 'make_Poke2_Right_sound'});
      set_callback({Pk2SoundType;Pk2SoundDuration}, ...
        {mfilename, 'make_Poke2_Left_sound' ; mfilename, 'make_Poke2_Right_sound'});
      
      % ============ NOW CENTER 2 SIDE AND SIDE ==========
      SubheaderParam(obj, 'separator3', ' ', x, y, 'position', [x y+4 200 7]); y = y+14;
               
      ToggleParam(obj, 'PunishCenter2SideBadPokes', 1, x, y, ...
        'OffString', 'do not punish bad pokes in center-to-side Gap', 'OnString', ...
        'punish bad pokes in center-to-side Gap', 'TooltipString', ...
        sprintf(['\nIf brown, poking during center-to-side gap has no effect;\nif black, bad poke sound ' ...
        'is emitted and center-to-side gap reinits'])); next_row(y);   
      NumeditParam(obj, 'C2Side_bpdur', 17, x, y); next_row(y);

      NumeditParam(obj, 'C2SideMin', 1, x, y, 'position', [x y 100 20], ...
        'labelfraction', 0.65, 'TooltipString', 'Minimum Center2SideGap, in secs');
      NumeditParam(obj, 'C2SideMax', 1, x, y, 'position', [x+100 y 100 20], ...
        'labelfraction', 0.65, 'TooltipString', 'Maximum Center2SideGap, in secs');
      next_row(y);
      NumeditParam(obj, 'C2SideTau', 1, x, y, 'position', [x y 100 20], ...
        'labelfraction', 0.65, 'TooltipString', ...
        'Decay time constant defining hazard rate for Center2SideGap');
      DispParam(obj, 'Center2SideGap', 1, x, y, 'position', [x+100 y 100 20], ...
        'labelfraction', 0.65, 'TooltipString', ...
        'Gap (in secs) between end of last center light and start of side light');
      next_row(y);
      feval(mfilename, obj, 'compute_gap_durations');
      set_callback({C2SideMin;C2SideMax;C2SideTau}, {mfilename, 'compute_gap_durations'});      
      NumeditParam(obj, 'SideLightDuration', 'Inf', x, y, 'TooltipString', ...
        'Length of time light will stay on, waiting for animal to poke'); next_row(y);
      set(get_glhandle(SideLightDuration), 'Enable', 'off'); % For now, Inf only handled value
      ToggleParam(obj, 'PunishSideLightBadPokes', 0, x, y, ...
        'OffString', 'do not punish wrong port pokes in sidelight', ...
        'OnString', 'punish wrong port pokes in sidelight', ...
        'TooltipString', ...
        sprintf(['\nIf brown, poking in center port during sidelight has no effect;\nif black, bad poke sound ' ...
        'is emitted and sidelight reinits'])); next_row(y);
      NumeditParam(obj, 'Side_light_bpdur', 3, x, y); next_row(y);
      
      SubheaderParam(obj, 'separator3', ' ', x, y, 'position', [x y+4 200 7]); y = y+14;
      
      
      % <~> Rats would probably better learn to poke when lights are on and
      %       not poke when lights are off if the lights also are on DURING
      %       drinktime instead of only until the animal pokes to start
      %       drinktime.
      %     This variable toggles that. Default is off, which is old
      %       behavior.
      MenuParam(obj, 'DrinkTimeLight', {'off', 'correct_only', 'both'}, 'off', x, y, 'position', [x,y,160,20],...
          'TooltipString', sprintf(['\noff(default) = light off in ' ...
                          'drinktime;\ncorrect_only = reward port ' ...
                          'light is on during drinktime, regardless ' ...
                          'of other settings.\nboth = both side ' ...
                          'lights are on during drinktime.\nLight behavior here is regardless of other settings.' ...
                          '\n<~>'])); next_row(y);
      % <~> end

      
      NumeditParam(obj, 'StimuliVolumeFactor', 1, x, y, ...
        'TooltipString', sprintf(['\nFactor, should be in [0,1], that multiplies all\n' ...
        'poke stimuli sounds. Penalty sounds are unafected by this parameter.'])); next_row(y);
      set_callback(StimuliVolumeFactor, {mfilename, 'make_all_sounds'});

      SubheaderParam(obj, 'separator3', ' ', x, y, 'position', [x y+4 200 7]); y = y+14;
      
      SoundManager(obj, 'init');
      SoundManager(obj, 'declare_new_sound', 'Poke1Right');
      SoundManager(obj, 'declare_new_sound', 'Poke1Left');
      SoundManager(obj, 'declare_new_sound', 'Poke2Right');
      SoundManager(obj, 'declare_new_sound', 'Poke2Left');
      
      next_row(y, 0.5);
      SubheaderParam(obj, 'title', 'Stimulus Definitions', x, y, 'height',12);
      next_row(y, 1.5);

      feval(mfilename, obj, 'n_center_pokes'); % Make sure enable/disable of buttons matches n_center_pokes setting
      feval(mfilename, obj, 'make_all_sounds');
      SoundManager(obj, 'send_not_yet_uploaded_sounds');

      SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', ...
        {'n_center_pokes', 'PunishITIBadPokes', 'iti_bpdur', 'PunishInterLightBadPokes', 'IL_bpdur', ...
        'PunishLight1BadPokes', 'Pk1_light_bpdur', 'PunishLight2BadPokes', 'Pk2_light_bpdur', ...
        'PunishSideLightBadPokes', 'Side_light_bpdur', ...
        'PunishCenter2SideBadPokes', 'C2Side_bpdur', 'InterLightGap', 'Center2SideGap', 'DrinkTimeLight'}); % <~> added drinktimelight
      
      
    case 'make_all_sounds',   % ---------- CASE MAKE_ALL_SOUNDS -------------
      
      feval(mfilename, obj, 'make_Poke1_Right_sound');
      
      feval(mfilename, obj, 'make_Poke1_Left_sound');
      feval(mfilename, obj, 'make_Poke2_Right_sound');
      feval(mfilename, obj, 'make_Poke2_Left_sound');

      
    case 'make_Poke1_Right_sound',  % ---------- -------------
      soundtype = get(get_ghandle(Pk1SoundType), 'String');
      sound = make_sound(obj, soundtype, Pk1SoundDuration, Pk1RightFrequ, 60, 1);
      SoundManager(obj, 'set_sound', 'Poke1Right', amp*sound*StimuliVolumeFactor);
      
      
    case 'make_Poke1_Left_sound',   % ---------- -------------
      soundtype = get(get_ghandle(Pk1SoundType), 'String');
      sound = make_sound(obj, soundtype, Pk1SoundDuration, Pk1LeftFrequ, 60, 1);
      SoundManager(obj, 'set_sound', 'Poke1Left', amp*sound*StimuliVolumeFactor);
    
      
    case 'make_Poke2_Right_sound',  % ---------- -------------
      soundtype = get(get_ghandle(Pk2SoundType), 'String');
      sound = make_sound(obj, soundtype, Pk2SoundDuration, Pk2RightFrequ, 60, 1);
      SoundManager(obj, 'set_sound', 'Poke2Right', amp*sound*StimuliVolumeFactor);
      
      
    case 'make_Poke2_Left_sound',   % ---------- -------------
      soundtype = get(get_ghandle(Pk2SoundType), 'String');
      sound = make_sound(obj, soundtype, Pk2SoundDuration, Pk2LeftFrequ, 60, 1);
      SoundManager(obj, 'set_sound', 'Poke2Left', amp*sound*StimuliVolumeFactor);
    
      
    case 'n_center_pokes',   % ---------- CASE N_CENTER_POKES -------------
      pk2_guys = [get_sphandle('fullname', [mfilename '_' 'Pk2+']) ; ...
        get_sphandle('fullname', [mfilename '_' 'ILGap+']) ; ...
        {PunishInterLightBadPokes ; PunishLight2BadPokes ; IL_bpdur}];

      if n_center_pokes == 1,
        for i=1:length(pk2_guys), set(get_glhandle(pk2_guys{i}), 'Enable', 'off'); end;
        set(get_glhandle(InterLightGap), 'Enable', 'off');        
      elseif n_center_pokes == 2,
        for i=1:length(pk2_guys), set(get_glhandle(pk2_guys{i}), 'Enable', 'on'); end;
        set(get_glhandle(InterLightGap), 'Enable', 'on');
        set(get_glhandle(Pk2LightDuration), 'Enable', 'off'); % For now, Inf only handled value
      end;

      
    case 'compute_gap_durations',  % ---------- CASE COMPUTE_GAP_DURATIONS ----------
      if C2SideMin  > C2SideMax, C2SideMin.value = value(C2SideMax); end;
      
      if C2SideMin == C2SideMax, Center2SideGap.value = value(C2SideMax);
      else
        T = C2SideMax - C2SideMin;
        Center2SideGap.value = -C2SideTau*log(1 - rand(1)*(1 - exp(-T/C2SideTau)));
        Center2SideGap.value = C2SideMin + round(Center2SideGap*1000)/1000;
      end;
      

      if ILGapMin  > ILGapMax, ILGapMin.value = value(ILGapMax); end;
      
      if ILGapMin == ILGapMax, InterLightGap.value = value(ILGapMax);
      else
        T = ILGapMax - ILGapMin;
        InterLightGap.value = -ILGapTau*log(1 - rand(1)*(1 - exp(-T/ILGapTau)));
        InterLightGap.value = ILGapMin + round(InterLightGap*1000)/1000;
      end;
      
      
    case 'make_sounds',   % ---------- CASE MAKE_SOUNDS -------------
      sound_sample_rate = SoundManager(obj, 'get_sample_rate');

      t = 0:1/sound_sample_rate:ToneDuration/1000;
      left = sin(2*pi*Ltone*1000*t);
      rght = sin(2*pi*Rtone*1000*t);

      % We'll give it 10 ms cosyne rise and fall
      start = sin(2*pi*25*(0:1/sound_sample_rate:0.01));
      stop  = start(end:-1:1);
      
      left(1:length(start))        = left(1:length(start)).*start;
      left(end-length(stop)+1:end) = left(end-length(stop)+1:end).*stop;

      rght(1:length(start))        = rght(1:length(start)).*start;
      rght(end-length(stop)+1:end) = rght(end-length(stop)+1:end).*stop;

      % Now make it stereo:
      SoundManager(obj, 'set_sound', 'left',  [left'*LVol_Ltone left'*RVol_Ltone]');
      SoundManager(obj, 'set_sound', 'right', [rght'*LVol_Rtone rght'*RVol_Rtone]');
            
      return;

      
      
    case 'get_tone_duration',   % ---------- CASE GET_TONE_DURATION ----------
      x = value(ToneDuration);
      return;

            
    case 'reinit',       % ---------- CASE REINIT -------------
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
      
      
     otherwise,
       warning('Unrecognized action %s\n', action);
   end;
   
   
      
  function [sound] = make_sound(obj, soundtype, duration, frequency, spl, volume_factor)
    srate = SoundManager(obj, 'get_sample_rate');
    
    switch soundtype,
      case 'pure tones',
        sound = MakeSigmoidSwoop3(srate, 70-spl, frequency*1000, frequency*1000, ...
          duration*1000, 0, 0, 0.1, 3, ...
          'F1_volume_factor', volume_factor);
      
      case 'bups',
        sound = MakeBupperSwoop(srate, 70-spl, frequency, frequency,...
          duration*1000, 0, 0, 0.1, 'F1_volume_factor', volume_factor);
      
      otherwise
        error('which sound type??');
    end;
    
