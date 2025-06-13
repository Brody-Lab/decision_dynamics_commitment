function ao_trig_handler(obj,event)

% Get the trigger time from the object.
    tictoc=obj.InitialTriggerTime;
    
    % Form a string using datestr for HH:MM:SS and sprintf for fraction.
    %msg=[ 'Triggered ' datestr(datenum(tictoc),13) ...
    %		sprintf('%d', 1000*(tictoc(end)-floor(tictoc(end))) ) ];
    
    message('ao',['Triggered ' datestr(datenum(tictoc),13)]);
