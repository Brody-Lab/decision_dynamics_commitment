% Create and send state matrix.
%
% Santiago Jaramillo - 2007.08.24
%
%%% CVS version control block - do not edit manually
%%%  $Revision$
%%%  $Date$
%%%  $Source$


%%% BUGS:
%
% [2007.10.04] If the duration of sound is changed, the State Matrix is not
% updated but the sound duration is.  This is a problem if Duration is changed
% from large value to a small one, since there will still be punishment after
% the sound off-set.  Updating the matrix on update_sounds didn't work.


function sma = StateMatrixSection(obj, action)

GetSoloFunctionArgs;
%%% Imported objects (see protocol constructor):
%%%  'PunishExtraTime'
%%%  'PreStimMean'
%%%  'PreStimRange'
%%%  'RewardAvail'
%%%  'WaterDelivery' (from SidesSection.m)
%%%  'RelevantSide'  (from SidesSection.m)
%%%  'EarlyWithdrawal'
%%%  'CueEveryNtrials'
%%%  'CueTrialsList'
%%%  'RewardSideList'
%%%  'DistractorList'
%%%  'SoundDuration' (from SoundsSection.m)


global left1water;
global right1water;

switch action
  case 'update',
% -- Variables for stimuli and states changes --
NextRewardSide = RewardSideList(n_done_trials);
NextDistractorType = DistractorList(n_done_trials);
%%% Shouldn't it be n_done_trials+1 ?  sjara 2007.08.14

CueDuration = value(SoundDuration);                  % seconds
%ValveDuration = 0.15;               % seconds
[ValveDurationL,ValveDurationR] = WaterValvesSection(obj,'get_water_times');


%RandDelay = (value(PreStimMax)-value(PreStimMin))*rand(1) + value(PreStimMin);          % Random delay before first stim. 
RandDelay = (value(PreStimRange))*(rand(1)-0.5) + value(PreStimMean);          % Random delay before first stim. 

IndSoundL1R1 = SoundManagerSection(obj, 'get_sound_id', 'SoundL1R1');
IndSoundL2R1 = SoundManagerSection(obj, 'get_sound_id', 'SoundL2R1');
IndSoundL1R2 = SoundManagerSection(obj, 'get_sound_id', 'SoundL1R2');
IndSoundL2R2 = SoundManagerSection(obj, 'get_sound_id', 'SoundL2R2');
IndPunishNoise = SoundManagerSection(obj, 'get_sound_id', 'PunishNoise');
IndSoundL1 = SoundManagerSection(obj, 'get_sound_id', 'L1');
IndSoundL2 = SoundManagerSection(obj, 'get_sound_id', 'L2');
IndSoundR1 = SoundManagerSection(obj, 'get_sound_id', 'R1');
IndSoundR2 = SoundManagerSection(obj, 'get_sound_id', 'R2');

if(NextRewardSide=='l')
    CorrectPort = 'Lin';
    WrongPort = 'Rin';
    RewardValve = left1water;       % *** Reward on LEFT ***
    ValveDuration = ValveDurationL;
    if(strcmp(value(RelevantSide),'left'))  % -- Relevant Stim comes from LEFT --
        if(~mod(n_done_trials,value(CueEveryNtrials))) %%% Cue trial
            IndSoundThisTrial = IndSoundL1;
            CueTrialsList(n_done_trials) = 1;
            fprintf('********************* NEXT IS CUE TRIAL *********************\n');
        else %%% Normal trial (non-cue trial)
            if(NextDistractorType==1)       % Distractor Type: left
                IndSoundThisTrial = IndSoundL1R1;
            else                            % Distractor Type: right
                IndSoundThisTrial = IndSoundL1R2;               
            end
        end
    else                                    % -- Relevant Stim comes from RIGHT --
        if(~mod(n_done_trials,value(CueEveryNtrials))) %%% Cue trial
            IndSoundThisTrial = IndSoundR1;
            CueTrialsList(n_done_trials) = 1;
            fprintf('********************* NEXT IS CUE TRIAL *********************\n');
        else %%% Normal trial (non-cue trial)
            if(NextDistractorType==1)       % Distractor Type: left
                IndSoundThisTrial = IndSoundL1R1;
            else                            % Distractor Type: right
                IndSoundThisTrial = IndSoundL2R1;               
            end
        end
    end
else
    CorrectPort = 'Rin';
    WrongPort = 'Lin';
    RewardValve = right1water;      % *** Reward on RIGHT ***
    ValveDuration = ValveDurationR;
    if(strcmp(value(RelevantSide),'left'))  % -- Relevant Stim comes from LEFT --
        if(~mod(n_done_trials,value(CueEveryNtrials))) %%% Cue trial
            IndSoundThisTrial = IndSoundL2;
            CueTrialsList(n_done_trials) = 1;
            fprintf('********************* NEXT IS CUE TRIAL *********************\n');
        else
            if(NextDistractorType==1)       % Distractor Type: left
                IndSoundThisTrial = IndSoundL2R1;
            else                            % Distractor Type: right
                IndSoundThisTrial = IndSoundL2R2;               
            end
        end
    else                            % -- Relevant Stim comes from RIGHT --
        if(~mod(n_done_trials,value(CueEveryNtrials))) %%% Cue trial
            IndSoundThisTrial = IndSoundR2;
            CueTrialsList(n_done_trials) = 1;
            fprintf('********************* NEXT IS CUE TRIAL *********************\n');
        else
            if(NextDistractorType==1)       % Distractor Type: left
                IndSoundThisTrial = IndSoundL1R2;
            else                            % Distractor Type: right
                IndSoundThisTrial = IndSoundL2R2;               
            end
        end
    end
