% [x, y] = AntibiasSection(obj, action, [arg1], [arg2], [arg3])    
%
% Section that calculates biases and calculates probability of choosing a stimulus
% given the previous history. 
%
%    Antibias assumes that trials are of two classes, Left desired answer
% and Right desired answer, and that their outcome is either Correct or
% Incorrect. Given the history of previous trial classes, and the history
% of previous corrects/incorrects, Antibias makes a local estimate of
% fraction correct for each class, combines that with a prior probability
% of making the next trial Left, and produces a recommended probability
% for choosing the next trial as Left. Antibias will tend to make the
% class with the smaller frac correct the one with the higher probability.
% The strength of that tendency is quantified by a parameter, beta. 
%   (See probabilistic_trial_selector.m for details on the math of how the
% tendency is generated.)
%
% Local estimates of fraction correct are computed using an exponential
% kernel, most recent trial the most strongly weighted. The tau of this
% kernel is a GUI parameter. Two different estimates are computed: one for
% use in computing Left probability and Right probability; and a second
% simply for GUI display purposes. The two estimates can have different
% taus for their kernels.
%
% GUI DISPLAY: When initialized, this plugin will put up two panels and a
% title. In each panel, there is a slider that controls the tau of the
% recent-trials exponential kernel. One panel will display the percent
% corrects for Right and Left, as computed with its kernel. The second panel
% will display the a posteriori probabilities of making the next trial a
% "Left" trial or making the next trial a "Right" trial. This second panel
% has its own tau slider, and it also has a GUI parameter, beta, that
% controls how strongly the history matters. If beta=0, history doesn't
% matter, and the a priori LeftProbability dominates. If beta=Inf, then
% history matters above all: the next trial will be of the type with lowest
% fraction correct, for sure.
%
% See the bottom of this help file for examples of usage.
%
% arg1, arg2, arg3 are optional and their meaning depends on action (see
% below).
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%
%     'init'        To initialise the plugin and set up the GUI for it. This
%                   action requires two more arguments: The bottom left
%        x y        position (in units of pixels) of where to start placing
%                   the GUI elements of this plugin. 
%
%     'update'      This call will recompute both local estimates of
%                   fraction correct, and will recompute the recommended 
%        LeftProb,  p(Left). This action requires three more arguments:
%        HitHist,   LProb, a scalar b/w 0 and 1; HitHist, a vector of 1s
%        SidesHist  and 0s and of length n_done_trials where 1 represents
%                   correct and 0 represents incorrect, first element
%                   corresponds to first trial; and SidesHist, a vector of
%                   'l's and 'r's and of length n_done_trials where 'l'
%                   represents 'left', 'r' represents 'right' first element
%                   corresponds to first trial.
%
%     'get_posterior_probs'  Returns a vector with two components, 
%                   [p(Left) p(Right)].
% 
% 
%     'update_biashitfrac'   This call will recompute the local estimate of fraction
%                   Left correct and fraction Right correct used for
%        LeftProb,  antibiasing, and will also recompute the recommended
%        HitHist,   Left probability. This action    
%        SidesHist, requires three more arguments: LProb, a scalar b/w 0
%                   and 1; HitHist, a vector of 1s and 0s and of length
%                   n_done_trials where 1 represents correct and 0
%                   represents incorrect, first element corresponds to
%                   first trial; and SidesHist, a vector of 'l's and 'r's
%                   and of length n_done_trials where 'l' represents
%                   'left', 'r' represents 'right' first element
%                   corresponds to first trial.
% 
%     'update_hitfrac'  This call is not related to computing the posterior
%                   Left probability, but will recompute only the local estimate
%        HitHist,   of fraction correct that is not used for antibiasing.
%        SidesHist  This action requires two more arguments: HitHist, a
%                   vector of 1s and 0s and of length n_done_trials where 1
%                   represents correct and 0 represents incorrect, first
%                   element corresponds to first trial; and SidesHist, a vector of
%                   'l's and 'r's and of length n_done_trials where 'l'
%                   represents 'left', 'r' represents 'right' first element
%                   corresponds to first trial.
%
%     'get'         Needs one extra parameter, either 'Beta' or
%                   'antibias_tau', and returns the corresponding scalar.
%
%     'reinit'      Delete all of this section's GUIs and data,
%                   and reinit, at the same position on the same
%                   figure as the original section GUI was placed.
%
%
% x, y     Relevant to action = 'init'; they indicate the initial
%          position to place the GUI at, in the current figure window
%
% RETURNS:
% --------
%
% if action == 'init' :
%
% [x1, y1, w, h]   When action == 'init', Antibias will put up GUIs and take
%          up a certain amount of space of the figure that was current when
%          AntiBiasSection(obj, 'init', x, y) was called. On return, [x1 y1]
%          will be the top left corner of the space used; [x y] (as passed
%          to Antibias in the init call) will be the bottom left corner;
%          [x+w y1] will be the top right; and [x+w y] will be the bottom
%          right. h = y1-y. All these are in units of pixels.
%
%
% if action == 'get_posterior_probs' :
%
% [L R]     When action == 'get_posterior_probs', a two-component vector is
%           returned, with p(Left) and p(Right).  If beta=0, then p(Left)
%           will be the same as the last LeftProb that was passed in.
%
%
% USAGE:
% ------
%
% To use this plugin, the typical calls would be:
%
% 'init' : On initializing your protocol, call 
%    AntibiasSection(obj, 'init', x, y);
%
% 'update' : After a trial is completed, call
%    AntibiasSection(obj, 'update', LeftProb, HitHist, SidesHist)
%
% 'get_posterior_probs' : After a trial is completed, and when you are
%       deciding what kind of trial to make the next trial, get the plugins
%       opinion on whether the next trial should be Left or Right by calling
%    AntibiasSection(obj, 'get_posterior_probs')
%
% See PARAMETERS section above for the documentation of each of these calls.
%


