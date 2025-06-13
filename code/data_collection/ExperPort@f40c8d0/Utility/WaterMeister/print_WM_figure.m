function print_WM_figure

if exist('C:\WaterMeisterFigure_temp.fig','file') ~= 0
    h = open('C:\WaterMeisterFigure_temp.fig');
    pause(2);
    print(h);
    pause(5); 
    flush
end
pause(1);
exit
