function varargout = Group(varargin)
% Group
%
% This module collects groups of trials based on parameters such as odor ID.
% These can be used by other modules to select useful groups of trials for
% averaging, etc.
% 
%

global exper

out = lower(mfilename); 
if nargin > 0
	action = lower(varargin{1});
else
	action = lower(get(gcbo,'tag'));
end

switch action
	
case {'init','reinit'}
	
	fig = ModuleFigure(me,'visible','off');	
	
	SetParam(me,'priority',6);
    
 	hs = 200;
	h = 5;
	vs = 20;
	n = 0;
   
    
    uicontrol(fig,'style','pushbutton','string','Add','callback',[me ';'],'tag','add_from_param','pos',[h+hs/3 n*vs hs/3 vs]); 
    uicontrol(fig,'style','pushbutton','string','Add all','callback',[me ';'],'tag','add_all_from_param','pos',[h+hs*2/3 n*vs hs/3 vs]); 
    uicontrol(fig,'style','pushbutton','string','Collect','callback',[me ';'],'tag','collect','pos',[h n*vs hs/3 vs]); n=n+1
    InitParam(me,'value','ui','popupmenu','list',{' '},'value',1,'pos',[h n*vs hs vs]); n=n+1;
    InitParam(me,'param','ui','popupmenu','list',{' '},'value',1,'pos',[h n*vs hs vs]); n=n+1;
    InitParam(me,'module','ui','popupmenu','list',{' '},'value',1,'pos',[h n*vs hs vs]); n=n+1;
   
    update_collect;
    
    n=n+1;

    
%    InitParam(me,'review','ui','popupmenu','list',' ','value',1,'trials',' ','pos',[h n*vs hs vs]); n=n+1;

    uicontrol(fig,'style','pushbutton','string','Update','callback',[me ';'],'tag','update_group','pos',[h+hs*2/3 n*vs hs/3 vs]); 
    uicontrol(fig,'style','pushbutton','string','Del all','callback',[me ';'],'tag','del_all','pos',[h+hs/3 n*vs hs/3 vs]); 
    uicontrol(fig,'style','pushbutton','string','Move dn','callback',[me ';'],'tag','move_dn','pos',[h n*vs hs/3 vs]); n=n+1;
    
    uicontrol(fig,'style','pushbutton','string','New','callback',[me ';'],'tag','new_group','pos',[h+hs*2/3 n*vs hs/3 vs]); 
    uicontrol(fig,'style','pushbutton','string','Del','callback',[me ';'],'tag','del','pos',[h+hs/3 n*vs hs/3 vs]); 
    uicontrol(fig,'style','pushbutton','string','Move up','callback',[me ';'],'tag','move_up','pos',[h n*vs hs/3 vs]); n=n+1
    
    InitParam(me,'group','ui','popupmenu','list',{' '},'trials',{' '},'value',1,'pos',[h n*vs hs vs]); n=n+2;
  

    InitParam(me,'name','ui','edit','value','','pos',[h n*vs hs vs]); n=n+1;
    InitParam(me,'trials','ui','edit','value','','pos',[h n*vs hs vs]); n=n+1;

    n=n+1;
    InitParam(me,'invalid','ui','edit','value','','pos',[h n*vs hs vs]); n=n+1;
    InitParam(me,'valid','ui','edit','value','','pos',[h n*vs hs vs]); n=n+1;
    
    hf = uimenu(fig,'label','File');
	uimenu(hf,'label','Open...','tag','open','callback',[me ';']);
	uimenu(hf,'label','Save...','tag','save','callback',[me ';']);
    uimenu(hf,'label','Export...','tag','export','callback',[me ';'],'separator','on');
    uimenu(hf,'label','Import...','tag','import','callback',[me ';']);
    uimenu(hf,'label','Copy .sets','tag','copy_sets','callback',[me ';']);


    
    % message box
    uicontrol('parent',fig,'tag','message','style','edit',...
        'enable','inact','horiz','left','pos',[h n*vs hs vs]); n=n+1;
    
	set(fig,'pos',[142 480-n*vs 68+hs n*vs],'visible','on');
    
    
case 'slice'
	
case 'trialready'
    
case 'trialend'
   	SaveParamsTrial(me);
    
case 'close'
    
case 'preload'
	
