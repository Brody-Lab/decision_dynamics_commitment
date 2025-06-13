
% [x, y] = Antibias3waySection(obj, action, [arg1], [arg2], [arg3], [arg4])    
%                                           
% Section that calculates biases and calculates probability of choosing a
% stimulus given the previous history. 
%
%    Antibias3way assumes that there are three types of trials, center (c),
% left(l) and right(r), and that the responses can be either correct (1) or
% incorrect (0).  Given the history of previous trial classes, and the 
% history of previous corrects/incorrects, Antibias3way makes a local
% estimate of fraction correct for each class, combines that with a target
% probability for each class (clr), and produces a recommended probability
% for choosing the next trial as each class. Antibias3way will tend to make
% the class with the smaller frac correct the one with the higher probability.
% The strength of that tendency is quantified by a parameter, beta. 
% (See probabilistic_trial_selector.m for details on the math of how the
% tendency is generated.)  If a class has not occurred, Antibias3way treats
% the frac correct as zero.
%
% Local estimates of fraction correct are computed using an exponential
% kernel, most recent trial the most strongly weighted. The tau of this
% kernel is a GUI parameter. Two different estimates are computed: one for
% use in computing the probability of each class; and a second simply for 
% GUI display purposes. The two estimates can have different taus for their
% kernels.
%
% GUI DISPLAY: When initialized, this plugin will put up two panels and a
% title. In each panel, there is a slider that controls the tau of the
% recent-trials exponential kernel. One panel will display the percent
% corrects for each class, as computed with its kernel, as well as the
% percent correct of trials completed and the percent of trials not
% completed.
%
% The second panel will display the a new probabilities of making the next
% trial choice as "Center," "Left" or "Right" trial. This second panel has 
% its own tau slider, and it also has a GUI parameter, beta, that controls 
% how strongly the history matters. If beta=0, history doesn't matter, and 
% the Target Probabilities dominate. If beta=Inf, then history matters
% above all: the next trial will be of the type with lowest fraction
% correct, for sure.
%
% See the bottom of this help file for examples of usage.
%
% arg1, arg2, arg3, arg are optional and their meaning depends on action (see
% below).
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%
%                 'init' (x y)        
%                   To initialise the plugin and set up the GUI for it. This
%                   action requires two more arguments: The bottom left
%                   position (in units of pixels) of where to start placing
%                   the GUI elements of this plugin. 
%
%                 'update' (HitHistory, SidesHistory)    
%                   This call will recompute both local estimates of
%                   fraction correct, and will recompute the recommended 
%                   probs. This action requires two more arguments:
%                   HitHist, a vector of 1s and 0s and of length 
%                   n_done_trials where 1 represents correct and 0
%                   represents incorrect, first element corresponds to 
%                   first trial; and SidesHist, a vector of 'c's 'l's and 
%                   'r's and of length n_done_trials where 'c' represents 
%                   'center', 'r' represents 'right' and 'l' represents 
%                   'left', first element corresponds to first trial.
%
%                 'get_posterior_probs'
%                   Returns a vector with three components, 
%                   [p(Center) p(Left) p(Right)].
% 
% 
%                 'update_biashitfrac' (HitHistory, SidesHistory) 
%                   This call will recompute the local estimate of fraction
%                   Left correct and fraction Right correct used for
%                   antibiasing, and will also recompute the recommended
%                   Left probability. This action requires two more arguments:
%                   HitHistory, a vector of 1s and 0s and of length 
%                   n_done_trials where 1 represents correct and 0
%                   represents incorrect, first element corresponds to 
%                   first trial; and SidesHistory, a vector of 'c's 'l's and 
%                   'r's and of length n_done_trials where 'c' represents 
%                   'center', 'r' represents 'right' and 'l' represents 
%                   'left', first element corresponds to first trial.
% 
%                 'update_hitfrac' (HitHistory, SidesHistory)
%                   This call is not related to computing the posterior
%                   Left probability, but will recompute only the local estimate
%                   of fraction correct that is not used for antibiasing.
%                   This action requires two more arguments: HitHist, a
%                   vector of 1s and 0s and of length n_done_trials where 1
%                   represents correct and 0 represents incorrect, first
%                   element corresponds to first trial; and SidesHist, a vector of
%                   'l's and 'r's and of length n_done_trials where 'l'
%                   represents 'left', 'r' represents 'right' first element
%                   corresponds to first trial.
%
%                 'get' (What)
%                   Needs one extra parameter, 'Beta', 'antibias_tau'
%                   'TargetProbs', and returns the corresponding scalar (or
%                   vector for TargetProbs, Center & Left)
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
% [x1, y1, w, h]   When action == 'init', Antibias3way will put up GUIs and
%          take up a certain amount of space of the figure that was current
%          when Antibias3waySection(obj, 'init', x, y) was called. On
%          return, [x1, y1] will be the top left corner of the space used; 
%          [x y] (as passed to Antibias3way in the init call) will be the
%          bottom left corner; [x+w y1] will be the top right; and [x+w y] 
%          will be the bottom right. h = y1-y. All these are in units of
%          pixels.
%
%
% if action == 'get_posterior_probs' :
%
% [C L R]   When action == 'get_posterior_probs', a three-component vector 
%           is returned, with p(center), p(Left) and p(Right).  If beta=0,
%           then p(Left) will be the same as the last LeftProb that was 
%           passed in.
%
%
% USAGE:
% ------
%
% To use this plugin, the typical calls would be:
%
% 'init' : On initializing your protocol, call 
%    Antibias3waySection(obj, 'init', x, y);
%
% 'update' : After a trial is completed, call
%    Antibias3waySection(obj, 'update', HitHistory, SidesHistory)
%
% 'get_posterior_probs' : After a trial is completed, and when you are
%       deciding what kind of trial to make the next trial, get the plugins
%       opinion on whether the next trial should be Left or Right by calling
%       Antibias3waySection(obj, 'get_posterior_probs')
%
% See PARAMETERS section above for the documentation of each of these calls.
%


