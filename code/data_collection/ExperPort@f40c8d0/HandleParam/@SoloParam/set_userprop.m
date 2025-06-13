function [sp] = set_userprop(sp, uprop_field, uprop_value)

if isstruct(uprop_field) && nargin==2,
  sp.UserData = uprop_field;
elseif ischar(uprop_field) && nargin==3,
  sp.UserData.(uprop_field) = uprop_value;  
else
  error('SoloParam:INVALID_CALL', ...
    'set_userprop: must pass either a struct or a char fieldname and a fieldvale');   
end;
   
   
   