function [] = softsm_motion_callback(myobj, event, ...
                                     leftbutton,   leftpos, ...
                                     centerbutton, centerpos, ...
                                     rightbutton,  rightpos, ...
                                     outbutton,    outpos)

   mydata = get(myobj, 'UserData');
   if ~mydata.Running,     return; end; % If not running, no events processed
   if mydata.flushing_now, return; end; % Ignore until end of flush queue 
   
   persistent position
   if isempty(position), position = 'Out'; end;
    
   oldpos = position;
   
   set(myobj, 'Units', 'normalized');
   currpt = get(myobj, 'CurrentPoint');
   
   newpos = oldpos;
   if iswithin(currpt, leftpos),   newpos = 'Left';   end;
   if iswithin(currpt, centerpos), newpos = 'Center'; end;
   if iswithin(currpt, rightpos),  newpos = 'Right';  end;
   if iswithin(currpt, outpos),    newpos = 'Out';    end;
   position = newpos;
   
   if strcmp(newpos, oldpos), return; end;  % nothing's changed
   if ~strcmp(oldpos, 'Out') & ~strcmp(newpos, 'Out'), return; end; 
   % if not Out, only legal act is to go Out 
   
   % fprintf(1, 'Was in %s, now entering %s\n', oldpos, newpos);
   % Store the event that happened
   if strcmp(oldpos, 'Out'), direction = 'In'; port = newpos;
   else direction = 'Out'; port = oldpos;
   end;
   timestamp_error(etime(clock, mydata.Init_time), ...
                   sprintf('Entering %s into the raw queue', [port ...
                       direction])); 
   mydata.event_queue = [mydata.event_queue ; ...
                       {[port direction] etime(clock, mydata.Init_time)}];
   set(myobj, 'UserData', mydata);
   timestamp_error(etime(clock, mydata.Init_time),'saving mydata');

   
   
   button = eval([lower(newpos) 'button']);
   set([leftbutton;centerbutton;rightbutton;outbutton],'BackgroundColor','g');
   set(button, 'BackgroundColor', 'c');
   drawnow;
   
   
   
function [b] = iswithin(currpt, position)
   
   if position(1) <= currpt(1) & currpt(1) <= position(1)+position(3)  &  ...
          position(2) <= currpt(2) & currpt(2) <= position(2)+position(4),
      b = 1;
   else
      b = 0;
   end;
   
    