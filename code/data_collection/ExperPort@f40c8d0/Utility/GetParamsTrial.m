function out = GetParamsTrial(module,trial)
global exper
% GETPARAMSTRIAL
% Retrieve *saved* values from all PARAMS of an exper MODULE.
% 
% GETPARAMSTRIAL(MODULE,TRIAL)
%
% ZF MAINEN, CSHL, 8/01
%

module = lower(module);

if nargin<2
    trial= GetParam('control','trial');
end

sf = sprintf('exper.%s.param',module);
s = evalin('caller',sf);
fields = fieldnames(s);
		
% go through all the parameters
for i=1:length(fields)
	sfs = sprintf('%s.%s',sf,fields{i});
	% retrieve only the ones that were saved
	if getp(sfs,'save')
		trial_vals = getp(sfs,'trial');
		setp(sfs,'value',trial_vals{trial});
	end
end
