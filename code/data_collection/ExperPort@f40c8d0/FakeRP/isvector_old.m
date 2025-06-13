% isvector(x)	returns length if x is either a row or column vector, 0 else
%
% This function conflicts with a built in matlab function and appears to
% have the same behavior. Therefore it is being renamed _old to remove the
% conflict. -Chuck 2020-03-18

function [a] = isvector_old(x)
	if iscolumn(x)
		a = size(x,1);
	elseif isrow(x)
		a = size(x,2);
	else
		a = 0;
	end;
	
