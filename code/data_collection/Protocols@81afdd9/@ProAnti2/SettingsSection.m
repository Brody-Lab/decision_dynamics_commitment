
% [x, y] = SettingsSection(obj, action, x, y)
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
% 			'numpokes'  ...
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


function [x, y] = SettingsSection(obj, action, x, y)

GetSoloFunctionArgs;

switch action
    case 'init',
        % Save the figure and the position in the figure where we are
        % going to start adding GUI elements:
        fig = double(gcf);
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y fig]);
        
        % need code here to make sure it is the only one

        ToggleParam(obj, 'settings_btn', 0, x, y, ...
            'OnString', 'Settings Panel Showing', ...
            'OffString', 'Settings Panel Hidden', ...
            'TooltipString', ['Show/Hide window that controls ' ...
            'the settings for the protocol'], ...
            'OnFontWeight', 'bold', 'OffFontWeight', 'normal');
            
            set_callback(settings_btn, {mfilename, 'window_toggle'}); %#ok<NODEF>
    
    next_row(y);

        oldx = x; oldy = y;

        SoloParamHandle(obj, 'myfig', 'saveable', 0, 'value', ...
            figure('position', [600   376   775   550], ...
            'MenuBar', 'none',  ...
            'NumberTitle', 'off', ...
            'Name','ProAnti2 Settings', ...
            'CloseRequestFcn', [mfilename ...
            '(' class(obj) ', ''hide_window'');']));

% for debugging
% callback(settings_btn);
           

           ToggleParam(obj, 'sounds_btn', 0, 5, 5, ...
            'OnString', 'Hide Sounds Panel', ...
            'OffString', 'Show Sounds Panel', ...
            'TooltipString', ['Show/Hide window that controls ' ...
            'the settings for the sounds'], ...
            'OnFontWeight', 'normal', 'OffFontWeight', 'normal');
            
            set_callback(sounds_btn, {mfilename, 'snd_window_toggle'}); %#ok<NODEF>
            
            SoloParamHandle(obj, 'soundsfig', 'saveable', 0, 'value', ...
            figure('position', [ 53   717   818   433], ...
            'MenuBar', 'none', 'Name', 'ProAnti2 Sounds', ...
            'NumberTitle', 'off', ...
            'CloseRequestFcn', [mfilename ...
            '(' class(obj) ', ''hide_snd_window'');']));
            
            x=5;y=5; boty=5;
            
            [x,y]=SoundInterface(obj,'add','StartTrialSound',x,y, 'TooltipString',...
               [ '\nThis sound will play at the start of a trial to tell the rat the trial will begin.\n' ...
               'After delay2start the led for poke1 will appear']);

            [x,y]=SoundInterface(obj,'add','ProSound',x,y);
            [x,y]=SoundInterface(obj,'add','AntiSound',x,y); %#ok<NASGU>
            next_column(x); y=boty;
            [x,y]=SoundInterface(obj,'add','RightSound',x,y);
            [x,y]=SoundInterface(obj,'add','CenterSound',x,y);
            [x,y]=SoundInterface(obj,'add','LeftSound',x,y); %#ok<NASGU>
            next_column(x); y=boty;
            [x,y]=SoundInterface(obj,'add','HitSound',x,y);
            [x,y]=SoundInterface(obj,'add','MissSound',x,y);
            [x,y]=SoundInterface(obj,'add','ViolationSound',x,y); %#ok<NASGU>
			next_column(x); y=boty;
			[x,y]=SoundInterface(obj,'add','BadBoySound',x,y);
			[x,y]=SoundInterface(obj,'add','ITISound',x,y); %#ok<NASGU>
            
   figure(value(myfig));     
   
   % For debugging purpose
    
        
%% Make SoloUIParams


        % ---- Now to initialising the new window
  x=5;y=5;boty=5;
  
next_row(y);next_row(y);

MenuParam(obj, 'nPokes', {'1' '2' '3'}, 3, x, y, 'labelfraction' , 0.65);
set_callback(nPokes,{mfilename,'numPokes'});
next_row(y);

NumeditParam(obj, 'pro_prob', .5, x, y, 'labelfraction' , 0.65);
set_callback(nPokes,{mfilename,'numPokes'});
next_row(y);

