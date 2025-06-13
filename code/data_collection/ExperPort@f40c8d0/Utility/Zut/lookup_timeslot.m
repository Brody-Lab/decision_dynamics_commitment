% <~> function: lookup_timeslot
%
%     This is currently Brody Lab--specific, along with all the
%       other session scheduling code.
%
%     This function is in essence the central location for all timeslot
%       constants. If the time windows for each timeslot are changed, this
%       is where that change would be implemented to affect all parts of
%       the scheduling code in MATLAB and in the Brody Lab mysql databases.
%
%     The function has three modes of operation depending on the type of
%       input provided:
%
%     1.  IN: timeslot string -> OUT: associated timeslot ID
%           e.g. lookup_timeslot('4-6p') returns 4.
%
%     2.  IN: timeslot ID -> OUT: associated timeslot string
%           e.g. lookup_timeslot(3) returns '12-2p'.
%
%     3.  IN: clock array -> OUT: associated timeslot string
%           e.g. lookup_timeslot(clock) might return '12-2p'
%
%     More examples:
%       lookup_timeslot('8-10a')    == 1
%       lookup_timeslot(1)          == '8-10a'
%       lookup_timeslot('10-12a')   == 2
%       lookup_timeslot(2)          == '10-12'a)
%       lookup_timeslot([2.0080 0.0070 0.0150 0.0190 0.0020]) == '6-8p'
%       etc.
%
function [o errID errmsg] = lookup_timeslot(timeslot)
errID = 0; errmsg = '';

if ~ischar(timeslot) && length(timeslot)==6,
    %     We've been given a time in 'clock' format, e.g. as returned by
    %       the 'now' command.
    mm = str2double(datestr(timeslot,'MM'))/60;
    hr = str2double(datestr(timeslot,'HH'));
    hr = hr + mm;
    if     hr > 19.2, o= '8-10p';
    elseif hr > 17.2, o= '6-8p' ;
    elseif hr > 13.0, o= '4-6p' ;
    elseif hr > 10.7, o='12-2p' ;
    elseif hr >  9,   o='10-12a';
    else              o= '8-10a';
    end;
else
    %     We've been given a time in timeslot ID or timeslot string format.
    switch(timeslot)   %     This could be done more clearly with a cell array for pairing, but I think this is more readible.
        case '8-10a',       o = 1;
        case 1,             o = '8-10a';
        case '10-12a',      o = 2;
        case 2,             o = '10-12a';
        case '12-2p',       o = 3;
        case 3,             o = '12-2p';
        case '4-6p',        o = 4;
        case 4,             o =  '4-6p';
        case '6-8p',        o = 5;
        case 5,             o =  '6-8p';
        case '8-10p',       o = 6;
        case 6,             o =  '8-10p';
        otherwise,
            if ~ischar(timeslot), timeslot = int2str(timeslot); end;
        o = NaN; errID = 1; errmsg = ['Error in wiki schedule interpretation. Timeslot ("' timeslot '") not recognized.'];
        return;
    end;%     end of switch timeslot
end;    %     end of if-else time is in clock vs. timeslot ID/str format
end     %     end of function lookup_timeslot