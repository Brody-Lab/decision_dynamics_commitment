% Typical section code-- this file may be used as a template to be added 
% on to. The code below stores the current figure and initial position when
% the action is 'init'; and, upon 'reinit', deletes all SoloParamHandles 
% belonging to this section, then calls 'init' at the proper GUI position 
% again.


% [x, y] = YOUR_SECTION_NAME(obj, action, x, y)
%
% Section that takes care of YOUR HELP DESCRIPTION
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%            'init'      To initialise the section and set up the GUI
%                        for it
%
%            'reinit'    Delete all of this section's GUIs and data,
%                        and reinit, at the same position on the same
%                        figure as the original section GUI was placed.
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
%
%%% CVS version control block - do not edit manually
%%%  $Revision$
%%%  $Date$
%%%  $Source$

function [xpos, ypos, WaterDeliverySPH,CurrentBlockSPH] = SidesSection(obj, action, varargin)

GetSoloFunctionArgs;
%%% Imported objects (see protocol constructor):
%%%  'MaxTrials'
%%%  'RewardSideList'
%%%  'CatchTrialsList'


switch action
  case 'init',
    % Save the figure and the position in the figure where we are
    % going to start adding GUI elements:
    xpos = varargin{1};
    ypos = varargin{2};
    SoloParamHandle(obj, 'my_gui_info', 'value', [xpos ypos gcf]);

    % -- Anti-bias method --
    MenuParam(obj, 'AntiBiasMethod', {'none','repeat mistake'}, 'none', ...
        xpos, ypos, 'TooltipString', 'Method for reducing bias');
    next_row(ypos);
    % --- Max times same side can appear ---
    MenuParam(obj, 'MaxSame', {'1', '2', '3', '4', '5', '6', '7', 'Inf'}, 4, ...
        xpos, ypos, 'TooltipString', 'Maximum number of times the same side can appear');
    set_callback(MaxSame, {mfilename, 'update_rewardsides'});
    next_row(ypos);
    % --- Prob of choosing left side ---
    NumeditParam(obj, 'LeftProb', 0.5, xpos, ypos); next_row(ypos);
    set_callback(LeftProb, {mfilename, 'update_rewardsides'});
    % --- Reward delivery mode --
    MenuParam(obj, 'WaterDeliverySPH',...
              {'direct', 'next corr poke','only if nxt pke corr'}, 3, xpos, ypos,...
              'label','WaterDelivery','TooltipString', 'Type of delivery');
    next_row(ypos,1.5);
    % --- Probability of a trial being a catch trial ---
    NumeditParam(obj, 'CatchProb', 0.0, xpos, ypos); next_row(ypos);
    set_callback(CatchProb, {mfilename, 'update_catchtrialslist'});
    %set(get_ghandle(CatchProb),'Enable','off');

    % --- Current block ---
    MenuParam(obj, 'CurrentBlockSPH', ...
              {'fixed-delay', 'rand-delay','long-delay', 'short-delay',...
               'target-left','target-right'},...
              'fixed-delay', xpos, ypos,...
              'label','CurrentBlock'); next_row(ypos);

    % --- Store previous reward side (to use for anti-bias) ---
    SoloParamHandle(obj, 'previous_sides', 'value', 'l');
    
    SubheaderParam(obj, 'title', 'Sides Section', xpos, ypos);
    next_row(ypos, 1.0);

    % -- Fill RewardSideList (l: Left  r: Right) --
    SidesSection(obj,'update_rewardsides');

    
  case 'apply_antibias'
    % -- If antibias, check if last response was a mistake --
    %%%% Not tested with catch trials (yet) %%%%    
    if(strcmp(value(AntiBiasMethod), 'repeat mistake'))
        if(~isempty(parsed_events.states.error_trial) |...
           ~isempty(parsed_events.states.error_trial_nextcorr))
            RewardSideList.values(n_done_trials+1) = RewardSideList.values(n_done_trials);
        end
    end
  
  
  case 'update_rewardsides'
    %%%  Note: USES N_DONE_TRIALS %%%
    
    % -- Applying LeftProb (probability of left reward) --
    FutureIndexes = (n_done_trials+1:value(MaxTrials));
    FutureLeftSides = rand(length(FutureIndexes),1)<value(LeftProb);

    % -- Applying MaxSame (change trial if last N trials are the same) --
    if ~strcmp(value(MaxSame), 'inf')
        for ind=value(MaxSame)+1:length(FutureLeftSides)
            SumLastSides = sum(FutureLeftSides(ind-MaxSame:ind));
            if(SumLastSides==value(MaxSame)+1)
                FutureLeftSides(ind)=0;
            elseif(SumLastSides==0)
                FutureLeftSides(ind)=1;
            end
        end
    end
    
    %SideLabels = 'rl';
    %RewardSideList(FutureIndexes) = SideLabels(FutureLeftSides+1);
    RewardSideList.values(FutureIndexes) = FutureLeftSides + 2*(~FutureLeftSides);

    SidesSection(obj,'update_catchtrialslist');
    
    
  case 'update_catchtrialslist'
    
    FutureIndexes = (n_done_trials+2:value(MaxTrials));
    FutureList = rand(length(FutureIndexes),1)<value(CatchProb);
    
    CatchTrialsList(FutureIndexes) =  FutureList;
    if(n_done_trials==0)
        %%SidesPlotSection(obj, 'update', n_done_trials+1, value(RewardSideList),[],IncongruentTrials);
        %% It doesn't work because something hasn't been initialized.
    else
        RewardSideListLabels = 'lr';
        SidesPlotSection(obj, 'update', n_done_trials+1, ...
                         RewardSideListLabels(RewardSideList.values),[],...
                         value(CatchTrialsList));        
    end
    
    
    %%%%% DISABLED temporarily %%%%%%%%
    if(~1)
    %TrialSpacing = value(ProbingContextEveryNtrialsSPH);
    
    ProbingTrials = [TrialSpacing:TrialSpacing:length(FutureList)];
    ProbingTrials(2:end-1)=ProbingTrials(2:end-1)+ceil(3*rand(1,length(ProbingTrials)-2)-2);
    FutureList(ProbingTrials) = 1;
    end
    %%%%% DISABLED temporarily %%%%%%%%
    
    
    
    
  case 'reinit',
    currfig = gcf;

    % Get the original GUI position and figure:
    xpos = my_gui_info(1); ypos = my_gui_info(2); figure(my_gui_info(3));

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);

    % Reinitialise at the original GUI position and figure:
    [xpos, ypos] = feval(mfilename, obj, 'init', xpos, ypos);

    % Restore the current figure:
    figure(currfig);

end %%% SWITCH


    
