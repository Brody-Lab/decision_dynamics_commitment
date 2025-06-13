function [x, y] = CerebroSection(obj, action, varargin)

% [x, y] = CerebroSection(obj, action, varargin)
%
% This plugin provides an interface between BControl and a Cerebro 1.0 wireless
% opto device. This includes a GUI for a user to specify commands to send
% to the cerebro, and to visualize responses from the cerebro.
% Additionally, this plugin provides calls for a BControl protocol to
% easily control a Cerebro device during active behavior, including
% changing the cerebro waveform trial-by-trial.
%
% Triggering stimulation works very similar to traditional opto. A "laser"
% DIO is specified in your settings file and triggered in your state
% matrix. This corresponds to a TTL output from the linux machine to the
% cerebro base station.
%
% Unlike traditional opto, what happens when the cerebro is triggered is
% controlled entirely by the "waveform" parameters in the cerebro's onboard
% memory. To change this, you send a new waveform with a serial command to
% the base station using CerebroSection('send_stim_specs',StimulatorSpecs).
% If you want to pulse, the DIO line is only used to initiate and terminate
% the pulse train. The control of the pulses themselves is done by Cerebro,
% according to the waveform parameters in its memory.
%
% If you make your protocol Obj a @cerebro obj, it will have sph's called
% "sent_message_list" and "received_message_list" which contain the full
% trial-by-trial history of serial communication between BControl and the
% Cerebro base station.
%
% Currently this plugin is only compatible with Cerebro 1.0.
%
% You can use this plugin as a standalone GUI to control a
% cerebro outside of BControl if you call it as follows:     
% CerebroSection(cerebro(),'init_standalone');

%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%
%   'init'     Initializes the plugin. Sets up internal variables
%               and the GUI window. Put this in your protocol's "init"
%               section
%
%   'update'  Updates the sent and received messages boxes and inserts new
%   trial numbers when appropriate. Put this in your protocol's "update"
%   section.
%
%   'close'  Closes the window and shuts the serial connection to the base
%   station. Put this in your protocol's "close" section.
%
%   'end_session' Shuts the serial connection to the base station. Put in
%   your protocol's "end_session" section.
%
%   'send_stim_specs' Updates the waveform in cerebro's memory. This takes
%   an additional argument that is a scalar structure with fields
%   "dur","freq","pulse" and "power", very similar to the StimulatorSpecs
%   variable used in the Stimulator plugin that some protocols use to
%   control stimulation. "freq" is interpreted as being in Hz, "pulse" is
%   the duration of a single pulse, in ms. Duration is in seconds. Power is 
%   a 12-bit signed integer (i.e. up to 4096) that the Cerebro DAC uses to set the current 
%   provided to the laser diode. Converting this to mW of power requires 
%   calibration of your implant before surgery and depends on whether or
%   not you are using photodiode feedback.
%   (Additional fields are ignored). You want to call CerebroSection with
%   "send_stim_specs" at the point when the stimulation parameters for an
%   upcoming stim trial are determined, so somewhere within your
%   protocol's "prepare_next_trial" section.
%

