function sma = add_stimulus(sma,wave_name,state_name)

temp = strcmp(lower(sma.state_name_list(:,1)),lower(state_name)) == 1;

if sum(temp) ~= 0
    statenum = sma.state_name_list{temp,2} + 1;
    currwave = sma.states{statenum,end};
    if currwave == 0
        sma.states{statenum,end} = wave_name;
    elseif ischar(currwave)
        sma.states{statenum,end} = [currwave,' + ',wave_name];
    end
else
    for i = 1:length(sma.sched_waves);
        if strcmp(sma.sched_waves(i).name,state_name) == 1
            currwave = sma.sched_waves(i).trigger_on_up;
            if isempty(currwave) 
                sma.sched_waves(i).trigger_on_up = wave_name;
            else
                sma.sched_waves(i).trigger_on_up = [currwave,' + ',wave_name];
            end
        end
    end
end