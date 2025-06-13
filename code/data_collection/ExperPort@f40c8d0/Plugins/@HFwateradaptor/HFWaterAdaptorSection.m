% [] = HFWaterAdaptorSection(obj, action, varargin)
%
%  Plugin that is meant to facilitate keeping track of how much the rat
%  has been drinking in behavioral sessions.  It also allows the experimenter
%  to allow or deprive the rat of 1 hour ad lib water, via a GUI the techs
%  have to interact with. Eventually, there will also be an option to automate
%  whether the animal gets ad lib water.  Algorithms to do this are currently
%  being tested (see Moving Averages algorithm).  The goal is not just to
%  automate ad lib water decisions, but to learn more about the dynamics of
%  water intake, weight loss, trials performed, and ad lib water,
%  particularly in the context of the voluntary head-fixed system (thus,
%  the "HF" in "HFwateradaptor").
%
%  Note: the plugin wateradaptor, which provided a skeleton for this
%  plugin, writes some of the same parameters, such as water volume
%  consumed, to the same bdata table as this plugin.  So it is probably not
%  a good idea to try to use both plugins in your protocol.
%
%  Christine Constantinople, May 2014
%
%
% HOW THE PLUGIN WORKS:
% ---------------------
%
% Arguably the most important parameter in the plugin is the "Force
% Deprive" param.  If this param is toggled on, the animal will not receive
% any ad lib water and the plugin puts up a big red square on the monitor
% saying "No Free Water for this rat: REMOVE SIPPER TUBE!"  The tech must
% click on that window for it to go away.  If the force deprive param is
% toggled off, the plugin puts a big green square saying "[rat] needs free
% water.  ADD SIPPER TUBE!!".  Christine has found that the techs follow
% these instructions well, although in the future, it would be nice to
% eliminate animals that are not getting free water from the WaterMeister.
%
% Two parameters in this plugin are the cutoff and total_water_target
% (mL).  The cutoff is the minimum amount of water we want the rat to get
% during the behavioral session (in % body weight), and it determines the
% total_water_target (mL). Our current IACUC protocol specifies a minimum
% of 3 for the cutoff (May-2014).
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

% Currently, at the end of the session, the plugin evaluates the animal's
% weight in the context of the past several days.  To detect a downward
% trend in noisy data (i.e. weight), the plugin borrows analysis used to
% predict trends in stock prices, exponentially weighted moving averages of
% different window sizes.  When animals are deprived of ad lib water, the
% fast moving average falls below the slow moving average, indicating a
% downward trend.  The differences of these averages is normalized by the
% animal's weight.  This is referred to as the loss_index in the plugin.
% Christine has found that a reasonable threshold for the loss_index is 5%:
% if the animal loses more than that, he is at high risk for going into a
% stressed, starved state.  In contrast, if an animal is given ad lib water
% before he reaches 5%, his weight and performance are stable.  Eventually,
% once the water table is populated in bdata, we can incorporate that data
% into the decision to give ad lib water.
%
% THIS DECISION IS NOT CURRENTLY AUTOMATED. Until we are sure about
% the best algorithm to use, the experimenter has to toggle the force
% deprive param to determine if the rat will get ad lib water.
%
%
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
%        (0) The plugin updates the water consumed on a trial-by-trial
%        basis, by calling the [Lvol, Rvol] = WaterValvesSection(obj,
%        'get_water_volumes');  This means that both changes in delivered
%        volume over trials and differences between left and right volumes
%        are accounted for.
%
%       KNOWN BUGS
%       (1) If the animal is deprived of ad lib water, an email is supposed
%       to be sent to the experimenter.  This is not yet working, so any
%       experimenter using this plugin must be very vigilant in tracking
%       their animals' weight and water.
%
%       (2) It is not yet automated.
%
%       (3) The techs find the GUI easy to work with, but it would be
%       better if animals being deprived of ad lib water were also
%       eliminated from the watermeister that day.
%
%
% CODE YOU NEED TO WRITE:
% -----------------------
%
% FIRST, make sure that "HFwateradaptor" is included as one of the classes
% from which your protocol will inherit properties. This is done in one of
% the top lines in your main protocol m-file. For example, it might read:
%
%   obj = class(struct, mfilename, saveload, water, HFwateradaptor, sqlsummary);
%
% SECOND, in your 'init' code, include the folliwng line, which will add two
% buttons for the water adaptor in your main window, and will make a window
% (defualt closed) for all the water adaptor parameters:
%
%   [x, y] = HFWaterAdaptorSection(obj, 'init', x, y);
%
% THIRD, in your 'trial_completed' code, include the following line,
% which will udpate the amount of water the rat is receiving
%
%   [x, y] = HFWaterAdaptorSection(obj, 'update_water_volume', x, y);
%
% FOURTH, in your 'trial_completed' code, include the following lines:
%    if n_done_trials==1,
%       HFWaterAdaptorSection(obj, 'set_first_trial_time_stamp');
%    end
%
%   (HFWaterAdaptor will use this timestamp to calculate performance time
%   while ignoring any delays that may occur between techs starting the
%   protocol and the rat actually being put into the box and starting
%   behavior).
%
% FIFTH, also in your 'trial_completed' code, include the following lines:
%
%   side = SideSection(obj, 'get_previous_sides');
%   x = side(end);
%   HFWaterAdaptorSection(obj, 'update_water_volume', x);
%
%   This allows left and right water volumes to be counted independently.
%   The varargin (x) MUST BE 'l' or 'r'.
%
% SIXTH, in your 'end_session' code, include the following line:
%
%    HFWaterAdaptorSection(obj, 'evaluate_outcome');
%
%    (This is where future automation would happen.)
%
% LAST, for general cleanliness, in your 'close' code, include the
% following line:
%
%     HFWaterAdaptorSection(obj, 'close');
%
% That's all the code you need to write.
%
%
%
%
% SUGGESTED WAY TO START A RAT ON USING THIS PLUGIN:
% --------------------------------------------------
%
% Because this is a work in progress and not fully automated, YOU MUST
% CHECK YOUR ANIMALS' WATER INTAKE, WEIGHT, AND LOSS_INDEX EVERY DAY. The
% force deprive option should be used with caution, and only when necessary
% (i.e. in the voluntary head-restraint system).
%
% Go over each of the parameters in the plugin, hovering your mouse over
% each one. They all have a tooltip string that should help you understand
% what they are, so you can figure out what value to give them. The default
% values are Carlos'-experience-suggested values.
%
% Put your own email address in the email listbox. Maybe once we've fully
% debugged the system we can take those out and not get so many pesky emails.
%



