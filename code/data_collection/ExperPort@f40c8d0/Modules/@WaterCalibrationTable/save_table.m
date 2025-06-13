% [] = save_table(wt, fname)
%
% saves a WaterCalibrationTable object. If no filename is passed, then
% saves in ../CNMC/Calibration/hostname_watertable.mat, where hostname
% is the current machine's host name.
%



function [] = save_table(wt, fname, varargin)

   if length(varargin)>0,
      if rem(length(varargin),2)==1, % If odd nguys in varargin
         varargin = [{fname} varargin];
         fname = '';
      end;
   end;
   pairs = { ...
     'commit'   0   ; ...
   }; parseargs(varargin, pairs);
   
   if nargin==1 || isempty(fname),
      hostname = get_hostname;
      
      if ~exist(fullfile('..', 'CNMC'), 'dir'),
         mkdir(fullfile('..', 'CNMC'));
      end;
      if ~exist(fullfile('..', 'CNMC', 'Calibration'), 'file'),
         mkdir(fullfile('..', 'CNMC', 'Calibration'), 'file');
      end;
      fname = fullfile('..', 'CNMC', 'Calibration', ...
                       [hostname '_watertable.mat']);
   end;
   
   wt = struct(wt);
   
   save(fname, 'wt');
   
   if commit, add_and_commit(fname); end;
   
   