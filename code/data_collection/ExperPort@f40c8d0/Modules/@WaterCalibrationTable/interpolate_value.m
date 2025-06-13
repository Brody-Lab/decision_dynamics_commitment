% [t, errnum, message] = interpolate_value(wt, valve, dispense,
%              {'maxdays_error', 15}, {'maxdistance', 0.15}, {'gui_warning', 0})
%
% Main function for a WaterCalibrationTable! given a table, a
% valvename, and a desired dispense amount, it tries to calculate how
% much time the valve should be open in order to dispense that
% amount. Only locally linear calculations, near entries in the water
% table, are allowed. Anything further away produces a warning message
% and no result.
%
%     This function will crash if no reasonable interpolation can be produced
%       (i.e. if there are no table entries matching the requirements of
%       maxdays_error and maxdistance). Consequently, no error numbers are
%       returned.
%
% PARAMETERS:
% -----------
%
% wt        A WaterCalibrationTable object
%
% valve     A string identifying the name of the valve we're talking
%           about
%
% dispense  The desired dispense volume, in uL.
%
%
% OPTIONAL PARAMETERS:
% --------------------
%
% maxdays_error   Any entries more than this days old are discarded from
%                 the table before any calculation begins. Default is 15,
%                 meaning that if you don't calibrate in 15 days, it is as
%                 if you had no entries at all!
%
% maxdays_warning   If no entries more recent than this days old, a warning
%                   is generated. Default is 10 days. Added by GF 12/19/06.
%
% maxdays_recent  Entries older than this are treated as old for the
%                 purposes of prediction during the calibration process.
%                 Old and new data points are treated differently, with new
%                 points having more bearing, and old points used only when
%                 new points are insufficient for good prediction of a
%                 pulse time for the next calibration round.
%
% maxdistance  Default 0.15. This is the maximum fractional distance
%              away from an entry in the water table that your request
%              can be. For example, say the only entry is for 20 uL,
%              and you ask for 23 uL. That is exactly 20*1.15 = 0.15
%              away, so you will get an answer. If, however, you ask
%              for 24 uL, the answer will be "I don't know-- too far
%              away from known points!"
%
% gui_warning  Default 0. If set to 1, then when there is no
%              well-defined answer (because of maxdays or maxdistance)
%              a little warning window saying so pops up. This window
%              does not halt other processing or anything, it just pops
%              up and quietly stays there until clicked away.
%
% calibrating  Default 0. Set this to 1 when calibrating - i.e. when the
%              estimation of a pulse time to deliver the requested quantity
%              of water is part of a calibration process. When 1, the
%              estimation employs extra logic intended to result in a
%              calibration process involving fewer trials by using new and
%              old data differently.
%
% linearfit_allpoints  Default 0. This generates a linear fit between the
%                      largest 2 entries in dispense volume and extrapolates
%                      the value for dispense from that fit.  If entries exist
%                      that surround the desired dispense value then a linear
%                      interpolation is used.  This is the standard old
%                      behavior before 2009-04-16.  Set to 1 to fit a line
%                      through all good values.  The dispense value is
%                      calculated from this line.  0 volume for 0 time point
%                      is included only if 1 good point exists (you need at
%                      least 2 points to fit a line). Chuck Kopec 2009-04-16
%
% use_mostrecent_day_only  Default 0. Data from all calibration sessions still
%                          in the WaterTable will be considered. This was the
%                          behavior prior to 2009-04-16. Set to 1 to only use
%                          data from the most recent calibration session.
%                          Chuck Kopec 2009-04-16
%
% RETURNS:
% --------
%
% t            How long to open the valve for in order to get the
%              requested amount of water. If an error occurred (see
%              above), this returns as NaN
%
% error        Error number: 1 means no valve with the name you asked
%              for exists in the table.; 2 means maxdays was exceeded;
%              3 means maxdistance was exceeded.
%
% message      A text string that reports the error in human-readable
%              form (if an error occurred, otherwise empty).
%

function [t, errnum, message] = interpolate_value(wt, valve, dispense,varargin)
global fake_rp_box;

[fixed_pulse_time errID] = bSettings('get','PUMPS','fixed_pulse_time');
if ~errID && ~isnan(fixed_pulse_time) && isnumeric(fixed_pulse_time) && fixed_pulse_time > 0,
    t=fixed_pulse_time;
    errnum=0;
    message='Using fixed pulse time from settings file.';
    return;
end;
if ismember(fake_rp_box, [3 4])
    t=0.2;
    errnum=0;
    message='Using fixed pulse time for emulator.';
    return;
