function [times]  = state_times(ratname, from,to)
% Returns struct where key is state and value is an array of start and end
% times of each occurrence of the state


% from = getdate(dfrom);
% to = getdate(dto);

dates = get_files(ratname, 'fromdate',from, 'todate',to);


times = {}; % key: statename, value: array of start and end times
for d = 1:length(dates)
    date = dates{d};
    p = get_pstruct(ratname,date);
    for k = 1:rows(p)
        curr = p{k};
        f = fieldnames(curr);
        for m = 1:length(f)
            if ~isfield(times, f{m})
                eval(['times.' f{m} ' = [];']);
            end;
            str=['times.' f{m} ' = vertcat(times.' f{m} ', curr.' f{m} ');'];
            eval(str);
        end;
    end;
end; 