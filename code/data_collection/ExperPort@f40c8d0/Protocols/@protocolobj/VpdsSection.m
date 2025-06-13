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

child_class = ['@' class(value(mychild))];

% pairs = {
% 	'n_done_trials', 	0 ;...
% 	'n_started_trials',	0 ; ...
% 	'maxtrials',		0 ; ...
% }; parse_knownargs(varargin, pairs);

child_vars = { 'MaxValidPokeDur', 'MinValidPokeDur', 'VpdsHazardRate', 'VPDSetPoint','vpds_list', 'h','p','o'};

if ~strcmp(action, 'init')
	for c_var = 1:length(child_vars)
		func_name = [ mfilename '_' child_vars{c_var} ]; 
   		sph = get_sphandle('owner', child_class, 'name', child_vars{c_var}, ...
		    'fullname', func_name); sph = sph{1};
 		eval([child_vars{c_var} ' =  sph;']);
	end;
end;

switch action,
    case 'init',
        EditParam(obj, 'VPDSetPoint', 0.1,x,y,'label','Pre-Sound Set Point', 'param_owner',child_class,'TooltipString','Till which point VPD ought to be increased');next_row(y);
        EditParam(obj, 'VpdsHazardRate',  0.0001, x, y, 'label', 'Pre-Sound HzdRt', 'param_owner', child_class, 'TooltipString', 'Controls level of uniformity of pre-sound time distribution');  next_row(y);
        EditParam(obj, 'MaxValidPokeDur', 0.05, x, y, 'label', 'Pre-Sound Max', 'param_owner', child_class, 'TooltipString', 'Max. silent time before relevant tone onset');  next_row(y);
        EditParam(obj, 'MinValidPokeDur', 0.1, x, y, 'label', 'Pre-Sound Min', 'param_owner', child_class, 'TooltipString', 'Min. silent time before relevant tone onset');  next_row(y);
        next_row(y,0.5);
        SubheaderParam(obj, 'vph_sbh', 'Pre-sound VPD', x, y);

        SoloParamHandle(obj, 'vpds_list', 'value', zeros(1, value(maxtrials)), 'param_owner', child_class);
        SoloParamHandle(obj,'trials_since_last_chng', 'value', 0, 'param_owner', child_class);

        set_callback({MaxValidPokeDur;MinValidPokeDur;VpdsHazardRate}, ...
            {'VpdsSection', 'super','set_future_vpds'; 'VpdsSection', 'super', 'update_plot'; ...
            'ChordSection', 'obj','update_prechord'});

        % --- Now initialize plot
        
        oldunits = get(gcf, 'Units'); set(gcf, 'Units', 'normalized');
        SoloParamHandle(obj, 'h', 'value', axes('Position', [0.06, 0.75, 0.9, 0.07]),'param_owner', child_class); % axes
        SoloParamHandle(obj, 'p', 'value', plot(1, 1, 'k.'),'param_owner', child_class); hold on; % black dots
        SoloParamHandle(obj, 'o', 'value', plot(1, 1, 'ro'),'param_owner', child_class);          % next trial indicator
        set_saveable({h;p;o}, 0);
        xlabel('trial num');
        set(gcf, 'Units', oldunits);
        width = SidesSection(obj, 'get_width');
        add_callback(width, {'VpdsSection', 'super', 'update_plot'});
        
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

    
