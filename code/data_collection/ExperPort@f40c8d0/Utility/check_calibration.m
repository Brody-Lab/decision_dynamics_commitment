%CHECK_CALIBRATION
%   Function to check if valid calibration data is available for the rig
%
%   Written by Chuck Kopec 2011 to work with new Water Calibration system

function lastcalib = check_calibration(rigid,dsp,varargin)

lastcalib = NaN;

if nargin < 1; rigid = bSettings('get','RIGS','Rig_ID'); end
if nargin < 2; dsp = 1; end

if isnan(rigid)
    %If a rig has no ID then it won't have any calibration data in the
    %table so we tell the user this but let them pass.
    if dsp == 1; disp('WARNING: There is no calibration data for Rig ID NaN.'); end
    lastcalib = datestr(now,'yyyy-mm-dd HH:MM:SS');
    return; 
end

%Let's get the last calibration entry date for this rig
try
    DT = bdata(['select dateval from calibration_info_tbl where isvalid=1 and rig_id=',...
        num2str(rigid),' order by dateval desc']);
catch %#ok<CTCH>
    DT = [];
    if dsp == 1; disp('ERROR: Unable to connect to MySQL'); end
end

if isempty(DT)
    if dsp == 1; disp('ERROR: No calibration data for this rig.'); end
    return;
end

%We have a calibration, but we need to check that it's good
[VLV,DSP] = bdata(['select valve, dispense from calibration_info_tbl where',...
    ' isvalid=1 and rig_id=',num2str(rigid),' and dateval like "',DT{1}(1:10),'%"']);

if nargin > 0
    HighTarget = 27;
    LowTarget  = 21;
    Tolerance  = 2;
else
    pname = bSettings('get','GENERAL','Protocols_Directory');
    try
        if bSettings('get','RIGS','bpod') == 1
            load([pname,filesep,'@WaterCalibrationBPod',filesep,'custom_preferences.mat']);
        else
            load([pname,filesep,'@WaterCalibration',filesep,'custom_preferences.mat']);
        end
        HighTarget = custom_prefs.HighTarget;
        LowTarget  = custom_prefs.LowTarget;
        Tolerance  = custom_prefs.Tolerance;
    catch %#ok<CTCH>
        HighTarget = 27;
        LowTarget  = 21;
        Tolerance  = 2;
    end
end

valvenames = {};
if nargin == 0
    if ~isnan(bSettings('get',        'DIOLINES','left1water')) &&...
        isnan(bSettings('get','INACTIVEDIOLINES','left1water'))   
        valvenames{end+1} = 'left1water';   
    end
    if ~isnan(bSettings('get',        'DIOLINES','center1water')) &&...
        isnan(bSettings('get','INACTIVEDIOLINES','center1water')) 
        valvenames{end+1} = 'center1water'; 
    end
    if ~isnan(bSettings('get',        'DIOLINES','right1water')) &&...
        isnan(bSettings('get','INACTIVEDIOLINES','right1water'))
        valvenames{end+1} = 'right1water';  
    end
else
    valvenames{1} = 'left1water';
    valvenames{2} = 'right1water';
end

if isempty(valvenames)
    if dsp == 1; disp('CURIOUS: This rig appears to have no water valves. No need to check calibration data.'); end
    lastcalib = datestr(now,'yyyy-mm-dd HH:MM:SS');
    return;
end

for i = 1:length(valvenames)
    thisvalve = strcmp(VLV,valvenames{i});
    dsp = DSP(thisvalve);
    
    high = sum(dsp > HighTarget-Tolerance & dsp < HighTarget+Tolerance);
    low  = sum(dsp > LowTarget -Tolerance & dsp < LowTarget +Tolerance);
    
    if high == 0
        if dsp == 1; disp(['ERROR: There is no recent calibration point for ',valvenames{i},' HIGH target.']); end
        return
    end
    if low == 0
        if dsp == 1; disp(['ERROR: There is no recent calibration point for ',valvenames{i},' LOW target.']); end
        return
    end
end

%If we make it here, then the last calibration was good
lastcalib = DT{1};

