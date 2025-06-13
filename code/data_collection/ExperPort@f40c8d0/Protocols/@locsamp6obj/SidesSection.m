function [x, y, side_list, WaterDelivery, RewardPorts]=SidesSection(obj,action,x,y);    
%
% [x, y, side_list, WaterDelivery, RewardPorts] = ...
%    SidesSection(obj, action, x, y);    
%
% args:    x, y                  current UI pos, in pixels
%          n_done_trials         handle to number of completed trials
%          hit_history           handle to history of hits versus errors
%                                (vector: 1=hit, 0=error, len=n_done_trials)
%          maxtrials             max number of trials in experiment
%          obj                   A locsamp3obj object
%
% returns: x, y                  updated UI pos
%          side_list             handle to vector of correct sides,
%                                   one per trial.
%          WaterDelivery         handle to type of delivery (direct, etc).
%          RewardPorts           handle to type of reward (correct, etc.)
%          update_sidesplot_fn  function that updates sides and rewards plot
%          set_next_side_fn     fn, uses error hist to override correct side
%

GetSoloFunctionArgs;
% SoloFunction('SidesSection', 'ro_args', ...
%    {'n_done_trials', 'n_started_trials', 'hit_history','maxtrials'});


switch action,
    
    case 'init', % ----------  INIT  -------------------------
        EditParam(obj, 'Stubbornness', 0,   x, y); next_row(y);
        MenuParam(obj, 'MaxSame', {'1' '2' '3' '4' '5' '6' '7' '8' '9' '10' 'Inf'}, 6, x, y); next_row(y);
        EditParam(obj, 'LeftProb',     0.5, x, y); next_row(y);
        next_row(y, 0.5);
        SoloParamHandle(obj, 'side_list', 'value', zeros(1, value(maxtrials)));
    
        set_callback({LeftProb, MaxSame}, { ...
            'SidesSection', 'set_future_sides' ; ...
            'SidesSection', 'update_plot'});

        % Params that control the reward mode:
        MenuParam(obj, 'WaterDelivery', {'direct', 'next corr poke', 'only if nxt pke corr'}, 2, x, y); next_row(y);
        MenuParam(obj, 'RewardPorts',   {'correct port', 'both ports'},1, x, y); next_row(y);

        % ---- Now initialize plot
        
        oldunits = get(gcf, 'Units'); set(gcf, 'Units', 'normalized');
        SoloParamHandle(obj, 'h',  'value', axes('Position', [0.06, 0.88, 0.8, 0.1])); % axes
        SoloParamHandle(obj, 'p',  'value', plot(-1, 1, 'b.')); hold on; % blue dots
        SoloParamHandle(obj, 'g',  'value', plot(-1, 1, 'g.')); hold on; % green dots
        SoloParamHandle(obj, 'r',  'value', plot(-1, 1, 'r.')); hold on; % red dots
        SoloParamHandle(obj, 'o',  'value', plot(-1, 1, 'ro')); hold on; % next trial indicator
        SoloParamHandle(obj, 'thl','value', text(-ones(1,maxtrials), 0.5*ones(1,maxtrials),'l'));
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
        
        % Will redraw all points; first clear them off the screen
        set(value(r), 'XData', -1, 'YData', -1);
        set(value(g), 'XData', -1, 'YData', -1);
        % Loop over all done trials:
        for i=1:u,
           % the both-ports-reward trials-- no hit or miss defined here, 
           % what matters is just r and l
           if strcmp(get_history(RewardPorts, i), 'both ports'), 
              if (side_list(i)==1 & hit_history(i)==1) | ...
                     (side_list(i)==0 & hit_history(i)==0),
                 set(thl(i), 'Position', [i 0.5]); 
              elseif (side_list(i)==0 & hit_history(i)==1) | ...
                     (side_list(i)==1 & hit_history(i)==0),
                 set(thr(i), 'Position', [u 0.5]); 
              end;

        
           % Next the guys with direct water delivery or next correct poke: 
           % rat *always* gets water here but hit and miss are well-defined
           elseif ismember(get_history(WaterDelivery, i), ...
                       {'next corr poke', 'direct'})
              if hit_history(i)==1, set(thh(i), 'Position',[i side_list(i)]);
              else                  set(thm(i), 'Position',[i side_list(i)]);
              end;

           % Remaining possibility: 
           % RewardPorts=correct, WaterDelivery=only if next poke correct 
           elseif hit_history(i),
              gh = value(g);
              set(gh, 'XData', [get(gh, 'XData') i], ...
                      'YData', [get(gh, 'YData') side_list(i)]);
           else
              gh = value(r);
              set(gh, 'XData', [get(gh, 'XData') i], ...
                      'YData', [get(gh, 'YData') side_list(i)]);
           end;
        end;
        
    case 'set_future_sides', % ----------  SET_FUTURE_SIDES  ----------------

        sl          = value(side_list);
        starting_at = n_started_trials+1;
        
        sl(starting_at:maxtrials) = rand(1,maxtrials-starting_at+1)<=LeftProb;
        
        if MaxSame < 11,
            seg_starts  = find(diff([-Inf sl -1]));
            seg_lengths = diff(seg_starts);
            long_segs   = find(seg_lengths > MaxSame);
            while ~isempty(long_segs),
                switch_point = seg_starts(long_segs(1)) + ceil(seg_lengths(long_segs(1))/2);
                sl(switch_point) = 1 - sl(switch_point);
                seg_starts  = find(diff([-Inf sl]));
                seg_lengths = diff(seg_starts);
                long_segs   = find(seg_lengths > MaxSame);
            end;
        end;
        
        side_list.value = sl;


    case 'choose_next_side', % ----------  CHOOSE_NEXT_SIDE  ----------------
        lasthit = hit_history(n_started_trials); 
        if ~isnan(lasthit) & lasthit==0, % If have response, and it was error, act:
            if rand(1) <= Stubbornness,
                side_list(n_started_trials+1) = side_list(n_started_trials); 
            end;   
        end;    
        

    case 'get_width',  % --- GET_WIDTH ---  VpdsSection sometimes requests this
        x         = width;
        y         = max(round(n_started_trials-2*width/3), 1);
        side_list = min(floor(y+width), length(side_list));   

        
    otherwise,
        error(['Don''t know how to handle action ' action]);

end;
