% [wt] = WaterCalibrationTable(fname)
%
% Creates and returns a WaterCalibrationTable object. If it is not
% passed a filename, then by default looks in
%
%      ../CNMC/Calibration/hostname_watertable.mat 
%
% where hostname is the current machine hostname, as obtained from
% get_hostname.m 
%
% If passed a filename, assumes that file holds a valid Water
% Calibration Table.
%


function [wt] = WaterCalibrationTable(fname)

   % If passwd a wt, just return a copy of it:
   if nargin==1 & isa(fname, 'WaterCalibrationTable'),
      wt = fname; 
      return;
   end;

   if nargin>=2,
      error('Max 1 argument to create a WaterCalibrationTable object');
   end;
   
   % Make an empty structure with the appropriate fields:
   s = struct('initials', '', 'date', [], 'valve', '', 'time', [], ...
              'dispense', []);
   s = s([],:);
   
   %New behaviour: added a field 'isvalid'.
   % - Sundeep Tuteja, 23rd October, 2009
   s2 = struct('initials', '', 'date', [], 'valve', '', 'time', [], ...
              'dispense', [], 'isvalid', []);
   s2 = s2([], :);

   
   if nargin==0, % totally new table-- try to load from file, if file exists
      % Get the hostname, everything before the first '.' :
      hostname = get_hostname;

      % Look for, or make, sister dir ../CNMC/Calibration/
      if ~exist(fullfile('..', 'CNMC'), 'dir'),
         mkdir(fullfile('..', 'CNMC'));
      end;
      if ~exist(fullfile('..', 'CNMC', 'Calibration'), 'dir'),
         mkdir(fullfile('..', 'CNMC', 'Calibration'));
      end;
      fname = fullfile('..', 'CNMC', 'Calibration', ...
                       [hostname '_watertable.mat']);
      
      % If file exists, load from that
      if exist(fname, 'file'), 
         wt = WaterCalibrationTable(fname);
      else % return empty table
         wt = class(s, 'WaterCalibrationTable');
      end;
      return;
   end;
      
   % --- there was just one arg
   
   if isstr(fname) % We were given a filename, let's try to load from that:
      if ~exist(fname, 'file'),
         error(sprintf('File %s does not exist.\n', fname));
      end;
      
      G = load(fname); G = G.wt;
      % If we have all the right fieldnames, assume all is good:
      if isempty(setdiff(fieldnames(G), fieldnames(s))) || ...
              isempty(setdiff(fieldnames(G), fieldnames(s2))), %Sundeep Tuteja, 10/23/2009: This should work for both formats
         wt = class(G, 'WaterCalibrationTable');
         return;
      else
         error(sprintf(['Contents of %s are not configured as a ' ...
                        'WaterCalibrationTable object\n'], fname));
      end;
   elseif isstruct(fname), % we were given a structure, let's try to
                           % turn it into an object:
      % Do we have the right fieldnames?
      if isempty(setdiff(fieldnames(fname), fieldnames(s))) || ...
              isempty(setdiff(fieldnames(fname), fieldnames(s2))),
         wt = class(fname, 'WaterCalibrationTable');
      else
         error(sprintf(['Struct given to constructor not configured as a ' ...
                        'WaterCalibrationTable object\n']));
      end;
   else
      error('Argument can only be a string (a filename) or a struct');
   end;
   
   
   
   
  return;


