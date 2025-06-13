function [bs_avg, tst_avg] = airmix_tg_sor(session, norm)
% sor: session over rats. average score of one session over all rats.
ratname = {'xu1_1','xu1_2','xu1_3','xu2_1','xu2_2','xu2_3'};
data_path2 = 'c:\Home\RatExper\SoloData\Data\NL_Analysis\nl2afc_mix2\';
figure('Position',[10 120 1380 850]);
bs_scr_allrats = []; bs_bias_allrats = [];
tst_scr_allrats = []; tst_bias_allrats = [];
for i = 1:6, 
    load([data_path2 ratname{i} '_' session]);
    tg_idx = find(strcmp(score_blk(:,1), '56/44'));
    tg_scr = [score_blk{tg_idx, 3}];
    bs_end = find(diff([score_blk{tg_idx, 4}])==1);
    test_end = find(diff([score_blk{tg_idx, 4}])==-1);
    if isempty(test_end),
        test_end = length(tg_idx);
    end;
    subplot(2,3,i);hold on;
    title([ratname{i}, ' in ' session]);
    plot((1:bs_end), tg_scr(1: bs_end),'o-c'); 
    plot((bs_end+1:test_end), tg_scr(bs_end+1:test_end),'o-g');
    plot((test_end+1:length(tg_idx)), tg_scr(test_end+1:end),'o-m');
    set(gca, 'YLim', [0 100], 'XLim', [0 length(tg_idx)+1], 'YGrid', 'on');
    for j = 1:length(tg_idx), 
        % left-right score biasing.
        bias(j) = score_blk{tg_idx(j),5} - score_blk{tg_idx(j),6}; 
        if bias(j) >= 0, bclr = 'b'; else, bclr = 'r'; end;
        h = bar(j, abs(bias(j))); 
        set(h, 'FaceColor', 'none', 'EdgeColor', bclr);
    end;
    bias = abs(bias);
% next average scores across rats, and plot them.
    % chunk out the last 3 blocks of baseline score (bs) of each rat
    if bs_end < 3,
        bs = [zeros(1,3-bs_end) tg_scr(1: bs_end)];
        bs_bias = [zeros(1,3-bs_end) bias(1: bs_end)];
    else
        bs = tg_scr(bs_end-2: bs_end);
        bs_bias = bias(bs_end-2: bs_end);
    end;
    if norm, % if to normalize
        norm_factor = mean(bs(end-1:end));
        bs = bs./norm_factor;
    end;
    % put baseline scores and bias of all rats into one vector
    bs_scr_allrats = [bs_scr_allrats; bs];
    bs_bias_allrats = [bs_bias_allrats; bs_bias];
    
    % next do the same thing for test blocks (4 block)
    if test_end-bs_end < 4 % if less than 4 blocks then 0 pad
        tst = [tg_scr(bs_end+1:test_end) zeros(1, 4-(test_end-bs_end))];
        tst_bias = [bias(bs_end+1:test_end) zeros(1, 4-(test_end-bs_end))];
    else
        tst = tg_scr(bs_end+1:test_end);
        tst_bias = bias(bs_end+1:test_end);
    end;
    if norm,
        tst = tst./norm_factor;
    end;
    tst_scr_allrats = [tst_scr_allrats; tst];
    tst_bias_allrats = [tst_bias_allrats; tst_bias];
end;
bs_avg = []; % to store mean and stde of scores and biasing across rats
tst_avg = [];
for i = 1:size(bs_scr_allrats,2),
    x1 = bs_scr_allrats(:,i); x1(x1==0)=[];
    x2 = bs_bias_allrats(:,i); x2(x2==0)=[];
    bs_avg = [bs_avg; [mean(x1) std(x1)/sqrt(length(x1)) mean(x2) std(x2)/sqrt(length(x2))]];
end;
for i = 1:size(tst_scr_allrats,2),
    x1 = tst_scr_allrats(:,i); x1(x1==0)=[];
    x2 = tst_bias_allrats(:,i); x2(x2==0)=[];
    tst_avg = [tst_avg; [mean(x1) std(x1)/sqrt(length(x1)) mean(x2) std(x2)/sqrt(length(x2))]];
end;
figure('Position',[420   230   550   700]); hold on; 
X1 = (1:size(bs_avg,1)); Y11 = bs_avg(:,1); err11 = bs_avg(:,2); Y21 = bs_avg(:,3); err21 = bs_avg(:,4);
X2 = (size(bs_avg,1)+1:size(bs_avg,1)+size(tst_avg,1));
Y12 = tst_avg(:,1); err12 = tst_avg(:,2); Y22 = tst_avg(:,3); err22 = tst_avg(:,4);
subplot(2,1,1); hold on; title(['6 rat avg, ' session], 'FontSize', 20);
set(gca,'XLim', [0 size(bs_avg,1)+size(bs_avg,1)+1],'YLim',[0.6 1.3]); 
h1 = errorbar(X1, Y11, err11, '-oc','MarkerSize', 10);
h2 = errorbar(X2, Y12, err12, '-og','MarkerSize', 10);
subplot(2,1,2); hold on;
b1 = bar(X1, Y21); set(b1, 'FaceColor', 'none', 'EdgeColor', 'c');
b2 = bar(X2, Y22); set(b2, 'FaceColor', 'none', 'EdgeColor', 'g');
errorbar(X1, Y21, err21, 'LineStyle','none','Color','c');
errorbar(X2, Y22, err22, 'LineStyle','none','Color','g');
set(gca,'XLim', [0 size(bs_avg,1)+size(bs_avg,1)+1],'YLim', [0 100]);
