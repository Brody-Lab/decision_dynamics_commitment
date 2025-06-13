% [x, y] = TBupsSection(obj, action, tname, varargin)
%
% This plugin makes a window that manages the making of Poisson bups, which
% are bups that occur as independent Poisson processes on the left and
% right.
%
% Note: TBupsSection not only controls the generation of the poisson clicks
% trains but it also controls the laser stimulation, and thus incorporates
% all the functionality of StimulatorSection which is therefore not used in the TBups
% protocol.
%
% PARAMETERS:
% -----------
%
% obj      Default object argument..
%
% action   One of:
%
%   'init'     Initializes the plugin. Sets up internal variables
%               and the GUI window.
%
% Wynne, Jan 2025 

function [x, y] = TBupsSection(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action
    
%% init    
  case 'init'
    if length(varargin) < 2
      error('Need at least two arguments, x and y position, to initialize %s', mfilename);
    end
    x = varargin{1}; y = varargin{2};

    SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);
    
    SoloParamHandle(obj, 'ThisSeed', 'value', 0);   
    SoloParamHandle(obj, 'Bups', 'value', {});
    
    ToggleParam(obj, 'tbup_show', 0, x, y, ...
       'OnString', 'TBup window Showing', ...
       'OffString', 'TBup window Hidden', ...
       'TooltipString', 'Show/Hide TBup window'); next_row(y);
    set_callback(tbup_show, {mfilename, 'show_hide';});  %#ok<NODEF>
    
    screen_size = get(0, 'ScreenSize'); fig = double(gcf);
    SoloParamHandle(obj, 'tbup_fig', ...
        'value', double(figure('Position', [200 50 700 400], ...
        'closerequestfcn', [mfilename '(' class(obj) ', ''hide''' ');'], 'MenuBar', 'none', ...
        'NumberTitle', 'off', 'Name', 'TBups')), 'saveable', 0);
    origfig_xy = [x y]; 
    
    x = 10;
    y=10;    
	
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
    % ONLY going to add nonprobe trials to the local history. probe trials are not used for antibias if reward style is set to endpoints
	SoloParamHandle(obj, 'LocalPrevSides',  'value', []);
	SoloParamHandle(obj, 'LocalPrevSounds', 'value', []);
	next_row(y, 4);
	SubheaderParam(obj, 'title2', 'Antibias Section', x, y);
	next_row(y, 1.3);

    ToggleParam(obj, 'reward_style', 1, x, y, 'position', [x y 200 20], ...
        'OffString', 'Reward all trials based on alpha thresh', ...
        'OnString',  'Reward only endpoints', ...
        'TooltipString', 'Set the reward to include all trials or only the endpoints');
    set_callback(reward_style, {mfilename, 'reward_style'});
    next_row(y);

	DispParam(obj, 'T', 0.5, x, y, 'position', [x y 100 20], ...
		'labelfraction', 0.3, ...
		'TooltipString', sprintf(['sample duration, is T_probe with probability p_probe, otherwise drawn between T_min and T_max uniformly'...
                           '\n Note that T controls the maximum sound duration in the RT version of the task!']));
	NumeditParam(obj, 'T_min', 0.2, x, y, 'position', [x+100 y 100 20], ...
		'TooltipString', 'the minimum sample duration');
	NumeditParam(obj, 'T_max', 1, x, y, 'position', [x+200 y 100 20], ...
		'TooltipString', 'the maximum sample duration');
	PushbuttonParam(obj, 'T_resample', x, y, 'position', [x+300 y 100 20], ...
		'label', 'Resample', ...
		'TooltipString', 'resample T, the sample duration');
	set_callback({T_min; T_max; T_resample;}, {mfilename, 'T_resample'}); %#ok<NODEF>

    NumeditParam(obj, 'post_T', 0.25, x, y, 'position', [x+400 y 100 20], ...
        'TooltipString', 'how much time (s) is added between stim train and go cue');

    MenuParam(obj, 'T_type', {'center','end','beginning'}, 1,x, y, 'position', [x+500 y 100 20], ...
                            'TooltipString', 'where in nic period click train goes if T train < nic')
