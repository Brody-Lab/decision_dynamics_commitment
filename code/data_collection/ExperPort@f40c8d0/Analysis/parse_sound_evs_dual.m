function [sound_evs] = parse_sound_evs_dual(saved, saved_history)

% pre_sound time is in state "prechord"
% cue, pre_go and go are all in state "chord", one after another

evs = saved_history.dual_discobj_LastTrialEvents;
rts = saved_history.dual_discobj_RealTimeStates;
sides = saved.SidesSection_side_list;

vpd = saved.VpdsSection_vpds_list;
tone_dur_L = saved_history.ChordSection_Tone_Dur_L;
tone_dur_R = saved_history.ChordSection_Tone_Dur_R;
prechord   = saved.ChordSection_prechord_list;
godur = saved_history.ChordSection_GODur;
vlst = saved_history.ChordSection_ValidSoundTime;

p = parse_trial(evs, rts);
sound_evs = cell(rows(p),1);

for k = 1:rows(p)
    curr = struct( ...,
        'pre_sound' , [] , ...
        'cue'       , [] , ...
        'pre_go'    , [] , ...
        'go'        , []   ...
        );
    if k == 26
        2;
    end;

    r = rows(p{k}.pre_chord);
%     curr.pre_sound(1:r,1) = p{k}.pre_chord(:,1);
%     curr.pre_sound(1:r,2) = curr.pre_sound(:,1) + vpd(k);
curr.pre_sound = p{k}.pre_chord;

    for j = 1:rows(p{k}.chord)         % everytime the process was restarted
        if sides(k)>0, td = tone_dur_L{k}; else td = tone_dur_R{k};end;

        curr.cue(j,1) = p{k}.chord(j,1);
        curr.cue(j,2) = p{k}.chord(j,1) + td;

        curr.pre_go(j,1) = curr.cue(j,2);
        curr.pre_go(j,2) = curr.cue(j,2) + prechord(k);

        curr.go(j,1) = curr.pre_go(j,2);
        curr.go(j,2) = curr.pre_go(j,2) + vlst{k};
    end;
    
    sound_evs{k} = curr;
end;

