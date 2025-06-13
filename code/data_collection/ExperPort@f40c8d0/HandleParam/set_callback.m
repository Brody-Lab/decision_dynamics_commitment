function [] = set_callback(handles, callback)
%
% Use this function to set common callbacks for a set of
% SoloParamHandles. This function is a wrapper for
% @SoloParamHandle/set_callback.m. The first parameter here, 'handles',
% can be a single SPH, or it can be a cell column vector of SPHs, in
% which case all the passed SPHs get the same callbacks.
% note: the object that owns the handle is automatically inserted as
% the first input argument
%
%
% EXAMPLE:
% --------
%
% Here LeftProb is a SoloParamHandle that belongs to the current mfile, and
% 'new_left_prob' is an action in the current mfile:
%
% 		set_callback(LeftProb, {mfilename, 'new_leftprob'});
%
% To set the same callback for two SoloParamHandles:
%
%       set_callback({LeftProb; RightProb}, {mfilename, 'new_prob'})
%

      
   if isempty(handles), return; end;
   
   if ~iscell(handles), handles = {handles}; end;
   handles = handles(:);
   
   for i=1:length(handles),
      if ~isa(handles{i}, 'SoloParamHandle'),
         error('Only know how to set callbacks for SoloParamHandles');
      end;
      set_callback(handles{i}, callback);
   end;
   
