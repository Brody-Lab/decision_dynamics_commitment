function [p] = Shraddha_filepath(ratname, type,varargin)
  
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

pairs = { ...
    'experimenter', 'Shraddha' ; ...  
    };
parse_knownargs(varargin,pairs);
  
p = {};
  
  if strcmpi(type, 'd'), type = 'data'; 
  elseif strcmpi(type, 's'), type = 'settings';
  else error('Type Error: Type can be ''d'' for data or ''s'' for settings');end;
  
  global Solo_datadir;
  if isempty(Solo_datadir), mystartup; end;
  
  p{1} = [Solo_datadir filesep type filesep  experimenter filesep ratname filesep];
  if ~exist(p{1}, 'dir'),
    warning(['Directory does not exist. You may need to create ' ...
             'it.']);
   end;

   % Old CSHL dir
   tmp = [ filesep 'Users' filesep 'oldpai' filesep 'Documents' filesep 'Brody_lab' filesep 'Rat_training' filesep 'SoloData'];
   tmp = [tmp filesep 'Data' filesep ratname filesep];
   p{end+1}=tmp;
   
   % Old CSHL dir on red Mac
   tmp = [ filesep 'Users' filesep 'pai' filesep 'Documents' filesep 'brodylab' filesep 'Solo_Code' filesep ...
       'SoloData_deprong' filesep 'SoloData'];
   tmp = [tmp filesep 'Data' filesep ratname filesep];
   p{end+1}=tmp;
   