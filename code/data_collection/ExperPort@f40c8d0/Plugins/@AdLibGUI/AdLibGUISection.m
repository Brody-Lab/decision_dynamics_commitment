% [] = AdLibGUISection(obj, action, varargin)
%
%  Plugin that is meant to facilitate keeping track of how much the rat
%  has been drinking in behavioral sessions.  It also allows the experimenter 
%  to allow or deprive the rat of 1 hour ad lib water, via a GUI the techs 
%  have to interact with. 
%
%  Note: the plugin wateradaptor, which provided a skeleton for this
%  plugin, writes some of the same parameters, such as water volume
%  consumed, to the same bdata table as this plugin.  So it is probably not
%  a good idea to try to use both plugins in your protocol.
%
%  Christine Constantinople, May 2014
%  Modifed by Jess Breda, June 2023
%
%
% HOW THE PLUGIN WORKS:
% --------------------- 
%
% Two parameters in this plugin are the cutoff and total_water_target
% (mL).  The cutoff is the minimum amount of water we want the rat to get
% during the behavioral session (in % body weight), and it determines the 
% total_water_target (mL). Our current IACUC protocol specifies a minimum
% of 3 for the cutoff, (May-2014), although for non-head-fixing rats, we 
% probably want to shoot for 5-6%.
%
% At the beginning of a session (after completion of the first trial), the
% plugin loads and displays information from the behavioral session the day
% before in the panel labeled "previous session report": percent correct 
% (last_hitfrac), number of trials performed (last_tot_trials), water volume 
% consumed (last_waterconsumed).  It retrieves the animal's weight from the
% mass table in bdata to compute the total_water_target (mL) in the
% "calculate target water" panel.  During the session, it updates the water
% delivered in total and from each side poke, and also reports water
% consumed as percent body weight (remember: we are shooting for 3%).
% Importantly, at the end of the session, the water_delivered is saved to
% the ratinfo.rigwater table in bdata (as totalvol), so we can easily 
% access it later.  Whether the animal received ad lib water is also saved
% to that table (in the 'complete' field).  If complete==1, the rat got all
% of its water during the session; if complete==0, the animal got ad lib
% water.  (This field name is a little weird because it has been
% repurposed).
%
% Previous default behavior was to set complete=1 if this plugin was
% active, this was to instruct the techs no to water the rat on his housing
% tower since he was to go to the pub.  Now that all rats will be going to
% the pub the default will be set back to complete=0. Any code that does
% change this to complete=1 will mark the rat as COMPLETE on the pub and
% therefore he will not receive any water there. -Chuck
%
% HOW TO INCORPORATE THIS PLUGIN INTO YOUR PROTOCOL:
% -----------------------
%
% ZEROTH, the protocol assumes that @saveload and @water are also plugins
% for your protocol. It will use the @saveload plugin to ask what the
% experimenter and ratname are; and it will use the @water plugin to set
% the water delivery amounts and to calculate how much the rat was given.
% The protocol also assumes that there is a global variable called
% hit_history that is a vector, n_done_trials long, with 1s for every trial
% in which water was delivered. Finally, the plugin needs a connection to
% bdata in order to be able to work.
% 
%        (0) The plugin updates the water consumed on a trial-by-trial
%        basis, by calling the [Lvol, Rvol] = WaterValvesSection(obj,
%        'get_water_volumes');  This means that both changes in delivered
%        volume over trials and differences between left and right volumes
%        are accounted for.
%
% 
% CODE YOU NEED TO WRITE:
% -----------------------
%
% FIRST, make sure that "AdLibGUI" is included as one of the classes
% from which your protocol will inherit properties. This is done in one of
% the top lines in your main protocol m-file. For example, it might read: 
%
%   obj = class(struct, mfilename, saveload, water, AdLibGUI, sqlsummary);
%
% SECOND, in your 'init' code, include the folliwng line, which will add two
% buttons for the water adaptor in your main window, and will make a window
% (defaUlt closed) for all the water adaptor parameters:
%
%   [x, y] = AdLibGUISection(obj, 'init', x, y); 
%
%
% THIRD, in your 'trial_completed' code, include the following lines:
%    if n_done_trials==1,
%       AdLibGUISection(obj, 'set_first_trial_time_stamp');
%    end
%
%   (AdLibGUI will use this timestamp to calculate performance time
%   while ignoring any delays that may occur between techs starting the
%   protocol and the rat actually being put into the box and starting
%   behavior).
%
% FOURTH, also in your 'trial_completed' code, you need to give this plugin
% information about what just occured so it can either (1) infer the water
% volume given (using `update_water_volume`) or (2) be told the water 
% volume given (using `update_water_volume_manual`). We  
%
%
% (1) Volume inference using `update_water_volume` and performance
% variables to track overall volume and side specific volumes delivered.
% 
%  NOTE: you only need ONE call to `update_water_volume`, in your
% `trial_complete` code, these examples just show you the possible inputs.
% 
% to use this case, there are three varagins:
%   side      : str,  either 'l' or 'r', usually side_history(end)
%   hit       : bool, either 1 or 0,     usually hit_history(end)
%   temperror : bool, either 1 or 0,     usually temperror_history(end)
%
%   Example calls:
%   --------------
%   AdLibGUISection(obj, 'update_water_volume', 'r', 1, 0); % hit trial
%   AdLibGUISection(obj, 'update_water_volume', 'r', 0, 1); % terror trial
%   AdLibGUISection(obj, 'update_water_volume', 'r', 0, 0); % error trial
%
% another way to make sure temp errors w/ water reward are tracked
% is to create a sph in your protocol that is 1 if there was a rewarded
% temp error (also called 'delayed' or 'forgivness') or a hit
%
%   Example calls:
%   --------------
%   AdLibGUISection(obj, 'update_water_volume', 'r', 1); % rewarded trial
%   AdLibGUISection(obj, 'update_water_volume', 'r', 0); % non-rewarded trial
%   
% (2) Explicit volume update using `update_water_volume_manual` which takes
% the volume, in uL, that the animal recieved on the trial. This requires
% your protocol to do the inference. This case has been written to address 
% github issue #10 in Experport. In short, give water and water multipliers 
% features used  by the DMS2 & PWM2 lead to instances where partial or
% multiplied amounts of the water valve volume in WaterValveSection is 
% delivered. See the HistorySection of these protocols to learn about 
% volume calculations.
%
%   Example calls:
%   --------------
%   % 13 uL deliverd to right port
%   AdLibGUISection(... 
%        obj, 'update_water_volume_manual', 'r', 'water_vol_uL', 13);
%   
% FIFTH, in your 'end_session' code, include the following line:
%
%    AdLibGUISection(obj, 'evaluate_outcome');
%
%    (This is where future automation would happen.)
%
% LAST, for general cleanliness, in your 'close' code, include the
% following line: 
%
%     AdLibGUISection(obj, 'close');
%
% That's all the code you need to write. 

 
 