function [x, y, w, h] = Antibias3waySection(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action

%% init

  case 'init',   % ------------ CASE INIT ----------------
    x = varargin{1}; y = varargin{2}; y0 = y;
    
    %Initialize SoloParamHandles    
    SoloParamHandle(obj, 'BiasCHitFrac', 'value', 0);
    SoloParamHandle(obj, 'BiasLHitFrac', 'value', 0);
    SoloParamHandle(obj, 'BiasRHitFrac', 'value', 0);

    SoloParamHandle(obj, 'LocalHitHistory',   'value', []);
    SoloParamHandle(obj, 'LocalPrevSides',    'value', []);
    SoloParamHandle(obj, 'LocalLateHistory',  'value', []);
    SoloParamHandle(obj, 'LocalWrongHistory', 'value', []);
    

    % Save the figure and the position in the figure where we are
    % going to start adding GUI elements:
    SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);

    
    %Hit Fractions
    LogsliderParam(obj, 'HitFracTau', 30, 10, 400, x, y, 'label', 'hits frac tau', ...
      'position', [x y 300 20], 'labelfraction', 0.50, 'TooltipString', ...
      sprintf(['\nnumber of trials back over which to compute fraction of correct trials.\n' ...
      'This is just for displaying info-- for the bias calculation, see BiasTau above']));
    set_callback(HitFracTau, {mfilename, 'update_hitfrac'});
    next_row(y);
    %CENTER
    DispParam(obj, 'CHitFrac',  0, x, y, 'position', [x     y 100 20], 'labelfraction', 0.45);
    DispParam(obj, 'CActFrac',  0, x, y, 'position', [x+100 y 100 20], 'labelfraction', 0.50);
    DispParam(obj, 'CLateFrac', 0, x, y, 'position', [x+200 y 100 20], 'labelfraction', 0.50);
    next_row(y);
    %LEFT
    DispParam(obj, 'LHitFrac',  0, x, y, 'position', [x     y 100 20], 'labelfraction', 0.45);
    DispParam(obj, 'LActFrac',  0, x, y, 'position', [x+100 y 100 20], 'labelfraction', 0.50);
    DispParam(obj, 'LLateFrac', 0, x, y, 'position', [x+200 y 100 20], 'labelfraction', 0.50);
    next_row(y);
    %RIGHT
    DispParam(obj, 'RHitFrac',  0, x, y, 'position', [x     y 100 20], 'labelfraction', 0.45);
    DispParam(obj, 'RActFrac',  0, x, y, 'position', [x+100 y 100 20], 'labelfraction', 0.50);
    DispParam(obj, 'RLateFrac', 0, x, y, 'position', [x+200 y 100 20], 'labelfraction', 0.50);
    next_row(y);
    %OVERALL
    DispParam(obj, 'HitFrac',  0, x, y, 'position', [x     y 100 20], 'labelfraction', 0.45);
    DispParam(obj, 'ActFrac',  0, x, y, 'position', [x+100 y 100 20], 'labelfraction', 0.50);
    DispParam(obj, 'LateFrac', 0, x, y, 'position', [x+200 y 100 20], 'labelfraction', 0.50);
    next_row(y);
    

    next_row(y, 0.5);
    
    
    %Probabilities Section
    LogsliderParam(obj, 'BiasTau', 30, 10, 400, x, y, 'label', 'Antibias Tau', ...
       'position', [x y 300 20], 'labelfraction', 0.5, 'TooltipString', ...
      sprintf(['\nnumber of trials back over\nwhich to compute fraction of correct trials\n' ...
      'for the Antibias3way function.']));
    next_row(y);

    NumeditParam(obj, 'Beta', 3, x, y, ...
       'position', [x y 150 20], 'labelfraction', 0.5,'TooltipString', ...
      sprintf(['When this is 0, past performance doesn''t affect choice\n' ...
      'of next trial. When this is large, the next trial is ' ...
      'almost guaranteed\nto be the one with smallest %% correct']));
    ToggleParam(obj, 'ExcLate', 0, x+150, y,'position', [x+150 y 150 20], 'TooltipString', ...
      sprintf('\nIf ON, late trials are exluded from hitfrac, if OFF, all trials are included.'), ...
      'OnString', 'Exclude Late', 'OffString', 'Include Late');
    next_row(y);

    NumeditParam(obj, 'TargetCProb', 0, x, y, 'position', [x y 150 20], 'labelfraction', 0.5,...
      'TooltipString', sprintf('Probability of Center when performance is unbiased'));
    DispParam(obj, 'CProb', value(TargetCProb), x+150, y, 'position', [x+150 y 150 20], 'labelfraction', 0.5); %#ok<NODEF>
    next_row(y);

    NumeditParam(obj, 'TargetLProb', 0.5, x, y, 'position', [x y 150 20], 'labelfraction', 0.5, ...
      'TooltipString', sprintf('Probability of Left when performance is unbiased'));
    DispParam(obj, 'LProb', value(TargetLProb), x+150, y, 'position', [x+150 y 150 20], 'labelfraction', 0.5); %#ok<NODEF>
    next_row(y);

    DispParam   (obj, 'TargetRProb', 1-(TargetCProb+TargetLProb), x, y,  'position', [x y 150 20], 'labelfraction', 0.5, ...
      'TooltipString', sprintf('Probability of Right when performance is unbiased'));%#ok<NODEF>
    DispParam(obj, 'RProb', value(TargetRProb), x+150, y, 'position', [x+150 y 150 20], 'labelfraction', 0.5); %#ok<NODEF>
    next_row(y);

    set_callback({BiasTau, Beta, ExcLate, TargetCProb, TargetLProb}, {mfilename, 'update_biashitfrac'});
    
   
    %Title
    SubheaderParam(obj, 'title', mfilename, x, y, 'position', [x y 300 20]);
    next_row(y, 1.5);

    w = gui_position('get_width');
    h = y-y0;


