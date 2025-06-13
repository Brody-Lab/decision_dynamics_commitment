function [zarray pdf_z] = pdf_sum_uni(x_min, x_max, y_min, y_max, varargin)
  % Draws the probability density function of a sum of two continuous
  % uniform distributions
  % Takes four arguments: the ranges for the two uniform distributions:
  % (x_min, x_max) and (y_min, y_max)
  % 

    
 pairs = { ...
     'showplot', 0 ; ...
     };
 parse_knownargs(varargin, pairs);

    
  close all;
   % two uniform distributions -- set min and max
  %x_min = 0.2; x_max = 0.6;
  %y_min = 0.1; y_max = 0.3;
  
  
  pdf_z = []; zarray = [];
  
  points_a = []; points_b = [];
  
  for z = x_min+y_min:0.001:x_max+y_max
    
    % right diagonal
    ay = y_max; ax = z - y_max;
    bx = x_max; by = z - x_max;    
    if (ax >= x_min) & (by >= y_min)

    dist = sqrt(((by - ay).^2) + ((bx - ax).^2));
    pdf_z = [pdf_z dist];
    zarray = [zarray z];
    points_a = [points_a; ax ay];
    points_b = [points_b; bx by];
    
    else % left diagonal
      by = y_min; bx = z - y_min; 
      ax = x_min; ay = z - x_min;
      if (ay <= y_max) & (bx <= x_max)
    dist = sqrt(((by - ay).^2) + ((bx - ax).^2));
    pdf_z = [pdf_z dist];
    zarray = [zarray z];
    points_a = [points_a; ax ay];
    points_b = [points_b; bx by];
      else
      by = y_min; bx = z - y_min; 
      ay = y_max; ax = z - y_max;
         if (ax >= x_min) & (bx <= x_max)
    dist = sqrt(((by - ay).^2) + ((bx - ax).^2));
    pdf_z = [pdf_z dist];
    zarray = [zarray z];
    points_a = [points_a; ax ay];
    points_b = [points_b; bx by];
        end;
         
      end;
    end;
    
  end;
  
  % normalise
  pdf_z = pdf_z / sum(pdf_z);
 %sum(pdf_z)

  if showplot > 0
      
      figure;
      hist(pdf_z);
      
  figure;
  set(gcf,'Menubar','none','Toolbar','none');
  subplot(2,1,1);
  plot(zarray, pdf_z,'-b');
  xlabel('Values of z = x+y');
  ylabel('Base of rectangle at z=x+y');
  title('prob. density function of two cts uniform distributions');
  
  subplot(2,1,2);
  set(gcf,'Menubar','none','Toolbar','none');
  plot(points_a(:,1), points_a(:,2),'.r'); hold on;
  plot(points_b(:,1), points_b(:,2),'.g');
  xlabel('x'); ylabel('y');
  title('(x,y) combinations included in the pdf calculation');
  end;
  
  