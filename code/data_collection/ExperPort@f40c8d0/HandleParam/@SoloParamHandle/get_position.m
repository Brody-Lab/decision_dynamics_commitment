% [p] = get_position(sph)
%
% p returns as an n-by-4 vector. If the SoloParamHandle is not a GUI type,
% then p will be empty. If the SoloParamHandle is a GUI, but has no
% associated label, p will be 1-by-4 and will be the position of the
% graphics handle. If the SoloParamHandle is a GUI and has an associated
% label, then p will be 2-by-4 and the first row will be the position of
% the main graphics handle, the second row the position of the graphics
% handle of the label.
%   

% Written by Carlos Brody May 2007


function [p] = get_position(sph)

   global private_soloparam_list
   p = get_position(private_soloparam_list{sph.lpos});
