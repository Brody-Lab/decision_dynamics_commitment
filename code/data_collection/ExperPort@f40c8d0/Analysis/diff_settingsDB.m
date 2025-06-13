function S=diff_settingsDB(ratname, experimenter, nback,varargin)
% diff_settingsDB(ratname, experimenter, date, [])
% Tells you what changed in a settings file from one day to the next!



   stngs = [];
   if nargin < 3, nback = 0; end;
   
   
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
     
   new_saved=load_data_from_sql(ratname, nback); 
   if isnumeric(nback)
   old_saved=load_data_from_sql(ratname, nback-1);
   else
	   old_saved=load_data_from_sql(ratname, datestr(datevec(nback)-[0 0 1 0 0 0],29));
   end   
   if isempty(new_saved)
	   return
   end
   
	   tr=2;
	   while tr<15 && isempty(old_saved)
		   	   old_saved=load_data_from_sql(ratname, datestr(datevec(nback)-[0 0 tr 0 0 0]));
			   tr=tr+1;
	   end
	   
	if isempty(old_saved)
		fprintf('No settings file within 2 weeks of %s\n', nback);
		return
	end
	
	
  
		   
   
   S.new_file=clean_fname(new_saved.SavingSection_data_file);
   S.old_file=clean_fname(old_saved.SavingSection_data_file);
  
   n_fnames = fieldnames(new_saved); %#ok<NODEF>
   o_fnames = fieldnames(old_saved);
   
   
   S.added=setdiff(n_fnames, o_fnames);
   S.deleted=setdiff(o_fnames, n_fnames);
   
   f_names=intersect(n_fnames, o_fnames);
   
   for fx=1:numel(f_names)
	   if ~isequal(new_saved.(f_names{fx}),old_saved.(f_names{fx}))
		   S.(f_names{fx}).new=new_saved.(f_names{fx});
		   S.(f_names{fx}).old=old_saved.(f_names{fx});
	   end
   end
   
   
   
   
	function x=clean_fname(x)   
      last_slash=max(find('\'==x)); %#ok<MXFND> % note this will only work as long as we are running all behavior rigs on windows.
   if ~isempty(last_slash)
   x=x(last_slash+1:end);
   end
   
   if strfind(x, 'ASV')
	   x=x(1:end-8);
   end

   