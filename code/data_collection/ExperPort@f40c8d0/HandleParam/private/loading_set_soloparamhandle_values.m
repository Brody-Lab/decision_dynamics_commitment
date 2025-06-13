% [updated_handles] = loading_set_soloparamhandle_values(handles, saved, sets_or_data, [saved_history])
%
% Helper function for load_soloparamvalues.m and load_solouiparamvalues.m 
%
% PARAMS:
% -------
%
% handles should be a cell vector; each of its elements should be an
%     @SoloParamHandle object. These should be all the SoloParamHandles that
%     belong to the owner that is trying to load values and that should be
%     loaded up in a load settings call.
%
% saved should be a structure; keys should correspond to fullnames of
%     SoloParamHandles, and their values will be the values that were saved
%     and that those SoloParamHandles will now acquire.
%
%
% sets_or_data  should be a string, one of 'settings' or 'data'.
%
% OPTIONAL PARAM saved_history should be struct
%
% RETURNS:
% --------
%
% updated_handles, a cell vector containing all those SoloParamHandles
%     that had a value that was loaded. This is intended for use later in
%     seeing which SoloParamHandles have their callback called.
%


function [updated_handles] = loading_set_soloparamhandle_values(handles, saved, ...
  sets_or_data, saved_history, varargin)

   pairs = { ...
     'prot_title_hack', ''  ; ...
   }; parseargs(varargin, pairs);


   if ~ismember(sets_or_data, {'settings' 'data'}),
     error('sets_or_data *must* be one of ''settings'' or ''data''');
   end;

   updated_handles = {}; % A list of handles that had their values
                         % updated. This may be used later for
                         % calling all the corresponding callbacks. 
   for hi=1:length(handles),
     if get_saveable(handles{hi})  % only if this SPH is saveable
       sph_fullname=get_fullname(handles{hi});
       if ~isfield(saved, sph_fullname),  % If we don't have a saved value, warn the user
         warning('Solo:LoadUI:NewSPH', ['You created a new handle ("%s") since these settings\n' ...
           'were saved, no setting for it can be loaded.'], get_fullname(handles{hi}));
       else
         try
           oldvalue = value(handles{hi});
           handles{hi}.value = saved.(sph_fullname);            
           % --- Following is old code For Shraddha protocols with special
           % SPH named 'prot_title'. This code is deprecated and will be
           % phased out. A much better way is to simply store the date with
           % prot_title.
           if ~isempty(prot_title_hack)  &&  length(sph_fullname) > 9  ...
               &&  strcmpi(sph_fullname(end-9:end),'prot_title')
             handles{hi}.value = [saved.(sph_fullname) ': ' prot_title_hack];
           end;
           % --- end special code (comment by CDB.)
           
           if ~isequal(oldvalue, value(handles{hi})) || get_callback_on_load(handles{hi}), 
             updated_handles = [updated_handles ; handles(hi)];
           end;
           
         catch % In case the handle couldn't be loaded up for some reason:
           last_error=lasterror;
           fprintf(2, '\n\n   *** Warning! ***\n  Last error was %s\n', last_error.message);
           fprintf(2, ['Couldn''t set the value of "%s" while loading:\n' ...
             'you''ll have to set it yourself, manually.\n'], sph_fullname);
           if ischar(saved.(sph_fullname)),
             fprintf(2, '  Intended value was "%s"\n\n', saved.(sph_fullname));
           elseif isnumeric(saved.(sph_fullname)),
             fprintf(2, '  Intended value was %g\n\n', saved.(sph_fullname));
           end;
           fprintf(2, 'The error message was "%s"\n\n\n', lasterr);
         end;
       end
     elseif get_callback_on_load(handles{hi}),
       updated_handles = [updated_handles ; handles(hi)];
     end;
     
     if strcmp(sets_or_data, 'data') && isfield(saved_history, sph_fullname),
       set_history(handles{hi}, saved_history.(sph_fullname));
     end;
   end
          
   return;
   
