function [x, y] = CerebroSection(obj, action, varargin)

% [x, y] = CerebroSection(obj, action, varargin)
%
% This plugin provides an interface between BControl and a Cerebro 2.0 wireless
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
% Currently this plugin is only compatible with Cerebro 2.0.
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
% updated by Chuck 10/2019 for cerebro 2


    GetSoloFunctionArgs(obj);

    switch action

        %% init_standalone    
        case 'init_standalone'
            %% setup and create some sph's    
            
            SoloParamHandle(obj, 'cerebro_fig', ...
                'value', double(figure('Position', [50 50 850 450],... %[200 50 700 450], ...
                'closerequestfcn', [mfilename '(' class(obj) ', ''close_standalone''' ');'], 'MenuBar', 'none', ...
                'NumberTitle', 'off', 'Name', 'CerebroSection')), 'saveable', 0);
            
            SoloParamHandle(obj, 'PingDispatcher', 'value', 0);
            
            feval(mfilename,obj,'make_gui_elements');
            GetSoloFunctionArgs(obj);
            
            %% initialize base station
            feval(mfilename,obj,'initialize_base_station');
            if ~feval(mfilename,obj,'is_connected')
                disable(lock_cerebro);
                h=errordlg('No cerebro base station found!','Connection Error');
                set(h,'DeleteFcn',{@cerebro_ui_callback,obj,'close_standalone'});
            end
            
        %% init    
        case 'init'
            %% setup and create some sph's
            if length(varargin) < 2
              error('Need at least two arguments, x and y position, to initialize %s', mfilename);
            end
            x = varargin{1}; y = varargin{2};
            SoloParamHandle(obj, 'PingDispatcher', 'value', 1);
            SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);
            ToggleParam(obj, 'cerebro_show', 0, x, y, ...
               'OnString', 'Cerebro window Showing', ...
               'OffString', 'Cerebro window Hidden', ...
               'TooltipString', 'Show/Hide Cerebro window'); next_row(y);
            set_callback(cerebro_show, {mfilename, 'show_hide'});  
            SoloParamHandle(obj, 'cerebro_fig', ...
                'value', double(figure('Position', [50 50 850 450], ...
                'closerequestfcn', [mfilename '(' class(obj) ', ''hide''' ');'], 'MenuBar', 'none', ...
                'NumberTitle', 'off', 'Name', 'CerebroSection')), 'saveable', 0);
            
            feval(mfilename,obj,'make_gui_elements');
            GetSoloFunctionArgs(obj);
            
            SoloParamHandle(obj,'local_n_started_trials','value',n_started_trials); 
            
            %% initialize base station
            feval(mfilename,obj,'initialize_base_station');
            %if ~feval(mfilename,obj,'is_connected')
            %    disable(lock_cerebro);
            %    h=errordlg('No cerebro base station found!','Connection Error');
            %    set(h,'DeleteFcn',{@cerebro_ui_callback,obj,'close_standalone'});
            %end
            
            %Reverting back to main protocol figure window and hide
            %Cerebro window
            figure(my_gui_info(3));
            feval(mfilename, obj, 'hide');            
        
        %% initialize base station
        case 'initialize_base_station'
            try
                base_station.value  = cerebro2_init;
            catch
                base_station.value=[];
            end
            if isempty(value(base_station))
                base_station_version.value='not connected'; 
                feval(mfilename,obj,'lock');
            else
                set(value(base_station),'timeout',0.2,...
                    'BytesAvailableFcn',{@cerebro_ui_callback,obj,'read_messages'},...
                    'BytesAvailableFcnMode','terminator');
                fopen(value(base_station));
                
                %Send all zeros to clear out last program
                feval(mfilename,obj,'send_current_waveform');
                
                x = tic;
                while value(did_read) == 0
                    pause(0.1);
                    if toc(x) > 10
                        %There is a base station on this rig but no cerebro
                        %in range so let's move on and finish this later
                        found_cerebro.value = 0;
                        break;
                    end
                end
                if value(found_cerebro) ~= 0; found_cerebro.value = 1; end
                did_read.value = 0;
                
                %This will send an N which will extract all info
                feval(mfilename,obj,'reboot');
                
                if value(found_cerebro) == 1
                    while value(did_read) == 0
                        pause(0.1);
                    end
                    did_read.value = 0;
                else
                    pause(5);
                    feval(mfilename,obj,'read_messages');
                end
                
                base_station_port.value =   get(value(base_station),'Port'); 
            end  
            
            
        %% extract info from received message
        case 'extract'
            x = [];
            y = '';
            try
                msg = varargin{1};
                bit = [];
                for i = numel(msg):-1:1
                    if isempty(msg{i}); continue; end
                    if msg{i}(end) ~= char(10)
                        msg{i}(end+1) = char(10);
                    end
                    
                    newlines = find(double(msg{i}) == 10);
                    semicolons = find(msg{i} == ';');
                    if newlines(end) < numel(msg{i})
                        newlines(end+1) = numel(msg{i})+1;
                    end
                    
                    if strcmp(varargin{2},'base_version')
                        match = 'Base Version,';
                    elseif strcmp(varargin{2},'cerebro_version')
                        match = 'Cerebro Version,';
                    elseif strcmp(varargin{2},'base_channel')
                        match = 'Base Channel,';    
                    elseif strcmp(varargin{2},'cerebro_channel')
                        match = 'Channel:';       
                    elseif strcmp(varargin{2},'battery')
                        match = 'Battery,';     
                    elseif strcmp(varargin{2},'diode_powers')
                        match = 'Diode Powers,';     
                    elseif strcmp(varargin{2},'waveform')
                        match = 'Waveform,';   
                    elseif strcmp(varargin{2},'feedback')
                        match = 'Feedback,';   
                    elseif strcmp(varargin{2},'failed')
                        match = 'Update Failed';   
                    elseif strcmp(varargin{2},'abort')
                        match = 'Abort';      
                    elseif strcmp(varargin{2},'error')
                        match = 'Error';     
                    end

                    if strcmp(varargin{2},'TTL')
                        match = {', TTL input went high.',', TTL input went low.'};
                        breakout = 0;
                        bit = [];
                        for m=1:2
                            pos = strfind(msg{i},match{m});
                            if ~isempty(pos)
                                previousnewline = find(newlines < pos(end),1,'last');
                                if isempty(previousnewline); previousnewline = 0; 
                                else previousnewline = newlines(previousnewline);
                                end
                                bit(end+1) = str2num(msg{i}(previousnewline+1:pos(end)-1));
                                if ~isempty(bit)
                                    y = msg{i}(previousnewline+1:pos(end)+numel(match{m})-1);
                                    breakout = 1;
                                end
                            end
                        end
                        if breakout == 1; 
                            x = bit;
                            if numel(bit) == 2 && all(bit ~= 0)
                                y = ['TTL high for ',num2str(bit(2)-bit(1)),' from ',num2str(bit(1)),' to ',num2str(bit(2))];
                            end
                            break; 
                        end
                    elseif strcmp(varargin{2},'failed')
                        pos = strfind(msg{i},match);
                        if ~isempty(pos)   
                            previousnewline = find(newlines < pos(end),1,'last');
                            if isempty(previousnewline); previousnewline = 0; 
                            else previousnewline = newlines(previousnewline);
                            end
                            bit = msg{i}(previousnewline+1:pos(end)-1);
                            if ~isempty(bit)
                                y = msg{i}(previousnewline+1:pos(end)+numel(match)-1);
                            end
                        end
                    elseif strcmp(varargin{2},'abort')
                        pos = strfind(msg{i},match);
                        if ~isempty(pos) 
                            y = 'Abort';
                        end
                    else
                        pos = strfind(msg{i},match);
                        if ~isempty(pos)    
                            nextnewline = find(newlines > pos(end),1,'first');
                            if ~isempty(semicolons)
                                nextsemicolon = find(semicolons > pos(end),1,'first');
                            else
                                nextsemicolon = [];
                            end
                            if ~isempty(nextsemicolon) && semicolons(nextsemicolon) < newlines(nextnewline)
                                nextbreak = semicolons(nextsemicolon);
                            else
                                nextbreak = newlines(nextnewline);
                            end
                            if isempty(nextbreak); nextbreak = numel(msg{i})+1; end
                            
                            bit = msg{i}(pos(end)+numel(match):nextbreak-1);
                            if ~isempty(bit)
                                y = msg{i}(pos(end):nextbreak-1);
                                break;
                            end
                        end
                    end
                end
                
                if ~isempty(bit)
                    if strcmp(varargin{2},'base_version')
                        x = str2num(bit);
                        base_station_version.value = x;
                    elseif strcmp(varargin{2},'cerebro_version')
                        x = str2num(bit);
                        cerebro_version.value = x;
                    elseif strcmp(varargin{2},'base_channel')
                        x = str2num(bit);
                        cerebro_channel.value = x;
                    elseif strcmp(varargin{2},'battery')
                        x = str2num(bit);
                        battery_power.value = x;  
                    elseif strcmp(varargin{2},'diode_powers')
                        brks = [0,find(bit=='-'),numel(bit)+1];
                        x = [];
                        for j = 1:numel(brks)-1
                            x(j) = str2num(bit(brks(j)+1:brks(j+1)-1));
                        end
                        power.value_callback = x;
                    elseif strcmp(varargin{2},'waveform')
                        brks = [0,find(bit=='-'),numel(bit)+1];
                        x = [];
                        for j = 1:numel(brks)-1
                            x(j) = str2num(bit(brks(j)+1:brks(j+1)-1));
                        end
                        delay.value = x(1);
                        ontime.value = x(2);
                        offtime.value = x(3);
                        duration.value = x(4);
                        ramp.value = x(5);
                    elseif strcmp(varargin{2},'feedback')
                        brks = [0,find(bit=='-'),numel(bit)+1];
                        x = [];
                        for j = 1:numel(brks)-1
                            x(j) = str2num(bit(brks(j)+1:brks(j+1)-1));
                        end    
                    elseif strcmp(varargin{2},'failed')
                        
                    end
                end
                    
            catch
                disp('Cannot extract info')
                x = [];
                y = '';
            end
            
        %% insert trial header (for easier parsing of message history)
        case 'insert_trial_header'
            if nargin>2
                received_message_list.value = [value(received_message_list);{''};varargin{1}];
                set(value(received_messages_box),'string',value(received_message_list),'ListboxTop',numel(value(received_message_list))) 
                
                received_raw_message_list.value = [value(received_raw_message_list),varargin{1}];
                
                sent_message_list.value = [value(sent_message_list);{''};varargin{1}];
                set(value(sent_messages_box),'string',value(sent_message_list),'ListboxTop',numel(value(sent_message_list)));              
            else
               warning('CerebroSection: additional input argument required with insert_trial_header flag.');
            end            
            
        %% get_base_station_info    
        case 'get_base_station_info'
            past_messages = value(received_message_list);
            base_station_line = strncmp(past_messages,'Base',4);
            x = [];
            if any(base_station_line)
                [x,y] = feval(mfilename,obj,'extract',past_messages,'base_version');     
            else
                feval(mfilename,obj,'send_message','?');
                past_messages = value(received_message_list);
                base_station_line = strncmp(past_messages,'Base',4);
                if any(base_station_line)
                    [x,y] = feval(mfilename,obj,'extract',past_messages,'base_version'); 
                end
            end    
            
        %% get last waveform
        case 'get_last_waveform'
            x = value(received_message_list);
            [x,y] = feval(mfilename,obj,'extract',x,'waveform');
                   
            
        %% is connected
        case 'is_connected'
            x = exist('base_station','var') && isa(value(base_station),'serial') && isvalid(value(base_station));
        
        
        %% is cerebro connected
        case 'is_cerebro_connected'    
        x = 0;
        if feval(mfilename,obj,'is_connected')
            x = ~isempty(value(cerebro_version)) && ~isempty(value(battery_power));
        end
        
            
        %% lock, i.e. the GUI if not cerebro is available
        case 'lock'
            if ~value(lock_cerebro)
                lock_cerebro.value=true;               
            end
            feval(mfilename,obj,'apply_lock');
            
        %% read messages
        case 'read_messages'
            if feval(mfilename,obj,'is_connected')
                
                warning('off','MATLAB:serial:fscanf:unsuccessfulRead');
                x = cell(0);
                base = value(base_station);
                while base.BytesAvailable > 0
                    pause(0.05);
                    disp([num2str(base.BytesAvailable),' bytes available to read...']);
                    x{end+1} = fscanf(value(base_station)); %#ok<AGROW>
                    disp(['received ',num2str(numel(x{end}))]);
                    did_read.value = 1;
                    if isempty(x{end})
                        disp('Bytes Available but none read.');
                    end
                end
                for i=1:numel(x); disp(x{i}); end; disp('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
                warning('on','MATLAB:serial:fscanf:unsuccessfulRead');
                parsed_message = '';
                
                if ~isempty(x)
                    [a,b] = feval(mfilename,obj,'extract',x,'base_version');
                    if ~isempty(b); parsed_message = [parsed_message,';',b]; end
                    
                    [a,b] = feval(mfilename,obj,'extract',x,'base_channel');
                    if ~isempty(b); parsed_message = [parsed_message,';',b]; end
                    
                    [a,b] = feval(mfilename,obj,'extract',x,'cerebro_version');
                    if ~isempty(b); parsed_message = [parsed_message,';',b]; end
                    
                    [a,b] = feval(mfilename,obj,'extract',x,'cerebro_channel');
                    if ~isempty(b); parsed_message = [parsed_message,';',b]; end
                    
                    [a,b] = feval(mfilename,obj,'extract',x,'diode_powers');
                    if ~isempty(b); parsed_message = [parsed_message,';',b]; end
                    
                    [a,b] = feval(mfilename,obj,'extract',x,'waveform');
                    if ~isempty(b); parsed_message = [parsed_message,';',b]; end
                    
                    [a,b] = feval(mfilename,obj,'extract',x,'feedback');
                    if ~isempty(b); parsed_message = [parsed_message,';',b]; end
                    
                    [a,b] = feval(mfilename,obj,'extract',x,'TTL');
                    if ~isempty(b); parsed_message = [parsed_message,';',b]; end
                    
                    [a,b] = feval(mfilename,obj,'extract',x,'battery');
                    if ~isempty(b); parsed_message = [parsed_message,';',b]; end
                    
                    [a,b] = feval(mfilename,obj,'extract',x,'failed');
                    if ~isempty(b); parsed_message = [parsed_message,';',b]; end
                    
                    [a,b] = feval(mfilename,obj,'extract',x,'abort');
                    if ~isempty(b); parsed_message = [parsed_message,';',b]; end
                    
                    [a,b] = feval(mfilename,obj,'extract',x,'error');
                    if ~isempty(b); parsed_message = [parsed_message,';',b]; end
                    
                    if numel(parsed_message)>1
                        if parsed_message(1) == ';'; parsed_message = parsed_message(2:end); end
                    end
                
                    received_message_list.value = [value(received_message_list);parsed_message];
                    set(value(received_messages_box),'string',value(received_message_list),'ListboxTop',numel(value(received_message_list)));

                    raw_message_list_temp = value(received_raw_message_list);
                    raw_message_list_temp(end+1:end+numel(x)) = x;
                    received_raw_message_list.value = raw_message_list_temp;
                    
                    feval(mfilename,obj,'get_last_waveform');
                end
                
                if value(battery_power) < value(battery_minimum)
                    feval(mfilename,obj,'zero_out','LOW BATTERY');
                end
            else
                warning('Cerebro not connected. Cannot execute request to read messages.');
            end

        %% reboot (resets base station's clock, i.e. millis() )
        case 'reboot'
            feval(mfilename,obj,'send_message','N');
            %R does not appear to be recognized by cerebro2, N resets
            %clocks and counters
            
        %% zero_out    
        case 'zero_out'
            if feval(mfilename,obj,'is_connected')
                if any(value(power) ~= 0) || value(ontime) ~= 0 || value(duration) ~= 0 || value(ramp) ~= 0
                    power.value_callback = [0 0];
                    delay.value = 0;
                    ontime.value = 0;
                    offtime.value = 0;
                    duration.value = 0;
                    ramp.value = 0;

                    cerebro2_send(value(base_station),'F,0,0,0,0,0,0,0');
                    
                    if nargin < 3; msg = '';
                    else           msg = varargin{1}; end

                    sent_message_list.value = [value(sent_message_list);['F,0,0,0,0,0,0,0 ',msg]];
                end
            end
            
        %% send message    
        case 'send_message'          
            if feval(mfilename,obj,'is_connected')
                base = value(base_station);
                if base.BytesAvailable > 0
                    feval(mfilename,obj,'read_messages');
                end

                if value(battery_power) < value(battery_minimum)

                    %battery is low, let's send one more waveform to zero it
                    %out so laser cannot be triggered again, and then stop
                    %sending all messages
                    feval(mfilename,obj,'zero_out','LOW BATTERY');

                    sent_message_list.value = [value(sent_message_list);[varargin{1},' NOT SENT LOW BATTERY']];
                    set(value(sent_messages_box),'string',value(sent_message_list),'ListboxTop',numel(value(sent_message_list))); 
                else
                    if value(PingDispatcher) == 1
                        sent_message_list.value = [value(sent_message_list);[varargin{1},'   at ',num2str(dispatcher('get_time')),'s']];
                    else
                        sent_message_list.value = [value(sent_message_list);[varargin{1},'   at ',datestr(now,'HH:MM:SS')]];
                    end
                    set(value(sent_messages_box),'string',value(sent_message_list),'ListboxTop',numel(value(sent_message_list)));      

                    cerebro2_send(value(base_station),varargin{1});
                end
            end
            
        %% send waveform
        case 'send_waveform'
            % the base station can only receive integer-valued waveform
            % values so round if necessary and warn the user
            wave = varargin{1};
            rounded_wave = round(wave);
            if any(rounded_wave~=wave)
                warning('CerebroSection: waveform must be an integer vector! Rounding was used.');
            end
            feval(mfilename,obj,'send_message',['F,',...
                num2str(rounded_wave(1)),',',...
                num2str(rounded_wave(2)),',',...
                num2str(rounded_wave(3)),',',...
                num2str(rounded_wave(4)),',',...
                num2str(rounded_wave(5)),',',...
                num2str(rounded_wave(6)),',',...
                num2str(rounded_wave(7))]);

        %% send current waveform 
        case 'send_current_waveform' %% callback for numedit params
            feval(mfilename,obj,'send_waveform',...
                [value(power) value(delay) value(ontime) value(offtime) value(duration) value(ramp)]);     

        %% send stim specs
        case 'send_stim_specs' %% gets called by stimulator section (or PBups section), easy way to interpret the structure syntax of these other functions
            
            if value(battery_power) >= value(battery_minimum)
                %only accept specs if battery is good
                specs = varargin{1};
                [ont,offt] = get_on_off_time(specs.pulse,specs.freq,specs.dur);
                
                real_power.value_callback = specs.power;
                delay.value = specs.pre;
                ontime.value = ont;
                offtime.value = offt;
                duration.value = specs.dur*1000*2;  
                %stimulatorspecs duration is in seconds so we need to convert. 
                %and to be safe, multiply by two to let bcontrol determine the timing.  
            else
                %battery is low, let's zero out the waveform
                real_power.value = [0 0];
                power.value = [0 0];
                delay.value = 0;
                ontime.value = 0;
                offtime.value = 0;
                duration.value = 0;
                ramp.value = 0;
                
            end
            
            %we still make the call to send current waveform since it will
            %zero out if it hasn't already done so and it will comment the
            %waveform it would have sent but didn't
            feval(mfilename,obj,'send_current_waveform');
            
            %We are generally doing this at the end of one trial before the
            %start of the trial with the opto stim, so we should make sure
            %the update went through before we move along
            did_read.value = 0;
            x = tic;
            while value(did_read) == 0
                pause(0.1);
                if toc(x) > 10
                    %Clearly something isn't working so let's move along
                    disp('Did not read cerebro after 10 seconds.');
                    break;
                end
            end
            
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
                    disable(delay)
                    disable(ontime);
                    disable(offtime);
                    disable(duration);
                    disable(ramp);
                    set(value(update_button),'enable','inactive');
                    set(value(trigger_button),'enable','inactive'); 
                    set(value(user_message_box),'enable','inactive');
                    set(value(send_button),'enable','inactive');                
                case false
                    enable(power);
                    enable(delay);
                    enable(ontime);
                    enable(offtime);
                    enable(duration);
                    enable(ramp);
                    set(value(update_button),'enable','on');
                    set(value(trigger_button),'enable','on');  
                    set(value(user_message_box),'enable','on');   
                    set(value(send_button),'enable','on');                                
            end
         
        %% update    
        case 'update'
            if feval(mfilename,obj,'is_connected')
                if exist('n_started_trials','var') && exist('local_n_started_trials','var')
                    if n_started_trials>local_n_started_trials
                        if value(PingDispatcher) == 1
                            feval(mfilename,obj,'insert_trial_header',['Trial ',num2str(n_started_trials),': ',num2str(dispatcher('get_time')),'s  ',datestr(now,'HH:MM:SS')]);
                        else
                            feval(mfilename,obj,'insert_trial_header',['Trial ',num2str(n_started_trials),': ',datestr(now,'HH:MM:SS')]);
                        end
                        local_n_started_trials.value=n_started_trials;
                    end
                end
                
                serial_obj=value(base_station);
                if serial_obj.BytesAvailable
                    feval(mfilename,obj,'read_messages');
                end
            end
            
        %% update power    
        case 'update_power'
            %user has changed the real_power value so we need to use the
            %calibration values to determine the cerebro power values
            rp = value(real_power);
            rp(rp < 0) = 0;
            real_power.value = rp;
            
            d1 = value(diode1);
            d2 = value(diode2);
            
            p = value(power);
            if numel(d1) == 2
                p(1) = (rp(1) * d1(1)) + d1(2);
            else
                disp('Unable to update diode 1 power');
            end
            
            if numel(d2) == 2 && numel(rp) == 2
                p(2) = (rp(2) * d2(1)) + d2(2);
            else
                disp('Unable to update diode 2 power');
            end
            p(p < 0) = 0;
            p(rp == 0) = 0;
            
            power.value = round(p);
            
        %% update real power    
        case 'update_real_power'
            %user has changed the cerebro power values so we need to use
            %the calibration values to determine the real power values
            rp = value(real_power);
            d1 = value(diode1);
            d2 = value(diode2);
            
            p = value(power);
            p(p < 0) = 0;
            if numel(d1) == 2
                rp(1) = (p(1) - d1(2)) / d1(1);
            else
                disp('Unable to update diode 1 real power');
            end
            
            if numel(d2) == 2 && numel(p) == 2
                rp(2) = (p(2) - d2(2)) / d2(1);
            else
                disp('Unable to update diode 2 real power');
            end
            rp(rp < 0) = 0;
            rp(p == 0) = 0;
            real_power.value = rp;
            

        %% hide, show_hide
        case 'hide'
            cerebro_show.value = 0;
            feval(mfilename, obj, 'show_hide');

        %% toggle show and hide
        case 'show_hide'
            if value(cerebro_show) == 1, set(value(cerebro_fig), 'Visible', 'on');  %#ok<NODEF>
            else                         set(value(cerebro_fig), 'Visible', 'off');
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
        
        %% serial shutdown    
        case 'serial_shutdown'
            if feval(mfilename,obj,'is_connected')
                fclose(value(base_station));
                delete(value(base_station));
                disp('Base Station CLOSED');
            end 
            
        %% set
        case 'set_real_power'
            real_power.value_callback = varargin{1};
            
        %% set_did_read
        case 'set_did_read'
            did_read.value = varargin{1};
            
        %% get_did_read
        case 'get_did_read'
            x = value(did_read);     
            
        %% make_gui_elements    
        case 'make_gui_elements'
            
            SoloParamHandle(obj, 'base_station','value','');
            
            %% make base station info panel
            hndl_uipanel_base_station_info = uipanel;
            set(hndl_uipanel_base_station_info,...                
                'Units', 'normalized', ...
                'Parent', value(cerebro_fig), ...
                'Title', 'Base Station Info', ...
                'Tag', 'uipanelSettings', ...
                'Position', [0.02 0.81 0.20 0.18]);    
            x = 25; y = 410;
            DispParam(obj, 'base_station_version', '', x, y, 'position', [x y 160 18], ...
                'labelfraction', 0.7);
            DispParam(obj, 'base_station_port', '', x, y, 'position', [x y-20 160 18], ...
                'labelfraction', 0.7);
            
            %% make waveform panel
            hndl_uipanel_current_waveform = uipanel;            
            set(hndl_uipanel_current_waveform, ...
                'Units', 'normalized', ...
                'Parent', value(cerebro_fig), ...
                'Title', 'Current Waveform', ...
                'Tag', 'uipanelSettings', ...
                'Position', [0.02 0.40 0.20 0.46]);    
            x = 25; y=355;
            NumeditParam(obj, 'real_power', [0,0], x, y, 'position', [x y 160 18], ...
                'labelfraction', 0.45,...
                'TooltipString','actual laser diode power output in mW, uses calibration values');
            set_callback(real_power,{mfilename,'update_power'});
            NumeditParam(obj, 'power', [0,0], x, y, 'position', [x y-20 160 18], ...
                'labelfraction', 0.45,...
                'TooltipString','current cerebro power value');
            set_callback(power,{mfilename,'update_real_power'});
            NumeditParam(obj, 'delay', 0, x, y, 'position', [x y-40 160 18], ...
                'labelfraction', 0.45,...
                'TooltipString','current cerebro power value');
            NumeditParam(obj, 'ontime', 0, x, y, 'position', [x y-60 160 18], ...
                'labelfraction', 0.45,...
                'TooltipString','current cerebro ontime value (ms; for pulsing)');
            NumeditParam(obj, 'offtime', 0, x, y, 'position', [x y-80 160 18], ...
                'labelfraction', 0.45,...
                'TooltipString','current cerebro offtime value (ms; for pulsing)');
            NumeditParam(obj, 'duration', 0, x, y, 'position', [x y-100 160 18], ...
                'labelfraction', 0.45,...
                'TooltipString','current cerebro duration value (ms). N.B.: this should be longer than ever necessary if you are using a TTL to turn on and off');
            NumeditParam(obj, 'ramp', 0, x, y, 'position', [x y-120 160 18], ...
                'labelfraction', 0.45,...
                'TooltipString','current cerebro ramp value');    
            %SoloParamHandle(obj,'update_button','value',...
            %    uicontrol(value(cerebro_fig),'style','pushbutton',...
            %     'String','Update','Callback',{@cerebro_ui_callback,obj,'send_current_waveform'},...
            %     'position',[x y-142 53 20],'TooltipString','Update waveform'));
            PushbuttonParam(obj,'update_button',x,y,'position',[x y-142 53 20],'label','Update','TooltipString','Update waveform');
            set_callback(update_button,{mfilename,'send_current_waveform'});
            
            %SoloParamHandle(obj,'trigger_button','value',...     
            %    uicontrol(value(cerebro_fig),'style','pushbutton',...
            %    'String','Trigger','Callback',{@cerebro_ui_callback,obj,'send_message','T'},...
            %    'position',[x+55 y-142 53 20],'TooltipString','Trigger current waveform')); 
            PushbuttonParam(obj,'trigger_button',x,y,'position',[x+55 y-142 53 20],'label','Trigger','TooltipString','Trigger current waveform');
            set_callback(trigger_button,{mfilename,'send_message','T'});
            
            %SoloParamHandle(obj,'abort_button','value',...     
            %    uicontrol(value(cerebro_fig),'style','pushbutton',...
            %    'String','Abort','Callback',{@cerebro_ui_callback,obj,'send_message','A'},...
            %    'position',[x+110 y-142 53 20],'TooltipString','Abort current waveform'));  
            PushbuttonParam(obj,'abort_button',x,y,'position',[x+110 y-142 53 20],'label','Abort','TooltipString','Abort current waveform');
            set_callback(abort_button,{mfilename,'send_message','A'});
            
            ToggleParam(obj,'lock_cerebro',0,20,50,'position',[x y-164 160 20],'OnString','Cerebro Locked',...
                'TooltipString','allow or disable user interactivty','OffString','Cerebro Unlocked');
            set_callback(lock_cerebro,{mfilename,'apply_lock'});
             
            %% make cerebro box
            x = 25; y = 146;
            hndl_uipanel_cerebro_info = uipanel;            
            set(hndl_uipanel_cerebro_info, ...
                'Units', 'normalized', ...
                'Parent', value(cerebro_fig), ...
                'Title', 'Cerebro Info', ...
                'Tag', 'uipanelSettings', ...
                'Position', [0.02 0.16 0.20 0.24]); 
            
            DispParam(obj, 'cerebro_channel', '', x, y, 'position', [x y 160 20], ...
                'labelfraction', 0.7);
            DispParam(obj, 'cerebro_version', '', x, y, 'position', [x y-22 160 20], ...
                'labelfraction', 0.7);
            DispParam(obj, 'battery_power', '', x, y, 'position', [x y-44 160 20], ...
                'labelfraction', 0.7,...
                'TooltipString','Battery value returned from cerebro, range from 0 (dead) to 100 (full)');
            NumeditParam(obj, 'battery_minimum', 10, x, y, 'position', [x y-66 160 20], ...
                'labelfraction', 0.7,...
                'TooltipString','Minimum battery value allowed for stimulation to still happen.');
            
            %% make calibration box
            x = 25; y = 35;
            hndl_uipanel_calibration = uipanel;            
            set(hndl_uipanel_calibration, ...
                'Units', 'normalized', ...
                'Parent', value(cerebro_fig), ...
                'Title', 'Diode Calibration', ...
                'Tag', 'uipanelSettings', ...
                'Position', [0.02 0.01 0.20 0.15]); 
            
            NumeditParam(obj, 'diode1', [61.25 568.7], x, y, 'position', [x y 160 20], ...
                'labelfraction', 0.3,...
                'TooltipString','Calibration values for diode 1');
            
            NumeditParam(obj, 'diode2', [55.99 709.5], x, y, 'position', [x y-22 160 20], ...
                'labelfraction', 0.3,...
                'TooltipString','Calibration values for diode 2');
            
             
            %% make message boxes
            x=200;y=15;    
            SoloParamHandle(obj,'received_messages_box','value',...
                uicontrol('style','listbox',...
                         'position',[x+250 y+40 395 360],...
                         'backgroundcolor','w',...
                         'HorizontalAlign','left',...
                         'min',0,'max',0,...
                         'enable','inactive'));
            SoloParamHandle(obj,'sent_message_list','value',{});
            SoloParamHandle(obj,'received_message_list','value',{});    
            SoloParamHandle(obj,'received_raw_message_list','value',{});
            %uicontrol('style','text',...
            %    'position',[x+250,y+410, 240 15],...
            %    'string','Received Messages');  
            HeaderParam(obj,'received_messages','Received Messages',x,y,'position',[x+250,y+410, 240 20]);
            
            SoloParamHandle(obj,'sent_messages_box','value',...
                uicontrol('style','listbox',...
                         'position',[x y+40 240 360],...
                         'backgroundcolor','w',...
                         'HorizontalAlign','left',...
                         'min',0,'max',0,...
                         'enable','inactive'));
            %uicontrol('style','text',...
            %    'position',[x,y+410, 240 15],...
            %    'string','Sent Messages');   
            HeaderParam(obj,'sent_messages','Sent Messages',x,y,'position',[x,y+410, 240 20]);
            
            SoloParamHandle(obj,'user_message_box','value',...
                uicontrol('style','edit',...
                         'position',[x y 200 30],...
                         'backgroundcolor','w',...
                         'HorizontalAlign','left',...
                         'min',1,'max',1));    
            %SoloParamHandle(obj,'send_button','value',...
            %    uicontrol(value(cerebro_fig),'style','pushbutton',...
            %     'String','Send','Callback',{@cerebro_ui_callback,obj,'send_user_message'},...
            %     'position',[x+205 y 40 30]));
            PushbuttonParam(obj,'send_button',x,y,'position',[x+205,y,40,30],'label','Send');
            set_callback(send_button,{mfilename,'send_user_message'});
             
            SoloParamHandle(obj,'did_read','value',0); 
            SoloParamHandle(obj,'found_cerebro','value',nan); 
            
        %% otherwise    
        otherwise
            warning('%s : action "%s" is unknown!', mfilename, action); %#ok<WNTAG> (This line OK.)
    end
end

%% helper functions

function [ontime,offtime] = get_on_off_time(pulse,freq,dur)
    % pulse in ms, freq in Hz, ontime and offtime in ms
    if pulse==0 && freq==0
        ontime=dur*1000*2;
        offtime=0;
    else
        offtime = (1000/freq)- pulse;
        ontime = pulse;
    end
end
    
function cerebro_ui_callback(src,event,obj,flag,varargin)
    CerebroSection(obj,flag,varargin{:});
end 