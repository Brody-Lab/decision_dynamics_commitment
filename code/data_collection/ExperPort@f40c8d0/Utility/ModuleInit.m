function ModuleInit(name,init)
% MODULEINIT(NAME,INIT)
% INIT parameter is optional name of initialization case
% CDB: Adds in exper.name.param to the exper structure; and
%      then fills that with fields priority, dependents, and open.
%      Finally, calls name('init'); if exper.name.param.sequence exists, 
%      then also calls name('sequence'); and restores the modules window pos
% 

global exper
	
	p.param = 1;
	if ~isfield(exper,name)
		exper = setfield(exper,name,p);
	end
	InitParam(name,'priority','value',5,'pref',0);
	InitParam(name,'dependents','list',{},'pref',0);
	InitParam(name,'open','value',1,'pref',0);
		
	% call the module's initialization
    if nargin < 2
        CallModule(name,'init');
    else 
        CallModule(name,init);
    end
    
	% Set the checkbox in control
	set(findobj('tag','modload','user',name),'checked','on');

	% Put me in the control sequence
	if ExistParam('control','sequence')
        CallModule('control','sequence');
        RestorePos(GetParam('control','user'),name);
    end
    
    