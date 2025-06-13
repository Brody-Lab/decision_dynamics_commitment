function EditParam(obj, module,param)
% EDITPARAM
% A ui tool to allow the user to view and edit all the fields of
% a parameter. 
% EDITPARAM(MODULE,PARAM)
%
% ZF MAINEN, CSHL, 10/00
%
global exper

% have we been called by the edit callback
if ~isempty(gcbo)
	whocalled = get(gcbo,'tag');
	switch whocalled
	case 'edit'	
		% we were called by the edit param figure
		pmf = get(gcbo,'user');
		module = pmf{1};
		param = pmf{2};
		field = pmf{3};
		switch field
		case 'range'
			val = str2num(get(gcbo,'string'));
		otherwise
			if isa(GetParam(module,param,field),'numeric');
				val = str2num(get(gcbo,'string'));
			else
				val = get(gcbo,'string');
			end
		end
		setparam(module,param,field,val);
		return
		
	case 'setprefs'
		pmf = get(gcbo,'user');
		module = pmf{1};
		param = pmf{2};
		user = GetParam('control','user');
		
		sf = sprintf('exper.%s.param.%s',module,param);
		% get the actual structure
		s = evalin('caller',sf);
		
		prefstr = sprintf('%s_%s',module,param);
        setpref(user,prefstr,s);
		return
			
	case 'clearprefs'
		pmf = get(gcbo,'user');
		module = pmf{1};
		param = pmf{2};
		user = GetParam('control','user');
		pref = sprintf('%s_%s',module,param);
		if ispref(user,pref);
			rmpref(user,pref);
		end
		return	
        
    case 'editlist'
      	pmf = get(gcbo,'user');
		module = pmf{1};
		param = pmf{2};
		field = pmf{3};
        list = GetParam(module,param,field);
        
        namestr = sprintf('%s.%s.%s',module,param,field);
	    f = figure('name',namestr,'menu','none','number','off','pos',[500 400 75 235]);
        
    	h = uicontrol(f,'style','edit','max',50,'string',list,'background',[1 1 1],...
    		'pos',[5 30 95 200],'horiz','left','tag','edit_editlist');
    	h = uicontrol(f,'style','pushbutton','string','Accept','pos',[5 5 50 20],...
            'user',pmf,'tag','accept_editlist','callback','editparam');
    	h = uicontrol(f,'style','pushbutton','string','Cancel','pos',[55 5 50 20],...
            'callback','closereq');
		
        
    case 'accept_editlist'
        p =1;
     	pmf = get(gcbo,'user');
		module = pmf{1};
		param = pmf{2};
		field = pmf{3};
        
        list = get(findobj(gcf,'tag','edit_editlist'),'string');
       
        % take out empty lines from thelist
        if ~isempty(list)
            for n=1:length(list)
                a = list{n};
                if ~isempty(a) 
                    listc{p} = a;
                    p = p+1;
                end
            end
            SetParam(module,param,field,listc,'value',1);
            closereq;
        end
        
	otherwise
	% we were called by a module figure
		param = get(gcbo,'tag');
		module = get(gcbf,'tag');

	end
end

param = lower(param);
module = lower(module);

sf = sprintf('exper.%s.param.%s',module,param);
% get the actual structure
s = evalin('caller',sf);
fields = fieldnames(s);

hs = 60;
vs = 20;
n = 1;
height = vs*(length(fields)+3);
name = sprintf('%s.%s',module,param);

h = findobj('tag','editparam','name',name);
if isempty(h)
	h = figure('tag','editparam','name',name,'number','off','menubar','none');
end
pnow = get(h,'pos');
set(h,'pos',[pnow(1:2) hs*2+20 height]);
bc = get(h,'color');

n=n+1;
for i=1:length(fields)
    % show the field name
    uicontrol(h,'style','text','string',fields{i},...
            'horiz','right','backgroundcolor',bc,'pos',[5 height-n*vs hs vs]);
        
    % check if this field is a cell array, which indicates a list
    list = getp(sf,fields{i});
    if iscell(list)
    % this is for lists, which get an edit box        
        h1 =  uicontrol(h,'style','pushbutton','string','edit',...
            'pos',[10+hs height-n*vs hs vs],'user',{module,param,fields{i}},...
            'tag','editlist','callback','editparam');  n = n+1;
    else
    % this is for all other types of fields
        h1 =  uicontrol(h,'style','edit','string',getp(sf,fields{i}),...
            'horiz','left','pos',[10+hs height-n*vs hs vs],'backgroundcolor',[1 1 1],...
            'user',{module,param,fields{i}},...
            'max',2,'tag','edit','callback','editparam');  n = n+1;
        switch fields{i}
        case {'name','type','ui','h'}
            set(h1,'backgroundcolor',bc,'enable','off');
        otherwise
        end
    end
end
n=n+1;
uicontrol(h,'style','pushbutton','string','Set Prefs','callback','editparam',...
	'tag','setprefs','user',{module,param},'pos',[5 height-n*vs hs vs]); 
uicontrol(h,'style','pushbutton','string','Clear Prefs','callback','editparam',...
	'tag','clearprefs','user',{module,param},'pos',[10+hs height-n*vs hs vs]); 

	

