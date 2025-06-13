% [sma]=StateMachineAssembler   An assembler for writing State Machine Matrices
%
% The StateMachineAssembler object is used to store State Machine matrix
% code (for the @RTLSM and the @SoftSMMarkII), as you build it; the code
% may have pointers and labels. Once completed, the assemble.m method
% disambiguates labels and builds a numeric state machine matrix. The
% send.m method assembles, calls the appropriate SetInputEvents.m,
% SetScheduledWaves.m, and SetOutputRouting.m for @RTLSM or @SoftSMMarkII,
% and then sends the assembled state matrix, ready for execution.
%
% See @StateMachineAssembler/Examples
%
% If StateMachineAssembler is passed an sma, returns it as is.
%
% If StateMachineAssembler is passed a struct, it tries to interpret it as
% a struct(sma), tries to revuild the sma as best it can, and returns that.
%

% Written by Carlos Brody October 2006; edited by Sebastien Awwad 2007,2008
% Additional Input lines added December 2012 CDB

function [sma] = StateMachineAssembler(varargin)
      
   if length(varargin)==1 && isa(varargin{1}, 'StateMachineAssembler'),
      sma = varargin{1};
      return;
   end;
   
   if length(varargin)==1 && isstruct(varargin{1}),
      % possibly a struct version of a previous version of
      % StateMachineAssembler. Let's try to reconstruct it as best we can. 
      
      sma_struct = varargin{1};
      varargin = varargin(2:end);
   else
      sma_struct = [];
   end;

      
   pairs = { ...
     'default_DOut'     0                 ; ...
     'default_happSpec' []                ; ...
     'use_happenings'   0                 ; ...
     'n_input_lines'    3                 ; ...
     'line_names'       'CLRABDEFGHIJKL'  ; ...
     'add_trialnum_indicator' 0           ; ...
     }; 
   singles = { ...
     'no_dead_time_technology',     'inputarg', 'no_dead_time_technology',     '' ; ...
     'standard_state35_technology', 'inputarg', 'standard_state35_technology', '' ; ...
     'full_trial_structure',        'inputarg', 'full_trial_structure',        '' ; ...
     };
   parseargs(varargin, pairs, singles);
   
   if n_input_lines ~= 3 && ~use_happenings,
       error('Can use n_input_lines different to 3 only if using happenings');   
   end;

   if isempty(default_happSpec) %#ok<*NODEF>
	   fnames     = {'name', 'detectorFunctionName', 'inputNumber', 'happId'};
	   happnames  = {'line_in', 'line_out', 'line_high', 'line_low'};
	   happabbrev = {'in', 'out', 'hi', 'lo'};
	   hid        = 0;
	   hs = {};
	   
	   for li = 1:3,
		   for hni = 1:2,
			   hid = hid + 1;
			   hs = [hs ; ...
				   {[line_names(li) happabbrev{hni}], happnames{hni}, li, hid}];
		   end;
	   end;
	   for li = 1:3,
		   for hni = 1:2,
			   hid = hid + 1;
			   hs = [hs ; ...
				   {[line_names(li) happabbrev{hni+2}], happnames{hni+2}, li, hid}];
		   end;
	   end;
	   
	   for li=4:n_input_lines,
		   for hni = 1:4,
			   hid = hid + 1;
			   hs = [hs ; ...
				   {[line_names(li) happabbrev{hni}], happnames{hni}, li, hid}];
		   end;	   
	   end;
       
       %Chuck's code to try to remap inputs
        inputs = bSettings('get','INPUTLINES','all');
        for i = 1:size(hs,1)
            inputnum = find(strcmp(inputs(:,1),hs{i,1}(1)) == 1,1,'first');
            if isempty(inputnum)
                error(['can''t find input channel ',hs{i,1}(1),' in INPUTLINES ']);
            elseif numel(inputnum) > 1
                error(['found more than one instance of input channel ',hs{i,1}(1),' in INPUTLINES ']);
            end
            
            hs{i,3} = inputs{inputnum,2};
        end
       %end Chuck's code
       
	   default_happSpec = cell2struct(hs, fnames, 2);
   end;

     
   if isempty(default_DOut),
     error('you passed in an empty matrix as a default_DOut -- can''t do that');
   end;
   if numel(default_DOut) ~= 1 || default_DOut ~= 0,
     % error('sorry, default_DOut different to zero not yet supported');
   end;
   
   ncols = 7;  % Keeping track of total number of state matrix columns
   input_line_names = line_names;
   default_input_map = cell(0, 2);
  for k=1:n_input_lines,
      if k > numel(input_line_names),
          error('Sorry, trying to have more input lines than I can handle!');
      end;
      default_input_map = [default_input_map ; ...
          {[input_line_names(k) 'in']  k*2-1     ; ...
           [input_line_names(k) 'out'] k*2       ; ...
           }];
   end;
   ncols = n_input_lines*2+1;
   default_input_map = [default_input_map ; {'Tup' ncols}];
   
   
   % default_input_map = { ...
%      'Cin'    1   ; ...
%      'Cout'   2   ; ...
%      'Lin'    3   ; ...
%      'Lout'   4   ; ...
%      'Rin'    5   ; ...
%      'Rout'   6   ; ...
%      'Tup'    ncols   ; ...
%    };

   default_self_timer_map = { ...
     'Timer'  ncols+1   ; ...
   };
   
   default_output_map = { ...
     'DOut'       ncols+2 ; ...
     'SoundOut'   ncols+3 ; ...
   };
   ncols = ncols+3;
   
   sma = struct( ...
	 'n_input_lines',       n_input_lines, ...
     'input_map',           {default_input_map},  ...
     'self_timer_map',      {default_self_timer_map},  ...
     'output_map',          {default_output_map}, ...
     'use_happenings',      use_happenings, ...
     'happSpec',            default_happSpec, ...
     'happList',            {cell(0, 1)},  ...
     'state_name_list',     {cell(0,3)},   ...
     'current_state',       0,             ...
     'states',              zeros(0, ncols),  ...
     'default_actions',     {cell(0, 1)},  ...
     'current_iti_state',   0,             ...
     'iti_states',          zeros(0, ncols),  ...
     'default_iti_actions', {cell(0, 1)},  ...
     'dio_sched_wave_cols', 8, ... 
     'sched_waves',         struct('name', {}, 'id', {}, 'in_column', {}, ...
                                   'out_column', {}, 'dio_line', {}, ...
                                   'preamble', {}, 'sustain', {}, ...
                                   'refraction', {}, 'sound_trig',{}, ...
                                   'loop', {}, ...
                                   'trigger_on_up', {}, 'untrigger_on_down', {}), ...
     'pre35_curr_state',   -1,             ...
     'default_DOut',        default_DOut,  ...   
     'full_trial_structure',             0, ...
     'prepare_next_trial_state_names',{{}}, ...
     'prepare_next_trial_states',       []  ...
...%     'globals',             '',             ... % <~> new RT system embedded c functionality
...%     'initfunc',            '',             ... % <~> new RT system embedded c functionality
...%     'cleanupfunc',         '',             ... % <~> new RT system embedded c functionality
...%     'transitionfunc',      '',             ... % <~> new RT system embedded c functionality
...%     'tickfunc',            '',             ... % <~> new RT system embedded c functionality
...%     'treshfunc',           '',             ... % <~> new RT system embedded c functionality
...%     'entryfuncs',          {cell(0,2)},    ... % <~> new RT system embedded c functionality
...%     'entrycode',           {cell(0,2)},    ... % <~> new RT system embedded c functionality
...%     'exitfuncs',           {cell(0,2)},    ... % <~> new RT system embedded c functionality
...%     'exitcode',            {cell(0,2)},    ... % <~> new RT system embedded c functionality
...%     'flagUsingEmbC',       false           ... % <~> flag specifying dependencies of this SMA object
   );
   
   if ~isempty(sma_struct)
      % possibly a struct version of a previous version of
      % StateMachineAssembler. Let's try to reconstruct it as best we can.

      old_fnames = fieldnames(sma_struct);
      for i=1:numel(old_fnames),
         if isfield(sma, old_fnames{i}),
            sma.(old_fnames{i}) = sma_struct.(old_fnames{i});
         end;
      end;
      
      sma = class(sma, 'StateMachineAssembler');
      return;
   end;


   sma = class(sma, 'StateMachineAssembler');
   
   if ischar(inputarg),
      switch inputarg,
        case '',
       
        case 'no_dead_time_technology',
          sma = initialize_no_dead_time_structure(sma);
         
        case 'full_trial_structure',
          sma = initialize_full_trial_structure(sma);
          
        case 'standard_state35_technology'
          error(sprintf(['Sorry, standard_state35_technology not ' ...
            'implemented yet. Use no_dead_time_technology.\n']));
          % sma = initialize_standard_state35_structure(sma);
        otherwise,
         error(sprintf(['Don''t know this flag for creating a ' ...
           'StateMachineAssembler object: %s\n'], inputarg));
      end;
   end;
   
   try
       %make the first state one that flashes the sync LED connected to center1water
       sma = add_sync_flash_state(sma);
   catch
       disp('ERROR adding sync flash state');
   end
   
      try
        if add_trialnum_indicator > 0 
            if bSettings('get','RIGS','bpod') == 1 
                sma = add_trialnum_indicator_bpod(sma,add_trialnum_indicator);
            else
                disp('Cannot add trialnum this way for non-bpod rigs or trial 0')
            end
        end
      catch
          disp('ERROR: trialnum states not added');
      end
   
   return;
   
   