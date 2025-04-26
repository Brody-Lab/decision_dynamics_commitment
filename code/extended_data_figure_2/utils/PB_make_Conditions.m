% PB_MAKE_CONDITIONS Makes the table "Conditions" that labels the conditions of each trial
%
%=INPUT
%   
%   Sessions_or_Trials
%       A structure produced by either PB_make_Sessions or PB_make_Trials.
%       If SESSIONS were provided, it is converted into Trials.
%
%=OPTIONAL INPUT, NAME-VALUE PAIRS
%   
%   custom_conditions
%       A cell array whose i-th element is an anonymous function on Trials
%       that results in a logical array indicating whether each trial is in
%       condition i.
%
%   remove_conditions_wo_comparable_ctrl
%       whether to remove perturbatio conditions that do not have a
%       comparable control.
%
%   stim_per
%       Limit the conditions to the specified stimulation conditions as
%       defined in PB_get_constant: {'early', 'late', 'full', 'two_s',
%       'fixation', 'move'}
%
%=OUTPUT
%
%   Conditions
%       A structure with the following fields:
%       - P, the list of parameters used for building Conditions
%       - sessid, a numeric array of session ids of all the sessions used
%       - rat, a string array of the rats used
%       - trial_index, a cell array whose i-th element specifies the trials
%       that belong to the i-th condition
%       - 
function Conditions = PB_make_Conditions(Sessions_or_Trials, varargin)
P = inputParser;
addParameter(P, 'control_only', false, @(x) islogical(x))
addParameter(P, 'custom_conditions', {}, @(x) validateattributes(x, {'cell', 'function_handle'}, {}))
addParameter(P, 'ignore_parameters', {'on_ramp_dur_s'}, @(x) iscell(x) || isstring(x) || ischar(x))
addParameter(P, 'min_trials', 1, @(x) isnumeric(x) && isscalar(x)) % miimum number of trials in conditions
addParameter(P, 'max_rt_s', 5, @(x) isnumeric(x) && isscalar(x)) % miimum number of trials in conditions
addParameter(P, 'on_off_only', false, @(x) islogical(x) && isscalar(x))
addParameter(P, 'probe_trial', '', @(x) ismember(x, {'', 'none', 'only'}))
addParameter(P, 'remove_conditions_wo_comparable_ctrl', true, @(x) islogical(x) && isscalar(x))
addParameter(P, 'stim_per', 'all', @(x) validateattributes(x, {'char', 'string', 'cell'}, {}))
addParameter(P, 'subsequent_trial', [], @(x) isnumeric(x) && isscalar(x))
parse(P, varargin{:});
P = P.Results;
P.stim_per = string(P.stim_per);
P.ignore_parameters = string(P.ignore_parameters);
if iscell(Sessions_or_Trials.violated)
    Trials = PB_make_Trials(Sessions_or_Trials);
else
    Trials = Sessions_or_Trials;
end
if isfield(Sessions_or_Trials.laser, 'analog_output')
    Sessions_or_Trials.laser = rmfield(Sessions_or_Trials.laser, 'analog_output');
end
if isfield('wavelengthNM', Trials.laser)
    Trials.laser.wavelengthNM(isnan(Trials.laser.wavelengthNM)) = 0;
else
    Trials.laser.wavelengthNM = zeros(numel(Trials.laser.isOn),1);
end
if ~isempty(P.subsequent_trial)
    Trials.laser.trial_rel_laser = PB_compute_relative_position(Trials.laser.isOn);
end
if isfield(Trials.laser, 'power_mW')
    Trials.laser.power_mW(isnan(Trials.laser.power_mW)) = 0;
end
if isfield(Trials.laser, 'voltage')
    Trials.laser = rmfield(Trials.laser, 'voltage');
end
if sum(Trials.is_probe_trial)/numel(Trials.is_probe_trial) < 0.01
    Trials.is_probe_trial = false(numel(Trials.is_probe_trial),1);
