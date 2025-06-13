function [] = comp_two

minnie = 300;
maxie = 800;

hzd = 0.1;

len = 100;

h = figure;
subplot(1,2,1);
hzd_p = generate_variability(minnie, maxie, hzd, len);
plot(1:len, hzd_p, 'ob');
title(['Variability with hazard rate: ' num2str(hzd) ]); 

subplot(1,2,2);
rand_p = (rand(len, 1) * (maxie-minnie)) + minnie;
plot(1:len, rand_p, 'og');
title('Scaling random numbers');