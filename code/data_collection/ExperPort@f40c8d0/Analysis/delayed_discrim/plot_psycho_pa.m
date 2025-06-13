function [y,x]=plot_psycho_pa(pd)

midpoint=100;
do_plot=1;

x=unique(pd.poke1sound_freq);
for xi=1:numel(x)
%	pd.gotit(isnan(pd.gotit))=0;
	y(xi)=nanmean(pd.gotit(pd.poke1sound_freq==x(xi)));
	if x(xi)<midpoint
		y(xi)=1-y(xi);
	end
end

if do_plot
	figure; 
	plot(x,y,'x-');
	xlabel('Bup Freq');
	ylabel('% reported high'); 
end



