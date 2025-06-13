% [] = SoloFunction(funcname, varargin)
%
% Identical to SoloFunctionAddVars.m. SoloFunction.m is kept only 
% for backwards compatibility in naming.
%
% Adds variables to the declared lists of read/write and/or read-only
% variables 
%
% SPECIAL CASES:
% --------------
%
% If called with only one parameter, it expects this to be a
% func_owner, and it CLEARS all the entries for that funcowner
%
% If called with the optional key-value pair, 'add_or_delete', 'add',
% it expects to have a total of three args, the first of which is an
% sph to be deleted from the lists.
%

function [] = SoloFunction(funcname, varargin)

   global private_solofunction_list
   if isempty(private_solofunction_list), 
      private_solofunction_list = {};
   end;

   % Did we get just one string param? Then it is an owner, and all its
   % guys are to be deleted:
   if nargin==1 && ischar(funcname),
      func_owner = funcname;
      mod = find_modules_funclist(func_owner);
      if ~isempty(mod),
         keeps = ones(rows(private_solofunction_list),1); keeps(mod) = 0;
         private_solofunction_list = private_solofunction_list(find(keeps),:);
      end;
      return;
   end;
   
   pairs = { ...
       'rw_args'           {}                     ;  ...
       'ro_args'           {}                     ;  ...
       'func_owner'        determine_owner        ;  ...
       'caller_funcname'   determine_fullfuncname ;  ...
       'add_or_delete'     'add'                  ;  ...
   }; parseargs(varargin, pairs);
    
   
   if strcmp(add_or_delete, 'delete'),
      if ~isa(funcname, 'SoloParamHandle'),
         error(['When add_or_delete is ''delete'', the first argument ' ...
                'must be a SoloParamHandle, the one to be erased from ' ...
                'all SoloFunction variable registries']);
      end;
      SoloFunctionRemoveVar(funcname)
      return;
   end;
   
   if ~iscell(rw_args), rw_args = {rw_args}; end;
   if ~iscell(ro_args), ro_args = {ro_args}; end;
   rw_args = rw_args(:); rw_args = [rw_args cell(size(rw_args))];
   ro_args = ro_args(:); ro_args = [ro_args cell(size(ro_args))];
   for i=1:size(rw_args,1),
      try, 
         rw_args{i,2} = evalin('caller', rw_args{i,1});
      catch,
         fprintf(2, '\n  ** %s does not exist. **\n\n', rw_args{i,1});
         rethrow(lasterror);
      end;
      if ~isa(rw_args{i,2}, 'SoloParamHandle'),
         error('rw arguments must be SoloParamHandles');
      end;
   end;

   for i=1:size(ro_args,1),
      try, 
         ro_args{i,2} = evalin('caller', ro_args{i,1});
      catch,
         fprintf(2, '\n  ** %s does not exist. **\n\n', ro_args{i,1});
         rethrow(lasterror);
      end;
   end;

   [mod, funclist, globals] = find_modules_funclist(func_owner);
   fun                      = find_function_entry(funclist, funcname);
   callerfun                = find_function_entry(funclist, caller_funcname);

   % If one of the new read-onlies was also a read-only in the caller's
   % space, then it should be stored as a handle, so it gets
   % instantiated with the current value when the new function is called.
   if ~isempty(callerfun),
      callers_readonlies = [globals{2} ; funclist{callerfun, 3}];
      if ~isempty(callers_readonlies),
         for i=1:size(ro_args,1),
            u = find(strcmp(ro_args{i,1}, callers_readonlies(:,1)));
            if ~isempty(u), % use the last instantiation
               if isa(callers_readonlies{u(end),2}, 'SoloParamHandle'),
                  ro_args{i,2} = callers_readonlies{u(end),2};
               end;
            end;
         end;
      end;
   end;
   
   if isempty(fun), funclist = [funclist ; {funcname rw_args ro_args}];
   else             
      old_rw_args = funclist{fun,2};
      old_ro_args = funclist{fun,3};
      funclist(fun,:) = ...
          {funcname add_new_args(old_rw_args, rw_args) ...
           add_new_args(old_ro_args, ro_args)};
   end;
   private_solofunction_list{mod,2} = funclist;
   

% -----

function [arglist] = add_new_args(old_args, new_args)
% Adds new arguments to produce complete list; if any new arguments
% have the same name as old arguments, then the old arg gets
% OVERWRITTEN (since it won't be accessible anyway). Thus no varname
% copies get stored.
%    Expected format for the cells is 1st column: varname; 2nd col: value.   
%
   if isempty(new_args), arglist = old_args; return; end;
   if isempty(old_args), arglist = new_args; return; end;
   
   keep = ones(rows(new_args), 1);
   for i=1:rows(new_args),
      u = find(strcmp(new_args{i,1}, old_args(:,1)));
      if ~isempty(u), % found old arg with same name
         u = u(end);
         old_args{u,2} = new_args{i,2}; % overwrite old arg's value
         keep(i) = 0;                   % mark new arg as already dealt with
      end;
   end;
   
   % Add on only new args not dealt with yet:
   new_args = new_args(find(keep),:);

   % Make concatenated list:
   arglist = [old_args ; new_args];
   
   return;
   
   
   
% -----  

function [fun] = find_function_entry(funclist, funcname)
% Find whether a particular function already has an entry in a list of
% functions 

   if isempty(funclist), fun = [];
   else fun = find(strcmp(funcname, funclist(:,1)));
   end;

   return;
   
      
