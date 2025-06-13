%     .../Utility/determine_next_rat.m
%     Query the Brodylab wiki to determine what rat will run next; Brody lab Custom Script;
%     this file written by Sebastien Awwad, 2007
%
%     In its current incarnation, this script connects to Sonnabend via ssh
%       and grabs the line dealing with the current rig for the nearest
%       start time from the Brody lab wiki. This allows us to select the
%       next rat and experimenter automatically.
%
%     In the future, this will be generalized.
%
%     returns:   nextrat, errID, errmsg
%
%       nextrat is a struct with at least the following fields:
%           experimenter    e.g. 'Jeff'
%           ratname         e.g. 'J003'
%           timeslot        e.g. '8-10', '10-12', '12-2', etc.
%           technician      e.g. 'Glyn'
%           platform        'RPBox', 'Dispatcher', or 'RunRats'
%           protocol        e.g. 'Multipokes3', 'ExtendedStimulus', etc.
%           rignum          integer rig identifier (as listed in wiki)
%
%       errID report:
%           0:  no problem. returned experimenter and ratname, or empty
%                 strings if no rats are running in this rig in this slot.
%           1:  did not find information for this rig in the wiki, or
%                 unable to connect to or parse wiki.
%           2:  unable to determine rig number from RIGS;Rig_ID setting or
%                 number in hostname.
%           3:  consistency check failed. see errmsg.
%           -1: code error. errID was not set. Contact a developer.
%
function [nextrat errID errmsg] = determine_next_rat()
errorlocation = 'Error in Utility/determine_next_rat.m: ';
errID = -1; errmsg = ''; %#ok<NASGU>
nextrat = struct('experimenter','','ratname','','timeslot','', ...
    'technician','','platform','','protocol','','rignum',NaN);

%     What rig are we on?
[rignum errID_t errmsg_t] = bSettings('get','RIGS','Rig_ID');
if errID_t,
    [trash1 trash2 trash3 rignum] = regexp(get_hostname,'[0123456789]+');
    if isempty(rignum),
        errID = 2; errmsg = [errorlocation 'RIGS;Rig_ID setting is not set or not a number, and I could not find a number in the machine''s hostname, so I am not going to try to parse the wiki to extract scheduling information for this rig. Error message from attempt to retrieve RIGS;Rig_ID setting follows:   ' errmsg_t];
        return;
    else rignum = rignum{1};
    end;
end;

%     What time is it?
hr = str2double(datestr(now,'MM'))/60 + str2double(datestr(now,'HH'));
if     hr > 17.5, timeslot= '8-10p';
elseif hr > 15.5, timeslot= '6-8p' ;
elseif hr > 13.0, timeslot= '4-6p' ;
elseif hr > 10.7, timeslot='12-2p' ;
elseif hr >  9,   timeslot='10-12a';
else              timeslot= '8-10a';
end;

%     Grab the line from the wiki that deals with this rig for this time
%       slot. We use Sonnabend to do our connection for us, for a variety
%       of good reasons.
if ~ispc,
        command = [ ...
        'ssh brodylab@brodyfs2 lynx -cookies -dump' ...
        ' http://brodylab.princeton.edu/wiki/index.php/Internal:Rig_training_schedule' ...
        ' | grep ''' timeslot '''' ...
        ' | awk' ...
        ' ''/' timeslot ' ([^%]+ [^%]+ [^%]+ [^%]+ ' int2str(rignum) ' |[^%]* ' int2str(rignum) '$)/' ...
        ' {print $1,$2,$3,$4,$5,$6,$7}'''];
    
    [exitval output] = system(command);
