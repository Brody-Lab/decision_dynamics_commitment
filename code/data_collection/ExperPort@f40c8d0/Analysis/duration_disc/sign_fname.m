function [] = sign_fname(fighandle, fname)
% Given a text string 'fname', puts the string on the bottom-right of the
% provided figure (fighandle).
% Use this script to mark which script generated which a given figure by
% calling within the script:
% sign_fname(my_generated_fig, mfilename)


posf = get(fighandle, 'Position');

currgcf = get(0,'CurrentFigure');
set(0,'CurrentFigure', fighandle);

flen = length(fname)+150;
uicontrol('Style','text', 'BackgroundColor',[0.8 0.8 0.8], 'HorizontalAlignment','left',...
    'Position', [posf(3)-flen 4 200 10], ...
    'String', fname,'Tag','scriptname');

uicontrol('Style','text', 'BackgroundColor',[0.8 0.8 0.8], 'HorizontalAlignment','left',...
    'Position', [10 4 100 10], ...
    'String', ['Run on ' date],'Tag','rundate');

    
set(0,'CurrentFigure',currgcf);