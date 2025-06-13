function out = Control(varargin)
% CONTROL(ACTION,[NAME])
% Call them all or just one called NAME.
% ACTION is 'init', 'sweep', 'trial', 'close'.
% 'init' must be called with module NAME and
% optionally with it's priority.
%
% ZFM
%
% changed file/new callback to sure_reset; 
% added "do you want to save" to sure_reset
% added pathdisplay update to set_path
% mike wehr 9-24-01

global exper

out = [];
if nargin > 0
	action = lower(varargin{1});
else
	action = lower(get(gcbo,'tag'));
end

switch action
	
% handle the big four (init,slice,trial,close)
case 'init'
%     user = inputdlg('Enter user name:','Initialization',1,{'carlos'});
%     if isempty(user)
%     	InitParam(me,'user','value','');
%         return;
%     else
%         user = user{1};
%     end
    user = 'carlos';
    fig= ModuleFigure(me,'pos',[5 608 128 120]);
	
	hs = 60;
	h = 5;
	vs = 20;
	n = 0;
	

	InitParam(me,'user','value',user,'ui','edit','tooltip','Used to keep track of prefs and window layout');
    InitParam(me,'expid','value','z001a','ui','edit');
	InitParam(me,'sequence','list',{});
	InitParam(me,'priority','value',0);		% control is not called like a normal module!
	
	InitParam(me,'TrialDur','ui','edit','value',20,'pref',1,'save',1,'pos',[h n*vs hs vs]); n=n+1;
	InitParam(me,'SliceRate','ui','edit','format','%d','value',0,'pref',1,'pos',[h n*vs hs vs]); n=n+1;
%	InitParam(me,'SliceRate','value',0,'pref',1);
	InitParam(me,'Start','value',clock,'format','clock');
	InitParam(me,'TrialStart','value',clock,'format','clock','save',1);
	InitParam(me,'ITI','ui','edit','format','%d','value',60,'pref',1,'pos',[h n*vs hs vs]); n=n+1;
	InitParam(me,'Advance','ui','checkbox','value',0,'pos',[h n*vs hs vs]); n=n+1;
	InitParam(me,'Trial','ui','disp','format','%d','value',1,'save',1,'pos',[h n*vs hs vs]); n=n+1;
	InitParam(me,'Slice','value',1);
	InitParam(me,'TrialTime','ui','disp','format','%4.2f','pos',[h n*vs hs vs]); n=n+1;
	InitParam(me,'ExpTime','ui','disp','format','clock','save',1,'pos',[h n*vs hs vs]); n=n+1;
		InitParam(me,'EndTrial','value',0);
	InitParam(me,'EndExp','value',0);
	InitParam(me,'SlicePerTrial','value',...
		GetParam(me,'SliceRate')*GetParam(me,'TrialDur'));
    SetParamUI(me,'expid','pos',[h n*vs hs vs]); n=n+1;
	SetParamUI(me,'user','pos',[h n*vs hs vs]); n=n+1;
		
	InitParam(me,'Run','value',0,'ui','togglebutton','pref',0,'pos',[h n*vs hs vs]);
	SetParamUI(me,'Run','string','Run','label',''); 
    
    % reset
	uicontrol(fig,'string','Reset','tag','reset','style','pushbutton',...
		'callback',[me '(''sure_reset'');'],'foregroundcolor',[.9 0 0],'pos',[h+hs n*vs hs vs]); 
    n=n+1;

    