function [varargout] = AdLibGUISection(obj, action, varargin)
 
GetSoloFunctionArgs(obj,'name');
 
switch action,
 
%% init
   case 'init'
      if length(varargin) < 2,
         error('Need at least two arguments, x and y position, to initialize %s', mfilename);
      end;
      if ~isa(obj, 'saveload'),
         error('I need to also be a @saveload class object, so I can get the ratname and experimenter');
      end;
      if ~isa(obj, 'water') && ~isa(obj,'water_pbups')
         error('I need to also be a @water class object, so I can get and set water volumes');
      end;
      x = varargin{1}; y = varargin{2}; varargin = varargin(3:end);
      pairs = { ...
         'init_poke'    'C'    ; ...
      }; parseargs(varargin, pairs);
      
      % SoloParamHandle(obj, 'init_poke_id', 'value', init_poke);  % Identity of poke that is taken as "start trial" poke
      fig = double(gcf);
      SoloParamHandle(obj, 'my_xyfig', 'value', [x y fig]);
      ToggleParam(obj, 'WaptorOnOff', 0, x, y, 'OnString', 'Waptor ON', ...
         'OffString', 'Waptor OFF', ...
         'TooltipString', sprintf('\nTurn AdLibGUI on or off. If off, the plugin is inactive.'), ...
         'position', [x+100 y 90 20]);
      set_callback(WaptorOnOff, {mfilename, 'onoff'});      
      set_callback_on_load(WaptorOnOff, 1);
      ToggleParam(obj, 'WaptorShow', 0, x, y, 'OnString', 'Waptor show', ...
         'OffString', 'Waptor hide', 'TooltipString', 'Show/Hide AdLibGUI panel', ...
         'position', [x y 90 20]);
      set_callback(WaptorShow, {mfilename, 'show_hide'});  %#ok<NODEF>
      next_row(y);
 
      origfig_pos = [x y];      
      SoloParamHandle(obj, 'myfig', 'value', double(figure('Position', [700 100 640 360], ...
         'closerequestfcn', [mfilename '(' class(obj) ', ''hide'');'], 'MenuBar', 'none', ...
         'Name', mfilename)), 'saveable', 0);
      set(gcf, 'Visible', 'off');
      
      x=10; y=10;
      TextBoxParam(obj, 'recipient_list', '', x, y, 'labelpos', 'top', 'labelfraction', 0.1, ...
         'position', [10 10 200 180], 'label', 'List of recipient emails (one per line)', ...
         'TooltipString', sprintf(['\nList of email addresses to get a message every session about this rat''s water consumption (one preson per line)']));
      set(get_ghandle(recipient_list), 'HorizontalAlignment', 'Left', 'FontSize', 12); %#ok<NODEF>
      set(get_lhandle(recipient_list), 'FontSize', 12);
      y = 200;
      
      %Getting rig of manual override.  This is dangerous.  Going to use
      %water consumed and the percent target the experimenter speficied in
      %the registry.  
      SoloParamHandle(obj, 'my_xyfig', 'value', [x y double(gcf)]);
      %ToggleParam(obj, 'manual_override', 0, x, y, 'position', [x y 100 20], ...
      %    'OnString', 'Force Deprive', 'OffString', 'No Force Deprive', 'TooltipString', ...
      %    sprintf(['\nIf ON (black), will force deprive the animal of free water regardless of water intake.\n' ...
      %    'Note that if the last session volume can''t be found in bdata, then the manual number will be used even if disabled.']));
      %set_callback(manual_override, {mfilename, 'manual_override'});
      %set_callback_on_load(manual_override, 1);
      
      ToggleParam(obj, 'water_apartment', 0, x, y, 'position', [x+105 y 100 20], ...
          'OnString', 'Water Apartment', 'OffString', 'Free Water', 'TooltipString', ...
          sprintf(['\nIf ON (black), will ask the tech to place the rat in the watering apartment.\n' ...
          'Otherwise, will ask the tech to water the rat with his session on the housing rack']));
      
      next_row(y);
      
      SoloParamHandle(obj, 'my_xyfig', 'value', [x y double(gcf)]);
      ToggleParam(obj, 'useGUI', 0, x, y, 'position', [x y 100 20], ...
          'OnString', 'pop-up GUI', 'OffString', 'no GUI', 'TooltipString', ...
          sprintf(['\nIf ON (black), GUI giving techs instructions will pop up.\n' ...
          'Otherwise, no GUI']));
      
      next_row(y);
      
      EditParam(obj, 'cutoff', 3, x, y, 'TooltipString', 'Percentage in water per body weight below which we are alarmed and conclude the rat didn''t drink enough in the session ask for extra water');
      next_row(y);
      EditParam(obj, 'max_days_wout_weighing', 3, x, y, 'TooltipString', 'How many days without weighing are we willing to accept before throwing an error.');
      next_row(y);
      EditParam(obj, 'target', 3, x, y, 'TooltipString', 'Target percentage of body weight to be drunk by the rat in the session');
      next_row(y);
      MenuParam(obj, 'FreeWaterMinutes', {'0' '1.5' '5' '60'}, 0, x, y, 'TooltipString', ...
          sprintf(['\nnumber of minutes for which to give free water to this rat after a successful session where it drank more than the cutoff.\n' ...
          'This is the number of minutes that will be shown in the message to the techs in a window on the rig']));
      next_row(y);
      SubheaderParam(obj,'basics_subpart','Targets and limits',x,y); next_row(y);
      
      
      next_column(x); y =10;
      
      SoloParamHandle(obj, 'number_of_assessed_days');
      
      DispParam(obj, 'last_waterconsumed', NaN, x, y, 'labelfraction', 0.65); next_row(y);
      DispParam(obj, 'last_tot_trials', NaN, x, y, 'labelfraction', 0.65); next_row(y);
      DispParam(obj, 'last_hitfrac', NaN, x, y, 'labelfraction', 0.65); next_row(y);
      SubheaderParam(obj,'wph_subpart','previous session report',x,y); next_row(y);
      next_row(y, 0.5);
  
      set_callback({cutoff; max_days_wout_weighing; target}, ...
          {mfilename, 'calculate'}); %#ok<NODEF>
 
      DispParam(obj, 'rat_mass', NaN, x, y, 'labelfraction', 0.65, 'TooltipString', 'latest measured weight'); next_row(y);
      DispParam(obj, 'total_water_target', NaN, x, y, 'label', 'total_water_target (mL)', 'labelfraction', 0.65, 'TooltipString', '= mass * target'); next_row(y);
      SubheaderParam(obj,'wph_subpart','Calculate target water',x,y); next_row(y);
      
      SoloParamHandle(obj, 'short_m', 'value', NaN);
      SoloParamHandle(obj, 'long_m', 'value', NaN);
      
      DispParam(obj, 'loss_index', NaN, x, y, 'label', 'loss_index', 'labelfraction', 0.65, 'TooltipString', 'Corresponds to percent mass lost'); next_row(y);
      DispParam(obj, 'short_avg', NaN, x, y, 'label', 'short_movingavg', 'labelfraction', 0.65, 'TooltipString', 'Mass calc from exponentially weighted moving average with window shortwindow'); next_row(y);
      DispParam(obj, 'long_avg', NaN, x, y, 'label', 'long_movingavg', 'labelfraction', 0.65, 'TooltipString', 'Mass calc from exponentially weighted moving average with window longwindow'); next_row(y);
      NumeditParam(obj, 'shortwindow', 3, x, y, 'label', 'shortwindow', 'labelfraction', 0.65, 'TooltipString', 'Number of days in the past to include in short moving average of weight'); next_row(y);
      NumeditParam(obj, 'longwindow', 20, x, y, 'label', 'longwindow', 'labelfraction', 0.65, 'TooltipString', 'Number of days in the past to include in long moving average of weight'); next_row(y);
      SubheaderParam(obj,'wph_subpart','Moving Averages algorithm',x,y); next_row(y);
 
      
      next_column(x); y = 10;
      next_row(y);
      DispParam(obj, 'nhits', 0, x, y, 'labelfraction', 0.65); next_row(y);
      DispParam(obj, 'right_volume', 0, x, y, 'labelfraction', 0.65); next_row(y);
      DispParam(obj, 'left_volume', 0, x, y, 'labelfraction', 0.65); next_row(y);
      DispParam(obj, 'water_delivered', 0, x, y, 'labelfraction', 0.65); next_row(y);
      DispParam(obj, 'water_as_percent', 0, x, y, 'labelfraction', 0.65); next_row(y);
      SubheaderParam(obj,'report_subpart','end-of-day Delivery Report',x,y); next_row(y);
 
      
      SoloParamHandle(obj, 'sessdate');
      SoloParamHandle(obj, 'sesshits');
      SoloParamHandle(obj, 'massdate');
      SoloParamHandle(obj, 'masses');
      SoloParamHandle(obj, 'wdate');
      SoloParamHandle(obj, 'water');
 
      
      SoloParamHandle(obj, 'init_time', 'value', now);
      SoloParamHandle(obj, 'end_of_first_trial_time', 'value', NaN);
      SoloParamHandle(obj, 'end_time', 'value', NaN);
      
      DispParam(obj, 'message',  'haven''t done more than just initialize', x, y, ...
         'labelfraction', 0.2, 'position', [10 450 440 20], ...
         'HorizontalAlignment', 'center');
      
      feval(mfilename, obj, 'onoff');
      figure(fig);
      varargout{1} = origfig_pos(1);
      varargout{2} = origfig_pos(2);
      
      SoloParamHandle(obj, 'wait_for_warning_click', 'value', 0);
      
      return;
        
      
   case 'set_first_trial_time_stamp',
      end_of_first_trial_time.value = now;
      
      [experimenter, ratname] = SavingSection(obj, 'get_info');         

      [last_ntrials, last_hits] = ...
             bdata(['select n_done_trials, total_correct ' ...
             'from sessions where ratname = "{S}" order by sessiondate desc limit 1 '], ...
             ratname);
      if isempty(last_ntrials); last_ntrials = 0; end
      if isempty(last_hits);    last_hits    = 0; end
         
      last_tot_trials.value = last_ntrials;
      last_hitfrac.value = last_hits;
 
      AdLibGUISection(obj, 'calculate');
      
      
   case 'set_recipient_list',
      recipient_list.value = varargin{1}; %#ok<STRNU>
      
   case 'ison?'
      varargout{1} = (WaptorOnOff==1);
      return;
      
 