end
if ~isempty(P.custom_conditions) && isa(P.custom_conditions, 'function_handle')
    P.custom_conditions = {P.custom_conditions};
end
%% Define relevant trial parameters
if P.on_off_only
    parameters_to_sort = table(Trials.laser.isOn(vl_trials), 'VariableName', {'isOn'});
else
    parameters_to_sort = struct2table(Trials.laser); % can add more or rename
    parameters_to_sort.pharma_manip = Trials.pharma.manip; % added 2019-04-08
    parameters_to_sort.is_probe_trial = Trials.is_probe_trial; % added 2019-11-19
end
% remove each parameter that is NaN for all trials
for v = parameters_to_sort.Properties.VariableNames; v = v{:};
    if all(isnumeric(parameters_to_sort.(v))) && all(isnan(parameters_to_sort.(v)))
        parameters_to_sort.(v) = [];
    end
end
if numel(unique(parameters_to_sort.isOn))==1
    parameters_to_sort.is_probe_trial = [];
end
parameters_to_sort.laterality(~parameters_to_sort.isOn) = string;
for i = 1:numel(P.ignore_parameters)
    if ismember(P.ignore_parameters{i}, parameters_to_sort.Properties.VariableNames)
        parameters_to_sort.(P.ignore_parameters{i}) = [];
    end
