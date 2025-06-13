
function tms=extract_state(peh,str,s)

if nargin<3
	s=1;
end


tms=zeros(numel(peh),1);
for ti=1:numel(peh)
	try
		tms(ti)=peh(ti).states.(str)(s);
	catch
		tms(ti)=nan;
	end
end

