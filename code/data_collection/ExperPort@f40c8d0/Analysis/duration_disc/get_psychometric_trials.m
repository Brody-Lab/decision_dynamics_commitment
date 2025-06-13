function [both] = get_psychometric_trials(ratname, task, date, varargin)
pairs =  { ...
    'binsamp', 0 ; ...
    'psych_flag_date', '06/01/23' ; ...
    };
parse_knownargs(varargin, pairs);


load_datafile(ratname, task, date(1:end-1), date(end));
the_day = [date(1:2) '/' date(3:4) '/' date(5:6)];

task_pfx = task(1:4);
if strcmpi(task_pfx, 'dura')
    if binsamp > 0 || datenum(the_day, 'yy/mm/dd') >= datenum(psych_flag_date, 'yy/mm/dd')
        psych_on = saved_history.ChordSection_psych_on;
        both = find(cell2mat(psych_on) > 0);
    else
        % previous to 23 Jan, psychometric trials were those where
        % controls for Tone 1 and Tone 2 were independently set 
        % to be random.
        t1r = getfield(saved_history,'ChordSection_Tone1_random');
        t2r = getfield(saved_history, 'ChordSection_Tone2_random');

        ind1 = find(strcmp(t1r,'on'));
        ind2 = find(strcmp(t2r,'on'));
        both = intersect(ind1, ind2);

    end;
elseif strcmpi(task_pfx, 'dual')
    psych_on = saved_history.ChordSection_pitch_psych;
    both = find(cell2mat(psych_on) > 0);
else
    error('Invalid task! Task an only be duration_discobj or dual_discobj');
end;


