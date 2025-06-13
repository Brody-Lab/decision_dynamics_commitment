function [x, y] = TimesSection(obj, action, x, y)
   
   GetSoloFunctionArgs;
   
   switch action
    case 'init',
      % Save the figure and the position in the figure where we are
      % going to start adding GUI elements:
      SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);
      
      NumeditParam(obj, 'ExtraITIOnError', 1, x, y);
      next_row(y);
      
      NumeditParam(obj, 'DrinkTime', 2, x, y);
      next_row(y);
      
      SoloParamHandle(obj, 'ValidPokeTime', 'type','menu','string',{0.01 0.1 0.2 0.3 0.4},...
          'value', 1, 'position', [x y 200 20],'label','ValidPokeTime');
      next_row(y);
      NumeditParam(obj, 'WatAvilTime', 8, x, y);
      next_row(y);
      NumeditParam(obj, 'total_correct_trials', 100, x, y,'label', 'nCorrectTrial',...
          'TooltipString', 'Total number of correct trials required');
      set_callback(total_correct_trials, {mfilename,'set_schedule'});
      next_row(y);
                
      SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', ...
                          {'ExtraITIOnError', 'DrinkTime', 'ValidPokeTime', 'WatAvilTime'});
      
      SoloParamHandle(obj, 'UserPush', 'value',0); % store information whether user changed the shedule
      
      % store the number of hits in each step (step_hits) into a SPH
      SoloParamHandle(obj,'step_hits', 'value', 0);
      SoloParamHandle(obj,'vpt_level', 'value', 1);
      
      % sph menu setting different task schedules
      MenuParam(obj, 'task_schedule', {'schedule1' 'schedule2' 'schedule3' 'schedule4'},1,x,y);
      set_callback(task_schedule, {mfilename, 'set_schedules'});
      
      next_row(y, 1.5);
      
      SubheaderParam(obj, 'title', 'Times & Schedules', x, y);
      next_row(y, 1.5);
      
      % ---- Initialize plot for the task schedule
        oldunits = get(gcf, 'Units'); set(gcf, 'Units', 'normalized');
        SoloParamHandle(obj, 'h',  'value', axes('Position', [0.1, 0.48, 0.8, 0.43])); % axes
        SoloParamHandle(obj, 'p',  'value', plot(-1, 0.2, 'b.')); hold on; % blue dots
        SoloParamHandle(obj, 'g',  'value', plot(-1, 0.2, 'g.')); hold on; % green dots
        SoloParamHandle(obj, 'r',  'value', plot(-1, 0.2, 'r.')); hold on; % red dots
        SoloParamHandle(obj, 'o',  'value', plot(-1, 0.2, 'ro')); hold on; % next trial indicator
        set_saveable({h;p;g;r;o}, 0);
        %set(value(h), 'YTick', [0 0.5]);
        xlim(value(h), [0 value(total_correct_trials)]);
        ylim(value(h), [0 0.5]);
        xlabel('Trials');
        ylabel('ValidPokeTime');

        set(gcf, 'Units', oldunits);
        
        % store the x value of the points in to a SPH. (initialize them)
        SoloParamHandle(obj, 'p_xdata', 'value', [1:value(total_correct_trials)]);
        SoloParamHandle(obj, 'p_ydata', 'value', zeros(1, value(total_correct_trials)));
               
        SoloParamHandle(obj, 'g_xdata', 'value', get(value(g),'XData'));
        
        SoloParamHandle(obj, 'session_end', 'value', 0);
        SoloFunctionAddVars('make_and_upload_state_matrix','ro_args','session_end');
        
        TimesSection(obj, 'set_schedules');
        
        
     case 'user_push' %if user changed the schedule progress, task will jump to the step user specified.
          y = value(p_ydata);
          m = find(y == value(ValidPokeTime));
          g_xdata.value = [get(value(g),'XData') m(1)-1]; 
          gx = value(g_xdata);
          set(value(o), 'XData', gx(end)+1);
          set(value(o), 'YData', y(gx(end)+1));
          vop_level.value = find([0.01 0.1 0.2 0.3 0.4]==value(ValidPokeTime));
          if strcmpi(value(task_schedule), 'schedule2')
              vop_level.value = find([0.3 0.4]==value(ValidPokeTime));
          end
          UserPush.value = 1; 
         
     case 'update_plot'     
       y = value(p_ydata);
       if  ~(rows(prevtrial.extra_iti)>0) % if the last tril is correct
          gx = value(g_xdata);
          gx = [gx gx(end)+1]; % the green point moves to the next x value.         
          if gx(1) <= 0 % eliminate the first non-integral element
              gx(2) = 1;
              gx(1) = [];
          end
          if value(UserPush)
              gx(end-1)=[];   % remove the end point of previous step, 
              %which was skipped due to user push.
          end
          g_xdata.value = gx; % update the green points XData information in the SPH g_xdata.
          % plot a green point upone a correct performance.
          set(value(g), 'XData', gx);
          set(value(g), 'YData', y(gx));
          
          % plot a red circle indicating the next trial.
          if gx(end)< value(total_correct_trials)
            set(value(o), 'XData', gx(end)+1);
            set(value(o), 'YData', y(gx(end)+1));
          else
            session_end.value = 1;
            return;
          end  
          
          % determine the valid center poke time
          ValidPokeTime.value = get(value(o), 'YData');
          
       end
       if value(ValidPokeTime) >= 0.2
           WatAvilTime.value = 6; % water available within 6 sec after center out
       end
       if value(ValidPokeTime) >= 0.4
           WatAvilTime.value = 4;
       end
       UserPush.value = 0;
   % set different task schedule according to user's choice.  
   case 'set_schedules'
       switch value(task_schedule)
           case 'schedule1'
               step = [10 10 15 25]; % number of hits needed for each task difficulty
               step = [step value(total_correct_trials)-sum(step)];
               % XData and YData of blue pionts, indicating the pre-specified task
               % schedule.
               delete_sphandle('name','p_xdata'); delete_sphandle('name', 'p_ydata');
               SoloParamHandle(obj, 'p_xdata', 'value', [1:value(total_correct_trials)]);
               SoloParamHandle(obj, 'p_ydata', 'value', [0.01*ones(1,step(1))...
                   0.1*ones(1,step(2))...
                   0.2*ones(1,step(3))...
                   0.3*ones(1,step(4))...
                   0.4*ones(1,step(5))]);
               set(value(p), 'XData', value(p_xdata));
               set(value(p), 'YData', value(p_ydata));
               set(value(h),'XLim',[0 value(total_correct_trials)],'YLim',[0 0.5]);
               pos = get(get_ghandle(ValidPokeTime), 'position');
               delete_sphandle('name','ValidPokeTime');
               SoloParamHandle(obj, 'ValidPokeTime','type','menu','string', {0.01 0.1 0.2 0.3 0.4},...
                   'value',1, 'position', [pos(1) pos(2) 200 20],'label','ValidPokeTime');
               SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', 'ValidPokeTime');
               set_callback(ValidPokeTime, {mfilename, 'user_push'});

               g_xdata.value = 0;
               
           case 'schedule2'
               step = [30 value(total_correct_trials) - 30];
               delete_sphandle('name','p_xdata'); delete_sphandle('name', 'p_ydata');
               SoloParamHandle(obj, 'p_xdata', 'value', [1:value(total_correct_trials)]);
               SoloParamHandle(obj, 'p_ydata', 'value', [0.3*ones(1,step(1)) 0.4*ones(1,step(2))]);
               set(value(p), 'XData', value(p_xdata));
               set(value(p), 'YData', value(p_ydata));
               set(value(h),'XLim',[0 value(total_correct_trials)],'YLim',[0.2 0.5]);
               pos = get(get_ghandle(ValidPokeTime), 'position');
               delete_sphandle('name','ValidPokeTime');
               SoloParamHandle(obj, 'ValidPokeTime','type','menu','string', {0.3 0.4},...
                   'value',1, 'position', [pos(1) pos(2) 200 20],'label','ValidPokeTime');
               SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', 'ValidPokeTime');
               set_callback(ValidPokeTime, {mfilename, 'user_push'});

               g_xdata.value = 0;
      
           case 'schedule3'
               delete_sphandle('name','p_xdata'); delete_sphandle('name', 'p_ydata');
               SoloParamHandle(obj, 'p_xdata', 'value', [1:value(total_correct_trials)]);
               SoloParamHandle(obj, 'p_ydata', 'value', [0.3*ones(1,value(total_correct_trials))]);
               set(value(p), 'XData', value(p_xdata));
               set(value(p), 'YData', value(p_ydata));
               set(value(h),'XLim',[0 value(total_correct_trials)],'YLim',[0.2 0.5]);
               pos = get(get_ghandle(ValidPokeTime), 'position');
               delete_sphandle('name','ValidPokeTime');
               SoloParamHandle(obj, 'ValidPokeTime','type','disp',...
                   'value', 0.3, 'position', [pos(1) pos(2) 200 20],'label','ValidPokeTime');
               SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', 'ValidPokeTime');
               
               g_xdata.value = 0;
               
           case 'schedule4'
               delete_sphandle('name','p_xdata'); delete_sphandle('name', 'p_ydata');
               SoloParamHandle(obj, 'p_xdata', 'value', [1:value(total_correct_trials)]);
               SoloParamHandle(obj, 'p_ydata', 'value', [0.4*ones(1,value(total_correct_trials))]);
               set(value(p), 'XData', value(p_xdata));
               set(value(p), 'YData', value(p_ydata));
               set(value(h),'XLim',[0 value(total_correct_trials)],'YLim',[0.2 0.5]);
               pos = get(get_ghandle(ValidPokeTime), 'position');
               delete_sphandle('name','ValidPokeTime');
               SoloParamHandle(obj, 'ValidPokeTime','type','disp',...
                   'value', 0.4, 'position', [pos(1) pos(2) 200 20],'label','ValidPokeTime');
               SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', 'ValidPokeTime');
               
               g_xdata.value = 0;
       end
        
    case 'reinit',
      currfig = gcf; 

      % Get the original GUI position and figure:
      x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));

      % Delete all SoloParamHandles who belong to this object and whose
      % fullname starts with the name of this mfile:
      delete_sphandle('owner', ['^@' class(obj) '$'], ...
                      'fullname', ['^' mfilename]);

      % Reinitialise at the original GUI position and figure:
      [x, y] = feval(mfilename, obj, 'init', x, y);

      % Restore the current figure:
      figure(currfig);      
  end;
   
   
      