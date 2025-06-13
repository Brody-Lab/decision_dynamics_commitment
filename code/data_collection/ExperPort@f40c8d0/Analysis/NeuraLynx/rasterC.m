function [ras,R]=rasterC(ev, ts,varargin)
% ax_handle=rasterC(ev, ts, varargin)

% pairs={'pre'        3;...
%        'post'       3;...
%        'binsz'      0.050;...
%        'cnd'        1;...
%        'meanflg'    0;...
%        'krn'        0.25;...
%        'ax_handle'  [];...
%        'legend_str' '';...
%        'renderer', 'opengl';...
%        'ref_label', 'REF';...
%        'psth_height', 0.248;...
%        'total_height' 0.8;...
%        'corner'       [0.1 0.1];...
%        'ax_width'      0.55;...
% 	   'font_name'	   'Helvetica';...
% 	   'font_size'		9;...
% 	   'legend_pos'     [0.73 0.1 0.2 0.15];...
% 	   'clrs'	{'c','b','r','m','r','g','m'};...
% 	   'x_label','';...

pairs={'pre'        3;...
	'post'       3;...
	'binsz'      0.050;...
	'cnd'        1;...
	'meanflg'    0;...
	'krn'        0.25;...
	'ax_handle'  [];...
	'legend_str' '';...
	'renderer', 'opengl';...
	'ref_label', 'REF';...
	'psth_height', 0.248;...
	'total_height' 0.8;...
	'corner'       [0.1 0.1];...
	'ax_width'      0.55;...
	'font_name'	   'Helvetica';...
	'font_size'		9;...
	'legend_pos'     [0.73 0.1 0.2 0.15];...
	'clrs'	{'c','b','r','m','r','g','m'};...
	'x_label','';...
	}; parseargs(varargin,pairs);


set(gcf, 'Renderer',renderer);


if isscalar(krn)
	dx=ceil(3*krn/binsz);
	krn=normpdf(-dx:dx,0,krn/binsz);
	krn(1:dx)=0;
	krn=(krn)/sum(krn);
end


n_cnd=unique(cnd(~isnan(cnd)));
raster_height=total_height-psth_height;
y_ind=psth_height+corner(2)+0.005;
num_trials=numel(ev);
height_per_trial=raster_height/num_trials;
psthax=axes('Position',[corner(1) corner(2) ax_width psth_height]);
set(psthax,'FontName',font_name);
set(psthax,'FontSize',font_size)

if numel(cnd)==1
	cnd=ones(size(ev));
end

for ci=1:numel(n_cnd)
	sampz=sum(cnd==n_cnd(ci));
	[y,x]=tsraster(1000*ev(cnd==n_cnd(ci)),ts*1000,(1+pre)*1e3,(1+post)*1e3,binsz*1e3);
	[y2,x2]=tsraster2(ev(cnd==n_cnd(ci)),ts,(pre)*1e3,(post*1e3),0);
	ras(ci)=axes('Position',[0.1 y_ind 0.55 height_per_trial*sampz]);
	y_ind=y_ind+height_per_trial*sampz+0.001;
	R{ci}={y x};
	%% Plot the rasters
	ll=line(x2/1000,y2);
	set(ll,'color','k');
	set(gca,'XTickLabel',[]);
	set(gca,'YTick',[]);
	set(gca,'Box','off')
	set(gca,'YLim',[0 max(y2)])
	set(gca,'XLim',[-pre post]);
	
	ll=line([0 0],[0 max(y2)]);
	set(ll,'LineStyle','-','color',clrs{ci},'LineWidth',2);
	
	%% Calculate the mean and ci of the
	ymn(ci,:) = mean(jconv(krn,y/binsz));
	yst(ci,:)=stderr(jconv(krn,y/binsz));
	
	axes(psthax);
	hold on
	%     hh=line(x/1000,ymn(ci,:));
	% 	set(hh,'LineWidth',1,'LineStyle','-','Color',clrs{ci});
	if strcmpi(renderer,'opengl')
		sh(ci)=shadeplot(x/1000,ymn(ci,:)-yst(ci,:),ymn(ci,:)+yst(ci,:),{clrs{ci},psthax,0.3});
		lh=line(x/1000,ymn(ci,:),'Color',clrs{ci},'LineWidth',2);
	else
		hh(1)=line(x/1000,ymn(ci,:)-yst(ci,:));
		hh(2)=line(x/1000,ymn(ci,:)+yst(ci,:));
		set(hh,'LineWidth',1,'LineStyle','-','Color',clrs{ci});
		sh(ci)=hh(1);
	end
	set(gca,'XLim',[-pre,post]);
	
	legstr{ci}=[num2str(n_cnd(ci)) ', n=' num2str(sampz)];
	
end

xticks=get(psthax,'XTick');
set(psthax,'XTick',xticks);
set(ras,'XTick',xticks);


[lh,oh]=legend(sh,legend_str);
legend boxoff
% keyboard
set(lh,'Position',legend_pos);

hold off
%set(gca,'FontSize',36);
if isempty(x_label)
	xlabel(['Time from ' ref_label '(sec)'])
else
	xlabel(x_label);
end
ylabel('Hz \pm SE')
ras(end+1)=psthax;