%% case show_hide      
  case 'show_hide',
    if WaptorShow == 1, set(value(myfig), 'Visible', 'on');  %#ok<NODEF>
    else                set(value(myfig), 'Visible', 'off');
    end;
      
            
%% case show
   case 'show'
      WaptorShow.value = 1; set(value(myfig), 'Visible', 'on'); %#ok<STRNU>
  
%% case hide or close
   case 'hide' 
      WaptorShow.value = 0; set(value(myfig), 'Visible', 'off'); %#ok<STRNU>
 
      
%% case update_water_volume      
   case 'update_water_volume'
       
       my_side = varargin{1}; 
       hit_history = varargin{2};
       
       % sub logic by Wynne S 2022 to track temp error water in pbups
       % protocol using temperror_history variable
       if length(varargin) >2
           temperr = varargin{3};
           if temperr == 1
               hit_history = 1;
           end
       end
      
       if hit_history==1 
           if numel(varargin{1})~=1 || ~ismember(varargin{1}, {'l' 'r'}),
               error('%s - %s expects exactly one argument, either ''1/l'' for left or ''0/r'' for right!', mfilename, action);
           end;
           nhits.value = value(nhits) + 1;
           
           try
           [Lvol, Rvol] = WaterValvesSection(obj, 'get_water_volumes');
           catch ME;
               warning('The error message was %s', ME.message); 
           end;
           if my_side == 'r'
               right_volume.value = right_volume + Rvol/1000;
               water_delivered.value = water_delivered + Rvol/1000; 
           elseif my_side == 'l'
               left_volume.value = left_volume + Lvol/1000;
               water_delivered.value = water_delivered + Lvol/1000; 
           end
           if ~isnan(value(rat_mass));
               water_as_percent.value = (value(water_delivered)/value(rat_mass))*100;
           end
       end
       
