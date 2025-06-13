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
    
    %% declare_new_sounds
    % -----------------------------------------------------------------------
    %
    %         declare_new_sounds
    %
    % -----------------------------------------------------------------------
    
    case 'declare_new_figures'
        
        % Make default figure. We remember to make it non-saveable; on next run
        % the handle to this figure might be different, and we don't want to
        % overwrite it when someone does load_data and some old value of the
        % fig handle was stored as SoloParamHandle "myfig"
        SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = double(figure);
        
        % Make the title of the figure be the protocol name, and if someone tries
        % to close this figure, call dispatcher's close_protocol function, so it'll know
        % to take it off the list of open protocols.
        name = mfilename;
        set(value(myfig), 'Name', name, 'Tag', name, ...
            'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
        
        
        % At this point we have one SoloParamHandle, myfig
        % Let's put the figure where we want it and give it a reasonable size:
        set(value(myfig), 'Position', [485   144   300   400]);
        
        % ----------
        
        x = 5; y = 5;             % Initial position on main GUI window
        
        [x, y] = SavingSection(obj, 'init', x, y);
        next_row(y);
        
        %DispParam(obj, 'nTrials', 0, x, y); next_row(y);
        % For plotting with the pokesplot plugin, we need to tell it what
        % colors to plot with:
%         my_state_colors = SMASection(obj, 'get_state_colors');
%         % In pokesplot, the poke colors have a default value, so we don't need
%         % to specify them, but here they are so you know how to change them.
%         my_poke_colors = struct( ...
%             'L',                  0.6*[1 0.66 0],    ...
%             'C',                      [0 0 0],       ...
%             'R',                  0.9*[1 0.66 0]);
%         
%         [x, y] = PokesPlotSection(obj, 'init', x, y, ...
%             struct('states',  my_state_colors, 'pokes', my_poke_colors));
%         
%         next_row(y);
        
        pos = get(value(myfig), 'Position');
        set(value(myfig), 'Position', [pos(1:2) x+240 y+25]);
        
end
end