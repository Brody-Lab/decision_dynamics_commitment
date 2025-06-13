function out = SaveParamTrial(module,param,trial)
global exper
% SAVEPARAMTRIAL
% Keep track of parameter values by saving a copy in a vector
% (field name 'trial'). Can be retrieved using GETPARAMTRIAL.
% SAVEPARAMTRIAL(MODULE,PARAM,TRIAL)
%
% ZF MAINEN, CSHL, 10/00
%

module = lower(module);
if nargin < 3 
    trial = GetParam('control','trial');
end

sfs = sprintf('exper.%s.param.%s',module,param);
%s = evalin('caller',sf);

trial_vals = getp(sfs,'trial');
val = getp(sfs,'value');
% if it's a list, we save the item, not the index
list = GetP(sfs,'list');
if ~isempty(list)
    val = list{val};
end
trial_vals{trial} = val;
setp(sfs,'trial',trial_vals);
