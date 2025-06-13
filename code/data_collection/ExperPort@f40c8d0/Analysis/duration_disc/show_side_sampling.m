function [] = show_side_sampling(ratname,dt)
% plots sides_list and calculates lprob for windows of 20 trials. 
% to see if there is inadvertent bias in stimulus presentation.

winsize = 20;

datafields = {'sides','tones_list','pitch_low','pitch_high','pitch_psych','blocks_switch','MP'};

get_fields(ratname, 'from',dt, 'to',dt, 'datafields',datafields);

figure;
set(gcf,'Position',[200 200 800 300]);
subplot(2,1,1);
plot(1:length(sides), sides, '.r'); hold on;
plot(1:length(sides), sides, '-b');
set(gca,'YLim',[-1 2]);

title('Trial sides');
xlabel('trial#');


lprob = []; % avg lprob for trials
for k = 1:length(sides)-winsize
    curr_l = sum( sides(k:k+(winsize-1)) ) / winsize;
    lprob = horzcat(lprob, curr_l);    
end;

subplot(2,1,2);
plot(1:length(lprob),lprob,'-r');
xlabel('Window #');
ylabel(sprintf('LProb calculated for %i trials',winsize));

% now look at tones presented
pidx = find(blocks_switch > 0);
plow = pitch_low(pidx); phi = pitch_high(pidx);
sl =sides(pidx);
tones = zeros(size(plow));

left = find(sl == 1); right = find(sl==0);
tones(left) = plow(left);
tones(right) = phi(right);

mp = MP(103);
thresh_tones = zeros(size(tones));
hi = find(tones > mp); lo = find(tones <=mp);
thresh_tones(lo) = 1;
thresh_tones(hi) = 0;

subplot(2,1,1); hold on;
%plot(pidx, thresh_tones,'.g');

dist = sum((sl - thresh_tones).^2);
fprintf(1,'Distance between sides list and thresholded tones list is zero?: %i\n\n', dist == 0);

2;