ToggleParam(obj, 'trial_type', 0, x,y, 'OnString', 'Reaction Time','OffString','Memory',...
    'TooltipString',sprintf('\nIf this is set to reaction time, the poke2sound stops as soon as he leaves the poke'));
set_callback(trial_type, {mfilename,'trial_toggle'});
next_row(y);

NumeditParam(obj, 'poke3resp_dist', '.5 0 .5', x,y, 'labelfraction' , 0.4, 'TooltipString', ...
  sprintf(['\nIf this has 1 element, it is the left probability.\n'...
  'Two elements has the same functionality as one element'...
  'Three elements imply [left center right] probability']));
set_callback(poke3resp_dist, {mfilename,'normProb', 'poke3resp_dist'});
next_row(y);

NumeditParam(obj, 'fullprior', '0.25 0.25 0.25 0.25', x, y, 'labelpos', 'top', 'label', ...
  'AL      AR      PL      PR', 'position', [x, y,  113, 40], 'TooltipString', ...
  sprintf(['\nIf Override is on, then next trial prior prob is calculated from this ' ...
  '\n4 element vector, not from poke3resp_dist and pro_prob.']));
SoloParamHandle(obj, 'old_fprior', 'value', [0.25 0.25 0.25 0.25]);
set_callback(fullprior, {mfilename, 'fullprior'}); %#ok<NODEF>
ToggleParam(obj, 'prior_override', 0, x, y, 'position', [x+120 y+10 80 20], ...
  'OnString', 'override', 'OffString', 'normal', 'TooltipString', ...
  sprintf(['\nOn override, the vector to the left overrides any value of poke3resp_dist' ...
  '\nand pro_prob to make the prior for trial types. On normal, the vector to the left is ignored.']));
set_callback(prior_override, {mfilename, 'prior_override'});
set_default_reset_value(prior_override, {0}); disable(fullprior);
next_row(y); next_row(y);
SoloFunctionAddVars('StateMatrixSection', 'ro_args', {'prior_override', 'fullprior'});
SoloFunctionAddVars('PerformanceSection', 'ro_args', {'prior_override', 'fullprior'});
DispParam(obj, 'hitfrac', '1 1 1 1', x, y, 'labelfraction', 0.435, ...
  'TooltipString', sprintf('\nhitfrac calculated using antibias tau.')); disable(hitfrac); next_row(y);
DispParam(obj, 'posterior', '0.25 0.25 0.25 0.25', x, y, 'labelfraction', 0.435, ...
  'TooltipString', sprintf('\nPosterior after antibias and before MaxSame.')); disable(posterior); next_row(y);
MenuParam(obj, 'repeat_on_error', {'Always','Never','Violation Only','Miss Only'} ,3, x,y);
SoloFunctionAddVars(repeat_on_error, 'ro_args',{'ProAnti2'}); next_row(y);
MenuParam(obj, 'MaxSame', {'Inf','1','2','3','4','5','6','8','10','15','20'},1, x,y); next_row(y);
SubheaderParam(obj, 'subhead1' , 'Essential Task Parameters',x,y); next_row(y, 1.5);

 states_explanation = ['\n A Violation ends the trial with a NaN in the hit history, and a Miss ends the trial with a 0 in the hit history.'...
     '\nBlank means no effect, and Badboy plays a punishment sound, but allows the trial to continue. '];
 contoutputbp         = '\nControls the output state of "bad pokes" during the ';
 contoutputto         = '\nControls the output state of a TimeOut of the ';
 contmintimeto        = '\nControls the minimum time to TimeOut of the ';
 contmaxtimeto        = '\nControls the maximum time to TimeOut of the ';
 timecomp             = 'time in which rat can complete ';
 failcomp             = 'failure to complete ';  

NumeditParam(obj, 'delay2startTO', .001, x,y, 'labelfraction' , 0.65); next_row(y);
MenuParam(obj, 'bp_del2start_state', {'', 'violation_state','miss_state','badboy_state'}, 1, x,y, 'labelfraction' , 0.65, ...
                'TooltipString', sprintf(badpokeout('delay2start')));next_row(y);
