function [] = tempblah()
  
  x = 1:5;
  h = plot(x,x, '.b');
  set(h, 'Callback', @plot_cbk);