end;
pairs = { ...
    'maxdays_error'            61      ; ... %     If all data is older than 31 days, error out. (Data older than this many days is not used.)
    'maxdays_warning'          25      ; ... %     If all data is older than 25 days, generate a GUI warning.
    'maxdistance'              0.15    ; ... %     Data further than 0.15 uL from the target dispense volume is not used.
    'maxdays_recent'           1.1     ; ... %     Data older than 24.2 hours is considered old for the purpose of calibration and is treated differently.
    'use_mostrecent_day_only'  0       ; ... %     If set to 1 only data from the last calibration session will be considered.
    'linearfit_allpoints'      0       ; ... %     0: use old behavior of fitting line to two largest values, 1: fits line through all good points
    'gui_warning'              0       ; ...
    'calibrating'              0       ; ... %     1 during the calibration process.
    'use_low_and_high'         1         ... %     Sundeep (10/22/2009): 0 implies old behavior, 1 implies use of a low and high value to get desired target dispense
    }; parseargs(varargin, pairs);
errnum = 0; message = ''; %#ok<NASGU>

[valves, times, dispenses, dates] = deal_table(wt); %#ok<NASGU>

wt = wt(find(strcmp(valve, valves)));
[valves, times, dispenses, dates] = deal_table(wt);
if isempty(wt),
    t = NaN; errnum = 1;
    message = sprintf('No valve named "%s" found in table. It appears that calibration has never been performed. Please close and calibrate before trying again.', valve); % <~> slightly more informative
    if gui_warning,
        fnum = double(gcf);
        errordlg(message, 'Water Calibration Table Manager');
        error(message); %#ok<SPERR>
        figure(fnum);
    end;
    return;
end;


% if no calibration entries within maxdays_warning, generate warning
% message
if length(find(now - dates <= maxdays_warning)) == 0
    
    most_recent = floor(min(now - dates));
    message = sprintf(['Most recent calibration measurement for %s was ' ...
        '%g days ago. This is only a warning.'], valve, most_recent);
    if gui_warning,
        fnum = double(gcf);
        errordlg(message, 'Water Calibration Table Manager');
        figure(fnum);
    end;
    
end

wt = wt(find(now - dates <= maxdays_error));
[valves, times, dispenses, dates] = deal_table(wt); %#ok<NASGU>
% if no calibration entries within maxdays_error, generate error
% message
if isempty(wt),
    t = NaN;
    errnum = 2;
    message = sprintf(['No calibration measurements for %s less than ' ...
        '%g days old. Please close, calibrate, and try again.'], valve, maxdays_error);
    if gui_warning,
        fnum = double(gcf);
        errordlg(message, 'Water Calibration Table Manager');
        error(message); %#ok<SPERR>
        figure(fnum);
    end;
    return;
end;

if ~use_low_and_high
    wt = wt(find(abs(log(dispenses) - log(dispense)) <= ...
        abs(log(1+maxdistance))));
    [valves, times, dispenses, dates] = deal_table(wt);
    if isempty(wt),
        t = NaN;
        errnum = 3;
        message = sprintf(['No calibration measurements for %s less than ' ...
            'a factor of %g away. Please close, calibrate, and try again.'], valve, maxdistance);
        if gui_warning,
            fnum = double(gcf);
            errordlg(message, 'Water Calibration Table Manager');
            error(message); %#ok<SPERR>
            figure(fnum);
        end;
        return;
    end;
end


if use_mostrecent_day_only == 1
    %Exclude any entries that are not from the last session
    lastdate = datestr(max(dates),29);
    for date_i = 1:length(dates)
        keepentry(date_i) = strcmp(datestr(dates(date_i),29),lastdate); %#ok<AGROW>
    end
    wt = wt(keepentry);
    [valves, times, dispenses, dates] = deal_table(wt);
    if isempty(wt),
        t = NaN;
        errnum = 4;
        message = sprintf(['No calibration measurements for %s less than ' ...
            '%g days old. Please close, calibrate, and try again.'], valve, maxdays_error);
        if gui_warning,
            fnum = double(gcf);
            errordlg(message, 'Water Calibration Table Manager');
            error(message); %#ok<SPERR>
            figure(fnum);
        end;
        return;
    end;
end;


if ~calibrating, %     If we're in the new calibrating state, this is a disruptive measure, so we don't do it.
    %     Add the 0 datapoint (0 valve open time --> 0 dispensed water)
    times = [0 times]; dispenses = [0 dispenses];
    [times, I] = sort(times); dispenses = dispenses(I); %     Sort times and dispenses by time.
end;


