
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
         
        %Get vr structure
        vr = value(solo_vr);
        
        %If at least one trial done
        experiment_ended = false;
        if n_done_trials > 0
            
            %Get trial info from virmen machine
            raw_trial = comm.tcp.get_binary_mat_file(solo_tcp_client);
            virmen_data_trial = comm.utility.load_binary_data(raw_trial); 
            
            final_data_trial     = vr.fieldsObj.get_trial_data(vr, virmen_data_trial, raw_events);
            %Store trial info in logger table
            vr.experimentLog.setTrialInfo(final_data_trial);
            
            session_updated_info = vr.fieldsObj.get_session_updated_data(vr);
            vr.experimentLog.updateSessionInfo(session_updated_info);
            
            experiment_ended = VirmenBControl.level_assignment.auto_terminate_session(...
                vr.experimentLog.session);
            
            if experiment_ended
                error('experiment already ended');
            end
            vr.level = VirmenBControl.level_assignment.decide_maze_advancement(vr);
            %Write block data if maze has changed
            if vr.level.maze_changed
                block_data     = vr.fieldsObj.get_block_data(vr);
                vr.experimentLog.setBlockInfo(block_data);
                vr.experimentLog.newBlock();
            end
                      
            vr.experimentLog.newTrial();
                
        end
        

        %Get next trial information
        vr.trial_info = VirmenBControl.draw_trials.prepare_next_trial(vr);
        
        
        curr_maze = vr.protocol_file.mazes(vr.trial_info.maze_id);
        max_cues  = vr.protocol_file.globalSettings{2};
        cue_structure = VirmenBControl.stimulus_gen.generate_cues(curr_maze, max_cues);
      
        
        vr.trial_info = VirmenBControl.utils.cat_struct(vr.trial_info, cue_structure);
%         params_modify_trial = vr.protocol_file.extra_params.change_colors_inside_region;
%         vr.trial_info = VirmenBControl.draw_trials.modify_trial_left_right_zones(...
%             vr.trial_info, vr.current_maze.lCue, ...
%             params_modify_trial.only_left_towers_ratio, ...
%             params_modify_trial.only_right_towers_ratio, ...
%             params_modify_trial.order_zones);
        
        vr.trial_info.experiment_ended = experiment_ended;

        disp('vr.trial_info.cuePos');
        disp(vr.trial_info.cuePos);
        
        %Communicate trial for virmen
        trial_comm      = VirmenBControl.draw_trials.get_trial_for_virmen(vr);         
        binary_trial = virmen_utils.struct2binary(vr.trial_info);
        comm.tcp.send_binary_mat_file(solo_tcp_client, binary_trial);
        
        solo_ac_trial.value = vr.trial_info;
        value(solo_ac_trial);
        
        solo_vr.value = vr;
        value(solo_vr);
              
end
