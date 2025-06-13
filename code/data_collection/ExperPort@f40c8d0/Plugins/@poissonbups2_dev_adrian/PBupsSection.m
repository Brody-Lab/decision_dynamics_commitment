% [x, y] = PBupsSection(obj, action, tname, varargin)
%
% This plugin makes a window that manages the making of Poisson bups, which
% are bups that occur as independent Poisson processes on the left and
% right.
%
% Note: PBupsSection not only controls the generation of the poisson clicks
% trains but it also controls the laser stimulation, and thus incorporates
% all the functionality of StimulatorSection which is therefore not used in the PBups
% protocol.
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%
%   'init'     Initializes the plugin. Sets up internal variables
%               and the GUI window.
%
% BWB, Dec. 2008
% significant overhaul, February 2009
% BWB, added functionality to trigger stimulator (laser) line, May 2012
% AGB, slight changes to access new functionality of make_pbup (min_ISI parameter), Nov. 2017
% Thomas Luo (TZL), Analog output for laser modulation, Oct, 2018
% TZL, Dec 2018
%       - Testing Section: Delivering a continuous sound at an amplitude
%       equal to the peak pressure of a click.
%       - Capability to manually correct for asmmetry in sound pressure
%       level between the left and right speaker
%       - Stimulus Properties Section: Option to manually specificy the
%       tones make up a click, option to specify sound pressure level if
%       headphones were used in a rig