function [x, y, w, h] = AntibiasSection(obj, action, varargin)
   
GetSoloFunctionArgs(obj);
   
switch action
    
  case 'init',   % ------------ CASE INIT ----------------
    x = varargin{1}; y = varargin{2}; y0 = y;
    % Save the figure and the position in the figure where we are
    % going to start adding GUI elements:
    SoloParamHandle(obj, 'my_gui_info', 'value', {x y gcf});

    LogsliderParam(obj, 'HitFracTau', 30, 10, 400, x, y, 'label', 'hits frac tau', ...
      'TooltipString', ...
      sprintf(['\nnumber of trials back over which to compute fraction of correct trials.\n' ...
      'This is just for displaying info-- for the bias calculation, see BiasTau above']));
    set_callback(HitFracTau, {mfilename, 'update_hitfrac'});
    next_row(y);
    DispParam(obj, 'PLHitFrac', 0, x, y, 'position',[x     y 100 20],'labelfraction', 0.6); 
    DispParam(obj, 'PRHitFrac', 0, x, y, 'position',[x+100 y 100 20],'labelfraction', 0.6); next_row(y);
    DispParam(obj, 'ALHitFrac', 0, x, y, 'position',[x     y 100 20],'labelfraction', 0.6); 
    DispParam(obj, 'ARHitFrac', 0, x, y, 'position',[x+100 y 100 20],'labelfraction', 0.6); next_row(y,1.1);
    
    DispParam(obj, 'L_HitFrac', 0, x, y, 'position',[x     y 100 20],'labelfraction', 0.6); 
    DispParam(obj, 'R_HitFrac', 0, x, y, 'position',[x+100 y 100 20],'labelfraction', 0.6); next_row(y);
    DispParam(obj, 'P_HitFrac', 0, x, y, 'position',[x     y 100 20],'labelfraction', 0.6); 
    DispParam(obj, 'A_HitFrac', 0, x, y, 'position',[x+100 y 100 20],'labelfraction', 0.6); next_row(y,1.1);
    
    DispParam(obj, 'HitFrac',   0, x, y); next_row(y,1.1);
    
    LogsliderParam(obj, 'BiasTau', 30, 10, 400, x, y, 'label', 'antibias tau'); next_row(y);
    NumeditParam(obj, 'Beta', 0, x, y);                                         next_row(y);
    set_callback({BiasTau, Beta}, {mfilename, 'update_biashitfrac'});
    
    DispParam(obj, 'PLProb', 0, x, y, 'position',[x     y 100 20]);
    DispParam(obj, 'PRProb', 0, x, y, 'position',[x+100 y 100 20]); next_row(y);
    DispParam(obj, 'ALProb', 0, x, y, 'position',[x     y 100 20]);
    DispParam(obj, 'ARProb', 0, x, y, 'position',[x+100 y 100 20]); next_row(y);
    
    SoloParamHandle(obj, 'BiasLtHitFrac', 'value', 0);
    SoloParamHandle(obj, 'BiasRtHitFrac', 'value', 0);
    SoloParamHandle(obj, 'BiasHitFrac',   'value', 0);
        
    SoloParamHandle(obj, 'LocalLeftProb',    'value', 0.5);
    SoloParamHandle(obj, 'LocalProProb',     'value', 1);
    SoloParamHandle(obj, 'LocalHitHistory',  'value', []);
    SoloParamHandle(obj, 'LocalSidesHistory','value', []);
    SoloParamHandle(obj, 'LocalLocHistory',  'value', []);
    SoloParamHandle(obj, 'ChoicesProb',      'value', []);

    
    SubheaderParam(obj, 'title', mfilename, x, y);
    next_row(y, 0.5);

    w = gui_position('get_width');
    h = y-y0;
    
    
  case 'update',    % --- CASE UPDATE -------------------
    if length(varargin)>0, LocalLeftProb.value     = varargin{1};  end %#ok<ISMT>
    if length(varargin)>1, LocalProProb.value      = varargin{2};  end
    if length(varargin)>2, LocalHitHistory.value   = varargin{3};  end
    if length(varargin)>3, LocalSidesHistory.value = varargin{4};  end
    if length(varargin)>4, LocalLocHistory.value   = varargin{5};  end
    
    % Protect against somebody passing in SPHs, not actual values, by mistake:
    if isa(value(LocalLeftProb),     'SoloParamHandle'), LocalLeftProb.value     = value(value(LocalLeftProb));     end
    if isa(value(LocalProProb),      'SoloParamHandle'), LocalProProb.value      = value(value(LocalProProb));      end
    if isa(value(LocalHitHistory),   'SoloParamHandle'), LocalHitHistory.value   = value(value(LocalHitHistory));   end
    if isa(value(LocalSidesHistory), 'SoloParamHandle'), LocalSidesHistory.value = value(value(LocalSidesHistory)); end
    if isa(value(LocalLocHistory),   'SoloParamHandle'), LocalLocHistory.value   = value(value(LocalLocHistory));   end

    feval(mfilename, obj, 'update_hitfrac');
    feval(mfilename, obj, 'update_biashitfrac');
    
    
   
  case 'update_biashitfrac',     % ------- CASE UPDATE_BIASHITFRAC -------------
    if length(varargin)>0, LocalLeftProb.value     = varargin{1};  end %#ok<ISMT>
    if length(varargin)>1, LocalProProb.value      = varargin{2};  end
    if length(varargin)>2, LocalHitHistory.value   = varargin{3};  end
    if length(varargin)>3, LocalSidesHistory.value = varargin{4};  end
    if length(varargin)>4, LocalLocHistory.value   = varargin{5};  end
    
    % Protect against somebody passing in SPHs, not actual values, by mistake:
    if isa(value(LocalLeftProb),     'SoloParamHandle'), LocalLeftProb.value     = value(value(LocalLeftProb));     end
    if isa(value(LocalProProb),      'SoloParamHandle'), LocalProProb.value      = value(value(LocalProProb));      end
    if isa(value(LocalHitHistory),   'SoloParamHandle'), LocalHitHistory.value   = value(value(LocalHitHistory));   end
    if isa(value(LocalSidesHistory), 'SoloParamHandle'), LocalSidesHistory.value = value(value(LocalSidesHistory)); end
    if isa(value(LocalLocHistory),   'SoloParamHandle'), LocalLocHistory.value   = value(value(LocalLocHistory));   end

    LP = value(LocalLeftProb);
    RP = 1 - LP;
    PP = value(LocalProProb);
    AP = 1 - PP;
    hh = value(LocalHitHistory);   hh = colvec(hh);     
    sh = value(LocalSidesHistory); sh = sh(1:length(hh));
    lh = value(LocalLocHistory);   lh = lh(1:length(hh));
    sth = StimulatorSection(obj,'get','stimulator_history'); sth = sth(1:length(hh))';
    if isempty(hh); sth = []; end
    
    if strcmp(StimulatorSection(obj,'get','StimOnSide'),'both')
        goods = ~isnan(hh) & sth==0;
    else
        goods = ~isnan(hh);
    end
    
    hh = hh(goods);
    sh = sh(goods);
    lh = lh(goods);
    
    th(sh == 'l' & lh == 'p') = 1;
    th(sh == 'l' & lh == 'a') = 2;
    th(sh == 'r' & lh == 'a') = 3;
    th(sh == 'r' & lh == 'p') = 4;
    
    PriProb    = zeros(1,4);
    PriProb(1) = LP * PP;
    PriProb(2) = LP * AP;
    PriProb(3) = RP * AP;
    PriProb(4) = RP * PP;
    
    bhf = ones(1,4);
    
    if length(hh) < BiasTau
        
        pad = int16(BiasTau - length(hh));
        hh  = [ones(pad, 1); hh];
        kernel = exp(-(0:length(hh)-1)/BiasTau)';
        kernel = kernel(end:-1:1);

        for k = 1:4
            pad_th = [k*ones(1,pad) th];
            khit   = find(pad_th == k);
            if isempty(khit), bhf(k) = 1;
            else              bhf(k) = sum(hh(khit).*kernel(khit))/sum(kernel(khit));
            end
        end
        
    else   
        kernel = exp(-(0:length(hh)-1)/BiasTau)';
        kernel = kernel(end:-1:1);

        for k = 1:4
            khit   = find(th == k);
            if isempty(khit), bhf(k) = 1;
            else              bhf(k) = sum(hh(khit).*kernel(khit))/sum(kernel(khit));
            end
        end
    end

    bhf(PriProb == 0) = 0;
    BiasHitFrac.value = bhf;
    
    choices = probabilistic_trial_selector(value(BiasHitFrac), PriProb, value(Beta));
    ChoicesProb.value = choices;
    push_history(ChoicesProb);
    
    PLProb.value = choices(1);
    ALProb.value = choices(2);
    ARProb.value = choices(3);
    PRProb.value = choices(4);


    
  case 'get_posterior_probs',      % ------- CASE GET_POSTERIOR_PROBS -------------
    x = value(ChoicesProb); %#ok<NODEF>
    
  
  case 'update_hitfrac',     % ------- CASE UPDATE_HITFRAC -------------
    if length(varargin)>0, LocalLeftProb.value     = varargin{1};  end %#ok<ISMT>
    if length(varargin)>1, LocalProProb.value      = varargin{2};  end
    if length(varargin)>2, LocalHitHistory.value   = varargin{3};  end
    if length(varargin)>3, LocalSidesHistory.value = varargin{4};  end
    if length(varargin)>4, LocalLocHistory.value   = varargin{5};  end
    
    % Protect against somebody passing in SPHs, not actual values, by mistake:
    if isa(value(LocalLeftProb),     'SoloParamHandle'), LocalLeftProb.value     = value(value(LocalLeftProb));     end
    if isa(value(LocalProProb),      'SoloParamHandle'), LocalProProb.value      = value(value(LocalProProb));      end
    if isa(value(LocalHitHistory),   'SoloParamHandle'), LocalHitHistory.value   = value(value(LocalHitHistory));   end
    if isa(value(LocalSidesHistory), 'SoloParamHandle'), LocalSidesHistory.value = value(value(LocalSidesHistory)); end
    if isa(value(LocalLocHistory),   'SoloParamHandle'), LocalLocHistory.value   = value(value(LocalLocHistory));   end

    hh = value(LocalHitHistory);   hh = colvec(hh);
    sh = value(LocalSidesHistory); sh = sh(1:length(hh));
    lh = value(LocalLocHistory);   lh = lh(1:length(hh));
    sth = StimulatorSection(obj,'get','stimulator_history'); sth = sth(1:length(hh))';
    if isempty(hh); sth = []; end
    
    if strcmp(StimulatorSection(obj,'get','StimOnSide'),'both')
        goods = ~isnan(hh) & sth==0;
    else
        goods = ~isnan(hh);
    end
    
    hh = hh(goods);
    sh = sh(goods);
    lh = lh(goods);
    
    if length(hh)>0 %#ok<ISMT>
      kernel = exp(-(0:length(hh)-1)/HitFracTau)';
      kernel = kernel(end:-1:1);
      HitFrac.value = sum(hh .* kernel)/sum(kernel);
    
      u = find(sh == 'l' & lh == 'p');
      if isempty(u), PLHitFrac.value = NaN;
      else           PLHitFrac.value = sum(hh(u) .* kernel(u))/sum(kernel(u));
      end;
      
      u = find(sh == 'r' & lh == 'p');
      if isempty(u), PRHitFrac.value = NaN;
      else           PRHitFrac.value = sum(hh(u) .* kernel(u))/sum(kernel(u));
      end;
      
      u = find(sh == 'l' & lh == 'a');
      if isempty(u), ALHitFrac.value = NaN;
      else           ALHitFrac.value = sum(hh(u) .* kernel(u))/sum(kernel(u));
      end;
      
      u = find(sh == 'r' & lh == 'a');
      if isempty(u), ARHitFrac.value = NaN;
      else           ARHitFrac.value = sum(hh(u) .* kernel(u))/sum(kernel(u));
      end;
      
      u = find(sh == 'r');
      if isempty(u), R_HitFrac.value = NaN;
      else           R_HitFrac.value = sum(hh(u) .* kernel(u))/sum(kernel(u));
      end;
      
      u = find(sh == 'l');
      if isempty(u), L_HitFrac.value = NaN;
      else           L_HitFrac.value = sum(hh(u) .* kernel(u))/sum(kernel(u));
      end;
      
      u = find(lh == 'p');
      if isempty(u), P_HitFrac.value = NaN;
      else           P_HitFrac.value = sum(hh(u) .* kernel(u))/sum(kernel(u));
      end;
      
      u = find(lh == 'a');
      if isempty(u), A_HitFrac.value = NaN;
      else           A_HitFrac.value = sum(hh(u) .* kernel(u))/sum(kernel(u));
      end;
    end;
    
    
  case 'get',    % ------- CASE GET -------------
    if length(varargin)~=1,
      error('AntibiasSection:Invalid', '''get'' needs one extra param');
    end;
    switch varargin{1},
      case 'Beta',
        x = value(Beta);
      case 'antibias_tau',
        x = value(BiasTau);
      otherwise
        error('AntibiasSection:Invalid', 'Don''t know how to get %s', varargin{1});
    end;
    
            
  case 'reinit',   % ------- CASE REINIT -------------
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
   
   
      

function [x] = colvec(x)
 if size(x,2) > size(x,1), x = x'; end;
 