%    uicontrol(fig,'tag','save_matfile_button','callback',[me ';'],'string','Save','pos',[h+hs n*vs hs vs]); n=n+1;
	
	% message box
	uicontrol(fig,'tag','message','style','edit',...
		'enable','inact','horiz','left','pos',[h n*vs hs*2 vs]); n = n+1;

 	InitParam(me,'matfile','value','');

    % set paths
    InitParam(me,'datapath','value',[pwd filesep 'data']);
  	InitParam(me,'modpath','value',[pwd filesep 'modules']);        % now assuming pwd is the exper directory
    check_paths;
    
    
    hf = uimenu('label','File');
  	uimenu(hf,'label','New...','tag','new_acquire','callback',[me ';']);
	uimenu(hf,'label','Open...','tag','restore_matfile','callback',[me ';']);
	uimenu(hf,'label','Save','tag','save_matfile','callback',[me ';']);
	uimenu(hf,'label','Save as...','tag','save_as_matfile','callback',[me ';']);
    uimenu(hf,'label','Autosave','tag','autosave','checked','on','callback',[me ';'],'separator','on');
	uimenu(hf,'label','Set data path...','tag','datapath','callback',[me ';']);
    
    hf2 = uimenu('label','Prefs');
    uimenu(hf2,'label','Save prefs','tag','save_prefs','callback',[me ';']);
    uimenu(hf2,'label','Restore prefs','tag','restore_prefs','callback',[me ';']);
    uimenu(hf2,'label','Clear prefs','tag','clear_prefs','callback',[me ';']);
	
	uimenu(fig,'label','Modules','tag','modules');
	mod_menu(fig,'modload');

	set(fig,'pos',[5 768-n*vs-40 128 n*vs]);

	out = sequence;
	
	CallModules(GetParam(me,'sequence','list'),'trialready');
    
    
    
case 'reinit'
    user = inputdlg('Enter user name:','Login',1,{'marx'});
    if isempty(user)
        return
    else
        user = user{1};
    end
       
    fig= ModuleFigure(me,'pos',[5 608 128 120]);
	
	hs = 60;
	h = 5;
	vs = 20;
	n = 0;

  	InitParam(me,'TrialDur','value',20,'ui','disp','save',1,'pos',[h n*vs hs vs]); n=n+1;
%	InitParam(me,'ExpTime','pref',0,'ui','disp','format','clock','save',1,'pos',[h n*vs hs vs]); n=n+1;
	InitParam(me,'TrialStart','value',clock,'format','clock','save',1);
    
    InitParam(me,'sequence','list',{});
    InitParam(me,'priority','value',0);		% control is not called like a normal module!
    
    InitParam(me,'Trial','pref',0,'ui','edit','format','%d','value',0,'range',[0 0],'pos',[h n*vs hs vs]);
    SetParamUI(me,'trial','callback','control(''trialreview'');');
    uicontrol(fig,'tag','trial_plus','string','+','pos',[115 n*vs+2 15 15],'callback',[me ';']); 
    uicontrol(fig,'tag','trial_minus','string','-','pos',[100 n*vs+2 15 15],'callback',[me ';']); n=n+1;
    
	InitParam(me,'ExpTime','pref',0,'ui','disp','format','clock','pos',[h n*vs hs vs]); n=n+1;

    InitParam(me,'expid','pref',0,'ui','disp','value','','pos',[h n*vs hs vs]); n=n+1;
    InitParam(me,'user','pref',0,'ui','edit','value',user,'pos',[h n*vs hs vs]); n=n+1;

    
	% message box
	uicontrol(fig,'tag','message','style','edit',...
		'enable','inact','horiz','left','pos',[h n*vs hs*2 vs]); n = n+1;
	InitParam(me,'matfile','value','');


    % set paths
	InitParam(me,'datapath','value',[pwd filesep 'data']);
  	InitParam(me,'modpath','value',[matlabroot '\work\exper']);
    check_paths;
    
	hf = uimenu('label','File');
    
	uimenu(hf,'label','New...','tag','new_analyze','callback',[me ';']);
	uimenu(hf,'label','Open...','tag','open_matfile','callback',[me ';']);
	uimenu(hf,'label','Save','tag','save_matfile','callback',[me ';']);
	uimenu(hf,'label','Save as...','tag','save_as_matfile','callback',[me ';']);
    
    hf2 = uimenu('label','Prefs');
    uimenu(hf2,'label','Save prefs','tag','save_prefs','callback',[me ';']);
    uimenu(hf2,'label','Restore prefs','tag','restore_prefs','callback',[me ';']);
    uimenu(hf2,'label','Clear prefs','tag','clear_prefs','callback',[me ';']);
   
   	uimenu(fig,'label','Modules','tag','modules');
	mod_menu(fig,'modreload');

	set(fig,'pos',[5 768-n*vs-40 128 n*vs]);
    
   	out = sequence;

	
	