%% update

  case 'update',    % --- CASE UPDATE -------------------

    feval(mfilename, obj, 'update_hitfrac');
    feval(mfilename, obj, 'update_biashitfrac');

    
%% update_biashitfrac    

  case 'update_biashitfrac',     % ------- CASE UPDATE_BIASHITFRAC -------------

    TargetRProb.value = 1-(TargetCProb+TargetLProb); %#ok<NODEF,NASGU>
      
    if exist('hit_history',   'var'), hh = value(hit_history);   hh = colvec(hh); end; %#ok<NASGU>
    if exist('late_history',  'var'), lh = value(late_history);  lh = colvec(lh); end; %#ok<NASGU>
    if exist('sides_history', 'var'), ps = value(sides_history); end; %#ok<NASGU>
    
    if length(varargin)>=1
        LocalHitHistory.value   = varargin{1};  
        if isa(value(LocalHitHistory), 'SoloParamHandle'), LocalHitHistory.value = value(value(LocalHitHistory)); end;
        hh = value(LocalHitHistory); hh = colvec(hh);%#ok<NASGU>
    end;
    if length(varargin)>=2
        LocalPrevSides.value    = varargin{2};
        if isa(value(LocalPrevSides), 'SoloParamHandle'), LocalPrevSides.value = value(value(LocalPrevSides)); end;
        lh = value(LocalHitHistory); lh = colvec(lh); %#ok<NASGU>
    end;
    if length(varargin)>=3
        LocalLateHistory.value  = varargin{3};  
        if isa(value(LocalLateHistory), 'SoloParamHandle'), LocalLateHistory.value = value(value(LocalLateHistory)); end;
        ps = value(LocalLateHistory); %#ok<NASGU>
    end;

    if ExcLate == 1
        act = find(lh == 0);
        hhbias = hh(act); %#ok<FNDSB>
    else
        hhbias = hh;
    end;
    
    if ~isempty(hhbias)
        kernel = exp(-(0:length(hhbias)-1)/BiasTau)';
        kernel = kernel(end:-1:1);

        prevs = ps(1:length(hhbias))';
        uc = find(prevs == 'c');
        BiasCHitFrac.value = fraccalc(hhbias, kernel, uc);
     
        ul = find(prevs == 'l');
        BiasLHitFrac.value = fraccalc(hhbias, kernel, ul);

        ur = find(prevs == 'r');
        BiasRHitFrac.value = fraccalc(hhbias, kernel, ur);

        choices = probabilistic_trial_selector([value(BiasCHitFrac), value(BiasLHitFrac), value(BiasRHitFrac)], ...
            [value(TargetCProb), value(TargetLProb), value(TargetRProb)], value(Beta)); %#ok<NODEF>
        
        CProb.value = choices(1);
        LProb.value = choices(2);
        RProb.value = choices(3);
    else
        CProb.value = value(TargetCProb);
        LProb.value = value(TargetLProb);
        RProb.value = value(TargetRProb);
    end;

    
