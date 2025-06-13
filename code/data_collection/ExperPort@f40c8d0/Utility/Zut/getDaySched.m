% <~> Gets the day's schedule for the current rig from the mysql server
%       (part of the Zut suite of code for the Brodylab).
%
%     [sched e m] = getDaySched(dateTarget,iRig)
%
%     Sebastien Awwad, 2008.Sep
%
%
%     PARAMETERS:
%     -----------
%     1. dateTarget     day to query in schedule, in one of these formats:
%                           -    clock format (as returned by clock)
%                           - or yyyy-mm-dd
%     2. iRig           number of the rig to query in schedule
%
%     RETURNS:
%     --------
%     1. sched          a six-member STRUCT ARRAY with fields:
%                         - timeslot        int, timeslot index, 1:6
%                         - experimenter    str, experimenter name
%                         - ratname         str, rat's name
%                         - instructions    str, tech instructions
%
%     2. errID           0 if there are no errors
%                       -1 for a programming error
%                        1 for other errors (e.g. not a Brody Lab machine)
%     3. errmsg         '' if there are no errors, else a descriptive str.
%
function [sched errID errmsg] = getDaySched(dateTarget, iRig)
sched = []; errID = -1; errmsg = ''; %#ok<NASGU>

%     First, make sure this is a Brody Lab system.
%     Zut was written for the Brody Lab.
if ~bSettings('compare','GENERAL','Lab','Brody'),
    errID  = 1;
    errmsg = 'queryDaySched is a part of Zut, which was written for the Brody Lab and communicates with Brody Lab servers. Returning empty cell array.';
    warning('ZUT:WrongLab',errmsg);
    return;
end;


%     Second, do argument checking / interpretation.
if          nargin ~= 2                                                 ...
        || (~ischar(dateTarget) && ~isnumeric(dateTarget))              ... %     yyyy-mm-dd format is okay.
        || (isnumeric(dateTarget) && length(dateTarget) ~= 6)           ... %     clock format is okay [][][][][][]
        || (ischar(dateTarget) && (length(dateTarget)~=10 || ~strmatch(dateTarget([1:2 5 8]),'20--'))) ...
        || ~isnumeric(iRig)                                             ...
        ||  length(iRig) ~= 1,
    errID = 1; %#ok<NASGU>
    errmsg = 'queryDaySched requires two arguments: a date and rig number. Date must be either in clock format or a string in format yyyy-mm-dd. Rig must be an integer.';
    error(errmsg);
end;
if ~ischar(dateTarget), dateTarget = datestr(dateTarget,'yyyy-mm-dd'); end;



%     Third, construct the mysql query string.
strSQLTable = getZutConstant('nameSchedTable');
strColumns  = 'timeslot, experimenter, ratname, instructions';
strCondit   = ['where date="' dateTarget '" and rig=' int2str(iRig)];

cmdQuery    = ['select ' strColumns ' from ' strSQLTable ' ' strCondit ' order by timeslot'];


%     Fourth, send the mysql query.
[iTimeslot strExp strRat strInstruct] = bdata(cmdQuery);


%     Fifth, output the schedule data and set errIDs.
errID = 0; %     no errors
sched = struct(...
    'timeslot',     [],             ...
    'experimenter', '',             ...
    'ratname',      '',             ...
    'instructions', '');
for i=1:length(iTimeslot),
    sched(i).timeslot       = iTimeslot(   i);
    sched(i).experimenter   = strExp{      i};
    sched(i).ratname        = strRat{      i};
    sched(i).instructions   = strInstruct{ i};
end; %     end of for each timeslot


end %     end of function getDaySched
