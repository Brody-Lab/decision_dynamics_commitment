% [t] = gets_saved_with_settings(sph)
%
% Returns 1 if this SoloParamHandle would get saved with settings, 0 if it
% would not.
%
% This is determined as follows:
%
% IF   the sph's saveable flag is not on, then it is not saved with settings.
% ELSE IF the save_with_settings flag is on, then it is saved with settings
% ELSE IF it is a GUI sph but not a disp or a pushbutton gui, then it is saved with setting
% ELSE it is not saved with settings.
% ENDIF
%
% 
% See get_saveable.m, get_save_with_settings.m, and get_type.m
%
     
function [t] = gets_saved_with_settings(sph)

   t = ( get_saveable(sph)==1 && ...
           (get_save_with_settings(sph) || ...
              (~isempty(get_type(sph)) && ~ismember(get_type(sph), {'disp' 'pushbutton'})) ...
           ) ...
       );

       