% [n] = delete_sphandle({'owner', '.*'}, {'name', '.*'}, ...
%             {'fullname', '.*'}, {'handlelist', all})
% 
% Finds those SoloParamHandles that regexp match the indicated owner
% (default: all owners), and that have the indicated name (default: all
% names), and indicated fullname (default: all) and permanently deletes
% them. An optional cell list of handles can also be passed; in that
% case the search and destroy will be limited to those handles listed. 
%
% RETURNS:   n,  the number of handles deleted
% --------
%
% OPTIONAL PARAMS:
% ----------------
%
% 'owner'       A string expression, default '.*' that will be matched
%               against the 'owner' tag of a SoloParamHandle.
%
% 'name'        A string expression, default '.*' that will be matched
%               against the 'name' tag of a SoloParamHandle. This
%               generally matches the ordinary name of the variable.
%
% 'fullname'    A string expression, default '.*' that will be matched
%               against the 'fullname' tag of a SoloParamHandle. This tag
%               includes the name of the function within which the
%               variable lives, as well as the name of the variable
%               itself. 
%
% 'handlelist'  A cell vector of SoloParamHandles.
%
%
% EXAMPLE:
% --------
%
%    >> delete_sphandle('owner', 'locsamp4obj')
%
% will permanently delete any SoloParamHandles owned by locsamp4obj.
%
%    >> delete_sphandle('handlelist', {a;b;c}, 'owner', 'locsamp4obj')
%
% will permanently delete any of a,b, or c handles owned by locsamp4obj.
%

% C Brody wrote me Sep-05

function [n] = delete_sphandle(varargin)
   global private_soloparam_list;
   psl = private_soloparam_list;

   pairs = { ...
       'owner'           '.*'   ; ...
       'name'            '.*'   ; ...
       'fullname'        '.*'   ; ...
       'handlelist'       psl   ; ...
   }; parseargs(varargin, pairs);

   if isempty(handlelist), return; end;
   if isa(handlelist{1}, 'SoloParamHandle'), full_splist_fg = 0;
   else                                      full_splist_fg = 1;
   end;
   
   hsl = handlelist(:); % Just a shorter name for handlelist
   
   handles = zeros(size(hsl));
   for i=1:length(hsl),
      if (isa(hsl{i}, 'SoloParam') || isa(hsl{i}, 'SoloParamHandle')) ....
          &&  ~isempty(regexp(get_owner(hsl{i}),    owner)) ...
          &&  ~isempty(regexp(get_name(hsl{i}),     name)) ...
          &&  ~isempty(regexp(get_fullname(hsl{i}), fullname)),
         % Mark the handle for deletion:
         handles(i) = 1; 
      end;
   end;

  
   if strcmp(name, '.*') && strcmp(fullname, '.*') && isempty(find(strcmp(varargin, 'handlelist')))
     % We're going to be deleting whole sets of owners, let's go the fast
     % route
     nn = delete_sphandle_owners(owner, handlelist, handles);
     if nargout > 0, nn=n; end;
     return;
   end;
 
   u = find(handles);
   if nargout > 0, n = length(u); end;

   if full_splist_fg,
     hlist = cell(size(u));
     for i=1:length(u), hlist{i} = SoloParamHandle(u(i)); end;

     SoloFunctionRemoveVar(hlist);
     for i=1:length(u),  
        delete(hlist{i},  0); drawnow;
     end;     
   else
     SoloFunctionRemoveVar(hsl(u));
     for i=1:length(u),  delete(hsl{u(i)}, 0); end;
   end;
   
   
   % --------------------
   
  function [n] = delete_sphandle_owners(owner, handlelist, handles)

     u = find(handles);
     n = length(u);
     
     ownernames = {};
     for i=1:length(u),
         ownernames = [ownernames ; get_owner(handlelist{u(i)})];
     end;
     ownernames = unique(ownernames);
     
     % Delete the SPHs without unregistering from the function access list:
     for i=1:length(u),
       if isa(handlelist{u(i)}, 'SoloParam'), delete(SoloParamHandle(u(i)), 0);
       else                                   delete(handlelist{u(i)},      0);
       end;
     end;

     % Now unregister whole chunks of owners:
     for i=1:length(ownernames)
       SoloFunctionAddVars(ownernames{i});       
     end;
     
     
   
