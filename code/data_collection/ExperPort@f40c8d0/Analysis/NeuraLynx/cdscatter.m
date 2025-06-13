function [y, x, t] = cdscatter(ref, cdtimes, cdvals, pre, post)
% [y, x, t] = cdscatter(ref, cdtimes, cdvals, pre, post, bin)
%
% Returns the values of cdtimes and cdvals that are within the window specified by [-pre post]
% 
% x is a column vector specifying the times relative to ref of each value
%   in y
% y is a column vector of the values of cdvals within the window specified relative to ref
% t is a column vector specifying which element of ref was associated with
%   the specific x and y values.
% 
% all times should be in seconds
%
% Example:
% ref = time of center nose out.
% ts  = timestamps of head direction data
% theta = head direction data
% [x,y,t]=cdscatter(ref, ts, theta, 2, 2);
% plot(x,y,'.');
%
% see also cdraster



if length(cdtimes) ~= length(cdvals),
    y = [];
    x = [];
    return;
end



[xc xi]=qbetween(cdtimes, ref-pre, ref+post, ref);

if numel(ref)==1
    xc={xc};
    xi={xi};
end

x=[];
y=[];
t=[];

for tx = 1:numel(ref),
    x=[x; xc{tx}(:)];
    tY=cdvals(xi{tx});
    y=[y; tY(:)];
    t=[t; zeros(numel(xc{tx}),1)+tx];

end