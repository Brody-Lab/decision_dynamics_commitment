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
        'value', double(figure('Position', [200 screen_size(4)-500 400 140], ...
        'closerequestfcn', [mfilename '(' class(obj) ', ''hide''' ');'], 'MenuBar', 'none', ...
        'NumberTitle', 'off', 'Name', 'PBups')), 'saveable', 0);
    origfig_xy = [x y]; 
    
    x = 10; y = 10;
    NumeditParam(obj, 'test_gamma', 2, x, y, 'position', [x y 120 20], ...
        'labelfraction', 0.7, ...
        'TooltipString', 'Pushing the Play button will play a sample sound of this gamma');
    PushbuttonParam(obj, 'test_play', x, y, 'position', [x+130 y 80 20], ...
        'label', 'test Play');
    PushbuttonParam(obj, 'test_stop', x, y, 'position', [x+210 y 80 20], ...
        'label', 'test Stop');
    set_callback(test_play, {mfilename, 'test_play'});
    set_callback(test_stop, {mfilename, 'test_stop'});
    
    NumeditParam(obj, 'vol', 0.5, x, y, 'position', [x+310 y 70 20], ...
        'labelfraction', 0.35, ...
        'TooltipString', 'volume multiplier for all sounds');
    next_row(y, 1.5);
    
    % in this implementation, there is no N-way antibias between the trial
    % types of gammas specified in this plugin
    NumeditParam(obj, 'R_gammas', 2, x, y, 'position', [x y 280 20], ...
        'labelfraction', 0.25, ...
        'TooltipString', 'gammas for sounds whose rates in the right ear are larger; these must all be > 0');
    DispParam(obj, 'R_pprob', 0.5, x, y, 'position', [x+280 y 100 20], ...
        'labelfraction', 0.7, ...
        'TooltipString', 'prior probability of selecting a right trial');
    next_row(y);
    NumeditParam(obj, 'L_gammas', -2, x, y, 'position', [x y 280 20], ...
        'labelfraction', 0.25, ...
        'TooltipString', 'gammas for sounds whose rates in the left ear are larger; these must all be < 0');
    NumeditParam(obj, 'L_pprob', 0.5, x, y, 'position', [x+280 y 100 20], ...
        'labelfraction', 0.7, ...
        'TooltipString', 'prior probability of selecting a left trial');
    next_row(y, 1.5);
    set_callback({R_gammas, L_gammas}, {mfilename, 'gammas'}); %#ok<NODEF>
    set_callback({L_pprob}, {mfilename, 'L_pprob'}); %#ok<NODEF>
    set_callback_on_load(L_pprob, 1);
    
    
    NumeditParam(obj, 'total_rate', 40, x, y, 'position', [x y 100 20], ...
        'TooltipString', 'the sum of left and right bup rates');
    NumeditParam(obj, 'sduration', 1, x, y, 'position', [x+100 y 100 20], ...
        'TooltipString', 'duration of each sound to be generated, in seconds (each sound may be terminated before it completes playing)');
	ToggleParam(obj, 'first_bup_stereo', 0, x, y, 'position', [x+200 y 100 20], ...
		'OffString', 'No stereo bup', ...
		'OnString', 'First bup stereo', ...
		'TooltipString', 'If on, a stereo bup is added before all other bups');
	NumeditParam(obj, 'crosstalk', 0, x, y, 'position', [x+300 y 100 20], ...
		'TooltipString', 'if >0, then is the amount the left clicks leak into the right channel, and vice versa.');
    next_row(y);
    
    DispParam(obj, 'ThisGamma', 0, x, y, 'position', [x y 120 20], ...
        'labelfraction', 0.6, ...
        'TooltipString', 'the gamma of the present trial; if r_R and r_L are the rates of Poisson events on the right and left, then gamma = log(r_R/r_L)');
    DispParam(obj, 'ThisLeftRate', 10, x, y, 'position', [x+120 y 130 20], ...
        'labelfraction', 0.6, ...
        'TooltipString', 'the average rate of Poisson events on the left for this trial');
    DispParam(obj, 'ThisRightRate', 10, x, y, 'position', [x+240 y 130 20], ...
        'labelfraction', 0.6, ...
        'TooltipString', 'the average rate of Poisson events on the right for this trial');    
    
    % this soloparamhandle stores the actual bup times (in seconds) on the left and right
    % for the present trial, as well as the side response of an ideal
    % observer that counts the number of bups on either side.
    % ThisBupTimes.observer is -1 for left, 1 for right, and 0 if the
    % numbers of bups on either side are equal.
    % ThisBupTimes.left and ThisBupTimes.right are updated as the next
    % sound is prepared and pushed to history to be saved with the data
    SoloParamHandle(obj, 'ThisBupTimes', 'value', {});
    
    
    feval(mfilename, obj, 'show_hide');                     
                         
    figure(fig);
    x = origfig_xy(1); y = origfig_xy(2);

   

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
             x = length(L_gammas) + length(R_gammas); %#ok<NODEF>
         case 'nleft',
             x = length(L_gammas); %#ok<NODEF>
         case 'nright',
             x = length(R_gammas); %#ok<NODEF>
         case 'all_sides',
             x = [char('l'*ones(1,length(L_gammas))) char('r'*ones(1,length(R_gammas)))]; %#ok<NODEF>
         case 'pprobs', 
             x = [value(L_pprob) value(R_pprob)]; %#ok<NODEF>
     end;
      
