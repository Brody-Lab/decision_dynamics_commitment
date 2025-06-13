function [x, y, SideBias] = RewardsSection(obj, action, x, y);    
%
%
% args:    x, y                 current UI pos, in pixels
%          obj                  A masa-operant_obj object
%
% returns: x, y                 updated UI pos
%
% Updates (and stores) history of various measures of hit (or reward
% rates); e.g. Hit rate for Last 20 trials, # Right rewards, etc.,
% Also updates the on-screen hit-rate display
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

GetSoloFunctionArgs;
% SoloFunction('RewardsSection', ...
%              'rw_args',{}, ...
%              'ro_args', {'n_done_trials', 'RewardData','BiasCorrect','Threshold'});

switch action,
    case 'init',
        fig=gcf;
        MenuParam(obj, 'RewardPlots', {'view', 'hidden'}, 1, x,y); next_row(y);
        set_callback(RewardPlots, {'RewardsSection', 'view'});
        oldx=x; oldy=y; x=1; y=1;
        SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable',0);
        
        screen_size = get(0, 'ScreenSize');
        set(value(myfig),'Position',[screen_size(3)-450 480, 400 200]); 
        set(value(myfig), ...
            'Visible', 'on', 'MenuBar', 'none', 'Name', 'Reward Plots', ...
            'NumberTitle', 'off', 'CloseRequestFcn', ...
            ['RewardsSection(' class(obj) '(''empty''), ''hide'')']);
        
        SoloParamHandle(obj, 'SideBias');
        
        DispParam(obj, 'RightRewards',0, x, y); next_row(y);
        DispParam(obj, 'LeftRewards', 0, x, y); next_row(y);
        next_column(x);y=1;
        DispParam(obj, 'Trials',      0, x, y); next_row(y,1.5);
        
        MenuParam(obj, 'Graph_Limits', {'latest', 'from, to'}, 1, x, y);
        next_row(y);
        set_callback(Graph_Limits, {'RewardsSection', 'graph_limits' ; ...
       'RewardsSection', 'update_plot1'});
        x2=x; y2=y;
        SoloParamHandle(obj, 'last', 'label', 'last', 'type', 'numedit', ...
       'value', 200, 'position', [x y 80 20]);
        set_callback(last, {'RewardsSection', 'update_plot1'});
   
        x=x2; y=y2;
        SoloParamHandle(obj, 'start_time','label', 'start_T', 'type', 'numedit', ...
       'value', 1, 'position', [x y 80 20]);
        set_callback(start_time, {'RewardsSection', 'update_plot1'});
        SoloParamHandle(obj, 'end_time','label', 'end_T', 'type', 'numedit', ...
       'value', 200, 'position', [x+90 y 80 20]); next_row(y);
        set_callback(end_time, {'RewardsSection', 'update_plot1'});
   
        set([get_ghandle(start_time);get_lhandle(start_time)], 'Visible', 'off');
        set([get_ghandle(end_time);get_lhandle(end_time)], 'Visible', 'off');
         
%Initialize axes for plots
        SoloParamHandle(obj, 'axes1', 'saveable', 0, ...
                  'value', axes('Position', [0.33 0.52 0.65 0.43]));
        xlabel('secs');
        set(value(axes1), 'YTick', [-1 1], 'YTickLabel', {'Right', 'Left'});

        SoloParamHandle(obj, 'Rb', 'value', line([0], [0]), 'saveable', 0);
        set(value(Rb),  'Color', 'b', 'Marker', '.', 'LineStyle', 'none');
        
        SoloParamHandle(obj, 'axes2', 'saveable', 0, ...
                  'value', axes('Position', [0.04 0.52 0.2 0.43]));
        %xlabel('right'); ylabel('left');
        set(value(axes2), 'XLim', [-0.1 1], 'YLim', [-0.1 1]);
        SoloParamHandle(obj, 'Cumplot', 'value', plot(1, 1, 'b-'), 'saveable', 0);
        
        x=oldx; y=oldy; figure(fig);
    case 'update',
%         hit_history(n_done_trials)=1;
        
        rside=RewardData.reward_side;
        
        SideBias.value = 'N';
        switch value(BiasCorrect)
            case 'OFF'
                %nothing
            case 'ON'
                if n_done_trials>=value(Threshold),
                    rside=rside(n_done_trials-value(Threshold)+1:n_done_trials);
                    if sum(rside==1)>=value(Threshold)   %sum(past10==1) is number of left reward.
                        SideBias.value = 'L';
                    elseif sum(rside==(-1))>=value(Threshold)
                        SideBias.value = 'R';
                    else
                        SideBias.value = 'N';
                    end;
                end;
        end;
        RewardsSection(obj, 'update_plot1');
        RewardsSection(obj, 'update_plot2');
            
    case 'update_plot1'   
    % Update UIs        
        rtime=RewardData.reward_time;
        rside=RewardData.reward_side;
        
        bline = value(Rb); 
        set(bline, 'XData', rtime(1:n_done_trials), 'YData', rside(1:n_done_trials));
        
        switch value(Graph_Limits);
            case 'latest',
                if value(Trials)==0,
                    from = 0;
                    to = value(last);
                else
                    from  = max(0, rtime(n_done_trials)-value(last));
                    to = from + value(last)+5;
                end;
            case 'from, to',
                from  = value(start_time);
                to = value(end_time);
                if from >= to,
                    to = from +10;
                    end_time.value=to;
                end;
          otherwise error('whuh?');
        end;           
     
        bot  = -1.1;  top = 1.1;
        set(value(axes1), 'XLim', [from to], 'YLim', [bot top]);
        
    case 'update_plot2'
        % Update UIs
        
        rside=RewardData.reward_side;
        left=cumsum(rside(1:n_done_trials)==1);
        right=cumsum(rside(1:n_done_trials)==-1);
        
        %update DispParam
        LeftRewards.value=left(end);
        RightRewards.value=right(end);
        Trials.value=n_done_trials;
        
        set(value(Cumplot), 'XData', [0 left], 'YData', [0 right]);
        
        from2 =-0.1; to2=1+max(left(end), right(end));
        bot2=-0.1; top2=to2;
        gridpts = [0:50:1000]; % must always contain 0
        set(value(axes2), 'XTick', gridpts, 'XGrid','on','Xlim',[from2 to2], ...
                'YTick', gridpts, 'YGrid','on','Ylim',[bot2 top2]);  
        
    case 'graph_limits', % ----  CASE TRIAL_LIMITS
        switch value(Graph_Limits),
            case 'latest',
                set([get_ghandle(last);    get_lhandle(last)],    'Visible', 'on');
                set([get_ghandle(start_time);get_lhandle(start_time)],'Visible','off');
                set([get_ghandle(end_time);  get_lhandle(end_time)],  'Visible','off');

            case 'from, to',
                set([get_ghandle(last);    get_lhandle(last)],    'Visible','off');
                set([get_ghandle(start_time);get_lhandle(start_time)],'Visible','on');
                set([get_ghandle(end_time);  get_lhandle(end_time)],  'Visible','on');

            otherwise,
                error(['Don''t recognize this trial_limits val: ' value(graph_limits)]);
        end;
        drawnow;
      
       case 'view',
           switch value(RewardPlots)
               case 'hidden',
                   set(value(myfig), 'Visible', 'off');
               case 'view',
                   set(value(myfig), 'Visible', 'on');
           end;

       case 'hide',
           RewardPlots.value='hidden';
           set(value(myfig), 'Visible', 'off');

       case 'delete'
           delete(value(myfig));
 
   otherwise,
        error(['Don''t know how to handle action ' action]);
end;    
  

