function [change_sets] = tone_sets_alternate(rat, task, date, varargin)

pairs = {
    'pitch_task', 0 ; ...
    };
parse_knownargs(varargin, pairs);

load_datafile(rat, task, date(1:end-1), date(end));

t = eval(['saved.' task '_n_done_trials;']);
if pitch_task
    tone1 = saved.ChordSection_pitch1_list;
    tone2 = saved.ChordSection_pitch2_list;
else
    tone1 = saved.ChordSection_tone1_list; tone1 = tone1(1:t);
    tone2 = saved.ChordSection_tone2_list; tone2 = tone2(1:t);
end;


left_diff = []; right_diff = [];
for k = 1:length(tone1)-1
    if tone1(k+1) ~= tone1(k)
        left_diff = [left_diff k+1];
    end;
    if tone2(k+1) ~= tone2(k)
        right_diff = [right_diff k+1];
    end;
end;

mx = max(length(left_diff), length(right_diff));

fprintf(1, '\nTONE SETS:\n');
fprintf(1, '----------------------\n');

lctr = 1; rctr = 1;
if pitch_task, fmt = '%2.1f'; else, fmt='%3.0f';end; 

%fprintf(1,'(%i, %i)', left_diff(lctr), right_diff(rctr));

change_sets = cell(0,0);
change_sets{1} = [1 tone1(1) tone2(1)]; cctr=2;
fprintf(1,['Start: (t=1) (' fmt ', ' fmt ')\n'], tone1(1), tone2(1));
while (lctr <= length(left_diff)) && (rctr <= length(right_diff))
    tnum = 0; lhs = 0; rhs = 0;
    lhs = tone1(left_diff(lctr)); rhs = tone2(right_diff(rctr));
    if ~pitch_task,lhs=lhs*1000; rhs=rhs*1000; end;
    if left_diff(lctr) == right_diff(rctr)
        tnum = left_diff(lctr);
        fprintf(1,['Both changed (t=%i): (' fmt ', ' fmt ')\n'], left_diff(lctr), lhs, rhs)
        lctr = lctr+1; rctr=rctr+1;

    elseif left_diff(lctr) > right_diff(rctr)
        tnum = right_diff(rctr);
        fprintf(1,['Right changed (t=%i): (' fmt ', ' fmt ')\n'], right_diff(rctr), tone1(left_diff(lctr)), rhs)
        rctr = rctr+1;
    elseif right_diff(rctr) > left_diff(lctr)
        tnum = left_diff(lctr);
        fprintf(1,['Left changed (t=%i): (' fmt ', ' fmt ')\n'], left_diff(lctr), lhs, tone2(right_diff(rctr)))
        lctr = lctr+1;
    end;
    change_sets{cctr} = [tnum lhs rhs]; cctr = cctr + 1;
    
%     if (lctr <= length(left_diff)) && (rctr <= length(right_diff))
%         fprintf(1,'(%i, %i)', left_diff(lctr), right_diff(rctr)); 
%     end;
end;


