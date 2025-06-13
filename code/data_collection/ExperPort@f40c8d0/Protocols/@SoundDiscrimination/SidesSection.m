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


function [x, y] = SidesSection(obj, action, x, y)
   
GetSoloFunctionArgs;

switch action

%% init  
  case 'init',
    % Save the figure and the position in the figure where we are
    % going to start adding GUI elements:
    SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);

    % Max times same side can appear
    MenuParam(obj, 'MaxSame', {'1', '2', '3', '4', '5', '6', '7', '8', 'Inf'}, 3, ...
        x, y, 'TooltipString', 'Maximum number of times the same side (L or R) can appear');
    next_row(y);  
    NumeditParam(obj, 'MaxWithout',    30, x, y); next_row(y);
    NumeditParam(obj, 'LeftProb',     0.5, x, y); next_row(y);
    DispParam(   obj, 'ThisTrial', 'LEFT', x, y); next_row(y);
    SoloParamHandle(obj, 'forcetrial', 'value', []);
    sides_history.value = '';

    SubheaderParam(obj, 'title', 'Sides Section', x, y);
    next_row(y, 0.5);

    
    
    % plot of side choices history at top of window
    pos = get(gcf, 'Position');
    SoloParamHandle(obj, 'myaxes', 'saveable', 0, 'value', axes);
    set(value(myaxes), 'Units', 'pixels');
    set(value(myaxes), 'Position', [90 pos(4)-200 pos(3)-130 160]);
    set(value(myaxes), 'YTick', [1 2], 'YLim', [0.1 2.1]);
    ToggleParam(obj, 'ViewState', 1, x,pos(4)-250, 'OnString','Expand',...
        'OffString','Collapse','position',[x+142 pos(4)-250 60 20]);
    set_callback(ViewState,{mfilename, 'update_plot'});

    xlabel('trial number');
    SoloParamHandle(obj, 'previous_plot', 'saveable', 0);
    
    SoloParamHandle(obj, 'counter',    'value', []);
    SoloParamHandle(obj, 'block_type', 'value', []);
    
    SoloParamHandle(obj, 'after_load_callbacks', 'value', []);
    set_callback(after_load_callbacks, {mfilename, 'update_plot'});
    set_callback_on_load(after_load_callbacks, 1);
    
    
    
%% get_left_prob   
% -----------------------------------------------------------------------
%
%         GET_LEFT_PROB
%
% -----------------------------------------------------------------------

  case 'get_left_prob',
    x = value(LeftProb);

    
%% get_forcetrial   
% -----------------------------------------------------------------------
%
%         GET_FORCETRIAL
%
% -----------------------------------------------------------------------

  case 'get_forcetrial',
    x = value(forcetrial);    
    
%% set_forcetrial   
% -----------------------------------------------------------------------
%
%         SET_FORCETRIAL
%
% -----------------------------------------------------------------------

  case 'set_forcetrial',
    forcetrial.value = x;    
    
    
