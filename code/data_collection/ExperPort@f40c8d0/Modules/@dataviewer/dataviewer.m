% dataviewer(varargin)
% This is the GUI for technicians in the lab to use for day to day running
% of rats.  The logic of the code follows that of dispatcher.


function obj=dataviewer(varargin)

HIDE_PROTOCOL=0;

%if isempty(strfind(cd ,'ExperPort'))
%    error('Must run from the ExperPort root directory');
%end

%global Solo_Datadir;

obj = class(struct, mfilename);
if nargin==0 || nargin==1 && ischar(varargin{1}) && strcmp(varargin{1}, 'empty'),
    return;
end;

% This line is required for the use of SoloParams
GetSoloFunctionArgs;

%% Contruct the module
% this syntax means that only a single dataviewer module can exist in a instantiaion of matlab
% This is the desired behavior, since matlab is very serial in its processing, and we do not
% want to end up waiting.

if ischar(varargin{1}) && strcmp(varargin{1}, 'init'),
    if exist('myfig', 'var'),
        if isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)), delete(value(myfig)); end;
    end;


    % Start and hide the dispatcher.

    dispobj=dispatcher('init');
    h=get_sphandle('owner','dispatcher','name','myfig');
    set(value(h{1}), 'Visible','Off');
    SoloParamHandle(obj, 'dispobj','value',dispobj);


    % The main window
    if nargin==2
        pos=varargin{2};
    else
        pos=[400 400];
    end
    wh=[650 250];  % width x height
    SoloParamHandle(obj, 'myfig', 'value',...
        double(figure('Position',[pos wh], ...
        'MenuBar','none', ...
        'ToolBar','none', ...
        'NumberTitle', 'off',...
        'Name','Data Viewer GUI',...
        'Resize','off',...
        'closerequestfcn', 'dataviewer(''Close'')')) ...
        );
    


    % Put a clock on the title.
    t=timer('TimerFcn',['set(' num2str(value(myfig))   ',''Name'', [''DataViewer   '' datestr(now, ''mmm dd, HH:MM'')])'], ...
        'Period',60, 'ExecutionMode', 'FixedRate');
    start(t);

    % save a handle to the timer, so that we can delete it when we close
    % the object
    SoloParamHandle(obj, 'figclock' , 'value', t);


    % Create 2 non-GUI SoloParams, that will be useful.

    SoloParamHandle(obj, 'curProtocol', 'value', '');  %Current Protocol
    SoloParamHandle(obj, 'Session', 'value',1); % This increments with each 'END action'
    SoloParamHandle(obj, 'OldRats', 'value', {''});


    % Then the experimenter menu
    MenuParam(obj, 'ExprmtrMenu', {''}, 1 , 5, 100, 'label', 'Experimenter', ...
        'TooltipString', sprintf('\nPick an experimenter.  Or pick none to\n select a rat using the old system.') ...
        );
    disable(ExprmtrMenu);
    mh= get_ghandle(ExprmtrMenu);
    lh=get_glhandle(ExprmtrMenu);
    set(mh,'ButtonDownFcn','');  % This prevents the auto_set dialog from accidentaly popping up.
    set(lh(2), 'Position', [180 185 190 35]);
    set(mh, 'FontSize', 24);
    set(lh(2), 'FontSize', 24);
    set(lh(2), 'BackgroundColor', [.8 .8 .8]);
    ph=get(mh,'Parent');
    set(ph, 'BackgroundColor',[1 .7 .4]);
    set(ph, 'BorderType','none');
    set(mh, 'Position', [5 190 170 35]);
    set_callback(ExprmtrMenu , {mfilename, 'fillRatMenu'});

    % The Rat Menu
    MenuParam(obj, 'RatMenu', {''}, 1 , 5, 5, 'label', 'Rat', ...
        'TooltipString', sprintf('\nPick an experimenter.  Or pick none to\n select a rat using the old system.') ...
        );
    disable(RatMenu);
    set_callback(RatMenu,{mfilename,'readyToLoad'});
    mh= get_ghandle(RatMenu);
    set(mh,'ButtonDownFcn','');   % This prevents the auto_set dialog from accidentaly popping up.
    lh=get_glhandle(RatMenu);
    set(mh, 'FontSize', 24);
    set(lh(2), 'FontSize', 24);
    set(lh(2), 'BackgroundColor', [.8 .8 .8]);
    set(lh(2), 'Position', [180 115 50 35]);
    set(mh, 'Position', [5 120 170 35]);

    % The Rescan Button
    PushbuttonParam(obj, 'ReScan', 40, 55,  ...
        'TooltipString', sprintf('\nLooks for data that have changed since the beginning of the day.') ...
        );
    set_callback(ReScan , {mfilename, 'fillExprmtrMenu'});
    disable(ReScan);
    mh= get_ghandle(ReScan);
    set(mh,'ButtonDownFcn','');
    set(mh, 'Position', [130 55 240 35]);
    set(mh, 'FontSize', 14);
    set(mh, 'BackgroundColor', [.5 .8 1]);
    set(mh, 'String', 'Get latest data');
	
	    

    % The MultiPurpose Button
    PushbuttonParam(obj, 'Multi', 260, 25, 'label','Load Data', ...
        'TooltipString', sprintf('\nAfter you select the Experimenter and Rat, press this button to initialize the protocol and load the data.') ...
        );

    set_callback(Multi , {mfilename, 'Load'});
    disable(Multi);
    mh= get_ghandle(Multi);
    set(mh,'ButtonDownFcn','');   % This prevents the auto_set dialog from accidentaly popping up.
    set(mh, 'Position', [380 65 240 150]);
    set(mh, 'FontSize', 24);
    set(mh, 'BackgroundColor', [.99 1 .62])

    % The Status Bar
    SubheaderParam(obj,'StatusBar','Ready',5,5);
    mh= get_ghandle(StatusBar);
    set(mh,'ButtonDownFcn','');   % This prevents the auto_set dialog from accidentaly popping up.
    set(mh, 'Position', [0 0 650 45]);
    set(mh, 'FontName','Arial');
    set(mh, 'FontSize',14);
    set(mh, 'BackgroundColor', [.9 1 1])

    drawnow
    dataviewer('fillExprmtrMenu');
    enable(ReScan);

    return;
    % init