NumeditParam(obj, 'poke1TO_max', 5, x,y, 'labelfraction' , 0.65, ...
                'TooltipString', [contmaxtimeto 'wait for poke 1 state (' timecomp 'poke 1']); next_row(y);
NumeditParam(obj, 'poke1TO_min', 1, x,y, 'labelfraction' , 0.65); next_row(y);
MenuParam(obj, 'poke1TO_state', {'', 'violation_state','miss_state','badboy_state','poke1sound'}, 1, x, y, 'labelfraction' , 0.45,...
    'TooltipString',sprintf(timeout('wait for poke 1'))); next_row(y);
NumeditParam(obj, 'poke1led_prob', '0 1 0', x,y, 'labelfraction' , 0.45);
set_callback(poke1led_prob, {mfilename,'normProb', 'poke1led_prob'}); next_row(y);
ToggleParam(obj, 'show_poke1leds', 1, x,y,'OnString','Poke1 LEDs ON','OffString','Poke1 LEDs OFF');next_row(y);
MenuParam(obj, 'bp_wait_for_poke1_state', {'', 'violation_state','miss_state','badboy_state'}, 1, x,y, 'labelfraction' , 0.65,...
    'TooltipString', sprintf(badpokeout('wait for poke 1'))); next_row(y);
pokesound{1} = 'poke 1'; pokesound{2} = 'sound following poke 1';
NumeditParam(obj, 'poke1snd_delay_max', 5.000000e-01, x,y, 'labelfraction' , 0.65, 'TooltipString', sprintf(['?!?' maxdelaybetween(pokesound)])); next_row(y);
NumeditParam(obj, 'poke1snd_delay_min', 0, x,y, 'labelfraction' , 0.65, 'TooltipString', sprintf(['?!?' mindelaybetween(pokesound)])); next_row(y)
NumeditParam(obj, 'poke1poke2gap_max', 1, x,y, 'labelfraction' , 0.65); next_row(y);
NumeditParam(obj, 'poke1poke2gap_min', 1.000000e-01, x,y, 'labelfraction' , 0.65); next_row(y);
MenuParam(obj, 'bp_p1p2gap_state', {'', 'violation_state','miss_state','badboy_state'}, 1, x,y, 'labelfraction' , 0.65,...
        'TooltipString',sprintf([contoutputbp 'gap between poke 1 and wait for poke 2.' states_explanation]));

next_column(x); y=boty+10;
%next_row(y);

NumeditParam(obj, 'poke2TO_max', 5, x,y, 'labelfraction' , 0.65); next_row(y); 
NumeditParam(obj, 'poke2TO_min', 1, x,y, 'labelfraction' , 0.65,...
    'TooltipString',sprintf([contmintimeto 'wait for poke 2 state (' timecomp 'poke 2).'])); next_row(y); 
MenuParam(obj, 'poke2TO_state', {'', 'violation_state','miss_state','badboy_state','poke2sound'}, 1, x, y, 'labelfraction' , 0.45,...
    'TooltipString',sprintf([contoutputto 'poke 2 state (' failcomp 'poke 2).'...
    '\n A Violation ends the trial with a NaN in the hit history, and a Miss ends the trial with a 0 in the hit history.'....
    '\nBlank means no effect, and Badboy plays a punishment sound, but allows the trial to continue with Temperror effects.'])); next_row(y); 
NumeditParam(obj, 'poke2led_prob', '0 1 0', x,y, 'labelfraction' , 0.45,...
    'TooltipString',sprintf(['\nThe probability of a each light being lit during the wait for poke 2 state,'...
                             '\n whichever led is lit will be the location of a correct poke 2. ']));
set_callback(poke2led_prob, {mfilename,'normProb', 'poke2led_prob'}); next_row(y);
ToggleParam(obj, 'show_poke2leds', 1, x,y,'OnString','Poke2 LEDs ON','OffString','Poke2 LEDs OFF', ...
    'TooltipString',sprintf(['?!?' goodled('2')])); next_row(y);
