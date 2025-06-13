function [cin_times] = get_short_poke_trials(rat, task, date, f_ver);

% rat = 'Sado';
% task = '@pitchsampobj';
% date = '051117';
% f_ver = 'a';
% Sample usage: get_short_poke_trials('Sado', '@pitchsampobj', '051117',
% 'a');


% For pitchsampobj, the relevant sound is played in state 43, and the
% penalty-less state is 44

load_datafile(rat, task, date, f_ver);

show_only_timeout = 0;      % set to 1 if want to see only trials with timeouts

% get constructor name
if strcmp(task(1),'@')
    task = task(2:end);
end;

% get trials with >= 1 Timeout
sound_state = 43;  % for @pitchsampobj
left_over_sound_state = 44;     % for @pitchsampobj, state where sound is played but rat can withdraw w/o penalty
wpks_state = 45;    % 'wait-for-answer-poke stsate
% Note: A valid Cout may occur either in state 44 or 45.


hdr = char( ...
'Trial Number', ...
    'Left?', ...
    'Hit?', ...
    'Pre-sound time', 'F1', 'F1_F2_Gap', 'F2', 'F2_GO_Gap', 'GO Dur', ...
    ['Cin Time (state ' num2str(sound_state) ')'], ...
    ['Cout Time (state ' num2str(sound_state) ')'], ...
    ['Cout Time (state ' num2str(left_over_sound_state) ')'], ...
    ['Cout Time (state ' num2str(wpks_state) ')'], ...
    'Poke Dur');

% get desired fields
sides = saved.SidesSection_side_list;
hits = eval(['saved.' task '_hit_history']);

evts = eval(['saved_history.' task '_LastTrialEvents']);
vpd = saved.VpdsSection_vpds_list;
f1 = saved_history.ChordSection_F1;
f1_f2_gap  = saved_history.ChordSection_F1_F2_Gap;
f2 = saved_history.ChordSection_F2;
f1a = saved_history.ChordSection_F1a;
f2a = saved_history.ChordSection_F2a;
go_dur  = saved_history.ChordSection_SoundDur;
f2_2_go = saved_history.ChordSection_PostRelevantGap;

% trim to actual trials
num_trials = max(find(~isnan(hits)));
sides = sides(1:num_trials);
hits = hits(1:num_trials);

to_trials = 0;

if show_only_timeout
    to_count = zeros(1,num_trials);
    for t_num = 1:num_trials    % getting trials with timeouts
        e = evts{t_num};
        to_count(t_num) = length(find(e(:,1) == sound_state));
    end;

    % 2 or more entry-exit pairs
    to_trials = find(to_count > 2);
else
    to_trials = 1:num_trials;
end;


% will store trial number, cin_time, cout_time, poke_duration
cin_times = cell(0,0);
cin_times{1} = hdr;
ctimes_ctr = 2;
% loop through all getting cin times
for ctr = 1:length(to_trials)

    e = evts{to_trials(ctr)};
    
   % other trial-related data
    curr_side = sides(to_trials(ctr));
    h = hits(to_trials(ctr));
    prst = vpd(to_trials(ctr));
    f1_now = f1(to_trials(ctr));
    f1f2_g_now = f1_f2_gap(to_trials(ctr));
    f2_now = f2(to_trials(ctr));
    f2_go_gap = f2_2_go(to_trials(ctr));
    go_now = go_dur(to_trials(ctr));

    % Get Cin-Couts in sound_state (short pokes)
    sstate = find(e(:,1) == sound_state);
    key_events = e(sstate,:);  % get rows in sound_state

    start = find(key_events(:,2) == 0); % entry events into sound_state
    latest_Cin = 0;          % USED TO compute poke_dur for all withdraws
        
    for s = 1:length(start)
        st = start(s);
        if (key_events(st,2) == 0)
            latest_Cin = key_events(st,3);
            
            if (key_events(st+1,2) == 2)
                poked_in = key_events(st,3); withdrew = key_events(st+1,3);
                poke_dur  = withdrew-poked_in;
              
                cin_times{ctimes_ctr} = [to_trials(ctr) curr_side h prst f1_now f1f2_g_now ...
                f2_now f2_go_gap go_now ...    
                poked_in withdrew 0 0 poke_dur];
                ctimes_ctr = ctimes_ctr+1;
            end;
        end;
    end;    
    
    % Get Cout events in left_over_sound_state
    sstate = find(e(:,1) == left_over_sound_state);
    key_events = e(sstate,:);
    
    start = find(key_events(:,2) == 0); % a valid poke is continued into this state
    for s = 1:length(start)
        st = start(s);
        if (key_events(st,2) == 0)
            if (key_events(st+1,2) == 2)
                withdrew = key_events(st+1,3);
                poke_dur  = withdrew-latest_Cin;

                cin_times{ctimes_ctr} = [to_trials(ctr) curr_side h prst f1_now f1f2_g_now ...
                f2_now f2_go_gap go_now ...    
                latest_Cin 0 withdrew  0 poke_dur];
                ctimes_ctr = ctimes_ctr+1;
            end;
        end;
    end;
    
    % Get Cout events in WpkS state
    sstate = find(e(:,1) == wpks_state);
    key_events = e(sstate,:);
    
    start = find(key_events(:,2) == 0); % a valid poke is continued into this state
    for s = 1:length(start)
        st = start(s);
        if (key_events(st,2) == 0)
            if (key_events(st+1,2) == 2)
                withdrew = key_events(st+1,3);
                poke_dur  = withdrew-latest_Cin;

                cin_times{ctimes_ctr} = [to_trials(ctr) curr_side h prst f1_now f1f2_g_now ...
                f2_now f2_go_gap go_now ...    
                latest_Cin 0 0 withdrew poke_dur];           
                ctimes_ctr = ctimes_ctr+1;
            end;
        end;
    end;       
end;
