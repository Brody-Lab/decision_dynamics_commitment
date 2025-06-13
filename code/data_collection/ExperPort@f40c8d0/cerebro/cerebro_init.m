function cerebro_obj = cerebro_init()
    % note: my preference is to always close serial port objects locally
    % with an oncleanup call to fclose. this requires opening locally too,
    % but seems a safer way of managing serial port objects and is robust
    % to functions crashing with serial port objects open.
    try
        hw_info=instrhwinfo('serial');
    catch
        error('Serial communication is not available in matlab. This means you either a) don''t have the Instrument Control Toolbox or b) are running an older version of Matlab on an unsupported system.');
    end
    available_ports = hw_info.AvailableSerialPorts;
    cerebro_obj=[];
    for p=1:length(available_ports)
        try
            cerebro_obj=serial(available_ports{p});
            set(cerebro_obj,'terminator','');
            set(cerebro_obj,'timeout',0.5);
            fopen(cerebro_obj);
            cleanupObj = onCleanup(@()fclose(cerebro_obj)); % this line ensures closure of the serial port connection object and avoids having to restart matlab                            
            warning('off','MATLAB:serial:fscanf:unsuccessfulRead'); % you need to fprintf to the base station a couple of times before it kicks in. Don't know why.
            fprintf(cerebro_obj,'F,0');
            fscanf(cerebro_obj);
            fprintf(cerebro_obj,'F,0');
            cerebro_output=fscanf(cerebro_obj);
            warning('on','MATLAB:serial:fscanf:unsuccessfulRead');            
            if ~isempty(strfind(cerebro_output,'Filter updated'))
                fprintf('Cerebro initialized.\n');
                fclose(cerebro_obj);
                return
            else
                cerebro_obj=[];
            end
            fclose(cerebro_obj);
        catch
            try
                fclose(cerebro_obj);
            end
            cerebro_obj=[];
        end
    end
    if isempty(cerebro_obj)
       fprintf('Cannot connect to Cerebro base station. Either one is not connected or the serial port is unavailable.\n'); 
    end
end