function [x, y] = PBupsSection(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action
    
%% init    
  case 'init'
    if length(varargin) < 2
      error('Need at least two arguments, x and y position, to initialize %s', mfilename);
    end
    x = varargin{1}; y = varargin{2};

    SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);
    
    
    SoloParamHandle(obj, 'is_frozen', 'value', 0);   
    SoloParamHandle(obj, 'ThisSeed', 'value', 0);   
    SoloParamHandle(obj, 'Bups', 'value', {});
    
    ToggleParam(obj, 'pbup_show', 0, x, y, ...
       'OnString', 'PBup window Showing', ...
       'OffString', 'PBup window Hidden', ...
       'TooltipString', 'Show/Hide PBup window'); next_row(y);
    set_callback(pbup_show, {mfilename, 'show_hide';});  %#ok<NODEF>
    
    screen_size = get(0, 'ScreenSize'); fig = double(gcf);
    SoloParamHandle(obj, 'pbup_fig', ...
        'value', double(figure('Position', [200 50 600 900], ...
        'closerequestfcn', [mfilename '(' class(obj) ', ''hide''' ');'], 'MenuBar', 'none', ...
        'NumberTitle', 'off', 'Name', 'PBups')), 'saveable', 0);
    origfig_xy = [x y]; 
    
    x = 10; y = 10;
	% TESTING SECTION
    ToggleParam(obj, 'test_right_speaker', 0, x, y, 'position', [x+200 y 200 20], ...
		'OffString', 'Right speaker off', ...
		'OnString',  'Right speaker on', ...
		'TooltipString', 'Plays a continuous sound from the right speaker');
    ToggleParam(obj, 'test_left_speaker', 0, x, y, 'position', [x y 200 20], ...
		'OffString', 'Left speaker off', ...
		'OnString',  'Left speaker on', ...
		'TooltipString', 'Plays a continuous sound from the left speaker');
    set_callback(test_left_speaker, {mfilename, 'test_left_speaker'});
    set_callback(test_right_speaker, {mfilename, 'test_right_speaker'});
    next_row(y);
    NumeditParam(obj, 'test_gamma', 2, x, y, 'position', [x y 100 20], ...
        'labelfraction', 0.7, ...
        'TooltipString', 'Pushing the Play button will play a sample sound of this gamma');
	set_callback(test_gamma, {mfilename, 'test_gamma'});
	set_callback_on_load(test_gamma, 1);
	DispParam(obj, 'test_lrate', 0, x, y, 'position', [x+100 y 100 20], ...
		'labelfraction', 0.7, ...
		'TooltipString', 'left rate of test_gamma');
	DispParam(obj, 'test_rrate', 0, x, y, 'position', [x+200 y 100 20], ...
		'labelfraction', 0.7, ...
		'TooltipString', 'right rate of test_gamma');
	NumeditParam(obj, 'sduration', 1, x, y, 'position', [x+300 y 100 20], ...
		'labelfraction', 0.7, ...
		'TooltipString', 'duration of test sound');
    PushbuttonParam(obj, 'test_play', x, y, 'position', [x+400 y 80 20], ...
        'label', 'test Play');
    PushbuttonParam(obj, 'test_stop', x, y, 'position', [x+480 y 80 20], ...
        'label', 'test Stop');
    set_callback(test_play, {mfilename, 'test_play'});
    set_callback(test_stop, {mfilename, 'test_stop'});
	next_row(y);
    SubheaderParam(obj, 'title1', 'Testing Section', x, y);
    next_row(y, 1.3);
	
	% ANTIBIAS SECTION
	LogsliderParam(obj, 'HitFracTau', 30, 10, 400, x, y, 'position', [x y 160 20], ...
		'label', 'hits frac tau', ...
		'TooltipString', 'Number of trials back over which to compute fraction correct (display only)');
	set_callback(HitFracTau, {mfilename, 'update_hitfrac'});
	DispParam(obj, 'RtHitFrac', 0, x, y, 'position', [x y+20 160 20]);
	DispParam(obj, 'LtHitFrac', 0, x, y, 'position', [x y+40 160 20]);
	DispParam(obj, 'HitFrac',   0, x, y, 'position', [x y+60 160 20]);
	offset = 180;
	LogsliderParam(obj, 'BiasTau', 30, 10, 400, x, y, 'position', [x+offset y 400 20], ...
		'label', 'antibias tau', ...
		'TooltipString', 'Number of trials back over which to compute the antibias function');
	DispParam(obj, 'RtHits', 0, x, y, 'position', [x+offset y+20 200 20], ...
		'labelfraction', 0.3);
	DispParam(obj, 'RtPostProb', 0, x, y, 'position', [x+200+offset y+20 200 20], ...
		'labelfraction', 0.3);
	DispParam(obj, 'LtHits', 0, x, y, 'position', [x+offset y+40 200 20], ...
		'labelfraction', 0.3);
	DispParam(obj, 'LtPostProb', 0, x, y, 'position', [x+200+offset y+40 200 20], ...
		'labelfraction', 0.3);
	NumeditParam(obj, 'Beta', 0, x, y, 'position', [x+offset y+60 200 20], ...
		'TooltipString', 'Antibias weight.  0 means past performance has no effect on next trial.  This affects left and right trials independently.');
	set_callback({BiasTau; Beta}, {mfilename, 'update_biashitfrac'});
	SoloParamHandle(obj, 'LocalPrevSides',  'value', []);
	SoloParamHandle(obj, 'LocalPrevSounds', 'value', []);
	next_row(y, 4);
	SubheaderParam(obj, 'title2', 'Antibias Section', x, y);
	next_row(y, 1.3);
    
    % STIMULATOR SECTION
    NumeditParam(obj, 'ao_off_ramp_dur_s', 0, x, y, 'position', [x+250 y 250 20], ...
        'labelfraction', 0.4, ...
        'TooltipString', 'Offset ramp duration in second. Ramp occurs during STIM_DUR and has a waveform according to AO_IS_SINE_NOT_SQUARE');
    NumeditParam(obj, 'ao_on_ramp_dur_s', 0, x, y, 'position', [x y 250 20], ...
        'labelfraction', 0.4, ...
        'TooltipString', 'Onset ramp duration in second. Ramp occurs during STIM_DUR and has a waveform according to AO_IS_SINE_NOT_SQUARE');
    next_row(y);
    NumeditParam(obj, 'ao_max_V', 5, x, y, 'position', [x+250 y 250 20], ...
        'labelfraction', 0.4, ...
        'TooltipString', 'Maximum voltage of the analog output. This assumes that the range of voltage output of the NIDAQ card in your RTlinux machine is [-10, 10] V.');
    NumeditParam(obj, 'ao_min_V', 0, x, y, 'position', [x y 250 20], ...
        'labelfraction', 0.4, ...
        'TooltipString', 'Minimum voltage of the analog output. This assumes that the range of voltage output of the NIDAQ card in your RTlinux machine is [-10, 10] V.');
    next_row(y);    
    ToggleParam(obj, 'ao_is_sine_not_square', 0, x, y, 'position', [x+100 y 75 20], ...
		'OffString', 'Square', ...
		'OnString',  'Sine', ...
		'TooltipString', 'Sine or square wave?');
    ToggleParam(obj, 'stim_is_analog_not_digital', 0, x, y, 'position', [x y 100 20], ...
		'OffString', 'Digital output', ...
		'OnString',  'Analog output', ...
		'TooltipString', 'Is laser stimulation controlled through digital or analog output?');
    next_row(y);
	NumeditParam(obj, 'stim_trigger_state', 1, x, y, 'position', [x y 150 20], ...
        'labelfraction', 0.7, ...
        'TooltipString', 'the state on which the stim will be triggered, as listed in states_list');
    valid_states = {'1: cpoke1', '2: wait_for_spoke','3: iti'};
    MenuParam(obj, 'states_list', valid_states, 1, x, y,'position', [x+150 y 150 20], ...
        'labelfraction', 0.7, ...
        'TooltipString', 'The list of possible states on which a scheduled wave carrying the stimulation');
    next_row(y);
    NumeditParam(obj, 'stim_pre_jitter', 0, x, y, 'position', [x y 150 20], ...
        'labelfraction', 0.7, ...
        'TooltipString', 'Allowable jitter (in sec) of the timing of the preamble before stimulator is turned on. The laser will come on randomly within this duration before or after stim_pre, with a uniform distribution.');
    NumeditParam(obj, 'stim_dur', 2, x, y, 'position', [x+150 y 150 20], ...
        'labelfraction', 0.7, ...
        'TooltipString', 'Duration (in sec) the stimulator remains on');
    next_row(y);
    
    NumeditParam(obj, 'stim_pre', 0, x, y, 'position', [x y 150 20], ...
        'labelfraction', 0.7, ...
        'TooltipString', 'Duration (in sec) of preamble before stimulator is turned on, relative to start of trigger state.');
    NumeditParam(obj, 'stim_freq', 0, x, y, 'position', [x+150 y 150 20], ...
        'labelfraction', 0.7, ...
        'TooltipString', 'Frequency (in Hz) of pulses, use 0 for a single continuous pulse');
    ToggleParam(obj, 'require_cerebro', 0, x, y, 'position', [x+300 y 200 20], ...
		'OffString', 'Cerebro NOT required for stim', ...
		'OnString',  'Cerebro required for stim', ...
		'TooltipString', 'Require a working connection to a Cerebro base station to stimulate?');
    next_row(y);
    NumeditParam(obj, 'stim_pulse', 0, x, y, 'position', [x y 150 20], ...
        'labelfraction', 0.7, ...
        'TooltipString', 'Duration (in milliseconds) for each stim pulse, use 0 for a single continuous pulse');    
    NumeditParam(obj, 'stimulator_frac', 0, x, y, 'position', [x+150 y 150 20], ...
        'labelfraction', 0.7, ...
        'TooltipString', 'fraction of trials stimulated; note that if only probe trials are stimulated, then this means the fraction of probe trials, not total trials');
    NumeditParam(obj, 'stim_power', 0, x, y, 'position', [x+300 y 150 20], ...
        'labelfraction', 0.7, ...
        'TooltipString', 'cerebro power (if not connected to a cerebro base station, this parameter is meaningless)');   
 set_callback({stim_trigger_state; stim_pre; stim_dur; stim_pre_jitter; stimulator_frac; stim_freq; stim_pulse; stim_power;...
                  ao_min_V; ao_max_V; ao_on_ramp_dur_s; ao_off_ramp_dur_s}, {mfilename, 'update_stim'});
   
     set_callback({stim_is_analog_not_digital, ao_is_sine_not_square}, {mfilename, 'update_laser_analog_output'});
    
    next_row(y);
    DispParam(obj, 'ThisStim', 0, x, y, 'position', [x y 150 20], ...
        'labelfraction', 0.7, ...
        'TooltipString', 'the stimulator class this trial');
    ToggleParam(obj, 'stimulator_style', 0, x, y, 'position', [x+150 y 250 20], ...
		'OffString', 'Stimulate on all trial types', ...
		'OnString',  'Stimulate on probe trials only', ...
		'TooltipString', 'specifies the types of trials the stimulator may be used');
    ToggleParam(obj, 'allow_consecutive_stimulation', 0, x, y, 'position', [x+400 y 150 20], ...
		'OffString', 'No consecutive stim', ...
		'OnString',  'Allow consecutive stim', ...
		'TooltipString', 'Can laser stimulation occur on consecutive trials?');
    next_row(y);
	SubheaderParam(obj, 'title5', 'Stimulator Section', x, y);
    next_row(y, 1.3);
        
    % MASK SECTION
    NumeditParam(obj, 'mask_trigger_state', 1, x, y, 'position', [x y 250 20], ...
        'labelfraction', 0.4, ...
        'TooltipString', 'the state on which the mask will be triggered, as listed in states_list');
    valid_states = {'1: cpoke1', '2: wait_for_spoke','3: iti'};
    MenuParam(obj, 'mask_states_list', valid_states, 1, x, y,'position', [x+250 y 250 20], ...
        'labelfraction', 0.3, ...
        'TooltipString', 'The list of possible states on which a scheduled wave carrying the mask');
    next_row(y);
    NumeditParam(obj, 'mask_pre', 0, x, y, 'position', [x y 250 20], ...
        'labelfraction', 0.4, ...
        'TooltipString', 'Duration (in sec) of preamble before mask is turned on, relative to start of nose-in-center');
    NumeditParam(obj, 'mask_dur', 2, x, y, 'position', [x+250 y 250 20], ...
        'labelfraction', 0.4, ...
        'TooltipString', 'Duration (in sec) the mask remains on');
    next_row(y);
    NumeditParam(obj, 'mask_channel', 1, x, y, 'position', [x y 250 20], ...
        'labelfraction', 0.4, ...
        'TooltipString', 'the mask channel used for each mask class; at this point, should be all ones');
    NumeditParam(obj, 'mask_frac', 0, x, y, 'position', [x+250 y 250 20], ...
        'labelfraction', 0.4, ...
        'TooltipString', 'fraction of trials masked; note that if only probe trials are masked, then this means the fraction of probe trials, not total trials');
    set_callback({mask_trigger_state; mask_pre; mask_dur; mask_channel; mask_frac}, {mfilename, 'update_mask'});
    next_row(y);
    DispParam(obj, 'ThisMask', 0, x, y, 'position', [x y 150 20], ...
        'labelfraction', 0.7, ...
        'TooltipString', 'the mask class this trial');
    ToggleParam(obj, 'mask_style', 0, x, y, 'position', [x+150 y 250 20], ...
		'OffString', 'Mask on all trial types', ...
		'OnString',  'Mask on probe trials only', ...
		'TooltipString', 'specifies the types of trials the mask may be used');
    ToggleParam(obj, 'lock_mask2stim', 0, x, y, 'position', [x+400 y 150 20], ...
		'OffString', 'Mask unlocked from Stim', ...
		'OnString',  'Mask LOCKED to Stim', ...
		'TooltipString', 'locking mask to stim ensures mask is simultaneous to stim on stim trials');
    next_row(y);
	SubheaderParam(obj, 'title5', 'Mask Section', x, y);
    next_row(y, 1.3);
    
	% SAMPLE DURATION SECTION
	NumeditParam(obj, 'DurationBeta', 0, x, y, 'position', [x y 200 20], ...
		'TooltipString', 'Duration-based L/R antibias weight');
	LogsliderParam(obj, 'DurationTau', 100, 50, 400, x, y, 'position', [x+offset y 250 20], ...
		'label', 'duration antibias tau');
	next_row(y);
	DispParam(obj, 'DurationBias', 1, x, y, 'position', [x y 420 20], ...
		'label', 'bias per duration', ...
		'labelfraction', 0.3, ...
		'TooltipString', sprintf(['as a function of sample durations (T), the left/right bias.' ...
		                          '\nin other words, this is the ratio lt_hitfrac/rt_hitfrac ' ...
								  '\nconditioned on each of the 10 possible T"s. ']));
    next_row(y);
	NumeditParam(obj, 'T_probe', x, y, 0.5, 'position', [x y 150 20], ...
		'TooltipString', 'in addition to the T''s specified by T_min and T_max, T can be this value with probability p_probe');
	NumeditParam(obj, 'p_probe', x, y, 0, 'position', [x+150 y 150 20], ...
		'TooltipString', 'probability T will be T_probe');
    ToggleParam(obj,  'insert_gap',0,x,y,  'position', [x+300 y 120 20],...
        'OffString', 'No Gap', ...
		'OnString',  'Insert Gap', ...
		'TooltipString', 'determines if a gap of defined duration will be inserted into the center of the click train');
    NumeditParam(obj, 'T_gap', 0, x, y, 'position', [x+420 y 150 20], ...
		'TooltipString', 'duration of gap in center of click train');
    
	next_row(y);
	DispParam(obj, 'T', 0.5, x, y, 'position', [x y 100 20], ...
		'labelfraction', 0.3, ...
		'TooltipString', sprintf(['sample duration, is T_probe with probability p_probe, otherwise drawn between T_min and T_max uniformly'...
                           '\n Note that T controls the maximum sound duration in the RT version of the task!']));
	NumeditParam(obj, 'T_min', 0.2, x, y, 'position', [x+100 y 100 20], ...
		'TooltipString', 'the minimum sample duration');
	NumeditParam(obj, 'T_max', 0.2, x, y, 'position', [x+200 y 100 20], ...
		'TooltipString', 'the maximum sample duration');
	PushbuttonParam(obj, 'T_resample', x, y, 'position', [x+300 y 100 20], ...
		'label', 'Resample', ...
		'TooltipString', 'resample T, the sample duration');
	set_callback({T_min; T_max; T_resample; T_probe; p_probe}, {mfilename, 'T_resample'}); %#ok<NODEF>
	next_row(y);

	SubheaderParam(obj, 'title3', 'Sample Duration Section', x, y);
	next_row(y, 1.3);
	
    % *************************
	% ** Passive stimulation **
    % *************************
    NumeditParam(obj, 'rp_post_s', 0.5, x, y, 'position', [x+225 y 125 20], ...
		'TooltipString', 'Time (s) after the replay of auditory stimuli');
    NumeditParam(obj, 'rp_pre_s', 0.5, x, y, 'position', [x+100 y 125 20], ...
		'TooltipString', 'Time (s) before the replay of auditory stimuli');
    ToggleParam(obj,  'replay_bups',0,x,y,  'position', [x y 100 20],...
        'OffString', 'No replay', ...
		'OnString',  'Replay', ...
		'TooltipString', 'Redeliver the auditory stimulus after the animal has responded');
    next_row(y);
    NumeditParam(obj, 'ps_post_s', 0.5, x, y, 'position', [x+225 y 125 20], ...
		'TooltipString', 'Time (s) after the delivery of task-independent bups');
    NumeditParam(obj, 'ps_pre_s', 0.5, x, y, 'position', [x+100 y 125 20], ...
		'TooltipString', 'Time (s) before the delivery of task-independent bups');
    ToggleParam(obj,  'passive_stim',0,x,y,  'position', [x y 100 20],...
        'OffString', 'No passive hearing', ...
		'OnString',  'Passive hearing', ...
		'TooltipString', 'Deliver task-independent bups to the animal at the end of a trial');
    next_row(y);
    SubheaderParam(obj, 'title_task_irrelevant_sounds', 'Passive Stimulation Section', x, y);
	next_row(y, 1.3);
    set_callback({passive_stim; ps_pre_s; ps_post_s; replay_bups; ...
                  rp_pre_s; rp_post_s}, {mfilename, 'check_passive_stimulation'})
    % *********************************************************************
    
    % STIMULUS PROPERTIES SPECIFICATION
    NumeditParam(obj, 'R_gammas', 2, x, y, 'position', [x+50 y 200 20], ...
        'labelfraction', 0.3, ...
        'TooltipString', 'gammas for sounds whose rates in the right ear are larger; these must all be > 0');
	NumeditParam(obj, 'R_pprobs', 0.5, x, y, 'position', [x+250 y 200 20], ...
		'labelfraction', 0.3, ...
		'TooltipString', 'prior probability for R sounds');
    next_row(y);
    NumeditParam(obj, 'L_gammas', -2, x, y, 'position', [x+50 y 200 20], ...
        'labelfraction', 0.3, ...
        'TooltipString', 'gammas for sounds whose rates in the left ear are larger; these must all be < 0');
	NumeditParam(obj, 'L_pprobs', 0.5, x, y, 'position', [x+250 y 200 20], ...
		'labelfraction', 0.3, ...
		'TooltipString', 'prior probability for R sounds');
	PushbuttonParam(obj, 'normalize_pprobs', x, y, 'position', [x+475 y 100 20], ...
		'label', 'normalize', ...
		'TooltipString', 'Normalize pprobs');
	set_callback(normalize_pprobs, {mfilename, 'normalize_pprobs'});
	next_row(y);
	ToggleParam(obj, 'gamma_style', 0, x, y, 'position', [x y 200 20], ...
		'OffString', 'Specify Gammas by Range', ...
		'OnString',  'Use Gammas Below', ...
		'TooltipString', 'write something here');
	set_callback(gamma_style, {mfilename, 'gamma_style'});
	set_callback_on_load(gamma_style, 1);
	NumeditParam(obj, 'easiest', 2.5, x, y, 'position', [x+200 y 150 20], ...
		'labelfraction', 0.4, ...
		'TooltipString', 'the easiest (endpoints) gamma; this value must be positive');
	NumeditParam(obj, 'hardest', 0.5, x, y, 'position', [x+350 y 150 20], ...
		'labelfraction', 0.4, ...
		'TooltipString', 'the hardest (closest to 0 midpoint) gamma; this value must be positive');
	NumeditParam(obj, 'N', 3, x, y, 'position', [x+500 y 60 20], ...
		'labelfraction', 0.4, ...
		'TooltipString', sprintf(['the number of gamma points between easiest and hardest;' ...
		                          '\nnote that there will actually be 2N trial types (l/r)' ...
								  '\nif N == 1, then the range will consist only of the easiest endpoint gammas']));
    set_callback({R_gammas, L_gammas, easiest, hardest, N}, {mfilename, 'gammas'}); %#ok<NODEF>
    next_row(y,0.2);
    
    next_row(y);
    ToggleParam(obj, 'tone_style', 0, x, y, 'position', [x y 250 20], ...
		'OffString', 'Specify tones by base_freq and ntones', ...
		'OnString',  'Specify tones manually', ...
		'TooltipString', 'S');
    NumeditParam(obj, 'tones', 2000, x, y, 'position', [x+250 y 300 20], ...
        'labelfraction', 0.15, ...
        'TooltipString', 'Tones that make up each click');
    
    next_row(y);
    NumeditParam(obj,'frozen_frac',0.5,x,y,'position',[x y 150 20],...
        'label','frozen fraction','TooltipString','the fraction of trials that use frozen noise');
    NumeditParam(obj,'n_seeds',20,x,y,'position',[x+150 y 200 20],...
        'label','no. frozen seeds','TooltipString','size of the pool of frozen noise seeds to select amongst (a separate pool for each gamma/totalrate combination)');
    NumeditParam(obj, 'headphone_attentuation_dB', [20, 20], x, y, 'position', [x+350 y 250 20], ...
        'label', 'headphone atten. (dB)', ...
        'TooltipString', ['[left,right]. The minimum is limited by the ' ...
                          '"HEADPHONE_MAX_C" in Settings_Custom']);
    set_callback({headphone_attentuation_dB}, {mfilename, 'check_headphones'});
    
    next_row(y);
    NumeditParam(obj, 'bup_width', 3, x, y, 'position', [x y 140 20], ...
        'label', 'bupwidth, ms', 'TooltipString', 'the bup width in units of msec');
    NumeditParam(obj, 'bup_ramp', 2, x, y, 'position', [x+140 y 140 20], ...
        'label', 'bupramp, ms', 'TooltipString', 'the duration in units of msec of the upwards and downwards volume ramps for individual bups');
    NumeditParam(obj, 'base_freq', 2000, x, y, 'position', [x+280 y 150 20], ...
        'TooltipString', 'the base frequency of individual bup; the bup consists of this frequency together with ntones-1 higher octaves','label','base freq, Hz');
    NumeditParam(obj, 'ntones', 5, x, y, 'position', [x+430 y 80 20], ...
        'TooltipString', 'total number of tones used to generate individual bup; so ntones-1 higher octaves are combined with base_freq');
    NumeditParam(obj, 'vol', 0.5, x, y, 'position', [x+510 y 90 20], ...
        'labelfraction', 0.3, ...
        'TooltipString', 'volume multiplier for all sounds; can be a 1x2 vector to specify multiplier for [left_vol right_vol]');    
    next_row(y);
    
	ToggleParam(obj, 'first_bup_stereo', 1, x, y, 'position', [x y 100 20], ...
		'OffString', 'no stereo bup', ...
		'OnString',  'first bup stereo', ...
		'TooltipString', 'If on, an extra stereo bup is added in front of the first bup');
	ToggleParam(obj, 'avoid_collisions', 0, x, y, 'position', [x+100 y 100 20], ...
		'OffString', 'allow collisions', ...
		'OnString',  'prevent collisions', ...
		'TooltipString', 'If not allowed, a refractory period is imposed equal to a single bup width. Otherwise, click waveforms sum and can therefore interfere.');    
	ToggleParam(obj, 'task_type', 1, x, y, 'position', [x+200 y 100 20], ...
		'OffString', 'Frequency Task', ...
		'OnString',  'Sides Task', ...
		'TooltipString', 'Sides task is classic PBups where clicks come from either the right or left. Frequency makes all clicks stereo with the first base_freq frequency favoring left responses and the second favoring right');    
	
    NumeditParam(obj, 'min_ISI', 0, x, y, 'position', [x+300 y 100 20],'labelfraction',0.68, ...
        'TooltipString', 'the minimum time in ms that is allowed between bups','label','min ISI, ms');    
	NumeditParam(obj, 'total_rate', 40, x, y, 'position', [x+400 y 100 20],'labelfraction',0.68, ...
        'TooltipString', 'the sum of left and right bup rates in Hz','label','total rate, Hz');    
	NumeditParam(obj, 'crosstalk', 0, x, y, 'position', [x+500 y 100 20],'labelfraction',0.68, ...
		'TooltipString', 'if >0, then is the amount the left clicks leak into the right channel, and vice versa.');    
    
    set_callback({tone_style, ntones, base_freq, task_type}, {mfilename, 'update_tones'});
    
    next_row(y);
    SubheaderParam(obj, 'title4', 'Stimulus Properties Section', x, y);
	next_row(y, 1.3);

    DispParam(obj, 'ThisGamma', 0, x, y, 'position', [x y 150 20], ...
        'labelfraction', 0.6, ...
        'TooltipString', 'the gamma of the present trial; if r_R and r_L are the rates of Poisson events on the right and left, then gamma = log(r_R/r_L)');
    DispParam(obj, 'ThisLeftRate', 10, x, y, 'position', [x+150 y 150 20], ...
        'labelfraction', 0.6, ...
        'TooltipString', 'the average rate of Poisson events on the left for this trial');
    DispParam(obj, 'ThisRightRate', 10, x, y, 'position', [x+300 y 150 20], ...
        'labelfraction', 0.6, ...
        'TooltipString', 'the average rate of Poisson events on the right for this trial');
    
	next_row(y, 1);
	HeaderParam(obj, 'panel_title', 'PBups plugin, v.2', x, y, 'position', [x y 600 20]);
	
    % this soloparamhandle stores the actual bup times (in seconds) on the left and right
    % for the present trial, as well as the side response of an ideal
    % observer that counts the number of bups on either side.
    % ThisBupTimes.observer is -1 for left, 1 for right, and 0 if the
    % numbers of bups on either side are equal.
    % ThisBupTimes.left and ThisBupTimes.right are updated as the next
    % sound is prepared and pushed to history to be saved with the data
    SoloParamHandle(obj, 'ThisBupTimes', 'value', {});
    
    % passive auditory stimulation at the end of a trial
    SoloParamHandle(obj, 'ThisPassiveSound', 'value', {});
    
    % this soloparamhandle stores the specification of the stimulator wave
    % fields are: .ison, .channel, .pre, and .dur
    specs.ison = 0;
    specs.channel = 0;
    specs.pulse = 0;
    specs.freq = 0;
    specs.pre = 0;
    specs.dur = 1;
    specs.power=0;
    specs.trigger = '';
    SoloParamHandle(obj, 'StimulatorSpecs', 'value', specs);
    SoloParamHandle(obj, 'MaskSpecs',       'value', specs);
    
	% stores the set of gamma values used to make pbups from
	% trial to trial.  
	% these values may be specified either by range or by enumeration
	SoloParamHandle(obj, 'left_gammas', 'value', -2);
	SoloParamHandle(obj, 'right_gammas', 'value', 2);
    
	feval(mfilename, obj, 'gamma_style');
    feval(mfilename, obj, 'show_hide');   
    feval(mfilename, obj, 'check_stim_channels');
    feval(mfilename, obj, 'check_mask_channels');
    feval(mfilename, obj, 'check_headphones');
    feval(mfilename, obj, 'check_passive_stimulation');
    feval(mfilename, obj, 'update_laser_analog_output');
    feval(mfilename, obj, 'update_tones');
    
    figure(fig);
    x = origfig_xy(1); y = origfig_xy(2);