ToggleParam(obj, 'pk2_stop_cntxt_snd', 0, x,y,'OnString','Cntxt Snd Stops at pk2','OffString','Cntxt Snd Keeps playing'); next_row(y);
MenuParam(obj, 'bp_wait_for_poke2_state', {'', 'violation_state','miss_state','badboy_state'}, 1, x,y, 'labelfraction' , 0.65); next_row(y);
NumeditParam(obj, 'poke2snd_delay_max', 5.000000e-01, x,y, 'labelfraction' , 0.65);next_row(y);
NumeditParam(obj, 'poke2snd_delay_min', 0, x,y, 'labelfraction' , 0.65); next_row(y);
MenuParam(obj, 'poke2led_rule', {'None','Correct Only','Wrong Only', 'ProAnti'},1, x,y, 'labelfraction' , 0.65); next_row(y);
NumeditParam(obj, 'poke2ledTime', 0.0001, x,y,'labelfraction' , 0.65); next_row(y);
NumeditParam(obj, 'poke2poke3gap_max', 1, x,y, 'labelfraction' , 0.65); next_row(y); 
NumeditParam(obj, 'poke2poke3gap_min', 1.000000e-01, x,y, 'labelfraction' , 0.65); next_row(y);
MenuParam(obj, 'bp_p2p3gap_state', {'', 'violation_state','miss_state','badboy_state'}, 1, x,y, 'labelfraction' , 0.65,...
    'TooltipString',sprintf(['\nControls the output state of "bad pokes" during the gap between poke 2 and wait for poke 3.'...
    '\n A Violation ends the trial with a NaN in the hit history, and a Miss ends the trial with a 0 in the hit history.'....
    '\nBlank means no effect, and Badboy plays a punishment sound, but allows the trial to continue. '])); next_row(y, 2);

NumeditParam(obj, 'poke3TO_max', 5, x,y, 'labelfraction' , 0.65); next_row(y); 
NumeditParam(obj, 'poke3TO_min', 1, x,y, 'labelfraction' , 0.65); next_row(y);
MenuParam(obj, 'poke3TO_state', {'', 'violation_state','miss_state','badboy_state','hit_state','lights_state'}, 1, x, y, 'labelfraction' , 0.45); next_row(y);
MenuParam(obj, 'poke3led_rule', {'All','Sides','Correct Only','None','Wrong Only','ProAnti'},1, x,y, 'labelfraction' , 0.65); next_row(y);

set_callback({poke1TO_state,poke2TO_state,poke3TO_state}, {mfilename, 'toggleTO'});
callback(poke1TO_state);

%[x,y]=SoundInterface(obj,'add','poke3Sound',x,y);

MenuParam(obj, 'wrong_response_state', {'', 'violation_state','miss_state','badboy_state','hit_state'}, 1, x, y, 'labelfraction' , 0.45);
next_row(y);
ToggleParam(obj, 'AL_badboy', 0, x, y, 'position', [x y 25 20], 'OnString', 'AL', 'OffString', 'AL', ...
  'TooltipString', sprintf(['if wrs_override is ON, then ' ...
  '\nthis button ON --> Anti Left trials are badboy wrong_response_state trials,' ...
  '\nthis button OFF --> Anti Left trials are miss wrong_response_state trials.']));
ToggleParam(obj, 'AR_badboy', 0, x, y, 'position', [x+26 y 25 20], 'OnString', 'AR', 'OffString', 'AR', ...
  'TooltipString', sprintf(['if wrs_override is ON, then ' ...
  '\nthis button ON --> Anti Right trials are badboy wrong_response_state trials,' ...
  '\nthis button OFF --> Anti Right trials are miss wrong_response_state trials.']));
ToggleParam(obj, 'PL_badboy', 0, x, y, 'position', [x+51 y 25 20], 'OnString', 'PL', 'OffString', 'PL', ...
  'TooltipString', sprintf(['if wrs_override is ON, then ' ...
  '\nthis button ON --> Pro Left trials are badboy wrong_response_state trials,' ...
  '\nthis button OFF --> Pro Left trials are miss wrong_response_state trials.']));
ToggleParam(obj, 'PR_badboy', 0, x, y, 'position', [x+76 y 25 20], 'OnString', 'PR', 'OffString', 'PR', ...
  'TooltipString', sprintf(['if wrs_override is ON, then ' ...
  '\nthis button ON --> Pro Right trials are badboy wrong_response_state trials,' ...
  '\nthis button OFF --> Pro Right trials are miss wrong_response_state trials.']));