case 'slice'
	if GetParam(me,'slice') == 0
		CallModule(me,'trial');
    else
		CallModules(GetParam(me,'sequence','list'),'slice');
		
		% call once per sec
		if ~mod(GetParam(me,'slice'),GetParam(me,'slicerate'))
			SetParam(me,'exptime',etime(clock,GetParam(me,'start')));	
		end
		SetParam(me,'trialtime',slice2time(GetParam(me,'slice')));
        
		if GetParam(me,'endtrial') | GetParam(me,'slice') >= GetParam(me,'SlicePerTrial')
            if ExistParam('ai','open') & Getparam('ai','open')  % Modified by Lung-Hao Tai, 05/01/2003
                stop(exper.ai.daq);                             % important for slice mode, prevent AI trigger extra slice causing AI to stop; 10/13/2003 Lung-Hao Tai
            end            
            CallModule(me,'trial');
        else
			AddParam(me,'Slice',1);			% Advance to the next slice
        end
	end
	
case 'trial'
    
	% exp time has to be set because there may have been no slices run
    SetParam(me,'slice',1);
    SetParam(me,'exptime',etime(clock,GetParam(me,'start')));	
    
  	SaveParamsTrial(me);
	CallModules(GetParam(me,'sequence','list'),'trialend');
	
	% deal with the ending of the last trial
	SetParam(me,'endtrial',0);
	
	% now get ready for the next trial
	if ExistParam('ao')
		ao('pause')
	end


	
	if GetParam(me,'run') & GetParam(me,'advance')
		message(me,'Inter-trial pause...');
		
		elapsed = etime(clock,GetParam(me,'trialstart'));	
		
		n = ceil(GetParam(me,'iti')-elapsed);
		
		while n>0 & GetParam(me,'run')
			message(me,sprintf('Inter-trial pause %d',n));
			pause(1);
			n=n-1
		end
	else
		SetParamUI(me,'run','BackgroundColor',get(gcf,'Color'));
	end

    %    set(findobj('tag','save_matfile_button'),'background',[1 0 0],'enable','on');
    auto_save;

	AddParam(me,'trial',1);

	CallModules(GetParam(me,'sequence','list'),'trialready');

	% we may start another trial
	if GetParam(me,'endexp') | ~GetParam(me,'advance')
		SetParam(me,'run',0);
        trigger;
		SetParam(me,'endexp',0);
        Message(me,'');
    else
		% now start the trial
		trigger;
    end

	
case 'close'
%	CallModules(GetParam(me,'sequence','list'),'close');
% called in ModuleClose instead


case 'preload'
    CallModules(GetParam(me,'sequence','list'),'preload');
    
    
case 'load'
    LoadParams(me);
    
    
case 'trialreview'
%    update_review_params(GetParam(me,'trial'));
    if GetParam(me,'trial') > 0
%        UpdateReviewParams('control',GetParam(me,'trial'));
        CallModules(GetParam(me,'sequence','list'),'trialreview');
    end


case 'trial_plus'
    SetParam(me,'trial',GetParam(me,'trial')+1);
    Control('trialreview');
    
case 'trial_minus'
    SetParam(me,'trial',GetParam(me,'trial')-1);
    Control('trialreview');


	
% handle UI button callbacks
    
case 'new_analyze'
    resp = questdlg('You are about to clear all data. Save matfile before continuing?');
    switch resp
    case 'Yes'
        save_as_matfile;
    case 'No'
    case 'Cancel'
        return;
    end
    
	SetParam(me,'slice',1);
	SetParam(me,'trial',1);
	SetParam(me,'endtrial',0);
	SetParam(me,'endexp',0);
	SetParam(me,'start',clock);
	SetParam(me,'trialtime',0);
	Message(me);
    
	CallModules(GetParam(me,'sequence','list'),'reset');
    

    
case 'new_acquire' % used to be called 'reset'
    resp = questdlg('You are about to clear all data. Save matfile before continuing?');
    switch resp
    case 'Yes'
        save_as_matfile;
    case 'No'
    case 'Cancel'
        return;
    end
    
	SetParam(me,'run',0);
	CallModules(GetParam(me,'sequence','list'),'reset');
    
    CallModules(GetParam(me,'sequence','list'),'slicerate')
	
%	trigger now will turn things off
	trigger;
	
	SetParam(me,'slice',1);
	SetParam(me,'trial',1);
	SetParam(me,'endtrial',0);
	SetParam(me,'endexp',0);
	SetParam(me,'start',clock);
	SetParam(me,'trialtime',0);
	SetParam(me,'exptime',etime(clock,GetParam(me,'start')));
	Message(me);
    
    check_paths;

    set(findobj(gcf,'tag','save_matfile_button'),'background',get(gcf,'color'),'enable','on');
   
	CallModules(GetParam(me,'sequence','list'),'trialready');