%% adjust_volume
  case 'adjust_volume'
    snd = varargin{1};
    if is_enabled(headphone_attentuation_dB)
        att = value(headphone_attentuation_dB);
        snd(1,:) = snd(1,:) * 10^-(att(1)/20);
        snd(2,:) = snd(2,:) * 10^-(att(2)/20);
    else
        if numel(value(vol)) == 1
            snd = snd*vol(1);
        else
            snd(1,:) = snd(1,:) * vol(1);
            snd(2,:) = snd(2,:) * vol(2);
        end
        % the volume and left and right speakers are not always matched
        RtoL_speaker_volume_ratio = bSettings('get', 'GENERAL', 'RtoL_speaker_volume_ratio');
        if ~isnan(RtoL_speaker_volume_ratio)
            snd(2,:) = snd(2,:) / RtoL_speaker_volume_ratio;
        end
    end
    x = snd;
%% check_headphones
  case 'check_headphones'
      hp_max_V = bSettings('get', 'GENERAL', 'HEADPHONE_MAX_V');
      if isnan(hp_max_V)
          disable(headphone_attentuation_dB)
          enable(vol)
      else
          enable(headphone_attentuation_dB)
          disable(vol)
      end
      
      % ** Make sure that there are always two values **
      s = value(headphone_attentuation_dB);
      if numel(s) < 2
          s(1,2) = s(1);
      elseif numel(s) > 2;
          s = s(1:2);
      end
      s = s(:)';
      headphone_attentuation_dB.value = s;
      
      % **Ensure minimum attentuation**
      if ~isnan(hp_max_V)
          % The Lynx L22 sound card generates a maximumal signal level of +20
          % dBU, which is equivalent to a  maximum voltage level of:  
          L22_max_V = sqrt(2) * sqrt(0.6) *10^(20/20);
          min_atten = 20*log10(L22_max_V/hp_max_V);
          s = value(headphone_attentuation_dB);
          s(s < min_atten) = min_atten;
          headphone_attentuation_dB.value = s;
          % https://brodylabwiki.princeton.edu/wiki/images/7/7e/Lynx_L22_ma
          % nual.pdf
      end
