function [x, y, side_list, WaterDelivery, RewardPorts, ChoiceWindow, ...
          beta, priors]=SidesSection(obj,action,x,y);    
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

% 1 means left  type one;  1.25 means left  type two;  
% 0 means right type one;  0.25 means right type two.   
   
GetSoloFunctionArgs;
% SoloFunction('SidesSection', 'ro_args', ...
%    {'n_done_trials', 'n_started_trials', 'hit_history','maxtrials'});


switch action,
    
    case 'init', % ----------  INIT  -------------------------
      fig = gcf;
      SoloParamHandle(obj, 'my_xyfig', 'value', [x y fig]);

      NumeditParam(obj, 'Stubbornness', 0,   x, y, 'TooltipString', ...
             'Prob that if an error is made, same side will be rechosen'); 
      set(get_ghandle(Stubbornness), 'Enable', 'off');
      ToggleParam(obj, 'EnableSoftStubb', 1, x, y, 'label', ' ', ...
            'position',[x+180 y 20 20],...
            'TooltipString', ['Toggle that chooses using ' ...
                          'softmax vs straight stubbornness']);     
      set_callback(EnableSoftStubb, {'SidesSection', 'enable_soft_stubb'});
      SoloParamHandle(obj, 'ChoiceWindow', 'value', 30);
      SoloParamHandle(obj, 'beta',         'value', 2.2);
      % Columns of priors: [f1 f2 prior_prob side_list_value prob_of_choice]
      SoloParamHandle(obj, 'priors',       'value', ...
                      [0 0 0.5 0     0 ;  ...
                       0 0 0   0.25  0 ;  ...
                       0 0 0.5 1     0 ;  ...
                       0 0 0   1.25  0]);
      SoloFunction('ChordSection', 'rw_args', {'priors'});
      SoloFunction('ReportHitsSection', 'ro_args', {'priors'});
      
      
      next_row(y);
      MenuParam(obj, 'MaxSame', {'1' '2' '3' '4' '5' '6' '7' '8' '9' '10' ...
                          'Inf'}, 6, x, y, 'TooltipString', ...
                'Max number of same target sides in a row');  
      PushbuttonParam(obj, 'all_ones', x, y, 'label', '', ...
                      'position', [x+170, y+6, 14, 14], 'TooltipString', ...
                      'Set L1Prob=1, R1Prob=1, TypeMaxSame=Inf');
      PushbuttonParam(obj, 'all_twos', x, y, 'label', '', ...
                      'position', [x+186, y+6, 14, 14], 'TooltipString', ...
                      'Set L1Prob=0, R1Prob=0, TypeMaxSame=Inf');
      set(get_ghandle({all_ones;all_twos}), 'Enable', 'off');
      set_callback(all_ones, {mfilename, 'all_ones'});
      set_callback(all_twos, {mfilename, 'all_twos'});
      next_row(y);

      % NumeditParam(obj, 'TypeStubbornness', 0,   x, y, 'TooltipString', ...
      % ['Prob that if an error is made, nsame type of stim ' ...
      % 'will be rechosen next time the same side is chosen']); 
      % next_row(y);
      MenuParam(obj, 'TypeMaxSame', ...
                {'1' '2' '3' '4' '5' '6' '7' '8' '9' '10' 'Inf'}, 11, ...
                x, y, 'TooltipString', ...
                sprintf(['\nFor each given side (L or R), this is the\n' ...
                         'max number of same target types in a row']));  
      next_row(y);
        
      NumeditParam(obj, 'LeftProb',     0.5, x, y); next_row(y);
      gpos = gui_position(x, y);
      NumeditParam(obj, 'L1Prob',       1, x, y, ...
             'position', [gpos(1) gpos(2) 5.5*gpos(3)/12 gpos(4)], ...
             'TooltipString', ['Given that Left is chosen, prob that ' ...
                          'it will be of type 1']);
      NumeditParam(obj, 'R1Prob',       1, x, y, ...
        'position',[gpos(1)+5.5*gpos(3)/12 gpos(2) 5.5*gpos(3)/12 gpos(4)],...
        'TooltipString', ['Given that Right is chosen, prob that ' ...
                          'it will be of type 1']);
      ToggleParam(obj, 'EnableTypeTwos', 0, x, y, 'label', ' ', ...
            'position',[gpos(1)+11*gpos(3)/12 gpos(2) gpos(3)/12 gpos(4)],...
            'TooltipString', ['Toggle that enables or disables using 2 ' ...
                          'stim types for each of Left and Right']);     
      SoloFunction('ReportHitsSection', 'ro_args', {'EnableTypeTwos'});
      
      
      set(get_ghandle({L1Prob;R1Prob;TypeMaxSame}), 'Enable', 'off');
      next_row(y, 1);
        
      SoloParamHandle(obj, 'side_list', 'value', zeros(1, value(maxtrials)));
    
      set_callback(MaxSame, { ...
        'SidesSection', 'set_future_sides' ; ...
        'SidesSection', 'set_left_types' ; ...
        'SidesSection', 'set_right_types' ; ...
        'SidesSection', 'update_plot'});
      set_callback(LeftProb, { ...
        'SidesSection',      'set_future_sides' ; ...
        'SidesSection',      'set_left_types'   ; ...
        'SidesSection',      'set_right_types'  ; ...
        'SidesSection',      'update_plot'      ; ...
        'ReportHitsSection', 'update_chooser'});
      set_callback(TypeMaxSame, { ...
        'SidesSection', 'set_left_types' ; ...
        'SidesSection', 'set_right_types' ; ...
        'SidesSection', 'update_plot'});
      set_callback(L1Prob, { ...
        'SidesSection',      'set_left_types' ; ...
        'SidesSection',      'update_plot'    ; ...
        'ReportHitsSection', 'update_chooser'});
      set_callback(R1Prob, { ...
        'SidesSection',      'set_right_types' ; ...
        'SidesSection',      'update_plot'    ; ...
        'ReportHitsSection', 'update_chooser'});
      set_callback(EnableTypeTwos, {'SidesSection', 'enable_type_twos'});
      

      MenuParam(obj, 'MinorPenalty', {'0' '2' '4' '6' '8'}, 1, x, y, ...
                'TooltipString', sprintf(['If WaterDelivery is "next ' ...
                          'corr poke" then on incorrect poke you get ' ...
                          'MinorPenalty secs of white noise; but you\n' ...
                          'can still then go poke in the correct port ' ...
                          'and get your reward'])); next_row(y); 
      SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', ...
                          'MinorPenalty');      
      % Params that control the reward mode:
      MenuParam(obj, 'WaterDelivery', {'direct', 'next corr poke', ...
           'only if nxt pke corr'}, 3, x, y); 
      gpos = gui_position(x, y);
      ToggleParam(obj, 'RespondDuringStim', 1, x, y, 'label', ' ', ...
            'position',[gpos(1)+11*gpos(3)/12 gpos(2) gpos(3)/12 gpos(4)],...
            'TooltipString', ['Toggle that enables (black) or disables (brown) ' ...
                          'whether side pokes while stim is still on count as responses']);     
      SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', {'RespondDuringStim'});
      next_row(y);
      MenuParam(obj, 'RewardPorts',   {'correct port', 'both ports'}, 1, ...
                x, y); next_row(y); 

        % ---- Now initialize plot
        
        oldunits = get(gcf, 'Units'); set(gcf, 'Units', 'normalized');
        SoloParamHandle(obj, 'h',  'value', axes('Position', [0.18, 0.88, ...
                            0.8, 0.1])); % axes

        set(value(h), 'Units', 'Pixels');        
        axpos = get(value(h), 'Position');
        set(value(h), 'Units', 'normalized');        
        ToggleParam(obj, 'lr_or_full', 1, x, y, 'position', ...
                    [2 axpos(2)+axpos(4)/2-10, 30, 20], ...
                    'OnString', 'full', 'OffString', 'L/R', ...
                    'OnFontWeight', 'normal', 'OffFontWeight', 'normal', ...
                    'TooltipString', ['plot Left1, Left2, Right1, Right2, ' ...
                            'separately, or collapse into all Lefts v ' ...
                            'all Rights']);
        set([get_ghandle(lr_or_full);get_lhandle(lr_or_full)], 'Units', ...
                          'normalized');
        ToggleParam(obj, 'act_or_intend', 1, x, y, 'position', ...
                    [33 axpos(2)+axpos(4)/2-10, 48, 20], ...
                    'OnString', 'intended', 'OffString', 'rat''s act', ...
                    'OnFontWeight', 'normal', 'OffFontWeight', 'normal', ...
                    'TooltipString', ['plot sides according to what ' ...
                            'would be correct or according to what the ' ...
                            'rat did']);
        set([get_ghandle(act_or_intend);get_lhandle(act_or_intend)],'Units',...
                          'normalized');
        set_callback({lr_or_full;act_or_intend}, {mfilename, 'update_plot'});

        
        SoloParamHandle(obj, 'p',  'value', plot(-1, 1, 'b.')); hold on; % blue dots
        SoloParamHandle(obj, 'g',  'value', plot(-1, 1, 'g.')); hold on; % green dots
        SoloParamHandle(obj, 'r',  'value', plot(-1, 1, 'r.')); hold on; % red dots
        SoloParamHandle(obj, 'o',  'value', plot(-1, 1, 'ro')); hold on; % next trial indicator
        SoloParamHandle(obj, 'thl','value', text(-ones(1,maxtrials), 0.5*ones(1,maxtrials),'l'));
        SoloParamHandle(obj, 'thr','value', text(-ones(1,maxtrials), 0.5*ones(1,maxtrials),'r'));
        SoloParamHandle(obj, 'thh','value', text(-ones(1,maxtrials), 0.5*ones(1,maxtrials),'h'));
        SoloParamHandle(obj, 'thm','value', text(-ones(1,maxtrials), 0.5*ones(1,maxtrials),'m'));
        set_saveable({h;p;g;r;o;thl;thh;thm;thr}, 0);
        set([value(thl);value(thr);value(thh);value(thm)], ...
            'HorizontalAlignment', 'Center', 'VerticalAlignment', ...
            'middle', 'FontSize', 8, 'FontWeight', 'bold', 'Color', 'b', ...
            'FontName', 'Helvetica', 'Clipping', 'on');
        set(value(thh), 'Color', 'g'); set(value(thm), 'Color', 'r');
        set(value(h), 'YTick', [0 0.125 0.25 1 1.125 1.25], ...
                      'YTickLabel', {'1', 'Right   ', '2', ...
                            '1', 'Left   ', '2'});
        xlabel('');

        set(gcf, 'Units', oldunits);

        % "width", an EditParam to control the # of trials in the plot:
        SoloParamHandle(obj, 'width', 'type', 'edit', 'label', 'ntrials', ...
            'labelpos', 'left','TooltipString', 'number of trials in plot',...
            'value', 90, 'position', [2 670 65 20], 'labelfraction', 0.6);
        set_callback(width, {'SidesSection', 'update_plot'});
        set([get_ghandle(width);get_lhandle(width)], 'Units', 'normalized');
        
        % --- ok, initialize actual values
        
        SidesSection(obj, 'set_future_sides');
        SidesSection(obj, 'set_left_types');
        SidesSection(obj, 'set_right_types');
        SidesSection(obj, 'update_plot');


        
 case 'enable_type_twos', % ----------  ENABLE_TYPE_TWOS  ------------------
   switch value(EnableTypeTwos),
    case 0,
      set(get_ghandle({L1Prob;R1Prob;TypeMaxSame;all_ones;all_twos}), ...
          'Enable', 'off');
      L1Prob.value = 1; R1Prob.value = 1; TypeMaxSame.value = 'Inf';
      SidesSection(obj, 'set_left_types');
      SidesSection(obj, 'set_right_types');
      SidesSection(obj, 'update_plot');
      ReportHitsSection(obj, 'update_chooser');
      
      ChordSection(obj, 'enable_type_twos', 0);
    
    case 1,
      set(get_ghandle({L1Prob;R1Prob;TypeMaxSame;all_ones;all_twos}), ...
          'Enable', 'on');
      ChordSection(obj, 'enable_type_twos', 1);
   end;
      
      
 case 'all_twos',          % ----------  ALL_TWOS  ------------------
   TypeMaxSame.value = 'Inf'; L1Prob.value = 0; R1Prob.value = 0;
   callback(L1Prob); callback(R1Prob);

 
 case 'all_ones',          % ----------  ALL_TWOS  ------------------
   TypeMaxSame.value = 'Inf'; L1Prob.value = 1; R1Prob.value = 1;
   callback(L1Prob); callback(R1Prob);
   
   
 case 'enable_soft_stubb', % ----------  ENABLE_SOFT_STUBB  ---------------
   switch value(EnableSoftStubb),
    case 0,
      set(get_ghandle(Stubbornness), 'Enable', 'on');
      ReportHitsSection(obj, 'disable_chooser');
      
    case 1,
      set(get_ghandle(Stubbornness), 'Enable', 'off');
      ReportHitsSection(obj, 'enable_chooser');
   end;
      
      
      
    case 'update_plot', % ----------  UPDATE_PLOT  -------------------------
        [x, mn, mx] = SidesSection(obj, 'get_width');
        
        % First, the future:
        if (lr_or_full==1  &  act_or_intend==1),  % Plot full set,
                           % including diff b/w Left1 and Left2
           set(value(p), 'XData', n_done_trials+1:mx, ...
                         'YData', side_list(n_done_trials+1:mx));
           set(value(h), 'Ylim', [-0.3 1.55], 'XLim', [mn-1 mx+1]);
           set(value(o), 'XData', n_done_trials+1, ...
                         'YData', side_list(n_done_trials+1));
        else % Plot only Left v Right
           set(value(p), 'XData', n_done_trials+1:mx, ...
                         'YData', round(side_list(n_done_trials+1:mx)));
           set(value(h), 'Ylim', [-0.3 1.55], 'XLim', [mn-1 mx+1]);
           set(value(o), 'XData', n_done_trials+1, ...
                         'YData', round(side_list(n_done_trials+1)));
        end;
        u = n_done_trials;
        if u==0, return; end;
        
        % Will redraw all points; first clear them off the screen
        set(value(r), 'XData', -1, 'YData', -1);
        set(value(g), 'XData', -1, 'YData', -1);
        set(value(thl), 'Position', [-1, 0]);
        % set(value(thr), 'Position', [-1, 0]);
        set(value(thh), 'Position', [-1, 0]);
        set(value(thm), 'Position', [-1, 0]);
        % Loop over all done trials:
        for i=1:u,
           if lr_or_full==1 & act_or_intend==1, ypos = side_list(i); 
           else                                 ypos = round(side_list(i)); 
           end;
           
           if act_or_intend==0  &  hit_history(i)==0, ypos = 1-ypos; end;

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
              if hit_history(i)==1, set(thh(i), 'Position',[i ypos]);
              else                  set(thm(i), 'Position',[i ypos]);
              end;

           % Remaining possibility: 
           % RewardPorts=correct, WaterDelivery=only if next poke correct 
           elseif hit_history(i),
              gh = value(g);
              set(gh, 'XData', [get(gh, 'XData') i], ...
                      'YData', [get(gh, 'YData') ypos]);
           else
              gh = value(r);
              set(gh, 'XData', [get(gh, 'XData') i], ...
                      'YData', [get(gh, 'YData') ypos]);
           end;
        end;
        
    case 'set_future_sides', % ----------  SET_FUTURE_SIDES  ----------------

        priors(:,3) = [(1-LeftProb)*[value(R1Prob) ; 1-R1Prob] ; ...
                      LeftProb*[value(L1Prob) ; 1-L1Prob]];
  
        sl          = value(side_list);
        starting_at = n_started_trials+1;

        % First set the sides ------------------
        sl(starting_at:maxtrials) = rand(1,maxtrials-starting_at+1)<=LeftProb;
        
        if MaxSame < 11,
            seg_starts  = find(diff([-Inf sl(starting_at:end) -1]));
            seg_lengths = diff(seg_starts);
            long_segs   = find(seg_lengths > MaxSame);
            while ~isempty(long_segs),
                switch_point = seg_starts(long_segs(1)) + ...
                    ceil(seg_lengths(long_segs(1))/2);
                sl(switch_point+starting_at-1) = ...
                    1 - sl(switch_point+starting_at-1);
                seg_starts  = find(diff([-Inf sl(starting_at:end)]));
                seg_lengths = diff(seg_starts);
                long_segs   = find(seg_lengths > MaxSame);                   
            end;
        end;

        side_list.value = sl;
        
        
    case 'set_left_types', % ----------  SET_LEFT_TYPES  ----------------
        
        priors(:,3) = [(1-LeftProb)*[value(R1Prob) ; 1-R1Prob] ; ...
                      LeftProb*[value(L1Prob) ; 1-L1Prob]];

        sl          = value(side_list);
        starting_at = n_started_trials+1;

        u = find(sl(starting_at:maxtrials)>0.5);
        u = u + starting_at - 1;

        sl(u) = 1 + 0.25*(rand(size(u))>L1Prob); % If rand>L1Prob, make type 2
        
        if TypeMaxSame < 11,
            seg_starts  = find(diff([-Inf sl(u) -1]));
            seg_lengths = diff(seg_starts);
            long_segs   = find(seg_lengths > TypeMaxSame);
            while ~isempty(long_segs),
                switch_point = seg_starts(long_segs(1)) + ceil(seg_lengths(long_segs(1))/2);
                sl(u(switch_point)) = 2.25 - sl(u(switch_point));
                seg_starts  = find(diff([-Inf sl(u)]));
                seg_lengths = diff(seg_starts);
                long_segs   = find(seg_lengths > TypeMaxSame);
            end;
        end;

        side_list.value = sl;

        
    case 'set_right_types', % ----------  SET_RIGHT_TYPES  ----------------
        
        priors(:,3) = [(1-LeftProb)*[value(R1Prob) ; 1-R1Prob] ; ...
                      LeftProb*[value(L1Prob) ; 1-L1Prob]];

        sl          = value(side_list);
        starting_at = n_started_trials+1;

        u = find(sl(starting_at:maxtrials)<0.5);
        u = u + starting_at - 1;

        sl(u) = 0.25*(rand(size(u))>R1Prob); % If rand>R1Prob, make type 2
        
        if TypeMaxSame < 11,
            seg_starts  = find(diff([-Inf sl(u) -1]));
            seg_lengths = diff(seg_starts);
            long_segs   = find(seg_lengths > TypeMaxSame);
            while ~isempty(long_segs),
                switch_point = seg_starts(long_segs(1)) + ceil(seg_lengths(long_segs(1))/2);
                sl(u(switch_point)) = 0.25 - sl(u(switch_point));
                seg_starts  = find(diff([-Inf sl(u)]));
                seg_lengths = diff(seg_starts);
                long_segs   = find(seg_lengths > TypeMaxSame);
            end;
        end;
               
        side_list.value = sl;

        
        

 case 'choose_next_side', % ----------  CHOOSE_NEXT_SIDE  ----------------

   if ~value(EnableSoftStubb),
      lasthit = hit_history(n_done_trials); 
      if ~isnan(lasthit) & lasthit==0, % If have response, and was err, act:
         if rand(1) <= Stubbornness,
            side_list(n_done_trials+1) = side_list(n_done_trials); 
         end;   
      end;    
   else
      % First get the raw prior probabilities:
      priors(:,3) = [(1-LeftProb)*[value(R1Prob) ; 1-R1Prob] ; ...
                      LeftProb*[value(L1Prob) ; 1-L1Prob]];
      
      
      ntrials = round(value(ChoiceWindow));
      start = n_done_trials - ntrials + 1; if start<1, start=1; end;   
      stop  = n_done_trials;

      percents = ones(rows(value(priors)), 1);
      if start<=stop,
         for i=1:rows(value(priors)),
            u=find(side_list(start:stop)==priors(i,4));
            if ~isempty(u), percents(i) = mean(hit_history(start+u-1));
            else            percents(i) = 1;
            end;
         end;
         u = find(ismember(side_list(start:stop), priors(1:2,4)));
         rpercent = mean(hit_history(start+u-1));
         u = find(ismember(side_list(start:stop), priors(3:4,4)));
         lpercent = mean(hit_history(start+u-1));         
      end;

      
      choices = probabilistic_trial_selector(percents,priors(:,3),value(beta));
      % choices = quadsamp_prob_selector([rpercent;lpercent]; ...
      % percents, priors(:,3), value(beta));
      priors(:,5) = choices;
      
      side_list(n_done_trials+1) = ...
          randsample([0 0.25 1 1.25], 1, true, choices);
         
      
      
      % Now enforce max_same rules:
      % Find all guys of same side:
      u = find(round(side_list(1:n_done_trials+1)) == ...
               round(side_list(n_done_trials+1)));
      if length(u)>1, % If more than one
         bpoint = find(diff(u)>1);   % look for breaks in rows of them
         if isempty(bpoint), nguys = length(u); % no break? length(u) consec
         else                nguys = length(u) - bpoint(end);
         end;
         if nguys > MaxSame,  % If more consecutive guys than allowed, switch
            if side_list(n_done_trials+1)>=1, % Was left,  switch to right
               side_list(n_done_trials+1) = ...
                   randsample([0 0.25],1,true,choices(1:2)+1e-6);
            else                              % Was right, switch to left
               side_list(n_done_trials+1) = ...
                   randsample([1 1.25],1,true,choices(3:4)+1e-6);
            end;
         end;
      end;

      
      % Now enfore TypeMaxSame rules:
      % First find all guys of same side:
      u0 = find(round(side_list(1:n_done_trials+1)) == ...
               round(side_list(n_done_trials+1)));
      % Now, within those, find all guys of same type:
      u = find(side_list(u0) == side_list(n_done_trials+1));
      if length(u)>1, % If more than one
         bpoint = find(diff(u)>1);   % look for breaks in rows of them
         if isempty(bpoint), nguys = length(u); % no break? length(u) consec
         else                nguys = length(u) - bpoint(end);
         end;
         if nguys > TypeMaxSame,  % If more guys in row than allowed, switch
            if side_list(n_done_trials+1)>=1,
               side_list(n_done_trials+1) = 2.25-side_list(n_done_trials+1);
            else
               side_list(n_done_trials+1) = 0.25-side_list(n_done_trials+1);
            end;
         end;
      end;
      
      
   end;
        

 case 'get_width',  % --- GET_WIDTH ---  VpdsSection sometimes requests this
   x         = width;
   y         = max(round(n_started_trials-19*width/20), 1);
   side_list = min(floor(y+width), length(side_list));   
   
        
 case 'reinit',  % --------------------  CASE REINIT
   x = my_xyfig(1); y = my_xyfig(2); fig = my_xyfig(3);
   
   delete(value(h));
   delete_sphandle('handlelist', ...
                   get_sphandle('owner', class(obj), 'fullname', mfilename));
   
   figure(fig);
   feval(mfilename, obj, 'init', x, y);
   
        
 otherwise,
   error(['Don''t know how to handle action ' action]);        
end;