%% case update_water_volume_manual      
    case 'update_water_volume_manual'
        
        my_side = varargin{1};
        % catch any errors in in the inputs
        if numel(varargin{1})~=1 || ~ismember(varargin{1}, {'l' 'r'}),
            error('%s - %s expects exactly one argument, either ''1/l'' for left or ''0/r'' for right!', mfilename, action);
        end
        
        method = varargin{2};
        if ~strcmp(method, 'water_vol_uL')
            error('%s - %s expects a label for the second argument of "water_vol_uL", not "%s"', mfilename, action, method);
        end
        
        volume_uL = varargin{3};
        if (volume_uL > 0) && (volume_uL < 0.1) % 0.1 uL can't be delievered by our valves
            error('volume appears to be in mL, %s-%s expects uL!', mfilename, action);
        end
        
        % append values if water was delievered 
        if volume_uL > 0
            % in this case, better to think about this as "n rewarded" trials
            nhits.value = value(nhits) + 1;
           
            % update side specific volumes
            if my_side == 'r'
                right_volume.value = right_volume + volume_uL/1000;
            elseif my_side == 'l'    
                left_volume.value = left_volume + volume_uL/1000;
            end
           
            % update total session volume
            water_delivered.value = water_delivered + volume_uL/1000; 
           
            % calculate water as a percent of today's mass
            if ~isnan(value(rat_mass));
                water_as_percent.value = (value(water_delivered)/value(rat_mass))*100;
            end
        end
        
       