%% check_passive_stimulation
  case 'check_passive_stimulation'
    if isnan(bSettings('get', 'GENERAL', 'HEADPHONE_MAX_V'))
        disable(passive_stim);
        disable(ps_pre_s);
        disable(ps_post_s);
        disable(replay_bups);
        disable(rp_pre_s);
        disable(rp_post_s);
    else
        enable(passive_stim);
        enable(ps_pre_s);
        enable(ps_post_s);
        enable(replay_bups);
        enable(rp_pre_s);
        enable(rp_post_s);
    end
    if ps_pre_s < 0; ps_pre_s.value = 0; end
    if ps_post_s < 0; ps_post_s.value = 0; end
    if rp_pre_s < 0; rp_pre_s.value = 0; end
    if rp_post_s < 0; rp_post_s.value = 0; end
    
    ps_pre_s.value =  ps_pre_s(1);
    ps_post_s.value =  ps_post_s(1);
    rp_pre_s.value =  rp_pre_s(1);
    rp_post_s.value =  rp_post_s(1);
    
    PenaltySection(obj, 'check_drink_time');
%% check_mask_channels
  case 'check_mask_channels'
    
      % HACK ALERT: right now we'll accomodate only a single mask channel,
      % the 'MASK' channel
      channel = bSettings('get', 'DIOLINES', 'MASK');
      if isnan(channel),
          mask_frac.value = 0; % setting this to zero is potentially overriden because settings are loaded after this is called
          disable(mask_frac);
          disable(mask_pre);
          disable(mask_dur);
      end;   
%% check_stim_channels
  case 'check_stim_channels'
    
      channel = bSettings('get', 'DIOLINES', 'LASER');
      if isnan(channel),
          stimulator_frac.value = 0; % setting this to zero is potentially overriden because settings are loaded after this is called
      end;
%% count_this_bups
  case 'count_last_trial_bups'
	  sample_duration = varargin{1};
	  
	  x = time;
	  y = observer;
%% get
  case 'get'
     switch varargin{1},
         case 'nstimuli',
             x = length(left_gammas)+length(right_gammas); %#ok<NODEF>
         case 'nleft',
             x = length(left_gammas); %#ok<NODEF>
         case 'nright',
             x = length(right_gammas); %#ok<NODEF>
		 case 'all_sides',
			 x = [char('l'*ones(1,length(left_gammas))) char('r'*ones(1,length(right_gammas)))]; %#ok<NODEF>
		 case 'sample_duration', 
			 x = value(T);
		 case 'pprobs',
			 x = [value(L_pprobs) value(R_pprobs)];
     end;
%% get_all_bup_times
  case 'get_all_bup_times'
    x = get_history(ThisBupTimes); %#ok<NODEF>
    return;
%% get_bup_times  
  case 'get_bup_times',
    x = value(ThisBupTimes); %#ok<NODEF>
    return;
%% get_passive_sounds
  case 'get_passive_sound'
    x = value(ThisPassiveSound);
%% get_ReplaySpecs
  case 'get_ReplaySpecs'
    x = [];
    if is_enabled(replay_bups) && value(replay_bups)
        Replay = struct;
        Replay.pre_s = value(rp_pre_s);
        Replay.post_s = value(rp_post_s);
        x = Replay;
    end
