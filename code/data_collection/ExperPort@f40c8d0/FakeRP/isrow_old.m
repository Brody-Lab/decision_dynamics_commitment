% isrow(x)		returns 1 if x is a row vector, 0 otherwise
%
% This function conflicts with a built in matlab function and appears to
% have the same behavior. Therefore it is being renamed _old to remove the
% conflict. -Chuck 2020-03-18

function [a] = isrow_old(x)
	if ( size(x,1) == 1 )
		a = 1;
	else
		a = 0;
	end;
