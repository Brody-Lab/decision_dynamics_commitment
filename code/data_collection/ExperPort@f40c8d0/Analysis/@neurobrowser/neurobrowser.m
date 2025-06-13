% neurobrowser(varargin)
% This is the GUI for technicians in the lab to use for day to day running
% of rats.  The logic of the code follows that of dispatcher.


function obj=neurobrowser(varargin)


obj = class(struct, mfilename, pokesplot2, tagger);
if nargin==0 || nargin==1 && ischar(varargin{1}) && strcmp(varargin{1}, 'empty'),
    return;
end;


GetSoloFunctionArgs(obj);


%% Contruct the module
% this syntax means that only a single neurobrowser module can exist in a instantiaion of matlab
% This is the desired behavior, since matlab is very serial in its processing, and we do not
% want to end up waiting.

if ischar(varargin{1}) && strcmp(varargin{1}, 'init'),
    if exist('myfig', 'var'),
        if isa(myfig, 'SoloParamHandle') && ishandle(value(myfig))
            close(myfig)
        end
    end;
    
    
    % make sure you can see the necessary code:
    
    addpath('Analysis/NeuraLynx');
    addpath('Analysis/jce_helpers');
    
    
    % The main window
    if nargin==2
        pos=varargin{2};
    else
        pos=[100 100];
    end
    wh=[650 650];  % width x height
    tu=bdata('select user()');
    SoloParamHandle(obj, 'myfig', 'value',...
        figure('Position',[pos wh], ...
        'MenuBar','none', ...
        'ToolBar','none', ...
        'NumberTitle', 'off',...
        'Name',['neurobrowser v 0.2, ' tu{1}],...
        'Resize','on',...
        'closerequestfcn', 'neurobrowser(''Close'')') ...
        );
    
    
    
    
    
    SoloParamHandle(obj, 'rat', 'value', '');  
    SoloParamHandle(obj, 'sessids', 'value',[]); 
    SoloParamHandle(obj, 'sessid', 'value',[]); 
    SoloParamHandle(obj, 'cellid', 'value',[]); 
    SoloParamHandle(obj, 'protocol', 'value',''); 
    SoloParamHandle(obj, 'pd', 'value',[]); 
    SoloParamHandle(obj, 'peh', 'value',[]); 
    SoloParamHandle(obj, 'sessiondate', 'value',[]); 
    
    
    
    list_base=300;
    
    % Then the experimenter menu
    MenuParam(obj, 'ExprmtrMenu', {''}, 1 , 5, 100, 'label', 'Experimenter', ...
        'TooltipString', sprintf('\nPick an experimenter.') ...
        );
    mh= get_ghandle(ExprmtrMenu);  %#ok<NODEF>
    lh=get_glhandle(ExprmtrMenu);
    set(mh,'ButtonDownFcn','');  % This prevents the auto_set dialog from accidentaly popping up.
    set(lh(2), 'Position', [160 620 100 20]);
    set(mh, 'FontSize', 14);
    set(lh(2), 'FontSize', 14);
    set(lh(2), 'BackgroundColor', [.8 .8 .8]);
    ph=get(mh,'Parent');
    set(ph, 'BorderType','none');
    set(mh, 'Position', [5 620 150 20]);
    set_callback(ExprmtrMenu , {mfilename, 'fillRatMenu'});
    
    % QUICKVIEW BUTTON
    ToggleParam(obj, 'only_phys', getpref('neurobrowser','only_phys',0) , 270, 620,'OnString','Only showing recording sessions',...
        'OffString','Showing all sessions');
    set_callback(only_phys,{mfilename,'fillExprmtrMenu'});
    
    
    % The Rat List
    ListboxParam(obj, 'RatMenu', {'Rats'}, 1 , 5, 5, 'label', 'Rat', ...
        'TooltipString', sprintf('\nSelect a rat') ...
        );
    set_callback(RatMenu,{mfilename,'fillSessList'});
    mh= get_ghandle(RatMenu);
    set(mh,'ButtonDownFcn','');   % This prevents the auto_set dialog from accidentaly popping up.
    set(mh, 'FontSize', 11,'FontName','Monaco');
    set(mh, 'Position', [5 list_base 70 600-list_base]);
     
    %The Session List
    
    ListboxParam(obj, 'SessList', {'Sessions'}, 1 , 5, 5, 'label', 'Rat', ...
        'TooltipString', sprintf('\nSelect a session.\nEach row is:\nSession Date, n_done_trials, %% correct') ...
        );
    set_callback(SessList,{mfilename,'showSessInfo'});
    mh= get_ghandle(SessList);
    set(mh,'ButtonDownFcn','');   % This prevents the auto_set dialog from accidentaly popping up.
      set(mh, 'FontSize', 11,'FontName','Monaco');
    set(mh, 'Position', [80 list_base 275 600-list_base]);
    
    
    %The Cell List
    
    ListboxParam(obj, 'CellList', {'Cells'}, 1 , 5, 5, 'label', 'Rat', ...
        'TooltipString', sprintf('\nSelect a cell.') ...
        );
    set_callback(CellList,{mfilename,'showCellInfo'});
    mh= get_ghandle(CellList);
    set(mh,'ButtonDownFcn','');   % This prevents the auto_set dialog from accidentaly popping up.
    set(mh, 'FontSize', 13);
    set(mh, 'Position', [360 list_base 75 600-list_base]);
    set(mh, 'Max' , 5);
    
    
    %The Sessions info Box
    
    TextBoxParam(obj, 'SessInfo', sprintf('Session Info'),5,5);
    mh= get_ghandle(SessInfo);
    set(mh,'ButtonDownFcn','');   % This prevents the auto_set dialog from accidentaly popping up.
    set(mh, 'FontSize', 13);
    set(mh, 'Position', [5 5 430 list_base-10]);
    set(mh, 'BackgroundColor',[82.7	86.3	92.5]/100);
    set(mh, 'HorizontalAlignment', 'Left');
    lh=get_lhandle(SessInfo);
    set(lh,'Visible','off')
    
    
    
    %The Cell info Box
    TextBoxParam(obj, 'CellInfo', 'Cell Info',  5, 5  );
    mh= get_ghandle(CellInfo);
    set(mh,'ButtonDownFcn','');   % This prevents the auto_set dialog from accidentaly popping up.
    set(mh, 'FontSize', 13);
    set(mh, 'Position', [440 280 210 320]);
    set(mh, 'HorizontalAlignment', 'Left');
    set(mh, 'BackgroundColor',[98.4	73.7	47.5]/100);
    lh=get_lhandle(CellInfo);
    set(lh,'Visible','off')
    
    
    
    % Plot Buttons
    
    PushbuttonParam(obj, 'SendToPokesPlot', 450, 20, 'label','Send Data to PokesPlot');
    set_callback(SendToPokesPlot, {mfilename, 'sendToPokesPlot'});
    
    PushbuttonParam(obj, 'SessPlot', 450, 40, 'label','Load Session Data');
    set_callback(SessPlot, {mfilename, 'plotSess'});
    
    PushbuttonParam(obj, 'helpervars', 450, 60, 'label','Load Helper Vars');
    set_callback(helpervars, {mfilename, 'helper_vars'});
    
    PushbuttonParam(obj, 'CutPlot', 450, 80, 'label','View cutting notes');
    set_callback(CutPlot, {mfilename, 'plotCutting'});
    
    PushbuttonParam(obj, 'psthPlot', 450, 100, 'label','summary_plot');
    ToggleParam(obj, 'plotMean', 0, 630, 100, ...
        'OnString', 'M', 'OffString', 'R', ...
        'position', [630, 100, 20, 20], ...
        'TooltipString', sprintf('\nBlack: plot mean PSTH only \nBrown: plot mean and range of PSTH'));
    set_callback(psthPlot, {mfilename, 'plotPSTH'});
    
    ToggleParam(obj, 'plotSides', 0, 630, 100, ...
        'OnString', 'M', 'OffString', 'R', ...
        'position', [630, 100, 20, 20], ...
        'TooltipString', sprintf('\nBlack: plot mean PSTH only \nBrown: plot mean and range of PSTH'));
    
    PushbuttonParam(obj, 'openinDisp', 450, 120, 'label','Open data in dispatcher');
    set_callback(openinDisp, {mfilename, 'openInDispatcher'});
    
    PushbuttonParam(obj, 'openSetinDisp', 450, 140, 'label','Open settings in dispatcher');
    set_callback(openSetinDisp, {mfilename, 'openSettingsInDispatcher'});
    
    PushbuttonParam(obj, 'openLateSetinDisp', 450, 160, 'label','Open latest settings');
    set_callback(openLateSetinDisp, {mfilename, 'openLatestSettingsInDispatcher'});
    
    
    PushbuttonParam(obj, 'openVideoButton', 450, 180, 'label','Open video for this session');
    set_callback(openVideoButton, {mfilename, 'openVideoAction'});
    
    
    ToggleParam(obj, 'showhidetags',0, 450, 200, 'label','Tag Manager');
    set_callback(showhidetags, {mfilename, 'show_tags'});
    
    ToggleParam(obj, 'enable_tags',getpref('neurobrowser','enable_tags',1), 450, 200,...
        'OnString','Tag Manager Enabled',...
        'OffString','Tag Manager Disabled',...
        'TooltipString', sprintf('\nSet this to OFF if you have a slow connection'));
    
    set_callback(enable_tags, {mfilename, 'enable_tags'});
    
    TagManager(obj,'init_with_gui',-1,-1);
    TagManager(obj,'showhide',0);
    
    neurobrowser('fillExprmtrMenu');
    
    return;
    % init
