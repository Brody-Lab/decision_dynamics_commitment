function add_cpv_RT_to_pd(ratstr)


if nargin==0
	all_rats=bdata('select distinct(ratname) from sessions where protocol="SameDifferent"');
else
	all_rats=bdata('select distinct(ratname) from sessions where ratname regexp "{S}"', ratstr);
end


for rx=1:numel(all_rats)
	do_it(all_rats{rx});
	fprintf(1,'Rat %s done, %d more to go\n',all_rats{rx}, numel(all_rats)-rx);
end



function do_it(ratname)

[sessid,pd]=bdata('select sessid,protocol_data from sessions where ratname="{S}" and protocol="{S}"',ratname, 'SameDifferent');

for sx=1:numel(sessid)
	t_pd=pd{sx};
	if ~isfield(t_pd,'totalRT')
	
	peh=get_peh(sessid(sx));
	[cpv,rtt,rtl]=get_it(peh);
	t_pd.cpoke_violations=cpv;
	t_pd.RT_to_leave=rtl;
	t_pd.totalRT=rtt;
	mym(bdata,'update sessions set protocol_data="{M}" where sessid="{S}"',t_pd, sessid(sx));
	end
end


function [cpv,rtt,rtl]=get_it(peh)

cpv=zeros(numel(peh),1);
rtt=cpv;
rtl=cpv;

for tx=1:numel(peh)
	cpv(tx)=rows(peh(tx).states.cpoke1);
	if ~isempty(peh(tx).states.cpoke1) && ~isempty(peh(tx).states.wait_for_spoke)
	rtt(tx)=peh(tx).states.wait_for_spoke(1,end)-peh(tx).states.cpoke1(end,2);
	else
		rtt(tx)=nan;
	end
	
	if isfield(peh(tx).states,'wait_for_center_nose_out') && ~isempty(peh(tx).states.wait_for_center_nose_out)
		rtl(tx)=diff(peh(tx).states.wait_for_center_nose_out(end,:));
	else
		rtl(tx)=nan;
	end
end
	
	

