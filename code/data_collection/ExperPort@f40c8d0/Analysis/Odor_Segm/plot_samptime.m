figure; hold on; x1 = 1; 
for i = 1: length(bgs), 
    x2 = x1+length(bgs(i).blkst_ses1)-1; 
    plot((x1:x2), bgs(i).blkst_ses1,'-o'); 
    text(mean(x1,x2),mean(bgs(i).blkst_ses1), bgs(i).sesname, ...
        'Color','g', 'Rotation', 80, 'FontSize',10);
    x1 = x2+1;
end;