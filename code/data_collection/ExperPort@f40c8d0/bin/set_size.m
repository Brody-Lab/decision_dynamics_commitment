%set_size.m   [newpos] = set_size(obj, [width height])
%
% Given a graphics object obj, changes its width and size without
% changing its lower left-hand corner position. Returns the new
% position, in format [x y width height] where x and y are the coords
% of the lower lefthand corner
%
%

% CDB Sep05

function [nnewpos] = set_size(obj, size)
   
   oldpos = get(obj, 'Position');
   newpos = [oldpos(1:2) size];
   set(obj, 'Position', newpos);
   
   if nargout > 0, nnewpos = newpos; end;
   
   