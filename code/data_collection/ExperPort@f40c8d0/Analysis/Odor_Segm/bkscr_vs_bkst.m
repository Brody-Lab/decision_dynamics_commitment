figure; hold on; bkscr = []; bkst = []; 
for i = 41: length(bgs), 
    bkscr = [bkscr bgs(i).blkscr_ses1];
    bkst = [bkst bgs(i).blkst_ses1];
end;
R = corrcoef(bkscr, bkst);
plot(bkscr, bkst, 'o', 'MarkerSize', 10);
xlabel('Block score'); ylabel('Odor Sampling Time (s)');
