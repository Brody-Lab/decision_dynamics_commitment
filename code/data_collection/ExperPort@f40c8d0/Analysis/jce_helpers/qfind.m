% function [ys] = qfind(x,ts)
%
% efficient finding of largest index of x for which ts >= x(i). If ts is
% smaller than the smallest element of x, then returns -1.
%
% PARAMETERS:
% -----------
%
%  x        a numeric vector, ASSUMED SORTED FROM LOW TO HIGH AND WITH NO 
%           REPEATING ELEMENTS.
%
%  ts       a vector of targets for which to perform the search. The search
%           will be performed independently for each element of ts.
%
% RETURNS:
% --------
%
% y         a vector, same length as ts. Each element of y(j) will be the
%           largest index i of x for which ts(j) >= x(i)
% 


function ys=qfind(x,ts)

ys=zeros(size(ts));

for i=1:length(ts)
    t=ts(i);
    high = length(x);  % the top end of the current interval being considered
    low = -1;          % the bottom end of the current interval being considered
    if t>=x(end)
       y=length(x);
    elseif x(1) > t
       y=-1;
    else
       try
          while (high - low > 1) % If there's still an interval range to search
             probe = ceil((high + low) / 2); % try the middle
             if (x(probe) > t)  % target is below the probe
                high = probe;
             else
                low = probe;    % target is above or equal to probe
             end
          end

          y=low;  % no more range: we're at the target
       catch
          y=low;
       end
    end

    ys(i)=y;
end