ToggleParam(obj, 'wrs_override', 0, x, y, 'position', [x+102 y 98 20], ...
  'OnString', 'wrs_override ON', 'OffString', 'wrs_override OFF', ...
  'TooltipString', sprintf(['\nif ON (black bg), then wrong_response_state menu is' ...
  '\nignored and choice of wrong_response_state=miss_state or badboy_state is made on a' ...
  '\ntrial type by trial type basis, using the buttons to the left.'...
  '\n   If OFF (brown bg), buttons to left are disabled and wrong_response_state menu' ...
  '\nis enabled as normal.']));
disable(AL_badboy);  
disable(AR_badboy);  
disable(PL_badboy);  
disable(PR_badboy);  
set_callback(wrs_override, {mfilename, 'wrs_override'});
next_row(y);

NumeditParam(obj, 'delay2reward_max', 1, x,y, 'labelfraction' , 0.65);
next_row(y);

NumeditParam(obj, 'delay2reward_min', 2.000000e-01, x,y, 'labelfraction' , 0.65);
next_row(y);

ToggleParam(obj, 'KeepSoundOn', 0, x, y, 'OnString', 'KeepSoundOn is ON', ...
  'OffString', 'KeepSoundOn is OFF', 'TooltipString', ...
  sprintf(['\nIf on (black bg), poke 2 sound stays on after hit trials, for ' ...
  '\npoke2sound_t_after_wtr seconds after water delivery. If off (brown bg), ' ...
  '\nsound turns off as soon as a response is made'])); next_row(y);
set_callback(KeepSoundOn, {mfilename, 'KeepSoundOn'});
NumeditParam(obj, 'poke2sound_t_after_wtr', 2, x, y, 'TooltipString', ...
  sprintf(['\nIf "Keep Sound On" button is on, this param says for how many secs after ' ...
  '\ndelivering water in a hit trial the poke2sound should remain on'])); next_row(y);
disable(poke2sound_t_after_wtr);
SubheaderParam(obj, 'subhead11' , 'poke2sound timing', x,y); next_row(y);




next_column(x); y=boty;

NumeditParam(obj, 'locsnd_anti_hz', -1, x,y, 'labelfraction' , 0.65, ...
	'TooltipString', sprintf(['\nIf this is -1 then this has no effect.'...
  '\nIf this is set to anything other than -1 then this will overwrite'...
  '\nthe value of LeftSoundFreq1 and RightSoundFreq1 on pro trials']));
next_row(y);
NumeditParam(obj, 'locsnd_pro_hz', -1, x,y, 'labelfraction' , 0.65 ,...
  'TooltipString', sprintf(['\nIf this is -1 then this has no effect.'...
  '\nIf this is set to anything other than -1 then this will overwrite'...
  '\nthe value of LeftSoundFreq1 and RightSoundFreq1 on pro trials']));
next_row(y);
SubheaderParam(obj, 'subhead41' , 'Dillaway Style', x,y);
next_row(y);
NumeditParam(obj, 'cntx_loc_overlap', -1, x,y, 'labelfraction' , 0.65 ,...
  'TooltipString', sprintf(['\nIf this is -1 then this has no effect.'...
  '\nOtherwise this will determine how long after the onset of the location sound'...
  '\nthe context sound is turned off']));
next_row(y);
SubheaderParam(obj, 'subhead42' , 'Backing off Context Snd', x,y);
next_row(y, 1.5);

[x,y]=PunishInterface(obj,'add', 'PApunish', x,y);
MenuParam(obj,'bp_ITI_state',{'', 'badboy_state'},1,x,y,'labelfraction' , 0.65);
next_row(y);
ToggleParam(obj, 'hit_iti_or_wd', 1, x, y, 'OnString', 'hit_iti', 'OffString', 'Warn/Danger', ...
   'TooltipString', sprintf(['\nIf on "hit_iti", regular hit_iti sound and duration.\n' ...
   'If on Warn/Danger, Warning/Danger panel above is used and there is no hit_iti'])); next_row(y);
set_callback(hit_iti_or_wd, {mfilename, 'hit_iti_or_wd'});
[x, y] = WarnDangerInterface(obj, 'add', 'wd', x, y); 
[x, y] = PunishInterface(obj, 'add', 'iti_punishment', x, y);
next_row(y);