%             MenuParam(obj, 'stim_type', {'Light Only', 'Sound Only', 'Light AND Sound'}, 2, x,y, ...
%                     'labelfraction', 0.3, ...
%                     'TooltipString', sprintf(['Controls what stimulus indicates correct side.' ...
%                                             '\nIf light only, no sounds and correct side LED turns on.'...
%                                             '\nIf sound only, only the sound train and no LED.'...
%                                             '\nIf light and sound, both.']))
	next_row(y);
    % *********************************************************************
    
    % STIMULUS PROPERTIES SPECIFICATION
    
    % *********************************************************************
    NumeditParam(obj, 'endpoint_alphas', [1 realmax], x, y, 'position', [x y 200 20], ...
        'labelfraction', 0.3, ...
        'TooltipString', ' 1/alpha should be between 0 and 1');

    NumeditParam(obj, 'probe_alphas', [100 10000], x, y, 'position', [x+200 y 200 20], ...
        'labelfraction', 0.3, ...
        'TooltipString', '1/alpha should be between 0 and 1, and the first value should be less than the second');
    NumeditParam(obj, 'probe_frac', 0.1, x, y, 'position', [x+400 y 100 20], ...
        'labelfraction', 0.3, ...
        'TooltipString', 'fraction of trials that are probe trials, i.e.have alpha values between the endpoint_alphas');
    next_row(y);

    NumeditParam(obj, 'l_pprobs', 0.5, x, y, 'position', [x y 100 20], ... %%need to figure out how to make this work for diff rew types
        'labelfraction', 0.3, ...
        'TooltipString', 'prior probability for L sounds');
	NumeditParam(obj, 'r_pprobs', 0.5, x, y, 'position', [x+100 y 100 20], ...
		'labelfraction', 0.3, ...
		'TooltipString', 'prior probability for R sounds');
    NumeditParam(obj, 'left_alphas', 1, x, y, 'position', [x+200 y 100 20], ...
        'labelfraction', 0.3, ...
        'TooltipString', 'alphas for L sounds');
    NumeditParam(obj, 'right_alphas', 1, x, y, 'position', [x+300 y 100 20], ...
        'labelfraction', 0.3, ...
        'TooltipString', 'alphas for R sounds');
    next_row(y);

	% set_callback_on_load(alpha_style, 1);
	% NumeditParam(obj, 'most_random', 1, x, y, 'position', [x y 100 20], ...
	% 	'labelfraction', 0.4, ...
	% 	'TooltipString', 'the most_random (endpoints) alpha; this value must be positive');
	% NumeditParam(obj, 'least_random', realmax, x, y, 'position', [x+100 y 100 20], ...
	% 	'labelfraction', 0.4, ...
	% 	'TooltipString', 'the hardest alpha (biggest value); this value must be positive');
	NumeditParam(obj, 'N', 2, x, y, 'position', [x y 60 20], ...
		'labelfraction', 0.4, ...
		'TooltipString', sprintf(['the number of different alpha values to use in the task.', ...
                                ' If N is bigger than 1, the definition of random vs fixed is based on the alpha_thresh parameter', ...
                                'but the reward and side definitions are based on the options in the reward and sides sections']));
    NumeditParam(obj, 'alpha_thresh',100, x, y, 'position', [x+60 y 100 20], ...
        'labelfraction', 0.4, ...
        'TooltipString', sprintf(['the threshold for the alpha value to be considered a fixed trial.', ...
        'Used for reward if reward type is set to alphas, and used for trial alpha selection regardless of reward type']));
    set_callback({probe_alphas, N}, {mfilename, 'alphas'}); %#ok<NODEF>
    	PushbuttonParam(obj, 'normalize_pprobs', x, y, 'position', [x+160 y 100 20], ...
		'label', 'normalize', ...
		'TooltipString', 'Normalize pprobs');
	set_callback(normalize_pprobs, {mfilename, 'normalize_pprobs'});
	% next_row(y);
	% ToggleParam(obj, 'probe_alpha_style', 0, x, y, 'position', [x+460 y 200 20], ...
	% 	'OffString', 'alphas equally spaced based on values and N', ...
	% 	'OnString',  'alphas manually defined below', ...
	% 	'TooltipString', 'Set the alphas to be equally spaced or manually defined');
	% set_callback(probe_alpha_style, {mfilename, 'probe_alpha_style'});

    next_row(y,0.2);
    
    next_row(y);
    ToggleParam(obj, 'tone_style', 0, x, y, 'position', [x y 250 20], ...
		'OffString', 'Specify tones by base_freq and n_tones', ...
		'OnString',  'Specify tones manually', ...
		'TooltipString', 'S');
    NumeditParam(obj, 'tones', 2000, x, y, 'position', [x+250 y 300 20], ...
        'labelfraction', 0.15, ...
        'TooltipString', 'Tones that make up each click');
    
    next_row(y);
    NumeditParam(obj, 'fixed_frac', 0, x, y, 'position', [x y 100 20], ...
        'label','fixed fraction',...
        'TooltipString', 'fraction of click trains that will be fixed vs randomly timed');    
    NumeditParam(obj, 'sing_frac', 0, x, y, 'position', [x+100 y 100 20], ...
        'label','single fraction',...
        'TooltipString', 'fraction of click trains that will be single bup trials');                    
   
    next_row(y);
    NumeditParam(obj, 'bup_width', 3, x, y, 'position', [x y 100 20], ...
        'label', 'bupwidth, ms', 'TooltipString', 'the bup width in units of msec');
    NumeditParam(obj, 'bup_ramp', 2, x, y, 'position', [x+100 y 100 20], ...
        'label', 'bupramp, ms', 'TooltipString', 'the duration in units of msec of the upwards and downwards volume ramps for individual bups');
    NumeditParam(obj, 'base_freq', [2000], x, y, 'position', [x+200 y 100 20], ...
        'TooltipString', 'the base frequency of individual bup; the bup consists of this frequency together with n_tones-1 higher octaves','label','base freq, Hz');
    NumeditParam(obj, 'n_tones', 5, x, y, 'position', [x+300 y 80 20], ...
        'TooltipString', 'total number of tones used to generate individual bup; so n_tones-1 higher octaves are combined with base_freq');
    NumeditParam(obj, 'vol', 0.15, x, y, 'position', [x+380 y 90 20], ...
        'labelfraction', 0.3, ...
        'TooltipString', 'volume multiplier for all sounds; can be a 1x2 vector to specify multiplier for [left_vol right_vol]');    
    ToggleParam(obj, 'freq_vol', 1, x, y, 'position', [x+470 y 80 20], ...
        'OnString', 'var freq vol', ...
        'OffString', 'flat freq vol', ...
        'TooltipString','if on, multiple entries in the volume param adjusts each frequency separately. if off, adjusts each speaker side');  
    NumeditParam(obj,'replay_vol_mult',1,x,y, 'position',[x+550 y 50 20], ...
        'TooltipString','frac multiplier for sound during reward');
    NumeditParam(obj,'continue_vol_mult',1,x,y, 'position',[x+600 y 50 20], ...
        'TooltipString','frac multiplier for sound during reward');    
    next_row(y);
    
	% ToggleParam(obj, 'first_bup_stereo', 0, x, y, 'position', [x y 100 20], ...
	% 	'OffString', 'no stereo bup', ...
	% 	'OnString',  'first bup stereo', ...
	% 	'TooltipString', 'If on, an extra stereo bup is added in front of the first bup');
	ToggleParam(obj, 'avoid_collisions', 1, x, y, 'position', [x y 100 20], ...
		'OffString', 'allow collisions', ...
		'OnString',  'prevent collisions', ...
		'TooltipString', 'If not allowed, a refractory period is imposed equal to a single bup width. Otherwise, click waveforms sum and can therefore interfere.');    
	% ToggleParam(obj, 'task_type', 0, x, y, 'position', [x+200 y 100 20], ...
	% 	'OffString', 'Frequency Task', ...
	% 	'OnString',  'Sides Task', ...
	% 	'TooltipString', 'Sides task is classic Tbups where clicks come from either the right or left. Frequency makes all clicks stereo with the first base_freq frequency favoring left responses and the second favoring right');    
    
    
    NumeditParam(obj, 'min_ISI', .003, x, y, 'position', [x+100 y 100 20],'labelfraction',0.68, ...
        'TooltipString', 'the minimum time in ms that is allowed between bups','label','min ISI, ms');    
	NumeditParam(obj, 'total_rate', 12, x, y, 'position', [x+200 y 100 20],'labelfraction',0.68, ...
        'TooltipString', 'the sum of left and right bup rates in Hz','label','total rate, Hz');    
	NumeditParam(obj, 'crosstalk', 0, x, y, 'position', [x+300 y 100 20],'labelfraction',0.68, ...
		'TooltipString', 'if >0, then is the amount the left clicks leak into the right channel, and vice versa.');    
    ToggleParam(obj, 'vol_on', 1, x, y, 'position', [x+400 y 80 20], ...
        'OnString', 'sound is on with vol multiplier set from vol', ...
        'OffString', 'sound is off fully, equivalent to vol multiplier being 0');  
    set_callback({tone_style, n_tones, base_freq}, {mfilename, 'update_tones'});
    
    next_row(y);
    SubheaderParam(obj, 'title4', 'Stimulus Properties Section', x, y);
	next_row(y, 1.3);

    DispParam(obj, 'ThisAlpha', 1, x, y, 'position', [x y 150 20], ...
        'labelfraction', 0.6, ...
        'TooltipString', 'the alpha for the present trial');
    DispParam(obj, 'is_fixed', 0, x, y, 'position', [x+150 y 100 20], ...
        'labelfraction', 0.6, ...
        'TooltipString', 'whether this trial is fixed interval or not');
    DispParam(obj,'is_probe',0, x,y,'position',[x+250 y 100 20], ...
        'labelfraction', 0.6, ...
        'TooltipString', 'whether this trial is fixed interval or not');
    
	next_row(y, 1);
	HeaderParam(obj, 'panel_title', 'Tbups plugin', x, y, 'position', [x y 600 20]);
    
	
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
    specs.power=[0 0];
    specs.trigger = '';
    SoloParamHandle(obj, 'StimulatorSpecs', 'value', specs);
    SoloParamHandle(obj, 'MaskSpecs',       'value', specs);
    
	% stores the set of gamma values used to make Tbups from
	% trial to trial.  
	% these values may be specified either by range or by enumeration
	SoloParamHandle(obj, 'alphas', 'value', [1 realmax]);

    % feval(mfilename, obj, 'ARbias');
	feval(mfilename, obj, 'reward_style');
    feval(mfilename, obj, 'show_hide');   
    feval(mfilename, obj, 'check_stim_channels');
    feval(mfilename, obj, 'check_mask_channels');
    feval(mfilename, obj, 'check_headphones');
    feval(mfilename, obj, 'check_passive_stimulation');
    feval(mfilename, obj, 'update_laser_analog_output');
    feval(mfilename, obj, 'update_tones');
    
    figure(fig);
    x = origfig_xy(1); y = origfig_xy(2);

    if exist("active_curricula",'var')
        for i = 1:numel(value(active_curricula))
            % Construct the function call with the updated curriculum name
            current_curricula = value(active_curricula{i});
            function_call = sprintf("SoloFunctionAddAllVars(obj, 'TS_%s', 'rw_args');", current_curricula);
            eval(function_call);
        end
    end
