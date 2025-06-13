% [settings] = check_settings(ratname, experimenter, varname, nback, {'nth', 1})
%
% Reports on settings for a particular rat; the report is printed out to
% the command line. Settings are read from local settings*.mat files,
% not from SQL.
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
%               checked for. A regular expression match between varname and
%               the fullname of the SoloParamHandle will be done; if this
%               is successful, that SPH is considered a target. Thus, to
%               look for an SPH that ends with "ments", you would use
%               varname "\w*ments$". \w* means any number of word
%               characters; $ means end of string (see regexp.m)
% 
% nback         By default looks at the settings file with the latest date.
%               nback can be a scalar or a vector of integers indicating
%               the number of files to look back to. E.g., -5:0 means look
%               at the files with the latest 6 dates.
%    
%
% OPTIONAL PARAMETERS:
% --------------------
%
% nth           By default, 1. Sometimes a varname will match more than one
%               SPH. nth will indicate which match to use-- the default is
%               to use the first match. 2 means use the second, etc.
%
% protocol      Specify the protocol to look at, e.g., 'Classical'. By
%               default this parameter is empty and the fucntion looks at
%               all protocols.
%
% EXAMPLE: 
% --------
%
%  >> check_settings('C147', 'Carlos', 'nTargets', -10:0)
%


% written by Carlos Brody 2009


function [stngs] = check_settings(ratname, experimenter, varname, nback, varargin)

   stngs = [];
   if nargin < 4, nback = 0; end;
   
   pairs = { ...
     'nth'         0  ; ...
	 'protocol'    '' ; ...
   }; parseargs(varargin, pairs);
   
   if length(nback)>1,
     for i=1:length(nback)
       if nargout>0,
         stngs = [stngs ; check_settings(ratname, experimenter, varname, nback(i), varargin{1:end})]; %#ok<AGROW>
       else
         check_settings(ratname, experimenter, varname, nback(i), varargin{1:end});
       end;
     end;
     return;
   end;
     
   datadir = bSettings('get', 'GENERAL', 'Main_Data_Directory');
   if isempty(protocol),
	   u = dir([datadir filesep 'Settings' filesep experimenter filesep ratname filesep 'settings*.mat']);
   else
	   u = dir([datadir filesep 'Settings' filesep experimenter filesep ratname filesep 'settings_@' protocol '_*.mat']);
   end;
   
   [X{1:length(u)}] = deal(u.name);
   X = sort(X);
   if     length(X)+nback > length(X), nback=0;
   elseif length(X)+nback < 1,         nback = -(length(X)-1);
   end;
   X = X{end+nback};
   filename = [datadir filesep 'Settings' filesep experimenter filesep ratname filesep X];
   load(filename);
   
   fnames = fieldnames(saved); %#ok<NODEF>
   keeps = zeros(size(fnames));
   for i=1:length(fnames),
     if ~isempty(regexp(fnames{i}, varname, 'ONCE')), keeps(i) = 1; end;
   end;
   keeps = find(keeps);
   if isempty(keeps),
     % warning('CHANGE_SETTINGS:BadMatch', 'Didn''t find %s\n', varname);
     fprintf(1, '%s: *** Didn''t find %s.\n', X, varname);
     return;
   elseif length(keeps)>1,
     if nth==0,
       warning('CHANGE_SETTINGS:BadMatch', 'Found more than one var matching %s, not doing anything\n', varname);
	   for kx=1:numel(keeps)
		   fprintf(1,'%s\n',fnames{keeps(kx)})
	   end
       return;
     else
       keeps = keeps(min(nth, length(keeps)));
     end;
   end;
   
   if ~ischar(saved.(fnames{keeps})),
     fprintf(1, '%s: Value of %s is %g\n', X, varname, saved.(fnames{keeps}));
     if nargout>0, stngs = [stngs ; saved.(fnames{keeps})]; end;
   else
     str = saved.(fnames{keeps}); 
     if size(str,1)==1,
       fprintf(1, '%s: Value of %s is %s\n', X, varname, str);
     else
       fprintf(1, '%s: Value of %s is:\n', X, varname);
       for k=1:size(str,1),
         fprintf(1, '%s\n', str(k,:));
       end;
     end;
   end;
   
  
   
   
   return;
   