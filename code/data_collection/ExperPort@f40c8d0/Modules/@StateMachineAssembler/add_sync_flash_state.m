function sma = add_sync_flash_state(sma)

%Adds a state that turns on a LED connected to the center port water valve.
%This will be used as a sync signal for aligning video to parsed_events.
%
%Written by Chuck 2023

do_sync_state  = bSettings('get','VIDEO','center_sync_led');
sync_flash_dur = bSettings('get','VIDEO','sync_flash_dur');
center1water   = bSettings('get','DIOLINES','center1water');

if isnan(center1water)
    center1water = bSettings('get','VIDEO','sync_led_line');
end

if isnan(sync_flash_dur); sync_flash_dur = 0.1; end

if do_sync_state == 1 && ~isnan(center1water)
    sma = add_state(sma, 'name','sync_flash',...
       'self_timer', sync_flash_dur, ...
       'input_to_statechange', {'Tup', 'current_state+1'}, ...
       'output_actions', {'DOut', center1water}); 
end