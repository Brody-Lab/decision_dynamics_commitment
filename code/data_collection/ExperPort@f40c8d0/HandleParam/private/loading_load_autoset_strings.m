%   [] = loading_load_autoset_strings(saved_autoset, handles)
%
% Helper function for load_soloparamvalues.m and load_solouiparamvalues.m 
% Args:
%
% saved_autoset is a structure; each key is a fullname of a
%    SoloParamHandles, and each corresponding value is its desired autoset
%    string.
%
% handles is a full list of SoloParamHandles that belong to the owner for
%    whom settings are currently being loaded.
%
%

function [] = loading_load_autoset_strings(saved_autoset, handles)

   for i=1:length(handles),
     fullname = get_fullname(handles{i});
     
     if isfield(saved_autoset, fullname),
       autoset_string = strtrim(saved_autoset.(fullname));
       set_autoset_string(handles{i}, autoset_string);
       if isempty(autoset_string),
         RegisterAutoSetParam(handles{i}, 'delete');
       else
         RegisterAutoSetParam(handles{i}, 'add');
       end;
     end;
   end;
