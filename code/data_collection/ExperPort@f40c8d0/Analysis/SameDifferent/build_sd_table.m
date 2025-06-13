function estr=build_sd_table(f)

uiopen('LOAD');

n=fieldnames(saved_history);

keep=zeros(size(n));
for nx=1:numel(n)
	if isempty(saved_history.(n{nx}))
		%toss
	elseif isa(saved_history.(n{nx}){1},'float')
		keep(nx)=1;
	end
end


mysqlstr1='create table protocol.samedifferent (sessid int not null, trial_n int(6) not null, ProtocolsSection_parsed_event blob, '; 
	
mysqlstr=[];
fx=find(keep==1);
for fi=1:sum(keep)
	col_name=n{fx(fi)};
	mysqlstr=[mysqlstr ' ' col_name ' float,'];
end

mysqlstr2='primary key (sessid,trial_n)) ENGINE=MyISAM;';


estr=[mysqlstr1 mysqlstr  mysqlstr2];