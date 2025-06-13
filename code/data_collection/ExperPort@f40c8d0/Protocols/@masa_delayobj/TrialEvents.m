function [PokeStretch_history, StateStretch_history, ...
    PokeStretch, StateStretch, AlignOn, ...
    TrialData, CinToTout, LastTrialEvents] = TrialEvents(obj, action);    
%  
%
%          obj                  A masa_operant_testobj object
%
% returns: x, y                 updated UI pos
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

GetSoloFunctionArgs;
% SoloFunction('TrialEvents', 'rw_args', {}, ...
%     'ro_args', {'RealTimeStates', 'n_done_trials', 'n_started_trials', 'maxtrials'});

persistent lasttrialeventcounter machine

switch action,
    case 'init',
        SoloParamHandle(obj, 'LastTrialEvents', 'value', []);
        
        SoloParamHandle(obj, 'TrialData', 'value', struct( ...
            'trial_type',    zeros(1,maxtrials), ... %1:short_poke, 2:impusive, 3:patient
            'first_action',  zeros(1,maxtrials), ... %1:side, 2:center, 3: no action
            'get_reward',    zeros(1,maxtrials), ... %1:none, 2:small, 3:large
            'poke_duration', zeros(1,maxtrials), ... %from Cin to Cout
            'movement_time', zeros(1,maxtrials)));   %from Cout to first action
        
        SoloParamHandle(obj, 'CinToTout', 'value', zeros(1,maxtrials));
        SoloParamHandle(obj, 'FakeCin',   'value', zeros(1,maxtrials)); %1:fake, 2;real
        
        lasttrialeventcounter=1;
        
        SoloParamHandle(obj, 'PokeStretch','value', struct( ...
            'center', [], ...
            'side',   []));
        
        SoloParamHandle(obj, 'StateStretch', 'value', struct( ... %shoule be the same as RealTimestates
            'wait_for_cpoke',  [], ...  % Waiting for a center poke
            'cpoke',           [], ...  % Inside a center port
            'cpoke_small',     [], ...
            'cpoke_large',     [], ...
            'short_poke',      [], ...
            'small_available', [], ...
            'large_available', [], ...
            'small_reward',    [], ...
            'large_reward',    [], ...
            'time_out1',       [], ...
            'time_out2',       [], ...
            'state35',         []));
        
        SoloParamHandle(obj, 'AlignOn', 'value', struct( ...
            'TrialStart', zeros(1,maxtrials), ...
            'Cin', zeros(1,maxtrials), ...
            'Cout', zeros(1,maxtrials)));
        
        SoloParamHandle(obj,'StateStretch_history');
        SoloParamHandle(obj,'PokeStretch_history');

       global fake_rp_box;
       global state_machine_server;

       if fake_rp_box==2,
           machine=RTLSM(state_machine_server);
       elseif fake_rp_box==3,
           machine=RPBox('getstatemachine');
       end;
       
    case 'get350',
        eventcounter=GetEventCounter(machine);
        events=GetEvents(machine,lasttrialeventcounter,eventcounter);
        LastTrialEvents.value=events;
        
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cinID=1; coutID=2; sinID=4; soutID=8;
    ainID1=16; ainID2=32; ainID3=64; ainID3=128;
    ainID4=256; ainID5=512; ainID6=1024;
    toutID=2048;
    %%%%%%%%%%Data_for_StatePatch&PokeLine%%%%%%%%%%%%%
       %First, Data for PokeLine
       fname_poke=fieldnames(value(PokeStretch));
       for i=1:2,
           in_idx=find(events(:,2)==2^(2*i-2));
           out_idx=find(events(:,2)==2^(2*i-1));
           if ~isempty(out_idx),
               ind=find(in_idx<out_idx(1)); %search for out before in (in within last trial)
               if isempty(ind),
                   in_idx=[1;in_idx]; %case out assoc with last_trial in, add trial start time on top of Cin!
               end;
           end;
           if ~isempty(in_idx),
               ind=find(out_idx>=in_idx(end)); % search for in after out (in assoc with next-trial out)
               if isempty(ind),
                   out_idx=[out_idx;size(events,1)]; %case in assoc with next-trial out, add trial end time at the bottom of Cout!
               end;
           end;
           if size(in_idx,1)~=size(out_idx,1),
               warning('Ins, Outs number don''t match after correction');
               events
               i
               in_idx
               out_idx
               
               min_size=min(size(in_idx,1),size(out_idx,1));
               in_idx=in_idx(1:min_size);
               out_idx=out_idx(1:min_size);
           end;
           in_times=events(in_idx,3);
           out_times=events(out_idx,3);
           PokeStretch.(fname_poke{i})=[in_times out_times];
       end;
       
       %Second, Data for State
       rts=value(RealTimeStates);
       fname_state=fieldnames(value(StateStretch));
       for i=1:size(fname_state,1),
           state01=ismember(events(:,4),rts.(fname_state{i}));
           if ~isempty(state01),
               ind_start=find(diff(state01)==1);
               if ~isempty(ind_start), ind_start=ind_start+1;end;
               if state01(1), ind_start=[1;ind_start];end;
               ind_stop=find(diff(state01)==-1);
               if ~isempty(ind_stop), ind_stop=ind_stop+1;end;
               if state01(end), ind_stop=[ind_stop;size(state01,1)];end;
           end;
           StateStretch.(fname_state{i})=[events(ind_start,3) events(ind_stop,3)];
       end;
       
       %Third, Data for Align On      
       idx_wcpk=find(ismember(events(:,4),rts.wait_for_cpoke));
       if ~isempty(idx_wcpk),
           AlignOn.TrialStart(n_started_trials)=events(idx_wcpk(1),3);
       end;
       
       idx_cin=find(ismember(events(:,4),rts.cpoke));
       if ~isempty(idx_cin),
           AlignOn.Cin(n_started_trials)=events(idx_cin(1),3);
       end;
       
       idx_cout=find(ismember(events(:,4),[rts.short_poke ...
           rts.small_available rts.large_available]));
       if ~isempty(idx_cout),
           AlignOn.Cout(n_started_trials)=events(idx_cout(1),3);
       end;
       
    case 'get',      
       eventcounter=GetEventCounter(machine);
       events=GetEvents(machine,lasttrialeventcounter,eventcounter);
       lasttrialeventcounter=eventcounter; %lasttrialeventcounter(persistent) for next trial
       LastTrialEvents.value=events;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cinID=1; coutID=2; sinID=4; soutID=8;
    ainID1=16; ainID2=32; ainID3=64; ainID3=128;
    ainID4=256; ainID5=512; ainID6=1024;
    toutID=2048;
    %%%%%%%%%%Data_for_StatePatch&PokeLine%%%%%%%%%%%%%
       %First, Data for PokeLine
       fname_poke=fieldnames(value(PokeStretch));
       fname_poke=fieldnames(value(PokeStretch));
       for i=1:2,
           in_idx=find(events(:,2)==2^(2*i-2));
           out_idx=find(events(:,2)==2^(2*i-1));
           if ~isempty(out_idx),
               ind=find(in_idx<out_idx(1)); %search for out before in (in within last trial)
               if isempty(ind),
                   in_idx=[1;in_idx]; %case out assoc with last_trial in, add trial start time on top of Cin!
               end;
           end;
           if ~isempty(in_idx),
               ind=find(out_idx>=in_idx(end)); % search for in after out (in assoc with next-trial out)
               if isempty(ind),
                   out_idx=[out_idx;size(events,1)]; %case in assoc with next-trial out, add trial end time at the bottom of Cout!
               end;
           end;
           if size(in_idx,1)~=size(out_idx,1),
               warning('Ins, Outs number don''t match after correction');
               events
               i
               in_idx
               out_idx
               
               min_size=min(size(in_idx,1),size(out_idx,1));
               in_idx=in_idx(1:min_size);
               out_idx=out_idx(1:min_size);
           end;
           in_times=events(in_idx,3);
           out_times=events(out_idx,3);
           PokeStretch.(fname_poke{i})=[in_times out_times];
       end;
       PokeStretch_hitory{value(n_done_trials)}=value(PokeStretch);
       
       %Second, Data for State
       rts=value(RealTimeStates);
       fname_state=fieldnames(value(StateStretch));
       for i=1:size(fname_state,1),
           state01=ismember(events(:,4),rts.(fname_state{i}));
           if ~isempty(state01),
               ind_start=find(diff(state01)==1);
               if ~isempty(ind_start), ind_start=ind_start+1;end;
               if state01(1), ind_start=[1;ind_start];end;
               ind_stop=find(diff(state01)==-1);
               if ~isempty(ind_stop), ind_stop=ind_stop+1;end;
               if state01(end), ind_stop=[ind_stop;size(state01,1)];end;
           end;
           StateStretch.(fname_state{i})=[events(ind_start,3) events(ind_stop,3)];
       end;
       StateStretch_hitory{value(n_done_trials)}=value(StateStretch);
       
    %%%%%%%%%%Trial Data extraction%%%%%%%%%%
       rts=value(RealTimeStates);
       
       t_type=TrialData.trial_type;
       f_action=TrialData.first_action;
       g_reward=TrialData.get_reward;
       poke_dur=TrialData.poke_duration;
       move_time=TrialData.movement_time;
       
       idx_wcpk=find(ismember(events(:,4),rts.wait_for_cpoke));
       if ~isempty(idx_wcpk),
           AlignOn.TrialStart(n_done_trials)=events(idx_wcpk(1),3);
       else, warning('No Wait for CPoke State!');
       end;
       
       idx_cin=find(ismember(events(:,4),rts.cpoke));
       if ~isempty(idx_cin),
           AlignOn.Cin(n_done_trials)=events(idx_cin(1),3);   
       end;
       
       idx_cout=find(ismember(events(:,4),[rts.short_poke ...
           rts.small_available rts.large_available]));
       if ~isempty(idx_cout),
           AlignOn.Cout(n_done_trials)=events(idx_cout(1),3);
           if ismember(events(idx_cout(1),4),rts.short_poke),
               t_type(n_done_trials)=1;
           elseif ismember(events(idx_cout(1),4),rts.small_available),
               t_type(n_done_trials)=2;
           elseif ismember(events(idx_cout(1),4),rts.large_available),
               t_type(n_done_trials)=3;
           end;
       end;
       
       %%%FakeCin%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       fake_cin=value(FakeCin);
       if ~isempty(idx_cin),
         if events(idx_cin(1),4)==59, %59:Fpks (fake poke state) fixed bug 080627
           fake_cin(n_done_trials)=1;
           %in case fake cin, t_type is 11 (add Nov 13)
           t_type(n_done_trials)=11;
         elseif events(idx_cin(1),4)==50, %50:Cpks (real cpoke)
           fake_cin(n_done_trials)=2;
         end;
       end;
       FakeCin.value=fake_cin;
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
       idx_fact=idx_cout(1)+1;
       if events(idx_fact,2)==toutID,
           idx_fact=idx_fact+1;
       end;
       if events(idx_fact,2)==sinID,
           f_action(n_done_trials)=1;
       elseif events(idx_fact,2)==cinID,
           f_action(n_done_trials)=2;
       elseif (events(idx_fact,2)==ainID2|events(idx_fact,2)==toutID),
           f_action(n_done_trials)=3;
       end;
       
       idx_rew=find(ismember(events(:,4), ...
            [rts.small_reward rts.large_reward]));
       if isempty(idx_rew), %no reward
           g_reward(n_done_trials)=1;
       elseif ismember(events(idx_rew(1),4), rts.small_reward), %small reward
           g_reward(n_done_trials)=2;
       elseif ismember(events(idx_rew(1),4), rts.large_reward), %large reward
           g_reward(n_done_trials)=3;
       end;           
       
       poke_dur(n_done_trials)=events(idx_cout(1),3)-events(idx_cin(1),3);
       move_time(n_done_trials)=events(idx_fact,3)-events(idx_cout(1),3);
       
       TrialData.trial_type=t_type;
       TrialData.first_action=f_action;
       TrialData.get_reward=g_reward;
       TrialData.poke_duration=poke_dur;
       TrialData.movement_time=move_time;
       
       %%%CinToTout (this value is used to realize a constant trial length)
       cin_to_tout=value(CinToTout);
       idx_tout=find(ismember(events(:,4),rts.time_out1));
       cin_to_tout(n_done_trials)=events(idx_tout(1),3)-events(idx_cin(1),3);
       CinToTout.value=cin_to_tout;
       
    case 'push_history_then_reset',
        push_history(LastTrialEvents);
        LastTrialEvents.value=[];
        
        push_history(PokeStretch);
        fname_poke=fieldnames(value(PokeStretch));
        for i=1:2, PokeStretch.(fname_poke{i})=[];end;
        
        push_history(StateStretch);
        fname_state=fieldnames(value(StateStretch));
        for i=1:size(fname_state,1),StateStretch.(fname_state{i})=[];end;
        
    case 'delete',
        if (~isa(machine, 'SoftSMMarkII')), 
            Close(machine);
        end;
    otherwise,
        error(['Don''t know how to deal with action ' action]);
end;    