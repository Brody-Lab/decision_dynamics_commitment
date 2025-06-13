function [sp] = push_history(sp)
% Appends current value onto the object's history list. Despite the
% name, treats history like a queue, not a stack! Does not clear the
% current value.
   
   % if isempty(sp.type),
   % error('History pushing only valid for ui params');
   % end;
   
   sp.value_history = [sp.value_history ; {sp.value}];
   