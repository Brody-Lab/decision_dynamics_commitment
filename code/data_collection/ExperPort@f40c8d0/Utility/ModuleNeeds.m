function ModuleNeeds(module,needs)
global exper
% MODULENEEDS(module,needs)
% open all the modules that this one needs in order to run

	SetParam(module,'needs','list',needs);

	for n=1:length(needs)
		c = needs{n};
		% Open anyone who I depend on
		if ~ExistParam(c,'open')
				ModuleInit(c); 
		else
			if ~GetParam(c,'open')
				ModuleInit(c); 
			end
		end
		
		% Update the dependents list of the modules I need
		dep = GetParam(c,'dependents','list');
		present = 0;
		for k=1:length(dep)
			if strcmp(dep{k},module)
				present = 1;
			end
		end
		if ~present
			dep{end+1} = module;
			SetParam(c,'dependents','list',dep,'value',1);
		end
	end

	
	

	
	