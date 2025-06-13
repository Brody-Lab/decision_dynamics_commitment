function out = GetParamTrial(module,param,trial)
global exper
% GETPARAMTRIAL
% Retrieve *saved* PARAM values from an exper MODULE.
% 
% OUT = GETPARAM(MODULE,PARAM,TRIAL)
% 		Return the 'value' of a parameter saved for a particular trial
%     with SAVEPARAMS.
%
% MODULE and PARAM are strings.
% FIELD can be a cell array of field names, FIELD = {'f1','f2'},
% in which case the output is a corresponding cell array VAL = {'v1','v2'}
%
% ZF MAINEN, CSHL, 2/01
%

module = lower(module);
param = lower(param);

sf = sprintf('exper.%s.param.%s',module,param);

out = '';
trials = GetP(sf,'trial');
if length(trials) >= trial 
	out = trials{trial};
end

