function [x, y, side_list, odor_list, WaterDelivery]=SidesSection(obj,action,x,y);
%
% [x, y, side_list, WaterDelivery] = ...
%    SidesSection(obj, action, x, y);
%
% args:    x, y                  current UI pos, in pixels
%          n_done_trials         handle to number of completed trials
%          hit_history           handle to history of hits versus errors
%                                (vector: 1=hit, 0=error, len=n_done_trials)
%          maxtrials             max number of trials in experiment
%          obj                   A classical_soloobj object
%
% returns: x, y                  updated UI pos
%          side_list             handle to vector of correct sides,
%                                   one per trial.
%          WaterDelivery         handle to type of delivery (direct, etc).
%          update_sidesplot_fn  function that updates sides and rewards plot
%          set_next_side_fn     fn, uses error hist to override correct side
%

GetSoloFunctionArgs;

switch action,

    case 'init', % ----------  INIT  -------------------------

        SoloParamHandle(obj, 'odor_list', 'value', zeros(1, value(maxtrials))); % vector of which odor will be presented on each trial
        SoloParamHandle(obj, 'side_list', 'value', zeros(1, value(maxtrials)));

        % Params that control the reward mode:
        MenuParam(obj, 'WaterDelivery', {'only if nxt pke corr', 'next corr poke'}, 1, x, y); ...
          next_row(y, 1.1);
        SubheaderParam(obj, 'sides_sbh', 'Trial Side & Schedule', x, y); ...
          next_row(y);

        % ---- Now initialize plot
        oldunits = get(gcf, 'Units'); set(gcf, 'Units', 'normalized');
        SoloParamHandle(obj, 'h',  'value', axes('Position', [0.06, 0.85, 0.8, 0.12])); % axes
        SoloParamHandle(obj, 'p',  'value', plot(-1, 1, 'b.')); hold on; % blue dots
        SoloParamHandle(obj, 'g',  'value', plot(-1, 1, 'g.')); hold on; % green dots
        SoloParamHandle(obj, 'r',  'value', plot(-1, 1, 'r.')); hold on; % red dots
        SoloParamHandle(obj, 'o',  'value', plot(-1, 1, 'ro')); hold on; % next trial indicator
        SoloParamHandle(obj, 'thl','value', text( -1 * ones(1,maxtrials), 0.5*ones(1,maxtrials),'l'));
        SoloParamHandle(obj, 'thr','value', text(-ones(1,maxtrials), 0.5*ones(1,maxtrials),'r'));
        SoloParamHandle(obj, 'thh','value', text(-ones(1,maxtrials), 0.5*ones(1,maxtrials),'h'));
        SoloParamHandle(obj, 'thm','value', text(-ones(1,maxtrials), 0.5*ones(1,maxtrials),'m'));
        set_saveable({h;p;g;r;o;thl;thh;thm}, 0);
        set([value(thl);value(thr);value(thh);value(thm)], ...
            'HorizontalAlignment', 'Center', 'VerticalAlignment', ...
            'middle', 'FontSize', 8, 'FontWeight', 'bold', 'Color', 'b', ...
            'FontName', 'Helvetica', 'Clipping', 'on');

        set(value(h), 'YTick', [0 1], 'YTickLabel', {'Right', 'Left'});
        xlabel('');

        set(gcf, 'Units', oldunits);

        % "width", an EditParam to control the # of trials in the plot:
        SoloParamHandle(obj, 'width', 'type', 'edit', 'label', 'ntrials', ...
            'labelpos', 'bottom','TooltipString', 'number of trials in plot', ...
            'value', 90, 'position', [490 645 35 40]);
        set(get_ghandle(width), 'Units','normalized', 'Position',[0.88 ...
                            0.9 0.05 0.035]); 
        set(get_lhandle(width), 'Units','normalized', 'Position', [0.88 ...
                            0.85 0.05 0.045]);        
        set_callback(width, {'SidesSection', 'update_plot'});

        % --- ok, initialize actual values

        SidesSection(obj, 'set_future_sides');
        SidesSection(obj, 'update_plot');


    case 'update_plot', % ----------  UPDATE_PLOT  -------------------------

        [x, mn, mx] = SidesSection(obj, 'get_width');

        % First, the future:
        set(value(p), 'XData', n_done_trials+1:mx, 'YData', side_list(n_done_trials+1:mx));
        set(value(h), 'Ylim', [-0.5 1.5], 'XLim', [mn-1 mx+1]);
        set(value(o), 'XData', n_done_trials+1, 'YData', side_list(n_done_trials+1));
        u = n_done_trials;
        if u==0, return; end;

        % Will redraw all points; first clear them off the sceen
        set(value(r), 'XData', -1, 'YData', -1);
        set(value(g), 'XData', -1, 'YData', -1);
        % Loop over all done trials:
        for i=1:u,

            % The guys with direct water delivery or next correct poke:
            % rat *always* gets water here but hit and miss are well-defined
            if ismember(get_history(WaterDelivery, i), ...
                    {'next corr poke', 'direct'})
                if hit_history(i)==1, set(thh(i), 'Position',[i side_list(i)]);
                else                  set(thm(i), 'Position',[i side_list(i)]);
                end;

            % Remaining possibility:
            % WaterDelivery=only if next poke correct
            % GF 12/5/06
            elseif ~isnan(hit_history(i)) && hit_history(i), % this trial was correct, so make it green
                gh = value(g);
                set(gh, 'XData', [get(gh, 'XData') i], ...
                    'YData', [get(gh, 'YData') side_list(i)]);
            elseif ~isnan(hit_history(i)) && ~hit_history(i), % this trial was an error, so make it red
                gh = value(r);
                set(gh, 'XData', [get(gh, 'XData') i], ...
                    'YData', [get(gh, 'YData') side_list(i)]);
            else % this trial was not performed, so keep it blue
                gh = value(p);
                set(gh, 'XData', [i get(gh, 'XData')], ...
                    'YData', [side_list(i) get(gh, 'YData')]);
            end;
        end;

    case 'set_future_sides', % ----------  SET_FUTURE_SIDES  ----------------

        sl = value(side_list);
        ol = value(odor_list);

        SoloFunctionAddVars('OdorSection', 'ro_args', 'odor_list');

        starting_at = n_started_trials+1;

        % generate order of odors
        probs = []; % initialize
        Lp = []; % initialize
        Rp = []; % initialize
        for ind = 1:value(max_odors)
            eval(strcat('probs = [probs trials_fraction', num2str(ind), '];'));
            eval(strcat('Lp = [Lp L_prob', num2str(ind), '];'));
            eval(strcat('Rp = [Rp R_prob', num2str(ind), '];'));
        end

        % make sure that probs vector sums to 1 (force it to if necessary)
        probs = probs ./ sum(probs);
        
        tmp = []; % initialize
        for ind = 1:value(max_odors)
            tmp = [tmp (ind * ones(1, (round(probs(ind) * (maxtrials - starting_at + 1) * 2))))]; % the '*2' is to make sure we have at least maxtrials trials
        end
        
        tmp = tmp(randperm(length(tmp)));
        
        ol(starting_at:maxtrials) = tmp(1:(maxtrials - starting_at + 1));
        
        % generate L-R reward availibility (R is 0, L is 1, neither is 2, both is 3)
        left_rewards = rand(1, (maxtrials - starting_at + 1)) <= Lp(ol(starting_at:maxtrials));
        right_rewards = rand(1, (maxtrials - starting_at + 1)) <= Rp(ol(starting_at:maxtrials));
        
        tmp = 99 * ones(1, (maxtrials - starting_at + 1));
        
        tmp(~left_rewards & right_rewards) = 0;
        tmp(left_rewards & ~right_rewards) = 1;
        tmp(~left_rewards & ~right_rewards) = 2;
        tmp(left_rewards & right_rewards) = 3;
        
        sl(starting_at:maxtrials) = tmp;
        
        side_list.value = sl;
        odor_list.value = ol;

    case 'fix_future_sides', % --------- FIX_FUTURE_SIDES -------------------

        warning('onebank_2AFC SidesSection(''fix_future_sides'') section deleted by GF 12/12/06. What function called this?');
        warning('Note: backup saved in C:\Gidon\mainen_projects\SoloSystem\GF_solo_backups\@onebank_2afcobj.');
        keyboard;

    case 'choose_next_side', % ----------  CHOOSE_NEXT_SIDE  ----------------

        warning('onebank_2AFC SidesSection(''fix_future_sides'') section deleted by GF 12/12/06. What function called this?');
        warning('Note: backup saved in C:\Gidon\mainen_projects\SoloSystem\GF_solo_backups\@onebank_2afcobj.');
        keyboard;

    case 'get_width',  % --- GET_WIDTH ---  VpdsSection sometimes requests this
        x         = width;
        y         = max(round(n_started_trials-2*width/3), 1);
        side_list = min(floor(y+width), length(side_list));

    otherwise,
        error(['Don''t know how to handle action ' action]);
end;
