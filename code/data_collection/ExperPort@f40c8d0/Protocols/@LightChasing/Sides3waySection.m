% [x, y] = SidesSection3way(obj, action, x, y)
%
% Section for choosing sides in a 3 way design, allows for user to
% determine the probability of center and left (right is automatically
% chosen the rest of the time).  Uses the Antibias3waySection to prevent 
% biased performance given the previous hit history.
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%                 'init'      
%                     To initialise the section and set up the GUI
%                     for it
%
%                 'get_probs' 
%                     Returns the current target probabilities acquired
%                     from Antibias3waySection, center and left in that
%                     order.
%            
%                 'prepare_next_trial'
%                     Gets the weighted probabilities from Antibias3way,
%                     then chooses a side for this trial using a randomly
%                     generated number, deletes the last side from the
%                     history if dispatcher is not running, adds the
%                     current side to the history.
%
%                 'update_plot'
%                     Redraws a plot of hits and misses, with each side
%                     appearing at a different value on the y axis.
%
%                 'get_current_side'
%                     Returns the current side in single character format
%                     (eg, c, l or r)
%
%                 'reinit'    
%                     Delete all of this section's GUIs and data,
%                     and reinit, at the same position on the same
%                     figure as the original section GUI was placed.
%
% x, y     Relevant to action = 'init'; they indicate the initial
%          position to place the GUI at, in the current figure window
%
% RETURNS:
% --------
%
% [x, y]   When action == 'init', returns x and y, pixel positions on
%          the current figure, updated after placing of this section's GUI.


function [x, y] = Sides3waySection(obj, action, varargin)
   
GetSoloFunctionArgs(obj);

switch action

%% init  
  case 'init',
      
    if length(varargin) <2
        error('Need at least two arguments, x and y position, to initialize %s', mfilename);
    end;
    x = varargin{1}; y = varargin{2};
    
    if length(varargin) >2
        width = varargin{3};  
    else
        width = 200;
    end;
    
    % Save the figure and the position in the figure where we are
    % going to start adding GUI elements:
    SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);

    %Get the Target Probabilities input by the user and display them
    Probs = Antibias3waySection(obj, 'get', 'TargetProbs');
    CenterProb = Probs(1); %#ok<NASGU>
    LeftProb   = Probs(2); %#ok<NASGU>
    
    
    ToggleParam(obj, 'center_side', 0, x, y, 'position', [x y width 20], 'TooltipString', ...
      sprintf('\nIf ON, center can be a side choice, but if OFF, center only as a poke before a side.'), ...
      'OnString', 'Left, Right & Center', 'OffString', 'Only Left & Right');
    next_row(y, 1);

    DispParam(obj, 'ThisTrial', 'LEFT', x, y, 'position', [x+2 y width-2 20]); y = y+20;
    sides_history.value = '';
    
    MenuParam(obj, 'MaxSame', {'1', '2', '3', '4', '5', '6', '7', '8', 'Inf'}, 3, ...
        x, y, 'position', [x y 140 20], ...
       'TooltipString', 'Maximum number of times the same side (L or R) can appear');
    next_row(y); 

    %Title of Display is Sides 3way Section
    SubheaderParam(obj, 'title', 'Sides 3way Section', x, y, 'position', [x+2 y width-2 20]);
    next_row(y, 1.5);

    % plot of side choices history at top of window
    pos = get(gcf, 'Position');
    SoloParamHandle(obj, 'myaxes', 'saveable', 0, 'value', axes);
    set(value(myaxes), 'Units', 'pixels');
    set(value(myaxes), 'Position', [90 pos(4)-140 pos(3)-210 100]);
    set(value(myaxes), 'YTick', [1 1.5 2], 'YLim', [0.5 2.5]);
    
    xlabel('trial number');
    SoloParamHandle(obj, 'previous_plot', 'saveable', 0);
    
    SoloParamHandle(obj, 'counter',    'value', []);
    SoloParamHandle(obj, 'block_type', 'value', []);
    
    SoloParamHandle(obj, 'after_load_callbacks', 'value', []);
    set_callback(after_load_callbacks, {mfilename, 'update_plot'});
    set_callback_on_load(after_load_callbacks, 1);
    
    
%% get_probs   
% -----------------------------------------------------------------------
%
%         GET_PROBS
%
% -----------------------------------------------------------------------

  case 'get_probs',
    x = value(CenterProb); %#ok<NODEF>
    y = value(LeftProb); %#ok<NODEF>
    

%% prepare_next_trial    
% -----------------------------------------------------------------------
%
%         PREPARE_NEXT_TRIAL
%
% -----------------------------------------------------------------------

  case 'prepare_next_trial',
    %Get the weighted probability for this trial based on performance
    if center_side == 0 %#ok<NODEF>
        feval(mfilename, obj, 'no_center');
    end;
    
    posterior = Antibias3waySection(obj, 'get_posterior_probs');
    pcenter = posterior(1);
    pleft   = posterior(2);
    
    P = [pleft pcenter 1-(pleft+pcenter)];
    
    
    if n_started_trials >= value(MaxSame),
      if all(sides_history(n_started_trials-MaxSame+1:n_started_trials) == ...
          sides_history(n_started_trials)), %#ok<NODEF>
      
        if sides_history(n_started_trials) == 'l'
            P(1) = 0; P = P / sum(P);
        elseif sides_history(n_started_trials) == 'c'
            P(2) = 0; P = P / sum(P);
        elseif sides_history(n_started_trials) == 'r'
            P(3) = 0; P = P / sum(P);
        end 
      end
    end
    
    if sum(P) ~= 1
        disp('Probabilities do not sum to 1. Defaulting to L=0.5 and R=0.5');
        P = [0.5 0 0.5];
    end
    
    pleft = P(1);
    pcenter = P(2);
    
    trialvalue = rand(1);
    
    %Use random value to choose a side
    if value(trialvalue)>=(pcenter+pleft),	ThisTrial.value = 'RIGHT';
    else if trialvalue >= (pcenter),        ThisTrial.value = 'LEFT';
        else                                ThisTrial.value = 'CENTER';
        end;
    end;
    
    oldsides = value(sides_history); %#ok<NODEF>
    if ~dispatcher('is_running'), ...                                       %Was semicolon here, was there supposed to be?
      % We're not running, last side wasn't used, lop it off:
      oldsides = oldsides(1:end-1); 
    end;
    %Add this trial's side choice to sides_history
    if isequal(ThisTrial, 'CENTER'),
            sides_history.value = [oldsides 'c']; %#ok<NODEF>
    else if isequal(ThisTrial, 'LEFT'),
            sides_history.value = [oldsides 'l']; %#ok<NODEF>
        else
            sides_history.value = [oldsides 'r']; %#ok<NODEF>
         end;
    end;
    
