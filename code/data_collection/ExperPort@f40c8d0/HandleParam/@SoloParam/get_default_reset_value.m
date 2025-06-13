%get_default_reset_value.m       [s] = get_default_reset_value(sp)
%
% Returns the default reset value. Doesn't affect the SP's value-- just
% returns it to the caller for examination. Default reset values are
% either empty (which means there is no default reset value), or cells
% with a single element, which is the default reset value.
   
function [s] = get_default_reset_value(sp)

   s = sp.default_reset_value;
   
   