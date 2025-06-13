function ai_trig_handler(obj,event)

    tictoc=obj.InitialTriggerTime;
    
    % Form a string using datestr for HH:MM:SS and sprintf for fraction.
    %msg=[ 'Triggered ' datestr(datenum(tictoc),13) ...
    %		sprintf('%d', 1000*(tictoc(end)-floor(tictoc(end))) ) ];
    
    message('ai',['Triggered ' datestr(datenum(tictoc),13)]);
