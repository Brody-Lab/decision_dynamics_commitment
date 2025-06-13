function ClearParamTrials(module)
global exper
% CLEARPARAMTRIALS
% Reset/clear saved parameters saved with SAVEPARAMTRIAL(MODULE,TRIAL).
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
        setp(sfs,'trial','');
    end
end
