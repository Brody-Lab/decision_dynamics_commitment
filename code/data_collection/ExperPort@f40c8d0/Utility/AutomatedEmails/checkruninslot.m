function output = checkruninslot(Ts,Te,slot)

output = 0;

if     slot == 1; SS = '00:00:00'; SE = '03:00:00';
elseif slot == 2; SS = '01:00:00'; SE = '05:00:00';
elseif slot == 3; SS = '03:00:00'; SE = '07:00:00';
elseif slot == 4; SS = '07:00:00'; SE = '11:00:00';
elseif slot == 5; SS = '09:00:00'; SE = '13:00:00';
elseif slot == 6; SS = '11:00:00'; SE = '15:00:00';
elseif slot == 7; SS = '15:00:00'; SE = '19:00:00';
elseif slot == 8; SS = '17:00:00'; SE = '21:00:00';
elseif slot == 9; SS = '19:00:00'; SE = '23:00:00';
end

test1 = timediff(SS,Te,2);
test2 = timediff(Ts,SE,2);

if test1 < 0; output = -1; end
if test2 < 0; output =  1; end