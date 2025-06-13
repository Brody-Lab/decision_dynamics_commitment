function [sph] = get_any_handle(func, meth, param)

% GET_ANY_HANDLE
%     Used for debugging purposes
%     Accesses private_solofunction_list to return the handle to any parameter
%     in any method in any function currently running.
%
%     Input params:
%     func: function in which variable is used
%     meth: Specific method that owns the variable
%     param: The parameter itself whose value is to be retrieved
%
%     Sample usage:
%         sph = get_any_handle('@dual_discobj', 'ChordSection', 'Tone_Loc');

global private_solofunction_list;

psf = private_solofunction_list;

if ~strcmp('@',func(1)),func = ['@' func]; end;

func_ind = find(strcmp(psf(:,1),func));
if isempty(func_ind), error(['Could not find function ' func]); end;

psf2 = psf{func_ind, 2};
meth_ind = find(strcmp(psf2(:,1),meth));
if isempty(meth_ind), error(['Could not find method ' method]); end;

psf3 = psf2{meth_ind, 2};
param_ind = find(strcmp(psf3(:,1), param));
if isempty(param_ind), error(['Could not find param ' param]); end;

sph = psf3{param_ind, 2};


