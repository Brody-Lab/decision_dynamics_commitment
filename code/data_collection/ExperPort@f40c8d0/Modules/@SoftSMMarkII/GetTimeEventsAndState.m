% [struct time_and_events] = GetTimeEventsAndState(sm, first_event_num)    
%                Gets the time, in seconds, that has elapsed since
%                the last call to Initialize(), as well as the Events matrix
%                starting from first_event_num up until the present.
%         
%                The returned struct has the following 4 fields:
%                        time: (time in seconds)
%                        state: (state number state machine is currently in)
%                        event_ct: (event number of the latest event)
%                        events: (m by 4 matrix of events)

function [stevs] = GetTimeEventsAndState(sm, first)
    
    time      = GetTime(sm);
    nevents   = GetEventCounter(sm);
    currstate = GetCurrentState(sm);
    evs       = GetEvents(sm, first, nevents);
    
    stevs = struct('time', time, 'state', currstate, 'event_ct', nevents, ...
      'events', evs);
    
    return;
