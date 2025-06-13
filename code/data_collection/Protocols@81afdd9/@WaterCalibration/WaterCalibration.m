%WaterCalibration is a protocol desgined to calibrate water delivery to
%behavior boxes.  
%
%Chuck Kopec - October 2011

function [obj] = WaterCalibration(varargin)

obj = class(struct, mfilename);

%---------------------------------------------------------------
%   BEGIN SECTION COMMON TO ALL PROTOCOLS, DO NOT MODIFY
%---------------------------------------------------------------

% If creating an empty object, return without further ado:
if nargin==0 || (nargin==1 && ischar(varargin{1}) && strcmp(varargin{1}, 'empty')),
    return;
end;

if isa(varargin{1}, mfilename), % If first arg is an object of this class itself, we are
    % Most likely responding to a callback from
    % a SoloParamHandle defined in this mfile.
    if length(varargin) < 2 || ~ischar(varargin{2}),
        error(['If called with a "%s" object as first arg, a second arg, a ' ...
            'string specifying the action, is required\n']);
    else action = varargin{2}; varargin = varargin(3:end); %#ok<NASGU>
    end;
else % Ok, regular call with first param being the action string.
    action = varargin{1}; varargin = varargin(2:end); %#ok<NASGU>
end;

GetSoloFunctionArgs(obj);

%---------------------------------------------------------------
%   END OF SECTION COMMON TO ALL PROTOCOLS, MODIFY AFTER THIS LINE
%---------------------------------------------------------------



