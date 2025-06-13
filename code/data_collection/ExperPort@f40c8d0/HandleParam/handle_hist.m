% [c] = handle_hist(owner, funcname, varname, [trialnum])
%
% Return the value of a SoloParamHandle in a particular trial number. If
% trialnum is not passed, then returns a cell vector with the whole history
% of the SoloParamHandle. If the SoloParamHandle is not found, returns an
% empty cell; if the trial number requested is not found, returns an empty
% vector.
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
% trialnum  An optional integer scalar. If passed, the value of the
%           SoloParamHandle for the indicated trial number will be
%           returned; if not passed, a cell vector with the entire history
%           will be returned.
%
% RETURNS:
% --------
%
% If trialnum is not passed, returns a cell vector with the entire history
% of the SoloParamHandle; if trialnum is passed, returns the value on the
% indicated trialnum.
%
% If the SoloParamHandle is not found, either because the owner is not
% found, the funcname is not found, or the varname is not found, returns an
% empty cell. If the history is empty, returns an empty cell. If the
% trialnum is not found, returns an emoty matrix.
%
%
% EXAMPLES:
% ---------
%
%  >> handle_hist(ExtendedStimulus, 'SidesSection', 'ThisPair', 3)
%

% written by CDB Mar 2008


function [c] = handle_hist(owner, funcname, varname, trialnum, varargin)

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
  varrow    = find(strcmp(varname, varscell(:,1)),1,'last');
  if isempty(varrow), return; end;
  sp        = varscell{varrow, 2};
end;

c = get_history(sp);
if nargin>3,
  if ~isempty(c) && 1<=trialnum && trialnum<=length(c), c = c{trialnum}; 
  else c = [];
  end;
end;




 