%% next_trial
  case 'next_trial'  
      % takes an optional argument that specifies the next side choice
      % if there's no specified next side, then pick using the pprobs
	  %
	  % a second optional argument specifies whether to this will be a
	  % probe trial
      %
      % returns [x y], where x is the index of the next sound picked and y
      % is the side of the next sound picked.  If it is a right sound,
      % then x > 0; if it is a left sound, then x < 0, where abs(x) is the
      % position of the sound in the vector L_gammas.
        if numel(varargin) > 0,
           side = varargin{1};
        else
           side = '';
        end;
		
		if numel(varargin) > 1,
			use_pbups_probe = varargin{2};
		else
			use_pbups_probe = 0;
		end;


		if side == 'l',
		   x = ceil(rand(1)*length(L_gammas)); %#ok<NODEF>
		   y = 'l';
		   ThisGamma.value = L_gammas(x);
		   x = -x;
		elseif side == 'r',
		   x = ceil(rand(1)*length(R_gammas)); %#ok<NODEF>
		   y = 'r';
		   ThisGamma.value = R_gammas(x);
		else
		   if rand(1) < L_pprob, %#ok<NODEF>
			   x = ceil(rand(1)*length(L_gammas)); %#ok<NODEF>
			   ThisGamma.value = L_gammas(x);
			   y = 'l';
			   x = -x;
		   else
			   x = ceil(rand(1)*length(R_gammas)); %#ok<NODEF>
			   ThisGamma.value = R_gammas(x);
			   y = 'r';
		   end;
		end;

		if use_pbups_probe == 0,
			feval(mfilename, obj, 'make_this_sound');
		else
			% MAJOR HACK ALERT: consider the sound id to be 0 when it's a
			% probe trial
			x  = 0;
			feval(mfilename, obj, 'make_pbups_probe_sound', side);
		end;
		
        push_history(ThisBupTimes); %#ok<NODEF>
		
%% push_history
  case 'push_history'
		push_history(ThisBupTimes);
		
