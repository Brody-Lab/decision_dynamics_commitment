% [] = initialize_trial(trialnum, parsed_events, my_state_colors, alignon, (sph)trial_info);
%
% 
% initializes info for trial entirely unplotted so far. Doesn't erase any
% graphics. Expects my_state_colors to be a structure with two fields
% ('states' and 'pokes'), the entries for which are also structures.
%

function [] = initialize_trial(trialnum, parsed_events, my_state_colors, alignon, trial_info)

   % Make local version of trial_info(trialnum) for speed:
   this_info = trial_info([]);
   % First assignment to this_info needs the (1) to make sure it has space
   % allocated for it.
   this_info(1).start_time   = parsed_events.states.state_0(1,2);
   atime = find_align_time(alignon, parsed_events);
   this_info.align_time   = atime;
   if isnan(this_info.align_time),
     this_info.align_found = 0;
     this_info.align_time  = this_info.start_time;
   else
     this_info.align_found = 1;
   end;
   
   % mainsort is used to group trials into blocks with all the same value:
   this_info.mainsort_value = 0;
   this_info.subsort_value  = trialnum;
   
   % Initialize structure holding all patch handles with fieldnames for each plottable state

   this_info.ghandles = struct('states', [], 'pokes', [], 'spikes', []);
   fnames = fieldnames(my_state_colors.states);
   this_info.ghandles.states  = cell2struct(cell(size(fnames)), fnames, 1);
   fnames = fieldnames(my_state_colors.pokes);
   this_info.ghandles.pokes   = cell2struct(cell(size(fnames)), fnames, 1);
   this_info.ghandles.spikes  = [];
   
   trial_info(trialnum) = this_info; %#ok<NASGU>
