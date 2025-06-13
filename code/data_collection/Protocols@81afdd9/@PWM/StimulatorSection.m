% [x, y] = StimulatorSection(obj, action, tname, varargin)
%
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
% Emily Dennis February 2020 - added with the goal of replacing
% StimulatorSection so cerebro2 can work with the PWM protocol.

function [x, y] = StimulatorSection(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action

    %---------------------------------------------------------------%
    %          init                                                 %
    %---------------------------------------------------------------%
    case 'init'
        if length(varargin) < 2
          error('Need at least two arguments, x and y position, to initialize %s', mfilename);
        end
        x = varargin{1}; y = varargin{2};

        SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);
    
        %adds a button and a soloparam stim_show which opens and closes the
        %New stimulus window
        ToggleParam(obj, 'stim_show', 0, x, y, ...
            'OnString', 'Stimulator window Showing', ...
            'OffString', 'Stimulator window Hidden', ...
            'TooltipString', 'Show/Hide Stimulator window'); 
        set_callback(stim_show, {mfilename, 'show_hide';});
        next_row(y);

    
        %this saves the position on the main PWM screen so we can return there
        %if the screen is closed/to add other buttons, etc.
        fig = double(gcf);
        oldx = x;
        oldy = y;
    
        % add a SPH called myfig that includes this window
        SoloParamHandle(obj, 'myfig', ...
            'value', double(figure('Position', [10 20 600 700], ...
            'closerequestfcn', [mfilename '(' class(obj) ', ''hide''' ');'], 'MenuBar', 'none', ...
            'NumberTitle', 'off', 'Name', mfilename)), 'saveable', 0);

        x = 10; 
        y = 10;     
    
    
