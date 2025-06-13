function [ob] = pbups_observer(left, right, sample)
% inputs:
% left = times (in sec) of bups on the left
% right = times of bups on the right
% sample = time (in sec) the stimulus was played
%
% output:
% based on the sample duration, the left/right discrimination based on an
% ideal observer that is able to count bups on either side
% -1 means left, +1 means right

l = sum(left <= sample);
r = sum(right <= sample);
if l > r,     ob = -1;
elseif r > l, ob = 1;
else          
	l = diff(left(left<=sample));
	r = diff(left(right<=sample));
	if isempty(l) || mean(l) == mean(r),
		ob = 0;
	elseif mean(l) < mean(r),
		ob = -1;
	elseif mean(r) > mean(l),
		ob = 1;
	end;
end;
return;
