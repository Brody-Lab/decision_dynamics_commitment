function [] = num_psych_sessions(rat, task, varargin)
% function [] = num_psych_sessions(rat, task, varargin)
% For the date range specified, returns the number of sessions during which
% the rat performed psychometric sampling trials
% Also gives the dates for these sessions
% Only sessions where more than 10 psych trials are performed are counted as valid psychometric sessions.


pairs = {'from', '000000'; 
      'to', '999999';};
parse_knownargs(varargin,pairs);

date_set = get_files(rat, 'fromdate', from, 'todate', to);

psych_set = {};

for d = 1:rows(date_set)
    load_datafile(rat, task, date_set{d});
    
   if strcmp(task(1:3), 'dur') 
     psych_on = saved_history.ChordSection_psych_on;     
   else
     psych_on = saved_history.ChordSection_pitch_psych;
   end;
     psych = find(cell2mat(psych_on) > 0);
     if length(psych) > 10
       psych_set{end+1} = date_set{d};       
     end;
end;

fprintf(1,'---------------------------\n');
fprintf(1,'No. psych sessions: %i\n', length(psych_set));
fprintf(1,'No. sessions: %i\n', rows(date_set)); 
fprintf(1,'Psych sessions:\n');
for k = 1:length(psych_set)
fprintf(1, '\t%s\n', psych_set{k});
end;
fprintf(1,'---------------------------\n');
