
function [x, y] = HitSection(obj, action, x, y)

GetSoloFunctionArgs(obj);

switch action
    
    %% prepare_next_trial
    % -----------------------------------------------------------------------
    %
    %         PREPARE_NEXT_TRIAL
    %
    % -----------------------------------------------------------------------
    
    case 'prepare_next_trial'
        
        toc
        disp(['n_done_trials: .....................', num2str(n_done_trials)])
        n_done_trials
        
        if n_done_trials > 0
            
            %PokesPlotSection(obj, 'time_axis', 0, 20);
            
            tic
            struct_map = ExperimentLogMin.TRAIL_COMM_SAMPLE_STRUCT_MAP;
            current_trial = comm.tcp.get_array_structure(solo_tcp_client,struct_map);
            toc
            
            
            current_trial
            
            position = current_trial.position;
            velocity = current_trial.velocity;
            sensors = current_trial.sensorDots;
            
            tic
            VirmenPlotSection(obj,'plot3', position, velocity, sensors)
            toc
            
        end
        
        trial_idx = value(solo_trial_idx);
        
        ac_trial = solo_virmenSession.trialTable(trial_idx,:);
        ac_block = ac_trial{1,'block'};
        
        ac_maze =  solo_virmenSession.blockTable{...
                        solo_virmenSession.blockTable.block == ac_block, 'level'};
        
        ac_stimuli = getStimuliTrial(obj, ac_trial, solo_virmenSession.test_stimuli);
        ac_stimuli.mazeID = ac_maze;
        ac_stimuli.mainMazeID = ac_maze;
        
        
        binary_stimuli = virmen_utils.struct2binary(ac_stimuli);
        comm.tcp.send_binary_mat_file(solo_tcp_client, binary_stimuli);
        

        trial_idx = trial_idx + 1;
        solo_trial_idx.value = trial_idx;
        value(solo_trial_idx);
        
        solo_ac_stimuli.value = ac_stimuli;
        value(solo_ac_stimuli);
        
end
