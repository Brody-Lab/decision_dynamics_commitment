function TrialEventsNSpike(obj, action);    
%  
% Saves the events, during and after each trial. The events are saved in the
% SoloParamHandle 'LastTrialEvents'. The events consist of a matrix whos columns are:
% 1. The state
% 2. The action taken
% 3. The time of the action, according to the state machine
% 4. The resulting state
% 5. The time of the action, according to the nspike machine
% 
% The 5th column is only present when the data is collected on a machine connected to
% an nspike machine.
% 
% The actions correspond to the columns of the state matrix:
% 1 - center in
% 2 - center out
% 3 - left in
% 4 - left out
% 5 - right in
% 6 - right out
% 
% Note that this matrix is largely redundant with the LastTrialEvents matrix
% created by the call 'GetParam('rpbox', 'event', 'user');', commonly found
% in 'CurrentTrialPokesSubsection'. The functional difference is that that
% matrix does not have the nspike time (the 5th column). It is possible
% that one of these will 'disappear' in the near future.
%
% This function should be called during initialization, trial_finished_actions
% (cases 'end_of_trial_update' and 'push_history_then_reset'), and
% within_trial_update_actions.
% 
% $ Version 2.0, GF 1/23/07 (adapted from code from Masa M)
% 
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

GetSoloFunctionArgs;

persistent lasttrialeventcounter machine

switch action,
    case 'init',
        
        SoloParamHandle(obj, 'LastTrialEvents', 'value', []);
                
        lasttrialeventcounter=1;
        
       global fake_rp_box;
       global state_machine_server;

       if fake_rp_box==2,
           machine=RTLSM(state_machine_server);
       elseif fake_rp_box==3,
           machine=RPBox('getstatemachine');
       end;
       
    case 'within_trial_update',
        eventcounter=GetEventCounter(machine);
        events=GetEvents(machine,lasttrialeventcounter,eventcounter);
        
        % transform the second column into the actions corresponding to the
        % columns of the stm
        actions = events(:, 2);
        actions(actions ~= 0) = log2(actions(actions ~= 0)) + 1; % don't take log2(0)
        events(:, 2) = actions;
        
        % save events in the sph
        LastTrialEvents.value=events;
       
    case 'end_of_trial_update',      
        eventcounter=GetEventCounter(machine);
        events=GetEvents(machine,lasttrialeventcounter,eventcounter);

        % transform the second column into the actions corresponding to the
        % columns of the stm
        actions = events(:, 2);
        actions(actions ~= 0) = log2(actions(actions ~= 0)) + 1; % don't take log2(0)
        events(:, 2) = actions;
        
        % save events in the sph
        LastTrialEvents.value=events;

        % update lasttrialeventcounter for the next trial (it's a
        % persistent variable)
        lasttrialeventcounter=eventcounter;
        
    case 'push_history_then_reset',
        push_history(LastTrialEvents);
        LastTrialEvents.value=[];
        
    case 'delete',
        if (~isa(machine, 'SoftSMMarkII')), 
            Close(machine);
        end;
    otherwise,
        error(['Don''t know how to deal with action ' action]);
end;