%% adjust_volume
  case 'adjust_volume'
    snd = varargin{1};

    if vol_on == 0 
        snd = snd*0;
    else
        snd = snd*vol(1);
    end
    % the volume and left and right speakers are not always matched
    RtoL_speaker_volume_ratio = bSettings('get', 'GENERAL', 'RtoL_speaker_volume_ratio');
    if ~isnan(RtoL_speaker_volume_ratio)
        snd(2,:) = snd(2,:) / RtoL_speaker_volume_ratio;
    end
    x = snd;

%% count_this_bups
  case 'count_last_trial_bups'
	  sample_duration = varargin{1};
	  
	  x = time;
	  y = observer;
%% get
  case 'get'
     switch varargin{1},
         case 'nstimuli',
             x = length(left_alphas)+length(right_alphas)+length(endpoint_alphas); %#ok<NODEF>
         case 'nleft',
             x = length(left_alphas)+1; %plus 1 is for endpoint
         case 'nright',
             x = length(right_alphas)+1; %#ok<NODEF>
		 case 'all_sides',
			 x = [char('l'*ones(1,length(left_alphas)+1)) char('r'*ones(1,length(right_alphas)+1))]; %#ok<NODEF>
		 case 'sample_duration', 
			 x = value(T);
		 case 'pprobs',
			 x = [value(l_pprobs) ; value(r_pprobs)]; 
        % case 'ARbias'
        %     x = value(ARbias);
        case 'repProb'
            x = value(repProb);
     end;