end
%% Deal with the other possible behaviors

if nargin>=2 && isa(varargin{1}, class(obj)), action = varargin{2}; varargin = varargin(3:end);
else                                          action = varargin{1}; varargin = varargin(2:end);
end;

switch action,

%% fillExprmtrMenu

    case 'fillExprmtrMenu',
       

        disable(ExprmtrMenu);
        disable(RatMenu);
        disable(Multi);
        StatusBar.value='Getting latest data from server... ';
        [xprs, OldRats.value]=getExperimenters;

        xprs{end+1}='None';
        xprs={'' xprs{:}};



        mh=get_ghandle(ExprmtrMenu);
        set(mh,'String',xprs);
        ExprmtrMenu.value=1;
        dataviewer('fillRatMenu')

%% fillRatMenu   
    case 'fillRatMenu'

        disable(ExprmtrMenu);
        RatMenu.value=1;

        mh=get_ghandle(RatMenu);

        if strcmp(value(ExprmtrMenu), 'None')
            set(mh, 'String', value(OldRats));
        elseif isempty(value(ExprmtrMenu))
            set(mh, 'String', {''});
        else
            rats=getRats(value(ExprmtrMenu));
            set(mh, 'String', rats);
		end
		RatMenu.value=1;
		if isempty(value(RatMenu))
			StatusBar.value=['Sorry, ' value(ExprmtrMenu) ' does not have any rats with data.'];
		else
			StatusBar.value='Please pick an Experimenter, then a rat';
		end
		enable(RatMenu);
        enable(ExprmtrMenu);
        enable(ReScan);
        dataviewer('readyToLoad');


