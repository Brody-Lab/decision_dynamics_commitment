% @SameDifferent/StimulusSection.m
% Bing, June 2008

% [x, y] = YOUR_SECTION_NAME(obj, action, varargin)
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


function [x, y] = StimulusSection(obj, action, varargin)

GetSoloFunctionArgs;

switch action
	%% init
	case 'init',
		x = varargin{1};
		y = varargin{2};
		
		% Save the figure and the position in the figure where we are going
		% to start adding GUI elements:
		SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);
		
		% hacky soloparamhandles for implementing blocks
		SoloParamHandle(obj, 'counter', 'value', 0);
		SoloParamHandle(obj, 'n_block', 'value', 0);
		
		%       MenuParam(obj, 'StimSchedule', {'Timed', 'During Cpoke Only'}, ...
		%           1, x, y, ...
		%           'labelfraction', 0.4, ...
		%           'TooltipString', sprintf(['Determines when the stimulus is on, whether by timing (there are two sorts, From Stim Start or From Answer Poke' ...
		%                                     '\n or during center pokes only (but not when the rat pulls out of the cpoke)']));
		%       next_row(y);
		
		ToggleParam(obj, 'cpoke_schedule', 1, x, y, ...
			'OnString', 'determined cpokes', ...
			'OffString', 'free graze for sounds', ...
			'TooltipString', sprintf(['\n If ''determined cpokes'', then the rat''s cpoke behavior' ...
			'\n is controled by the count_cpokes toggle button, either counting' ...
			'\n cpokes or timing cpokes.' ...
			'\n If ''free graze for sounds'', then the rat can graze for sound at will.' ...
			'\n Sounds (if on) will play for as long as he holds his nose' ...
			'\n in the center.  He may center poke for sound as many times as he wants' ...
			'\n or poke L or R as an answer poke.']));
		next_row(y);
		set_callback(cpoke_schedule, {mfilename, 'cpoke_schedule'});
		
		% number of center pokes
		ToggleParam(obj, 'count_cpokes', 1, x, y, ...
			'OnString',  'count cpokes', ...
			'OffString', 'one cpoke w/ legal breaks', ...
			'TooltipString', sprintf(['\nIf ''count cpokes'', then the rat must make n_center_pokes' ...
			'\nor keep nose in for a cumulative nose_in_center sec before side poke is allowed. ' ...
			'\nIf ''one cpoke with breaks'', the rat must make one center poke then keep his nose' ...
			'\nin for nose_in_center sec, making only nose-outs that are shorter than legal_cbreak;' ...
			'\nfailure to keep his nose in for this duration results in a violation.']));
		next_row(y);
		set_callback(count_cpokes, {mfilename, 'count_cpokes'});
		
		
		MenuParam(obj, 'n_center_pokes', {'0', '1', '2', '3', '4', '5'}, 1, x, y, ...
			'labelfraction', 0.4, ...
			'TooltipString', 'Number of center pokes before side choice is allowed');
		next_row(y);
		
		NumeditParam(obj, 'nose_in_center', 0.5, x, y, 'position', [x y 100 20], ...
			'labelfraction', 0.4, ...
			'label', 'NIC',...
			'TooltipString', 'Duration (in sec) nose must be kept in center poke before side choice is allowed');
		
		ToggleParam(obj,'use_randvar_for_nic',0 , x, y, 'position', [x+101 y 100 20], ...
			'OnString', 'using DistribNIC', 'OffString', 'nose_in_center', ...
			'TooltipString', sprintf(['\nIf this is on (Black) then nose_in_center is updated with the value, ' ...
			'\nof the DistribNIC on each trial']));
		
		next_row(y);
		set_callback(n_center_pokes, {mfilename, 'n_center_pokes'});
		
		NumeditParam(obj, 'legal_cbreak', 0.001, x, y, ...
			'labelfraction', 0.4444, ...
			'TooltipString', sprintf(['\nGoing out of the center poke and poking back in' ...
			'\nwithin this many seconds means the nose-out is ignored, it is treated' ...
			'\nas if the rat had kept his nose in the center continuously']));
		next_row(y);
		
		ToggleParam(obj, 'nic_end_sound', 0, x, y, 'position', [x y 100 20], ...
			'OnString', 'end sound ON', 'OffString', 'end sound OFF', ...
			'TooltipString', sprintf(['\nsound that is triggered at start of center_2_side_gap, ' ...
			'\nto help the rat realize nose_in_center is over']));
		ToggleParam(obj, 'nic_end_sound_show', 0, x, y, 'position', [x+101 y 100 20], ...
			'OnString', 'end sound showing', 'OffString', 'end sound hidden', ...
			'TooltipString', sprintf(['\nshow or hide the interface for the nic_end_sound']));
		set_callback(nic_end_sound_show, {mfilename 'nic_end_sound_show'}); %#ok<NODEF>
		next_row(y);
		
		% Put up the little figure for the nic_end_sound, set up the SoundUI,
		% then close the figure:
		currfig = double(gcf); cfpos = get(currfig, 'Position');
		SoloParamHandle(obj, 'nic_end_sound_fig', 'value', ...
			figure('Position', [cfpos(1)+487 cfpos(2)+289 218 170], 'Name', 'nic_end_sound', ...
			'CloseRequestFcn', [mfilename '(' class(obj) ', ''nic_end_sound_hide'')'], 'MenuBar', 'none'), ...
			'saveable', 0);
		myx = 10; myy = 10;
		SoundInterface(obj, 'add', 'nic_end_sound', myx, myy);
		SoundInterface(obj, 'set', 'nic_end_sound', 'Style', 'Tone', 'Vol', 0.004, ...
			'Freq1', 6000, 'Dur1', 0.05, 'Loop', 0, 'Bal', 0);
		nic_end_sound_show.value = 0;
		set(value(nic_end_sound_fig), 'Visible', 'off');
		
		
		figure(currfig);
		% NIC_sound - plays during fixation period.
		ToggleParam(obj, 'nic_sound', 0, x, y, 'position', [x y 100 20], ...
			'OnString', 'NIC sound ON', 'OffString', 'NIC sound OFF', ...
			'TooltipString', sprintf(['\nsound that is triggered at start of cpoke1, ' ...
			'\nto help the rat realize nose_in_center is over']));
		ToggleParam(obj, 'nic_sound_show', 0, x, y, 'position', [x+101 y 100 20], ...
			'OnString', 'NIC sound showing', 'OffString', 'NIC sound hidden', ...
			'TooltipString', sprintf(['\nshow or hide the interface for the nic_sound']));
		set_callback(nic_sound_show, {mfilename 'nic_sound_show'}); %#ok<NODEF>
		next_row(y);
		
		% Put up the little figure for the nic_sound, set up the SoundUI,
		% then close the figure:
		currfig = double(gcf); cfpos = get(currfig, 'Position');
		SoloParamHandle(obj, 'nic_sound_fig', 'value', ...
			figure('Position', [cfpos(1)+487 cfpos(2)+289 218 170], 'Name', 'nic_sound', ...
			'CloseRequestFcn', [mfilename '(' class(obj) ', ''nic_sound_hide'')'], 'MenuBar', 'none'), ...
			'saveable', 0);
		myx = 10; myy = 10;
		SoundInterface(obj, 'add', 'nic_sound', myx, myy);
		SoundInterface(obj, 'set', 'nic_sound', 'Style', 'Tone', 'Vol', 0.001, ...
			'Freq1', 8000, 'Dur1', 2, 'Loop', 1, 'Bal', 0);
		nic_sound_show.value = 0;
		set(value(nic_sound_fig), 'Visible', 'off');
		
		figure(currfig);
		ToggleParam(obj, 'temp_pun_on_violation', 0, x, y, ...
			'OffString', 'end trial on violation', ...
			'OnString', 'temp pun on violation', ...
			'TooltipString', sprintf(['\nIf ''end trial on violation'', then a cbreak longer' ...
			'\nthan the legal cbreak results in the violation state and the trial ending; the' ...
			'\nnext trial is a repeat of the violation trial. ' ...
			'\n   But if ''temp pun on violation'', then the TempPun sound is played, we stay' ...
			'\nin the same trial, go to the temp_violation state and then go back to ' ...
			'\nwait_for_cpoke1. The length of the temp_violation state is the same as the TempPun sound.']));
		next_row(y);
		
		
		MenuParam(obj, 'center_light', {'on during cpokes', 'off at first cpoke'}, 1, ...
			x, y, 'labelfraction', 0.4, ...
			'TooltipString', 'When the center light is kept on');
		next_row(y);
        
        ToggleParam(obj,'side_lights_show',0,x,y,'OnString','Side LEDs Panel Showing','OffString','Side LEDs Panel Hidden','TooltipString','Hide and show the side lights panel');
        set_callback(side_lights_show, {mfilename 'side_lights_show'}); %#ok<NODEF>

        next_row(y)
        
        
        currfig = double(gcf); cfpos = get(currfig, 'Position');
		SoloParamHandle(obj, 'side_lights_fig', 'value', ...
			figure('Position', [cfpos(1)+487 cfpos(2)+289 250 270], 'Name', 'side_lights', ...
			'CloseRequestFcn', [mfilename '(' class(obj) ', ''side_lights_hide'')'], 'MenuBar', 'none'), ...
			'saveable', 0);
		myx = 10; myy = 10;
		sld=DistribInterface(obj, 'add', 'side_lights_dur', myx, myy,'TooltipString','If the flash_side_lights toggle is set to "flash", then this is the duration that they flash for');        
        next_row(myy,6);
	    ToggleParam(obj,'flash_side_lights',0,myx,myy,'OnString','Side LEDs Flashed','OffString','Side LEDs stay on','TooltipString','When on the side lights briefly flash, when off they stay on until the side poke');
        next_row(myy)
        MenuParam(obj, 'side_lights', {'correct side only', 'both sides on', 'both sides off', ...
         'anticorrect side only', 'on during cpokes'}, 1, myx, myy, ...
			'labelfraction', 0.4, ...
			'TooltipString', 'Which side lights are turned on');
		set_callback(side_lights, {mfilename, 'side_lights'});
		set_callback_on_load(side_lights, 1);
		next_row(myy);
        NumeditParam(obj,'LEDMaskDur', 0 ,myx , myy, ...
        'TooltipString', sprintf('\nDuration to flash side lights after initial flash'));
        next_row(myy);
        NumeditParam(obj,'LEDMaskDelay', 0.01 ,myx , myy, ...
        'TooltipString', sprintf('\nDuration to delay flash side lights after initial flash'));
        next_row(myy);
        
		NumeditParam(obj, 'LEDRewardTime', 0, myx, myy, ...
			'TooltipString', sprintf(['\nIf side lights are on, length of time (secs) to keep them' ...
			'\non during the reward state']));
        
        set(value(side_lights_fig), 'Visible', 'off');
		
		figure(currfig);
        
		
		next_row(y);
		NumeditParam(obj, 'C2SGap_2', 0, x, y, 'position', [x+100 y 100 20], ...
			'labelfraction', 0.7, ...
			'TooltipString', 'An additional center-to-side gap that follows C2SGap where there is no punishment for poking anywhere');
		NumeditParam(obj, 'C2SGap', 1, x, y, 'position', [x y 100 20], ...
			'labelfraction', 0.5, ...
			'TooltipString', 'Time (sec) between last center poke and when a side poke is accepted');
		next_row(y);
		
		
		NumeditParam(obj, 'fixed_stim_dur', 1, x, y, ...
			'TooltipString', 'Stimulus duration, regardless of cycle boundaries');
		next_row(y);
		NumeditParam(obj, 'n_stimulus_cycles', 1, x, y, ...
			'TooltipString', 'Number of cycles the stimulus is repeated after triggered by the first center poke');
		next_row(y);
		NumeditParam(obj, 'from_answer_poke', 8, x, y, ...
			'TooltipString', 'Duration (sec) of stimulus play after side poke answer is made');
		next_row(y);
		% the functionality of this ToggleParam has been replaced by
		% stim_timing; it still exists here for the sake of backwards
		% compatibility but will not be visible from the protocol GUI
		ToggleParam(obj, 'StimTimeStart', 0, x, y, ...
			'OffString', 'From Stim Start', ...
			'OnString',  'From Answer Poke', ...
			'TooltipString', 'From Stim Start means stimulus is timed by n_stimulus_cycles; From Answer Poke means it is timed by from_answer_poke');
		make_invisible(StimTimeStart);
		set_callback_on_load(StimTimeStart, 1);
		MenuParam(obj, 'stim_timing', {'From Answer Poke', 'From Stim Start', 'Fixed T After Start', 'During Cpoke Only'}, 2, x, y, ...
			'labelfraction', 0.3, ...
			'TooltipString', sprintf(['\n Controls the timing of when the stimulus is on' ...
			'\n If From Answer Poke, stim is timed from_answer_poke' ...
			'\n If From Stim Start, stim is timed by n_stimulus_cycles' ...
			'\n If Fixed T After Stim Start, stim is stopped after a fixed time (MUST be less than 10*(cycle duration)' ...
			'\n If During Cpoke Only, stim is only ON in one of the cpoke states']));
		set_callback(StimTimeStart, {mfilename, 'StimTimeStart'});
		set_callback(stim_timing,   {mfilename, 'stim_timing'});
		set_callback_on_load(stim_timing, 1);
		next_row(y);
		NumeditParam(obj, 'stim_start_delay', 0, x, y, ...
			'position', [x y 150 20], ...
			'labelfraction', 0.6, ...
			'TooltipString', 'the delay (in sec) between cpoke1 and when the stimulus starts playing');
		next_row(y);
		
		ToggleParam(obj, 'SoundSource', 0, x, y, 'position', [x y 150 20], ...
			'OnString', 'Use Poisson Bups', ...
			'OffString', 'Use Sound Table', ...
			'TooltipString', 'Determines which sounds are used');
		ToggleParam(obj, 'SoundsOn', 1, x, y, 'position', [x+150 y 50 20], ...
			'OnString', 'On', ...
			'OffString', 'Off', ...
			'TooltipString', 'Turns stimulus sounds on/off');
		set_callback(SoundsOn, {mfilename, 'SoundsOn'});
		next_row(y);
		
		[x, y] = PBupsSection(obj, 'init', x, y);
		
		SoloParamHandle(obj, 'tablename', 'value', 'T1');
		[x, y] = SoundTableSection(obj, 'init', value(tablename), x, y);
		
		next_column(x);
		y=5;
		[x, y] = DistribInterface(obj, 'add', 'NIC', x, y, 'Style', ...
			'gaussian', 'Mu', 1.15, 'Sd', 0.1, 'Min', 0.9, 'Max', 1.3);
		
		SoloFunctionAddVars('StateMatrixSection', 'ro_args', ...
			{'SoundsOn'; 'tablename'; 'SoundSource'; ...
			'count_cpokes'; 'legal_cbreak'; 'nic_end_sound' ; 'nic_sound'; ...
			'nose_in_center'; 'n_center_pokes'; ...
			'temp_pun_on_violation'; ...
			'C2SGap'; 'C2SGap_2'; 'LEDRewardTime' ; ...
			'side_lights'; 'center_light'; 'flash_side_lights';...
            'LEDMaskDelay';'LEDMaskDur';...
			'n_stimulus_cycles'; 'fixed_stim_dur' ; 'from_answer_poke';...
			'stim_timing'; 'stim_start_delay'; ...
			'cpoke_schedule'; ...
			});
		
		SoloFunctionAddVars('SidesSection', 'ro_args', ...
			{'tablename'; 'SoundsOn'; 'SoundSource'});
		
		SoloFunctionAddVars('CpokeEODSection', 'ro_args', {'count_cpokes'}, 'rw_args', {'legal_cbreak'});
		
		feval(mfilename, obj, 'stim_timing');
		feval(mfilename, obj, 'count_cpokes');
		feval(mfilename, obj, 'side_lights');
		
		
		%% next_trial
	case 'next_trial',
		a = SoundTableSection(obj, 'next_trial', value(tablename), ...
			varargin{1}, varargin{2}, varargin{3});
		% the 3 varargins should be hit_history, previous_sides, and
		% previous_sounds
		
		if a == 0, % if for some reason SoundTableSection cannot pick sounds, try normalizing.
			
			SoundTableSection(obj,'normalize',value(tablename));
			a = SoundTableSection(obj, 'next_trial', value(tablename), ...
				varargin{1}, varargin{2}, varargin{3});
			if a ==0  % if you still can't get a sound then turn them off.
				SoundsOn.value = 0;
				
			end
			return;
		end;
		
		%% push_history
	case 'push_history'
		if SoundSource == 1,
			PBupsSection(obj, 'push_history');
		else
			SoundTableSection(obj,'push_history',value(tablename));
		end
		
		%% get_next_trial_sound
	case 'get_next_trial_sound',
		if SoundsOn == 1,
			x = SoundTableSection(obj, 'get_next_trial_sound', value(tablename));
		else
			x = 0;
		end;
		
		
		%% cpoke_schedule
	case 'cpoke_schedule',
		if cpoke_schedule == 1, % determined cpokes
			enable(count_cpokes);
			enable(n_center_pokes);
			enable(nose_in_center);
			enable(legal_cbreak);
			enable(temp_pun_on_violation);
			enable(C2SGap_2);
			enable(C2SGap);
			enable(fixed_stim_dur);
			enable(n_stimulus_cycles);
			enable(from_answer_poke);
			enable(stim_timing);
			enable(nic_end_sound);
			enable(nic_end_sound_show);
			feval(mfilename, obj, 'count_cpokes');
			feval(mfilename, obj, 'n_center_pokes');
			feval(mfilename, obj, 'stim_timing');
			
		else                    % free graze for sound cpokes
			disable(count_cpokes);
			disable(n_center_pokes);
			disable(nose_in_center);
			disable(legal_cbreak);
			disable(temp_pun_on_violation);
			disable(C2SGap_2);
			disable(C2SGap);
			disable(fixed_stim_dur);
			disable(n_stimulus_cycles);
			disable(from_answer_poke);
			disable(stim_timing);
			disable(nic_end_sound);
			nic_end_sound_show.value = 0;
			set(value(nic_end_sound_fig), 'Visible', 'off');
			disable(nic_end_sound_show);
			
		end;
		
		%% n_stimulus_cycles
	case 'n_stimulus_cycles',
		if n_stimulus_cycles < 1, n_stimulus_cycles.value = 1; end;
		if n_stimulus_cycles > 10, n_stimulus_cycles.value = 10; end;
		
		%% count_cpokes
	case 'count_cpokes'
		if count_cpokes == 1,
			enable(n_center_pokes);
			disable(legal_cbreak);
			disable(temp_pun_on_violation);
		else
			n_center_pokes.value = 1;
			disable(n_center_pokes);
			enable(legal_cbreak);
			enable(temp_pun_on_violation);
		end
		
		feval(mfilename, obj, 'n_center_pokes');
		
		%% n_center_pokes
	case 'n_center_pokes'
		if n_center_pokes == 0,
			disable(C2SGap);
			disable(C2SGap_2);
			disable(center_light);
		else
			enable(C2SGap);
			enable(C2SGap_2);
			enable(center_light);
		end;
		%% compute_NIC
	case 'compute_NIC'
		% check the value of the toggle
		
		if use_randvar_for_nic==1
			nose_in_center.value=DistribInterface(obj,'get_new_sample','NIC');
		end
		%% side_lights
	case 'side_lights'
		if strcmp(side_lights, 'both sides off'),
			disable(LEDRewardTime);
		else
			enable(LEDRewardTime);
		end;
		
		
		
		%% StimTimeStart
		% the functionality of this ToggleParam has been replaced by stim_timing,
		% but this case is here for the sake of backwards compatibility
	case 'StimTimeStart'
		if strcmp(stim_timing, 'Fixed T After Start') || strcmp(stim_timing, 'During Cpoke Only'),
			% The new functionality is being used -- ignore old info
		else % use old info
			if StimTimeStart == 0,
				stim_timing.value = 2;
			else
				stim_timing.value = 1;
			end;
		end;
		
		%% stim_timing
	case 'stim_timing'
		switch value(stim_timing), %#ok<NODEF>
			case 'From Answer Poke',
				enable(from_answer_poke);
				disable(n_stimulus_cycles); %#ok<NODEF>
				disable(fixed_stim_dur);
			case 'From Stim Start',
				disable(from_answer_poke);
				enable(n_stimulus_cycles); %#ok<NODEF>
				disable(fixed_stim_dur);
			case 'Fixed T After Start',
				disable(from_answer_poke);
				disable(n_stimulus_cycles); %#ok<NODEF>
				enable(fixed_stim_dur);
			case 'During Cpoke Only',
				disable(from_answer_poke);
				disable(n_stimulus_cycles); %#ok<NODEF>
				disable(fixed_stim_dur);
		end;
		
		
		%% nic_end_sound_hide
	case 'nic_end_sound_hide'
		nic_end_sound_show.value = 0;
		set(value(nic_end_sound_fig), 'Visible', 'off');
		
		
		%% nic_end_sound_show
	case 'nic_end_sound_show'
		if nic_end_sound_show==1, %#ok<NODEF>
			set(value(nic_end_sound_fig), 'Visible', 'on');
		else
			set(value(nic_end_sound_fig), 'Visible', 'off');
		end;
		
		%% nic_sound_hide
	case 'nic_sound_hide'
		nic_sound_show.value = 0;
		set(value(nic_sound_fig), 'Visible', 'off');
		
		
		%% nic_sound_show
	case 'nic_sound_show'
		if nic_sound_show==1, %#ok<NODEF>
			set(value(nic_sound_fig), 'Visible', 'on');
		else
			set(value(nic_sound_fig), 'Visible', 'off');
		end;
		
		%% side_lights_hide
	case 'side_lights_hide'
		side_lights_show.value = 0;
		set(value(side_lights_fig), 'Visible', 'off');
		
		
		%% side_lights_show
	case 'side_lights_show'
		if side_lights_show==1, %#ok<NODEF>
			set(value(side_lights_fig), 'Visible', 'on');
		else
			set(value(side_lights_fig), 'Visible', 'off');
		end;
			
		
		%% SoundsOn
	case 'SoundsOn',
		if SoundsOn == 1,
			enable(stim_start_delay);
		else
			disable(stim_start_delay);
		end;
		%% get_send_summary_info
	case 'get_send_summary_info',
		upto=varargin{1};
		s_l=get_history(side_lights);
		s_lights=zeros(size(s_l));
		for cx=1:numel(s_l)
			if s_l{cx}(1)=='c'
				s_lights(cx)=1;
			elseif s_l{cx}(1)=='a'
				s_lights(cx)=-1;
			end
		end
		fsd=get_history(fixed_stim_dur);
		ssd=get_history(stim_start_delay);
        nic=get_history(nose_in_center);
		x.fsd=cell2mat(fsd(1:upto));
        x.nic=cell2mat(nic(1:upto));
		x.ssd=cell2mat(ssd(1:upto));
		x.side_lights=s_lights(1:upto);
        
		
		
		%% close
	case 'close',
		SoundTableSection(obj, 'close', value(tablename));
		PBupsSection(obj, 'close');
		% Delete all SoloParamHandles who belong to this object and whose
		% fullname starts with the name of this mfile:
		delete_sphandle('owner', ['^@' class(obj) '$'], ...
			'fullname', ['^' mfilename]);
		
		delete(value(nic_end_sound_fig));
		delete(value(nic_sound_fig));
		delete(value(side_lights_fig));
        
		
		%% end_session
	case 'end_session',
		
		
		%% reinit
	case 'reinit',
		currfig = double(gcf);
		
		% Get the original GUI position and figure:
		x = my_gui_info(1); y = my_gui_info(2); f = my_gui_info(3);
		
		feval(mfilename, obj, 'close');
		
		% Reinitialise at the original GUI position and figure:
		figure(f);
		[x, y] = feval(mfilename, obj, 'init', x, y);
		
		% Restore the current figure:
		figure(currfig);
end;
