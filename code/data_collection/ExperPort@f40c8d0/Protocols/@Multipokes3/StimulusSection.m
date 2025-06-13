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


function [x, y] = StimulusSection(obj, action, x, y)
   
GetSoloFunctionArgs;
amp = 0.05;

switch action
  case 'init',
    % Save the figure and the position in the figure where we are
    % going to start adding GUI elements:
    SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);

    % Number of center pokes
    MenuParam(obj, 'n_center_pokes', {'0', '1', '2'}, 1, ...
        x, y, 'TooltipString', 'Number of center pokes');
    set_callback(n_center_pokes, {mfilename, 'n_center_pokes'});
    next_row(y, 1.5);
    
    
    %  ============= POKE 1 BUTTONS =======================================
    ToggleParam(obj, 'PunishLight1BadPokes', 0, x, y, ...
        'OffString', 'do not punish wrong port pokes in light1', ...
        'OnString',  'punish wrong port pokes in light1', ...
        'TooltipString', sprintf(['\nIf brown, poking in a bad port during light1 has no effect;' ...
                                  '\nIf black, poking emits bad pokes sound and light1 reinits']));
    next_row(y);
    NumeditParam(obj, 'Pk1_light_bpdur', 3, x, y); next_row(y, 1.5);
    ToggleParam(obj, 'Pk1SoundType', 0, x, y, 'position', [x y 66 20], ...
        'OffString', 'bups', 'OnString', 'pure tones', ...
        'TooltipString', 'Type of sound in response to first poke');
    ToggleParam(obj, 'Pk1Light', 1, x, y, 'position', [x+67 y 66 20], ...
        'OffString', 'Pk1 Light off', 'OnString', 'Pk1 Light on');
    ToggleParam(obj, 'Pk1SndLoop', 0, x, y, 'position', [x+134 y 66 20], ...
        'OffString', 'No loop', 'OnString', 'Loop sound');
    next_row(y);
    NumeditParam(obj, 'Pk1LeftDur', 0.5, x, y, 'position', [x y 100 20], ...
        'labelfraction', 0.7, ...
        'TooltipString', 'Duration in secs of sound in response to first poke \n when correct response is left');
    NumeditParam(obj, 'Pk1RightDur', 0.5, x, y, 'position', [x+100 y 100 20], ...
        'labelfraction', 0.7, ...
        'TooltipString', 'Duration in secs of sound in response to first poke \n when correct response is right');
    next_row(y);
    NumeditParam(obj, 'Pk1LeftFrequ', 25, x, y, 'position', [x y 100 20], ...
        'labelfraction', 0.7, ...
        'TooltipString', 'Sound frequency (Hz for bups, kHz for pure tones) \n when correct response is left');
    NumeditParam(obj, 'Pk1RightFrequ', 25, x, y, 'position', [x+100 y 100 20], ...
        'labelfraction', 0.7, ...
        'TooltipString', 'Sound frequency (Hz for bups, kHz for pure tones) \n when correct response is right');
    next_row(y);
    MenuParam(obj, 'Pk1ToneLocalization', {'stereo', 'localized:pro', 'localized:anti'}, 1, x, y, ...
        'TooltipString', ...
        sprintf(['Localization of sound1 \npro: sound from same side as correct choice', ...
                 '\nanti: sound from opposite side as correct choice']));
    next_row(y);
    
    next_row(y, 0.5);
    SubheaderParam(obj, 'title', 'Center Poke 1', x, y);
    next_row(y, 1.5);
    
    set_callback(Pk1Light, {mfilename, 'pk1_light'});
    set_callback({Pk1LeftDur;  Pk1LeftFrequ},  {mfilename, 'make_Poke1_Left_sound'});
    set_callback({Pk1RightDur; Pk1RightFrequ}, {mfilename, 'make_Poke1_Right_sound'});
    set_callback({Pk1SoundType; Pk1SndLoop}, ...
        {mfilename, 'make_Poke1_Left_sound' ; mfilename, 'make_Poke1_Right_sound'});
    
    
    %  ============= INTER LIGHT GAP BUTTONS ==============================
    SubheaderParam(obj, 'separator2', ' ', x, y, 'position', [x y+4 200 2]); y = y+8;
    
    NumeditParam(obj, 'ILGapTau', 5, x, y, ...
        'labelfraction', 0.65, 'TooltipString', ...
        'Decay time constant defining hazard rate for InterLightGap');
    next_row(y);
    NumeditParam(obj, 'ILGapMax', 10, x, y, ...
        'labelfraction', 0.65, 'TooltipString', 'Maximum InterLightGap, in secs');
    next_row(y);
    NumeditParam(obj, 'ILGapMin', 5, x, y, ...
        'labelfraction', 0.65, 'TooltipString', 'Minimum InterLightGap, in secs');
    next_row(y);
    DispParam(obj, 'InterLightGap', 1, x, y,  ...
        'labelfraction', 0.65, 'TooltipString', ...
        sprintf(['Gap (in secs) between first center light and second center light.']) ...
        );
    next_row(y);
    set_callback({ILGapMin;ILGapMax;ILGapTau}, {mfilename, 'compute_gap_durations'});

    ToggleParam(obj, 'PunishInterLightBadPokes', 1, x, y, ...
        'OffString', 'do not punish side pokes in IL Gap', 'OnString', 'punish side pokes in IL Gap', ...
        'TooltipString', ...
        sprintf(['\nIf brown, poking side during inter-light gap has no effect;\nif black, poking left/right' ...
        '(but not center) emits bad poke sound and inter-light gap reinits'])); next_row(y);  
    ToggleParam(obj, 'PunishInterLightBadCenterPokes', 0, x, y, ...
        'OffString', 'do not punish center pokes in IL Gap', 'OnString', 'punish center pokes in IL Gap', ...
        'TooltipString', ...
        sprintf(['\nIf brown, poking center during inter-light gap has no effect;\nif black, poking center' ...
        '(but not l/r) emits bad poke sound and inter-light gap reinits'])); next_row(y);  
    NumeditParam(obj, 'IL_bpdur', 3, x, y); next_row(y);

    next_row(y, 0.5);
    SubheaderParam(obj, 'title', 'Inter Light Gap', x, y);
    next_row(y, 1.5);

    %  ============== INTER-LIGHT TONE BUTTONS ============================
    SubheaderParam(obj, 'separator2', ' ', x, y, 'position', [x y+4 200 2]); y = y+8;
    
    NumeditParam(obj, 'ILToneStartTau', 1.5, x, y,  ...
        'labelfraction', 0.65, 'TooltipString', ...
        'Decay time constant defining hazard rate for Inter Light Tone Start');
    next_row(y);
    NumeditParam(obj, 'ILToneStartMax', 5, x, y,  ...
        'labelfraction', 0.65, ...
        'TooltipString', 'Maximum Inter Light Tone Start, in secs; must be 0.5 sec less than ILGapMin');  
    next_row(y);
    NumeditParam(obj, 'ILToneStartMin', 1, x, y,  ...
        'labelfraction', 0.65, 'TooltipString', 'Minimum Inter Light Tone Start, in secs');
    next_row(y);
    DispParam(obj, 'InterLightToneStart', 1, x, y,  ...
        'labelfraction', 0.65, 'TooltipString', ...
        'Gap (in secs) between first center light and Inter Light Tone Start');
    next_row(y);
      
    next_row(y, 0.25);
    NumeditParam(obj, 'ILToneLeftDur', 2, x, y, 'position', [x y 100 20], ...
          'labelfraction', 0.65, 'TooltipString', ...
          sprintf(['Duration (in sec) of Inter Light Tone if correct response if left \n' ...
          'if duration is longer than inter light gap, sound plays until turned off at end of trial \n ' ...
          'or at a bad poke/bad side choice']));
    NumeditParam(obj, 'ILToneRightDur', 0.5, x, y, 'position', [x+100 y 100 20],...
          'labelfraction', 0.65, 'TooltipString', ... 
          'Duration (in sec) of Inter Light Tone if correct response is right (see ILToneLeftDur for more info)');
    next_row(y);
    
    NumeditParam(obj, 'ILToneLeftFrequ', 50, x, y, 'position', [x y 100 20], ...
          'labelfraction', 0.65, 'TooltipString', 'Frequency of Inter Light Tone if correct response if left');
    NumeditParam(obj, 'ILToneRightFrequ', 50, x, y, 'position', [x+100 y 100 20],...
        'labelfraction', 0.65, 'TooltipString', 'Frequency of Inter Light Tone if correct response is right');
    next_row(y);      

    MenuParam(obj, 'ILToneLocalization', {'stereo', 'localized:pro', 'localized:anti'}, 1, x, y, ...
        'TooltipString', ...
        sprintf(['Localization of Inter Light Tone \npro: sound from same side as correct choice', ...
                 '\nanti: sound from opposite side as correct choice']));
    next_row(y);
    MenuParam(obj, 'IL_ToneSoundType', {'bups', 'pure tones', 'off'}, 1, x, y, ...
        'TooltipString', 'Type of sound for the Inter Light Tone, or none'); 
    next_row(y);  
    set_callback(IL_ToneSoundType, {mfilename, 'il_tone_sound_type'; ...
                                 mfilename, 'make_ILTone_Left_sound'; ...
                                 mfilename, 'make_ILTone_Right_sound'});

    set_callback(ILToneLocalization, {mfilename, 'make_ILTone_Left_sound'; ...
                                       mfilename, 'make_ILTone_Right_sound'});

    next_row(y, 0.5);
    SubheaderParam(obj, 'title', 'Inter Light Tone', x, y);
    next_row(y, 1.5);

    set_callback({ILToneLeftDur; ILToneLeftFrequ}, {mfilename, 'make_ILTone_Left_sound'});
    set_callback({ILToneRightDur; ILToneRightFrequ}, {mfilename, 'make_ILTone_Right_sound'});
    set_callback({ILToneStartMin; ILToneStartMax; ILToneStartTau}, {mfilename, 'compute_IL_tone_start'});

    %  ============= CENTER POKE 2 BUTTONS =======================================    
    y = 5;
    next_column(x);
      