%% update_plot
% -----------------------------------------------------------------------
%
%         UPDATE_PLOT
%
% -----------------------------------------------------------------------

  case 'update_plot',      
    blues = find(late_history==1);
    if isempty(blues),
        reds  = find(hit_history==0);
    else
        reds  = find((wrong_history-hit_history)==1);
    end;
    greens    = find(hit_history==1);
    blacks    = find((hit_history+wrong_history)==2);
 
    ax = value(myaxes);
    delete(get(ax, 'Children'));
    
    lefts  = find(sides_history(1:end-1) == 'l'); %#ok<NODEF>
    rights = find(sides_history(1:end-1) == 'r');
    
    prolefts = find(types_history(lefts) == 'p');
    prorights= find(types_history(rights)== 'p');
    
    antilefts = find(types_history(lefts) == 'a');
    antirights= find(types_history(rights)== 'a');
            
    if ~isempty(prolefts ), totproleft  = length(prolefts ); else totproleft  = 0; end;
    if ~isempty(prorights), totproright = length(prorights); else totproright = 0; end;

    if ~isempty(antilefts ), totantileft  = length(antilefts ); else totantileft  = 0; end;
    if ~isempty(antirights), totantiright = length(antirights); else totantiright = 0; end;

    antitoplable    = strcat('Anti: LEFT (', num2str(totantileft),  ')');    
    antibottomlable = strcat(     'RIGHT (', num2str(totantiright), ')');
    
    protoplable    = strcat('Pro: LEFT (', num2str(totproleft),  ')');    
    probottomlable = strcat(    'RIGHT (', num2str(totproright), ')');
    
    plot(ax, greens, (types_history(greens)=='a')*2   + ...
                     (sides_history(greens)=='l')*2   + ...
                     (sides_history(greens)=='c')*1.5 + ...
                     (sides_history(greens)=='r'),    'g.'); %#ok<NODEF>
    hold(ax, 'on');

    plot(ax, blues,  (types_history(blues)=='a')*2   + ...
                     (sides_history(blues)=='l')*2   + ...
                     (sides_history(blues)=='c')*1.5 + ...
                     (sides_history(blues)=='r'),    'b.'); %#ok<NODEF>
    hold(ax, 'on');

    plot(ax, blacks, (types_history(blacks)=='a')*2   + ...
                     (sides_history(blacks)=='l')*2   + ...
                     (sides_history(blacks)=='c')*1.5 + ...
                     (sides_history(blacks)=='r'),    'k.'); %#ok<NODEF>
    hold(ax, 'on');
   
    plot(ax, reds,   (types_history(reds) == 'a')*2   + ...
                     (sides_history(reds) == 'l')*2   + ...
                     (sides_history(reds) == 'c')*1.5 + ...
                     (sides_history(reds) == 'r'),    'r.');
    hold(ax, 'on');
 
    plot(ax, n_done_trials+1, (types_history(n_done_trials+1)=='a')*2   + ...
                              (sides_history(n_done_trials+1)=='l')*2   +...
                              (sides_history(n_done_trials+1)=='c')*1.5 +...
                              (sides_history(n_done_trials+1)=='r'),    'b.');
    hold (ax, 'off');
    set(ax, 'Ylim', [0.5 4.5], 'XLim', [0 n_done_trials+1], ...
      'YTick', [1 2 3 4], 'YTickLabel', {probottomlable, protoplable, antibottomlable, antitoplable});
    xlabel(ax, 'Trial number');
    
%% get_current_side    
% -----------------------------------------------------------------------
%
%         GET_CURRENT_SIDE
%   
% -----------------------------------------------------------------------

    %Returns l if side is Left, c if side is Center, and r if side is
    %Right.

  case 'get_current_side',
    if isequal(ThisTrial, 'LEFT'), %#ok<NODEF>
        x = 'l';
    else if isequal(ThisTrial, 'CENTER'), %#ok<NODEF>
        x = 'c';
        else
        x = 'r';
        end;
    end;
    
%% no_center
%--------------------------------------------------------------------------
%
%         NO_CENTER
%
%--------------------------------------------------------------------------

  case 'no_center',
     TargetProbs = Antibias3waySection(obj, 'get', 'TargetProbs');
     LProb = TargetProbs(2) + 0.5*TargetProbs(1);
     Antibias3waySection(obj, 'set_target_probs', 0, LProb);
     center_side.value = 0;
     



%% reinit      
% -----------------------------------------------------------------------
%
%         REINIT
%
% -----------------------------------------------------------------------

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

