
function [x, y] = SoundsSection(obj, action, x, y)

GetSoloFunctionArgs;

switch action
    %% init
    case 'init',


[x,y] = SoundInterface(obj,   'add', 'right_sound',    x, y);
        next_row(y,0.5);
        [x,y] = SoundInterface(obj,   'add', 'left_sound',    x, y);
        next_row(y,0.5);
 % Send a silence sound to the machine
        silence_vect = zeros(1,100);
        SoundManagerSection(obj,'declare_new_sound','silence',silence_vect);
        
        
end

end