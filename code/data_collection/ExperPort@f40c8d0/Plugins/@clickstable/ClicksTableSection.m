% [x, y] = ClicksTableSection(obj, action, x, y, varargin)

% Starts a subfigure and creates a table of click train sounds. Each sound
% has a volume entry, a frequency entry (clicks/sec), a duration entry, and
% a balance (-1=Left, 0=balanced, 1=Right; total power kept constant
% across balance settings). The number of sounds in the table is dynamic.
%
% This plugin assumes that obj has inherited @SoundManager properties, and
% that dispatcher is open, so that a sound machine exists. The sounds will
% be sent to the sound manager and will have names 'ClicksTableSnd#' where
% sound runs from 1..n, where n is the number of sounds in the table. 
%


function [x, y] = ClicksTableSection(obj, action, x, y, varargin)

GetSoloFunctionArgs(obj);
% sound_attributes = {'vol', 'freq', 'dur', 'bal', 'side', 'pprob', 'wtr_mul'};
sound_attributes = {'vol', 'freq', 'dur', 'bal'};
sound_defaults   = {0.4,    100,    0.5,   0};

switch action
   %% case init
   case 'init',
      SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)], 'saveable', 0);
      
      ToggleParam(obj, 'showhide_clicks_table', 1, x, y, 'OnString', 'Showing Clicks Table', ...
         'OffString', 'Hiding Clicks Table'); next_row(y);
      set_callback(showhide_clicks_table, {mfilename, 'showhide_clicks_table'});  %#ok<NODEF>
      
      SoloParamHandle(obj, 'myfig', 'value', ...
         double(figure('Name', 'Clicks Table', 'CloseRequestFcn', [mfilename '(' class(obj) ', ''hide'')'], ...
         'MenuBar', 'none')), ...
         'saveable', 0);
         figure(value(myfig));
         myx = 10; myy = 10;
         SoloParamHandle(obj, 'my_window_info', 'value', [myx, myy, value(myfig)], 'saveable', 0);
      
         SoloParamHandle(obj, 'existing_nSounds', 'value', 0, 'saveable', 0);
         NumeditParam(obj, 'nSounds', 0, myx, myy, 'HorizontalAlignment', 'center'); next_row(myy);
         set_callback_on_load(nSounds, 1); %#ok<NODEF>
         set_callback(nSounds, {mfilename, 'nSounds'}); %#ok<NODEF>

         nSounds.value = 1; callback(nSounds);
         
      % Return to the main figure window:
      figure(my_gui_info(3));
      
   %% case nSounds
   case 'nSounds',
      if nSounds > existing_nSounds,        %#ok<NODEF>
         % If asking for more sounds than exist, make them:
         orig_fig = double(gcf);
         my_window_visibility = get(my_window_info(3), 'Visible');
         x = my_window_info(1); y = my_window_info(2); figure(my_window_info(3));
         set(my_window_info(3), 'Visible', my_window_visibility);
         
         next_row(y, 1+ value(existing_nSounds));
                 
         new_sounds = (existing_nSounds + 1):value(nSounds);
         for newnum = new_sounds,
            ToggleParam(obj, ['snd_' num2str(newnum) '_header'], 0, x, y, ...
               'OnString', ['Sound ' num2str(newnum)], 'OffString', ['Sound ' num2str(newnum)], ...
               'position', [x y 80 20], 'TooltipString', sprintf(['\nToggle on to play sound; ' ...
               'toggle off to stop it.'])); x = x +80;
            set_callback(eval(['snd_' num2str(newnum) '_header']), {mfilename, 'play_sound', newnum});
            for i=1:numel(sound_attributes),
               if ismember(sound_attributes{i}, {'pprob', 'wtr_mul'}), width = 100; frac = 0.55; 
               else                                                    width = 70; frac = 0.45; 
               end;
               NumeditParam(obj, ['snd_' num2str(newnum) '_' sound_attributes{i}], ...
                  sound_defaults{i}, x, y, 'HorizontalAlignment', 'center', ...
                  'position', [x y width 20], 'labelfraction', frac, ...
                  'label', sound_attributes{i}); x = x+width;
               set_callback(eval(['snd_' num2str(newnum) '_' sound_attributes{i}]), ...
                  {mfilename, 'update_sounds', newnum});
            end;
            next_row(y); x = my_window_info(1);
         end;
         existing_nSounds.value = value(nSounds);
         
         feval(mfilename, obj, 'update_sounds', new_sounds);
         
         figure(orig_fig);
         
      elseif nSounds < existing_nSounds,
         % If asking for fewer vars than exist, delete excess:
         for oldnum = (nSounds+1):value(existing_nSounds);
            delete(eval(['snd_' num2str(oldnum) '_header']));
            for i=1:numel(sound_attributes),
               sphname = ['snd_' num2str(oldnum) '_' sound_attributes{i}];
               delete(eval(sphname));
            end;
         end;
         existing_nSounds.value = value(nSounds);
      end;
      
      % Now check for whether we are in the middle of load settings or load
      % data.
      
      varhandles = {};
      for i = 1:value(nSounds), 
         for j=1:numel(sound_attributes),            
            varhandles = [varhandles ; {eval(['snd_' num2str(i) '_' sound_attributes{j}])}]; %#ok<AGROW>
         end;
      end;
      load_solouiparamvalues(obj, 'ratname', 'rescan_during_load', varhandles);

      
   %% case 'play_sound',
   case 'play_sound'
      snd_toggle = eval(['snd_' num2str(x) '_header']);
      if snd_toggle==1,
         SoundManagerSection(obj, 'play_sound', ['ClicksTableSnd' num2str(x)]);
      else
         SoundManagerSection(obj, 'stop_sound', ['ClicksTableSnd' num2str(x)]);
      end;
      
   %% case set
   case 'set'
      if strcmp(x, 'nSounds'),
         nSounds.value = y;
         callback(nSounds);
         return;
      end;
      
      updated_sounds = [];
      % repackage x and y into varargin so we're always working with
      % triples of "sound_num, attribute, value"
      varargin = [{x y} varargin];
      while numel(varargin)>=3,
         if isnumeric(varargin{1}) && ismember(varargin{2}, sound_attributes),
            if varargin{1}>=1 && varargin{1}<=nSounds, %#ok<NODEF>
               sph = eval(['snd_' num2str(varargin{1}) '_' varargin{2}]);
               sph.value = varargin{3};
               updated_sounds = [updated_sounds ; varargin{1}]; %#ok<AGROW>
            end;
         end;
         varargin = varargin(4:end);
      end;
      
      feval(mfilename, obj, 'update_sounds', unique(updated_sounds));
      
   %% case get
   case 'get'
      switch x,
         case 'nSounds'
            x = value(nSounds);  %#ok<NODEF>
            
         case 'fignum'
            x = my_window_info(3);
         otherwise
            fprintf(1, '%s: Sorry, don''t know how to get "%s"\n', mfilename, x);
      end;
      return;
      
   %% case update_sounds
   case 'update_sounds'
      updated_sounds = x;
      sr=SoundManagerSection(obj,'get_sample_rate');
      
      for i=1:numel(updated_sounds), 
         vol  = value(eval(['snd_' num2str(updated_sounds(i)) '_vol']));
         freq = value(eval(['snd_' num2str(updated_sounds(i)) '_freq']));
         bal  = value(eval(['snd_' num2str(updated_sounds(i)) '_bal']));
         dur  = value(eval(['snd_' num2str(updated_sounds(i)) '_dur']));

         if bal<-1, bal=-1; elseif bal>1, bal=1; end;
         RVol=vol*sqrt((1+bal)/2);
         LVol=vol*sqrt((1-bal)/2);
         snd = MakeBupperSwoop(sr, 0, freq , freq , 1000*dur/2 , 1000*dur/2, 0, 0.1);
         snd = [LVol*snd ; RVol*snd];
         
         sound_name = ['ClicksTableSnd' num2str(updated_sounds(i))];
         if ~SoundManagerSection(obj, 'sound_exists', sound_name),
            SoundManagerSection(obj, 'declare_new_sound', sound_name);
         end;
         SoundManagerSection(obj, 'set_sound', sound_name, snd, 0);
      end;
      SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
      
      
   %% case showhide_clicks_table
   case 'showhide_clicks_table'
      if showhide_clicks_table==1,  %#ok<NODEF>
         set(value(myfig), 'Visible', 'on');
      else
         set(value(myfig), 'Visible', 'off');
      end;
      
   %% case hide
   case 'hide'
      set(value(myfig), 'Visible', 'off');
      showhide_clicks_table.value = 0;
      
   %% case close
   case 'close'
      currfig = double(gcf);
      
      % Get the original GUI position and figure:
      x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));
      my_figure = my_window_info(3);
      
      % Delete all SoloParamHandles who belong to this object and whose
      % fullname starts with the name of this mfile:
      delete_sphandle('owner', ['^@' class(obj) '$'], ...
         'fullname', ['^' mfilename]);
      delete(my_figure);

      % Restore the current figure:
      if my_figure~=currfig,
         figure(currfig);
      end;

         
   %% case reinit
   case 'reinit',
      currfig = double(gcf);
      
      % Get the original GUI position and figure:
      x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));
      my_figure = my_window_info(3);
      
      % Delete all SoloParamHandles who belong to this object and whose
      % fullname starts with the name of this mfile:
      delete_sphandle('owner', ['^@' class(obj) '$'], ...
         'fullname', ['^' mfilename]);
      delete(my_figure);
      
      % Reinitialise at the original GUI position and figure:
      [x, y] = feval(mfilename, obj, 'init', x, y);
      
      % Restore the current figure:
      figure(currfig);
end

      
      
