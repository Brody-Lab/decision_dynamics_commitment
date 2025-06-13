% [sph] = set_userprop(sph, uprop_field, uprop_value)
%
% Use this to store data of your choice in a SoloParamHandle. Your user
% data will be a property of a SoloParamHandle, similar to "position", or
% the label string-- which means that user prop will *not* get saved when
% the SoloParamHandle is saved, and no history of the user prop is
% accumulated or stored.
%
% SET_USERPROP(sph, uprop_field, uprop_value), where uprop_field is a
%      string, erases only the previous value of the field named
%      uprop_field in the user prop, replacing it with the new value
%      uprop_value. If no field of the right name existed already, then the
%      field is created. This form of the call, with uprop_field, and
%      uprop_value, is the recommended form of call.
%
% SET_USERPROP(sph, uprop_struct) erases any previous user prop in
%      SoloParamHandle sph, and sets it to uprop_struct. This last,
%      uprop_struct, *must* be struct, even if it is an empty one.
%
% Returns the SoloParamHandle.
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

function [sph] = set_userprop(sph, uprop_field, uprop_value)

global private_soloparam_list;

if isstruct(uprop_field) && nargin==2,
  private_soloparam_list{sph.lpos} = ...
    set_userprop(private_soloparam_list{sph.lpos}, uprop_field);
  
elseif ischar(uprop_field) && nargin==3,
  private_soloparam_list{sph.lpos} = ...
    set_userprop(private_soloparam_list{sph.lpos}, uprop_field, uprop_value);

else
  error('SoloParamHandle:INVALID_CALL', ...
    'set_userprop: must pass either a struct or a char fieldname and a fieldvale');   
end;
   
   