%     NumeditParam(obj, 'Pk2LightDuration', 'Inf', x, y, 'TooltipString', ...
%         'Length of time light will stay on, waiting for animal to poke'); next_row(y);
%     set(get_glhandle(Pk2LightDuration), 'Enable', 'off'); % For now, Inf only handled value
    ToggleParam(obj, 'PunishLight2BadPokes', 0, x, y, ...
        'OffString', 'do not punish wrong port pokes in light2', ...
        'OnString', 'punish wrong port pokes in light2', ...
        'TooltipString', ...
        sprintf(['\nIf brown, poking in a bad port during light2 has no effect;\nif black, bad poke sound ' ...
        'is emitted and light2 reinits'])); next_row(y);
    NumeditParam(obj, 'Pk2_light_bpdur', 3, x, y); next_row(y);
    ToggleParam(obj, 'Pk2SoundType', 0, x, y, 'position', [x y 100 20], ...
        'OffString', 'bups', 'OnString', 'pure tones', ...
        'TooltipString', 'Type of sound in response to second poke');
    ToggleParam(obj, 'Pk2Light', 1, x, y, 'position', [x+100 y 100 20], ...
        'OffString', 'Pk2 Light off', 'OnString', 'Pk2 Light on');
    next_row(y);
    NumeditParam(obj, 'Pk2LeftDur', 0.5, x, y, 'position', [x y 100 20], ...
        'labelfraction', 0.7, ...
        'TooltipString', 'Duration in secs of sound in response to second poke \n when correct response is left');
    NumeditParam(obj, 'Pk2RightDur', 0.5, x, y, 'position', [x+100 y 100 20], ...
        'labelfraction', 0.7, ...
        'TooltipString', 'Duration in secs of sound in response to second poke \n when correct response is right');
    next_row(y);
    NumeditParam(obj, 'Pk2LeftFrequ', 25, x, y, 'position', [x y 100 20], ...
        'labelfraction', 0.7, 'TooltipString', 'Sound frequency when correct response is Left');
    NumeditParam(obj, 'Pk2RightFrequ', 25, x, y, 'position', [x+100 y 100 20], ...
        'labelfraction', 0.7, 'TooltipString', 'Sound frequency when correct response is Right');
    next_row(y);
    MenuParam(obj, 'Pk2ToneLocalization', {'stereo', 'localized:pro', 'localized:anti'}, 1, x, y, ...
        'TooltipString', ...
        sprintf(['Localization of sound2 \npro: sound from same side as correct choice', ...
                 '\nanti: sound from opposite side as correct choice']));
    next_row(y);
    NumeditParam(obj, 'Pk2ToneVol', 1, x, y, 'TooltipString', sprintf(['\nFactor by which sound amplitude is ' ...
      'multiplied.\n1 means normal volume, use less than 1 for lower volumes. 0 is allowed.'])); next_row(y);
    
    next_row(y, 0.5);
    SubheaderParam(obj, 'title', 'Center Poke 2', x, y);
    next_row(y, 1.5);
      
    set_callback(Pk2Light, {mfilename, 'pk2_light'});
    set_callback({Pk2LeftDur;  Pk2LeftFrequ},  {mfilename, 'make_Poke2_Left_sound'});
    set_callback({Pk2RightDur; Pk2RightFrequ}, {mfilename, 'make_Poke2_Right_sound'});
    set_callback({Pk2SoundType; Pk2ToneVol}, ...
        {mfilename, 'make_Poke2_Left_sound' ; mfilename, 'make_Poke2_Right_sound'});
    
    
    % ================ CENTER 2 SIDE AND SIDE =============================
    SubheaderParam(obj, 'separator3', ' ', x, y, 'position', [x y+4 200 2]); y = y+8;
               
    ToggleParam(obj, 'PunishCenter2SideBadPokes', 1, x, y, ...
        'OffString', 'do not punish bad pokes in center-to-side Gap', 'OnString', ...
        'punish bad pokes in center-to-side gap', 'TooltipString', ...
        sprintf(['\nIf brown, poking during center-to-side gap has no effect;\nif black, bad poke sound ' ...
        'is emitted and center-to-side gap reinits'])); next_row(y);   
    NumeditParam(obj, 'C2Side_bpdur', 3, x, y); next_row(y);

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

