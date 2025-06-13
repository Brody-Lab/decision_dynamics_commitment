function [] = rankplot(n1,r1,varargin)

pairs = { ...
    'numgroups', 1 ; ...% currently supports 1 or 2
    'n2', [] ; ...
    'r2', [] ; ...
    };
parse_knownargs(varargin,pairs);

figure; axes;
for d=0:length(r1) % plot old versus new measure for duration rats
    if d==0
        x1='WORST'; clr='b'; fw='bold';
        if numgroups == 2
            x2='WORST';
        end;
    else
        clr='k';
        x1=n1{r1(d)}; 
        if numgroups==2
            x2=n1{r2(d)};
        end;
    end;

    if numgroups==2
        if ~strcmpi(x1,x2), clr='r'; fw='bold'; else
            clr='k'; fw='normal'; end;
    end;

    text(1, length(r1)-(d-1),   x1, 'Color', clr, 'FontWeight',fw,'FontSize',16 ); hold on;
    if numgroups==2
        text(2, length(r1)-(d-1),  x2, 'Color', clr, 'FontWeight',fw,'FontSize',16 );
    end;
end;

set(gca,'XLim',[numgroups-0.2 numgroups+0.2], 'YLim',[0 length(r1)+1]);
