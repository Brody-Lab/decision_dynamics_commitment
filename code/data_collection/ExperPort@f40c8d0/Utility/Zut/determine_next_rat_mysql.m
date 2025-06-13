% <~> .../Utility/determine_next_rat_bdata.m
%     Query a Brodylab mysql database to determine which rat should run
%       next in this rig. Brody lab Custom Script
%     Sebastien Awwad, 2008-Feb, 2008-Aug
%
%     This script connects to Sonnabend's mysql server bdata database and
%       grabs the entry dealing with the current rig for the coming
%       timeslot. This allows us to select the next rat and experimenter
%       automatically.
%
%     returns:   nextrat, errID, errmsg
%
%       nextrat is a struct with at least the following fields:
%           experimenter    e.g. 'Jeff'
%           ratname         e.g. 'J003'
%           timeslot        e.g. '8-10', '10-12', '12-2', etc.
%           technician      e.g. 'Glyn'
%           platform        0 for RPbox or 1 for Dispatcher/RunRats
%           protocol        e.g. 'Multipokes3', 'ExtendedStimulus', etc.
%           rignum          integer rig identifier (as listed in database)
%
%       errID report:
%           0:  no problem. returned experimenter and ratname, or empty
%                 strings if no rats are running in this rig in this slot.
%           1:  did not find any information for this rig-timeslot
%                 combination in the database for any day in the past or
%                 today
%           2:  unable to determine rig number from RIGS;Rig_ID setting or
%                 number in hostname.
%           -1: code error. errID was not set. Contact a developer.
%
function [nextrat errID errmsg] = determine_next_rat_mysql()
errorlocation = 'Problem in Utility/determine_next_rat_mysql.m: ';
errID = -1; errmsg = ''; %#ok<NASGU>
nextrat = struct('experimenter','','ratname','','timeslot','', ...
    'technician','','platform','','protocol','','rignum',NaN);

%     Constants
nameSchedTable      = getZutConstant('nameSchedTable');

%     What rig are we on?
[iRig errID_t errmsg_t] = getRigID();
if errID_t,
    errID = errID_t;
    errmsg = [errorlocation errmsg_t];
    return;
end;

%     What timeslot would a rat loading now be in?
[strTimeslot e m] = lookup_timeslot(clock);
if e, error(['Timeslot lookup failed. Programming error. Please contact a developer. lookup_timeslot returned the following error message: ' m]); end;
%     What's the numeric ID of that timeslot string?
[iTimeslot e m] = lookup_timeslot(strTimeslot);
if e, error(['Timeslot lookup failed. Programming error. Please contact a developer. lookup_timeslot returned the following error message: ' m]); end;

%     Grab the line from the mysql database that deals with this rig for
%       this time slot on this day. If there are multiple lines returned,
%       we use the most recent date that is not after today. If there are
%       multiple dates for the same day-timeslot-rig combination (which
%       is currently impossible, since it's a unique key), we use the
%       highest schedentryid in that set.
[schedentryid iDate iTimeslot_chk iRig_chk iSystem protocol experimenter ratname technician instructions] = ...
    bdata(['select schedentryid,date,timeslot,rig,system,protocol,experimenter,ratname,technician,instructions from ' nameSchedTable ' where date<="' datestr(now,'yyyy-mm-dd') '" and timeslot=' int2str(iTimeslot) ' and rig=' int2str(iRig) ' order by date desc,schedentryid;']);

% <^> If there are leaading or trailing spaces on the experimenter or
% ratname then remove them.

experimenter=strtrim(experimenter);
ratname=strtrim(ratname);
    
%     If this Timeslot-Rig combination has never had an entry for some
%       bizarre reason, throw a warning, since that should not be, even if
%       the rat/experimenter/etc. fields are empty in an extant row.
if isempty(iDate),
    errID = 1; errmsg = [errorlocation 'There is no row at all regarding any past date for timeslot:' int2str(iTimeslot) ', rig:' int2str(iRig) '. This suggests an error.'];
    nextrat.timeslot    = strTimeslot;
    nextrat.technician  = '';
    nextrat.experimenter= '';
    nextrat.ratname     = '';
    nextrat.platform    = [];
    nextrat.protocol    = '';
    nextrat.instructions= '';
    warning(errmsg); %#ok<WNTAG>
    return;
end;

%     If there is a row, but there's just no rat scheduled in the row of
%       interest (most recent date up to and including today), then we
%       return the appropriate values and display a message stating that
%       there's no rat scheduled.
if isempty(iSystem) || isempty(ratname) || isnan(iSystem(1)) || isempty(ratname{1}),
    errID = 0; errmsg = ['No rat scheduled for this rig (' int2str(iRig) ') on this day (' datestr(now,'yyyy-mm-dd') ') in this timeslot (' int2str(iTimeslot) ').'];
    nextrat.timeslot    = strTimeslot;
    nextrat.technician  = '';
    nextrat.experimenter= '';
    nextrat.ratname     = '';
    nextrat.platform    = [];
    nextrat.protocol    = '';
    nextrat.instructions= '';
    display(errmsg);
    return;
end;



%     Extract values from cells/arrays (using the first row returned, which
%       is, because of the sort options used, the most recent date up to
%       and including today (not after).
%     Cells/arrays to single values:
schedentryid    = schedentryid(1);  %#ok<NASGU> %     array
iDate           = iDate{1};         %#ok<NASGU> %     cell
iTimeslot_chk   = iTimeslot_chk(1); %     array
iRig_chk        = iRig_chk(1);      %     array
iSystem         = iSystem(1);       %     array
protocol        = protocol{1};      %     cell
experimenter    = experimenter{1};  %     cell
ratname         = ratname{1};       %     cell
technician      = technician{1};    %     cell
instructions    = instructions{1};  %     cell


if iTimeslot ~= iTimeslot_chk, errID = 3; errmsg = ['Timeslot requested and timeslot received from mysql server do not match. Requested: ' int2str(iTimeslot) '; received: ' int2str(iTimeslotchk)]; error(errmsg); end; %#ok<NASGU>
if iRig      ~= iRig_chk     , errID = 3; errmsg = ['Rig number requested and rig number received from mysql server do not match. Requested: ' int2str(iRig)  '; received: ' int2str(iRig_chk)    ]; error(errmsg); end; %#ok<NASGU>
nextrat.timeslot        = strTimeslot;
nextrat.technician      = technician;
nextrat.experimenter    = experimenter;
nextrat.ratname         = ratname;
nextrat.platform        = lookup_system(iSystem); %     Translate index into string.
nextrat.protocol        = protocol;
nextrat.instructions    = instructions;
%nextrat.rignum          = tokens{7}(1);
errID = 0; errmsg = '';

end %     end of function determine_next_rat_bdata
