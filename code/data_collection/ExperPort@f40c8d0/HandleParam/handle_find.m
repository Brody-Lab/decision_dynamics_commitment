% [sp] = handle_find(owner, funcname, varname)
%
% Return a SoloParamHandle, given an owner, the function name in which the
% SoloParamHandle was declared, and the name of the SoloParamHandle.
%
% This function is similar to get_sphandle.m, but because of its much more
% resticted search structure, it is also far far faster than get_sphandle.
%
% PARAMETERS:
% -----------
% 
% owner     Either an object, or a string indicating the class of an object
%
% funcname  A string indicating the name of the m-file in which the
%           SoloParamHamdle was declared.
%
% varname   The name of the SoloParamHandle
%
%
% RETURNS:
% --------
%
% The requested SoloParamHandle. If the SoloParamHandle is not found,
% either because the owner is not found, the funcname is not found, or the
% varname is not found, returns an empty cell. 
%
%
% EXAMPLES:
% ---------
%
%  >> handle_find(ExtendedStimulus, 'SidesSection', 'ThisPair')
%

% written by CDB Mar 2008


function [c] = handle_find(owner, funcname, varname)

if nargin<3, error('Need 3 args: owner, funcname, and varname'); end;

global private_solofunction_list  % The list in which all variables are registered to their owners and functions
c = {};

if isobject(owner), 
  owner = ['@' class(owner)]; 
end;
if ~ischar(owner) || isempty(owner),
  error('InvalidParam:owner', 'owner must be either a string or an object');
end;
if owner(1) ~= '@', owner = ['@' owner]; end;

ownergroup = find(strcmp(owner, private_solofunction_list(:,1)), 1);

if isempty(ownergroup), return; end;

if ~isempty(funcname), % It is not a global for this owner
  tmp = private_solofunction_list{ownergroup,2}; % list of func names and their vars
  funcgroup = find(strcmp(funcname, tmp(:,1)),1);
  if isempty(funcgroup), return; end;
  varscell  = tmp{funcgroup,2};
  varrow    = find(strcmp(varname, varscell(:,1)),1);
  if isempty(varrow), return; end;
  sp        = varscell{varrow, 2};
end;

c = sp;





 



