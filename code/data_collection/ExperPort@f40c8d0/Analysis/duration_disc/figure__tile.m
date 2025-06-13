function [] = figure__tile(figwidth, figheight, tiletype, flist)
% tiles all figures on the screen
% figwidth and figheight: size of each figure (all figures will have same
% dimension)
% tiletype - pattern in which to tile
%   - left2right
%   - top2bottom
%   - bottom2top

if nargin == 3, flist = []; end;

wd = figwidth;
ht = figheight;

ssize = get(0,'ScreenSize');
SCREEN__WD = 1280; % ssize(3);
SCREEN__HT = ssize(4);
HT__SPACER = 20;

if isempty(flist)
kids = get(0,'Children');
else kids = flist;
end;

switch tiletype
    case 'left2right'
        ypos = 200; xpos =0;
        for idx =1:length(kids)
            set(0,'CurrentFigure', kids(idx));
            set(gcf,'Position',[xpos ypos wd ht],'Menubar','none','Toolbar','none'); refresh;
            xpos = xpos+wd+10;
            if xpos > SCREEN__WD - (wd+10), xpos=10; ypos = ypos + ht + 10; end;
        end;
    case 'top2bottom'
        ypos=SCREEN__HT - 10;        xpos = 10;        
        for idx =1:length(kids)
                       set(0,'CurrentFigure', kids(idx));
            fprintf(1,'\tTHIS x,y: %i, %i\n', xpos, ypos);                           
            set(gcf,'Position',[xpos ypos wd ht],'Menubar','none','Toolbar','none'); refresh;
            ypos = ypos-(2.5*ht);
            if ypos < 10, ypos = SCREEN__HT - 10; xpos = xpos+wd+10;end;
            fprintf(1,'next x,y: %i, %i\n', xpos, ypos);    
        end;

    case 'bottom2top'
        ypos= 0;        xpos = 10;        
        for idx =length(kids):-1:1
                        set(0,'CurrentFigure', kids(idx));
            set(gcf,'Position',[xpos ypos wd ht],'Menubar','none','Toolbar','none'); refresh;
            ypos = ypos+(ht+10);
            if ypos > SCREEN__HT - 10, ypos = SCREEN__HT - 10; xpos = xpos+wd+10;end;
        end;        
    otherwise
        error('tiletype can either be left2right, top2bottom, or bottom2top');
end;

