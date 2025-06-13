% [] = change_settings(ratname, experimenter, varname, newvalue)
%
% Changes the settings file with the latest date for a particular rats.
% Settings are read from local settings*.mat files, not from SQL. Don't
% forget to commit your updated settings files!
%
% PARAMETERS:
% -----------
%
% ratname       A string representing the name of the rat, e.g., 'B059'
%
% experimenter  A string representing the name of the experimenter, e.g.,
%              'Bing'
%
% varname       The name of the SoloParamHandle whose settings are being
%               changed. A regular expression match between varname and
%               the fullname of the SoloParamHandle will be done; if this
%               is successful, that SPH is considered a target. Thus, to
%               look for an SPH that ends with "ments", you would use
%               varname "\w*ments$". \w* means any number of word
%               characters; $ means end of string (see regexp.m)
%         
%               If more than one target is found, prints a warning and does
%               nothing; if no target is found, prints a warning and does
%               nothing. Only if exactly one target is found does it go
%               ahead.
%
% protocol      Specify the protocol to look at, e.g., 'Classical'. By
%               default this parameter is empty and the fucntion looks at
%               all protocols.
%
%
% EXAMPLE: 
% --------
%
%  >> change_settings('C147', 'Carlos', 'nTargets', 1)
%

function [] = change_settings(ratname, experimenter, varname, newvalue, varargin)

   pairs = { ...
	 'protocol'    '' ; ...
   }; parseargs(varargin, pairs);

   datadir = bSettings('get', 'GENERAL', 'Main_Data_Directory');
   if isnan(datadir)
      error('Not sure what''s going on: Unable to determine the Settings directory.');
   end;
   if isempty(protocol),
	   u = dir([datadir filesep 'Settings' filesep experimenter filesep ratname filesep 'settings*.mat']);
   else
	   u = dir([datadir filesep 'Settings' filesep experimenter filesep ratname filesep 'settings_@' protocol '_*.mat']);
   end;

   
   [X{1:length(u)}] = deal(u.name);
  % First find the latest date
   for xind=1:numel(X)
       Xd{xind}=X{xind}(end-10:end-4);  % This avoids getting the wrong setting because of rat that has run on multiple protocols. or has multiple files for one day.
   end
   [Xd, iXd] = sort(Xd);
   X = X{iXd(end)};
   filename = [datadir filesep 'Settings' filesep experimenter filesep ratname filesep X];
   load(filename);
   
   fnames = fieldnames(saved); %#ok<NODEF>
   keeps = zeros(size(fnames));
   for i=1:length(fnames),
     if ~isempty(regexp(fnames{i}, varname, 'ONCE')), keeps(i) = 1; end;
   end;
   keeps = find(keeps);
   if isempty(keeps),
     warning('CHANGE_SETTINGS:BadMatch', 'Didn''t find %s\n', varname);
     return;
   elseif length(keeps)>1,
     warning('CHANGE_SETTINGS:BadMatch', 'Found more than one var matching %s, not doing anything\n', varname);
     return;
   end;
   
   if isnumeric(newvalue),
     fprintf(1, '%s: Old value of %s was %g, new value is %g\n', X, varname, saved.(fnames{keeps}), newvalue);
   elseif ischar(newvalue),
     fprintf(1, '%s: Old value of %s was %s, new value is %s\n', X, varname, saved.(fnames{keeps}), newvalue);
   else
	 fprintf(1, '%s: %s updated with new value ', X, varname);
   
   end;
   saved.(fnames{keeps}) = newvalue;
   
   save(filename, 'saved', 'saved_autoset');
   
   
   
   return;
   