case 'load'
    if ~isfield(exper,me)
        ModuleInit(me);
    end
    LoadParams(me);
    
case 'reset'
    SetParam(me,'group','value',1,'list',{' '},'trials',{' '});
    update_group;
    
    
% functions that are called by other modules that work with Group


case 'current'
% [trials, name] = Group('current')
% return the currently selected group of trials and its name
% trials is an array, name is a string. Invalid trials are
% removed. Both trials and name are passed as strings.

   varargout{1} = remove_invalid(GetParam(me,'trials'));
   varargout{2} = GetParam(me,'name');

   
case 'all'
% [trials, name] = Group('all')
% Return cell arrays of all the groups and their names. 
% Invalid trials are removed. Both trials and names are passed as strings.

   trials = GetParam(me,'group','trials'); 
   for n=1:length(trials)
       val_trials{n} = remove_invalid(trials{n});
   end
   varargout{1} = val_trials;
   if nargout > 1
       names = GetParam(me,'group','list');
       varargout{2} = names; 
   end
    
   
case 'all_valid'
    
    % trials = Group('all_valid')
    % Return all valid trials in all groups as a single list.
    
    
    val_trials = [];
    trials = GetParam(me,'group','trials'); 
    for n=1:length(trials)
        val_trials = [val_trials remove_invalid(trials{n})];
    end
    varargout{1} = sprintf('%d ',(sort(str2num(val_trials))));
    
    
case 'add'
% Group('add',trial,name]
% Add a trial to the group 'name'. Create a new group if 
% name does not exist.


    trials = GetParam(me,'group','trials'); 
    groups = GetParam(me,'group','list'); 
    
    new_trial = varargin{2};
    if ischar(new_trial)
        new_trial = str2num(new_trial)
    end
    new_group = varargin{3};
    
    % start at 2 because the first string is not used
    for n=1:length(groups)
        if ~isempty(groups{n}) & strmatch(groups{n},new_group)
            tr = str2num(trials{n});
            if isempty(find(tr == new_trial))
                trials{n} = num2str(sort([tr new_trial]));
            end
            SetParam(me,'group','trials',trials,'value',n);
            update_group;
            return;
        end
    end
    
    % search failed, so add a new one
    groups{end+1} = new_group;
    trials{end+1} = num2str(new_trial);
    
    SetParam(me,'group','list',groups,'trials',trials,'value',length(groups));
    
    update_group;
    

    
   
case 'match'
% [name, index] = Group('match',target_trial)
% Target is a string specifying a trial
% Returns the first group which includes the target trial.
% Name is a string and index is a number.

    target = varargin{2};
    if ischar(target)
        target = str2num(target);
    end
    trials = GetParam(me,'group','trials'); 
    groups = GetParam(me,'group','list'); 
    
    varargout{1} = [];
    for n=1:length(trials)
        tr = str2num(trials{n});
        if ~isempty(find(tr == target))
            varargout{1} = groups{n};
            if nargout > 1
                varargout{2} = n;
            end
            return;
        end
    end
    
    
case 'get'
% [trials, index] = Group('get',target_group)
% Returns the trials associated with a group
% Target_group can be either a string (group name)
% of the index of the group (value of the popupmenu ui).
% Trials are returned as a string. Invalid trials are removed.
    
    
    trials = GetParam(me,'group','trials'); 
    groups = GetParam(me,'group','list'); 
    
    target_group = varargin{2};
    
    % if passed a string, then search for it
    if ischar(target_group)
        % start at 2 because the first string is not used
        for n=1:length(groups)
            if strmatch(groups{n},target_group)
                varargout{1} = remove_invalid(trials{n});
                if nargout ==2 
                    varargout{2} = n;
                end
                return;
            end
        end
        % search failed
        varargout{1} = [];
    else 
        % if passed a number just return the trials
        varargout{1} = trials{target_group};
    end
    
case 'add_invalid'
% invalid = Group('add_invalid',trials)
% Add trials to the invalid list. Trials can be passed as
% an array or a string. Checks to avoid duplicates.

    trials = varargin{2};
    if ischar(trials)
        trials = str2num(trials);
    end
    
    invalid = GetParam(me,'invalid');
    if ~isempty(invalid)
        invalid = str2num(invalid);
        
        for n=1:length(trials)
            if isempty(find(trials(n) == invalid))
                invalid(end+1) = trials(n);
            end
        end
        invalid = sprintf('%d ',sort(invalid));
        SetParam(me,'invalid',invalid(1:end-1));
    else 
        SetParam(me,'invalid',num2str(trials));
    end
    
    
