% PWM protocol
% edited by Emily Dennis September 2018, based on AthenaDelayComp
% major overhaul March 2019
% clean up September 2021

function [obj] = PWM(varargin)

% Default object is of our own class (mfilename);
% we inherit only from Plugins
% removed pokesplot2
obj = class(struct, mfilename, saveload, sessionmodel, soundmanager, soundui, antibias, ...
  water, distribui, punishui, comments, soundtable, sqlsummary, AdLibGUI, reinforcement,cerebro2);
% TODO add AdLibGUI

%---------------------------------------------------------------
%   BEGIN SECTION COMMON TO ALL PROTOCOLS, DO NOT MODIFY
%---------------------------------------------------------------

% If creating an empty object, return without further ado:
if nargin==0 || (nargin==1 && ischar(varargin{1}) && strcmp(varargin{1}, 'empty')),
   return;
end;

if isa(varargin{1}, mfilename), % If first arg is an object of this class itself, we are
   % Most likely responding to a callback from
   % a SoloParamHandle defined in this mfile.
   if length(varargin) < 2 || ~ischar(varargin{2}),
      error(['If called with a "%s" object as first arg, a second arg, a ' ...
         'string specifying the action, is required\n']);
   else action = varargin{2}; varargin = varargin(3:end); %#ok<NASGU>
   end;
else % Ok, regular call with first param being the action string.
   action = varargin{1}; varargin = varargin(2:end); %#ok<NASGU>
end;

GetSoloFunctionArgs(obj);

%---------------------------------------------------------------
%   END OF SECTION COMMON TO ALL PROTOCOLS, MODIFY AFTER THIS LINE
%---------------------------------------------------------------


% ---- From here on is where you can put the code you like.
%
% Your protocol will be called, at the appropriate times, with the
% following possible actions:
%
%   'init'     To initialize -- make figure windows, variables, etc.
%
%   'update'   Called periodically within a trial
%
%   'prepare_next_trial'  Called when a trial has ended and your protocol
%              is expected to produce the StateMachine diagram for the next
%              trial; i.e., somewhere in your protocol's response to this
%              call, it should call "dispatcher('send_assembler', sma,
%              prepare_next_trial_set);" where sma is the
%              StateMachineAssembler object that you have prepared and
%              prepare_next_trial_set is either a single string or a cell
%              with elements that are all strings. These strings should
%              correspond to names of states in sma.
%                 Note that after the 'prepare_next_trial' call, further
%              events may still occur in the RTLSM while your protocol is thinking,
%              before the new StateMachine diagram gets sent. These events
%              will be available to you when 'trial_completed' is called on your
%              protocol (see below).
%
%   'trial_completed'   Called when 'state_0' is reached in the RTLSM,
%              marking final completion of a trial (and the start of 
%              the next).
%
%   'close'    Called when the protocol is to be closed.
%
%
% VARIABLES THAT DISPATCHER WILL ALWAYS INSTANTIATE FOR YOU IN YOUR 
% PROTOCOL:
%
% (These variables will be instantiated as regular Matlab variables, 
% not SoloParamHandles. For any method in your protocol (i.e., an m-file
% within the @your_protocol directory) that takes "obj" as its first argument,
% calling "GetSoloFunctionArgs(obj)" will instantiate all the variables below.)
%
%
% n_done_trials     How many trials have been finished; when a trial reaches
%                   one of the prepare_next_trial states for the first
%                   time, this variable is incremented by 1.
%
% n_started trials  How many trials have been started. This variable gets
%                   incremented by 1 every time the state machine goes
%                   through state 0.
%
% parsed_events     The result of running disassemble.m, with the
%                   parsed_structure flag set to 1, on all events from the
%                   start of the current trial to now.
%
% latest_events     The result of running disassemble.m, with the
%                   parsed_structure flag set to 1, on all new events from
%                   the last time 'update' was called to now.
%
% raw_events        All the events obtained in the current trial, not parsed
%                   or disassembled, but raw as gotten from the State
%                   Machine object.
%
% current_assembler The StateMachineAssembler object that was used to
%                   generate the State Machine diagram in effect in the
%                   current trial.
%
% Trial-by-trial history of parsed_events, raw_events, and
% current_assembler, are automatically stored for you in your protocol by
% dispatcher.m. See the wiki documentation for information on how to access
% those histories from within your protocol and for information.
%


