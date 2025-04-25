function Trials = remove_unindexed_trials(Trials,trialindices)
% remove unindexed trials
%
%=ARGUMENT
%
%   Trials
%       a struct containing information about the task settings and behavioral events
%
%   trialindices
%       linear indices of trials to be used
%
% RETURN
%
%   Trials
%       Unindexed trials were removed. A new field, "index" is added to enable referencing of the
%       remaining entries to the original structure.
validateattributes(Trials, {'struct'},{})
validateattributes(trialindices, {'numeric'}, {'vector', 'positive', 'integer'})

for fieldname = string(fieldnames(Trials))'
    if ismember(fieldname, ["pharma", "laser", "stateTimes"])
        for f2 = string(fieldnames(Trials.(fieldname)))'
            Trials.(fieldname).(f2) = Trials.(fieldname).(f2)(trialindices);
        end
    else
        Trials.(fieldname) = Trials.(fieldname)(trialindices);
    end
end
Trials.index = trialindices;