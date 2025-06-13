
function tms=extract_pokes(peh,str,s)
% tms=extract_pokes(peh,str,[1 = in, 2 = out])

if nargin<3
	s=1;
end



str=upper(str);
tms = [];
for ti = 1:numel(peh)
	try
		tms = [tms; peh(ti).pokes.(str)(:,s)];
	catch

	end
end