%% case 'close'
   case 'close'
      
    
      %AdLibGUISection(obj, 'evaluate_outcome');
       
      while(value(wait_for_warning_click)==1), %#ok<NODEF>
         pause(0.3); drawnow;
      end;
      
      delete(warningBtn);
      delete(warningTxt);
      delete(fig);
       
      fnum = value(myfig);
      delete_sphandle('owner', ['^@' class(obj) '$'], ...
         'fullname', ['^' mfilename]);
      delete(fnum);
      
%% calculate
    case 'calculate'  %
       varargout{1} = NaN; % Default return value is error
 
       % Don't calculate if loading data
       if load_soloparamvalues(obj, 'in the middle of a data load?')
          return;
       end;
       
       message.value = ''; % But default message is empty, given we don't know the error yet
              
       pairs = { ...
          'outlier_sd'              3   ; ...
       }; parseargs(varargin, pairs);
 
       try
          [experimenter, ratname] = SavingSection(obj, 'get_info');         
          if strcmp(experimenter, 'experimenter') || strcmp(ratname, 'ratname')
             return;
          end;
          
 
          [sdate, protocol, ntrials, hitfrac, sessid, starttime, endtime, percent_violations] = ...
             bdata(['select sessiondate, protocol, n_done_trials, total_correct, sessid, starttime, endtime, percent_violations ' ...
             'from sessions where ratname = "{S}" and experimenter = "{S}" order by sessiondate desc limit 1'], ...
             ratname, experimenter);
         
          if isempty(sdate),
             report_message(obj, recipient_list, 'Are experimenter/ratname set to a real rat?'); %#ok<NODEF>
             return;
          end;

          minutes = (datenum(endtime) - datenum(starttime))*24*60;


          sessdate.value = sdate; %#ok<STRNU>
          sesshits.value = round(ntrials.*hitfrac.*(1-percent_violations));
         
          [waterdate, last_water] = bdata(['select dateval, totalvol from ratinfo.rigwater where ratname="{S}" order by dateval desc limit 1'], ratname);
          
          if ~isempty(last_water)
            last_waterconsumed.value = last_water;
          end
          
          israt = bdata(['select israt from ratinfo.rats where ratname="',ratname,'"']);
          if israt == 1
            [mdate, mass] = bdata(['select date, mass from ratinfo.mass where ratname="{S}" order by date desc limit 1'], ratname);
          else
            [mdate,mass] = bdata(['select date, mass from ratinfo.mass where ratname="',ratname,'" order by date']);
            freewaterdays = find(mass == 0);
            mass(freewaterdays) = [];
            mdate(freewaterdays) = [];
            
            if numel(mass) >= 7
                m = max(mass(1:7));
                mdate = mdate{find(mass == m,1,'first')};
                mass = m;
            elseif ~isempty(mass)
                m = max(mass);
                mdate = mdate{find(mass == m,1,'first')};
                mass = m;
            else
                mass = 999;
                mdate = '';
            end
          end
          
          if now-datenum(mdate) >= max_days_wout_weighing && israt == 1,
             %only do this check for rats, mouse weight uses baseline
             report_message(obj, recipient_list, sprintf('Rat has not been weighed in %d days or more.', ...
                floor(now - datenum(mdate)))); %#ok<NODEF>
          end;
          massdate.value = mdate; %#ok<STRNU>
          masses.value   = mass;
          rat_mass.value = mass; %#ok<STRNU>
          
          %AdLibGUISection(obj, 'update_water_volume');
          
          [ptemp,exclude] = extract_percent_water_registry(ratname);
          
          total_water_target.value = value(rat_mass)*(ptemp / 100);
          target.value = ptemp;
          
          
       catch ME, report_error(obj, recipient_list, ME);
          return;
       end;
       
  