%% Sundeep Tuteja: 22nd October, 2009
% The use of the additional argument use_low_and_high prompts the
% function to utilize the new behavior, using a value lower than the
% target dispense, and a value higher than the target dispense to
% compute the valve open time for the target dispense itself.
% At this stage, wt contains only the values that are meant to be
% considered for the purpose of calculation.
if ~calibrating && use_low_and_high == 1
    dispenses = zeros(length(wt), 1);
    dates = zeros(length(wt), 1);
    times = zeros(length(wt), 1);
    valve_names = cell(length(wt), 1);
    
    target_dispense = dispense;
    
    for ctr = 1:length(wt)
        dispenses(ctr) = wt(ctr).dispense;
        dates(ctr) = wt(ctr).date;
        times(ctr) = wt(ctr).time;
        valve_names{ctr} = wt(ctr).valve;
    end
    
    [dates, I] = sort(dates);
    dispenses = dispenses(I);
    times = times(I);
    valve_names = valve_names(I);
    
    lfound = false;
    for ctr = length(wt):-1:1
        if dispenses(ctr) < target_dispense && strcmpi(valve, valve_names{ctr}) && wt(ctr).isvalid
            ldispense = dispenses(ctr);
            ltime = times(ctr);
            lfound = true;
            break;
        end
    end
    
	hfound = false;
    for ctr = length(wt):-1:1
        if dispenses(ctr) > target_dispense && strcmpi(valve, valve_names{ctr}) && wt(ctr).isvalid
            hdispense = dispenses(ctr);
            htime = times(ctr);
            hfound = true;
            break;
        end
    end
    
    if lfound && hfound
        %Points are: (hdispense, htime), and (ldispense, ltime)
        point1 = [hdispense, htime]; point2 = [ldispense, ltime];
    elseif lfound
        point1 = [0, 0]; point2 = [ldispense, ltime];
    elseif hfound
        point1 = [hdispense, htime]; point2 = [0, 0];
    else
		waitfor(errordlg('No valid calibration data is available. Please calibrate and try again.'));
        error('No valid calibration data is available. Please calibrate and try again.');
    end
    
    target_time = interp1([point1(1), point2(1)], [point1(2), point2(2)], target_dispense, 'linear', 'extrap');
    assert(target_time > 0);
    t = target_time;
	fprintf(['\n', datestr(now), ' - ', mfilename, ' - ', num2str(target_dispense), ' microlitres --> ', num2str(target_time), ' seconds (', valve, ')\n']);
    errnum = 0;
    message = '';
    return;
end

%%


