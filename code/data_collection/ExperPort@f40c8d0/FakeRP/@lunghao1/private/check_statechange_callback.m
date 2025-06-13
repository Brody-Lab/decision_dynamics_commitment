function [] = check_statechange_callback(lh1)

    if ~isempty(lh1.statechange_callback),
        if ~iscell(lh1.statechange_callback),      feval(lh1.statechange_callback,    lh1); 
        else for i=1:length(statechange_callback), feval(lh1.statechange_callback{i}, lh1); end;    
        end;
    end;