MenuParam(obj,'after_reward',{'hit_iti', 'soft_drink_time'},1,x,y,'labelfraction' , 0.65); next_row(y);
[x, y] = SoftPokeStayInterface(obj, 'add', 'soft_drink_time_aftertemperror', x, y);
SoftPokeStayInterface(obj, 'set', 'soft_drink_time_aftertemperror', 'Duration', 20, 'Grace', 2.401);
[x, y] = SoftPokeStayInterface(obj, 'add', 'soft_drink_time', x, y);
SoftPokeStayInterface(obj, 'set', 'soft_drink_time', 'Duration', 20, 'Grace', 2.5);
% NumeditParam(obj, 'drink_grace',     1, x,y, 'labelfraction' , 0.65);
% next_row(y);
% NumeditParam(obj, 'soft_drink_time', 1.4, x,y, 'labelfraction' , 0.65); next_row(y);
ToggleParam(obj, 'reward_type', 0, x,y, 'OnString', 'Brain Stim', 'OffString', 'Water'); next_row(y);
ToggleParam(obj, 'FlashCorrectResp', 0, x,y, 'OnString', 'Flash Correct LED', 'OffString', 'Do NOT flash correct LED'); next_row(y);
NumeditParam(obj, 'reward_prob', 1, x,y, 'labelfraction' , 0.65); next_row(y);
EditParam(obj, 'scale_reward', 1, x, y, 'labelfraction' , 0.65);
set_tooltipstring(scale_reward, sprintf(['\nMultiplies time water valves are open. ' ...
  '\nIf this is set to 1, rewards are given as normal. '])); next_row(y);
EditParam(obj, 'scale_temperror_rew', 1, x, y, 'labelfraction', 0.65, ...
  'TooltipString', sprintf(['\nMultiplies length of time water valve is open ONLY after ' ...
  '\na temperror is committed. "Temperror" means wrong_response_state is set to badboy_state. ' ...
  '\nSet this variable to less than one if you want to extrapunish temperrors'])); next_row(y);
SubheaderParam(obj, 'subhead10' , 'Reward scaling', x,y); next_row(y, 1.5); 

next_column(x); y=boty; 
[x,y]=DistribInterface(obj, 'add', 'hitITIdurUI',x,y);
[x,y]=DistribInterface(obj, 'add', 'violationITIdurUI',x,y);
[x,y]=DistribInterface(obj, 'add', 'missITIdurUI',x,y); %#ok<NASGU>

feval(mfilename, obj, 'hit_iti_or_wd');

SettingsSection(obj, 'window_toggle');

        SoloFunctionAddAllVars('StateMatrixSection', 'ro_args');
        SoloFunctionAddAllVars('PerformanceSection', 'ro_args');

        % Ugh -- should never have allowed creation of
        % SoloFunctionAddAllVars.m to begin with.
		% What is this code?  Is there a conflict with variable names in
		% SessionModel? -jce 080126
        SoloFunctionRemoveVar(posterior);
        SoloFunctionRemoveVar(hitfrac);
        SoloFunctionAddVars(mfilename, 'rw_args', {'posterior' 'hitfrac'});
        SoloFunctionAddVars('PerformanceSection', 'rw_args', {'posterior' 'hitfrac'});
        SoloFunctionAddVars('SessionModel', 'rw_args', 'posterior', 'target_name', get_fullname(posterior));
        SoloFunctionAddVars('SessionModel', 'rw_args', 'hitfrac',   'target_name', get_fullname(hitfrac));
        
        % Stretch position of figure to fit all the vars.
        % TODO

        x = oldx; y = oldy; figure(fig);
return;


        
%% KeepSoundOn
  case 'KeepSoundOn'
    if KeepSoundOn==1,
      enable(poke2sound_t_after_wtr);
    else
      disable(poke2sound_t_after_wtr);
    end;

    
%% hit_iti_or_wd
  case 'hit_iti_or_wd',
    if hit_iti_or_wd==1, 
      WarnDangerInterface(obj, 'disable', 'wd');
      PunishInterface(    obj, 'disable', 'iti_punishment');
    else
      WarnDangerInterface(obj, 'enable', 'wd');
      PunishInterface(    obj, 'enable', 'iti_punishment');
    end;
    
    
