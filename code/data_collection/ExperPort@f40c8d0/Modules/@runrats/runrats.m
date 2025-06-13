% RunRats(varargin)
% This is the GUI for technicians in the lab to use for day to day running
% of rats.  The logic of the code follows that of dispatcher.

% The original RunRats was written by Jeff Erlich with modifications by
% Sebastien Awwad, 2007-2008 and Sundeep Tuteja, 2009
%
% This is a complete rewrite written by     Chuck Kopec 2011
% Maintenance features added by             Chuck Kopec 2012 
% 9 shift expansion by                      Chuck Kopec 2013 V2.2
% Split ratname into 2 menus                Chuck Kopec 2017 V2.3
% Adding video recording                    Chuck Kopec 2018 V2.4
% Auto loading, auto run                    Chuck Kopec 2021 V2.5


function [obj, varargout]=runrats(varargin)

%Argument handling
obj = class(struct, mfilename, sqlsummary);
varargout = {};
if nargin==0 || nargin==1 && ischar(varargin{1}) && strcmp(varargin{1}, 'empty'),
    return;
end;

% This line is required for the use of SoloParams
GetSoloFunctionArgs;

if nargin>=2 && isa(varargin{1}, class(obj)), action = varargin{2}; varargin = varargin(3:end);
else                                          action = varargin{1}; varargin = varargin(2:end);
end;
if ~ischar(action)
    error('Runrats expects to be called with a string as the first argument specifying the action to perform. E.g.: runrats(''init'');');
end

%Make the action case insensitive
action = lower(action);

