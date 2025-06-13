function AddParam(module,name,value,tr)
% ADDPARAM(MODULE,NAME,VALUE,[TRIAL])
% Add VALUE to the value of the parameter
global exper

%if nargin < 4 tr = GetTrial; end

%SetParam(module,name,GetParam(module,name)+value,tr);

SetParam(module,name,GetParam(module,name)+value);


