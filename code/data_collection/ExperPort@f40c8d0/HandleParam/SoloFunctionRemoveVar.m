% [] = SoloFunctionRemoveVar(sph)   Remove ALL access permission to a single sph
%
% This function removes the passed SoloParamHandle from the variable
% registries for all functions. This means that NO function will have
% access to this SoloParamHandle. Useful mostly when erasing
% SoloParamHandles. 
%
% sph may be either a single SoloParamHandle, or a cell vector containing
% SoloParamHandles; in the latter case, all SoloParamHandles in the vector
% will be removed from the registries.
%

function [] = SoloFunctionRemoveVar(sph)   
   
   global private_solofunction_list

   % Check that we have at least two columns: ownername, funclist. 
   % Otherwise there is nothing to do.
   if cols(private_solofunction_list)<2 || rows(private_solofunction_list)<1,
      return; 
   end;

   % Which modules to keep because they are still non-empty:
   keepmods = ones(rows(private_solofunction_list),1);
   for i=1:rows(private_solofunction_list),
      funclist = private_solofunction_list{i,2};
      % Which functions to keep because they are still non-empty:
      keepfuns = ones(rows(funclist),1);

      % For each function, remove sph from rw and r-o.
      for j=1:rows(funclist),
         if ~isempty(funclist{j,2}),
            funclist{j,2}  = remove_from(funclist{j,2}, sph); 
         end;
         if ~isempty(funclist{j,3}),
            funclist{j,3}  = remove_from(funclist{j,3}, sph); 
         end;
         if isempty(funclist{j,2}) & isempty(funclist{j,3}), 
            keepfuns(j) = 0; 
         end;
      end;
      % Remove functions that had nothing left
      funclist = funclist(find(keepfuns),:);

      % Now go through globals for this owner:
      if cols(private_solofunction_list)>=3,
         globals = private_solofunction_list{i,3};
         if ~isempty(globals),
            globals{1} = remove_from(globals{1}, sph);
            globals{2} = remove_from(globals{2}, sph);
         end;
         empty_globals = isempty(globals) || ...
             (isempty(globals{1}) & isempty(globals{2}));
      end;
      
      % If nothing left for the owner, we'll want to kill the owner entry
      if isempty(funclist) &&  ...
           (cols(private_solofunction_list)<=2 || empty_globals),
         keepmods(i) = 0;
      else
         % Owner still meaningful, keep updated lists:
         private_solofunction_list{i,2} = funclist;
         if cols(private_solofunction_list)>=3,
            private_solofunction_list{i,3} = globals;
         end;
      end;
   end;

   % Keep only those owners that have some entries:
   private_solofunction_list = private_solofunction_list(find(keepmods),:);

   
% -----

function [args] = remove_from(args, sph)

   if ~iscell(sph), sph = {sph}; end;
   
   if cols(args)>=2 && rows(args)>=1, 
      keep = ones(rows(args),1);
      for k=1:rows(args),        
        for s=1:length(sph),
          if isa(args{k,2}, 'SoloParamHandle')
            if is_same_soloparamhandle_nocheck(args{k,2}, sph{s}),
              keep(k)=0;
            end;
          end;
        end;
      end;
      args = args(find(keep),:); %#ok<FNDSB>
   end;