switch action

    %---------------------------------------------------------------%
    %          init                                                 %
    %---------------------------------------------------------------%
    case 'init'

        getSessID(obj);
        dispatcher('set_trialnum_indicator_flag');

        % Make default figure. We remember to make it non-saveable; on next run
        % the handle to this figure might be different, and we don't want to
        % overwrite it when someone does load_data and some old value of the
        % fig handle was stored as SoloParamHandle "myfig"
        SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = double(figure);
        
        % Make the title of the figure be the protocol name, and if someone tries
        % to close this figure, call dispatcher's close_protocol function, so it'll know
        % to take it off the list of open protocols.
        name = mfilename;
        set(value(myfig), 'Name', name, 'Tag', name, ...
          'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
         
        hackvar = 10; SoloFunctionAddVars('SessionModel', 'ro_args', 'hackvar'); %#ok<NASGU>

        % At this point we have one SoloParamHandle, myfig
        % Let's put the figure where we want it and give it a reasonable size:
        set(value(myfig), 'Position', [303   100   825   700]);

        %   ----------------------
        %   Let's declare some globals that everybody is likely to want to know about.
        %   ----------------------   

        %   History of hit/miss:
        SoloParamHandle(obj, 'hit_history', 'value', []);
        DeclareGlobals(obj, 'ro_args', {'hit_history'});
        %   Let SideSection write to hit_history:    
        % PBUPS USES RewardsSection for this
        SoloFunctionAddVars('SideSection', 'rw_args', 'hit_history');

        %   History of pairs:
        SoloParamHandle(obj, 'pair_history', 'value', []);
        DeclareGlobals(obj, 'ro_args', {'pair_history'});
        %   Let PWMSection write to pair_history:    
        SoloFunctionAddVars('PWMSection', 'rw_args', 'pair_history');    

        %   History of violations:  
        SoloParamHandle(obj, 'violation_history', 'value', []);
        DeclareGlobals(obj, 'ro_args', {'violation_history'});
        %   Let SideSection write to violation_history
        SoloFunctionAddVars('SideSection', 'rw_args', 'violation_history');

        %   History of timeouts:
        SoloParamHandle(obj, 'timeout_history', 'value', []);
        DeclareGlobals(obj, 'ro_args', {'timeout_history'});
        %   Let SideSection write to timeout_history
        SoloFunctionAddVars('SideSection', 'rw_args', 'timeout_history');
       
        % save # of pokes
        SoloParamHandle(obj, 'nsessions_healthy_number_of_pokes', 'value', 0, 'save_with_settings', 1);
        % these two are always empty:
        SoloParamHandle(obj, 'post_PWMduration_protocol', 'value', '', 'save_with_settings', 1);
        SoloParamHandle(obj, 'post_DelCompZ_settings_filename', 'value', '', 'save_with_settings', 1);
            
        % From Plugins/@soundmanager:
        SoundManagerSection(obj, 'init');
        
        %   ----------------------
        %   Set up the main GUI window
        %   ----------------------

        x = 5; 
        y = 5;             % Initial position on main GUI window
        
        %%%%%%%%%%%%%%%%%%
        %%%% COLUMN 1 %%%%
        %%%%%%%%%%%%%%%%%%
        %   From Plugins/@saveload:
        [x, y] = SavingSection(obj,       'init', x, y); 
        
        %     % We use the following to generate a call that will occur after
        %     % any loading of data. We can use that to do any updates we may want.
        %   set_callback({maxasymp;slp;inflp;minasymp;assym}, {mfilename, 'change_water_modulation_params'});
        %   feval(mfilename, obj, 'change_water_modulation_params');
        %     SoloFunctionAddVars('PWMsma', 'ro_args', ...
        %           {'maxasymp';'slp';'inflp';'minasymp';'assym'});
        %   From Plugins/@water:     
        [x, y] = WaterValvesSection(obj,  'init', x, y);
        %   From Plugins/@wateradaptor -- adapt water/hit to maximize trialnum
        % TODO change over to adlibgui
        % [x, y] = AdLibGUISection(obj, 'init', x, y);    
        % ----------------------This is the default from PBups: 
        %   From Plugins/@wateradaptor -- adapt water/hit to maximize trialnum
        [ x, y] = AdLibGUISection(obj, 'init', x, y);
        % ----------------------end of default from PBups   
        
        % For plotting with the pokesplot plugin, we need to tell it what
        % colors to plot with:
            %my_state_colors = PWMsma(obj, 'get_state_colors');
        % In pokesplot, the poke colors have a default value, so we don't need
        % to specify them, but here they are so you know how to change them.
            % my_poke_colors = struct( ...
        %'L',                      [1 1 1],    ...
        %'C',                      [0 0 0],    ...
        %'R',                  [217    111 39]/255);
        
        %   From Plugins/@pokesplot:
        %[x, y] = PokesPlotSection(obj, 'init', x, y, ...
        %struct('states',  my_state_colors, 'pokes', my_poke_colors)); 
        %PokesPlotSection(obj, 'set_alignon', 'cp(1,1)');
        next_row(y);

        %   From Plugins/@comments:    
        [x, y] = CommentsSection(obj, 'init', x, y);
        SessionDefinition(obj, 'init', x, y, value(myfig)); 
        
        %%%%%%%%%%%%%%%%%%
        %%%% COLUMN 2 %%%%
        %%%%%%%%%%%%%%%%%%
        next_column(x); y=5;
        next_row(y)
        [x, y] = RewardsSection(obj,'init',x,y);  
        [x, y] = StimulatorSection(obj, 'init', x, y); 
        [x, y] = SideSection(obj,  'init', x, y); 
        [x, y] = SoundSection(obj, 'init', x,y);
        [x, y]= PWMSection(obj,'init',x,y);


        %%%%%%%%%%%%%%%%%%
        %%%% COLUMN 3 %%%%
        %%%%%%%%%%%%%%%%%%
        figpos = get(gcf, 'Position');
        [expmtr, rname]=SavingSection(obj, 'get_info');
        HeaderParam(obj, 'prot_title', [mfilename ': ' expmtr ', ' rname], x, y, 'position', [10 figpos(4)-25, 800 20]);

    
    %---------------------------------------------------------------%
    %          prepare_next_trial                                   %
    %---------------------------------------------------------------%
    case 'prepare_next_trial'

        if n_done_trials == 0; 
            %Stuff to happen after settings load but before first trial run
            PWMsma(obj, 'init'); 
            CommentsSection(obj, 'clear_history'); % Make sure we're not storing unnecessary history
        end
       
        SideSection(obj, 'prepare_next_trial');
        % Run SessionDefinition *after* SideSection so we know whether the
        % trial was a violation or not
        SessionDefinition(obj, 'next_trial');
        StimulatorSection(obj, 'update_values');
        RewardsSection(obj,'evaluate');
        PWMSection(obj,'prepare_next_trial');
        SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');

        nTrials.value = n_done_trials;

        [sma, prepare_next_trial_states] = PWMsma(obj, 'prepare_next_trial');

        % Default behavior of following call is that every 20 trials, the data
        % gets saved, not interactive, no commit to CVS.
        SavingSection(obj, 'autosave_data');

        CommentsSection(obj, 'clear_history'); % Make sure we're not storing unnecessary history
        if n_done_trials==1,  % Auto-append date for convenience.
            CommentsSection(obj, 'append_date'); CommentsSection(obj, 'append_line', '');
        end;

        if n_done_trials==1
            [expmtr, rname]=SavingSection(obj, 'get_info');
            prot_title.value=[mfilename ' on rig ' get_hostname ' : ' expmtr ', ' rname  '.  Started at ' datestr(now, 'HH:MM')];
        end

        try send_n_done_trials(obj); end
           
        if n_done_trials==1,
            AdLibGUISection(obj, 'set_first_trial_time_stamp');
        end

    
 
    %---------------------------------------------------------------%
    %          trial_completed                                      %
    %---------------------------------------------------------------%
    case 'trial_completed'
           
        % Do any updates in the protocol that need doing:
        feval(mfilename, 'update');
        % And PokesPlot needs completing the trial:
        %PokesPlotSection(obj, 'trial_completed');
        % MouseSection(obj,'trial_completed');

        if n_done_trials>0  
            side = SideSection(obj,'get_current_side');
            hits = value(hit_history);
            try
                AdLibGUISection(obj,'update_water_volume',side,hits(end));
            catch
                warning('AdLibGUI failed to update')
            end
        end

    %---------------------------------------------------------------%
    %          update                                               %
    %---------------------------------------------------------------%
    case 'update'
      %PokesPlotSection(obj, 'update');
      %% close


    %---------------------------------------------------------------%
    %          close                                                %
    %---------------------------------------------------------------%
    case 'close'
        %PokesPlotSection(obj, 'close');
        CommentsSection(obj, 'close');
        SessionDefinition(obj, 'delete');
        SoundSection(obj,'close');
        RewardsSection(obj,'close');
        StimulatorSection(obj,'close');
        SideSection(obj, 'close');
        PWMSection(obj,'close');
        AntibiasSectionPWM(obj,'close');
        try AdLibGUISection(obj,'close')
            catch warning('adlibgui stinks');
        end;    

        if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)), %#ok<NODEF>
            delete(value(myfig));
        end; 

        try
            delete_sphandle('owner', ['^@' class(obj) '$']);
        catch
            warning('Some SoloParams were not properly cleaned up');
        end

    %---------------------------------------------------------------%
    %          end_session                                          %
    %---------------------------------------------------------------%
    case 'end_session'
        prot_title.value = [value(prot_title) ', Ended at ' datestr(now, 'HH:MM')];
        try
            AdLibGUISection(obj, 'evaluate_outcome');
        catch
            warning('adlibgui eval outcome failed')
        end


    %---------------------------------------------------------------%
    %          pre_saving_settings                                  %
    %---------------------------------------------------------------%
    case 'pre_saving_settings'
        % Get active stage number for this session
        tsnum = SessionDefinition(obj, 'get_current_training_stage');
        PWMSection(obj,'hide');    
        SessionDefinition(obj, 'run_eod_logic_without_saving');
        perf = RewardsSection(obj,'evaluate');
        control = RewardsSection(obj,'control');
        cp_durs = SideSection(obj, 'get_cp_history');
        [classperf tot_perf]= PWMSection(obj, 'get_class_perform');
        [pairs_u pairs_d] = PWMSection(obj,'get_pairs');
        ctype=PWMSection(obj,'get_comparison_type');
        stype=PWMSection(obj,'get_sound_type');
        warmup = SideSection(obj,'get_warmup');
        sidelights = SideSection(obj,'get_sidelights');
        reward = SideSection(obj,'get_reward');
        psychpairs = PWMSection(obj,'get_psych_info_for_summary');
        control_history = PWMSection(obj,'get_control_history');
    
        % TODO Figure out whether we can acquire training stage string
        % from SessionDefinition in order to get rid of this logic
        if strcmp(RewardFromPoke,'spoke');
            if RewardSound==0;
                trainingstage = 'learning sides';
            else
                trainingstage = 'learning reward sounds';
            end
        else
            if strcmp(sidelights,'correct side')
                if warmup==1
                    trainingstage = 'grow nose poke';
                else
                    trainingstage = 'grow nose poke?';
                end
            else
                if strcmp(reward,'DelayedReward')
                    trainingstage = 'delayed';
                elseif strcmp(reward,'Always')
                    trainingstage = 'always';
                elseif  strcmp(reward,'NoReward')&& psychpairs<0.01
                    trainingstage = 'never';
                elseif  strcmp(reward,'NoReward')&& psychpairs>0
                    trainingstage = 'psych';
                else
                trainingstage = 'unknown sloff';
                end
            end
        end
        trainingstage = sprintf('%i %s', tsnum, trainingstage);

        CommentsSection(obj, 'append_line', ...
            sprintf(['%s, t= %d, v= %.2f, h= %.2f\n', ...
            'delta=%.1f\n', ...
            ' %s', ' %s' , ' %s'], ...
            trainingstage, perf(1), perf(2), perf(6), ...
            max(cp_durs),ctype,stype,control));


        pd.hits=hit_history(:);
        pd.sides=previous_sides(:);
        pd.viols=violation_history(:);
        pd.timeouts=timeout_history(:);
        pd.performance=tot_perf(:);
        pd.cp_durs=cp_durs(:);
        pd.pairs_u=pairs_u(:);
        pd.pairs_d=pairs_d(:);
        pd.pairs=pair_history(:);
        pd.control=control_history(:);
        %pd.stimul=stim_history(:);
    
        % % ADDED FOR VIDEO
        leftwatertime  = zeros(numel(parsed_events_history),1); 
        leftwatertime(:)  = nan;
        rightwatertime = zeros(numel(parsed_events_history),1); 
        rightwatertime(:) = nan;
        for i = 1:numel(parsed_events_history)
            right  = parsed_events_history{i}.states.drink_state;
            if ~isempty(right); rightwatertime(i) = mean(right); end
        end
        pd.leftwatertime  = leftwatertime;
        pd.rightwatertime = rightwatertime;

        %sendsummary(obj, 'sides', pd.sides, 'protocol_data', pd);
        sendsummary(obj,'protocol_data',pd);       
  
    %---------------------------------------------------------------%
    %          otherwise                                            %
    %---------------------------------------------------------------%
    otherwise
        warning('Unknown action! "%s"\n', action);
    end;
return;

