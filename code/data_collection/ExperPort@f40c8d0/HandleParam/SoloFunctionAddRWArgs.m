% [] = SoloFunctionAddRWArgs(func_owner, funcname, rw_args)
%
% Private function used by SoloParamHandle -- this function is not
% intended for user space. 
%
% Adds read/write arguments to the list of SoloParamHandles that a
% function will obtain when it calls GetSoloFunctionArgs.
%
% PARAMS:
% -------
%
% func_owner      The object that will own the function and the
%                 SoloParamHandles.
% 
% funcname        The full name of the function (as obtained from
%                 determine_fullfuncname)  that will have the
%                 SoloParamHandles made accessible to it.
%
% rw_args         May be either a single element of a cell column vector of
%                 elements. For each element, if a string, must be a
%                 string that evaluates to a SoloParamHandle in the
%                 caller's workspace. Otherwise, must be a
%                 SoloParamHandle. 

% Written by Carlos Brody

function [] = SoloFunctionAddRWArgs(func_owner, funcname, rw_args)
   
   
      
   global private_solofunction_list
   if isempty(private_solofunction_list), 
      private_solofunction_list = {};
   end;
   
   if ~iscell(rw_args), rw_args = {rw_args}; end;
   rw_args = rw_args(:); rw_args = [rw_args cell(size(rw_args))];

   for i=1:size(rw_args,1),
      if isa(rw_args{i,1}, 'SoloParamHandle'), % Already passed as handle 
         rw_args{i,2} = rw_args{i,1};
         rw_args{i,1} = get_name(rw_args{i,2});
      else                                     % Must've been passed as string
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
   end;
   
   [mod, funclist] = find_modules_funclist(func_owner);

   if isempty(funclist), fun = [];
   else fun = find(strcmp(funcname, funclist(:,1)));
   end;
   if isempty(fun),
      funclist = [funclist ; {funcname rw_args {}}];
   else
      old_rw_args = funclist{fun, 2};
      old_ro_args = funclist{fun, 3};
      funclist(fun,:) = {funcname [old_rw_args ; rw_args] old_ro_args};
   end;
   private_solofunction_list{mod,2} = funclist;
   
