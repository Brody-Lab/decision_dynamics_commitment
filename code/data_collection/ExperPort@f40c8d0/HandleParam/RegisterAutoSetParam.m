% [] = RegisterAutoSetParam(sph, add_or_delete_flag)
%
% Private function used by the HandleParam suite -- this function is
% not intended for user space.
%
% Adds (or deletes) a SoloParamHandle to a list that keeps track of
% which SPHs have autoset strings that must be called when
% ComputeAutoSet.m is called.
%
% Internally, the list groups SPHs into groups with the same owner and
% belonging to the same function. These two attributes (owner and
% function) are derived from the SPH's param_owner and param_fullname
% properties.
%
% If the first parameter is a string, it is taken to be the name of an
% owner; and all that owner's SPHs are then deleted from the AutoSet
% register.
%
% PARAMS:
% -------
%
% sph                   A SoloParamHandle. If a string instead of an
%                       SPH, it is taken to be the name of an owner;
%                       any SPHs in the register belonging to that
%                       owner are deleted from the register.
%
% add_or_delete_flag    By default, 1, which means add the sph to the
%                       list; if passed as 0, it means delete it from
%                       the list.

function [] = RegisterAutoSetParam(sph, add_or_delete_flag)
   
% Determine whether to add the SoloParamHandle to the register
% (addit=1), or delete it (add it=0).
if nargin < 2, addit = 1;
elseif isstr(add_or_delete_flag),
    switch add_or_delete_flag,
        case 'add',    addit = 1;
        case 'delete', addit = 0;
        otherwise error('Don''t understand string command');
    end;
else
    addit = add_or_delete_flag;
end;

% Let's get the list
global private_autoset_list
if isempty(private_autoset_list),
    private_autoset_list = {};
end;

if isstr(sph), % Not an SPH-- it is the name of an owner!
    if isempty(private_autoset_list), return; end; % nothing there to delete
    mod = find(strcmp(sph, private_autoset_list(:,1))); % Guy to delete
    if ~isempty(mod),
        % If found that owner, delete everything it owns from our list:
        private_autoset_list = private_autoset_list([1:mod-1 mod+1:end],:);
    end;
    return; % We're done.
end;

param_name     = get_name(sph);
param_owner    = get_owner(sph);
param_fullname = get_fullname(sph);

func_owner = param_owner;
% In SoloParamHandle.m, the param_fullname is defined as
%    [determine_fullfuncname '_' name], so we can get the funcname
% out by subtracting the name:
funcname   = param_fullname(1:end - (length(param_name)+1));

% First find the owner and find the function list corresponding to it:
if isempty(private_autoset_list), mod = [];
else mod = find(strcmp(func_owner, private_autoset_list(:,1)));
end;
if isempty(mod),
    if ~addit, return; end;
    private_autoset_list = ...
        [private_autoset_list ;{func_owner {}}];
    mod = size(private_autoset_list, 1);
end;
funclist = private_autoset_list{mod, 2};

% Now find the parameter list for this function:
if isempty(funclist), fun = [];
else fun = find(strcmp(funcname, funclist(:,1)));
end;
if isempty(fun), % Function not in list yet, much less its params
    if ~addit, return; end;
    funclist = [funclist ; {funcname {sph}}];
    g = get_ghandle(sph);
    change_autoset_look(sph, 'on');
else % Ok, function is in list
    old_rw_args = funclist{fun, 2};
    % Let's check whether param is there already:
    pos = []; for i=1:length(old_rw_args),
        if is_same_soloparamhandle(sph, old_rw_args{i}), pos = i; end;
    end;
    if addit,
        % If it was there already, do nothing; otherwise add it in:
        if ~isempty(pos), return;
        else
            funclist(fun,:) = {funcname [old_rw_args ; {sph}]};
            change_autoset_look(sph,'on');
            % ADDING  ---- must be adding if here
        end;
    else % want to remove it
        % If it wasn't there, no need to do anything; otherwise, remove:
        if isempty(pos), return;
        else
            funclist(fun,:) = {funcname old_rw_args([1:pos-1 pos+1:end])};
            % REMOVING  ---- must be removing if here
            change_autoset_look(sph,'off');
            % Check whether removing it emptied param list for this function:
            if isempty(funclist{fun,2}),
                funclist = funclist([1:fun-1 fun+1:end],:);
            end;
        end;
    end;
end;

% Ok, put the revised funclist into the master list:
private_autoset_list{mod,2} = funclist;


% ----------------------------------------
function [] = change_autoset_look(sph, flag)

g = get_ghandle(sph);
% If it is not a graphics handle, ignore it-- probably an SPH that is
% about to be deleted, since its graphics object has been deleted:
if ~ishandle(g), return; end;

if strcmpi(flag,'on')
   set(g,'FontAngle','italic');
   set(g,'BackgroundColor',[0.6 1 0.8]);
   set(g,'Enable','inactive'); 
elseif strcmpi(flag,'off')
   set(g,'FontAngle','normal');
   set(g,'BackgroundColor', 'w');
   set(g,'Enable','on');
else
   error('Um, autoset appearance flag should be ''on'' or ''off''. What''s this?');
end;
