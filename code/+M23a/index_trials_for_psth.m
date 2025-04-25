function Trialindices = index_trials_for_psth(trials)
% Group trials for computing peristimulus time histograms
%
%=ARGUMENT
%
%   trials
%       A cell array whose each element is a struct containing the data for one trial
%
%=RETURN
%   
%   Trialindices
%       A struct whose fields are the trial conditions for computing the peristimulus time
%       histogram. Each field contains a vector of logicals indicating which trials are included in
%       the condition
validateattributes(trials, {'cell'}, {'vector'})
psthsettings = M23a.psthsettings;
Trialindices.unconditioned = true(numel(trials),1);
Trialindices.leftchoice = cellfun(@(x) x.choice == 0, trials) & Trialindices.unconditioned;
Trialindices.rightchoice = cellfun(@(x) x.choice == 1, trials) & Trialindices.unconditioned;
Trialindices.leftevidence = cellfun(@(x) x.gamma < 0, trials) & Trialindices.unconditioned;
Trialindices.rightevidence = cellfun(@(x) x.gamma > 0, trials) & Trialindices.unconditioned;
Trialindices.leftchoice_strong_leftevidence = cellfun(@(x) x.choice == 0 & ...
    x.gamma < -psthsettings.weakstrongthreshold, trials) & Trialindices.unconditioned;
Trialindices.leftchoice_weak_leftevidence = cellfun(@(x) x.choice == 0 & ...
    x.gamma >= -psthsettings.weakstrongthreshold & ...
    x.gamma < 0, trials) & Trialindices.unconditioned;
Trialindices.rightchoice_weak_rightevidence = cellfun(@(x) x.choice == 1 & ...
    x.gamma >  0 & ...
    x.gamma <= psthsettings.weakstrongthreshold, trials) & Trialindices.unconditioned;
Trialindices.rightchoice_strong_rightevidence = cellfun(@(x) x.choice == 1 & ...
    x.gamma > psthsettings.weakstrongthreshold, trials) & Trialindices.unconditioned;