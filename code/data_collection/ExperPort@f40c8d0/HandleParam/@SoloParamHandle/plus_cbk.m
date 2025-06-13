% [sp] = plus_cbk(sp, step)
%
% plus_cbk: A method to succinctly increment or decrement the value of a
% SPH by a specified number (step), and invoke the callback for the SPH.
%

function [sp] = plus_cbk(sp, step)

   if ~isnumeric(step)
       error('step should be a number');
   end;
   
   sp = subsasgn(sp, struct('type', '.', 'subs', 'value'), sp+step);
   callback(sp);