%% get_all_bup_times
  case 'get_all_bup_times'
    x = get_history(ThisBupTimes); %#ok<NODEF>
    return;
%% get_bup_times  
  case 'get_bup_times',
    x = value(ThisBupTimes); %#ok<NODEF>
    return;
%% make_sounds
  case 'make_this_sound'
	srate = SoundManagerSection(obj, 'get_sample_rate');

    [snd,bpt] = make_time_train(value(total_rate), value(ThisAlpha), value(srate), value(T), 'bup_width',value(bup_width), ...
                'base_freq',value(base_freq),'n_tones',value(n_tones),'bup_ramp',value(bup_ramp),...
                'avoid_collisions',value(avoid_collisions),'min_ISI',value(min_ISI),'force_fixed',value(is_fixed));
    
    % if we made a click train and there are fewer than 2 bups, this is an
    % impossible trial. try again.
    while bpt.n_bups < 2
        [snd,bpt] = make_time_train(value(total_rate), value(ThisAlpha), value(srate), value(T), 'bup_width',value(bup_width), ...
                'base_freq',value(base_freq),'n_tones',value(n_tones),'bup_ramp',value(bup_ramp),...
                'avoid_collisions',value(avoid_collisions),'min_ISI',value(min_ISI),'force_fixed',value(is_fixed)); 
    end
    if value(T) < value(nose_in_center)
        if strcmp(T_type,'center')
            post_T.value = (value(nose_in_center) - value(T)) / 2;    
            post_snd = zeros(2,round(value(post_T)*value(srate)));
            snd = [snd post_snd];

        elseif strcmp(T_type, 'end')
            post_T.value = value(nose_in_center) - value(T);  
            post_snd = zeros(2,round(value(post_T)*value(srate)));
            snd = [snd post_snd];
        elseif strcmp(T_type, 'beginning')
            post_T.value = value(nose_in_center) - value(T);
            pre_snd = zeros(2,round(value(post_T)*value(srate)));
            snd = [pre_snd snd];
        end
    else
        post_T.value = 0;
    end

    snd = feval(mfilename, obj, 'adjust_volume', snd);

    feval(mfilename, obj,'reinforce_sound',snd);

	if ~SoundManagerSection(obj, 'sound_exists', 'TBupsSound')
		SoundManagerSection(obj, 'declare_new_sound', 'TBupsSound');
		SoundManagerSection(obj, 'set_sound', 'TBupsSound', snd);
	else
		snd_prev = SoundManagerSection(obj, 'get_sound', 'TBupsSound');
		if ~isequal(snd, snd_prev)
			SoundManagerSection(obj, 'set_sound', 'TBupsSound', snd);
        end
    end

	ThisAlpha.value = bpt.alpha;
    bpt.alpha=value(ThisAlpha);

    if value('reward_style')
        if bpt.alpha == 1 || bpt.alpha == realmax
            bpt.is_probe = 0;
            is_probe.value = 0;
        else
            bpt.is_probe = 1;
            is_probe.value = 1;
        end
    end
    % if all(abs(bpt.ICIs-bpt.tot_rate) < value(diff_click_threshold))
    %     bpt.is_fixed = 1;
    %     is_fixed.value = 1;
    % else
    %     bpt.is_fixed = 0;
    %     is_fixed.value = 0;

    % end

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

      if value(reward_style) && value(probe_frac) > rand
        temp_side = side;
        side = 'p';
      end

	  LocalPrevSides.value  = varargin{2};
	  LocalPrevSounds.value = varargin{3};
      replay_stim.value = varargin{4};
      continue_stim.value = varargin{5};
	  
      feval(mfilename, obj, 'alphas');
	  feval(mfilename, obj, 'normalize_pprobs');
	  feval(mfilename, obj, 'T_resample');
	  feval(mfilename, obj, 'update_hitfrac');
	  feval(mfilename, obj, 'update_biashitfrac');
     
    
      if value(reward_style)
        if side == 'l',
                x = -1;
                ThisAlpha.value = endpoint_alphas(1);

        elseif side == 'r',

                x = 1;
                ThisAlpha.value = endpoint_alphas(2);

        elseif side == 'p',
            x = randi(length(probe_alphas));
            ThisAlpha.value = probe_alphas(x);
            x= 0;
        end
      else
        if side == 'r'
            poss_r_alphas = probe_alphas(value(probe_alphas) > value(alpha_thresh));
            poss_r_alphas =[endpoint_alphas(2) poss_r_alphas];
            x = randi(length(poss_r_alphas));
            ThisAlpha.value = poss_r_alphas(x);
            x=1;
        elseif side == 'l'
            poss_l_alphas = probe_alphas(value(probe_alphas) < value(alpha_thresh));
            poss_l_alphas =[endpoint_alphas(1) poss_l_alphas];
            x = randi(length(poss_l_alphas));
            ThisAlpha.value = poss_l_alphas(x);
            x = -1;
        end

	  end;

      %T_resample depends on the seed to it got moved down here
      feval(mfilename, obj, 'T_resample');

      feval(mfilename, obj, 'make_this_sound');

	  feval(mfilename, obj, 'push_history');
      y = value(T)+value(post_T);

    
