function [x, y] = BlockControl(obj, action, x, y)
% This file is mainly connected with OdorSection and RewardsSection

GetSoloFunctionArgs;
switch action,
    case 'init',
        NumeditParam(obj, 'block_size', 20, x, y, 'label','Trials/Block');
        
        SoloParamHandle(obj, 'block', 'value', struct('bgrd',{1}, 'bgrd_nm','name',...
            'left_valve',{1}, 'right_valve',{2}, 'score', 0, 'score_lft',0, 'score_rt', 0));
        SoloParamHandle(obj, 'block_count', 'value', 1);
        SoloParamHandle(obj, 'trial_count', 'value', 0);
        next_row(y);
        NumeditParam(obj, 'score',85, x, y, 'label', 'acceptable score', 'labelfraction',0.6);
        next_row(y);
        MenuParam(obj, 'block_update', {'upon_score', 'upon_block','stay','go_probe'}, 1,x, y);
        SoloFunctionAddVars('OdorSection', 'ro_args', {'block', 'block_count'});
        
        next_row(y);
        SubheaderParam(obj, 'title', 'Block Control', x, y);
      
        % store the value of rat performance, with columns: Score, Hits, Miss, False
        SoloParamHandle(obj, 'perform_left', 'value', ones(maxtrials,4)*(-1)); 
        SoloParamHandle(obj, 'perform_right', 'value', ones(maxtrials,4)*(-1)); 
        SoloParamHandle(obj, 'perform_overall', 'value', ones(maxtrials,4)*(-1));
        SoloParamHandle(obj, 'block_left', 'value', ones(maxtrials/block_size, 4)*(-1));
        SoloParamHandle(obj, 'block_right', 'value', ones(maxtrials/block_size, 4)*(-1));
        SoloParamHandle(obj, 'block_overall', 'value', ones(maxtrials/block_size, 4)*(-1));
        
        SoloFunctionAddVars('RewardsSection', 'ro_args', {'block_size','block_count','perform_left', 'perform_right',...
            'perform_overall','block_left','block_right','block_overall'});
        
    case 'user_specify'
        % if user changed the bgrd_ID which is specified in OdorSection.m
        % change the id accordingly in block structure here.
        block(value(block_count)).bgrd = value(bgrd_ID);
        OdorSection(obj,'update_odor');
        
    case 'update'
        block_updated = 0;
        sides_till_now = side_list(1:n_done_trials);
        % the number of current block
        blk = value(block_count);
        % count the number of trials finished in the current block
        trial_count.value = n_done_trials - (block_count-1)*block_size;
        t46 = value(trial_count)
        % store the background name to the field "bgrd" of the structure of
        % current block. The "bgrd_name" is specified in OdorSection
        block(blk).bgrd_nm = value(bgrd_name); 
        %%%%% specify the valve ID of odor with left or right target.
        %%%%% currently correlated with bgrd ID number.
        block(blk).left_valve = value(L_valve);
        block(blk).right_valve = value(R_valve);            
        if trial_count>= block_size
            left_rw = LeftRewards(n_done_trials - block_size + 1 : n_done_trials);
            right_rw = RightRewards(n_done_trials - block_size + 1 : n_done_trials);
            left_trial_id = find(sides_till_now(n_done_trials - block_size + 1 : n_done_trials));
            right_trial_id = find(sides_till_now(n_done_trials - block_size + 1 : n_done_trials) == 0);
            
            % percent correct choice in the last block
            block(blk).score = sum(left_rw + right_rw)/block_size*100;
            block_overall(blk) = block(blk).score;
            % percent correct choice of the left trials in the last block
            block(blk).score_lft = sum(left_rw)/length(left_trial_id)*100;
            block_left(blk) = block(blk).score_lft;
            % percent correct choice of the right trials in the last block
            block(blk).score_rt =  sum(right_rw)/length(right_trial_id)*100;
            block_right(blk) = block(blk).score_rt;
            % update the next block upon 3 options
            if strcmp(value(block_update), 'upon_score')
                WaterDelivery.value = 3;
                    % update next block upon rats performance
                    % now with overall score
                    if block(blk).score >= score
                        % change background odor to next one
                        block(blk+1).bgrd = block(blk).bgrd + 1;
                        % if all backgrounds are run through, start from
                        % the first one again.
                        if block(blk+1).bgrd> length(Bgrd_Names)
                            block(blk+1).bgrd = 1;
                        end
                        block_updated = 1;
                    else
                        block(blk+1).bgrd = block(blk).bgrd;
                    end
              %      bgrd_ID.value = block(blk+1).bgrd;
            elseif strcmp(value(block_update), 'upon_block')
                WaterDelivery.value = 3;
                   % update next block anyway
                    block(blk+1).bgrd = block(blk).bgrd + 1;
                    if block(blk+1).bgrd > length(Bgrd_Names)
                        block(blk+1).bgrd = 1;
                    end
              %      bgrd_ID.value = block(blk+1).bgrd;
                    block_updated = 1;
            elseif strcmp(value(block_update), 'stay')
                WaterDelivery.value = 3;
                    % do nothing
            elseif strcmp(value(block_update), 'go_probe')
                    WaterDelivery.value = 4;
                    block(blk+1).bgrd = block(blk).bgrd;
                    block_updated = 1;
            end
            
            blk = blk+1;
            block_count.value = blk;
            
           % update performance plotting
        
           
           new_start = 1;
        if block_updated
            new_start = (block_count-1)*block_size+1;
        end
        if ~strcmp(value(block_update),'upon_block')
            left_index = find(sides_till_now(new_start:n_done_trials));
            right_index = find(sides_till_now(new_start:n_done_trials) == 0);
            if length(left_index) >=block_size/2 & sides_till_now(n_done_trials)
                perform_left(n_done_trials,2) = sum(LeftRewards(left_index(end-block_size/2+1:end))); % left hits over the last 20 trials
                perform_left(n_done_trials,1) = (perform_left(n_done_trials,2)/block_size/2)*100; % left score over the last 20 trials
                perform_left(n_done_trials,3) = block_size/2 - perform_left(n_done_trials,2); % left missed trials
                perform_left(n_done_trials,4) = 0;  % not decided yet
            end
            if length(right_index) >= block_size/2 & ~sides_till_now(n_done_trials)
                perform_right(n_done_trials,2) = sum(RightRewards(right_index(end-block_size/2+1:end))); % right hits over the last 20 trials
                perform_right(n_done_trials,1) = (perform_right(n_done_trials,2)/block_size/2)*100; % ritht score over the last 20 trials
                perform_right(n_done_trials,3) = block_size/2 - perform_right(n_done_trials,2); % right missed trials
                perform_right(n_done_trials,4) = 0;  % not decided yet
            end
        end
           
        end
end
        
