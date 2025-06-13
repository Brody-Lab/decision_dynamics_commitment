%msegment_finder  [S] = msegment_finder(u) Find arbitrary segs in u
%
% Given a vector u, finds all segments of constant values in
% it. Returns these as a nsegments-by-3 matrix S. Each row of S
% corresponds to one segment (they are in sequential order
% w.r.t. occurrence of segments in u). The first column is the
% starting bin in u, the second column is the ending bin of the
% segment in u, and the third column is the value of the segment.
%
% EXAMPLE:
%
% The vector [1 1 3 3 3 1 1 2]
%
% would produce
%
%   S = [1 2 1 ; ...
%        3 5 3 ; ...
%        6 7 1 ; ...
%        8 8 2];
%

% Carlos Brody July 03


function [S] = msegment_finder(v)
   
   if isempty(v), S = []; return; end;
   
   u = find(diff(v));
   if isempty(u), S = [1 length(v) v(1)]; return; end;
   
   S = zeros(length(u)+1, 3);
   S(1,1) = 1;
   S(1,2) = u(1);
   S(1,3) = v(1);
   for i=2:length(u),
      S(i,1) = u(i-1)+1;
      S(i,2) = u(i);
      S(i,3) = v(u(i-1)+1);
   end;
   S(end,1) = u(end)+1;
   S(end,2) = length(v);
   S(end,3) = v(u(end)+1);
   return;
   
   u = find(v);
   if isempty(u), S = zeros(0, 2); return; end;
   breaks = find(diff(u) ~= 1);
   if isempty(breaks), 
      S = [u(1) u(end)];
      return; 
   end;
   
   S = zeros(length(breaks)+1,2);
   S(1,1) = u(1); S(1,2) = u(breaks(1));
   for i=2:length(breaks),
      S(i,1) = u(breaks(i-1)+1);
      S(i,2) = u(breaks(i));
   end;
   S(end,1) = u(breaks(end)+1);
   S(end,2) = u(end);
   
