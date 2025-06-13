function [] = check_doutchange_callback(lh1)

    if ~isempty(lh1.doutchange_callback),
        if ~iscell(lh1.doutchange_callback),      feval(lh1.doutchange_callback,    lh1); 
        else for i=1:length(doutchange_callback), feval(lh1.doutchange_callback{i}, lh1); end;    
        end;
    end;
