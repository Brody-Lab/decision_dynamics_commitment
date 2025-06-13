% [] = move(sphs, x, y)    Moves SoloParamHandles by a specified number of pixels in x and y. Both
%  the GUI and the label move, together. 
%
% sphs should be a cell, with all of its elements being SoloParamHandles.
% All of the SoloParamHandles in sphs will mvoe the same amount.
%

function [] = move(sphs, x, y)

if ~iscell(sphs), error('sphs should be a cell'); end;

sphs = sphs(:);
for i=1:numel(sphs),
   if isa(sphs{i}, 'SoloParamHandle')
      move(sphs{i}, x, y);
   end;
end;
