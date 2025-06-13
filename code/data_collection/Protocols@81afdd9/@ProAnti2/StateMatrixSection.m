% @ProAnti/StateMatrixSection
% Jeffrey Erlich, July 2007

% [x, y] = StateMatrixSection(obj, action, x, y)
%
% HELP HERE
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%            'init'         To initialise the section
%
%            'next_trial'   To set up the state matrix for the next trial
%
%            'reinit'       Delete all of this section's GUIs and data,
%                           and reinit, at the same position on the same
%                           figure as the original section GUI was placed.
%
% x, y     Relevant to action = 'init'; they indicate the initial
%          position to place the GUI at, in the current figure window
%
% RETURNS:
% --------
%
% [x, y]   When action == 'init', returns x and y, pixel positions on
%          the current figure, updated after placing of this section's GUI.
%
% NOTE: Because of the use of 'current_state+1' and 'current_state-1' it is
% very important that calls that involve the StateMachineAssembler are in a
% certain order.  If you add an intervening line of code or add a state
% inbetween states that use 'current_state+1' you will break the code.


function  [] =  StateMatrixSection(obj, action)


%STIM_TIME=0.005; % 5 ms, this should just produce a TTL of the shortest duration noticable by the grass stim.

GetSoloFunctionArgs;

switch action
%% CASE INIT
    case 'init',
        feval(mfilename, obj, 'next_trial');

%% CASE Next Trial
    case 'next_trial',

%% DECLARE SOUNDS

        start_snd_id=SoundManagerSection(obj, 'get_sound_id', 'StartTrialSound');

        if pro_trial==1
            poke1sound_id=SoundManagerSection(obj, 'get_sound_id', 'ProSound');
            init_trans='pro_trial_state';
        else
            poke1sound_id=SoundManagerSection(obj, 'get_sound_id', 'AntiSound');
            init_trans='anti_trial_state';
        end

        switch poke2_snd_loc,
            case 1
                poke2sound_id=SoundManagerSection(obj, 'get_sound_id', 'RightSound');
            case -1
                poke2sound_id=SoundManagerSection(obj, 'get_sound_id', 'LeftSound');
            case 0
                poke2sound_id=SoundManagerSection(obj, 'get_sound_id', 'CenterSound');
        end

        HitSound_id=SoundManagerSection(obj,'get_sound_id','HitSound');
        MissSound_id=SoundManagerSection(obj,'get_sound_id','MissSound');
        MissSound_dur=SoundInterface(obj, 'get', 'MissSound', 'total_duration');
        ViolationSound_id=SoundManagerSection(obj,'get_sound_id','ViolationSound');
        ITISound_id=SoundManagerSection(obj,'get_sound_id','ITISound');
        BadBoySound_id=SoundManagerSection(obj,'get_sound_id','BadBoySound');
        BadBoySound_dur=SoundInterface(obj, 'get', 'BadBoySound', 'total_duration');


%% ADD STATES
        sma = StateMachineAssembler('full_trial_structure');

        first_state={'wait_for_poke3', 'wait_for_poke2', 'wait_for_poke1'};

        sma=add_state(sma, 'self_timer',0.0001,...
            'output_actions',{'SoundOut', -ITISound_id}, ...
            'input_to_statechange', {'Tup',init_trans});

        sma =add_state(sma, 'name', 'pro_trial_state',...
            'self_timer',0.0001,...
            'input_to_statechange', {'Tup','delay2start'});

        sma =add_state(sma, 'name', 'anti_trial_state',...
            'self_timer',0.0001,...
            'input_to_statechange', {'Tup','delay2start'});

        if SoundManagerSection(ProAnti2, 'get_sound_duration', 'StartTrialSound') > 0.0005,
            sma = add_state(sma, 'name', 'delay2start', ...
                'self_timer', delay2startTO, ...
                'output_actions',{'SoundOut', start_snd_id}, ...
                'input_to_statechange', mapping([],bp_del2start_state ,bp_del2start_state, first_state{nPokes}));
        else
            sma = add_state(sma, 'name', 'delay2start', ...
                'self_timer', delay2startTO, ...
                'input_to_statechange', mapping([],bp_del2start_state ,bp_del2start_state, first_state{nPokes}));
        end;



        sma = add_state(sma, 'self_timer', BadBoySound_dur, ...
            'output_actions',{'SoundOut',BadBoySound_id},...
            'input_to_statechange', {'Tup','current_state-1'});



