function [x, y, vpds_list] = VpdsSection(obj, action, x, y);    
%
% [x, y, vpds_list] = VpdsSection(obj, action, x, y);
% 
%
% args:    x, y                 current UI pos, in pixels
%          obj                  A locsamp3obj object
%
% returns: x, y                 updated UI position
%          vpd_list             handle to vector of valid poke durs,
%                                  one per trial.

GetSoloFunctionArgs;
% SoloFunction('VpdsSection', 'ro_args', ...
%               {'n_done_trials', 'n_started_trials', 'maxtrials'});

switch action,
    case 'init',
        EditParam(obj, 'MaxValidPokeDur', 0.05, x, y);  next_row(y);
        EditParam(obj, 'MinValidPokeDur', 0.05, x, y);  next_row(y);
        EditParam(obj, 'VpdsHazardRate',  0.01, x, y);  next_row(y);

        SoloParamHandle(obj, 'vpds_list', 'value', zeros(1, value(maxtrials)));

        set_callback({MaxValidPokeDur;MinValidPokeDur;VpdsHazardRate}, ...
            {'VpdsSection', 'set_future_vpds'; 'VpdsSection', 'update_plot'});

        % --- Now initialize plot
        
        oldunits = get(gcf, 'Units'); set(gcf, 'Units', 'normalized');
        SoloParamHandle(obj, 'h', 'value', axes('Position', [0.06, 0.75, 0.8, 0.1])); % axes
        SoloParamHandle(obj, 'p', 'value', plot(1, 1, 'k.')); hold on; % black dots
        SoloParamHandle(obj, 'o', 'value', plot(1, 1, 'ro'));          % next trial indicator
        set_saveable({h;p;o}, 0);
        xlabel('trial num');
        set(gcf, 'Units', oldunits);
        width = SidesSection(obj, 'get_width');
        add_callback(width, {'VpdsSection', 'update_plot'});
        
        % ----
            
        VpdsSection(obj, 'set_future_vpds');
        VpdsSection(obj, 'update_plot');

        
    case 'set_future_vpds',
        if MinValidPokeDur > MaxValidPokeDur,
           MaxValidPokeDur.value = value(MinValidPokeDur);
        end;
        vpds       = value(MinValidPokeDur):0.010:value(MaxValidPokeDur);
        prob       = VpdsHazardRate*((1-VpdsHazardRate).^(0:length(vpds)-1));
        cumprob    = cumsum(prob/sum(prob));
        vl         = value(vpds_list);
        
        for i=n_started_trials+1:length(vpds_list), ...
                vl(i) = vpds(min(find(rand(1)<=cumprob)));
        end;
        vpds_list.value = vl;
        
    case 'update_plot',
        [width, mn, mx] = SidesSection(obj, 'get_width');
        mylist = vpds_list(mn:mx);
        
        set(value(h), 'Ylim', [min(mylist)-0.01, max(mylist)+0.01], 'XLim', [mn-1 mx+1]);
        set(value(p), 'XData', mn:mx, 'YData', mylist);
        set(value(o), 'XData', n_done_trials+1, 'YData', vpds_list(n_done_trials+1));


    
    otherwise,
        error(['Don''t know how to handle action ' action]);
end;    

    