function [varargout] = HFWaterAdaptorSection(obj, action, varargin)

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
        fig = double(gcf);
        SoloParamHandle(obj, 'my_xyfig', 'value', [x y fig]);
        ToggleParam(obj, 'WaptorOnOff', 0, x, y, 'OnString', 'Waptor ON', ...
            'OffString', 'Waptor OFF', ...
            'TooltipString', sprintf('\nTurn HFWaterAdaptor on or off. If off, the plugin is inactive.'), ...
            'position', [x+100 y 90 20]);
        set_callback(WaptorOnOff, {mfilename, 'onoff'});
        set_callback_on_load(WaptorOnOff, 1);
        ToggleParam(obj, 'WaptorShow', 0, x, y, 'OnString', 'Waptor show', ...
            'OffString', 'Waptor hide', 'TooltipString', 'Show/Hide HFWaterAdaptor panel', ...
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
        set(get_lhandle(recipient_list), 'FontSize', 14);
        y = 200;
        
        SoloParamHandle(obj, 'my_xyfig', 'value', [x y fig]);
        ToggleParam(obj, 'AutomateAdLib', 0, x, y, 'OnString', 'AutomateAdLib', ...
            'OffString', 'NO AutomateAdLib', ...
            'TooltipString', sprintf('\nTurn automation of ad lib decisions on or off. If off, the pluging listens to the force deprive button.'), ...
            'position', [x+100 y 90 20]);
        set_callback(AutomateAdLib, {mfilename, 'AutomateAdLib'});
        set_callback_on_load(AutomateAdLib, 1);
        SoloParamHandle(obj, 'my_xyfig', 'value', [x y double(gcf)]);
        ToggleParam(obj, 'manual_override', 0, x, y, 'position', [x y 90 20], ...
            'OnString', 'Force Deprive', 'OffString', 'No Force Deprive', 'TooltipString', ...
            sprintf(['\nIf ON (black), will force deprive the animal of free water regardless of water intake.\n' ...
            'Note that if the last session volume can''t be found in bdata, then the manual number will be used even if disabled.']));
        set_callback(manual_override, {mfilename, 'manual_override'});
        set_callback_on_load(manual_override, 1);
        next_row(y);
        
        NumeditParam(obj, 'daysinarow', 2, x, y, 'TooltipString', 'Number of days in a row the animal can be deprived of ad lib water even if it drinks less than target water volume');
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
        
        return;
        
        
    case 'set_first_trial_time_stamp',
        end_of_first_trial_time.value = now;
        
        [experimenter, ratname] = SavingSection(obj, 'get_info');
        
        [last_ntrials, last_hits] = ...
            bdata(['select n_done_trials, total_correct ' ...
            'from sessions where ratname = "{S}" order by sessiondate desc limit 1 '], ...
            ratname);
        last_tot_trials.value = last_ntrials;
        last_hitfrac.value = last_hits;
        
        HFWaterAdaptorSection(obj, 'calculate');
        
        
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
        
        if value(hit_history(end,:))==1
            if numel(varargin)~=1 || ~ismember(varargin{1}, {'l' 'r'}),
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
            
            
            [mdate, mass] = bdata(['select date, mass from ratinfo.mass where ratname="{S}" order by date desc limit 1'], ratname);
            
            
            if now-datenum(mdate) >= max_days_wout_weighing,
                report_message(obj, recipient_list, sprintf('Rat has not been weighed in %d days or more.', ...
                    floor(now - datenum(mdate)))); %#ok<NODEF>
            end;
            massdate.value = mdate; %#ok<STRNU>
            masses.value   = mass;
            rat_mass.value = mass; %#ok<STRNU>
            
            %HFWaterAdaptorSection(obj, 'update_water_volume');
            
            total_water_target.value = value(rat_mass)*.03;
            
            
        catch ME, report_error(obj, recipient_list, ME);
            return;
        end;
        
        
        %% evaluate_outcome
    case 'evaluate_outcome'
        
        
        end_time.value = now;
        minutes = (datenum(value(end_time)) - datenum(value(end_of_first_trial_time)))*24*60; %#ok<NODEF>
        ntrials = value(n_done_trials);
        nhits = nansum(hit_history);
        waterconsumed = value(water_delivered);
        
        water_as_percent.value = value(water_delivered)/value(rat_mass)*100;
        
        [experimenter, ratname] = SavingSection(obj, 'get_info'); %#ok<ASGLU>
        %       try
        %           feval(mfilename, obj, 'email_report', waterconsumed, ntrials, nhits, minutes);
        %       catch ME, report_error(obj, recipient_list, ME); %#ok<NODEF>
        %       end;
        %
        
        [mdate, mass] = bdata(['select date, mass from ratinfo.mass where ratname="{S}"'], ratname);
        [mdate, I] = sort(mdate);
        mass = mass(I);
        %% Calculate weight from short and long moving averages
        n = value(longwindow);
        longalpha = n/(n+1);
        s = value(shortwindow);
        shortalpha = s/(s+1); long_m = []; short_m = []; counter = 0;
        if length(mass) > n;
            for t = length(mass)-n+1:length(mass);
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
        
        if value(AutomateAdLib==0)
            if manual_override ==1
                message.value = sprintf('Force Deprived ',ratname,'. ALERT: Delivered %.1f%% of water', value(water_as_percent));
                try
                    feval(mfilename, obj, 'water_needs_figure', 0);
                catch ME, report_error(obj, recipient_list, ME);
                end;
                
                
            elseif manual_override ==0
                message.value = sprintf('Watered ',ratname,'. Earned %.1f%% of water', value(water_as_percent));
                try
                    feval(mfilename, obj, 'water_needs_figure', 1);
                catch ME, report_error(obj, recipient_list, ME);
                end;
            end
            
        elseif value(AutomateAdLib==1)
            if isnan(value(loss_index));
                feval(mfilename, obj, 'water_needs_figure', 1);
            else
                try
                    [wdate, drank, noadlib] = bdata(['select dateval, totalvol, complete from ratinfo.rigwater where ratname="{S}"'], ratname);
                    [wdate, I] = sort(wdate);
                    drank = drank(I);
                    noadlib = noadlib(I);
                    if value(water_as_percent) >= value(cutoff)
                        %Even if the rat drank all his water in the box, if he's
                        %dangerously thin (loss index is too high), we'll give him ad
                        %lib water. 3 is a conservative cutoff for the loss index.
                        if value(loss_index) >= 3
                            feval(mfilename, obj, 'water_needs_figure', 1);
                            %If he is not too thin and drank all his water in the box,
                            %we'll force deprive him
                        elseif value(loss_index) < 3
                            feval(mfilename, obj, 'water_needs_figure', 0);
                        end
                    elseif value(water_as_percent) < value(cutoff)
                        %If he didn't drink enough water AND he's dangerously thin,
                        %we'll definitely give him water!
                        if value(loss_index) >= 3
                            feval(mfilename, obj, 'water_needs_figure', 1);
                        elseif value(loss_index) < 3  %not dangerously thin
                            %if he's gotten adlib water for 1 or 2 days in the past 2 days,
                            %force deprive
                            if sum(noadlib((end-(value(daysinarow)-1)):end)) <= (value(daysinarow)-1)
                                feval(mfilename, obj, 'water_needs_figure', 0);
                                %or if he's been deprived for 2 days in a row (or whatever
                                %you set with the daysinarow param, give ad
                                %lib
                            elseif sum(noadlib((end-(value(daysinarow)-1)):end))>(value(daysinarow)-1)
                                feval(mfilename, obj, 'water_needs_figure', 1);
                            end
                            
                        end
                        
                        
                    end
                catch ME, report_error(obj, recipient_list, ME);
                end
            end
            
        end;
        
        
        
        %% end_session_report
    case 'end_session_report'
        
        try
            %            nowtime = str2double(datestr(now, 'HHMM'));
            %            % If we're in the hours between 1am and 6am, this is an orphaned data
            %            % file scavenge, don't do the report with the window, email, or
            %            % bdata.
            %            if 100 < nowtime && nowtime < 600
            %                return;
            %            end;
            
            ntrials = nansum(hit_history);
            
            if WaptorOnOff==1 && isa(obj, 'water')
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
        
        if manual_override==1
            mstr = sprintf('%s\n*** WAS FORCE-DEPRIVED BY USER BY MANUAL OVERRIDE.  MONITOR WEIGHT/WATER. ***\n\n', mstr);
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
        
        %% If cagemate had different watering instructions and they were already committed, 
        %% we will use those.
        [cagemate] = bdata(['select cagemate from ratinfo.rats where ratname = "{S}"'], ratname);
        if ~isempty(cell2mat(cagemate))
            cagemate_water =  bdata(['select complete from ratinfo.rigwater where ratname = "{S}" and dateval = "{S}"'], cell2mat(cagemate), datestr(now, 'yyyy-mm-dd'));
            if ~isempty(cagemate_water);
                if cagemate_water==1
                    water_the_rat = 0;
                elseif cagemate_water==0
                    water_the_rat = 1;
                end
            %% if cagemate has no instructions yet, we will just check to see if he is too thin; 
            %% if he is, we will water them both
            elseif isempty(cagemate_water)
                [mate_date, mate_mass] = bdata(['select date, mass from ratinfo.mass where ratname="{S}"'], cell2mat(cagemate));
                [mate_date, I] = sort(mate_date);
                mate_mass = mate_mass(I);
                %% Calculate weight from short and long moving averages
                n = value(longwindow);
                longalpha = n/(n+1);
                s = value(shortwindow);
                shortalpha = s/(s+1); long_m = []; short_m = []; counter = 0;
                if length(mate_mass) > n;
                    for t = length(mate_mass)-n+1:length(mate_mass);
                        if counter==0
                            long_m(t) = mate_mass(t);
                            short_m(t) = mate_mass(t);
                        else
                            long_m(t) = longalpha*long_m(t-1) + (1-longalpha)*mate_mass(t);
                            short_m(t) = shortalpha*short_m(t-1) + (1-shortalpha)*mate_mass(t);
                        end
                        counter = counter+1;
                    end
                    long_mov_avg = long_m(end);
                    short__mov_avg = short_m(end);
                    mate_loss_index = ((value(long_mov_avg)- value(short_mov_avg))/mate_mass(end))*100;
                else
                    long_mov_avg = NaN;
                    short_mov_avg = NaN;
                    mate_loss_index = NaN;
                end
                if mate_loss_index >= 3
                    water_the_rat = 1;
                end
            end
        end

        
        if water_the_rat,
            background_color = [0 1 0];
            str = {[ratname ' gets free water.']  'ADD SIPPER TUBE!!'};
            str2 = {['REGRESE EL TUBO DE AGUA'] 'de le su hora'};
        else
            background_color = [1 0 0];
            str = {['No free water for ', ratname,] 'REMOVE SIPPER TUBE!!'};
            str2 = {['Restricion: SACE EL TUBO'] 'no le de agua hoy.'};
        end;
        
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
        SoloParamHandle(obj, 'warning_clicked', 'value', 0);
        set_callback(warningBtn, {mfilename, 'warning_callback'});
        
        while(value(warning_clicked)==0), %#ok<NODEF>
            pause(0.1); drawnow;
        end;
        
        delete(warningBtn);
        delete(warningTxt);
        delete(fig);
        
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
    %setpref('Internet','E_mail','HFWaterAdaptorSection@Princeton.EDU');
    set_email_sender
    sendmail(cstr, sstr, mstr);
end;
return;


