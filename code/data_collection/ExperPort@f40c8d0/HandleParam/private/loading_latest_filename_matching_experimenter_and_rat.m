% [fullname, no_file_flag] = loading_latest_filename_matching_experimenter_and_rat(filepath, ...
%                         owner, experimenter, ratname, sets_or_data)
%
%
% filepath should be a string, ending in filesep
%
% owner should be a string, starting with '@', that defines the object that
%    owns all the soloparamhandles being loaded.
%
% experimenter_ should either be a string, ending in '_', or an empty string
%
% ratname should be a string
%
% sets_or_data  must be one of the two following strings: 'settings' or 'data'
%
%
%
% RETURNS:
% --------
%
% fullname   the full path and filename of a settings file
%
% no_file_flag   1 if the file indicated in fullname was not found: it
%            does not exist yet. 0 if it was found and we can therefore try
%            to load it.
%


function [fullname, no_file_flag] = loading_latest_filename_matching_experimenter_and_rat(filepath, ...
  owner, experimenter, ratname, sets_or_data)

   if ~ismember(sets_or_data, {'settings' 'data'}),
     error('sets_or_data *must* be one of ''settings'' or ''data''');
   end;

   rat_dir = [filepath ratname];
   if ~exist(rat_dir, 'dir') % <~> specified 2nd arg to speed command up
     success = mkdir(filepath, ratname);
     if ~success, error(['Couldn''t make directory ' rat_dir]); end;
   end;
   if rat_dir(end)~=filesep, rat_dir=[rat_dir filesep]; end;

   if ~isempty(experimenter) && experimenter(end)~='_', experimenter_ = [experimenter '_']; 
   else                                                 experimenter_ = '';
   end;

   %     We search for the file (within the proper directory for
   %       this rat) that has the latest date number that does not
   %       correspond to a future date.
   u = dir([rat_dir sets_or_data '_' owner '_' experimenter_ ratname '*.mat']);
   fullname = [rat_dir sets_or_data '_' owner '_' experimenter_ ... % <~> added experimenter_
     ratname '_' yearmonthday 'a'];
   no_file_flag=1;
   if ~isempty(u),
     [filenames{1:length(u)}] = deal(u.name); filenames = sort(filenames'); %#ok<UDIM> (can't use dimension argument with cell sort)
     for i=length(u):-1:1, %     search from the end back
       file_date_num = textscan(filenames{i},[sets_or_data '_' owner '_' experimenter_ ratname '_%n%*c.mat']);
       if         ~isempty(file_date_num{1}) ...
           &&  file_date_num{1} <= str2double(yearmonthday),
         fullname = [rat_dir filenames{i}]; %     We've found it.
         no_file_flag=0;
         break;
       end;
     end;
   end;
   return;
        
 