case 'remove_invalid'
% invalid = Group('remove_invalid',trials)
% Remove trials from the invalid list. Trials can be passed as
% an array or a string. It is NOT an error to try to remove 
% trials which are not presently invalid.
    
    trials = varargin{2};
    
    if ischar(trials)
        trials = str2num(trials);
    end
    invalid_num = str2num(GetParam('group','invalid'));
    for n=1:length(trials)
        good_ind = find(invalid_num ~= trials(n));
        invalid_num = invalid_num(good_ind);
    end
    
    new_invalid = sprintf('%d ',invalid_num); 
    SetParam('group','invalid',new_invalid(1:end-1));
    varargout{1} = new_invalid(1:end-1);
           


% handle UI parameter callbacks

    
case 'module'
    update_collect;
            
 
case 'value'
    trials = GetParamList(me,'value','trials');
    SetParam(me,'trials',trials);
	
    
case 'new_group'
    % update the group to reflect new trials and name
    trials_list = GetParam(me,'group','trials'); 
    trials_list{end+1} = ' ';    
    SetParam(me,'trials',' ');
    SetParam(me,'name',' ');
    SetParam(me,'group','trials',trials_list);
  
    name_list = GetParam(me,'group','list');      % list of names
    name_list{end+1} = ' ';
    SetParam(me,'group','list',name_list);
   
case 'update_group'
    % update the group to reflect new trials and name
    trials_list = GetParam(me,'group','trials'); 
    trials_list{GetParam(me,'group','value')} = GetParam(me,'trials');    
    SetParam(me,'group','trials',trials_list);
  
    name_list = GetParam(me,'group','list');      % list of names
    name_list{GetParam(me,'group','value')} = GetParam(me,'name');    
    SetParam(me,'group','list',name_list);
    update_group;

    
case 'collect'
    if ExistParam('control','run') & GetParam('control','run')
        message(me,'Stop run before collecting trials','error');
        return;
    else
        collect;
        message(me,'');
    end
    
    
    
    
case 'group'
    tr = GetParamList(me,'group','trials');

    SetParam(me,'trials',tr);
    SetParam(me,'name',GetParamList(me,'group','list'));
    

    
case 'add_from_param'
    trials = GetParam(me,'trials');
 
    if isempty(trials)
%        SetParam(me,'trials',select_trials(trs{GetParam(me,'value','value')}));
        return
    end


    trials_list = GetParam(me,'group','trials');  % list of trials
    name_list = GetParam(me,'group','list');      % list of names
    
    name = sprintf('%s',GetParamList(me,'value'));
    
    ind = length(trials_list)+1;
    
    trials_list{ind} = select_trials(trials);
    name_list{ind} = name;
        
    SetParam(me,'group','trials',trials_list,'list',name_list,'value',ind);
    
    update_group;
    
case 'add_all_from_param'
    for n=1:length(GetParam(me,'value','list'))
        SetParam(me,'value',n);
        Group('value');
        Group('add_from_param');
    end
 
    
case 'del'
    ind = GetParam(me,'group','value');
    trials_list = GetParam(me,'group','trials'); % list of trials
    name_list = GetParam(me,'group','list');  % list of comments
       
    k=1;
    for n=1:length(trials_list)
        if n ~= ind    
            new_name_list{k} = name_list{n};
            new_trials_list{k} = trials_list{n};
            k=k+1;
        end
    end
    ind = max([ind-1 1]);
    
    SetParam(me,'group','trials',new_trials_list,'value',ind,'list',new_name_list);
    update_group;
    
    
case 'del_all'
    if strcmp(questdlg('Remove all trials?'),'Yes')
        SetParam(me,'group','value',1,'list',{' '},'trials',{' '});
        update_group;
    end
    
case 'move_dn'
    % move the current group down in the list
    s_list = GetParam(me,'group','list');
    s_trials = GetParam(me,'group','trials');
    v = GetParam(me,'group','value');
    
    if v == 1
        return;
    end
    tmp = s_list{v-1};
    s_list{v-1} = s_list{v};
    s_list{v} = tmp;
    ttmp = s_trials{v-1};
    s_trials{v-1} = s_trials{v};
    s_trials{v} = ttmp;
    SetParam(me,'group','list',s_list);
    SetParam(me,'group','trials',s_trials);
    SetParam(me,'group','value',v-1);
    update_group;
    