%% poke1
        if nPokes>=3
            sma = add_state(sma, 'name', 'wait_for_poke1', ...
                'self_timer', poke1TO,...
                'output_actions', {'DOut', transLED(goodPoke1)*show_poke1leds},...
                'input_to_statechange', mapping(goodPoke1, 'delay_for_poke1sound',bp_wait_for_poke1_state, poke1TO_state));

            sma = add_state(sma, 'self_timer', BadBoySound_dur, ...
                'output_actions',{'SoundOut',BadBoySound_id},...
                'input_to_statechange', {'Tup','current_state-1'});


            sma = add_state(sma, 'name', 'delay_for_poke1Sound', ...
                'self_timer', poke1snd_delay, ...
                'input_to_statechange', {'Tup','poke1sound'});

            sma = add_state(sma, 'name', 'poke1sound',...
                'self_timer', poke1poke2gap, ...
                'output_actions' ,{'SoundOut',poke1sound_id},...
                'input_to_statechange', mapping([],bp_p1p2gap_state ,bp_p1p2gap_state,'wait_for_poke2'));

            sma = add_state(sma, 'self_timer', BadBoySound_dur, ...
                'output_actions',{'SoundOut',BadBoySound_id},...
                'input_to_statechange', {'Tup','current_state-1'});


        end

%% poke2
        if nPokes>=2
            sma = add_state(sma, 'name', 'wait_for_poke2', ...
                'self_timer', poke2TO,...
                'output_actions', {'DOut', transLED(goodPoke2)*show_poke2leds},...
                'input_to_statechange', mapping(goodPoke2, 'delay_for_poke2sound',bp_wait_for_poke2_state, poke2TO_state));

            sma = add_state(sma, 'self_timer', BadBoySound_dur, ...
                'output_actions',{'SoundOut',BadBoySound_id},...
                'input_to_statechange', {'Tup','current_state-1'});

            gd_pk2_str={'Lout','Cout','Rout'};

            if trial_type % reaction time
                if pk2_stop_cntxt_snd
                    sma = add_state(sma, 'name', 'delay_for_poke2Sound', ...
                        'output_actions', {'SoundOut', -poke1sound_id},...
                        'self_timer', poke2snd_delay, ...
                        'input_to_statechange', {'Tup','poke2sound';...
                        gd_pk2_str{2+goodPoke2}, 'violation_state'});

                else
                    sma = add_state(sma, 'name', 'delay_for_poke2Sound', ...
                        'self_timer', poke2snd_delay, ...
                        'input_to_statechange', {'Tup','poke2sound';...
                        gd_pk2_str{2+goodPoke2}, 'violation_state'});
                end
                sma = add_state(sma, 'name', 'poke2sound',...
                    'output_actions' ,{'SoundOut',poke2sound_id;...
                    'DOut',  transLED(goodPoke2)*show_poke2leds},...
                    'input_to_statechange', {gd_pk2_str{2+goodPoke2}, 'current_state+1'});

                sma= add_state(sma, 'self_timer', 0.001,...
                    'output_actions', {'SoundOut', -poke2sound_id},...
                    'input_to_statechange',{'Tup','wait_for_poke3'});

            else
                if pk2_stop_cntxt_snd

                    sma = add_state(sma, 'name', 'delay_for_poke2Sound', ...
                        'output_actions', {'SoundOut', -poke1sound_id},...
                        'self_timer', poke2snd_delay, ...
                        'input_to_statechange', {'Tup','poke2leds'});
                else

                    sma = add_state(sma, 'name', 'delay_for_poke2Sound', ...
                        'self_timer', poke2snd_delay, ...
                        'input_to_statechange', {'Tup','poke2leds'});
                end
                sma = add_state(sma, 'name', 'poke2leds',...
                    'self_timer', poke2ledTime, ...
                    'output_actions' , {'DOut', transLED(lightCue)},...
                    'input_to_statechange', mapping([],bp_p2p3gap_state ,bp_p2p3gap_state,'poke2sound'));

                tx=max(poke2poke3gap-poke2ledTime, 0.00001);
                % This is a sanity check in case someone made the ledtime longer
                % than the gap.  This should probably be in the SettingsSection.

                % tx is the enforced gap before the rat is allowed to respond.
                % if the overlap is greater than the gap then there is nothing to
                % do here.
                if (cntx_loc_overlap>tx) || (cntx_loc_overlap<0) %#ok<NODEF>
                    sma = add_state(sma, 'name', 'poke2sound',...
                        'self_timer', tx, ...
                        'output_actions',{'SoundOut',poke2sound_id;},...
                        'input_to_statechange', mapping([],bp_p2p3gap_state ,bp_p2p3gap_state,'wait_for_poke3'));

                    sma = add_state(sma, 'self_timer', BadBoySound_dur, ...
                        'output_actions',{'SoundOut',BadBoySound_id},...
                        'input_to_statechange', {'Tup','current_state-1'});

                    cntx_loc_overlap=cntx_loc_overlap-tx;
                    % The overlap left after the gap.

                else  % we need to turn off the context sound after a certain time.
                    % so split up the gap into context sound playing and not
                    % playing
                    tx=tx-cntx_loc_overlap;

                    % This is a sanity check in case someone made the ledtime longer
                    % than the gap.  This should probably be in the SettingsSection.
                    sma = add_state(sma, 'name', 'poke2sound',...
                        'self_timer', cntx_loc_overlap, ...
                        'output_actions',{'SoundOut',poke2sound_id;},...
                        'input_to_statechange', mapping([],bp_p2p3gap_state ,bp_p2p3gap_state,'current_state+2'));

                    sma = add_state(sma, 'self_timer', BadBoySound_dur, ...
                        'output_actions',{'SoundOut',BadBoySound_id},...
                        'input_to_statechange', {'Tup','current_state-1'});

                    sma = add_state(sma,...
                        'self_timer', tx, ...
                        'output_actions',{'SoundOut',-poke1sound_id;},...
                        'input_to_statechange', mapping([],bp_p2p3gap_state ,bp_p2p3gap_state,'wait_for_poke3'));

                    sma = add_state(sma, 'self_timer', BadBoySound_dur, ...
                        'output_actions',{'SoundOut',BadBoySound_id},...
                        'input_to_statechange', {'Tup','current_state-1'});

                    % we are done with the overlap so set it to -1
                    cntx_loc_overlap=-1;

                end

            end


        end

