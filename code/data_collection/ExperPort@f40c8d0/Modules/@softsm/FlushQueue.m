function [ssm] = flush_queue(ssm)

   mydata = get(ssm.myfig, 'UserData');
   
   % Set a flag that says, "I'm working, don't bother me."
   mydata.flushing_now = 1;
   mydata.Trigout = 0;
   set(mydata.toutbutton, 'String', 'Trigout = 00000000');
   set(ssm.myfig, 'UserData', mydata);
   
   while ~isempty(mydata.event_queue),
      % pull the event off the queue
      timestamp_error(etime(clock, mydata.Init_time), ...
                      sprintf('pulling 1 event off %d-long queue', ...
                              size(mydata.event_queue,1)));
      event = mydata.event_queue{1,1}; time = mydata.event_queue{1,2};
      mydata.event_queue = mydata.event_queue(2:end,:);

      % process all possible timeups up til that point in time
      mydata = process_timeups(ssm, mydata, time);
      
      % process the event itself
      timestamp_error(etime(clock, mydata.Init_time), 'processing event');
      mydata = process_external_event(ssm, mydata, event, time); 
   end;

   % process any timeup events up til now
   mydata = process_timeups(ssm, mydata, etime(clock, mydata.Init_time));
   set(mydata.timerbutton, 'String', ...
                     sprintf('Time = %.2f', etime(clock, mydata.Init_time)));
   
   % ok, we're done.
   mydata.flushing_now = 0;
   timestamp_error(etime(clock, mydata.Init_time), ...
                   sprintf('Save a %d-long raw queue', ...
                           size(mydata.event_queue,1)))
   set(ssm.myfig, 'UserData', mydata);
   