switch action
    
    case 'physinit'
        %% physinit
        SoloParamHandle(obj,'phys','value',1);
        runrats(obj,'init');
        
    case 'init'
        %% init
        
        % Update the rig info table
        update_riginfo();
        
        %Reset the values that GCS sees for trials and performance
        try send_n_done_trials(obj,'reset'); end %#ok<TRYNC>
        
        %If we are starting from a forced reboot from runrats itself we
        %need to make sure the do_on_reboot.bat file is set back to nothing
        try %#ok<TRYNC>
            if bSettings('get','RIGS','bpod') ~= 1
                %We want bpod rigs to always start runrats on startup so
                %don't do this on them
                p = pwd;
                cd('\ratter\Rigscripts')

                !del do_on_reboot.bat
                !copy nothing.bat do_on_reboot.bat /Y
                cd(p);
            end
        end
        
        %Starting 190116 the log will be written to a temp text file which
        %is not in the SVN reposity. The text file which is on SVN will be
        %blank.  This should prevent conflicts with the file
        experport_path = bSettings('get','GENERAL','Main_Code_Directory');
        if experport_path(end) == filesep; experport_path = experport_path(1:end-1); end
        mainlog = [experport_path,'\Modules\@runrats\runrats_datalog.txt'];
        templog = [experport_path,'\Modules\@runrats\runrats_datalog_temp.txt'];
        
        %If there is no temp log file, copy the existing main log over,
        %delete the main log, and svn update. The new main log file will be
        %an empty text file
        if ~exist(templog,'file')
            copyfile(mainlog,templog,'f');
            delete(mainlog);
            update_folder(bSettings('get','GENERAL','Main_Code_Directory'));
        end
        
        %Let's set the autoload file
        try
            autoload_file = bSettings('get','GENERAL','Main_Code_Directory');
            if autoload_file(end) ~= '\'; autoload_file = [autoload_file,'\']; end
            autoload_file = [autoload_file,'Modules\@runrats\next_rat_to_autoload.mat'];
        catch
            disp('ERROR setting autoload file');
        end
        
        %If a dispatcher is already open, let's close it so we don't ever have
        %more than 1
        if exist('myfig', 'var')
            if isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)), delete(value(myfig)); end;
        end
        
        %Let's see if the rig is broken
        isbroken = bdata(['select isbroken from ratinfo.rig_maintenance where rigid="',num2str(bSettings('get','RIGS','Rig_ID')),'" and isbroken=1']);
        if isempty(isbroken); isbroken = 0;
        else                  isbroken = 1;
        end
        SoloParamHandle(obj,'IsBroken','value',isbroken); %
        
        %Let's see how long it's been since the last calibration
        SoloParamHandle(obj,'CalibAge','value',Inf); %Age of the calibration in days
        SoloParamHandle(obj,'CalibExp','value',100);
        runrats(obj,'check_calibration');
        
        %If the calibration is too old, let's open WaterCalibration for the
        %tech, if we are getting near needing a new calibration let's warn them
        %If the rig is broken ignore calibration
        
        techmessage = '';
        if dispatcher('is_running'); dispatcher('close'); end
        if bSettings('get','WATER','skip_calibration_now') ~= 1 && isbroken == 0
            if value(CalibAge) >= value(CalibExp) %#ok<NODEF>
                dispatcher('init'); set(gcf,'visible','off');
                isbpodrig = bSettings('get','RIGS','bpod');
                if isnan(isbpodrig); isbpodrig = 0; end
                if isbpodrig
                    dispatcher('set_protocol','WaterCalibrationBPod');
                else
                    dispatcher('set_protocol','WaterCalibration');
                end
                return;
            elseif value(CalibAge) >= value(CalibExp)-1
                techmessage = 'WARNING Calibration will expire in 1 day!';
            elseif value(CalibAge) >= value(CalibExp)-2
                techmessage = 'Calibration will expire in 2 days,';
            elseif value(CalibAge) >= value(CalibExp)-3
                techmessage = 'Calibration will expire in 3 days,';
            end
        end
        
        %Copy Settings Files to Cup
        runrats(obj,'copy_settings_files');
        
        % Start and hide the dispatcher.
        
        dispobj=dispatcher('init');
        h=get_sphandle('owner','dispatcher','name','myfig');
        set(value(h{1}), 'Visible','Off');
        SoloParamHandle(obj, 'dispobj','value',dispobj);
        
        %SoloParamHandle storing the settings file
        SoloParamHandle(obj, 'settings_file_sph',       'value', '');
        SoloParamHandle(obj, 'settings_file_load_time', 'value', 0 );
        
        
        % The main RunRats window should appear in the center of the screen
        % at the bottom so video will be less obstructed
        sr = get(0,'MonitorPositions');
        wh = [650 250];
        pos = [(sr(3)-wh(1))/2,50,wh(1),wh(2)];
        
        fig = double(figure('Position',pos,'MenuBar','none','ToolBar','none', ...
            'NumberTitle','off','Name','RunRats V2.5','Resize','off',...
            'closerequestfcn', [mfilename '(''close'')']));
        SoloParamHandle(obj,'myfig', 'value',fig);
        
        try
            %Works for matlab 2013
            jf = findjobj(value(myfig));
            if matlab_version_number < 9
                set(jf,'alwaysOnTop',1)
            else
                set(jf(1),'alwaysOnTop',1)
            end
            %This was for matlab 2008b
            %jf=get(value(myfig), 'JavaFrame');
            %pause(0.1);
            %javaMethod('setAlwaysOnTop', jf.fFigureClient.getWindow, 1);
        catch %#ok<CTCH>
            disp('WARNING: Failed to keep runrats on top');
        end
        
        
        %Create the non-gui variables we will need
        SoloParamHandle(obj,'RigID',           'value',bSettings('get','RIGS','Rig_ID')); %The rig ID
        SoloParamHandle(obj,'RatSch',          'value',cell(10,1)); %The rats that run in this rig in session order
        SoloParamHandle(obj,'CurrSession',     'value',1); %The session that we should prep to load
        SoloParamHandle(obj,'CurrProtocol',    'value',1); %The protocol that the rat runs under
        SoloParamHandle(obj,'WasFlushed',      'value',0); %Was the rig flused today
        SoloParamHandle(obj,'InLiveLoop',      'value',0); %Let's us know if we should break out of the loop
        SoloParamHandle(obj,'CurrRat',         'value',''); %The name of the current rat
        SoloParamHandle(obj,'PanelBack',       'value',[]); %handles to all the uicontrols that share the background color
        SoloParamHandle(obj,'RigIsBroken',     'value',0); %1 if the rig is broken, 0 if it's not
        SoloParamHandle(obj,'DoingMaintenance','value',0); %1 if we are entering a maintenance note
        SoloParamHandle(obj,'do_full_restart', 'value',1); %1 if we want to restart matlab between each session
        SoloParamHandle(obj,'SafetyMode',      'value',''); %empty for no safety, B for before, A for after
        SoloParamHandle(obj,'OptoPlugColor',   'value',[]); %figure handle for opto plug color panel
        SoloParamHandle(obj,'PuckDuration',    'value',120); %duration in hours before a food puck must be changed out
        SoloParamHandle(obj,'VideoFile',       'value',''); %Path the video is being saved to
        SoloParamHandle(obj,'IsBpodRig',       'value',0); %0 for Bcontrol, 1 for Bpod
        SoloParamHandle(obj,'UseBucket',       'value',bSettings('get','RIGS','use_bucket')); %1 if backing up to bucket, 0 for cvs
        SoloParamHandle(obj,'ManualTestFail',  'value','none'); %which port purposely failed to test the techs
        SoloParamHandle(obj,'InputArgs',       'value',[]); %used to locally store varargin and pass between cases
        SoloParamHandle(obj,'AutoLoadFile',    'value',autoload_file); %the autoload file
        SoloParamHandle(obj,'UpdateCounter',   'value',0); %how many times we've called update
        SoloParamHandle(obj,'SessionEnded',    'value',0); %have we clicked End Session
        
        SoloParamHandle(obj,'VideoFile2',      'value',''); %Path video 2  is being saved to
        SoloParamHandle(obj,'VideoFile3',      'value',''); %Path video 3  is being saved to
        SoloParamHandle(obj,'VideoFile4',      'value',''); %Path video 4  is being saved to
        SoloParamHandle(obj,'VideoFile5',      'value',''); %Path video 5  is being saved to
        SoloParamHandle(obj,'VideoFile6',      'value',''); %Path video 6  is being saved to
        SoloParamHandle(obj,'VideoFile7',      'value',''); %Path video 7  is being saved to
        SoloParamHandle(obj,'VideoFile8',      'value',''); %Path video 8  is being saved to
        SoloParamHandle(obj,'VideoFile9',      'value',''); %Path video 9  is being saved to
        SoloParamHandle(obj,'VideoFile10',     'value',''); %Path video 10 is being saved to
        
        
        try bdata('call cleanup_crashed("{S}","{S}")',999999999,value(RigID)); end
        
        figname = get(fig,'name');
        if value(UseBucket) == 1
            set(fig,'name',[figname,'_buc']);
        else
            set(fig,'name',[figname,'_cvs']);
        end
        
        %Notify the tech when calibration will expire
        figname = get(fig,'name');
        do_calibration = floor(value(CalibExp) - value(CalibAge));
        set(fig,'name',[figname,'   Calibration Expires in ',num2str(do_calibration),' days']);
        
        if ~exist('phys','var'); SoloParamHandle(obj,'phys','value',0); end
        
        SoloParamHandle(obj, 'curProtocol', 'value', '');  %Current Protocol
        SoloParamHandle(obj,'schedDay','value',[]);
        
        rigtype = bSettings('get','RIGS','bpod');
        if rigtype == 1; IsBpodRig.value = 1; end %#ok<STRNU>
        
        ratrig = bSettings('get','RIGS','ratrig');
        if isnan(ratrig); ratrig = 1; end
        
        r = bdata(['select ratname from ratinfo.rats where extant=1 and israt=',num2str(ratrig)]);
        r = unique(r);
        SoloParamHandle(obj,'AllRats','value',r);
        for i = 1:numel(r);
            alllets{i} = r{i}(1); %#ok<AGROW>
        end
        alllets{end+1} = '';
        alllets = unique(alllets);
        
        
        %Let's make the menus
        try
            all_experimenters = bdata('select distinct experimenter from ratinfo.rats where extant=1 order by experimenter');
        catch %#ok<CTCH>
            disp('ERROR: Unable to connect to MySQL Server');
            all_experimenters = '';
        end
        all_experimenters = [{''};all_experimenters];
        SoloParamHandle(obj,'AllExps','value',all_experimenters);
        
        SubheaderParam(obj,'ExpName','',            0,0,'position',[10 204 200 35]);
        
        MenuParam(obj,'LetMenu',alllets,          1,0,0,'position',[10 147  70 50],'labelfraction',0.03);
        MenuParam(obj,'NumMenu',{''},             1,0,0,'position',[80 147 130 50],'labelfraction',0.02);
        MenuParam(obj,'SchList',{'Not Active'},   1,0,0,'position',[10  95 360 35],'labelfraction',0.01);
        
        SubheaderParam(obj,'ExpLbl','Experimenter',0,0,'position',[215 204 170 35]);
        SubheaderParam(obj,'RatLbl','Rat',         0,0,'position',[215 162 170 35]);
        
        set(get_ghandle(ExpName),'FontSize',20,'BackgroundColor',[1 1 1]); %#ok<NODEF>
        set(get_ghandle(LetMenu),'FontSize',34,'BackgroundColor',[1 1 1]); %#ok<NODEF>
        set(get_ghandle(NumMenu),'FontSize',34,'BackgroundColor',[1 1 1],'ButtonDownFcn',@clbck); %#ok<NODEF>
        set(get_ghandle(SchList),'FontSize',20,'BackgroundColor',[1 1 1],'FontName','Courier','FontWeight','bold'); %#ok<NODEF>
        
        set(get_ghandle(ExpLbl),'FontSize',20,'BackgroundColor',[1,0.8,0.6],'HorizontalAlignment','left');
        set(get_ghandle(RatLbl),'FontSize',20,'BackgroundColor',[1,0.8,0.6],'HorizontalAlignment','left');
        
        set_callback(LetMenu,{mfilename,'letmenu_callback'});
        set_callback(NumMenu,{mfilename,'nummenu_callback'});
        set_callback(SchList,{mfilename,'schlist_callback'});
        
        %Try to alter the java property of the letter and number menu
        %objects to only display 8 in the window, others accessed via
        %slider, this way the large font list will fit on small screens
        try
            NumMenu_jhandle = findjobj(get_ghandle(NumMenu));
            set(NumMenu_jhandle,'MaximumRowCount',8);
        
            LetMenu_jhandle = findjobj(get_ghandle(LetMenu));
            set(LetMenu_jhandle,'MaximumRowCount',8);
        catch
            disp('ERROR setting Menu item count display');
        end
        
        %Let's make the buttons
        PushbuttonParam(obj,'FlushValves', 0,0,'position',[ 10,30,140, 25],'BackgroundColor',[0.6 1   1  ],'label','Flush Valves');
        ToggleParam(    obj,'UsingPucks',1,0,0,'position',[ 10,30, 90, 25],'BackgroundColor',[1   1   1  ],'ForegroundColor',[0.5,0.3,0.1],'OnString','Use Puck','OffString','No Puck');
        PushbuttonParam(obj,'ReplacePuck', 0,0,'position',[101,30,110, 25],'BackgroundColor',[0.5,0.3,0.1],'label','Replace 48h');
        PushbuttonParam(obj,'TestImplant', 0,0,'position',[220,30,135, 25],'BackgroundColor',[1   0.6 1  ],'label','Test Implant');
        PushbuttonParam(obj,'UpdateMode' , 0,0,'position',[365,30,145, 25],'BackgroundColor',[0.6 1   0.6],'label','Live Update On');
        PushbuttonParam(obj,'Maintenance', 0,0,'position',[520,30,120, 25],'BackgroundColor',[1   0.3 0.1],'label','Maintenance');
        
        PushbuttonParam(obj,'Multi',       0,0,'position',[380,95,260,155],'BackgroundColor',[1   1   0.4],'label','Load Protocol');
        
        
        set(get_ghandle(FlushValves),'Fontsize',12,'visible','off');
        set(get_ghandle(UsingPucks), 'Fontsize',12); %#ok<NODEF>
        set(get_ghandle(ReplacePuck),'Fontsize',12,'ForegroundColor',[1,1,1]);
        set(get_ghandle(TestImplant),'Fontsize',12);
        set(get_ghandle(UpdateMode), 'Fontsize',12);
        set(get_ghandle(Maintenance),'Fontsize',12);
        set(get_ghandle(Multi),      'Fontsize',26);
        
        set_callback(FlushValves,{mfilename,'flush_valves'});
        set_callback(UsingPucks, {mfilename,'using_pucks'});
        set_callback(ReplacePuck,{mfilename,'replace_puck'});
        set_callback(TestImplant,{mfilename,'test_implant'});
        set_callback(UpdateMode, {mfilename,'updatemode_button'});
        set_callback(Maintenance,{mfilename,'rig_maintenance'});
        set_callback(Multi,      {mfilename,'multi_button'});
        
        %Hide the Test Implant button if this rig isn't set up to do this
        alldio=bSettings('get','DIOLINES','ALL');
        if isempty(alldio) || (sum(strcmp(alldio(:,1),'stim1'))  == 0 && sum(strcmp(alldio(:,1),'LASER')) == 0) &&...
                (sum(strcmp(alldio(:,1),'BLUE'))   == 0 && sum(strcmp(alldio(:,1),'GREEN')) == 0) &&...
                (sum(strcmp(alldio(:,1),'YELLOW')) == 0 && sum(strcmp(alldio(:,1),'RED'))   == 0)
            set(get_ghandle(TestImplant),'visible','off');
        end
        
        
        %Let's make the display areas
        DispParam(obj,'Instructions','',         0,0,'position',[10,57,630,35],'label','','labelfraction',0.005);
        DispParam(obj,'StatusBar',   techmessage,0,0,'position',[ 1, 1,650,30],'label','','labelfraction',0.003);
        
        %This is intended to be a copy of the instructions field which will
        %require the tech to click on if the experimenter wants it
        PushbuttonParam(obj,'Safety',            0,0,'position',[10,57,630,35],'label','');
        set_callback(Safety,{mfilename,'safety_button'});
        
        set(get_ghandle(Instructions),'Fontsize',14,'BackgroundColor',[1,0.8,0.6],'HorizontalAlignment','left','FontWeight','bold'); %#ok<NODEF>
        set(get_ghandle(StatusBar),   'Fontsize',14,'BackgroundColor',[0.9,0.9,1],'HorizontalAlignment','center'); %#ok<NODEF>
        set(get_ghandle(Safety),      'Fontsize',14,'BackgroundColor',[1,0.8,0.6],'HorizontalAlignment','left','FontWeight','bold','visible','off');
        
        if matlab_version_number < 9
            c = get(gcf,'children');
            set(c(end),'backgroundcolor',[1,0.8,0.6]);
            PanelBack.value = [c(end),get_ghandle(ExpLbl),get_ghandle(RatLbl),get_ghandle(Instructions)]; %#ok<STRNU> %get_ghandle(SchLbl) #ok<STRNU>
        else
            set(gcf,'color',[1,0.8,0.6]);
            PanelBack.value = [gcf,get_ghandle(ExpLbl),get_ghandle(RatLbl),get_ghandle(Instructions)]; %#ok<STRNU> %get_ghandle(SchLbl) #ok<STRNU>
        end
        
        %Time to make the rig maintenance screen
        confirmnote = {'If you repaired the rig, enter','your name and click FIXED.'};
        schedulenote = 'Run these rats in different rigs';
        try %#ok<TRYNC>
            labmembers = bdata('select experimenter from ratinfo.contacts where is_alumni=0');
            labmembers = unique(strtrim(labmembers));
            labmembers(2:end+1) = labmembers;
        end
        labmembers{1} = 'Select Name';
        
        DispParam(obj,'MaintenanceTitle','Rig is Broken',0,0,'position',[220,190,430, 60],'label','','labelfraction',0.01);
        DispParam(obj,'ScheduleNote',schedulenote,       0,0,'position',[  1,220,220, 30],'label','','labelfraction',0.01);
        DispParam(obj,'Schedule','',                     0,0,'position',[  1, 40,220,180],'label','','labelfraction',0.01);
        DispParam(obj,'RigTechNote','',                  0,0,'position',[220, 40,430,150],'label','','labelfraction',0.01);
        DispParam(obj,'ConfirmNote',confirmnote,         0,0,'position',[  1,  1,220, 40],'label','','labelfraction',0.01);
        MenuParam(obj,'LabMembersMenu',labmembers,     1,0,0,'position',[220,  1,283, 40],'labelfraction',0.01);
        PushbuttonParam(obj,'Fixed',                     0,0,'position',[500,  1,150, 40],'label','Fixed');
        
        set(get_ghandle(MaintenanceTitle),'Fontsize',32,'visible','off','BackgroundColor',[1,0,0],      'HorizontalAlignment','center');
        set(get_ghandle(ScheduleNote),    'Fontsize',12,'visible','off','BackgroundColor',[1,0.7,0.7],  'HorizontalAlignment','center');
        set(get_ghandle(Schedule),        'Fontsize',12,'visible','off','BackgroundColor',[1,0.7,0.7],  'HorizontalAlignment','left');
        set(get_ghandle(RigTechNote),     'Fontsize',12,'visible','off','BackgroundColor',[1,1,1],      'HorizontalAlignment','center');
        set(get_ghandle(ConfirmNote),     'Fontsize',12,'visible','off','BackgroundColor',[0.9,0.9,0.9],'HorizontalAlignment','center');
        set(get_ghandle(LabMembersMenu),  'Fontsize',24,'visible','off','BackgroundColor',[1,1,1]); %#ok<NODEF>
        set(get_ghandle(Fixed),           'Fontsize',24,'visible','off','BackgroundColor',[0,1,0],'enable','off');
        
        set_callback(LabMembersMenu,{mfilename,'select_labmember'});
        set_callback(Fixed,         {mfilename,'flag_rig_fixed'});
        
        %Let's make a fix comments screen
        EditParam(obj,      'RepairNote','',0,0,'position',[  1, 40,650,150],'label','','HorizontalAlignment','left','labelfraction',0.003);
        PushbuttonParam(obj,'Submit',       0,0,'position',[  1,  1,650, 40],'label','Submit');
        
        set(get_ghandle(RepairNote),'Fontsize',16,'visible','off','BackgroundColor',[1,1,1],'max',2);
        set(get_ghandle(Submit),    'Fontsize',24,'visible','off','BackgroundColor',[0,1,0],'enable','off');
        
        set_callback(RepairNote,{mfilename,'enter_repairnote'});
        set_callback(Submit,    {mfilename,'submit_rig_fixed'});
        
        
        %Let's clean up the unused labels
        temp = get_glhandle(Instructions);   set(temp(2),'visible','off');
        temp = get_glhandle(StatusBar);      set(temp(2),'visible','off');
        temp = get_glhandle(ConfirmNote);    set(temp(2),'visible','off');
        temp = get_glhandle(ScheduleNote);   set(temp(2),'visible','off');
        temp = get_glhandle(Schedule);       set(temp(2),'visible','off');
        temp = get_glhandle(LabMembersMenu); set(temp(2),'visible','off');
        
        %Last thing we need to make is a timer, boooooo, I don't like them
        %actually past self they're not that bad, you'll learn to like them
        scr = timer;
        set(scr,'Period', 0.2,'ExecutionMode','FixedRate','TasksToExecute',Inf,...
            'BusyMode','drop','TimerFcn',[mfilename,'(''End_Continued'')']);
        SoloParamHandle(obj, 'stopping_complete_timer', 'value', scr);
        
        %Update the runrats log
        runrats(obj,'updatelog','startup');
        
        %We are done building the GUI, let's update the session menu, figure
        %out what session we are in and load up that rat
        
        runrats(obj,'update_schedule');
        runrats(obj,'estimate_current_session');
        
        %Now that we know the schedule for this rig and what session we should
        %prepare to load, let's do it.
        runrats(obj,'update_exprat');
        runrats(obj,'check_rig_flushed');  
        
        %Before entering the live_loop let's clean up the desktop to make
        %runrats easier for techs to see.  Only do this once now so if
        %someone needs to work on a rig it doesn't keep closing things on
        %them.  Protocol figures are also minimized after a tech clicks run
        runrats(obj,'minimize_matlab_windows');
        
        %The autoload script starts runrats paused so we don't go to the
        %live loop and instead directly loads a rat's settings
        if ~isempty(varargin) && strcmp(varargin{1},'paused')
            runrats(obj,'updatemode_button',0);
        else
            runrats(obj,'live_loop');
        end
        
    case 'send_empty_state_machine'
        %% send_empty_state_machine
            
        state_machine_server = bSettings('get','RIGS','state_machine_server');
        
        server_slot = bSettings('get','RIGS','server_slot');
        if isnan(server_slot); server_slot = 0; end
        
        card_slot = bSettings('get', 'RIGS', 'card_slot');
        if isnan(card_slot); card_slot = 0; end
        
        if value(IsBpodRig) == 1 %#ok<NODEF>
            sm = BpodSM(state_machine_server, 3333,server_slot);
        else
            sm = RTLSM2(state_machine_server, 3333,server_slot);
        end
        sm = Initialize(sm);
        
        [inL,outL] = MachinesSection(dispatcher,'determine_io_maps');
        
        sma = StateMachineAssembler('full_trial_structure','use_happenings',1);
        sma = add_state(sma,'name','vapid_state_in_vapid_matrix');
        
        send(sma,sm,'run_trial_asap',0,'input_lines',inL,'dout_lines',outL,'sound_card_slot', int2str(card_slot));
       
        
    case 'check_calibration'
        %% check_calibration
        
        lastcalib = check_calibration;
        if ~isnan(lastcalib); calibage = now - datenum(lastcalib,'yyyy-mm-dd HH:MM:SS');
        else                  calibage = Inf;
        end
        
        CalibAge.value = calibage; %#ok<STRNU>
        days = floor(value(CalibExp) - calibage);
        hours = floor((value(CalibExp) - days - calibage) * 24);
        
        if exist('StatusBar','var') && calibage > value(CalibExp) && bSettings('get','WATER','skip_calibration_now') ~= 1
            %If calibration has expired close runrats and open calibration protocol
            dispatcher(value(dispobj),'set_protocol','WaterCalibration'); %#ok<NODEF>
            runrats(obj,'close_gui_only');
            return;
            
        elseif exist('StatusBar','var') && (calibage > value(CalibExp)- 6) && bSettings('get','WATER','skip_calibration_now') ~= 1
            %Calibration is not expired but old, so let's warn the tech it
            %will expire soon
            
            techmessage = value(StatusBar); %#ok<NODEF>
            tempF = strfind(techmessage,'flush');
            
            %Only update message if it's not already telling the tech to
            %flush the valves
            if isempty(tempF)
                tempC = strfind(techmessage,'Calibration will expire in');
                
                if ~isempty(tempC); techmessage(min(tempC):end) = ''; end
                
                lastchar = find(techmessage ~= ' ',1,'last');
                if ~isempty(lastchar) && lastchar < numel(techmessage)
                    techmessage(lastchar + 1:end) = '';
                end
                
                techmessage = [techmessage,'    Calibration will expire in ',...
                    num2str(days),' days ',num2str(hours),' hours'];
                
                StatusBar.value = techmessage;
            end
        end
        
        
        
    case 'live_loop'
        %% live_loop
        %Here we loop, updated the schedule and menus accordingly.
        
        %We do this so the DIO lines work
        runrats(obj,'send_empty_state_machine');
        
        InLiveLoop.value = 1;
        strt = now;
        donefirst = 0;
        while value(InLiveLoop) == 1
            %We only want to update every 30 seconds so we don't clog the
            %network but we want the loop to go fast to be responsive.
            if ((now - strt) * 24 * 60) > 0.5 || donefirst == 0
                disp(['RunRats Live Update at ',datestr(now,'HH:MM:SS')]);
                runrats(obj,'update_backcolor');
                runrats(obj,'update_schedule');
                runrats(obj,'estimate_current_session');
                runrats(obj,'update_exprat');
                runrats(obj,'check_rig_flushed');
                runrats(obj,'check_rig_broken');
                runrats(obj,'update_using_pucks_state');
                runrats(obj,'check_puck_expiration');
                
                if strcmp(get(get_ghandle(MaintenanceTitle),'string'),'Please wait while RunRats updates...')
                    set(get_ghandle(MaintenanceTitle),'string','Rig is Broken','BackgroundColor',[1 0 0]);
                elseif value(IsBroken) == 0 %#ok<NODEF>
                    %Only check for calibration if the rig is not broken
                    runrats(obj,'check_calibration');
                end
                
                strt = now;
                donefirst = 1;
            end
            pause(rand(1));
            runrats(obj,'flicker_puck_button');
            
        end
        if runrats('is_running')
            %disp(get(get_ghandle(Multi),'string'));
            if isempty(strfind(get(get_ghandle(Multi),'string'),'Run')) &&...
                    isempty(strfind(get(get_ghandle(Multi),'string'),'Unloading Test'))
                runrats(obj,'updatemode_button',0);
            end
        end
        
        
    case 'update_backcolor'
        %% update_backcolor
        %Sets the runrats background color to be peach if running normally
        %or blue if water calibration will expire soon
        
        h = value(PanelBack); %#ok<NODEF>
        for i = 1:length(h)
            if strcmp(get(h(i),'type'),'figure')
                propname = 'color';
            else
                propname = 'BackgroundColor';
            end
            if value(CalibAge) >= value(CalibExp)-4 %#ok<NODEF>
                set(h(i),propname,[0,0.8,1]);
            else
                set(h(i),propname,[1,0.8,0.6]);
            end
        end
                
                
    case 'updatemode_button'
        %% updatemode_button
        %The user has clicked the updatemode button, this will either take
        %us in or out of the live loop, we also need to change colors
        
        if     nargin > 2;                                                     forceto = varargin{1};
        elseif strcmp(get(get_ghandle(UpdateMode),'string'),'Live Update On'); forceto = 0;
        else                                                                   forceto = 1;
        end
        
        if forceto == 0
            set(get_ghandle(UpdateMode),'String','Update Paused','BackgroundColor',[1 0 0],'ForegroundColor',[0 0 0]);
            h = value(PanelBack); %#ok<NODEF>
            for i = 1:length(h)
                if strcmp(get(h(i),'type'),'figure')
                    propname = 'color';
                else
                    propname = 'BackgroundColor';
                end
                set(h(i),propname,[1,0.2,0.2]);
            end
            set(get_ghandle(Safety),'BackgroundColor',[1,0.2,0.2]);
            InLiveLoop.value = 0; %#ok<STRNU>
            
            %Use pause button as a hack to make dispatcher appear
            if bSettings('get','RIGS','bpod') == 1
                figure(2);
            else
                figure(1);
            end
        else
            h = value(PanelBack); %#ok<NODEF>
            for i = 1:length(h)
                if strcmp(get(h(i),'type'),'figure')
                    propname = 'color';
                else
                    propname = 'BackgroundColor';
                end
                set(h(i),propname,[1,0.8,0.6]);
            end
            set(get_ghandle(Safety),'BackgroundColor',[1,0.8,0.6]);
            set(get_ghandle(UpdateMode),'String','Live Update On','BackgroundColor',[0.6 1 0.6],'ForegroundColor',[0 0 0]);
            runrats(obj,'live_loop');
        end
        
        
        
    case 'letmenu_callback'
        %% letmenu_callback
        %The user has selected a different letter from the menu
        
        InLiveLoop.value = 0; %#ok<STRNU>
        runrats(obj,'update_num',1);
        
        
        
    case 'nummenu_callback'
        %% nummenu_callback
        %The user has selected a different number from the menu
        
        InLiveLoop.value = 0; %#ok<STRNU>
        runrats(obj,'update_rat',1);
        
        
        
    case 'schlist_callback'
        %% schlist_callback
        %The user has selected a different session from the schedule
        
        InLiveLoop.value = 0; %#ok<STRNU>
        runrats(obj,'update_exprat');
        
        
        
    case 'check_rig_flushed'
        %% check_rig_flushed
        %Check if the rig has been flushed today
