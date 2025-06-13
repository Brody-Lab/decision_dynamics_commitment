

function [x, y] = NicSection(obj, action, x, y, varargin)

GetSoloFunctionArgs(obj);

switch action
   %% case init
   case 'init',
      SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)], 'saveable', 0);
      
      
      MenuParam(obj, 'prenic_stim', {'C LED on', 'C LED flash', 'sound', 'none'}, 1, x, y, ...
         'labelfraction', 0.4, ...
         'TooltipString', sprintf('\n Stimulus that indicates "ready to start NIC period"')); next_row(y);
      MenuParam(obj, 'nic_stim', {'C LED on', 'C LED flash',  'C/S LEDs counterflash', 'sound', 'none'}, 1, x, y, ...
         'labelfraction', 0.4, ...
         'TooltipString', sprintf('\n Stimulus that indicates "NIC period"')); 
      set_callback(nic_stim, {mfilename, 'nic_stim'});
      ToggleParam(obj, 'nic_stim_controls', 0, x, y, 'position', [x+180 y 20 20], ...
         'OnString', '', 'OffString', '', 'TooltipString', 'show/hide nic stim parameters window');
      set_callback(nic_stim_controls, {mfilename, 'nic_stim_controls'});
      
         % Create our own figure window
         SoloParamHandle(obj, 'myfig', 'value', ...
            figure('Name', 'Nic Stim Controls', ...
            'CloseRequestFcn', [mfilename '(' class(obj) ', ''nic_stim_controls'', 0)'], ...
            'MenuBar', 'none'), ...
            'saveable', 0);
         figure(value(myfig));
         fpos = get(gcf, 'Position'); set(gcf, 'Position', [fpos(1:2), 220 40]);
         myx = 10; myy = 10;
         SoloParamHandle(obj, 'my_window_info', 'value', [myx, myy, value(myfig)], 'saveable', 0);
         NumeditParam(obj, 'flash_frequency', 5, myx, myy);
         disable(flash_frequency);
         set(gcf, 'Visible', 'off');
         
         % Return to main window;
         figure(my_gui_info(3));
      
      next_row(y, 1.5);
      
      NumeditParam(obj, 'cviol_dur', 0.2, x, y, 'position', [x y 100 20], 'labelfraction', 0.6, ...
         'TooltipString', sprintf(['\nC violation punishment duration.\nIf the animal withdraws ' ...
         'from the C poke during NIC, white noise is played and then a new Cpoke opportunity starts.']), ...
         'HorizontalAlignment', 'center');
      NumeditParam(obj, 'cviol_vol', 0.4, x, y, 'position', [x+100 y 100 20], 'labelfraction', 0.6, ...
         'TooltipString', sprintf(['\nC violation punishment volume.\nIf the animal withdraws ' ...
         'from the C poke during NIC, white noise is played and then a new Cpoke opportunity starts.']), ...
         'HorizontalAlignment', 'center');
      set_callback(cviol_vol, {mfilename, 'cviol_vol'}); set_callback(cviol_dur, {mfilename, 'cviol_dur'});
      PushbuttonParam(obj, 'pcviol_dur', x, y, 'position', [x+40 y 60 20],  'label', 'cviol_dur', ...
         'TooltipString', 'Click to play cviolation sound');
      PushbuttonParam(obj, 'pcviol_vol', x, y, 'position', [x+140 y 60 20], 'label', 'cviol_vol', ...
         'TooltipString', 'Click to play cviolation sound');
      next_row(y);
      set_callback({pcviol_dur, pcviol_vol}, {mfilename, 'play_cviolation_sound'});
      ToggleParam(obj, 'reinit_cpoke', 0, x, y, 'OnString', 'use Cin to reinit cpoke', ...
         'OffString', 'use Chi to reinit cpoke', 'TooltipString', ...
         sprintf(['\nIf black, then after cpoke violation state, a new Cin event is required to start a cpoke;\n' ...
         'If brown, the Cin can occur *during* the violatio state: ' ...
         'if C is hi, then cpoke starts as soon as violation state ends.']));      
      next_row(y, 1.5);
      
      
      NumeditParam(obj, 'nic_mintime', 0, x, y, ...
         'TooltipString', 'Min nic duration per each Cin entry before legal_cbreak or wait_for_cout allowed (in secs)', ...
         'HorizontalAlignment', 'center');
      next_row(y);
      NumeditParam(obj, 'legal_cbreak', 0, x, y, ...
         'TooltipString', 'Max duration of each legal_cbreak (in secs)', 'HorizontalAlignment', 'center');
      next_row(y);
      
      NumeditParam(obj, 'nic', 0.05, x, y, 'position', [x y 80 20], 'labelfraction', 0.35, ...
         'TooltipString', 'Nose in center duration, in secs', 'HorizontalAlignment', 'center');
      ToggleParam(obj, 'rand_nic', 0, x, y, 'position', [x+80 y 120 20], ...
         'OnString', 'Rand NIC', 'OffString', 'Deterministic NIC');
      set_callback(rand_nic, {mfilename, 'rand_nic'});
      next_row(y);
      
      [x, y] = DistribInterface(obj, 'add', 'RandomNIC', x, y, 'Style', ...
         'exponential', 'Min', 0.05, 'Max', 0.06, 'Tau', 1, 'TooltipString', ...
         'Distribution from which the NIC is drawn on each trial');
      DistribInterface(obj, 'disable_all', 'RandomNIC');

      callback(cviol_vol);
      
      SoloFunctionAddVars('SMASection', 'ro_args', ...
         {'prenic_stim', 'nic_stim', 'flash_frequency', 'cviol_dur', 'reinit_cpoke', 'nic', 'nic_mintime', 'legal_cbreak'});

      
      
   %% case next_nic
   case 'next_nic'
      if rand_nic==0,
         return;
      else
         nic.value = DistribInterface(obj, 'get_new_sample', 'RandomNIC');
      end;
      
      
   %% case cviol_vol, cviol_dur
   case {'cviol_vol' 'cviol_dur'}
      if ~SoundManagerSection(obj, 'sound_exists', 'cviolation_sound'),
         SoundManagerSection(obj, 'declare_new_sound', 'cviolation_sound');
      end;

      sr = SoundManagerSection(obj, 'get_sample_rate');
      t=0:(1/sr):value(cviol_dur); 
      RW=cviol_vol*randn(1, numel(t));
      LW=cviol_vol*randn(1, numel(t));

      SoundManagerSection(obj, 'set_sound', 'cviolation_sound', [LW ; RW]);      
      
   %% case play_cviolation_sound   
   case 'play_cviolation_sound',
      SoundManagerSection(obj, 'play_sound', 'cviolation_sound');
      
   %% case rand_nic
   case 'rand_nic',
      if rand_nic==1,
         DistribInterface(obj, 'enable_all',  'RandomNIC');
         disable(nic);
      else
         DistribInterface(obj, 'disable_all', 'RandomNIC');
         enable(nic);
      end;      
      
   %% case nic_stim
   case 'nic_stim'
      if ismember(value(nic_stim), {'C LED flash', 'C/S LEDs counterflash'}),
         enable(flash_frequency);
      else
         disable(flash_frequency);
      end;

   %% case nic_stim_controls
   case 'nic_stim_controls'
      if nargin==3, show = x;
      else          show = (nic_stim_controls==true); %#ok<NODEF>
      end;
      
      if show, set(value(myfig), 'Visible', 'on');  nic_stim_controls.value = true;
      else     set(value(myfig), 'Visible', 'off'); nic_stim_controls.value = false;
      end;
      
      
   %% case close
   case 'close'
      currfig = double(gcf);
      
      % Get the original GUI position and figure:
      x = my_gui_info(1); y = my_gui_info(2); my_figure = my_gui_info(3);
      myfignum = my_window_info(3);

      figure(my_figure);
      
      % Delete all SoloParamHandles who belong to this object and whose
      % fullname starts with the name of this mfile:
      delete_sphandle('owner', ['^@' class(obj) '$'], ...
         'fullname', ['^' mfilename]);
      DistribInterface(obj, 'close', 'RandomNIC');
      delete(myfignum);
      
      % Restore the current figure:
      if my_figure~=currfig,
         figure(currfig);
      end;

         
   %% case reinit
   case 'reinit',
      currfig = double(gcf);
      
      % Get the original GUI position and figure:
      x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));

      feval(mfilename, obj, 'close');
      
      % Reinitialise at the original GUI position and figure:
      [x, y] = feval(mfilename, obj, 'init', x, y);
      
      % Restore the current figure:
      figure(currfig);
end

      
      