%% set_target_probs
  case 'set_target_probs',
    
    if length(varargin)~=2,
      error('Antibias3waySection:InvalidArgs', 'set_target_probs needs two args, the TargetCProb and the TargetLProb');
    end;
    TargetCProb.value = varargin{1};
    TargetLProb.value = varargin{2};
    
    
%% get_posterior_probs

  case 'get_posterior_probs',      % ------- CASE GET_POSTERIOR_PROBS -------------
    x = [value(CProb); value(LProb); value(RProb)]; %#ok<NODEF>


%% update_hitfrac

  case 'update_hitfrac',     % ------- CASE UPDATE_HITFRAC -------------

    if exist('hit_history',   'var'), hh = value(hit_history);   hh = colvec(hh); end; %#ok<NASGU>
    if exist('late_history',  'var'), lh = value(late_history);  lh = colvec(lh); end; %#ok<NASGU>
    if exist('sides_history', 'var'), ps = value(sides_history); end; %#ok<NASGU>
    
    if length(varargin)>=1
        LocalHitHistory.value   = varargin{1};  
        if isa(value(LocalHitHistory), 'SoloParamHandle'), LocalHitHistory.value = value(value(LocalHitHistory)); end;
        hh = value(LocalHitHistory); %#ok<NASGU>
    end;
    if length(varargin)>=2
        LocalPrevSides.value    = varargin{2};
        if isa(value(LocalPrevSides), 'SoloParamHandle'), LocalPrevSides.value = value(value(LocalPrevSides)); end;
        lh = value(LocalHitHistory); %#ok<NASGU>
    end;
    if length(varargin)>=3
        LocalLateHistory.value  = varargin{3};  
        if isa(value(LocalLateHistory), 'SoloParamHandle'), LocalLateHistory.value = value(value(LocalLateHistory)); end;
        ps = value(LocalLateHistory); %#ok<NASGU>
    end;

      
    if length(hh)>=1, 
      kern1 = exp(-(0:length(hh)-1)/HitFracTau)';
      kern1 = kern1(end:-1:1);
      HitFrac.value = fraccalc(hh, kern1, 'all');

      prevs = ps(1:length(hh))';
      uc = find(prevs == 'c');
      CHitFrac.value = fraccalc(hh, kern1, uc);
     
      ul = find(prevs == 'l');
      LHitFrac.value = fraccalc(hh, kern1, ul);

      ur = find(prevs == 'r');
      RHitFrac.value = fraccalc(hh, kern1, ur);

      if length(lh)>=1, 
        kern2 = exp(-(0:length(lh)-1)/HitFracTau)';
        kern2 = kern2(end:-1:1);
        LateFrac.value = fraccalc(lh, kern2, 'all');

        prevs = ps(1:length(lh));
      
        uc = find(prevs == 'c');
        CLateFrac.value = fraccalc(lh, kern2, uc);

        ul = find(prevs == 'l');
        LLateFrac.value = fraccalc(lh, kern2, ul);

        ur = find(prevs == 'r');
        RLateFrac.value = fraccalc(lh, kern2, ur);
      end;

      if length(hh)>=1,
        act = find(lh == 0);
        hhact = hh(act); %#ok<FNDSB>
        if  isempty(hhact)
          hhact = 0;
        end;
  
        kern3 = exp(-(0:length(hhact)-1)/HitFracTau)';
        kern3 = kern3(end:-1:1);
        ActFrac.value = fraccalc(hhact, kern3, 'all');

        prevs = ps(act)';
        uc = find(prevs == 'c');
        CActFrac.value = fraccalc(hhact, kern3, uc);

        ul = find(prevs == 'l');
        LActFrac.value = fraccalc(hhact, kern3, ul);

        ur = find(prevs == 'r');
        RActFrac.value = fraccalc(hhact, kern3, ur);
      end;
    end;

    
%% get    
  case 'get',    % ------- CASE GET -------------
    if length(varargin)~=1,
      error('Antibias3waySection:Invalid', '''get'' needs one extra param');
    end;
    switch varargin{1},
      case 'Beta',
        x = value(Beta);
      case 'antibias_tau',
        x = value(BiasTau);
      case 'TargetProbs',
        x = [value(TargetCProb) value(TargetLProb)]; %#ok<NODEF>
      otherwise
        error('Antibias3waySection:Invalid', 'Don''t know how to get %s', varargin{1});
    end;


%% reinit

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


%% function colvec

function [x] = colvec(x)
 if size(x,2) > size(x,1), x = x'; end;

 
%%Function Frac Calculator
 
function [frac] = fraccalc(hist, weight, elem)
if (~strcmp(elem, 'all'))
    if isempty(elem), frac = 0;
    else frac = sum(hist(elem) .* weight(elem))/sum(weight(elem));
    end;
else frac = sum(hist .* weight)/sum(weight); 
end;
 
 