% [settings] = check_settingsDB(ratname, experimenter, varname, dates, {'nth', 1})
%
% Reports on settings for a particular rat; the report is printed out to
% the command line. If the value of the settings is a cell then the value
% is passed in the output but not displayed.
%
% Uses regexp to match the varname.  If the varname matches multiple
% SoloParamHandles the function prints out all matching variables.
%
% Uses the solodata mysql schema.  Will only function for rats that are running
% on a protocol with a table in this schema.
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
% dates         By default looks at the settings file with the latest date.
%               dates can be a scalar or a vector of integers indicating
%               the number of files to look back to. E.g., -5:0 means look
%               at the files with the latest 6 dates.
%				dates can also be a date string, e.g. '2009-05-10' or a 
%				cell array of date strings 
%    
%
% OPTIONAL PARAMETERS:
% --------------------
%
% nth           By default, 1. Sometimes a varname will match more than one
%               SPH. nth will indicate which match to use-- the default is
%               to use the first match. 2 means use the second, etc.
%

% written by Jeffrey Erlich 2009
% modified from check_settings.m by Carlos Brody 2009


function [stngs] = check_settingsDB(ratname, experimenter, varname, nback, varargin)

   stngs = [];
   if nargin < 3, nback = 0; end;
   
   pairs = { ...
     'nth'   0  ; ...
   }; parseargs(varargin, pairs);
   
   if ~ischar(nback) && length(nback)>1,
     for i=1:length(nback)
		 if iscell(nback)
			 t_nback=nback{i};
		 else
			 t_nback=nback(i);
		 end
       if nargout>0,
         stngs = [stngs ; check_settingsDB(ratname, experimenter,varname, t_nback, varargin{1:end})]; %#ok<AGROW>
       else
         check_settingsDB(ratname, experimenter, varname, t_nback, varargin{1:end});
       end;
     end;
     return;
   end;
     
   saved=load_data_from_sql(ratname, nback); 
   if isempty(saved)
	   return
   end
   X=saved.SavingSection_data_file;
   last_slash=max(find('\'==X));
   if ~isempty(last_slash)
   X=X(last_slash+1:end);
   end
   
   if strfind(X, 'ASV')
	   X=X(1:end-8);
   end
   
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
   
   stngs=saved.(fnames{keeps});
   
   if isnumeric(stngs),
     fprintf(1, '%s: Value of %s is %s\n', X, fnames{keeps}, num2str(stngs));
   elseif iscell(stngs),
     fprintf(1, '%s: Value of %s is a cell.  Can''t display.\n', X, fnames{keeps});
   elseif ischar(stngs)
     if size(stngs,1)==1,
       fprintf(1, '%s: Value of %s is %s\n', X, fnames{keeps}, stngs);
     else
       fprintf(1, '%s: Value of %s is:\n', X, fnames{keeps});
       for k=1:size(stngs,1),
         fprintf(1, '%s\n', stngs(k,:));
       end;
     end;
   end;
   
  
   
   
   return;
   