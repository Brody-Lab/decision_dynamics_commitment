function [x, y]= PokeDuration(obj, action, x, y);
%
% args:    obj                  A masa_opeerantobj object
%          action               'init'
%          x, y                 current UI pos, in pixels
%                    
% returns: x, y             updated UI pos
%          VpdList         Array(2*maxtrials) containing list of valid poke durations
%
% Simply initialises UI elements parameterisings
%
GetSoloFunctionArgs;
% SoloFunction('PokeDuration', 'rw_args',{}, ...
%   'ro_args', {'VpdList'});

switch action,
 case 'init',
   %PokeDuration Parameters Window
   fig=gcf;
  
   MenuParam(obj, 'CpokePlots', {'view', 'hidden'}, 1, x,y); next_row(y);
   set_callback(CpokePlots, {'PokeDuration', 'cpoke_plots_view'});
   oldx=x; oldy=y; x=5; y=5;
   SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable',0);
   
   screen_size = get(0, 'ScreenSize');
   set(value(myfig),'Position',[450 screen_size(4)-700, 210 650]); 
   
   %display for valid poke duratoin
   
   MenuParam(obj, 'Time_Limits', {'auto', 'manual'},1,x,y);next_row(y);
   set_callback(Time_Limits, {'PokeDuration', 'time_limits' ; ...
       'PokeDuration', 'update'});
   SoloParamHandle(obj, 'time_max', 'label', 'time max', 'type', 'numedit', ...
       'value', 2, 'position', [x y 80 20]);next_row(y);
   set_callback(time_max, {'PokeDuration', 'update'});

   MenuParam(obj, 'Trial_Limits', {'latest', 'from, to'}, 1, x, y); next_row(y);
   set_callback(Trial_Limits, {'PokeDuration', 'trial_limits' ; ...
       'PokeDuration', 'update'; ...
       'CurrentTrialPokesSubsection', 'redraw'});
   x2=x; y2=y;
   SoloParamHandle(obj, 'last_n', 'label', 'last_n', 'type', 'numedit', ...
       'value', 25, 'position', [x y 80 20]);
   SoloParamHandle(obj, 'next_n', 'label', 'next_n', 'type', 'numedit', ...
       'value', 5, 'position', [x+90 y 80 20]);
   x=x2; y=y2;
   SoloParamHandle(obj, 'start_trial','label', 'start', 'type', 'numedit', ...
       'value', 1, 'position', [x y 80 20]);
   SoloParamHandle(obj, 'end_trial','label', 'end', 'type', 'numedit', ...
       'value', 25, 'position', [x+90 y 80 20]); next_row(y);   
   set_callback({last_n,next_n,start_trial,end_trial}, ...
       {'PokeDuration', 'update'; ...
        'CurrentTrialPokesSubsection', 'redraw'});
   
   set([get_ghandle(time_max);get_lhandle(time_max)], 'Visible', 'off');
   set([get_ghandle(start_trial);get_lhandle(start_trial)], 'Visible', 'off');
   set([get_ghandle(end_trial);get_lhandle(end_trial)], 'Visible', 'off');
   
   %axes
   SoloParamHandle(obj, 'BOT', 'value', 0);
   SoloParamHandle(obj, 'TOP', 'value', 30);
   SoloParamHandle(obj, 'axesPD', 'saveable', 0, ...
       'value', axes('Position', [0.2 0.18 0.75 0.77])); %[Xstart Ystart Xwidth Ywidth]
   xlabel('time'); ylabel('trials');
   set(value(axesPD), 'XLim', [0 3], 'YLim', [value(BOT) value(TOP)]);
   
   %plots  
   SoloParamHandle(obj, 'P_sm', 'value', line([0], [0]), 'saveable', 0);
   set(value(P_sm),  'Color', 0.6*[1 0.66 0], 'Marker', '.', 'LineStyle', 'none');
   SoloParamHandle(obj, 'P_la', 'value', line([0], [0]), 'saveable', 0);
   set(value(P_la),  'Color', 0.9*[1 0.66 0], 'Marker', '.', 'LineStyle', 'none');

   SoloParamHandle(obj, 'P_gr', 'value', line([0], [0]), 'saveable', 0);
   set(value(P_gr),  'Color', [0 0.6 0], 'Marker', '.', 'LineStyle', 'none');
   SoloParamHandle(obj, 'P_yg', 'value', line([0], [0]), 'saveable', 0);
   set(value(P_yg),  'Color', [0.5 1 0], 'Marker', '.', 'LineStyle', 'none');
   SoloParamHandle(obj, 'P_rd', 'value', line([0], [0]), 'saveable', 0);
   set(value(P_rd),  'Color', [1 0 0], 'Marker', '.', 'LineStyle', 'none');     
   
   set(value(myfig), ...
       'Visible', 'on', 'MenuBar', 'none', 'Name', 'Cpoke Plots', ...
       'NumberTitle', 'off', 'CloseRequestFcn', ...
       ['PokeDuration(' class(obj) '(''empty''), ''cpoke_plots_hide'')']);
   x=oldx; y=oldy; figure(fig);
    
