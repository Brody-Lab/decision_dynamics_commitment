% <~> function: submit_wiki_schedule_to_bdata.m
%     Takes as input a 3D cell array of session schedule data interpreted
%       from the html source of the Brody lab wiki rat training schedule
%       page. This matrix is output by the function
%       interpret_wiki_schedule.
%     Returns an errID (0 if no problems) and errmsg ('' if no problems)
%       after submitting data to the BData mysql database.
%
%     The input is either 1 or 2 arguments:
%
%       1- sched (a structure described below)
%       2- dateSched (optional; string, date the current schedule is for,
%                       in yyyy-mm-dd format (e.g. 2008-01-29')
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
%     The second input argument is optional and specifies the date that the
%       schedule submitted refers to. By default, this is the current date.
%
function [errID errmsg] = submit_wiki_schedule_to_bdata(sched,varargin)

%     Argument checking (basic)
%     This method must be called with either 1 or 2 arguments. (just the
%       schedule in the format described above, or the schedule and the
%       date (string) in the format yyyy-mm-dd (e.g. 2008-12-25).
error(nargchk(1, 2, nargin, 'struct'));
if ~iscell(sched),
    errID = 1; errmsg = 'submit_wiki_schedule_to_bdata was passed an inappropriate argument - it was not even a cell array! Please see submit_wiki_schedule_to_bdata.m.';
    return;
end;
if nargin==1, dateSched = datestr(now,'yyyy-mm-dd');
elseif ~ischar(varargin{1}), error(['When provided, the second argument of ' mfilename ' should be a string: the date, in yyyy-mm-dd form (e.g. 2008-01-30).']);
else          dateSched = varargin{1};
end;

%     Constants
nameSchedTable      = getZutConstant('nameSchedTable');


nTimeslots  = size(sched,1);
nRigs       = size(sched,2);
%nFields    = size(sched,3);

%     Iterate through the entries and add them to the schedule.
for         t = 1:nTimeslots,
    for     r = 1:nRigs,
        %     If one or more of the experimenter, ratname, or system fields
        %       is empty, skip it because it is not an entry.
        if isempty(sched{t,r,1}) || isempty(sched{t,r,2}) || isempty(sched{t,r,3}), continue; end;
        command_part1       = ['insert into ' nameSchedTable ' (date,timeslot,rig'];
        command_part2       = [') VALUES("' dateSched '",' int2str(t) ',' int2str(r)];
        command_part3       = ');';
        for f = {1 2 3 4 5; 'experimenter' 'ratname' 'system' 'protocol' 'instructions'},
            nameCol         = f{2};
            vCol            = sched{t,r,f{1}};   if isnumeric(vCol), vCol = int2str(vCol); end; %     If it's numeric, turn it into a string so we don't fail to append it to the command string.
            command_part1   = [command_part1 ','  nameCol ]; %#ok<AGROW> %     e.g. ',experimenter' or ',system'
            command_part2   = [command_part2 ',"' vCol '"']; %#ok<AGROW> %     e.g. ',"Carlos"'     or ',"1"'
        end; %     end for experiment
        command = [command_part1 command_part2 command_part3];
        %display(command);
        bdata(command); %     Add the entry to the schedule.
    end; %     end for all rigs
end;     %     end for all timeslots
errID = 0; errmsg = '';
end %     end of function interpret_wiki_schedule