%% push_history
  case 'push_history'
	  push_history(ThisBupTimes);
     % push_history(StimulatorSpecs);
    %   push_history(MaskSpecs);
    %   push_history(is_frozen);
    %   push_history(ThisSeed);  

%% update_hitfrac
  case 'update_hitfrac',
	PrevSides = colvec(value(LocalPrevSides));

	if ~isempty(hit_history),
		kernel = exp(-(0:length(hit_history)-1)/HitFracTau)';
        kernel = kernel(end:-1:1);
		HitFrac.value = nansum(hit_history .* kernel)/sum(kernel);
		
		if ~isempty(PrevSides),
			PrevSides = PrevSides(1:length(hit_history));
		end;
		
		u = find(PrevSides == 'l');
		if isempty(u), LtHitFrac.value = NaN;
		else           LtHitFrac.value = nansum(hit_history(u) .* kernel(u))/sum(kernel(u));
		end;
		
		u = find(PrevSides == 'r');
		if isempty(u), RtHitFrac.value = NaN;
		else           RtHitFrac.value = nansum(hit_history(u) .* kernel(u))/sum(kernel(u));
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
	  
	  if ~isempty(reward_history),
		  if ~isempty(PrevSounds),
			  PrevSides  = PrevSides(1:length(reward_history));
			  PrevSounds = PrevSounds(1:length(reward_history));
		  end;
		  
		  u = find(PrevSides == 'l');
		  if isempty(u), 
			  LtHits.value     = ones(size(l_pprobs));
			  LtPostProb.value = value(l_pprobs);
		  else
			  biashitfrac_value = exponential_hitfrac(PrevSounds(u), reward_history(u), value(BiasTau), -(1:length(l_pprobs(:))));
			  LtHits.value     = biashitfrac_value;
			  LtPostProb.value = probabilistic_trial_selector(biashitfrac_value, value(l_pprobs), value(Beta))*sum(l_pprobs(:));
			  if isnan(value(LtPostProb)), LtPostProb.value = value(l_pprobs); end;
		  end;

		  u = find(PrevSides == 'r');
		  if isempty(u), 
			  RtHits.value     = ones(size(r_pprobs));
			  RtPostProb.value = value(r_pprobs);
		  else
			  biashitfrac_value = exponential_hitfrac(PrevSounds(u), hit_history(u), value(BiasTau), 1:length(r_pprobs(:)));
			  RtHits.value     = biashitfrac_value;
			  RtPostProb.value = probabilistic_trial_selector(biashitfrac_value, value(r_pprobs), value(Beta))*sum(r_pprobs(:));
			  if isnan(value(RtPostProb)), RtPostProb.value = value(r_pprobs); end;
		  end;	
	  else
		  LtHits.value = NaN;
		  RtHits.value = NaN;
		  LtPostProb.value = value(l_pprobs);
		  RtPostProb.value = value(r_pprobs);
	  end;
