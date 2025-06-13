function out = SaveParams(module,trial)
global exper
% SAVEPARAMS
% Keep track of parameter values by saving a copy in a vector
% (field name 'trial'). Can be retrieved using GETPARAMTRIAL.
% SAVEPARAMS(MODULE,TRIAL)
%
% ZF MAINEN, CSHL, 10/00
%


module = lower(module);

sf = sprintf('exper.%s.param',module);
s = evalin('caller',sf);
fields = fieldnames(s);
		
% go through all the parameters
for i=1:length(fields)
	sfs = sprintf('%s.%s',sf,fields{i});
	% save only the ones that need to be saved
	save = getp(sfs,'save');
	if save
		trial_vals = getp(sfs,'trial');
		val = getp(sfs,'value');
		% if it's a list, we save the item, not the index
		list = GetP(sfs,'list');
		if ~isempty(list)
			 val = list{val};
		end
		trial_vals{trial} = val;
		setp(sfs,'trial',trial_vals);
	end
end
