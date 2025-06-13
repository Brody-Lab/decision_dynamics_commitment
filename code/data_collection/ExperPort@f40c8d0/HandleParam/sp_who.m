% [] = sp_who([handlelist | {'name', '.*',}, {'fullname', '.*'}, {'owner', '.*'}])
%
% Find and report on ownership. r/w access and r/o access of
% SoloParamHandles. Prints out report to command line.
%
% PARAMETERS:
% -----------
%
% handlelist    If passed a cell as a single argument, sp_who assumes that
%               each element of the cell is a SoloParamHandle, and it runs
%               @SoloParamHandle/sp_who.m on each of those cells. Any
%               non-SoloParamHandles in the cell will be ignored.
%
% other         If not passed a cell, or if passed no arguments at all,
%               sp_who first runs get_sphandle.m on the passed arguments to
%               make a cell of SoloParamHandles, and then runs
%               @SoloParamHandle/sp_who.m on each of them. See
%               get_sphandle.m for details an admissible arguments.
%
% EXAMPLES:
% ---------
%
%    >> sp_who('name', 'assem')   
%
% is equivalent to sp_who(get_sp_handle('name', 'assem')), and will report
% on any existing SoloParamHandles that have a name that contains the string 'assem'.
% Similarly,
%
%    >> sp_who('owner', 'gug', 'name', 'bleep') 
%
% is equivalent to sp_who(get_sphandle('owner', 'gug', 'name', 'bleep')),
% and will report on any existing SoloParamHandles whose owner's name
% contains the string gug and whose name contains the string bleep.
%
%    >> sp_who
%
% will report on every existing SoloParamHandle. 
%
% Finally, to get all the SoloParamHandles that a particular method has,
% try
%
%   >> sp_who('fullname', '^MyMethodName_')
%

% written by Carlos Brody June 2007

function [] = sp_who(varargin)

if nargin==1 && iscell(varargin{1}), 
  handlelist = varargin{1};
  handlelist = handlelist(:);
  for i=1:length(handlelist),
    if isa(handlelist{i}, 'SoloParamHandle'), sp_who(handlelist{i}); end;
  end;
  return;
end;

if isempty(varargin), sp_who(get_sphandle); return; end;

str = 'varargin{1}'; 
for i=2:length(varargin),
  str = sprintf('%s, %s', str, ['varargin{' num2str(i) '}']);
end;
handlelist = eval(['get_sphandle(' str ')']);
sp_who(handlelist);


