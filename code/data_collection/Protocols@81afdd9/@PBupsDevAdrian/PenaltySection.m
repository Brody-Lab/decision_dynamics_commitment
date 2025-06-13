% @PBups/PenaltySection.m
% Bing, March 2009


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


function [x, y] = PenaltySection(obj, action, x, y)
   
GetSoloFunctionArgs;

switch action
%% init
  case 'init',
    [x, y] = DistribInterface(obj, 'add', 'ITI', x, y, 'Style', ...
                    'gaussian', 'Mu', 0.001, 'Sd', 0.001, 'Min', 0, 'Max', 20);
    NumeditParam(obj, 'miss_ITI', 0, x, y, ...
        'TooltipString', 'extra ITI when previos trial was an error');
    next_row(y,1.5);
    
    % Save the figure and the position in the figure where we are
    % going to start adding GUI elements:
    fig = double(gcf);
    SoloParamHandle(obj, 'my_gui_info', 'value', [x y fig]);

    % this is the only thing that shows up on the main GUI window:
    ToggleParam(obj, 'penalty_button', 0, x, y, ...
        'OnString', 'Penalties Panel Showing', ...
        'OffString', 'Penalties Panel Hidden', ...
        'TooltipString', 'Show/Hide the window that controls penalties for the protocol');
    next_row(y);
    set_callback(penalty_button, {mfilename, 'window_toggle'}); %#ok<NODEF>

    origx = x; origy = y;
    

    % Now we set up the window that pops up to specify penalties
    SoloParamHandle(obj, 'mypfig', 'saveable', 0, 'value', ...
        figure('position', [409   316   420   700], ...
            'MenuBar', 'none',  ...
            'NumberTitle', 'off', ...
            'Name','PBups Penalty Settings', ...
            'CloseRequestFcn', [mfilename ...
            '(' class(obj) ', ''hide_window'');']));

        
    x = 5; y = 5; boty = 5;
    
    
    [x, y] = PunishInterface(obj, 'add', 'CenterLightPun', x, y);
    PunishInterface(obj, 'set', 'CenterLightPun', 'SoundsPanel', 0);
    
    ToggleParam(obj, 'PunishCL1BadPokes', 0, x, y, ...
        'OffString', 'do not punish wrong pokes in c light', ...
        'OnString',  'punish wrong pokes in center light', ...
        'TooltipString', sprintf(['\nIf brown, poking in a bad port during center light has no effect;' ...
                                  '\nIf black, poking emits Violation1Sound and center light reinits']));
    
    
    next_row(y,2);
    
    [x, y] = PunishInterface(obj, 'add', 'C2SPun', x, y);
    PunishInterface(obj, 'set', 'C2SPun', 'SoundsPanel', 0);   

    MenuParam(obj, 'AfterC2SPunishment', {'play_stimulus_sound', 'play_stimulus_goto_c2sgap'}, 1, ...
      x, y, 'position', [x y 200 40], 'labelpos', 'bottom', 'TooltipString', ...
      sprintf(['\nThis param has no effect unless side pokes in c2sgap are being punished.' ...
               '\n"play_stimulus_sound" means that after such a punishment, we go back to the ' ...
               '\nstate that follows the end of wait_for_cpoke1 (usually cpoke1).' ...
               '\n"play_stimulus_goto_c2sgap" means that after such a punishment, the stimulus ' ...
               '\nsound is restarted, but we go straight back to reinitializing the' ...
               '\ncenter_2_side_gap state'])); next_row(y); next_row(y);
    
    ToggleParam(obj, 'PunishC2SSidePokes', 0, x, y, ...
        'OffString', 'do not punish side pokes in c2s gap', ...
        'OnString',  'punish side pokes in c2s gap', ...
        'TooltipString', sprintf(['\nIf brown, poking during center to side gap has no effect;' ...
                                  '\nIf black, poking emits Violation2Sound and c2s gap reinits']));
    next_row(y);
    
    ToggleParam(obj, 'PunishC2SCenterPokes', 0, x, y, ...
        'OffString', 'do not punish center pokes in c2s gap', ...
        'OnString',  'punish center pokes in c2s gap', ...
        'TooltipString', sprintf(['\nIf brown, poking during center to side gap has no effect;' ...
                                  '\nIf black, poking emits Violation2Sound and c2s gap reinits']));
    next_row(y,2);

    
    [x, y] = PunishInterface(obj, 'add', 'ITIPun', x, y);
    PunishInterface(obj, 'set', 'ITIPun', 'SoundsPanel', 0);
    ToggleParam(obj, 'PunishITIPokes', 0, x, y, ...
        'OffString', 'do not punish pokes during ITI', ...
        'OnString',  'punish pokes during ITI', ...
        'TooltipString', 'if black, punish pokes during ITI with Violation3Sound');    
    
    next_row(y, 2);
    MenuParam(obj, 'TempPunChoice', {'non-reinit temp pun', 'reinit-able temp pun'}, 1, x, y, ...
      'TooltipString', sprintf(['\n"non-reinit temp pun" is a single sound that plays and then ' ...
                                '\nwe return to wait_for_cpoke (if nose was out) or to start of cpoke1 ' ...
                                '\n(if nose is in). "reinit-able temp pun" uses PunishInterface and ' ...
                                '\n*assumes* the nose is out when the punishment ends. non-reinit is ' ...
                                '\nbest used when reinit is not desired, reinit-able when the reinit is ' ...
                                '\ndesired'])); next_row(y); y = y+2;
    set_callback(TempPunChoice, {mfilename 'TempPunChoice'});                          
    [x, y] = SoundInterface(obj, 'add', 'TempPun', x, y); y = y+2;
    SoundInterface(obj, 'set', 'TempPun', 'Style', 'WhiteNoise', 'Vol', 0.01, 'Dur1', 0.1, ...
      'Loop', 0, 'Bal', 0);
    
    
    next_column(x); y = boty;
    
    ToggleParam(obj, 'SoftDrinkTime', 1, x, y, 'position', [x y 120 20], ...
        'OffString', 'no soft drink time', ...
        'OnString',  'allow soft drink time', ...
        'TooltipString', sprintf(['soft drink time delays the start of next trial until the rat' ...
                                  '\nhas finished drinking. SoftDrinkGrace is how much time the rat' ...
                                  '\ncan spend outside the reward port before the system thinks' ...
                                  '\nhe''s finished drinking.']));
    next_row(y);
    ToggleParam(obj, 'WD_in_sdt', 0, x, y, ... 'position', [x+130 y 70 20], ...
        'OffString', 'no WD in softDT', ...
        'OnString',  'WD in softDT', ...
        'TooltipString', sprintf(['\nIf on (black bg), soft drinktime ends with warning and danger' ...
                                  '\nnoises. Otherwise, soft drinktime ends by going straight to new trial']));
    next_row(y);
    NumeditParam(obj, 'SoftDrinkGrace', 1, x, y, ...'position', [x y 150 20], ...
        'TooltipString', 'After this amount of time has passed without licks, we assume he is done drinking and go on');
    next_row(y);
    NumeditParam(obj, 'SoftDrinkCap', 5, x, y, ...'position', [x y 150 20], ...
        'TooltipString', 'Maximum time cap for drinking, including DrinkTime'); 
    next_row(y);
    NumeditParam(obj, 'DrinkTime', 2, x, y, 'TooltipString', sprintf('\nTime over which drinking is ok')); 
    feval(mfilename, obj, 'check_drink_time');
    next_row(y);
    ToggleParam(obj, 'WarningSoundPanel', 0, x, y, ...
                     'OnString', 'show Warn. & Dang. sounds', ...
                     'OffString', 'hide Warn. & Dang. sounds'); 
    next_row(y);
    NumeditParam(obj, 'WarnDur', 1, x, y, ...
                      'TooltipString', 'Warning sound duration in secs');
    next_row(y);
    NumeditParam(obj, 'DangerDur', 2, x, y, ...
                      'TooltipString', 'Duration of post-drink period where poking is punished');
    next_row(y);
    set_callback(WarningSoundPanel, {mfilename, 'WarningSoundPanel'});
    % start subpanel
      oldx = x; oldy = y; oldfigure = double(gcf);
      SoloParamHandle(obj, 'WarningSoundPanelFigure', 'saveable', 0, 'value', figure('Position', [120 120 430 156]));
      sfig = value(WarningSoundPanelFigure);
      set(sfig, 'MenuBar', 'none', 'NumberTitle', 'off', ...
        'Name', 'Warning sound', 'CloseRequestFcn', 'Classical(classical, ''closeWarningSoundPanel'')');
      SoundInterface(obj, 'add', 'WarningSound', 10,  10);
      SoundInterface(obj, 'set', 'WarningSound', 'Vol',   0.0002);
      SoundInterface(obj, 'set', 'WarningSound', 'Vol2',  0.004);
      SoundInterface(obj, 'set', 'WarningSound', 'Dur1',  1);
      SoundInterface(obj, 'set', 'WarningSound', 'Loop',  0);
      SoundInterface(obj, 'set', 'WarningSound', 'Style', 'WhiteNoiseRamp');
      
      SoundInterface(obj, 'add', 'DangerSound',  215,  10);
      SoundInterface(obj, 'set', 'DangerSound', 'Vol',   0.004);
      SoundInterface(obj, 'set', 'DangerSound', 'Dur1',  1);
      SoundInterface(obj, 'set', 'DangerSound', 'Loop',  1);
      SoundInterface(obj, 'set', 'DangerSound', 'Style', 'WhiteNoise');

      x = oldx; y = oldy; figure(oldfigure);
    % end subpanel
    feval(mfilename, obj, 'WarningSoundPanel');
    SoloFunctionAddVars('StateMatrixSection', 'ro_args', {'DrinkTime', 'WarnDur', 'DangerDur'});
    [x, y] = PunishInterface(obj, 'add', 'PostDrinkPun', x, y);
    PunishInterface(obj, 'set', 'PostDrinkPun', 'SoundsPanel', 0);
    set_callback(DangerDur, {mfilename, 'DangerDur_triggers'});
    set_callback(WarnDur, {mfilename, 'WarnDur_triggers'});
    
    next_row(y, 1);
    
    NumeditParam(obj, 'wait_for_cpoke1_tout', 10000, x, y, ...
          'labelfraction', 0.7, ...
          'TooltipString', sprintf(['\nIf we''re in "one cpoke w/legal breaks" mode, then this param counts' ...
                                    '\nhow long, in secs, to wait for the animal to make the first cpoke. If this much' ...
                                    '\ntime passes in the wait_for_cpoke1 state without a cpoke, we go directly to' ...
                                    '\ncenter_2_side_gap state, ignoring the fact that no cpoke happened (let alone of' ...
                                    '\nappropriate duration).' ...
                                    '\n   If in "count cpokes" mode, this param is irrelevant.']));
                                
    next_row(y);
                                
    ToggleParam(obj, 'cleanup_on_cpoke1_tup', 0, x, y,'position', [x+180 y-25 20 20], ...
      'TooltipString', sprintf(['\nIf brown, transition to wait for side poke state after cpoke1 tup;' ...
                                '\nIf black, transition to clean up state after cpoke1 tup.']));
      
    next_row(y, 2);
  
    
    [x, y] = PunishInterface(obj, 'add', 'ErrorPun', x, y);
    PunishInterface(obj, 'set', 'ErrorPun', 'SoundsPanel', 0);
    
    [x, y] = PunishInterface(obj, 'add', 'TimeOutPun', x, y);
    PunishInterface(obj, 'set', 'TimeOutPun', 'SoundsPanel', 0);

    ToggleParam(obj, 'LEDtemp_pun', 0, x, y, 'position', [x+180 y-25 20 20], ...
      'TooltipString', sprintf(['\nIf brown, side light choice doesn''t stay on in temporary punsihment;' ...
                                '\nIf black, it does stay on']));
    
    ToggleParam(obj, 'SideChoicePunishmentType', 0, x, y, ...
        'OffString', 'trial terminates -> error sound', ...
        'OnString',  'temporary time out', ...
        'TooltipString', sprintf(['\nIf brown, upon wrong side choice the trial is terminated and TimeOutSound plays' ...
                                  '\nIf black, wrong side choice plays TempTOSound; stimulus sound is not turned off']));
    next_row(y);
    
    ToggleParam(obj, 'PunishSideChoice', 1, x, y, ...
        'OffString', 'do not punish wrong side choice', ...
        'OnString',  'punish wrong side choice', ...
        'TooltipString', 'If black, punish wrong side choice: choose type of punishment');

    next_row(y);


    SubheaderParam(obj, 'empty_seprator', '', x, y); next_row(y);
    [x, y] = SoundInterface(obj, 'add', 'WFCOPun', x, y);     
    MenuParam(obj, 'PunishSidePokesinWFCO', {'ignore side pokes','punish side pokes','forbid side pokes'},1, x, y, ...
      'TooltipString', sprintf(['\n' ...
      'If 1, side pokes during WFCO are ignored.\nIf 2, side pokes are punished with selected sound.\n' ...
      'If 3, side pokes are punished and the trial is terminated before any reward can be delivered.'])); next_row(y);
    ToggleParam(obj, 'WaitForCenterNoseOut', 0, x, y, ...
      'OffString', 'no "wait for center nose out" state', ...
      'OnString',  'have "wait for center nose out" state', ...
      'TooltipString', sprintf(['\n' ...
      'If black, then after cpoke1 we go into a state that waits until Cout before\n' ...
      'rewards or errors can happen. The purpose of this state is to discourage double-poking,\n' ...
      'where a paw is left behind in the center poke while the nose pokes into a side poke.'])); next_row(y);
    SubheaderParam(obj, 'SimultaneousPokes', 'Simultaneous Pokes', x, y); next_row(y);
    

    
    SoloFunctionAddVars('StateMatrixSection', 'ro_args', ...
          {'PunishCL1BadPokes'; ...
          'PunishC2SSidePokes'; 'AfterC2SPunishment' ; ...
          'PunishC2SCenterPokes'; ...
          'PunishSideChoice'; 'SideChoicePunishmentType';...
          'PunishITIPokes'; 'SoftDrinkTime'; 'WD_in_sdt' ; ...
          'SoftDrinkGrace'; 'SoftDrinkCap'; ...
          'cleanup_on_cpoke1_tup' ;  ...
          'wait_for_cpoke1_tout'; ...
          'miss_ITI'; 'TempPunChoice' ; 'LEDtemp_pun' ; ...
		  'WaitForCenterNoseOut'; 'PunishSidePokesinWFCO';});
      
    SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
    feval(mfilename, obj, 'window_toggle');    
   
    x = origx; y = origy; figure(fig);
    return;
