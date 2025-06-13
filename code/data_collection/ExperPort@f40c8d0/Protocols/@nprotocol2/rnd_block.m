function [probvec_waterLeft, probvec_waterRight, probvec_shockLeft, probvec_shockRight] = rnd_block(obj, action, x, y)

%This function creates the session profile
% i.e. the vector containing all probabilities (for shock and/or water
% delivery)
% persistent probvec_waterLeft probvec_waterRight probvec_shockLeft probvec_shockRight
GetSoloFunctionArgs;

buildCheck.value = 'ALREADY BUILT                    ';
switch action,

    %%% START OF CASES %%%
    case 'init',
        filename1 = ['Protocols\@nprotocol2\WaterProfiles\',value(waterProfileLeft)];
        filename2 = ['Protocols\@nprotocol2\WaterProfiles\',value(waterProfileRight)];
        filename3 = ['Protocols\@nprotocol2\ShockProfiles\',value(shockProfileLeft)];
        filename4 = ['Protocols\@nprotocol2\ShockProfiles\',value(shockProfileRight)];
        if (length(load(filename1)) ~= length(load(filename2))) || (length(load(filename1)) ~= length(load(filename3))) || (length(load(filename1)) ~= length(load(filename4)))
            warndlg('Probability vector lengths do not match!!!');
        end;
        
    case 'waterLeft',
        filename = ['Protocols\@nprotocol2\WaterProfiles\',value(waterProfileLeft)];
        probability_vec = load(filename);
        local_profile_vec = [];
        for i=(1:length(probability_vec))
            vec=zeros(1,value(blockSize));
            vec(1:value(blockSize)*probability_vec(i))=1;
            dummy=rand(1,value(blockSize));
            [dummy_sorted, dummy_index] = sort(dummy);
            local_profile_vec((i-1)*value(blockSize)+1:i*value(blockSize)) = vec(dummy_index);
        end;
        probvec_waterLeft.value = local_profile_vec;
        
    case 'waterRight',
        filename = ['Protocols\@nprotocol2\WaterProfiles\',value(waterProfileRight)];
        probability_vec = load(filename);
        local_profile_vec = [];
        for i=(1:length(probability_vec))
            vec=zeros(1,value(blockSize));
            vec(1:value(blockSize)*probability_vec(i))=1;
            dummy=rand(1,value(blockSize));
            [dummy_sorted, dummy_index] = sort(dummy);
            local_profile_vec((i-1)*value(blockSize)+1:i*value(blockSize)) = vec(dummy_index);
        end;
        probvec_waterRight.value = local_profile_vec;
        
    case 'shockLeft',
        filename = ['Protocols\@nprotocol2\ShockProfiles\',value(shockProfileLeft)];
        probability_vec = load(filename);
        local_profile_vec = [];
        for i=(1:length(probability_vec))
            vec=zeros(1,value(blockSize));
            vec(1:value(blockSize)*probability_vec(i))=1;
            dummy=rand(1,value(blockSize));
            [dummy_sorted, dummy_index] = sort(dummy);
            local_profile_vec((i-1)*value(blockSize)+1:i*value(blockSize)) = vec(dummy_index);
        end;
        probvec_shockLeft.value = local_profile_vec;

    case 'shockRight',
        filename = ['Protocols\@nprotocol2\ShockProfiles\',value(shockProfileRight)];
        probability_vec = load(filename);
        local_profile_vec = [];
        for i=(1:length(probability_vec))
            vec=zeros(1,value(blockSize));
            vec(1:value(blockSize)*probability_vec(i))=1;
            dummy=rand(1,value(blockSize));
            [dummy_sorted, dummy_index] = sort(dummy);
            local_profile_vec((i-1)*value(blockSize)+1:i*value(blockSize)) = vec(dummy_index);
        end;
        probvec_shockRight.value = local_profile_vec;
        

    
     %%% END OF CASES %%%
        
%         if value(buildStatus) == 0,
%             buildStatus.value = 1;
%         else
%             buildStatus.value = 0;
%         end;
        
    otherwise
        error(['Don''t know how to deal with action ' action]);
end;


ntrials_available.value = (length(value(probvec_waterLeft))+length(value(probvec_waterRight))+length(value(probvec_shockLeft))+length(value(probvec_shockRight)))/4;