%% readyToLoad
    case 'readyToLoad',  
        disable(Multi);
        disable(ReScan);
        disable(RatMenu);
        disable(ExprmtrMenu);
        dispatcher('set_protocol','');
        set_callback(Multi , {mfilename, 'Load'});
        mh= get_ghandle(Multi);
        set(mh,'String','Load Protocol');        %find protocol
        set(mh, 'BackgroundColor', [.99 1 .62])
        enable(Multi);
        enable(RatMenu);
        enable(ExprmtrMenu);
        enable(ReScan);



%% Close

    case  'Close'
        try
        StatusBar.value='Cleaning up......';
        disable(Multi);
        disable(ReScan);
        catch, end
        try
        stop(value(figclock));
        delete(value(figclock));
        catch, end
        % should we check if it exists first?
        try
            dispatcher(value(dispobj),'close');
        catch
        end
        delete(value(myfig));

        delete_sphandle('owner', ['^@', mfilename '$']);
        obj = [];


%% Load
    case  'Load'
        %change label to 'Loading....'

        disable(Multi);
        mh=get_ghandle(Multi);
        set(mh,'String','Loading...');        %find protocol
        StatusBar.value='Loading protocol and data.  Please be patient!';
        curProtocol.value=getProtocol(value(ExprmtrMenu), value(RatMenu));
        if isempty(value(curProtocol))
            StatusBar.value=['No Data for ' value(RatMenu)];
            dataviewer('readyToLoad');
            return;
        end
        try
        dispatcher(value(dispobj),'set_protocol',value(curProtocol));         %load protocol
        catch
            StatusBar.value=['"' value(curProtocol) '" is not compatible with dispatcher.'];
            dataviewer('readyToLoad');
            return;
        end
        % hide protocol?

        if HIDE_PROTOCOL
            h=get_sphandle('owner',value(curProtocol),'name', 'myfig');
            for hi=1:numel(h)
                set(value(h{hi}), 'Visible','Off');
            end
        end


        rath=get_sphandle('name','ratname','owner',value(curProtocol));
        exph=get_sphandle('name','experimenter','owner',value(curProtocol));
        rath{1}.value=value(RatMenu);
        exph{1}.value=value(ExprmtrMenu);
        try
            protobj=eval(value(curProtocol));
            
            [out, sfile]=load_soloparamvalues(value(RatMenu),'experimenter',value(ExprmtrMenu),...
                'owner',class(protobj));
            
        catch
            display(lasterr)
        end

        %load Data
        %change button to RUN
        mh=get_ghandle(Multi);
        set(mh,'String',['CLOSE: ' value(RatMenu)], 'BackgroundColor', [.3 1 .3]);
        set_callback(Multi , {mfilename, 'End'});
        while ~isempty(sfile)
            [r,sfile]=strtok(sfile,filesep);
        end
        StatusBar.value=['Using data file : ' r];
        enable(Multi)
        figure(value(myfig));


%% RUN
    case  'RUN'
        try
            disable(ExprmtrMenu);
            disable(RatMenu);
            disable(Multi);
            disable(ReScan);

            % THIS STARTS THE RUNNING!
            dispatcher(value(dispobj), 'Run');

            % NOTE: This will only work in the dispatcher_with_timer branch.
            % In the dispatcher_without_timer branch this call only returns
            % after running is stopped.  I actually could look for the timer
            % and use different code depending.  But really, this should be
            % part of the with_timer branch, and the other version should be
            % part of the without_timer branch

            mh=get_ghandle(Multi);
            set(mh,'String',sprintf(['End Session:' value(RatMenu)]), 'BackgroundColor', [.7 .3 .3]);
            set_callback(Multi , {mfilename, 'End'});

        catch
            set_callback(Multi , {mfilename, 'RUN'});
            StatusBar.value='failed';
        end
        enable(Multi)

%% End Experiment

    case  'End'
        try
            %Change Label to 'saving'
            lh=get_ghandle(Multi);
            set(lh,'String','Saving...');
            disable(Multi);
            dispatcher('set_protocol','');
            %increment session
            Session.value=Session+1;
            %rescan
            dataviewer('fillExprmtrMenu');
            dataviewer('readyToLoad');
        catch
            set_callback(Multi ,{mfilename, 'End'});
            display(lasterror);
        end


    otherwise
        warning('Unknown action "%s" !', action);
end

return;
