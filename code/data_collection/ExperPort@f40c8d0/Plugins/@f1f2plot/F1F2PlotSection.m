% [x, y] = F1F2PlotSection(obj, action, [arg1], [arg2])

% TEMPORARY COMMENTS: IMPROVE ME SOON!
%
%
% pairs_used is a soloparamhandle that lists all the f1/f2 pairs used in
% this session, and whether correct side choice is 'l' or 'r'
% example: pairs_used.value = {[30 100]    'l'; 
%                               [30 30]    'r'; 
%                               [100 30]   'l'; 
%                               [100 100]  'r'};
%
%
% trial_info stores the performance info for each trial, where each row of
% the cell array corresonds to one trial.
% it has 3 columns as follows:
%                {pair_id    hit}
% where pair_id is the index of the particular f1f2 pair (from pairs_used)
%       hit is 0 or 1, correct side choice or not



% Bing, Sept. 2007




function [x, y] = F1F2PlotSection(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action,
    
  % ------------------------------------------------------------------
  %              INIT
  % ------------------------------------------------------------------    

  case 'init'
    if length(varargin) < 2,
      error('Need at least two arguments, x and y position, to initialize %s', mfilename);
    end;
    x = varargin{1}; y = varargin{2};
    
    SoloParamHandle(obj, 'my_xyfig', 'value', [x y double(gcf)]);
    
    
    ToggleParam(obj, 'f1f2plot_show', 0, x, y, ...
       'OnString', 'f1f2 Plot Showing', ...
       'OffString', 'f1f2 Plot Hidden', ...
       'TooltipString', 'Show/Hide f1-f2 Plot window'); next_row(y);
    set_callback(f1f2plot_show, {mfilename, 'show_hide'}); 
    
    screen_size = get(0, 'ScreenSize'); fig = double(gcf);
    SoloParamHandle(obj, 'myf1f2fig', ...
        'value', double(figure('Position', [200 screen_size(4)-740, 800 400], ...
        'closerequestfcn', [mfilename '(' class(obj) ', ''hide'');'], 'MenuBar', 'none', ...
        'NumberTitle', 'off', 'Name', 'f1f2 Dashboard')), 'saveable', 0);
    origfig_xy = [x y]; 
    x = 10; y = 20;


    % UI params that control what's plotted 

    LogsliderParam(obj, 'HitFracTau', 30, 10, 400, ...
        x, y, 'position', [50 y 250 20], ...
        'labelfraction', 0.4, ...
        'label', 'hits frac tau', ...
        'TooltipString', '\nnumber of trials back over which to compute fraction of correct trials');
    set_callback(HitFracTau, {mfilename, 'update_hitfractau'});

    SubheaderParam(obj, 'title', 'Axes:', x, y, 'position', [350 y 40 20]);
    NumeditParam(obj, 'a_min', 0,   x, y, 'position', [390 y 70 20]);
    NumeditParam(obj, 'a_max', 250, x, y, 'position', [460 y 70 20]);
    PushbuttonParam(obj, 'Autofit', x, y, 'position', [610 y 60 20]);
    PushbuttonParam(obj, 'Redraw', x, y,  'position', [680 y 60 20]);
    set_callback({a_min; a_max; Redraw}, {mfilename, 'redraw'});
    set_callback_on_load(Redraw, 1);  % callback for Redraw will always be executed when loading data
    set_callback(Autofit, {mfilename, 'autofit_axes'});
    
    
    % soloparams that store trials' performance info (see comments at top)
%      SoloParamHandle(obj, 'pairs_used', 'value', {[80 200] 'l'; [80 80] 'r'; [200 80] 'l'; [200 200] 'r'});
%      SoloParamHandle(obj, 'trial_info', 'value', {1 1; 2 1; 2 1; 2 0; 4 0; 1 1; 1 1; 2 0; 4 1; 4 0; 2 1; 2 1; 2 1; 2 1; 2 0;3 0;});
    
    SoloParamHandle(obj, 'pairs_used', 'value', {});
    SoloParamHandle(obj, 'trial_info', 'value', {});
    


    % set up the 2 axes
    % TODO: Make axes scale when window is scaled
    SoloParamHandle(obj, 'hits_axes', 'saveable', 0, ...
        'value', double(axes('Position', [0.1 0.25 0.4 0.6])));
    xlabel('f1'); ylabel('f2'); title('Performance: hits frac', 'FontSize', 17);
    SoloParamHandle(obj, 'p_colorbar', 'saveable', 0, ...
        'value', colorbar('Location', 'EastOutside'));
    jetmap = jet;
    SoloParamHandle(obj, 'p_colormap', 'saveable', 0, ...
        'value', colormap(jetmap(end:-1:1,:)));
    axis square;
    set(value(hits_axes), 'Color', 1*[1 1 1]);
    set(value(hits_axes), 'Units', 'pixels');
    set(value(hits_axes), 'YLim', [value(a_min) value(a_max)], ...
                          'XLim', [value(a_min) value(a_max)]);
    set(value(p_colorbar), ...
        'YTick', [1 ceil(rows(p_colormap)/2) ceil(rows(p_colormap)*0.8) rows(p_colormap)], ...
        'YTickLabel', {'0', '0.5', '0.8', '1'});
    
    SoloParamHandle(obj, 'history_axes', 'saveable', 0, ...
        'value', double(axes('Position', [0.6 0.25 0.3 0.6])));
    xlabel('f1'); ylabel('f2'); title('History: fraction presented','FontSize', 17);
    set(value(history_axes), 'Color', 1*[1 1 1]);    
    set(value(history_axes), 'Units', 'pixels');
    set(value(history_axes), 'YLim', [value(a_min) value(a_max)], ...
                             'XLim', [value(a_min) value(a_max)]);

    feval(mfilename, obj, 'show_hide');                     
                         
    figure(fig);
    x = origfig_xy(1); y = origfig_xy(2);

  % ------------------------------------------------------------------
  %              ADD_TRIAL
  % ------------------------------------------------------------------    

  case 'add_trial',
    if length(varargin) < 3,
        %warning('Must pass F1F2PlotSection 3 arguments when calling add_trial!!');
        return;
    end;
    if length(varargin)>0, this_pair  = varargin{1}; varargin = varargin(2:end); end; % 1x2 matrix: [f1 f2]
    if length(varargin)>0, this_side  = varargin{1}; varargin = varargin(2:end); end; % 'l' or 'r'
    if length(varargin)>0, this_hit   = varargin{1}; varargin = varargin(2:end); end; % 0 or 1
    pairs = { ...
      'skip_auto_redraw'   0  ; ...
    }; parseargs(varargin, pairs);
    
    % protect against accidentally passing SoloParamHandles instead of
    % their values:
    if isa(this_pair, 'SoloParamHandle'), this_pair = value(this_pair); end;
    if isa(this_side, 'SoloParamHandle'), this_side = value(this_side); end;
    if isa(this_hit , 'SoloParamHandle'), this_hit  = value(this_hit);  end;

    if n_done_trials > 0,
        if ~isempty(pairs_used),
            pairs_mat = cell2mat(pairs_used(:,1));
            pid       = find(pairs_mat(:,1) == this_pair(1) & ...
                             pairs_mat(:,2) == this_pair(2));
        else
            pid = [];
        end;

        if isempty(pid),
            sz = size(value(pairs_used));
            newrow = sz(1)+1;
            pairs_used.value = [value(pairs_used); cell(1, sz(2))];
            
            pairs_used{newrow,1} = this_pair;
            pairs_used{newrow,2} = this_side;
            pid = newrow;
        elseif numel(pid) > 1,
            warning('Duplicate f1/f2 pairs exist in F1F2PlotSection; using first instance of the pair');
            pid = pid(1);
        end;
        
        sz = size(value(trial_info));
        newtrial = sz(1)+1;
        trial_info.value = [value(trial_info); cell(1, sz(2))];
        trial_info{newtrial,1} = pid;
        trial_info{newtrial,2} = this_hit;
    end;
   
    if skip_auto_redraw == 0,
      callback(Redraw);
    end;
      
    

  % ------------------------------------------------------------------
  %              REDRAW
  % ------------------------------------------------------------------    
  
  case 'redraw',
    if isempty(pairs_used) || isempty(trial_info), return; end;   
      
    % pos = get(value(myf1f2fig), 'Position');
    R = 120/sqrt(rows(pairs_used));  % size of markers on hits_axes
    Q = 30*rows(pairs_used);  % size of marker in history_axes whose i_history = 1 (always presented)  
    
    cla(value(hits_axes));
    cla(value(history_axes));
    
    ref1 = line([value(a_min) value(a_max)], [value(a_min) value(a_max)], ...
        'Parent', value(hits_axes));
    ref2 = line([value(a_min) value(a_max)], [value(a_min) value(a_max)], ...
        'Parent', value(history_axes));
    set(ref1, 'Color', 0.7*[1 1 1]);
    set(ref2, 'Color', 0.7*[1 1 1]);
    
    kernel = exp(-(0:rows(trial_info)-1)/HitFracTau)';
    kernel = kernel(end:-1:1);
    hits = cell2mat(trial_info(:,2));
    
    for i = 1:rows(pairs_used),
        ipair.pair    = pairs_used{i,1};
        ipair.side    = pairs_used{i,2};      
        i_guys    = find(cell2mat(trial_info(:,1)) == i);
        if ~isempty(i_guys),
            i_hitfrac = sum(hits(i_guys).*kernel(i_guys))/sum(kernel(i_guys));
        else
            i_hitfrac = NaN;
        end;
        i_history = length(i_guys)/rows(trial_info);
        
        % circles for Left, squares for Right
        if strcmp(ipair.side, 'l'), curv = [1, 1];
        else                        curv = [0, 0];
        end;
        
        if ~isnan(i_hitfrac),
            rectangle('Position', [ipair.pair(1)-R/2, ipair.pair(2)-R/2, R, R], ...
                      'Curvature', curv, ...
                      'FaceColor', p_colormap(round((rows(p_colormap)-1)*i_hitfrac)+1,:), ...
                      'EdgeColor', 'k', ...
                      'Parent', value(hits_axes));
            text(ipair.pair(1)-10, ipair.pair(2), sprintf('%1.2f', i_hitfrac), ...
                'Color', 1-p_colormap(round((rows(p_colormap)-1)*i_hitfrac)+1,:), ...
                'Parent', value(hits_axes));
        end;
        
        if i_history > 0,
            rectangle('Position', [ipair.pair(1)-Q*i_history/2, ipair.pair(2)-Q*i_history/2, Q*i_history, Q*i_history], ...
                      'Curvature', curv, ...
                      'FaceColor', [225 200 240]/255, ... %[152 251 152]/255, ...
                      'EdgeColor', [34  0  24]/255, ...
                      'Parent', value(history_axes));
            text(ipair.pair(1)-10, ipair.pair(2), sprintf('%1.2f', i_history), ...
                'Color', 'k', ...
                'Parent', value(history_axes));
        end;
    end;
    drawnow;
    
    set(value(hits_axes), 'YLim', [value(a_min) value(a_max)], ...
                          'XLim', [value(a_min) value(a_max)]);

    set(value(history_axes), 'YLim', [value(a_min) value(a_max)], ...
                             'XLim', [value(a_min) value(a_max)]);

    
  % ------------------------------------------------------------------
  %              UPDATE_HITFRACTAU
  % ------------------------------------------------------------------    

  case 'update_hitfractau',
      callback(Redraw);
    
  % ------------------------------------------------------------------
  %              AUTOFIT_AXES
  % ------------------------------------------------------------------    

  case 'autofit_axes',
      if isempty(pairs_used), return; end;
      
      pairs_mat = cell2mat(pairs_used(:,1));
      pmax = max(max(pairs_mat));
      pmin = min(min(pairs_mat));
      
      a_min.value = pmin-30;
      a_max.value = pmax+30;
      
      callback(Redraw);
    
  % ------------------------------------------------------------------
  %              SHOW HIDE
  % ------------------------------------------------------------------    

  case 'hide',
    f1f2plot_show.value_callback = 0; 
    %set(value(myf1f2fig), 'Visible', 'off');
    
  case 'show_hide',
    if f1f2plot_show == 1, set(value(myf1f2fig), 'Visible', 'on'); %#ok<NODEF> (defined by GetSoloFunctionArgs)
    else                   set(value(myf1f2fig), 'Visible', 'off');
    end;
    
    
  % ------------------------------------------------------------------
  %              CLOSE
  % ------------------------------------------------------------------    
  case 'close'   
    %if exist('myf1f2fig', 'var') && isa(myf1f2fig, 'SoloParamHandle') && ishandle(value(myf1f2fig)),
      delete(value(myf1f2fig));
    %end;    
    delete_sphandle('owner', ['^@' class(obj) '$'], 'fullname', [mfilename '_']);
    
  % ------------------------------------------------------------------
  %              REINIT
  % ------------------------------------------------------------------    
  case 'reinit'
    x = my_xyfig(1); y = my_xyfig(2); origfig = my_xyfig(3);
    currfig = double(gcf);
    
    feval(mfilename, obj, 'close');
    
    figure(origfig);
    feval(mfilename, obj, 'init', x, y, scolors);
    figure(currfig);

    
        
        
  otherwise
    warning('%s : action "%s" is unknown!', mfilename, action); %#ok<WNTAG> (This line OK.)

end; %     end of switch action
end  %     end of function F1F2PlotSection

