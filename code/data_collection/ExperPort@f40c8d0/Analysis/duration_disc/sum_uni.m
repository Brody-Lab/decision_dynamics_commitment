function [] = sum_uni()
  % sandbox to simulate two uniform distributions and their interaction.
  
  
  % two uniform distributions -- set min and max
  x_min = 0.2; x_max = 0.6;
  y_min = 0.1; y_max = 0.3;
  
  % set # samples
  n = 100000;
  
  x = (rand(n,1) .* (x_max-x_min)) + x_min;
  y = (rand(n,1) .* (y_max-y_min)) + y_min;
  
  % joint pdf
  joint_xy = x + y;
  
  subplot(3,1,1); hist(x,n/2);
  subplot(3,1,2); hist(y,n/2);
  subplot(3,1,3); hist(joint_xy, n/2);
 