%% evaluate_outcome
   case 'evaluate_outcome'
 
       if value(WaptorOnOff)==1;

          end_time.value = now;
          minutes = (datenum(value(end_time)) - datenum(value(end_of_first_trial_time)))*24*60; %#ok<NODEF>
          ntrials = value(n_done_trials);
          nhits = value(nhits);
          waterconsumed = value(water_delivered);

          water_as_percent.value = value(water_delivered)/value(rat_mass)*100;

          [experimenter, ratname] = SavingSection(obj, 'get_info'); %#ok<ASGLU>
           %try
           %    feval(mfilename, obj, 'email_report', waterconsumed, ntrials, nhits, minutes);
           %catch ME, report_error(obj, recipient_list, ME); %#ok<NODEF>
           %end;

      
          [mdate, mass] = bdata(['select date, mass from ratinfo.mass where ratname="{S}"'], ratname);
          [mdate, I] = sort(mdate);
          mass = mass(I);
          
          %% Calculate weight from short and long moving averages
          n = value(longwindow);
          longalpha = n/(n+1);
          s = value(shortwindow);
          shortalpha = s/(s+1); long_m = []; short_m = []; counter = 0;
          if length(mass) > n;
              for t = length(mass)-20:length(mass);
                  if counter==0
                      long_m(t) = mass(t);
                      short_m(t) = mass(t);
                  else
                      long_m(t) = longalpha*long_m(t-1) + (1-longalpha)*mass(t);
                      short_m(t) = shortalpha*short_m(t-1) + (1-shortalpha)*mass(t);
                  end
                  counter = counter+1;
              end

              long_avg.value = long_m(end);
              short_avg.value = short_m(end);
              loss_index.value = ((value(long_avg)- value(short_avg))/value(rat_mass))*100;
          else
              long_avg.value = NaN;
              short_avg.value = NaN;
              loss_index.value = NaN;
          end


          %No longer using manual override.  Now the only way a rat will
          %not get extra water is if he consumed all his water in the rig
          if value(water_delivered) >= value(total_water_target) %manual_override ==1
              message.value = sprintf([ratname,' consumed %.1f%% body mass of water. This is ABOVE his target.'], value(water_as_percent));
              try
                  feval(mfilename, obj, 'water_needs_figure', 0);
              catch ME, report_error(obj, recipient_list, ME);
              end;

          else
              message.value = sprintf([ratname,' consumed %.1f%% body mass of water. This is BELOW his target.'], value(water_as_percent));
              try
                  feval(mfilename, obj, 'water_needs_figure', 1);
              catch ME, report_error(obj, recipient_list, ME);
              end;
          end
       end
       
%% Until we find a good algorithm for making the watering decisions for us, 
%% this part will not be automated.                  
%       elseif manual_override ==0
%           if value(short_m(end)) < value(long_m(end)),
%               if water_as_percent < cutoff,
%                   message.value = sprintf('ALERT! Delivered only %.1f%% of water', value(water_as_percent));
%                   try
%                       feval(mfilename, obj, 'water_needs_figure', 1);
%                   catch ME, report_error(obj, recipient_list, ME);
%                   end;
%                   
%                   try
%                       if use_bdata,
%                           bdata(['insert into ratinfo.rigwater set ratname="', ratname, ...
%                               '", dateval="', datestr(now, 'yyyy-mm-dd'), ...
%                               '", totalvol=', num2str(value(water_delivered)), ...
%                               ', complete=0', ...
%                               ', n_rewarded_trials=',num2str(nhits)]);
%                       end;
%                   catch ME, report_error(obj, recipient_list, ME);
%                   end;
%               else
%                   message.value = sprintf('All good. Delivered %.1f%% of water', value(water_as_percent));
%                   try
%                       feval(mfilename, obj, 'water_needs_figure', 0);
%                   catch ME, report_error(obj, recipient_list, ME);
%                   end;
%                   
%                   try
%                       if use_bdata,
%                           bdata(['insert into ratinfo.rigwater set ratname="', ratname, ...
%                               '", dateval="', datestr(now, 'yyyy-mm-dd'), ...
%                               '", totalvol=', num2str(value(water_delivered)), ...
%                               ', complete=1', ...
%                               ', n_rewarded_trials=',num2str(nhits)]);
%                       end;
%                   catch ME, report_error(obj, recipient_list, ME);
%                   end;
%               end;
%           elseif value(short_m(end)) >= value(long_m(end));
%               message.value = sprintf('All good. Delivered %.1f%% of water', value(water_as_percent));
%               try
%                   feval(mfilename, obj, 'water_needs_figure', 0);
%               catch ME, report_error(obj, recipient_list, ME);
%               end;
%               
%               try
%                   if use_bdata,
%                       bdata(['insert into ratinfo.rigwater set ratname="', ratname, ...
%                           '", dateval="', datestr(now, 'yyyy-mm-dd'), ...
%                           '", totalvol=', num2str(value(water_delivered)), ...
%                           ', complete=1', ...
%                           ', n_rewarded_trials=',num2str(nhits)]);
%                   end;
%               catch ME, report_error(obj, recipient_list, ME);
%               end;
%           end
      
      
%% end_session_report
   case 'end_session_report'
       
        try
           ntrials = value(nhits);
           
          % if WaptorOnOff==1 && isa(obj, 'water')
           if WaptorOnOff==1
               feval(mfilename, obj, 'evaluate_outcome', ntrials);
           end;
        catch ME, report_error(obj, recipient_list, ME);
        end
      
