% A template protocol that does almost nothing-- each trial
% just waits a second and then ends.
%

function [x y] = SoundsSection(obj, action, x, y, varargin)


GetSoloFunctionArgs(obj);

switch action
    %% case init
    case 'init',
        gui_width = gui_position('get_width');
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)], 'saveable', 0);
        
        %fprintf('x = %.2f, y = %.2f banana\n', x, y);
        
        ToggleParam(obj, 'showhide', 1, x, y, 'OnString', 'Showing Sounds', ...
            'OffString', 'Hiding Sounds');
        
        next_row(y);
        
        %fprintf('x = %.2f, y = %.2f tiger\n', x, y);
        set_callback(showhide, {mfilename, 'showhide'});   %#ok<NODEF>

        % Create our own figure window
        SoloParamHandle(obj, 'myfig', 'value', ...
            figure('Name', 'Sounds Section', 'CloseRequestFcn', [mfilename '(' class(obj) ', ''hide'')'], ...
            'MenuBar', 'none'), ...
            'saveable', 0);
        
%         gui_position('set_width', gui_width);
        figure(value(myfig));
        myx = 10; myy = 10;
        SoloParamHandle(obj, 'my_window_info', 'value', [myx, myy, value(myfig)], 'saveable', 0);
        
        [myx, myy] = SoundInterface(obj, 'add', 'WarningSound', myx,  myy);
        SoundInterface(obj, 'set', 'WarningSound', 'Vol',   0.0002);
        SoundInterface(obj, 'set', 'WarningSound', 'Vol2',  0.008);
        SoundInterface(obj, 'set', 'WarningSound', 'Dur1',  10);
        SoundInterface(obj, 'set', 'WarningSound', 'Loop',  0);
        SoundInterface(obj, 'set', 'WarningSound', 'Style', 'WhiteNoiseRamp');
        
        next_row(myy);
        %fprintf('x = %.2f, y = %.2f hat\n', x, y);

        [myx, myy] = SoundInterface(obj, 'add', 'DangerSound',  myx,  myy);
        SoundInterface(obj, 'set', 'DangerSound', 'Vol',   0.005);
        SoundInterface(obj, 'set', 'DangerSound', 'Dur1',  1);
        SoundInterface(obj, 'set', 'DangerSound', 'Loop',  1);
        SoundInterface(obj, 'set', 'DangerSound', 'Style', 'WhiteNoise');
        
        next_row(myy);
        %fprintf('x = %.2f, y = %.2f rose\n', x, y);
        
        next_column(myx); myy = 5;
        
        [myx, myy] = SoundInterface(obj, 'add', 'LeftClicks', myx,  myy);
        SoundInterface(obj, 'set', 'LeftClicks', 'Vol',   0.04);
        SoundInterface(obj, 'set', 'LeftClicks', 'Dur1',  2);
        SoundInterface(obj, 'set', 'LeftClicks', 'Freq1',  10);
        SoundInterface(obj, 'set', 'LeftClicks', 'Bal',  -1);
        SoundInterface(obj, 'set', 'LeftClicks', 'Loop',  0);
        SoundInterface(obj, 'set', 'LeftClicks', 'Style', 'Bups');
        
        next_row(myy);
                %fprintf('x = %.2f, y = %.2f bottle\n', x, y);

        [myx, myy] = SoundInterface(obj, 'add', 'RightClicks', myx,  myy);
        SoundInterface(obj, 'set', 'RightClicks', 'Vol',   0.04);
        SoundInterface(obj, 'set', 'RightClicks', 'Dur1',  2);
        SoundInterface(obj, 'set', 'RightClicks', 'Freq1',  10);
        SoundInterface(obj, 'set', 'RightClicks', 'Bal',  1);
        SoundInterface(obj, 'set', 'RightClicks', 'Loop',  0);
        SoundInterface(obj, 'set', 'RightClicks', 'Style', 'Bups');
        
        next_row(myy);
        
        
        pos = get(value(myfig), 'Position');
        set(value(myfig), 'Position', [pos(1:2) myx*2 myy]);
        set(value(myfig), 'Visible', 'off');
        showhide.value = 0;
        
        % Return to the main figure window;
        figure(my_gui_info(3));
%         gui_position('set_width', gui_width);
        

        %fprintf('x = %.2f, y = %.2f chimpanzee\n', x, y);
        return;
        
        %% case showhide
    case 'showhide'
        if showhide==1,  %#ok<NODEF>
            set(value(myfig), 'Visible', 'on');
        else
            set(value(myfig), 'Visible', 'off');
        end;
        
        %% case hide
    case 'hide'
        set(value(myfig), 'Visible', 'off');
        showhide.value = 0;
        
        %% case close
    case 'close'
        currfig = double(gcf);
        
        % Get the original GUI position and figure:
        x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));
        my_figure = my_window_info(3);
        
        % Delete all SoloParamHandles who belong to this object and whose
        % fullname starts with the name of this mfile:
        delete_sphandle('owner', ['^@' class(obj) '$'], ...
            'fullname', ['^' mfilename]);
        delete(my_figure);
        
        % Restore the current figure:
        if my_figure~=currfig,
            figure(currfig);
        end;
        
end