%% update_tones
  case 'update_tones'     
      s = value(base_freq);
      s(s < 0) = 0;
      base_freq.value = s;
      
      s = value(n_tones);
      s(s < 0) = 0;
      n_tones.value = s;
      
      if  tone_style
          enable(tones)
      else
          disable(tones)
      end

      if ~value(tone_style)
          tones.value = value(base_freq) * 2.^(0:value(n_tones)-1);
      end

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
	% if p_probe > 1, p_probe.value = 1; end
	% if p_probe < 0, p_probe.value = 0; end
	% if T_probe < 0, T_probe.value = 0; end % p_probe.value = 0; 
	if T_max < T_min, T_max.value = T_min(1); end
	ThisSeed.value = randi(10^9,1);

    if isempty(value(Bups))
        % set T using the seed, so that frozen noise trials have the same
        % bup sequence AND stimulus duration
        try
            RandStream.setDefaultStream(RandStream('mt19937ar','Seed',value(ThisSeed))); % old matlab            
        catch
            rng(value(ThisSeed),'twister'); % new matlab
        end            
        T.value = value(T_min)+rand(1)*(T_max-T_min);

    else
        b=value(Bups);
        T.value = b.T;
    end
    % end
	
%% normalize_pprobs
  case 'normalize_pprobs'

	nlefts = length(l_pprobs(:));
	p = [l_pprobs(:); r_pprobs(:)];
	p = p/sum(p);
	l_pprobs.value = p(1:nlefts);
	r_pprobs.value = p(nlefts+1:end);
    
