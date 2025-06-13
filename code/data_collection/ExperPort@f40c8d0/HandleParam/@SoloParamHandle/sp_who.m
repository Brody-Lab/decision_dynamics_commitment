% [] = sp_who(sph)
%
% Gievn a SoloParamHandle object, sph, this function prints out a list of
% which function creates this sph, and which functions have read-only
% or read-write access to it.
%


function [] = sp_who(sph)

% pairs = { ...
%   'owner'      []     ; ...
%   'name'       []      ; ...
%   'fullname'   []  ; ...
%   }; parseargs(varargin, pairs);


% spstruct = {};

global private_soloparam_list;

global private_solofunction_list;
% private_solofunction_list is a cell array with three columns. The
% first column contains owner ids. Each row is unique. For each row
% with an owner id, the second column contains a cell array that
% corresponds to the set of function names that are registered for that
% owner. The third row contains the globals declared for that owner.

name  = get_name(sph);
func  = get_fullname(sph); func = func(1:(length(func) - (length(name)+1)));
owner = get_owner(sph);

fprintf(1, '\n%s/%s.m  owns "%s"\n', owner, func, name);

psfl = private_solofunction_list;

u = find(strcmp(owner, psfl(:,1)));
if ~isempty(u),
  rw_globals = psfl{u,3}{1};
  ro_globals = psfl{u,3}{2};
  
  rwi = find(same_soloparamhandle(sph, rw_globals(:,2)));
  roi = find(same_soloparamhandle(sph, ro_globals(:,2)));
  
  if ~isempty(rwi),
    fprintf(1, '"%s" is also registered as a read-write global for %s\n', name, owner);
  end;
  if ~isempty(roi),
    fprintf(1, '"%s" is also registered as a read-only global for %s\n\n', name, owner);
  end;

  
  for f=1:rows(psfl{u,2}),
    rws = psfl{u,2}{f,2};
    ros = psfl{u,2}{f,3};
    
    if ~isempty(rws), rwi = find(same_soloparamhandle(sph, rws(:,2))); else rwi = []; end;
    if ~isempty(ros), roi = find(same_soloparamhandle(sph, ros(:,2))); else roi = []; end;
    
    if ~isempty(rwi) && ~strcmp(func, psfl{u,2}{f,1}),
      fprintf(1, '%s/%s.m has read-write access to "%s"\n', owner, psfl{u,2}{f,1}, name);
    end;
    if ~isempty(roi),
      fprintf(1, '%s/%s.m has read-only access to "%s"\n',  owner, psfl{u,2}{f,1}, name);
    end;
    
  end;
end;

fprintf(1, '\n');

