function vs = MakeParamUIs(module,pos)
% VS = MAKEPARAMUIS(MODULE,[POS])
% Make UIs for displaying/editing parameters
% VS is the vertical size made
global exper

	fig = findobj('tag',module,'type','figure');

	if nargin < 2 
		pos=get(gcf,'pos'); 
		voff = pos(4);
	else
		voff = pos(2);	
	end
	
	bvs = 20;
	hs1 = 60;
	hs2 = 100;
	hoff = pos(1);
	bc = get(gcf,'color');

	md = getfield(exper,module);
   if ~isempty(md.param)
      cnames = fieldnames(md.param);
		n=1;
		np = length(cnames);
      for p=1:np
			param = cnames(p);
   		name = GetParam(module,param{1},'name');
	  		type = GetParam(module,param{1},'type');
			value = GetParam(module,param{1},'value');
			if strcmp(type,'clock')
				value = Sec2TimeStr(value);
			end		
	   	switch type
			case {'param','string'}
	         uicontrol('parent',fig,'tag',name,'pos',[hoff voff-bvs*n hs1 bvs],...
					'style','edit','horiz','right','backgroundcolor',[1 1 1],...
					'string',value,'callback','FigHandler;');
	  			uicontrol('parent',fig,'string',[name ' '],'pos',[hoff+hs1 voff-bvs*n hs2 bvs],...
					'style','text','horiz','left','backgroundcolor',bc);
				n = n+1;
			case {'list'}
				list = GetParam(module,param{1},'list');
				uicontrol('parent',fig,'tag',name,'pos',[hoff voff-bvs*n hs1 bvs],...
					'style','popupmenu','horiz','right','backgroundcolor',[1 1 1],...
					'string',list,'value',value,'callback','FigHandler;');
	  			uicontrol('parent',fig,'string',[name ' '],'pos',[hoff+hs1 voff-bvs*n hs2 bvs],...
					'style','text','horiz','left','backgroundcolor',bc);
				n = n+1;
			case {'calc','clock'}
				h = uicontrol('parent',fig,'tag',name,'pos',[hoff voff-bvs*n hs1 bvs],...
					'style','edit','horiz','right','backgroundcolor',bc,...
					'string',value,'enable','inactive','foregroundcolor',[0 0 0]);
	  			uicontrol('parent',fig,'string',[name ' '],'pos',[hoff+hs1 voff-bvs*n hs2 bvs],...
					'style','text','horiz','left','backgroundcolor',bc);	
				n = n+1;
			case 'slist'
				
			otherwise
			end
		end
   end
	
	vs = bvs*np;
	