end
%% Determine unique sets of parameters
Conditions = struct;
Conditions.P = P;
unique_sessid = unique(Trials.sessid);
Conditions.sessid = unique_sessid(:)';
Conditions.rat = unique(Trials.rat);
if isempty(P.custom_conditions)
    [parameter_sets, ~, cond_of_each_trial] = unique(parameters_to_sort, 'rows');
    % Remove conditions with too few trials
    vl_trials = ~Trials.violated & Trials.responded;
    has_enough_trials = sum(cond_of_each_trial == unique(cond_of_each_trial)' & vl_trials) >= P.min_trials;
    parameter_sets = parameter_sets(has_enough_trials, :);
    % Remove non-control trials, if requested
    if P.control_only
        parameter_sets = parameter_sets(~parameter_sets.isOn | ...
                                        parameter_sets.pharma_manip == string('saline'), :);
    end
    % Remove non-probe trials if probe_only were specified
    if ismember('is_probe_trial', parameter_sets.Properties.VariableNames)
        switch P.probe_trial
            case 'only'
                parameter_sets(~parameter_sets.is_probe_trial,:) = [];
            case 'none'
                parameter_sets(parameter_sets.is_probe_trial,:) = [];
        end
    end
    % stimulation condition
    if ~any(P.stim_per == 'all') && isfield(parameter_sets, 'stim_per')
        idx = ismember(parameter_sets.stim_per, P.stim_per);
        parameter_sets = parameter_sets(idx,:);
    end
    n_parameters = numel(parameter_sets.Properties.VariableNames);
    for c = 1:size(parameter_sets,1)
        % trial index
        Conditions.trial_index{c,1} = true(numel(Trials.violated),1);
        for p = 1:n_parameters
            param = parameter_sets.Properties.VariableNames{p};
            Conditions.trial_index{c,1} = Conditions.trial_index{c} & ...
                          parameter_sets.(param)(c) == parameters_to_sort.(param);
        end    
        
    end
else
    n_cond = numel(P.custom_conditions);
    parameter_sets = table;
    for i =1:n_cond
        Conditions.trial_index{i,1} = P.custom_conditions{i}(Trials);
        % determine the common parameters
        [~, T_unique] = find_constant_table_column(parameters_to_sort(Conditions.trial_index{i},:));
        parameter_sets = [parameter_sets; T_unique];
    end
    % remove conditions with too few trials
    has_enough_trials = cellfun(@sum, Conditions.trial_index) >= P.min_trials;
    Conditions.trial_index = Conditions.trial_index(has_enough_trials);
    parameter_sets=parameter_sets(has_enough_trials,:);
    P.custom_conditions = P.custom_conditions(has_enough_trials);
end
%% Provide statistics for each condition
Conditions.parameters = parameter_sets;
Conditions.n = size(Conditions.parameters,1);
for c = 1:Conditions.n
    % violations
    n_violated =  sum(Conditions.trial_index{c} & Trials.violated);
    n_this_cond = sum(Conditions.trial_index{c});
    Conditions.trial_index{c,1} = Conditions.trial_index{c} & ~Trials.violated ...
                                                         & Trials.responded;
    [Conditions.violated.frac(c,1), Conditions.violated.ci95(c,1:2)] = binofit(n_violated, n_this_cond);
    % reaction times
    for side = {'L', 'R'}; side = side{:};
        idx_this_side = Conditions.trial_index{c} & Trials.pokedR == strcmp(side, 'R');
        reaction_time_s = Trials.stateTimes.cpoke_out(idx_this_side) - Trials.stateTimes.cpoke_req_end(idx_this_side);
        reaction_time_s(reaction_time_s > P.max_rt_s) = [];
        Conditions.rt.(side).median(c,1) = nanmedian(reaction_time_s);
        Conditions.rt.(side).ci95(c,1:2) = quantile(reaction_time_s, [0.025, 0.975]);
    end
    % movement times
    for side = {'L', 'R'}; side = side{:};
        idx_this_side = Conditions.trial_index{c} & Trials.pokedR == strcmp(side, 'R');
        move_t = Trials.stateTimes.spoke(idx_this_side) - Trials.stateTimes.cpoke_out(idx_this_side);
        move_t(move_t > P.max_rt_s) = [];
        Conditions.move_time_s.(side).median(c,1) = nanmedian(move_t);
        Conditions.move_time_s.(side).ci95(c,1:2) = quantile(move_t, [0.025, 0.975]);
    end
    % frac_chose_R
    Conditions.frac_chose_R(c,1) = sum(Trials.pokedR(Conditions.trial_index{c})) / ...
                                   sum(Conditions.trial_index{c});
   % frac_correct
    Conditions.frac_correct(c,1) = sum(Trials.is_hit(Conditions.trial_index{c})) / ...
                                   sum(Conditions.trial_index{c});
   % frac_probe
   Conditions.frac_probe(c,1) = sum(Trials.is_probe_trial(Conditions.trial_index{c})) / ...
                                sum(Conditions.trial_index{c});
end
%% is this a control or pertubation condition? Index the perturbation conditions
Conditions.is_ctrl = ~Conditions.parameters.isOn & ...
                    any(Conditions.parameters.pharma_manip == string({'', 'none', 'saline', 'isofluorane'}),2);
Conditions.i_perturb = zeros(Conditions.n,1);
for i = 1:Conditions.n
    Conditions.i_perturb(i) = max(Conditions.i_perturb) + 1-Conditions.is_ctrl(i);
end
Conditions.n_perturb = max(Conditions.i_perturb);
Conditions.n_ctrl = sum(Conditions.is_ctrl);
Conditions.comparable_ctrl = PB_find_unique_comparable_control(Conditions);
%% Remove perturbation conditions without comparable control
if P.remove_conditions_wo_comparable_ctrl
    no_comparble_ctrl = isnan(Conditions.comparable_ctrl) & ~Conditions.is_ctrl;
    if sum(no_comparble_ctrl) > 1 && ~all(Trials.is_anesthetized)
        fprintf('\n Removing %i perturbation condition(s) that lacks a comparable control condition', ...
                sum(no_comparble_ctrl));
        Conditions = struct_index(Conditions, ~no_comparble_ctrl);
        Conditions.n = sum(no_comparble_ctrl);
        Conditions.n_perturb = sum(~Conditions.is_ctrl);
        Conditions.n_ctr = sum(Conditions.is_ctrl);
    end
end