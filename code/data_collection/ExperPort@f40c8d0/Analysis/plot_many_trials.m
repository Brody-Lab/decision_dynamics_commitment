% [tids]=plot_many_trials(evs,RTS,bh,alignon,ax)  show states/pokes sequence
%
% Plots a set of colored patches and lines that indicate a sequence of
% states and pokes during each trial. This is done not on the current
% axes, but on the axes passed by 'ax' (which are never made current).
%
% RETURNS:
% -------
%
% tids         doubles column vector, containing the trial numbers that
%              are plotted after selection.
%
% PARAMETERS:
% -----------
%
% evs          An ntrials-by-1 cell vector. The first element of this
%              vector is trial 1; subsequent elements are subsequent
%              trials. Each element must be n-by-3 matrix indicating, in
%              its first column, state numbers, in its second column the
%              event by which the state in that row was exited, and in the
%              third column the time at which the event occurred.
%
% RTS          An ntrials-by-1 cell vector. Each element must be a
%              structure, each entry of which indicates a set of state id
%              numbers. The corresponding fieldname gives these state IDs
%              meaning. For example, 
%                 RTS.wait_for_cpoke = [40 41] means
%              that states 40 and 41 are 'wait_for_cpoke' states.
%
% bh           The patches to be drawn start at vertical position bh (for
%              (base height), and extend vertically to bh+1+trialnum.
%
% alignon      A string indicating what to take as t=0 in the
%              trial. Current possibilities are: 'base state'  
%              '1st Cpoke'  'wait_for_apoke'   'Outcome', and any
%              evaluatable string based on Rea-Time-States (e.g.,
%              'wait_for_cpoke(end,1)', which would mean the start of
%              the last wait_for_cpoke state.
%
% ax           Handle to graphics axes on which all of this will be drawn.
%

% DOCUMENT THE VARARGINS !!!



function [tids] = plot_many_trials(cell_evs, cell_RTS, bh,alignon,ax,varargin)

   tids = [];
   
   pairs = { ... 
     'trial_types'        []   ; ...
     'trial_selection'    []   ; ...
     'trial_selector'     ''   ; ...
     'collapse_selection'  0   ; ...
     'custom_colors'      []   ; ...
     'plottables'         []   ; ...
     'YLim'               []   ; ...    
     'TLim'               []   ; ...    
     'pstruct'            []   ; ...
   }; parseargs(varargin, pairs);

   
   if ~iscell(cell_evs) | size(cell_evs,2)>1, 
      error('Expecting ntrials-by-1 cells for evs and RTS');
   elseif ~all(size(cell_evs)==size(cell_RTS)),
      error('evs and RTS should be the same size');
   end;
   
   if isempty(cell_evs), return; end;
   if isempty(pstruct), pstruct = parse_trial(cell_evs, cell_RTS); 
   elseif ~iscell(pstruct) || ~all(size(pstruct)==size(cell_evs)),
         error(['if pstruct is passed, it must be a cell the same size ' ...
                'as cell_evs']);
   end;

   % Avoid crashes by making sure trial_types{trial} always exists,
   % even if empty:
   if isempty(trial_types), trial_types = cell(size(cell_evs)); end;
   
   % If necessary, translate from old-style alignon menu to new style:
   alignon = backwards_compatible_alignon(alignon);
   
   EventIds = struct( ...
     'cin',   1,  'cout',   2,  ...
     'lin',   3,  'lout',   4,  ...
     'rin',   5,  'rout',   6,  ...
     'tup',   7);

   if isempty(custom_colors)
       state_colors; % This script determines vars "plottables" and "SC"
   else
       SC = custom_colors;
       if isempty(plottables), 
           error('When custom state colours are provided, custom plottables must be, too!');
       end;
   end;   
   
   % Make three structures that will contain the X, Y, and color for
   % each color type of state patch.
   fillables_X = SC;
   fillables_Y = SC;
   fillables_c = SC;
   for i=1:size(plottables,1),
      fillables_X.(plottables{i,1}) = [];
      fillables_Y.(plottables{i,1}) = [];
      fillables_C.(plottables{i,1}) = [];
   end;

   cell_t0 = cell(size(cell_evs));

   for trial = 1:length(cell_evs),
      evs = cell_evs{trial}; RTS = cell_RTS{trial}; doit = 1;
      if ~isempty(trial_selection) && ~isempty(trial_types{trial}), 
         % Check whether trial_selection allows us to do this trial
         doit = evaluate_trial(trial_types{trial}, trial_selection);
      end;
      if ~isempty(trial_selector)  &&  isempty(trial_types{trial}), 
         doit = doit & selectize(pstruct{trial}, trial_selector);
      elseif ~isempty(trial_selector)  &&  ~isempty(trial_types{trial}), 
         doit = doit & ...
                selectize(pstruct{trial}, trial_selector, trial_types{trial});
      end;
      cell_t0{trial} = [];
      if doit & ~isempty(evs),
         try,   
            cell_t0{trial} = eval(['pstruct{trial}.' alignon]);
            if any(size(cell_t0{trial})>1), ...
                 cell_t0{trial} = cell_t0{trial}(1);
            end;
         catch,
         end;
      end;
   end;

   % Loop through all trials, collecting data for the state patches
   n_plotted = 0;
   for trial = 1:length(cell_evs),
      evs = cell_evs{trial}; RTS = cell_RTS{trial}; t0 = cell_t0{trial};
      if ~collapse_selection, n_plotted = n_plotted + 1; end;

      if ~isempty(t0), 
         if collapse_selection, n_plotted = n_plotted + 1; end;
         tids = [tids ; trial];
         
         for i=1:size(plottables,1),
             X = []; Y = []; 
             start_stop = pstruct{trial}.(plottables{i,1});
             for j=1:rows(start_stop),
                 X = [X start_stop(j,[1 1 2 2])'-t0];
                 Y = [Y bh+n_plotted-1 + [0.05 0.95 0.95 0.05]'];
             end;
            color = SC.(plottables{i,1});
            if ~isempty(X),
               fillables_X.(plottables{i,1})=[fillables_X.(plottables{i,1}) X];
               fillables_Y.(plottables{i,1})=[fillables_Y.(plottables{i,1}) Y];
               fillables_c.(plottables{i,1})=color;
            end;
         end;         
      end;
   end;
   % Now plot all the state patches
   str = []; for i=1:size(plottables,1),
     %       fill(fillables_X.(plottables{i,1}), fillables_Y.(plottables{i,1}), ...
     %            fillables_c.(plottables{i,1}), 'EdgeColor', 'none', 'Parent', ax);
     str = sprintf(['%s fillables_X.(plottables{%d,1}), ' ...
       'fillables_Y.(plottables{%d,1}), fillables_c.(plottables{%d,1}),'], str, i, i, i);
   end;
   if i>0,
     str = sprintf(['fill(%s ''EdgeColor'', ''none'', ''Parent'', ax);'], str);
     eval(str);
   end;

   % Loop through all trials, plotting poke lines on top of the state patches
   n_plotted = 0;
   for trial = 1:length(cell_evs),
      evs = cell_evs{trial}; t0 = cell_t0{trial};
      if ~collapse_selection, n_plotted = n_plotted + 1; end;

      if ~isempty(t0), 
         if collapse_selection, n_plotted = n_plotted + 1; end;

         guys = pstruct{trial}.left1' - t0; 
         l = line(guys, 0.8+(bh+n_plotted-1)*ones(size(guys)), 'Parent', ax);
         set(l, 'Color', 0.6*[1 0.66 0], 'LineWidth', 4);

         guys = pstruct{trial}.center1' - t0; 
         l = line(guys, 0.5+(bh+n_plotted-1)*ones(size(guys)), 'Parent', ax);
         set(l, 'Color', 0.0*[1 0.66 0], 'LineWidth', 4);

         guys = pstruct{trial}.right1' - t0; 
         l = line(guys, 0.2+(bh+n_plotted-1)*ones(size(guys)), 'Parent', ax);
         set(l, 'Color', 0.9*[1 0.66 0], 'LineWidth', 4);
      end;
   end;

   % Ensure that YLim range is bigger than zero:
   if n_plotted == 0, n_plotted = 1; end;

   if collapse_selection | isempty(YLim), 
      set(ax, 'YLim', [bh bh+n_plotted]);
   else
      set(ax, 'YLim', YLim);
   end;
   if ~isempty(TLim), set(ax, 'XLim', TLim); end;
   
   return;
   

% -------------   
   
function [private_doit] = evaluate_trial(trial_types, trial_selection)
   
   try, 
      private_doit = eval(trial_selection); 
   catch, 
      private_doit = 1; 
      fprintf(1, ['\n\n ** Warning **\n\nString %s couldn''t be ' ...
                  'evaluated.\n\n'], trial_selection); 
   end;
      
   
   
% -------------


function [alignon] = backwards_compatible_alignon(alignon)
   
   switch alignon,
    case 'base state',     alignon = 'wait_for_cpoke(1,1)';         
    case '1st Cpoke',      alignon = 'center1(1,1)'; 
    case 'wait_for_apoke', alignon = 'wait_for_apoke(1,1)';
    case 'wait_for_cpoke', alignon = 'wait_for_cpoke(end,2)';
    case 'Outcome',        alignon = 'wait_for_apoke(end,2)';
    case 'Outcome End',    alignon = 'hit_state(end,2)';
    case '1st Side poke',
      fprintf(1, ['\n\n *** Sorry ! *** \n\n1st Side poke no longer ' ...
                  'supported in alignon; will do Outcome instead\n\n']);      
      alignon = 'wait_for_apoke(end,2)';
   end;
   