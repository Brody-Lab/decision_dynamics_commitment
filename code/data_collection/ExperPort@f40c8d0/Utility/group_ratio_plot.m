function [mix_pred, mix_resp, res_cat] = group_ratio_plot(blob,trial_range)

% 1    
% 2   mix100_0
% 3   mix80_20
% 4   mix60_40
% 5   mix40_60
% 6   mix20_80
% 7   mix0_100
% 8   mix0_20
% 9   mix0_40
% 10   mix0_60
% 11   mix0_80
% 12   mix80_0
% 13   mix60_0
% 14   mix40_0
% 15   mix20_0
% 16   blank
% 17   mix200_0
% grm = [2 3 4 5 6 7];
% grc = [16 8 9 10 11 7];
% grh = [16 15 14 13 12 2];

global exper

if nargin == 0
    errordlg('Please enter blob number')
end

grm = [2 3 4 5 6 7];
grc = [16 8 9 10 11 7];
grh = [16 15 14 13 12 2];

g_list = exper.group.param.group.list;
% g_list = g_list([16 8 9 10 11 2 3 4 5 6 7 12 13 14 15]);
g_trial = exper.sequence.param.group.trial;
trial_length = length(exper.blob.roi(1).ratio);

if nargin < 2
    trial_range = 1:trial_length;
end

% figure;
x = [];
y = [];
gg = [grh grm fliplr(grc)]
xx = zeros(1,length(trial_range));
for i = 1:length(g_list)
    g = g_list{i};
    
    for t = trial_range
        if strcmp(g,g_trial{t})
            x = [x i];
            y = [y exper.blob.roi(blob).ratio(t)];
            
            xx(t) = i;
        end
    end
end

xx(find(xx==0)) = max(xx)+1;
figure;
plot(xx,exper.blob.roi(blob).ratio*(-1),'o'); hold on
ax = axis;
plot([ax(1) ax(2)],[0 0],':')


% judge what type of response
% 0, no response; 1, renponded to A;  2, responded to B;  3, responded to both
% 2   mix100_0
% 7   mix0_100
% 16   blank

res_A = exper.blob.roi(blob).ratio(find(xx == 2));
res_B = exper.blob.roi(blob).ratio(find(xx == 7));
res_blank = exper.blob.roi(blob).ratio(find(xx == 16));

res_cat = 0;
if kstest2(res_A,res_blank,0.01, 1)
    res_cat = res_cat + 1;
end
if kstest2(res_B,res_blank,0.01, 1)
    res_cat = res_cat + 2;
end

figure('pos',[360 537 899 397])
for i = 1:length(xx)
    c = colormap;
    ind = round(8+(48/(length(xx)-1)*(i-1)));
    color = c(ind,:);
    plot(xx(i),exper.blob.roi(blob).ratio(i)*(-1),'o','color',color); hold on
    drawnow
end
plot([2 18],[0 0],'k')
% plot(x,y,'o')


for i = 1:length(g_list)
    disp([num2str(i) '   ' g_list{i}])
end

M = [];
SE = [];
for i = 1:length(g_list)
    t = find(xx == i);
    m = mean(exper.blob.roi(blob).ratio(t)*(-1));
    se = std(exper.blob.roi(blob).ratio(t)*(-1))/sqrt(length(t));
    M = [M m];
    SE = [SE se];
end
% figure
% errorbar(1:length(g_list),M,SE)

perc = [0 20 40 60 80 100];

fig = figure('pos',[292   324   983   625]);

mix_pred = M(grc(2:5))+M(fliplr(grh(2:5)));

mix_resp = M([3 4 5 6]);
max_res = max([M(2:16) mix_pred]);
min_res = min([M(2:16) mix_pred]);
ax = [-5 105 min_res max_res*1.2];

subplot(2,2,1)
gr = grc;
errorbar(perc,M(gr),SE(gr)); hold on
title('caproic acid')
xlabel('[A]')
ylabel('response')
plot([-10 110],[0 0],'k:')
axis(ax)

subplot(2,2,2)
gr = grh;
errorbar(perc,M(gr),SE(gr)); hold on
title('hexanol')
xlabel('[B]')
ylabel('response')
plot([-10 110],[0 0],'k:')
axis(ax)

subplot(2,2,3)
gr = grm;
errorbar(perc,M(gr),SE(gr)); hold on
title('mixture')
xlabel('[A] (= 100-[B])')
ylabel('response')
plot([-10 110],[0 0],'k:')
axis(ax)

subplot(2,2,4)
errorbar(perc,M(grm),SE(grm)); hold on
plot(perc(2:5),mix_pred,'ro:')
plot(perc,M(grc),'m:')
plot(fliplr(perc),M(grh),'c:')
title('mixture')
xlabel('[A] (= 100-[B])')
ylabel('response')
plot([-10 110],[0 0],'k:')
axis(ax)

axi = axes('parent',fig,'pos',[0 0 1 1],'tag','r_title','visible','off');
title_str = ['glomerulus ' num2str(blob) '   ( trial : ' num2str(trial_range(1)) ' - ' num2str(trial_range(end)) ' )'];
h = text(0.5,1,title_str,'horiz','center','vertical','top','parent',axi,'tag','ratio_title');

% fig2 = figure;
% gr = [2 3 4 5 6 7];
% grc = [16 11 10 9 8 7];
% grh = [16 15 14 13 12 2];
% errorbar(perc,M(gr),SE(gr)); hold on
% plot(perc(2:5),mix_pred,'ro:')
% plot(perc,M(grc),'m:')
% plot(fliplr(perc),M(grh),'c:')
% title('mixture')
% xlabel('[A] (= 100-[B])')
% ylabel('response')
% plot([-10 110],[0 0],'k:')
% axis(ax)
% 
% axi = axes('parent',fig2,'pos',[0 0 1 1],'tag','r_title','visible','off');
% title_str = ['glomerulus ' num2str(blob)];
% h = text(0.5,1,title_str,'horiz','center','vertical','top','parent',axi,'tag','ratio_title');