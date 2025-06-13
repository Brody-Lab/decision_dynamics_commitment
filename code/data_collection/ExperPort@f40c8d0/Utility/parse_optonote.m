function figurehandle = parse_optonote(note)

figurehandle = [];
colors = {'red'   ,[1 0 0];...
          'yellow',[1 1 0];...
          'green' ,[0 1 0];...
          'blue'  ,[0 0 1];...
          'black' ,[0 0 0]};
c = [];
for i = 1:size(colors,1)
    if ~isempty(strfind(lower(note),['plug in ',colors{i}])) ||...
       ~isempty(strfind(lower(note),['and ',    colors{i}]))
    
        c(end+1) = i; %#ok<AGROW>
    end
end
if isempty(c); return; end

C = [];
for i = 1:numel(c)
    for j = 1:3
        C(1,i,j) = colors{c(i),2}(j); %#ok<AGROW>
    end
end

figurehandle = figure('color','w','position',[10 10 300*numel(c) 300]);
imagesc(double(C));
set(gca,'position',get(gca,'outerposition'));
axis off
hold on


if numel(c) == 1
    fs = 20;
    x = 'This Color';
else
    fs = 30;
    x = 'These Colors';
end

h = text(0.6,0.6,['Plug In ',x]);

set(h,'fontsize',fs,'color',[1 1 1],'fontweight','bold');

try %#ok<TRYNC>
    jf=get(figurehandle, 'JavaFrame');
    pause(0.1);
    javaMethod('setAlwaysOnTop', jf.fFigureClient.getWindow, 1);
end

