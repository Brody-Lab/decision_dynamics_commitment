function [] = makeSine()

shortt=0:1/2000:4;
longt= 0:1/2000:8;

    
    figure;
    subplot(2,1,1);
    snd =  sin( 2*pi.*shortt ) ; %IS THIS CORRECT???
   
    l = plot(shortt, snd);
   set(l,'LineWidth'); 
   
    set(gca,'YLim', [-2 2]);
    
    subplot(2,1,2);
    snd =  sin( 2*pi.*longt ) ; %IS THIS CORRECT???
   
    l = plot(longt, snd);
   set(l,'LineWidth'); 
   
    set(gca,'YLim', [-2 2]);
    

