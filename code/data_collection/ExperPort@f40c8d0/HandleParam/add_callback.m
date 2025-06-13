function [] = add_callback(handles, callback)
%
% Use this function to add common callbacks for a set of
% SoloParamHandles. This function is a wrapper for
% @SoloParamHandle/add_callback.m. The first parameter here, 'handles',
% can be a single SPH, or it can be a cell column vector of SPHs, in
% which case all the passed SPHs get the same callbacks added.
%

      
   if isempty(handles), return; end;
   
   if ~iscell(handles), handles = {handles}; end;
   handles = handles(:);
   
   for i=1:length(handles),
      if ~isa(handles{i}, 'SoloParamHandle'),
         error('Only know how to set callbacks for SoloParamHandles');
      end;
      add_callback(handles{i}, callback);
   end;
   
