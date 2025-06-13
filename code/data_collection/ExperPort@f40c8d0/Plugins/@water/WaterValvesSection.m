% [x, y] = WaterValvesSection(obj, action, x, y)
%
% This plugin uses the water calibration table (constructed using
% @WaterCalibrationTable) to automatically translate from a desired water
% delivery amount into a time for which the water valve should be left
% open.
%
% GUI DISPLAY: Puts up two numerical editable fields, Left microliters and
% Right microliters, where the user can insert the desired dispense amount.
% To the right of these will be two display fields showing the
% corresponding times for which the valves should be left open. A title
% will be above all these GUI fields. If the GUIs for the desired amounts
% are edited by a user, (or changed by loading Solo settings), the dispense
% times will be automatically recalculated.
%
% Note that @WaterCalibrationTable figures out dispense times for amounts
% that are within 15% of the calibrated data points that it has; and that
% calibrations have finite lifetimes. If asking for a value that is beyond
% the known range of the calibration table, or the calibration table is out
% of date, a warning window will go up, dispense times will acquire a red
% background, and dispense times will go to a default value of 0.01 (i.e.,
% essentially nothing.) If your dispense times have a red background, that
% means "recalibrate your table before using them" !!
%
% Provides a GUI interface for using a reward ladder, where reward increases with consecutive correct trials.
% Reward delivered is volume*streak_base^streak_len. 
% 
% Adrian Bondy:  There are no optional args to this function which do
% anything anymore. As of Nov. 17, streak length is now
% computed internally, and does not need to be provided as an optional
% input argument. To get this to work, however, this function needs
% access to your hit_history. The easiest way to ensure this is to add the
% line "DeclareGlobals(obj, 'ro_args', 'hit_history');" just after you
% instantiate the hit_history sph in your protocol.
%
%
% PARAMETERS AND RETURNS:
% -----------------------
%
% obj      Default object argument.
%
% action   One of:
%
%   'init' x y
%            Initializes the plugin and sets up the GUI for it. Requires
%            two extra arguments, which will be the (x, y) coords, in
%            pixels, of the lower left hand corner of where this plugin's
%            GUI elements will start to be displayed in the current figure.
%            Returns [x, y], the position of the top left hand corner of
%            the plugin's GUI elements after they have been added to the
%            current figure.
%
%
%   'set_water_amounts'  l_uL r_uL
%            Requires two extra arguments; sets the GUI parameter for left
%            volume to the first of these, l_uL, and sets the GUI
%            parameter for right volume to the second, r_uL; then
%            recalculates the appropriate water dispense times. This action
%            is provided here to allow a command-line way of changing the
%            GUIs for left and right volume; the user can also change them
%            by hand, directly in the GUI.
%
%   'get_water_volumes' Returns two values, l_uL and r_uL, which were the
%            volumes delivered on the just-completed correct trial. This is called
%            by AdLibGUI to update the water table.
%
%   'get_water_times' 
%            Returns two values, LeftTime, and RightTime, which are the
%            water valve opening times that were calculated to correspond
%            to the GUI dispense amounts. This is called when preparing the next trial,
%            to calculate the water times on offer in the next state matrix.
%            Example call:
%              WaterValvesSection(obj,'get_water_times');
%
%   'calculate'
%            Force a recalculation of water dispanse times. This call
%            should normally never be needed by the user, since both
%            command line and GUI modes of changing desired dispense times
%            automaticaly force the recalculation.
%
%   'reinit' Delete all of this section's GUIs and data, and reinit, at the
%            same position on the same figure as the original section GUI
%            was placed.
%


% Written  by Carlos Brody 2007
% Modified by Jeff Erlich  2007
% Modified by Chuck Kopec  2009
% Overhaul by Chuck Kopec  2011 to work with new calibration
% Modified by Adrian Bondy 2017 to correctly report water volume delivered when Streak_base>1

function [x, y] = WaterValvesSection(obj, action, x, y, varargin)

GetSoloFunctionArgs(obj);

if numel(varargin)
    warning('Optional input arguments are now deprecated in WaterValvesSection. Please read updated documentation.');
end

