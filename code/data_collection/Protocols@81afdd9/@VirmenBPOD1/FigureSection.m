% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%
%            'declare_new_figures'   Make the definition of the figures for the task

function FigureSection(obj, action)

GetSoloFunctionArgs(obj);

switch action
    
    case 'declare_new_figures'

        % For plotting with the pokesplot plugin, we need to tell it what
        % colors to plot with:
        my_state_colors = SMASection(obj, 'get_state_colors');
        PokesPlotSection(obj, 'init', 400, 5, ...
             struct('states',  my_state_colors));
         
        VirmenPlotSection(obj,'init')
   
end
end