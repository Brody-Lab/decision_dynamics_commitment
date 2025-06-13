function [] = paramChange(obj, action)
%SOUND Summary of this function goes here
%   Detailed explanation goes here
GetSoloFunctionArgs;
switch action,
    case 'beginner',
        if strcmp(beginner, 'YES')
            cPokeTime.value = 0.001;
            if strcmp(click_or_sound, 'SOUND')
                cClickTime.value = value(soundTime);
            elseif strcmp(click_or_sound, 'CLICK')
                cClickTime.value = 0.005;
            end
            timeto_lrPoke.value = 10000;
            lPokePVO.value = 0.001;
            rPokePVO.value = 0.001;
            leftValve.value = 0.164;
            rightValve.value = 0.187;
            timeOut.value = 1;
            leftTimetoSuction.value = 3;
            rightTimetoSuction.value = 3;
            leftSuctionTime.value = 0.001;
            rightSuctionTime.value = 0.001;
        elseif strcmp(beginner, 'NO')
            cPokeTime.value = 0.1;
            if strcmp(click_or_sound, 'SOUND')
                cClickTime.value = value(soundTime);
            elseif strcmp(click_or_sound, 'CLICK')
                cClickTime.value = 0.005;
            end
            timeto_lrPoke.value = 3;
            lPokePVO.value = 0.001;
            rPokePVO.value = 0.001;
            leftValve.value = 0.164;
            rightValve.value = 0.187;
            timeOut.value = 0.8;
            leftTimetoSuction.value = 1.5;
            rightTimetoSuction.value = 1.5;
            leftSuctionTime.value = 0.001;
            rightSuctionTime.value = 0.001;
            blockSize.value = 40;
            xRange.value = value(blockSize)+10;
        end
        
    case 'sound'
        if strcmp(click_or_sound, 'SOUND')
            cClickTime.value = value(soundTime);
        elseif strcmp(click_or_sound, 'CLICK')
            cClickTime.value = 0.005;
        end
    case 'water',
%         if parsed_events == [],
%              volumeLossLeft.value = 0;
%              volumeLossRight.value = 0;
% else
        if ~isempty(parsed_events.states.l_poke_in_shock_start) && probvec_waterLeft(n_done_trials) == 1,
           volumeLossLeft.value = value(volumeLossLeft) + 0.000016;
        elseif ~isempty(parsed_events.states.r_poke_in_shock_start) && probvec_waterRight(n_done_trials) == 1, 
           volumeLossRight.value = value(volumeLossRight) + 0.000016;
        end
       
end;