%% Poke3
% WAIT FOR RESPONSE
% For NOW ignore center pokes in wait_for_poke3

        pokes={'Lin' 'Cin' 'Rin'};
        if isempty(wrong_response_state) %#ok<NODEF>
            wrong_response_state='current_state';
        elseif strcmp(wrong_response_state,'badboy_state')
            wrong_response_state='current_state+1';
        end


        if isempty(poke3TO_state) %#ok<NODEF>
            poke3TO_state='current_state';
        elseif strcmp(poke3TO_state,'badboy_state')
            poke3TO_state='current_state+1';
        end

        % Check if overlap is longer than time_outs.  If it is... ignore it.
        sma = add_scheduled_wave(sma, 'name', 'overlapWV', 'preamble', cntx_loc_overlap);

        if cntx_loc_overlap<0 || (cntx_loc_overlap>poke3TO && ((poke3TO_state(1)=='m')||(poke3TO_state(1)=='v')))
            % in this case ignore the overlap parameter.
            sma = add_state(sma, 'name', 'wait_for_poke3', ...
                'self_timer', poke3TO, ...
                'output_actions', {'DOut', transLED(poke3led)}, ...
                'input_to_statechange', {pokes{goodPoke3+2}, 'hit_state'; ...
                pokes{-goodPoke3+2},wrong_response_state;...
                'Tup',poke3TO_state});


        else
            % trigger the overlap parameter



            sma = add_state(sma, 'name', 'wait_for_poke3', ...
                'self_timer', poke3TO, ...
                'output_actions', {'DOut', transLED(poke3led);'SchedWaveTrig', 'overlapWV'}, ...
                'input_to_statechange', {pokes{goodPoke3+2}, 'hit_state'; ...
                pokes{-goodPoke3+2},wrong_response_state;...
                'Tup',poke3TO_state;...
                'overlapWV_In','current_state+2'});
        end

