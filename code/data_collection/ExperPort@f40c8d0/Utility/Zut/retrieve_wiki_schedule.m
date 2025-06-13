% <~> function: retrieve_wiki_schedule.m
%     Returns a cell array of strings, one for each entry in the Brody lab
%       wiki rat training schedule page. Each string is the html source for
%       that line (as output by e.g. lynx -cookies -source
%       brodylab.princeton.edu/wiki/index.php/Internal:Rig_training_schedule). 
%     Only lines containing individual entries for rat slots are retained.
%
function sched = retrieve_wiki_schedule()

%     Query Sonnabend to grab the schedule from the net.

if strcmp(get_hostname(),'sonnabend'),
    [status strSched] = ...
        system(['lynx -cookies -source http://' ...
                'brodylab.princeton.edu/wiki/index.php/Internal:Rig_training_schedule']);
else
    [status strSched] = ...
        system('ssh brodylab@sonnabend.princeton.edu lynx -cookies -source http://brodylab.princeton.edu/wiki/index.php/Internal:Rig_training_schedule');
end;

%     Turn the one-line string (with newline chars) into a cell array of
%       strings, retaining only the lines that are rat entries (ignoring,
%       for example, the instructions, headers, etc.).

charNewline     = sprintf('\n');
strEntryPromoter= [charNewline '<td> <b>'];
iNewlines       = strfind(strSched,charNewline);
iEntries        = strfind(strSched,strEntryPromoter);
nLines          = length(iNewlines);
nEntries        = length(iEntries);

sched       = cell(0);

for i=1:nEntries
    iStart      = iEntries(i)+1; %     The start of the entry (the "<" in "<td> <b>")
    iEnd        = iNewlines(find(iNewlines > iStart)) - 1; %     The character before the first endline character after the start of the entry.
    sched{i} = strSched(iStart:iEnd);
end;


end %     end function retrieve_wiki_schedule