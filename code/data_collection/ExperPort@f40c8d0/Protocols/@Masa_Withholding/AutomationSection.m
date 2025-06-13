
function  [] =  AutomationSection(obj, action)

GetSoloFunctionArgs;

switch action
    case 'init'
        %nothing

    case 'prepare_next_trial',
        
        %added because 'prepare_next_trial' will be called also by
        %LoadSetting in the beggining of the session. If so n_done_trials
        %should be 0. In that case do nothing.
        if n_done_trials==0,
            return,
        end;
        
        %%first check whether rat did nose-poke or lever-press in the done
        %%trial
        if isempty(parsed_events.states.waiting1_np)
            time_np = NaN;
        else
            time_np = parsed_events.states.waiting1_np(1,1);
        end;
        
        if isempty(parsed_events.states.waiting1_lp)
            time_lp = NaN;
        else
            time_lp = parsed_events.states.waiting1_lp(1,1);
        end;

        [min_val min_idx] = min([time_np time_lp]);
        if isnan(min_val),
            %neither nosepoke nor leverpress,,, fake poke
            %arbitrary choose nose poke
            NP_OR_LP = 'NosePoke';
        else
            if min_idx == 1,
                NP_OR_LP = 'NosePoke';
            elseif min_idx ==2,
                NP_OR_LP = 'LeverPress';
            end;
        end;
        
        BEGINNER = value(Beginner);
        WAIT_POKE_NECESSARY = value(WaitPokeNecessary);
        REWARD_COUNTER = value(RewardCounter);
        MULTI_POKE = value(MultiPoke);
        TIME_TO_FAKE_POKE = value(TimeToFakePoke);
        REWARD_AVAIL_PERIOD = value(RewardAvailPeriod);
        ITI_POKE_TIME_OUT = value(ITIPokeTimeOut);
        
        if strcmp(NP_OR_LP,'NosePoke'),
            ADAPTIVE = value(Adaptive_N);
            VPD_SMALL = value(VpdSmall_N);
            VPD_LARGE_MIN = value(VpdLargeMin_N);
            VPD_LARGE_MEAN = value(VpdLargeMean_N);            
        elseif strcmp(NP_OR_LP,'LeverPress'),
            ADAPTIVE = value(Adaptive_L);
            VPD_SMALL = value(VpdSmall_L);
            VPD_LARGE_MIN = value(VpdLargeMin_L);
            VPD_LARGE_MEAN = value(VpdLargeMean_L);
        end;
        
        if (strcmp(BEGINNER,'No') && strcmp(ADAPTIVE, 'Off')),
            %if non-beginner and adaptive-off, there is nothing to do here
            return
        end;    

        if VPD_SMALL==0.0001,
            VPD_SMALL=0;
        end;
        
        %check patient trial or not (ispatient) and change vpds accordingly
        if ~isempty(parsed_events.states.fake_poke),
        %if fake poke
            ispatient=0;
        else
        %if not fake poke
        
            combined_waiting_large = [parsed_events.states.waiting_large1_np;
                                      parsed_events.states.waiting_large4_np;
                                      parsed_events.states.waiting_large1_lp;
                                      parsed_events.states.waiting_large4_lp;
                                      parsed_events.states.mirror_waiting_large1_np;
                                      parsed_events.states.mirror_waiting_large4_np;
                                      parsed_events.states.mirror_waiting_large1_lp;
                                      parsed_events.states.mirror_waiting_large4_lp];
                                  
            if isempty(combined_waiting_large),
                %never in waiting_large
                ispatient = 0;
                
            else %there is waiting_large state
                if size([parsed_events.states.waiting1_np;parsed_events.states.waiting1_lp],1) == 1,
                    %only one waiting, and there is waiting_large state
                    ispatient = 1;
                    
                else
                    %multiple waiting, and there is waiting_large state
                    sorted_waiting1 = ...
                        sort([parsed_events.states.waiting1_np;parsed_events.states.waiting1_lp],1);
                    second_waiting1_time = sorted_waiting1(2,1); %time of second waiting1 in
                    if min(combined_waiting_large(:,1)) > second_waiting1_time,
                        %existing waiting_large is all after second waiting1
                        ispatient = 0;
                    else
                        ispatient = 1;
                    end;
                end;
            end;
        end;

        if ispatient == 0,
            if VPD_LARGE_MEAN>0.7,
                VPD_SMALL=0.4;
                VPD_LARGE_MEAN=VPD_LARGE_MEAN-0.02;   %change on Dec17/07
                VPD_LARGE_MIN=min(0.7,VPD_LARGE_MEAN);%change on Dec17/07
            elseif VPD_LARGE_MIN>0.5,
                VPD_SMALL=0.4;
                VPD_LARGE_MIN=VPD_LARGE_MIN-0.01;
                VPD_LARGE_MEAN=VPD_LARGE_MIN;
            else %vpd_la_min<=0.5
                VPD_SMALL=VPD_SMALL-0.01;
                VPD_SMALL=max(VPD_SMALL,0);
                VPD_LARGE_MIN=VPD_SMALL+0.1;
                VPD_LARGE_MEAN=VPD_LARGE_MIN;
            end;
        elseif ispatient == 1,
            if VPD_SMALL<0.4,
                VPD_SMALL=VPD_SMALL+0.02;
                VPD_LARGE_MIN=VPD_SMALL+0.1;
                VPD_LARGE_MEAN=VPD_LARGE_MIN;
            elseif VPD_LARGE_MIN<0.7,
                VPD_SMALL=0.4;
                VPD_LARGE_MIN=min(0.7,VPD_LARGE_MIN+0.02);
                VPD_LARGE_MEAN=VPD_LARGE_MEAN+0.02;
            else %vpd_la_min>=0.7
                VPD_SMALL=0.4;
                VPD_LARGE_MIN=0.7;
                VPD_LARGE_MEAN=VPD_LARGE_MEAN+0.04;
            end;
        end;        
        
        %%%%%%%%%% Do Different things depending on the stage of learning
        %%%%%%%%%% e.g. WaitPokeNecessary: Yes? No? 
        %%%%%%%%%%%%          Beginner: Yes? No?
        
        if strcmp(BEGINNER, 'No'),
            %if non beginner, vpd parameters should not goes down below
            %certain parameters
            %other than that nothing
            VPD_SMALL = max(VPD_SMALL, 0.4);
            VPD_LARGE_MIN = max(VPD_LARGE_MIN, 0.7);
            VPD_LARGE_MEAN = max(VPD_LARGE_MEAN, 0.8);   
            
        elseif strcmp(BEGINNER, 'Yes'),
        %%%%% Beginner can be either WaitPokeNecessary 'No' or 'Yes' %%%%
            if strcmp(WAIT_POKE_NECESSARY, 'No'),
                
            %%%%%%% Change TimeToFakeIn according to Reward Counter %%%%%%%
                %%check rewarded or not
                if (isempty(parsed_events.states.pre_center_small_reward) && ...
                        isempty(parsed_events.states.pre_center_large_reward) && ...
                        isempty(parsed_events.states.pre_left_small_reward) && ...
                        isempty(parsed_events.states.pre_left_large_reward) && ...
                        isempty(parsed_events.states.pre_right_small_reward) && ...
                        isempty(parsed_events.states.pre_right_large_reward)),
                    rewarded = 0;
                else
                    rewarded = 1;
                end;

                %change RewardCounter
                if rewarded == 1,
                    %if got reward, increase reward counter
                    REWARD_COUNTER = REWARD_COUNTER+1;
                    REWARD_COUNTER = min(REWARD_COUNTER,80);
                elseif rewarded == 0,
                    %if didn't get reward, decrease reward counter
                    REWARD_COUNTER = REWARD_COUNTER-1;
                    REWARD_COUNTER = max(REWARD_COUNTER,0);
                end;

                %%change TimeToFakePoke
                if REWARD_COUNTER>=70,
                    TIME_TO_FAKE_POKE=300;
                elseif REWARD_COUNTER>=60,
                    TIME_TO_FAKE_POKE=100;
                elseif REWARD_COUNTER>=50,
                    TIME_TO_FAKE_POKE=60;
                elseif REWARD_COUNTER>=40,
                    TIME_TO_FAKE_POKE=30;
                elseif REWARD_COUNTER>=30,
                    TIME_TO_FAKE_POKE=20;
                elseif REWARD_COUNTER>=20,
                    TIME_TO_FAKE_POKE=10;
                elseif REWARD_COUNTER>=10,
                    TIME_TO_FAKE_POKE=6;
                elseif REWARD_COUNTER>=5,
                    TIME_TO_FAKE_POKE=3;
                else
                    TIME_TO_FAKE_POKE=0.0001;
                end;
      %%%%%%%%%  End Change TimeToFakeIn according to Reward Counter %%%%%%%

                %% parameter for CPoke NOT Necessary (Still learning center
                %% poking)
                
                TrialLengthSection(obj, 'trial_length_constant_no');
                
            elseif strcmp(WAIT_POKE_NECESSARY, 'Yes'), % && Beginner 'Yes'
                %not many things to do         
            end;

            if VPD_SMALL < 0.2,
                MULTI_POKE='valid_waiting';
                REWARD_AVAIL_PERIOD=20;
                ITI_POKE_TIME_OUT=0.0001;
            else
                if strcmp(MULTI_POKE,'valid_waiting'),
                    MULTI_POKE='just_noiseB';
                end;
                REWARD_AVAIL_PERIOD=2;
                ITI_POKE_TIME_OUT=2;
            end;
        end;

        VPD_SMALL = max(VPD_SMALL, 0.0001);

        %%just pass local variables to
        %%SoloParamHandles (VpdSmall, ...)

        Beginner.value = BEGINNER;
        WaitPokeNecessary.value = WAIT_POKE_NECESSARY;
        RewardCounter.value=REWARD_COUNTER;
        TimeToFakePoke.value=TIME_TO_FAKE_POKE;
        MultiPoke.value=MULTI_POKE;
        RewardAvailPeriod.value=REWARD_AVAIL_PERIOD;
        ITIPokeTimeOut.value=ITI_POKE_TIME_OUT;
        
        if strcmp(NP_OR_LP,'NosePoke'),            
            Adaptive_N.value = ADAPTIVE;            
            VpdSmall_N.value=VPD_SMALL;
            VpdLargeMin_N.value=VPD_LARGE_MIN;
            VpdLargeMean_N.value=VPD_LARGE_MEAN;
            
            if value(SameBlockParams) == 0, %Use Same value
                Adaptive_L.value = ADAPTIVE;
                VpdSmall_L.value=VPD_SMALL;
                VpdLargeMin_L.value=VPD_LARGE_MIN;
                VpdLargeMean_L.value=VPD_LARGE_MEAN;
            end;
            
        elseif strcmp(NP_OR_LP,'LeverPress'),
            Adaptive_L.value = ADAPTIVE;
            VpdSmall_L.value=VPD_SMALL;
            VpdLargeMin_L.value=VPD_LARGE_MIN;
            VpdLargeMean_L.value=VPD_LARGE_MEAN;
            
            if value(SameBlockParams) == 0, %Use Same value
                Adaptive_N.value = ADAPTIVE;
                VpdSmall_N.value=VPD_SMALL;
                VpdLargeMin_N.value=VPD_LARGE_MIN;
                VpdLargeMean_N.value=VPD_LARGE_MEAN;
            end;
        end;
end;