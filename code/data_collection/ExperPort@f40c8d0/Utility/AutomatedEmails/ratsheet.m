function F = ratsheet(ratnames,s,LastTraining,day,varargin)

if nargin < 4; day = now; end

if isempty(ratnames); ratnames = {'',''}; end

[TL RGB] = bdata('select tag_letter,tag_RGB from ratinfo.contacts');
for i = 1:length(RGB); if ischar(RGB{i}); RGB{i} = str2num(RGB{i}); end; end %#ok<ST2NM>
for i = 1:length(RGB); RGB{i} = RGB{i} / 255; end

C = cell(0);
for e = 1:length(TL)
    if ~isempty(TL{e});  C{end+1,1} = TL{e};  else continue; end %#ok<AGROW>
    if ~isempty(RGB{e}); C{end,  2} = RGB{e};
    else                 C{end,  2} = [1 1 1]; 
    end
end

if     size(ratnames,1) <= 20; h = 5; w = 4; fs = 44;
else                           h = 6; w = 5; fs = 40;
end

if LastTraining < size(ratnames,1); drawbreak = 1; else drawbreak = 0; end

for f = 1:ceil(size(ratnames,1)/(h*w))
    
    if f ~= ceil(size(ratnames,1)/(h*w))
        ratnames_temp = ratnames(((f-1)*h*w)+1:f*h*w,:);
    else
        ratnames_temp = ratnames(((f-1)*h*w)+1:end,:);
    end
    
    F(f) = figure('color','w'); hold on; %#ok<AGROW>

    set(gca,'xlim',[0 100],'ylim',[0 85],'Units','points','YDir','reverse')
    set(gca,'Position',get(gca,'OuterPosition'));
    xc = 100/(w*2):100/w:100-(100/(w*2));
    yc = 75/(h*2):75/h:75-(75/(h*2)); yc = yc + 8;

    if ceil(size(ratnames,1)/(h*w)) > 1
        text(5,5,['Bring Up Before Session ',num2str(s),'  (',num2str(f),' of ',num2str(ceil(size(ratnames,1)/(h*w))),')','  ',datestr(day,29)],'fontsize',fs*0.7);
    else
        text(5,5,['Bring Up Before Session ',num2str(s),'  ',datestr(day,29)],'fontsize',fs*0.8);
    end
    cnt = 0;
    
    if size(ratnames,1)>1 || (~isempty(ratnames{1,1}) || ~isempty(ratnames{1,2}))
        for x = xc
            for y = yc
                cnt = cnt + 1;
                if cnt > size(ratnames_temp,1); continue; end
                makelabel(x,y,100/w,75/h,ratnames_temp(cnt,:),C);
                if cnt == LastTraining && drawbreak == 1; makebreak(x,y,100/w,75/h); end
            end
        end
    end

    set(gca,'Units','Normalized');
end




function makelabel(x,y,dx,dy,ratnames,C)
ratnames(strcmp(ratnames,'')) = [];

bad = [];
for i=1:length(ratnames); 
    if length(ratnames{i}) ~= 4
        bad(end+1) = 1; %#ok<AGROW>
    end
end
ratnames(bad) = [];

text(x-(dx/4),y,ratnames,'fontsize',32);
c = C{strcmp(C(:,1),ratnames{1}(1)),2};

pw = 2;
ph = 10;

p1 = [x-(dx/4)-pw-1, y-(dy/2)+((dy-ph)/2)];
p2 = [x+(dx/4)+1,    y-(dy/2)+((dy-ph)/2)];

patch([p1(1) p1(1)+pw p1(1)+pw p1(1)],[p1(2) p1(2) p1(2)+ph p1(2)+ph],c);
patch([p2(1) p2(1)+pw p2(1)+pw p2(1)],[p2(2) p2(2) p2(2)+ph p2(2)+ph],c);


function makebreak(x,y,dx,dy)

pw1 = 2;
pw2 = dx * 0.8;
ph1 = 10;
ph2 = 1;

p1 = [x-(dx/4)-pw1-1, y-(dy/2)+((dy-ph1)/2)];
p1(2) = p1(2) + ph1 + 1;

patch([p1(1) p1(1) p1(1)+pw2 p1(1)+pw2],[p1(2) p1(2)+ph2 p1(2)+ph2 p1(2)],'k');





