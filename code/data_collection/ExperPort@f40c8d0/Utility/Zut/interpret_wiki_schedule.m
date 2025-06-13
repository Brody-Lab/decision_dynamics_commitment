% <~> function: interpret_wiki_schedule.m
%     Takes as input the cropped html source of the Brody lab wiki rat
%       training schedule page (as output by retrieve_wiki_schedule).
%     Returns a matrix of session data in the following format:
%
%       nTimes x nSlots x nFields, where:
%           nTimes is the number of timeslots in the day (now: 6)
%           nSlots is the maximum number of rigs operating in any slot on
%                       that day
%           nFields is 5, the number of data fields per entry in the
%                       schedule
%
%       The times corresponding to the timeslots are currently:
%           1:      08-10 AM
%           2:      10-12 AM-PM
%           3:      12-14 AM
%           4:      16-18 PM
%           5:      18-20 PM
%           6:      20-22 PM
%
%       The current maximum for the maximum number of rigs operating in any
%         slot is 18.
%
%       The current fields of each entry are (5):
%           1   experimenter
%           2   ratname
%           3   system
%           4   protocol
%           5   requests
%
function schedule = interpret_wiki_schedule(htmlSched)

%     An element in the htmlSched cell array is a string that looks like:
%       <td> <b>8-10p</b>    </td><td>  Klaus </td><td> Jeff </td><td> J020-pm </td><td> RunRats </td><td> ProAnti2 </td><td>   <b>5</b> </td><td>
%
%     To turn this into something more reasonable, we:
%       1 - crop out the SEVEN (7) tasty tokens between the <td> </td> keys
%       2 - strip leading and trailing spaces
%       3 - strip all flavor text like <b> and <i>   <------- !!! %<~>TODO
%

%     Verify argument.
error(nargchk(1,1,nargin));
if ~iscellstr(htmlSched), error('Error. Function interpret_wiki_schedule expects a cell array of strings as its single input. retrieve_wiki_schedule should return the proper variable.'); end;

nEntries    = length(htmlSched);
nTimeslots  = 6;  %<~>TODO: Determine this dynamically with a helper fn.
nRigs       = 18; %<~>TODO: Determine this dynamically with a helper fn.
nFields     = 5;  %<~>TODO: Determine this dynamically with a helper fn.
schedule    = cell(nTimeslots,nRigs,nFields);

for i=1:nEntries,
    strLine     = htmlSched{i}; %     temp
    %     For code readability and editability, I've broken up the format
    %       string below into a single substring per token to read.
    fstrTimeslot = '<td> <b>%[0123456789-ampAMP]</b> </td>'; %     e.g. '<td> <b>8-10p</b>   </td>'
    fstrTech     = '<td> %[^<>] </td>'; %     e.g. '<td> Klaus </td>'
    fstrExp      = '<td> %[^<>] </td>'; %     e.g. '<td> Jeff        </td>'
    fstrRat      = '<td> %[^<>] </td>'; %     e.g. '<td> J059    </td>'
    fstrBase     = '<td>%[^<>]</td>'; %     e.g. '<td>  RunRats    </td>'
    fstrProtocol = '<td>%[^<>]</td>'; %     e.g. '<td>                      </td>'
    fstrRig      = '<td> <b>%[^<>]</b> </td>';   %     e.g. '<td> <b>13</b> </td>'
    fstrRequests = '<td>%[^?]';   %     e.g. '<td> %Water for 30 minutes'
    fstrFull     = [fstrTimeslot fstrTech fstrExp fstrRat fstrBase fstrProtocol fstrRig fstrRequests];
    scanoutput  = textscan(strLine,fstrFull,'whitespace',''); %     The ? is arbitrary. The remaining comment string I want to capture in its entirety, spaces included. Note also that for protocol and technician, the expression is %[<>] instead of %[< >]. This is because they may be empty, in which case they will simply stored as some number of spaces and cropped to an empty string by the strtrim call below. If I don't capture spaces for these, nothing will be captured instead, and the textscan will be interrupted and not capture later fields, which would result in the exclusion of entries with blank protocol or technician fields - which obviously, I don't want.

    scanoutput  = strtrim(scanoutput); %     Remove leading and trailing whitespace.
    %     scanoutput should be a cell array of the form (1x8 elements):
    %       timeslot    technician  experimenter    ratname     system  protocol    rignumber   specialinstructions 
    
    
    %     Fetch the rig number and timeslot index. If this line has no rig
    %       number or timeslot index, skip it; it's probably a note to the
    %       technician(s) instead of a rat entry.
    if isempty(scanoutput{7}) || isempty(scanoutput{1}), continue;
    else
        iTimeslot           = scanoutput{1}{1};
        [iTimeslot errID]   = lookup_timeslot(iTimeslot);
        iRig                = str2double(scanoutput{7}{1});
        if isnan(iTimeslot) || isnan(iRig) || errID, continue; end; %     If this line doesn't include a rat to run (e.g. it's water instruction information with a timeslot of '___'), it doesn't get interpreted in this schedule.
    end;
    if ~isempty(scanoutput{5}), %     Interpret the system string into the system index used in the mysql table.
        [iSys errID]        = lookup_system(scanoutput{5}{1});
        if ~errID && ~isnan(iSys),  schedule{iTimeslot,iRig,3} = iSys;             end; %     system
    end;
    if ~isempty(scanoutput{3}),     schedule{iTimeslot,iRig,1} = scanoutput{3}{1}; end; %     experimenter
    if ~isempty(scanoutput{4}),     schedule{iTimeslot,iRig,2} = scanoutput{4}{1}; end; %     ratname
    if ~isempty(scanoutput{6}),     schedule{iTimeslot,iRig,4} = scanoutput{6}{1}; end; %     protocol
    if ~isempty(scanoutput{8}),     schedule{iTimeslot,iRig,5} = scanoutput{8}{1}; end; %     specialinstructions
    
end;  %     end of for all entries in the schedule

end %     end of function interpret_wiki_schedule