%% make_passive_sound
  case 'make_passive_sound'
    srate = SoundManagerSection(obj, 'get_sample_rate');
    options = [nan(1,2), value(left_gammas), value(right_gammas)];
    this_roll = randi(numel(options));
    this_gamma = options(this_roll);
    switch this_roll
        case 1 % left/low freq#1 bup
            snd = singlebup(srate, 0,'tones', tones, ...
                                     'width', bup_width, ...
                                     'basefreq', base_freq(1), ...
                                     'ramp', bup_ramp);
            if task_type % spatial localization
                snd(2,:) = zeros(1,numel(snd));
            else
                snd = [snd, snd];
            end
            snd_dur_s = size(snd,2)/srate;
        case 2 % right/freq#2 bup
            snd = singlebup(srate, 0,'tones', tones, ...
                                     'width', bup_width, ...
                                     'basefreq', base_freq(numel(base_freq)), ...
                                     'ramp', bup_ramp);
            if task_type % spatial localization
                snd = [zeros(1,numel(snd)); snd];
            else
                snd = [snd, snd];
            end
            snd_dur_s = size(snd,2)/srate;
        otherwise
            snd_dur_s = T_min + rand*(T_max-T_min);
            [snd,lrate,rrate,bpt] = ...
                make_pbup(value(total_rate), this_gamma, srate, value(snd_dur_s), ...
                                       'bup_width', value(bup_width), ...
                                       'first_bup_stereo', value(first_bup_stereo), ...
                                       'crosstalk', value(crosstalk), ...
                                       'base_freq', value(base_freq), ...
                                       'tones', value(tones), ...
                                       'bup_ramp', value(bup_ramp),...
                                       'avoid_collisions',value(avoid_collisions), ...
                                       'min_ISI',value(min_ISI),...
                                       'task_type',value(task_type));
    end
    % ** Add silence to snd so that sound duration is T_max seconds **
    snd_pre_samples = max(ceil(T_max*srate - snd_dur_s*srate), 0);
    snd = [zeros(2,snd_pre_samples), snd];
    snd = feval(mfilename, obj, 'adjust_volume', snd);
    % *********************************************************************
    passive_sound.sound_name = 'PassiveSound';
	if ~SoundManagerSection(obj, 'sound_exists', passive_sound.sound_name)
		SoundManagerSection(obj, 'declare_new_sound', passive_sound.sound_name);
		SoundManagerSection(obj, 'set_sound', passive_sound.sound_name, snd);
	else
		snd_prev = SoundManagerSection(obj, 'get_sound', passive_sound.sound_name);
		if ~isequal(snd, snd_prev)
			SoundManagerSection(obj, 'set_sound', passive_sound.sound_name, snd);
        end
    end
    passive_sound.sound_id = SoundManagerSection(obj, 'get_sound_id', passive_sound.sound_name);
    passive_sound.gamma=this_gamma;
    passive_sound.tones = value(tones);
    if is_enabled(headphone_attentuation_dB);
        passive_sound.headphone_attentuation_dB = value(headphone_attentuation_dB);
    end
    passive_sound.pre_s = value(ps_pre_s);
    passive_sound.post_s = value(ps_post_s);
    
    % ** storage
    ThisPassiveSound.value = passive_sound;
    push_history(ThisPassiveSound);
%% make_sounds
  case 'make_this_sound'
	srate = SoundManagerSection(obj, 'get_sample_rate');
	% the sound made is at least 1 sec long, or as long as T
    if isempty(value(Bups))
        [snd,lrate,rrate,bpt] = make_pbup(value(total_rate), value(ThisGamma), srate, value(T), ...
                                           'bup_width', value(bup_width), 'first_bup_stereo', value(first_bup_stereo), ...
                                           'crosstalk', value(crosstalk), 'base_freq', value(base_freq), ...
                                           'tones', value(tones), 'bup_ramp', value(bup_ramp),...
                                           'avoid_collisions',value(avoid_collisions),'min_ISI',value(min_ISI),...
                                           'seed',value(ThisSeed),'task_type',value(task_type)); %#ok<NODEF>;        
    else
        [snd,lrate,rrate,bpt] = make_pbup(value(total_rate), value(ThisGamma), srate, value(T), ...
                                           'bup_width', value(bup_width), 'first_bup_stereo', value(first_bup_stereo), ...
                                           'crosstalk', value(crosstalk), 'base_freq', value(base_freq), ...
                                           'tones', value(tones), 'bup_ramp', value(bup_ramp),...
                                           'avoid_collisions',value(avoid_collisions),'min_ISI',value(min_ISI),...
                                           'seed',value(ThisSeed),'fixed_sound',value(Bups),'task_type',value(task_type)); %#ok<NODEF>;        
    end
    snd = PBupsSection(obj, 'adjust_volume', snd);
    if value(T) == value(T_probe)
        bpt.is_probe_trial=1;
    else
        bpt.is_probe_trial=0;
    end
    
    %new feature inserts a period of silence into the center of the click
    %train, requires user to change default settings
    if value(T) == value(T_probe) && value(insert_gap) == 1 && value(T_gap) > 0 && isempty(value(Bups))
        pr = sum(abs(snd));
        mid = round(numel(pr)/2);
        pt = find(pr(mid+1:end)==0,1,'first') + mid;
        
        snd1 = [snd(1,1:pt-1),zeros(1,round(srate*value(T_gap))),snd(1,pt:end)];
        snd2 = [snd(2,1:pt-1),zeros(1,round(srate*value(T_gap))),snd(2,pt:end)];
        snd  = [snd1;snd2];
        
        bpt.left( bpt.left  > value(T_probe)/2) = bpt.left( bpt.left  > value(T_probe)/2) + value(T_gap);
        bpt.right(bpt.right > value(T_probe)/2) = bpt.right(bpt.right > value(T_probe)/2) + value(T_gap);
        
        T.value = value(T) + value(T_gap);
    end
        
	if ~SoundManagerSection(obj, 'sound_exists', 'PBupsSound')
		SoundManagerSection(obj, 'declare_new_sound', 'PBupsSound');
		SoundManagerSection(obj, 'set_sound', 'PBupsSound', snd);
	else
		snd_prev = SoundManagerSection(obj, 'get_sound', 'PBupsSound');
		if ~isequal(snd, snd_prev)
			SoundManagerSection(obj, 'set_sound', 'PBupsSound', snd);
        end
    end

	ThisLeftRate.value = lrate;
	ThisRightRate.value = rrate;
    bpt.gamma=value(ThisGamma);
    bpt.is_frozen = value(is_frozen);
    bpt.user_defined_bup=~isempty(value(Bups));
    bpt.tones = value(tones);
    if is_enabled(headphone_attentuation_dB);
        bpt.headphone_attentuation_dB = value(headphone_attentuation_dB);
    end
	ThisBupTimes.value = bpt;
%% next_trial
  case 'next_trial'  
      % takes an additional argument that specifies the next side choice
	  % and vectors previous_sides and previous_sounds
      % returns the id of the next sound picked
	  % and the sample duration 
	  
      side = varargin{1};

      if isempty(side), % if we are not given which side the next trial is,
          if rand(1) < sum(LtPostProb(:)), side = 'l';
          else                             side = 'r';
          end;
      end;

      if value(n_seeds)>1000
          warning('Maximum allowed value of n_seeds is 1000!!!');
      end

    % if frozen, set a random seed within a small predetermined range                
    is_frozen.value = value(frozen_frac)<rand;
    if value(is_frozen)
        ThisSeed.value = round(value(total_rate)*10)*10^7 + round(value(ThisGamma)*10^2)*10^4 + (side=='r')*10^3 + randi(min(999,value(n_seeds)-1),1) ; % this more or less ensures frozen seeds are unique for each possible combination of gamma, side, and total_rate
    else
        ThisSeed.value = randi(10^9);
    end
	  
	  LocalPrevSides.value  = varargin{2};
	  LocalPrevSounds.value = varargin{3};
	  
      b = value(Bups);
      if ~isempty(b)
          if ~isstruct(b) || ~isscalar(b) || ~isfield(b,'left') || ~isfield(b,'right') ...
                  || ~isfield(b,'T') || ~isscalar(b.T) || ~isnumeric(b.T) || ~isnumeric(b.left) ...
                  || ~isnumeric(b.right) || min(size(b.left))>1 || min(size(b.right))>1
              error('user defined SoloParamHandle Bups is improperly defined');
          end
      end
      
	  feval(mfilename, obj, 'normalize_pprobs');
	  feval(mfilename, obj, 'T_resample');
	  feval(mfilename, obj, 'update_hitfrac');
	  feval(mfilename, obj, 'update_biashitfrac');
      feval(mfilename, obj, 'pick_stimulator');
	  feval(mfilename, obj, 'pick_mask');
      
	  if side == 'l',
          if length(LtPostProb)~=length(left_gammas)
              error('Vector of stimulus probabilities is not the same length as the vector of gammas. This can happen if you added free-choice code without adding free-choice gammas (i.e. +/-99)');
          end
		  x = find(cumsum(LtPostProb(:)) > rand(1)/2, 1, 'first');
		  if isempty(x), x = 1; end; % a catch so things don't break
		  ThisGamma.value = left_gammas(x);
		  x = -x;
	  elseif side == 'r',
          if length(RtPostProb)~=length(right_gammas)
              error('Vector of stimulus probabilities is not the same length as the vector of gammas. This can happen if you added free-choice code without adding free-choice gammas (i.e. +/-99)');
          end          
		  x = find(cumsum(RtPostProb(:)) > rand(1)/2, 1, 'first');
		  if isempty(x), x = 1; end; % a catch so things don't break
		  ThisGamma.value = right_gammas(x);
	  end;
	  
      feval(mfilename, obj, 'make_this_sound');
      if is_enabled(passive_stim) && passive_stim
          feval(mfilename, obj, 'make_passive_sound');
      end
	  feval(mfilename, obj, 'push_history');
      y = value(T);
%% push_history
  case 'push_history'
	  push_history(ThisBupTimes);
      push_history(StimulatorSpecs);
      push_history(MaskSpecs);
