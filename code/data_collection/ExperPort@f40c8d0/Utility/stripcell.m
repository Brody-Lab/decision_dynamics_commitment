function out = stripcell(c)
% OUT = STRIPCELL(C)
% Get rid of singleton cell dimensions.
% Isn't working except for case of 1x1 input.

	if size(c,1) == 1 & size(c,2) == 1 & iscell(c)
		out = c{1,1};
	else
		out = c;
	end