case 'move_up'
    % move the current group up in the list
    s_list = GetParam(me,'group','list');
    s_trials = GetParam(me,'group','trials');
    v = GetParam(me,'group','value');
    
    if v == length(s_list)
        return;
    end
    
    tmp = s_list{v+1};
    s_list{v+1} = s_list{v};
    s_list{v} = tmp;
    ttmp = s_trials{v+1};
    s_trials{v+1} = s_trials{v};
    s_trials{v} = ttmp;
    
    SetParam(me,'group','list',s_list);
    SetParam(me,'group','trials',s_trials);
    SetParam(me,'group','value',v+1);
    update_group;
    
    
case 'open'
    
    path = get(get(gcbo,'parent'),'user');
    if isempty(path)
	    filterspec = '*.mat';
    else 
        filterspec = [path '\*.mat'];
    end
    prompt = 'Load groups from mat file...';
	[filename, pathname] = uigetfile(filterspec, prompt);
    if isequal(filename,0)|isequal(pathname,0)
         message(me,'Open canceled');
         return
    end
	set(get(gcbo,'parent'),'user',pathname);
    s = load([pathname '\' filename]);
    exper = setfield(exper,'group',s.group);
    message(me,['Opened ' filename]);
    LoadParams(me);
    
    
case 'save'
    path = get(get(gcbo,'parent'),'user');
    filterspec = sprintf('%s_groups.mat',GetParam('control','expid'));
    if ~isempty(path)
        filterspec = [path '\' filterspec];
    end
    prompt = 'Save groups to mat file...';
	[filename, pathname] = uiputfile(filterspec, prompt);
    if isequal(filename,0)|isequal(pathname,0)
         message(me,'Save canceled');
         return
    end
	set(get(gcbo,'parent'),'user',pathname);
    group = exper.group;
    save([pathname '\' filename],'group');
    message(me,['Saved ' filename]);
    
    
case 'export'
    % to format suitable for excel
    path = get(get(gcbo,'parent'),'user');
    filterspec = sprintf('%s_groups.txt',GetParam('control','expid'));
    if ~isempty(path)
        filterspec = [path '\' filterspec];
    end
    prompt = 'Export groups to text/xls file...';
	[filename, pathname] = uiputfile(filterspec, prompt);
    if isequal(filename,0)|isequal(pathname,0)
         message(me,'Export canceled');
         return
    end
	set(get(gcbo,'parent'),'user',pathname);
    fid = fopen([pathname '\' filename],'w');
    if fid == -1
        message(me,'Cannot write to file','error');
        return    
    end
    
    s_list = GetParam(me,'group','list');
    s_trials = GetParam(me,'group','trials');
    
    for n=1:length(s_list)
        
        fprintf(fid,'%s\t',s_list{n});
        tr = str2num(s_trials{n});
        for k=1:length(tr)
            fprintf(fid,'%d\t',tr(k));
        end
        fprintf(fid,'\n');
    end
    fclose(fid);
    message(me,['Exported ' filename]);
    
    
case 'import'
    path = get(get(gcbo,'parent'),'user');
    filterspec = '*.txt';
    if ~isempty(path)
        filterspec = [path '\' filterspec];
    end
    prompt = 'Import groups file...';
    [filename, pathname] = uigetfile(filterspec, prompt);
    if isequal(filename,0)|isequal(pathname,0)
        return
    end
    set(get(gcbo,'parent'),'user',pathname);
    
    % first read into lines
    parse = textread([pathname filename],'%s','commentstyle','matlab');
    
    k = 0;
    for n=1:length(parse)
        % is this a group name -- that is, not a trial number?
        if isempty(str2num(parse{n}))
            k=k+1;
            names{k} = parse{n};
            trials{k} = [];
        else
            trials{k} = [trials{k} ' ' parse{n}];
        end
    end
    
    message(me,sprintf('Imported %d groups',k))
     
    SetParam(me,'group','list',names);
    SetParam(me,'group','trials',trials);
    SetParam(me,'group','value',1);
    update_group;
 
    
case 'copy_sets'
    
    SetParam(me,'invalid',GetParam('sets','invalid'));
    SetParam(me,'valid',GetParam('sets','valid'));
    
    SetParam(me,'group','value',GetParam('sets','sets','value'));
    SetParam(me,'group','list',GetParam('sets','sets','list'));
    SetParam(me,'group','trials',GetParam('sets','sets','trials'));
    
    
    
    
   
otherwise
	
end

% begin local functions

function out = me
	out = lower(mfilename); 
	
function out = callback
	out = [lower(mfilename) ';'];

    
function update_group

    [trials,names] = Group('all');
    val = GetParam('group','group');
    SetParam(me,'trials',trials{val});
    SetParam(me,'name',names{val});
 
    % these functions allow group to update lists in any figure that makes
    % use of a popupmenu tagged 'group' or edit ui tagged 'trials'
    % for each of these ui's to be found, they should have the 'user' field set to 'group'
    
    set(findobj('style','edit','tag','trials','user','group'),'string',trials{val});
    set(findobj('style','popupmenu','user','group'),'string',names,'value',val);
    
    % opt may have more to do 
    Opt('update_group');
    
function update_collect
global exper

    modules = fieldnames(exper);    
    SetParam(me,'module','list',modules);
    
    module = GetParamList(me,'module');
    fields = eval(sprintf('fieldnames(exper.%s.param)',module));
    params = {' '};
    k=1;
    for n=1:length(fields)
        save = eval(sprintf('exper.%s.param.%s.save',module,fields{n}));
        if save
            params{k} = fields{n};
            k=k+1;
        end
    end
    
    SetParam(me,'param','list',params,'value',1);
    
    
function collect
global exper

    % any parameter specified by the user
    
    module = GetParamList(me,'module');
    param = GetParamList(me,'param');
    
    trials = 1:length(GetParam(module,param,'trial'));
    
    current_trial = GetParam('control','trial');
	if ExistParam('control','run') & GetParam('control','run')
        ai('pause');
        if ExistParam('ao')
    		ao('pause');
        end
        restart = 1;
    else
        restart = 0;
    end
    
    
    numeric = 0;
    for n=1:length(trials)
        SetParam('control','trial',trials(n));
        
        % should retrieve the saved parameters
        CallModule(module,'trialreview');
        
        xr = GetParamTrial(module,param,trials(n));
        
        if isnumeric(xr)
            x{n} = num2str(xr);
            numeric = 1;
        elseif isstr(xr)
            x{n} = xr;
        end
    end
    
    % order the trials
    xs = {' '};
    k = 1;
    trs = {' '};
    for n=1:length(trials)
        match = strcmp(x{n},xs);

        if ~match
            xs{k} = x{n};
            trs{k} = num2str(trials(n));
            k = k+1;
        else
            trs{match} = [trs{match} ' ' num2str(trials(n))];
        end
    end
    
    % sort 
    [xs,i] = sort(xs);
    trs = trs(i);
    
    SetParam(me,'value','list',xs,'trials',trs,'value',1);
    SetParam('control','trial',current_trial);
    if restart
        Control('run');
    end
    
    
    
function good = select_trials(trials,valid,invalid)
global exper

    
    if nargin < 3
        invalid = str2num(GetParam(me,'invalid'));
    end
    if nargin < 2
        valid = str2num(GetParam(me,'valid'));
    end
    if nargin < 1
        trials = 1:length(GetParam('control','trialdur','trial'));
    else
        if isstr(trials)
            trials = str2num(trials);
        end
    end
        
    used = [];
    if isempty(valid)
        valid = 1:length(exper.opt.trial);
    end
    
    good = '';
    k=1;
    for n=1:length(trials)
        if ~isempty(find([-1 valid] == trials(n))) & isempty(find([-1 invalid] == trials(n)))
            good(k) = trials(n);
            k=k+1;
        end
    end
    if ~isempty(good)
        good = sprintf('%d ',good);
    end

    
function good = remove_invalid(trials_str)

    good = '';
    k=1;
    trials = str2num(trials_str);
    invalid = str2num(GetParam('group','invalid'));
    for n=1:length(trials)
        if isempty(find([-1 invalid] == trials(n)))
            good(k) = trials(n);
            k=k+1;
        end
    end
    if ~isempty(good)
        good = sprintf('%d ',good);
    end
 
    
