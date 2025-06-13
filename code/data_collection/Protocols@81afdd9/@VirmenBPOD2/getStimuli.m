function stimuli = getStimuli(ac_trial, orig_stimuli)

stimuli = orig_stimuli;

if ~iscell(ac_trial{1,'cue_pos_left'})
    left_pos = ac_trial{1,'cue_pos_left'};
else
    left_pos = ac_trial{1,'cue_pos_left'}{:};
end
if ~iscell(ac_trial{1,'cue_pos_right'})
    right_pos = ac_trial{1,'cue_pos_right'};
else
    right_pos = ac_trial{1,'cue_pos_right'}{:};
end

leftCombo = ac_trial{1,'cue_presence_left'}{:};
rightCombo = ac_trial{1,'cue_presence_right'}{:};
nleft = sum(leftCombo);
nright = sum(rightCombo);
stimuli.cueCombo = [leftCombo; rightCombo];

if nleft >= nright
    stimuli.nSalient = nleft;
    stimuli.nDistract = nright;
    stimuli.trialType = Choice.L;
else
    stimuli.nSalient = nright;
    stimuli.nDistract = nleft;
    stimuli.trialType = Choice.R;
end

if nleft == 0
    left_pos = repmat(-1,size(left_pos));
end
if nright == 0
    right_pos = repmat(-1,size(right_pos));
end

stimuli.cuePos = {left_pos, right_pos};
stimuli.index = -1;

end