%% check_wrs_override

  case 'check_wrs_override',
    if wrs_override == 1,
      pro  = PerformanceSection(ProAnti2, 'get', 'pro_trial');
      side = PerformanceSection(ProAnti2, 'get', 'goodPoke3');
      
      wrsbb = value(wrong_response_state); %#ok<NODEF>

      if     pro==-1 && side == -1,
        if AL_badboy==1, wrsbb = 1; else wrsbb = 0; end;
      elseif pro==-1 && side ==  1,
        if AR_badboy==1, wrsbb = 1; else wrsbb = 0; end;
      elseif pro==1  && side == -1,
        if PL_badboy==1, wrsbb = 1; else wrsbb = 0; end;
      elseif pro==1  && side ==  1,
        if PR_badboy==1, wrsbb = 1; else wrsbb = 0; end;
      end;
      
      if     isequal(wrsbb, 1), wrong_response_state.value = 'badboy_state';
      elseif isequal(wrsbb, 0), wrong_response_state.value = 'miss_state';
      end;
      
    end;
    
%% wrs_override
  case 'wrs_override', 
    if wrs_override == 1,
      enable(AL_badboy);
      enable(AR_badboy);
      enable(PL_badboy);
      enable(PR_badboy);
      disable(wrong_response_state); %#ok<NODEF>
    else
      disable(AL_badboy);
      disable(AR_badboy);
      disable(PL_badboy);
      disable(PR_badboy);
      enable(wrong_response_state); %#ok<NODEF>
    end;
      
      
%% fullprior
  case 'fullprior'
    p = value(fullprior);  %#ok<NODEF>
    if length(p)~=4 || any(p<0) || sum(p)<=0  ||  ~(p(1)+p(3)>0  &&  p(2)+p(4)>0), 
      fullprior.value = value(old_fprior); %#ok<NODEF>
    end;
    fullprior.value  = fullprior/sum(value(fullprior));
    old_fprior.value = value(fullprior);
      
    

%% prior_override
  case 'prior_override'
    if prior_override==1
      disable(pro_prob); 
      disable(poke3resp_dist);
      enable(fullprior); %#ok<NODEF>
      enable(posterior);
      enable(hitfrac);
      
    elseif prior_override==0;
      enable(pro_prob); 
      enable(poke3resp_dist);
      disable(fullprior); %#ok<NODEF>
      disable(posterior);
      disable(hitfrac);
    end;

%% numpokes
    case 'numPokes',
	
        if value(nPokes)<=2
            h=get_sphandle('owner',class(obj),'name','poke1');
            for xi=1:numel(h)
                disable(h{xi});
            end
            h=get_sphandle('owner',class(obj),'name','poke2');
            for xi=1:numel(h)
                enable(h{xi});
            end
        end
        
        if value(nPokes)==1
            h=get_sphandle('owner',class(obj),'name','poke2');
            for xi=1:numel(h)
                disable(h{xi});
            end
        end
        
        
        if value(nPokes)==3
            h=get_sphandle('owner',class(obj),'name','poke');
            for xi=1:numel(h)
                enable(h{xi});
            end
        end


%% trial_toggle
    case 'trial_toggle'
        
        if value(trial_type)==1   %reaction time
            disable(poke2poke3gap_max);
            disable(poke2poke3gap_min);
            disable(bp_p2p3gap_state);
        else
            enable(poke2poke3gap_max);
            enable(poke2poke3gap_min);
            enable(bp_p2p3gap_state);
        end

