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
    SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);

    % Max times same side can appear
    MenuParam(obj, 'MaxSame', {'1', '2', '3', '4', '5', '6', '7', '8', 'Inf'}, 3, x, y);   next_row(y);  
    NumeditParam(obj, 'LeftProb',     0.5, x, y);                                          next_row(y);
    NumeditParam(obj, 'ProProb',      0.5, x, y);                                          next_row(y);
    NumeditParam(obj, 'LightProb',    0.5, x, y);                                          next_row(y);
    %MenuParam(obj, 'StimLoc',  {'Pro','Anti'},    1, x, y, 'labelfraction', 0.5); next_row(y); 
    %MenuParam(obj, 'StimType', {'Light','Sound'}, 1, x, y, 'labelfraction', 0.5); next_row(y);
    DispParam(   obj, 'ThisTrial_Side', 'LEFT',  x, y); next_row(y);
    DispParam(   obj, 'ThisTrial_Type', 'Pro',   x, y); next_row(y);
    DispParam(   obj, 'ThisTrial_Stim', 'Light', x, y); next_row(y);

    SubheaderParam(obj, 'title', 'Sides Section', x, y); next_row(y, 1.3);

    % plot of side choices history at top of window
    pos = get(gcf, 'Position');
    SoloParamHandle(obj, 'myaxes', 'saveable', 0, 'value', axes);
    set(value(myaxes), 'Units', 'pixels');
    set(value(myaxes), 'Position', [90 pos(4)-200 pos(3)-130 160]);
    set(value(myaxes), 'YTick', 1:4, 'YLim', [0.1 4.1]);


    xlabel('trial number');
    SoloParamHandle(obj, 'previous_plot', 'saveable', 0);
    
    SoloParamHandle(obj, 'counter',                  'value', [], 'save_with_settings',1);
    SoloParamHandle(obj, 'block_type',               'value', [], 'save_with_settings',1);
    SoloParamHandle(obj, 'good_day_counter',         'value',  0, 'save_with_settings',1);
    
    SoloParamHandle(obj, 'ProFinal_start_date',      'value',  [], 'save_with_settings',1);
    SoloParamHandle(obj, 'ProFinal_stop_date',       'value',  [], 'save_with_settings',1);
    SoloParamHandle(obj, 'ProFinal_start_trial',     'value',  [], 'save_with_settings',1);
    SoloParamHandle(obj, 'ProFinal_stop_trial',      'value',  [], 'save_with_settings',1);
    
    SoloParamHandle(obj, 'AntiFinal_start_date',     'value',  [], 'save_with_settings',1);
    SoloParamHandle(obj, 'AntiFinal_stop_date',      'value',  [], 'save_with_settings',1);
    SoloParamHandle(obj, 'AntiFinal_start_trial',    'value',  [], 'save_with_settings',1);
    SoloParamHandle(obj, 'AntiFinal_stop_trial',     'value',  [], 'save_with_settings',1);
    
    SoloParamHandle(obj, 'ProAntiFinal_start_date',  'value',  [], 'save_with_settings',1);
    SoloParamHandle(obj, 'ProAntiFinal_stop_date',   'value',  [], 'save_with_settings',1);
    SoloParamHandle(obj, 'ProAntiFinal_start_trial', 'value',  [], 'save_with_settings',1);
    SoloParamHandle(obj, 'ProAntiFinal_stop_trial',  'value',  [], 'save_with_settings',1);
    
    
    SoloFunctionAddVars('SMASection', 'ro_args', {'ThisTrial_Side','ThisTrial_Type','ThisTrial_Stim'});
    
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
    
    
%% get_pro_prob   
% -----------------------------------------------------------------------
%
%         GET_PRO_PROB
%
% -----------------------------------------------------------------------

  case 'get_pro_prob',
    x = value(ProProb);
    
    
%% get_current_side    
% -----------------------------------------------------------------------
%
%         GET_CURRENT_SIDE
%
% -----------------------------------------------------------------------

  case 'get_current_side',
    if isequal(ThisTrial_Side, 'LEFT'), %#ok<NODEF>
      x = 'l';
    else
      x = 'r';
    end;    

    
%% get_current_type   
% -----------------------------------------------------------------------
%
%         GET_CURRENT_TYPE
%
% -----------------------------------------------------------------------

  case 'get_current_type',
    if isequal(ThisTrial_Type, 'PRO'), %#ok<NODEF>
      x = 'pro';
    else
      x = 'anti';
    end;    
   
    
