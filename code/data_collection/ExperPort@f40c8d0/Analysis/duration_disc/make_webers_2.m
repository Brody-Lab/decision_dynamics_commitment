function [] = make_webers_2(a,b,c,d)
  
    mega_weber = [cell2mat(a) cell2mat(b) cell2mat(c) cell2mat(d) ];
    mp = sqrt(300*800) * 2;
    mega_weber = mega_weber * mp;
   
  figure;
  set(gcf,'Menubar','none','Toolbar','none');
  l = errorbar(1:4, mean(mega_weber), std(mega_weber), std(mega_weber),'.k');
  set(l, 'MarkerSize',20);
  
  xlabel('Rat #');
  ylabel('Discriminability measure (ms)');
  
  text(0.8, 0.1*mp, 'Ghazni','FontSize',12);
  text(1.8, 0.1*mp, 'Timur', 'FontSize', 12);
  text(2.8, 0.1*mp, 'Babur', 'FontSize',12);
  text(3.8, 0.1*mp, 'Akbar', 'FontSize', 12);
  
  
  set(gca,'XTick', 1:1:4, 'YLim', [0 0.3*mp]);
  
  title('Discriminability measure shown on rat-by-rat basis');
