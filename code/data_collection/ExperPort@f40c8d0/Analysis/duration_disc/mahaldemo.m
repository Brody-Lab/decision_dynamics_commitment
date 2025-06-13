function [] = mahaldemo
% demo of Mahalanobis distance

  x = mvnrnd([0;0], [1 .9;.9 1], 100);
       y = [1 1;1 -1;-1 1;-1 -1];
       mahal(y,x)

       figure;
       line([0 0],[-2 +2],'LineStyle',':','Color',[1 1 1]*0.3);
       line([-2 +2], [0 0], 'LineStyle',':','Color',[1 1 1]*0.3);
       plot(x(:,1),x(:,2),'.r','Color',[1 1 1]*0.3);
       hold on;
       plot(y(:,1),y(:,2),'.r');
       