%% update_hitfrac
  case 'update_hitfrac',
	PrevSides = colvec(value(LocalPrevSides));

	if ~isempty(hit_history),
		kernel = exp(-(0:length(hit_history)-1)/HitFracTau)';
        kernel = kernel(end:-1:1);
		HitFrac.value = sum(hit_history .* kernel)/sum(kernel);
		
		if ~isempty(PrevSides),
			PrevSides = PrevSides(1:length(hit_history));
		end;
		
		u = find(PrevSides == 'l');
		if isempty(u), LtHitFrac.value = NaN;
		else           LtHitFrac.value = sum(hit_history(u) .* kernel(u))/sum(kernel(u));
		end;
		
		u = find(PrevSides == 'r');
		if isempty(u), RtHitFrac.value = NaN;
		else           RtHitFrac.value = sum(hit_history(u) .* kernel(u))/sum(kernel(u));
		end;
	else
		HitFrac.value   = NaN;
		LtHitFrac.value = NaN;
		RtHitFrac.value = NaN;
	end;
	  
%% update_biashitfrac
  case 'update_biashitfrac', 	  
      PrevSides = colvec(value(LocalPrevSides));  
	  PrevSounds  = colvec(value(LocalPrevSounds));
	  
	  if ~isempty(hit_history),
		  if ~isempty(PrevSounds),
			  PrevSides  = PrevSides(1:length(hit_history));
			  PrevSounds = PrevSounds(1:length(hit_history));
		  end;
		  
		  u = find(PrevSides == 'l');
		  if isempty(u), 
			  LtHits.value     = ones(size(L_pprobs));
			  LtPostProb.value = value(L_pprobs);
		  else
			  biashitfrac_value = exponential_hitfrac(PrevSounds(u), hit_history(u), value(BiasTau), -(1:length(L_pprobs(:))));
			  LtHits.value     = biashitfrac_value;
			  LtPostProb.value = probabilistic_trial_selector(biashitfrac_value, value(L_pprobs), value(Beta))*sum(L_pprobs(:));
			  if isnan(value(LtPostProb)), LtPostProb.value = value(L_pprobs); end;
		  end;

		  u = find(PrevSides == 'r');
		  if isempty(u), 
			  RtHits.value     = ones(size(R_pprobs));
			  RtPostProb.value = value(R_pprobs);
		  else
			  biashitfrac_value = exponential_hitfrac(PrevSounds(u), hit_history(u), value(BiasTau), 1:length(R_pprobs(:)));
			  RtHits.value     = biashitfrac_value;
			  RtPostProb.value = probabilistic_trial_selector(biashitfrac_value, value(R_pprobs), value(Beta))*sum(R_pprobs(:));
			  if isnan(value(RtPostProb)), RtPostProb.value = value(R_pprobs); end;
		  end;	
	  else
		  LtHits.value = NaN;
		  RtHits.value = NaN;
		  LtPostProb.value = value(L_pprobs);
		  RtPostProb.value = value(R_pprobs);
	  end;
%% update_tones
  case 'update_tones'     
      s = value(base_freq);
      s(s < 0) = 0;
      base_freq.value = s;
      
      s = value(ntones);
      s(s < 0) = 0;
      ntones.value = s;
      
      if task_type && tone_style
          enable(tones)
      else
          disable(tones)
      end

      if task_type % if performing spatial localization
          base_freq.value = base_freq(1);
      end
      
      if ~tone_style
          tones.value = value(base_freq) * 2.^(0:value(ntones)-1);
      end
%% test_gamma
  case 'test_gamma'
	srate = SoundManagerSection(obj, 'get_sample_rate');
    [snd,lrate,rrate] = make_pbup(value(total_rate), value(test_gamma), srate, value(sduration), ...
                     'bup_width', value(bup_width), 'first_bup_stereo', value(first_bup_stereo), ...
                     'crosstalk', value(crosstalk), 'base_freq', value(base_freq), ...
                     'ntones', value(ntones), 'bup_ramp', value(bup_ramp), 'generate_sound', 0,...
                     'avoid_collisions',value(avoid_collisions),'min_ISI',value(min_ISI),'task_type',value(task_type)); 
		
	test_lrate.value = lrate;
	test_rrate.value = rrate;
	
%% test_play
  case 'test_play',
    srate = SoundManagerSection(obj, 'get_sample_rate');
    if task_type
        [snd] = make_pbup(value(total_rate), value(test_gamma), srate, value(sduration), ...
                         'bup_width', value(bup_width), 'first_bup_stereo', value(first_bup_stereo), ...
                         'crosstalk', value(crosstalk), ...
                         'tones', value(tones), 'bup_ramp', value(bup_ramp),...
                         'avoid_collisions',value(avoid_collisions),'min_ISI',value(min_ISI),'task_type',value(task_type)); 
    else
        [snd] = make_pbup(value(total_rate), value(test_gamma), srate, value(sduration), ...
                         'bup_width', value(bup_width), 'first_bup_stereo', value(first_bup_stereo), ...
                         'crosstalk', value(crosstalk), 'base_freq', value(base_freq), ...
                         'ntones', value(ntones), 'bup_ramp', value(bup_ramp),...
                         'avoid_collisions',value(avoid_collisions),'min_ISI',value(min_ISI),'task_type',value(task_type)); 
    end
                 
    if numel(value(vol)) == 1
        snd = snd*vol(1);
    else
        snd(1,:) = snd(1,:) * vol(1);
        snd(2,:) = snd(2,:) * vol(2);
    end
    
    if ~SoundManagerSection(obj, 'sound_exists', 'TestSound')
      SoundManagerSection(obj, 'declare_new_sound', 'TestSound');
    end

    SoundManagerSection(obj, 'set_sound', 'TestSound', snd);
    
    SoundManagerSection(obj, 'play_sound', 'TestSound');
%% stop_sound      
  case 'test_stop'
      
    SoundManagerSection(obj, 'stop_sound', 'TestSound');
%% test_left_speaker
    case 'test_left_speaker'
        if test_left_speaker
            srate = SoundManagerSection(obj, 'get_sample_rate');
            t = 0:(1/srate):1-1/srate;
            din = zeros(size(t));
            for i = 1:numel(value(tones))
                din = din + sin(2*pi*tones(i)*t);
            end
            
            % scale din by the peak of a single bup
            bup = singlebup(srate, 0, ...
                            'tones', value(tones), ...
                            'width', value(bup_width), ...
                            'basefreq', value(base_freq), ...
                            'ramp', value(bup_ramp));
            if is_enabled(headphone_attentuation_dB)
                att = value(headphone_attentuation_dB);
                bup_max = 10^-(att(1)/20);
            else
                bup_max = max(bup)*vol(1);
            end
            din = din/max(din)*bup_max;
            din = [din; zeros(1,numel(din))];
            
            if ~SoundManagerSection(obj, 'sound_exists', 'left_din')
                SoundManagerSection(obj, 'declare_new_sound', 'left_din');
            end
            SoundManagerSection(obj, 'set_sound', 'left_din', din);
            SoundManagerSection(obj, 'loop_sound','left_din', 1);
            SoundManagerSection(obj, 'play_sound', 'left_din');
        else
            if SoundManagerSection(obj, 'sound_exists', 'left_din')
                SoundManagerSection(obj, 'stop_sound', 'left_din');
            end
        end 
%% test_right_speaker
    case 'test_right_speaker'
        if test_right_speaker
            srate = SoundManagerSection(obj, 'get_sample_rate');
            t = 0:(1/srate):1;
            din = zeros(size(t));
            for i = 1:numel(value(tones))
                din = din + sin(2*pi*tones(i)*t);
            end
            
            % scale din by the max of a single bup
            bup = singlebup(srate, 0, ...
                            'tones', value(tones), ...
                            'width', value(bup_width), ...
                            'basefreq', value(base_freq), ...
                            'ramp', value(bup_ramp));
            if is_enabled(headphone_attentuation_dB)
                att = value(headphone_attentuation_dB);
                bup_max = 10^-(att(2)/20);
            else
                bup_max = max(bup) * vol(numel(value(vol))); % VOL could be either a scalar or a 1x2 numeric
                RtoL_speaker_volume_ratio = bSettings('get', 'GENERAL', 'RtoL_speaker_volume_ratio');
                if ~isnan(RtoL_speaker_volume_ratio)
                    bup_max = bup_max/sqrt(RtoL_speaker_volume_ratio);
                end
            end
            din = din/max(din)*bup_max;
            din = [zeros(1,numel(din)); din];
            
            if ~SoundManagerSection(obj, 'sound_exists', 'right_din')
                SoundManagerSection(obj, 'declare_new_sound', 'right_din');
            end
            SoundManagerSection(obj, 'set_sound', 'right_din', din);
            SoundManagerSection(obj, 'loop_sound','right_din', 1);
            SoundManagerSection(obj, 'play_sound', 'right_din');
        else
            if SoundManagerSection(obj, 'sound_exists', 'right_din')
                SoundManagerSection(obj, 'stop_sound', 'right_din');
            end
        end 
