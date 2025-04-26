function Diff = compute_PCTH_choice_difference(PCTHsets, varargin)
% compute the trial-averaged difference in the peri-commitment time histogram (PCTH)
%
% ARGUMENT
%
%   PCTH
%       A structure containing the data for computing the peri-commitment time histograms
%
%   with_respect_to
%       A string specifying the sorting method through which the difference shall be computed:
%           "wEA": encoding weight during evidence accumulation
%           "wCM": encoding weight during choice maintenance
%           "w": either "wEA" or "wCM" depending on their absolute magnitude
%
% RETURN
%
%   Diff
%       a structure that computes the difference for both the observed PCTH and the PCTH computed
%       after shuffling the inferred times of decision commitment across trials
specs = M23a.specify_pericommitment_analyses;
ntimesteps = numel(PCTHsets{1}.time_s);
%% right_minus_left_fit
neuronindices = cellfun(@(PCTHset) PCTHset.fit, PCTHsets);
for datatype = ["observed", "shuffled"]
    diffs = cell2mat(cellfun(@(PCTHset) PCTHset.(datatype).right - ...
        PCTHset.(datatype).left, PCTHsets(neuronindices), 'uni', 0));
    [coeff, ~, latent] = pca(diffs);
    for i = 1:3
        fieldname = ['rightleft_fit_PC' num2str(i)];
        proj = coeff(:,i)';
        if proj(end) < proj(1)
            proj = proj*-1;
        end
        Diff.(fieldname).(datatype).est = proj;
        Diff.(fieldname).(datatype).ci = nan(2,ntimesteps);
        Diff.(fieldname).(datatype).fracvar = latent(i)/sum(latent);
    end
end
for i = 1:3
    fieldname = ['rightleft_fit_PC' num2str(i)];
    Diff.(fieldname).time_s = PCTHsets{1}.time_s;
    Diff.(fieldname).ylabel = ['PC' num2str(i) ' (' ...
        num2str(round(Diff.(fieldname).observed.fracvar*100), '%i') '%)'];
end
%% right_minus_left_notfit
neuronindices = cellfun(@(PCTHset) ~PCTHset.fit, PCTHsets);
for datatype = ["observed", "shuffled"]
    diffs = cell2mat(cellfun(@(PCTHset) PCTHset.(datatype).right - ...
        PCTHset.(datatype).left, PCTHsets(neuronindices), 'uni', 0));
    [coeff, ~, latent] = pca(diffs);
    for i = 1:3
        fieldname = ['rightleft_notfit_PC' num2str(i)];
        if size(coeff,2) < i
            Diff.(fieldname).(datatype).est = nan(1,ntimesteps);
            Diff.(fieldname).(datatype).ci = nan(2,ntimesteps);
            Diff.(fieldname).(datatype).fracvar = nan;
        else
            proj = coeff(:,i)';
            if proj(end) < proj(1)
                proj = proj*-1;
            end
            Diff.(fieldname).(datatype).est = proj;
            Diff.(fieldname).(datatype).ci = nan(2,ntimesteps);
            Diff.(fieldname).(datatype).fracvar = latent(i)/sum(latent);
        end
    end
end
for i = 1:3
    fieldname = ['rightleft_notfit_PC' num2str(i)];
    Diff.(fieldname).time_s = PCTHsets{1}.time_s;
    Diff.(fieldname).ylabel = ['PC' num2str(i) '(' ...
        num2str(round(Diff.(fieldname).observed.fracvar*100), '%i') '%)'];
end
%% pref_minus_null
neuronindices = find(cellfun(@(PCTHset) PCTHset.EI, PCTHsets) < specs.EIthreshold & ...
    cellfun(@(PCTHset) PCTHset.EI, PCTHsets) > -specs.EIthreshold);
for datatype = ["observed", "shuffled"]
    diffs = nan(numel(neuronindices), numel(PCTHsets{1}.time_s));
    for n = 1:numel(neuronindices)
        neuronindex = neuronindices(n);
        w = PCTHsets{neuronindex}.wCM;
        if w > 0
            diffs(n,:) = PCTHsets{neuronindex}.(datatype).right - ...
                PCTHsets{neuronindex}.(datatype).left;
        else
            diffs(n,:) = PCTHsets{neuronindex}.(datatype).left- ...
                PCTHsets{neuronindex}.(datatype).right;
        end
    end
    Diff.pref_minus_null.(datatype).est = mean(diffs);
    Diff.pref_minus_null.(datatype).ci = bootci(1e3, @mean, diffs);
end
Diff.pref_minus_null.time_s = PCTHsets{1}.time_s;
Diff.pref_minus_null.ylabel = 'spikes/s';
%% pref_minus_null_EA
neuronindices = find(cellfun(@(PCTHset) PCTHset.EI, PCTHsets) > specs.EIthreshold);
for datatype = ["observed", "shuffled"]
    diffs = nan(numel(neuronindices), numel(PCTHsets{1}.time_s));
    for n = 1:numel(neuronindices)
        neuronindex = neuronindices(n);
        if PCTHsets{neuronindex}.wEA > 0
            diffs(n,:) = PCTHsets{neuronindex}.(datatype).right - ...
                PCTHsets{neuronindex}.(datatype).left;
        else
            diffs(n,:) = PCTHsets{neuronindex}.(datatype).left - ...
                PCTHsets{neuronindex}.(datatype).right;
        end
    end
    Diff.pref_minus_null_EA.(datatype).est = mean(diffs);
    Diff.pref_minus_null_EA.(datatype).ci = bootci(1e3, @mean, diffs);
end
Diff.pref_minus_null_EA.time_s = PCTHsets{1}.time_s;
Diff.pref_minus_null_EA.ylabel = 'spikes/s';
%% pref_minus_null_CM
neuronindices = find(cellfun(@(PCTHset) PCTHset.EI, PCTHsets) < -specs.EIthreshold);
for datatype = ["observed", "shuffled"]
    diffs = nan(numel(neuronindices), numel(PCTHsets{1}.time_s));
    for n = 1:numel(neuronindices)
        neuronindex = neuronindices(n);
        if PCTHsets{neuronindex}.wCM > 0
            diffs(n,:) = PCTHsets{neuronindex}.(datatype).right - ...
                PCTHsets{neuronindex}.(datatype).left;
        else
            diffs(n,:) = PCTHsets{neuronindex}.(datatype).left - ...
                PCTHsets{neuronindex}.(datatype).right;
        end
    end
    Diff.pref_minus_null_CM.(datatype).est = mean(diffs);
    Diff.pref_minus_null_CM.(datatype).ci = bootci(1e3, @mean, diffs);
end
Diff.pref_minus_null_CM.time_s = PCTHsets{1}.time_s;
Diff.pref_minus_null_CM.ylabel = 'spikes/s';