function ax_handle=psthplot(ev, ts, varargin)
% ax_handle=psthplot(ev, ts, varargin)
% pairs={'pre'        2;...
%        'post'       2;...
%        'binsz'      0.010;...
%        'cnd'        [];...
%        'meanflg'    0;...
%        'krn'        0.1;...
%        'ax_handle'  figure;...
%        'legend_lab' '';...
%        'renderer', 'opengl';...
% }; 

pairs={'pre'        2;...
       'post'       2;...
       'binsz'      0.010;...
       'cnd'        1;...
       'meanflg'    0;...
       'krn'        0.1;...
       'ax_handle'  figure;...
       'legend_str' '';...
       'renderer', 'opengl';...
}; parseargs(varargin,pairs);


set(gcf, 'Renderer',renderer);

set(gcf,'Color','w')
hold on


if isscalar(krn)
	dx=ceil(3*krn/binsz);
    krn=normpdf(-dx:dx,0,krn/binsz);
	krn(1:dx)=0;
	krn=(krn)/sum(krn);
end


clrs={'r','b','m','g','b','r','g','m'};

n_cnd=unique(cnd(~isnan(cnd)));

for ci=1:numel(n_cnd)
	sampz=sum(cnd==n_cnd(ci));
	[y,x]=rasterplot(ev(cnd==n_cnd(ci)),ts,pre,post,binsz);
	ymn(ci,:) = mean(jconv(krn,y/binsz));
	yst(ci,:)=stderr(jconv(krn,y/binsz));

	hh=plot(x,ymn(ci,:),clrs{ci});
	set(hh,'LineWidth',2);
	if ~isempty(legend_str)
		legstr{ci}=[legend_str{ci} ', n=' num2str(sampz)];
	else
		legstr{ci}=[num2str(n_cnd(ci)) ', n=' num2str(sampz)];
	end
end

legend(legstr);


if ~meanflg,
    for ci=1:numel(n_cnd)


        shadeplot(x,ymn(ci,:)-yst(ci,:),ymn(ci,:)+yst(ci,:),{clrs{ci},[],.6});

    end
end;
hold off
set(gca,'FontSize',20);

xlabel('Time from {\bfREF}  in Seconds')
ylabel('Firing Rate (Hz \pm Std. Err.)')
