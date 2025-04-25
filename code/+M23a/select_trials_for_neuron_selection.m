function trialindices = select_trials_for_neuron_selection(Trials, settings)
% Return linear indices of trials
%
% ARGUMENT
%-`Trials`: a structure containing the behavioral data
%-`settings`: a structure containing 
%
% OUTPUT
%-`trialindices`: a vector of logicals representing which trial is to be included
validateattributes(Trials, {'struct'},{'scalar'})
validateattributes(settings, {'struct'},{'scalar'})
stereoclick_times_s = M23a.get_stereo_click_time(Trials);
ratinfo = M23a.get_rat_info(unique(string(Trials.rat)));
trialindices = Trials.responded & ...
               Trials.trial_type == 'a' & ...
               Trials.stateTimes.cpoke_out > stereoclick_times_s;
if settings.excludes_perturbation
    if ratinfo.expressesopsin
        trialindices = trialindices & ~Trials.laser.isOn;
    end
end
trialindices = find(trialindices);