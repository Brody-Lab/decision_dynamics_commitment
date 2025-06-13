% [o] = get_userprop(sph, [uprop_field])
%
% If called with no arguments, returns a struct that is the user prop for
% SoloParamHandle sph. The default value is an empty struct.
%
% If called with one argument, that argument must be a string; if the user
% prop struct has a field with name uprop_field, then its value is
% returned. If no such field is found, an error will occur.
%
% EXAMPLE:
% -------
%
% If sph is a SoloParamHandle,
%
% >> set_userprop(sph, 'my_new_field', 23);
%
% >> get_userprop(sph, 'my_new_field')
%   ans =
%      23
%
% >> has_userprop_field(sph, 'field_not_created_yet')
%   ans = 
%      0
%
% >> set_userprop(sph, 'field_not_created_yet', ...
%       {'oh yes it is created now', [30 40]});
%
% >> has_userprop_field(sph, 'field_not_created_yet')
%   ans = 
%      1
%

% Written by Carlos Brody, March 2009


function [o] = get_userprop(sph, uprop_field)

   global private_soloparam_list;
   
   if nargin == 1,
     o = get_userprop(private_soloparam_list{sph.lpos});
   else
     o = get_userprop(private_soloparam_list{sph.lpos}, uprop_field);
   end;
   
     
   
   