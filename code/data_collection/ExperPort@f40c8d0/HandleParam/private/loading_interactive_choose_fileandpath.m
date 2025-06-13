% [fullname] = loading_interactive_choose_fileandpath(fullname, owner, experimenter, ratname, ...
%                 ['settings'|'data'])
%
% Given a default fullname (full path plus filename), an owner (string object
% that is loading handles), an experimenter name (which may be empty), and
% a ratname, puts up a dialog with the user to choose fullname.
%
% Last parameter MUST be one of the string 'settings' or the string 'data'.
%
% RETURNS a string with a fullname of a chosen file, or zero if the user
% clicked cancel.
% 



function [fullname] = loading_interactive_choose_fileandpath(fullname, owner, experimenter, ...
  ratname, sets_or_data)

   % if experimenter is empty, filenames will be of the form "settings_@protocolobj_ratname_YYMMDDz.mat"
   % Otherwise they will be of the form "settings_@protocolobj_experimentername_ratname_YYMMDDz.mat"
   if isempty(experimenter),  experimenter = '';
   else                       experimenter = [experimenter '_'];
   end;

   if ~ismember(sets_or_data, {'settings' 'data'}),
     error('sets_or_data *must* be one of ''settings'' or ''data''');
   end;
   
   rn = [experimenter ratname];
   [fname, pname] = ...
     uigetfile({[sets_or_data '_' owner '*' rn '*.mat'], ...
     [sets_or_data '_' owner ' ' rn ' files (' owner '*' rn '*.mat)'] ; ...
     ['*' rn '*.mat'], [rn ' files (*' rn '*.mat)'] ; ...
     ['*' owner '*.mat'], [owner ' files (*' owner '*.mat)'] ; ...
     '*.mat',  'All .mat files (*.mat)'}, ...
     ['Load ' sets_or_data], fullname);

   drawnow;
   if fname == 0, fullname = 0; return; end;

   fullname = [pname fname];
   return;
   