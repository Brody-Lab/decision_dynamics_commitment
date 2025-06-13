%restore_default_reset_value.m    [sp] = restore_default_reset_value(sp)
%
% Sets the value of the SoloParam to be its default reset value. If the
% default reset value is empty, then the SP's value is not changed; if the
% default reset value is non-empty, it is assumed to be a cell with a
% single element, and the SP's value will become equal to that element.
   
function [sp] = restore_default_reset_value(sp, str)
   
   if ~isempty(sp.default_reset_value),
      sp = subsasgn_dot_value(sp, sp.default_reset_value{1});
   end;
   
   
   