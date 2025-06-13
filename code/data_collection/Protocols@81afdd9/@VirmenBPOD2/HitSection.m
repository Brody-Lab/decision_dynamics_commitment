
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
        
        
        trial_idx = value(solo_trial_idx);
        
        ac_trial = solo_virmenSession.trialsTable(trial_idx,:);
        ac_stiumuli = getStimuli(obj, ac_trial, solo_virmenSession.test_stimuli);
        
        binary_stimuli = virmen_utils.struct2binary(ac_stiumuli);
        comm.tcp.send_binary_mat_file(tcp_client, binary_stimuli);
        
        
        trial_idx = trial_idx + 1;
        solo_trial_idx.value = trial_idx;
        value(solo_trial_idx)
        
        
        if n_done_trials > 0
            
            %parsed_events
            %save('C:\ratter\Protocols\@PCLink_Virmen2\parsed_events_now', 'parsed_events');
     
            
        end
        
end