% AGB 2018

    GetSoloFunctionArgs(obj);

    switch action

        %% init    
        case 'init'
            %% setup and create some sph's
            addpath([pwd filesep 'cerebro']);     
            if length(varargin) < 2
              error('Need at least two arguments, x and y position, to initialize %s', mfilename);
            end
            x = varargin{1}; y = varargin{2};
            SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);
            SoloParamHandle(obj, 'base_station','value','');
            ToggleParam(obj, 'cerebro_show', 0, x, y, ...
               'OnString', 'Cerebro window Showing', ...
               'OffString', 'Cerebro window Hidden', ...
               'TooltipString', 'Show/Hide Cerebro window'); next_row(y);
            set_callback(cerebro_show, {mfilename, 'show_hide';});  
            SoloParamHandle(obj, 'cerebro_fig', ...
                'value', double(figure('Position', [200 50 700 450], ...
                'closerequestfcn', [mfilename '(' class(obj) ', ''hide''' ');'], 'MenuBar', 'none', ...
                'NumberTitle', 'off', 'Name', 'Cerebro')), 'saveable', 0);
            %% start making gui elements
            x=200;y=15;    
            SoloParamHandle(obj,'received_messages_box','value',...
                uicontrol('style','edit',...
                         'position',[x+250 y 240 400],...
                         'backgroundcolor','w',...
                         'HorizontalAlign','left',...
                         'min',0,'max',15,...
                         'enable','inactive'));
            SoloParamHandle(obj,'sent_message_list','value',{});
            SoloParamHandle(obj,'received_message_list','value',{});    
            uicontrol('style','text',...
                'position',[x+250,y+410, 240 15],...
                'string','Received Messages');             
            SoloParamHandle(obj,'sent_messages_box','value',...
                uicontrol('style','listbox',...
                         'position',[x y+40 240 360],...
                         'backgroundcolor','w',...
                         'HorizontalAlign','left',...
                         'min',0,'max',0,...
                         'enable','inactive'));
            uicontrol('style','text',...
                'position',[x,y+410, 240 15],...
                'string','Sent Messages');    
            SoloParamHandle(obj,'user_message_box','value',...
                uicontrol('style','edit',...
                         'position',[x y 200 30],...
                         'backgroundcolor','w',...
                         'HorizontalAlign','left',...
                         'min',1,'max',1));    
            SoloParamHandle(obj,'send_button','value',...
                uicontrol(value(cerebro_fig),'style','pushbutton',...
                 'String','Send','Callback',{@cerebro_ui_callback,obj,'send_user_message'},...
                 'position',[x+205 y 30 30]));
            %% make base station info panel
            hndl_uipanel_base_station_info = uipanel;            
            set(hndl_uipanel_base_station_info, ...
                'Units', 'normalized', ...
                'Parent', value(cerebro_fig), ...
                'Title', 'Base Station Info', ...
                'Tag', 'uipanelSettings', ...
                'Position', [0.02 0.78 0.25 0.20]);    
            x = 25; y = 395;
            DispParam(obj, 'base_station_version', '', x, y, 'position', [x y 140 30], ...
                'labelfraction', 0.5);
            DispParam(obj, 'base_station_port', '', x, y, 'position', [x y-40 140 30], ...
                'labelfraction', 0.5);
            %% make waveform panel
            hndl_uipanel_current_waveform = uipanel;            
            set(hndl_uipanel_current_waveform, ...
                'Units', 'normalized', ...
                'Parent', value(cerebro_fig), ...
                'Title', 'Current Waveform', ...
                'Tag', 'uipanelSettings', ...
                'Position', [0.02 0.20 0.25 0.56]);    
            x = 25; y=295;
            NumeditParam(obj, 'power', 500, x, y, 'position', [x y 140 30], ...
                'labelfraction', 0.5,...
                'TooltipString','current cerebro power value');
            NumeditParam(obj, 'duration', 500, x, y, 'position', [x y-35 140 30], ...
                'labelfraction', 0.5,...
                'TooltipString','current cerebro duration value (ms). N.B.: this should be longer than ever necessary if you are using a TTL to turn on and off');
            NumeditParam(obj, 'ontime', 0, x, y, 'position', [x y-70 140 30], ...
                'labelfraction', 0.5,...
                'TooltipString','current cerebro ontime value (ms; for pulsing)');
            NumeditParam(obj, 'offtime', 0, x, y, 'position', [x y-105 140 30], ...
                'labelfraction', 0.5,...
                'TooltipString','current cerebro offtime value (ms; for pulsing)');
            NumeditParam(obj, 'ramp', 0, x, y, 'position', [x y-140 140 30], ...
                'labelfraction', 0.5,...
                'TooltipString','current cerebro ramp value');    
            SoloParamHandle(obj,'update_button','value',...
                uicontrol(value(cerebro_fig),'style','pushbutton',...
                 'String','Update','Callback',{@cerebro_ui_callback,obj,'send_current_waveform'},...
                 'position',[25 115 60 30],'TooltipString','Update waveform'));
            SoloParamHandle(obj,'trigger_button','value',...     
                uicontrol(value(cerebro_fig),'style','pushbutton',...
                 'String','Trigger','Callback',{@cerebro_ui_callback,obj,'send_message','T'},...
                 'position',[105 115 60 30],'TooltipString','Trigger current waveform'));    
             ToggleParam(obj,'lock_cerebro',0,20,50,'position',[30 50 150 30],'OnString','Cerebro Locked',...
                 'TooltipString','allow or disable user interactivty','OffString','Cerebro Unlocked');
             set_callback(lock_cerebro,{mfilename,'apply_lock'});
             SoloParamHandle(obj,'local_n_started_trials','value',n_started_trials);             
             %% initialize base station
            feval(mfilename,obj,'initialize_base_station');
            
            %Reverting back to main protocol figure window and hide
            %PsychometricsSection window
            figure(my_gui_info(3));
            feval(mfilename, obj, 'hide');            
        
        %% initialize base station
        case 'initialize_base_station'
            try
                base_station.value  = cerebro_init();
            catch
                base_station.value=[];
            end
            if isempty(value(base_station))
                base_station_version.value='not connected'; 
                feval(mfilename,obj,'lock');
            else
                set(value(base_station),'timeout',0.2,...
                    'BytesAvailableFcn',{@cerebro_ui_callback,obj,'read_messages'},...
                    'BytesAvailableFcnMode','byte');
                fopen(value(base_station));
                feval(mfilename,obj,'reboot');pause(0.1);
                feval(mfilename,obj,'send_current_waveform');
                base_station_version.value =  feval(mfilename,obj,'get_base_station_info');
                base_station_port.value =   get(value(base_station),'Port');         
            end  
            
        %% insert trial header (for easier parsing of message history)
        case 'insert_trial_header'
            if nargin>2
                received_message_list.value = [value(received_message_list);{''};varargin{1}];
                set(value(received_messages_box),'string',value(received_message_list));    
                sent_message_list.value = [value(sent_message_list);{''};varargin{1}];
                set(value(sent_messages_box),'string',value(sent_message_list));              
            else
               warning('CerebroSection: additional input argument required with insert_trial_header flag.');
            end            
            
        %% get_base_station_info    
        case 'get_base_station_info'
            past_messages = value(received_message_list);
            base_station_line = strncmp(past_messages,'Base',4);
            parse_attempt = regexprep(past_messages,'.*: ([0-9-]*-[0-9]*-[0-9]*).*','$1');
            if any(base_station_line)
                x = parse_attempt{find(base_station_line,1,'last')};     
            else
                feval(mfilename,obj,'send_message','V');
                past_messages = value(received_message_list);
                base_station_line = strncmp(past_messages,'Base',4);
                parse_attempt = regexprep(past_messages,'.*: ()','$1');
                x = parse_attempt{find(base_station_line,1,'last')}; 
            end                
            
        %% get last waveform
        case 'get_last_waveform'
            waveforms = ~cellfun(@isempty,regexp(value(received_message_list),...
                '[0-9]*,[0-9]*,[0-9]*,[0-9]*,[0-9]*'));
            last_waveform_idx=find(waveforms,1,'last');
            if isempty(last_waveform_idx)
                x=[];
                return
            end
            tmp=value(received_message_list);
            x = tmp{last_waveform_idx};
            x=regexprep(x,'.*= ()','$1');
            x=regexprep(x,'.*Sent,()','$1');           
            x=deblank(x);
            if strcmp(x(1),',')
                x=x(2:end);
            end
            if strcmp(x(end),',')
                x=x(1:end-1);
            end
            x = cellfun(@str2num,splitstr(x,','));
            power.value = x(1);
            duration.value = x(2);
            ontime.value = x(3);
            offtime.value = x(4);
            ramp.value = x(5);       
            
        %% is connected
        case 'is_connected'
            x = isa(value(base_station),'serial') && isvalid(value(base_station));
            
        %% lock, i.e. the GUI if not cerebro is available
        case 'lock'
            if ~value(lock_cerebro)
                lock_cerebro.value=true;               
            end
            feval(mfilename,obj,'apply_lock');
            
        %% read messages
        case 'read_messages'
            if feval(mfilename,obj,'is_connected')
                x = fscanf(value(base_station));  
                [x,tmp] = regexp(x,'\r','split','match');
                x=cellfun(@deblank,x,'uniformoutput',false)';
                x=x(~cellfun(@isempty,x));
                if ~isempty(x)
                    received_message_list.value = [value(received_message_list);x];
                    set(value(received_messages_box),'string',value(received_message_list));    
                end
            else
                warning('Cerebro not connected. Cannot execute request to read messages.');
            end

        %% reboot (resets base station's clock, i.e. millis() )
        case 'reboot'
            feval(mfilename,obj,'send_message','R');
            
        %% send message    
        case 'send_message'          
            sent_message_list.value = [value(sent_message_list);varargin{1}];  
            set(value(sent_messages_box),'string',value(sent_message_list));      
            fprintf(value(base_station),varargin{1});
            drawnow;            
            startWaitForBytes=tic;
            while toc(startWaitForBytes)<3
                serial_obj=value(base_station);
                if serial_obj.BytesAvailable
                    feval(mfilename,obj,'read_messages');                    
                    break
                end
            end
            feval(mfilename,obj,'get_last_waveform');
        

        %% send waveform
        case 'send_waveform'
            % the base station can only receive integer-valued waveform
            % values so round if necessary and warn the user
            wave = varargin{1};
            rounded_wave = round(wave);
            if any(rounded_wave~=wave)
                warning('CerebroSection: waveform must be an integer vector! Rounding was used.');
            end
            feval(mfilename,obj,'send_message',[num2str(rounded_wave(1)),',',num2str(rounded_wave(2)),','...
                num2str(rounded_wave(3)),',',num2str(rounded_wave(4)),',',num2str(rounded_wave(5))]);

        %% send current waveform 
        case 'send_current_waveform' %% callback for numedit params
            feval(mfilename,obj,'send_waveform',...
                [value(power) value(duration) value(ontime) value(offtime) value(ramp)]);     

        %% send stim specs
        case 'send_stim_specs' %% gets called by stimulator section (or PBups section), easy way to interpret the structure syntax of these other functions
            specs = varargin{1};
            [ontime,offtime] = get_on_off_time(specs.pulse,specs.freq);
            feval(mfilename,obj,'send_waveform',...
                [specs.power specs.dur*1000*2 ontime offtime value(ramp)]);  %stimulatorspecs duration is in seconds so we need to convert. and to be safe, multiply by two to let bcontrol determine the timing.      
        
        %% send user message
        case 'send_user_message'
            user_message = get(value(user_message_box),'String');
            set(value(user_message_box),'String','');
            feval(mfilename,obj,'send_message',user_message);

        %% apply lock
        case 'apply_lock' % applys lock button
            switch value(lock_cerebro)
                case true
                    disable(power);
                    disable(duration);
                    disable(ontime);
                    disable(offtime);
                    disable(ramp);
                    set(value(update_button),'enable','inactive');
                    set(value(trigger_button),'enable','inactive'); 
                    set(value(user_message_box),'enable','inactive');
                    set(value(send_button),'enable','inactive');                
                case false
                    enable(power);
                    enable(duration);
                    enable(ontime);
                    enable(offtime);
                    enable(ramp);
                    set(value(update_button),'enable','on');
                    set(value(trigger_button),'enable','on');  
                    set(value(user_message_box),'enable','on');   
                    set(value(send_button),'enable','on');                                
            end
            
        case 'update'
            if feval(mfilename,obj,'is_connected')
                serial_obj=value(base_station);
                if serial_obj.BytesAvailable
                    feval(mfilename,obj,'read_messages');
                end
                if n_started_trials>local_n_started_trials
                    feval(mfilename,obj,'insert_trial_header',['Trial ',num2str(n_started_trials),':']); 
                    local_n_started_trials.value=n_started_trials;
                end
            end
            

        %% hide, show_hide
        case 'hide'
            cerebro_show.value = 0;
            feval(mfilename, obj, 'show_hide');

        %% toggle show and hide
        case 'show_hide'
            if value(cerebro_show) == 1, set(value(cerebro_fig), 'Visible', 'on');  %#ok<NODEF>
            else                      set(value(cerebro_fig), 'Visible', 'off');
            end

        %% close
        case 'close'   
            try %#ok<TRYNC>
                feval(mfilename,obj,'serial_shutdown');
                if ishandle(value(cerebro_fig)), delete(value(cerebro_fig)); end
            end

        %% close_standalone
        case 'close_standalone'   
            if ishandle(value(cerebro_fig)), delete(value(cerebro_fig)); end
            delete(obj);
                
        %% reinit
        case 'reinit'
            % Get the original GUI position and figure:
            my_gui_info = value(my_gui_info);
            x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));
            % close everything involved with the plugin
            feval(mfilename, obj, 'close');
            % Reinitialise at the original GUI position and figure:
            feval(mfilename, obj, 'init', x, y);

        %% end session (and close serial object)
        case 'end_session'
            feval(mfilename,obj,'serial_shutdown');
            
        case 'serial_shutdown'
            if feval(mfilename,obj,'is_connected')
                fclose(value(base_station));
                delete(value(base_station));
            end            

        %% init    
        case 'init_standalone'
            %% setup and create some sph's
            addpath([pwd filesep 'cerebro']);     
            SoloParamHandle(obj, 'base_station','value','');
            SoloParamHandle(obj, 'cerebro_fig', ...
                'value', double(figure('Position', [200 50 700 450], ...
                'closerequestfcn', [mfilename '(' class(obj) ', ''close_standalone''' ');'], 'MenuBar', 'none', ...
                'NumberTitle', 'off', 'Name', 'CerebroSection')), 'saveable', 0);
            %% start making gui elements
           
            %% make base station info panel
            hndl_uipanel_base_station_info = uipanel( ...                'Units', 'normalized', ...
                'Parent', value(cerebro_fig), ...
                'Title', 'Base Station Info', ...
                'Tag', 'uipanelSettings', ...
                'Position', [0.02 0.78 0.25 0.20]);    
            x = 25; y = 395;
            DispParam(obj, 'base_station_version', '', x, y, 'position', [x y 140 30], ...
                'labelfraction', 0.5);
            DispParam(obj, 'base_station_port', '', x, y, 'position', [x y-40 140 30], ...
                'labelfraction', 0.5);
            %% make waveform panel
            hndl_uipanel_current_waveform = uipanel;            
            set(hndl_uipanel_current_waveform, ...
                'Units', 'normalized', ...
                'Parent', value(cerebro_fig), ...
                'Title', 'Current Waveform', ...
                'Tag', 'uipanelSettings', ...
                'Position', [0.02 0.20 0.25 0.56]);    
            x = 25; y=295;
            NumeditParam(obj, 'power', 0, x, y, 'position', [x y 140 30], ...
                'labelfraction', 0.5,...
                'TooltipString','current cerebro power value');
            NumeditParam(obj, 'duration', 0, x, y, 'position', [x y-35 140 30], ...
                'labelfraction', 0.5,...
                'TooltipString','current cerebro duration value (ms). N.B.: this should be longer than ever necessary if you are using a TTL to turn on and off');
            NumeditParam(obj, 'ontime', 0, x, y, 'position', [x y-70 140 30], ...
                'labelfraction', 0.5,...
                'TooltipString','current cerebro ontime value (ms; for pulsing)');
            NumeditParam(obj, 'offtime', 0, x, y, 'position', [x y-105 140 30], ...
                'labelfraction', 0.5,...
                'TooltipString','current cerebro offtime value (ms; for pulsing)');
            NumeditParam(obj, 'ramp', 0, x, y, 'position', [x y-140 140 30], ...
                'labelfraction', 0.5,...
                'TooltipString','current cerebro ramp value');    
            SoloParamHandle(obj,'update_button','value',...
                uicontrol(value(cerebro_fig),'style','pushbutton',...
                 'String','Update','Callback',{@cerebro_ui_callback,obj,'send_current_waveform'},...
                 'position',[25 115 60 30],'TooltipString','Update waveform'));
            SoloParamHandle(obj,'trigger_button','value',...     
                uicontrol(value(cerebro_fig),'style','pushbutton',...
                 'String','Trigger','Callback',{@cerebro_ui_callback,obj,'send_message','T'},...
                 'position',[105 115 60 30],'TooltipString','Trigger current waveform'));    
             ToggleParam(obj,'lock_cerebro',0,20,50,'position',[30 50 150 30],'OnString','Cerebro Locked',...
                 'TooltipString','allow or disable user interactivty','OffString','Cerebro Unlocked');
             set_callback(lock_cerebro,{mfilename,'apply_lock'});
             %%make message boxes
              x=200;y=15;    
            SoloParamHandle(obj,'received_messages_box','value',...
                uicontrol('style','edit',...
                         'position',[x+250 y 240 400],...
                         'backgroundcolor','w',...
                         'HorizontalAlign','left',...
                         'min',0,'max',15,...
                         'enable','inactive'));
            SoloParamHandle(obj,'sent_message_list','value',{});
            SoloParamHandle(obj,'received_message_list','value',{});    
            uicontrol('style','text',...
                'position',[x+250,y+410, 240 15],...
                'string','Received Messages');             
            SoloParamHandle(obj,'sent_messages_box','value',...
                uicontrol('style','listbox',...
                         'position',[x y+40 240 360],...
                         'backgroundcolor','w',...
                         'HorizontalAlign','left',...
                         'min',0,'max',0,...
                         'enable','inactive'));
            uicontrol('style','text',...
                'position',[x,y+410, 240 15],...
                'string','Sent Messages');    
            SoloParamHandle(obj,'user_message_box','value',...
                uicontrol('style','edit',...
                         'position',[x y 200 30],...
                         'backgroundcolor','w',...
                         'HorizontalAlign','left',...
                         'min',1,'max',1));    
            SoloParamHandle(obj,'send_button','value',...
                uicontrol(value(cerebro_fig),'style','pushbutton',...
                 'String','Send','Callback',{@cerebro_ui_callback,obj,'send_user_message'},...
                 'position',[x+205 y 30 30]));
             %% initialize base station
            feval(mfilename,obj,'initialize_base_station');
            if ~feval(mfilename,obj,'is_connected')
                disable(lock_cerebro);
                h=errordlg('No cerebro base station found!','Connection Error');
                set(h,'DeleteFcn',{@cerebro_ui_callback,obj,'close_standalone'});
            end
        %% otherwise    
        otherwise
            warning('%s : action "%s" is unknown!', mfilename, action); %#ok<WNTAG> (This line OK.)
    end
end

%% helper functions

function [ontime,offtime] = get_on_off_time(pulse,freq)
    % pulse in ms, freq in Hz, ontime and offtime in ms
    if pulse==0 || freq==0
        ontime=0;
        offtime=0;
    else
        offtime = (1000/freq)- pulse;
        ontime = pulse;
    end
end
    
function cerebro_ui_callback(src,event,obj,flag,varargin)
    CerebroSection(obj,flag,varargin{:});
end 