%% prepare_next_trial    
% -----------------------------------------------------------------------
%
%         PREPARE_NEXT_TRIAL
%
% -----------------------------------------------------------------------

  case 'prepare_next_trial',
    posterior = AntibiasSection(obj, 'get_posterior_probs');
    pleft = sum(posterior(1:5));
    
    if n_started_trials >= MaxSame,
      if all(sides_history(n_started_trials-MaxSame+1:n_started_trials) == ...
          sides_history(n_started_trials)), %#ok<NODEF>
        if sides_history(n_started_trials) == 'l', pleft = 0;
        else                                       pleft = 1;
        end;
      end;
    end;
    
    %forcetrial.value = [];
    ns = PsychSection(obj,'get_numpsych');
    ph = PsychSection(obj,'get_psych_history');
    
    if n_done_trials > value(MaxWithout)
        gL = 1:ns;
        gR = 10:-1:10-ns+1;
        g  = [gL gR]; 
        for t = 1:10
            temp = find(ph == t);
            if isempty(temp); wo = n_done_trials;
            else              wo = n_done_trials - temp(end);
            end

            if wo >= value(MaxWithout) && ~isempty(find(g == t,1))
                forcetrial.value = t; disp(t)
                if t <= ns; ThisTrial.value = 'LEFT';
                else        ThisTrial.value = 'Right';
                end
                break;
            end
        end
    end
    
    if isempty(value(forcetrial))
        if rand(1)<pleft, ThisTrial.value = 'LEFT'; else ThisTrial.value = 'RIGHT'; end;
    else
        if value(forcetrial) <= ns; ThisTrial.value = 'LEFT';
        else                        ThisTrial.value = 'RIGHT';
        end
    end
    
    oldsides = value(sides_history); %#ok<NODEF>
    if ~dispatcher('is_running');
      % We're not running, last side wasn't used, lop it off:
      oldsides = oldsides(1:end-1); 
    end;
    if isequal(ThisTrial, 'LEFT'),
      sides_history.value = [oldsides 'l']; %#ok<NODEF>
    else
      sides_history.value = [oldsides 'r']; %#ok<NODEF>
    end;

    
    

%% update_plot
% -----------------------------------------------------------------------
%
%         UPDATE_PLOT
%
% -----------------------------------------------------------------------

  case 'update_plot',
    reds   = find(hit_history==0);
    greens = find(hit_history==1);
    
    ax = value(myaxes);
    delete(get(ax, 'Children'));
    
    tt = PsychSection(obj,'get_trialtype');
    ph = PsychSection(obj,'get_psych_history');
    if length(ph) < n_done_trials
        temp = value(sides_history);
        temp = temp(1:end-1);
        ph = zeros(length(temp),1);
        ph(temp == 'l') = 1;
        ph(temp == 'r') = 10;
    end
    
    if value(ViewState) == 1
        yvals = (1:10)/5;
        yt = (0.2:0.2:2);
        yl = {'1','2','3','4','5','6','7','8','9','10'};
    else
        yvals = [3 3 3 3 3 8 8 8 8 8] / 5;
        yt = [0.6 1.6];
        yl = {'Left','Right'};
    end
    
    plot(ax, [0 n_done_trials + 1], [1.1 1.1], '-', 'Color', [0.2 0.2 0.2]);
    hold(ax, 'on');
    for t = 1:10
        plot(ax, [0 n_done_trials + 1], [yvals(t) yvals(t)], ':', 'Color',[0.5 0.5 0.5]);
        plot(ax, greens(ph(greens)==t), ones(length([greens(ph(greens)==t)]),1) * yvals(t), 'g.');
        plot(ax,   reds(ph(reds)==t),   ones(length([reds(ph(reds)==t)]),1) * yvals(t),     'r.');
    end
    
%     plot(ax, greens, (sides_history(greens)=='l')+1, 'g.');
%     hold(ax, 'on');
%     plot(ax, reds,   (sides_history(reds)  =='l')+1, 'r.'); 
%     plot(ax, n_done_trials+1, (sides_history(n_done_trials+1)=='l')+1, 'b.');

    plot(ax, n_done_trials+1, tt/5, 'b.');
    hold (ax, 'off');
    set(ax, 'Ylim', [0.1 2.1], 'XLim', [0 n_done_trials+1],'YTick', yt, 'YTickLabel', yl);
    xlabel(ax, 'Trial number');
    
    
    
    
%% get_current_side    
% -----------------------------------------------------------------------
%
%         GET_CURRENT_SIDE
%
% -----------------------------------------------------------------------

  case 'get_current_side',
    if isequal(ThisTrial, 'LEFT'), %#ok<NODEF>
      x = 'l';
    else
      x = 'r';
    end;
    
%% get_maxwithout
% -----------------------------------------------------------------------
%
%         GET_MAXWITHOUT
%
% -----------------------------------------------------------------------

  case 'get_maxwithout',

      x = value(MaxWithout);


    
    
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

