function [bs_avg, tst_avg, p] = airmix_tg_ros(ratname, norm, varargin)

data_path2 = 'c:\Home\RatExper\SoloData\Data\NL_Analysis\nl2afc_airmix\';
% figure('Position',[10 120 1380 850]);
bs_scr = []; bs_bias = [];
tst_scr = []; tst_bias = [];
recov = [];
m_bs = []; m_tst = [];
session = varargin;
for i = 1:length(session), 
    load([data_path2 ratname '_' session{i}]);
    tg_idx = find(strcmp(score_blk(:,1), '56/44'));
    tg_scr = [score_blk{tg_idx, 3}];
    bias = abs([score_blk{tg_idx,5}] - [score_blk{tg_idx,6}]);
    bs_end = find(diff([score_blk{tg_idx, 4}])==1);
    test_end = find(diff([score_blk{tg_idx, 4}])==-1);
    if isempty(test_end),
        test_end = length(tg_idx);
    end;
    if bs_end < 3,
        bs = [zeros(1,3-bs_end) tg_scr(1: bs_end)];
        bs_b = [zeros(1,3-bs_end) bias(1: bs_end)];
    else
        bs = tg_scr(bs_end-2: bs_end);
        bs_b = bias(bs_end-2: bs_end);
    end;
    if norm, % if to normalize
        norm_factor = mean(bs(end-1:end)); % normalize with mean of the last two block of baseline
        bs = bs./norm_factor; 
    end;
        % next do the same thing for test blocks (4 block)
    if test_end-bs_end < 4 % if less than 4 blocks then 0 pad
        tst = [tg_scr(bs_end+1:test_end) zeros(1, 4-(test_end-bs_end))];
        tst_b = [bias(bs_end+1:test_end) zeros(1, 4-(test_end-bs_end))];
    else
        tst = tg_scr(bs_end+1:test_end);
        tst_b = bias(bs_end+1:test_end);
    end;
    if norm,
        tst = tst./norm_factor;
    end;
    % get the quantities for t-test
    m_bs = [m_bs mean(tg_scr(bs_end-1: bs_end))];
    m_tst = [m_tst mean(tg_scr(bs_end+1:test_end))];
    
    % construct a matrix for average across sessions
    bs_scr = [bs_scr; bs];
    tst_scr = [tst_scr; tst];
   % recov = [recov; tg_scr(test_end+1:end)];
    
    bs_bias = [bs_bias;  bs_b];
    tst_bias = [tst_bias; tst_b];
   % recov_bias = [recov_bias; bias(test_end+1:end)];
end;

% paired t-test:
[h, p] = ttest(m_bs, m_tst);
    
bs_avg = []; % to store mean and stde of scores and biasing across rats
tst_avg = [];
for i = 1:size(bs_scr,2),
    x1 = bs_scr(:,i); x1(x1==0)=[];
    x2 = bs_bias(:,i); x2(x2==0)=[];
    bs_avg = [bs_avg; [mean(x1) std(x1)/sqrt(length(x1)) mean(x2) std(x2)/sqrt(length(x2))]];
end;
for i = 1:size(tst_scr,2),
    x1 = tst_scr(:,i); x1(x1==0)=[];
    x2 = tst_bias(:,i); x2(x2==0)=[];
    tst_avg = [tst_avg; [mean(x1) std(x1)/sqrt(length(x1)) mean(x2) std(x2)/sqrt(length(x2))]];
end;
figure('Position',[420   230   550   700]); hold on; 
X1 = (1:size(bs_avg,1)); Y11 = bs_avg(:,1); err11 = bs_avg(:,2); Y21 = bs_avg(:,3); err21 = bs_avg(:,4);
X2 = (size(bs_avg,1)+1:size(bs_avg,1)+size(tst_avg,1));
Y12 = tst_avg(:,1); err12 = tst_avg(:,2); Y22 = tst_avg(:,3); err22 = tst_avg(:,4);
subplot(2,1,1); hold on; 
title([ratname ' average in ' num2str(length(session)) ' sessions'], 'FontSize', 20);
text(0.5, 50, ['P = ' num2str(p)], 'FontSize',20);
if norm, y_lim = [0.6 1.3]; else, y_lim = [40 100]; end;
set(gca,'XLim', [0 8],'YLim',y_lim); 
h1 = errorbar(X1, Y11, err11, '-oc','MarkerSize', 10);
h2 = errorbar(X2, Y12, err12, '-og','MarkerSize', 10);
subplot(2,1,2); hold on;
b1 = bar(X1, Y21); set(b1, 'FaceColor', 'none', 'EdgeColor', 'c');
b2 = bar(X2, Y22); set(b2, 'FaceColor', 'none', 'EdgeColor', 'g');
errorbar(X1, Y21, err21, 'LineStyle','none','Color','c');
errorbar(X2, Y22, err22, 'LineStyle','none','Color','g');
set(gca,'XLim', [0 8],'YLim', [0 100]);



    
    