%% use_probe_sounds
  case 'make_pbups_probe_sound',
		side = varargin{1};
		
		% here's our canonical probe sound
		total_duration = 1;
		rate_larger = 24.8984;
		rate_smaller = 15.1016;
		bupstimes_larger  = [0.0081 0.0124 0.0337 0.0495 0.0874 0.1994 0.2009 0.2546 0.2578 0.3499 0.4389 0.4733 0.4797 0.5464 0.5475 0.5544 0.6118 0.6792 0.7380 0.8047 0.8278 0.8437 0.8637 0.8756 0.9839];
		bupstimes_smaller = [0.0081 0.0638 0.1103 0.1141 0.1201 0.2342 0.2926 0.3285 0.3669 0.4480 0.4858 0.5754 0.6106 0.6229 0.6276 0.9577];
		
		if side == 'l',
			ThisGamma.value = -0.5;
			data.left = bupstimes_larger;
			data.right = bupstimes_smaller;
			data.lrate = rate_larger;
			data.rrate = rate_smaller;
			ThisLeftRate.value = rate_larger;
			ThisRightRate.value = rate_smaller;
			bpt.observer = -1;
		elseif side =='r',
			ThisGamma.value = 0.5;
			data.left  = bupstimes_smaller;
			data.right = bupstimes_larger;
			data.lrate = rate_smaller;
			data.rrate = rate_larger;
			ThisLeftRate.value = rate_smaller;
			ThisRightRate.value = rate_larger;
			bpt.observer = 1;
		end;
		
		% make the sound
		srate = SoundManagerSection(obj, 'get_sample_rate');
        [snd lrate rrate data] = make_pbup(value(total_rate), value(ThisGamma), ...
			srate, total_duration, ...
			'bup_width', 3, 'fixed_sound', data); %#ok<NODEF>
        snd = snd*vol;
		
        if ~SoundManagerSection(obj, 'sound_exists', 'PBupsSound'),
            SoundManagerSection(obj, 'declare_new_sound', 'PBupsSound');
            SoundManagerSection(obj, 'set_sound', 'PBupsSound', snd);
        else
            snd_prev = SoundManagerSection(obj, 'get_sound', 'PBupsSound');
            if ~isequal(snd, snd_prev),
                SoundManagerSection(obj, 'set_sound', 'PBupsSound', snd);
            end;
        end;
		
		bpt.gamma = value(ThisGamma);
		bpt.left = data.left;
		bpt.right = data.right;
		bpt.is_probe = 1;
		ThisBupTimes.value = bpt;
		
		

%% make_sounds
  case 'make_this_sound',
        srate = SoundManagerSection(obj, 'get_sample_rate');
        [snd lrate rrate data] = make_pbup(value(total_rate), value(ThisGamma), ...
			srate, value(sduration), ...
			'bup_width', 3, 'first_bup_stereo', value(first_bup_stereo), ...
			'crosstalk', value(crosstalk)); %#ok<NODEF>
        snd = snd*vol;

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
		bpt.is_probe = 0;
        if numel(data.left) > numel(data.right),
            bpt.observer = -1;
        elseif numel(data.right) > numel(data.left),
            bpt.observer = 1;
        else
            bpt.observer = 0;
        end;
        ThisBupTimes.value = bpt;

        
    
%% test_play
  case 'test_play',
    srate = SoundManagerSection(obj, 'get_sample_rate');
    [snd] = make_pbup(value(total_rate), value(test_gamma), srate, value(sduration), ...
				'bup_width', 3, 'first_bup_stereo', value(first_bup_stereo), ...
				'crosstalk', value(crosstalk));
    snd = snd*vol;

    if ~SoundManagerSection(obj, 'sound_exists', 'TestSound'),
      SoundManagerSection(obj, 'declare_new_sound', 'TestSound');
    end;

    SoundManagerSection(obj, 'set_sound', 'TestSound', snd);
    
    SoundManagerSection(obj, 'play_sound', 'TestSound');
      
      
%% stop_sound      
  case 'test_stop',
      
    SoundManagerSection(obj, 'stop_sound', 'TestSound');
    

%% L_pprob
  case 'L_pprob',
    if L_pprob > 1, L_pprob.value = 1; end; %#ok<NODEF>
    if L_pprob < 0, L_pprob.value = 0; end;
    
    R_pprob.value = 1 - L_pprob; 
    
%% gammas
  case 'gammas'
    L_gammas.value = -abs(value(L_gammas)); %#ok<NODEF>
    R_gammas.value = abs(value(R_gammas)); %#ok<NODEF>

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
%     end;
    
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