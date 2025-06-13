
close all;

minner = 0.3;
maxxer = 1;
%hzd = 0.001;
hzd = [0.05 -0.04];
%hzd = [0.1 0.3 0.5 0.7];

% Higher values lead to quicker rising functions
%    (sharper cutoffs for cumprob) exponential

if minner > maxxer,
    maxxer = minner;
end;
 vpds       = minner:0.01:maxxer;
% prob       = hzd(for_dots)*((1-hzd(for_dots)).^(0:length(vpds)-1));
% cumprob    = cumsum(prob/sum(prob));
%vl         = 1:100;

% for i=1:100, ...
%         vl(i) = vpds(min(find(rand(1)<=cumprob)));
% end;

%magic_num = hzd .* (1-hzd)

figure;
subplot(1,2,1);
colours = 'rgbk';
for c = 1:length(hzd)
    prob = (hzd(c)*((1-hzd(c)).^(0:length(vpds)-1)));
    cumprob = 1-cumsum(prob/sum(prob));
    plot(vpds, cumprob, colours(c));
    hold on;
    ['magic num for ' num2str(hzd(c)) ' = ' num2str(hzd(c) * (1-hzd(c)))]
end;
title('Effect of Hazard rate on cumprob');
hold off;
%        plot(vpds, cumprob);

subplot(1,2,2);
for c = 1:length(hzd)
    prob = hzd(c)*((1-hzd(c)).^(0:length(vpds)-1));
    cumprob = cumsum(prob/sum(prob));
%     for i=1:100, ...
%             vl(i) = vpds(min(find(rand(1)<=cumprob)));
%     end;

%     plot(1:length(vl), vl, ['o' colours(c)]);
plot(vpds, prob, [ 'o' colours(c)]);
    hold on;
end;