%     % STIMULATOR SECTION
%     NumeditParam(obj, 'ao_off_ramp_dur_s', 0, x, y, 'position', [x+250 y 250 20], ...
%         'labelfraction', 0.4, ...
%         'TooltipString', 'Offset ramp duration in second. Ramp occurs during STIM_DUR and has a waveform according to AO_IS_SINE_NOT_SQUARE');
%     NumeditParam(obj, 'ao_on_ramp_dur_s', 0, x, y, 'position', [x y 250 20], ...
%         'labelfraction', 0.4, ...
%         'TooltipString', 'Onset ramp duration in second. Ramp occurs during STIM_DUR and has a waveform according to AO_IS_SINE_NOT_SQUARE');
%     next_row(y);
%     NumeditParam(obj, 'ao_max_V', 5, x, y, 'position', [x+250 y 250 20], ...
%         'labelfraction', 0.4, ...
%         'TooltipString', 'Maximum voltage of the analog output. This assumes that the range of voltage output of the NIDAQ card in your RTlinux machine is [-10, 10] V.');
%     NumeditParam(obj, 'ao_min_V', 0, x, y, 'position', [x y 250 20], ...
%         'labelfraction', 0.4, ...
%         'TooltipString', 'Minimum voltage of the analog output. This assumes that the range of voltage output of the NIDAQ card in your RTlinux machine is [-10, 10] V.');
%     next_row(y);    
%     ToggleParam(obj, 'ao_is_sine_not_square', 0, x, y, 'position', [x+100 y 75 20], ...
%     'OffString', 'Square', ...
%     'OnString',  'Sine', ...
%     'TooltipString', 'Sine or square wave?');
%     ToggleParam(obj, 'stim_is_analog_not_digital', 0, x, y, 'position', [x y 100 20], ...
%     'OffString', 'Digital output', ...
%     'OnString',  'Analog output', ...
%     'TooltipString', 'Is laser stimulation controlled through digital or analog output?');
%     next_row(y,2);

        NumeditParam(obj, 'stim_trigger_state', 1, x, y, 'position', [x y 290 20], ...
            'labelfraction', 0.5, ...
            'TooltipString', 'the state on which the stim will be triggered, as listed in states_list');
        valid_states = {'1: cpoke1', '2: wait_for_spoke','3: iti'};
        MenuParam(obj, 'states_list', valid_states, 1, x, y,'position', [x+300 y 290 20], ...
            'labelfraction', 0.5, ...
            'TooltipString', 'The list of possible states on which a scheduled wave carrying the stimulation');

        next_row(y);
        NumeditParam(obj, 'stim_pre_jitter', 0, x, y, 'position', [x y 290 20], ...
            'labelfraction', 0.5, ...
            'TooltipString', 'Allowable jitter (in sec) of the timing of the preamble before stimulator is turned on. The laser will come on randomly within this duration before or after stim_pre, with a uniform distribution.');
        NumeditParam(obj, 'stim_dur', 2, x, y, 'position', [x+300 y 290 20], ...
            'labelfraction', 0.5, ...
            'TooltipString', 'Duration (in sec) the stimulator remains on');
        
        next_row(y);
        NumeditParam(obj, 'stim_pre', 0, x, y, 'position', [x y 290 20], ...
            'labelfraction', 0.5, ...
            'TooltipString', 'Duration (in sec) of preamble before stimulator is turned on, relative to start of trigger state.');
        NumeditParam(obj, 'stim_freq', 0, x, y, 'position', [x+300 y 290 20], ...
            'labelfraction', 0.5, ...
            'TooltipString', 'Frequency (in Hz) of pulses, use 0 for a single continuous pulse');
       
        next_row(y);
        NumeditParam(obj, 'stim_pulse', 0, x, y, 'position', [x y 290 20], ...
            'labelfraction', 0.5, ...
            'TooltipString', 'Duration (in milliseconds) for each stim pulse, use 0 for a single continuous pulse');    
        NumeditParam(obj, 'stimulator_frac', 0, x, y, 'position', [x+300 y 290 20], ...
            'labelfraction', 0.5, ...
            'TooltipString', 'fraction of trials stimulated; note that if only probe trials are stimulated, then this means the fraction of probe trials, not total trials');
        
        next_row(y);
        ToggleParam(obj, 'require_cerebro', 0, x, y, 'position', [x y 200 20], ...
            'OffString', 'Cerebro NOT required for stim', ...
            'OnString',  'Cerebro required for stim', ...
            'TooltipString', 'Require a working connection to a Cerebro base station to stimulate?');
        NumeditParam(obj, 'stim_power1', 0, x, y, 'position', [x+200 y 190 20], ...
            'labelfraction', 0.4, ...
            'TooltipString', 'cerebro power (if not connected to a cerebro base station, this parameter is meaningless), for cerebro2 it is interpreted as mW');   
        NumeditParam(obj, 'stim_power2', 0, x, y, 'position', [x+400 y 190 20], ...
            'labelfraction', 0.4, ...
            'TooltipString', 'cerebro power (if not connected to a cerebro base station, this parameter is meaningless), for cerebro2 it is interpreted as mW');   


        set_callback({stim_trigger_state; stim_pre; stim_dur; stim_pre_jitter; stimulator_frac; stim_freq; stim_pulse; stim_power1; stim_power2;...
                      % ao_min_V; ao_max_V; ao_on_ramp_dur_s; ao_off_ramp_dur_s...
                      }, {mfilename, 'update_stim'});
   
        % set_callback({stim_is_analog_not_digital, ao_is_sine_not_square}, {mfilename, 'update_laser_analog_output'});
    
        % next_row(y);
        % ToggleParam(obj, 'Automatic settings for stim', 0, x, y, 'position', [x y 250, 20], ...
        %    'Offstring', 'Use settings specified below', ...
        %    'Onstring', 'Stim pre/1/2/post', ...
        %    'TooltipString', 'This button if on inactivates pre stim (500ms), 1st half, 2nd half, and post (500ms). It automatically sets the setting, and doesnt allow stim on just probe trials');

        % set_callback()

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
            DeclareGlobals(obj, 'ro_args', {'StimulatorSpecs'});

        feval(mfilename, obj, 'show_hide');   
        feval(mfilename, obj, 'check_stim_channels');
        % feval(mfilename, obj, 'update_laser_analog_output');
    
        % return to PWM window
        x=oldx;
        y=oldy;
        figure(fig);
        %% check_mask_channels

    %---------------------------------------------------------------%
    %          check_stim_channels                                  %
    %---------------------------------------------------------------%
    case 'check_stim_channels'
        channel = bSettings('get', 'DIOLINES', 'LASER');
        if isnan(channel),
            stimulator_frac.value = 0; % setting this to zero is potentially overriden because settings are loaded after this is called
        end

    %---------------------------------------------------------------%
    %          next_trial_simulator                                 %
    %---------------------------------------------------------------%
    case 'next_trial_stimulator'
        feval(mfilename, obj, 'pick_stimulator', varargin{1}, varargin{2}, varargin{3});
        push_history(StimulatorSpecs);
 

    %---------------------------------------------------------------%
    %          update_values                                        %
    %---------------------------------------------------------------%
    case 'update_values'
      
        % enforces that the correct number of entries are in all the
        % stimulation related sphs.
        n = numel(value(stimulator_frac));
        s = value(stimulator_frac);
        if sum(s) > 1
            stimulator_frac.value = s/sum(s);
        end
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

        if numel(stim_power1) < n,
            s = value(stim_power1);
            stim_power1.value = [s s(end)*ones(1,n-numel(s))];
        elseif numel(value(stim_power1)) > n
            s = value(stim_power1);
            stim_power1.value = s(1:n);
        end 

        if numel(stim_power2) < n,
            s = value(stim_power2);
            stim_power2.value = [s s(end)*ones(1,n-numel(s))];
        elseif numel(value(stim_power2)) > n
            s = value(stim_power2);
            stim_power2.value = s(1:n);
        end 
