% PB_FIND_UNIQUE_COMPARABLE_CONTROL For each perturbation condition in
% CONDITIONS, try to identify a unique, comparable control condition
%
%=INPUT
%   Conditions
%       Structure made by PB_make_Conditions
%
%=OUTPUT
%   comparable_ctrl
%       A logical array indicating the index of the comparable control
%       condition for each perturbation conditon. If comparable_ctrl =
%       [NaN, NaN, 1, 2], then condition #3's comparable control is
%       condition #1, and condition #4's comparable control is condition #2
function comparable_ctrl = PB_find_unique_comparable_control(Conditions)
comparable_ctrl = nan(Conditions.n, 1);
for c = 1:Conditions.n
    if Conditions.parameters.isOn(c) % laser
        idx = ~Conditions.parameters.isOn;
        if ismember('is_probe_trial', Conditions.parameters.Properties.VariableNames)
            idx = idx & Conditions.parameters.is_probe_trial(c) == ...
                        Conditions.parameters.is_probe_trial;
        end  
    elseif strcmp(Conditions.parameters.pharma_manip(c), 'muscimol')
        idx=strcmp(Conditions.parameters.pharma_manip, 'saline');
    else
        continue
    end
    if sum(idx) == 1
        comparable_ctrl(c,1) = find(idx);
    else
        warning('Cannot find unique comparable control for condition %i', c)
        comparable_ctrl(c,1) = nan;
    end
end