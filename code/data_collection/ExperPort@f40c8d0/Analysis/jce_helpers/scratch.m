keep=zeros(size(n));
n=fieldnames(saved_history);
for nx=1:numel(n)
	if isempty(saved_history.(n{nx}))
		%toss
	elseif isa(saved_history.(n{nx}){1},'float')
		keep(nx)=1;
	end
end


mysqlstr1='create table ProAnti2 (sessid int not null, trial_n int(6) not null, '; 
	
mysqlstr=[];
fx=find(keep==1);
for fi=1:sum(keep)
	col_name=n{fx(fi)};
	mysqlstr=[mysqlstr ' ' col_name ' float,'];
end

mysqlstr2='primary key (sessid)) ENGINE=MyISAM;';




% %%
% peh=get_sphandle('name','parsed_events');
% peh=get_history(peh{1});
% psds=get_sphandle('name','sides_history');
% psds=value(psds{1});
% pp=zeros(size(psds));
% pp(psds=='l')=-1;
% pp(psds=='r')=1;
% pp=pp(2:end-1);
% pokes=ones(size(peh));
% s_pokes=pokes;
% sorta_c=zeros(size(peh));
% for xi=1:numel(peh)
% 
% [pokes(xi), poke_time]=find_first_poke(peh{xi}.states.var_gap2(1,:), peh{xi}.pokes);	
% [s_pokes(xi), poke_time]=find_first_poke(peh{xi}.states.wait_for_spoke(1,:), peh{xi}.pokes);
% % if poke==pp(xi)
% % 	sorta_c(xi)=1;
% % end
% end
% 
% %%
% 
% % pp 234   what the rat was supposed to do
% % hh 233   
% % pokes 232 what the rat did
% 
% figure;
% plot(pokes.*(hh(1:end-1)*2-1)-pp(1:end-2),'.')


%%


% 
%  [beta(:,1), beta(:,2), M(:,1),M(:,2),M(:,3)]=mym('select beta," ",cellid, p, r from st_stats where shft<0 and cellid in (select id from labeh.lac100 where type!="HAB")');
%   b=beta';           
%   b=reshape(b, 1, numel(b));
%   b=str2num([b{:}])'
% 
% 
% lacssi=mym('SELECT si FROM stsi_sine where id <500 and type!="HAB" and shft=0 and wndw=1.5E6 and smooth=0');
% lapresi=mym('SELECT si FROM stsi_sine where id <500 and type!="HAB" and shft<0 and wndw=1.5E6 and smooth=0');
% dt=lacssi-lapresi;
% dt=dt(~isnan(dt));
% [t1,t2,t3,t4]=ttest(dt)
% 
% 
% [r,phi]=mym('select r,phi from stsi_sine where smooth=0 and shft=0 and wndw=2E6 ')
% 
% 
% x=-pi/2:0.1:pi/2;
% 
% r=5*randn(1)+5*randn(1)*i;
% 
% p=angle(r);
% m=abs(r);
% y1=real(r)*cos(x)-imag(r)*sin(x);
% y2=m.*cos(x+p);
% subplot(2,1,1)
% plot(x,y1,'o')
% hold on 
% plot(x,y2,'-')
% title(ns(p))
% hold off
% subplot(2,1,2)
% vplot(r,'-o');
% hold off
% title(ns(p))
% 
% 


% 
