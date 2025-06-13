function [] = check_aoutchange_callback(lh1)

    if ~isempty(lh1.aoutchange_callback),
        if ~iscell(lh1.aoutchange_callback), feval(lh1.aoutchange_callback, lh1); 
        else
            if size(lh1.aoutchange_callback,2)==1, 
                for i=1:length(lh1.aoutchange_callback), feval(lh1.aoutchange_callback{i}, lh1); end;
            else
                for i=1:size(lh1.aoutchange_callback,1), 
                    feval(lh1.aoutchange_callback{i,1}, lh1, lh1.aoutchange_callback{i,2}); 
                end;
            end;
        end;
    end;
