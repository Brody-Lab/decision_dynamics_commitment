function [flist] = get_files(ratname, varargin)

% Returns the dates and file versions ("a","b", etc.,) for given rat for all dates in specified range
% (inclusive on both ends)
pairs = { ...
    'fromdate', '000000' ; ...
    'todate', '999999' ; ...
    };
parse_knownargs(varargin, pairs);

ddir = Shraddha_filepath(ratname, 'd');
flist = {};
ratrow = rat_task_table(ratname);
exc_dates = ratrow{1,rat_task_table('','action','get_excluded_col')}; % get dates to be excluded from analyses


for idx = 1:length(ddir)
    data = dir(ddir{idx});
    for f = 1:length(data)
        fname = data(f).name;
        if length(fname) > 3 & strcmp(fname(1:4), 'data')
            dt = fname(end-10:end-5);
            dtext = fname(end-10:end-4);
            
            if (str2num(dt) >= str2num(fromdate)) & (str2num(dt) <= ...
                    str2num(todate))
                if strcmpi(dt,'070920')
                    2;
                end;
                if isempty(find(strcmpi(exc_dates, dtext)))
                    flist{end+1,1} = [dt fname(end-4)];
                end;
            end;
            
        end;
    end;
end;

flist = sort(flist);
flist = unique(flist);
