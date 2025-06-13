%----------------------------------------------------------------------------------------------------------------------
%  This function returns a string containg color information for plotting the frame.  Color is chosen in a specific
%   order based on preference.  The color yellow is used to represent raw green due to the absence of a light green color string.
%----------------------------------------------------------------------------------------------------------------------
function [color_string] = GetColorString( color_array )

    if ( color_array(2) ~= 0 )      % pure red
        color_string = 'ro';
    elseif ( color_array(4) ~= 0 )  % pure green
        color_string = 'go';        
    elseif ( color_array(6) ~= 0 )  % pure blue
        color_string = 'bo';
    elseif ( color_array(5) ~= 0 )  % raw blue
        color_string = 'co';
    elseif ( color_array(1) ~= 0 )  % raw red
        color_string = 'mo';
    elseif ( color_array(3) ~= 0 )  % raw green
        color_string = 'yo';
    else                            % black for luminance or default
        color_string = 'ko';
    end