%% T_resample
  case 'T_resample'
	if p_probe > 1, p_probe.value = 1; end
	if p_probe < 0, p_probe.value = 0; end
	if T_probe < 0, T_probe.value = 0; p_probe.value = 0; end
	if T_max < T_min, T_max.value = T_min(1); end
	
	if rand(1) < p_probe
		T.value = value(T_probe);
    else
        if isempty(value(Bups))
            % set T using the seed, so that frozen noise trials have the same
            % bup sequence AND stimulus duration
            try
                RandStream.setDefaultStream(RandStream('mt19937ar','Seed',value(ThisSeed))); % old matlab            
            catch
                rng(value(ThisSeed),'twister'); % new matlab
            end            
            T.value = value(T_min)+rand(1)*(T_max-T_min);

            % shuffle seed up to max allowed, using the current time. This is
            % required to make things non-deterministic after fixing the seed.
            seed0 = mod(floor(now*8640000),2^32-1); 
            for i = 1:100
                clockSeed = mod(floor(now*8640000),2^32-1);
                if clockSeed ~= seed0, break; end
                pause(.01); % smallest recommended interval
            end
            try
                RandStream.setDefaultStream(RandStream('mt19937ar','Seed',clockSeed)); % old matlab            
            catch
                rng('shuffle','twister'); % new matlab
            end    
        else
            b=value(Bups);
            T.value = b.T;
        end
    end
	
%% normalize_pprobs
  case 'normalize_pprobs'
	nlefts = length(L_pprobs(:));
	p = [L_pprobs(:); R_pprobs(:)];
	p = p/sum(p);
	L_pprobs.value = p(1:nlefts);
	R_pprobs.value = p(nlefts+1:end);
    
%% gammas
  case 'gammas'
    L_gammas.value = -abs(value(L_gammas)); %#ok<NODEF>
    R_gammas.value = abs(value(R_gammas)); %#ok<NODEF>
	easiest.value = abs(value(easiest)); %#ok<NODEF>
	hardest.value = abs(value(hardest)); %#ok<NODEF>
	if N < 1, N.value = 1; end; %#ok<NODEF>
	feval(mfilename, obj, 'gamma_style');
	
%% gamma_style
  case 'gamma_style'
	if gamma_style == 0, % if we're going by the range
		enable(easiest);
		enable(hardest);
		enable(N);
		disable(L_gammas);
		disable(R_gammas);
		if N == 1,
			g = easiest(1);
		else
			g = linspace(easiest(1), hardest(1), N(1));
		end;
		left_gammas.value  = -g;  % internal soloparam
		right_gammas.value = g;   % internal soloparam
		L_gammas.value = value(left_gammas);  % for display 
		R_gammas.value = value(right_gammas); % for display
		if length(L_pprobs) ~= length(L_gammas),	L_pprobs.value = ones(1, N(1)); end;
		if length(R_pprobs) ~= length(R_gammas),    R_pprobs.value = ones(1, N(1)); end;
		feval(mfilename, obj, 'normalize_pprobs');
	else                 % if we're going by L_gammas and R_gammas
		disable(easiest);
		disable(hardest);
		disable(N);
		enable(L_gammas);
		enable(R_gammas);
		left_gammas.value  = L_gammas(:);
		right_gammas.value = R_gammas(:);
		if length(L_pprobs) ~= length(L_gammas),	L_pprobs.value = ones(1, length(L_gammas)); end;
		if length(R_pprobs) ~= length(R_gammas),    R_pprobs.value = ones(1, length(R_gammas)); end;
		feval(mfilename, obj, 'normalize_pprobs');
	end;
%% update_stim
  case 'update_stim'
      
      % enforces that the correct number of entries are in all the
      % stimulation related sphs.
      n = numel(value(stimulator_frac));
      
      if numel(value(stim_freq)) < n,
          s = value(stim_freq);
          stim_freq.value = [s s(end)*ones(1,n-numel(s))];
      elseif numel(value(stim_freq)) > n
          s = value(stim_freq);
          stim_freq.value = s(1:n);
      end
      
      if numel(value(stim_pulse)) < n,
          s = value(stim_pulse);
          stim_pulse.value = [s s(end)*ones(1,n-numel(s))];
      elseif numel(value(stim_pulse)) > n
          s = value(stim_pulse);
          stim_pulse.value = s(1:n);
      end
      
      if numel(value(stim_pre)) < n,
          s = value(stim_pre);
          stim_pre.value = [s s(end)*ones(1,n-numel(s))];
      elseif numel(value(stim_pre)) > n
          s = value(stim_pre);
          stim_pre.value = s(1:n);
      end
      
      if numel(value(stim_pre_jitter)) < n,
          s = value(stim_pre_jitter);
          stim_pre_jitter.value = [s s(end)*ones(1,n-numel(s))];
      elseif numel(value(stim_pre_jitter)) > n
          s = value(stim_pre_jitter);
          stim_pre_jitter.value = s(1:n);
      end     
      
      if numel(value(stim_dur)) < n,
          s = value(stim_dur);
          stim_dur.value = [s s(end)*ones(1,n-numel(s))];
      elseif numel(value(stim_dur)) > n
          s = value(stim_dur);
          stim_dur.value = s(1:n);
      end  
      
      if numel(stim_trigger_state) < n,
          s = value(stim_trigger_state);
          stim_trigger_state.value = [s s(end)*ones(1,n-numel(s))];
      elseif numel(value(stim_trigger_state)) > n
          s = value(stim_trigger_state);
          stim_trigger_state.value = s(1:n);
      end 

      if numel(stim_power) < n,
          s = value(stim_power);
          stim_power.value = [s s(end)*ones(1,n-numel(s))];
      elseif numel(value(stim_power)) > n
          s = value(stim_power);
          stim_power.value = s(1:n);
      end 
      
      if numel(ao_min_V) < n,
          s = value(ao_min_V);
          ao_min_V.value = [s s(end)*ones(1,n-numel(s))];
      elseif numel(value(ao_min_V)) > n
          s = value(ao_min_V);
          ao_min_V.value = s(1:n);
      end 
      
      if numel(ao_max_V) < n,
          s = value(ao_max_V);
          ao_max_V.value = [s s(end)*ones(1,n-numel(s))];
      elseif numel(value(ao_max_V)) > n
          s = value(ao_max_V);
          ao_max_V.value = s(1:n);
      end 
      
      if numel(ao_on_ramp_dur_s) < n,
          s = value(ao_on_ramp_dur_s);
          ao_on_ramp_dur_s.value = [s s(end)*ones(1,n-numel(s))];
      elseif numel(value(ao_on_ramp_dur_s)) > n
          s = value(ao_on_ramp_dur_s);
          ao_on_ramp_dur_s.value = s(1:n);
      end 
      
      if numel(ao_off_ramp_dur_s) < n,
          s = value(ao_off_ramp_dur_s);
          ao_off_ramp_dur_s.value = [s s(end)*ones(1,n-numel(s))];
      elseif numel(value(ao_off_ramp_dur_s)) > n
          s = value(ao_off_ramp_dur_s);
          ao_off_ramp_dur_s.value = s(1:n);
      end 
      
      s = value(ao_min_V);
      s(s < -10) = -10;
      ao_min_V.value = s;      
      s = value(ao_max_V);
      s(s < -10) = -10;
      ao_max_V.value = s;
      s = value(ao_on_ramp_dur_s);
      s(s < 0) = 0;
      ao_on_ramp_dur_s.value = s;
      s = value(ao_off_ramp_dur_s);
      s(s < 0) = 0;
      ao_off_ramp_dur_s.value = s;
      s = value(stim_dur);
      ramp_dur_s = value(ao_on_ramp_dur_s) + value(ao_off_ramp_dur_s);
      s(s < ramp_dur_s) = ramp_dur_s(s < ramp_dur_s);
      stim_dur.value = s;
      s = value(stim_trigger_state);
      s(s < 1 | mod(s, 1)~=0) = 1;
      stim_trigger_state.value = s;
%% update_laser_analog_output
  case 'update_laser_analog_output'
      if isnan(bSettings('get', 'GENERAL', 'CLOCK_SPEED_HZ')) || ...
         isnan(bSettings('get', 'AO_LINES', 'LASER'));
          stim_is_analog_not_digital.value = 0;
          disable(stim_is_analog_not_digital);
      end
      
      for param = {'ao_min_V', 'ao_max_V', 'ao_on_ramp_dur_s', 'ao_off_ramp_dur_s', 'ao_is_sine_not_square'};
          if stim_is_analog_not_digital
            eval(['enable(' param{:} ')']);
          else
            eval(['disable(' param{:} ')']);
          end
      end
      if stim_is_analog_not_digital && ao_is_sine_not_square
          disable(stim_pulse)
      else
          enable(stim_pulse)
      end
%% update_mask
  case 'update_mask'
      
      % enforces that the correct number of entries are in mask_channel,
      % mask_frac, mask_pre, and mask_dur
      n = numel(value(mask_frac));

      mask_channel.value = ones(1, n);
      
      if numel(value(mask_pre)) < n,
          s = value(mask_pre);
          mask_pre.value = [s s(end)*ones(1,n-numel(s))];
      end;
      
      if numel(value(mask_dur)) < n,
          s = value(mask_dur);
          mask_dur.value = [s s(end)*ones(1,n-numel(s))];
      end;
      
      if numel(mask_trigger_state) < n,
          s = value(mask_trigger_state);
          mask_trigger_state.value = [s s(end)*ones(1,n-numel(s))];
      end;      
    
