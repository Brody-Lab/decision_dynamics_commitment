function [x, y, vpds_list] = VpdsSection(obj, action, x, y);    
%
% [x, y, vpds_list] = Section_Vpds(obj, action, x, y);
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
%               {'n_done_trials', 'maxtrials', 'chord_sound_len'});

switch action,
    case 'init',
        EditParam(obj, 'MaxValidPokeDur', 0.05, x, y);  next_row(y);
        EditParam(obj, 'MinValidPokeDur', 0.05, x, y);  next_row(y);
        EditParam(obj, 'VpdsHazardRate',  0.01, x, y);  next_row(y);

        SoloParamHandle(obj, 'vpds_list', 'value', zeros(1, value(maxtrials)));

        set_callback({MaxValidPokeDur;MinValidPokeDur;VpdsHazardRate}, ...
            {'VpdsSection', 'set_future_vpds'; 'VpdsSection', 'update_plot'});

        VpdsSection(obj, 'set_future_vpds');
        VpdsSection(obj, 'update_plot');

        
    case 'set_future_vpds',
        vpds = value(MinValidPokeDur):0.010:MaxValidPokeDur;
        prob       = hazardrate*((1-hazardrate).^(0:length(vpds)-1));
        cumprob    = cumsum(prob/sum(prob));
    
        for i=n_done_trials+1:length(vpds_list), ...
                vpds_list(i) = vpds(min(find(rand(1)<=cumprob)));
        end;
    
    case 'update_plot',

    
    otherwise,
        error(['Don''t know how to handle action ' action]);
end;    

    
