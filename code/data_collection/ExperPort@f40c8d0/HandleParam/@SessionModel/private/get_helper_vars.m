% [varlist, initvals, forceinit] = get_helper_vars(SessionModel_obj, [training_stage_number])
%
% Returns three cell vectors: the first, varlist, is a cell vector  of
% strings, each the name of a helper var in stage number
% training_stage_number of the SessionModel_obj
%
% The second is a cell vector, the same size as the varlist, with each
% element an initialization value for each of the helper vars.
%
% The last is an integers vector, the same size as the varlist, with a 1
% for each element in which initialization should be forced after a stage
% jump and a 0 when preserving a previous stage's value is allowed.
%
% If training stage number is ommitted, the current training stage is used.
%

function [varlist, initvals, forceinit] = get_helper_vars(obj, ind)

   if nargin<2, ind = get_current_training_stage(obj); end;

   varlist = {}; initvals = {}; forceinit = [];
   ts = get_training_stages(obj);
   if ind < 1 || ind > rows(ts), return; end;
   
   vars = ts{ind, obj.vars_COL};
   
   for i=1:length(vars),
     trimmed = strtrim(vars{i});
     if ~isempty(trimmed) && trimmed(1)~='%',
       [varname, trimmed] = strtok(trimmed); %#ok<STTOK>
       varlist = [varlist ; {varname}]; %#ok<AGROW>
       if nargout>=2
         trimmed = strtrim(trimmed);
         if isempty(trimmed), varval = 0; varforceinit = 0;
         else
           [lasttok, withoutlast] = strtok(trimmed(end:-1:1)); 
           lasttok = lasttok(end:-1:1);
           if ismember(lasttok, {'forceinit=1', 'force_init=1'}), 
             trimmed = withoutlast(end:-1:1);
             varforceinit = 1;
           else
             varforceinit = 0;
           end;
           try   varval = eval(trimmed); %#ok<ST2NM>
           catch %#ok<CTCH>
             lerr = lasterror; %#ok<LERR>
             warning(lerr.identifier, ['On trying to initialize your helper var "%s",\n' ...
               'you got error "%s",\ninitializing to default value 0'], varname, lerr.message);
             varval = 0;
           end;
         end;
         initvals =  [initvals  ; {varval}]; %#ok<AGROW>
         forceinit = [forceinit ; varforceinit]; %#ok<AGROW>
       end;
     end;
   end;

   