switch action
    case 'init', 
       
        
        
        % Save the figure and the position in the figure where we are going to start adding GUI elements:
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);
        
        ToggleParam(obj, 'WaterShow', 0, x, y, 'OnString', 'WaterExtras Showing', ...
            'OffString', 'WaterExtras Hidden', 'TooltipString', 'Show/Hide Water Valves panel');
        set_callback(WaterShow, {mfilename, 'show_hide'}); %#ok<NODEF> (Defined just above)
        next_row(y);
        
        EditParam(obj,'Left_volume',     24,x,y,'position',[x    y  90 20],'labelfraction',0.7, 'label','Left uL');
        DispParam(obj,'LeftWValveTime',   0,x,y,'position',[x+90 y 110 20],'labelfraction',0.6,'label','Lt Wtr time');
        if ~isnan(bSettings('get','DIOLINES','left1water')); next_row(y);
        else make_invisible(Left_volume); make_invisible(LeftWValveTime); end %#ok<NODEF>
        
        EditParam(obj,'Center_volume',   24,x,y,'position',[x    y  90 20],'labelfraction',0.7, 'label','Center uL');
        DispParam(obj,'CenterWValveTime', 0,x,y,'position',[x+90 y 110 20],'labelfraction',0.6,'label','Ct Wtr time');
        if ~isnan(bSettings('get','DIOLINES','center1water')); next_row(y);
        else make_invisible(Center_volume); make_invisible(CenterWValveTime); end %#ok<NODEF>
        
        EditParam(obj,'Right_volume',    24,x,y,'position',[x    y  90 20],'labelfraction',0.7, 'label','Right uL');
        DispParam(obj,'RightWValveTime',  0,x,y,'position',[x+90 y 110 20],'labelfraction',0.6,'label','Rt Wtr time');
        if ~isnan(bSettings('get','DIOLINES','right1water')); next_row(y);
        else make_invisible(Right_volume); make_invisible(RightWValveTime); end %#ok<NODEF>
        
        
        SoloParamHandle(obj,'RigID',         'value',bSettings('get','RIGS','Rig_ID'));
        SoloParamHandle(obj,'Valves',        'value',{});
        SoloParamHandle(obj,'Dispense',      'value',[]);
        SoloParamHandle(obj,'OpenTime',      'value',[]);
        
        
        
        SubheaderParam(obj,'title',mfilename,x,y); next_row(y, 1.5);
        
        
        
        SoloParamHandle(obj, 'my_xyfig', 'value', [x y double(gcf)]);
        
        
        SoloParamHandle(obj, 'myfig', 'value', double(figure('Position', [ 226   671   233    65], ...
            'closerequestfcn', [mfilename '(' class(obj) ', ''hide'');'], 'MenuBar', 'none', ...
            'Name', mfilename)), 'saveable', 0);
        set(gcf, 'Visible', 'off');
        
        
        nx=10; ny=10;
        DispParam(obj,'Tech',            '',nx,ny,'position',[nx    ny  90 20],'labelfraction',0.7);
        DispParam(obj,'LastCalib',       '',nx,ny,'position',[nx+90 ny 120 20],'labelfraction',0.45);
        
        next_row(ny);
        
        NumeditParam(obj,'Streak_base',1,nx,ny,'position',[nx ny 90 20],'labelfraction',0.75,'label','Streak Base');
        tts=sprintf(['\n The streak mulitplier is streak_base^streak_length.\n  '...
            'If streak base is 1, then water is delivered as normal, since 1^n is 1\n. '...
            'If streak base is >1 then the water delivered will grow exponentially\n'...
            'with # of correct trials in a row.  The streak length is passed as an input \n'...
            'parameter to get_water_times']);
        set_tooltipstring(Streak_base, tts);
        
        NumeditParam(obj,'Streak_max',6,nx,ny,'position',[nx+90 ny 120 20],'labelfraction',0.8,'label','Max Streak Length');
        tts=sprintf(['\n If streak length is >= MaxStreak then water  is watertime*streak_base^maxstreak.']);
        set_tooltipstring(Streak_max, tts);
        
        next_row(ny);
        
        feval(mfilename,obj,'hide');
        feval(mfilename,obj,'get_calibration_info');
        
       parent_fig=my_gui_info(3);
       figure(parent_fig);
       
        if ~exist('hit_history')
            try 
               hit_history = evalin('caller','hit_history');
               DeclareGlobals(obj,'ro_args','hit_history');
            end
        end        
        
    case 'get_calibration_info'
        %% get_calibration_info
        skip_calib = bSettings('get','WATER','skip_water_calib');
        
        if ~isnan(value(RigID))
            try
                DT = bdata(['select dateval from calibration_info_tbl where isvalid=1 and rig_id=',...
                    num2str(value(RigID)),' order by dateval desc']);
                dt = DT{1}(1:10);
                
                [USR DT VLV DSP TM] = bdata(['select initials, dateval, valve, dispense, timeval from',...
                    ' calibration_info_tbl where isvalid=1 and rig_id=',num2str(value(RigID)),...
                    ' and dateval like "',dt,'%"']);
                
                Valves.value    = VLV;
                Dispense.value  = DSP;
                OpenTime.value  = TM;
                Tech.value      = USR{1};
                
                datetemp = DT{1}(1:10); datetemp(datetemp == '-') = ' ';
                LastCalib.value = datetemp;
            catch %#ok<CTCH>
                disp('ERROR: Cannot connect to bdata.calibration_info_tbl. No calibration values received.');
                skip_calib = 1;
            end
        else
            disp('ERROR: This rig has ID NaN. Valve times set to default.');
            skip_calib = 1;
        end
        
        
        if isnan(skip_calib) || skip_calib == 0
            set_callback({Left_volume;Center_volume;Right_volume}, {mfilename, 'calculate'});
            feval(mfilename, obj, 'calculate');
        else
            LeftWValveTime.value   = 0.5;
            CenterWValveTime.value = 0.5;
            RightWValveTime.value  = 0.5;
            
        end
        
        
        
    case 'calculate'
        %% calculate
        valves     = value(Valves);   %#ok<NODEF>
        valvenames = unique(valves);
        dispense   = value(Dispense); %#ok<NODEF>
        opentime   = value(OpenTime); %#ok<NODEF>
        
        for i = 1:length(valvenames)
            OT        = 0.1;
            thisvalve = strcmp(valves,valvenames{i});
            dsp       = dispense(thisvalve);
            ot        = opentime(thisvalve);
            
            if     strcmp(valvenames{i},'left1water');   volume = value(Left_volume);  %#ok<NODEF>
            elseif strcmp(valvenames{i},'center1water'); volume = value(Center_volume);
            elseif strcmp(valvenames{i},'right1water');  volume = value(Right_volume);  %#ok<NODEF>
            else
            end
            
            if length(dsp) >= 2 && length(ot) >= 2
                if length(dsp) > 2 || length(ot) > 2
                    disp('ERROR: Extra calibration points detected. All will be used.');
                end
                p = polyfit(dsp,ot,1);
                OT = (p(1) * volume) + p(2);
            else
                disp('ERROR: Less than 2 calibration points detected. Setting valve open time to default');
            end
            
            if     strcmp(valvenames{i},'left1water');   LeftWValveTime.value   = OT;
            elseif strcmp(valvenames{i},'center1water'); CenterWValveTime.value = OT;
            elseif strcmp(valvenames{i},'right1water');  RightWValveTime.value  = OT;
            else
            end
        end
        
        
        
        
    case 'set_water_amounts'
        %% set_water_amounts
        if nargin < 4, error('Need two extra args for this action'); end;
        Left_volume.value  = x;
        Right_volume.value = y;
        feval(mfilename, obj, 'calculate');
        
        
    case 'get_water_times'
        %% get_water_times on offer for next trial, this should be in your
        %% prepare_next_trial section
        if Streak_base==1
            x = value(LeftWValveTime) ;  %#ok<NODEF>
            y = value(RightWValveTime) ; %#ok<NODEF>
            return
        end
        if ~exist('hit_history')
           warning('WaterValvesSection: Could not get access to hit_history. Streak_base will be treated as 1!!');
           hit_history=0;
        end        
        if n_done_trials
            waterMultiplier = getWaterMultiplier(hit_history,Streak_max,Streak_base);
        else
            waterMultiplier=1;
        end
        
        x = LeftWValveTime * waterMultiplier;  %#ok<NODEF>
        y = RightWValveTime * waterMultiplier; %#ok<NODEF>
        return;
        
    case 'get_left_time'
        %% get_left_time
        %% get_water_times on offer for next trial, this should be in your
        %% prepare_next_trial section
        if Streak_base==1
            x = value(LeftWValveTime) ;  %#ok<NODEF>
            y = value(RightWValveTime) ; %#ok<NODEF>
            return
        end        
        if ~exist('hit_history')
           warning('WaterValvesSection: Could not get access to hit_history. Streak_base will be treated as 1!!');
           hit_history=0;
        end        
        if n_done_trials
            waterMultiplier = getWaterMultiplier(hit_history,Streak_max,Streak_base);
        else
            waterMultiplier=1;
        end
        
        x = LeftWValveTime * waterMultiplier;  %#ok<NODEF>
        return;
        
    case 'get_center_time'
        %% get_center_time
        %% get_water_times on offer for next trial, this should be in your
        %% prepare_next_trial section
        if Streak_base==1
            x = value(LeftWValveTime) ;  %#ok<NODEF>
            y = value(RightWValveTime) ; %#ok<NODEF>
            return
        end        
        if ~exist('hit_history')
           warning('WaterValvesSection: Could not get access to hit_history. Streak_base will be treated as 1!!');
           hit_history=0;
        end        
        if n_done_trials
            waterMultiplier = getWaterMultiplier(hit_history,Streak_max,Streak_base);
        else
            waterMultiplier=1;
        end
        
        x = CenterWValveTime * waterMultiplier;  %#ok<NODEF>
        return;
        
    case 'get_right_time'
        %% get_right_time
        %% get_water_times on offer for next trial, this should be in your
        %% prepare_next_trial section
        if Streak_base==1
            x = value(LeftWValveTime) ;  %#ok<NODEF>
            y = value(RightWValveTime) ; %#ok<NODEF>
            return
        end        
        if ~exist('hit_history')
           warning('WaterValvesSection: Could not get access to hit_history. Streak_base will be treated as 1!!');
           hit_history=0;
        end        
        if n_done_trials
            waterMultiplier = getWaterMultiplier(hit_history,Streak_max,Streak_base);
        else
            waterMultiplier=1;
        end
        
        x = CenterWValveTime * waterMultiplier;  %#ok<NODEF>
        return;
        
        
    case 'get_water_volumes'
        %% get_water_volumes delivered on just-completed trial (to update AdLibGUI)
        if Streak_base==1
            x = value(Left_volume); %#ok<NODEF>
            y = value(Right_volume); %#ok<NODEF>   
            return
        end        
        if ~exist('hit_history')
           warning('WaterValvesSection: Could not get access to hit_history. Streak_base will be treated as 1!!');
           % assume it was correct or you wouldn't be calling me
           hit_history=1;
        end
        if hit_history(end)~=1
            [x,y] = deal(0);
        end
        if n_done_trials<2
            waterMultiplier=1;
        else
            waterMultiplier = getWaterMultiplier(hit_history(1:end-1),Streak_max,Streak_base);
        end
        x = value(Left_volume)*waterMultiplier; %#ok<NODEF>
        y = value(Right_volume)*waterMultiplier; %#ok<NODEF>        
        
        
    case 'reinit',
        %% reinit
        currfig = double(gcf);
        
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
        
        
        %% SHOW HIDE
        
    case 'hide',
        WaterShow.value = 0; set(value(myfig), 'Visible', 'off');
        
    case 'show',
        WaterShow.value = 1; set(value(myfig), 'Visible', 'on');
        
    case 'show_hide',
        if WaterShow == 1, set(value(myfig), 'Visible', 'on'); %#ok<NODEF> (defined by GetSoloFunctionArgs)
        else                   set(value(myfig), 'Visible', 'off');
        end;
        
        
        % ------------------------------------------------------------------
        %%              CLOSE
        % ------------------------------------------------------------------
    case 'close'
        if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)),
           myfignum = value(myfig);
        else
           myfignum = [];
        end;
        delete_sphandle('owner', ['^@' class(obj) '$'], 'fullname', ['^' mfilename '_']);
        if ~isempty(myfignum), delete(myfignum); end;
end;

end

function waterMultiplier = getWaterMultiplier(hits,Streak_max,Streak_base)
    %%hits is really hit history. the last element of hits is the most
    %%recent trial to use to calculate the streak.
    
    %hits=hits(~isnan(hits)); % violations don't count against you
     hits(isnan(hits))=0; % this will count violations as misses for the purposes of the reward ladder
    streak_len=0;
    for i=1:value(Streak_max)
        if length(hits)>=i
            if hits(end-i+1)
                streak_len = streak_len+1;
            else
                break
            end
        else
            break
        end
    end
    waterMultiplier = Streak_base^streak_len;
end
                



