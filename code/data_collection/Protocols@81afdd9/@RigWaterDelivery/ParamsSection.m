function [x, y] = ParamsSection(obj, action, x, y)

GetSoloFunctionArgs;

switch action
    
    
    case 'init'
        lf = 0.65;
        
        NumeditParam(obj,'drink_time',1,x,y,'labelfraction',lf);
        next_row(y);
        DispParam(obj,'remaining_to_deliver',0,x,y,'labelfraction',lf);
        next_row(y);
        DispParam(obj,'delivered_vol',0,x,y,'labelfraction',lf);
        next_row(y);
        DispParam(obj, 'previously_delivered_vol',0,x,y,'labelfraction',lf);
        next_row(y);
        DispParam(obj,'target_vol',5,x,y,'labelfraction',lf);
        next_row(y);
        DispParam(obj,'ratmass',0,x,y,'labelfraction',lf);
        next_row(y);
        
        NumeditParam(obj,'target_percent',3.5,x,y,'labelfraction',lf);
        next_row(y);
        set_callback(target_percent, {mfilename, 'update'});
        
        ToggleParam(obj,'get_rat_info',0,x,y,'OnString','Get Rat Info','OffString','Get Rat Info');
        set_callback(get_rat_info, {mfilename, 'update'});
        %set_callback(get_rat_info, {mfilename, 'update_target_percent'});
        % TODO: Set callback to make this read the rat's weight, water
        % earned earlier today, update the target_vol.  Maybe have a disp
        % param for earlier_delivered_vol
        pause(0.01);
        ParamsSection(obj,'update');
        
    case 'trial_completed'
        vol = WaterValvesSection(obj,'get_water_volumes');
        delivered_vol.value = value(delivered_vol) + vol/1000;
        remaining_to_deliver.value = value(target_vol) - value(delivered_vol) - value(previously_delivered_vol);
        
    case 'get_params'
        
        x.drink_time = value(drink_time);
        x.remaining_to_deliver = value(remaining_to_deliver);
        
    case 'update'
        % Find the last entry for the rat in the watervolume table
        [experimenter, ratname] = SavingSection(obj, 'get_info');
        
        [date, volume] = bdata(['select dateval, totalvol from ratinfo.rigwater where ratname="{S}" order by dateval desc limit 1'], ratname);
        if datenum(date) == today
            previously_delivered_vol.value = volume;
        end
        get_rat_info.value = 0;
        
        [mdate, mass] = bdata(['select date, mass from ratinfo.mass where ratname="{S}" order by date desc limit 1'], ratname);
        if isnumeric(mass) && numel(mass) == 1
            target_vol.value = mass*value(target_percent)/100;
            ratmass.value = mass;
        end
        
        rtd = value(remaining_to_deliver);
        remaining_to_deliver.value = value(target_vol) - value(delivered_vol) - value(previously_delivered_vol);
        
        if value(remaining_to_deliver) > 0 && rtd < 0
            % If we just updated from a regime where the rat needs more
            % water to oen where he doesn't
            RigWaterDelivery(obj, 'prepare_next_trial')
        end
    otherwise,
        warning('Unknown action! "%s"\n', action);
end