%% gammas
  case 'alphas'
    if value(reward_style) == 0
        probe_alphas.value = abs(value(probe_alphas)); 
        tot_alphas = sort([value(endpoint_alphas) value(probe_alphas)]);
        N.value = length(tot_alphas);
        left_alphas.value = tot_alphas(tot_alphas < value(alpha_thresh));
        right_alphas.value = tot_alphas(tot_alphas >=value(alpha_thresh));
        l_pprobs.value = ones(1, length(left_alphas)); 
        r_pprobs.value = ones(1,length(right_alphas));
    else
        N.value = length(value(endpoint_alphas));
        left_alphas.value = endpoint_alphas(value(endpoint_alphas) < value(alpha_thresh));
        right_alphas.value = endpoint_alphas(value(endpoint_alphas) > value(alpha_thresh));
        l_pprobs.value = ones(1, length(left_alphas)); 
        r_pprobs.value = ones(1,length(right_alphas));
    end

    feval(mfilename, obj, 'normalize_pprobs');
%% Adjust and create reinforce sounds
  case 'reinforce_sound' %snd = feval(mfilename, obj, 'adjust_volume', snd);
    snd = varargin{1};

    replay_sound = snd * value(replay_vol_mult);
    if ~SoundManagerSection(obj, 'sound_exists', 'replay_sound')
        SoundManagerSection(obj, 'declare_new_sound', 'replay_sound');
        SoundManagerSection(obj, 'set_sound', 'replay_sound', replay_sound);
    else
        SoundManagerSection(obj, 'set_sound', 'replay_sound', replay_sound);
    end

    cont_sound = snd * value(continue_vol_mult);
    if ~SoundManagerSection(obj, 'sound_exists', 'continue_sound')
        SoundManagerSection(obj, 'declare_new_sound', 'continue_sound');
        SoundManagerSection(obj, 'set_sound', 'continue_sound', cont_sound);
        SoundManagerSection(obj, 'loop_sound','continue_sound', 1);
    else
        SoundManagerSection(obj, 'set_sound', 'continue_sound', cont_sound);
        SoundManagerSection(obj, 'loop_sound','continue_sound', 1);
    end