%       
%       if numel(ao_min_V) < n,
%           s = value(ao_min_V);
%           ao_min_V.value = [s s(end)*ones(1,n-numel(s))];
%       elseif numel(value(ao_min_V)) > n
%           s = value(ao_min_V);
%           ao_min_V.value = s(1:n);
%       end 
%       
%       if numel(ao_max_V) < n,
%           s = value(ao_max_V);
%           ao_max_V.value = [s s(end)*ones(1,n-numel(s))];
%       elseif numel(value(ao_max_V)) > n
%           s = value(ao_max_V);
%           ao_max_V.value = s(1:n);
%       end 
%       
%       if numel(ao_on_ramp_dur_s) < n,
%           s = value(ao_on_ramp_dur_s);
%           ao_on_ramp_dur_s.value = [s s(end)*ones(1,n-numel(s))];
%       elseif numel(value(ao_on_ramp_dur_s)) > n
%           s = value(ao_on_ramp_dur_s);
%           ao_on_ramp_dur_s.value = s(1:n);
%       end 
%       
%       if numel(ao_off_ramp_dur_s) < n,
%           s = value(ao_off_ramp_dur_s);
%           ao_off_ramp_dur_s.value = [s s(end)*ones(1,n-numel(s))];
%       elseif numel(value(ao_off_ramp_dur_s)) > n
%           s = value(ao_off_ramp_dur_s);
%           ao_off_ramp_dur_s.value = s(1:n);
%       end 
%       
%       s = value(ao_min_V);
%       s(s < -10) = -10;
%       ao_min_V.value = s;      
%       s = value(ao_max_V);
%       s(s < -10) = -10;
%       ao_max_V.value = s;
%       s = value(ao_on_ramp_dur_s);
%       s(s < 0) = 0;
%       ao_on_ramp_dur_s.value = s;
%       s = value(ao_off_ramp_dur_s);
%       s(s < 0) = 0;
%       ao_off_ramp_dur_s.value = s;
%       s = value(stim_dur);
%       ramp_dur_s = value(ao_on_ramp_dur_s) + value(ao_off_ramp_dur_s);
%       s(s < ramp_dur_s) = ramp_dur_s(s < ramp_dur_s);
%       stim_dur.value = s;
%       s = value(stim_trigger_state);
%       s(s < 1 | mod(s, 1)~=0) = 1;
%       stim_trigger_state.value = s;
% %% update_laser_analog_output
%   case 'update_laser_analog_output'
%       for param = {'ao_min_V', 'ao_max_V', 'ao_on_ramp_dur_s', 'ao_off_ramp_dur_s', 'ao_is_sine_not_square'};
%           if stim_is_analog_not_digital
%             eval(['enable(' param{:} ')']);
%           else
%             eval(['disable(' param{:} ')']);
%           end
%       end
%       if stim_is_analog_not_digital && ao_is_sine_not_square
%           disable(stim_pulse)
%       else
%           enable(stim_pulse)
%       end
%     

    %---------------------------------------------------------------%
    %          pick_stimulator                                      %
    %---------------------------------------------------------------%
    case 'pick_stimulator'
        % determine if the next trial will be accompanied by a stim DIOLINE 
        % some stim durations are codes for inactivations for a certain epoch of the trial
        % and they ignore the other specifications
        % stim_dur 101 = inactivate delay before stim start
        % stim_dur 102 = inactivate first half
        % stim_dur 103 = inactivate second half
        % stim_dur 104 = inactivate memory gap

        StimulatorSpecs.ison    = 0;
        StimulatorSpecs.pre     = 0;
        StimulatorSpecs.dur     = 0;
        StimulatorSpecs.freq    = 0;
        StimulatorSpecs.pulse   = 0;
        StimulatorSpecs.power   = [0 0];
        StimulatorSpecs.trigger = '';
        % if isfield(value(StimulatorSpecs), 'analog_output')
        %     StimulatorSpecs.value = rmfield(value(StimulatorSpecs), 'analog_output');
        % end
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

                if stim_dur(mystim)<100
                    StimulatorSpecs.pre     = unifrnd(stim_pre(mystim)-stim_pre_jitter(mystim),stim_pre(mystim)+stim_pre_jitter(mystim));
                    StimulatorSpecs.dur     = stim_dur(mystim);            
                    StimulatorSpecs.trigger = valid_states{stim_trigger_state(mystim)};
              
                elseif stim_dur(mystim) == 101
                    StimulatorSpecs.pre = unifrnd(0,0+stim_pre_jitter(mystim));    % can't have this be negative
                    StimulatorSpecs.dur = varargin{1};
                    StimulatorSpecs.trigger = 'cpoke1'; 

                elseif stim_dur(mystim) == 102
                    StimulatorSpecs.pre =  unifrnd(max(0, varargin{1}-stim_pre_jitter(mystim)), varargin{1}+stim_pre_jitter(mystim)); 
                    StimulatorSpecs.dur = varargin{2}/2;
                    StimulatorSpecs.trigger = 'cpoke1';

                elseif stim_dur(mystim) == 103
                    predelay = varargin{1} + varargin{2}/2;
                    StimulatorSpecs.pre = unifrnd(max(0, predelay-stim_pre_jitter(mystim)), predelay +stim_pre_jitter(mystim)); 
                    StimulatorSpecs.dur = varargin{2}/2;
                    StimulatorSpecs.trigger = 'cpoke1';

                elseif stim_dur(mystim) == 104
                    predelay = varargin{1} + varargin{2};
                    StimulatorSpecs.pre = unifrnd(max(0, predelay-stim_pre_jitter(mystim)), predelay +stim_pre_jitter(mystim)); 
                    StimulatorSpecs.dur = varargin{3};
                    StimulatorSpecs.trigger = 'cpoke1';
                end

                StimulatorSpecs.freq    = stim_freq(mystim);
                StimulatorSpecs.pulse   = stim_pulse(mystim);
                StimulatorSpecs.power   = [stim_power1(mystim) stim_power2(mystim)];
            
                % if value(stim_is_analog_not_digital)
                %     StimulatorSpecs.ison = mystim;
                %     feval(mfilename, obj, 'set_up_laser_analog_modulation');
                % end
            end;
        end;
      
        ThisStim.value = mystim;
        StimulatorSpecs.ison = mystim;


    %---------------------------------------------------------------%
    %          send_specs_to_cerebro                                %
    %---------------------------------------------------------------%
    case 'send_specs_to_cerebro'
        if value(ThisStim) && CerebroSection(obj,'is_connected')
            CerebroSection(obj,'send_stim_specs',StimulatorSpecs); 
        end