%% email_report
   case 'email_report'
 
      waterconsumed         = varargin{1};
      ntrials               = varargin{2};
      nhits                 = varargin{3};
      training_time         = varargin{4};
      hitfrac               = nhits/ntrials;
      
      [experimenter, ratname] = SavingSection(obj, 'get_info'); 
      [mdate, mass] = bdata(['select date, mass ' ...
          'from ratinfo.mass where ratname="{S}" order by date desc limit 10'], ratname);
      
      rat_mass.value = mass(end); %#ok<STRNU>
      water_as_percent.value = (waterconsumed/value(rat_mass))*100;
      
      try
      [wdate, water] = bdata('select dateval, totalvol, complete from ratinfo.rigwater where ratname = "{S}"', ratname);
      
      catch
          ME, report_error(obj, recipient_list, ME);
      end
      
      
      mstr = sprintf('%s / %s\n\n', experimenter,  ratname);
      
      if ~isempty(value(message)), %#ok<NODEF>
          mstr = sprintf('%sNote: had this error message: "%s"\n\n', mstr, value(message));
      end;
      
      mstr = sprintf('%s%.1f%% of weight from %d hits, at avg %.1f uL/hit, which is %.1f g of water.\n\n', ...
         mstr, water_as_percent, nhits, 1000*waterconsumed/nhits, waterconsumed);
     
      mstr = sprintf('%sNote: history of weight from past week:  %.1f g, %.1f g, %.1f g, %.1f g, %.1f g, %.1f g, %.1f g.\n\n', ...
         mstr, mass(I-6), mass(I-5), mass(I-4), mass(I-3), mass(I-2), mass(I-1), rat_mass);
     
      % If all the times exist, report them:
      if ~any(isnan([value(init_time) value(end_of_first_trial_time) value(end_time)])), %#ok<NODEF>
         minutes = (end_time - end_of_first_trial_time)*24*60;
         mstr = sprintf('%sProtocol Init time=%s, End of tial 1=%s, End time=%s,\nfor %.2f minutes', mstr, ...
            datestr(value(init_time), 'HH:MM'), ...
            datestr(value(end_of_first_trial_time), 'HH:MM'), ...
            datestr(value(end_time), 'HH:MM'),  minutes);
         mstr = sprintf('%s at %.1f trials per minute and %.1f%% correct.\n\n', mstr, ntrials./minutes, 100*hitfrac);
      end;
      
      %if manual_override==1
      %    mstr = sprintf('%s\n*** WAS FORCE-DEPRIVED BY USER BY MANUAL OVERRIDE.  MONITOR WEIGHT/WATER. ***\n\n', mstr);
      %end;
   
      mstr = sprintf('%sRat history:\n', mstr);
      sdates = sessdate(end-min(numel(value(sessdate))-1, 7):end); %#ok<NODEF>
      shits  = sesshits(end-min(numel(value(sesshits))-1, 7):end); %#ok<NODEF>
      mdates = massdate(end-min(numel(value(massdate))-1, 7):end); %#ok<NODEF>
      mass   = masses(end-min(numel(value(masses))-1,   7):end); %#ok<NODEF>
      mstr = sprintf('%sDays ago; nhits\n', mstr);
      for i=1:numel(sdates)
         sdates{i} = floor(now - datenum(sdates{i}));
         mstr = sprintf('%s%d\t', mstr, sdates{i});
      end;
      mstr = sprintf('%s\n', mstr);
      for i=1:numel(sdates)
         mstr = sprintf('%s%d\t', mstr, shits(i));
      end;
      mstr = sprintf('%s\n\nDays ago; mass\n', mstr);
      for i=1:numel(sdates)
         mdates{i} = floor(now - datenum(mdates{i}));
         mstr = sprintf('%s%d\t', mstr, mdates{i});
      end;
      mstr = sprintf('%s\n', mstr);
      for i=1:numel(mdates)
         mstr = sprintf('%s%d\t', mstr, mass(i));
      end;
      mstr = sprintf('%s\n', mstr);
 
 
      mysendmail(cellstr(value(recipient_list)), sstr, mstr); %#ok<NODEF>
 
      if isa(obj, 'comments')
         CommentsSection(obj, 'append_line', mstr);
         CommentsSection(obj, 'clean_lines');
      end;
 
      
      
