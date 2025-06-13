function [] = sandbox2(b)

% num_bins = 8;
% binmin =1;
% binmax=16;
% [bins] = generate_bins(binmin,binmax, num_bins, 'pitches',1);
% numsamples = 4;
% BLOCK_SIZE = num_bins * numsamples;
% 
% weights = ones(1,num_bins) * (1 / num_bins);
% %weights = set_weight(weights,[1 num_bins], [0.5 0.5]);
% 
% num2make = round(weights * BLOCK_SIZE);
% if sum(num2make) > BLOCK_SIZE, num2make(end) = num2make(end)-1;end;
% if sum(num2make) < BLOCK_SIZE, num2make(end) = num2make(end)+1; end;
% 
% % make sides list
% half = BLOCK_SIZE/2;
% left_trials = sum(num2make(1:num_bins/2));
% right_trials = sum(num2make((num_bins/2)+1:num_bins));
% sides = [ones(1,left_trials) zeros(1,right_trials)];
% mix = randperm(BLOCK_SIZE);
% sides = sides(mix);
% 
% % generate the tones
% logbins = log2(bins);
% logmin = log2(binmin);
% logmax = log2(binmax);
% tone_list = [];
% for idx=1:length(bins)
%     if idx == 1, bin_from = logmin;
%     else bin_from = (logbins(idx-1)+logbins(idx))/2; end;
% 
%     if idx == length(bins), bin_to = logmax;
%     else bin_to = (logbins(idx)+logbins(idx+1))/2; end;
% 
%     new_tones = (rand(1,num2make(idx)) * (bin_to - bin_from) ) + bin_from;
%     tone_list = horzcat(tone_list, new_tones);
% end;
% 
% % plot tone samples
% figure;
% subplot(1,3,1);
% for idx=1:length(bins)
%     if idx == 1, sidx=1; end;
%     eidx = (sidx+num2make(idx))-1;
%     fprintf(1,'%i - %i\n',sidx,eidx);
%     l=plot(sidx:eidx, tone_list(sidx:eidx), '.b'); hold on;
%     c=rand(1,3); set(l,'Color',c);
%     sidx = eidx+1;
% end;
% 
% % now permute the tones too.
% left_tones = tone_list(1:left_trials);
% mix = randperm(length(left_tones));
% left_tones = left_tones(mix);
% 
% right_tones = tone_list(left_trials+1:end);
% mix = randperm(length(right_tones));
% right_tones = right_tones(mix);
% 
% % now plot the mixed tones
% subplot(1,3,2);
% plot(1:length(left_tones),left_tones,'.b');hold on;
% plot(1:length(right_tones),right_tones,'.r');
% %set(gca,'XLim',[1 5]);
% 
% % now stitch the mixed tones together using the mixed sides list
% block_tones = zeros(size(sides));
% block_tones(find(sides > 0)) = left_tones;
% block_tones(find(sides==0)) = right_tones;
% 
% subplot(1,3,3);
% left_side = find(sides>0); right_side = find(sides==0);
% plot(left_side, block_tones(left_side),'.b');
% hold on;
% plot(right_side, block_tones(right_side),'.r');
% 
% 
% function [weights] = set_weight(old_weights, pos, new_wt)
% wt_so_far =0;
% weights = ones(size(old_weights));
% for f = 1:length(pos)
%     p = pos(f);
%     weights(p) = new_wt(f);
%     wt_so_far = wt_so_far + new_wt(f);
% end;
% left_over = (1-wt_so_far)/(length(weights)-length(pos));
% weights(setdiff(1:length(weights), pos)) = left_over;
% 
% % 
% % 
% 
% hh = ones(1,100) * 1; % start out perfect
% hh(2:3:100)=0; % now get every alternate right
% x = 1:length(hh);
% running_avg=10;
% 
% nums=[];
%   t = (1:length(hh))';
%             a = zeros(size(t));
% for i=1:length(hh),
%     x = 1:i;
%     if i == running_avg-1
%         2;
%     end;
%     kernel = exp(-(i-t(1:i))/running_avg);
%     kernel = kernel(1:i) / sum(kernel(1:i)); % normalize weights to add up to 1.
% 
%     if i == length(hh)
%         2;
%     end;
%     a(i) = sum(hh(x)' .*kernel);
% end;
% num = a;
% 
% hold on;
% plot(num, '.-'); nums = [nums ; {num}]; hold on;
% 
% dates = get_files('Adler','fromdate','080108','todate','999999');
% for d = 1:length(dates)
%     try
%     psychometric_curve('Adler', 0, 'usedate', dates{d},'nohist',1);
%     catch
%         warning('%s did not work', dates{d});
%     end;
% end;

%  ratname = 'Blaze';
%  days_after_musc = {'080523a','080529a','080603a'}; %,'080605a','080614a','080617a'};
% % saline_days = {'080506a','080509a','080513a'}; % first three saline days
% % musc_days = {'080528a'}; % {'080522a','080524a','080602a'}; % first three musc days
% 
% % ratname = 'Pips';
% % days_after_musc = {'080522a', '080524a','080603a' ,'080605a','080614a','080617a'};
% % musc_days = {'080521a','080523a','080531a'};
% % saline_days = {'080506a','080509a','080513a'};
% % days_after_saline = {'080507a','080510a','080514a'};
% 
% % ratname = 'Grimesby';
% % saline_days = {'080409b','080414a','080421a'};
% % days_after_musc = {'080411a','080417a','080423a'};
%    psych_pooled_oversessions(ratname,'use_dateset','given','given_dateset', days_after_musc, 'daily_bin_variability', 1);

%p = get_pstruct('S033','080916a');
time_ill_wasted('S033','080916a');
