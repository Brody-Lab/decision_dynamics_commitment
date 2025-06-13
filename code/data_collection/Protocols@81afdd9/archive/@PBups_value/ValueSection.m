function [x,y] = ValueSection(obj, action, varargin)

GetSoloFunctionArgs;

switch action
    
    case 'init'
        
        x = varargin{1};
        y = varargin{2};
        
        ToggleParam(obj, 'value_task', 1, x, y, ...
            'OffString', 'flat feedback', ...
            'OnString',  'value-based feedback', ...
            'TooltipString', sprintf(['\n' ...
            'If flat feedback, all trials are worth the same amount of water, set in WaterValvesSection.\n' ...
            'If value feedback, the rat receives water proportional to the number of clicks on the chosen side, but not less than the minimum or more than the maximum.\n']));
        set_callback(value_task, {mfilename, 'value_task'});
        next_row(y);
        
        ToggleParam(obj, 'less_than_min', 1, x, y, ...
            'OffString', 'set to zero', ...
            'OnString',  'set to min', ...
            'TooltipString', sprintf(['\n' ...
            'If the water requested is less than the minimum amount of water allowed, should we give out min, or should we give out zero?']));
        set_callback(less_than_min, {mfilename, 'update_water'});
        next_row(y);
        
        NumeditParam(obj, 'water_per_bup', 0.1, x, y, 'TooltipString', 'The amount of water to give the rat per click on the chosen side (uL)');
        set_callback(water_per_bup, {mfilename, 'update_water'});
        set_callback_on_load(water_per_bup, 1);
        next_row(y);
        
        NumeditParam(obj, 'min_water', 0, x, y, 'TooltipString', 'The smallest amount of water to deliver for one trial (uL)');
        set_callback(min_water, {mfilename, 'update_water'});
        set_callback_on_load(min_water, 1);
        next_row(y);
        
        NumeditParam(obj, 'max_water', 50, x, y, 'TooltipString', 'The most water to deliver on one trial (uL)');
        set_callback(max_water, {mfilename, 'update_water'});
        set_callback_on_load(max_water, 1);
        next_row(y);
        
        SubheaderParam(obj, 'title', 'ValueSection', x, y);
        
        
    case 'get_feedback_type'
        % Returns 0 for standard PBups, 1 for value-based PBups
        x = value(value_task); 
        
    case 'value_task'
        % The value_task parameter has been changed.  Enable or disable
        % fields appropriately
        if value(value_task) % If a value task
            enable(water_per_bup);
            enable(min_water);
            enable(max_water);
            ValueSection(obj, 'update_water');
        else % it's not a value task
            disable(water_per_bup);
            disable(min_water);
            disable(max_water);
            WaterValvesSection(obj, 'reinit')
        end
        
        
        
    case 'update_water'
        % Get the bup times for the upcoming trial
        bupTimes = PBupsSection(obj, 'get_bup_times');
        sample_duration = PBupsSection(obj,'get','sample_duration');
        nBupsRight = sum(bupTimes.right < sample_duration);
        nBupsLeft = sum(bupTimes.left < sample_duration);
        
        rightWater = water_per_bup * nBupsRight;
        leftWater = water_per_bup * nBupsLeft;
        
        if min_water > max_water
            error('min_water must be less than max_water');
        end
        
        % Check that they're within acceptable range
        rightWater = min(rightWater, value(max_water));
        leftWater = min(leftWater, value(max_water));
        
        if value(less_than_min)
            if rightWater < min_water
                rightWater = value(min_water);
            end
            if leftWater < min_water
                leftWater = value(min_water);
            end
        else
            if rightWater < min_water
                rightWater = 0;
            end
            if leftWater < min_water
                leftWater = 0;
            end
        end
        
        WaterValvesSection(obj, 'set_water_amounts', leftWater, rightWater);
        
end