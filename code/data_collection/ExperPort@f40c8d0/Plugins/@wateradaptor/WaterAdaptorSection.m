% [] = WaterAdaptorSection(obj, action, varargin)
%
%  Plugin that keeps track of how much the rat has been drinking in behavioral
%  sessions, and uses that information, together with a target rat mass
%  fraction of water, to decide how much to water to deliver per correct trial.
%
%
% HOW THE PLUGIN WORKS:
% ---------------------
%
% Two key parameters in this plugin, at the top left of its window, are the
% target, and the cutoff. The target is the percentage of the rat's mass
% that we want to deliver as water. The cutoff is the percentage below
% which we decide that the rat received too little in its session, and send
% alerts to the techs and the experimenter so the rat receives some extra
% water. Our current IACUC protocol specifies a minimum of 3 for the
% cutoff (April-2013).
%
% At the beginning of a session, the plugin will use the number of hits in
% the last session as a guess of the number of hits for this session, and
% will divide the desired water delivery mass by that number to obtain a
% guess as to how much water to give per hit. After that guess is made, the
% water to be delivered is further limited by parameters defining the
% maximum fractional increase/decrease from one session to the next (we
% don't like sudden changes, they can lead to instability), as well as 
% an absolute minimum or maximum to give (e.g., never give more than 200 uL
% per trial, that's getting crazy in terms of open water valve times). The 
% plugin  then talks directly to @water/WaterValvesSection to set the
% desired water per hit.
%
% At the end of the session, the plugin will calculate how much water the
% rat was given. If it was given more than the cutoff, the plugin puts up a
% big green square on the rig saying "no further water for this rat". The
% tech must click on that window for it to go away. In addition, the plugin
% makes an entry in bdata/ratinfo.rigwater that indicates that this rat got
% its water allotment. WaterMeister will take that into account and will
% remove (for today only) the rat from the list of rats to be given water.
%    If the rat was given less than the cutoff, the plugin puts up a big
% red square on the rig saying "give this rat water!". The tech must click
% on that window for it to go away. In addition, the plugin makes an
% entry in bdata/ratinfo.rigwater that indicates that this rat did NOT get
% its water allotment. WaterMeister will report this rat as an animal that
% needs to be given post-training water.
%    In either event, an email reporting what happened is sent to the
% people on the email list (one of the plugins GUI parameters is where the
% email list is defined). 
%
%
% HOW TO USE THIS PLUGIN:
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
%     KNOWN BUGS: 
%         (0) The plugin computes water delivered as 
%                 (# hits) * mean([leftwater, rightwater]) where the
%            leftwater and rightwater are as reported by @water at the end
%            of the session. This means that changes in delivered volume
%            over trials, or differences between left and right volumes,
%            are not considered.
%         (1) The plugin DOES NOT YET WORK WITH NIGHT SHIFT RATS
%         (2) The plugin does not yet take into account the fact that Sats,
%            Suns, and Mons, may be special in the sense that the expected
%            nhits for these days may differ from other, regular days
%         (3) The protocol currently predicts nhits just from the previous
%            session, and does not take into account longer history. Nor
%            does it automatically ignore outliers (e.g., if a rig broke on
%            a particular day, that does not mean that the rat will perform
%            zero trials on the next day when it's been fixed)
%         (4) Startup into using this plugin for a rat should be automated.
%            See below in this help section for suggestions on how to
%            start a rat. 
%         (5) Documentation on the code to automatically adapt the target
%            across sessions is still missing.
%
% 
% CODE YOU NEED TO WRITE:
% -----------------------
%
% FIRST, make sure that "wateradaptor" is included as one of the classes
% from which your protocol will inherit properties. This is done in one of
% the top lines in your main protocol m-file. For example, it might read: 
%
%   obj = class(struct, mfilename, saveload, water, wateradaptor, sqlsummary);
%
% SECOND, in your 'init' code, include the folliwng line, which will add two
% buttons for the water adaptor in your main window, and will make a window
% (defualt closed) for all the water adaptor parameters:
%
%   [x, y] = WaterAdaptorSection(obj, 'init', x, y); 
%
% THIRD, in your 'trial_completed' code, include the following lines:
%    if n_done_trials==1,
%       WaterAdaptorSection(obj, 'set_first_trial_time_stamp');
%    end
%
%   (WaterAdaptor will use this timestamp to calculate trials per minute
%   while ignoring any delays that may occur between techs starting the
%   protocol and the rat actually being put into the box and starting
%   behavior).
%
% FOURTH, in your 'end_session' code, include the following line:
%
%    WaterAdaptorSection(obj, 'end_session_report');
%
%    (This is where WaterAdaptor figures out how much the rat drank,
%    whether it reached its target, alerts techs and users about it, etc.)
%
% FIFTH, for general cleanliness, in your 'close' code, include the
% following line: 
%
%     WaterAdaptorSection(obj, 'close');
%
% That's all the code you need to write. 
%
%
% 
%
% SUGGESTED WAY TO START A RAT ON USING THIS PLUGIN:
% --------------------------------------------------
%
% The hardest thing is the transition from regular watering to water in
% session only. Choose a day, and tell the tech not to water the rat. Give
% it a 5-min post-training supplement yourself. On the second day, do the
% same again. This second day's session will give you an estimate of how
% many trials to expect from the rat under water-mostly-in-session
% conditions. For the third day, turn WaterAdaptor on, and use the manual
% override on last session volume so that the expected total water the rat
% will receive will be close to your target. On the fourth day, turn the
% manual override off, and hopefully you can now sit back and let the
% automated system do its thing. 
%
% Go over each of the parameters in the plugin, hovering your mouse over
% each one. They all have a tooltip string that should help you understand
% what they are, so you can figure out what value to give them. The default
% values are Carlos'-experience-suggested values.
%
% Put your own email address, and the email address of the tech running the
% rat, in the email listbox. Maybe once we've fully fully debugged the
% system we can take those out and not get so many pesky emails.
%



function [varargout] = WaterAdaptorSection(obj, action, varargin)

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
      if ~isa(obj, 'water'),
         error('I need to also be a @water class object, so I can get and set water volumes');
      end;
      x = varargin{1}; y = varargin{2}; varargin = varargin(3:end);
      pairs = { ...
         'init_poke'    'C'    ; ...
      }; parseargs(varargin, pairs);
      
      % SoloParamHandle(obj, 'init_poke_id', 'value', init_poke);  % Identity of poke that is taken as "start trial" poke
      SoloParamHandle(obj, 'my_xyfig', 'value', [x y double(gcf)]);
      ToggleParam(obj, 'WaptorOnOff', 0, x, y, 'OnString', 'Waptor ON', ...
         'OffString', 'Waptor OFF', ...
		 'TooltipString', sprintf('\nTurn WaterAdaptor on or off. If off, the plugin is inactive.'), ...
         'position', [x+100 y 90 20]);
      set_callback(WaptorOnOff, {mfilename, 'onoff'});      
      set_callback_on_load(WaptorOnOff, 1);
      ToggleParam(obj, 'WaptorShow', 0, x, y, 'OnString', 'Waptor show', ...
         'OffString', 'Waptor hide', 'TooltipString', 'Show/Hide WaterAdaptor panel', ...
         'position', [x y 90 20]);
      set_callback(WaptorShow, {mfilename, 'show_hide'});  %#ok<NODEF>
      next_row(y);

      origfig_pos = [x y];      
      SoloParamHandle(obj, 'myfig', 'value', double(figure('Position', [700 100 640 560], ...
         'closerequestfcn', [mfilename '(' class(obj) ', ''hide'');'], 'MenuBar', 'none', ...
         'Name', mfilename)), 'saveable', 0);
      set(gcf, 'Visible', 'off');
      
      x=10; y=10;
      TextBoxParam(obj, 'recipient_list', '', x, y, 'labelpos', 'top', 'labelfraction', 0.1, ...
         'position', [10 10 200 180], 'label', 'List of recipient emails (one per line)', ...
         'TooltipString', sprintf(['\nList of email addresses to get a message every session about this rat''s water consumption (one preson per line)']));
      set(get_ghandle(recipient_list), 'HorizontalAlignment', 'Left', 'FontSize', 12); %#ok<NODEF>
      set(get_lhandle(recipient_list), 'FontSize', 14);
      y = 200;
      
      EditParam(obj, 'max_days_wout_training', 5, x, y, 'TooltipString', ...
         sprintf(['\nWaterAdaptor tries to predict number of trials;\n' ...
		 'this param sets maximum number of days without training before we declare we can''t predict number of trials']), ...
         'labelfraction', 0.8);
      next_row(y);
      EditParam(obj, 'max_days_wout_weighing', 3, x, y, 'TooltipString', ...
         sprintf(['\nWaterAdaptor tries to predict required water as a fraction of rat mass;\n', ...
		 'maximum number of days without weighing before we declare we don''t know this rat''s mass']), ...
         'labelfraction', 0.8);
      next_row(y, 1.5);
      
      EditParam(obj, 'min_water', 15, x, y, 'TooltipString', 'minimum water per hit, in uL. Overrides any other factor');
      next_row(y);
      EditParam(obj, 'max_water', 200, x, y, 'TooltipString', 'maximum water per hit, in uL. Overrides any other factor');
      next_row(y, 1.5);

      EditParam(obj, 'cutoff', 3, x, y, 'TooltipString', 'percentage in water per body weight below which we are alarmed and conclude the rat didn''t drink enough in the session ask for extra water');
      next_row(y);
      EditParam(obj, 'target', 4, x, y, 'TooltipString', 'target percentage of body weight to be drunk by the rat in the session');
      next_row(y);
	  MenuParam(obj, 'FreeWaterMinutes', {'0' '1.5' '5'}, 0, x, y, 'TooltipString', ...
		  sprintf(['\nnumber of minutes for which to give free water to this rat after a successful session where it drank more than the cutoff.\n' ...
		  'This is the number of minutes that will be shown in the message to the techs in a window on the rig']));
	  next_row(y);
	  SubheaderParam(obj,'basics_subpart','Targets and limits',x,y); next_row(y);
	  
	  
      next_column(x); y =10;
      
      SoloParamHandle(obj, 'number_of_assessed_days');
      
      DispParam(obj, 'last_trials_per_min', NaN, x, y, 'labelfraction', 0.65); next_row(y);
      DispParam(obj, 'last_tot_trials', NaN, x, y, 'labelfraction', 0.65); next_row(y);
      DispParam(obj, 'last_hitfrac', NaN, x, y, 'labelfraction', 0.65); next_row(y);
	  SubheaderParam(obj,'wph_subpart','previous session report',x,y); next_row(y);
	  next_row(y, 0.5);
	  
	  % EditParam(obj, 'avgwindow', 10, x, y, 'TooltipString', 'For predicting nhits: window of # of sessions over which will examine nhits');
      % next_row(y);
      % EditParam(obj, 'avgtau', 0.1, x, y, 'TooltipString', 'For predicting nhits: tau of exponential weighting on nhits per session, most recent weighted most strongly-- used to predict nhits in next session');
      % next_row(y);
      EditParam(obj, 'manual_lastsess_vol', 70, x, y, 'labelfraction', 0.65, ...
		  'position', [x y 175 20], ...
		  'TooltipString', sprintf(['\nDon''t try to find last session''s volume per hit, use this manual override number (in uL) instead.\n' ...
		  'Note that if the last session volume can''t be found in bdata, then the manual number will be used even if disabled.\n' ...
		  'The toggle button at the right turns this manual override on or off.']));
	  ToggleParam(obj, 'manual_lastsess_vol_override', 0, x, y, 'position', [x+180 y 20 20], ...
		  'OnString', '', 'OffString', '', 'TooltipString', ...
		  sprintf(['\nIf ON (black), don''t try to find last session''s volume per hit, and use the manual override number instead.\n' ...
		  'Note that if the last session volume can''t be found in bdata, then the manual number will be used even if disabled.']));
	  disable(manual_lastsess_vol);
	  set_callback(manual_lastsess_vol_override, {mfilename, 'manual_lastsess_vol_override'});
	  next_row(y);
      EditParam(obj, 'manual_nhits', 200, x, y, 'labelfraction', 0.65, ...
		  'position', [x y 175 20], ...
		  'TooltipString', sprintf(['\nIgnore nhits predicted based on previous performance, use this manual override number instead.\n' ...
		  'The toggle button at the right turns this manual override on or off.']));
	  ToggleParam(obj, 'manual_override', 0, x, y, 'position', [x+180 y 20 20], ...
		  'OnString', '', 'OffString', '', 'TooltipString', ...
		  sprintf('\nIf ON (black), ignore previous performance-based prediction of nhits, and use the manual override number instead'));
	  disable(manual_nhits);
	  set_callback(manual_override, {mfilename, 'manual_override'});
	  next_row(y, 1.5);
      EditParam(obj, 'max_reduction', 1.15, x, y, 'TooltipString', ['\nmaximum factor by which the uL/hit is allowed to decrease from one ' ...
         'session to the next. The water/hit is capped at this, it can''t be smaller.']);
      next_row(y);
      EditParam(obj, 'max_increase', 1.05, x, y, 'TooltipString', ['\nmaximum factor by which the uL/hit is allowed to increase from one ' ...
         'session to the next. The water/hit is capped at this, it can''t be larger.']);
      next_row(y, 1.5);

	  set_callback({max_reduction;max_increase;min_water;max_water;manual_nhits;manual_lastsess_vol;target}, ...
		  {mfilename, 'calculate'}); %#ok<NODEF>

      DispParam(obj, 'rat_mass', NaN, x, y, 'labelfraction', 0.65, 'TooltipString', 'latest measured weight'); next_row(y);
      DispParam(obj, 'uncapped_expected_hits', NaN, x, y, 'labelfraction', 0.65, ...
		  'TooltipString', 'Based on most recent session'); next_row(y);
      DispParam(obj, 'expected_hits', NaN, x, y, 'labelfraction', 0.65, ...
		  'TooltipString', 'expected hits after considering possible manual override'); next_row(y);
      DispParam(obj, 'total_water_target', NaN, x, y, 'label', 'total_water_target (mL)', 'labelfraction', 0.65, 'TooltipString', '= mass * target'); next_row(y);
      DispParam(obj, 'uncapped_water_per_hit', NaN, x, y, 'labelfraction', 0.65, 'TooltipString', '= total_water_target / expected_hits'); next_row(y);
      DispParam(obj, 'water_per_hit', NaN, x, y, 'label', 'water_per_hit (uL)', 'labelfraction', 0.65, 'TooltipString', 'amount that will be given after considering max/min change limits, etc.'); next_row(y);
	  DispParam(obj, 'final_expected_water', NaN, x, y, 'label', 'final_expected_water (mL)', 'labelfraction', 0.65, 'TooltipString', '= water_per_hit * expected_hits. Compare to total_wtaer_target.'); next_row(y);
	  SubheaderParam(obj,'wph_subpart','start-of-day Estimating water per hit',x,y); next_row(y);
	  next_row(y);     	  
      
	  next_column(x); y = 10;
      EditParam(obj, 'tpm_threshold', 5.1, x, y, 'TooltipString', ...
		  sprintf(['threshold (or rather, target) for trials per minute.\n' ...
		  'If the day had more than these trials per minute, increase the water target.\n' ...
		  'If the day had fewer than these trials per minute, increase the water target.\n' ...
		  'The goal is to make the water target (expressed in term of fraction of body mass)\n.' ...
		  'as large as possible consistent with achieving a certain number of trials per minute.']));
      next_row(y);
      EditParam(obj, 'target_increase', 0.2, x, y, 'TooltipString', 'How much to increase the target by if we were above threshold. E.g., "0.1" here on a "3.5" target would mean increase from "3.5%" to "3.6%"');
      next_row(y);
      EditParam(obj, 'target_decrease', 0.5, x, y, 'TooltipString', 'How much to decrease the target by if we were below threshold. E.g., "0.1" here on a "3.5" target would mean decrease from "3.5%" to "3.4%"');
      next_row(y);
      EditParam(obj, 'target_min', 3.5, x, y, 'TooltipString', 'Minimum target-- decreases cannot take it lower than this');
      next_row(y);
      EditParam(obj, 'target_max', 6.0, x, y, 'TooltipString', 'Maximum target-- increases cannot take it higher than this');
      next_row(y);
	  ToggleParam(obj, 'TargetControlOnOff', 0, x, y, 'OnString', 'Target Control ON', ...
		  'OffString', 'Target Control OFF', 'TooltipString', ...
		  sprintf(['Toggle automatic across-days control of target water as a percentage of body mass']));
	  set_callback(TargetControlOnOff', {mfilename, 'toggle_target_control'});
	  feval(mfilename, obj, 'toggle_target_control');
	  next_row(y);
	  SubheaderParam(obj,'title','Target Control',x,y, 'TooltipString', ...
		  sprintf(['\nThis part controls across-days automatic setting of the target\n' ...
		  'percentage of water to give per session. This is done by comparing, at the end\n', ...
		  'of each session, the trials performed per minute (tpm) to tpm_threshold. If the\n', ...
		  'animal performed more tpm than the threshold, it is assumed to be too thirsty, and\n', ...
		  'the target for the next session is increased. If the animal performed fewer tpm than the threshold, it\n', ...
		  'is assumed to not be thirsty enough, and the target for the next session is decreased.'])); 
      next_row(y, 2);

	  DispParam(obj, 'water_delivered', NaN, x, y, 'labelfraction', 0.75); next_row(y);
      DispParam(obj, 'percent_weight_delivered', NaN, x, y, 'labelfraction', 0.75); next_row(y);
      SubheaderParam(obj,'report_subpart','end-of-day Delivery Report',x,y); next_row(y);

      
      SoloParamHandle(obj, 'sessdate');
      SoloParamHandle(obj, 'sesshits');
      SoloParamHandle(obj, 'massdate');
      SoloParamHandle(obj, 'masses');

      SoloParamHandle(obj, 'init_time', 'value', now);
      SoloParamHandle(obj, 'end_of_first_trial_time', 'value', NaN);
      SoloParamHandle(obj, 'end_time', 'value', NaN);
      
      DispParam(obj, 'message',  'haven''t done more than just initialize', x, y, ...
         'labelfraction', 0.2, 'position', [10 450 440 20], ...
         'HorizontalAlignment', 'center');
      
      feval(mfilename, obj, 'onoff');
      figure(my_xyfig(3));
      varargout{1} = origfig_pos(1);
      varargout{2} = origfig_pos(2);
      
      return;
      
%% case manual_lastsess_vol_override
	case 'manual_lastsess_vol_override'
		if manual_lastsess_vol_override==1,
			enable(manual_lastsess_vol);
		else
			disable(manual_lastsess_vol);
		end;
		if WaptorOnOff==1,
			feval(mfilename, obj, 'calculate');
		end;
	  

		%% case manual_override
	case 'manual_override'
		if manual_override==1,
			enable(manual_nhits);
			disable(max_days_wout_training);
		else
			disable(manual_nhits);
			enable(max_days_wout_training);
		end;
		if WaptorOnOff==1,
			feval(mfilename, obj, 'calculate');
		end;
	  
%% case toggle_target_control
	case 'toggle_target_control', 
		if TargetControlOnOff==1,
			enable(target_max);
			enable(target_min);
			enable(target_decrease);
			enable(target_increase);
			enable(tpm_threshold);
		else
			disable(target_max);
			disable(target_min);
			disable(target_decrease);
			disable(target_increase);
			disable(tpm_threshold);
		end;
      
%% case set_first_trial_time_stamp
   case 'set_first_trial_time_stamp',
      end_of_first_trial_time.value = now;
      
      
%% case set_recipient_list
   case 'set_recipient_list',
      recipient_list.value = varargin{1}; %#ok<STRNU>
      
%% case ison
   case 'ison?'
      varargout{1} = (WaptorOnOff==1);
      return;
      
%% case onoff
   case 'onoff'
      if WaptorOnOff==1,
         enable(target); 
         enable(total_water_target); 
		 enable(uncapped_water_per_hit); %#ok<*NODEF>
		 enable(water_per_hit);
		 enable(final_expected_water);
         target = feval(mfilename, obj, 'calculate');
      else
         disable(target); %#ok<NODEF>
         disable(total_water_target); %#ok<NODEF>
		 disable(uncapped_water_per_hit); %#ok<*NODEF>
		 disable(water_per_hit);
		 disable(final_expected_water);
      end;

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
      
%% case 'close'
   case 'close'
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

          [sdate, ntrials, hitfrac, sessid, starttime, endtime, percent_violations] = ...
             bdata(['select sessiondate, n_done_trials, total_correct, sessid, starttime, endtime, percent_violations ' ...
             'from sessions where ratname="{S}" and experimenter="{S}" order by sessiondate '], ...
             ratname, experimenter);
          if isempty(sdate),
             report_message(obj, recipient_list, 'Are experimenter/ratname set to a real rat?'); %#ok<NODEF>
             return;
          end;

          minutes = (datenum(endtime) - datenum(starttime))*24*60;

          if manual_override==0 && (now - datenum(sdate{end}) >= max_days_wout_training),
             report_message(obj, recipient_list, sprintf('Haven''t trained in %d days or more, don''t know how much water to give!', ...
                floor(now - datenum(sdate(end))))); %#ok<NODEF>
             return;
          end;
          sessdate.value = sdate; %#ok<STRNU>
          sesshits.value = round(ntrials.*hitfrac.*(1-percent_violations));

          last_trials_per_min.value = round(10*ntrials(end)./minutes(end))/10; %#ok<STRNU>
          last_tot_trials.value     = ntrials(end); %#ok<STRNU>
          last_hitfrac.value        = round(100*sesshits(end)./ntrials(end))/100; %#ok<STRNU>
          
          [mdate, mass] = ...
             bdata(['select date, mass ' ...
             'from ratinfo.mass where ratname="{S}"'], ratname);
          [mdate, I] = sort(mdate);
          mass = mass(I);
          
          if now-datenum(mdate{end}) >= max_days_wout_weighing,
             report_message(obj, recipient_list, sprintf('Rat has not been weighed in %d days or more, I don''t know how much water to give', ...
                floor(now - datenume(mdate{end})))); %#ok<NODEF>
          end;
          massdate.value = mdate; %#ok<STRNU>
          masses.value   = mass;
          rat_mass.value = mass(end); %#ok<STRNU>
          
          if manual_lastsess_vol_override==0,
			  [tdate, trvol] = bdata(['select dateval, trialvol from ratinfo.rigwater where ratname="{S}"'], ratname);
			  if ~isempty(trvol)
				  [trash, I] = sort(tdate); %#ok<ASGLU>  % Matlab on the rigs doesn't know about ~ !!
				  trvol = trvol(I);
			  else  % If it's the first day the rat is doing WaterAdaptor, it doesn't have any entries in ratinfo.rigwater
				  trvol = NaN;   
				  if ismember(lower(class(obj)),lower(bdata('show tables from protocol')))
					  % We have a protocol table
					  column_names = bdata(['explain protocol.' class(obj)]);
					  if ~isempty(find(strcmp(column_names, 'WaterValvesSection_Left_volume'), 1)) && ...
							  ~isempty(find(strcmp(column_names, 'WaterValvesSection_Right_volume'), 1)),
						  % We have entries for lefto volume and right volume
						  leftvol  = bdata(sprintf('select WaterValvesSection_Left_volume  from protocol.%s where sessid="%d"', class(obj), sessid(end)));
						  rightvol = bdata(sprintf('select WaterValvesSection_Right_volume from protocol.%s where sessid="%d"', class(obj), sessid(end)));
						  trvol = mean([leftvol;rightvol]);
					  end;
				  end;
				  if isnan(trvol), % Just couldn''t find it! use the manual override amount
					  trvol = value(manual_lastsess_vol);
				  end;
			  end;
		  else
			  trvol = value(manual_lastsess_vol);
		  end;
          
       catch ME, report_error(obj, recipient_list, ME);
          return;
       end;
       
       
       try
          % Get the number of sessions over which we'll average # hit trials:
          % OLD CODE: exponential weighting over a window, ignoring
          % outliers
		  % winsize = min([value(avgwindow), numel(value(sesshits))]); 
		  % myguys  = sesshits(end-winsize+1:end);
          % non_outliers = find(abs(myguys - mean(myguys)) < outlier_sd*std(myguys));
          % 
          % while numel(non_outliers) < numel(myguys),
          %   if numel(non_outliers) < 1,
          %      message.value = sprintf('Can''t find a non-outlier day in the last %d days', avgtau);
          %      varargout{1} = NaN;
          %      varargout{2} = value(message);
          %      return;
          %   end;
		  %   myguys = myguys(non_outliers);
          %   non_outliers = find(abs(myguys - mean(myguys)) < outlier_sd*std(myguys));
          % end;
		  % number_of_assessed_days.value = numel(myguys);
          % s = -(numel(myguys)-1):0;
          % w = exp(s'/avgtau);
		  %
		  % ("markdown" used to be a multiplicative manual fudge factor)
          % expected_hits.value           = ceil(markdown*sum(w.*myguys)/sum(w)); 
          
		  uncapped_expected_hits.value  = sesshits(end);
		  if manual_override == 1,
			  expected_hits.value       = value(manual_nhits);
			  if expected_hits < 1,     
				  % Can't be less than one.
				  expected_hits.value = 1;
			  end;
		  else
			  expected_hits.value       = value(uncapped_expected_hits);
		  end;
		  
		  total_water_target.value      = (target/100)*masses(end);       %#ok<NODEF> % in uL
          uncapped_water_per_hit.value  = total_water_target/expected_hits*1000; %#ok<*STRNU> % in uL
		  water_per_hit.value           = value(uncapped_water_per_hit);
		  
          % Implement cap on water reduction:
          minimum_water_per_hit         = trvol(end)/max_reduction;
          maximum_water_per_hit         = trvol(end)*max_increase;
          water_per_hit.value           = min([value(max_water), maximum_water_per_hit, value(water_per_hit)]);
          water_per_hit.value           = max([value(min_water), minimum_water_per_hit, value(water_per_hit)]);
          
		  final_expected_water.value    = water_per_hit*expected_hits/1000;
		  
          varargout{1} = value(water_per_hit);

          if ~isnan(value(water_per_hit)) && WaptorOnOff==1,
             WaterValvesSection(obj, 'set_water_amounts', value(water_per_hit), value(water_per_hit));
          end;
          
       catch ME, report_error(obj, recipient_list, ME);
          return;
       end;
       
       
       
%% evaluate_outcome
   case 'evaluate_outcome'
      
      nhits             = varargin{1};
      delivered_per_hit = varargin{2};
      
      varargin = varargin(3:end);      
      pairs = { ...
         'use_bdata', 1 ; ...
      }; parseargs(varargin, pairs);

      end_time.value = now;
      minutes = (datenum(value(end_time)) - datenum(value(end_of_first_trial_time)))*24*60; %#ok<NODEF>
      ntrials = value(n_done_trials);
      if TargetControlOnOff==1,
		  if ntrials/minutes >= tpm_threshold
			  new_target = target + target_increase; %#ok<NODEF>
		  else
			  new_target = target - target_decrease; %#ok<NODEF>
		  end;
		  if new_target > target_max, new_target = value(target_max); end;
		  if new_target < target_min, new_target = value(target_min); end;
		  delta_target = new_target - target;
		  target.value = new_target;
	  end;
      
      water_delivered.value   = nhits*(delivered_per_hit/1000);            
      percent_weight_delivered.value = 100*water_delivered/rat_mass; %#ok<NODEF>
      [experimenter, ratname] = SavingSection(obj, 'get_info'); %#ok<ASGLU>

      try
         feval(mfilename, obj, 'email_report', value(water_delivered), nhits, delta_target);
      catch ME, report_error(obj, recipient_list, ME); %#ok<NODEF>
      end;        

      if percent_weight_delivered < cutoff, 
         message.value = sprintf('ALERT! Delivered only %.1f%% of water', value(percent_weight_delivered));
         try
            feval(mfilename, obj, 'water_needs_figure', 1);
         catch ME, report_error(obj, recipient_list, ME);
         end;
         
         try
            if use_bdata,
               bdata(['insert into ratinfo.rigwater set ratname="', ratname, ...
                  '", dateval="', datestr(now, 'yyyy-mm-dd'), ...
                  '", totalvol=', num2str(value(water_delivered)), ...
                  ', trialvol=',  num2str(delivered_per_hit), ...
                  ', complete=0', ...
                  ', n_rewarded_trials=',num2str(nhits)]);
            end;
         catch ME, report_error(obj, recipient_list, ME);
         end;
      else
         message.value = sprintf('All good. Delivered %.1f%% of water', value(percent_weight_delivered));
         try
            feval(mfilename, obj, 'water_needs_figure', 0);
         catch ME, report_error(obj, recipient_list, ME);
         end;

         try
            if use_bdata,
               bdata(['insert into ratinfo.rigwater set ratname="', ratname, ...
                  '", dateval="', datestr(now, 'yyyy-mm-dd'), ...
                  '", totalvol=', num2str(value(water_delivered)), ...
                  ', trialvol=',  num2str(delivered_per_hit), ...
                  ', complete=1', ...
                  ', n_rewarded_trials=',num2str(nhits)]);
            end;
         catch ME, report_error(obj, recipient_list, ME);
         end;
      end;
         
      
      
      
%% end_session_report
   case 'end_session_report'
      
      nowtime = str2double(datestr(now, 'HHMM'));
      % If we're in the hours between 1am and 6am, this is an orphaned data
      % file scavenge, don't do the report with the window, email, or
      % bdata.
      if 100 < nowtime && nowtime < 600
         return;
      end;
      pairs = { ...
         'use_bdata',   1   ; ...
      }; parseargs(varargin, pairs);
      
      if WaptorOnOff==1 && isa(obj, 'water')
         [left_ul right_ul] = WaterValvesSection(obj, 'get_water_volumes');
         feval(mfilename, obj, 'evaluate_outcome', ...
            numel(find(hit_history==1)), mean([left_ul right_ul]), 'use_bdata', use_bdata);
      end;

      
%% email_report
   case 'email_report'
      total_water_delivered = varargin{1};
      nhits                 = varargin{2};
      delta_target          = varargin{3};
      ntrials               = n_done_trials;
      hitfrac               = nhits/ntrials;
      
      percent_mass_delivered = 100*total_water_delivered/rat_mass; %#ok<NODEF>

      [experimenter, ratname] = SavingSection(obj, 'get_info');
      mstr = sprintf('%s / %s\n\n', experimenter,  ratname);
      
      if ~isempty(value(message)), %#ok<NODEF>
         mstr = sprintf('%sNote: had this error message: "%s"\n\n', mstr, value(message));
      end;
      
      mstr = sprintf('%sWe have a %.1f%% target and %d grams. With expected hits of %d, we were expecting %d hits. We got\n', ...
         mstr, target-delta_target, value(rat_mass), value(expected_hits), round(value(expected_hits))); %#ok<NODEF>
      mstr = sprintf('%s%.1f%% of weight from %d hits, at %.1f uL/hit, which is %.1f g of water.\n\n', ...
         mstr, percent_mass_delivered, nhits, 1000*total_water_delivered/nhits, total_water_delivered);
      
      % If all the times exist, report them:
      if ~any(isnan([value(init_time) value(end_of_first_trial_time) value(end_time)])), %#ok<NODEF>
         minutes = (end_time - end_of_first_trial_time)*24*60;
         mstr = sprintf('%sProtocol Init time=%s, End of tial 1=%s, End time=%s,\nfor %.2f minutes', mstr, ...
            datestr(value(init_time), 'HH:MM'), ...
            datestr(value(end_of_first_trial_time), 'HH:MM'), ...
            datestr(value(end_time), 'HH:MM'),  minutes);
         mstr = sprintf('%s at %.1f trials per minute and %.1f%% correct.\n\n', mstr, ntrials./minutes, 100*hitfrac);
      end;
      
      if TargetControlOnOff==1,
		  mstr = sprintf('%s(Water target changing by %.2f, from %.2f%% to %.2f%% of body weight.)\n\n', mstr, ...
			  delta_target, target-delta_target, value(target));
	  end;
	  
      if percent_mass_delivered < cutoff,
         mstr = sprintf('%s\n*** WATER DELIVERED IS BELOW THE %d%% CUTOFF ***\n\n', mstr, value(cutoff));
         mstr = sprintf('%sAsking for free water for this rat.\n\n', mstr);
         sstr = sprintf('%s : %.1f%% ALERT!', ratname, percent_mass_delivered);
      else
         mstr = sprintf('%sWater delivered is above the %d%% cutoff, so the rat will not receive more water.\n\n', ...
            mstr, value(cutoff));
         sstr = sprintf('%s : %.1f%% report', ratname, percent_mass_delivered);
      end;
   
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

      [experimenter, ratname] = SavingSection(obj, 'get_info'); %#ok<ASGLU>
      
      if water_the_rat,
         background_color = [1 0 0];
         str = {[ratname ' needs'] 'a full amount of water!!'};
      else
         background_color = [0 1 0];
         str = {sprintf('ONLY %g min of water for %s', value(FreeWaterMinutes), ratname)};
      end;
      
      fig = double(figure('Position', [50, 50, 800, 600]));
      set(fig, 'WindowStyle', 'modal');
      DispParam(obj, 'warningTxt', str, 50, 50, 'position', [50 100 700 450], ...
         'labelfraction', 0.01);
      h = get_ghandle(warningTxt);
      set(h, 'FontSize', 40, 'FontWeight', 'bold', 'BackgroundColor', background_color, ...
         'HorizontalAlignment', 'center');
      
      PushbuttonParam(obj, 'warningBtn', 50, 50, 'position', [50 5 700 90], ... 
         'label', 'OK -- click here to acknowledge', 'FontWeight', 'bold')
      h = get_ghandle(warningBtn);
      set(h, 'FontSize', 30);
      SoloParamHandle(obj, 'warning_clicked', 'value', 0);
      set_callback(warningBtn, {mfilename, 'warning_callback'});

      while(value(warning_clicked)==0), %#ok<NODEF>
         pause(0.1); drawnow;
      end;
      
      delete(warningBtn);
      delete(warningTxt);
      delete(fig);
      
      % nhits = varargin{1};
      

%% warning_callback
   case 'warning_callback'
      warning_clicked.value = 1; %#ok<STRNU>
      
      
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
   %setpref('Internet','E_mail','WaterAdaptorSection@Princeton.EDU');
   set_email_sender
   sendmail(cstr, sstr, mstr);
end;
return;

