function [sp] = subsasgn(sp, stct, rhs)

   % First deal with UI params
   if ~isempty(sp.type), % Assigning to a UI Param: only ".value" allowed
      if length(sp) > 1,
         error(['Nested subcript assignment allowed only for non-UI params']);
      end;
      if ~(strcmp(stct.type, '.') &&  (strcmp(stct.subs, 'value') || strcmp(stct.subs,'value_callback') || strcmp(stct.subs,'name')) )
         error(['Only ".value = " assignment us allowed for UI params']);
      end;

      if strcmp(stct.subs, 'value') | strcmp(stct.subs,'value_callback')
          sp = subsasgn_dot_value(sp, rhs);
      elseif strcmp(stct.subs, 'name')
          sp.param_name = rhs;
      end;
      return;
   end;

   % OK, not a UI param. More complex things allowed.

   % Check for straightforward ".value = " assignment
   if length(stct)==1 & strcmp(stct.type, '.') & strcmp(stct.subs, 'value'),
          sp.value = rhs; return;
   elseif length(stct)==1 & strcmp(stct.type, '.') & strcmp(stct.subs, 'name'),
          sp.param_name = rhs; return;
   end;      
   
   % Eliminate following check for existence of a field in a structure: 
   % regular Matlab behavior (which works ok) is to create a field if
   % assigning to it and it didn't exist before.
   
%    % If assigning as if for a structure, check that the field exists.
%    if strcmp(stct(1).type, '.')  &  ~isfield(sp.value, stct(1).subs),
%       error(['Value of parameter "' sp.param_name '" does not contain ' ...
%              'desired "' stct(1).subs '" field, or is not a structure']);
%    end;

   % Everything looks good and it wasnt .value-- just pass it on
   if isobject(rhs) && exist(['@' class(rhs) filesep 'subsasgn'], 'file')==2,
       error(['Sorry, can''t execute this kind of assignment statement -- objects ' ...
           'of class ' class(rhs) ', like the right-hand-side, will take precedence ' ...
           'with their own definitions of assignment']);
   end; 
   sp.value = subsasgn(sp.value, stct, rhs);
     
   
   