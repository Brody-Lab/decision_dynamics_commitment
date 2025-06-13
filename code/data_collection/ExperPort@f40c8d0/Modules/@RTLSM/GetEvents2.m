% <~> This method is the same as GetEvents for @RTLSM.
%     For @RTLSM2, it is not; rather, for @RTLSM2, it is modified to use
%       the new event type format, event column # instead of 2^(event
%       column #). This is a necessity, as the server we're connecting to
%       has to have the patched code to be able to perform a proper
%       GetEvents2, and I can't expect old servers to have this patch.
%
% <~> In effect, old servers cannot use more than 32 input columns, while
%       new servers (svn revision >= 108 of the rtfsm project) can. For
%       example, an old server will not treat events properly if you have
%       3 pokes (6 input columns), a timer (1 input column), and 13
%       scheduled waves (26 input columns). In that scenario, all _out
%       events of the 13th scheduled wave will appear to be different event
%       types.
%
% [EventList]   = GetEvents(sm, int StartEventNumber, int EndEventNumber)
%
%                Gets a matrix in which each row corresponds to an
%                Event; the matrix will have
%                EndEventNumber-StartEventNumber+1 rows and 4
%                columns. (If EndEventNumber is bigger than
%                GetEventCounter(), this produces an error).
%
%                Each of the rows in EventList has 4
%                columns: 
%
%                the first is the state that was current when
%                the event occurred
%
%                the second is the event_id, which is
%                2^(event_column) that occurred. event_column is
%                0-indexed.  See SetInputEvents() for a description
%                of what we mean by event columns.
%
%                In the default event column configuration
%                SetInputEvents(sm, 6), you would have as possible event_id's:
%
%                1=Cin, 
%                2=Cout, 
%                4=Lin, 
%                8=Lout, 
%                16=Rin,
%                32=Rout, 
%                64=Tup, 
%                0=no detected event, (e.g. when a jump to state 0 is forced)
%               
%                the third is the time, in seconds, at which the
%                event occurred.
%
%                the fourth is the new state that was entered as a
%                result of the state transition
function [eventList] = GetEvents(sm, start_no, end_no)
    if start_no > end_no,
        eventList = zeros(0,4);
    else
        eventList = DoQueryMatrixCmd(sm, sprintf('GET EVENTS %d %d', start_no-1, end_no-1));
    end;

