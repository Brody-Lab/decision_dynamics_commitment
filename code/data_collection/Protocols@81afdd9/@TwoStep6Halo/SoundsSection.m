
function [x, y] = SoundsSection(obj, action, x, y)

GetSoloFunctionArgs;

switch action
    %% init
    case 'init',
        
            fig = double(gcf);
        % this is the only thing that shows up on the main GUI window:
        ToggleParam(obj, 'sounds_button', 0, x, y, ...
            'OnString', 'Sounds Panel Showing', ...
            'OffString', 'Sounds Panel Hidden', ...
            'TooltipString', 'Show/Hide the window that controls auditory stimuli');
        next_row(y);
        set_callback(sounds_button, {mfilename, 'window_toggle'}); %#ok<NODEF>
        
        origx = x; origy = y;
        
        
        % Now we set up the window that pops up to show sound details
        SoloParamHandle(obj, 'mysfig', 'saveable', 0, 'value', ...
            figure('position', [500   300   210   300], ...
            'MenuBar', 'none',  ...
            'NumberTitle', 'off', ...
            'Name','TwoStep Sounds', ...
            'CloseRequestFcn', [mfilename ...
            '(' class(obj) ', ''hide_window'');']));
        
        
        
        x = 5; y = 5;
        
        [x,y] = SoundInterface(obj,   'add', 'right_sound',    x, y);
        next_row(y,0.5);
        [x,y] = SoundInterface(obj,   'add', 'left_sound',    x, y);
        next_row(y,0.5);
        % Send a silence sound to the machine
        silence_vect = zeros(1,100);
        SoundManagerSection(obj,'declare_new_sound','silence',silence_vect);
        
        
        x = origx; y = origy; figure(fig);
        
    case 'window_toggle',
        if value(sounds_button) == 1,  %#ok<NODEF>
            set(value(mysfig), 'Visible', 'on');
        else
            set(value(mysfig), 'Visible', 'off');
        end;
        
        %% hide_window
    case 'hide_window',
        sounds_button.value_callback = 0;
end

end