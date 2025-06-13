function [] = surgery_effect_correlate_resid_hrate

area_filter ='ACx';
postpsych=1;

% STEP 1: get performance differences
[hdiff fnames grp]=surgery_effect_hrate(area_filter, postpsych);

ylim = [-20 10];
figure;
line([0 3],[0 0], 'LineStyle',':','Color', [1 1 1]*0.4);hold on;
line([1.5 1.5],ylim, 'LineStyle',':','Color', [1 1 1]*0.4);hold on;

for k = 1:length(fnames{1})
    p=plot(1,hdiff{1}(k)*100, '.k'); 
end;

for k = 1:length(fnames{2})
    p=plot(2, hdiff{2}(k)*100,'.k');
end;

if rows(hdiff{1}) > 1, hdiff{1} = hdiff{1}'; end;
if rows(hdiff{2}) > 1, hdiff{2} = hdiff{2}'; end;

mega_fnames = [ fnames{1}' fnames{2}' ];
mega_hdiff = [hdiff{1} hdiff{2}];

ylabel({'Change in % correct','(POST - PRE)'});
set(gca,'XLim',[1-0.2 2+0.2], 'XTick',[1 2], 'XTickLabel', grp,'YLim', ylim);
set(gcf,'Position',[ 213   421   266   471]);
title(area_filter);
axes__format(gca);

% STEP 2: now get residuals
[resid fnames_resid grp_resid] = surgery_effect_residuals('area_filter', 'ACx');
set(gcf,'Position',[860   421   266   471]);

if rows(resid{1}) > 1, resid{1} = resid{1}'; end; 
if rows(resid{2}) > 1, resid{2} = resid{2}'; end; 

% STEP 3: now see if the two measures have a correlation
mega_resid = sub__sortval([resid{1} resid{2}], [fnames_resid{1}' fnames_resid{2}'], mega_fnames);

r = corrcoef(mega_hdiff, mega_resid);
figure; plot(mega_hdiff, mega_resid,'.b'); xlabel('% correct change'); ylabel('residual of fitted sigmoid');

p = polyfit(mega_hdiff, mega_resid, 1);
x= [min(mega_hdiff) max(mega_hdiff)]; y = polyval(p, x);
c = corrcoef(mega_hdiff, mega_resid);

line(x,y,'Color','b');
title('''Residual'' measure versus ''(Post-Pre) %correct''');
axes__format(gca);
text(-0.01, 0.09, sprintf('r=%1.2f', c(1,2)),'FontSize', 16,'FontWeight','bold');
set(gca,'XLim', [x(1)-0.02 x(2)+0.02]);
set(gcf,'Position',[204    78   529   268],'Toolbar','none','Menubar','figure');

2;

% plot impairment value against ratname
figure;
yvals = [0 -0.05 -0.1];
for k=1:length(yvals)
line([0 length(mega_hdiff)+1], [yvals(k) yvals(k)], 'LineStyle',':','Color',[1 1 1]*0.5,'LineWidth',2); hold on;
    end;
plot(mega_hdiff,'.r', 'MarkerSize',24);
set(gca,'XLim',[0 length(mega_hdiff)+1], 'XTick', 1:length(mega_hdiff), ...
    'XTickLabel', mega_fnames);
title('Impairment levels of individual rats');
axes__format(gca);
ylabel('% change in performance');
set(gcf,'Position',  [385 628 1018 243]);
set(gca,'Position',[0.08 0.1 0.88 0.75])

2;


function [sorted] = sub__sortval(d, origfnames, fnames2sortby)

sorted = NaN(size(d));
oldidx = NaN(size(d)); newidx = NaN(size(d));
for f = 1:length(fnames2sortby)
    idx=find(strcmpi(origfnames, fnames2sortby{f}) > 0);
    sorted(f) = d(idx);
    oldidx(f) = idx; newidx(f) = f;
end;

oldidx, newidx