%% Deal with first_temp_error and context_snd_overlap

        sma = add_state(sma, 'self_timer', MissSound_dur, ...
            'output_actions',{'SoundOut',MissSound_id},...
            'input_to_statechange', {'Tup','current_state+3'});

        sma = add_state(sma, 'self_timer', 0.0001, ...
            'output_actions',{'SoundOut',-poke1sound_id},...
            'input_to_statechange', {'Tup','current_state+1'});
        %if context_sound is turned off do NOT retrigger scheduled wave

        sma = add_state(sma,  ...
            'self_timer', poke3TO, ...
            'output_actions', {'DOut', transLED(poke3led);}, ...
            'input_to_statechange', {pokes{goodPoke3+2}, 'hit_state'; ...
            pokes{-goodPoke3+2},wrong_response_state;...
            'Tup',poke3TO_state});

        sma = add_state(sma, 'self_timer', MissSound_dur, ...
            'output_actions',{'SoundOut',MissSound_id},...
            'input_to_statechange', {'Tup','current_state+1'});

        sma = add_state(sma, 'name', 'wait_for_poke3_aftertemperror', ...
            'self_timer', poke3TO, ...
            'output_actions', {'DOut', transLED(poke3led);'SchedWaveTrig', 'overlapWV'}, ...
            'input_to_statechange', {pokes{goodPoke3+2}, 'hit_state_aftertemperror'; ...
            pokes{-goodPoke3+2},wrong_response_state;...
            'Tup',poke3TO_state;...
            'overlapWV_In','current_state+2'});


        sma = add_state(sma, 'self_timer', MissSound_dur, ...
            'output_actions',{'SoundOut',MissSound_id},...
            'input_to_statechange', {'Tup','current_state-1'});



        sma = add_state(sma, 'self_timer', 0.0001, ...
            'output_actions',{'SoundOut',-poke1sound_id},...
            'input_to_statechange', {'Tup','current_state+1'});

% Do not retrigger scheduled wave 

