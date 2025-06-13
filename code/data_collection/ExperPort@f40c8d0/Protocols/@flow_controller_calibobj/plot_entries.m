% GF 4/30/07

function [] = plot_entries(obj, action)
   
GetSoloFunctionArgs;

switch action
    
    case 'init'
        
        % initialize plot
        SoloParamHandle(obj, 'plot_handle',  'value', axes('Position', [0.15, 0.3, 0.55, 0.55]));
        xlabel('voltage');
        ylabel('flow rate');
        
    case 'update'
        
        % make the plot the current axes
        axes(value(plot_handle));
        cla;
        
        % plot the data
        plot(lookup_table(1, :), lookup_table(2, :), 'ko');
        
        % plot the best fit line
        hold on;
        if size(lookup_table, 2) > 1 % if more than 1 entry
            
            coeffs = polyfit(lookup_table(1, :), lookup_table(2, :), 1);
            
            x_plot = [0:5];

            y_fit = (coeffs(1) .* x_plot) + coeffs(2);

            plot(x_plot, y_fit, 'r-');
            
        end
        
        % set  axes limits and labels
        if size(lookup_table, 2) > 0
            min_y = min(0, min(lookup_table(2, :)));
            max_y = max(100, max(lookup_table(2, :)));
        else
            min_y = 0;
            max_y = 100;
        end
        set(gca, 'XLim', [0 5], 'YLim', [min_y max_y]);
        
        xlabel('voltage');
        ylabel('flow rate');
        
        
        
        
    otherwise
        
        error(['Don''t know how to handle action ' action]);

end;
