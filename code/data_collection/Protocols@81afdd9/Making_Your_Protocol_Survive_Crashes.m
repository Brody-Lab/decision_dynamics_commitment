
%% init
  case 'init'
	
      
    %Add these 3 SoloParams to your init section
    SoloParamHandle(obj, 'SMA',                    'value', []); %stores sma variable from last trial
    SoloParamHandle(obj, 'PrepareNextTrialStates', 'value', cell(0)); %stores preparenexttrialstates from last trial
    SoloParamHandle(obj, 'n_prepped_trials',       'value', 0); %tracks how many times we went through the prepare next trial case
    
    
    
    
%% prepare next trial
  case 'prepare_next_trial'
    %There are 2 ways you get here. 1) Things are normal and you're just
    %preparing your next trial, or 2) something crashed and dispatcher
    %RunninSection.m is trying to call it to continue running
      
    %add this line
    if isempty(varargin) || ~strcmp(varargin{1},'crashed')
        %We have not crashed, prepare things as normal, the amjority of the code you
        %have in prepare_next_trial should go in here
        
        %make a call to your subfunction that makes your state matrix and
        %return the values here
        [sma, prepare_next_trial_states] = StateMatrixSection(obj, 'next_trial');

        %store the state matrix and prepare next trial state names in the
        %variables we created in the init case
        SMA.value = sma;
        PrepareNextTrialStates.value = prepare_next_trial_states;

        %update the n_prepped_trials counter so we know how many times
        %we've come through here
        n_prepped_trials.value = value(n_prepped_trials) + 1;
    
    %add this section until end    
    elseif strcmp(varargin{1},'crashed')
        %We're here because dispatcher caught an error and crashed.
        %RunningSection calls prepare_next_trial in the running protocol
        %but also adds an extra input variable, the string 'crashed' so
        %that's how we know things aren't normal.  Now the question is did
        %we crash after prepping the next trial or are we still early in
        %the current trial and haven't prepped it yet
        
        if value(n_prepped_trials) < value(n_started_trials)
            %By comparing the n_prepped_trials to n_started trials we see
            %that we have not been through here on this trial, so let's 
            %append all the variables that grow on each trial and then 
            %we'll resend the same state matrix we're currently running
            
            %okay so here you need to dig through your normal
            %prepare_next_trial code above and figure out what variables
            %grow on each trial, then append them here with a useful
            %variable like nan. 
            
            %You need to make sure this function has read write access to 
            %these variables. To do that after creating the variable in the
            %subfunction's init case call
            %
            %SoloFunctionAddVars('ThisFunctionsName', 'rw_args',{'VariablesName'});
            %
            %So for example in PBups RewardsSection.m we call
            %SoloFunctionAddVars('PBups', 'rw_args',{'nTrials'});
            
            hit_history.value          = [hit_history(:)         ; nan];
            violation_history.value    = [violation_history(:)   ; 1];
            nTrials.value              = nTrials                 + 1;
            %There's likely many variables you'll need to add here
            
            %Again append n_prepped trials
            n_prepped_trials.value = value(n_prepped_trials) + 1;
            
        end
        
        %If we determine we have crashed but HAVE already been through here
        %this trial we do not do anything and we do not append the
        %n_prepped_trials counter
    end
    
    %now make your call to dispatcher sending the sma variable and list of
    %prepare next trial state names
    dispatcher('send_assembler', value(SMA), value(PrepareNextTrialStates));

    %This is just some house keeping stuff that everyone should have in
    %their prepare_next_trial case
    % invoke autosave
    SavingSection(obj, 'autosave_data');

    if n_done_trials==1
        [expmtr, rname]=SavingSection(obj, 'get_info');
        %Title should be protocol specific so change PBups to your protocol name
        prot_title.value=['PBups - on rig ' get_hostname ' : ' expmtr ', ' rname  '.  Started at ' datestr(now, 'HH:MM')];
    end
    
    try send_n_done_trials(obj); end
    
    %and that's it