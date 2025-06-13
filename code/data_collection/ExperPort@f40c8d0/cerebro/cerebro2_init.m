function cerebro_obj = cerebro2_init()
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
            cerebro_obj=serial(available_ports{p}); %#ok<TNMLP>
            set(cerebro_obj,'BaudRate',57600);
            set(cerebro_obj,'terminator','CR/LF');
            set(cerebro_obj,'timeout',0.05);
            fopen(cerebro_obj);
            
            cleanupObj = onCleanup(@()fclose(cerebro_obj)); % this line ensures closure of the serial port connection object and avoids having to restart matlab                            
            
            cerebro2_send(cerebro_obj,'N');
            cerebro_output = cerebro2_scan(cerebro_obj);
            
            for i = 1:numel(cerebro_output)
                if ~isempty(strfind(cerebro_output{i},'Base Channel'))
                    fprintf('Base Station initialized.\n');
                    fclose(cerebro_obj);
                    return
                end
            end
            
            fclose(cerebro_obj);
            cerebro_obj=[];
            
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