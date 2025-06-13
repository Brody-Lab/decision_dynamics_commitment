function h = rasterHV(ref, cdtimes, cdvals, varargin) 
% function h = rasterHV(ref, cdtimes, cdvals, varargin) 
% 
% pairs = {'pre'			3; ...
% 	     'post'			3; ...
% 		 'bin'			0.10; ...
% 		 'cnd'			1; ...
% 		 'ax_handle'	[]; ...
% 		 'legend_str'	''; ...
% 		 'legend_on'    1; ...
% 		 'renderer'		'opengl'; ...
% 		 'ref_label'	'REF'; ...
% 		 'labels_on'    1; ...
% 		 'ax_height'	1; ...
% 		 'corner'		[0.1 0.1]; ...
% 		 'ax_width'		0.55; ...
% }; parseargs(varargin, pairs);
corner=[]; % corner is a matlab function in 7.12 so using parseargs breaks.

pairs = {'pre'			3; ...
	     'post'			3; ...
		 'bin'			0.10; ...
		 'cnd'			1; ...
		 'ax_handle'	[]; ...
		 'legend_str'	''; ...
		 'legend_on'    1; ...
		 'renderer'		'opengl'; ...
		 'ref_label'	'REF'; ...
		 'labels_on'    1; ...
		 'ax_height'	1; ...
		 'corner'		[0.1 0.1]; ...
		 'ax_width'		0.55; ...
         'post_mask'    +inf; ...
         'pre_mask'    -inf; ...
         'krn'          1; ...
         'clrs'         {'b','m','r','c','k','g','y',[1 0.5 0]};...
}; parseargs(varargin, pairs);

% shadeplot is broken on this machine
renderer='painters';

cdvals=imfilter(cdvals,krn);

if isscalar(pre_mask)
    pre_mask=zeros(1,numel(ref))+pre_mask;
elseif numel(pre_mask)~=numel(ref)
    fprintf(1,'numel(pre_mask) must equal num ref events or be scalar');
    return;
end


if isscalar(post_mask)
    post_mask=zeros(1,numel(ref))+post_mask;
elseif numel(post_mask)~=numel(ref)
    fprintf(1,'numel(post_mask) must equal num ref events or be scalar');
    return;
end

if isscalar(cnd)
	cnd=ones(size(ref));
end
n_cnd = unique(cnd(~isnan(cnd)));

num_trials = numel(ref);

if isempty(ax_handle),
	ax_handle = axes('Position', [corner(1) corner(2) ax_width ax_height]);
else
	set(ax_handle, 'Position', [corner(1) corner(2) ax_width ax_height]);
end;

for ci = 1:numel(n_cnd),
    this_cnd = cnd==n_cnd(ci);
	[y x] = cdraster(ref(this_cnd), cdtimes, cdvals, pre, post, bin);
    [y x] = maskraster(x,y,pre_mask(this_cnd),post_mask(this_cnd));
	
	good = ~all(isnan(y),2);
	y = y(good,:);
	sampz = rows(y);
	
	if isempty(y),
		ymn(ci,:) = zeros(size(x));
		yst(ci,:) = zeros(size(x));
    else
            
		ymn(ci,:) = nanmean(y,1);
		yst(ci,:) = nanstderr(y,1);
	end;
	
	% plot the averaged trace
	axes(ax_handle); hold on;
	
	if strcmpi(renderer, 'opengl'),
		shadeplot(x, ymn(ci,:)-yst(ci,:), ymn(ci,:)+yst(ci,:), {clrs{ci},ax_handle,0.7});
	else
		hh(1) = line(x, ymn(ci,:), 'LineWidth', 2);
	%	hh(2) = line(x, ymn(ci,:)-yst(ci,:));
	%	hh(3) = line(x, ymn(ci,:)+yst(ci,:));
		set(hh, 'Color', clrs{ci});
	%	set(hh(2:3), 'LineStyle', '--', 'LineWidth', 0.5);
	end;
	
	set(gca, 'XLim', [-pre,post], 'YLim', [-300 300]);
	
	legstr{ci} = [num2str(n_cnd(ci)) ', n=' num2str(sampz)];
end;

if legend_on,
	[lh, oh] = legend(legstr);
	set(lh, 'Position', [0.73 0.1 0.2 0.15]);
	for ci=1:numel(n_cnd)
		if strcmpi(renderer,'opengl')
			ch=get(oh(numel(n_cnd)+ci),'Children');
			set(ch,'FaceColor',clrs{ci})
		else
			set(oh(numel(n_cnd)+(2*ci-1)),'Color',clrs{ci},'LineStyle','-','LineWidth',2);
		end
	end
end;

hold off;

if labels_on,
	xlabel(['Time from ' ref_label '(sec)']);
	ylabel('^{\circ}/s \pm se');
end;

h = ax_handle;

