% Typical section code-- this file may be used as a template to be added 
% on to. The code below stores the current figure and initial position when
% the action is 'init'; and, upon 'reinit', deletes all SoloParamHandles 
% belonging to this section, then calls 'init' at the proper GUI position 
% again.


% [x, y] = YOUR_SECTION_NAME(obj, action, x, y)
%
% Section that takes care of YOUR HELP DESCRIPTION
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%            'init'      To initialise the section and set up the GUI
%                        for it
%
%            'reinit'    Delete all of this section's GUIs and data,
%                        and reinit, at the same position on the same
%                        figure as the original section GUI was placed.
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


function [x, y] = ReactionTimeWaterSection(obj, action, x, y)
   
   GetSoloFunctionArgs;
   
   switch action
    case 'init',
      % Save the figure and the position in the figure where we are
      % going to start adding GUI elements:
      fig = gcf;
      SoloParamHandle(obj, 'my_gui_info', 'value', [x y fig]);

      ToggleParam(obj, 'RT_Water_btn', 0, x, y, ...
                  'label', 'Reaction Time and Water', ...
                  'TooltipString', ['Show/Hide window that controls ' ...
                          'Water as a function of reaction time'], ...
                  'OnFontWeight', 'normal', 'OffFontWeight', 'normal', ...
                  'position', [x y 180 20]);
      set_callback(RT_Water_btn, {mfilename, 'window_toggle'});
      next_row(y);

      oldx = x; oldy = y;
   
      SoloParamHandle(obj, 'myfig', 'saveable', 0, 'value', ...
                      figure('Position', [200 320 300 200], ...
                             'MenuBar', 'none', 'Name', mfilename, ...
                             'NumberTitle', 'off', ...
                             'CloseRequestFcn', [mfilename ...
                          '(' class(obj) ', ''hide_window'');']));

      set(value(myfig), 'Visible', 'off');

      % ---- No w to initialising the new window
      x = 5; y = 5;
      
      NumeditParam(obj, 'LowWaterRT_L1', 0.001, x, y, 'position', ...
                   [x y 148 20], 'labelfraction', 0.6, ...
                   'TooltipString', sprintf(['\nReaction times smaller ' ...
                          'than this (secs) on left lead to water \n' ...
                          'valve time multiplied by LowWaterFactor']));
      NumeditParam(obj, 'HighWaterRT_L1', 1, x, y, ...
                   'position', [x+150 y 150 20], 'labelfraction', 0.65, ...
                   'TooltipString', sprintf(['\nReaction times larger ' ...
                          'than this (secs) on left lead to water \n' ...
                          'valve time multiplied by HighWaterFactor']));
      next_row(y);

      NumeditParam(obj, 'LowWaterRT_L2', 0.001, x, y, 'position', ...
                   [x y 148 20], 'labelfraction', 0.6, ...
                   'TooltipString', sprintf(['\nReaction times smaller ' ...
                          'than this (secs) on left lead to water \n' ...
                          'valve time multiplied by LowWaterFactor']));
      NumeditParam(obj, 'HighWaterRT_L2', 1, x, y, ...
                   'position', [x+150 y 150 20], 'labelfraction', 0.65, ...
                   'TooltipString', sprintf(['\nReaction times larger ' ...
                          'than this (secs) on left lead to water \n' ...
                          'valve time multiplied by HighWaterFactor']));
      next_row(y, 1.5);

      NumeditParam(obj, 'LowWaterRT_R1', 0.001, x, y, 'position', ...
                   [x y 148 20], 'labelfraction', 0.6, ...
                   'TooltipString', sprintf(['\nReaction times smaller ' ...
                          'than this (secs) on right lead to water \n' ...
                          'valve time multiplied by LowWaterFactor']));
      NumeditParam(obj, 'HighWaterRT_R1', 1, x, y, ...
                   'position', [x+150 y 150 20], 'labelfraction', 0.65, ...
                   'TooltipString', sprintf(['\nReaction times larger ' ...
                          'than this (secs) on right lead to water \n' ...
                          'valve time multiplied by HighWaterFactor']));
      next_row(y);

      NumeditParam(obj, 'LowWaterRT_R2', 0.001, x, y, 'position', ...
                   [x y 148 20], 'labelfraction', 0.6, ...
                   'TooltipString', sprintf(['\nReaction times smaller ' ...
                          'than this (secs) on right lead to water \n' ...
                          'valve time multiplied by LowWaterFactor']));
      NumeditParam(obj, 'HighWaterRT_R2', 1, x, y, ...
                   'position', [x+150 y 150 20], 'labelfraction', 0.65, ...
                   'TooltipString', sprintf(['\nReaction times larger ' ...
                          'than this (secs) on right lead to water \n' ...
                          'valve time multiplied by HighWaterFactor']));
      next_row(y, 2);

      NumeditParam(obj, 'LowWaterFactor', 1, x, y, 'position', ...
                [x y 148 20], 'labelfraction', 0.6, ...
                   'TooltipString', sprintf(...
                     ['\nFactor by which to multiply water valve time\n' ...
                      'when reaction time < LowWaterRT']));
      NumeditParam(obj, 'HighWaterFactor', 1, x, y, ...
                   'position', [x+150 y 150 20], 'labelfraction', 0.65, ...
                   'TooltipString', sprintf(...
                  ['\nFactor by which to multiply water valve time\n' ...
                   'when reaction time > HighWaterRT']));
      next_row(y, 2);

      
      set_callback({LowWaterRT_L1;  HighWaterRT_L1 ; ...
                    LowWaterRT_L2;  HighWaterRT_L2 ; ...
                    LowWaterRT_R1;  HighWaterRT_R1 ; ...
                    LowWaterRT_R2;  HighWaterRT_R2 ; ...
                   },   {mfilename, 'rt_boundaries'});
      set_callback({LowWaterFactor;HighWaterFactor}, {mfilename, ...
                          'factor_boundaries'});

      
      SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', ...
                          {'LowWaterRT_L1',  'HighWaterRT_L1', ...
                          'LowWaterRT_L2',   'HighWaterRT_L2', ...
                          'LowWaterRT_R1',   'HighWaterRT_R1', ...
                          'LowWaterRT_R2',   'HighWaterRT_R2', ...
                          'LowWaterFactor',  'HighWaterFactor'});
      
      SubheaderParam(obj, 'title', 'Reaction Time / Water', x, y);

      x = oldx; y = oldy; figure(fig);
      return;

    case 'window_toggle',
      if value(RT_Water_btn) == 1, set(value(myfig), 'Visible', 'on');
      else                         set(value(myfig), 'Visible', 'off');
      end;

    case 'hide_window'       , % ------------ case HIDE ----------
      RT_Water_btn.value = 0;
      set(value(myfig), 'Visible', 'off');
      
    case 'rt_boundaries',
      if HighWaterRT_L2 < 0.001,  HighWaterRT_L2.value = 0.001; end;
      if LowWaterRT_L2  < 0.001,  LowWaterRT_L2.value  = 0.001; end;
      if HighWaterRT_L2 < LowWaterRT_L2, 
         HighWaterRT_L2.value = value(LowWaterRT_L2);
      end;

      if HighWaterRT_L1 < 0.001,  HighWaterRT_L1.value = 0.001; end;
      if LowWaterRT_L1  < 0.001,  LowWaterRT_L1.value  = 0.001; end;
      if HighWaterRT_L1 < LowWaterRT_L1, 
         HighWaterRT_L1.value = value(LowWaterRT_L1);
      end;
      
      if HighWaterRT_R2 < 0.001,  HighWaterRT_R2.value = 0.001; end;
      if LowWaterRT_R2  < 0.001,  LowWaterRT_R2.value  = 0.001; end;
      if HighWaterRT_R2 < LowWaterRT_R2, 
         HighWaterRT_R2.value = value(LowWaterRT_R2);
      end;
      
      if HighWaterRT_R1 < 0.001,  HighWaterRT_R1.value = 0.001; end;
      if LowWaterRT_R1  < 0.001,  LowWaterRT_R1.value  = 0.001; end;
      if HighWaterRT_R1 < LowWaterRT_R1, 
         HighWaterRT_R1.value = value(LowWaterRT_R1);
      end;
      
      
      
    case 'factor_boundaries',
      if HighWaterFactor < 0, HighWaterFactor.value = 0; end;
      if LowWaterFactor  < 0, LowWaterFactor.value  = 0; end;

      
    case 'delete'            , % ------------ case DELETE ----------
      delete(value(myfig));

      
    case 'reinit',
      currfig = gcf; 

      % Get the original GUI position and figure:
      x = my_gui_info(1); y = my_gui_info(2); origfig = my_gui_info(3);
      myfignum = myfig(1); 
      
      % Delete all SoloParamHandles who belong to this object and whose
      % fullname starts with the name of this mfile:
      delete_sphandle('owner', ['^@' class(obj) '$'], ...
                      'fullname', ['^' mfilename]);      
      delete(myfignum);

      % Reinitialise at the original GUI position and figure:
      figure(origfig);
      [x, y] = feval(mfilename, obj, 'init', x, y);

      % Restore the current figure:
      figure(currfig);      
   end;
   
   
      