end
%% Deal with the other possible behaviors
set(value(myfig),'Pointer','watch')
drawnow
if nargin>=2 && isa(varargin{1}, class(obj)), action = varargin{2}; varargin = varargin(3:end);
else                                          action = varargin{1}; varargin = varargin(2:end);
end;

switch action,
    
    %% fillExprmtrMenu
    
    case 'fillExprmtrMenu',
        setpref('neurobrowser','only_phys',value(only_phys));
        disable(ExprmtrMenu); %#ok<NODEF>
        [xprs]=getExperimenters(value(only_phys));
        
        if isempty(xprs)
            xprs={''};
        end
        
        
        
        mh=get_ghandle(ExprmtrMenu);
        set(mh,'String',xprs);
        try
            ExprmtrMenu.value=getpref('neurobrowser','experimenter',1);
        catch
            ExprmtrMenu.value=1;
        end
        enable(ExprmtrMenu);
        neurobrowser('fillRatMenu');
        
        %% fillRatMenu
    case 'fillRatMenu'
        
        disable(ExprmtrMenu); %#ok<NODEF>
        disable(RatMenu);
        
        setpref('neurobrowser','experimenter',value(ExprmtrMenu));
        mh=get_ghandle(RatMenu);
        
        if isempty(value(ExprmtrMenu))
            set(mh, 'String', {''});
        elseif strcmp(value(ExprmtrMenu),'Rigs')
            riglist=bdata('select distinct(hostname) from sessions where sessiondate>"{S}" and hostname like "Rig%" order by hostname',datestr(now-30,'yyyy-mm-dd'));
            set(mh,'String', riglist)
        else
            rats=getRats(value(ExprmtrMenu),value(only_phys));
            set(mh, 'String', rats);
        end
        RatMenu.value=1;
        if isempty(value(RatMenu))
            SessInfo.value=['Sorry, ' value(ExprmtrMenu) ' does not have any rats with settings.'];
        end
        enable(RatMenu);
        enable(ExprmtrMenu);
        neurobrowser('fillSessList');
        %% fillSessList
    case 'fillSessList'
        
        disable(ExprmtrMenu); %#ok<NODEF>
        disable(RatMenu);
        mh=get_ghandle(SessList);
        
        if isempty(value(RatMenu))
            set(mh, 'String', {''});
            sessids.value=[];
        else
            [sessid, sessstr]=getSessions(value(RatMenu),value(only_phys));
            set(mh, 'String', sessstr);
            sessids.value=sessid;
        end
        SessList.value=1;
        enable(RatMenu);
        enable(ExprmtrMenu);
        %neurobrowser('fillCellList');
        neurobrowser('showSessInfo');
        
        
        %% fillCellList
    case 'fillCellList'
        
        mh=get_ghandle(CellList);
        sh=get_ghandle(SessList);
        sind=get(sh,'Value');
        set(mh,'Value',1)  % do this here so the value will not be set to an invalid value
        
        if isempty(value(SessList))
            set(mh, 'String', {''});
        else
            [cellid]=getCells(sessids(sind));
            set(mh, 'String', cellid);
        end
        %	set(mh,'Value',1)
        CellList.value=1;
        enable(RatMenu);
        enable(ExprmtrMenu);
        neurobrowser('showCellInfo');
        
        
        %% set_experimenter
    case 'set_experimenter'
        exprstr=varargin{1};
        ExprmtrMenu.value_callback=exprstr;
        % This is a workaround for a non-reproducible gui bug in the
        % experimenter dropdown.
        
        %% showSessInfo
    case 'showSessInfo'
        sh=get_ghandle(SessList);
        sind=get(sh,'Value');
        sessid.value=sessids(sind);
        if sessid>0
        [str,protostr,sessdate]=getSessInfo(value(sessid));
        sessiondate.value=sessdate;
        protocol.value=protostr;
        mh=get_ghandle(SessInfo);
        set(mh,'String',str);
        if enable_tags==1
            TagManager(obj,'update');
        end
        neurobrowser('fillCellList');
        else
            mh=get_ghandle(SessInfo);
            set(mh,'String','');
        end
        %% showCellInfo
    case 'showCellInfo',
        cellid.value=value(CellList);
        if numel(value(cellid))==1
            str=getCellInfo(cellid+0);
        else
            str='Cannot display info for multiple cells';
        end
        mh=get_ghandle(CellInfo);
        set(mh,'String',str);
        
        
        
        % fill event list - this might be ugly.
        
        % 		fn=fieldnames(peh{1}
        
        %% show_tags
    case 'show_tags'
        if enable_tags==1
            TagManager(obj,'showhide',value(showhidetags));
        end
        
        
        %% 'enable_tags'
    case 'enable_tags'
        setpref('neurobrowser','enable_tags',value(enable_tags));
        
        %% get_protocol
        
    case 'get_protocol',
        obj=value(protocol);
        %% get_sessid
        
    case 'get_sessid',
        obj=value(sessid);
        %% get_info
    case 'get_info',
        obj=[];
        obj.experimenter= value(ExprmtrMenu);
        [obj.protocol,obj.sessdate,obj.ratname]=bdata('select protocol, sessiondate, ratname from sessions  where sessid = "{S}"',value(sessid));
        obj.protocol=obj.protocol{1};
        obj.sessdate=obj.sessdate{1};
        obj.ratname=obj.ratname{1};
        %% helper_vars
    case 'helper_vars',
        try
            hv=get_helper_vars(sessid+0);
            assignin('base','hv',hv);
        catch ME
            showerror;
            fprintf(2,'Error loading helper vars\n')
        end
        %% Load Session Data
    case 'plotSess',
        try
            
            pd=bdata('select protocol_data from sessions where sessid ="{Si}"',value(sessid));
            peh=get_peh(value(sessid));
            assignin('base','pd',pd{1});
            assignin('base','peh',peh);
            
            
            
            
        catch
            warning('neurobrowser:plotsess',['no session plotting function defined for protocol:' value(protocol)]);
        end
        
        %% Open in Dispatcher
    case 'openInDispatcher',
        openInDispatcher(value(protocol),value(ExprmtrMenu), value(RatMenu),value(sessid));
        
        %% Open in Dispatcher
    case 'openSettingsInDispatcher',
        openSettingsInDispatcher(value(protocol),value(ExprmtrMenu), value(RatMenu),value(sessid));
    case 'openLatestSettingsInDispatcher',
        openSettingsInDispatcher(value(protocol),value(ExprmtrMenu), value(RatMenu),value(sessid),1);
  case 'openVideoAction',
       [exp,ratn,sdate]=bdata('select experimenter, ratname, sessiondate from sessions where sessid="{S}"',value(sessid)); 
       openVideo(exp{1}, ratn{1},sdate{1});
        
       
        %% plotPSTH
    case 'plotPSTH',
        
        cs=value(CellList);
        
        for tx=1:numel(cs)
            summary_plot(cs,'by_sounds',1,'correct_only',1);
        end
        %% sendToPokesPlot
    case 'sendToPokesPlot'
        
        % get the data from MySQL:
        cs=celllisthelper(CellList); %#ok<NODEF>
        if ~isempty(cs),
            [cid,ts]=bdata(['select cellid,ts from spktimes where cellid in (' cs ' )']);
        end;
        
        sp = get_sphandle('name', 'I_am_PokesPlotSection');
        % If a pokes plot isn't open yet, open one:
        if isempty(sp),
            % We're going to try to get the state colors from the protocol. First
            % we see whether state_colors.m is a method of the protocol object.
            % If that doesn't work, we try the action 'get_state_colors'. If that
            % doesn't work, we use neurobrowser's default state colors (which are
            % the same as ProAnti2's on 2-Apr-08.
            
            % Does the parsed_events SoloParamHandle exist already?
            
            
            protocol_name = bdata('select protocol from sessions where sessid="{Si}"', sessid+0);
            protocol_obj  = eval(protocol_name{1});
            the_state_colors = [];
            if ismethod(protocol_obj, 'state_colors'),
                the_state_colors = struct('states', state_colors(protocol_obj));
            end;
            if isempty(the_state_colors) || ~isstruct(the_state_colors),
                try
                    the_state_colors = struct('states', eval([protocol_name{1} '(''get_state_colors'')']));
                catch
                end;
            end;
            if isempty(the_state_colors) || ~isstruct(the_state_colors),
                the_state_colors = state_colors(obj);
            end;
            
            PokesPlotSection(obj, 'init', -100, -100, the_state_colors);
            
            sp = get_sphandle('name', 'I_am_PokesPlotSection');
        end;
        
        pe = get_sphandle('fullname', 'ProtocolsSection_parsed_events');
        if isempty(pe), % If not, create it, give it to PokesPlot, and also create
            % and give all the other globals that PokesPloy expects:
            
            SoloParamHandle(obj, 'parsed_events'); pe = parsed_events;
            SoloParamHandle(obj, 'latest_parsed_events');
            SoloParamHandle(obj, 'n_done_trials');
            SoloParamHandle(obj, 'n_started_trials');
            SoloParamHandle(obj, 'n_completed_trials');
            DeclareGlobals(obj, 'ro_args', ...
                {'parsed_events', 'latest_parsed_events', 'n_done_trials', ...
                'n_started_trials', 'n_completed_trials'});
        else
            pe = pe{1};
        end;
        
        
        % Now set the value of parsed_events and its history over trials:
        pevs=get_peh(sessid+0);
        for i=1:length(pevs), peh{i} = pevs(i); end;
        
        if isempty(peh),
            fprintf(1, 'Neurbrowser (560) : No history of parsed_events, exiting without redrawing\n');
        else
            set_history(pe, peh);
            nullstruct1 = struct('starting_state', [], 'ending_state', [], 'state_0', [NaN peh{end}.states.state_0(2,1)]);
            nullstruct2 = struct('starting_state', struct, 'ending_state', struct);
            pe.value                   = struct('states', nullstruct1, 'pokes', nullstruct2);
            latest_parsed_events.value = struct('states', nullstruct1, 'pokes', nullstruct2);
            n_done_trials.value        = length(peh);
            n_completed_trials.value   = length(peh);
            n_started_trials.value     = length(peh)+1;
            
            % If I can, set the spikes in parsed_events.
            if ~isempty(cs),
                %           if isempty(ts)
                %               ts=
                set_spikes_in_parsed_events(pe, ts{1});
            end;
            
            owner = get_owner(sp{1});
            PokesPlotSection(eval(owner(2:end)), 'redraw');
        end;
        
        
        
        %% plotCutting
    case 'plotCutting',
        cn=bdata('select cutting_notes from phys_sess where sessid="{Si}"',sessid+0');
        if isempty(cn)
            cn{1}='';
        end
        cn=cn{1}';
        cn(cn==9)=32;
        h=msgbox(char(cn),['Cutting Notes for session ' num2str(sessid+0)]);
        c=get(h,'Children');
        c2=get(c(1),'Children');
        set(c2,'FontSize',11);
        p=get(h,'Position');
        set(h,'Position',[p(1) p(2) p(3) p(4)+20])
        
        
        %% Close
        
    case  'Close'
        delete(value(myfig));
        
        delete_sphandle('owner', ['^@', mfilename '$']);
        obj = [];
        
        
        
        
        
        
        
    otherwise
        warning('Unknown action " %s" !', action);%#ok<WNTAG>
end
set(value(myfig),'Pointer','arrow')
return;


function popList(lp,str)

lp.value=1;
mh=get_ghandle(lp);
set(mh,'String',str);
lp.value=1;

function x=celllisthelper(CL)
tx=value(CL);
x='';
if isnumeric(tx)
    x=num2str(tx);
else
    for xi=1:numel(tx)
        x=[x tx{xi} ','];
    end
    x=x(1:end-1);
end


function [cond,condstr]=procTT(tpd,TTL)
cond=0;
condstr=[];
if ~iscell(TTL)
    TTL={TTL};
end
for lx=1:numel(TTL)
    try,
        cond=cond+10^(lx-1)*tpd.(TTL{lx});
        condstr=[condstr TTL{lx} ','];
    catch,
        1;
    end;
end
condstr=condstr(1:end-1);







