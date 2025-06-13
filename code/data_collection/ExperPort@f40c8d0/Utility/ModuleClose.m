function ModuleClose(name)
% MODULECLOSE(NAME)
global exper

	% If I have a figure, hide it
	%set(findobj('tag',name,'type','figure'),'visible','off');
	% Close me!
	set(findobj('tag','modload','user',name),'checked','off');
	set(findobj('tag','modreload','user',name),'checked','off');
	
	if ~isstruct(exper) return; end

	% Job is done if the module is not present in exper
	if ~isfield(exper,name) 
        closereq;
        return; 
    end
	
	% Set my priority to 0 so I am not called and tell modules about it
	SetParam(name,'open',0);
	if ExistParam('control','sequence')
        CallModule('control','sequence');
    end
	
	h=findobj('tag',name,'type','figure');
	if ishandle(h)
		CallModule(name,'close');	% used to be called in Control
		figure(h);
		delete(h);
	end
	
	% Close anyone who depends on me
	depend = GetParam(name,'dependents','list');
	for n=1:length(depend)
		modu = depend{n};
		if ExistParam(modu,'open')
			if GetParam(modu,'open')
				ModuleClose(modu);
			end
		end
	end
	
	
	
