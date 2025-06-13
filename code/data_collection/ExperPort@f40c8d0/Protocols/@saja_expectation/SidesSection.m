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


function [x, y, WaterDeliverySPH, RelevantSideSPH] = SidesSection(obj, action, varargin)
   
GetSoloFunctionArgs;
%%% Imported objects (see protocol constructor):
%%%  'MaxTrials'
%%%  'RewardSideList' (created empty on protocol constructor)
%%%  'ProbingContextTrialsList'
%%%  'DistractorList' (created empty on protocol constructor)

switch action
  case 'init',
    % Save the figure and the position in the figure where we are
    % going to start adding GUI elements:
    x = varargin{1};
    y = varargin{2};
    SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);

    % -- Anti-bias method --
    MenuParam(obj, 'AntiBiasMethod', {'none','repeat mistake'}, 'none', ...
        x, y, 'TooltipString', 'Method for reducing bias');
    next_row(y);
    % -- Reward method --
    MenuParam(obj, 'WaterDeliverySPH',...
              {'direct', 'next corr poke','only if nxt pke corr'}, 2, x, y,...
              'label','WaterDelivery','TooltipString', 'Type of delivery');
    next_row(y);
    % --- Max times same side can appear ---
    MenuParam(obj, 'MaxSame', {'1', '2', '3', '4', '5', '6', '7', 'Inf'}, 4, ...
        x, y, 'TooltipString', 'Maximum number of times the same side can appear');
    set_callback(MaxSame, {mfilename, 'update_rewardsides'});
    next_row(y);
    % --- Prob of choosing left side ---
    NumeditParam(obj, 'LeftProb', 0.5, x, y); next_row(y);
    set_callback(LeftProb, {mfilename, 'update_rewardsides'});

    next_row(y, 0.5);
    NumeditParam(obj, 'ProbingContextEveryNtrialsSPH', 2000, x, y,...
                 'label','InvalidContextEveryNtrials'); next_row(y);
    set_callback(ProbingContextEveryNtrialsSPH, {mfilename, 'update_distractorlist'});
    %%%set(get_ghandle(ProbingContextEveryNtrialsSPH),'Enable','off');
   
    %NumeditParam(obj, 'IncongruentProb', 0.5, x, y,...
    %             'label','IncongrProb'); next_row(y);
    %set_callback(IncongruentProb, {mfilename, 'update_distractorlist'});
    %set(get_ghandle(IncongruentProb),'Enable','off');
   
    MenuParam(obj, 'RelevantSideSPH', {'left' 'right'}, 'left', x, y,...
              'label','RelevantSide'); next_row(y);
    %set_callback(RelevantSideSPH, {'SoundsSection', 'update_all_sounds'});
    next_row(y, 0.5);

    SoloParamHandle(obj, 'previous_sides', 'value', 'l');
    SubheaderParam(obj, 'title', 'Sides Section', x, y);
    next_row(y, 1.0);
    
    % -- Fill RewardSideList (l: Left  r: Right) --
    SidesSection(obj,'update_rewardsides');

    
  case 'apply_antibias'
    % -- If antibias, check if last response was a mistake --
    %%%% Not tested with catch trials (yet) %%%%    
    if(strcmp(value(AntiBiasMethod), 'repeat mistake'))
        if(~isempty(parsed_events.states.errortrial) |...
           ~isempty(parsed_events.states.misstrial))
            NextTrial = n_done_trials;
            RewardSideList(NextTrial) = RewardSideList(NextTrial-1);
        end
    end

    
  case 'update_rewardsides'
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
    
    SideLabels = 'rl';
    RewardSideList(FutureIndexes) = SideLabels(FutureLeftSides+1);

    SidesSection(obj,'update_distractorlist');
    
    
  case 'update_distractorlist'
    FutureIndexes = (n_done_trials+1:value(MaxTrials));
    % -- Set future ProbingContext trials (1:invalid 0:valid) --
    %IncongList = rand(1, length(FutureIndexes))<value(IncongruentProb);
    %NewDistrList = xor(value(RewardSideList(FutureIndexes))=='l',IncongList);
    %DistractorList(FutureIndexes) = NewDistrList;
    %IncongruentTrials = xor(value(RewardSideList)=='l',value(DistractorList));

    FutureList = zeros(length(FutureIndexes),1);
    TrialSpacing = value(ProbingContextEveryNtrialsSPH);
    ProbingTrials = [TrialSpacing:TrialSpacing:length(FutureList)];
    ProbingTrials(2:end-1)=ProbingTrials(2:end-1)+ceil(3*rand(1,length(ProbingTrials)-2)-2);
    FutureList(ProbingTrials) = 1;
    ProbingContextTrialsList(FutureIndexes) =  FutureList;
    
    if(n_done_trials==0)
        %%SidesPlotSection(obj, 'update', n_done_trials+1, value(RewardSideList),[],IncongruentTrials);
        %% It doesn't work because something hasn't been initialized.
    else
        SidesPlotSection(obj, 'update', n_done_trials, value(RewardSideList),[],...
                         value(ProbingContextTrialsList));        
    end
    
    
  case 'reinit',
    currfig = gcf;

    % Get the original GUI position and figure:
    x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);

    % Reinitialise at the original GUI position and figure:
    [x, y] = feval(mfilename, obj, 'init', x, y);

    % Restore the current figure:
    figure(currfig);
end;