else
    command = [ ...
        'ssh brodylab@brodyfs2 "lynx -cookies -dump' ...
        ' http://brodylab.princeton.edu/wiki/index.php/Internal:Rig_training_schedule' ...
        ' | grep ''' timeslot '''' ...
        ' | awk' ...
        ' ''/' timeslot ' ([^%]+ [^%]+ [^%]+ [^%]+ ' int2str(rignum) ' |[^%]* ' int2str(rignum) '$)/' ...
        ' {print $1,$2,$3,$4,$5,$6,$7}''"'];
    [exitval output] = system(command);
end;

%     The output from grep should look like this, for example:
%       8-10 Glyn Jeff J005 RunRats Classical 11
%      (time tech exp  rat  base    protocol  rig)

%     This commented segment is for illustrative purposes and for testing.
%       It would compile the full schedule for the day, minux comments, in
%       a very inefficient way.
% schedule = [];
% timeslots = {'8-10' '10-12' '12-2' '2-4' '4-6' '6-8'};
% for i=1:6;
%     timeslot = timeslots{i};
%     for rignum=rigs;
%         [e o] = system(['ssh brodylab@brodyfs2 lynx -cookies -dump' ...
%             ' http://brodylab.princeton.edu/wiki/index.php/Internal:Rig_training_schedule' ...
%             ' | grep ''' timeslot '''' ...
%             ' | awk' ...
%             ' ''/' timeslot ' (.+ .+ .+ .+ ' int2str(rignum) ' |.* ' int2str(rignum) '$)/' ...
%             ' {print $1,$2,$3,$4,$5,$6,$7}''']);
%         schedule = [schedule sprintf('\n') o];
%     end;
% end;
% display(schedule);


if isempty(output),
    errID = 1; errmsg = [errorlocation 'Failed to find any lines listing this rig for this time slot in the wiki, or output from system command was empty for some other reason.'];
    return;
end;

%     Grab (up to) the first seven tokens in the first line returned.
%     We never parse past a % symbol. Comments should be preceded by a %.
%     (We shouldn't have more than one line returned by the awk above, by the way.)
tokens = textscan(output,'%[^% \t] %[^% \t] %[^% \t] %[^% \t] %[^% \t] %[^% \t]',1);
if isempty(tokens{6}),
    %     If we don't have at least 6 tokens, assume this is an empty slot.
    %     Examples of empty slots:
    %       '8-10  Glyn 11'                  empty
    %       '12-2  Glyn Carlos C008 10'      empty
    %       '2-4   Glyn Carlos Runrats 3'    empty
    %
    %     Because some experimenters are excluding the protocol field, I
    %       can't expect 7 fields instead of 6, and because some
    %       experimenters are leaving most of the fields in when a rat is
    %       not running in that slot (taking out only the rat name), I
    %       can't prevent the following line from being misread:
    %       
    %           '4-6   Glyn Carlos Runrats Classical 5'
    %
    %         i.e. if the *only* field not filled is the rat name,
    %           determination will fail. The line is interpreted to mean
    %           that a rat named "Runrats" should be run.
    errID = 0;
    return;
else
    nextrat.timeslot        = tokens{1}{1};
    nextrat.technician      = tokens{2}{1};
    nextrat.experimenter    = tokens{3}{1};
    nextrat.ratname         = tokens{4}{1};
    nextrat.platform        = tokens{5}{1};
    nextrat.protocol        = tokens{6}{1};
    %nextrat.rignum          = tokens{7}(1);
    if         strmatch(nextrat.timeslot, timeslot),
        errID = 0;
        return;
    else
        errID = 3;
        errmsg = [errorlocation 'Wiki parsing consistency check failed. Wiki parse returned:' ...
            ' timeslot     ="' nextrat.timeslot '" (expecting "' timeslot '" -- this should not be different...),' ...
            ' technician   ="' nextrat.technician '",' ...
            ' experimenter ="' nextrat.experimenter '",' ...
            ' ratname      ="' nextrat.ratname '",' ...
            ' platform     ="' nextrat.platform '",' ...
            ' protocol     ="' nextrat.protocol '",'];
        %   ' rignum_      ="' nextrat.rignum '" (expecting "' rignum '" -- this is allowed to be different).'];
        return;
    end;

end;

end
