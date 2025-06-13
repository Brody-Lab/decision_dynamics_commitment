% [handles, idx_within_list] = get_sphandle({'name', '.*',}, {'fullname', '.*'}, ...
%        {'funcowner', '.*'}, ...
%        {'owner', '.*'}, {'handlelist', {}}, {'first', 0})    Find a SoloParamHandle.
%
% For clean code, IT IS NOT RECOMMENDED YOU USE GET_SPHANDLE IN YOUR CODE.
% This function is meant as a debugging tool, not for regular coding.
%
% Given some search parameters, this function finds the SoloParamHandle(s)
% that fit those parameters. If it is given no parameters, it will return
% all existing SoloParamHandles. Typically it is used with at least one of
% the optional parameters specified.
%
% OPTIONAL PARAMETERS:
% ---------------------
%
% 'name'       A string that will be matched (using regexp.m) to the name
%              of the SoloParamHandle-- e.g., if a SoloParamHandle with
%              name 'nombre' was created in function
%              @myobject/myfunction.m, then the name is 'nombre'. Thus  the
%              strings 'nombre' and 'nom' and 'ombr' will all match it.
%              To match the exact name, use '^nombre$' (see help
%              regexp.m). Default value of this optional param is '.*',
%              i.e., all names.
%
% 'fullname'   A string that will be matched (using regexp.m) to the fullname
%              of the SoloParamHandle-- e.g., if a SoloParamHandle with
%              name 'nombre' was created in function
%              @myobject/myfunction.m, then the fullname is
%              'myfunction_nombre'. Thus the strings 'myfunc' and
%              'tion_nom' and 'ombr' will all match it. To match the exact
%              fullname, use '^myfunction_nombre$' (see help regexp.m).
%              Default value of this optional param is '.*', i.e., all
%              fullnames.
%
% 'funcowner'  A string that will be matched (using regexp.m) to the function of
%              the SoloParamHandle. Typically the function owner is the mfile 
%               that created the SoloParamHandle-- e.g., if a
%              SoloParamHandle with name 'nombre' was created in function
%              @myobject/myfunction.m, then the function owner is 'myfunction'. Thus
%              the strings 'myfun' and 'unc' and 'tion' will all match it.
%              To match the exact ofunction wner string, use '^myfunction$' (see help
%              regexp.m). Default value of this optional param is '.*',
%
% 'owner'      A string that will be matched (using regexp.m) to the owner of
%              the SoloParamHandle. Typically the owner is the class of the
%              object that created the SoloParamHandle-- e.g., if a
%              SoloParamHandle with name 'nombre' was created in function
%              @myobject/myfunction.m, then the owner is 'myobject'. Thus
%              the strings 'myobj' and 'obje' and 'ct' will all match it.
%              To match the exact owner string, use '^myobject$' (see help
%              regexp.m). Default value of this optional param is '.*',
%              i.e., all owners.
%
% 'handlelist' A cell vector, each entry of which is a SoloParamHandle.
%              Default value of this parameter is an empty cell. When
%              handlelist is an empty cell, all existing SoloParamHandles
%              are searched. When handlelist is not empty, only
%              SoloParamHandles *within* the list will be searched.
%              Limiting the search this way can be useful when trying to
%              speed things up.
%
% 'first'      A scalar, either 0 or 1. Default value is 0. The value 0
%              means "return all the SoloParamHandles that match the search
%              terms." A value of 1 means "return only the first
%              SoloParamHandle that matches the search term."
%
%
% RETURNS:
% --------
%
% handles      A cell vector. Each entry will be a SoloParamHandle that
%              matched the search terms. If no SoloParamHandles matches the
%              search terms, handles will be an empty cell.
%
% idx_within_list   A numeric vector, same size as handles. If the
%             handlelist was specified, then idx_within_list will indicate
%             the indices of the entries in handlelist that matched the
%             search terms; that is, handles will be equal to
%             handlelist(idx_within_list). If no handlelist was specified,
%             idx_within_list will return as an empty vector.
%
% EXAMPLE:
% ---------
%
% >> handles = get_sphandle('name', 'this')
%
% Will return all the SoloParamHandles that have the string 'this' in their
% name, regardless of owner or fullname. If you then call
%
% >> subset = get_sphandle('owner', '^hunter_s_thompson$', 'handlelist', handles)
%
% you will get back only those SoloParamHandles that have 'this' in their
% name *and* are owned by 'hunter_s_thompson'. Of course, if all you wanted
% was that net result, you could also do it directly with the single line:
%
% >> subset = get_sphandle('owner', '^hunter_s_thompson$', 'name', 'this')
%


% Written by Carlos Brody 2005, rewritten May 2007.

function [handles, idx_within_list] = get_sphandle(varargin)

   global private_soloparam_list;

   pairs = { ...
       'funcowner'    '.*'   ; ...
       'owner'        '.*'   ; ...
       'name'         '.*'   ; ...
       'fullname'     '.*'   ; ...
       'handlelist'    {}    ; ...
       'first'          0    ; ...
   }; parseargs(varargin, pairs);
   
   if isempty(handlelist), psl = private_soloparam_list;  % Entries will be SoloParam objects
   else                    psl = handlelist;              % Entries will be SoloParamHandle objects
   end;
   if isempty(psl), handles = {}; return; end;
   
   guys = zeros(size(psl)); idx_within_list = [];
   
   % Moved these 4 strcmp calls out of the loop.  Saves some time if ps1 is large
   
   def_funcowner=strcmp(funcowner, '.*');
   def_owner=strcmp(owner, '.*');
   def_name=strcmp(name,  '.*');
   def_fullname=strcmp(fullname, '.*');
   
   for i=1:length(psl),
      % if ~isempty(psl{i})  &&  ... 
      if  (isa(psl{i}, 'SoloParam') || isa(psl{i}, 'SoloParamHandle')) &&  ...
             (def_funcowner || ~isempty(regexp(get_funcowner(psl{i}), funcowner, 'once')))  &&  ...
             (def_owner     || ~isempty(regexp(get_owner(psl{i}), owner, 'once')))  &&  ...
             (def_name      || ~isempty(regexp(get_name(psl{i}),   name, 'once' )))  &&  ...
             (def_fullname  || ~isempty(regexp(get_fullname(psl{i}), fullname, 'once'))),
         
         
         
         guys(i) = 1; if nargout > 1, idx_within_list = [idx_within_list ; i]; end;
         if first==1, break; end;
      end;
   end;
   
   guys = find(guys);
   if isempty(guys), handles = {}; return; end;
    
   if ~isempty(handlelist),
      handles = handlelist(guys);
   else
      handles = cell(size(guys));
      for i=1:length(guys),
         handles{i} = SoloParamHandle(guys(i));
      end;
   end;
   
   