%         
%         if ~isnan(value(RigID))
%             wf = bdata(['select wasflushed from ratinfo.rigflush where rig=',...
%                 num2str(value(RigID)),' and dateval="',datestr(now,'yyyy-mm-dd'),'"']);
%             if isempty(wf) || wf == 0
%                 %The rig has not been flushed
%                 StatusBar.value = 'Please flush the rig before loading the first rat today.';
%                 set(get_ghandle(Multi),'enable','off');
%                 wf = 0;
%             end
%         else
%             wf = nan;
%         end
%         WasFlushed.value = wf;
        
    %As of 2015-09-02 I am turning this feature off.  Possibly leading to
    %rats lossing motivation in session 1 if they can drink it. -Chuck
    
    WasFlushed.value = 1; %#ok<STRNU>
        
        
    
    case 'check_rig_broken'
        %% check_rig_broken
        %Here we determine if the rig has been flagged as broken.  If it is
        %we bring up the maintenance screen, if not we keep it as normal,
        %however, if we are entering a maintenance note we should skip this
        
        if value(DoingMaintenance) == 0 && ~isnan(value(RigID)) %#ok<NODEF>
            [note,isbroken,tech,notedate] = bdata('select note, isbroken, broke_person, broke_date from ratinfo.rig_maintenance where rigid="{S}"',value(RigID));
            
            fullnote = '';
            if ~isempty(note)
                recent_break = find(isbroken == 1,1,'last');
                if ~isempty(recent_break)
                    note     = note{recent_break};
                    isbroken = isbroken(recent_break);
                    tech     = tech{recent_break};
                    notedate = notedate{recent_break};
                    try %#ok<TRYNC>
                        fullnote = {['Note entered by ',tech,' on ',notedate],char(note)'};
                    end
                else
                    isbroken = 0;
                end
                
                set(get_ghandle(Fixed),'enable','off');
                
                if isbroken == 1; s = {'on','off'};
                else              s = {'off','on'};
                end
            else                  s = {'off','on'};
            end
            
            set(get_ghandle(MaintenanceTitle),'visible',s{1});
            set(get_ghandle(RigTechNote),     'visible',s{1},'string',fullnote);
            set(get_ghandle(ConfirmNote),     'visible',s{1});
            set(get_ghandle(LabMembersMenu),  'visible',s{1}); %#ok<NODEF>
            set(get_ghandle(Fixed),           'visible',s{1});
            set(get_ghandle(ScheduleNote),    'visible',s{1});
            set(get_ghandle(Schedule),        'visible',s{1});
            
            set(get_ghandle(Instructions),    'visible',s{2}); %#ok<NODEF>
            set(get_ghandle(StatusBar),       'visible',s{2}); %#ok<NODEF>
            set(get_ghandle(FlushValves),     'visible',s{2});
            set(get_ghandle(TestImplant),     'visible',s{2});
            set(get_ghandle(UpdateMode),      'visible',s{2});
            set(get_ghandle(Maintenance),     'visible',s{2});
            set(get_ghandle(Multi),           'visible',s{2});
            set(get_ghandle(ExpName),         'visible',s{2}); %#ok<NODEF>
            set(get_ghandle(LetMenu),         'visible',s{2}); %#ok<NODEF>
            set(get_ghandle(NumMenu),         'visible',s{2}); %#ok<NODEF>
            set(get_ghandle(SchList),         'visible',s{2}); %#ok<NODEF>
            set(get_ghandle(ExpLbl),          'visible',s{2});
            set(get_ghandle(RatLbl),          'visible',s{2});
            %set(get_ghandle(SchLbl),          'visible',s{2});
            
            
            %Hide the Test Implant button if this rig isn't set up to do this
            alldio=bSettings('get','DIOLINES','ALL');
            if isempty(alldio) || (sum(strcmp(alldio(:,1),'stim1')) == 0 && sum(strcmp(alldio(:,1),'LASER')) == 0)
                set(get_ghandle(TestImplant),'visible','off');
            end
            
            IsBroken.value = isbroken; %#ok<STRNU>
        end
        
        
        
    case 'select_labmember'
        %% select_labmember
        %If the user has selected their name we enable the fixed button
        
        if strcmp(value(LabMembersMenu),'Select Name') == 0 %#ok<NODEF>
            set(get_ghandle(Fixed),'enable','on');
        else
            set(get_ghandle(Fixed),'enable','off');
        end
        
        if ~strcmp(value(RepairNote),'') && ~strcmp(value(LabMembersMenu),'Select Name')
            set(get_ghandle(Submit),'enable','on');
        end
        
        
        
    case 'enter_repairnote'
        %% enter_repairnote
        %If the user has entered a note we can enable the Submit button
        
        if strcmp(value(RepairNote),'') || strcmp(value(LabMembersMenu),'Select Name') %#ok<NODEF>
            set(get_ghandle(Submit),'enable','off');
        else
            set(get_ghandle(Submit),'enable','on');
        end
        
        
        
    case 'flag_rig_fixed'
        %% flag_rig_fixed
        %The user has confirmed that the rig is fixed. Now we make them
        %enter comments about how they fixed it before going back to
        %runrats normal mode
        
        set(get_ghandle(MaintenanceTitle),'string','Enter how you fixed the rig, then click SUBMIT',...
            'BackgroundColor',[0.7,1,0.7],'FontSize',20);
        set(get_ghandle(RepairNote),'visible','on','string','');
        set(get_ghandle(Submit),    'visible','on','enable','off');
        
        
        
    case 'submit_rig_fixed'
        %% submit_rig_fixed
        %The user has entered comments.  Update the MySQL table and return
        %runrats to normal operation
        
        [id,isbroken] = bdata(['select maintenance_id, isbroken from ratinfo.rig_maintenance where rigid=',num2str(value(RigID))]);
        if ~isempty(id) && sum(isbroken) ~= 0
            %The rig was broken, let's add info to that MySQL entry
            temp = find(isbroken == 1,1,'last');
            id = id(temp);
            bdata('call ratinfo.mark_rigfixed("{S}","{S}","{S}","{S}")',id,value(LabMembersMenu),...
                datestr(now,'yyyy-mm-dd HH:MM'),value(RepairNote)); %#ok<NODEF>
            InLiveLoop.value = 1; %#ok<STRNU>
        else
            %We just did maintenance, make a new MySQL entry
            bdata(['insert into ratinfo.rig_maintenance set fix_person="',value(LabMembersMenu),...
                '", fix_note="',value(RepairNote),'", fix_date="',datestr(now,'yyyy-mm-dd HH:MM'),...
                '", rigid=',num2str(value(RigID))]); %#ok<NODEF>
        end
        
        set(get_ghandle(LabMembersMenu),'position',[220,  1,283, 40]);
        set(get_ghandle(Submit),        'position',[  1,  1,650, 40]);
        
        set(get_ghandle(RepairNote),    'visible','off','string','');
        set(get_ghandle(Submit),        'visible','off');
        set(get_ghandle(LabMembersMenu),'visible','off');
        
        set(get_ghandle(MaintenanceTitle),'string','Please wait while RunRats updates...',...
            'BackgroundColor',[0.7 0.7 0.7],'FontSize',20);
        
        DoingMaintenance.value = 0; %#ok<STRNU>
        LabMembersMenu.value   = 1;
        
        runrats(obj,'check_rig_broken');
        
        
    
    case 'update_num'
        %% update_num
        %The user selected a new letter from te menu, now we need to update
        %the numbers for extant rats with that letter, make the first
        %number blank so it's clear no rat has yet been selected
        
        allrats = value(AllRats);
        currlet = value(LetMenu); %#ok<NODEF>
        allnums{1} = '';
        for i = 1:numel(allrats);
            if allrats{i}(1) == currlet
                allnums{end+1} = allrats{i}(2:4); %#ok<AGROW>
            end
        end
        set(get_ghandle(NumMenu),'string',allnums); %#ok<NODEF>
        NumMenu.value = [];
        ExpName.value = ''; %#ok<STRNU>
    
        
        
    case 'update_rat'
        %% udpate_rat
        %Here we take the selected rat and checkout their settings if
        %necessary, update their settings, and update the tech instructions
        
        if isempty(value(NumMenu))    %#ok<NODEF>
            return;
        end
        
        %Determine who the experimenter is
        expname = bdata(['select experimenter from ratinfo.rats where ratname="',[value(LetMenu),sprintf('%03i',value(NumMenu))],'"']); %#ok<NODEF>
        ExpName.value = expname{1};
        
        runrats(obj,'disable_all');
        set(get_ghandle(Multi),'string',['Updating ',value(LetMenu),sprintf('%03i',value(NumMenu))],...
            'Backgroundcolor',[0.8 0.8 0.8],'fontsize',26);
        pause(0.1);
        
        dirCurrent  = cd;
        [dirData,errtmp] = bSettings('get','GENERAL','Main_Data_Directory');
        if errtmp || ~ischar(dirData) || isempty(dirData);
            return;
        end
        
        if ~exist(dirData,'dir')
            %We need to check out SoloData
        end
        cd(dirData);
        
        dirSettings = [dirData    ,filesep,'Settings'];
        dirExp      = [dirSettings,filesep,value(ExpName)];
        dirRat      = [dirExp     ,filesep,value(LetMenu),sprintf('%03i',value(NumMenu))];
        
        if ~exist(dirSettings,'dir')
            mkdir('Settings');
            if value(UseBucket)~= 1; 
                system('cvs add Settings'); 
            end
        end
        cd(dirSettings);
        
        if ~exist(dirExp,'dir')
            mkdir(value(ExpName));
            if value(UseBucket)~= 1; 
                system(['cvs add ' value(ExpName)]);
            end
        end
        cd(dirExp);
        
        if ~exist(dirRat,'dir');
            mkdir([value(LetMenu),sprintf('%03i',value(NumMenu))]);
            if value(UseBucket)~= 1; 
                system(['cvs add ',value(LetMenu),sprintf('%03i',value(NumMenu))]);
            end
        end
        cd(dirRat);
        
        %cvs no longer in use
        %if value(UseBucket)~= 1; 
        %    update_folder(pwd,'cvs');
        %else
        %    update_folder(pwd,'bucket');
        %end
        copy_recent_file_from_bucket(pwd)
        
        cd(dirCurrent);
        runrats(obj,'enable_all');
        set(get_ghandle(Multi),'string','Load Protocol','BackgroundColor',[1,1,0.4],'FontSize',26);
        
        if strcmp(value(CurrRat),[value(LetMenu),sprintf('%03i',value(NumMenu))]) %#ok<NODEF>
            if nargin < 3 || varargin{1} == 1
                InLiveLoop.value = 1; %#ok<STRNU>
            end
        else
            CurrRat.value = [value(LetMenu),sprintf('%03i',value(NumMenu))];
            
            %Let's see if this is a new rat, if so, warn the tech
            ratM = bdata(['select mass from ratinfo.mass where ratname="',[value(LetMenu),sprintf('%03i',value(NumMenu))],'"']);
            if length(ratM) < 14
                StatusBar.value = 'WARNING: New Rat!';
                set(get_ghandle(StatusBar),'fontweight','bold');
            else
                StatusBar.value = ['Ready to load ',[value(LetMenu),sprintf('%03i',value(NumMenu))]];
                set(get_ghandle(StatusBar),'fontweight','normal');
            end
        end
        
        runrats(obj,'update_tech_instructions');
        runrats(obj,'check_rig_flushed');
        
        
        
    case 'update_exprat'
        %% update_exprat
        %Here we update the Experimenter and Rat Menus to reflect the
        %selected entry in the Schedule List
        
        CurrSession.value = get(get_ghandle(SchList),'value'); %#ok<NODEF>
        currrat = [value(LetMenu),sprintf('%03i',value(NumMenu))]; %#ok<NODEF>
        
        ratsch = value(RatSch); %#ok<NODEF>
        if ~isnan(value(CurrSession))
            if value(CurrSession) <= 8
                SchList.value = value(CurrSession);
                StatusBar.value = ['Ready to load session ',num2str(value(CurrSession))]; %#ok<STRNU>
            else
                SchList.value = 10;
                StatusBar.value = 'All training session are done for today.'; %#ok<STRNU>
            end
            activerat = ratsch{value(CurrSession)};
        else
            activerat = '';
        end
        
        %Find the rat's experimenter, and set the experimenter and rat menus accordingly
        if ~isempty(activerat)
            exp = bdata(['select experimenter from ratinfo.rats where ratname="',activerat,'"']);
            LetMenu.value = activerat(1);
            runrats(obj,'update_num');
            NumMenu.value = activerat(2:4);
            ExpName.value = exp{1}; %#ok<STRNU>
        else
            ExpName.value = ''; %#ok<STRNU>
            LetMenu.value = '';
            NumMenu.value = [];
        end
        
        %runrats(obj,'update_ratmenu',activerat);
        runrats(obj,'update_tech_instructions');
        
        %If the rat has changed, let's update it.
        if ~strcmp([value(LetMenu),sprintf('%03i',value(NumMenu))],currrat)
            runrats(obj,'update_rat',value(InLiveLoop)); %#ok<NODEF>
        else
            %Stay in the loop if we haven't changed anything
            InLiveLoop.value = 1; %#ok<STRNU>
        end
        
        %runrats(obj,'updatelog','update_exprat');
        
        
        
    case 'update_tech_instructions'
        %% update_tech_instructions
        %Posts the tech instructions for the active rat on the screen
        
        if ~isempty(value(OptoPlugColor)) %#ok<NODEF>
            try delete(value(OptoPlugColor)); end %#ok<TRYNC>
        end
                
        if ~isempty([value(LetMenu),sprintf('%03i',value(NumMenu))]) %#ok<NODEF>
            [ti,sess] = bdata(['select instructions, timeslot from ratinfo.schedule where ratname="',...
                [value(LetMenu),sprintf('%03i',value(NumMenu))],'" and date="',datestr(now,'yyyy-mm-dd'),'"']);
            if iscell(ti) && numel(ti) > 1 % More than one session is scheduled for this rat.  Grab the appropriate tech instruction
                runrats(obj,'estimate_current_session');
                if isempty(value(CurrSession)) %#ok<NODEF>
                    ti = ti{1};
                elseif sum(sess==value(CurrSession)) == 1
                    ti = ti{sess==value(CurrSession)};
                else
                    ti = '';
                end
            elseif iscell(ti) && ~isempty(ti); ti = ti{1};
            else                           ti = '';
            end
            try
                if sum(ti=='#') >= 2 && rem(sum(ti=='#'),2)==0
                    %This may be a day specific message. Let's try to parse it
                    
                    if     strcmp(datestr(now,'ddd'),'Mon'); dayltr = 'm';
                    elseif strcmp(datestr(now,'ddd'),'Tue'); dayltr = 't';
                    elseif strcmp(datestr(now,'ddd'),'Wed'); dayltr = 'w';
                    elseif strcmp(datestr(now,'ddd'),'Thu'); dayltr = 'r';
                    elseif strcmp(datestr(now,'ddd'),'Fri'); dayltr = 'f';
                    elseif strcmp(datestr(now,'ddd'),'Sat'); dayltr = 's';
                    else   strcmp(datestr(now,'ddd'),'Sun'); dayltr = 'u';
                    end
                    
                    p = find(ti == '#');
                    
                    TI = ti(1:p(1)-1);
                    
                    for i = 1:2:numel(p)-1
                        d = ti(p(i)+1:p(i+1)-1);
                        if ~isempty(strfind(lower(d),dayltr))
                            %This portion of the instructions should be
                            %displayed today
                            msg = '';
                            if i+1==numel(p)
                                if numel(ti)>p(end); msg = ti(p(end)+1:end); end
                            else
                                msg = ti(p(i+1)+1:p(i+2)-1);
                            end
                            
                            TI = [TI,' ',msg]; %#ok<AGROW>
                        end
                    end
                    
                    fstltr = find(TI ~= ' ',1,'first');
                    if fstltr > 1; TI(1:fstltr-1) = ''; end
                    ti = TI;
                    
                end
            catch %#ok<CTCH>
                disp('Error while parsing tech instructions. Displaying everything.')
            end
            
            %Now let's check the instructions for the safety code
            d = find(ti == '$');
            s = '';
            if numel(d) > 1
                for i = 1:2:numel(d) - 1
                    temp = ti(d(i)+1:d(i+1)-1);
                    s(end+1:end+numel(temp)) = temp;
                end
            end
            if     ~isempty(strfind(s,'A')) && ~isempty(strfind(s,'B')) >  0; SafetyMode.value = 'AB'; %#ok<STRNU>
            elseif ~isempty(strfind(s,'A')) &&  isempty(strfind(s,'B')) == 0; SafetyMode.value = 'A'; %#ok<STRNU>
            elseif  isempty(strfind(s,'A')) && ~isempty(strfind(s,'B')) >  0; SafetyMode.value = 'B'; %#ok<STRNU>
            else                                                              SafetyMode.value = ''; %#ok<STRNU>
            end
            
            bad = [];
            if numel(d) > 1
                for i = 1:2:numel(d) - 1
                    bad(end+1:end+numel(d(i):d(i+1))) = d(i):d(i+1);
                end
            end
            ti(bad) = [];
            
            Instructions.value = ti; %#ok<STRNU>
            try  %#ok<TRYNC>
                OptoPlugColor.value = parse_optonote(ti); 
            end
        else
            Instructions.value = ''; %#ok<STRNU>
            SafetyMode.value = ''; %#ok<STRNU>
        end
        
        
        
    case 'disable_all'
        %% disable_all
        %Disable all the buttons.
        
        set(get_ghandle(ExpName),    'enable','off'); %#ok<NODEF>
        set(get_ghandle(LetMenu),    'enable','off'); %#ok<NODEF>
        set(get_ghandle(NumMenu),    'enable','off'); %#ok<NODEF>
        set(get_ghandle(SchList),    'enable','off'); %#ok<NODEF>
        set(get_ghandle(FlushValves),'enable','off');
        set(get_ghandle(UsingPucks), 'enable','off'); %#ok<NODEF>
        set(get_ghandle(ReplacePuck),'enable','off');
        set(get_ghandle(TestImplant),'enable','off');
        set(get_ghandle(UpdateMode), 'enable','off');
        set(get_ghandle(Maintenance),'enable','off');
        set(get_ghandle(Multi),      'enable','off');
        
        
        
    case 'enable_all'
        %% enable_all
        %Enable all the buttons.
        
        set(get_ghandle(ExpName),    'enable','on'); %#ok<NODEF>
        set(get_ghandle(LetMenu),    'enable','on'); %#ok<NODEF>
        set(get_ghandle(NumMenu),    'enable','on'); %#ok<NODEF>
        set(get_ghandle(SchList),    'enable','on'); %#ok<NODEF>
        set(get_ghandle(UsingPucks), 'enable','on'); %#ok<NODEF>
        set(get_ghandle(ReplacePuck),'enable','on');
        set(get_ghandle(FlushValves),'enable','on');
        set(get_ghandle(TestImplant),'enable','on');
        set(get_ghandle(UpdateMode), 'enable','on');
        set(get_ghandle(Maintenance),'enable','on');
        set(get_ghandle(Multi),      'enable','on');
        
        
        
    case 'flush_valves'
        %% flush_valves
        %This will open each water valve sequentially for 10 seconds
        
        runrats(obj,'disable_all');
        oldval=value(StatusBar); %#ok<NODEF>
        StatusBar.value='Flushing Each Valve for 10 seconds';
        
        %Let's find all the water valves
        alldio=bSettings('get','DIOLINES','ALL');
        diolist=[];
        skip_center = bSettings('get','WATER','skip_center_flush');
        if isnan(skip_center) || isempty(skip_center); skip_center = 0; end
        
        for di=1:size(alldio,1)
            if ~isempty(strfind(alldio{di,1},'water')) && ~isnan(alldio{di,2})
                if ~isempty(strfind(alldio{di,1},'center')) && skip_center == 1;
                    continue;
                end
                diolist=[diolist alldio{di,2}]; %#ok<AGROW>
            end
        end
        %Dispatcher needs the log of each DIO line
        diolist = log2(diolist);
        
        %Cycle through the list opening each for 10 seconds
        for i = 1:length(diolist)
            dispatcher('toggle_bypass',diolist(i)); 
            pause(10);
            dispatcher('toggle_bypass',diolist(i));
        end
        
        if strcmp(oldval,'Please flush the rig before loading the first rat today.')
            oldval = '';
        end
        StatusBar.value=oldval;
        runrats(obj,'enable_all');
        
        
        %Update MySQL to show this rig has been flushed today
        if ~isnan(value(RigID))
            id = bdata(['select id from ratinfo.rigflush where rig=',...
                num2str(value(RigID)),' and dateval="',datestr(now,'yyyy-mm-dd'),'"']);
            
            
            if isempty(id) || ~isnan(id)
                if isempty(id)
                    bdata(['insert into ratinfo.rigflush set rig=',num2str(value(RigID)),...
                        ', wasflushed=1, dateval="',datestr(now,'yyyy-mm-dd'),'"']);
                end
            end
        end
        WasFlushed.value = 1; %#ok<STRNU>
        
        
        
    case 'update_using_pucks_state'
        %% update_using_pucks_state
        
        if ~isnan(value(RigID))
            ups = bdata(['select foodpuck from ratinfo.rigtrials where rigid=',num2str(value(RigID))]);
            if isempty(ups); ups = 0; end
        else
            ups = 0;
        end
        
        UsingPucks.value = ups; %#ok<STRNU>
        
        
        
    case 'using_pucks'
        %% using_pucks
        
        if value(UsingPucks)==1 %#ok<NODEF>
            runrats(obj,'check_puck_expiration');
            bdata('call ratinfo.update_foodpuck("{Si}","{Si}")',1,value(RigID));
            runrats(obj,'updatelog','Using_Pucks');
        else
            set(get_ghandle(ReplacePuck),'enable','off','string','','backgroundcolor',[1 1 1],'foregroundcolor',[0.5,0.3,0.1]);
            set(get_ghandle(Multi),'Enable','on');
            bdata('call ratinfo.update_foodpuck("{Si}","{Si}")',0,value(RigID));
            runrats(obj,'updatelog','No_Pucks');
        end
        
        
        
    case 'check_puck_expiration'
        %% check_puck_expiration
        
        if value(UsingPucks)==1 %#ok<NODEF>
            lastchange = bdata(['select datetime from ratinfo.rigfood where rigid=',...
                num2str(value(RigID)),' order by rigfoodid desc limit 1']);
            
            if isempty(lastchange)
                h = 0;
            else
                h = value(PuckDuration) - floor((now - datenum(lastchange{1},'yyyy-mm-dd HH:MM:SS')) * 24);
            end
            
            if h <= 0; str =  'Replace NOW';                     set(get_ghandle(Multi),'Enable','off');
            else       str = ['Replace ',sprintf('%02i',h),'h']; set(get_ghandle(Multi),'Enable','on');
            end
            set(get_ghandle(ReplacePuck),'enable','on','string',str,'backgroundcolor',[0.5,0.3,0.1],'foregroundcolor',[1 1 1]);
        else
            set(get_ghandle(ReplacePuck),'enable','off','string','','backgroundcolor',[1 1 1],'foregroundcolor',[0.5,0.3,0.1]);
        end
        
        
        
    case 'flicker_puck_button'
        %% flicker_puck_button
        
        try %#ok<TRYNC>
            %We have to put this in a try catch because it may try to
            %flicker the button after the handle has been deleted during a
            %close request.
            s = get(get_ghandle(ReplacePuck),'string');
            if strcmp(s,'Replace NOW');
                b = get(get_ghandle(ReplacePuck),'backgroundcolor');
                f = get(get_ghandle(ReplacePuck),'foregroundcolor');

                set(get_ghandle(ReplacePuck),'backgroundcolor',1-b,'foregroundcolor',1-f);
            end
        end
            
        
        
    case 'replace_puck'
        %% replace_puck
        
        %mym(bdata,['insert into ratinfo.rigfood set rigid=',num2str(value(RigID)),', datetime="',datestr(now,'yyyy-mm-dd HH:MM:SS'),'"']);
        bdata('call ratinfo.replace_foodpuck("{Si}","{S}")',value(RigID),datestr(now,'yyyy-mm-dd HH:MM:SS'))
        runrats(obj,'using_pucks');
        runrats(obj,'updatelog','replace_puck');
        
        
        
    case 'get_foodpuck_state'
        %% get_foodpuck_state
        
        obj = value(UsingPucks); %#ok<NODEF>
        
        
        
    case 'test_implant'
        %% test_implant
        %This will toggle all the stim and laser lines to test a rats
        %implant before running
        
        %Check to see if the multi button is already disabled
        if strcmp(get(get_ghandle(Multi),'enable'),'off')
            disablemulti = 1;
        else
            disablemulti = 0;
        end
        
        runrats(obj,'disable_all');
        oldval=value(StatusBar); %#ok<NODEF>
        StatusBar.value='Testing Implant. Please Observe Rat';
        
        cbr = bSettings('get','RIGS','cerebrorig');
        if isnan(cbr); cbr = 0; end
        
        if cbr == 1
            %This is a Cerebro Rig
            if ischar(value(CurrProtocol)) %#ok<NODEF>
                %We've loaded a protocol, it should have a cerebro section
                try
                    tempobj = eval(value(CurrProtocol));
                    if ~isempty(tempobj) && CerebroSection(tempobj,'is_connected');
                        %We have a connected cerebro base station
                        z = tic;
                        
                        %Send a reboot signal since it probably didn't go
                        %through when the protocol loaded.
                        CerebroSection(tempobj,'set_did_read',0);
                        CerebroSection(tempobj,'reboot');
                        
                        %Now pause until we successfully heard back
                        x = tic;
                        while CerebroSection(tempobj,'get_did_read') == 0
                            pause(0.1);
                            if toc(x) > 10
                                %still no cerebro in range
                                break
                            end
                        end
                        
                        %Send a 10mW 500ms bilateral pulse
                        specs.power = [10 10];
                        specs.pulse = 0;
                        specs.freq  = 0;
                        specs.dur   = 0.5;
                        
                        CerebroSection(tempobj,'set_did_read',0);
                        CerebroSection(tempobj,'send_stim_specs',specs);
                        x = tic;
                        while CerebroSection(tempobj,'get_did_read') == 0
                            pause(0.1);
                            if toc(x) > 10
                                %still no cerebro in range
                                break
                            end
                        end
                        
                        %let's guarantee a 3s pause between clicking the
                        %button and the laser pusling.
                        pause(3-toc(z));
                        
                        %get the laser line and toggle it on for 500ms
                        laserline = log2(bSettings('get','DIOLINES','LASER'));
                        dispatcher('toggle_bypass',laserline);
                        pause(0.5);
                        dispatcher('toggle_bypass',laserline);
                        pause(0.1);
                        
                        %reset the stim to 0
                        specs.power = [0 0];
                        specs.pulse = 0;
                        specs.freq  = 0;
                        specs.dur   = 0;
                        
                        CerebroSection(tempobj,'set_did_read',0);
                        CerebroSection(tempobj,'send_stim_specs',specs);
                        pause(1);
                    end
                    
                catch
                    disp('ERROR testing Cerebro implant');
                end
            end
        else

            %Let's find all the stim lines
            alldio=bSettings('get','DIOLINES','ALL');
            diolist=[];
            for di=1:size(alldio,1)
                if (~isempty(strfind(alldio{di,1},'LASER'))  ||...
                        ~isempty(strfind(alldio{di,1},'GREEN'))  ||...
                        ~isempty(strfind(alldio{di,1},'BLUE'))   ||...
                        ~isempty(strfind(alldio{di,1},'YELLOW')) ||...
                        ~isempty(strfind(alldio{di,1},'RED')))   &&...
                        ~isnan(alldio{di,2})
                    diolist=[diolist alldio{di,2}]; %#ok<AGROW>
                end
            end
            %Dispatcher needs the log of each DIO line
            diolist = log2(diolist);

            %Call dispatcher to toggle the stim lines in succession
            pause(3);
            for i = 1:length(diolist)
                dispatcher('toggle_bypass',diolist(i));
                pause(0.2);
                dispatcher('toggle_bypass',diolist(i));
                pause(0.5);
            end
        end
        
        StatusBar.value=oldval;
        runrats(obj,'enable_all');
        runrats(obj,'check_rig_flushed');
        
        if disablemulti == 1
            set(get_ghandle(Multi),'enable','off');
        end
        
        runrats(obj,'updatelog','testimplant');
        
        
        
    case 'rig_maintenance'
        %% rig_maintenance
        %The user wants to enter some comments about maintenance they
        %performed on the rig.
        
        set(get_ghandle(StatusBar),'visible','off'); %#ok<NODEF>
        
        set(get_ghandle(MaintenanceTitle),'visible','on','string','Enter a description of the maintenance performed:','BackgroundColor',[1 0.3 0.1],'Fontsize',20);
        set(get_ghandle(RepairNote),      'visible','on');
        set(get_ghandle(Submit),          'visible','on','position',[325,1,325,40]);
        set(get_ghandle(LabMembersMenu),  'visible','on','position',[  1,1,325,40]); %#ok<NODEF>
        DoingMaintenance.value = 1; %#ok<STRNU>
        
        
        
%     case 'update_ratmenu'
%         %% update_ratmenu
%         %Here we get the list of extant rats for the selected experimenter
%         %and populate the rat menu with it
%         
%         exp = value(ExpMenu);
%         currats = get(get_ghandle(RatMenu),'string'); %#ok<NODEF>
%         
%         if strcmp(exp,'')
%             ratnames = {''};
%         else
%             ratnames = bdata(['select ratname from ratinfo.rats where experimenter="',exp,'" and extant=1']);
%             ratnames = sortrows(strtrim(ratnames));
%         end
%         
%         %If we've changed things, update the menus accordingly
%         if length(currats) ~= length(ratnames) || ~strcmp(currats{1},ratnames{1}) ||...
%                 (nargin > 2 && ~strcmp(varargin{1},value(RatMenu)))
%             set(get_ghandle(RatMenu),'string',ratnames,'value',1);
%             
%             %If we passed in a rat name, set the manu to it
%             if nargin > 2; RatMenu.value = varargin{1};
%             else           RatMenu.value = ratnames{1};
%             end
%             
%             runrats(obj,'update_rat');
%         else
%             %Stay in the loop if we haven't changed anything
%             InLiveLoop.value = 1;
%         end
        
        
        
    case 'update_schedule'
        %% update_schedule
        %Here we grab the current schedule for this rig
        
        if ~isnan(value(RigID));
            [rats,slots] = bdata(['select ratname, timeslot from ratinfo.schedule where date="',...
                datestr(now,'yyyy-mm-dd'),'" and rig=',num2str(value(RigID))]);
        end
        
        %Let's populate the 9 training sessions
        ratsch = cell(10,1); for i=1:10; ratsch{i} = ''; end
        sch    = cell(10,1);
        
        sch{1}  = '1)  0:00- 2:30: ';
        sch{2}  = '2)  2:40- 5:10: ';
        sch{3}  = '3)  5:20- 7:50: ';
        sch{4}  = '4)  8:00-10:30: ';
        sch{5}  = '5) 10:40- 1:10: ';
        sch{6}  = '6)  1:20- 3:50: ';
        sch{7}  = '7)  4:00- 6:30: ';
        sch{8}  = '8)  6:40- 9:10: ';
        sch{9}  = '9)  9:20-11:50: ';
        sch{10} = '';
        
        if ~isnan(value(RigID))
            for i = 1:9
                temp = slots==i;
                if sum(temp) == 1
                    ratsch{i} = rats{temp};
                    sch{i} = [sch{i},ratsch{i}];
                end
            end
        end
        set(get_ghandle(Schedule),'string',sch(1:9));
        set(get_ghandle(SchList),'string',sch); %#ok<NODEF>
        RatSch.value = ratsch; %#ok<STRNU>
        
        
        
    case 'estimate_current_session'
        %% estimate_current_session
        %Here we will try to estimate which session is currently training
        
        CS = value(CurrSession); %#ok<NODEF>
        
        [ratSCH,slots] = bdata(['select ratname, timeslot from ratinfo.schedule where date="',...
            datestr(now,'yyyy-mm-dd'),'"']);
        ratSES = bdata(['select ratname from sessions where sessiondate="',datestr(now,'yyyy-mm-dd'),'"']);
        [ratSS,ST]  = bdata(['select ratname, starttime from sess_started where sessiondate="',...
            datestr(now,'yyyy-mm-dd'),'"']);
        
        %Let's cycle through each of the 9 training sessions and see if the
        %rats are started, done, or neither
        COMP = zeros(9,1);
        for i = 1:9
            currats = ratSCH(slots == i);
            currats(strcmp(currats,'')) = [];
            comp = zeros(size(currats));
            st   = zeros(size(currats)); st(:) = nan;
            for j = 1:length(currats)
                if     sum(strcmp(ratSES,currats{j})) > 0; comp(j) = 2; %rat finished
                elseif sum(strcmp(ratSS, currats{j})) > 0; comp(j) = 1; %rat running
                    st(j) = datenum(ST{find(strcmp(ratSS, currats{j})==1,1,'first')},'HH:MM:SS');
                end
            end
            
            if isempty(currats);                    COMP(i) = nan; %no rats in session
            elseif sum(comp == 2) >= numel(comp)/2; COMP(i) = 2; %session is likely completed
            elseif sum(comp  > 0) >= numel(comp)/2; COMP(i) = 1; %session is likely running
            else,                                   COMP(i) = 0; %session not yet started
            end
            
            %If the session is still running, let's see how long they've been in.
            if COMP(i) == 1
                st = (datenum(datestr(now,'HH:MM:SS')) - nanmean(st)) * 24 * 60;
                if st > 60; COMP(i) = 2; end
            end
        end
        
        lastcomp = find(COMP == 2,1,'last');
        if isempty(lastcomp); lastcomp = 0; end
        
        firstreal = find(~isnan(COMP) == 1,1,'first'); %first session with rats schedules
        lastreal  = find(~isnan(COMP) == 1,1,'last');  %last session with rats schedules
        
        if lastcomp < lastreal
            nextreal = find(~isnan(COMP(lastcomp+1:end)) == 1,1,'first') + lastcomp;
            if isempty(nextreal); nextreal = []; end
        end
            
        if     lastcomp == 0;        CurrSession.value = firstreal;
        elseif lastcomp == lastreal; CurrSession.value = [];
        else,                        CurrSession.value = nextreal;
        end
        
        %In the event the system thinks we've finished the last session but there are
        %sessions earlier that aren't completed, let's find the first not
        %completed session and make that the current session.
        if isempty(value(CurrSession))
            notcomp = find(COMP ~= 2 & ~isnan(COMP) == 1,1,'first');
            if ~isempty(notcomp)
                CurrSession.value = notcomp;
            end
        end
        
        %CurrSession.value = find(COMP ~= 2,1,'first');
        SchList.value = value(CurrSession);
        
        if isempty(value(CurrSession)) || isempty(CS) || value(CurrSession) ~= CS
            %CurrSession is empty if we've finished all training for the
            %day. 1st update after session 9 deemed finished CS will not be
            %empty. 1st update after midnight CS will be empty but
            %CurrSession will be 1.
            disp('Updating Current Session');
            
            if ~isempty(value(CurrSession)) && ~isempty(CS)
                runrats(obj,'updatelog','update_session');
            end
            
            never_reboot = bSettings('get','RUNRATS','never_reboot');
            if isnan(never_reboot)
                never_reboot = 0;
            end
                
            if (isempty(value(CurrSession)) && ~isempty(CS) && CS == lastreal) && never_reboot == 0 %|| (value(CurrSession) == 7 && CS == 6)
                %Training for today is nearing its end but this rig is
                %likely not running a rat in sthe last session or it's already out.
                %Let's do the daily reboot for this rig here.
                runrats(obj,'reboot')
            end
            
        end
        
        
        
    case 'safety_button'
        %% safety_button
        %The user had clicked the safety button which will unlock the multi
        %button
        
        set(get_ghandle(Multi),'enable','on');
        
        
        
    case 'minimize_matlab_windows'
        %% minimize_matlab_windows
        %Let's try to minimize all windows except RunRats to clean up the
        %desktop. This way techs can spot problems with RunRats easier

        %I'm commenting this out until I can figure out how to make it work
        %properly and why it failed on 8/4/2017 but passed testing on rig 1
%         try
%             %This code depends on undocumented Java code which may or noy
%             %not work on different versions of matlab, best to put in a try
%             %catch
%             
%             %if value(RigID) <= 40
%                 %Here we minimize Matlab figure windows
%                 otherfigs = get(0,'children');
%                 otherfigs(otherfigs == value(myfig)) = [];
%                 for i = 1:numel(otherfigs);
%                     jf = get(otherfigs(i),'JavaFrame');
%                     if get(jf,'Minimized') == 0
%                         set(jf,'Minimized',1);
%                     end
%                 end
% 
%                 desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
% 
%                 %here we minimize the editor
%                 try
%                     %editor may not be open so put in try in case it's not
%                     jEditor = desktop.getGroupContainer('Editor').getTopLevelAncestor;
%                     set(jEditor,'minimized','on');
%                 end
% 
%                 %here we minimize the command window
%                 mainFrame = desktop.getMainFrame;
%                 mainFrame.setMinimized(1);
%             %end
%         end



    case 'start_video'
        %% start_video
        
        currpath = pwd;
        try
            vlc_path      = bSettings('get','VIDEO','vlc_path');
            record_string = bSettings('get','VIDEO','record_string');
            stream_string = bSettings('get','VIDEO','stream_string');
            video_path    = bSettings('get','VIDEO','video_path');
            
            if ischar(vlc_path)      && ischar(record_string) &&...
               ischar(stream_string) && ischar(video_path)
           
                ratname=[value(LetMenu),sprintf('%03i',value(NumMenu))]; %#ok<NODEF>

                video_file_path = [video_path,filesep,value(ExpName),filesep,ratname,filesep]; %#ok<NODEF>
                if ~exist(video_file_path,'dir')
                    mkdir(video_file_path);
                end
                cd(video_file_path);
                LTR = 'abcdefghijklmnopqrstuvwxyz';
                for i = 1:numel(LTR)
                    x = dir(['*',datestr(now,'yymmdd'),LTR(i),'.mp4']);
                    if isempty(x); break; end
                end
                video_file = [ratname,'_',datestr(now,'yymmdd'),LTR(i),'.mp4'];
                VideoFile.value = [video_file_path,video_file]; %#ok<STRNU>

                cd(vlc_path); 
                system(['vlc -vvv ',record_string,' ',...
                     '--sout ',video_file_path,video_file,' &']); 
                pause(1); 
                system(['vlc -vvv ',stream_string,' &']);
                
                for camera = 2:10
                    %allows for up to 9 additional cameras
                    new_record_string = bSettings('get','VIDEO',['record_string',num2str(camera)]);
                    new_stream_string = bSettings('get','VIDEO',['stream_string',num2str(camera)]);

                    if ischar(new_record_string) && ischar(new_stream_string)
                        %additional camera found
                        video_file = [video_file(1:end-4),num2str(camera),'.mp4'];

                        pause(1)
                        system(['vlc -vvv ',new_record_string,' ',...
                            '--sout ',video_file_path,video_file,' &']); 
                        pause(1); 
                        system(['vlc -vvv ',new_stream_string,' &']);
                        
                        eval(['VideoFile',num2str(camera),'.value = [video_file_path,video_file];']);
                    else
                        %no camera found
                        break
                    end
                end

            else
                disp('Video recording not started because settings are missing.');
            end
        catch
            disp('Failed to start video recording.');
        end
        
        cd(currpath);
        try figure(value(myfig)); end %#ok<TRYNC>

        
        
    case 'end_video'
        %% end_video
        
        system('taskkill /im vlc.exe');
        pause(20); %ensure video is stopped before write starts
        try
            write_video_network(value(VideoFile)); %#ok<NODEF>
            for i = 2:10
                video_file = eval(['value(VideoFile',num2str(i),')']);
                if ~isempty(video_file)
                    write_video_network(video_file);
                else
                    break;
                end
            end
        catch
            disp('Failed to write video file to the network');
        end
        
        
        
    case 'multi_button'
        %% multi_button
        %The user has clicked the Multi purpose button, depending on what
        %state runrats is in, this button will do different things. Let's
        %figure out what to do here.
        
        if     strcmp(get(get_ghandle(Multi),'string'),'Load Protocol')
            runrats(obj,'begin_load_protocol');
            
        elseif ~isempty(strfind(get(get_ghandle(Multi),'string'),'Run'))
            runrats(obj,'run');
            
        elseif ~isempty(strfind(get(get_ghandle(Multi),'string'),'End Session'))
            runrats(obj,'end');
            
        elseif ~isempty(strfind(get(get_ghandle(Multi),'string'),'Crashed'))
            runrats(obj,'crash_cleanup');
            
        end
        
        
        
    case 'begin_load_protocol'
        %% begin_load_protocol
        %Let's unload any protocols from dispatcher and either do the
        %manual test or skip right to loading the protocol depending on the
        %rig's settings
        
        InLiveLoop.value = 0; %#ok<STRNU>
        runrats(obj,'disable_all');
        
        set(get_ghandle(Multi),'string','Unloading...','fontsize',28);
        
        x = '';
        try x = dispatcher(value(dispobj),'get_protocol_object'); end %#ok<NODEF,TRYNC>
        if ~isempty(x)
            %There was a protocol previously open. Let's not trust that
            %their close section is working properly.
            try  %#ok<TRYNC>
                p = bSettings('get','GENERAL','Main_Code_Directory');
                p(strfind(p,'ExperPort'):end) = '';
                p = [p,'Rigscripts'];
                cd(p);
                if ispc == 1
                    system('restart_runrats.bat');
                end
            end
        end
        
        dispatcher(value(dispobj),'set_protocol','');
        if bSettings('get','RUNRATS','skip_manual_test') == 1
            runrats(obj,'load_protocol');
        else
            runrats(obj,'manual_test');
        end
        
        
        
    case 'manual_test'
        %% manual_test
        %Load and run the manual test protocol
        
        set(get_ghandle(Multi),'string','Loading Test','fontsize',28);
        
        r = rand(1);
        if r < 0.005 && value(RigID) < 40
            runrats(obj,'updatelog','manualtest_leftfail');
            ManualTestFail.value = 'left'; %#ok<STRNU>
            dispatcher(value(dispobj),'set_protocol','Rigtest_singletrial_leftfail'); %#ok<NODEF>
        elseif r < 0.01 && value(RigID) < 40
            runrats(obj,'updatelog','manualtest_rightfail');
            ManualTestFail.value = 'right'; %#ok<STRNU>
            dispatcher(value(dispobj),'set_protocol','Rigtest_singletrial_rightfail'); %#ok<NODEF>
        else
            runrats(obj,'updatelog','manualtest');
            ManualTestFail.value = 'none'; %#ok<STRNU>
            dispatcher(value(dispobj),'set_protocol','Rigtest_singletrial'); %#ok<NODEF>
        end,
        %Hide protocol window.
        h=get_sphandle('owner','Rigtest_singletrial','name', 'myfig');
        for i=1:numel(h); set(value(h{i}),'Visible','Off'); end
        
        set(get_ghandle(Multi),'String','Manual Test','Fontsize',28);
        StatusBar.value='Please test the rig by poking in the lit pokes.'; %#ok<STRNU>
        
        %Begin execution of the manual test protocol.
        dispatcher(value(dispobj),'Run');
        
        %RigTest_singletrial will call runrats('rigtest_singletrial_is_complete')
        %after it finishes one trial at which point we continue on
        
        
        
    case 'rigtest_singletrial_is_complete'
        %% rigtest_singletrial_is_complete
        %The manual test is complete, let's clear out the protocol and move
        %on to load the rat's protocol and settings
        
        set(get_ghandle(Multi),'String','Unloading Test','Fontsize',26);
        StatusBar.value='Completing Test. Please be patient!'; %#ok<STRNU>
        
        dispatcher(value(dispobj),'Stop'); %#ok<NODEF>
        
        %Let's pause until we know dispatcher is done running
        set(value(stopping_complete_timer),'TimerFcn',[mfilename,'(''rigtest_singletrial_is_complete_continued'');']);
        start(value(stopping_complete_timer));
        
        
        
    case 'rigtest_singletrial_is_complete_continued',
        %% rigtest_singletrial_is_complete_continued
        if value(stopping_process_completed) %This is provided by dispatcher to runrats
            stop(value(stopping_complete_timer)); %Stop looping.
            dispatcher(value(dispobj),'set_protocol',''); %#ok<NODEF>
            runrats(obj,'load_protocol');
        end  
        
        
        
    case 'load_protocol'
        %% load_protocol
        %Okay, we are finally ready to load the protocol and the rats
        %settings, runrats will then wait for the tech to click Run
        
        runrats(obj,'updatelog','Load_Start');
        
        %Let's make sure we have the most up-to-date settings
        runrats(obj,'update_rat',0);
        
        set(get_ghandle(Multi),'String','Loading...','BackgroundColor', [0.8 0.8 0.6],'Fontsize',30);
        StatusBar.value='Loading protocol and settings.  Please be patient!';
        pause(0.1);
        
        %Let's also make sure we have the most up-to-date code
        CurrDir = pwd;
        update_folder(bSettings('get','GENERAL','Main_Code_Directory'));
        
        %And finally we make sure the protocols are up-to-date
        update_folder(bSettings('get','GENERAL','Protocols_Directory'));
        cd(CurrDir);
        
        %Let's get the protocol for the rat and load it
        CurrProtocol.value = getProtocol(value(ExpName),[value(LetMenu),sprintf('%03i',value(NumMenu))]); %#ok<NODEF>
        if isempty(value(CurrProtocol))
            StatusBar.value = ['No Settings for ',value(LetMenu),sprintf('%03i',value(NumMenu))]; %#ok<STRNU>
            runrats(obj,'enable_all');
            set(get_ghandle(Multi),'string','NO Settings','BackgroundColor',[0,0,0],'ForegroundColor',[1,1,1],'FontSize',26);
            InLiveLoop.value = 1; %#ok<STRNU>
            
            %Let's notify the experimenter that the load failed, pause to
            %let the tech see the note, then go back to live loop
            runrats(obj,'email_experimenter','no settings');
            
            runrats(obj,'updatelog','nosettings');
            
            pause(120);
            
            set(get_ghandle(Multi),'string','Load Protocol','BackgroundColor',[1,1,0.4],'ForegroundColor',[0,0,0],'FontSize',26);
            runrats(obj,'live_loop');
            return;
        end
        
        try
            dispatcher(value(dispobj),'set_protocol',value(CurrProtocol)); %#ok<NODEF>
        catch %#ok<CTCH>
            StatusBar.value = ['Failed to load ',value(CurrProtocol),' for ',value(LetMenu),sprintf('%03i',value(NumMenu))]; %#ok<STRNU>
            runrats(obj,'enable_all');
            set(get_ghandle(Multi),'string','LOAD FAIL','BackgroundColor',[0,0,0],'ForegroundColor',[1,1,1],'FontSize',26);
            InLiveLoop.value = 1; %#ok<STRNU>
            
            %Let's notify the experimenter that the load failed, pause to
            %let the tech see the note, then go back to live loop
            runrats(obj,'email_experimenter','protocol fail');
            
            runrats(obj,'updatelog','failload protocol');
            
            pause(120);
            
            set(get_ghandle(Multi),'string','Load Protocol','BackgroundColor',[1,1,0.4],'ForegroundColor',[0,0,0],'FontSize',26);
            
            runrats(obj,'live_loop');
            try send_n_done_trials(obj,'reset'); end %#ok<TRYNC>
            return;
        end
        
        rath=get_sphandle('name','ratname','owner',value(CurrProtocol));
        exph=get_sphandle('name','experimenter','owner',value(CurrProtocol));
        rath{1}.value=[value(LetMenu),sprintf('%03i',value(NumMenu))]; %#ok<NASGU>
        exph{1}.value=value(ExpName); %#ok<NASGU>
        
        % now load settings (success flag from load_solouiparamvalues now required)
        try
            protobj=eval(value(CurrProtocol));
            
            [out, sfile]=load_solouiparamvalues([value(LetMenu),sprintf('%03i',value(NumMenu))],'experimenter',value(ExpName),...
                'owner',class(protobj),'interactive',0,'require_success',true); %#ok<ASGLU> 
            settings_file_sph.value = sfile; %#ok<STRNU>
            settings_file_load_time.value = now;
            if ~dispatcher(value(dispobj),'is_running')
                pop_history(class(protobj), 'include_non_gui', 1);
                feval(value(CurrProtocol), protobj, 'prepare_next_trial');
            end
            
        catch %#ok<CTCH>
            StatusBar.value = 'Failed to load Settings file.'; %#ok<STRNU>
            runrats(obj,'enable_all');
            set(get_ghandle(Multi),'string','LOAD FAIL','BackgroundColor',[0,0,0],'ForegroundColor',[1,1,1],'FontSize',26);
            InLiveLoop.value = 1; %#ok<STRNU>
            
            %Let's notify the experimenter that the load failed, pause to
            %let the tech see the note, then go back to live loop
            runrats(obj,'email_experimenter','settings fail');
            
            runrats(obj,'updatelog','failload settings');
            
            pause(120);
            
            set(get_ghandle(Multi),'string','Load Protocol','BackgroundColor',[1,1,0.4],'ForegroundColor',[0,0,0],'FontSize',26);
            runrats(obj,'live_loop');
            try send_n_done_trials(obj,'reset'); end %#ok<TRYNC>
            return;
        end
        
        set(get_ghandle(Multi),'String',['Run: ',value(LetMenu),sprintf('%03i',value(NumMenu))],'BackgroundColor',[0.3,1,0.3],'Fontsize',36);
        
        try
            [pname,fname,ext,v] = fileparts(sfile); %#ok<ASGLU,NASGU>
        catch
            [pname,fname,ext] = fileparts(sfile); %#ok<ASGLU,NASGU>
        end
        
        StatusBar.value=fname; %#ok<STRNU>
        if value(phys)==1
            create_phys_session(eval(value(CurrProtocol)))
        end
        
        runrats(obj,'enable_all');
        figure(value(myfig));
        InLiveLoop.value = 0; %#ok<STRNU>
        
        %Check to see if the experimenter wants to enable the safety before
        if ~isempty(strfind(value(SafetyMode),'B')) %#ok<NODEF>
            set(get_ghandle(Multi),'enable','off');
            set(get_ghandle(Safety),'visible','on','string',value(Instructions)); %#ok<NODEF>
        else
            set(get_ghandle(Multi),'enable','on');
            set(get_ghandle(Safety),'visible','off','string','');
        end
        
        %Turn this on if you want to notify techs when they don't catch a
        %manual test water fail test
        %if ~strcmp(value(ManualTestFail),'none') %#ok<NODEF>
        %    %The rig failed and the tech probably didn't notice
        %    pause(20);
        %    runrats(obj,'redo_manual_test');
        %end
        runrats(obj,'updatelog','Load_End');
        try send_n_done_trials(obj,'reset'); end %#ok<TRYNC>
        
        
    case 'redo_manual_test'
        %% redo_manual_test
        %The tech likely failed to notice one of the ports was not
        %dispensing water. Let's reload that test so they can see it
        
        set(get_ghandle(Multi),'string','Test Fail','BackgroundColor',[1,0,1],'fontsize',28);
        dispatcher(value(dispobj),'set_protocol',''); %#ok<NODEF>
        
        if strcmp(value(ManualTestFail),'left') %#ok<NODEF>
            set(get_ghandle(Multi),'string','Left Fail','BackgroundColor',[1,0,1],'fontsize',28);
            dispatcher(value(dispobj),'set_protocol','Rigtest_singletrial_leftfail'); 
        elseif strcmp(value(ManualTestFail),'right')
            set(get_ghandle(Multi),'string','Right Fail','BackgroundColor',[1,0,1],'fontsize',28);
            dispatcher(value(dispobj),'set_protocol','Rigtest_singletrial_rightfail');
        end
        
        %Hide protocol window.
        h=get_sphandle('owner','Rigtest_singletrial','name', 'myfig');
        for i=1:numel(h); set(value(h{i}),'Visible','Off'); end
        
        StatusBar.value=['The ',value(ManualTestFail),' port failed on purpose but was not caught.']; %#ok<STRNU>
        
        runrats(obj,'updatelog','manualtest_redo');
        
        %Begin execution of the manual test protocol.
        dispatcher(value(dispobj),'Run');
        
        
        
    case  'run'
        %% run
        %Here we start the protocol running
        set(get_ghandle(Multi),'String','End Session','BackgroundColor',[1,0.2,0.2],'Fontsize',30);
        StatusBar.value = ['Start: ',datestr(now,'HH:MM PM'),'. ',value(StatusBar)]; %#ok<NODEF>
        
        runrats(obj,'updatelog','runstart');
        runrats(obj,'disable_all');
        
        try
            sendstarttime(eval(value(CurrProtocol))); %#ok<NODEF>
            bdata('call ratinfo.update_rigtrials_lastupdate("{S}","{Si}")',datestr(now,'HH:MM:SS'),value(RigID));
        catch %#ok<CTCH>
            disp('ERROR: Failed to add the start time to the MySQL table.');
        end;
        
        runrats(obj,'minimize_matlab_windows');
        
        %Let's start the video
        runrats(obj,'start_video');
        
        %Let's make everything unresponsive for 5 more seconds to prevent
        %double clicks from stopping the session
        pause(5);
        
        %Enable the Multi button so the user can stop the session
        enable(Multi);
        
        %Check to see if the experimenter wants to enable the safety before
        if ~isempty(strfind(value(SafetyMode),'A')) %#ok<NODEF>
            set(get_ghandle(Multi),'enable','off');
            set(get_ghandle(Safety),'visible','on','string',value(Instructions)); %#ok<NODEF>
        else
            set(get_ghandle(Multi),'enable','on');
            set(get_ghandle(Safety),'visible','off','string','');
        end
        
        dispatcher(value(dispobj),'Run'); %#ok<NODEF>
        
        
        
    case 'flicker_multibutton'
        %% flicker_multibutton
        %Called by dispatcher while running to invert the color of the
        %multi button, let's the tech know if the rig is running
        clr = get(get_ghandle(Multi),'BackgroundColor');
        set(get_ghandle(Multi),'BackgroundColor',1 - clr);
        
        %Every 10 flickers we update the lastupdate time in the
        %ratinfo.rigtrials table. This way we can see if a rig has frozen.
        %Don't do it every time because that will slow things down
        UpdateCounter.value = value(UpdateCounter) + 1; %#ok<NODEF>
        if value(UpdateCounter) >= 10
            bdata('call ratinfo.update_rigtrials_lastupdate("{S}","{Si}")',datestr(now,'HH:MM:SS'),value(RigID));
            UpdateCounter.value = 0;
        end
        
        
        
    case  'end'
        %% end
        %Ends the current protocol being run through dispatcher
        runrats(obj,'updatelog','runend');
        SessionEnded.value = 1;
        runrats(obj,'disable_all');
        set(get_ghandle(Multi),'String','Saving...','Fontsize',34);
        
        try send_n_done_trials(obj,'reset'); end %#ok<TRYNC>
        
        %Stop dispatcher and wait for it to respond
        dispatcher(value(dispobj),'Stop'); %#ok<NODEF>
        
        %Let's pause until we know dispatcher is done running
        set(value(stopping_complete_timer),'TimerFcn',[mfilename,'(''end_continued'');']);
        start(value(stopping_complete_timer));
        
        
        
    case 'end_continued'
        %% end_continued
        if value(stopping_process_completed) %This is provided by dispatcher to runrats
            stop(value(stopping_complete_timer)); %Stop looping.
            
            varargin{1} = value(InputArgs); %#ok<NODEF>
            
            %Now that everything is stopped let's send an empty state
            %matrix to the Linux machine.  This will reset all the lines
            %and sounds to be off.
            runrats(obj,'send_empty_state_machine')
            
            %Stop the video recording
            runrats(obj,'end_video');
            
            protobj=eval(value(CurrProtocol)); %#ok<NODEF>
            feval(value(CurrProtocol), protobj, 'end_session');
            sfile=SavingSection(protobj,'savedata','interactive',0);
            [pname,fname] = fileparts(sfile); %#ok<ASGLU>
            
            %Let's rename the video file according to the data file saved
            try
                vfile = value(VideoFile); %#ok<NODEF>
                if exist(vfile,'file') == 2
                    [v_pname,v_fname,ext] = fileparts(vfile);
                    new_vfile = ['video',fname(5:end),ext];
                    system(['rename ',vfile,' ',new_vfile]);
                    VideoFile.value = [v_pname,filesep,new_vfile];

                    vidpos = strfind(v_pname,'Video');
                    bfile = ['X:\RATTER\',v_pname(vidpos:end),filesep,v_fname,ext];
                    if exist(bfile,'file') == 2
                        system(['rename ',bfile,' ',new_vfile]);
                        VideoFile.value = ['X:\RATTER\',v_pname(vidpos:end),filesep,new_vfile];
                    end
                end
                
                for i = 2:10
                    vfile = eval(['value(VideoFile',num2str(i),')']);
                    if exist(vfile,'file') == 2
                        [v_pname,v_fname,ext] = fileparts(vfile);
                        new_vfile = ['video',fname(5:end),num2str(i),ext];
                        system(['rename ',vfile,' ',new_vfile]);
                        eval(['VideoFile',num2str(i),'.value = [v_pname,filesep,new_vfile];'])
                    
                        vidpos = strfind(v_pname,'Video');
                        bfile = ['X:\RATTER\',v_pname(vidpos:end),filesep,v_fname,ext];
                        if exist(bfile,'file') == 2
                            system(['rename ',bfile,' ',new_vfile]);
                            NewVideoFile = ['X:\RATTER\',v_pname(vidpos:end),filesep,new_vfile];
                            eval(['VideoFile',num2str(i),'.value = NewVideoFile;']);
                        end
                    else
                        break
                    end
                end
            catch
                disp('ERROR: failure to rename video file')
            end
            
            %if the protocol has a pre_saving_settings section, call it
            try
                feval(value(CurrProtocol),protobj,'pre_saving_settings');
            catch %#ok<CTCH>
                disp('Protocol does not appeat to have a pre_saving_settings')
            end
            
            SavingSection(protobj,'savesets','interactive',0);
            
            StatusBar.value=['Saved data file: ',fname]; %#ok<STRNU>
            
            set(get_ghandle(Multi),'String','Reloading');
            dispatcher(value(dispobj),'set_protocol',''); %#ok<NODEF>
            
            %Let's reset the Multi button and hop back in the live loop
            set(get_ghandle(Multi),'ForegroundColor',[0,0,0],'BackgroundColor',...
                [1,1,0.4],'string','Load Protocol','FontSize',24);
            InLiveLoop.value = 1; %#ok<STRNU>
            runrats(obj,'enable_all');
            
            %We need to turn RunRats back to live mode
            h = value(PanelBack); %#ok<NODEF>
            for i = 1:length(h)
                try %#ok<TRYNC>
                    if strcmp(get(h(1),'type'),'figure')
                        set(h(i),'Color',[1,0.8,0.6]);
                    else
                        set(h(i),'BackgroundColor',[1,0.8,0.6]);
                    end
                end
            end
            set(get_ghandle(UpdateMode),'String','Live Update On','BackgroundColor',[0.6 1 0.6],'ForegroundColor',[0 0 0]);
            
            %Another option is to now kill MatLab completely and restart
            %runrats.  This ensures windows don't pile up, and code can get
            %updated before each session. Before we restart Matlab let's
            %see if we're coming in from a crash and if so, how long since
            %the previous crash.
            
            crash_hang = 0;
            if strcmp(value(InputArgs),'no_reboot')
                %We're comming in from a crash. We want to quickly reload
                %the protocol so if this is a session where the rig would
                %full reboot let's not do that
                okay_to_reboot = 0;
                if exist(value(AutoLoadFile),'file')
                    load(value(AutoLoadFile));
                end
                if ~exist('last_crash_time','var')
                    last_crash_time = 0;
                end
                
                if (now - last_crash_time) * (24*60) < 20
                    %It's been less than 20 minutes since the last crash
                    crash_hang = 1;
                end 
            else
                okay_to_reboot = 1;
            end
            
            if value(do_full_restart) == 1 && crash_hang == 0
                
                %Close the MySQL connection
                try bdata('close'); end %#ok<TRYNC>
                
                if value(IsBpodRig) == 1 %#ok<NODEF>
                    try
                        EndBpod;
                        %global BpodSystem
                        %close(BpodSystem.GUIHandles.MainFig);
                    catch
                        disp('UNABLE TO CLOSE BPOD');
                    end
                    drawnow;
                    pause(5);
                end
                reboot_after_last_rat = bSettings('get','RUNRATS','reboot_after_last_rat');
                if isnan(reboot_after_last_rat)
                    reboot_after_last_rat = 1;
                end
                
                never_reboot = bSettings('get','RUNRATS','never_reboot');
                if isnan(never_reboot)
                    never_reboot = 0;
                end
                    
                more_to_train = 0;
                if reboot_after_last_rat == 1
                    rats_yet_to_train = bdata(['select ratname from ratinfo.schedule where rig=',...
                        num2str(value(RigID)),' and timeslot>',num2str(value(CurrSession)),...
                        ' and date="',datestr(now,'yyyy-mm-dd'),'"']); %#ok<NODEF>
                
                    for i = 1:numel(rats_yet_to_train)
                        if ~isempty(rats_yet_to_train{i})
                            more_to_train = 1;
                            break;
                        end
                    end
                end
                
                if (value(CurrSession) == 8 || (reboot_after_last_rat == 1 && more_to_train == 0)) &&...
                        okay_to_reboot == 1 && never_reboot == 0    
                    %We just finished session 9 or we reboot after the last rat and there
                    %are no more rats so let's do a full reboot as long as
                    %we did not set InputArgs to 'no_reboot'
                    ratname = ''; %#ok<NASGU>
                    last_crash_time = 0; %#ok<NASGU>
                    save(value(AutoLoadFile),'ratname','last_crash_time');
                    runrats(obj,'reboot');
                else
                    %This is an earlier session during the day, let's simply
                    %restart Matlab
                    pause(1);
                    drawnow;
                    
                    %Let's do a forced quit of any vlc running incase the
                    %gentle close in end_video didn't work
                    system('taskkill /F /im vlc.exe')

                    p = bSettings('get','GENERAL','Main_Code_Directory');
                    p(strfind(p,'ExperPort'):end) = '';
                    p = [p,'Rigscripts'];
                    cd(p);
                    
                    try %#ok<TRYNC>
                        if ispc == 1
                            if isempty(varargin) || isempty(varargin{1})
                                ratname = ''; %#ok<NASGU>
                                last_crash_time = 0; %#ok<NASGU>
                                save(value(AutoLoadFile),'ratname','last_crash_time');
                                system('restart_runrats.bat');
                            else
                                %we're coming from a crash cleanup
                                ratname = [value(LetMenu),sprintf('%03i',value(NumMenu))]; %#ok<NODEF,NASGU>
                                last_crash_time = now; %#ok<NASGU>
                                save(value(AutoLoadFile),'ratname','last_crash_time');
                                system('restart_runrats_autoload.bat');
                            end
                        else
                            system('./start_runrats.sh');
                        end
                    end
                end
            end
            
            if crash_hang == 0
                %And now we hop back in the loop
                runrats(obj,'live_loop');
            else
                set(get_ghandle(Multi),'String','Crashed','BackgroundColor',[0,0,0],...
                    'ForegroundColor',[1,1,1],'Fontsize',40);
            end
        end
        
        
        
    case 'reboot'
        %% reboot
        %This is designed to execute once each day, either when the session
        %8 rat is done training or if this rig is not running a rat in
        %session 8, when it sees that session 9 is nearning completion.
        runrats(obj,'updatelog','reboot');
        try %#ok<TRYNC>
            try %#ok<TRYNC>
                %At the end of the month let's upload the file to CVS and
                %clear the log so it doesn't grow forever
                if strcmp(datestr(now+1,'dd'),'01')
                    file = which('runrats_datalog_temp.txt');
                    path = bSettings('get','GENERAL','Main_Data_Directory');
                    newfile = [path,filesep,'Data',filesep,'RunRats',filesep,'Rig',sprintf('%03.0f',value(RigID)),filesep,...
                        datestr(now,'yymmdd'),'_','Rig',sprintf('%03.0f',value(RigID)),'_runrats_datalog.txt'];
                    system(['echo f | xcopy "',file,'" "',newfile,'"']);
                    add_and_commit(newfile);
                    f = fopen(file,'w');
                    fprintf(f,['New File Generated ',datestr(now,'yyyy-mm-dd HH:MM:SS')]);
                    fclose(f);
                end
            end
            
            %put code here you'd like to run each night before the reboot
            try %#ok<TRYNC>
                %Stop deleting old video until we can fix the corrupted
                %files on Cup
                upload_delete_old_video(30);
                check_video_hash('C:\ratter\Video\','','',1);
            end
            
            cd(bSettings('get','GENERAL','Rigscripts_Directory'))
            
            !del do_on_reboot.bat
            !copy start_runrats.bat do_on_reboot.bat /Y
            pause(1)           
            
            if bSettings('get','RIGS','bpod') == 1
                EndBpod;
            end
            pause(5);
            
            system('shutdown -r -f -t 10');
            pause(20);
        end
        
        
        
    case 'autoload'
        %% autoload
        %Here we can pass in the rat name to be loaded and load that
        %protocol and settings without having to click buttons
        
        %Let's check that the first value is a valid rat name
        if numel(varargin) < 1
            disp('No ratname provided. Cannot autoload.');
            return;
        end
        extant = bdata(['select extant from ratinfo.rats where ratname="',varargin{1},'"']);
        if isempty(extant)
            disp([varargin{1},' is not a valid ratname. Cannot autoload.']);
            return;
        end
        if extant == 0
            disp([varargin{1},' is not extant. Cannot autoload.']);
            return;
        end 
        
        %Let's load the rat's name into runrats
        LetMenu.value = varargin{1}(1); %#ok<STRNU>
        runrats(obj,'update_num');
        
        NumMenu.value = sprintf('%03i',str2num(varargin{1}(2:end))); %#ok<ST2NM>
        runrats(obj,'update_rat',0);
        
        runrats(obj,'updatelog','autoload');
        
        try
            if exist(value(AutoLoadFile),'file')
                load(value(AutoLoadFile));
            end
            ratname = ''; %#ok<NASGU>
            if ~exist('last_crash_time','var')
                last_crash_time = 0; %#ok<NASGU>
            end
            save(value(AutoLoadFile),'ratname','last_crash_time');
        catch
            disp('ERROR clearning autoload file');
        end
        
        %Now let's load the protocol and settings file
        if numel(varargin) < 2 || ~strcmp(varargin{2},'skipmanualtest')
            disp('AUTOLOAD COMPLETE');
            return;
        end
        runrats(obj,'load_protocol');
        
        %Finally let's start it running
        if numel(varargin) < 3 || ~strcmp(varargin{3},'run')
            disp('AUTOLOAD COMPLETE');
            return;
        end
        
        runrats(obj,'run');
        
        
        
    case 'crashed'
        %% crashed
        %Dispatcher crashed while running the protocol. Let's notify the
        %tech that we've crashed and send an email with the last error
        %message to the rat's owner. We will also update a MySQL table that
        %the GCS reads to post that a crash happened
        runrats(obj,'updatelog','crashed');
        set(get_ghandle(Multi),'String','Crashed','BackgroundColor',[0,0,0],...
            'ForegroundColor',[1,1,1],'Fontsize',40);
        enable(Multi);
        
        %Stop the video recording
        runrats(obj,'end_video');
            
        if ~isempty(varargin) && iscell(varargin) && strcmp(class(varargin{1}),'MException') %#ok<STISA>
            lsterr = [varargin{1}];
        else
            lsterr = [lasterror]; %#ok<LERR>
        end
        
        %Let's stop dispatcher
        %RunningSection(value(dispobj),'RunStop'); %#ok<NODEF>
        
        %Now we can email the rat's owner a crash report
        try %#ok<TRYNC>
            message = cell(0);
            message{end+1} = ['Rig ',num2str(value(RigID)),' crashed while running ',value(LetMenu),sprintf('%03i',value(NumMenu)),' at ',datestr(now,13)]; %#ok<NODEF>
            message{end+1} = '';
            for i = 1:numel(lsterr)
                message{end+1} = ['ERROR MESSAGE ',num2str(i)]; %#ok<AGROW>
                message{end+1} = lsterr(i).message; %#ok<AGROW>
                message{end+1} = ''; %#ok<AGROW>
            
                for j = 1:length(lsterr(i).stack)
                    message{end+1} = [lsterr(i).stack(j).name,' at ',num2str(lsterr(i).stack(j).line)]; %#ok<AGROW>
                end
                message{end+1} = ''; %#ok<AGROW>
            end
            
            message{end+1} = 'If there are 2 error messages, 1 is the original crash,';
            message{end+1} = '2 is the crash during the attempt to recover from 1.';
            message{end+1} = 'If both are the same your protocol likely experienced';
            message{end+1} = '10 crashed trials in a row. Check crashed_history and';
            message{end+1} = 'crashed_history_comments in the SoloData data file.';
            
            
            IP = get_network_info;
            message{end+1} = ' ';
            if ischar(IP); message{end+1} = ['Email generated by ',IP];
            else           message{end+1} = 'Email generated by an unknown computer!!!';
            end
            message{end+1} = 'ratter\ExperPort\Modules\@runrats\runrats.m';
            
            %setpref('Internet','SMTP_Server','brodyfs2.princeton.edu');
            %setpref('Internet','E_mail',['RunRats',datestr(now,'yymm'),'@Princeton.EDU']);
            set_email_sender
            
            owner = bdata(['select contact from ratinfo.rats where ratname="',value(LetMenu),sprintf('%03i',value(NumMenu)),'"']);
            if ~isempty(owner)
                owner = owner{1};
                owner = [',',owner,','];
                owner(owner == ' ') = '';
                cms = find(owner == ',');
                
                for i = 1:length(cms)-1
                    exp = owner(cms(i)+1:cms(i+1)-1);
                    sendmail([exp,'@princeton.edu'],[value(LetMenu),sprintf('%03i',value(NumMenu)),' Crashed'],message);
                end
            end
        end
        
        %Let's update the MySQL table to indicate a crash has happened
        id = bdata(['select sessid from sess_started where ratname="',value(LetMenu),sprintf('%03i',value(NumMenu)),...
            '" and was_ended=0 and sessiondate="',datestr(now,'yyyy-mm-dd'),'"']);
        if ~isempty(id)
            id = id(end);
            bdata('call mark_crashed("{S}")',id);
        end
        
        %Let's try to save the data before closing down
        try
            InputArgs.value = 'no_reboot'; %#ok<STRNU>
            
            set(value(stopping_complete_timer),'TimerFcn',[mfilename,'(''end_continued'');']);
            start(value(stopping_complete_timer)); 
            
        catch
            disp('ERROR while trying to save data.');
        end
        
        %Let's stop dispatcher and clean it up
        %dispatcher(value(dispobj),'set_protocol','');
        
        
        
    case 'crash_cleanup'
        %% crash_cleanup
        %The tech has acknowledged the crash. Let's jump back in the loop
        
        runrats(obj,'updatelog','crashcleanup');
        
        runrats(obj,'enable_all');
        set(get_ghandle(Multi),'ForegroundColor',[0,0,0],'BackgroundColor',...
            [1,1,0.4],'string','Load Protocol','FontSize',24);
        
        InLiveLoop.value = 1; %#ok<STRNU>
        
        if value(do_full_restart) == 1
                
            %Close the MySQL connection
            try bdata('close'); end %#ok<TRYNC>

            if value(CurrSession) == 8 %#ok<NODEF> %|| value(CurrSession) == 6 %#ok<NODEF>
                %We just finished session 9 so let's do a full reboot
                runrats(obj,'reboot')
            else
                %This is an earlier session during the day, let's simply
                %restart Matlab
                pause(1);
                drawnow;

                %Let's do a forced quit of any vlc running incase the
                %gentle close in end_video didn't work
                system('taskkill /F /im vlc.exe')

                p = bSettings('get','GENERAL','Main_Code_Directory');
                p(strfind(p,'ExperPort'):end) = '';
                p = [p,'Rigscripts'];
                cd(p);

                try %#ok<TRYNC>
                    if ispc == 1
                        system('restart_runrats.bat')
                    else
                        system('./start_runrats.sh')
                    end
                end
            end
        end
            
        runrats(obj,'live_loop');
        
        
        
    case 'copy_settings_files'
        map_bucket_drive;
        
        rigid = bSettings('get','RIGS','Rig_ID');
        cuppath = ['X:',filesep,'Training Room',filesep,...
            'Settings',filesep,'Rig',num2str(rigid),filesep];
        
        exppath = bSettings('get','GENERAL','Main_Code_Directory');
        if exppath(end) == filesep
            exppath = exppath(1:end-1);
        end
        expsettings = [exppath,filesep,'Settings'];
        expsetfiles = dir(expsettings);
        
        cupdir = [cuppath,'ExperPort'];
        if ~exist(cupdir,'dir')
            mkdir(cupdir);
        end

        for i = 1:numel(expsetfiles)
            %Copy ExperPort Settings to Cup
            if expsetfiles(i).isdir == 0
                [pname,fname,ext] = fileparts(expsetfiles(i).name);
                if strcmp(ext,'.conf')
                    %Copy this file
                    try
                        copyfile([expsettings,filesep,expsetfiles(i).name],...
                             [cupdir,filesep,expsetfiles(i).name],'f');
                    catch
                        disp(['WARNING: Unable to copy ',expsetfiles(i).name]);
                    end
                end
            end
        end

        runratsettings = [exppath,filesep,'Modules',filesep,'@runrats'];
        runratsetfiles = dir(runratsettings);
        
        cupdir = [cuppath,'Runrats'];
        if ~exist(cupdir,'dir')
            mkdir(cupdir);
        end

        for i = 1:numel(runratsetfiles)
            %Copy Runrats Settings to Cup
            if runratsetfiles(i).isdir == 0
                [pname,fname,ext] = fileparts(runratsetfiles(i).name);
                if strcmp(ext,'.txt') || strcmp(ext,'.mat')
                    %Copy this file
                    try
                        copyfile([runratsettings,filesep,runratsetfiles(i).name],...
                             [cupdir,filesep,runratsetfiles(i).name],'f');
                    catch
                        disp(['WARNING: Unable to copy ',runratsetfiles(i).name]);
                    end
                end
            end
        end

        if bSettings('get','RIGS','bpod')
            bpodpath = bSettings('get','GENERAL','Bpod_Code_Directory');
            if bpodpath(end) == filesep
                bpodpath = bpodpath(1:end-1);
            end
            bpodsettings = [bpodpath,filesep,'Bpod Local\Settings'];
            bpodsetfiles = dir(bpodsettings);

            cupdir = [cuppath,'Bpod'];
            if ~exist(cupdir,'dir')
                mkdir(cupdir);
            end

            for i = 1:numel(bpodsetfiles)
                %Copy Bpod Settings to Cup
                if bpodsetfiles(i).isdir == 0
                    [pname,fname,ext] = fileparts(bpodsetfiles(i).name);
                    if strcmp(ext,'.mat')
                        %Copy this file
                        try
                            copyfile([bpodsettings,filesep,bpodsetfiles(i).name],...
                                 [cupdir,filesep,bpodsetfiles(i).name],'f');
                        catch
                            disp(['WARNING: Unable to copy ',bpodsetfiles(i).name]);
                        end     
                    end
                end
            end
        end
        
        calibpath = bSettings('get','GENERAL','Protocols_Directory');
        if calibpath(end) == filesep
            calibpath = calibpath(1:end-1);
        end
        
        if bSettings('get','RIGS','bpod')
            calibsettings = [calibpath,filesep,'@WaterCalibrationBPod'];
        else
            calibsettings = [calibpath,filesep,'@WaterCalibration'];
        end
        calibsetfiles = dir(calibsettings);
        
        cupdir = [cuppath,'Calibration'];
        if ~exist(cupdir,'dir')
            mkdir(cupdir);
        end
        
        for i = 1:numel(calibsetfiles)
            %Copy Calibration Settings to Cup
            if calibsetfiles(i).isdir == 0
                [pname,fname,ext] = fileparts(calibsetfiles(i).name);
                if strcmp(ext,'.mat')
                    %Copy this file
                    try
                        copyfile([calibsettings,filesep,calibsetfiles(i).name],...
                             [cupdir,filesep,calibsetfiles(i).name],'f');
                    catch
                        disp(['WARNING: Unable to copy ',calibsetfiles(i).name]);
                    end     
                end
            end
        end
        
        
        
    case 'updatelog'
        %% updatelog
        
        try %#ok<TRYNC>
            Exp = value(ExpName); %#ok<NODEF>
            Rat = [value(LetMenu),sprintf('%03i',value(NumMenu))]; %#ok<NODEF>
            Sch = value(SchList); %#ok<NODEF>

            time = datestr(now,'yymmdd HH:MM:SS');

            str = [time,' ',varargin{1},' ',Exp,' ',Rat,' ',Sch,char(10)];
            file = which('runrats_datalog_temp.txt');
            f = fopen(file,'a+t');
            fseek(f,0,'eof');
            fprintf(f,str,'char');
            fclose(f);
            
            %runrats_datalog{end+1} = str;
            %save(file,'runrats_datalog');
        end
           
        
        
    case 'email_experimenter'
        %% email_experimenter
        %Something has gone wrong during the load phase and we should email
        %the experimenter if we can
        
        try %#ok<TRYNC>
            
            if ~isempty(value(LetMenu)) && ~isempty(value(NumMenu)) %#ok<NODEF>

                %setpref('Internet','SMTP_Server','brodyfs2.princeton.edu');
                %setpref('Internet','E_mail',['RunRats',datestr(now,'yymm'),'@Princeton.EDU']);
                set_email_sender

                message{1} = ['Load failed for ',value(LetMenu),sprintf('%03i',value(NumMenu))];
                if strcmp(varargin{1},'no settings')
                    subject    = ['No settings for ',value(LetMenu),sprintf('%03i',value(NumMenu))];
                    message{2} = ['Please check that there are settings for ',value(LetMenu),sprintf('%03i',value(NumMenu))];
                elseif strcmp(varargin{1},'protocol fail')
                    subject    = ['Failed to load ',value(CurrProtocol)]; %#ok<NODEF>
                    message{2} = ['Protocol ',value(CurrProtocol),' could not be laoded for ',value(LetMenu),sprintf('%03i',value(NumMenu))];
                else
                    subject    = ['Failed to load settings for ',value(LetMenu),sprintf('%03i',value(NumMenu))];
                    message{2} = ['The settings file for ',value(LetMenu),sprintf('%03i',value(NumMenu)),' failed to load'];
                end

                IP = get_network_info;
                message{end+1} = ' ';
                if ischar(IP); message{end+1} = ['Email generated by ',IP];
                else           message{end+1} = 'Email generated by an unknown computer!!!';
                end
                message{end+1} = 'ratter\ExperPort\Modules\@runrats\runrats.m';

                contact = bdata(['select contact from ratinfo.rats where ratname="',[value(LetMenu),sprintf('%03i',value(NumMenu))],'"']);
                if ~isempty(contact)
                    contact = [',',contact{1},','];
                    contact(contact == ' ') = '';
                    cms = find(contact == ',');
                    for i = 1:length(cms)-1
                        email = contact(cms(i)+1:cms(i+1)-1);
                        sendmail([email,'@princeton.edu'],subject,message);
                    end
                end
            end
        end
        
        
        
    case 'is_running'
        %% is_running
        %If the Multi button exists, runrats has been loaded
        if exist('Multi','var'), obj = 1; else obj = 0; end
        
        
        
    case 'session_ended'
        %% sesion_ended
        %return the value of SessionEnded
        obj = value(SessionEnded);
        
        
        
    case 'get_videofile'
        %% get_videofile
        %If the Multi button exists, runrats has been loaded
        if exist('Multi','var'), obj = value(VideoFile); else obj = ''; end %#ok<NODEF>
        
        
        
    case 'get_settings_file_load_time'
        %% get_settings_file_load_time
        %This is called by SavingSection, let's not modify it
        
        if exist('settings_file_load_time', 'var') && isa(settings_file_load_time, 'SoloParamHandle') %#ok<NODEF>
            varargout{1} = value(settings_file_load_time);
        else
            varargout{1} = 0;
        end
        
        
    case 'get_settings_file_path'
        %% get_setting_file_path
        %This is called by SavingSection, let's not modify it
        
        if exist('settings_file_sph', 'var') && isa(settings_file_sph, 'SoloParamHandle') %#ok<NODEF>
            varargout{1} = value(settings_file_sph);
        else
            varargout{1} = '';
        end
                
        

    case  'close'
        %% close
        %Closes runrats
        
        runrats(obj,'close_gui_only');
        
        try send_n_done_trials(obj,'reset'); end %#ok<TRYNC>
        
        try
            dispatcher(value(dispobj),'close'); %#ok<NODEF>
        catch %#ok<CTCH>
            disp('WARNING: Dispatcher close attempt in runrats failed.');
        end
        
        
        
    case 'close_gui_only'
        %% close_gui_only
        
        try
            StatusBar.value='Cleaning up......'; %#ok<STRNU>
            runrats(obj,'disable_all');
        catch %#ok<CTCH>
            disp('WARNING: Close attempt in runrats failed.');
        end
        delete(value(myfig));
        
        delete_sphandle('owner', ['^@', mfilename '$']);
        obj = [];
        
        
        
    otherwise
        warning('Unknown action " %s" !', action);%#ok<WNTAG>
end;

return;


function p=getProtocol(exprmtr,rat)

olddir=cd;
p='';
try %#ok<TRYNC>
    dd=bSettings('get','GENERAL','Main_Data_Directory');
    
    if isnan(dd); dd='../SoloData'; end
    if dd(end)~=filesep; dd(end+1)=filesep; end
    
    dd=[dd,'Settings',filesep];
    cd([dd,exprmtr,filesep,rat]);
    fn=dir('settings_*_*_*_*.mat');
    for xi=1:numel(fn)
        s=fn(xi).name;
        tc=textscan(s,'%s','Delimiter','_');
        prt{xi}=tc{1}{2};         %#ok<AGROW>
        r=tc{1}{end};
        % Must have had 5 fields (settings, prot, exprtr, rat, date), the
        % date must be 11 chars long (7 of date plus '.mat'), the first six
        % of those must be numbers, not letters:
        if length(tc{1}) == 5 && length(r) == 11 && all(~isletter(r(1:6))),
            setdate{xi}=r(1:7); %#ok<AGROW>
        else % not a file we want, give it a really early date, 2000:
            setdate{xi}='000101a'; %#ok<AGROW>
        end;
    end
    
    [srtdsets, sdi]=sort(setdate);
    
    % Look only at settings that are not later than today
    ymd = str2double(yearmonthday); keeps = ones(size(sdi));
    for i=1:length(sdi), if str2double(srtdsets{i}(1:6)) > ymd, keeps(i) = 0; end; end;
    srtdsets = srtdsets(find(keeps)); sdi = sdi(find(keeps)); %#ok<FNDSB,NASGU>
    
    p=prt{sdi(end)};
    if p(1)=='@'
        p=p(2:end);
    end
    
end
cd(olddir)


% function update_folder(pname,vn)
% 
% try
%     currdir = pwd;
%     cd(pname);
%     if strcmp(vn,'cvs')
%         %cvs no longer in use
%         %failed1 = 0;
%         %[failed2,message2] = system('cvs up -d -P -A');
%     elseif strcmp(vn,'svn')
%         %svn no longer in use
%         %[failed1,message1] = system('svn cleanup');
%         %[failed2,message2] = system('svn update');
%     elseif strcmp(vn,'bucket')
%         failed1 = 0;
%         [failed2,message2] = copy_recent_file_from_bucket(pname);
%     end
%     cd(currdir);
%     
%     rig = bSettings('get','RIGS','Rig_ID');
%     if ~ischar(rig); rig = num2str(rig); end
%     
%     if failed1 == 1 || failed2 == 1
%         %setpref('Internet','SMTP_Server','brodyfs2.princeton.edu');
%         %setpref('Internet','E_mail',['RunRats',datestr(now,'yymm'),'@Princeton.EDU']);
%         set_email_sender
%         
%         if pname(1)   ~= filesep; pname = [filesep,pname]; end
%         if pname(end) ~= filesep; pname = [pname,filesep]; end
%         fs = find(pname == filesep);
%         
%         contact = '';
%         for i = 1:length(fs)-1
%             temp = pname(fs(i)+1:fs(i+1)-1);
%             if length(temp) == 4 && ~isempty(str2num(temp(2:4))) %#ok<ST2NM>
%                 %This is a rat, let's email the owner
%                 contact = bdata(['select contact from ratinfo.rats where ratname="',temp,'"']);
%             elseif strcmpi(temp,'experport') || strcmpi(temp,'protocols')
%                 contact = {'ckopec'};
%             end
%         end
%         
%         if failed1 == 1
%             message    = cell(0);
%             message{1} = ['SVN cleanup failed in ',pname];
%             message{2} = ' ';
%             message{3} = message1;
%             
%             IP = get_network_info;
%             message{end+1} = ' ';
%             if ischar(IP); message{end+1} = ['Email generated by ',IP];
%             else           message{end+1} = 'Email generated by an unknown computer!!!';
%             end
%             message{end+1} = 'ratter\ExperPort\Modules\@runrats\runrats.m';
%             
%             ctemp = [',',contact{1},','];
%             ctemp(ctemp == ' ') = '';
%             cms = find(ctemp == ',');
%             for i = 1:length(cms)-1
%                 email = ctemp(cms(i)+1:cms(i+1)-1);
%                 sendmail([email,'@princeton.edu'],['SVN Cleanup FAILED on Rig ',rig],message);
%             end
%         end
%         
%         if failed2 == 1
%             message    = cell(0);
%             message{1} = [vn,' update failed in ',pname];
%             message{2} = ' ';
%             message{3} = message2;
%             if     strcmp(vn,'cvs');    subject = ['SVN Update FAILED on Rig ',rig];
%             elseif strcmp(vn,'svn');    subject = ['SVN Update FAILED on Rig ',rig];
%             elseif strcmp(vn,'bucket'); subject = ['BUCKET Update FAILED on Rig ',rig];
%             else                        subject = '';
%             end
%             
%             IP = get_network_info;
%             message{end+1} = ' ';
%             if ischar(IP); message{end+1} = ['Email generated by ',IP];
%             else           message{end+1} = 'Email generated by an unknown computer!!!';
%             end
%             message{end+1} = 'ratter\ExperPort\Modules\@runrats\runrats.m';
%             
%             ctemp = [',',contact{1},','];
%             ctemp(ctemp == ' ') = '';
%             cms = find(ctemp == ',');
%             for i = 1:length(cms)-1
%                 email = ctemp(cms(i)+1:cms(i+1)-1);
%                 sendmail([email,'@princeton.edu'],subject,message);
%             end
%         end
%     end
% catch %#ok<CTCH>
%     senderror_report;
% end




