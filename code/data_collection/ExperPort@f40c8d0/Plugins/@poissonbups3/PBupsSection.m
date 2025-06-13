% [x, y] = PBupsSection(obj, action, tname, varargin)
%
% This plugin makes a window that manages the making of Poisson bups, which
% are bups that occur as independent Poisson processes on the left and
% right.
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

function [x, y] = PBupsSection(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action,
    
%% init    
  case 'init'
    if length(varargin) < 2,
      error('Need at least two arguments, x and y position, to initialize %s', mfilename);
    end;
    x = varargin{1}; y = varargin{2};

    SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);
    
    ToggleParam(obj, 'pbup_show', 0, x, y, ...
       'OnString', 'PBup window Showing', ...
       'OffString', 'PBup window Hidden', ...
       'TooltipString', 'Show/Hide PBup window'); next_row(y);
    set_callback(pbup_show, {mfilename, 'show_hide';});  %#ok<NODEF>
    
    screen_size = get(0, 'ScreenSize'); fig = double(gcf);
    SoloParamHandle(obj, 'pbup_fig', ...
        'value', double(figure('Position', [200 50 600 700], ...
        'closerequestfcn', [mfilename '(' class(obj) ', ''hide''' ');'], 'MenuBar', 'none', ...
        'NumberTitle', 'off', 'Name', 'PBups')), 'saveable', 0);
    origfig_xy = [x y]; 
    
    x = 10; y = 10;
	% TESTING SECTION
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
    next_row(y, 1.5);
	
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
	next_row(y, 1.5);
    
    % STIMULATOR SECTION
    NumeditParam(obj, 'stim_trigger_state', 1, x, y, 'position', [x y 250 20], ...
        'labelfraction', 0.4, ...
        'TooltipString', 'the state on which the stim will be triggered, as listed in states_list');
    valid_states = {'1: cpoke1', '2: wait_for_spoke'};
    MenuParam(obj, 'states_list', valid_states, 1, x, y,'position', [x+250 y 250 20], ...
        'labelfraction', 0.3, ...
        'TooltipString', 'The list of possible states on which a scheduled wave carrying the stimulation');
    next_row(y);
    NumeditParam(obj, 'stim_pre', 0, x, y, 'position', [x y 250 20], ...
        'labelfraction', 0.4, ...
        'TooltipString', 'Duration (in sec) of preamble before stimulator is turned on, relative to start of nose-in-center');
    NumeditParam(obj, 'stim_dur', 2, x, y, 'position', [x+250 y 250 20], ...
        'labelfraction', 0.4, ...
        'TooltipString', 'Duration (in sec) the stimulator remains on');
    next_row(y);
    NumeditParam(obj, 'stim_channel', 1, x, y, 'position', [x y 250 20], ...
        'labelfraction', 0.4, ...
        'TooltipString', 'the stim channel used for each stimulator class; at this point, should be all ones');
    NumeditParam(obj, 'stimulator_frac', 0, x, y, 'position', [x+250 y 250 20], ...
        'labelfraction', 0.4, ...
        'TooltipString', 'fraction of trials stimulated; note that if only probe trials are stimulated, then this means the fraction of probe trials, not total trials');
    set_callback({stim_trigger_state; stim_pre; stim_dur; stim_channel; stimulator_frac}, {mfilename, 'update_stim'});
    next_row(y);
    DispParam(obj, 'ThisStim', 0, x, y, 'position', [x y 150 20], ...
        'labelfraction', 0.7, ...
        'TooltipString', 'the stimulator class this trial');
    ToggleParam(obj, 'stimulator_style', 0, x, y, 'position', [x+150 y 250 20], ...
		'OffString', 'Stimulate on all trial types', ...
		'OnString',  'Stimulate on probe trials only', ...
		'TooltipString', 'specifies the types of trials the stimulator may be used');
    next_row(y);
	SubheaderParam(obj, 'title5', 'Stimulator Section', x, y);
    next_row(y, 1.5);
    
    % MASK SECTION
    NumeditParam(obj, 'mask_trigger_state', 1, x, y, 'position', [x y 250 20], ...
        'labelfraction', 0.4, ...
        'TooltipString', 'the state on which the mask will be triggered, as listed in states_list');
    valid_states = {'1: cpoke1', '2: wait_for_spoke'};
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
    next_row(y);
	SubheaderParam(obj, 'title5', 'Mask Section', x, y);
    next_row(y, 1.5);
    
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
	next_row(y, 1.5);
	
	% PBUPS SPECIFICATION
    NumeditParam(obj, 'R_gammas', [.5 1.1 2 3.6], x, y, 'position', [x+50 y 200 20], ...
        'labelfraction', 0.3, ...
        'TooltipString', 'gammas for sounds whose rates in the right ear are larger; these must all be > 0');
	NumeditParam(obj, 'R_pprobs', 0.25, x, y, 'position', [x+250 y 200 20], ...
		'labelfraction', 0.3, ...
		'TooltipString', 'prior probability for R sounds');
    next_row(y);
    NumeditParam(obj, 'L_gammas', -[.5 1.1 2 3.6], x, y, 'position', [x+50 y 200 20], ...
        'labelfraction', 0.3, ...
        'TooltipString', 'gammas for sounds whose rates in the left ear are larger; these must all be < 0');
	NumeditParam(obj, 'L_pprobs', 0.25, x, y, 'position', [x+250 y 200 20], ...
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
                              
    next_row(y);
    set_callback({R_gammas, L_gammas, easiest, hardest, N}, {mfilename, 'gammas'}); %#ok<NODEF>
 
    NumeditParam(obj, 'bup_width', 3, x, y, 'position', [x y 180 20], ...
        'label', 'bup_width (ms)', 'TooltipString', 'the bup width in units of msec');
    NumeditParam(obj, 'bup_ramp', 2, x, y, 'position', [x+180 y 180 20], ...
        'label', 'bup_ramp (ms)', 'TooltipString', 'the duration in units of msec of the upwards and downwards volume ramps for individual bups');
    NumeditParam(obj, 'base_freq', 2000, x, y, 'position', [x+360 y 140 20], ...
        'TooltipString', 'the base frequency of individual bup; the bup consists of this frequency together with ntones-1 higher octaves');
    NumeditParam(obj, 'ntones', 5, x, y, 'position', [x+500 y 100 20], ...
        'TooltipString', 'total number of tones used to generate individual bup; so ntones-1 higher octaves are combined with base_freq');
    next_row(y);
    
	NumeditParam(obj, 'total_rate', 40, x, y, 'position', [x y 150 20], ...
        'TooltipString', 'the sum of left and right bup rates');
	ToggleParam(obj, 'first_bup_stereo', 1, x, y, 'position', [x+150 y 150 20], ...
		'OffString', 'no stereo bup', ...
		'OnString',  'first bup stereo', ...
		'TooltipString', 'If on, an extra stereo bup is added in front of the first bup');
	NumeditParam(obj, 'crosstalk', 0, x, y, 'position', [x+300 y 150 20], ...
		'TooltipString', 'if >0, then is the amount the left clicks leak into the right channel, and vice versa.');    
    NumeditParam(obj, 'vol', 0.5, x, y, 'position', [x+450 y 150 20], ...
        'labelfraction', 0.3, ...
        'TooltipString', 'volume multiplier for all sounds; can be a 1x2 vector to specify multiplier for [left_vol right_vol]');
    next_row(y);
    SubheaderParam(obj, 'title4', 'Stimulus Properties Section', x, y);
	next_row(y, 1.5);
  
  
  % FROZEN STIMULI SECTION
  disable(L_gammas);
  disable(R_gammas);
  disable(L_pprobs);
  disable(R_pprobs);
  disable(easiest);
  disable(hardest);
  disable(N);
  disable(gamma_style);
  NumeditParam(obj,'IndicesStimToPrint',[1 1 1 1],x,y,'position',[x y 200 20],...
    'TooltipString','indices (L/R,gamma,duration,nstimper) of frozen stim click times to print');
  PushbuttonParam(obj,'print_click_times',x,y,'position',[x+200 y 100 20],...
		'label','Print Click Times',...
		'TooltipString','print click times of frozen stim indicated by IndicesStimToPrint');
  set_callback(print_click_times,{mfilename,'print_click_times'});
  next_row(y);
  PushbuttonParam(obj,'gen_frozen_stim',x,y,'position',[x y 150 20],...
		'label','Gen Frozen Stimuli',...
		'TooltipString','resample frozen stimuli');
  set_callback(gen_frozen_stim,{mfilename,'gen_frozen_stim'});
  PushbuttonParam(obj,'choose_todays_frozen',x,y,'position',[x+150 y 150 20],...
		'label','Choose Todays Frozen',...
		'TooltipString','choose frozen stimuli for todays queue');
  set_callback(choose_todays_frozen,{mfilename,'choose_todays_frozen'});
  PushbuttonParam(obj,'gen_frozen_queue',x,y,'position',[x+300 y 150 20],...
		'label','Gen Frozen Queue',...
		'TooltipString','reshuffle queue of todays frozen stimuli');
  set_callback(gen_frozen_queue,{mfilename,'gen_frozen_queue'});
  PushbuttonParam(obj,'choose_frozen_trials',x,y,'position',[x+450 y 150 20],...
		'label','Choose Frozen Trials',...
		'TooltipString','resample which trials will use frozen stimuli');
  set_callback(choose_frozen_trials,{mfilename,'choose_frozen_trials'});
  next_row(y);
  NumeditParam(obj,'FrozenGammasR',[.5 1.1 2 3.6],x,y,'position',[x y 200 20],...
    'TooltipString','gammas for frozen right-correct stimuli');
  R_gammas.value = value(FrozenGammasR);
  N.value = length(value(FrozenGammasR));
  NumeditParam(obj,'FrozenClickDiffsR',[10 20 30 38],x,y,'position',[x+200 y 200 20],...
    'TooltipString','click differences for frozen right-correct stimuli');
  NumeditParam(obj,'FrozenDurationsR',[.3 .5 .7 1],x,y,'position',[x+400 y 200 20],...
    'TooltipString','durations for frozen right-correct stimuli');
  next_row(y);
  NumeditParam(obj,'FrozenGammasL',[-.5 -1.1 -2 -3.6],x,y,'position',[x y 200 20],...
    'TooltipString','gammas for frozen left-correct stimuli');
  L_gammas.value = value(FrozenGammasL);
  NumeditParam(obj,'FrozenClickDiffsL',[-10 -20 -30 -38],x,y,'position',[x+200 y 200 20],...
    'TooltipString','click differences for frozen left-correct stimuli');
  NumeditParam(obj,'FrozenDurationsL',[.3 .5 .7 1],x,y,'position',[x+400 y 200 20],... % correct durations?
    'TooltipString','durations for frozen left-correct stimuli');
  next_row(y);
  DispParam(obj,'NFrozenGammasR',length(value(FrozenGammasR)),x,y,...
    'position',[x y 200 20],...
		'TooltipString','number frozen right gammas');
  DispParam(obj,'NFrozenClickDiffsR',length(value(FrozenClickDiffsR)),x,y,...
    'position',[x+200 y 200 20],...
		'TooltipString','number frozen right gammas');
  DispParam(obj,'NFrozenDurationsR',length(value(FrozenDurationsR)),x,y,...
    'position',[x+400 y 200 20],...
		'TooltipString','number frozen right durations');
  next_row(y);
  DispParam(obj,'NFrozenGammasL',length(value(FrozenGammasL)),x,y,...
    'position',[x y 200 20],...
		'TooltipString','number frozen left gammas');
  DispParam(obj,'NFrozenClickDiffsL',length(value(FrozenClickDiffsL)),x,y,...
    'position',[x+200 y 200 20],...
		'TooltipString','number frozen left click differences');
  DispParam(obj,'NFrozenDurationsL',length(value(FrozenDurationsL)),x,y,...
    'position',[x+400 y 200 20],...
		'TooltipString','number frozen left durations');
  next_row(y);
  NumeditParam(obj,'NFrozenStimPer',2,x,y,'position',[x y 150 20],...
    'labelfraction',.67,...
    'TooltipString','number stimuli per gamma/duration pair');
  DispParam(obj,'NFrozenStimL',...
    value(NFrozenGammasL)*value(NFrozenDurationsL)*value(NFrozenStimPer),...
    x,y,'position',[x+150 y 150 20],...
    'labelfraction',.67,...
    'TooltipString','number of left-correct frozen stimuli');
  DispParam(obj,'NFrozenStimR',...
    value(NFrozenGammasR)*value(NFrozenDurationsR)*value(NFrozenStimPer),...
    x,y,'position',[x+300 y 150 20],...
    'labelfraction',.67,...
    'TooltipString','number of right-correct frozen stimuli');
  DispParam(obj,'NFrozenStimTot',...
    value(NFrozenStimR)+value(NFrozenStimL),...
    x,y,'position',[x+450 y 150 20],...
    'labelfraction',.67,...
    'TooltipString','total number of frozen stimuli');
  next_row(y);
  NumeditParam(obj,'FracFrozenTrials',.5,x,y,'position',[x y 200 20],...
    'TooltipString','fraction trials using frozen stimuli');
  NumeditParam(obj,'NFrozenLPerDay',round(.5*value(NFrozenStimL)),x,y,'position',[x+200 y 200 20],...
    'TooltipString','number of frozen left-correct stimuli used each day');
  NumeditParam(obj,'NFrozenRPerDay',round(.5*value(NFrozenStimR)),x,y,'position',[x+400 y 200 20],...
    'TooltipString','number of frozen right-correct stimuli used each day');
  next_row(y);
  NumeditParam(obj,'LenFrozenQueue',500,x,y,'position',[x y 200 20],...
    'TooltipString','length of frozen stimuli queue');
  NumeditParam(obj,'LenQueueShuffle',10,x,y,'position',[x+200 y 200 20],...
    'TooltipString','number of next frozen stimuli shuffled on violation');
  NumeditParam(obj,'LenIsFrozenTrial',...
    round(value(LenFrozenQueue)/value(FracFrozenTrials)),...
    x,y,'position',[x+400 y 200 20],...
    'TooltipString','length of frozen stimuli queue');
  % initialize IsFrozenTrial
  SoloParamHandle(obj,'IsFrozenTrial',...
      'value',(rand(value(LenIsFrozenTrial),1)<value(FracFrozenTrials))*1);
  push_history(IsFrozenTrial);
  next_row(y);
  NumeditParam(obj,'ClickDiffLeeway',100,x,y,'position',[x y 200 20],...
    'TooltipString','allowable gap between specified and actual click diff');
  NumeditParam(obj,'ClickTotalLeeway',100,x,y,'position',[x+200 y 200 20],...
    'TooltipString','allowable gap between specified and actual click total');
  next_row(y);
  DispParam(obj,'QueuePosL',0,x,y,...
    'position',[x y 150 20],...
    'labelfraction',.67,...
		'TooltipString','number frozen right gammas');
  DispParam(obj,'QueuePosR',0,x,y,...
    'position',[x+150 y 150 20],...
    'labelfraction',.67,...
		'TooltipString','number frozen right gammas');
  DispParam(obj,'ThisTrialFrozen',1*value(IsFrozenTrial(1)),x,y,...
    'position',[x+300 y 150 20],...
    'labelfraction',.67,...
		'TooltipString','number frozen right gammas');  
  DispParam(obj,'ThisSide','N/A',x,y,...
    'position',[x+450 y 150 20],...
    'labelfraction',.67,...
		'TooltipString','number frozen right gammas');
  next_row(y);
  SubheaderParam(obj,'title4','Frozen Stimuli Section',x,y);
	next_row(y,1.5);
  % other frozen init stuff
  feval(mfilename,obj,'choose_frozen_trials');
  feval(mfilename,obj,'choose_todays_frozen');
  feval(mfilename,obj,'gen_frozen_queue');
  right_gammas.value = value(FrozenGammasR);
  left_gammas.value = value(FrozenGammasL);
  SoloParamHandle(obj,'FrozenLsnd','value',1,'save_with_settings',1);
  SoloParamHandle(obj,'FrozenRsnd','value',1,'save_with_settings',1);
  SoloParamHandle(obj,'FrozenLlrate','value',1,'save_with_settings',1);
  SoloParamHandle(obj,'FrozenRlrate','value',1,'save_with_settings',1);
  SoloParamHandle(obj,'FrozenLrrate','value',1,'save_with_settings',1);
  SoloParamHandle(obj,'FrozenRrrate','value',1,'save_with_settings',1);
  SoloParamHandle(obj,'FrozenLdata','value',1,'save_with_settings',1);
  SoloParamHandle(obj,'FrozenRdata','value',1,'save_with_settings',1);
  % The number of trials per frozen stimulus in d days is:
  %     N = (FracFrozenTrials*T*d)/NFrozenStimTot,
  % where T is the number of trials per day (~150), or:
  %     N = 75*d/NFrozenStimTot.
  % In terms of days:
  %     d = (NFrozenStimTot*N)/150.

  % the rest
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

  % this soloparamhandle stores the specification of the stimulator wave
  % fields are: .ison, .channel, .pre, and .dur
  specs.ison = 0;
  specs.channel = 0;
  specs.pre = 0;
  specs.dur = 1;
  specs.trigger = '';
  SoloParamHandle(obj, 'StimulatorSpecs', 'value', specs);
  SoloParamHandle(obj, 'MaskSpecs',       'value', specs);
    
	
	% stores the set of gamma values used to make pbups from
	% trial to trial.  
	% these values may be specified either by range or by enumeration
	SoloParamHandle(obj, 'left_gammas', 'value', -2);
	SoloParamHandle(obj, 'right_gammas', 'value', 2);
  
  % the line below is incompatible with frozen stimuli so i've gotten rid
  % of it, though perhaps in a future version, a frozen toggle could be
  % added so that it should be included in that case
  % feval(mfilename,obj,'gamma_style');
  feval(mfilename, obj, 'show_hide');   
  feval(mfilename, obj, 'check_stim_channels');
  feval(mfilename, obj, 'check_mask_channels');
    
  figure(fig);
  x = origfig_xy(1); y = origfig_xy(2);
      
%% gen_frozen_stim
  case 'gen_frozen_stim'
    
    disp('Generating frozen stimuli.')
    
    % initialize
    clear FrozenLsnd FrozenRsnd FrozenLlrate FrozenRlrate;
    clear FrozenLrrate FrozenRrrate FrozenLdata FrozenRdata;
    SoloParamHandle(obj,'FrozenLsnd',...
      'value',cell(value(NFrozenGammasL),value(NFrozenDurationsL),value(NFrozenStimPer)),...
      'save_with_settings',1);
    SoloParamHandle(obj,'FrozenRsnd',...
      'value',cell(value(NFrozenGammasR),value(NFrozenDurationsR),value(NFrozenStimPer)),...
      'save_with_settings',1);
    SoloParamHandle(obj,'FrozenLlrate',...
      'value',zeros(value(NFrozenGammasL),value(NFrozenDurationsL),value(NFrozenStimPer)),...
      'save_with_settings',1);
    SoloParamHandle(obj,'FrozenRlrate',...
      'value',zeros(value(NFrozenGammasR),value(NFrozenDurationsR),value(NFrozenStimPer)),...
      'save_with_settings',1);
    SoloParamHandle(obj,'FrozenLrrate',...
      'value',zeros(value(NFrozenGammasL),value(NFrozenDurationsL),value(NFrozenStimPer)),...
      'save_with_settings',1);
    SoloParamHandle(obj,'FrozenRrrate',...
      'value',zeros(value(NFrozenGammasR),value(NFrozenDurationsR),value(NFrozenStimPer)),...
      'save_with_settings',1);
    SoloParamHandle(obj,'FrozenLdata',...
      'value',cell(value(NFrozenGammasL),value(NFrozenDurationsL),value(NFrozenStimPer)),...
      'save_with_settings',1);
    SoloParamHandle(obj,'FrozenRdata',...
      'value',cell(value(NFrozenGammasR),value(NFrozenDurationsR),value(NFrozenStimPer)),...
      'save_with_settings',1);

    % generate left-correct stimuli
    srate = SoundManagerSection(obj,'get_sample_rate');
    lgs = value(FrozenGammasL);
    lds = value(FrozenDurationsL);
    c = 1;
    for g = 1:value(NFrozenGammasL)
     for t = 1:value(NFrozenDurationsL)
       for n = 1:value(NFrozenStimPer)
         [snd lrate rrate data] = make_pbup(...
           value(total_rate),lgs(g),srate,lds(t),...
           'bup_width',value(bup_width),'first_bup_stereo',value(first_bup_stereo),...
           'crosstalk',value(crosstalk),'base_freq',value(base_freq),...
           'ntones',value(ntones),'bup_ramp',value(bup_ramp)); %#ok<NODEF>
         Nleft = length(value(data.left));
         Nright = length(value(data.right));
         diff = Nright-Nleft;
         tot = Nright+Nleft;
         expdiff = round(value(FrozenClickDiffsL(g))*value(FrozenDurationsL(t)));
         exptot = round(value(total_rate)*value(FrozenDurationsL(t)));
         % ensure that click total and difference are correct
         clicktotal_flag = abs(tot-exptot)>value(ClickTotalLeeway);
         clickdiff_flag = abs(diff-expdiff)>value(ClickDiffLeeway);
         while clicktotal_flag||clickdiff_flag
           [snd lrate rrate data] = make_pbup(...
             value(total_rate),lgs(g),srate,lds(t),...
             'bup_width',value(bup_width),'first_bup_stereo',value(first_bup_stereo),...
             'crosstalk',value(crosstalk),'base_freq',value(base_freq),...
             'ntones',value(ntones),'bup_ramp',value(bup_ramp)); %#ok<NODEF>
           Nleft = length(value(data.left));
           Nright = length(value(data.right));
           diff = Nright-Nleft;
           tot = Nright+Nleft;
           clicktotal_flag = abs(tot-exptot)>value(ClickTotalLeeway);
           clickdiff_flag = abs(diff-expdiff)>value(ClickDiffLeeway);
           disp(sprintf('abs(%i-%i) = %i ?> %i [abs(tot-exptot) = error ?> leeway]',...
             tot,exptot,abs(tot-exptot),value(ClickTotalLeeway)))
           disp(sprintf('abs(%i-%i) = %i ?> %i [abs(diff-expdiff) = error ?> leeway]',...
             diff,expdiff,abs(diff-expdiff),value(ClickDiffLeeway)))
         end
         clear Nleft Nright diff tot clicktotal_flag clickdiff_flag;
         tmp = value(FrozenLsnd); tmp{g,t,n} = snd; FrozenLsnd.value = tmp; clear tmp;
         tmp = value(FrozenLlrate); tmp(g,t,n) = lrate; FrozenLlrate.value = tmp; clear tmp;
         tmp = value(FrozenLrrate); tmp(g,t,n) = rrate; FrozenLrrate.value = tmp; clear tmp;
         tmp = value(FrozenLdata); tmp{g,t,n} = data; FrozenLdata.value = tmp; clear tmp;
         clear snd lrate rrate data;
         c = c+1;
         disp(sprintf('Generated %i of %i left-correct stimuli.',c,value(NFrozenStimL)))
       end
       clear n;
     end
     clear t;
    end
    clear g lgs lds c;
    
    % generate left-correct stimuli
    srate = SoundManagerSection(obj,'get_sample_rate');
    rgs = value(FrozenGammasR);
    rds = value(FrozenDurationsR);
    c = 0;
    for g = 1:value(NFrozenGammasR)
     for t = 1:value(NFrozenDurationsR)
       for n = 1:value(NFrozenStimPer)
         [snd lrate rrate data] = make_pbup(...
           value(total_rate),rgs(g),srate,rds(t),...
           'bup_width',value(bup_width),'first_bup_stereo',value(first_bup_stereo),...
           'crosstalk',value(crosstalk),'base_freq',value(base_freq),...
           'ntones',value(ntones),'bup_ramp',value(bup_ramp)); %#ok<NODEF>
         Nleft = length(value(data.left));
         Nright = length(value(data.right));
         diff = Nright-Nleft;
         tot = Nright+Nleft;
         expdiff = round(value(FrozenClickDiffsR(g))*value(FrozenDurationsR(t)));
         exptot = round(value(total_rate)*value(FrozenDurationsR(t)));
         % ensure that click total and difference are correct
         clicktotal_flag = abs(tot-exptot)>value(ClickTotalLeeway);
         clickdiff_flag = abs(diff-expdiff)>value(ClickDiffLeeway);
         while clicktotal_flag||clickdiff_flag
           [snd lrate rrate data] = make_pbup(...
             value(total_rate),rgs(g),srate,rds(t),...
             'bup_width',value(bup_width),'first_bup_stereo',value(first_bup_stereo),...
             'crosstalk',value(crosstalk),'base_freq',value(base_freq),...
             'ntones',value(ntones),'bup_ramp',value(bup_ramp)); %#ok<NODEF>
           Nleft = length(value(data.left));
           Nright = length(value(data.right));
           diff = Nright-Nleft;
           tot = Nright+Nleft;
           clicktotal_flag = abs(tot-exptot)>value(ClickTotalLeeway);
           clickdiff_flag = abs(diff-expdiff)>value(ClickDiffLeeway);
           disp(sprintf('abs(%i-%i) = %i ?> %i [abs(tot-exptot) = error ?> leeway]',...
             tot,exptot,abs(tot-exptot),value(ClickTotalLeeway)))
           disp(sprintf('abs(%i-%i) = %i ?> %i [abs(diff-expdiff) = error ?> leeway]',...
             diff,expdiff,abs(diff-expdiff),value(ClickDiffLeeway)))
         end
         clear Nleft Nright diff tot clicktotal_flag clickdiff_flag;
         tmp = value(FrozenRsnd); tmp{g,t,n} = snd; FrozenRsnd.value = tmp; clear tmp;
         tmp = value(FrozenRlrate); tmp(g,t,n) = lrate; FrozenRlrate.value = tmp; clear tmp;
         tmp = value(FrozenRrrate); tmp(g,t,n) = rrate; FrozenRrrate.value = tmp; clear tmp;
         tmp = value(FrozenRdata); tmp{g,t,n} = data; FrozenRdata.value = tmp; clear tmp;
         clear snd lrate rrate data;
         c = c+1;
         disp(sprintf('Generated %i of %i right-correct stimuli.',c,value(NFrozenStimR)))
       end
       clear n;
     end
     clear t;
    end
    clear g rgs rds c;
    
    % save
    push_history(FrozenLsnd); push_history(FrozenRsnd);
    push_history(FrozenLlrate); push_history(FrozenRlrate);
    push_history(FrozenLrrate); push_history(FrozenRrrate);
    push_history(FrozenLdata); push_history(FrozenRdata);
    disp('Generated frozen stimuli.')
    
    return;
    
%% gen_frozen_queue
  case 'gen_frozen_queue'
    
    % NOTE: indices are 1:NFrozenL/RPerDay and so need to be combined with
    % TodaysFrozen in order to refer to data structure containing stimuli
    
    % initialize
    SoloParamHandle(obj,'FrozenQueueL','value',zeros(value(LenFrozenQueue),1));
    if value(LenFrozenQueue)<value(NFrozenLPerDay)
      error('Queue shorted than number of left-correct stimuli used per day!')
    end
    SoloParamHandle(obj,'FrozenQueueR','value',zeros(value(LenFrozenQueue),1));
    if value(LenFrozenQueue)<value(NFrozenRPerDay)
      error('Queue shorted than number of right-correct stimuli used per day!')
    end
    
    % generate left-correct queue
    Nadded = 0;
    q = zeros(value(LenFrozenQueue),1);
    while (Nadded+value(NFrozenLPerDay))<value(LenFrozenQueue) % while next permutation won't fill queue
      q(Nadded+1:Nadded+value(NFrozenLPerDay)) = randperm(value(NFrozenLPerDay))';
      Nadded = Nadded + value(NFrozenLPerDay);
    end
    Ntoadd = value(LenFrozenQueue)-Nadded;
    q(Nadded+1:Nadded+Ntoadd) = randperm(Ntoadd)'; clear Nadded Ntoadd;
    FrozenQueueL.value = q; clear q;
    
    % generate right-correct queue
    Nadded = 0;
    q = zeros(value(LenFrozenQueue),1);
    while (Nadded+value(NFrozenRPerDay))<value(LenFrozenQueue) % while next permutation won't fill queue
      q(Nadded+1:Nadded+value(NFrozenRPerDay)) = randperm(value(NFrozenRPerDay))';
      Nadded = Nadded + value(NFrozenRPerDay);
    end
    Ntoadd = value(LenFrozenQueue)-Nadded;
    q(Nadded+1:Nadded+Ntoadd) = randperm(Ntoadd)'; clear Nadded Ntoadd;
    FrozenQueueR.value = q; clear q;
    
    % save
    push_history(FrozenQueueL);
    push_history(FrozenQueueR);
    disp('Generated frozen queues.')
    
%% choose_todays_frozen
  case 'choose_todays_frozen'
    
    % initialization
    SoloParamHandle(obj,'TodaysFrozenL','value',zeros(value(NFrozenLPerDay),3));
        % contains the gamma/duration/nstim indices for todays frozen stim
    if value(NFrozenLPerDay)>value(NFrozenStimL)
      error('Number of stimuli used per day larger than total number of left-correct stimuli!')
    end
    SoloParamHandle(obj,'TodaysFrozenR','value',zeros(value(NFrozenRPerDay),3));
    if value(NFrozenRPerDay)>value(NFrozenStimR)
      error('Number of stimuli used per day larger than total number of right-correct stimuli!')
    end
    
    % choose indices for left-correct stimuli
    perm = randperm(value(NFrozenStimL));
    perm = perm(1:value(NFrozenLPerDay));
    allindices = cell(value(NFrozenGammasL),value(NFrozenDurationsL),value(NFrozenStimPer));
    for g = 1:value(NFrozenGammasL)
      for t = 1:value(NFrozenDurationsL)
        for n = 1:value(NFrozenStimPer)
          allindices{g,t,n} = [g,t,n];
        end
        clear n;
      end
      clear t;
    end
    clear g;
    allindices = allindices(:);
    indices = zeros(value(NFrozenLPerDay),3);
    for n = 1:length(perm)
      p = perm(n);
      indices(n,:) = allindices{p};
    end
    clear n;
    TodaysFrozenL.value = indices;
    clear allindices indices;
    
    % choose indices for right-correct stimuli
    perm = randperm(value(NFrozenStimR));
    perm = perm(1:value(NFrozenRPerDay));
    allindices = cell(value(NFrozenGammasR),value(NFrozenDurationsR),value(NFrozenStimPer));
    for g = 1:value(NFrozenGammasR)
      for t = 1:value(NFrozenDurationsR)
        for n = 1:value(NFrozenStimPer)
          allindices{g,t,n} = [g,t,n];
        end
        clear n;
      end
      clear t;
    end
    clear g;
    allindices = allindices(:);
    indices = zeros(value(NFrozenRPerDay),3);
    for n = 1:length(perm)
      p = perm(n);
      indices(n,:) = allindices{p};
    end
    clear n;
    TodaysFrozenR.value = indices;
    clear allindices indices;
    
    % save
    push_history(TodaysFrozenL);
    push_history(TodaysFrozenR);
    disp('Chose todays frozen stimuli.')

%% print_click_times
  case 'print_click_times'
    indices = value(IndicesStimToPrint);
    g = indices(2);
    t = indices(3);
    n = indices(4);
    if indices(1)==1
      data = value(FrozenLdata{g,t,n});
      s = 'left';
      gam = FrozenGammasL(g);
      dur = FrozenDurationsL(t);
    elseif indices(1)==2
      data = value(FrozenRdata{g,t,n});
      s = 'right';
      gam = FrozenGammasR(g);
      dur = FrozenDurationsR(t);
    else
      error('First index (L/R) must be 1 or 2!')
    end
    disp('indices')
    disp(indices)
    disp('meaning')
    disp('    L/R, gamma, duration, index')
    disp('value')
    disp(['    ',s,sprintf(', %g, %gs, index',gam,dur)])
    disp('left click times')
    disp(data.left)
    disp('right click times')
    disp(data.right)
    clear s gam dur data;
    return;
    
%% choose_frozen_trials
  case 'choose_frozen_trials'
    SoloParamHandle(obj,'IsFrozenTrial',...
      'value',(rand(value(LenIsFrozenTrial),1)<value(FracFrozenTrials))*1);
    % save
    push_history(IsFrozenTrial);
    disp('Chose frozen trials.')
    return;
    
%% end_of_day_stuff
  case 'eod_stuff'
%     FrozenQueueL.value = value(FrozenQueueL(1:value(QueuePosL)));
%     FrozenQueueR.value = value(FrozenQueueR(1:value(QueuePosR)));
%     IsFrozenTrial.value = value(IsFrozenTrial(1:n_trials_done));
    QueuePosL.value = 0;
    QueuePosR.value = 0;
    return;
    
%% package_frozen
  case 'package_frozen'
%     disp('called package_frozen')
    % stuff that is typically the same across rats
    x.FrozenGammasR = value(FrozenGammasR);
    x.FrozenClickDiffsR = value(FrozenClickDiffsR);
    x.FrozenDurationsR = value(FrozenDurationsR);
    x.FrozenGammasL = value(FrozenGammasL);
    x.FrozenClickDiffsL = value(FrozenClickDiffsL);
    x.FrozenDurationsL = value(FrozenDurationsL);
    x.NFrozenStimPer = value(NFrozenStimPer);
    x.FracFrozenTrials = value(FracFrozenTrials);
    x.FrozenLsnd = value(FrozenLsnd);
    x.FrozenLlrate = value(FrozenLlrate);
    x.FrozenLrrate = value(FrozenLrrate);
    x.FrozenLdata = value(FrozenLdata);
    x.FrozenRsnd = value(FrozenRsnd);
    x.FrozenRlrate = value(FrozenRlrate);
    x.FrozenRrrate = value(FrozenRrrate);
    x.FrozenRdata = value(FrozenRdata);
%     disp('processed first section')

    % intermediate stuff that won't be saved
    s = SidesSection(obj,'get_previous_sides_and_sounds');
    Lmask = (s=='l'); Rmask = ~Lmask;
    n = min(length(Lmask),length(value(IsFrozenTrial)));
    tmp = value(IsFrozenTrial);
    NFrozenL = sum(Lmask(1:n).*tmp(1:n));
    NFrozenR = sum(Rmask(1:n).*tmp(1:n)); clear tmp;
%     disp('processed second section')

    % stuff that is different for each rat and each day
    tmp = value(FrozenQueueL); x.FrozenQueueL = tmp(1:NFrozenL); clear tmp;
    tmp = value(FrozenQueueR); x.FrozenQueueR = tmp(1:NFrozenR); clear tmp;
%     disp('1')
    tmp = value(IsFrozenTrial); x.IsFrozenTrial = tmp(1:n); clear tmp;
%     disp('2')
    x.TodaysFrozenL = value(TodaysFrozenL);
    x.TodaysFrozenR = value(TodaysFrozenR);
%     disp('3')
    x.FrozenTrialData = zeros(n,5); % Frozen?/R?/FrozenIndicesORzeros
    x.FrozenTrialData(:,1) = x.IsFrozenTrial(1:n);
%     disp('4')
    x.FrozenTrialData(:,2) = Rmask(1:n); clear Lmask Rmask;
%     disp('5')
    l = 0;
    r = 0;
%     disp('got to the loop')
    for i = 1:n
      if x.IsFrozenTrial(i)
        if s(i)=='l'
          l = l+1;
          x.FrozenTrialData(i,3:5) = x.TodaysFrozenL(x.FrozenQueueL(l),:);
        else
          r = r+1;
          x.FrozenTrialData(i,3:5) = x.TodaysFrozenR(x.FrozenQueueR(r),:);
        end
      else
        x.FrozenTrialData(i,3:5) = [0 0 0];
      end
    end
    clear i;
%     disp('processed third section')
    if l~=NFrozenL
      disp('final index l and NFrozenL dont match!')
    elseif r~=NFrozenR
      disp('final index r and NFrozenR dont match!')
    end
    clear l r NFrozenL NFrozenR;
    
    return;

%% get_bup_times  
  case 'get_bup_times',
    x = value(ThisBupTimes); %#ok<NODEF>
    return;
    
%% get_all_bup_times
  case 'get_all_bup_times'
    x = get_history(ThisBupTimes); %#ok<NODEF>
    return;
      
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
	  
	  LocalPrevSides.value  = varargin{2};
	  LocalPrevSounds.value = varargin{3};
	  
	  feval(mfilename, obj, 'normalize_pprobs');
	  feval(mfilename, obj, 'T_resample');
	  feval(mfilename, obj, 'update_hitfrac');
	  feval(mfilename, obj, 'update_biashitfrac');
    feval(mfilename, obj, 'pick_stimulator');
	  feval(mfilename, obj, 'pick_mask');
    
    ThisSide.value = value(side);
    % if the last trial was frozen and there was a violation...
    if n_started_trials>0
      if (value(IsFrozenTrial(n_started_trials))==1)...
          &&(violation_history(n_started_trials)==1)
        % ...bump and shuffle the appropriate queue
        if (value(LocalPrevSides(end-1))=='l')
          FrozenQueueL.value =...
            [value(FrozenQueueL(1:n_started_trials));...
            value(FrozenQueueL(n_started_trials:end))];
          shuffle = randperm(value(LenQueueShuffle));
          while shuffle(1)==1 % reshuffle if next stim is the same
            shuffle = randperm(value(LenQueueShuffle));
          end
          tmp = value(FrozenQueueL);
          tmp2 = tmp(shuffle+n_started_trials);
          tmp(n_started_trials+1:n_started_trials+value(LenQueueShuffle)) = tmp2;
          FrozenQueueL.value = tmp; clear tmp tmp2;
          push_history(FrozenQueueL);
        elseif (value(LocalPrevSides(end-1))=='r')
          FrozenQueueR.value =...
            [value(FrozenQueueR(1:n_started_trials));...
            value(FrozenQueueR(n_started_trials:end))];
          shuffle = randperm(value(LenQueueShuffle));
          while shuffle(1)==1 % reshuffle if next stim is the same
            shuffle = randperm(value(LenQueueShuffle));
          end
          tmp = value(FrozenQueueR);
          tmp2 = tmp(shuffle+n_started_trials);
          tmp(n_started_trials+1:n_started_trials+value(LenQueueShuffle)) = tmp2;
          FrozenQueueR.value = tmp; clear tmp tmp2;
          push_history(FrozenQueueR);
        end
      end

      % extend frozen trial indicator if necessary
      if length(value(IsFrozenTrial))<(n_started_trials+1)
        tmp = value(IsFrozenTrial);
        tmp(n_started_trials+1) = (rand<value(FracFrozenTrials))*1;
        IsFrozenTrial.value = tmp; clear tmp;
        push_history(IsFrozenTrial);
      end
      ThisTrialFrozen.value = value(IsFrozenTrial(n_started_trials));
    end
    
    % if frozen trial...
    if value(IsFrozenTrial(n_started_trials+1))==1
      if side == 'l'
        % update queue position
        QueuePosL.value = value(QueuePosL)+1;
        push_history(QueuePosL);
        % set indices
        g = value(TodaysFrozenL(value(FrozenQueueL(value(QueuePosL))),1));
        t = value(TodaysFrozenL(value(FrozenQueueL(value(QueuePosL))),2));
        % set param
        ThisGamma.value = value(FrozenGammasL(g));
        x = -g; % x is index of gamma
        y = value(FrozenDurationsL(t)); % y is current duration
      elseif side == 'r'
        % update queue position
        QueuePosR.value = value(QueuePosR)+1;
        push_history(QueuePosR);
        % set indices
        g = value(TodaysFrozenR(value(FrozenQueueR(value(QueuePosR))),1));
        t = value(TodaysFrozenR(value(FrozenQueueR(value(QueuePosR))),2));
        % set param
        ThisGamma.value = value(FrozenGammasR(g));
        x = g; % x is index of gamma
        y = value(FrozenDurationsR(t)); % y is current duration
      end
    % ...else if random trial
    else
      if side == 'l',
        x = find(cumsum(LtPostProb(:)) > rand(1)/2, 1, 'first');
        if isempty(x), x = 1; end; % a catch so things don't break
        ThisGamma.value = left_gammas(x);
        x = -x;
      elseif side == 'r',
        x = find(cumsum(RtPostProb(:)) > rand(1)/2, 1, 'first');
        if isempty(x), x = 1; end; % a catch so things don't break
        ThisGamma.value = right_gammas(x);
      end
      y = value(T);
    end

    feval(mfilename, obj, 'make_this_sound');
	  feval(mfilename, obj, 'push_history');
      
%% push_history
  case 'push_history'
	  push_history(ThisBupTimes);
    push_history(StimulatorSpecs);
    push_history(MaskSpecs);

%% count_this_bups
  case 'count_last_trial_bups'
	  sample_duration = varargin{1};
	  
	  x = time;
	  y = observer;

%% make_sounds
  case 'make_this_sound',
	srate = SoundManagerSection(obj, 'get_sample_rate');
  % if this trial is not frozen
  if value(IsFrozenTrial(n_started_trials+1))==0
    % the sound made is at least 1 sec long, or as long as T
    [snd lrate rrate data] = make_pbup(value(total_rate), value(ThisGamma), srate, max(1,value(T)), ...
                       'bup_width', value(bup_width), 'first_bup_stereo', value(first_bup_stereo), ...
                       'crosstalk', value(crosstalk), 'base_freq', value(base_freq), ...
                                         'ntones', value(ntones), 'bup_ramp', value(bup_ramp)); %#ok<NODEF>
  % if this trial is frozen
  else
    if value(ThisSide) == 'l'
      % set indices
      g = value(TodaysFrozenL(value(FrozenQueueL(value(QueuePosL))),1));
      t = value(TodaysFrozenL(value(FrozenQueueL(value(QueuePosL))),2));
      n = value(TodaysFrozenL(value(FrozenQueueL(value(QueuePosL))),3));
      % set param
      snd = value(FrozenLsnd{g,t,n});
      lrate = value(FrozenLlrate(g,t,n));
      rrate = value(FrozenLrrate(g,t,n));
      data = value(FrozenLdata{g,t,n});
    elseif value(ThisSide) == 'r'
      % set indices
      g = value(TodaysFrozenR(value(FrozenQueueR(value(QueuePosR))),1));
      t = value(TodaysFrozenR(value(FrozenQueueR(value(QueuePosR))),2));
      n = value(TodaysFrozenR(value(FrozenQueueR(value(QueuePosR))),3));
      % set param
      snd = value(FrozenRsnd{g,t,n});
      lrate = value(FrozenRlrate(g,t,n));
      rrate = value(FrozenRrrate(g,t,n));
      data = value(FrozenRdata{g,t,n});
    end
  end
	
  if numel(value(vol)) == 1,
      snd = snd*vol(1);
  else
      snd(1,:) = snd(1,:) * vol(1);
      snd(2,:) = snd(2,:) * vol(2);
  end;

	if ~SoundManagerSection(obj, 'sound_exists', 'PBupsSound'),
		SoundManagerSection(obj, 'declare_new_sound', 'PBupsSound');
		SoundManagerSection(obj, 'set_sound', 'PBupsSound', snd);
	else
		snd_prev = SoundManagerSection(obj, 'get_sound', 'PBupsSound');
		if ~isequal(snd, snd_prev),
			SoundManagerSection(obj, 'set_sound', 'PBupsSound', snd);
		end;
	end;

	ThisLeftRate.value = lrate;
	ThisRightRate.value = rrate;

	bpt.gamma = value(ThisGamma);
	bpt.left = data.left;
	bpt.right = data.right;
	ThisBupTimes.value = bpt;

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
	  
        
%% test_gamma
  case 'test_gamma'
	srate = SoundManagerSection(obj, 'get_sample_rate');
    [snd lrate rrate] = make_pbup(value(total_rate), value(test_gamma), srate, value(sduration), ...
                     'bup_width', value(bup_width), 'first_bup_stereo', value(first_bup_stereo), ...
                     'crosstalk', value(crosstalk), 'base_freq', value(base_freq), ...
                     'ntones', value(ntones), 'bup_ramp', value(bup_ramp), 'generate_sound', 0);
		
	test_lrate.value = lrate;
	test_rrate.value = rrate;
	
%% test_play
  case 'test_play',
    srate = SoundManagerSection(obj, 'get_sample_rate');
    [snd] = make_pbup(value(total_rate), value(test_gamma), srate, value(sduration), ...
                     'bup_width', value(bup_width), 'first_bup_stereo', value(first_bup_stereo), ...
                     'crosstalk', value(crosstalk), 'base_freq', value(base_freq), ...
                     'ntones', value(ntones), 'bup_ramp', value(bup_ramp)); 
    
    if numel(value(vol)) == 1,
        snd = snd*vol(1);
    else
        snd(1,:) = snd(1,:) * vol(1);
        snd(2,:) = snd(2,:) * vol(2);
    end;
    
    if ~SoundManagerSection(obj, 'sound_exists', 'TestSound'),
      SoundManagerSection(obj, 'declare_new_sound', 'TestSound');
    end;

    SoundManagerSection(obj, 'set_sound', 'TestSound', snd);
    
    SoundManagerSection(obj, 'play_sound', 'TestSound');
      
      
%% stop_sound      
  case 'test_stop',
      
    SoundManagerSection(obj, 'stop_sound', 'TestSound');
    
%% T_resample
  case 'T_resample'
	if p_probe > 1, p_probe.value = 1; end;
	if p_probe < 0, p_probe.value = 0; end;
	if T_probe < 0, T_probe.value = 0; p_probe.value = 0; end;
	if T_max < T_min, T_max.value = T_min(1); end;
	
	if rand(1) < p_probe,
		T.value = value(T_probe);
	else
		T.value = value(T_min)+rand(1)*(T_max-T_min);
	end;
	
%% normalize_pprobs
  case 'normalize_pprobs',
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
    
%% check_stim_channels
  case 'check_stim_channels'
    
      % HACK ALERT: right now we'll accomodate only a single stim channel,
      % the 'LASER' channel
      channel = bSettings('get', 'DIOLINES', 'LASER');
      if isnan(channel),
          stimulator_frac.value = 0;
          disable(stimulator_frac);
          disable(stim_pre);
          disable(stim_dur);
      end;
      
%% check_mask_channels
  case 'check_mask_channels'
    
      % HACK ALERT: right now we'll accomodate only a single mask channel,
      % the 'MASK' channel
      channel = bSettings('get', 'DIOLINES', 'MASK');
      if isnan(channel),
          mask_frac.value = 0;
          disable(mask_frac);
          disable(mask_pre);
          disable(mask_dur);
      end;      
      
%% update_stim
  case 'update_stim'
      
      % enforces that the correct number of entries are in stim_channel,
      % stimulator_frac, stim_pre, and stim_dur
      n = numel(value(stimulator_frac));

      stim_channel.value = ones(1, n);
      
      if numel(value(stim_pre)) < n,
          s = value(stim_pre);
          stim_pre.value = [s s(end)*ones(1,n-numel(s))];
      end;
      
      if numel(value(stim_dur)) < n,
          s = value(stim_dur);
          stim_dur.value = [s s(end)*ones(1,n-numel(s))];
      end;
      
      if numel(stim_trigger_state) < n,
          s = value(stim_trigger_state);
          stim_trigger_state.value = [s s(end)*ones(1,n-numel(s))];
      end;
      
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
      
      StimulatorSpecs.ison = 0;
      StimulatorSpecs.channel = 0;
      StimulatorSpecs.pre = 0;
      StimulatorSpecs.dur = 0;
      StimulatorSpecs.trigger = '';
      
      if n_done_trials == 0 || value(ThisStim) > 0,
          % don't stimulate on the first trial of the session, or if the
          % previous trial was a stimulated trial
          mystim = 0;
      elseif sum(value(stimulator_frac)) < eps,
          mystim = 0;
      else
          mystim = find(rand(1) < cumsum(value(stimulator_frac)), 1, 'first');
          if isempty(mystim), mystim = 0; end;
          
          if value(stimulator_style) == 1 && value(T) ~= value(T_probe), 
              % if we're only stimulating on probe trials, and this is not
              % a probe trial,
              mystim = 0;
          end;
          
          valid_states = {'cpoke1', 'wait_for_spoke'};
          
          if mystim > 0, 
            StimulatorSpecs.channel = stim_channel(mystim);
            StimulatorSpecs.pre     = stim_pre(mystim);
            StimulatorSpecs.dur     = stim_dur(mystim);
            StimulatorSpecs.trigger = valid_states{stim_trigger_state(mystim)};
          end;
      end;
      
      ThisStim.value = mystim;
      StimulatorSpecs.ison = mystim;

%% mask
  case 'pick_mask'
      % determine if the next trial will be accompanied by a mask DIOLINE 
      
      MaskSpecs.ison = 0;
      MaskSpecs.channel = 0;
      MaskSpecs.pre = 0;
      MaskSpecs.dur = 0;
      MaskSpecs.trigger = '';
       
      mymask = find(rand(1) < cumsum(value(mask_frac)), 1, 'first');
      if isempty(mymask), mymask = 0; end;

      if value(mask_style) == 1 && value(T) ~= value(T_probe), 
          % if we're only masking on probe trials, and this is not a probe trial,
          mymask = 0;
      end;

      valid_states = {'cpoke1', 'wait_for_spoke'};

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