%% check_drink_time
    case 'check_drink_time'
        if exist('DrinkTime', 'var')
            if ~isempty(PBupsSection(obj, 'get_ReplaySpecs'))
                disable(DrinkTime)
            else
                enable(DrinkTime)
            end
        end
%% get_ITI
  case 'get_ITI',
	DistribInterface(obj, 'sample', 'ITI');
	if ~isempty(hit_history) && hit_history(n_done_trials)==0,
		extra_iti = value(miss_ITI);
	else
		extra_iti = 0;
	end;
    x = DistribInterface(obj, 'get_current_sample', 'ITI') + extra_iti;
%% window_toggle
  case 'window_toggle', 
    if value(penalty_button) == 1,  %#ok<NODEF>
            set(value(mypfig), 'Visible', 'on');    
    else
            set(value(mypfig), 'Visible', 'off');
    end;
    
%% hide_window
  case 'hide_window', 
    penalty_button.value_callback = 0;
    
%% WarningSoundPanel
  case 'WarningSoundPanel'
    if WarningSoundPanel==0, set(value(WarningSoundPanelFigure), 'Visible', 'off');
    else                     set(value(WarningSoundPanelFigure), 'Visible', 'on');
    end;
%% WarnDur_triggers
    case 'WarnDur_triggers'
        if value(WarnDur) < eps
            SoundInterface(obj, 'disable_all', 'WarningSound')
        else
            SoundInterface(obj, 'enable_all', 'WarningSound')
        end
%% DangerDur_triggers
    case 'DangerDur_triggers'
        if value(DangerDur) < eps
            SoundInterface(obj, 'disable_all', 'DangerSound')
            PunishInterface(obj, 'disable', 'PostDrinkPun')
        else
            SoundInterface(obj, 'enable_all', 'DangerSound')
            PunishInterface(obj, 'enable', 'PostDrinkPun') 
        end
%% close
  case 'close',
    if exist('WarningSoundPanelFigure', 'var'),
      delete(value(WarningSoundPanelFigure));
    end;  
    delete(value(mypfig));    
    
%% reinit
  case 'reinit',
    currfig = double(gcf);

    % Get the original GUI position and figure:
    x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);
    DistribInterface(obj, 'reinit', 'ITI');

    % Reinitialise at the original GUI position and figure:
    [x, y] = feval(mfilename, obj, 'init', x, y);

    % Restore the current figure:
    figure(currfig);
end;


