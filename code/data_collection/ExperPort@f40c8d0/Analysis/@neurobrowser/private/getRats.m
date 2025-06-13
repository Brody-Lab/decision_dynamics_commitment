function [x]=getRats(expr,op)
try
if ~op
	% get all experimenters
	
	[recent_rats]=bdata('select distinct(ratname) from sessions where experimenter="{S}" and sessiondate>date_sub(now(),interval 30 day) order by ratname',expr);
 	all_rats=bdata('select ratname from ratinfo.rats where experimenter="{S}" and ratname regexp "^[A-Z]"',expr);
% 	keeps=zeros(size(ratname))==1;
% 	for rx=1:numel(ratname)
% 		if isempty(ratname{rx}) || ~isempty(regexp(ratname{rx}(1),'[0-9]'))
% 			keeps(rx)=false;
% 		else
% 			sessid=bdata('select sessid from sessions where ratname="{S}" limit 1',ratname{rx});
% 			if isempty(sessid)
% 				keeps(rx)=false;
% 			else
% 				keeps(rx)=true;
% 			end
% 		end
% 	end
% 	
% 	
% 	
% 	all_rats=ratname(keeps);
% 	
	
	old_rats=setdiff(all_rats, recent_rats);
	x=[recent_rats; old_rats];
	
else
	[x]=bdata('select distinct(ratname) from cells where ratname in (select ratname from ratinfo.rats where experimenter="{S}") order by ratname',expr);
end
catch
    x={' '};
end