% %% set_up_laser_analog_modulation
%   case 'set_up_laser_analog_modulation'
%     mystim = StimulatorSpecs.ison;
%     StimulatorSpecs.analog_output.line = bSettings('get', 'AO_LINES', 'LASER');
%     StimulatorSpecs.analog_output.clock_speed_hz = bSettings('get', 'GENERAL', 'CLOCK_SPEED_HZ');
%     StimulatorSpecs.analog_output.is_sine_not_square = value(ao_is_sine_not_square);
%     StimulatorSpecs.analog_output.min_V = ao_min_V(mystim);
%     StimulatorSpecs.analog_output.max_V = ao_max_V(mystim);
%     StimulatorSpecs.analog_output.on_ramp_dur_s = ao_on_ramp_dur_s(mystim);
%     StimulatorSpecs.analog_output.off_ramp_dur_s = ao_off_ramp_dur_s(mystim);
%     % simplify nomenclature of variables for manipulation
%     for f = fields(StimulatorSpecs.analog_output)'
%         eval([f{:} ' = StimulatorSpecs.analog_output.' f{:}])
%     end
%     if StimulatorSpecs.freq == 0 % continuous illumination
%         n_samples = clock_speed_hz*StimulatorSpecs.dur;
%         analog_out_V = ones(1,n_samples) * max_V;
%     else
%         clock_cycle_s = 1/clock_speed_hz;
%         t = 0:clock_cycle_s:StimulatorSpecs.dur-clock_cycle_s;
%         StimulatorSpecs.analog_output.time_s = t;
%         if is_sine_not_square
%             t = t*2*pi;
%             t = t*StimulatorSpecs.freq;
%             t = t - pi/2; % to start the output at the trough of the wave
%             analog_out_V = sin(t);
%             analog_out_V = analog_out_V + 1; % to set the trough at zero
%             analog_out_V = analog_out_V * (max_V-min_V)/2; 
%             analog_out_V = analog_out_V + min_V;
%         else
%             t = mod(t, 1/StimulatorSpecs.freq);
%             analog_out_V = min_V*ones(1,numel(t));
%             analog_out_V(t < StimulatorSpecs.pulse/1000) = max_V;
%         end
%     end
%     n_ramp_on  = floor(on_ramp_dur_s  * clock_speed_hz); % number of samples
%     n_ramp_off = floor(off_ramp_dur_s * clock_speed_hz);
%     if n_ramp_on > 0
%         analog_out_V(1:n_ramp_on) = analog_out_V(1:n_ramp_on) .* (1:n_ramp_on)/n_ramp_on;
%     end
%     if n_ramp_off > 0
%         analog_out_V(end-n_ramp_off+1:end) = analog_out_V(end-n_ramp_off+1:end) .* (n_ramp_off:-1:1)/n_ramp_off;
%     end
%     StimulatorSpecs.analog_output.voltage = analog_out_V;
%     % The input 'analog_waveform' to ADD_SCHEDULED_WAVE takes values within the range of [-1,1],
%     % which corresponds to output of [-10, 10] volts by the NIDAQ cards as measured by TZL on 2018-10-19
%     StimulatorSpecs.analog_output.waveform = analog_out_V/10;
% %     disp(StimulatorSpecs.analog_output.waveform)
%       
      

    %---------------------------------------------------------------%
    %          send_specs_to_cerebro                                %
    %---------------------------------------------------------------%
    case 'get_stimulator_specs'
        x = value(StimulatorSpecs);
        return;
      
    %---------------------------------------------------------------%
    %          get_all_stimulator_specs                             %
    %---------------------------------------------------------------%
    case 'get_all_stimulator_specs'
        x = get_history(StimulatorSpecs);
        return;

    %---------------------------------------------------------------%
    %          hide / show_hide / close                             %
    %---------------------------------------------------------------%
    case 'hide',
        stim_show.value = 0;
        feval(mfilename, obj, 'show_hide');
    
    case 'show_hide',
        if value(stim_show) == 1, set(value(myfig), 'Visible', 'on');  %#ok<NODEF>
        else                      set(value(myfig), 'Visible', 'off');
        end;
    
    case 'close'   
        try %#ok<TRYNC>
            if ishandle(value(myfig)), delete(value(myfig)); end;
            delete_sphandle('owner', ['^@' class(obj) '$'], 'fullname', [mfilename '_' tname]);
        end;
    
    %---------------------------------------------------------------%
    %          reinit                                               %
    %---------------------------------------------------------------%
    case 'reinit'
        % Get the original GUI position and figure:
        my_gui_info = value(my_gui_info);
        x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));
        
        % close everything involved with the plugin
        feval(mfilename, obj, 'close');

        % Reinitialise at the original GUI position and figure:
        feval(mfilename, obj, 'init', x, y);


    %---------------------------------------------------------------%
    %          otherwise                                            %
    %---------------------------------------------------------------%
    otherwise
        warning('%s : action "%s" is unknown!', mfilename, action); %#ok<WNTAG> (This line OK.)

end; %     end of switch action