% from M Wehr & L Tai 9/15/01    
case 'sure_reset'
    name = questdlg('Would you like to save Exper?');
    if strcmp(name,'Yes')
        control('save_as_matfile');   
    end
	 name = questdlg('Are you sure you want to reset all data and create a new Exper?');
    if strcmp(name,'Yes')
        control('reset');   
    end    
    
    
case 'reset'
	SetParam(me,'run',0);
	CallModules(GetParam(me,'sequence','list'),'reset');
    
    CallModules(GetParam(me,'sequence','list'),'slicerate')
	
%	trigger now will turn things off
	trigger;
	
	SetParam(me,'slice',1);
	SetParam(me,'trial',1);
	SetParam(me,'endtrial',0);
	SetParam(me,'endexp',0);
	SetParam(me,'start',clock);
	SetParam(me,'trialtime',0);
	SetParam(me,'exptime',etime(clock,GetParam(me,'start')));
	Message(me);
    
    check_paths;

	CallModules(GetParam(me,'sequence','list'),'trialready');

	
	
case 'run'
    
   trigger;

	
case 'trialdur'
	AI('samplerate');
	if existparam('ao','board') % LHT
		AO('reset');
	end
	CallModules(GetParam(me,'sequence','list'),'slicerate');
	
case 'slicerate'
	if GetParam(me,'SliceRate') == 0
		SetParam(me,'SlicePerTrial',1);
	end
	CallModules(GetParam(me,'sequence','list'),'slicerate');
    
case 'save_matfile_button'
    save_matfile;
    
case 'save_matfile'
	save_matfile;
    set(findobj('tag','save_matfile_button'),'background',get(gcf,'color'),'enable','on');
    
case 'save_as_matfile'
    save_as_matfile;
    
case 'datapath'
    set_path('datapath','Select a file in the DATA directory...');
    
case 'open_matfile'
    % called when reviewing data
    ok = open_exper;
    if ok
        SetParam(me,'trial','range',[1 length(exper.control.param.trialstart.trial)],'value',1);
        message(me,'Opened matfile');
    else
        message(me,'Problem opening experiment','error');
    end

    
case 'restore_matfile'
    % called when acquiring data
    ok = open_exper;  
    if ok
    	CallModules(GetParam(me,'sequence','list'),'trialready');
        message(me,'Restored matfile');
    else
        message(me,'Problem opening experiment','error');
    end
    
    
case 'autosave'
    show = get(gcbo,'checked');
    if strcmp(show,'off')
        set(gcbo,'checked','on');
    else
        set(gcbo,'checked','off');
    end
    
case 'restore_prefs'
    message(me,sprintf('Restoring %s prefs...',GetParam(me,'user')));
	RestorePrefs(GetParam(me,'user'));
    restore_layout;
    message(me,'');
    
    
case 'save_prefs'
    message(me,sprintf('Saving %s prefs...',GetParam(me,'user')));
	SavePrefs(GetParam(me,'user'));
    save_layout;
    message(me,'');
    
case 'clear_prefs'
	if ispref(GetParam(me,'user'))
        rmpref(GetParam(me,'user'));
    end
    message(me,sprintf('Cleared %s prefs',GetParam(me,'user')));


	
case 'modload'
	name = get(gcbo,'user');
	
	if strcmp(get(gcbo,'checked'),'on')
		set(gcbo,'checked','off');
		ModuleClose(name);
	else
		set(gcbo,'checked','on');
		ModuleInit(name);
	end
%    restore_layout;
    
case 'modreload'
    
    if ~isempty(gcbo)
        name = get(gcbo,'user');
        menu = gcbo;
    else
        name = varargin{2};    
        menu = findobj('tag','modreload','label',name);
    end
    checked = strcmp(get(menu,'checked'),'on');
    
    if checked
        set(menu,'checked','off');
        ModuleClose(name);
    else
        %        if isfield(exper,name)
        if 1
            set(menu,'checked','on');
            ModuleInit(name,'reinit');
        else
            ans = questdlg(sprintf('Module %s doesn''t exist yet.\nInitialize new module?',name));
            if strcmp(ans,'Yes')
                set(menu,'checked','on');
                ModuleInit(name,'reinit');
            end
        end
    end
