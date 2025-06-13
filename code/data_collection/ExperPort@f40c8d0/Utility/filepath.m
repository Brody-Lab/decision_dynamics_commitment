function [p] = filepath(rat, type)
  
% Returns the path to a given rat's data or settings directory.
% The path is returned as a string.
% Input args:
% rat: the rat name (string)
% type: A character, either 'd' or 's'.
% If the type is 'd', the path to the data directory is returned.
% If 's', the path to the settings directory is returned.
%
% Output: A string with the pathname
% 
% Note: The script will check if the path in question exists and if not,
% it will generate a warning message to indicate the absence.
%
% Sample usage:
% >> p = filepath('ghazni','s')  
%
% p =
% C:/home/Rat_behavior/ExperPort/../SoloData/settings/ghazni/
%
%
% >> p = filepath('jiminy','s')  
% Warning: Directory does not exist. You may need to create it.
% > In filepath at 25
%
% p =
%
% C:/home/Rat_behavior/ExperPort/../SoloData/settings/jiminy/
  
  
  if strcmpi(type, 'd'), type = 'data'; 
  elseif strcmpi(type, 's'), type = 'settings';
  else error('Type Error: Type can be ''d'' for data or ''s'' for settings');end;
  
  global Solo_datadir;
  if isempty(Solo_datadir), mystartup; end;
  
  p = [Solo_datadir filesep type filesep rat filesep];
  if ~exist(p, 'dir'),
    warning(['Directory does not exist. You may need to create ' ...
             'it.']);
   end;
