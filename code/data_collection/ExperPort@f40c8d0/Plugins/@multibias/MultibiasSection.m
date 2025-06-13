% [x, y] = MultibiasSection(obj, action, [arg1], [arg2], [arg3])    
%
% Section that calculates biases and calculates probability of choosing a stimulus
% given the previous history. 
% 
% Note that with the default trial classes 'l' and 'r',
% Multibias is functionally equivalent to Antibias. But it is not 100%
% backwards-compatible: when you pass in the prior probabilities, you can't
% just pass in a scalar anymore (in Antibias you could just pass in
% LeftProb, and it knew that RightProb was 1-LeftProb; but now there can be
% more than two classes).  So if you're movingfrom Antibias to Multibias,
% don't just do a "find and replace", read the documentation.
%
%    Multibias assumes that trials are of n classes, (default 'l' and 'r')
%    and that their outcome is either Correct or Incorrect. Given the
%    history of previous trial classes, and the history of previous
%    corrects/incorrects, Multibias makes a local estimate of fraction
%    correct for each class, combines that with a prior probability of
%    making the next trial each class, and produces a recommended
%    probability  for choosing the next trial as each class. Multibias will
%    tend to make the class with the smaller frac correct the one with the
%    higher probability. When a class has no trials in the session yet, its
%    fraction correct is assumed to be the overall average fraction
%    correct.
%
% The strength of the tendency to favor classes with lower fraction correct
% is quantified by a parameter, beta. (See probabilistic_trial_selector.m
% for details on the math of how the tendency is generated.)
%
% Local estimates of fraction correct are computed using an exponential
% kernel, most recent trial the most strongly weighted. The tau of this
% kernel is a GUI parameter. Two different estimates are computed: one for
% use in computing the class probabilities; and a second simply for GUI
% display purposes. The two estimates can have different taus for their
% kernels. So you can use the display-only one to see fraction corrects at
% taus different to the bias tau, without affecting the bias calculation.
%
% GUI DISPLAY: When initialized, this plugin will put up two panels and a
% title. In each panel, there is a slider that controls the tau of the
% recent-trials exponential kernel. One panel will display the percent
% corrects for each class, as computed with its kernel. The second panel
% will display the a posteriori probabilities of making the next trial a
% each of the classes. This second panel has its own tau slider, and it
% also has a GUI parameter, beta, that controls how strongly the history
% matters. If beta=0, history doesn't matter, and the a priori
% probability dominates. If beta=Inf, then history matters above all:
% the next trial will be of the type with lowest fraction correct, for sure.
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
%        [classes=['l', 'r']]  An additional optional argument, by default
%                   the vector ['l', 'r'] for Left and Right, specifies the
%                   classes of the trials that will be distinguished, and
%                   over which computations will be based. The individual
%                   class IDs can be chars, or integers, or strings.
%
%     'update'      This call will recompute both local estimates of
%                   fraction correct, and will recompute the recommended 
%                   probVec a vector of probabilities whose sum is 1 and 
%                   indicates the posterior probabilities of the different
%                   classes (in the same order as the classes argument in
%                   'init', i.e., the default is [p(Left) p(Right)].
%       priorProbs, This action requires three more arguments:
%       HitHist,    priorProbs, a probability vector, same length as
%       ClassesHist classes; HitHist, a vector of 1s and 0s and of length
%                   n_done_trials where 1 represents correct and 0
%                   represents incorrect, first element corresponds to
%                   first trial; and ClassesHist, a vector of length
%                   n_done_trials, first element corresponds to first
%                   trial, whose elements are all drawn from the elements
%                   of classes.  For example, for the default classes, 'l'
%                   represents 'left would be the correct response',  
%                   'r' represents 'right would be correct' .
%                       Calling 'update' is the same as calling
%                   'update_hitfrac' and 'update_biashitfrac' in succession.
%
%     'update_biashitfrac'   This call will recompute the local estimate of
%                   fraction correct for each class, used for
%      priorProbs,  antibiasing, and will also recompute the recommended
%      HitHist,     Left probability. This action    
%      ClassesHist, requires three more arguments: priorProbs, a
%                   probability vector, same length as classes; HitHist, a
%                   vector of 1s and 0s and of length n_done_trials where 1
%                   represents correct and 0 represents incorrect, first element corresponds to
%                   first trial; and ClassesHist, a vector of length
%                   n_done_trials, first element corresponds to first
%                   trial, whose elements are all drawn from the elements
%                   of classes.  For example, for the default classes, 'l'
%                   represents 'left would be the correct response',  
%                   'r' represents 'right would be correct'.
%
%      ClassesSubset    If a 4th argument is passed in to 'update_biashitfrac', 
%                   it is interpreted as a list, a subset of all the originally registered
%                   classes, to be considered when doing the
%                   multibiasing. If this 4th argument is passed in, then
%                   in addition to computing the above as normal, this action 
%                   will return a vector pp of posterior probabilities, length
%                   of ClassesSubset, that contains the posterior, computed 
%                   taking it as given that one of the classes in
%                   ClassesSubset will chosen.  A second value cc is returned, and this
%                   will  be a list of the classes that correspond to the
%                   probabilities in pp.  That is, class cc(i) will have
%                   posterior probability pp(i).
% 
%     'update_hitfrac'  This call is not related to computing the posterior
%                   probabilities, but will recompute only the local estimate
%       HitHist,    of fraction correct that is not used for antibiasing.
%       ClassesHist This action requires two more arguments: HitHist, a
%                   vector of 1s and 0s and of length n_done_trials where 1
%                   represents correct and 0 represents incorrect, first
%                   element corresponds to first trial; and ClassesHist, a
%                   vector of length n_done_trials, first element
%                   corresponds to first trial, whose elements are all
%                   drawn from the elements of classes.  For example, for
%                   the default classes, 'l' represents 'left would be the
%                   correct response', 'r' represents 'right would be correct' .
%
%     'get_posterior_probs'  Returns a probability vector same length as
%                   classes, each entry is the recommended probability of
%                   choosing that class, the entries are all >=0 and add up
%                   to 1. 
% 
%     'get'         Needs one extra parameter, either 'Beta' or
%                   'antibias_tau', and returns the corresponding scalar.
% 
%     'set'         Needs two extra parameters, first either 'Beta' or
%                   'antibias_tau', and then a numeric scalar; it will set
%                   the corresponding SoloParamHandle's value to that scalar.
%
%     'reinit'      Delete all of this section's GUIs and data,
%                   and reinit, at the same position on the same
%         [classes] figure as the original section GUI was placed. If no
%                   argument is passed, reinits with the same classes as
%                   last 'init' or 'reinit'. If an argument is passed, it
%                   is assumed to be classes.
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
% [x1, y1, w, h]   When action == 'init', Multibias will put up GUIs and take
%          up a certain amount of space of the figure that was current when
%          MultibiasSection(obj, 'init', x, y) was called. On return, [x1 y1]
%          will be the top left corner of the space used; [x y] (as passed
%          to Multibias in the init call) will be the bottom left corner;
%          [x+w y1] will be the top right; and [x+w y] will be the bottom
%          right. h = y1-y. All these are in units of pixels.
%
%
% if action == 'get_posterior_probs' :
%
% probVec   When action == 'get_posterior_probs', returns a
%           length-of-classes-component vector, with the probability for
%           each class in the corresponding element. If beta=0, then 
%           will be the same as the priorProbs that was passed in.
%
%
% if action == 'update_biashitfrac' and a 4th argument, ClassesSubset, is provided:
% 
% [pp, cc]    a vector pp of posterior probabilities, length
%             of ClassesSubset, that contains the posterior, computed 
%             taking it as given that one of the classes in
%             ClassesSubset will chosen.  A second value cc is returned, and this
%             will  be a list of the classes that correspond to the
%             probabilities in pp.  That is, class cc(i) will have
%             posterior probability pp(i).
%
% USAGE:
% ------
%
% To use this plugin, the typical calls would be:
%
% 'init' : On initializing your protocol, call 
%    MultibiasSection(obj, 'init', x, y, [classes=['l' 'r']]);
%
%  e.g., if your classes are not the default but have IDs [1, 4, 50, 10], you
%  would call 
%    MultibiasSection(obj, 'init', x, y, [1, 4, 50, 10]);
%
% 'update' : After a trial is completed, call
%    MultibiasSection(obj, 'update', priorProbs, HitHist, ClassesHist)
%
%           priorProbs is the prior probabilities for the different trial
%           classes, HitHist is a vector, history of correct/incorrect in
%           the session so far, ClassesHist is a vector, same length as Hit
%           Hist, each entry indicates the class of the corresponding
%           trial. For example, if you called 'init' with classes 
%           [1, 4, 50, 10], and you want the prior probability for the last
%           two to be 4 times as much as the first two; and 6 trials have
%           elapsed in the session, with one trial of class 1, one of class
%           10, and four of class 50, you might call update as  
%    MultibiasSection(u, 'update', [0.1 0.1 0.4, 0.4], [1 0 0 1 0 0], [1 50 10 50 50 50])
%
% 'get_posterior_probs' : After a trial is completed, and when you are
%       deciding what kind of trial to make the next trial, get the plugins
%       opinion on whether the next trial should be Left or Right by calling
%       MultibiasSection(obj, 'get_posterior_probs')
%
% 'update_biashitfrac' with a 4th param, ClassesSubset:
%
%   (assuming the owning object is u):
%
%   MultibiasSection(u, 'set', 'Beta', 2);  % we set Beta to 2 just as an example.
%   [pp, cc] = MultibiasSection(u, 'update_biashitfrac', [0.3, 0.3, 0.2, 0.2], [1, 1, 1, 0, 1, 1], [1, 2, 3, 4, 1, 2], [1, 4, 2])
% 
%       pp = [0.1444    0.1444    0.7112]
%       cc =  [1     2     4]
%
%   Note that the 4th param, classesSubset, was passed in as [1 4 2], but
%   the answer came in a different classes order. That's why it is
%   important to look at cc, not just pp.
%
% See PARAMETERS section above for the documentation of each of these calls.
%


function [x, y, w, h] = MultibiasSection(obj, action, varargin)
   
GetSoloFunctionArgs(obj);
   
switch action
    
  case 'init'   % ------------ CASE INIT ----------------
    x = varargin{1}; y = varargin{2}; y0 = y;
    if length(varargin)>2
        classes = varargin{3};
    else
        classes = ['l' 'r'];
    end
    % Save the figure and the position in the figure where we are
    % going to start adding GUI elements:
    SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);
    SoloParamHandle(obj, 'my_classes_info', 'value', classes)

    LogsliderParam(obj, 'HitFracTau', 30, 10, 400, x, y, 'label', 'hits frac tau', ...
      'TooltipString', ...
      sprintf(['\nnumber of trials back over which to compute fraction of correct trials.\n' ...
      'This is just for displaying info-- for the bias calculation, see BiasTau above']));
    set_callback(HitFracTau, {mfilename, 'update_hitfrac'});
    next_row(y);
    for i=1:length(classes)
        DispParam(obj, classId2char("HitFrac_", classes(i)), 0, x, y, ...
            'TooltipString', ['exponentially weighted fraction correct for' ...
            ' this class, using the tau below, recent trials most ' ...
            'weighted.']); next_row(y);
    end
    DispParam(obj, 'HitFrac',   0, x, y, ...
            'TooltipString', ['overall fraction correct, using exponential' ...
            ' kernel but ignoring class ID.']); next_row(y);
    
    next_row(y, 0.5);
    LogsliderParam(obj, 'BiasTau', 30, 10, 400, x, y, 'label', 'antibias tau', ...
      'TooltipString', ...
      sprintf(['\nnumber of trials back over\nwhich to compute fraction of correct trials\n' ...
      'for the antibias function.'])); next_row(y);
    NumeditParam(obj, 'Beta', 0, x, y, ...
      'TooltipString', ...
      sprintf(['When this is 0, past performance doesn''t affect choice\n' ...
      'of next trial. When this is large, the next trial is ' ...
      'almost guaranteed\nto be the one with smallest %% correct'])); next_row(y);
    set_callback({BiasTau, Beta}, {mfilename, 'update_biashitfrac'});
    for i=1:length(classes)
        DispParam(obj, classId2char("Prob_", classes(i)), 0, x, y, ...
            'TooltipString', ['recommended P of choosing this class, after' ...
            ' biasing for classes with lower fraction correct']); next_row(y);
    end
    SoloParamHandle(obj, 'BiasHitFracs', 'value', zeros(size(classes)));
    

    SoloParamHandle(obj, 'LocalpriorProbs',    'value', [ones(size(classes))]/length(classes));
    SoloParamHandle(obj, 'LocalHitHistory', 'value', []);
    SoloParamHandle(obj, 'LocalClassesHist',  'value', []);

    
    SubheaderParam(obj, 'title', mfilename, x, y);
    next_row(y, 1.5);

    w = gui_position('get_width');
    h = y-y0;
    
    
  case 'update'    % --- CASE UPDATE -------------------
    if length(varargin)>0, LocalpriorProbs.value      = varargin{1};  end    %#ok<ISMT> 
    if length(varargin)>1, LocalHitHistory.value   = varargin{2};  end
    if length(varargin)>2, LocalClassesHist.value  = varargin{3};  end
    % Protect against somebody passing in SPHs, not actual values, by mistake:
    if isa(value(LocalpriorProbs),   'SoloParamHandle'), LocalpriorProbs.value   = value(value(LocalpriorProbs));   end
    if isa(value(LocalHitHistory),   'SoloParamHandle'), LocalHitHistory.value   = value(value(LocalHitHistory)); end
    if isa(value(LocalClassesHist),  'SoloParamHandle'), LocalClassesHist.value  = value(value(LocalClassesHist));  end

    feval(mfilename, obj, 'update_hitfrac');
    feval(mfilename, obj, 'update_biashitfrac');
    
    
   
  case 'update_biashitfrac'     % ------- CASE UPDATE_BIASHITFRAC -------------
    if length(varargin)>0 %#ok<ISMT> 
        if isa(varargin{1}, 'SoloParamHandle')  LocalpriorProbs.value = value(varargin{1});
        else                                    LocalpriorProbs.value  = varargin{1};  
        end
    end    
    if length(varargin)>1 
        if isa(varargin{2}, 'SoloParamHandle') LocalHitHistory.value  = value(varargin{2});
        else                                   LocalHitHistory.value  = varargin{2};  
        end
    end
    if length(varargin)>2 
        if isa(varargin{3}, 'SoloParamHandle') LocalClassesHist.value = value(varargin{3});
        else                                   LocalClassesHist.value = varargin{3};  
        end
    end
    if length(varargin)>3 && ~isempty(setdiff(value(my_classes_info), varargin{4}))
        classesSubset = varargin{4};
        if ~all(ismember(unique(classesSubset), value(my_classes_info)))
            error('MultibiasSection:Invalid', 'classesSubset should be a subset of the registered classes')
        end
    else
        classesSubset = [];
    end

    priorProbs       = value(LocalpriorProbs);
    hit_history      = value(LocalHitHistory);  hit_history = colvec(hit_history);
    previous_classes = value(LocalClassesHist); 
    classes          = value(my_classes_info);

    errorCheck(previous_classes, hit_history, value(my_classes_info));
    if length(priorProbs) ~= length(classes)
        error('MutlibiasSection:Invalid', ['the passed priorProbs vector ' ...
            'is not the same length as the classes registered in the latest ' ...
            'call to ''init'' or ''reinit''']);
    end
    if abs(sum(priorProbs)-1)>eps  || any(priorProbs > 1) || any(priorProbs < 0)
        error('MutlibiasSection:Invalid', ['all elements of the the passed ' ...
            'priorProbs vector must be >=0, <=1, and they must all sum to 1']); 
    end

    kernel = exp(-(0:length(hit_history)-1)/BiasTau)';
    kernel = kernel(end:-1:1);
    
    prevs = previous_classes(1:length(hit_history))';

    classEmptyFlags = false(size(classes));  % a vector that will have 1s for classes with no trials yet

    % now put into SoloParamHandle BiasHitFracs the fraction correct for each class, according
    % to the kernel:
    for i=1:length(classes)
        u = find(prevs == classes(i));
        if isempty(u), BiasHitFracs(i) = 1; classEmptyFlags(i) = true; %#ok<AGROW> 
        else           BiasHitFracs(i) = sum(hit_history(u) .* kernel(u))/sum(kernel(u)); %#ok<AGROW,SEPEX> 
        end
    end
    
    % any class that has had no trials at all so far gets the average
    % fraction correct across the other classes
    avgPerf = sum(hit_history .* kernel)/sum(kernel);
    BiasHitFracs(classEmptyFlags) = avgPerf;

    choices = probabilistic_trial_selector(value(BiasHitFracs), priorProbs, value(Beta));
    for i=1:length(classes)
        sph = eval(classId2char("Prob_", classes(i)));
        sph.value = choices(i);
    end

    if ~isempty(classesSubset)
        classMask = ismember(classes, classesSubset);
        BiasHitFracsSubset = BiasHitFracs(classMask);
        priorProbsSubset   = priorProbs(classMask);
        priorProbsSubset   = priorProbsSubset/sum(priorProbsSubset);
        x = probabilistic_trial_selector(BiasHitFracsSubset, priorProbsSubset, value(Beta));
        y = classes(classMask);
        return;
    end
     

  case 'compute_posterior_probs_only'   % ------- CASE COMPUTE_POSTERIOR_PROBS_ONLY -------------
    if length(varargin) ~= 4
        error('MultibiasSection:Invalid', '''compute_posterior_probs_only'' needs 4 params');
    end
    priorProbs             = varargin{1}; 
    LocalHitHistory.value  = varargin{2}; 
    LocalClassesHist.value = varargin{3}; 
    ValidClasses           = varargin{4};

    % Protect against somebody passing in SPHs, not actual values, by mistake:
    if isa(value(LocalpriorProbs),  'SoloParamHandle'), LocalpriorProbs.value  = value(value(LocalpriorProbs));     end
    if isa(value(LocalHitHistory),  'SoloParamHandle'), LocalHitHistory.value  = value(value(LocalHitHistory));  end
    if isa(value(LocalClassesHist), 'SoloParamHandle'), LocalClassesHist.value = value(value(LocalClassesHist)); end

    priorProbs       = value(LocalpriorProbs);
    hit_history      = value(LocalHitHistory);  hit_history = colvec(hit_history);
    previous_classes = value(LocalClassesHist); 
  
    if abs(sum(priorProbs)-1)>eps  || any(priorProbs > 1) || any(priorProbs < 0)
        error('MutlibiasSection:Invalid', ['all elements of the the passed ' ...
            'priorProbs vector must be >=0, <=1, and they must all sum to 1']); 
    end


  case 'get_posterior_probs'      % ------- CASE GET_POSTERIOR_PROBS -------------
    classes = value(my_classes_info);
    x = zeros(size(classes));
    for i=1:length(classes)
        sph = eval(classId2char("Prob_", classes(i)));
        x(i) = value(sph);
    end
    
  
  case 'update_hitfrac'     % ------- CASE UPDATE_HITFRAC -------------
    if ~isempty(varargin), LocalHitHistory.value  = varargin{1};  end
    if length(varargin)>1, LocalClassesHist.value = varargin{2};  end
    % Protect against somebody passing in SPHs, not actual values, by mistake:
    if isa(value(LocalHitHistory),  'SoloParamHandle'), LocalHitHistory.value  = value(value(LocalHitHistory)); end
    if isa(value(LocalClassesHist), 'SoloParamHandle'), LocalClassesHist.value = value(value(LocalClassesHist));  end

    hit_history    = value(LocalHitHistory); hit_history = colvec(hit_history);
    previous_classes = value(LocalClassesHist); 

    errorCheck(previous_classes, hit_history, value(my_classes_info));

    if ~isempty(hit_history) 
      kernel = exp(-(0:length(hit_history)-1)/HitFracTau)';
      kernel = kernel(end:-1:1);
      HitFrac.value = sum(hit_history .* kernel)/sum(kernel); %#ok<STRNU> 
    
      prevs = previous_classes(1:length(hit_history))';

      classes = value(my_classes_info);
      for i=1:length(classes)
        u = find(prevs == classes(i));
        sph = eval(classId2char("HitFrac_", classes(i)));
        if isempty(u), sph.value = NaN; 
        else           sph.value = sum(hit_history(u) .* kernel(u))/sum(kernel(u)); %#ok<SEPEX> 
        end
      end
    end
          
    
  case 'get'    % ------- CASE GET -------------
    if length(varargin)~=1
      error('MultibiasSection:Invalid', '''get'' needs one extra param');
    end
    switch varargin{1}
      case 'Beta'
        x = value(Beta);
      case 'antibias_tau'
        x = value(BiasTau);
      otherwise
        error('MultibiasSection:Invalid', 'Don''t know how to get %s', varargin{1});
    end
    
            
  case 'set'    % ------- CASE SET -------------
    if length(varargin)~=2
      error('MultibiasSection:Invalid', '''set'' needs two extra params');
    end
    if ~( isnumeric(varargin{2}) && isscalar(varargin{2}) )
      error('MultibiasSection:Invalid', 'values to be set must be numeric scalars')
    end
    switch varargin{1}
      case 'Beta'
        Beta.value = varargin{2}; %#ok<STRNU> 
      case 'antibias_tau'
        BiasTau.value = varargin{2}; %#ok<STRNU> 
      otherwise
        error('MultibiasSection:Invalid', 'Don''t know how to set %s', varargin{1});
    end
    
            
  case 'reinit'   % ------- CASE REINIT -------------
    if length(varargin) > 1
        error('MultibiasSection:Invalid', 'reinit can take max one optional argument')
    end
    currfig = double(gcf);
    if ~isempty(varargin)
        classes = varargin{1};
    else
        classes = value(my_classes_info);
    end
    
    % Get the original GUI position and figure:
    x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);
    
    % Reinitialise at the original GUI position and figure:
    [x, y] = feval(mfilename, obj, 'init', x, y, classes);
    
    % Restore the current figure:
    figure(currfig);
end
   

% [] = errorCheck(previous_classes, hit_history, classes)
%
% throws an error if length(previous_classes)~=length(hit_history) or if 
% there is an eleement of previous_classes that isn't in the set classes
%

function errorCheck(previous_classes, hit_history, classes)

    if length(previous_classes) ~= length(hit_history)
        error('MultibiasSection:Invalid', ['HitHistory and ClassesHist ' ...
            'should be the same length vectors.'])
    end
    if ~all(ismember(unique(previous_classes), classes))
        z = unique(previous_classes);
        u = find(~ismember(z, classes));
        disp("Registered classes are:");
        disp(classes);
        error('MultibiasSection:Invalid', ['Entry ' char(string(z(u(1)))) ' ' ...
            'in ClassesHist is ' ...
            'not found in the registered classes. Did you intitialize this ' ...
            'multibias object (''init'' call) with the correct classes parameter?'])
    end

   
% charvec = classId2char(rootString, id)
%
% makes sure id is a string, and then returns char(rootString+id)
%
function charvec = classId2char(rootString, id)
    if ~isstring(id)
        id = string(id);
    end
    charvec = char(rootString + id);



function [x] = colvec(x)
 if size(x,2) > size(x,1), x = x'; end;
 