%% get_current_stim   
% -----------------------------------------------------------------------
%
%         GET_CURRENT_STIM
%
% -----------------------------------------------------------------------

  case 'get_current_stim',
    if isequal(ThisTrial_Stim, 'LIGHT'),  %#ok<NODEF>
      x = 'light';
    else
      x = 'sound';
    end;   
    
    
%% prepare_next_trial    
% -----------------------------------------------------------------------
%
%         PREPARE_NEXT_TRIAL
%
% -----------------------------------------------------------------------

  case 'prepare_next_trial',

      
    posterior = AntibiasSection(obj, 'get_posterior_probs');
%     p_PL = posterior(1);
%     p_AL = posterior(2);
%     p_AR = posterior(3);
%     p_PR = posterior(4);
    
    if n_started_trials >= MaxSame,
      if all(sides_history(n_started_trials-MaxSame+1:n_started_trials) == ...
          sides_history(n_started_trials)), %#ok<NODEF>
        if sides_history(n_started_trials) == 'l', posterior(1:2) = 0;
        else                                       posterior(3:4) = 0; 
        end;
      end;
    end;
    
    posterior = posterior ./ sum(posterior);
    P(1) = posterior(1);
    for p = 2:length(posterior); P(p) = P(p-1) + posterior(p); end %#ok<AGROW>
    t = find(rand(1) < P,1,'first');
    if     t == 1; ThisTrial_Type.value = 'PRO';   ThisTrial_Side.value = 'LEFT';   SoundInterface(obj, 'set', 'StimSound', 'Bal', -1);
    elseif t == 2; ThisTrial_Type.value = 'ANTI';  ThisTrial_Side.value = 'LEFT';   SoundInterface(obj, 'set', 'StimSound', 'Bal',  1);
    elseif t == 3; ThisTrial_Type.value = 'ANTI';  ThisTrial_Side.value = 'RIGHT';  SoundInterface(obj, 'set', 'StimSound', 'Bal', -1);
    else           ThisTrial_Type.value = 'PRO';   ThisTrial_Side.value = 'RIGHT';  SoundInterface(obj, 'set', 'StimSound', 'Bal',  1);
    end
    
    
    
    if rand(1)<value(LightProb),ThisTrial_Stim.value = 'LIGHT';else ThisTrial_Stim.value = 'SOUND'; end
    
    oldsides = value(sides_history); 
    oldlocs  = value(loc_history); %#ok<NODEF>
    if ~dispatcher('is_running');
      % We're not running, last side wasn't used, lop it off:
      oldsides = oldsides(1:end-1); 
      oldlocs  = oldlocs(1:end-1);
    end;
    if strcmp(ThisTrial_Side, 'LEFT'); sides_history.value = [oldsides 'l']; 
    else                                sides_history.value = [oldsides 'r']; 
    end;
    if strcmp(ThisTrial_Type, 'PRO');  loc_history.value = [oldlocs 'p']; 
    else                                loc_history.value = [oldlocs 'a']; 
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
    
    sh = value(sides_history); %#ok<NODEF>
    lh = value(loc_history); %#ok<NODEF>
    
    y = zeros(size(sh));
    y(sh == 'l' & lh == 'p') = 1;
    y(sh == 'l' & lh == 'a') = 2;
    y(sh == 'r' & lh == 'a') = 3;
    y(sh == 'r' & lh == 'p') = 4;
    
    yl = {'ProLeft','AntiLeft','AntiRight','ProRight'};
    midline = 2.5;
    yvals = 1:4;
    
    plot(ax, [0 n_done_trials + 1], [midline midline], '-', 'Color', [0.2 0.2 0.2]);
    hold(ax, 'on');
    for t = 1:4
        plot(ax, [0 n_done_trials + 1], [yvals(t) yvals(t)], ':', 'Color',[0.5 0.5 0.5]);
    end
    plot(ax, greens, y(greens), 'g.');
    plot(ax,   reds, y(reds),   'r.');
    

    plot(ax, n_done_trials+1, y(end), 'b.');
    hold (ax, 'off');
    set(ax, 'Ylim', [0.5 4.5], 'XLim', [0 n_done_trials+1],'YTick', 1:4, 'YTickLabel', yl);
    xlabel(ax, 'Trial number');
    
    
        
    
%% reinit      
% -----------------------------------------------------------------------
%
%         REINIT
%
% -----------------------------------------------------------------------

  case 'reinit',
    currfig = double(gcf);
    
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

