function [md] = process_timeups(ssm, md, time)
% Process all the timeup state change events up to t = time.  Because
% this procedure only processes timeups, it does not change the raw
% external event queue (md.event_queue) at all-- the outgoing event
% queue (EventList), however, will of course be affected: All effects
% of any state changes that occur because of timeups will happen. 
%
   
   oldstate  = md.CurrentState;
   maxtime   = md.StateMatrix(oldstate+1, 8);

   while time-md.LastStChangeTime >= maxtime,      
      newstate = md.StateMatrix(oldstate+1, 7);
      md = state_change(md, newstate, 7, md.LastStChangeTime+maxtime);
      if newstate == oldstate, % even if nothing happened, we reset
                               % the timer:
         md.LastStChangeTime = md.LastStChangeTime+maxtime;
      end;
      
      oldstate  = md.CurrentState;
      maxtime   = md.StateMatrix(md.CurrentState+1, 8);
   end;
      
