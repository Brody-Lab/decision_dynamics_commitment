function h=plot_rat_mass_agb(ratname,dates,varargin)

    p=inputParser;
    p.addParameter('color',[0 0 0],@(x)validateattributes(x,{'numeric'},{'numel',3,'vector','<=',1,'>=',0}));
    p.parse(varargin{:});
    params=p.Results;

    if iscell(ratname)
        if numel(ratname)==1
            ratname=ratname{1};
        else
            colors=parula(numel(ratname));
            for i=1:numel(ratname)
                h(i) = plot_rat_mass_agb(ratname{i},dates,'color',colors(i,:));
                ylabel('Mass (g)');
                legend(h);
            end
            return
        end
    elseif ~ischar(ratname) && ~isstring(ratname)
        error('ratname unrecognized: must be a string scalar or character vector (or cell array of those)');
    end

    date_str = parse_daterange(dates);
    date_str = strrep(date_str,'session','');
    [mass,date] = bdata(['select mass, date from ratinfo.mass where ratname="',ratname,'" and (',date_str,') order by date']);
    date = datetime(date);
    mass(mass == 0) = nan;

    h=plot(date,mass,'-o');
    h.Color = params.color;
    h.MarkerFaceColor = params.color;
    h.DisplayName = ratname;
    ylabel(sprintf('%s mass (g)',ratname));
    xlabel('Date');
    grid on;

end