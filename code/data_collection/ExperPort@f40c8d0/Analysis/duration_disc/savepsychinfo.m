function [] = savepsychinfo(ratname, varargin)
% Saves psychometric curve data from multiple sessions for given rat
% By setting 'before' or 'after' flags, will save data from psychometric
% sessions before or after (respectively) the lesion.
% The rat's task and necessary dates are obtained from the cell array in
% the file Analysis/duration_disc/rat_task_table

% example:
% savepsychinfo('Violet')
% savepsychinfo('Hatty','action','after')
% savepsychinfo('','action','rat_set','array_name','pitch_psych','area_filt
% er','PFC');

pairs =  { ...
    'from', '000000'; ...
    'to', '999999'; ...
    'action','before'; ... % before, after, both
    'outfile', 'psych' ; ... % name for output file. Default is: psych.mat
    'array_name','duration_psych'; ... % use array names from rat_task_table
    'area_filter', 'ACx'; ...
    };
parse_knownargs(varargin, pairs);

switch action
    case 'rat_set'
        ratlist = rat_task_table('','action',['get_' array_name],'area_filter',area_filter);
        fprintf(1,'Saving data for %i rats (Set = %s, Filter= %s)\n', length(ratlist),array_name, area_filter);
        for r = 1:length(ratlist)
            ratname = ratlist{r};
            fprintf(1,'\tSaving for %s...\n', ratname);
            savepsychinfo(ratname,'action','both');
        end;
        return;
    case 'before'
        ratrow = rat_task_table(ratname);
        dates = ratrow{1,rat_task_table('','action','get_prepsych_col')};
        from = dates{1}; to = dates{2};
        if strcmpi(outfile,'psych')
            outfile = [ratname '_psych_before'];
        end;
    case 'after'
        ratrow = rat_task_table(ratname);
        dates = ratrow{1,rat_task_table('','action','get_postpsych_col')};
        from = dates{1}; to = dates{2};
        if strcmpi(outfile,'psych')
            outfile = [ratname '_psych_after'];
        end;
    case 'both'
        savepsychinfo(ratname,'action','before');
        savepsychinfo(ratname,'action','after');
        return;
    otherwise
        error('invalid action');
end;

fprintf(1,'Saving data from %s to %s...\n',from,to);


global Solo_datadir;
if isempty(Solo_datadir), mystartup; end;
outdir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Set_Analysis' filesep 'psych_compiles' filesep];
fname = [outdir outfile '.mat'];
fprintf(1, 'Output file is:\n%s\n', fname);

if ~exist(outdir, 'dir'), error('Directory does not exist!:\n%s\n', outdir); end;

% if adding a fieldname here, REMEMBER to add it to the list of fields
% saved to a file below
task = ratrow{1,2};
f_left = 'dur_short';
f_right = 'dur_long';

if strcmpi(task(1:3),'dur'),
    psych_field ='psych';
    ispitch=0;
else
    psych_field = 'pitch_psych';
    f_left = 'pitch_low';
    f_right = 'pitch_high';
    ispitch=1;
end;

fields = {f_left,f_right,...
    psych_field,'logdiff', ...
    'logflag', 'sides', ...
    'pstruct','blocks_switch','tones_list','left_prob','bbspl','flipped'};

dates = get_files(ratname, 'fromdate', from, 'todate', to);
get_fields(ratname, 'from', from, 'to',to,'datafields',fields);

left_tone = eval(f_left);
right_tone = eval(f_right);
side_list = sides;
if strcmpi(task(1:3),'dur'),
    psychflag = psych;
else
    psychflag = pitch_psych;
end;

if ~isnan(blocks_switch)% Block_Switch implemented
    if sum(blocks_switch) > 0
   
        psychflag = blocks_switch;
        left_psych = intersect(find(psychflag > 0), find(side_list > 0));
        right_psych = intersect(find(psychflag > 0), find(side_list==0));

        left_tone(left_psych) = tones_list(left_psych);
        right_tone(right_psych) = tones_list(right_psych);
    end;
end;

% precompute reaction time
rxn=rxn_rate(pstruct, numtrials,ispitch);
% precompute timeout array
timeout_count_var= timeout_rate(pstruct, numtrials,'action','timeout_count');



save(fname, 'dates','logdiff', 'hit_history','numtrials',...
    'logflag','psychflag','blocks_switch','left_tone','right_tone', 'side_list',...
    'pstruct','rxn','timeout_count_var','left_prob','bbspl','flipped');

% dates = get_files(ratname, 'fromdate', from, 'todate', to);
%
% logdiff=[];
% hit_history=[];
% max_trials=[];
% logflag=[];
% psychflag=[];
% left_tone=[];
% right_tone=[];
% side_list =[];
%
% for d = 1:rows(dates)
%     date = dates{d};
%     load_datafile(ratname,task,date);
%
%     % sharpening stuff
%     lon = cell2mat(saved_history.ChordSection_vanilla_on);
%     pson = 0;
%     if strcmpi(task(1:3),'dur')
%         pson = cell2mat(saved_history.ChordSection_psych_on);
%     else
%         pson = cell2mat(saved_history.ChordSection_pitch_psych);
%     end;
%     ld = cell2mat(saved_history.ChordSection_logdiff);
%
%     % hits and session boundary
%     hh = eval(['saved.' task '_hit_history']);
%     maxt = eval(['saved_history.' task '_Max_Trials']);
%     maxt = cell2mat(maxt); maxt = maxt(end);
%
%     idx = find(~isnan(hh));
%     maxt = length(idx);
%
%     % other fields
%     sl = saved.SidesSection_side_list; side_list = [side_list sl(1:maxt)];
%     ltone = saved.ChordSection_tone1_list; left_tone = [left_tone ltone(1:maxt)];
%     rtone = saved.ChordSection_tone2_list; right_tone = [right_tone rtone(1:maxt)];
%
%     hit_history = [hit_history hh(1:maxt)];
%     logdiff = [logdiff; ld(1:maxt)];
%     max_trials=[max_trials maxt];
%     logflag = [logflag; lon(1:maxt)];
%     psychflag = [psychflag; pson(1:maxt)];
%     fprintf(1,'.');
% end;
%
% fprintf(1,'\n');
% save(fname, 'dates','logdiff', 'hit_history','max_trials','logflag','psychflag','left_tone','right_tone', 'side_list');