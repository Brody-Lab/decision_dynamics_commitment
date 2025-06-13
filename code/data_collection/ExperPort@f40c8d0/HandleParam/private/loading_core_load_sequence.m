% outflag = loading_core_load_sequence(handles, owner, loaded_data, {'history', 0)
%
% Helper function for load_soloparamvalues.m and load_solouiparamvalues.m 
% Arguments:
%   handles      a cell vector of SoloParamHandles to load values for
%   owner        a string indicating the owner of all these SPHs
%   loaded_data  a struct, the result of load(filename) where filename is
%                  either a settings file or a data file
%   sets_or_data  should be a string, one of 'settings' or 'data'.
%
%
% RETURNS: 
%
% outflag=1  if success, outflag=0 if trouble. (Currently trouble
%                causes an error, so outflag=0 is never successfully
%                returned).
%

function outflag = loading_core_load_sequence(handles, owner, loaded_data, sets_or_data, varargin)

   pairs = { ...
     'prot_title_hack', ''  ; ...
   }; parseargs(varargin, pairs);
 
   if ~ismember(sets_or_data, {'settings' 'data'}),
     error('sets_or_data *must* be one of ''settings'' or ''data''');
   end;

 
   outflag=0; %#ok<NASGU>
   
   % Set value of handles that had a saved entry, return list of updated handles:
   switch sets_or_data,
     case 'settings',
       updated_handles = loading_set_soloparamhandle_values(handles, loaded_data.saved, 'settings');
       
     case 'data'
       updated_handles = loading_set_soloparamhandle_values(handles, loaded_data.saved, 'data', ...
         loaded_data.saved_history, 'prot_title_hack', prot_title_hack);
   end;
   
   % For handles that didn't have a saved value in the settings:
   unloaded_handles = setdiff_sph(handles, updated_handles);
   for i=1:length(unloaded_handles),
      % If there is a defined default reset value for the handle, this
      % function call will now set its value to that:
      restore_default_reset_value(unloaded_handles{i});
   end;

   % Ok, SoloParamHandles now have values they should have, check callbacks.
   loading_go_through_all_callbacks(updated_handles, owner);
          

   % --- check for autoset strings and set them if necessary
   if isfield('saved_autoset', loaded_data),
     loading_load_autoset_strings(loaded_data.saved_autoset, handles);
   end;
      
   % We're done successfully; return.
   outflag = 1;
   return;
   