% [] = DeclareGlobals(obj, {'rw_args', {'arg1', 'arg2, ...}}, ...
%                          {'ro_args', {'arg1', 'arg2, ...}}, ...
%                          {'owner', class(obj)})
%
% Function that adds to the globals list for a particular owner
% (by default, this owner is the class of obj).
%

function [] = DeclareGlobals(obj, varargin)
   
   pairs = { ...
     'rw_args'       cell(0,2)          ; ...
     'ro_args'       cell(0,2)          ; ...
     'owner'         ['@' class(obj)]   ; ...
   }; parseargs(varargin, pairs);
   
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
         error('globals arguments must be SoloParamHandles');
      end;
   end;

   for i=1:size(ro_args,1),
      try, 
         ro_args{i,2} = evalin('caller', ro_args{i,1});
      catch,
         fprintf(2, '\n  ** %s does not exist. **\n\n', ro_args{i,1});
         rethrow(lasterror);
      end;
      if ~isa(ro_args{i,2}, 'SoloParamHandle'),
         error('globals arguments must be SoloParamHandles');
      end;
   end;

   global private_solofunction_list;
   
   [mod, funclist, globals] = find_modules_funclist(owner);
   globals{1} = [globals{1} ; rw_args];
   globals{2} = [globals{2} ; ro_args];

   private_solofunction_list{mod,3} = globals;
   