% [dir_path] = loading_define_sets_or_data_directory(Solo_datadir, experimenter, sets_or_data)
%
% Solo_datadir should be either empty, in which case the Settings.m system
%     is used to find the main data directory (under GENERAL :
%     Main_Data_Directory), or it should be a string containing the path to
%     the main data directory.
%
% experimenter should be a string 
%
% sets_or_data  must be one of the two following strings: 'settings' or 'data'
%
%
% RETURNS: a string with the path to the experimenter's settings directory,
% ending  in a filesep.
%

function [dir_path] = loading_define_sets_or_data_directory(Solo_datadir, experimenter, sets_or_data)

   if ~ismember(sets_or_data, {'settings' 'data'}),
     error('sets_or_data *must* be one of ''settings'' or ''data''');
   end;

   sets_or_data = [upper(sets_or_data(1)) sets_or_data(2:end)];
   
   if isempty(Solo_datadir),
     [Solo_datadir, errID]=bSettings('get','GENERAL','Main_Data_Directory');
     if errID || isnan(Solo_datadir) || isempty(Solo_datadir)
       Solo_datadir=[pwd filesep '..' filesep 'SoloData'];
     end
   end;

   dir_path = [Solo_datadir filesep sets_or_data];
   if ~exist(dir_path, 'dir'),
     success = mkdir(Solo_datadir, sets_or_data);
     if ~success, error(['Couldn''t make directory ' dir_path]); end;
   end;
   if dir_path(end)~=filesep, dir_path=[dir_path filesep]; end;

   if ~isempty(experimenter)
     dir_path = [dir_path experimenter filesep];
   end;
   return;
