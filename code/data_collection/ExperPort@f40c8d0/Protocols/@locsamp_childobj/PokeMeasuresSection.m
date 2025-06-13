function [x, y] = PokeMeasuresSection(obj, action, x, y)
%
% [x, y] = InitPoke_Measures(x, y, obj)
%
% args:    x, y                 current UI pos, in pixels
%          obj                  A locsamp3obj object
%
% returns: x, y                 updated UI pos
%

GetSoloFunctionArgs;
% SoloFunction('PokeMeasuresSection', 'rw_args', 'LastTrialEvents', ...
%    'ro_args', {'n_done_trials', 'n_started_trials', 'RealTimeStates'});


global Solo_Try_Catch_Flag;
   

switch action,
 case 'init',  % ---------- CASE INIT ----------
  DispParam(obj, 'CenterPokes',   0, x, y); next_row(y);
  DispParam(obj, 'LeftPokes',     0, x, y); next_row(y);
  DispParam(obj, 'RightPokes',    0, x, y); next_row(y);
  next_row(y, 0.5);
  
  EditParam(obj, 'LastCpokeMins', 5, 335, 475); 
  set(get_ghandle(LastCpokeMins), 'TooltipString', ...
                    ['Center pokes plot looks this many minutes into the' ...
                     ' past from last Center poke']);
  set_callback(LastCpokeMins, {'PokeMeasuresSection', 'update_plot'});
  next_row(y, 0.5);
  
  SoloParamHandle(obj, 'last_cpoke_in_time',  'value', -Inf);
  SoloParamHandle(obj, 'last_cpoke_out_time', 'value', -Inf);
  SoloParamHandle(obj, 'CPokes', 'value', struct( ...
      'npokes',     0, ...
      'poke_len',   zeros(1,100000), ...
      'poke_time',  zeros(1,100000), ...
      'poke_state', zeros(1,100000)));
  
  SoloParamHandle(obj, 'h', 'saveable', 0, ...
                  'value', axes('Position', [0.25 0.55 0.67 0.12]));
  set(value(h), 'YAxisLocation', 'right'); 
  xlabel('secs'); ylabel('CPokeDur');
  
  SoloParamHandle(obj, 'p', 'value', line([0], [0]), 'saveable', 0);
  SoloParamHandle(obj, 'r', 'value', line([0], [0]), 'saveable', 0);
  set(value(p), 'Color', 'k', 'Marker', '.', 'LineStyle', '-');
  set(value(r),  'Color', 'r', 'Marker', '.', 'LineStyle', 'none');
  
  SoloParamHandle(obj, 'h2', 'saveable', 0, ...
                  'value', axes('Position', [0.08 0.5 0.145 0.1]));
  SoloParamHandle(obj, 'cumplot', 'value', plot(1, 1, 'b-'), 'saveable', 0);
  set(value(h2), 'XLim', [0 0.95], 'YLim', [0 1]);

  
  % --- current trial pokes figure
  SoloFunction('CurrentTrialPokesSubsection', ...
               'ro_args', {'LastTrialEvents', 'RealTimeStates', ...
                      'n_started_trials'});
  if ~Solo_Try_Catch_Flag,
     [x, y] = CurrentTrialPokesSubSection(obj, 'init', x, y);
  else
     try,
        [x, y] = CurrentTrialPokesSubSection(obj, 'init', x, y);
     catch,
        warning('Error in init portion of CurrentTrialPokesSubSection');
        lasterr,
     end;
  end;
 
 case 'update_counts',  % ---------- CASE UPDATE_COUNTS ---------
  Event = GetParam('rpbox', 'event', 'user');
  LastTrialEvents.value = [value(LastTrialEvents) ; Event];
  rts = value(RealTimeStates);
  for i=1:size(Event,1),
     if Event(i,2)==1, % CenterIn
        last_cpoke_in_time.value = Event(i,3); 
     elseif Event(i,2)==2, % CenterOut
        last_cpoke_out_time.value = Event(i,3); 
        CPokes.npokes = CPokes.npokes + 1;
        CPokes.poke_len(CPokes.npokes) = ...
            last_cpoke_out_time - last_cpoke_in_time;
        CPokes.poke_time(CPokes.npokes)  = value(last_cpoke_in_time);
        CPokes.poke_state(CPokes.npokes) = Event(i,1);
        
        CenterPokes.value = CenterPokes + 1;                
        PokeMeasuresSection(obj, 'update_plot');
     elseif Event(i,2) == 3, % LeftIn
        LeftPokes.value = LeftPokes + 1;
     elseif Event(i,2) == 5, % RightIn
        RightPokes.value = RightPokes + 1;
     end;
  end;

  if ~Solo_Try_Catch_Flag, CurrentTrialPokesSubSection(obj, 'update');
  else 
     try,   CurrentTrialPokesSubSection(obj, 'update');
     catch, warning('Error in CurrentTrialPokesSubSection.update'); lasterr,
     end;
  end;
  
  
 case 'update_plot', % --------- CASE UPDATE_PLOT ------- 
   n = CPokes.npokes;
   if n>0,
      u = find(LastCpokeMins*60 > ...
               CPokes.poke_time(n)-CPokes.poke_time(1:n)  &  ...
               CPokes.poke_len(1:n) > 0);
   else
      return;
   end;
   
   if length(u)>0,
      pline = value(p);
      rline = value(r);
      
      set(pline, 'XData', CPokes.poke_time(u), 'YData', CPokes.poke_len(u));
      from = min(CPokes.poke_time(u))-1;   to  = max(CPokes.poke_time(u))+1;
      bot  = min(CPokes.poke_len(u))*0.9;  top = max(CPokes.poke_len(u))*1.1;
      set(value(h), 'XLim', [from to], 'YLim', [bot top]);
     
      red_u = find(CPokes.poke_state(u) == RealTimeStates.wait_for_apoke);
      set(rline, 'XData', CPokes.poke_time(u(red_u)), ...
                 'YData', CPokes.poke_len(u(red_u)));
   end;
   
   if length(u) > 1,
      n = CPokes.poke_len(u);  
      [n, x] = hist(n, 0:0.001:max(n)); n = 100*cumsum(n)/length(u);
      set(value(cumplot), 'XData', n, 'YData', x);
      gridpts = [0 25 50 75 95]; % must always contain 0
      set(value(h2), 'XTick', gridpts, 'XGrid','on','Xlim',gridpts([1 end]));
      
      p = zeros(size(gridpts)); p(1) = 1; empty_flag = 0;
      for i=2:length(gridpts),
         z = max(find(n <= gridpts(i)));
         if isempty(z), empty_flag = 1;
         else p(i) = z;
         end;
      end;
      if ~empty_flag,
         if min(diff(x(p)))>0, 
           set(value(h2), 'YTick', x(p), 'Ygrid', 'on','YLim',x(p([1 end])));
         end;
      end;
   end;
   
   
 case 'delete'            , % ------------ case DELETE ----------
  if ~Solo_Try_Catch_Flag, CurrentTrialPokesSubSection(obj, 'delete');
  else 
     try,   CurrentTrialPokesSubSection(obj, 'delete');
     catch, warning('Error in CurrentTrialPokesSubSection.delete'); lasterr
     end;
  end;
   
   
 otherwise,
   error(['Don''t know how to deal with action ' action]);
end;    


    
    
