function [aa] = es_checksph(ratstr, sphname, daterange, varargin)
% checks the values of variable 'sphname' for the rats specified in ratstr
% over daterange.  the sphname does not have to the be the full name.
% plots the values by default, or returns them
%
% Examples:
%
% es_checksph('B01[4-7]', 'f1f2Gap', -10);
% es_checksph('C033', 'f1f2Gap', [-50 -30]);
% es_checksph('B012|C033', 'f2f2Gap', '2008-07-24');
% g = es_checksph('B0%', 'FromAnswerPoke', -30, 'plotit', 0);

pairs = { ...
    'fignum_in', []; ...
    'plotit',    1; ...
}; parseargs(varargin, pairs);

% Get Rats
if ischar(daterange),
    date_str = ['sessiondate="' daterange '"'];
else
    if length(daterange) == 1,
        startdate= bdata(['select date_sub("' datestr(now,29) '" , interval ' num2str(-1*daterange) ' day)']);
        enddate  = bdata(['select date_sub("' datestr(now,29) '" , interval ' num2str(0) ' day)']);
    else
        startdate= bdata(['select date_sub("' datestr(now,29) '" , interval ' num2str(-1*daterange(1)) ' day)']);
        enddate  = bdata(['select date_sub("' datestr(now,29) '" , interval ' num2str(-1*daterange(2)) ' day)']);
    end

    date_str = ['sessiondate>"' startdate{1} '" and sessiondate<= "' enddate{1} '"'];
end


if strfind(ratstr,'%')
    all_rats=bdata(['select distinct(ratname) from bdata.sessions where ratname like "' ratstr '" and ' date_str ' order by ratname']);
else
    all_rats=bdata(['select distinct(ratname) from bdata.sessions where ratname regexp "{S}" and ' date_str ' order by ratname'], ratstr);
end

figP = fig_place(numel(all_rats));

% get all matching fields
[fullname,b,b,b,b,b]=bdata(['show columns from protocol.extendedstimulus where field regexp "{S}"'], sphname);

if numel(fullname)~=1 
    helpdlg([{'The SPH name matched the following names:'}; fullname ; {'Please be more specific'}])
end

% for each rat
for rat_i = 1:numel(all_rats)
    ratname = all_rats{rat_i};
    
    day_separators = 0.5;
    sessids = bdata(['select sessid from bdata.sessions where ratname="' ratname '" and ' date_str ' and protocol="ExtendedStimulus" order by sessiondate']);
    
    if isempty(sessids), 
        warning(sprintf('es_checksph: no rat by name %s has trained in ExtendedStimulus matching daterange %d', ratname, daterange));
        break; 
    end
    
    V = [];
    for j = 1:numel(sessids)
        vals = bdata(['select ' fullname{1} ' from protocol.extendedstimulus where sessid = ' num2str(sessids(j)) ]);
        V = [V ; vals];
        day_separators = [day_separators; rows(V)+0.5];
    end
    
    if plotit,
        if isempty(fignum_in),
            figure; fignum = gcf;
        elseif ~ishandle(fignum_in),
            figure(fignum_in);
            fignum = gcf;
        else
            figure(fignum_in);
            clear gcf;
            fignum = gcf; 
        end;

        ch = get(fignum, 'Children');
        if ~isempty(ch), delete(ch); end;
        ax = axes('Parent', fignum); 

        plot(ax, V, '.-');
        set(ax, 'Ylim', [min(V)*0.8, max(V)*1.2]);
        set(ax, 'Layer', 'top');
        set(vlines(ax, day_separators), 'Color', 'k');
        
        set(ax, 'YGrid', 'on');
        set(fignum, 'Name', [ratname ': ' sphname]);
        set(fignum, 'Position', figP(rat_i,:));
    end;
    
    if nargout > 0, aa{rat_i} = V; end
end
