function [o] = get_userprop(sp, uprop_field)
   
  if nargin==1,
    o = sp.UserData;
  else
    o = sp.UserData.(uprop_field);
  end;
  
  