function [] = go_trigger(md, trigger)
% Sets the GUI's trigger button signal and calls the trigger callback
   
   str = dec2bin(trigger);
   if length(str < 8), str = ['0'*ones(1, 8-length(str)) str]; end;
   set(md.toutbutton, 'String', ['Trigout = ' str]);
   drawnow;
   if ~isempty(md.tout_callback), 
      feval(md.tout_callback{1}, md.tout_callback{2}, trigger);
   end;
   drawnow;