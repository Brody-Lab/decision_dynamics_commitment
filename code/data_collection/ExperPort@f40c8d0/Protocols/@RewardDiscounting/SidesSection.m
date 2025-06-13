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

    NumeditParam(obj, 'LeftProb',     0.5, x, y); next_row(y);
    DispParam(   obj, 'ThisTrial', 'LEFT', x, y); next_row(y);
    MenuParam(obj, 'Trial_Type', {'Free', 'Forced'}, 1, x, y); next_row(y, 1.5);
    %sides_history.value = '';
    
    set_callback(Trial_Type, {mfilename, 'update_thistrial'});

    SubheaderParam(obj, 'title', 'Sides Section', x, y);
    next_row(y, 0.5);

    % plot of side choices history at top of window
    pos = get(gcf, 'Position');
    SoloParamHandle(obj, 'myaxes', 'saveable', 0, 'value', axes);
    set(value(myaxes), 'Units', 'pixels');
    set(value(myaxes), 'Position', [90 pos(4)-200 pos(3)-130 160]);
    set(value(myaxes), 'YTick', [1 2], 'YLim', [0.5 2.5]);

    xlabel('trial number');
    SoloParamHandle(obj, 'previous_plot', 'saveable', 0);
    
    SoloParamHandle(obj, 'counter',    'value', 0);
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

    
%% get_trial_type   
% -----------------------------------------------------------------------
%
%         GET_TRIAL_TYPE
%
% -----------------------------------------------------------------------

  case 'get_trial_type',
    x = value(Trial_Type);  
    
    
%% update_thistrial 
% -----------------------------------------------------------------------
%
%         UPDATE_THISTRIAL
%
% -----------------------------------------------------------------------

  case 'update_thistrial',
    if strcmp(Trial_Type,'Forced')
        if rand(1)<LeftProb, ThisTrial.value = 'LEFT'; 
        else                 ThisTrial.value = 'RIGHT'; 
        end;
    else
        ThisTrial.value = 'FREE';
    end    
    
    
%% prepare_next_trial    
% -----------------------------------------------------------------------
%
%         PREPARE_NEXT_TRIAL
%
% -----------------------------------------------------------------------

  case 'prepare_next_trial',
    
    if strcmp(Trial_Type,'Forced')
        if rand(1)<LeftProb, ThisTrial.value = 'LEFT'; 
        else                 ThisTrial.value = 'RIGHT'; 
        end;
    else
        ThisTrial.value = 'FREE';
    end
        
    oldsides = value(sides_history); %#ok<NODEF>
    if ~dispatcher('is_running');
        % We're not running, last side wasn't used, lop it off:
        oldsides = oldsides(1:end-1); 
    end;
    if isequal(ThisTrial, 'LEFT'),
        sides_history.value = [oldsides; 'l']; %#ok<NODEF>
    elseif isequal(ThisTrial, 'RIGHT')
        sides_history.value = [oldsides; 'r']; %#ok<NODEF>
    else
        sides_history.value = [oldsides; 'f'];
    end;

    
    

%% update_plot
% -----------------------------------------------------------------------
%
%         UPDATE_PLOT
%
% -----------------------------------------------------------------------

  case 'update_plot',
    sh = value(sides_history);
    ch = value(choice_history);
    hh = value(hit_history);
    sh = sh(1:length(hh));
    ch = ch(1:length(hh));
    
    if n_done_trials >= 1  
        reds   = find(hh==0 & sh~='f');
        greens = find(hh==1 & sh~='f');

        bls    = find(sh=='f' & ch=='l');
        gns    = find(sh=='f' & ch=='r');
    else
        reds   = [];
        greens = [];
        bls    = [];
        gns    = [];
    end
        
    ax = value(myaxes);
    delete(get(ax, 'Children'));
    
    yt = [1 1.5 2];
    yl = {'Left','Free','Right'};
    
    plot(ax, greens, (sh(greens)=='r')+1, 'g.');
    hold(ax, 'on');
    plot(ax, reds,   (sh(reds)  =='r')+1, 'r.'); 
    
    sh = value(sides_history);
    if     sh(n_done_trials+1)=='r'; nt = 2;
    elseif sh(n_done_trials+1)=='f'; nt = 1.5;
    else                             nt = 1;
    end
        
    plot(ax, n_done_trials+1, nt, 'c.');
    
    plot(ax, bls, ones(size(bls))*1.5, 'b.');
    plot(ax, gns, ones(size(gns))*1.5, 'g.');

    hold (ax, 'off');
    set(ax, 'Ylim', [0.5 2.5], 'XLim', [0 n_done_trials+1],'YTick', yt, 'YTickLabel', yl);
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
    elseif isequal(ThisTrial, 'RIGHT')
        x = 'r';
    else
        x = 'f';
    end;
    
    
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

