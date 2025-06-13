
function [] = hsvplay

 sub__plotclrmap();

 
% cmap = colormap;
% blue = cmap(floor(0.6*length(cmap)),:);
% yellow = cmap(floor(0.2*length(cmap)),:);
% patch([0 0 1 1], [1 2 2 1], [blue(1) 1 1]);
% patch([0 0 1 1], [2 3 3 2], yellow);
% patch([0 0 1 1], [3 4 4 3], mean([blue;yellow]));

fig1=figure;colormap hsv; cmap1 = colormap;
fig2=figure;colormap hsv; cmap2 = colormap;
fig3=figure;colormap hsv; cmap3 = colormap;



colormap hsv;
cmap = colormap;

for c = 1:5
    for r = 1:5
        bidx = 43;      
        a = [cmap(bidx,1) 1-(0.2*c) 1];  % blue saturation changes across columns
        yelidx = 11;
        b = [cmap(13,1) 1 1-(0.2*c)]; % yellow
        x = mean([a;b]);
        x(1) = 0.8*((a(1)+b(1))/2); x(3)=max(0,x(3)-0.5);
       
        set(0,'CurrentFigure',fig1); patch([r r r+1 r+1], [c c+1 c+1 c], a); % blue
        set(0,'CurrentFigure',fig2); patch([r r r+1 r+1], [c c+1 c+1 c], b); % yellow
        set(0,'CurrentFigure',fig3); patch([r r r+1 r+1], [c c+1 c+1 c], x); % green
    end;
end;

 set(0,'CurrentFigure',fig1);set(fig1,'Position',[200 200 200 200],'Menubar','none','Toolbar','none'); title('Blue');
 set(0,'CurrentFigure',fig2);set(fig2,'Position',[500 200 200 200],'Menubar','none','Toolbar','none'); title('Yellow');
 set(0,'CurrentFigure',fig3);set(fig3,'Position',[800 200 200 200],'Menubar','none','Toolbar','none');title('Green');

xlabel('Value (brightness)');
ylabel('Saturation');

function [] = sub__plotclrmap()
figure;
colormap hsv; cmap = colormap;
for k = 1:rows(cmap)
    patch([k k k+1 k+1], [0 1 1 0], cmap(k,:));
    hold on;
end;
set(gca,'XTick', 1.5:1:rows(cmap)+0.5,'XTickLabel', 1:rows(cmap), 'YTick',[],...
    'Position',[0.01 0.25 0.95 0.75],'XLim', [1 rows(cmap)+1]);
title('Colormap');
set(gcf,'Position', [100 100 1200 50],'Menubar','none','Toolbar','none');