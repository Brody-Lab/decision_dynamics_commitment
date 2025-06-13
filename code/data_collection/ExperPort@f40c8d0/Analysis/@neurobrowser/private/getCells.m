function [str]=getCells(sess)

	x=bdata('select cellid from cells where sessid="{Si}"',sess);
	str={''};
	for xi=1:numel(x)
		str{xi}=num2str(x(xi));
	end
	
