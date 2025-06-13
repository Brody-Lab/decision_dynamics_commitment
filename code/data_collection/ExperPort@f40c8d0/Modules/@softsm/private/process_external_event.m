function [md] = process_external_event(ssm, md, ev, time)

   event_table = {'CenterIn' 'CenterOut' 'LeftIn' 'LeftOut' 'RightIn' ...
                  'RightOut' 'TimeUp'};     
   event_index = strmatch(ev, event_table);
   if isempty(event_index),
      error(['What kind of event is ' ev '???']);
   end;
   
   newstate = md.StateMatrix(md.CurrentState+1, event_index);
   timestamp_error(etime(clock, md.Init_time), ...
                   sprintf('newstate %d', newstate));

   md = state_change(md, newstate, event_index, time);