%% stimulator
  case 'pick_stimulator'
      % determine if the next trial will be accompanied by a stim DIOLINE 

      StimulatorSpecs.ison    = 0;
      StimulatorSpecs.pre     = 0;
      StimulatorSpecs.dur     = 0;
      StimulatorSpecs.freq    = 0;
      StimulatorSpecs.pulse   = 0;
      StimulatorSpecs.power   = 0;
      StimulatorSpecs.trigger = '';
      if isfield(value(StimulatorSpecs), 'analog_output')
          StimulatorSpecs.value = rmfield(value(StimulatorSpecs), 'analog_output');
      end
      if n_done_trials == 0 || ... % don't stimulate on the first trial of the session
         (value(ThisStim) > 0 && value(allow_consecutive_stimulation) == 0) % if the previous trial had stimulation
          mystim = 0;
      elseif sum(value(stimulator_frac)) < eps,
          mystim = 0;
      elseif value(require_cerebro) && ~CerebroSection(obj,'is_connected')
          mystim=0;
          warning('Settings dictate cerebro connection is required for stimulation but one is not connected.');
      else
          mystim = find(rand(1) < cumsum(value(stimulator_frac)), 1, 'first');
          if isempty(mystim), mystim = 0; end;
          
          if value(stimulator_style) == 1 && ...
                  value(T) ~= value(T_probe) && ...
                  abs(value(ThisGamma)) ~= 99 && ...
                    ~strncmpi(value(reward_type),'free',4)
              % if we're only stimulating on probe trials, and this is not
              % a probe trial,
              % but allow stim to occur on side LED and FC trials even if
              % you select stim on probe trials only. 
              % Adrian: What we should really do is have stim on sideLEd
              % and stim on FC be options the user can set. Even bigger
              % picture, FC and sideLEd should be controlled by
              % PBupsSection, rather than as part of the stage
              % algorithm.10/2018
              
              mystim = 0;
          end
          
          valid_states = {'cpoke1', 'wait_for_spoke','iti'};
          
          if mystim > 0

            StimulatorSpecs.pre     = unifrnd(stim_pre(mystim)-stim_pre_jitter(mystim),stim_pre(mystim)+stim_pre_jitter(mystim));
            StimulatorSpecs.dur     = stim_dur(mystim);
            StimulatorSpecs.freq    = stim_freq(mystim);
            StimulatorSpecs.pulse   = stim_pulse(mystim);
            StimulatorSpecs.power   = stim_power(mystim);
            StimulatorSpecs.trigger = valid_states{stim_trigger_state(mystim)};
            if value(stim_is_analog_not_digital)
                StimulatorSpecs.ison = mystim;
                feval(mfilename, obj, 'set_up_laser_analog_modulation');
            end
          end;
      end;
      
      ThisStim.value = mystim;
      StimulatorSpecs.ison = mystim;
%% set_up_laser_analog_modulation
  case 'set_up_laser_analog_modulation'
    mystim = StimulatorSpecs.ison;
    StimulatorSpecs.analog_output.line = bSettings('get', 'AO_LINES', 'LASER');
    StimulatorSpecs.analog_output.clock_speed_hz = bSettings('get', 'GENERAL', 'CLOCK_SPEED_HZ');
    StimulatorSpecs.analog_output.is_sine_not_square = value(ao_is_sine_not_square);
    StimulatorSpecs.analog_output.min_V = ao_min_V(mystim);
    StimulatorSpecs.analog_output.max_V = ao_max_V(mystim);
    StimulatorSpecs.analog_output.on_ramp_dur_s = ao_on_ramp_dur_s(mystim);
    StimulatorSpecs.analog_output.off_ramp_dur_s = ao_off_ramp_dur_s(mystim);
    % simplify nomenclature of variables for manipulation
    for f = fields(StimulatorSpecs.analog_output)'
        eval([f{:} ' = StimulatorSpecs.analog_output.' f{:}])
    end
    if StimulatorSpecs.freq == 0 || StimulatorSpecs.pulse == 0 % continuous illumination
        n_samples = clock_speed_hz*StimulatorSpecs.dur;
        analog_out_V = ones(1,n_samples) * max_V;
    else
        clock_cycle_s = 1/clock_speed_hz;
        t = 0:clock_cycle_s:StimulatorSpecs.dur-clock_cycle_s;
        StimulatorSpecs.analog_output.time_s = t;
        if is_sine_not_square
            t = t*2*pi;
            t = t*StimulatorSpecs.freq;
            t = t - pi/2; % to start the output at the trough of the wave
            analog_out_V = sin(t);
            analog_out_V = analog_out_V + 1; % to set the trough at zero
            analog_out_V = analog_out_V * (max_V-min_V)/2; 
            analog_out_V = analog_out_V + min_V;
        else
            t = mod(t, 1/StimulatorSpecs.freq);
            analog_out_V = min_V*ones(1,numel(t));
            analog_out_V(t < StimulatorSpecs.pulse/1000) = max_V;
        end
    end
    n_ramp_on  = floor(on_ramp_dur_s  * clock_speed_hz); % number of samples
    n_ramp_off = floor(off_ramp_dur_s * clock_speed_hz);
    if n_ramp_on > 0
        analog_out_V(1:n_ramp_on) = analog_out_V(1:n_ramp_on) .* (1:n_ramp_on)/n_ramp_on;
    end
    if n_ramp_off > 0
        analog_out_V(end-n_ramp_off+1:end) = analog_out_V(end-n_ramp_off+1:end) .* (n_ramp_off:-1:1)/n_ramp_off;
    end
    StimulatorSpecs.analog_output.voltage = analog_out_V;
    % The input 'analog_waveform' to ADD_SCHEDULED_WAVE takes values within the range of [-1,1],
    % which corresponds to output of [-10, 10] volts by the NIDAQ cards as measured by TZL on 2018-10-19
    StimulatorSpecs.analog_output.waveform = analog_out_V/10;
      
      %% send new specs to cerebro
      if mystim && CerebroSection(obj,'is_connected')
        % don't send a waveform of zero because it can mess with
        % testing implant
        CerebroSection(obj,'send_stim_specs',StimulatorSpecs); 
      end

%% mask
  case 'pick_mask'
      % determine if the next trial will be accompanied by a mask DIOLINE 
      
      MaskSpecs.ison = 0;
      MaskSpecs.channel = 0;
      MaskSpecs.pre = 0;
      MaskSpecs.dur = 0;
      MaskSpecs.trigger = '';
      
      %If we are locking the mask to the stim, and this is a stim trial
      %then the mask should happen at the same time. We're going to assume
      %the user has the same stim and mask specs
      if value(lock_mask2stim) == 1 && value(ThisStim) ~= 0
          mymask = value(ThisStim);
      else
          mymask = find(rand(1) < cumsum(value(mask_frac)), 1, 'first');
          
          if isempty(mymask), mymask = 0; end;

          if value(mask_style) == 1 && value(T) ~= value(T_probe), 
              % if we're only masking on probe trials, and this is not a probe trial,
              mymask = 0;
          end;
      end
      
      valid_states = {'cpoke1', 'wait_for_spoke','iti'};

      if mymask > 0, 
        MaskSpecs.channel = mask_channel(mymask);
        MaskSpecs.pre     = mask_pre(mymask);
        MaskSpecs.dur     = mask_dur(mymask);
        MaskSpecs.trigger = valid_states{mask_trigger_state(mymask)};
      end;
      
      ThisMask.value = mymask;
      MaskSpecs.ison = mymask;

      
%% get_ThisStim
  case 'get_ThisStim'
      x = value(ThisStim);
      return;
      
%% get_stimulator_specs
  case 'get_stimulator_specs'
      x = value(StimulatorSpecs);
      return;
      
%% get_all_stimulator_specs
  case 'get_all_stimulator_specs'
      x = get_history(StimulatorSpecs);
      return;
      
%% get_ThisMask
  case 'get_ThisMask'
      x = value(ThisMask);
      return;
      
%% get_mask_specs
  case 'get_mask_specs'
      x = value(MaskSpecs);
      return;
      
%% get_all_mask_specs
  case 'get_all_mask_specs'
      x = get_history(MaskSpecs);
      return;      
      
%% hide, show_hide
  case 'hide',
    pbup_show.value = 0;
    feval(mfilename, obj, 'show_hide');
    
  case 'show_hide',
    if value(pbup_show) == 1, set(value(pbup_fig), 'Visible', 'on');  %#ok<NODEF>
    else                      set(value(pbup_fig), 'Visible', 'off');
    end;
    
%% close
  case 'close'   
    try %#ok<TRYNC>
        if ishandle(value(pbup_fig)), delete(value(pbup_fig)); end;
        delete_sphandle('owner', ['^@' class(obj) '$'], 'fullname', [mfilename '_' tname]);
    end;
    
%% reinit
  case 'reinit'
    % Get the original GUI position and figure:
    my_gui_info = value(my_gui_info);
    x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));
    
    % close everything involved with the plugin
    feval(mfilename, obj, 'close');

    % Reinitialise at the original GUI position and figure:
    feval(mfilename, obj, 'init', x, y);
        
%% otherwise    
  otherwise
    warning('%s : action "%s" is unknown!', mfilename, action); %#ok<WNTAG> (This line OK.)

end; %     end of switch action

function [x] = colvec(x)
    if size(x,2) > size(x,1), x = x'; end;
    return;