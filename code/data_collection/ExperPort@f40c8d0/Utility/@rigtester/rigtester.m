%RIGTESTER: Utility to diagnose problems with rigs

function [obj, varargout] = rigtester(varargin)


% <~> Argument handling (This interface method is technically a
% constructor.)
if nargin==0
    obj = class(struct, mfilename);
    return;
end
if ischar(varargin{1})
    action = varargin{1};
    obj = class(struct, mfilename);
elseif isa(varargin{1}, mfilename)
    obj = varargin{1};
    if nargin<2
        return;
    else
        action = varargin{2};
    end
end
    


GetSoloFunctionArgs(obj);


switch action
    %% CASE INIT
    case 'init'
        %This section initializes the GUI, sets element callbacks
        %e.g. rigtester('init');
        error(nargchk(1, 1, nargin, 'struct'));
        
        
        state_machine_server = bSettings('get', 'RIGS', 'state_machine_server');
        sound_machine_server = bSettings('get', 'RIGS', 'sound_machine_server');
        Rig_ID = bSettings('get', 'RIGS', 'Rig_ID');
        card_slot = bSettings('get', 'RIGS', 'card_slot');
        server_slot = bSettings('get', 'RIGS', 'server_slot');
        
        
        SoloParamHandle(obj, 'GUI_NAME', 'value', 'RIG_TESTER_GUI');
        SoloParamHandle(obj, 'SOUND_LEFT', 'value', 1);
        SoloParamHandle(obj, 'SOUND_RIGHT', 'value', 2);
        SoloParamHandle(obj, 'SOUND_LEFT_RIGHT', 'value', 3);
        SoloParamHandle(obj, 'timerObj_Period', 'value', 0.1); %seconds
        SoloParamHandle(obj, 'defaultPulseTime', 'value', 1); %seconds
        
        
        SoloParamHandle(obj, 'left1water', 'value', bSettings('get', 'DIOLINES', 'left1water'));
        SoloParamHandle(obj, 'left1led', 'value', bSettings('get', 'DIOLINES', 'left1led'));
        SoloParamHandle(obj, 'center1water', 'value', bSettings('get', 'DIOLINES', 'center1water'));
        SoloParamHandle(obj, 'center1led', 'value', bSettings('get', 'DIOLINES', 'center1led'));
        SoloParamHandle(obj, 'right1water', 'value', bSettings('get', 'DIOLINES', 'right1water'));
        SoloParamHandle(obj, 'right1led', 'value', bSettings('get', 'DIOLINES', 'right1led'));
        
        
        SoloParamHandle(obj, 'HANDLES', 'value', []); %Stores the child handles of the main rig_tester_gui
        SoloParamHandle(obj, 'sm', 'value', []); %RTLSM2 object
        SoloParamHandle(obj, 'sndm', 'value', []); %RTLSoundMachine object
        SoloParamHandle(obj, 'sma', 'value', []); %StateMachineAssembler object
        SoloParamHandle(obj, 'EVENTS_LIST', 'value', []); %Array which stores all events.
        SoloParamHandle(obj, 'REMOVE_THESE_PATHS', 'value', {}); %Cell array containing paths to remove
        
        SoloParamHandle(obj, 'rig_tester_gui', ...
            'value', figure('WindowStyle', 'normal', 'Units', 'characters', 'Name', value(GUI_NAME), 'Visible', 'on', 'Menubar', 'None'), ...
            'saveable', false);
        
        set(value(rig_tester_gui), 'Position', [10   10  110.2000   38.4615]);
        set(value(rig_tester_gui), 'CloseRequestFcn', [mfilename '(''close'')']);
        set(value(rig_tester_gui), 'Resize', 'on');
        
        REMOVE_THESE_PATHS{end+1} = pwd; %#ok<NASGU>
        addpath(pwd);
        
        %% Creating GUI elements
        HeaderParam(obj, 'textHeader', 'RIG TEST UTILITY', 1, 1);
        set(get_ghandle(textHeader), ...
            'Parent', value(rig_tester_gui), ...
            'Units', 'characters', ...
            'Style', 'text', ...
            'BackgroundColor', 'cyan', ...
            'Tag', 'textHeader', ...
            'FontSize', 13.0, ...
            'FontName', 'Monospaced', ...
            'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center', ...
            'Position', [9.6 32.923 90.2 2.231]);
        
        HeaderParam(obj, 'textHeader2', ['RIG: ' num2str(Rig_ID) ', LINUX MACHINE: ' state_machine_server], 1, 1);
        set(get_ghandle(textHeader2), ...
            'Parent', value(rig_tester_gui), ...
            'Units', 'characters', ...
            'Style', 'text', ...
            'BackgroundColor', 'cyan', ...
            'Tag', 'textHeader', ...
            'FontSize', 10.0, ...
            'FontName', 'Monospaced', ...
            'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center', ...
            'Position', [9.6 30.692 90.2 2.231]);
        
        
        PushbuttonParam(obj, 'btnHelp', 1, 1);
        set(get_ghandle(btnHelp), ...
            'Parent', value(rig_tester_gui), ...
            'Units', 'characters', ...
            'Tag', 'btnHelp', ...
            'FontSize', 13.0, ...
            'FontName', 'Monospaced', ...
            'FontWeight', 'bold', ...
            'String', '?', ...
            'HorizontalAlignment', 'center', ...
            'Position', [93.6 32.077 4.8 1.769]);
        set_callback(btnHelp, {mfilename, 'btnHelpCallback'});
        
        
        uipanel('Parent', value(rig_tester_gui), ...
            'Units', 'characters', ...
            'Tag', 'uipanelLeftPoke', ...
            'FontSize', 10.0, ...
            'FontWeight', 'bold', ...
            'Position', [9.6 17.846 30.2 11.615], ...
            'Title', 'LEFT POKE', ...
            'BackgroundColor', 'green', ...
            'TitlePosition', 'centertop');
        
        uipanel('Parent', value(rig_tester_gui), ...
            'Units', 'characters', ...
            'Tag', 'uipanelCenterPoke', ...
            'FontSize', 10.0, ...
            'FontWeight', 'bold', ...
            'Position', [39.6 17.846 30.2 11.615], ...
            'Title', 'CENTER POKE', ...
            'BackgroundColor', 'green', ...
            'TitlePosition', 'centertop');
        
        uipanel('Parent', value(rig_tester_gui), ...
            'Units', 'characters', ...
            'Tag', 'uipanelRightPoke', ...
            'FontSize', 10.0, ...
            'FontWeight', 'bold', ...
            'Position', [69.6 17.846 30.2 11.615], ...
            'Title', 'RIGHT POKE', ...
            'BackgroundColor', 'green', ...
            'TitlePosition', 'centertop');
        
        uipanel('Parent', value(rig_tester_gui), ...
            'Units', 'characters', ...
            'Tag', 'uipanelBypass', ...
            'FontSize', 8.0, ...
            'FontWeight', 'normal', ...
            'Position', [4.6 7.077 100.4 8.308], ...
            'Title', 'Bypass', ...
            'TitlePosition', 'lefttop');
        
        handles = guihandles(value(rig_tester_gui));
        ToggleParam(obj, 'btnLeftLED', false, 1, 1, 'OnString', 'Left LED', 'OffString', 'Left LED');
        set(get_ghandle(btnLeftLED), ...
            'Parent', handles.uipanelBypass, ...
            'Units', 'characters', ...
            'Tag', 'btnLeftLED', ...
            'String', 'Left LED', ...
            'HorizontalAlignment', 'center', ...
            'Position', [5 4.692 20.2 2]);
        set_callback(btnLeftLED, {mfilename, 'btnLeftLEDCallback'});
        
        %I didn't want set_callback to change the color scheme, so this is
        %a workaround.
        SoloParamHandle(obj, 'OnBackgroundColor', 'value', get(get_ghandle(btnLeftLED), 'BackgroundColor'));
        SoloParamHandle(obj, 'OnForegroundColor', 'value', get(get_ghandle(btnLeftLED), 'ForegroundColor'));
        
        
        ToggleParam(obj, 'btnLeftWater', false, 1, 1, 'OnString', 'Left Water', 'OffString', 'Left Water');
        set(get_ghandle(btnLeftWater), ...
            'Parent', handles.uipanelBypass, ...
            'Units', 'characters', ...
            'Tag', 'btnLeftWater', ...
            'String', 'Left Water', ...
            'HorizontalAlignment', 'center', ...
            'Position', [5 2.769 20.2 2]);
        set_callback(btnLeftWater, {mfilename, 'btnLeftWaterCallback'});
        
        
        ToggleParam(obj, 'btnLeftSpeaker', false, 1, 1, 'OnString', 'Left Speaker', 'OffString', 'Left Speaker');
        set(get_ghandle(btnLeftSpeaker), ...
            'Parent', handles.uipanelBypass, ...
            'Units', 'characters', ...
            'Tag', 'btnLeftSpeaker', ...
            'String', 'Left Speaker', ...
            'HorizontalAlignment', 'center', ...
            'Position', [5 0.846 20.2 2]);
        set_callback(btnLeftSpeaker, {mfilename, 'btnLeftSpeakerCallback'});
        
        
        ToggleParam(obj, 'btnCenterLED', false, 1, 1, 'OnString', 'Center LED', 'OffString', 'Center LED');
        set(get_ghandle(btnCenterLED), ...
            'Parent', handles.uipanelBypass, ...
            'Units', 'characters', ...
            'Tag', 'btnCenterLED', ...
            'String', 'Center LED', ...
            'HorizontalAlignment', 'center', ...
            'Position', [40 4.692 20.2 2]);
        set_callback(btnCenterLED, {mfilename, 'btnCenterLEDCallback'});
        
        ToggleParam(obj, 'btnCenterWater', false, 1, 1, 'OnString', 'Center Water', 'OffString', 'Center Water');
        set(get_ghandle(btnCenterWater), ...
            'Parent', handles.uipanelBypass, ...
            'Units', 'characters', ...
            'Tag', 'btnCenterWater', ...
            'String', 'Center Water', ...
            'HorizontalAlignment', 'center', ...
            'Position', [40 2.769 20.2 2]);
        set_callback(btnCenterWater, {mfilename, 'btnCenterWaterCallback'});
        
        
        ToggleParam(obj, 'btnRightLED', false, 1, 1, 'OnString', 'Right LED', 'OffString', 'Right LED');
        set(get_ghandle(btnRightLED), ...
            'Parent', handles.uipanelBypass, ...
            'Units', 'characters', ...
            'Tag', 'btnRightLED', ...
            'String', 'Right LED', ...
            'HorizontalAlignment', 'center', ...
            'Position', [75 4.692 20.2 2]);
        set_callback(btnRightLED, {mfilename, 'btnRightLEDCallback'});
        
        
        ToggleParam(obj, 'btnRightWater', false, 1, 1, 'OnString', 'Right Water', 'OffString', 'Right Water');
        set(get_ghandle(btnRightWater), ...
            'Parent', handles.uipanelBypass, ...
            'Units', 'characters', ...
            'Tag', 'btnRightWater', ...
            'String', 'Right Water', ...
            'HorizontalAlignment', 'center', ...
            'Position', [75 2.769 20.2 2]);
        set_callback(btnRightWater, {mfilename, 'btnRightWaterCallback'});
        
        
        ToggleParam(obj, 'btnRightSpeaker', false, 1, 1, 'OnString', 'Right Speaker', 'OffString', 'Right Speaker');
        set(get_ghandle(btnRightSpeaker), ...
            'Parent', handles.uipanelBypass, ...
            'Units', 'characters', ...
            'Tag', 'btnRightSpeaker', ...
            'String', 'Right Speaker', ...
            'HorizontalAlignment', 'center', ...
            'Position', [75 0.846 20.2 2]);
        set_callback(btnRightSpeaker, {mfilename, 'btnRightSpeakerCallback'});
        
        
        ToggleParam(obj, 'btnToggleOrPulse', false, 1, 1, 'OnString', 'Pulse ON', 'OffString', 'Toggle ON');
        set(get_ghandle(btnToggleOrPulse), ...
            'Parent', value(rig_tester_gui), ...
            'Tag', 'btnToggleOrPulse', ...
            'Units', 'characters', ...
            'HorizontalAlignment', 'center', ...
            'Position', [55.2 4.615 20.2 1.769]);
        set_callback(btnToggleOrPulse, {mfilename, 'btnToggleOrPulseCallback'});
        
        
        %uicontrol('Parent', value(rig_tester_gui), ...
        %    'Units', 'characters', ...
        %    'Position', [34.4 4.615 20.2 1.769], ...
        %    'Style', 'radiobutton', ...
        %    'String', 'Toggle', ...
        %    'Tag', 'radioToggle', ...
        %    'Value', true, ...
        %    'Enable', 'inactive', ...
        %    'Callback', ['feval(''' mfilename ''', ''radioToggleCallback'');']);
        
        %uicontrol('Parent', value(rig_tester_gui), ...
        %    'Units', 'characters', ...
        %    'Position', [55.2 4.615 20.2 1.769], ...
        %    'Style', 'radiobutton', ...
        %    'String', 'Pulse', ...
        %    'Tag', 'radioPulse', ...
        %    'Value', false, ...
        %    'Callback', ['feval(''' mfilename ''', ''radioPulseCallback'');']);
        
        NumeditParam(obj, 'editPulseTime_seconds', value(defaultPulseTime), 1, 1);
        set(get_ghandle(editPulseTime_seconds), ...
            'Parent', value(rig_tester_gui), ...
            'Units', 'characters', ...
            'Tag', 'editPulseTime_seconds', ...
            'String', num2str(value(defaultPulseTime)), ...
            'Style', 'edit', ...
            'HorizontalAlignment', 'center', ...
            'Position', [55.6 2.308 11.6 1.538], ...
            'Enable', 'off');
        set(get_lhandle(editPulseTime_seconds), ...
            'Visible', 'off');
        
        HeaderParam(obj, 'textPulseTime_seconds', 'Pulse Time (seconds)', 1, 1);
        set(get_ghandle(textPulseTime_seconds), ...
            'Parent', value(rig_tester_gui), ...
            'Units', 'characters', ...
            'Tag', 'textPulseTime_seconds', ...
            'String', 'Pulse Time (seconds)', ...
            'FontSize', 10.0, ...
            'Style', 'text', ...
            'HorizontalAlignment', 'center', ...
            'Position', [67 2.308 27.8 1.538]);
        
        handles = guihandles(value(rig_tester_gui));
        if(any(isnan(value(left1led))))
            set(handles.btnLeftLED, 'Enable', 'off');
        end
        if(any(isnan(value(left1water))))
            set(handles.btnLeftWater, 'Enable', 'off');
        end
        if(any(isnan(value(center1led))))
            set(handles.btnCenterLED, 'Enable', 'off');
        end
        if(any(isnan(value(center1water))))
            set(handles.btnCenterWater, 'Enable', 'off');
        end
        if(any(isnan(value(right1led))))
            set(handles.btnRightLED, 'Enable', 'off');
        end
        if(any(isnan(value(right1water))))
            set(handles.btnRightWater, 'Enable', 'off');
        end
        
      
        
        inputlines_offset = bSettings('get', 'INPUTLINES_MISC', 'offset');
        if isnan(inputlines_offset)
            inputlines_offset = 0;
        end
        diolines_offset = bSettings('get', 'DIOLINES_MISC', 'offset');
        if isnan(diolines_offset)
            diolines_offset = 0;
        end
        
        
        sm.value = RTLSM2(state_machine_server, 3333, server_slot);
        sm.value = Initialize(value(sm));
        sndm.value = RTLSoundMachine(sound_machine_server, 3334, card_slot);
        soundvec = 0.005*sin(2*pi*2000*(0:1/GetSampleRate(value(sndm)):1));
        soundvec = (soundvec(:)).';
        sound_left = [soundvec; zeros(1, length(soundvec))];
        sound_right = [zeros(1, length(soundvec)); soundvec];
        sound_left_right = [soundvec; soundvec];
        sndm.value = LoadSound(value(sndm), value(SOUND_LEFT), sound_left, 'both', 3, 0, 1);
        sndm.value = LoadSound(value(sndm), value(SOUND_RIGHT), sound_right, 'both', 3, 0, 1);
        sndm.value = LoadSound(value(sndm), value(SOUND_LEFT_RIGHT), sound_left_right, 'both', 3, 0, 1);
        sma.value = StateMachineAssembler('full_trial_structure');
        sma.value = add_state(value(sma), 'name', 'start_state', 'self_timer', 0.001, ...
            'input_to_statechange', {'Tup', 'current_state+1'});
        sma.value = add_state(value(sma), 'name', 'state_1', 'self_timer', 999999, ...
            'input_to_statechange', {'Tup', 'current_state'});
        dout_lines = bSettings('get', 'DIOLINES', 'all');
        dout_lines_array = cell2num(dout_lines(:,2));
        send(value(sma), value(sm), ...
        'input_lines', struct('C', 1+inputlines_offset, 'L', 2+inputlines_offset, 'R', 3+inputlines_offset), ...
        'dout_lines', [num2str(diolines_offset) '-' num2str(diolines_offset+log2(max(dout_lines_array)))]);
        sm.value = Run(value(sm));
        sm.value = ForceState0(value(sm));
        
        HANDLES.value = guihandles(value(rig_tester_gui));
        
        timerObj1 = timer('TimerFcn', [mfilename '(''recalculate_bypass'');'], 'Period', value(timerObj_Period), 'ExecutionMode', 'fixedSpacing');
        timerObj2 = timer('TimerFcn', [mfilename '(''monitor_inputs'');'], 'Period', value(timerObj_Period), 'ExecutionMode', 'fixedSpacing');
        start(timerObj1);
        start(timerObj2);
        %% CASE btnHelpCallback
    case 'btnHelpCallback'
        msgbox('Use the toggle buttons to set the status of the output lines manually. This can be done in Toggle mode or in Pulse mode. Activating the pokes should change the color on the GUI window.');
        
        %% CASE btnLeftLEDCallback
    case 'btnLeftLEDCallback'
        if value(btnToggleOrPulse) %false == toggle, true == pulse
            feval(mfilename, obj, 'set_enable_timer', 'btnLeftLED');
        end
        
        %% CASE btnLeftWaterCallback
    case 'btnLeftWaterCallback'
        if value(btnToggleOrPulse)
            feval(mfilename, obj, 'set_enable_timer', 'btnLeftWater');
        end
        
        %% CASE btnLeftSpeakerCallback
    case 'btnLeftSpeakerCallback'
        if value(btnLeftSpeaker) && ~value(btnRightSpeaker)
            PlaySound(value(sndm), value(SOUND_LEFT));
        elseif value(btnRightSpeaker) && ~value(btnLeftSpeaker)
            PlaySound(value(sndm), value(SOUND_RIGHT));
        elseif value(btnLeftSpeaker) && value(btnRightSpeaker)
            PlaySound(value(sndm), value(SOUND_LEFT_RIGHT));
        elseif ~value(btnLeftSpeaker) && ~value(btnRightSpeaker)
            StopSound(value(sndm));
        end
        if value(btnToggleOrPulse)
            feval(mfilename, obj, 'set_enable_timer', 'btnLeftSpeaker');           
        end
        
        %% CASE btnCenterLEDCallback
    case 'btnCenterLEDCallback'
        if value(btnToggleOrPulse)
            feval(mfilename, obj, 'set_enable_timer', 'btnCenterLED');
        end
        
        %% CASE btnCenterWaterCallback
    case 'btnCenterWaterCallback'
        if value(btnToggleOrPulse)
            feval(mfilename, obj, 'set_enable_timer', 'btnCenterWater');
        end
        
        %% CASE btnRightLEDCallback
    case 'btnRightLEDCallback'
        if value(btnToggleOrPulse)
            feval(mfilename, obj, 'set_enable_timer', 'btnRightLED');
        end
        
        %% CASE btnRightWaterCallback
    case 'btnRightWaterCallback'
        if value(btnToggleOrPulse)
            feval(mfilename, obj, 'set_enable_timer', 'btnRightWater');
        end
        
        %% CASE btnRightSpeakerCallback
    case 'btnRightSpeakerCallback'
        if value(btnLeftSpeaker) && ~value(btnRightSpeaker)
            PlaySound(value(sndm), value(SOUND_LEFT));
        elseif value(btnRightSpeaker) && ~value(btnLeftSpeaker)
            PlaySound(value(sndm), value(SOUND_RIGHT));
        elseif value(btnLeftSpeaker) && value(btnRightSpeaker)
            PlaySound(value(sndm), value(SOUND_LEFT_RIGHT));
        elseif ~value(btnLeftSpeaker) && ~value(btnRightSpeaker)
            StopSound(value(sndm));
        end
        if value(btnToggleOrPulse)
            feval(mfilename, obj, 'set_enable_timer', 'btnRightSpeaker');           
        end
        
        
        %% CASE set_enable_timer
    case 'set_enable_timer'
        start_string = ['obj = ' mfilename '; feval(''' mfilename ''', obj, ''onstart_enable_timer'', ''' varargin{3} '''); clear(''obj'');'];
        callback_string = ['obj = ' mfilename '; feval(''' mfilename ''', obj, ''onstop_enable_timer'', ''' varargin{3} '''); clear(''obj'');'];
        timerObj2 = timer('TimerFcn', callback_string, 'StartDelay', value(editPulseTime_seconds), 'StartFcn', start_string);
        start(timerObj2);
        
        
        %% CASE onstart_enable_timer
    case 'onstart_enable_timer'
        sphDisableElement = eval(varargin{3});
        set(get_ghandle(sphDisableElement), 'Enable', 'off');
        
        
        
        %% CASE onstop_enable_timer
    case 'onstop_enable_timer'
        sphEnableElement = eval(varargin{3});
        sphEnableElement.value = false;
        set(get_ghandle(sphEnableElement), 'Enable', 'on');
        sphEnableElementTag = get(get_ghandle(sphEnableElement), 'Tag');
        if strcmpi(sphEnableElementTag, 'btnLeftSpeaker') || strcmpi(sphEnableElementTag, 'btnRightSpeaker')
            if value(btnLeftSpeaker) && ~value(btnRightSpeaker)
                PlaySound(value(sndm), value(SOUND_LEFT));
            elseif value(btnRightSpeaker) && ~value(btnLeftSpeaker)
                PlaySound(value(sndm), value(SOUND_RIGHT));
            elseif value(btnLeftSpeaker) && value(btnRightSpeaker)
                PlaySound(value(sndm), value(SOUND_LEFT_RIGHT));
            elseif ~value(btnLeftSpeaker) && ~value(btnRightSpeaker)
                StopSound(value(sndm));
            end
        end
        
        
        %% CASE btnToggleOrPulseCallback
    case 'btnToggleOrPulseCallback'
        btnLeftLED.value = false;
        btnLeftWater.value = false;
        btnLeftSpeaker.value = false;
        btnCenterLED.value = false;
        btnCenterWater.value = false;
        btnRightLED.value = false;
        btnRightWater.value = false;
        btnRightSpeaker.value = false;
        if value(btnToggleOrPulse) == false
            set(get_ghandle(editPulseTime_seconds), 'Enable', 'off');
        else
            set(get_ghandle(editPulseTime_seconds), 'Enable', 'on');
        end
        StopSound(value(sndm));
        
        %% CASE recalculate_bypass
    case 'recalculate_bypass'
        %This case runs every timerObJ_Period seconds
        %Step 1: Recalculate bypass for left1led, left1water, center1led,
        %center1water, right1led, right1water
        sum = 0;
        if ~isnan(value(left1led))
            sum = sum + value(btnLeftLED)*value(left1led);
        end
        if ~isnan(value(left1water))
            sum = sum + value(btnLeftWater)*value(left1water);
        end
        if ~isnan(value(center1led))
            sum = sum + value(btnCenterLED)*value(center1led);
        end
        if ~isnan(value(center1water))
            sum = sum + value(btnCenterWater)*value(center1water);
        end
        if ~isnan(value(right1led))
            sum = sum + value(btnRightLED)*value(right1led);
        end
        if ~isnan(value(right1water))
            sum = sum + value(btnRightWater)*value(right1water);
        end
        BypassDout(value(sm), sum);
        
    %% CASE monitor_inputs
    case 'monitor_inputs'
        %Monitor Cin, Lin, and Rin events
        n_EVENTS_LIST = GetEventCounter(value(sm));
        if n_EVENTS_LIST > size(value(EVENTS_LIST), 1)
            newEVENTS_LIST = GetEvents2(value(sm), size(value(EVENTS_LIST), 1)+1, n_EVENTS_LIST);
            strevs = disassemble(value(sma), newEVENTS_LIST);
            for ii=1:size(strevs,1)
                %fprintf([strevs{ii, 2} '\n']);
                if strcmpi(strtrim(strevs{ii, 2}), 'Cin')
                    set(HANDLES.uipanelCenterPoke, 'BackgroundColor', 'red');
                elseif strcmpi(strtrim(strevs{ii, 2}), 'Lin')
                    set(HANDLES.uipanelLeftPoke, 'BackgroundColor', 'red');
                elseif strcmpi(strtrim(strevs{ii, 2}), 'Rin')
                    set(HANDLES.uipanelRightPoke, 'BackgroundColor', 'red');
                elseif strcmpi(strtrim(strevs{ii, 2}), 'Cout')
                    set(HANDLES.uipanelCenterPoke, 'BackgroundColor', 'green');
                elseif strcmpi(strtrim(strevs{ii, 2}), 'Lout')
                    set(HANDLES.uipanelLeftPoke, 'BackgroundColor', 'green');
                elseif strcmpi(strtrim(strevs{ii, 2}), 'Rout')
                    set(HANDLES.uipanelRightPoke, 'BackgroundColor', 'green');
                end
            end
            EVENTS_LIST.value = [value(EVENTS_LIST); newEVENTS_LIST];
        end
            
     
        %% CASE close
    case 'close'
        out = timerfind;
        for ctr = 1:length(out)
            try
                stop(out(ctr));
            catch %#ok<CTCH>
            end
            try
                delete(out(ctr));
            catch %#ok<CTCH>
            end
        end
        try
            Close(value(sm));
        catch %#ok<CTCH>
        end
        
        delete(value(rig_tester_gui));
        delete(HANDLES);
        delete(sm);
        delete(sndm);
        delete(sma);
        for ctr=1:length(value(REMOVE_THESE_PATHS))
            try
                rmpath(REMOVE_THESE_PATHS{ctr});
            catch %#ok<CTCH>
            end
        end
end



end

%% FUNCTION invert_color_scheme(handle) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function invert_color_scheme(handle) %#ok<DEFNU>
% This function inverts the color scheme for the specified handle. i.e. It
% swaps the ForegroundColor and BackgroundColor properties. If one of these
% properties does not exist or if the handle does not exist, the function does nothing.
try
    ForegroundColor = get(handle, 'ForegroundColor');
    BackgroundColor = get(handle, 'BackgroundColor');
    set(handle, 'ForegroundColor', BackgroundColor);
    set(handle, 'BackgroundColor', ForegroundColor);
catch %#ok<CTCH>
    %DO NOTHING
end

end

%% FUNCTION tempvarname
function tempvar = tempvarname %#ok<DEFNU>

[dummy, tempvar] = fileparts(tempname);

end


