%set_default_reset_value.m    [sp] = set_default_reset_value(sp, str)
%
% Sets the default reset value-- does not affect the SP's value, this
% will only be done if restore_default_reset_value() is called. Default
% reset values are either empty (which means there is no default reset
% value), or cells with a single element, which is the default reset
% value. 
   
function [sp] = set_default_reset_value(sp, str)
   
   if (iscell(str) && prod(size(str))==1)  ||  isempty(str)
      sp.default_reset_value = str;
   else
      error(['default reset values must either be empty non-cells ' ...
             '(meaning no default value) or a cell with a single element ' ...
              'in it, which will be the default reset value']);
    end;
   
   