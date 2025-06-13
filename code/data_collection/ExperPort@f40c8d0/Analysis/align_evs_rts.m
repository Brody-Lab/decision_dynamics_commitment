function [] = align_evs_rts(rat, task, date);

load_datafile(rat, task, date(1:end-1), date(end));

evs = eval(['saved_history.' task '_LastTrialEvents']);
rts = eval(['saved_history.' task '_RealTimeStates']);
bbs = saved_history.TimesSection_BadBoySPL;
wns = saved_history.TimesSection_WN_SPL;
trials = rows(evs);

evs_ctr = 1; rts_ctr = 1;

aligned_evs = cell(trials, 1);
aligned_rts = cell(trials, 1);
matcher = zeros(trials, 2);

for t = 1:trials-1
    if ~strcmp(bbs{t}, bbs{t+1}), rts_ctr=rts_ctr+1;end;
    if wns{t} ~= wns{t+1}, rts_ctr=rts_ctr+1;end;
    aligned_evs{t} = evs{evs_ctr}; aligned_rts{t} = rts{rts_ctr};
    matcher(t,:) = [ evs_ctr rts_ctr ];

    evs_ctr = evs_ctr+1; rts_ctr = rts_ctr+1;
end;

if rts_ctr <= rows(rts)
    aligned_evs{trials} = evs{evs_ctr};
    aligned_rts{trials} = rts{rts_ctr};
    matcher(trials,:) = [ evs_ctr rts_ctr ] ;
end;

global Solo_datadir;
base_path = [Solo_datadir filesep 'data' filesep rat filesep];
fname = [base_path 'Realigned' filesep 'data_' task '_' rat '_' date '_realigned.mat'];

if ~exist([base_path 'Realigned' filesep], 'dir')
    mkdir(base_path, 'Realigned');
end;

evs_name = ['saved_history.' task '_LastTrialEvents'];
rts_name = ['saved_history.' task '_RealTimeStates'];
eval([evs_name ' = aligned_evs;']);
eval([rts_name ' = aligned_rts;']);

try,
    save(fname, 'saved', 'saved_history', ...
        'fig_position', 'matcher');
catch
    error('Could not saved realigned data');
end;
