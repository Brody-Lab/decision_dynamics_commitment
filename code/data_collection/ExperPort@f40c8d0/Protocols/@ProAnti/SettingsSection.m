
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
        fig = gcf;
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y fig]);
        
        % need code here to make sure it is the only one

        ToggleParam(obj, 'settings_btn', 0, x, y, ...
            'OnString', 'Settings Panel Showing', ...
            'OffString', 'Settings Panel Hidden', ...
            'TooltipString', ['Show/Hide window that controls ' ...
            'the settings for the protocol'], ...
            'OnFontWeight', 'bold', 'OffFontWeight', 'normal');
            
            set_callback(settings_btn, {mfilename, 'window_toggle'});
    
    next_row(y);

        oldx = x; oldy = y;
       

        SoloParamHandle(obj, 'myfig', 'saveable', 0, 'value', ...
            figure('position', [689   716   616   440], ...
            'MenuBar', 'none',  ...
            'NumberTitle', 'off', ...
            'Name','ProAnti Settings', ...
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
            
            set_callback(sounds_btn, {mfilename, 'snd_window_toggle'});
            
            SoloParamHandle(obj, 'soundsfig', 'saveable', 0, 'value', ...
            figure('position', [ 53   717   818   433], ...
            'MenuBar', 'none', 'Name', 'ProAnti Sounds', ...
            'NumberTitle', 'off', ...
            'CloseRequestFcn', [mfilename ...
            '(' class(obj) ', ''hide_snd_window'');']));
            
            x=5;y=5; boty=5;
            
            [x,y]=SoundInterface(obj,'add','StartTrialSound',x,y, 'TooltipString',...
               [ '\nThis sound will play at the start of a trial to tell the rat the trial will begin.\n' ...
               'After delay2start the led for poke1 will appear']);

            [x,y]=SoundInterface(obj,'add','ProSound',x,y);
            [x,y]=SoundInterface(obj,'add','AntiSound',x,y);
            next_column(x); y=boty;
            [x,y]=SoundInterface(obj,'add','RightSound',x,y);
            [x,y]=SoundInterface(obj,'add','CenterSound',x,y);
            [x,y]=SoundInterface(obj,'add','LeftSound',x,y);
            next_column(x); y=boty;
            [x,y]=SoundInterface(obj,'add','HitSound',x,y);
            [x,y]=SoundInterface(obj,'add','MissSound',x,y);
            [x,y]=SoundInterface(obj,'add','ViolationSound',x,y);
			next_column(x); y=boty;
			[x,y]=SoundInterface(obj,'add','BadBoySound',x,y);
			[x,y]=SoundInterface(obj,'add','ITISound',x,y);
            
   figure(value(myfig));     
   
   % For debugging purpose
    
        
%% Make SoloUIParams


        % ---- Now to initialising the new window
  x=5;y=5;boty=5;
  
next_row(y);

MenuParam(obj, 'nPokes', {'1' '2' '3'}, 3, x, y, 'labelfraction' , 0.65);
set_callback(nPokes,{mfilename,'numPokes'});
next_row(y);

NumeditParam(obj, 'pro_prob', .5, x, y, 'labelfraction' , 0.65);
set_callback(nPokes,{mfilename,'numPokes'});
next_row(y);

ToggleParam(obj, 'trial_type', 0, x,y, 'OnString', 'Reaction Time','OffString','Memory',...
    'TooltipString',sprintf(['\nIf this is set to reaction time, the poke2sound stops as soon as he leaves the poke']));
set_callback(trial_type, {mfilename,'trial_toggle'});
next_row(y);

NumeditParam(obj, 'poke3resp_dist', '.5 0 .5', x,y, 'labelfraction' , 0.4);
set_tooltipstring(poke3resp_dist,sprintf(['\nIf this has 1 element, it is the left probaility.\n'...
	'Two elements has the same functionality as one element'...
	'Three elements imply [left center right] probability']));
set_callback(poke3resp_dist, {mfilename,'normProb', 'poke3resp_dist'});
next_row(y);

MenuParam(obj, 'repeat_on_error', {'Always','Never','Violation Only','Miss Only'} ,3, x,y);
SoloFunctionAddVars(repeat_on_error, 'ro_args',{'ProAnti'});
next_row(y);

MenuParam(obj, 'MaxSame', {'Inf','1','2','3','4','5','6','8','10','15','20'},1, x,y);
next_row(y);

SubheaderParam(obj, 'subhead1' , 'Essential Task Parameters',x,y);
next_row(y);
  

NumeditParam(obj, 'delay2startTO', .001, x,y, 'labelfraction' , 0.65);
next_row(y);


MenuParam(obj, 'bp_del2start_state', {'', 'violation_state','miss_state','badboy_state'}, 1, x,y, 'labelfraction' , 0.65);
next_row(y);


NumeditParam(obj, 'poke1TO_max', 5, x,y, 'labelfraction' , 0.65);
next_row(y);

NumeditParam(obj, 'poke1TO_min', 1, x,y, 'labelfraction' , 0.65);
next_row(y);

MenuParam(obj, 'poke1TO_state', {'', 'violation_state','miss_state','badboy_state','poke1sound'}, 1, x, y, 'labelfraction' , 0.45);
next_row(y);

NumeditParam(obj, 'poke1led_prob', '0 1 0', x,y, 'labelfraction' , 0.45);
set_callback(poke1led_prob, {mfilename,'normProb', 'poke1led_prob'});
next_row(y);

ToggleParam(obj, 'show_poke1leds', 1, x,y,'OnString','Poke1 LEDs ON','OffString','Poke1 LEDs OFF');
next_row(y);

MenuParam(obj, 'bp_wait_for_poke1_state', {'', 'violation_state','miss_state','badboy_state'}, 1, x,y, 'labelfraction' , 0.65);
next_row(y);

NumeditParam(obj, 'poke1snd_delay_max', 5.000000e-01, x,y, 'labelfraction' , 0.65);
next_row(y);

NumeditParam(obj, 'poke1snd_delay_min', 0, x,y, 'labelfraction' , 0.65);
next_row(y)

NumeditParam(obj, 'poke1poke2gap_max', 1, x,y, 'labelfraction' , 0.65);
next_row(y);

NumeditParam(obj, 'poke1poke2gap_min', 1.000000e-01, x,y, 'labelfraction' , 0.65);
next_row(y);

MenuParam(obj, 'bp_p1p2gap_state', {'', 'violation_state','miss_state','badboy_state'}, 1, x,y, 'labelfraction' , 0.65);
next_column(x); y=boty;
%next_row(y);

NumeditParam(obj, 'poke2TO_max', 5, x,y, 'labelfraction' , 0.65);
next_row(y);

NumeditParam(obj, 'poke2TO_min', 1, x,y, 'labelfraction' , 0.65);
next_row(y);

MenuParam(obj, 'poke2TO_state', {'', 'violation_state','miss_state','badboy_state','poke2sound'}, 1, x, y, 'labelfraction' , 0.45);
next_row(y);

NumeditParam(obj, 'poke2led_prob', '0 1 0', x,y, 'labelfraction' , 0.45);
set_callback(poke2led_prob, {mfilename,'normProb', 'poke2led_prob'});
next_row(y);

ToggleParam(obj, 'show_poke2leds', 1, x,y,'OnString','Poke2 LEDs ON','OffString','Poke2 LEDs OFF');
next_row(y);


MenuParam(obj, 'bp_wait_for_poke2_state', {'', 'violation_state','miss_state','badboy_state'}, 1, x,y, 'labelfraction' , 0.65);
next_row(y);

NumeditParam(obj, 'poke2snd_delay_max', 5.000000e-01, x,y, 'labelfraction' , 0.65);
next_row(y);

NumeditParam(obj, 'poke2snd_delay_min', 0, x,y, 'labelfraction' , 0.65);
next_row(y);

NumeditParam(obj, 'poke2poke3gap_max', 1, x,y, 'labelfraction' , 0.65);
next_row(y);

NumeditParam(obj, 'poke2poke3gap_min', 1.000000e-01, x,y, 'labelfraction' , 0.65);
next_row(y);


MenuParam(obj, 'bp_p2p3gap_state', {'', 'violation_state','miss_state','badboy_state'}, 1, x,y, 'labelfraction' , 0.65);
next_row(y);

NumeditParam(obj, 'poke3TO_max', 5, x,y, 'labelfraction' , 0.65);
next_row(y);

NumeditParam(obj, 'poke3TO_min', 1, x,y, 'labelfraction' , 0.65);
next_row(y);

MenuParam(obj, 'poke3TO_state', {'', 'violation_state','miss_state','badboy_state','hit_state','lights_state'}, 1, x, y, 'labelfraction' , 0.45);
next_row(y);

MenuParam(obj, 'poke3led_rule', {'All','Sides','Correct Only','None','Wrong Only'},1, x,y, 'labelfraction' , 0.65);
next_row(y);


set_callback({poke1TO_state,poke2TO_state,poke3TO_state}, {mfilename, 'toggleTO'});
callback(poke1TO_state);

%[x,y]=SoundInterface(obj,'add','poke3Sound',x,y);

MenuParam(obj, 'wrong_response_state', {'', 'violation_state','miss_state','badboy_state'}, 1, x, y, 'labelfraction' , 0.45);
next_row(y);

NumeditParam(obj, 'delay2reward_max', 1, x,y, 'labelfraction' , 0.65);
next_row(y);

NumeditParam(obj, 'delay2reward_min', 2.000000e-01, x,y, 'labelfraction' , 0.65);
next_row(y);


NumeditParam(obj, 'reward_prob', 1, x,y, 'labelfraction' , 0.65);
next_row(y);
ToggleParam(obj, 'FlashCorrectResp', 0, x,y, 'OnString', 'Flash Correct LED', 'OffString', 'Do NOT flash correct LED');



next_column(x); y=boty;

NumeditParam(obj, 'hitITIdur_max', 2, x,y, 'labelfraction' , 0.65);
next_row(y);

NumeditParam(obj, 'hitITIdur_min', 1, x,y, 'labelfraction' , 0.65);
next_row(y);

NumeditParam(obj, 'drink_grace', 1, x,y, 'labelfraction' , 0.65);
next_row(y);


ToggleParam(obj, 'punish_delay2start', 0, x,y, 'OnString', 'Do punish_delay2start', 'OffString', 'Do NOT punish_delay2start');
next_row(y);

ToggleParam(obj, 'reward_type', 0, x,y, 'OnString', 'Brain Stim', 'OffString', 'Water');
next_row(y);


% EditParam(obj, 'scale_reward', 1, x, y, 'labelfraction' , 0.45);
% set_tooltipstring(scale_reward,['If this is set to 1, rewards are given as normal. '])
% next_row(y);



NumeditParam(obj, 'violationITIdur_max', 1, x,y, 'labelfraction' , 0.65);
next_row(y);

NumeditParam(obj, 'violationITIdur_min', 1, x,y, 'labelfraction' , 0.65);
next_row(y);


NumeditParam(obj, 'missITIdur_max', 2, x,y, 'labelfraction' , 0.65);
next_row(y);

NumeditParam(obj, 'missITIdur_min', 1, x,y, 'labelfraction' , 0.65);
next_row(y);

MenuParam(obj,'bp_ITI_state',{'', 'badboy_state'},1,x,y,'labelfraction' , 0.65);
next_row(y);

MenuParam(obj,'after_reward',{'hit_iti', 'soft_drink_time'},1,x,y,'labelfraction' , 0.65);

SettingsSection(obj, 'window_toggle');




        SoloFunctionAddAllVars('StateMatrixSection', 'ro_args');
        SoloFunctionAddAllVars('PerformanceSection', 'ro_args');
        
        
        % Stretch position of figure to fit all the vars.
        % TODO

        x = oldx; y = oldy; figure(fig);
        return;

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
        if tr==0
        eval([ x '.value=0;']);
		else
			eval([ x '.value=tr/sum(tr);']);
		end
        % normalize the probalities.
      catch
          warning('Bad inputs to normProb in SettingsSection')
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
        if value(settings_btn) == 1, 
            set(value(myfig), 'Visible', 'on');
            feval(mfilename,obj,'snd_window_toggle');    
        else
            set(value(myfig), 'Visible', 'off');
            set(value(soundsfig), 'Visible', 'off');
            
        end;
        
%% snd_window_toggle
    
    case 'snd_window_toggle',
        if value(sounds_btn) == 1, set(value(soundsfig), 'Visible', 'on');
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
        currfig = gcf;

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



