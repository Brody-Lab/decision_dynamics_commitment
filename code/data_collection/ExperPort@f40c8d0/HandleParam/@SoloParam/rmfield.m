function [sp] = rmfield(sp, fieldname)

  % We usually use subsasgn_dot_value to ensure linkage of GUI and internal
  % vals; but if we're here, we already know that the sp contains a struct
  % and isnt a GUI; so we can take a shortcut:
  
  sp.value = rmfield(sp.value, fieldname);
  