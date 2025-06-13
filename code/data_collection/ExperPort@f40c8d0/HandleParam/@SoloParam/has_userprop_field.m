function [o] = has_userprop_field(sp, uprop_field)
   
  o = isfield(sp.UserData, uprop_field);
  
  