% @Multipokes3/TimesSection.m
% Bing, June 2007


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
    NumeditParam(obj, 'drinkt_min', 2.5, x, y, 'position', [x y 70 20], ...
      'TooltipString', 'Minimum drink time, in secs');
    NumeditParam(obj, 'soft_dt', 0.5, x, y, 'position', [x+70 y 70 20], ...
      'TooltipString', sprintf('\nAfter drinkt_min, if the rat is out of pokes for this long, drinking time ends')); 
    NumeditParam(obj, 'drinkt_max', 0.5, x, y, 'position', [x+140 y 70 20], ...
      'TooltipString', sprintf('\nHard maximum cap on drink time, no matter what the rat is doing')); 
    next_row(y);
    ToggleParam(obj, 'WarningSoundPanel', 0, x, y, 'OnString', 'warn show', 'OffString', 'warn hide', 'position', [x y 80 20]); 
    NumeditParam(obj, 'WarnDur',   4, x, y, 'labelfraction', 0.6, 'TooltipString', 'Warning sound duration in secs (zero means no warning)', 'position', [x+80 y 60 20]);
    NumeditParam(obj, 'DangerDur', 5, x, y, 'labelfraction', 0.6, 'TooltipString', sprintf('\nDuration of post-drink period where poking is punished (zero means no danger)'), 'position', [x+140 y 60 20]); next_row(y);
    set_callback(WarningSoundPanel, {mfilename, 'WarningSoundPanel'});
      % start subpanel
      oldx = x; oldy = y; oldfigure = gcf;
      SoloParamHandle(obj, 'WarningSoundPanelFigure', 'saveable', 0, 'value', figure('Position', [120 120 430 156]));
      sfig = value(WarningSoundPanelFigure);
      set(sfig, 'MenuBar', 'none', 'NumberTitle', 'off', ...
        'Name', 'Warning sound', 'CloseRequestFcn', 'Classical(classical, ''closeWarningSoundPanel'')');
      SoundInterface(obj, 'add', 'WarningSound', 10,  10);
      SoundInterface(obj, 'set', 'WarningSound', 'Vol',   0.0002);
      SoundInterface(obj, 'set', 'WarningSound', 'Vol2',  0.004);
      SoundInterface(obj, 'set', 'WarningSound', 'Dur1',  4);
      SoundInterface(obj, 'set', 'WarningSound', 'Loop',  0);
      SoundInterface(obj, 'set', 'WarningSound', 'Style', 'WhiteNoiseRamp');
      
      SoundInterface(obj, 'add', 'DangerSound',  215,  10);
      SoundInterface(obj, 'set', 'DangerSound', 'Vol',   0.004);
      SoundInterface(obj, 'set', 'DangerSound', 'Dur1',  1);
      SoundInterface(obj, 'set', 'DangerSound', 'Loop',  1);
      SoundInterface(obj, 'set', 'DangerSound', 'Style', 'WhiteNoise');
      set(sfig, 'Visible', 'off');
      
      x = oldx; y = oldy; figure(oldfigure);
    % end subpanel
    SoloFunctionAddVars('StateMatrixSection', 'ro_args', {'drinkt_min', 'drinkt_max', 'soft_dt', 'WarnDur', 'DangerDur'});
   
    [x, y] = PunishInterface(obj, 'add', 'PostDrinkPun', x, y);  %#ok<NASGU>
    PunishInterface(obj, 'set', 'PostDrinkPun', 'SoundsPanel', 0);
    next_row(y, 1.5);

    NumeditParam(obj, 'mu_ITI', 2, x, y, 'position', [x y 100 20], ...
        'labelfraction', 0.7, 'TooltipString', 'mean inter-trial-interval, in secs');
    NumeditParam(obj, 'sd_ITI', 0.1, x, y, 'position', [x+100 y 100 20], ...
        'labelfraction', 0.7, 'TooltipString', 'st dev ITI, in secs');
    next_row(y);
    DispParam(obj, 'ITI',           4, x, y, ...
        'TooltipString', 'Inter Trial Interval, secs before trial end signal is sent'); next_row(y, 1);  
    NumeditParam(obj, 'ExtraITIOnError', 3, x, y, ...
        'TooltipString', 'extra secs pause if error trial'); next_row(y, 1.5);
    ToggleParam(obj, 'PunishITIBadPokes', 0, x, y, ...
        'OffString', 'do not punish wrong port pokes in ITI', ...
        'OnString', 'punish wrong port pokes in ITI', ...
        'TooltipString', ...
        sprintf(['\nIf brown, poking in a bad port during iti has no effect;\nif black, bad boy poke sound ' ...
        'is emitted and light2 reinits'])); next_row(y);
    NumeditParam(obj, 'ITI_bpdur', 3, x, y); next_row(y);
    
    
    DispParam(obj, 'BadPokeSoundType', 'white noise', x, y, ...
        'labelfraction', 0.65, ...
        'TooltipString', 'Type of sound in response to wrong side choice'); 
    next_row(y);
    DispParam(obj, 'BadBoyPokeSoundType', 'bad boy noise', x, y, ...
        'labelfraction', 0.65, ...
        'TooltipString', 'Type of sound in response to pokes where no light is on');
    next_row(y);
    ToggleParam(obj, 'UseAnnoyingSoundPenalty', 0, x, y,  ...
        'OffString', 'do not use annoying sound penalty', ...
        'OnString',  'punish with annoying sound plus bad boy noise', ...
        'TooltipString', ...
        sprintf(['If brown, punishment is the regular bad boy noise' ...
                 '\n If black, punishment with bad boy noise follows a short, loud, horrible annoying sound']));
    next_row(y);
    NumeditParam(obj, 'AnnoyingVolumeFactor', 1, x, y, ...
        'labelfraction', 0.7, ...
        'TooltipString', 'Factor, can be in [0, 10], that multiplies the annoying sound penalty');
    next_row(y);
    set_callback(AnnoyingVolumeFactor, {mfilename, 'make_annoying_sound'});
    
    SoundManagerSection(obj, 'declare_new_sound', 'bad_poke_sound');
    SoundManagerSection(obj, 'declare_new_sound', 'bad_boy_poke_sound');
    SoundManagerSection(obj, 'declare_new_sound', 'annoying_sound');
    
    %set_callback(BadPokeSoundType, {mfilename, 'make_bad_poke_sound'});
    %set_callback(BadBoyPokeSoundType, {mfilename, 'make_bad_boy_poke_sound'});
    feval(mfilename, obj, 'make_bad_poke_sound');    
    feval(mfilename, obj, 'make_bad_boy_poke_sound');
    feval(mfilename, obj, 'make_annoying_sound');
    
    
    
    
    ToggleParam(obj, 'PunishBadSideChoice', 0, x, y, ...
        'OffString', 'do not punish bad side choice', ...
        'OnString',  'punish bad side choice');
    next_row(y);
    ToggleParam(obj, 'BadSideChoicePunishment', 0, x, y, ...
        'OffString', 'punishment: trial terminates', ...
        'OnString',  'punishment: temporary white noise', ...
        'TooltipString', ' ');
    next_row(y);
    NumeditParam(obj, 'TempError', 5, x, y, ...
        'TooltipString', 'time out in sec with white noise upon bad side choice');
    next_row(y);
    set_callback(PunishBadSideChoice, {mfilename, 'punish_bad_side_choice_callback'});
    feval(mfilename, obj, 'punish_bad_side_choice_callback');
      
    SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');

    
    
    next_row(y, 0.5);
    SubheaderParam(obj, 'title', 'Times and Punishments', x, y);
    next_row(y, 1.5);
    
    SoloFunctionAddVars('StateMatrixSection', 'ro_args', ...
                        {'water_wait'; 'ITI'; 'ExtraITIOnError'; ...
                         'PunishBadSideChoice'; 'BadSideChoicePunishment'; ...
                         'TempError'; 'UseAnnoyingSoundPenalty'; ...
                         'PunishITIBadPokes'; 'ITI_bpdur'});

                       
    %---------------------------------------------------------------
    %          WarningSoundPanel
    %---------------------------------------------------------------

  case 'WarningSoundPanel'
    if WarningSoundPanel==0, set(value(WarningSoundPanelFigure), 'Visible', 'off');
    else                     set(value(WarningSoundPanelFigure), 'Visible', 'on');
    end;
                       
                       
  case 'compute_iti',
    ITI.value = mu_ITI + sd_ITI*randn(1);
    if ITI < 0.05, ITI.value = 0.05; end;  
  
  case 'punish_bad_side_choice_callback'
    if PunishBadSideChoice == 0, 
        set(get_ghandle({BadSideChoicePunishment; TempError}), 'Enable', 'off');
    else
        set(get_ghandle({BadSideChoicePunishment; TempError}), 'Enable', 'on');
    end;
    
  case 'make_bad_poke_sound'
    % make the bad poke sound, played in response to bad side choice during
    % time out
    amp = 0.005;
    srate = SoundManagerSection(obj, 'get_sample_rate');
    bp_sound = amp*PenaltyVolumeFactor*randn(1, srate);
    SoundManagerSection(obj, 'set_sound', 'bad_poke_sound', bp_sound);
    
  case 'make_bad_boy_poke_sound'
    % make a half-second bad boy poke sound, played in response to breaks
    % in trial structure
    % currently, it's louder than bad_pokes_sound and 0.5 sec long
    amp = 0.007;
    srate = SoundManagerSection(obj, 'get_sample_rate');
    bbp_sound = amp*PenaltyVolumeFactor*randn(1, srate*0.5);
    SoundManagerSection(obj, 'set_sound', 'bad_boy_poke_sound', bbp_sound);
    
  case 'make_annoying_sound'
    a_sound = Make_annoying_sound(0.25, 'volume_factor', value(AnnoyingVolumeFactor));
    SoundManagerSection(obj, 'set_sound', 'annoying_sound', a_sound);
    
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


