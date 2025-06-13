function [] = tempblah()
  
  x = 1:5;
  h = plot(x,x, '.b');
   datacursormode on;
  dcm = datacursormode(gcf);
  set(dcm, 'DisplayStyle','datatip', 'SnapToDataVertex', 'on');
  set(dcm, 'UpdateFcn', @plot_cbk);
 %set(h, 'ButtonDownFcn', @plot_cbk);
 