%End of case 'init'
     
 case 'update',  %trial_finished_action 
     %first display for vpd
     list = value(VpdList);
     bdot_sm = value(P_sm);
     bdot_la = value(P_la);
     
     xdata_sm=list(1, 1:n_done_trials+1);
     xdata_la=list(2, 1:n_done_trials+1);
     ydata=[1:n_done_trials+1];

     set(bdot_sm, 'XData', xdata_sm, 'YData', ydata-0.05);
     set(bdot_la, 'XData', xdata_la, 'YData', ydata+0.05);
     
     %second display for cpoke
     pdur=TrialData.poke_duration;
     ttype=TrialData.trial_type;
     
     sp_idx=find(ttype(1:n_done_trials)==1); %short poke
     im_idx=find(ttype(1:n_done_trials)==2); %impulsive
     pa_idx=find(ttype(1:n_done_trials)==3); %patient
     
     set(value(P_gr),'XData',pdur(pa_idx),'YData', pa_idx);
     set(value(P_yg),'XData',pdur(im_idx),'YData', im_idx);
     set(value(P_rd),'XData',pdur(sp_idx),'YData', sp_idx);
     
     %xaxis     
     switch value(Time_Limits),
         case 'auto'
             xlim=get(value(axesPD), 'xlim');
             to=max([max(pdur),max(xdata_la),xlim(2)-0.1])+0.1;
         case 'manual'
             to=value(time_max);
     end;
     set(value(axesPD), 'XLim', [0 to]);
     
     %yaxis             
     switch value(Trial_Limits),
          case 'latest',
            if last_n<1,
                last_n=1;
            end;
            bot  = max(0, n_done_trials-last_n)-0.1;
            top = n_done_trials+next_n+0.1;
          case 'from, to',
            if start_trial<1,
                start_trial.value=1;
            end;
            bot  = value(start_trial)-1-0.1;
            top = value(end_trial)+0.1;
            if bot>=top,
                top=value(start_trial)+10;
                end_trial.value=top;
            end;
          otherwise error('whuh?');
     end;
     set(value(axesPD), 'YLim', [bot top]);
     
     BOT.value=bot;
     TOP.value=top;
     
 case 'time_limits',
     switch value(Time_Limits),
         case 'auto'
             set([get_ghandle(time_max); get_lhandle(time_max)],'Visible', 'off');
         case 'manual'
             set([get_ghandle(time_max); get_lhandle(time_max)],'Visible', 'on');
         otherwise
             error(['Don''t recognize this trial_limits val: ' value(trial_limits)]);
     end;
     drawnow;
 
 case 'trial_limits', % ----  CASE TRIAL_LIMITS
   switch value(Trial_Limits),
    case 'latest',
      set([get_ghandle(last_n);    get_lhandle(last_n)],    'Visible', 'on');
      set([get_ghandle(next_n);    get_lhandle(next_n)],    'Visible', 'on');
      set([get_ghandle(start_trial);get_lhandle(start_trial)],'Visible','off');
      set([get_ghandle(end_trial);  get_lhandle(end_trial)],  'Visible','off');
    
    case 'from, to',      
      set([get_ghandle(last_n);    get_lhandle(last_n)],    'Visible','off');
      set([get_ghandle(next_n);    get_lhandle(next_n)],    'Visible','off');
      set([get_ghandle(start_trial);get_lhandle(start_trial)],'Visible','on');
      set([get_ghandle(end_trial);  get_lhandle(end_trial)],  'Visible','on');
    
    otherwise
      error(['Don''t recognize this trial_limits val: ' value(trial_limits)]);
   end;
   drawnow;     
        
 case 'delete'
     delete(value(myfig));
     
 case 'cpoke_plots_view',
     switch value(CpokePlots)
         case 'hidden',
             set(value(myfig), 'Visible', 'off');
         case 'view',
             set(value(myfig), 'Visible', 'on');
     end;
        
 case 'cpoke_plots_hide',
     CpokePlotsPlots.value='hidden';
     set(value(myfig), 'Visible', 'off');

 otherwise,
   error(['Don''t know how to deal with action ' action]);
   
end;