end


sma = StateMachineAssembler('full_trial_structure');

sma = add_state(sma, 'name', 'wait_for_cpoke', ...
                'input_to_statechange', {'Cin', 'pre_cue'},...
                'output_actions',{'SoundOut',-IndPunishNoise});

sma = add_state(sma, 'name', 'pre_cue', ...
                'self_timer', RandDelay,...
                'input_to_statechange', {'Cout','wait_for_cpoke','Tup', 'play_cue'});

% -- If DIRECT delivery --
if strcmpi(value(WaterDelivery), 'direct')
    sma = add_state(sma, 'name', 'play_cue', ...
                'self_timer', CueDuration,...
                'input_to_statechange', {'Tup', 'directtrial'},...
                'output_actions', {'SoundOut', IndSoundThisTrial});
% -- Otherwise wait for answer poke --
else
    if(strcmp(value(EarlyWithdrawal),'punish'))
        sma = add_state(sma, 'name', 'play_cue', ...
                        'self_timer', CueDuration,...
                        'input_to_statechange', {'Tup', 'wait_for_apoke', 'Cout', 'SilenceCue'},...
                        'output_actions', {'SoundOut', IndSoundThisTrial});
        sma = add_state(sma, 'name', 'SilenceCue', ...
                        'self_timer', 0.005,...
                        'input_to_statechange', {'Tup', 'WithdrawalPunish'},...
                        'output_actions', {'SoundOut', -IndSoundThisTrial});
    else
        sma = add_state(sma, 'name', 'play_cue', ...
                        'self_timer', CueDuration,...
                        'input_to_statechange', {'Tup', 'wait_for_apoke'},...
                        'output_actions', {'SoundOut', IndSoundThisTrial});
    end
end


% -- If NEXT CORRECT POKE (stay in this state when miss) --
if strcmpi(value(WaterDelivery), 'next corr poke')
sma = add_state(sma, 'name', 'wait_for_apoke', ...
                'self_timer', value(RewardAvail),...
                'output_actions', {'SoundOut', -IndSoundThisTrial},...
                'input_to_statechange', ...
                {CorrectPort, 'hittrial',WrongPort, 'misstrial','Tup', 'timeouttrial'});
% -- If ONLY WHEN CORRECT POKE (end trial if miss) --
else
sma = add_state(sma, 'name', 'wait_for_apoke', ...
                'self_timer', value(RewardAvail),...
                'output_actions', {'SoundOut', -IndSoundThisTrial},...
                'input_to_statechange', ...
                {CorrectPort, 'correcttrial',WrongPort, 'errortrial','Tup', 'timeouttrial'});
end


sma = add_state(sma, 'name', 'directtrial', ...
                'self_timer', 0.001,...
                'input_to_statechange', {'Tup', 'reward'});
sma = add_state(sma, 'name', 'hittrial', ...
                'self_timer', 0.001,...
                'input_to_statechange', {'Tup', 'reward'});
sma = add_state(sma, 'name', 'misstrial', ...
                'self_timer', 0.001,...
                'input_to_statechange', {'Tup', 'wait_for_apoke'});
sma = add_state(sma, 'name', 'correcttrial', ...
                'self_timer', 0.001,...
                'input_to_statechange', {'Tup', 'reward'});
sma = add_state(sma, 'name', 'errortrial', ...
                'self_timer', 0.001,...
                'input_to_statechange', {'Tup', 'punish'});
sma = add_state(sma, 'name', 'timeouttrial', ...
                'self_timer', 0.001,...
                'input_to_statechange', {'Tup', 'final_state'});


sma = add_state(sma, 'name', 'reward', ...
                'self_timer', ValveDuration,...
                'input_to_statechange', {'Tup', 'final_state'},...
                'output_actions', {'DOut', RewardValve});

sma = add_state(sma, 'name', 'WithdrawalPunish', ...
                'self_timer', 0.2,...
                'input_to_statechange', {'Tup', 'wait_for_cpoke'},...
                'output_actions', {'SoundOut', IndPunishNoise});

%%%% Time of sound is hardcoded here and in SoundsSection.m %%%%
sma = add_state(sma, 'name', 'punish', ...
                'self_timer', 0.05,...
                'input_to_statechange', {'Tup', 'extratime'},...
                'output_actions', {'SoundOut', IndPunishNoise});
%%%% ExtraTime is hardcoded here %%%%
sma = add_state(sma, 'name', 'extratime', ...
                'self_timer', value(PunishExtraTime),...
                'input_to_statechange', {'Tup', 'final_state'});

sma = add_state(sma, 'name', 'final_state', ...
                'self_timer', 0.01, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
dispatcher('send_assembler', sma, 'final_state');


end %%% SWITCH action
