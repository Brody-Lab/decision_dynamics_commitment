% [t] = has_userprop_field(sph, fieldname)
%
% Returns TRUE if SoloParamHandle sph has a field called fieldname, FALSE
% otherwise.
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

function [o] = has_userprop_field(sph, uprop_field)

   global private_soloparam_list;
   
   o = has_userprop_field(private_soloparam_list{sph.lpos}, uprop_field);
   
     
   
   