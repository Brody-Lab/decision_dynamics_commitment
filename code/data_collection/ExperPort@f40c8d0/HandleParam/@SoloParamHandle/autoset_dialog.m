function [] = autoset_dialog(sph)
%
% Given sph, pops up a dialog window in which users can insert a string
% that will be then set as the autoset_string for sph. If the resulting
% string is non-empty, also registers sph as a parameter with
% RegisterAutoSetParam, so that it is known as a parameter with an
% evaluatable autoset_string.  
%
   

   owner    = get_owner(sph);
   fullname = get_fullname(sph);
   name     = get_name(sph);
   
   funcname = fullname(1:end - (length(name)+1));

   vars = GetSoloFunctionArgList(owner, funcname);

   str1 = '';
   str1 = [str1 sprintf(...
     ['This is an autoset dialog box. You can type in a MATLAB string  ' ...
      'that will be evaluated at the end of every trial; the result of ' ...
      'that evaluation will then be assigned as the value of parameter ' ...
      '"%s".\n\n'], name)];
   
%   str1 = [str1 sprintf(...
%     ['(The evaluation actually takes place when ComputeAutoSet.m is ' ...
%      'called. In a correctly programmed protocol, this is immediately ' ...
%      'after each trial ends, and before params for the next one are ' ...
%      'readied.)\n\n'])];
   
   str2 = sprintf(['parameter name="%s" : Is part of function="%s" : ' ...
                   'Which has owner="%s"\n\n'], name, funcname, owner);   

   str2 = [str2 sprintf( ...
     ['    (NOTE: Matlab will be halted until you finish with this ' ...
           'window.)\n\n'])];

   if ~isempty(vars),
      str3 = sprintf(...
        ['The following SoloParamHandles will be instantiated when the ' ...
         'MATLAB string is evaluated (and can therefore be used within ' ...
         'your MATLAB string):\n\n']);
      str3 = add_prepared_varlist(vars, str3, 20);
   else
      str3 = sprintf(...
        ['For this parameter, there are no SoloParamHandles that will ' ...
         'be instantiated before evaluation of your MATLAB string.\n']);
   end;
     
   str3 = [str3 sprintf('\n%s.value = ', name)];

   options.Resize      = 'off';
   options.WindowStyle = 'normal';
   options.Interpreter = 'none';
   
   autoset_string = inputdlg([str1 str2 str3], ...
                             sprintf('%s : autoset', name), ...
                             7, {get_autoset_string(sph)}, options);

   % If user clicked 'cancel', do nothing:
   if isempty(autoset_string), return; end;
   
   t = cellstr(autoset_string{1});
   concat = 't{1}';
       for ctr = 2:size(t,1)
           temp = t{ctr}; t{ctr} = [' ' temp ' '];
           concat = [concat ', t{' num2str(ctr) '}'];
       end;
   eval(['autoset_string = strcat(' concat ')']);
  
%    s = autoset_string{1};
%    autoset_string = cellstr(s);
%    autoset_string = strtrim(autoset_string);
   if isempty(autoset_string),
      set_autoset_string(sph, autoset_string);
      RegisterAutoSetParam(sph, 'delete');
      msgbox(sprintf('Your autoset string was:\n\n--EMPTY (no autoset)--\n'),...
             sprintf('%s : autoset', name), 'warn', 'modal');
   else
      set_autoset_string(sph, autoset_string);
      RegisterAutoSetParam(sph, 'add');
      msgbox(sprintf('Your autoset string was:\n\n%s\n', autoset_string), ...
             sprintf('%s : autoset', name), 'warn', 'modal');
   end;

   return;
   
   
% ----------------

function [str] = add_prepared_varlist(vars, str, tabpt)
% Returns a string containing all the strings in cell vector vars; if
% there are more than 8, breaks it into two columns

   if nargin<3, tabpt = 7; end;
   
   if length(vars)<8,
      for i=1:length(vars),  str = [str sprintf('   %s\n', vars{i})]; end;
   else
      % Maximum var name length:
      mx = 0; for i=1:length(vars), mx = max(mx, length(vars{i})); end;
      
      bp = ceil(length(vars)/2);
      for i=1:bp,
         if i+bp <= length(vars),
            ntabs = round((mx - length(vars{i}))/tabpt)+2;
            str = [str sprintf('   %s%s%s\n', vars{i}, ...
                               char(sprintf('\t')*ones(1, ntabs)), ...
                               vars{i+bp})];
         else
            str = [str sprintf('   %s\n', vars{i})];
         end;
      end;
   end;
   