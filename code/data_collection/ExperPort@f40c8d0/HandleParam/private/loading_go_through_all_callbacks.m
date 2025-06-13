% [] = loading_go_through_all_callbacks(updated_handles, owner)
%
% Helper function for load_soloparamvalues.m and load_solouiparamvalues.m 
% Arguments: 
%    updated_handles   a cell vector of SoloParamHandles whose callbacks
%                      need to be called.
%    owner             a string indicating the owner of all these SPHs
%


function [] = loading_go_through_all_callbacks(updated_handles, owner)
% Does this func really need the owner? Each SPH knows who its owner is...
% It does mean we make an owner object only once, but still.

   % First, get a list of all the callbacks. First column is number of
   % callback args.
   cback_list = cell(rows(updated_handles), 2);
   ncalls        = 0;
   for i=1:length(updated_handles), 
      cback = get_callback(updated_handles{i});
      if ~isempty(cback), % We have an explicit callback
         % First make sure cback_list has the requisite number of columns
         if cols(cback) > cols(cback_list)
            emptycell = cell(rows(cback_list), cols(cback)-cols(cback_list));
            emptycell(:) = {''};
            cback_list = [cback_list emptycell]; %#ok<AGROW>
         end;
         % Now store # of args and actual callback
         cback_list(ncalls+1:ncalls+rows(cback),1) = {cols(cback)-1};
         cback_list(ncalls+1:ncalls+rows(cback), 2:1+cols(cback)) = cback;
         ncalls = ncalls+rows(cback);
      else % Implicit callback for method with same name as SPH
         if exist([owner filesep get_name(updated_handles{i}) '*.m'], 'file'),
            ncalls = ncalls+1;
            cback_list{ncalls,1} = 0;
            cback_list{ncalls,2} = get_name(updated_handles{i});
         end;
      end;
   end;
   cback_list = cback_list(1:ncalls,:);
   if ~isempty(cback_list),
      % To save time, don't run the identical callback twice:
      [trash, I] = uniquecell(cback_list);
      % But do run them in the order in which they were found in
      % cback_list, that'll be the order in which they're declared and
      % saved in the saved structure. Thus callback order is defined by
      % SoloParamHandle declaration order.
      I = sort(I);
      cback_list = cback_list(I,:);
   end;
   %
   % Ok, now call all the callbacks...
   % First make an empty object:
   try
     if strcmp(owner(1),'@'), obj = feval(owner(2:end),  'empty');
     else                     obj = feval(owner, 'empty');
     end;
   catch
      fprintf(2, ['When a SoloParamHandle is owned by an object, ' ...
                  'that object must allow constuction with a single '... 
                  ' (''empty'') argument\n']);
      rethrow(lasterror)
   end;
   % Now call them all:
   for i=1:rows(cback_list),
     parse_and_call_sph_callback(obj, owner, '', ...
       cback_list(i,2:cback_list{i,1}+2));
   end;
   return;
   
   
