% [sp] = add_callback(sp, callback)      Add a callback for a SoloParam.
%
% If the SoloParam had no callbacks in its list, creates a list. If a list
% exists already, all callbacks in it, including the new one being added,
% must have the same number of args.
%

function [sp] = add_callback(sp, callback)

   if isempty(sp.callback_fn),
      sp = set_callback(sp, callback);
      return;
   end;
   
   if ~iscell(callback),       callback = {callback};             end;
   if ~iscell(sp.callback_fn), sp.callback_fn = {sp.callback_fn}; end; 

   if size(sp.callback_fn,2) ~= size(callback,2)
      error(['Can only add callbacks with same number of args as those ' ...
             'previously defined.']);
   end;
   
   sp.callback_fn = [sp.callback_fn ; callback];

   