%% gamma_style
%   case 'probe_alpha_style'
% 	if probe_alpha_style == 0, % if we're going by the range
% 		enable(most_random);
% 		enable(least_random);
% 		enable(N);
% 		disable(probe_alphas);
% 		if N == 1,
% 			g =most_random(1);
% 		else
% 			g = linspace(most_random(1), least_random(1), N(1));
% 		end;
% 		probe_alphas.value  = g;  % internal soloparam
% 		probe_alphas.value = value(probe_alphas);  % for display 

%         left_alphas.value = probe_alphas(probe_alphas < value(alpha_thresh));
%         right_alphas.value = probe_alphas(probe_alphas >= value(alpha_thresh));

% 		if length(value(l_pprobs)) ~= length(left_alphas) || length(value(r_pprobs)) ~= length(right_alphas),	
%             l_pprobs.value = ones(1, length(left_alphas)); 
%             r_pprobs.value = ones(1, length(right_alphas));
%         end;

% 		feval(mfilename, obj, 'normalize_pprobs');
% 	else                 % if we're going byalphas, still use thresholds to determine fixed vs random
% 		disable(most_random);
% 		disable(least_random);
% 		disable(N);
% 		enable(probe_alphas);

% 		probe_alphas.value  = probe_alphas(:);

%         left_alphas.value = probe_alphas(probe_alphas < value(alpha_thresh));
%         right_alphas.value = probe_alphas(probe_alphas >= value(alpha_thresh));

% 		if length(value(l_pprobs)) ~= length(value(left_alphas)) || length(value(r_pprobs)) ~= length(value(right_alphas)),	
%             l_pprobs.value = ones(1, length(value(left_alphas))); 
%             r_pprobs.value = ones(1, length(value(right_alphas)));
%         end;

% 		feval(mfilename, obj, 'normalize_pprobs');
% 	end; 
      
%% hide, show_hide
  case 'hide',
    tbup_show.value = 0;
    feval(mfilename, obj, 'show_hide');
    
  case 'show_hide',
    if value(tbup_show) == 1, set(value(tbup_fig), 'Visible', 'on');  %#ok<NODEF>
    else                      set(value(tbup_fig), 'Visible', 'off');
    end;
    
%% close
  case 'close'   
    try %#ok<TRYNC>
        if ishandle(value(tbup_fig)), delete(value(tbup_fig)); end;
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