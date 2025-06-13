

function [x, y] = PostResponseSection(obj, action, x, y, varargin)

GetSoloFunctionArgs(obj);

switch action
   %% case init
   case 'init',
      SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);
      
      NumeditParam(obj, 'CViolWaterFactor', 1, x, y, 'TooltipString', ...
         sprintf(['\nFactor by which water valve times will be multiplied on trials in which' ...
         'there was a cpoke violation'])); next_row(y);
      NumeditParam(obj, 'CGoodWaterFactor', 1, x, y, 'TooltipString', ...
         sprintf(['\nFactor by which water valve times will be multiplied on trials in which' ...
         'there was NO cpoke violation'])); next_row(y);
      NumeditParam(obj, 'DrinkTime', 3, x, y, 'TooltipString', ...
         sprintf('\nOn correct trials, this is the initial drinking time before SoftDrinkTime begins')); 
      next_row(y);
      NumeditParam(obj, 'SoftDrinkGrace', 1.5, x, y, 'position', [x y 100 20], ...
         'TooltipString', sprintf(['\nAfter this amount of time has passed without licks, we assume ' ...
         'he is done drinking and go on']));
      NumeditParam(obj, 'SoftDrinkCap', 7, x, y, 'position', [x+100 y 100 20], ...
         'TooltipString', 'Maximum time cap for drinking, including DrinkTime'); next_row(y);
      ToggleParam(obj, 'WarningSoundPanel', 0, x, y, 'OnString', 'warning sound show', ...
         'OffString', 'warning sound hide', 'position', [x y 140 20]); next_row(y, 1.5);
      set_callback(WarningSoundPanel, {mfilename, 'warn_showhide'}); %#ok<NODEF>
      
         % Create a figure window for Warning sound
         SoloParamHandle(obj, 'warn_fig', 'value', ...
            figure('Name', 'Warning Sound', 'CloseRequestFcn', [mfilename '(' class(obj) ', ''warn_hide'')'], ...
            'MenuBar', 'none'), ...
            'saveable', 0);
         figure(value(warn_fig)); pos = get(gcf, 'Position'); set(gcf, 'Position', [pos(1:2) 230 180]);
         myx = 10; myy = 10;
         SoloParamHandle(obj, 'warn_window_info', 'value', [myx, myy, value(warn_fig)]);

         SoundInterface(obj, 'add', 'warning_sound', myx, myy);
         SoundInterface(obj, 'set', 'warning_sound', 'Vol',   0.0002, 'Vol2',  0.004, 'Dur1',  3, ...
            'Loop',  0, 'Style', 'WhiteNoiseRamp');

         SoloFunctionAddVars('SMASection', 'ro_args', {'DrinkTime', 'SoftDrinkGrace', 'SoftDrinkCap'});

      % Return to the main figure window;
      figure(my_gui_info(3));
      
      ToggleParam(obj, 'temp_v_error', 1, x, y, 'OnString', 'error -> trial terminates', ...
         'OffString', 'error -> temp pun', 'TooltipString', sprintf(['\nChoose between temporary ' ...
         'punishment, in which reward stays available at unchosen side, \nand error pun, in which case ' ...
         'an error terminates the trial.'])); next_row(y);
      ToggleParam(obj, 'showhide', 1, x, y, 'OnString', 'Showing Error Sounds', ...
         'OffString', 'Hiding Error Sounds'); next_row(y);
      set_callback(showhide, {mfilename, 'showhide'});   %#ok<NODEF>
         
         % Create our own figure window
         SoloParamHandle(obj, 'myfig', 'value', ...
            figure('Name', 'Error Sounds', 'CloseRequestFcn', [mfilename '(' class(obj) ', ''hide'')'], ...
            'MenuBar', 'none'), ...
            'saveable', 0);
         figure(value(myfig)); pos = get(gcf, 'Position'); set(gcf, 'Position', [pos(1:2) 230 350]);
         myx = 10; myy = 10;
         SoloParamHandle(obj, 'my_window_info', 'value', [myx, myy, value(myfig)]);
         
         [myx, myy] = SoundInterface(obj, 'add', 'temppun',  myx, myy);         
         NumeditParam(obj, 'temppun_dur', 0.3, myx, myy, ...
            'TooltipString', sprintf(['\nSeconds of temppun punishment-- after this error he ' ...
            '\ncan get reward on the other side']));         
         next_row(myy, 1.5); 
         
         [myx, myy] = SoundInterface(obj, 'add', 'errorpun', myx, myy); 
         NumeditParam(obj, 'errorpun_dur', 4, myx, myy, ...
            'TooltipString', sprintf(['\nSeconds of error punishment-- after this error the ' ...
            '\ntrial terminates and a new trial begins']));         
         next_row(myy, 1.5);
         
         SoundInterface(obj, 'set', 'temppun', 'Vol', 0.01, ...
            'Style', 'ToneFMWiggle', 'Freq1', 4000, 'FMFreq', 50, 'FMAmp', 800, ...
            'Dur1', 1, 'Bal', 0, 'Loop', 1);
         SoundInterface(obj, 'set', 'errorpun', 'Vol', 0.005, ...
            'Style', 'ToneFMWiggle', 'Freq1', 4000, 'FMFreq', 50, 'FMAmp', 800, ...
            'Dur1', 1, 'Bal', 0, 'Loop', 1);

      % Return to the main figure window;   
      figure(my_gui_info(3));

      SoloFunctionAddVars(obj, 'SMASection', 'ro_args', ...
         {'temp_v_error', 'temppun_dur', 'errorpun_dur', 'CViolWaterFactor', 'CGoodWaterFactor'});
      
      feval(mfilename, obj, 'hide');
      feval(mfilename, obj, 'warn_hide');
      
      
   %% case showhide
   case 'showhide'
      if showhide==1,  %#ok<NODEF>
         set(value(myfig), 'Visible', 'on');
      else
         set(value(myfig), 'Visible', 'off');
      end;
      
   %% case hide
   case 'hide'
      set(value(myfig), 'Visible', 'off');
      showhide.value = 0;
      
   %% case warn_showhide
   case 'warn_showhide'
      if WarningSoundPanel==1,  %#ok<NODEF>
         set(value(warn_fig), 'Visible', 'on');
      else
         set(value(warn_fig), 'Visible', 'off');
      end;
      
   %% case warn_hide
   case 'warn_hide'
      set(value(warn_fig), 'Visible', 'off');
      WarningSoundPanel.value = 0;
      
   %% case close
   case 'close'
      currfig = double(gcf);
      
      % Get the original GUI position and figure:
      x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));
      my_figure = my_window_info(3); warn_figure = value(warn_fig);
      
      SoundInterface(obj, 'close', 'temppun');
      SoundInterface(obj, 'close', 'errorpun');
      SoundInterface(obj, 'close', 'warning_sound');
      
      % Delete all SoloParamHandles who belong to this object and whose
      % fullname starts with the name of this mfile:
      delete_sphandle('owner', ['^@' class(obj) '$'], ...
         'fullname', ['^' mfilename]);
      delete(my_figure);
      delete(warn_figure);

      % Restore the current figure:
      if my_figure~=currfig,
         figure(currfig);
      end;

         
   %% case reinit
   case 'reinit',
      currfig = double(gcf);
      
      % Get the original GUI position and figure:
      x = my_gui_info(1); y = my_gui_info(2); start_fig = my_gui_info(3);

      feval(mfilename, obj, 'close');
      
      % Reinitialise at the original GUI position and figure:
      figure(start_fig);
      [x, y] = feval(mfilename, obj, 'init', x, y);
      
      % Restore the current figure:
      figure(currfig);
end

      
      