switch action
    
    case 'init'        
        %Build the main figure
        SoloParamHandle(obj, 'myfig', 'saveable', 0);

        mp = get(0,'MonitorPositions'); fig_w = 650; fig_h = 500;
        mf_pos = [(mp(3)-fig_w)/2 (mp(4)-fig_h)/2 fig_w fig_h];
        
        myfig.value = figure('Position',mf_pos,'color','w');
        set(value(myfig), 'Name', mfilename, 'Tag', mfilename, ...
            'closerequestfcn', [mfilename,'(',class(obj),',''Close_callback'');'], 'MenuBar', 'none','Resize','off');
        
        %Build the buttons
        PushbuttonParam(obj,'Run',      0,0,'position',[  5,395,300,100],'BackgroundColor',[0 1 0]);
        PushbuttonParam(obj,'Close',    0,0,'position',[445,445,100, 50],'BackgroundColor',[1 0 0]); 
        PushbuttonParam(obj,'Reset',    0,0,'position',[445,350,100, 50],'BackgroundColor',[1 0 0]); 
        ToggleParam(obj,'Preferences',0,0,0,'position',[  5,  5,200, 50],'BackgroundColor',[0.8 0.8 0.8],'OnString','Hide Preferences','OffString','Show Preferences'); 
        ToggleParam(obj,'ShowTable',  0,0,0,'position',[345,  5,200, 50],'BackgroundColor',[0.8 0.8 0.8],'OnString','Hide Table',      'OffString','Show Table'); 
        PushbuttonParam(obj,'Flush',    0,0,'position',[225,  5,100, 50],'BackgroundColor',[0   1   1]);
        
        SoloParamHandle(obj,'DoneFlush','value',0);
        SoloParamHandle(obj,'LeftCup',  'value',0);
        SoloParamHandle(obj,'CenterCup','value',0);
        SoloParamHandle(obj,'RightCup', 'value',0);
        
        set(get_ghandle(Run),        'FontSize',50,'enable','off');
        set(get_ghandle(Close),      'FontSize',20);
        set(get_ghandle(Preferences),'FontSize',15); %#ok<NODEF>
        set(get_ghandle(ShowTable),  'FontSize',15); %#ok<NODEF>
        set(get_ghandle(Reset),      'FontSize',15);
        set(get_ghandle(Flush),      'FontSize',15,'enable','off');
        
        set_callback(Run,        {mfilename,'Run_callback'});
        set_callback(Close,      {mfilename,'Close_callback'});
        set_callback(Preferences,{mfilename,'Preferences_callback'});
        set_callback(ShowTable,  {mfilename,'ShowTable_callback'});
        set_callback(Reset,      {mfilename,'Reset_callback'});
        set_callback(Flush,      {mfilename,'Flush_callback'});
        
        
        %Build the status table
        SubheaderParam(obj,'Low',           'Low',       0,0,'position',[30  300 80 30]);
        SubheaderParam(obj,'High',          'High',      0,0,'position',[30  260 80 30]);
        SubheaderParam(obj,'Current',       'Current',   0,0,'position',[30  220 80 30]);
        SubheaderParam(obj,'Left',          'Left',      0,0,'position',[120 340 90 30]);
        SubheaderParam(obj,'LeftLowStat',   'Incomplete',0,0,'position',[120 300 90 30]);
        SubheaderParam(obj,'LeftHighStat',  'Incomplete',0,0,'position',[120 260 90 30]);
        SubheaderParam(obj,'Center',        'Center',    0,0,'position',[220 340 90 30]);
        SubheaderParam(obj,'CenterLowStat', 'Incomplete',0,0,'position',[220 300 90 30]);
        SubheaderParam(obj,'CenterHighStat','Incomplete',0,0,'position',[220 260 90 30]);
        SubheaderParam(obj,'Right',         'Right',     0,0,'position',[320 340 90 30]);
        SubheaderParam(obj,'RightLowStat',  'Incomplete',0,0,'position',[320 300 90 30]);
        SubheaderParam(obj,'RightHighStat', 'Incomplete',0,0,'position',[320 260 90 30]);
        
        NumeditParam(obj,'LeftCurrent',  0.15,0,0,'position',[120 220 90 30],'labelfraction',0.02);
        NumeditParam(obj,'CenterCurrent',0.15,0,0,'position',[220 220 90 30],'labelfraction',0.02);
        NumeditParam(obj,'RightCurrent', 0.15,0,0,'position',[320 220 90 30],'labelfraction',0.02);
        
        SubheaderParam(obj,'Line1', '',0,0,'position',[114 218 2 150]);
        SubheaderParam(obj,'Line2', '',0,0,'position',[214 218 2 150]);
        SubheaderParam(obj,'Line3', '',0,0,'position',[314 218 2 150]);
        SubheaderParam(obj,'Line4', '',0,0,'position',[414 218 2 150]);
        SubheaderParam(obj,'Line5', '',0,0,'position',[30  216 385 2]);
        SubheaderParam(obj,'Line6', '',0,0,'position',[30  254 385 2]);
        SubheaderParam(obj,'Line7', '',0,0,'position',[30  296 385 2]);
        SubheaderParam(obj,'Line8', '',0,0,'position',[30  336 385 2]);
        
        set(get_ghandle(Line1),'BackgroundColor',[0.7 0.7 0.7]);
        set(get_ghandle(Line2),'BackgroundColor',[0.7 0.7 0.7]);
        set(get_ghandle(Line3),'BackgroundColor',[0.7 0.7 0.7]);
        set(get_ghandle(Line4),'BackgroundColor',[0.7 0.7 0.7]);
        set(get_ghandle(Line5),'BackgroundColor',[0.7 0.7 0.7]);
        set(get_ghandle(Line6),'BackgroundColor',[0.7 0.7 0.7]);
        set(get_ghandle(Line7),'BackgroundColor',[0.7 0.7 0.7]);
        set(get_ghandle(Line8),'BackgroundColor',[0.7 0.7 0.7]);
        
        set(get_ghandle(LeftCurrent),   'Fontsize',12,'BackgroundColor',[1 1 1],'position',[120 220 90 30]); %#ok<NODEF>
        set(get_ghandle(CenterCurrent), 'Fontsize',12,'BackgroundColor',[1 1 1],'position',[220 220 90 30]); %#ok<NODEF>
        set(get_ghandle(RightCurrent),  'Fontsize',12,'BackgroundColor',[1 1 1],'position',[320 220 90 30]); %#ok<NODEF>
        
        set(get_ghandle(Low),           'Fontsize',15,'BackgroundColor',[1 1 1]);
        set(get_ghandle(High),          'Fontsize',15,'BackgroundColor',[1 1 1]);
        set(get_ghandle(Current),       'Fontsize',15,'BackgroundColor',[1 1 1]);
        set(get_ghandle(Left),          'Fontsize',15,'BackgroundColor',[1 1 1]);
        set(get_ghandle(Center),        'Fontsize',15,'BackgroundColor',[1 1 1]);
        set(get_ghandle(Right),         'Fontsize',15,'BackgroundColor',[1 1 1]);
        set(get_ghandle(LeftLowStat),   'Fontsize',12,'BackgroundColor',[1 1 1],'ForegroundColor',[1 0 0],'FontWeight','bold');
        set(get_ghandle(LeftHighStat),  'Fontsize',12,'BackgroundColor',[1 1 1],'ForegroundColor',[1 0 0],'FontWeight','bold');
        set(get_ghandle(CenterLowStat), 'Fontsize',12,'BackgroundColor',[1 1 1],'ForegroundColor',[1 0 0],'FontWeight','bold');
        set(get_ghandle(CenterHighStat),'Fontsize',12,'BackgroundColor',[1 1 1],'ForegroundColor',[1 0 0],'FontWeight','bold');
        set(get_ghandle(RightLowStat),  'Fontsize',12,'BackgroundColor',[1 1 1],'ForegroundColor',[1 0 0],'FontWeight','bold');
        set(get_ghandle(RightHighStat), 'Fontsize',12,'BackgroundColor',[1 1 1],'ForegroundColor',[1 0 0],'FontWeight','bold');
        

        %Build the status bar
        SubheaderParam(obj,'Status',      'Status: ',0,0,'position',[30 160 80 30]);
        SubheaderParam(obj,'StatusString',' ',       0,0,'position',[120 70 300 120]);
        
        set(get_ghandle(StatusString),'Fontsize',15,'BackgroundColor',[1 1 1],'HorizontalAlignment','left'); %#ok<NODEF>
        set(get_ghandle(Status),      'Fontsize',15,'BackgroundColor',[1 1 1],'FontWeight','bold');
       
        
        %Build the schedule table
        [rn,ts] = bdata(['select ratname, timeslot from ratinfo.schedule where rig="',...
            num2str(bSettings('get','RIGS','Rig_ID')),'" and date="',datestr(now,'yyyy-mm-dd'),'"']);

        %Just in case a session was deleted from the schedule for a rig
        for i = 1:9
            if sum(ts==i) == 0; ts(end+1) = i; rn{end+1} = ''; end %#ok<AGROW>
        end
        
        SubheaderParam(obj,'Schedule',{['Rig ',num2str(bSettings('get','RIGS','Rig_ID')),' Schedule:'],'',...
            [' 0- 2  ',rn{ts==1}],...
            [' 2- 4  ',rn{ts==2}],...
            [' 4- 6  ',rn{ts==3}],...
            [' 8-10  ',rn{ts==4}],...
            ['10-12  ',rn{ts==5}],...
            ['12- 2  ',rn{ts==6}],...
            [' 4- 6  ',rn{ts==7}],...
            [' 6- 8  ',rn{ts==8}],...
            [' 8-10  ',rn{ts==9}]},...
            0,0,'position',[435 60 210 275]);
        
        set(get_ghandle(Schedule),'Fontsize',15,'BackgroundColor',[1 1 1],'HorizontalAlignment','left','fontname','Courier');
        
        
        %Determine which valves the rig uses and adjust the GUI accordingly
        
        alldio = bSettings('get','DIOLINES','ALL');
        doside = '1';
        
        if sum(strcmp(alldio(:,1),'left2water'))   == 1 &&...
           sum(strcmp(alldio(:,1),'center2water')) == 1 &&...
           sum(strcmp(alldio(:,1),'right2water'))  == 1
            %This is likely a water apartment rig, ask which half is to be
            %calibrated.
            
            answer = questdlg('Which half do you want to calibrate?','Detected 6 valves','Left','Right','Left');
            if strcmp(answer,'Right')
                doside = '2';
            end
        end 
        SoloParamHandle(obj,'DoSide','value',doside);
        
        SoloParamHandle(obj,'Valves','value',[1 1 1]);
        if isnan(bSettings('get','DIOLINES',['left',doside,'water']))
            set(get_ghandle(Left),        'ForegroundColor',[0.7 0.7 0.7]);
            set(get_ghandle(LeftLowStat), 'String',' ','visible','off');
            set(get_ghandle(LeftHighStat),'String',' ','visible','off');
            set(get_ghandle(LeftCurrent), 'Value',[],'visible','off');
            v = value(Valves); v(1) = 0; Valves.value = v; %#ok<NODEF>
        end
        
        if isnan(bSettings('get','DIOLINES',['center',doside,'water']))
            set(get_ghandle(Center),        'ForegroundColor',[0.7 0.7 0.7]);
            set(get_ghandle(CenterLowStat), 'String',' ','visible','off');
            set(get_ghandle(CenterHighStat),'String',' ','visible','off');
            set(get_ghandle(CenterCurrent), 'Value',[],'visible','off');
            v = value(Valves); v(2) = 0; Valves.value = v; 
        end
            
        if isnan(bSettings('get','DIOLINES',['right',doside,'water']))
            set(get_ghandle(Right),        'ForegroundColor',[0.7 0.7 0.7]);
            set(get_ghandle(RightLowStat), 'String',' ','visible','off');
            set(get_ghandle(RightHighStat),'String',' ','visible','off');
            set(get_ghandle(RightCurrent), 'Value',[],'visible','off');
            v = value(Valves); v(3) = 0; Valves.value = v;
        end
        SoloParamHandle(obj,'ValveNames','value',{['left',  doside,'water'],...
                                                  ['center',doside,'water'],...
                                                  ['right', doside,'water']});
        SoloParamHandle(obj,'Target',    'value',2);
        SoloParamHandle(obj,'Weigh',     'value',[0 0 0]);
        SoloParamHandle(obj,'Running',   'value',0);
        v = value(Valves);
        
        try
            [names,initials] = bdata(['select experimenter, initials from ratinfo.contacts where',...
            ' is_alumni=0 order by tech_morning desc, tech_afternoon desc, experimenter asc']);
        catch %#ok<CTCH>
            names = {''};
            initials = {''};
        end
        
        names = ['Select Name';names];

        SubheaderParam(obj,'Rig',     'Rig:',                                  0,0,'position',[310 455 70 35]);
        SubheaderParam(obj,'RigID',   num2str(bSettings('get','RIGS','Rig_ID')),0,0,'position',[380 455 60 35]); 
        MenuParam(obj,'User', names, 1,0,0,'position',[310 405 130 35],'labelfraction',0.02);
        SoloParamHandle(obj,'Initials','value',initials);
        SoloParamHandle(obj,'ActiveUser','value','');
        
        set(get_ghandle(Rig),  'FontSize',20,'BackgroundColor',[1 1 1],'HorizontalAlignment','left');
        set(get_ghandle(RigID),'FontSize',20,'BackgroundColor',[1 1 1],'HorizontalAlignment','left');
        set(get_ghandle(User), 'FontSize',12,'BackgroundColor',[1 1 1]);
        
        set_callback(User,{mfilename,'update_initials'});
        
        
        %Build the Reset Confirm Panel
        rc_fig_w = 400; rc_fig_h = 150;
        rc_pos = [((mp(3)-rc_fig_w)/2)-50 (mp(4)-rc_fig_h)/2 rc_fig_w rc_fig_h];
        SoloParamHandle(obj, 'ResetConfirmPanel', 'value',...
            figure('Position', rc_pos, ...
            'closerequestfcn', [mfilename,'(',class(obj),', ''No_callback'');'], 'MenuBar', 'none', ...
            'Name', 'Confirm Reset','Resize','off'), 'saveable', 0);
        
        PushbuttonParam(obj,'Yes', 0,0,'position',[  5 5   190 40],'BackgroundColor',[1   0   0]);
        PushbuttonParam(obj,'No',  0,0,'position',[205 5   190 40],'BackgroundColor',[0.8 0.8 0.8]);
        SubheaderParam(obj,'ResetConfirm','Are you sure you want to invalidate ALL previous calibration entries for this rig?',...
            0,0,'position',[5 50 400 100]);
        
        set(get_ghandle(Yes),         'FontSize',20,'FontWeight','bold');
        set(get_ghandle(No),          'FontSize',20,'FontWeight','bold');
        set(get_ghandle(ResetConfirm),'FontSize',20,'BackgroundColor',[1 1 1]);
        
        set_callback(Yes,{mfilename,'Yes_callback'});
        set_callback(No, {mfilename,'No_callback'});
        
        set(value(ResetConfirmPanel),'visible','off');
        
        
        %Build the Weight Entry Panel
        we_fig_w = 500; we_fig_h = 200;
        we_pos = [(mp(3)-we_fig_w)/2 ((mp(4)-we_fig_h)/2)+60 we_fig_w we_fig_h];
        SoloParamHandle(obj, 'WeightPanel', 'value',...
            figure('Position', we_pos, ...
            'closerequestfcn', [mfilename,'(',class(obj),', ''Cancel_callback'');'], 'MenuBar', 'none', ...
            'Name', 'Weight Entry Panel','Resize','off'), 'saveable', 0);
        
        PushbuttonParam(obj,'Enter',                 0,0,'position',[  5 5   240 40],'BackgroundColor',[0 1 0]);
        PushbuttonParam(obj,'Cancel',                0,0,'position',[255 5   240 40],'BackgroundColor',[1 0 0]);
        
        NumeditParam(obj,'LeftWeight',           0,  0,0,'position',[5   70  150 30],'labelfraction',0.02,'label','');        
        NumeditParam(obj,'CenterWeight',         0,  0,0,'position',[175 70  150 30],'labelfraction',0.02,'label','');
        NumeditParam(obj,'RightWeight',          0,  0,0,'position',[345 70  150 30],'labelfraction',0.02,'label','');
        
        SubheaderParam(obj,'LeftWeightT',   'Left',  0,0,'position',[5   110 150 30]);
        SubheaderParam(obj,'CenterWeightT', 'Center',0,0,'position',[175 110 150 30]);
        SubheaderParam(obj,'RightWeightT',  'Right', 0,0,'position',[345 110 150 30]);
        SubheaderParam(obj,'WeightInstruct','Please enter empty cup weights:', 0,0,'position',[5 160 490 30]);
        
        set(get_ghandle(Enter),                                  'FontSize',20,'KeyPressFcn',[mfilename,'(',class(obj),', ''Zero_callback'');']);
        set(get_ghandle(Cancel),                                 'FontSize',20,'KeyPressFcn',[mfilename,'(',class(obj),', ''Cancel_callback'');']);
        set(get_ghandle(LeftWeightT),                            'Fontsize',20,'BackgroundColor',[1 1 1]);
        set(get_ghandle(CenterWeightT),                          'Fontsize',20,'BackgroundColor',[1 1 1]);
        set(get_ghandle(RightWeightT),                           'Fontsize',20,'BackgroundColor',[1 1 1]);
        set(get_ghandle(WeightInstruct),                         'Fontsize',16,'BackgroundColor',[1 1 1]); %#ok<NODEF>
        set(get_ghandle(LeftWeight),  'position',[5   70 150 30],'FontSize',20); %#ok<NODEF>
        set(get_ghandle(CenterWeight),'position',[175 70 150 30],'FontSize',20); %#ok<NODEF>
        set(get_ghandle(RightWeight), 'position',[345 70 150 30],'FontSize',20); %#ok<NODEF>
        
        %The first use of the Weight Entry Panel is to zero out the cup
        %weights.  After that use the callback is set to Enter_callback
        set_callback(Enter, {mfilename,'Zero_callback'});
        set_callback(Cancel,{mfilename,'Cancel_callback'});
        
        set(value(WeightPanel),'Visible','off');
        
        
        %Load the custom settings if they exist
        pname = bSettings('get','GENERAL','Protocols_Directory');
        file = [pname,filesep,'@',mfilename,filesep,'custom_preferences.mat'];
        if exist(file,'file')==2; load(file);
        else custom_prefs.PulseNumber     = 150;
             custom_prefs.DefaultDuration = 0.05;
             custom_prefs.LowTarget       = 21;
             custom_prefs.HighTarget      = 27;
             custom_prefs.Tolerance       = 2;
             custom_prefs.InterPulseInt   = 1;
        end
        
        
        %Build the Preference Panel
        pp_fig_w = 250; pp_fig_h = 200;
        pp_pos = [((mp(3)-fig_w)/2)-pp_fig_w-10, (mp(4)-pp_fig_h)/2, pp_fig_w, pp_fig_h];
        pp_pos(pp_pos < 1) = 1;
        SoloParamHandle(obj, 'PreferencePanel', 'value',...
            figure('Position', pp_pos, ...
            'closerequestfcn', [mfilename,'(',class(obj),', ''Preferences_callback'');'], 'MenuBar', 'none', ...
            'Name', 'Preference Panel','Resize','off'), 'saveable', 0);
        
        NumeditParam(obj,'PulseNumber',    custom_prefs.PulseNumber,    0,0,'position',[5   5 250 30],'labelfraction',0.7,'label','Number of Pulses');        
        NumeditParam(obj,'DefaultDuration',custom_prefs.DefaultDuration,0,0,'position',[5  35 250 30],'labelfraction',0.7,'label','Default Duration, s');
        NumeditParam(obj,'LowTarget',      custom_prefs.LowTarget,      0,0,'position',[5  65 250 30],'labelfraction',0.7,'label','Low Target, uL');
        NumeditParam(obj,'HighTarget',     custom_prefs.HighTarget,     0,0,'position',[5  95 250 30],'labelfraction',0.7,'label','High Target, uL');
        NumeditParam(obj,'Tolerance',      custom_prefs.Tolerance,      0,0,'position',[5 125 250 30],'labelfraction',0.7,'label','Tolerance, uL');
        NumeditParam(obj,'InterPulseInt',  custom_prefs.InterPulseInt,  0,0,'position',[5 155 250 30],'labelfraction',0.7,'label','Interpulse Interval, s'); 
        set_callback({PulseNumber,DefaultDuration,LowTarget,HighTarget,Tolerance,InterPulseInt},...
            {mfilename,'update_preference_values'});
        
        c = get(gcf,'children');
        for i=1:length(c); set(c(i),'BackgroundColor',[1 1 1],'FontSize',12); end
        set(value(PreferencePanel), 'Visible', 'off');
         
        
        %Build the Water Table
        pp_fig_w = 550; pp_fig_h = 500;
        wt_pos = [((mp(3)-fig_w)/2)+pp_fig_w+10, (mp(4)-pp_fig_h)/2, pp_fig_w, pp_fig_h];
        if sum(wt_pos([1,3]))>mp(3); wt_pos(1)=mp(3)-wt_pos(3); end
        if sum(wt_pos([2,4]))>mp(4); wt_pos(2)=mp(4)-wt_pos(4); end
        
        SoloParamHandle(obj, 'WaterTablePanel', 'value',...
            figure('Position', wt_pos, ...
            'closerequestfcn', [mfilename,'(',class(obj),', ''ShowTable_callback'');'], 'MenuBar', 'none', ...
            'Name', 'Water Table','Resize','off'), 'saveable', 0);
        
        tbl_h = floor((pp_fig_h - 75 - (21 * 3) - (50 * sum(v == 0))) / sum(v == 1));
        TBL_H(v==1) = tbl_h;
        TBL_H(v==0) = 50;
        
        y = 75;
        ListboxParam(obj,'RightWaterTable', {'Right Table'}, 1,0,0,'position',[5 y 540 TBL_H(1)],'labelfraction',0.02,'FontSize',10,'FontName','Courier'); y=y+TBL_H(1);
        SubheaderParam( obj,'RightTable', 'Right Valve Table', 0,0,'position',[5 y 150 21]);                                                               y=y+21;
        
        ListboxParam(obj,'CenterWaterTable',{'Center Table'},1,0,0,'position',[5 y 540 TBL_H(2)],'labelfraction',0.02,'FontSize',10,'FontName','Courier'); y=y+TBL_H(2);
        SubheaderParam( obj,'CenterTable','Center Valve Table',0,0,'position',[5 y 150 21]);                                                               y=y+21;
        
        ListboxParam(obj,'LeftWaterTable',  {'Left Table'},  1,0,0,'position',[5 y 540 TBL_H(3)],'labelfraction',0.02,'FontSize',10,'FontName','Courier'); y=y+TBL_H(3);
        SubheaderParam( obj,'LeftTable',  'Left Valve Table',  0,0,'position',[5 y 150 21]);                                                               
        
        set_callback({LeftWaterTable,CenterWaterTable,RightWaterTable},{mfilename,'watertable_callback'});
        
        SoloParamHandle(obj,'TableValues',   'value',[1 1 1]);
        SoloParamHandle(obj,'ActiveID',      'value',[]);
        SoloParamHandle(obj,'LeftTableIDs',  'value',[]);
        SoloParamHandle(obj,'CenterTableIDs','value',[]);
        SoloParamHandle(obj,'RightTableIDs', 'value',[]);

        PushbuttonParam(obj,'Validate',                        0,0,'position',[5,  5,250,30],'BackgroundColor',[0 1 0]);
        PushbuttonParam(obj,'Invalidate',                      0,0,'position',[280,5,250,30],'BackgroundColor',[1 0 0]);
        
        ToggleParam(obj,'ShowValid',  0,0,0,'position',[5,  40,250,30],'BackgroundColor',[0.7 0.7 0.7],'OnString','Show All Validities','OffString','Show Valid' );
        ToggleParam(obj,'ShowRecent', 0,0,0,'position',[280,40,250,30],'BackgroundColor',[0.7 0.7 0.7],'OnString','Show All Dates',     'OffString','Show Recent');

        set(get_ghandle(LeftTable),  'Fontsize',10,'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],'FontWeight','bold');
        set(get_ghandle(CenterTable),'Fontsize',10,'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],'FontWeight','bold');
        set(get_ghandle(RightTable), 'Fontsize',10,'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],'FontWeight','bold');
        set(get_ghandle(Validate),   'FontSize',20);
        set(get_ghandle(Invalidate), 'FontSize',20);
        set(get_ghandle(ShowValid),  'Fontsize',15);
        set(get_ghandle(ShowRecent), 'Fontsize',15);
        
        set_callback(Validate,  {mfilename,'Validate_callback'});
        set_callback(Invalidate,{mfilename,'Invalidate_callback'});
        set_callback({ShowValid,ShowRecent}, {mfilename,'update_table'});
        
        WaterCalibration(obj,'update_table');
        set(value(WaterTablePanel), 'Visible', 'off');
        
        
        %Build the video confirm panel
        %We decided that every 2 weeks when techs calibrate each rig they
        %should also do a check that video in each rig is working properly
        
        %With the new video recording software the video should be live on
        %a monitor at the top of each tower.  Techs will now be instructed
        %to check that video feed rather than having to pull up a new video
        %recorder on the current system.
        
%         currdir = pwd;
%         try %#ok<TRYNC>
%             cd(bSettings('get','GENERAL','Main_Code_Directory')); 
%             cd ..
%             cd(['.',filesep,'Rigscripts']);
% 
%             if ispc; system('check_video.bat');
%             else     system('./check_video.sh');
%             end
%         end
%         cd(currdir);

        vc_fig_w = 400; vc_fig_h = 500;
        vc_pos = [((mp(3)-fig_w)/2)-vc_fig_w-10, (mp(4)-vc_fig_h)/2, vc_fig_w, vc_fig_h];
        vc_pos(vc_pos < 1) = 1;
        
        SoloParamHandle(obj, 'VideoConfirmPanel', 'value',...
            figure('Position', vc_pos, ...
            'closerequestfcn', [mfilename,'(',class(obj),', ''No_callback'');'], 'MenuBar', 'none', ...
            'Name', 'Confirm Video','Resize','off'), 'saveable', 0);
        
        SubheaderParam(obj,'VideoConfirmTitle','Please confirm that video is working properly for this rig.',...
            0,0,'position',[5 400 390 100]);
        
        SubheaderParam(obj,'VideoConfirm1','Video working:',0,0,'position',[5 350 190 40]);
        ToggleParam(obj,'Yes1',0,0,0,'position',[205,350,90,45],'BackgroundColor',[0.7 0.7 0.7],'OnString','Yes','OffString','Yes');
        ToggleParam(obj,'No1', 0,0,0,'position',[305,350,90,45],'BackgroundColor',[0.7 0.7 0.7],'OnString','No', 'OffString','No' );
        
        SubheaderParam(obj,'VideoConfirm2','Aimed correctly:',0,0,'position',[5 300 190 40]);
        ToggleParam(obj,'Yes2',0,0,0,'position',[205,300,90,45],'BackgroundColor',[0.7 0.7 0.7],'OnString','Yes','OffString','Yes');
        ToggleParam(obj,'No2', 0,0,0,'position',[305,300,90,45],'BackgroundColor',[0.7 0.7 0.7],'OnString','No', 'OffString','No' );
        
        SubheaderParam(obj,'VideoConfirm3','Image focused:',0,0,'position',[5 250 190 40]);
        ToggleParam(obj,'Yes3',0,0,0,'position',[205,250,90,45],'BackgroundColor',[0.7 0.7 0.7],'OnString','Yes','OffString','Yes');
        ToggleParam(obj,'No3', 0,0,0,'position',[305,250,90,45],'BackgroundColor',[0.7 0.7 0.7],'OnString','No', 'OffString','No' );
        
        SubheaderParam(obj,'VideoConfirm4','Lid cleaned:',0,0,'position',[5 200 190 40]);
        ToggleParam(obj,'Yes4',0,0,0,'position',[205,200,90,45],'BackgroundColor',[0.7 0.7 0.7],'OnString','Yes','OffString','Yes');
        ToggleParam(obj,'No4', 0,0,0,'position',[305,200,90,45],'BackgroundColor',[0.7 0.7 0.7],'OnString','No', 'OffString','No' );
        
        PushbuttonParam(obj,'Submit',0,0,'position',[205,150,190,45],'BackgroundColor',[0.7 0.7 0.7]);
        
        SubheaderParam(obj,'Comments','Comments:',0,0,'position',[5 130 200 40]);
        EditParam(obj,'VideoComments','',0,0,'position',[5 5 390 125],'labelfraction',0.01);

        set(get_ghandle(VideoConfirmTitle),'FontSize',22,'BackgroundColor',[1 1 1],'HorizontalAlignment','left');
        set(get_ghandle(VideoConfirm1),    'FontSize',18,'BackgroundColor',[1 1 1],'HorizontalAlignment','right');
        set(get_ghandle(VideoConfirm2),    'FontSize',18,'BackgroundColor',[1 1 1],'HorizontalAlignment','right');
        set(get_ghandle(VideoConfirm3),    'FontSize',18,'BackgroundColor',[1 1 1],'HorizontalAlignment','right');
        set(get_ghandle(VideoConfirm4),    'FontSize',18,'BackgroundColor',[1 1 1],'HorizontalAlignment','right');
        
        set(get_ghandle(Yes1),             'FontSize',20,'FontWeight','bold'); %#ok<NODEF>
        set(get_ghandle(Yes2),             'FontSize',20,'FontWeight','bold'); %#ok<NODEF>
        set(get_ghandle(Yes3),             'FontSize',20,'FontWeight','bold'); %#ok<NODEF>
        set(get_ghandle(Yes4),             'FontSize',20,'FontWeight','bold'); %#ok<NODEF>
        
        set(get_ghandle(No1),              'FontSize',20,'FontWeight','bold'); %#ok<NODEF>
        set(get_ghandle(No2),              'FontSize',20,'FontWeight','bold'); %#ok<NODEF>
        set(get_ghandle(No3),              'FontSize',20,'FontWeight','bold'); %#ok<NODEF>
        set(get_ghandle(No4),              'FontSize',20,'FontWeight','bold'); %#ok<NODEF>
        
        set(get_ghandle(Submit),           'FontSize',24,'FontWeight','bold','enable','off');
        
        set(get_ghandle(Comments),         'FontSize',18,'BackgroundColor',[1 1 1],'HorizontalAlignment','left');
        set(get_ghandle(VideoComments),    'FontSize',14,'BackgroundColor',[1 1 1],'HorizontalAlignment','left','max',2);
        
        set_callback({Yes1,Yes2,Yes3,Yes4,No1,No2,No3,No4},{mfilename,'Video_YesNo_callback'});
        set_callback(Submit,{mfilename,'Video_Submit_callback'});
        
        SoloParamHandle(obj,'YesNoState', 'value',[0 0 0 0]);
        SoloParamHandle(obj,'IsSubmitted','value',0);
        
        %Make the Main GUI background white
        c = get(value(myfig),'children');
        for i=1:length(c); 
            t=get(c(i),'type'); 
            if strcmp(t,'uipanel'); set(c(i),'backgroundcolor',[1 1 1]); end
        end
        
        %Make the Water Table Panel background white
        c = get(value(WaterTablePanel),'children');
        for i=1:length(c); 
            t=get(c(i),'type'); 
            if strcmp(t,'uipanel'); set(c(i),'backgroundcolor',[1 1 1]); end
        end
        
        %Make the Weight Panel background white
        c = get(value(WeightPanel),'children');
        for i=1:length(c); 
            t=get(c(i),'type'); 
            if strcmp(t,'uipanel'); set(c(i),'backgroundcolor',[1 1 1]); end
        end
        
        %Make the Reset Confirm Panel background white
        c = get(value(ResetConfirmPanel),'children');
        for i=1:length(c); 
            t=get(c(i),'type'); 
            if strcmp(t,'uipanel'); set(c(i),'backgroundcolor',[1 1 1]); end
        end
        
        %Make the Video Confirm Panel background white
        c = get(value(VideoConfirmPanel),'children');
        for i=1:length(c); 
            t=get(c(i),'type'); 
            if strcmp(t,'uipanel'); set(c(i),'backgroundcolor',[1 1 1]); end
        end
        
        %Now that everything is built, let's update the estimate of the
        %valve open times for our first run.
        WaterCalibration(obj,'update_estimate');
        
        %Before finalizing the GUI, let's get the user's initials
        StatusString.value = 'Waiting for the user to select their name.';
        set(get_ghandle(StatusString),'FontSize',20,'ForegroundColor',[0 0 0],'FontWeight','bold');
        set(get_ghandle(Run),'enable','off');
        
        %Now just to make the dispatcher bypass lines work we need to send
        %any old state machine.
        WaterCalibration(obj,'send_empty_state_machine');
        
        %Finally let's turn on the LEDs to help the tech inset tube
        %extenders
        diolist=[]; 
        %alldio=bSettings('get','DIOLINES','ALL');
        for di=1:size(alldio,1)
            if ~isempty(strfind(alldio{di,1},'led')) && ~isnan(alldio{di,2})
                diolist=[diolist alldio{di,2}]; %#ok<AGROW>
            end
        end
        
        %Take the log of the channel values to get the channel numbers that 
        %dispatcher needs to toggle bypass lines.
        diolist = log2(diolist);
		
        %Call dispatcher to toggle on the LEDs
        pause(0.1);
        for c = 1:length(diolist)
            dispatcher('toggle_bypass',diolist(c));
            pause(0.1);
        end  
        
    
    case 'Video_YesNo_callback'
        %Here we control the color of the yes and no buttons in the video
        %confirm panel
        
        YN = value(YesNoState); %#ok<NODEF>
        if value(Yes1) == 1 && YN(1) ~= 1; YN(1) = 1; No1.value = 0; end %#ok<NODEF>
        if value(Yes2) == 1 && YN(2) ~= 1; YN(2) = 1; No2.value = 0; end %#ok<NODEF>
        if value(Yes3) == 1 && YN(3) ~= 1; YN(3) = 1; No3.value = 0; end %#ok<NODEF>
        if value(Yes4) == 1 && YN(4) ~= 1; YN(4) = 1; No4.value = 0; end %#ok<NODEF>
        
        if value(No1) == 1 && YN(1) ~= 2; YN(1) = 2; Yes1.value = 0; end
        if value(No2) == 1 && YN(2) ~= 2; YN(2) = 2; Yes2.value = 0; end
        if value(No3) == 1 && YN(3) ~= 2; YN(3) = 2; Yes3.value = 0; end
        if value(No4) == 1 && YN(4) ~= 2; YN(4) = 2; Yes4.value = 0; end
        
        if value(Yes1) == 0; set(get_ghandle(Yes2),'enable','off','BackgroundColor',[0.7 0.7 0.7],'ForegroundColor',[0.3 0.3 0.3]); Yes2.value = 0; YN(2) = 0;
                             set(get_ghandle(Yes3),'enable','off','BackgroundColor',[0.7 0.7 0.7],'ForegroundColor',[0.3 0.3 0.3]); Yes3.value = 0; YN(3) = 0;
                             set(get_ghandle(No2), 'enable','off','BackgroundColor',[0.7 0.7 0.7],'ForegroundColor',[0.3 0.3 0.3]); No2.value  = 0;
                             set(get_ghandle(No3), 'enable','off','BackgroundColor',[0.7 0.7 0.7],'ForegroundColor',[0.3 0.3 0.3]); No3.value  = 0;
        else                 set(get_ghandle(Yes2),'enable','on');
                             set(get_ghandle(Yes3),'enable','on');
                             set(get_ghandle(No2), 'enable','on');
                             set(get_ghandle(No3), 'enable','on');
        end
        
        if value(Yes1) == 0 && value(No1) == 0; YN(1) = 0; end
        if value(Yes2) == 0 && value(No2) == 0; YN(2) = 0; end
        if value(Yes3) == 0 && value(No3) == 0; YN(3) = 0; end
        if value(Yes4) == 0 && value(No4) == 0; YN(4) = 0; end
        
        if (YN(1) == 1 && all(YN ~= 0) && YN(4) ~= 2) || (YN(1) == 2 && YN(4) == 1); set(get_ghandle(Submit),'enable','on', 'BackgroundColor',[0   1   0],  'ForegroundColor',[0   0   0]);
        else                                                                         set(get_ghandle(Submit),'enable','off','BackgroundColor',[0.7 0.7 0.7],'ForegroundColor',[0.3 0.3 0.3]);
        end
        
        if YN(4) == 2; set(get_ghandle(VideoConfirmTitle),'string','Please Clean the Lid.');
        else           set(get_ghandle(VideoConfirmTitle),'string','Please confirm that video is working properly on this rig.');
        end
        
        YesNoState.value = YN;
        
        if value(Yes1) == 1; set(get_ghandle(Yes1),'BackgroundColor',[0 1 0],'ForegroundColor',[0 0 0]); else set(get_ghandle(Yes1),'BackgroundColor',[0.7 0.7 0.7],'ForegroundColor',[0.3 0.3 0.3]); end
        if value(Yes2) == 1; set(get_ghandle(Yes2),'BackgroundColor',[0 1 0],'ForegroundColor',[0 0 0]); else set(get_ghandle(Yes2),'BackgroundColor',[0.7 0.7 0.7],'ForegroundColor',[0.3 0.3 0.3]); end
        if value(Yes3) == 1; set(get_ghandle(Yes3),'BackgroundColor',[0 1 0],'ForegroundColor',[0 0 0]); else set(get_ghandle(Yes3),'BackgroundColor',[0.7 0.7 0.7],'ForegroundColor',[0.3 0.3 0.3]); end
        if value(Yes4) == 1; set(get_ghandle(Yes4),'BackgroundColor',[0 1 0],'ForegroundColor',[0 0 0]); else set(get_ghandle(Yes4),'BackgroundColor',[0.7 0.7 0.7],'ForegroundColor',[0.3 0.3 0.3]); end
        
        if value(No1) == 1;  set(get_ghandle(No1), 'BackgroundColor',[1 0 0],'ForegroundColor',[0 0 0]); else set(get_ghandle(No1), 'BackgroundColor',[0.7 0.7 0.7],'ForegroundColor',[0.3 0.3 0.3]); end
        if value(No2) == 1;  set(get_ghandle(No2), 'BackgroundColor',[1 0 0],'ForegroundColor',[0 0 0]); else set(get_ghandle(No2), 'BackgroundColor',[0.7 0.7 0.7],'ForegroundColor',[0.3 0.3 0.3]); end
        if value(No3) == 1;  set(get_ghandle(No3), 'BackgroundColor',[1 0 0],'ForegroundColor',[0 0 0]); else set(get_ghandle(No3), 'BackgroundColor',[0.7 0.7 0.7],'ForegroundColor',[0.3 0.3 0.3]); end
        if value(No4) == 1;  set(get_ghandle(No4), 'BackgroundColor',[1 0 0],'ForegroundColor',[0 0 0]); else set(get_ghandle(No4), 'BackgroundColor',[0.7 0.7 0.7],'ForegroundColor',[0.3 0.3 0.3]); end
        
        
    case 'Video_Submit_callback'
        %Here we submit the user answers and comments contained in the
        %video confirm panel to the MySQL table 
        
        YN = value(YesNoState); %#ok<NODEF>
        if any(YN == 2)
            %There was a "No" answer so we need to send the lab manager an
            %email about what's wrong with the rig
            
            %setpref('Internet','SMTP_Server','brodyfs2.princeton.edu');
            %setpref('Internet','E_mail','VideoCheck@princeton.edu');
            set_email_sender
            
            message = cell(0);
            message{1} = [value(User),' has reported a problem with video on rig ',num2str(value(RigID))];
            message{2} = ' ';
            if YN(1) == 1; message{3}     = '  Video Working: yes'; elseif YN(1) == 2; message{3}     = '  Video Working: NO'; end
            if YN(2) == 1; message{end+1} = 'Aimed Correctly: yes'; elseif YN(2) == 2; message{end+1} = 'Aimed Correctly: NO'; end
            if YN(3) == 1; message{end+1} = '  Image Focused: yes'; elseif YN(3) == 2; message{end+1} = '  Image Focused: NO'; end
            if YN(4) == 1; message{end+1} = '      Lid Clean: yes'; elseif YN(4) == 2; message{end+1} = '      Lid Clean: NO'; end
            message{end+1} = ' ';
            message{end+1} = 'Comments:';
            message{end+1} = value(VideoComments);
            
            for i = 1:length(message); disp(message{i}); end
            
            LM = bdata('select email from ratinfo.contacts where is_alumni=0 and lab_manager=1'); 
            for i = 1:length(LM)
                sendmail(LM{i},['Video Problem Rig ',num2str(value(RigID))],message);
            end
        end
        
        user = bdata(['select initials from ratinfo.contacts where experimenter="',value(User),'"']);
        if isempty(user); user{1} = ''; end
        
        comments = value(VideoComments);
        comments(comments == '''') = '';
        bdata(['insert into ratinfo.rigvideo set rig_id=',num2str(value(RigID)),', initials="',user{1},...
            '", dateval="',datestr(now,'yyyy-mm-dd HH:MM:SS'),'", comments="',comments,...
            '", video=',num2str(YN(1)),', aimed=',num2str(YN(2)),', focused=',num2str(YN(3)),', lid=',num2str(YN(4))]);
          
        set(value(VideoConfirmPanel),'visible','off');
        
        
        
    case 'send_empty_state_machine'
        state_machine_server = bSettings('get','RIGS','state_machine_server');
        
        server_slot = bSettings('get','RIGS','server_slot');
        if isnan(server_slot); server_slot = 0; end
        
        card_slot = bSettings('get', 'RIGS', 'card_slot');
        if isnan(card_slot); card_slot = 0; end
        
        sm = RTLSM2(state_machine_server, 3333,server_slot);
        sm = Initialize(sm);
        
        [inL,outL] = MachinesSection(dispatcher,'determine_io_maps');
        
        sma = StateMachineAssembler('full_trial_structure');
        sma = add_state(sma,'name','vapid_state_in_vapid_matrix');
        
        send(sma,sm,'run_trial_asap',0,'input_lines',inL,'dout_lines',outL,'sound_card_slot', int2str(card_slot));
        
        
        
    case 'Flush_callback'
        %Here we open the valves to flush out any air bubble and fill the
        %tube extenders with water
        DoneFlush.value = 1; %#ok<STRNU>
        StatusString.value = 'Flushing the valves.  Please wait...';
        set(get_ghandle(StatusString),'FontSize',20,'ForegroundColor',[0 0.7 0.7],'FontWeight','bold');
        
        %Let's only flush the valves we are currently calibrating, some
        %rigs have 6 valves and we're either opening first or last 3.
        VN = value(ValveNames);
        
        diolist=[]; 
        alldio=bSettings('get','DIOLINES','ALL');
        for di=1:size(alldio,1)
            for vn = 1:numel(VN)
                if strcmp(alldio{di,1},VN{vn})==1 && ~isnan(alldio{di,2})
                    diolist=[diolist alldio{di,2}]; %#ok<AGROW>
                end
            end
        end
        
        %Take the log of the channel values to get the channel numbers that 
        %dispatcher needs to toggle bypass lines.
        diolist = log2(diolist);
		
        %Call dispatcher to toggle the water valves in succession
        pause(0.1);
        for c = 1:length(diolist)
            dispatcher('toggle_bypass',diolist(c));
            pause(5);
            dispatcher('toggle_bypass',diolist(c));
            pause(0.1);
        end    
        
        WaterCalibration(obj,'update_estimate');
        
        if all([value(LeftCup),value(CenterCup),value(RightCup)] == 0) %#ok<NODEF>
            WaterCalibration(obj,'empty_cup_weights');
        end
        
    case 'empty_cup_weights'
        
        StatusString.value = 'Make sure cups as empty and dry, and enter their weights.';
        set(get_ghandle(StatusString),'FontSize',18,'ForegroundColor',[0 0 0],'FontWeight','bold');
        
        %Before bringing up the Weight Entry Panel, let's disable the edit
        %windows for any valves the user does not need to enter weights
        %for
        weigh = value(Weigh); %#ok<NODEF>
        if weigh(1) == 1; set(get_ghandle(LeftWeight),  'enable','on');  set(get_ghandle(LeftWeightT),  'ForegroundColor',[0   0   0]); %#ok<NODEF>
        else              set(get_ghandle(LeftWeight),  'enable','off'); set(get_ghandle(LeftWeightT),  'ForegroundColor',[0.8 0.8 0.8]); %#ok<NODEF>
        end
        if weigh(2) == 1; set(get_ghandle(CenterWeight),'enable','on');  set(get_ghandle(CenterWeightT),'ForegroundColor',[0   0   0]); %#ok<NODEF>
        else              set(get_ghandle(CenterWeight),'enable','off'); set(get_ghandle(CenterWeightT),'ForegroundColor',[0.8 0.8 0.8]); %#ok<NODEF>
        end
        if weigh(3) == 1; set(get_ghandle(RightWeight), 'enable','on');  set(get_ghandle(RightWeightT), 'ForegroundColor',[0   0   0]); %#ok<NODEF>
        else              set(get_ghandle(RightWeight), 'enable','off'); set(get_ghandle(RightWeightT), 'ForegroundColor',[0.8 0.8 0.8]); %#ok<NODEF>
        end
        
        %Now we can turn the panel on
        set(value(WeightPanel),'Visible','on');
        
        %Let's make the first enables edit window active so the user
        %doesn't need to mouse over and click on it.
        
        if     weigh(1) == 1; uicontrol(get_ghandle(LeftWeight));
        elseif weigh(2) == 1; uicontrol(get_ghandle(CenterWeight));
        elseif weigh(3) == 1; uicontrol(get_ghandle(RightWeight));
        end
        
        
        
    case 'update_initials'
        names = get(get_ghandle(User),'string');
        activename = get(get_ghandle(User),'value');
        initials = value(Initials);
        if strcmp(names{1},'Select Name')
            names = names(2:end);
            activename = activename - 1;
            
            set(get_ghandle(User),'string',names,'value',activename,'FontSize',20);
        end
        ActiveUser.value = initials{activename}; %#ok<STRNU>
        
        %Now that we have new user, let's upadte our estimates.
        WaterCalibration(obj,'update_estimate');
        
        if value(DoneFlush) == 0 %#ok<NODEF>
            StatusString.value = ['Please insert the tube extenders, then click "Flush"',...
                ' to flush the valves before running the first cycle.'];
            set(get_ghandle(StatusString),'FontSize',16,'ForegroundColor',[0 0 0],'FontWeight','bold');
            set(get_ghandle(Run),'enable','off');
        end
        
        set(get_ghandle(Flush),'enable','on');
        
    case 'Cancel_callback'
        %The user doesn't want to enter the weights from the current cycle.
        %Soall we need to do is make it invisible again.
        set(value(WeightPanel),'visible','off');
        
        LeftWeight.value   = 0; %#ok<STRNU>
        CenterWeight.value = 0; %#ok<STRNU>
        RightWeight.value  = 0; %#ok<STRNU>
        
        
    case 'Zero_callback'
        %The original callback for the Enter button, only used at the start
        %of calibration to enter the empty cup weights
        
        WeightInstruct.value = 'Please enter empty cup weights:';
        %set(get_ghandle(value(WeightInstruct)),'string','Please enter empty cup weights:');
        
        
        LeftCup.value   = value(LeftWeight); %#ok<NODEF>
        CenterCup.value = value(CenterWeight); %#ok<NODEF>
        RightCup.value  = value(RightWeight); %#ok<NODEF>
        
        set(get_ghandle(Enter),'KeyPressFcn',[mfilename,'(',class(obj),', ''Enter_callback'');']);
        set_callback(Enter, {mfilename,'Enter_callback'});
        
        LeftWeight.value   = 0;
        CenterWeight.value = 0;
        RightWeight.value  = 0;
        
        set(value(WeightPanel),'visible','off');
        set(get_ghandle(Run),'enable','on');
        
        StatusString.value = [value(User),', Water Calibration is ready for it''s first cycle. Make sure the rig is ready, then click "Run".'];
        set(get_ghandle(StatusString),'FontSize',14,'ForegroundColor',[0 0 0],'FontWeight','normal');
        
        WeightInstruct.value = 'Please enter the cup weights from each valve:'; %#ok<STRNU>
        %set(get_ghandle(value(WeightInstruct)),'string','Please enter the cup weights from each valve:');
        
        
    case 'Enter_callback'
        %Take the weights entered by the user, calculate the volume
        %dispensed per drop, and add that as a line to the MySQL table
        
        d = zeros(1,3);
        
        weigh = value(Weigh); %#ok<NODEF>
        if weigh(1) == 1; d(1) = round(((value(LeftWeight)   - value(LeftCup))   / value(PulseNumber)) * 1e5) / 1e2; end %#ok<NODEF>
        if weigh(2) == 1; d(2) = round(((value(CenterWeight) - value(CenterCup)) / value(PulseNumber)) * 1e5) / 1e2; end %#ok<NODEF>
        if weigh(3) == 1; d(3) = round(((value(RightWeight)  - value(RightCup))  / value(PulseNumber)) * 1e5) / 1e2; end %#ok<NODEF>
        
        %Now that we have the dispense volumes, clear the panel and make it
        %invisible.
        LeftWeight.value   = 0;
        CenterWeight.value = 0;
        RightWeight.value  = 0;
        set(value(WeightPanel),'visible','off');
        
        %Let's add the entries to the MySQL Table
        rigid = str2num(value(RigID)); %#ok<ST2NM>
        valves = value(ValveNames);
        tgt    = value(Target);  %#ok<NODEF>
        weigh  = value(Weigh);
        user   = value(ActiveUser); %#ok<NODEF>
        
        if     tgt == 2; tgt='HIGH'; 
        elseif tgt == 1; tgt='LOW'; 
        else return; 
        end
        
        if ~isnan(rigid)
            
            for i = 1:length(valves)
                if weigh(i) == 0; continue; end
                if     i == 1; opentime = value(LeftCurrent); %#ok<NODEF>
                elseif i == 2; opentime = value(CenterCurrent); %#ok<NODEF>
                elseif i == 3; opentime = value(RightCurrent); %#ok<NODEF>
                end
                
                bdata(['insert into calibration_info_tbl set rig_id=',num2str(rigid),', initials="',user,...
                    '", dateval="',datestr(now,'yyyy-mm-dd HH:MM:SS'),'", valve="',valves{i},...
                    '", timeval=',num2str(opentime),', dispense=',num2str(d(i)),', isvalid=1, target="',tgt,'"']);
            end
            
        end
        
        %Now that we have new data, let's update our estimates.
        WaterCalibration(obj,'update_estimate');
        WaterCalibration(obj,'update_table');
        
        
        
    case 'disable_buttons'
        %This disables all the buttons, edit windows, and tables in the GUI
        set(get_ghandle(Run),             'enable','off');
        set(get_ghandle(Close),           'enable','off');
        set(get_ghandle(Reset),           'enable','off');
        set(get_ghandle(Preferences),     'enable','off'); %#ok<NODEF>
        set(get_ghandle(ShowTable),       'enable','off'); %#ok<NODEF>
        set(get_ghandle(Validate),        'enable','off');
        set(get_ghandle(Invalidate),      'enable','off');
        set(get_ghandle(ShowValid),       'enable','off');
        set(get_ghandle(ShowRecent),      'enable','off');
        set(get_ghandle(LeftWaterTable),  'enable','off');
        set(get_ghandle(CenterWaterTable),'enable','off');
        set(get_ghandle(RightWaterTable), 'enable','off');
        set(get_ghandle(PulseNumber),     'enable','off');
        set(get_ghandle(DefaultDuration), 'enable','off');
        set(get_ghandle(LowTarget),       'enable','off');
        set(get_ghandle(HighTarget),      'enable','off');
        set(get_ghandle(Tolerance),       'enable','off');
        set(get_ghandle(InterPulseInt),   'enable','off');
        set(get_ghandle(LeftCurrent),     'enable','off'); %#ok<NODEF>
        set(get_ghandle(CenterCurrent),   'enable','off'); %#ok<NODEF>
        set(get_ghandle(RightCurrent),    'enable','off'); %#ok<NODEF>
        set(get_ghandle(Flush),           'enable','off'); 
        set(get_ghandle(User),            'enable','off'); 
        
      
        
        
    case 'enable_buttons'
        %This enables all the buttons, edit windows, and tables in the GUI
        set(get_ghandle(Run),             'enable','on');
        set(get_ghandle(Close),           'enable','on');
        set(get_ghandle(Reset),           'enable','on');
        set(get_ghandle(Preferences),     'enable','on'); %#ok<NODEF>
        set(get_ghandle(ShowTable),       'enable','on'); %#ok<NODEF>
        set(get_ghandle(Validate),        'enable','on');
        set(get_ghandle(Invalidate),      'enable','on');
        set(get_ghandle(ShowValid),       'enable','on');
        set(get_ghandle(ShowRecent),      'enable','on');
        set(get_ghandle(LeftWaterTable),  'enable','on');
        set(get_ghandle(CenterWaterTable),'enable','on');
        set(get_ghandle(RightWaterTable), 'enable','on');
        set(get_ghandle(PulseNumber),     'enable','on');
        set(get_ghandle(DefaultDuration), 'enable','on');
        set(get_ghandle(LowTarget),       'enable','on');
        set(get_ghandle(HighTarget),      'enable','on');
        set(get_ghandle(Tolerance),       'enable','on');
        set(get_ghandle(InterPulseInt),   'enable','on');
        set(get_ghandle(LeftCurrent),     'enable','on'); %#ok<NODEF>
        set(get_ghandle(CenterCurrent),   'enable','on'); %#ok<NODEF>
        set(get_ghandle(RightCurrent),    'enable','on'); %#ok<NODEF>
        set(get_ghandle(Flush),           'enable','on'); 
        set(get_ghandle(User),            'enable','on');
        
        
    case 'update_preference_values'
        %Takes the values from the Preference Panel and saves them to a mat
        %file in the WaterCalibration directory
        custom_prefs.PulseNumber     = value(PulseNumber);
        custom_prefs.DefaultDuration = value(DefaultDuration);
        custom_prefs.LowTarget       = value(LowTarget);
        custom_prefs.HighTarget      = value(HighTarget);
        custom_prefs.Tolerance       = value(Tolerance);
        custom_prefs.InterPulseInt   = value(InterPulseInt);
        
        pname = bSettings('get','GENERAL','Protocols_Directory');
        file = [pname,filesep,'@',mfilename,filesep,'custom_preferences.mat'];
        save(file,'custom_prefs');
        
        %We may have changed something that alters our estimates
        WaterCalibration(obj,'update_estimate');
        
        
        
    case 'Validate_callback'
        %Validates the selected entry (active ID) in the water table
        ID = value(ActiveID); %#ok<NODEF>
        if ~isempty(ID)
            bdata('call bdata.validate_calibration_point("{Si}")',ID);
            WaterCalibration(obj,'update_table');
        end
        
        %We may have changed something that alters our estimates
        WaterCalibration(obj,'update_estimate');
        
        
        
    case 'Invalidate_callback'
        %Invalidates on the selected entry (active ID) in the water table
        ID = value(ActiveID); %#ok<NODEF>
        if ~isempty(ID)
            bdata('call bdata.invalidate_calibration_point("{Si}")',ID);
            WaterCalibration(obj,'update_table');
        end
        
        %We may have changed something that alters our estimates
        WaterCalibration(obj,'update_estimate');
        
        
        
    case 'Yes_callback'
        %The user has confirmed they really want to reset the calibration
        %table
        set(value(ResetConfirmPanel),'visible','off');
        rigid = value(RigID); 
        valvenames = value(ValveNames);
        if strcmp(rigid,'NaN'); return; end
        try
            [ID,ISV,VLV] = bdata(['select calibrationid, isvalid, valve from calibration_info_tbl where rig_id=',rigid]);
        catch %#ok<CTCH>
            StatusString.value = 'ERROR: Can''t connect to network.';
            set(get_ghandle(StatusString),'FontSize',16,'ForegroundColor',[1 0 0],'FontWeight','bold');
            set(get_ghandle(Run),'enable','off');
            return;
        end
        for i = 1:length(ID)
            %only invalidate those entries that are valid for valves we are
            %currently calibrating
            if ISV(i) == 1 && sum(strcmp(valvenames,VLV{i})) == 1
                bdata('call invalidate_calibration_point("{Si}")',ID(i)); 
            end
        end
        WaterCalibration(obj,'update_table');
        
        %We may have changed something that alters our estimates
        WaterCalibration(obj,'update_estimate');
        
        
        
    case 'No_callback'
        %The user does not want to reset the table.  Just make the Confirm
        %Reset window go away
        set(value(ResetConfirmPanel),'visible','off');
        
        
        
    case 'Reset_callback'
        %Let's double check that the user really wants to reset the
        %calibration table for this rig
        set(value(ResetConfirmPanel),'visible','on');
        
        
        
    case 'watertable_callback'
        %This ensures that only one table can have an active line selected
        %at any time, thus preventing any confusion about which entry we
        %want to validate or invalidate.
        newvals = [get(get_ghandle(LeftWaterTable),  'value'),...
                   get(get_ghandle(CenterWaterTable),'value'),...
                   get(get_ghandle(RightWaterTable), 'value')];
        oldvals = value(TableValues); %#ok<NODEF>
        nochange = find(newvals == oldvals);
        if length(nochange) ~= 3 && sum(newvals > 2) > 1 
            for i = 1:length(nochange)
                if     nochange(i) == 1; set(get_ghandle(LeftWaterTable),  'value',1);
                elseif nochange(i) == 2; set(get_ghandle(CenterWaterTable),'value',1);
                elseif nochange(i) == 3; set(get_ghandle(RightWaterTable), 'value',1);
                end
            end
        end
        newvals = [get(get_ghandle(LeftWaterTable),  'value'),...
                   get(get_ghandle(CenterWaterTable),'value'),...
                   get(get_ghandle(RightWaterTable), 'value')];
        TableValues.value = newvals;
        
        active_tbl = find(newvals ~= 1);
        active_row = newvals(active_tbl);
        
        LID = value(LeftTableIDs); %#ok<NODEF>
        CID = value(CenterTableIDs); %#ok<NODEF>
        RID = value(RightTableIDs); %#ok<NODEF>
        
        %Get the calibrationid for the active line
        if active_row > 2
            if     active_tbl == 1; ID = LID(active_row-2); 
            elseif active_tbl == 2; ID = CID(active_row-2);
            elseif active_tbl == 3; ID = RID(active_row-2);
            else return
            end
        else ID = []; 
        end
        ActiveID.value = ID; %#ok<STRNU>
        
        
        
    case 'update_table'
        
        %If the RigID is NaN then this likely isn't a real rig.  Disable
        %the tables and return.
        rigid = value(RigID);
        if strcmp(rigid,'NaN'); 
            set(get_ghandle(LeftWaterTable),  'enable','off');
            set(get_ghandle(CenterWaterTable),'enable','off');
            set(get_ghandle(RightWaterTable), 'enable','off');
            return; 
        else
            set(get_ghandle(LeftWaterTable),  'enable','on');
            set(get_ghandle(CenterWaterTable),'enable','on');
            set(get_ghandle(RightWaterTable), 'enable','on');
        end
        
        %Depending on the state of the ShowValid and ShowRecent buttons we
        %should select only a subset or all of the entries for this rig
        if value(ShowValid)  == 1; vstr = '1'; else vstr = '0|1'; end
        if value(ShowRecent) == 1;
            DT = bdata(['select dateval from calibration_info_tbl where rig_id=',rigid]);
            for i=1:length(DT); DT{i}=DT{i}(1:10); end; DT=unique(DT);
            if strcmp(DT(end),datestr(now,29)); DT = DT(end-1:end);
            else                                DT = DT(end);
            end
            dstr = '';
            for i=1:length(DT); dstr = [dstr,DT{i},'.*|']; end %#ok<AGROW>
            dstr = dstr(1:end-1);
        else dstr = '.*';
        end
         
        %Get entries from the MySQL table
        try
            [ID,IN,DT,VLV,TM,DSP,ISV,TG] = bdata(['select calibrationid, initials, dateval, valve, timeval,',...
                 ' dispense, isvalid, target, validity from calibration_info_tbl where rig_id=',rigid,' and dateval regexp "',dstr,...
                 '" and isvalid regexp "',vstr,'" order by dateval']);
        catch %#ok<CTCH>
            StatusString.value = 'ERROR: Can''t connect to network.';
            set(get_ghandle(StatusString),'FontSize',16,'ForegroundColor',[1 0 0],'FontWeight','bold');
            set(get_ghandle(Run),'enable','off');
            return;
        end
        
        %Parse them into a pretty table format
        formatstr = '| %3s | %16s | %8.3f | %6.2f | %6s | %5s |';
        TableString{1} = '| User|    Date     Time | Duration | Volume | Target | Valid |';
        TableString{2} = '---------------------------------------------------------------';
        LeftStr   = TableString;
        CenterStr = TableString;
        RightStr  = TableString;
        
        LID = []; CID = []; RID = []; 
        doside = value(DoSide);
        for i = length(IN):-1:1
            if strcmp(VLV{i},['left',doside,'water'])
                if ISV(i) == 0; isvs = ' '; else isvs = 'Yes'; end
                LeftStr{end+1} = sprintf(formatstr,IN{i},DT{i}(1:end-3),TM(i),DSP(i),TG{i},isvs); %#ok<AGROW>
                LID(end+1) = ID(i); %#ok<AGROW>
            end
            if strcmp(VLV{i},['center',doside,'water'])
                if ISV(i) == 0; isvs = ' '; else isvs = 'Yes'; end
                CenterStr{end+1} = sprintf(formatstr,IN{i},DT{i}(1:end-3),TM(i),DSP(i),TG{i},isvs); %#ok<AGROW>
                CID(end+1) = ID(i); %#ok<AGROW>
            end
            if strcmp(VLV{i},['right',doside,'water'])
                if ISV(i) == 0; isvs = ' '; else isvs = 'Yes'; end
                RightStr{end+1} = sprintf(formatstr,IN{i},DT{i}(1:end-3),TM(i),DSP(i),TG{i},isvs); %#ok<AGROW>
                RID(end+1) = ID(i); %#ok<AGROW>
            end
        end
        
        %Change the active line in the table if it's length has been
        %shortened beyond the old value.
        oldLv = get(get_ghandle(LeftWaterTable),  'value');
        oldCv = get(get_ghandle(CenterWaterTable),'value');
        oldRv = get(get_ghandle(RightWaterTable), 'value');
        
        if isempty(oldLv); oldLv = 1; end
        if isempty(oldCv); oldCv = 1; end
        if isempty(oldRv); oldRv = 1; end
        
        if oldLv > length(LeftStr);   newLv = length(LeftStr);   else newLv = oldLv; end
        if oldCv > length(CenterStr); newCv = length(CenterStr); else newCv = oldCv; end
        if oldRv > length(RightStr);  newRv = length(RightStr);  else newRv = oldRv; end
        
        set(get_ghandle(LeftWaterTable),  'string',LeftStr,  'value',newLv);
        set(get_ghandle(CenterWaterTable),'string',CenterStr,'value',newCv);
        set(get_ghandle(RightWaterTable), 'string',RightStr, 'value',newRv);

        TableValues.value = [newLv newCv newRv]; %#ok<STRNU>
        
        %These are the calibrationids for the lines that appear in the
        %table, no need to show them to the user, but we do need them
        LeftTableIDs.value   = LID; %#ok<STRNU>
        CenterTableIDs.value = CID; %#ok<STRNU>
        RightTableIDs.value  = RID; %#ok<STRNU>
        
        

    case 'Preferences_callback'
        %Toggles the Preference Panel visibility on and off
        if strcmp(get(value(PreferencePanel),'Visible'),'off')
            set(value(PreferencePanel),'Visible','on');
            Preferences.value = 1; %#ok<STRNU>
        else
            set(value(PreferencePanel),'Visible','off');
            Preferences.value = 0; %#ok<STRNU>
        end
        
        
        
    case 'ShowTable_callback'
        %Toggles the Water Table Panel visibility on and off
        if strcmp(get(value(WaterTablePanel),'Visible'),'off')
            WaterCalibration(obj,'update_table');
            set(value(WaterTablePanel),'Visible','on');
            ShowTable.value = 1; %#ok<STRNU>
        else
            set(value(WaterTablePanel),'Visible','off');
            ShowTable.value = 0; %#ok<STRNU>
        end
   
   
        
    case 'Run_callback'
        %Before we start the run, and even though we've probably done this
        %a million times, let's update our estimate of the valve open times
        WaterCalibration(obj,'update_estimate');
        
        %Let's get the line numbers for the lights and valves
        doside = value(DoSide);
        
        leftled     = bSettings('get', 'DIOLINES', ['left',  doside,'led']);
        centerled   = bSettings('get', 'DIOLINES', ['center',doside,'led']);
        rightled    = bSettings('get', 'DIOLINES', ['right', doside,'led']); 
        leftwater   = bSettings('get', 'DIOLINES', ['left',  doside,'water']);
        centerwater = bSettings('get', 'DIOLINES', ['center',doside,'water']);
        rightwater  = bSettings('get', 'DIOLINES', ['right', doside,'water']);
        
        %LeftCurrent.value = 0.15;
        %RightCurrent.value = 0.15;
        
        %Time to build the state matrix
        sma = StateMachineAssembler('full_trial_structure');
        valves = value(Valves); %#ok<NODEF>
        
        sma = add_state(sma, 'name','pulsing','self_timer', value(InterPulseInt),...
            'input_to_statechange', {'Tup','current_state+1'});
        
        %We'll loop through the pulse number and add a state for each valve
        %and a state for the interpulse interval
        for i = 1:value(PulseNumber)
            if valves(1) == 1
                sma = add_state(sma, 'self_timer', value(LeftCurrent),...
                    'output_actions',{'DOut',leftled+leftwater},...
                    'input_to_statechange', {'Tup','current_state+1'});  %#ok<NODEF>
                sma = add_state(sma, 'self_timer', value(InterPulseInt),...
                    'input_to_statechange', {'Tup','current_state+1'});
            end
            
            if valves(2) == 1
                sma = add_state(sma, 'self_timer', value(CenterCurrent),...
                    'output_actions',{'DOut',centerled+centerwater},...
                    'input_to_statechange', {'Tup','current_state+1'}); %#ok<NODEF>
                sma = add_state(sma, 'self_timer', value(InterPulseInt),...
                        'input_to_statechange', {'Tup','current_state+1'});
            end
            
            if valves(3) == 1
                sma = add_state(sma, 'self_timer', value(RightCurrent),...
                    'output_actions',{'DOut',rightled+rightwater},...
                    'input_to_statechange', {'Tup','current_state+1'}); %#ok<NODEF>
                sma = add_state(sma, 'self_timer', value(InterPulseInt),...
                        'input_to_statechange', {'Tup','current_state+1'});
            end
        end
        
        sma = add_state(sma, 'name','complete','self_timer', value(InterPulseInt),...
            'input_to_statechange', {'Tup','check_next_trial_ready'});
        
        %Now that we have the state matrix, we disable all the buttons so
        %the user can't do anything while the rig is running, send the
        %State Matrix to dispatcher, and start everything running
        Running.value = 1; %#ok<STRNU>
        WaterCalibration(obj,'disable_buttons');
        dispatcher('send_assembler', sma, 'complete');
        
        RunningSection(dispatcher,'RunButtonCallback')
        
        
        
    case 'update'
        %Dispatcher will call this periodically while the calibration cycle
        %is running. Based on the number of states that have passed we can
        %determine how many pulses are left to go. 
        n = RunningSection(dispatcher,'get_currentstatenum');
        r = value(PulseNumber) - round((n - 40) / (sum(value(Valves)) * 2)); %#ok<NODEF>
        
        %Update the status window accordingly
        if value(Running) == 1 %#ok<NODEF>
            StatusString.value = ['Cycle Running. ',num2str(r),' of ',num2str(value(PulseNumber)),...
                ' pulses remain.  Please wait...'];
            set(get_ghandle(StatusString),'FontSize',18,'ForegroundColor',[0 0.7 0.7],'FontWeight','bold');
        else
            StatusString.value = 'Cycle Complete. Please enter the cup weights.';
            set(get_ghandle(StatusString),'FontSize',18,'ForegroundColor',[0 0 0],'FontWeight','bold');
        end
        
        
        
    case 'prepare_next_trial'
        %This gets called at the end of the cycle.  Let's stop dispatcher,
        %update the status window, and enable the buttons
        RunningSection(dispatcher,'RunButtonCallback')
        
        Running.value = 0; %#ok<STRNU>
        StatusString.value = 'Cycle Complete. Please enter the cup weights.';
        set(get_ghandle(StatusString),'FontSize',18,'ForegroundColor',[0 0 0],'FontWeight','bold');
        
        WaterCalibration(obj,'enable_buttons');
        
        %Before bringing up the Weight Entry Panel, let's disable the edit
        %windows for any valves the user does not need to enter weights
        %for
        weigh = value(Weigh); %#ok<NODEF>
        if weigh(1) == 1; set(get_ghandle(LeftWeight),  'enable','on');  set(get_ghandle(LeftWeightT),  'ForegroundColor',[0   0   0]); %#ok<NODEF>
        else              set(get_ghandle(LeftWeight),  'enable','off'); set(get_ghandle(LeftWeightT),  'ForegroundColor',[0.8 0.8 0.8]); %#ok<NODEF>
        end
        if weigh(2) == 1; set(get_ghandle(CenterWeight),'enable','on');  set(get_ghandle(CenterWeightT),'ForegroundColor',[0   0   0]); %#ok<NODEF>
        else              set(get_ghandle(CenterWeight),'enable','off'); set(get_ghandle(CenterWeightT),'ForegroundColor',[0.8 0.8 0.8]); %#ok<NODEF>
        end
        if weigh(3) == 1; set(get_ghandle(RightWeight), 'enable','on');  set(get_ghandle(RightWeightT), 'ForegroundColor',[0   0   0]); %#ok<NODEF>
        else              set(get_ghandle(RightWeight), 'enable','off'); set(get_ghandle(RightWeightT), 'ForegroundColor',[0.8 0.8 0.8]); %#ok<NODEF>
        end
        
        %Now we can turn the panel on
        set(value(WeightPanel),'Visible','on');
        
        %Let's make the first enables edit window active so the user
        %doesn't need to mouse over and click on it.
        
        if     weigh(1) == 1; uicontrol(get_ghandle(LeftWeight));
        elseif weigh(2) == 1; uicontrol(get_ghandle(CenterWeight));
        elseif weigh(3) == 1; uicontrol(get_ghandle(RightWeight));
        end
        
        
        
    case 'update_estimate'
        %If the RigID is NaN then this likely isn't a real rig.  
        rigid = value(RigID);
        if strcmp(rigid,'NaN'); 
            StatusString.value = 'ERROR: Water Calibration cannot run on a NaN Rig.';
            set(get_ghandle(StatusString),'FontSize',16,'ForegroundColor',[1 0 0],'FontWeight','bold');
            return;
        end
        
        %Let's turn the Run button on. We'll turn it off if we encounter
        %any errors.
        set(get_ghandle(Run),'enable','on');
        
        %Get the valid entries in the MySQL table for this rig
        try
            [ID,DT,VLV,TM,DSP,TG] = bdata(['select calibrationid, dateval, valve, timeval,',...
                ' dispense, target from calibration_info_tbl where rig_id=',rigid,' and isvalid=1']);
        catch %#ok<CTCH>
            StatusString.value = 'ERROR: Can''t connect to network.';
            set(get_ghandle(StatusString),'FontSize',16,'ForegroundColor',[1 0 0],'FontWeight','bold');
            LeftCurrent.value   = 0; %#ok<STRNU>
            CenterCurrent.value = 0; %#ok<STRNU>
            RightCurrent.value  = 0; %#ok<STRNU>
            set(get_ghandle(Run),'enable','off');
            return;
        end
        
        %Clean up old valid entries that should not be valid
        for i=1:length(DT); DT{i}=DT{i}(1:10); end; dt=unique(DT);
        if ~isempty(dt)
            if strcmp(dt(end),datestr(now,29)) && length(dt) > 1; dt = dt(end-1:end);
            else                                                  dt = dt(end);
            end
        end
        
        %Any entries that do not have the date in dt should be invalidated outright
        good = [];
        for i=1:length(dt); good(:,i) = strcmp(DT,dt{i}); end %#ok<AGROW>
        %We only want to invalidate entries for the valves we're currently
        %calibrating
        valvenames = value(ValveNames);
        for i = 1:numel(VLV)
            if sum(strcmp(valvenames,VLV{i})) == 0
                %We're not calibrating this valve now, mark it good so we
                %don't invalidate the entry
                good(i,:) = 1; %#ok<AGROW>
            end
        end
        badID = ID(sum(good,2)==0);
        for i=1:length(badID); bdata('call invalidate_calibration_point("{Si}")',badID(i)); end
        
        %If we invalidated entries, let's get a clean list
        if ~isempty(badID)
            [ID,DT,VLV,TM,DSP,TG] = bdata(['select calibrationid, dateval, valve, timeval,',...
                ' dispense, target from calibration_info_tbl where rig_id=',rigid,' and isvalid=1']);
        end
        
        %If there is at least one entry with today's date for a particular
        %valve, all older entries for that valve should be invalidated. 
        badID = [];
        for i=1:length(valvenames)
            dts = DT(strcmp(VLV,valvenames{i}));
            for j=1:length(dts); dts{j} = dts{j}(1:10); end
            if sum(strcmp(dts,datestr(now,29))) > 0
                %Found an entry from today for this valve, invalidate all older ones
                ids = ID(strcmp(VLV,valvenames{i}));
                badID = ids(~strcmp(dts,datestr(now,29)));
                for j=1:length(badID); bdata('call invalidate_calibration_point("{Si}")',badID(j)); end
            end
        end
        
        %If we invalidated entries, let's get a clean list
        if ~isempty(badID)
            [ID,DT,VLV,TM,DSP,TG] = bdata(['select calibrationid, dateval, valve, timeval,',...
                ' dispense, target from calibration_info_tbl where rig_id=',rigid,' and isvalid=1']); %#ok<ASGLU>
        end
        for i=1:length(DT); DT{i}=DT{i}(1:10); end
        
        %Okay, by now we should have only the values we want to work with,
        %and any future passes through this case should not encounter any
        %mess.  From what we have left we can determine what we need to do.
        
        DATA = cell(length(valvenames),1);
        completed = zeros(length(valvenames),2);
        ESTIMATE  = zeros(size(valvenames));
        target    = zeros(size(valvenames));
        valves    = value(Valves); %#ok<NODEF>
        for i=1:length(valvenames)
            %Skip this valve if it's not active
            if valves(i) == 0; completed(i,:) = 1; continue; end
            
            %Get the values for the current valve
            thisvalve = strcmp(VLV,valvenames{i});
            dsp = DSP(thisvalve);
            tm  =  TM(thisvalve);
            tg  =  TG(thisvalve);
            
            dataold = 1;
            
            highattempts = strcmpi(tg,'high');
            lowattempts  = strcmpi(tg,'low');
            
            %If we have a low target value, add it to DATA
            low = find(dsp < value(LowTarget)+value(Tolerance) & dsp > value(LowTarget)-value(Tolerance) == 1,1,'first');
            if ~isempty(low); DATA{i}(end+1,:) = [dsp(low) tm(low)]; end
            
            %If we have a high target value, add it to DATA
            high = find(dsp < value(HighTarget)+value(Tolerance) & dsp > value(HighTarget)-value(Tolerance) == 1,1,'first');
            if ~isempty(high); DATA{i}(end+1,:) = [dsp(high) tm(high)]; end
            
            %Remove any target hits from the attempts so we don't add the
            %same value twice to the DATA matrix
            highattempts(low)  = 0;
            lowattempts(low)   = 0;
            highattempts(high) = 0;
            lowattempts(high)  = 0;
                
            %If all the values are from the current day, depending on which
            %targets we already have, we can add in some miss values
            if all(strcmp(DT(thisvalve),datestr(now,29))) && sum(thisvalve) ~= 0
                dataold = 0;
                if ~isempty(low) && ~isempty(high)
                    %We have both targets for this valve, we're done.
                    completed(i,:) = 1;
                
                elseif ~isempty(low) && isempty(high)
                    %We only have the low target
                    completed(i,1) = 1;
                    if sum(highattempts) > 0
                        %If we have a high miss then take the low target and
                        %all high misses
                        DATA{i}(end+1:end+sum(highattempts),:) = [dsp(highattempts) tm(highattempts)];
                    elseif sum(lowattempts) > 0
                        %If we don't have a high miss then take the low target
                        %and all low misses
                        DATA{i}(end+1:end+sum(lowattempts),:) = [dsp(lowattempts) tm(lowattempts)];
                    end
                    
                elseif isempty(low) && ~isempty(high)
                    %We only have the high target
                    completed(i,2) = 1;
                    if sum(lowattempts) > 0
                        %If we have a low miss then take the high target and
                        %all low misses
                        DATA{i}(end+1:end+sum(lowattempts),:) = [dsp(lowattempts) tm(lowattempts)];
                    elseif sum(highattempts) > 0
                        %If we don't have a low miss then take the high target
                        %and all high misses
                        DATA{i}(end+1:end+sum(highattempts),:) = [dsp(highattempts) tm(highattempts)];
                    end
                    
                else
                    %We have no targets yet, take all the misses
                    DATA{i} = [dsp tm];
                end
            end
            
            %If we only have 1 data point, assume [0,0.026] as a second,
            %analysis of the water valves across all rigs yields an average
            %y-axis intercept of 26ms open time for 0uL water, so let's
            %assume this value rather than [0,0] since we know that's wrong
            
            %The new water system has higher pressure so the intercept will
            %be different. Let's see if the rig has the new water system,
            %if not use 26ms intercept.  If it does the intercept will
            %depend on height of the rig.
            rigpos = bSettings('get','WATER','rig_position');
            if (~ischar(rigpos) && isnan(rigpos)) || strcmp(rigpos,'reservoir')
                if size(DATA{i},1) == 1; DATA{i}(2,:) = [0,0.026]; end
            elseif strcmp(rigpos,'bottom')
                if size(DATA{i},1) == 1; DATA{i}(2,:) = [0,0.014]; end
            elseif strcmp(rigpos,'middle')
                if size(DATA{i},1) == 1; DATA{i}(2,:) = [0,0.017]; end
            elseif strcmp(rigpos,'top')
                if size(DATA{i},1) == 1; DATA{i}(2,:) = [0,0.020]; end
            else
                if size(DATA{i},1) == 1; DATA{i}(2,:) = [0,0.026]; end
            end
            
            %Now we are going to estimate the valve open time for the
            %missing target(s)
            
            if sum(completed(i,:)) < 2
                %If we have no data points for this valve use the default guess
                if isempty(DATA{i}) 
                    ESTIMATE(i) = value(DefaultDuration);
                    target(i) = value(HighTarget);
                else
                    %We have data points, so let's determine our target
                    
                    if dataold == 1; target(i) = value(HighTarget);
                    else
                        %If we don't have either target, go for the high one first
                        if      isempty(low) &&  isempty(high); target(i) = value(HighTarget);
                        %We have the low target, but we need the high target
                        elseif ~isempty(low) &&  isempty(high); target(i) = value(HighTarget);
                        %We have the high target, but we need the low target
                        elseif  isempty(low) && ~isempty(high); target(i) = value(LowTarget);  
                        %We have both targets so we need none
                        else                                   target(i) = 0;    
                        end
                    end
                end
            end
        end
        
        %Now we have all the data values and targets. Let's sync the
        %targets and calculate the estimates.
        synctarget = max(target);
        
        %Let's update the display to tell the user what target we are
        %going for, not that it really matters to them though
        if     synctarget == value(HighTarget); t = 2;
            set(get_ghandle(High),'BackgroundColor',[0 1 1]);
            set(get_ghandle(Low), 'BackgroundColor',[1 1 1]);
        elseif synctarget == value(LowTarget);  t = 1;
            set(get_ghandle(High),'BackgroundColor',[1 1 1]);
            set(get_ghandle(Low), 'BackgroundColor',[0 1 1]);
        else                                    t = 0;
            set(get_ghandle(High),'BackgroundColor',[1 1 1]);
            set(get_ghandle(Low), 'BackgroundColor',[1 1 1]);
        end
        
        %Let's update the display to tell them which targets are complete 
        if completed(1,1)==1; set(get_ghandle(LeftLowStat),   'string','Complete',  'ForegroundColor',[0 1 0]);
        else                  set(get_ghandle(LeftLowStat),   'string','Incomplete','ForegroundColor',[1 0 0]);
        end
        if completed(1,2)==1; set(get_ghandle(LeftHighStat),  'string','Complete',  'ForegroundColor',[0 1 0]);
        else                  set(get_ghandle(LeftHighStat),  'string','Incomplete','ForegroundColor',[1 0 0]);
        end

        if completed(2,1)==1; set(get_ghandle(CenterLowStat), 'string','Complete',  'ForegroundColor',[0 1 0]);
        else                  set(get_ghandle(CenterLowStat), 'string','Incomplete','ForegroundColor',[1 0 0]);
        end
        if completed(2,2)==1; set(get_ghandle(CenterHighStat),'string','Complete',  'ForegroundColor',[0 1 0]);
        else                  set(get_ghandle(CenterHighStat),'string','Incomplete','ForegroundColor',[1 0 0]);
        end

        if completed(3,1)==1; set(get_ghandle(RightLowStat),  'string','Complete',  'ForegroundColor',[0 1 0]);
        else                  set(get_ghandle(RightLowStat),  'string','Incomplete','ForegroundColor',[1 0 0]);
        end
        if completed(3,2)==1; set(get_ghandle(RightHighStat), 'string','Complete',  'ForegroundColor',[0 1 0]);
        else                  set(get_ghandle(RightHighStat), 'string','Incomplete','ForegroundColor',[1 0 0]);
        end

        %Let's update the display to tell them which valve(s) the will be
        %measuring
        if t == 0;                set(get_ghandle(Left),  'BackgroundColor',[1 1 1]);
                                  set(get_ghandle(Center),'BackgroundColor',[1 1 1]);
                                  set(get_ghandle(Right), 'BackgroundColor',[1 1 1]);
        else
            if completed(1,t)==0; set(get_ghandle(Left),  'BackgroundColor',[0 1 1]); 
            else                  set(get_ghandle(Left),  'BackgroundColor',[1 1 1]); 
            end
            if completed(2,t)==0; set(get_ghandle(Center),'BackgroundColor',[0 1 1]); 
            else                  set(get_ghandle(Center),'BackgroundColor',[1 1 1]); 
            end
            if completed(3,t)==0; set(get_ghandle(Right), 'BackgroundColor',[0 1 1]); 
            else                  set(get_ghandle(Right), 'BackgroundColor',[1 1 1]); 
            end
        end
        
        if any(completed(:) == 0)
            for i = 1:length(valvenames)
                if valves(i) == 0; continue; end
                if ESTIMATE(i) == 0
                    p = polyfit(DATA{i}(:,1),DATA{i}(:,2),1);
                    ESTIMATE(i) = (synctarget * p(1)) + p(2);
                    
                    %Check for a negative or 0 slope
                    if p(1) <= 0
                        StatusString.value = ['ERROR: WaterCalibration has estimated a negative slope.',...
                            ' One or more of the calibration entries must have been in error.',...
                            ' Please click "Reset" and start the calibration over.'];
                        set(get_ghandle(StatusString),'FontSize',12,'ForegroundColor',[1 0 0],'FontWeight','normal');
                        set(get_ghandle(Run),'enable','off');
                        return;
                    end
                end
            end
        else
            StatusString.value = 'The calibration is complete. There is no need to run another cycle.';
            set(get_ghandle(StatusString),'FontSize',16,'ForegroundColor',[0 1 0],'FontWeight','bold');
            set(get_ghandle(Run),'enable','off');
            
            %Now all we need to do is invalidate all non-target entries and
            %we're done.
            WaterCalibration(obj,'invalidate_all_nontarget_entries');
        end
        
        %Check to see if the valves may be clogged. We should only do this
        %early on in the calibration so as to not waste the user's time
        isearly = 0;
        for i = 1:length(DATA); if size(DATA{i},1) < 3; isearly = 1; end; end
        if any(ESTIMATE > 0.5) && dataold == 0 && isearly == 1
            StatusString.value = ['ERROR: WaterCalibration has estimated a valve open time greater then 0.5s.',...
                ' This likely indicates one of the valves is very dirty and likely clogged.',...
                ' Please clean the valves, click "Reset" and start the calibration over.'];
            set(get_ghandle(StatusString),'FontSize',12,'ForegroundColor',[1 0 0],'FontWeight','normal');
            set(get_ghandle(Run),'enable','off');
            return
        end
        
        %Let's round the estiamte to the nearest millisecond
        ESTIMATE = (round(ESTIMATE * 1000)) / 1000;
        
        %We made it. At this point we should have the valve open time
        %estimates that we can feed to the state machine
        LeftCurrent.value   = ESTIMATE(1); %#ok<STRNU>
        CenterCurrent.value = ESTIMATE(2); %#ok<STRNU>
        RightCurrent.value  = ESTIMATE(3); %#ok<STRNU>
        
        %These will be used after the run to know which valves we need to
        %weigh and what target to enter in the MySQL table for this run
        Target.value = t; %#ok<STRNU>
        if t == 0; Weigh.value = [0 0 0];
        else       Weigh.value = ~completed(:,t);
        end
        
        if any(value(Weigh) == 1)
            StatusString.value = [value(User),', Water Calibration is ready for it''s next cycle. Make sure the rig is ready, then click "Run".'];
            set(get_ghandle(StatusString),'FontSize',14,'ForegroundColor',[0 0 0],'FontWeight','normal');
        end
        
        
        
    case 'invalidate_all_nontarget_entries'
        %This is only called once the calibration is deemed complete for
        %the day.  It will invalidate all nontarget entries.  This way one
        %only needs to get the valid entries to find the targets.
        
        rigid = value(RigID);
        [ID,DSP,VLV] = bdata(['select calibrationid, dispense, valve from',...
            ' calibration_info_tbl where rig_id=',rigid,' and isvalid=1 order by calibrationid desc']);
        
        valvenames = value(ValveNames);
        valves     = value(Valves); %#ok<NODEF>
        good       = zeros(size(ID));
        for i = 1:length(valves)
            if valves(i) == 0; continue; end
            
            high = find(DSP > value(HighTarget)-value(Tolerance) & DSP < value(HighTarget)+value(Tolerance) & strcmp(VLV,valvenames{i}),1,'first');
            low  = find(DSP > value(LowTarget) -value(Tolerance) & DSP < value(LowTarget) +value(Tolerance) & strcmp(VLV,valvenames{i}),1,'first');
            
            good(high) = 1;
            good(low)  = 1;
        end
        
        %we don't want to invalidate entries for valves we're not currently
        %calibrating.
        for i = 1:numel(VLV)
            foundname = 0;
            for j = 1:numel(valvenames)
                if strcmp(VLV{i},valvenames{j})
                    foundname = 1;
                end
            end
            if foundname == 0
                good(i) = 1;
            end
        end
                    
        bad = ID(good == 0);
        for i = 1:length(bad); bdata('call invalidate_calibration_point("{Si}")',bad(i)); end 
        
        
    case 'close'
        %This deletes everything
        if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)) %#ok<NODEF>
            delete(value(myfig));
        end
        if exist('PreferencePanel', 'var')   && isa(PreferencePanel,   'SoloParamHandle') && ishandle(value(PreferencePanel))
            delete(value(PreferencePanel));
        end
        if exist('WaterTablePanel', 'var')   && isa(WaterTablePanel,   'SoloParamHandle') && ishandle(value(WaterTablePanel)) 
            delete(value(WaterTablePanel));
        end
        if exist('WeightPanel', 'var')       && isa(WeightPanel,       'SoloParamHandle') && ishandle(value(WeightPanel)) 
            delete(value(WeightPanel));
        end
        if exist('ResetConfirmPanel', 'var') && isa(ResetConfirmPanel, 'SoloParamHandle') && ishandle(value(ResetConfirmPanel)) 
            delete(value(ResetConfirmPanel));
        end
        if exist('VideoConfirmPanel','var')  && isa(VideoConfirmPanel, 'SoloParamHandle') && ishandle(value(VideoConfirmPanel))
            delete(value(VideoConfirmPanel));
        end
        delete_sphandle('owner', ['^@' class(obj) '$']);
        
        
        
    case 'Close_callback'
        %executes from the Close button or X in the upper right corner of
        %the GUI.  Tries to close things via dispatcher, but if it can't it
        %just calls close
        try
            %first try closing the protocol through dispatcher
            if dispatcher('is_running'); 
                RunningSection(dispatcher,'RunButtonCallback');
            end
            dispatcher('close_protocol'); %This will call the close case
        catch %#ok<CTCH>
            %dispatcher likely is not even open, delete stuff the old fashioned way
            WaterCalibration(obj,'close');
        end
        dispatcher('close');
        
        try %#ok<TRYNC>
            newstartup; 
            runrats('init');
        end
        
    otherwise
        if ~ischar(action); action = num2str(action); end
        disp(['WARNING Unknown action: ', action]);
end

return