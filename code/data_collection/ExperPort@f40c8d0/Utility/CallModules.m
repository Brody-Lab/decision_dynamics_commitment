function CallModules(seq,action)
global exper

	for n=1:length(seq)
        eval(sprintf('%s(''%s'');',seq{n},action));
%		CallModule(seq{n},action);
	end