%% water_needs_figure
   case 'water_needs_figure'
      water_the_rat = varargin{1};
      
      %This is a hack to ensure this plugin does not mark the rat as
      %complete=1 in the rigwater table.  If the rat did drink his full
      %alotment of water in the rig the pub will mark him as complete and
      %not offer him any water. -Chuck
      %water_the_rat = 1;
      %Turned the hack off since the plugin now pulls the percent water the
      %experimenter has designated in the registry just like the pub
 
      [experimenter, ratname] = SavingSection(obj, 'get_info'); %#ok<ASGLU>
      
      if water_the_rat
          try
              bdata(['insert into ratinfo.rigwater set ratname="', ratname, ...
                  '", dateval="', datestr(now, 'yyyy-mm-dd'), ...
                  '", totalvol=', num2str(value(water_delivered)), ...
                  ', complete=0', ...
                  ', n_rewarded_trials=',num2str(nhits)]);
          catch ME, report_error(obj, recipient_list, ME);
              
          end
      else
          try
              bdata(['insert into ratinfo.rigwater set ratname="', ratname, ...
                  '", dateval="', datestr(now, 'yyyy-mm-dd'), ...
                  '", totalvol=', num2str(value(water_delivered)), ...
                  ', complete=1', ...
                  ', n_rewarded_trials=',num2str(nhits)]);
          catch ME, report_error(obj, recipient_list, ME);
          end;
      end
      
      
      if water_the_rat && ~value(water_apartment),
         background_color = [0 1 0];
         str = {[ratname ' gets free water.']  'ADD SIPPER TUBE!!'};
         str2 = {['REGRESE EL TUBO DE AGUA'] 'de le su hora'};
      elseif water_the_rat && value(water_apartment),
         background_color = [0 1 1];
         str = {['TAKE ' ratname ' TO WATERING CHAMBER']  'remove sipper tube'};
         str2 = {['TOMALO A LA CAJA DE AGUA'] 'regrese el tube de agua'};
      else
         background_color = [1 0 0];
         str = {['No free water for ', ratname,] 'REMOVE SIPPER TUBE!!'};
         str2 = {['Restricion: SACE EL TUBO'] 'no le de agua hoy.'};
      end;
      
      
      if value(useGUI)==1
          fig = double(figure('Position', [50, 50, 800, 600]));
          try
              jf=get(value(fig), 'JavaFrame');
              pause(0.1);
              javaMethod('setAlwaysOnTop', jf.fFigureClient.getWindow, 1);
          catch %#ok<CTCH>
              disp('WARNING: Failed to keep runrats on top');
          end
          
          
          set(fig, 'WindowStyle', 'modal');
          DispParam(obj, 'warningTxt', str, 50, 50, 'position', [50 100 700 450], ...
              'labelfraction', 0.01);
          DispParam(obj, 'spanishwarning', str2, 50, 50, 'position', [50 15 700 300],...
              'labelfraction', 0.01);
          h = get_ghandle(warningTxt);
          set(h, 'FontSize', 40, 'FontWeight', 'bold', 'BackgroundColor', background_color, ...
              'HorizontalAlignment', 'center');
          h = get_ghandle(spanishwarning);
          set(h, 'FontSize', 40, 'FontWeight', 'bold', 'BackgroundColor', background_color, ...
              'HorizontalAlignment', 'center');
          
          
          PushbuttonParam(obj, 'warningBtn', 50, 50, 'position', [50 5 700 90], ...
              'label', 'OK -- click here to acknowledge', 'FontWeight', 'bold')
          h = get_ghandle(warningBtn);
          set(h, 'FontSize', 30);
          wait_for_warning_click.value = 1;
          
          set_callback(warningBtn, {mfilename, 'warning_callback'});
          
          
          drawnow;
          
      end
%% warning_callback
   case 'warning_callback'
      wait_for_warning_click.value = 0; %#ok<STRNU>
      
      
%% reinit
    case 'reinit',       % ---------- CASE REINIT -------------
       % Delete all SoloParamHandles who belong to this object and whose
       % fullname starts with the name of this mfile:
 
       if exist('my_xyfig', 'var');
          x = my_xyfig(1); y = my_xyfig(2); origfig = my_xyfig(3); %#ok<NASGU>
          feval(mfilename, obj, 'close');
          delete(value(myfig));
       else
          x = varargin{1}; y = varargin{2};
       end;
       currfig = double(gcf); origfig = double(gcf);
    
    
       delete_sphandle('owner', ['^@' class(obj) '$'], ...
          'fullname', ['^' mfilename]);
 
       figure(origfig);
       feval(mfilename, obj, 'init', x, y);
       figure(currfig);
   
end;
return;
 
 
 
%% report_message
 
function [] = report_message(obj, recipient_list, message)
   warning(message);
   if isa(obj, 'comments'),
      CommentsSection(obj, 'append_line', sprintf('Got error "%s"\n', message));
      CommentsSection(obj, 'clean_lines');
   end;
 
   try
      mysendmail(cellstr(value(recipient_list)), 'Waptor error', message); 
   catch %#ok<CTCH>
   end;
 
 
 
 
 
%% report_error
 
function [] = report_error(obj, recipient_list, ME)
   warning(ME.identifier, 'Got error "%s" in file "%s", line %d\n', ...
      ME.message, ME.stack(1).file, ME.stack(1).line);
   if isa(obj, 'comments')
      CommentsSection(obj, 'append_line', ...
         sprintf('Got error "%s" in file "%s", line %d\n', ...
         ME.message, ME.stack(1).file, ME.stack(1).line));
      CommentsSection(obj, 'clean_lines');
   end;
 
   try
      mysendmail(cellstr(value(recipient_list)), 'Waptor error', ME.message); 
   catch %#ok<CTCH>
   end;
 
 
%% mysendmail
 
function [] = mysendmail(cstr, sstr, mstr)
cstr = strtrim(cstr);
keeps = logical(ones(size(cstr))); %#ok<LOGL>
for i=1:numel(cstr)
   if isempty(cstr{i}),
      keeps(i) = false;
   end;
end;
cstr = cstr(keeps);
 
if ~isempty(cstr) && ~isempty(cstr{1})
   %setpref('Internet','SMTP_Server','brodyfs2.princeton.edu');
   %setpref('Internet','E_mail','AdLibGUISection@Princeton.EDU');
   set_email_sender
   sendmail(cstr, sstr, mstr);
end;
return;
 

