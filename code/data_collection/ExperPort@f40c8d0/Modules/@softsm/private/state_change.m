function [md] = state_change(md, newstate, event_index, time)
% If the new state is the same as md.CurrentState, nothing
% happens and the procedure returns directly-- EXCEPT if the
% CurrentState is 35 and the PC_Ready flag is set, in which case
% there is a state change to state 0.
%
% Otherwise, given an md data structure and the new state to which the
% machine should go, this procedure updates the outgoing EventList and
% nevents, changes CurrentState, Dout, and Trigout, and does all the
% GUI and callback things that changing to a new state might
% imply. The state change is recorded as time.
% 
%
% This is the central state-changing station; for this reason,
% special checks for special states are also done here: state 35
% checks for the PC_Ready flag, and going to state 0 sets the
% PC_Ready flag to 0.
%

   oldstate   = md.CurrentState;
   oldtrigout = md.Trigout;
      
   md.nevents = md.nevents+1;
   md.EventList(md.nevents,:) = ...
       [md.CurrentState, 2^(event_index-1), time newstate];
            
   md.CurrentState = newstate;
   set(md.statebutton, 'String', ['State = ' num2str(md.CurrentState)]);

   if newstate ~= oldstate,       
      % reset timer only if switched to new state; process_timeups.m
      % takes care of resetting the timer on TimeUp events, even those
      % that don't change the state                            
      md.LastStChangeTime = time;

      md = check_dout_change(md);
      
      % Backwards compatibility hack: double event generation      
      % md.nevents = md.nevents+1;
      % md.EventList(md.nevents,:) = [md.CurrentState, 0, time];
      % --- End backwards hack ---            
   end;

   newtrigout = md.StateMatrix(md.CurrentState+1,10);
   if newtrigout ~= oldtrigout,
      go_trigger(md, newtrigout);
      md.Trigout = 0; % Triggers are instantaneous beasts; reset
                      % at once. Next time FlushQueue is called,
                      % the GUI will reset to 0.
   end;
   

   % Final checks on PC_Ready flag:
   if md.CurrentState == 0, md.PC_Ready = 0; end;
   
   if md.CurrentState == 35 & md.PC_Ready == 1,
      md = state_change(md, 0, -Inf, etime(clock, md.Init_time));
   end;
   