% [x, y] = SidesSection(obj, action, x, y)
%
% Section that takes care of choosing the next correct side and keeping
% track of a plot of sides and hit/miss history.
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%            'init'      To initialise the section and set up the GUI
%                        for it; also calls 'choose_next_side' and
%                        'update_plot' (see below)
%
%            'reinit'    Delete all of this section's GUIs and data,
%                        and reinit, at the same position on the same
%                        figure as the original section GUI was placed.
%
%            'choose_next_side'  Picks what will be the next correct
%                        side. 
%
%            'get_next_side'  Returns either 'l' for left or 'r' for right.
%
%            'update_plot'    Update plot that reports on sides and hit
%                        history
%
% x, y     Relevant to action = 'init'; they indicate the initial
%          position to place the GUI at, in the current figure window
%
% RETURNS:
% --------
%
% [x, y]   When action == 'init', returns x and y, pixel positions on
%          the current figure, updated after placing of this section's GUI. 
%
% x        When action = 'get_next_side', x will be either 'l' for
%          left or 'r' for right.
%

function [x, y] = SidesSection(obj, action, x, y)
   
   GetSoloFunctionArgs;
   
   switch action
    
    case 'init',   % ------------ CASE INIT ----------------
      % Save the figure and the position in the figure where we are
      % going to start adding GUI elements:
      SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);

      % List of intended correct sides
      SoloParamHandle(obj, 'previous_sides', 'value', []);

      % Max number of times same side can appear
      MenuParam(obj, 'MaxSame', {'1' '2' '3' '4' '5' '6' '7' '8' 'Inf'}, ...
                '3', x, y);
      next_row(y);
      % Prob of choosing left as correct side
      NumeditParam(obj, 'LeftProb', 0.5, x, y); 
      next_row(y, 1.5);

      SubheaderParam(obj, 'sidestitle', 'Choice of correct Side', x, y);
      next_row(y);

      pos = get(gcf, 'Position');
      SoloParamHandle(obj, 'myaxes', 'saveable', 0, 'value', axes);
      set(value(myaxes), 'Units', 'pixels');
      set(value(myaxes), 'Position', [90 pos(4)-140 pos(3)-130 100]);
      set(value(myaxes), 'YTick', [1 2], 'YLim', [0.5 2.5], 'YTickLabel', ...
                        {'Right', 'Left'});
      NumeditParam(obj, 'ntrials', 20, x, y, ...
                   'position', [5 pos(4)-100 40 40], 'labelpos', 'top', ...
                   'TooltipString', 'How many trials to show in plot');
      set_callback(ntrials, {mfilename, 'update_plot'});      
      xlabel('trial number');
      SoloParamHandle(obj, 'previous_plot', 'saveable', 0);
      
      SidesSection(obj, 'choose_next_side');
      SidesSection(obj, 'update_plot');
      
      
      
    case 'choose_next_side', % --------- CASE CHOOSE_NEXT_SIDE -----
      % If MaxSame doesn't apply yet, choose at random
      if strcmp(value(MaxSame), 'Inf') | MaxSame > n_started_trials,
         if rand(1)<=LeftProb, next_side = 'l'; else next_side = 'r'; end;
      else 
         % MaxSame applies, check for its rules:
         % If there's been a string of MaxSame guys all the same, force change:
         if all(previous_sides(n_started_trials-MaxSame+1:n_started_trials) == ...
                previous_sides(n_started_trials))
            if previous_sides(n_started_trials)=='l', next_side = 'r';
            else                                      next_side = 'l';
            end;
         else
            % Haven't reached MaxSame limits yet, choose at random:
            if rand(1)<=LeftProb, next_side = 'l'; else next_side = 'r'; end;
         end;
      end;
         
      previous_sides(n_started_trials+1) = next_side;

      
    case 'get_next_side',   % --------- CASE GET_NEXT_SIDE ------
      if isempty(previous_sides),
         error('Don''t have next side chosen! Did you run choose_next_side?');
      end;
      x = previous_sides(length(previous_sides));
      return;
      
      
    case 'update_plot',     % --------- UPDATE_PLOT ------
      if ~isempty(value(previous_plot)), delete(previous_plot(:)); end;
      if isempty(previous_sides), return; end;

      ps = value(previous_sides);
      if ps(end)=='l', 
         hb = line(length(previous_sides), 2, 'Parent', value(myaxes));
      else                         
         hb = line(length(previous_sides), 1, 'Parent', value(myaxes));
      end;
      set(hb, 'Color', 'b', 'Marker', '.', 'LineStyle', 'none');
      
      xgreen = find(hit_history);
      lefts  = find(previous_sides(xgreen) == 'l');
      rghts  = find(previous_sides(xgreen) == 'r');
      ygreen = zeros(size(xgreen)); ygreen(lefts) = 2; ygreen(rghts) = 1;
      hg = line(xgreen, ygreen, 'Parent', value(myaxes));
      set(hg, 'Color', 'g', 'Marker', '.', 'LineStyle', 'none'); 

      xred  = find(~hit_history);
      lefts = find(previous_sides(xred) == 'l');
      rghts = find(previous_sides(xred) == 'r');
      yred = zeros(size(xred)); yred(lefts) = 2; yred(rghts) = 1;
      hr = line(xred, yred, 'Parent', value(myaxes));
      set(hr, 'Color', 'r', 'Marker', '.', 'LineStyle', 'none'); 

      previous_plot.value = [hb ; hr; hg];

      minx = n_done_trials - ntrials; if minx < 0, minx = 0; end;
      maxx = n_done_trials + 2; if maxx <= ntrials, maxx = ntrials+2; end;
      set(value(myaxes), 'Xlim', [minx, maxx]);
      drawnow;
      
      
    case 'reinit',   % ------- CASE REINIT -------------
      currfig = gcf; 

      % Get the original GUI position and figure:
      x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));

      delete(value(myaxes));
      
      % Delete all SoloParamHandles who belong to this object and whose
      % fullname starts with the name of this mfile:
      delete_sphandle('owner', ['^@' class(obj) '$'], ...
                      'fullname', ['^' mfilename]);

      % Reinitialise at the original GUI position and figure:
      [x, y] = feval(mfilename, obj, 'init', x, y);

      % Restore the current figure:
      figure(currfig);      
   end;
   
   
      