%     NumeditParam(obj, 'SideLightDuration', 'Inf', x, y, 'TooltipString', ...
%         'Length of time light will stay on, waiting for animal to poke'); next_row(y);
%     set(get_glhandle(SideLightDuration), 'Enable', 'off'); % For now, Inf only handled value
    
      
    next_row(y, 0.5);
    SubheaderParam(obj, 'title', 'Center to Side', x, y);
    next_row(y, 1.5);
    
    % ================ SIDE CHOICE BUTTONS =============================
    SubheaderParam(obj, 'separator3', ' ', x, y, 'position', [x y+4 200 2]); y = y+8;
      
    ToggleParam(obj, 'PunishSideLightBadPokes', 0, x, y, ...
        'OffString', 'do not punish wrong port pokes in sidelight', ...
        'OnString', 'punish wrong port pokes in sidelight', ...
        'TooltipString', ...
        sprintf(['\nIf brown, poking in center port during sidelight has no effect;\nif black, bad poke sound ' ...
        'is emitted and sidelight reinits'])); next_row(y);
    NumeditParam(obj, 'Side_light_bpdur', 3, x, y); next_row(y);
    
    MenuParam(obj, 'SideLights', {'correct side only', 'both sides on', 'off'}, 1, x, y, ...
        'labelfraction', 0.4, 'TooltipString', ' ');
    next_row(y);
    set_callback(SideLights, {mfilename, 'side_lights'});
    
    next_row(y, 0.5);
    SubheaderParam(obj, 'title', 'Side Choice', x, y);
    next_row(y, 1.5);
    
    
    % ================ STIMULUS VOLUME =================================
    NumeditParam(obj, 'PenaltyVolumeFactor', 1, x, y, ...
        'TooltipString', sprintf(['\nFactor, can be in [0,10], that multiplies all\n' ...
        'penalty sounds. Stimuli sounds are unafected by this parameter.'])); next_row(y);
    SoloFunctionAddVars('TimesSection', 'ro_args', {'PenaltyVolumeFactor'});
    set_callback(PenaltyVolumeFactor, {'TimesSection', 'make_bad_poke_sound'; ...
                                       'TimesSection', 'make_bad_boy_poke_sound'});
   
    NumeditParam(obj, 'StimuliVolumeFactor', 1, x, y, ...
        'TooltipString', sprintf(['\nFactor, can be in [0,10], that multiplies all\n' ...
        'poke stimuli sounds. Penalty sounds are unafected by this parameter.'])); next_row(y);
    set_callback(StimuliVolumeFactor, {mfilename, 'make_all_sounds'});
    
      
    next_row(y, 0.5);
    SubheaderParam(obj, 'title', 'Sound Definition', x, y);
    next_row(y, 1.5);
    
    
    
    % ==================================================================

    
    
    SoundManagerSection(obj, 'declare_new_sound', 'Poke1Left_stereo');
    SoundManagerSection(obj, 'declare_new_sound', 'Poke1Left_l');
    SoundManagerSection(obj, 'declare_new_sound', 'Poke1Left_r');
    SoundManagerSection(obj, 'declare_new_sound', 'Poke1Right_stereo');
    SoundManagerSection(obj, 'declare_new_sound', 'Poke1Right_l');
    SoundManagerSection(obj, 'declare_new_sound', 'Poke1Right_r');
    SoundManagerSection(obj, 'declare_new_sound', 'Poke2Left_stereo');
    SoundManagerSection(obj, 'declare_new_sound', 'Poke2Left_l');
    SoundManagerSection(obj, 'declare_new_sound', 'Poke2Left_r');
    SoundManagerSection(obj, 'declare_new_sound', 'Poke2Right_stereo');
    SoundManagerSection(obj, 'declare_new_sound', 'Poke2Right_l');
    SoundManagerSection(obj, 'declare_new_sound', 'Poke2Right_r');
    SoundManagerSection(obj, 'declare_new_sound', 'ILToneLeft_stereo');
    SoundManagerSection(obj, 'declare_new_sound', 'ILToneLeft_l');
    SoundManagerSection(obj, 'declare_new_sound', 'ILToneLeft_r');
    SoundManagerSection(obj, 'declare_new_sound', 'ILToneRight_stereo');
    SoundManagerSection(obj, 'declare_new_sound', 'ILToneRight_l');
    SoundManagerSection(obj, 'declare_new_sound', 'ILToneRight_r');
    
    
    feval(mfilename, obj, 'n_center_pokes');
    feval(mfilename, obj, 'make_all_sounds');
    SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
    
    SoloFunctionAddVars('StateMatrixSection', 'ro_args', ...
        {'n_center_pokes'; 'PunishLight1BadPokes'; 'Pk1_light_bpdur'; ...
         'Pk1Light'; 'Pk1ToneLocalization'; ...
         'InterLightGap'; 'ILToneLocalization'; ...
         'IL_ToneSoundType'; 'InterLightToneStart'; ...
         'PunishInterLightBadPokes'; 'PunishInterLightBadCenterPokes'; ...
         'IL_bpdur'; ...
         'PunishLight2BadPokes'; 'Pk2_light_bpdur'; ...
         'Pk2Light'; 'Pk2ToneLocalization'; ...
         'Center2SideGap'; ...
         'PunishCenter2SideBadPokes'; 'C2Side_bpdur'; ...
         'PunishSideLightBadPokes'; 'Side_light_bpdur'; ...
         'SideLights'});
  
   
    feval(mfilename, obj, 'update');
    
    
    
    
  case 'update'
    feval(mfilename, obj, 'compute_gap_durations');
    feval(mfilename, obj, 'compute_IL_tone_start');
    
  case 'n_center_pokes',
    pk1_guys = [get_sphandle('fullname', [mfilename '_' 'Pk1+']); ...
        {PunishLight1BadPokes}];
    
    il_guys = [get_sphandle('fullname', [mfilename '_' 'ILGap+']); ...
        get_sphandle('fullname', [mfilename '_' 'ILTone+']); ...
        {PunishInterLightBadPokes; PunishInterLightBadCenterPokes}];
    
    pk2_guys = [get_sphandle('fullname', [mfilename '_' 'Pk2+']); ...
        {PunishLight2BadPokes}];
    
    c2s_guys = [get_sphandle('fullname', [mfilename '_' 'C2Side+']); ...
        {PunishCenter2SideBadPokes}];
    
    set(get_glhandle(PunishLight1BadPokes), 'Enable', 'off');
    
    switch value(n_center_pokes),
        case 0,
            for i=1:length(pk1_guys), set(get_glhandle(pk1_guys{i}), 'Enable', 'off'); end;
            for i=1:length(il_guys), set(get_glhandle(il_guys{i}), 'Enable', 'off'); end;
            for i=1:length(pk2_guys), set(get_glhandle(pk2_guys{i}), 'Enable', 'off'); end;
            for i=1:length(c2s_guys), set(get_glhandle(c2s_guys{i}), 'Enable', 'off'); end;
        case 1,
            for i=1:length(pk1_guys), set(get_glhandle(pk1_guys{i}), 'Enable', 'on'); end;
            for i=1:length(il_guys), set(get_glhandle(il_guys{i}), 'Enable', 'off'); end;
            for i=1:length(pk2_guys), set(get_glhandle(pk2_guys{i}), 'Enable', 'off'); end;
            for i=1:length(c2s_guys), set(get_glhandle(c2s_guys{i}), 'Enable', 'on'); end;
        case 2,
            for i=1:length(pk1_guys), set(get_glhandle(pk1_guys{i}), 'Enable', 'on'); end;
            for i=1:length(il_guys), set(get_glhandle(il_guys{i}), 'Enable', 'on'); end;
            for i=1:length(pk2_guys), set(get_glhandle(pk2_guys{i}), 'Enable', 'on'); end;
            for i=1:length(c2s_guys), set(get_glhandle(c2s_guys{i}), 'Enable', 'on'); end;
    end;
            
  case 'make_all_sounds',
      feval(mfilename, obj, 'make_Poke1_Left_sound');
      feval(mfilename, obj, 'make_Poke1_Right_sound');
      feval(mfilename, obj, 'make_ILTone_Left_sound');
      feval(mfilename, obj, 'make_ILTone_Right_sound');
      feval(mfilename, obj, 'make_Poke2_Left_sound');
      feval(mfilename, obj, 'make_Poke2_Right_sound');
        
  case 'pk1_light',
      % if poke1 light is off, do not punish bad pokes during non-existent
      % light1
    if value(Pk1Light) == 0, 
        PunishLight1BadPokes.value = 0; 
        set(get_glhandle(PunishLight1BadPokes), 'Enable', 'off');
    else
        set(get_glhandle(PunishLight1BadPokes), 'Enable', 'on');
    end;
        
    
  case 'make_Poke1_Left_sound',
    soundtype = get(get_ghandle(Pk1SoundType), 'String');
    sound = make_sound(obj, soundtype, Pk1LeftDur, Pk1LeftFrequ, 60, 1);
    SoundManagerSection(obj, 'set_sound', 'Poke1Left_stereo', amp*sound*StimuliVolumeFactor, Pk1SndLoop(1));
    
    % makes sounds localized on the left and right
    sound_on_left = [sound(:)'; zeros(1, length(sound))];
    sound_on_right = [zeros(1, length(sound)); sound(:)'];
    SoundManagerSection(obj, 'set_sound', 'Poke1Left_l', amp*sound_on_left*StimuliVolumeFactor, Pk1SndLoop(1));
    SoundManagerSection(obj, 'set_sound', 'Poke1Left_r', amp*sound_on_right*StimuliVolumeFactor, Pk1SndLoop(1));
    
    
  case 'make_Poke1_Right_sound',     
    soundtype = get(get_ghandle(Pk1SoundType), 'String');
    sound = make_sound(obj, soundtype, Pk1RightDur, Pk1RightFrequ, 60, 1);
    SoundManagerSection(obj, 'set_sound', 'Poke1Right_stereo', amp*sound*StimuliVolumeFactor, Pk1SndLoop(1));
    
    % makes sounds localized on the left and right
    sound_on_left = [sound(:)'; zeros(1, length(sound))];
    sound_on_right = [zeros(1, length(sound)); sound(:)'];
    SoundManagerSection(obj, 'set_sound', 'Poke1Right_l', amp*sound_on_left*StimuliVolumeFactor, Pk1SndLoop(1));
    SoundManagerSection(obj, 'set_sound', 'Poke1Right_r', amp*sound_on_right*StimuliVolumeFactor, Pk1SndLoop(1));
    
  case 'compute_gap_durations',
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

  case 'compute_IL_tone_start',
    if ILToneStartMax >= ILGapMin, ILToneStartMax.value = value(ILGapMin)-0.5; end;
    if ILToneStartMin > ILToneStartMax, ILToneStartMin.value = value(ILToneStartMax); end;

    if ILToneStartMin == ILToneStartMax, InterLightToneStart.value = value(ILToneStartMax); 
    else
        T = ILToneStartMax - ILToneStartMin;
        InterLightToneStart.value = -ILToneStartTau * log(1 - rand(1)*(1 - exp(-T/ILToneStartTau)));
        InterLightToneStart.value = ILToneStartMin + round(InterLightToneStart*1000)/1000;
    end;

  case 'il_tone_sound_type',
    iltone_guys = [get_sphandle('fullname', [mfilename '_' 'ILTone+']); ...
        {PunishInterLightBadPokes}];
    
    switch value(IL_ToneSoundType),
        case 'off',
            for i=1:length(iltone_guys), set(get_glhandle(iltone_guys{i}), 'Enable', 'off'); end;
        case 'bups',
            for i=1:length(iltone_guys), set(get_glhandle(iltone_guys{i}), 'Enable', 'on'); end;
        case 'pure tones',
            for i=1:length(iltone_guys), set(get_glhandle(iltone_guys{i}), 'Enable', 'on'); end;
    end;
    
  case 'make_ILTone_Left_sound',
    soundtype = value(IL_ToneSoundType);
    % if ILTone is off, make bups anyway so that the sound exists on the
    % sound server
    if strcmpi(soundtype, 'off'), soundtype = 'bups'; end;
    
    sound = make_sound(obj, soundtype, ILToneLeftDur, ILToneLeftFrequ, 60, 1);
    SoundManagerSection(obj, 'set_sound', 'ILToneLeft_stereo', amp*sound*StimuliVolumeFactor);
      
    % makes sounds localized on the left and right
    sound_on_left = [sound(:)'; zeros(1, length(sound))];
    sound_on_right = [zeros(1, length(sound)); sound(:)'];
    SoundManagerSection(obj, 'set_sound', 'ILToneLeft_l', amp*sound_on_left*StimuliVolumeFactor);
    SoundManagerSection(obj, 'set_sound', 'ILToneLeft_r', amp*sound_on_right*StimuliVolumeFactor); 
      
  case 'make_ILTone_Right_sound',
    soundtype = value(IL_ToneSoundType);
    % if ILTone is off, make bups anyway so that the sound exists on the
    % sound server
    if strcmpi(soundtype, 'off'), soundtype = 'bups'; end;
    
    sound = make_sound(obj, soundtype, ILToneRightDur, ILToneRightFrequ, 60, 1);
    SoundManagerSection(obj, 'set_sound', 'ILToneRight_stereo', amp*sound*StimuliVolumeFactor);
      
    % makes sounds localized on the left and right
    sound_on_left = [sound(:)'; zeros(1, length(sound))];
    sound_on_right = [zeros(1, length(sound)); sound(:)'];
    SoundManagerSection(obj, 'set_sound', 'ILToneRight_l', amp*sound_on_left*StimuliVolumeFactor);
    SoundManagerSection(obj, 'set_sound', 'ILToneRight_r', amp*sound_on_right*StimuliVolumeFactor);
      
  case 'pk2_light',
    % if poke2 light is off, do not punish bad pokes during non-existent
    % light2
    if value(Pk2Light) == 0, 
        PunishLight2BadPokes.value = 0;
        set(get_glhandle(PunishLight2BadPokes), 'Enable', 'off');
    else
        set(get_glhandle(PunishLight2BadPokes), 'Enable', 'on');
    end;

  case 'make_Poke2_Left_sound',
    soundtype = get(get_ghandle(Pk2SoundType), 'String');
    sound = Pk2ToneVol*make_sound(obj, soundtype, Pk2LeftDur, Pk2LeftFrequ, 60, 1);
    SoundManagerSection(obj, 'set_sound', 'Poke2Left_stereo', amp*sound*StimuliVolumeFactor);
    
    % makes sounds localized on the left and right
    sound_on_left = [sound(:)'; zeros(1, length(sound))];
    sound_on_right = [zeros(1, length(sound)); sound(:)'];
    SoundManagerSection(obj, 'set_sound', 'Poke2Left_l', amp*sound_on_left*StimuliVolumeFactor);
    SoundManagerSection(obj, 'set_sound', 'Poke2Left_r', amp*sound_on_right*StimuliVolumeFactor);  

  case 'make_Poke2_Right_sound', 
    soundtype = get(get_ghandle(Pk2SoundType), 'String');
    sound = Pk2ToneVol*make_sound(obj, soundtype, Pk2RightDur, Pk2RightFrequ, 60, 1);
    SoundManagerSection(obj, 'set_sound', 'Poke2Right_stereo', amp*sound*StimuliVolumeFactor);
    
    % makes sounds localized on the left and right
    sound_on_left = [sound(:)'; zeros(1, length(sound))];
    sound_on_right = [zeros(1, length(sound)); sound(:)'];
    SoundManagerSection(obj, 'set_sound', 'Poke2Right_l', amp*sound_on_left*StimuliVolumeFactor);
    SoundManagerSection(obj, 'set_sound', 'Poke2Right_r', amp*sound_on_right*StimuliVolumeFactor);  

      
  case 'side_lights',
    switch value(SideLights)
        case 'off',
            PunishSideLightBadPokes.value = 0;
            set(get_glhandle(PunishSideLightBadPokes), 'Enable', 'off');
        case 'correct side only',
            set(get_glhandle(PunishSideLightBadPokes), 'Enable', 'on');
        case 'both sides on',
            set(get_glhandle(PunishSideLightBadPokes), 'Enable', 'on');
    end;
    
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



function [sound] = make_sound(obj, soundtype, duration, frequency, spl, volume_factor)
    srate = SoundManagerSection(obj, 'get_sample_rate');

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
    
    return;
