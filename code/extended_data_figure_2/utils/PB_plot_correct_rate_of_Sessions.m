%=INPUT
%   
%   Trials
%       The output of PB_process_data
%
%=OPTIONAL INPUT, NAME-VALUE PAIRS
%   
%   ax
%       The matlab.graphics.axis.Axes object in which the lines will be
%       drawn. If this is empty, a new figure is created.
%
%   Conditions
%       structure from PB_make_Conditions
%
%   fig_idx
%       A numeric scalar and positive integer that specifies the position
%       and size of the created figure. This is ignored if "ax" is
%       specified.
%
%   line_properties
%       A cell array with an even numer of elements specifying additional
%       plotting conditions.
%
%   min_trials
%       minimum number of trials for a session to be counted
%
%   one_line
%       a logical scalar indicating whether to plot all the data connected
%       by a single line. Useful for looking at the robustness of
%       pharmacological effects
%
%   y_data
%       A char array that is either "frac" or "prct"
%
%=Output
%   
%   Res
%       A structure summarizing the results
function Res = PB_plot_correct_rate_of_Sessions(Trials, varargin)
P = inputParser;
addParameter(P, 'ax', [],  @(x) isa(x, 'matlab.graphics.axis.Axes') || isempty(x))
addParameter(P, 'axes_properties', {},@(x) iscell(x) && mod(numel(x),2)==0)
addParameter(P, 'Conditions', [], @(x) isstruct(x));
addParameter(P, 'fig_idx', 1, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive', 'integer'}))
addParameter(P, 'line_properties', {}, @(x) iscell(x) && mod(numel(x),2)==0)
addParameter(P, 'min_trials', 10, @(x) iscell(x) && mod(numel(x),2)==0)
addParameter(P, 'one_line', false, @(x) islogical(x) && isscalar(x))
addParameter(P, 'y_data', 'prct', @(x) all(ismember(x, {'frac', 'prct'})))
parse(P, varargin{:});
P = P.Results;
if isempty(P.Conditions)
    P.Conditions = PB_make_Conditions(Trials);
end
k = 0;
for i = 1:P.Conditions.n
    unique_sessids = unique(Trials.sessid(P.Conditions.trial_index{i}));
    for j = 1:numel(unique_sessids)
        idx = Trials.sessid==unique_sessids(j) & ...
             ~Trials.violated&...
            Trials.responded&...
            Trials.trial_type=='a' & ...
            P.Conditions.trial_index{i};
        n = numel(Trials.is_hit(idx));
        if n < P.min_trials
            warning('Skipping a session with only %i trials', n)
            continue
        end
        x = sum(Trials.is_hit(idx));
        k = k+1;
        Res.sessid(k,1) = unique_sessids(j);
        Res.i_condition(k,1) = i;
        [Res.est(k,1), pci] = binofit(x,n);
        Res.neg95(k,1) = Res.est(k) - pci(1);
        Res.pos95(k,1) = pci(2)-Res.est(k);
    end 
end
[~, I] = sort(Res.sessid);
for f = fieldnames(Res)'
    Res.(f{:}) = Res.(f{:})(I);
end
if strcmp(P.y_data, 'prct')
    Res.est = Res.est*100;
    Res.neg95 = Res.neg95*100;
    Res.pos95 = Res.pos95*100;
end
%%
if ~isempty(P.ax)
    axes(P.ax)
else
    figure('position', fig_get_pos(P.fig_idx))
end
set(gca, 'XLim', [0, numel(Res.est)+1], ...
         'XTick', [])
if P.one_line
    x = 1:numel(Res.est);
    y = Res.est;
    y_neg = Res.neg95;
    y_pos = Res.pos95;
    errorbar(x, y,y_neg, y_pos, 'k');
end
% plot for each condition
if ~P.one_line || P.Conditions.n > 1
    for i = 1:P.Conditions.n
        the_color = PB_get_color_of_condition(P.Conditions, i);
        idx = Res.i_condition == i;
        x = find(idx);
        y = Res.est(idx);
        y_neg = Res.neg95(idx);
        y_pos = Res.pos95(idx);
        if P.one_line
            line_style = 'o';
        else
            line_style = 'o-';
        end
        h = errorbar(x, y,y_neg, y_pos, line_style, 'Color', the_color, P.line_properties{:});
    end
end
ylabel([P.y_data ' correct'])
set(gca, P.axes_properties{:});