% this states is just like wait_for_poke3_aftertemperror without the
% scheduled wave events.

        sma = add_state(sma,  ...
            'self_timer', poke3TO, ...
            'output_actions', {'DOut', transLED(poke3led)}, ...
            'input_to_statechange', {pokes{goodPoke3+2}, 'hit_state_aftertemperror'; ...
            pokes{-goodPoke3+2},wrong_response_state;...
            'Tup',poke3TO_state'});


        sma = add_state(sma, 'self_timer', MissSound_dur, ...
            'output_actions',{'SoundOut',MissSound_id},...
            'input_to_statechange', {'Tup','current_state-1'});


        sma = add_state(sma, 'name', 'lights_state', ...
            'output_actions', {'DOut', transLED(goodPoke3);'SchedWaveTrig', 'overlapWV'}, ...
            'input_to_statechange', {pokes{goodPoke3+2}, 'hit_state'; ...
            pokes{-goodPoke3+2},wrong_response_state;...
            'overlapWV_In','current_state+2'});

        sma = add_state(sma, 'self_timer', MissSound_dur, ...
            'output_actions',{'SoundOut',MissSound_id},...
            'input_to_statechange', {'Tup','current_state-1'});

        sma = add_state(sma, 'self_timer', 0.0001, ...
            'output_actions',{'SoundOut',-poke1sound_id},...
            'input_to_statechange', {'Tup','current_state-2'});
        
%% HIT


        if reward_type==0 || isnan(stimio)%#ok<NODEF> % water reward
            rew_dout=transREW(goodPoke3)*reward_baited+transLED(goodPoke3)*FlashCorrectResp;
        else % brain stim
            rew_dout=stimio*reward_baited+transLED(goodPoke3)*FlashCorrectResp;
        end

        if KeepSoundOn==1 && isequal(after_reward, 'soft_drink_time'),
            % If context and loc sound should stay on during drink, don't turn them off yet
            snds_list = [-start_snd_id]; %#ok<NBRAK>
        else
            snds_list= [-poke1sound_id -poke2sound_id -start_snd_id];
        end;

        if SoundManagerSection(obj, 'get_sound_duration', 'HitSound') > 0.0005,
            sma = add_multi_sounds_state(sma,[snds_list HitSound_id],'state_name','hit_state','return_state','give_reward', 'self_timer', delay2reward);
            sma = add_multi_sounds_state(sma,[snds_list HitSound_id],'state_name','hit_state_aftertemperror','return_state','give_reward_aftertemperror', 'self_timer', delay2reward);
        else
            sma = add_multi_sounds_state(sma,[snds_list],'state_name','hit_state','return_state','give_reward', 'self_timer', delay2reward); %#ok<NBRAK>
            sma = add_multi_sounds_state(sma,[snds_list],'state_name','hit_state_aftertemperror','return_state','give_reward_aftertemperror', 'self_timer', delay2reward); %#ok<NBRAK>
        end;
        % reward_baited is set in the PerformanceSection and can be :
        % give_reward or give_nothing

        stimio=bSettings('get','DIOLINES','stim1'); %#ok<NASGU>

        if isequal(after_reward, 'soft_drink_time'),
            if hit_iti_or_wd == 1,  post_soft_drink = 'hit_iti';
            else                    post_soft_drink = 'wd_warning';
            end;
            % If we're not keeping sounds on after delivering water, turn them
            % off 2 ms into water delivery.
            if KeepSoundOn == 0, poke2sound_t_after_wtr = 0.002; end;

            sma = add_scheduled_wave(sma, 'name', 'context_sound_off', ...
                'preamble', poke2sound_t_after_wtr);

            sma = add_state(sma, 'name', 'give_reward', 'self_timer', 0.0001, ...
                'input_to_statechange', {'Tup', 'soft_drink_time'});
            sma = add_state(sma, 'name', 'give_reward_aftertemperror', 'self_timer', 0.0001, ...
                'input_to_statechange', {'Tup', 'soft_drink_time_aftertemperror'});

            sma = SoftPokeStayInterface(obj, 'add_sma_states', 'soft_drink_time', sma, ...
                'pokeid', pokes{goodPoke3+2}(1), ...
                'DOut', rew_dout, 'DOutStartTime', 0, 'DOutOnTime', reward_time, ...
                'Sound1TrigTime', max(poke2sound_t_after_wtr, 0.002), 'Sound1Id', -poke2sound_id, ...
                'InitialSchedWaveTrig',  'context_sound_off', ...
                'success_exitstate_name', 'post_soft_drink_cleanup' ,'abort_exitstate_name', 'post_soft_drink_cleanup',...
                'Sound2TriggeringEvent', 'context_sound_off_In', 'Sound2Id', -poke1sound_id);

            sma = SoftPokeStayInterface(obj, 'add_sma_states', 'soft_drink_time_aftertemperror', sma, ...
                'pokeid', pokes{goodPoke3+2}(1), ...
                'DOut', rew_dout, 'DOutStartTime', 0, 'DOutOnTime', reward_time*scale_temperror_rew, ...
                'Sound1TrigTime', max(poke2sound_t_after_wtr, 0.002), 'Sound1Id', -poke2sound_id, ...
                'InitialSchedWaveTrig',  'context_sound_off', ...
                'success_exitstate_name', 'post_soft_drink_cleanup' ,'abort_exitstate_name', 'post_soft_drink_cleanup',...
                'Sound2TriggeringEvent', 'context_sound_off_In', 'Sound2Id', -poke1sound_id);

            sma = add_state(sma, 'name', 'post_soft_drink_cleanup', 'self_timer', 0.0001, ...
                'output_actions', {'SoundOut', -poke1sound_id}, ...
                'input_to_statechange', {'Tup', post_soft_drink});
        else
            sma = add_state(sma, 'name', 'give_reward', ...
                'self_timer', reward_time, ...
                'output_actions',{'DOut', rew_dout}, ...
                'input_to_statechange',{'Tup',after_reward});

            sma = add_state(sma, 'name', 'give_reward_aftertemperror', ...
                'self_timer', reward_time*scale_temperror_rew, ...
                'output_actions',{'DOut', rew_dout}, ...
                'input_to_statechange',{'Tup',after_reward});
        end;


        if SoundManagerSection(obj, 'get_sound_duration', 'ITISound') > 0.0005,
            % Apparently, very short sounds can cause a problem with the sound
            % card. Don't play the sound if less than half a ms long.
            sma = add_state(sma, 'name', 'hit_iti', ...
                'self_timer', hitITIdur, ...
                'output_actions', {'SoundOut', ITISound_id}, ...
                'input_to_statechange', mapping([], bp_ITI_state,bp_ITI_state,'cleanup'));
        else
            sma = add_state(sma, 'name', 'hit_iti', ...
                'self_timer', hitITIdur, ...
                'input_to_statechange', mapping([], bp_ITI_state,bp_ITI_state,'cleanup'));
        end;

        sma = add_state(sma, 'self_timer', BadBoySound_dur, ...
            'output_actions',{'SoundOut',BadBoySound_id},...
            'input_to_statechange', {'Tup','current_state-1'});

        sma = WarnDangerInterface(obj, 'add_sma_states', 'wd', sma, ...
            'exitstate', 'cleanup', 'on_poke_when_danger_state', 'iti_punishment');

        sma = PunishInterface(obj, 'add_sma_states', 'iti_punishment', sma, ...
            'exitstate', 'wd_danger');

%% MISS

        snds_list= [-poke1sound_id -poke2sound_id -start_snd_id];

        sma = add_multi_sounds_state(sma, [snds_list MissSound_id],'state_name','miss_state');


        sma = add_state(sma, 'name', 'miss_iti', ...
            'self_timer', missITIdur, ...
            'output_actions',{'SoundOut', ITISound_id}, ...
            'input_to_statechange', mapping([], bp_ITI_state,bp_ITI_state,'cleanup'));

        sma = add_state(sma, 'self_timer', BadBoySound_dur, ...
            'output_actions',{'SoundOut',BadBoySound_id},...
            'input_to_statechange', {'Tup','current_state-1'});

        sma = add_multi_sounds_state(sma, [snds_list ViolationSound_id], 'state_name','violation_state');

        sma = add_state(sma, 'name', 'violation_iti', ...
            'self_timer', violationITIdur, ...
            'output_actions',{'SoundOut', ITISound_id}, ...
            'input_to_statechange', mapping([], bp_ITI_state,bp_ITI_state,'cleanup'));

        sma = add_state(sma, 'self_timer', BadBoySound_dur, ...
            'output_actions',{'SoundOut',BadBoySound_id},...
            'input_to_statechange', {'Tup','current_state-1'});

        sma = add_multi_sounds_state(sma, [-start_snd_id -MissSound_id -ITISound_id -HitSound_id -BadBoySound_id], ...
            'state_name', 'cleanup', 'return_state', 'check_next_trial_ready');


        dispatcher('send_assembler', sma, {'hit_state','hit_state_aftertemperror','miss_state','violation_state'});
        % This sets the 'ready_to_start_next_trial' flag

    otherwise
        warning('PROANTI:StateMatrixSection',['unknown action ' action])

end



%% MAPPING
function y=mapping(gd_poke_id, gd_poke_state, bd_pokes_state, to_state, ignore_pokes) %#ok<INUSD>

% y=mapping(gd_poke, gd_poke_state, bd_pokes_state, to_state)
% y=mapping(gd_poke, gd_poke_state)
% y=mapping(gd_poke, gd_poke_state, [], to_state)
% Use this as short hand for input to statechange.
% 'input_to_statechange',mapping('c', 'next_state','punish','violation')
% But the real reason to use this is to use variables in the call.
% 'input_to_statechange',mapping(poke1, 'next_state','bpstate','tostate')
% then poke1 can be set in the 'prepare_next_trial' section and it avoids
% many if statements in this section.

pokes={'Lin','Cin','Rin'};

if isempty(gd_poke_id)
    gd_poke_id=0;
end
if isempty(gd_poke_state)
    gd_poke_state='current_state';
end
if nargin>2 && isempty(bd_pokes_state)
    bd_pokes_state='current_state';
end

if strcmp(gd_poke_state,'badboy_state')
    gd_poke_state='current_state+1';
end

if strcmp(bd_pokes_state,'badboy_state')
    bd_pokes_state='current_state+1';
end

if strcmp(to_state,'badboy_state')
    to_state='current_state+1';
end

y(1,:)={pokes{gd_poke_id+2}, gd_poke_state};

if nargin>2
    switch gd_poke_id
        case 0
            y(2:3,:)={'Lin', bd_pokes_state; 'Rin', bd_pokes_state;};
        case -1
            y(2:3,:)={'Cin', bd_pokes_state; 'Rin', bd_pokes_state;};
        case 1
            y(2:3,:)={'Cin', bd_pokes_state; 'Lin', bd_pokes_state;};
    end

end

if nargin>3 && ~isempty(to_state)
    y(end+1,:)={'Tup', to_state};
end

return;

%% TRANSLED
function y=transLED(ledstr)
global left1led;
global center1led;
global right1led;
if ischar(ledstr)
    ledstr=eval(['[' ledstr ']']);
end

y=[left1led center1led right1led];
y=sum(y(ledstr+2));
if isempty(y)
    y=0;
end

%% TRANSREW
function y=transREW(rewstr)
global left1water;
global center1water;
global right1water;

if isempty(center1water);
    center1water=2^0;
end

y=[left1water center1water right1water];
y=y(rewstr+2);

if isempty(y)
    y=0;
end

