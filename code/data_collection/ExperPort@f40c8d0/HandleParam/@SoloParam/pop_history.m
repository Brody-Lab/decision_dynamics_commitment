function [sp] = pop_history(sp)
% Takes the last value in the object's history list off the list. Current
% value is NOT affected. Despite the name, treats history like a queue,
% not a stack!
   
% if isempty(sp.type),
% error('History pushing only valid for ui params');
% end;

   if length(sp.value_history) < 1,
      % warning('No existing history to pop from %s', get_fullname(sp));
   end;

   if strcmp(sp.type, 'pushbutton'), return; end;
   
   %    sp = subsasgn(sp, struct('type', '.', 'subs', 'value'), ...
   %                 sp.value_history{end});
   
   sp.value_history = sp.value_history(1:end-1);
   