%    restore_layout;    
    CallModule(name,'load');
    
    
case 'save_layout'
    save_layout;
    message(me,'Saved layout');
    
case 'restore_layout'
    restore_layout;
    message(me,'Restored layout');
    
case 'sequence'
	out = sequence;
	
	
case 'slice2time'
	out = slice2time(varargin{2:end});
	
case 'time2slice'
	out = time2slice(varargin{2:end});
    

    	   
otherwise
	
end

% begin local functions

function out = me
	out = lower(mfilename); 
	
function out = callback
	out = [lower(mfilename) ';'];

	
function out = sequence
global exper

	seq = {};
% figure out the order in which to call modules using their priorities
	names = fieldnames(exper);
	for p=1:length(names)
		prior(p) = GetParam(names{p},'priority') * GetParam(names{p},'open');
	end
	[y sorted] = sort(prior);
	n = 1;
	for p=1:length(sorted)
		name = names{sorted(p)};
		useit = prior(sorted(p)) > 0;
		if useit
			seq(n) = {name};
			n=n+1;
		end
	end
	SetParam(me,'sequence','list',seq,'value',1);
	SetParam(me,'dependents','list',seq,'value',1);
	out = seq;

	
	
function save_as_matfile
global exper
	
	prompt = 'Save experiment...';
	filetype = '*.mat';
	filterspec = [GetParam(me,'datapath') '\' filetype];
	[filename, pathname] = uiputfile(filterspec, prompt);
	if filename == 0 return; end
	
	message(me, sprintf('Saving %s...',filename));
    save([pathname filename], 'exper');
    message(me,'');
	SetParam(me,'matfile',filename);
	SetParam(me,'datapath',pathname);
    
    
function save_matfile
global exper
    filename = GetParam(me,'matfile');
    if isempty(filename)
        save_as_matfile;
        return;
    end
    pathname = GetParam(me,'datapath');
    if size(dir([pathname filename ]),1) |size(dir([pathname filename '.mat']),1)
        name = questdlg(['Data file ' pathname filename  ' exists. Do you want to overwrite?']); %ask user to be sure to overwrite data file; 02/08/2004 Lung-Hao Tai
        if strcmp(name,'Yes')
            message(me, sprintf('Saving %s...',filename));
            save([pathname filename], 'exper');
        elseif strcmp(name,'No')   
            save_as_matfile;
        else
            return;
        end
    else
        message(me, sprintf('Saving %s...',filename));
        save([pathname filename], 'exper');
    end
    message(me,'');
    

function ok = open_exper
global exper

    ok = 1;
	prompt = 'Open experiment...';
	filetype = '*.mat';
	filterspec = [GetParam(me,'datapath') '\' filetype];
	[filename, pathname] = uigetfile(filterspec, prompt);
	if filename == 0 
        ok = 0;
        return; 
    end
	SetParam(me,'datapath',pathname);

    % get the module list before loading the structure
    modules = GetParam(me,'sequence','list');
    
    message(me,sprintf('Loading %s...',filename));
    control('preload');
    try
        load([pathname filename], 'exper');
    catch
    end
    message(me,'');
	
    control('load');
    CallModules(modules,'load');


function time = slice2time(slice,sample)
time = slice * GetParam('ai','SamplesPerSlice')/GetParam('ai','SampleRate');
if nargin > 1
	time = time + sample/GetParam('ai','SampleRate');
end

function slice = time2slice(time)
slice = floor(time * GetParam('ai','SampleRate')/GetParam('ai','SamplesPerSlice'));


function trigger
global exper

	message(me,'');

	SetParam(me,'trialstart',clock);

    if GetParam(me,'run')
        
        SetParamUI(me,'slicerate','disable');
        SetParamUI(me,'trialdur','disable');
        
        if ExistParam('ai','open')           % 		Modified by Lung-Hao Tai, 05/01/2003
            AI('slicerate');
		end
        
        % first start ao, which either waits for trigger or 
		% starts immediately
		if ExistParam('ao','samplerate') & GetParam('ao','open')    % LHT
            ao('trigger');
		end
        if ExistParam('till','on')
            till('trigger');
        end
        if ExistParam('ai','open')           % 		Modified by Lung-Hao Tai, 05/01/2003
            ai('trigger');
        end
        if ExistParam('rpbox','open')       % 		Modified by Lung-Hao Tai, 05/01/2003
            rpbox('trigger');
        end
        if ExistParam('dio','open')          % 		Modified by Lung-Hao Tai, 05/01/2003
            dio('trigger');
        end
		message(me,sprintf('Acquiring %d sec trial...',GetParam(me,'trialdur')));
        if ExistParam('orca','open')         % 		Modified by Lung-Hao Tai, 05/01/2003
            Orca('focus',0);
            orca('trigger');
        end
    else
        if ExistParam('ai')
            ai('pause');
        end
		if ExistParam('ao')
			ao('pause');
		end
	     if ExistParam('rpbox','open')       % 		Modified by Lung-Hao Tai, 05/01/2003
            rpbox('pause');
        end
% 		SetParam('control','run',0);    % unnecessary  
% 		Modified by Lung-Hao Tai, 05/01/2003

	%	SetParamUI(me,'run','BackgroundColor',get(gcf,'Color'));
    
        SetParamUI(me,'slicerate','enable');
        SetParamUI(me,'trialdur','enable');

    
	end
    
    
function mod_menu(fig,tag)
global exper

men = findobj(fig,'type','uimenu','tag','modules');

% get rid of any items already in this menu
delete(findobj('parent',men));

uimenu(men,'tag','save_layout','label','Save layout','callback',callback);
uimenu(men,'tag','restore_layout','label','Restore layout','callback',callback);

	n=0;
	w = dir([GetParam(me,'modpath') filesep '*.m']);
	for p=1:length(w)
		m = w(p).name;
		if ~w(p).isdir
			name = lower(m(1:end-2));
			switch name
			case {'control', 'exper', 'rexper'}
				% ignore these
			otherwise
				op = 0;
				if n==0
                    mh = uimenu(men,'tag',tag,'label',name,'user',name,'callback',callback,'separator','on');
                else
                    mh = uimenu(men,'tag',tag,'label',name,'user',name,'callback',callback);
                end
                    
				if ExistParam(name)
					op = GetParam(name,'open');
				end
				if op
					set(mh,'checked','on');
				else 
					set(mh,'checked','off');
				end
				n = n+1;
 			end
		end
	end
    
    
function set_path(name,prompt)
global exper

    directory = GetParam(me,name);
    if isstr(directory) & exist(directory, 'dir')
        path = uigetfolder(prompt,[directory '\*.*']);
    else
        path = uigetfolder(prompt,'*.*');
    end
    
    if isequal(path,0)
        return;
    end
	SetParam(me,name,path);
	
	prefstr = sprintf('%s_%s',me,name);
	setpref(GetParam(me,'user'),prefstr,path);

		
    
function check_paths
global exper
  
    if isempty(dir(GetParam(me,'datapath')))
		set_path('datapath','Select a file in the DATA directory...');
    end
    
	if isempty(dir(GetParam(me,'modpath')))
		set_path('modpath','Select a file in the MODULE directory...');
		CallModule(me,'init');
	end
    
    CallModules(GetParam(me,'sequence','list'),'check_paths');
    
    
    
function save_layout
global exper

    user = GetParam(me,'user');
    modules = GetParam(me,'sequence','list');
    modules{end+1} = 'control';
    for n=1:length(modules)
        evalc(sprintf('SavePos(''%s'',''%s'');',user,modules{n}));
    end        
    
    
function restore_layout
global exper

    user = GetParam(me,'user');
    modules = GetParam(me,'sequence','list');
    modules{end+1} = 'control';
    for n=1:length(modules)
        if ExistParam(modules{n})
            evalc(sprintf('RestorePos(''%s'',''%s'');',user,modules{n}));
        end
    end        
    
    
    % save just the param values for a particular trial
function auto_save
global exper


    saveit = strcmp(get(findobj('tag','autosave'),'checked'),'on');
    if ~saveit
        return
    end

    modules = GetParam(me,'sequence','list');
    modules{end+1} = 'control';

    exper_autosave = [];
    for n=1:length(modules)
        
        eval_str = sprintf('exper_autosave.%s.param = exper.%s.param;',modules{n},modules{n});
        eval(eval_str);
        
    end
    
    filename = sprintf('%s_autosave.mat',GetParam(me,'expid'));
    pathname = GetParam(me,'datapath');
    save([pathname filename], 'exper_autosave');
    
    