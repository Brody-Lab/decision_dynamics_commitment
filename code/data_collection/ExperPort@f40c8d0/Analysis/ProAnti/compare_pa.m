function y=compare_pa(a,b,expr,n_days)
% y = compare_pa(group1, group2, n_days)
% group1 and group2 should be cell arrays of strings of ratnames

h=figure;

for aind=1:numel(a)
	a_data=pa_analyze(a{aind}, expr, n_days,'tau',2,'fignum',h);
	ed=extract_lc(a_data);
	lca{aind}=ed;
end

for bind=1:numel(b)
	b_data=pa_analyze(b{bind}, expr, n_days,'tau',2,'fignum',h);
	ed=extract_lc(b_data);
	lcb{bind}=ed;
end

clf;

da=plot_summary(lca,'b',h, 'sham');
db=plot_summary(lcb,'r',h, 'lesion');
	
% [a,b,c,d]=ttest(da,db);
% stat_str=sprintf('%s %s %s %s',a,b,c,d);
% text(100,100,stat_str);

function dp=extract_lc(x)

hits=x(:,1,5);
for dind=1:numel(hits)
	dp(dind)=nanmean(cell2mat(hits{dind}));
end


function d=plot_summary(d,colr,fig,leglab)

figure(fig);
hold on
for di=1:numel(d)
	plot(d{di},colr);
end