if calibrating,
    %     If we're in the midst of calibration, we want to make
    %       predictions about the proper amount of water to deliver that
    %       take into account the recency of data. We want to reduce the
    %       number of necessary calibration rounds, because calibration
    %       is very time-consuming!
    %     The scheme:
    %        - If we have 0  new data, interpolate as usual.
    %        - If we have 2+ new data, ignore old data.     %<~>TODO: Should modify this later so that we don't ignore old data if new data is far from target.
    %        - If we have 1  new data point, use old data to determine
    %            something about the nonlinearity of the
    %            pulse-time-to-pulse-volume relationship and combine
    %            this information with the new data point.
    tNow     = now;
    ixOld    = find(tNow - dates > maxdays_recent); %     The indices of old calibration data. We need these indices for deletion later.
    wtOld    = wt(ixOld); %     A water table w/ only old data.
    wtRecent = wt(tNow - dates <= maxdays_recent);
    if isempty(wtRecent) || isempty(wtOld),
        %     If our values are all new or all old, we can't do anything
        %       special, so we just call interpolate_value again without
        %       the "calibrating" flag set and return the same value
        %       that would be returned if we were not calibrating.
        [t errnum message] = interpolate_value(wt,valve,dispense,varargin{1:end},'calibrating',0); %     The curious will note that "calibrating" is set twice in this call. (The first is in varargin, and sets "calibrating" to 1, or we wouldn't be in this code to begin with.) The second value, 0, overwrites the first so that different code runs.
        return;
    else
        %     If we have both new and old data, there are several
        %       different ways in which to attack the problem of
        %       prediction depending on how much data we have of each
        %       type.
        if size(wtOld,2) < 2 || size(wtRecent,2) > 1,
            %     If we only have 1 old data point, we should just
            %       ignore it, for several reasons. Alternatively, if we
            %       have at least two new data points, we can rely on
            %       them instead and ignore the old data points since
            %       new data points are sufficient for a reasonable
            %       interpolation. (Note: the latter check should be
            %       conditioned on points being in a reasonable range
            %       around the desired dispense volume as well.)
            [t errnum message] = interpolate_value(wtRecent,valve,dispense,varargin{1:end},'calibrating',0); %     The curious will note that "calibrating" is set twice in this call. (The first is in varargin, and sets "calibrating" to 1, or we wouldn't be in this code to begin with.) The second value, 0, overwrites the first so that different code runs.
            
            
            return;
        else
            %     If we have several old data points but only one new
            %       data point, then we will combine new and old
            %       information to produce an estimate. Specifically, we
            %       use old data to judge something about the pulse time
            %       required to release a *minimal* drop of water and
            %       use the more limited new data to try to judge recent
            %       change in the relationship between pulse time and
            %       water release beyond that minimal drop threshold.
            
            %     Extract the two old points nearest the desired
            %       dispense volume, and the single new point.
            [trash ptOld.t ptOld.vol trash]  = deal_table(wtOld); %#ok<NASGU>
            
            filterAboveTargetVol = ptOld.vol - dispense > 0; %     A boolean vector (filter) of size length(ptOld.vol), valued 1 where volumes are above the target.
            filterBelowTargetVol = ~filterAboveTargetVol;
            ptOldAbove.vol       = ptOld.vol(filterAboveTargetVol);
            ptOldAbove.t         = ptOld.t(filterAboveTargetVol);
            ptOldBelow.vol       = ptOld.vol(filterBelowTargetVol);
            [ptOldAbove.vol ix]  = sort(ptOldAbove.vol);
            ptOldAbove.t         = ptOldAbove.t(ix);
            ptOldBelow.t         = ptOld.t(filterBelowTargetVol);
            [ptOldBelow.vol ix]  = sort(ptOldBelow.vol);
            ptOldBelow.t         = ptOldBelow.t(ix);
            
            %     If we have a point above and a point below, we'll use
            %       the line formed by the closest (to the target value)
            %       such pair. If all data points lie to one side of the
            %       target value, we'll just use the line formed by the
            %       two closest, instead.
            if isempty(find(filterAboveTargetVol,1)),
                ptPair.vol           = ptOldBelow.vol(end-1:end);
                ptPair.t             = ptOldBelow.t(end-1:end);
            elseif isempty(find(filterBelowTargetVol,1)),
                ptPair.vol           = ptOldAbove.vol(end-1:end);
                ptPair.t             = ptOldAbove.t(end-1:end);
            else
                ptPair.vol           = [ptOldBelow.vol(end) ptOldAbove.vol(1)];
                ptPair.t             = [ptOldBelow.t(end)   ptOldAbove.t(1)  ];
            end;
            
            %     Now we generate a line from ptPair and determine the
            %       y-intercept (ptOldIntercept).
            %       We then use the line defined by that point and ptNew
            %       below (our new data point) to make a guess at an
            %       ideal pulse time.
            p                    = polyfit(ptPair.t,ptPair.vol,1);
            ptOldIntercept.t     = 0;
            ptOldIntercept.vol   = p(2);
            
            [trash ptNew.t ptNew.vol trash]  = deal_table(wtRecent); %#ok<NASGU>
            if length(ptNew) ~= 1 || length(ptNew.t) ~= 1 || length(ptNew.vol) ~= 1, %     Consistency check
                t = 0.15; errnum = -1; message = 'Programming error. At this point, there should be exactly 1 data point in wtRecent, but this not the case. Please contact a developer.'; error(message); return;
            end;
            
            p                    = polyfit([ptOldIntercept.t ptNew.t], [ptOldIntercept.vol ptNew.vol], 1);
            tNextPulseGuess      = (dispense-p(2)) / p(1); %     literally, (vol to dispense minus vol dispensed for 0 sec pulse) divided by the vol dispensed per second
            
            t                    = tNextPulseGuess;
            errnum               = 0;
            message              = '';
            return;
            
        end; % end if else concerning quantity of old and new info
    end;     % end if else recent/old is empty/nonempty
    
elseif linearfit_allpoints == 0
    %This is the old behavior (before 2009-04-16)
    if dispense<=max(dispenses)
        %     If desired dispense volume is less than highest dispense vol in
        %       table (i.e. there is data on both sides of desired dispense
        %       volume), use interp1 to interpolate appropriate dispense time.
        t = interp1(dispenses, times, dispense);
        message = '';
        return;
    else
        dtimes = diff(times); ddispenses = diff(dispenses);
        dtimes = dtimes(end); ddispenses = ddispenses(end);
        if ddispenses<=0,
            dtimes = diff(times([1 end]));
            ddispenses = diff(dispenses([1 end]));
        end;
        
        t = times(end) + (dtimes/ddispenses)*(dispense - dispenses(end));
        message = '';
    end
    
elseif linearfit_allpoints == 1
    %This is the new behavior (after 2009-04-16)
    if length(times) > 2
        times = times(times ~= 0); dispenses = dispenses(dispenses ~= 0);
    end
    linearfit = polyfit(dispenses,times,1);
    t = (linearfit(1) * dispense) + linearfit(2);
    
end;








end %     End function.