%% normProb    
    case 'normProb',
      try
          
		tr=eval(x);  
        tr=value(tr);
		
		% In 'next_trial' it only considers left/right pokes.  so let's
		% force the poke3resp_dist to be honest.  otherwise you end up with
		% a bias. :(
		
		if strcmp(x,'poke3resp_dist')
			tr(2)=0;
		end
		
        if tr==0
            eval([ x '.value=0;']);
		else
			eval([ x '.value=tr/sum(tr);']);
        end
        % normalize the probalities.
      catch
          warning('Bad inputs to normProb in SettingsSection') %#ok<WNTAG>
      end
      
%% toggleTO
    case 'toggleTO',
        
        for xi=1:3
            pstr=['poke' num2str(xi) 'TO'];
            
            if isempty(value(eval([pstr '_state']))) || xi<(4-value(nPokes))
                disable(eval([pstr '_min']));
                disable(eval([pstr '_max']));
            else
                enable(eval([pstr '_min']));
                enable(eval([pstr '_max']));
            end
        end
        
%% window_toggle
    
    case 'window_toggle',
        if value(settings_btn) == 1,  %#ok<NODEF>
            set(value(myfig), 'Visible', 'on');
            feval(mfilename,obj,'snd_window_toggle');    
        else
            set(value(myfig), 'Visible', 'off');
            set(value(soundsfig), 'Visible', 'off');
            
        end;
        
%% snd_window_toggle
    
    case 'snd_window_toggle',
        if value(sounds_btn) == 1, set(value(soundsfig), 'Visible', 'on'); %#ok<NODEF>
        else                         set(value(soundsfig), 'Visible', 'off');
        end;
%% hide_window
    case 'hide_window'       
        settings_btn.value_callback = 0;
        set(value(soundsfig), 'Visible','Off');       
%% hide_snd_window
    case 'hide_snd_window'       
        sounds_btn.value_callback = 0;
%% close
    case 'close'         
        try
        delete(value(myfig));
        delete(value(soundsfig));
        catch
        end
%% reinit
    case 'reinit',
        currfig = double(gcf);

        % Get the original GUI position and figure:
        x = my_gui_info(1); y = my_gui_info(2); origfig = my_gui_info(3);
        myfignum = myfig(1);

        % Delete all SoloParamHandles who belong to this object and whose
        % fullname starts with the name of this mfile:
        delete_sphandle('owner', ['^@' class(obj) '$'], ...
            'fullname', ['^' mfilename]);
        delete(myfignum);

        % Reinitialise at the original GUI position and figure:
        figure(origfig);
        [x, y] = feval(mfilename, obj, 'init', x, y);

        % Restore the current figure:
        figure(currfig);
%% reward_type        
    case {'reward_type'}
        
    % check state of toggle button
    
    % if water
    [LeftWValveTime RightWValveTime] = WaterValvesSection(obj, 'get_water_times');  

    if lower(goodPoke3(1))=='r'
        reward_time.value=RightWValveTime;
        reward_port.value=right1water;
    else
        reward_time.value=LeftWValveTime;
        reward_port.value=left1water;
    end
    % elsebrain
    
    
end;
end

%% Functions
% 
%     function [output] = lengof(input)
%         output = ['/n Length of ' input];
%     end
% 
%     function [output] = lengofstate(input)
%         output = ['/n Length of ' input ' state.'];
%     end
% 
%     function [output] = maxlengofstate
%         output = ['Maximum length of ' input ' state.'];
%     end

    function [output] = maxdelaybetween(input)
        output = ['Maximum delay between ' input{1} 'and' input{2}];
    end

    function [output] = mindelaybetween(input)
        output = ['Minimum delay between ' input{1} 'and' input{2}];
    end

%     function [output] = maxgapbetween(input)
%         output = ['Maximum gap between ' input{1} 'and' input{2}];
%     end
% 
%     function [output] = mingapbetween(input)
%         output = ['Minimum gap between ' input{1} 'and' input{2}];
%     end


    function [output] = badpokeout(input)
        output = ['\nControls the output state of "bad pokes" during the ' input ' state.' ...
                  '\n A Violation ends the trial with a NaN in the hit history, and a Miss ends the trial with a 0 in the hit history.'...
                  '\nBlank means no effect, and Badboy plays a punishment sound, but allows the trial to continue. '];
    end

    function [output] = timeout(input)
        output = ['Controls the output of a timeout of the ' input 'state.' ...
                  '\n A Violation ends the trial with a NaN in the hit history, and a Miss ends the trial with a 0 in the hit history.'...
                  '\nBlank means no effect, and Badboy plays a punishment sound, but allows the trial to continue. '];
    end
    
    function [output] = goodled(input)
        output = ['The good led for poke' input];
    end
%     function [output] = badboy_miss(input)
%         output = [];
%     end







