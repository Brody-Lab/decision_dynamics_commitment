% 
% GETTING DATA FILES
% load_datafile: Loads the data file of a given rat, task, date, and
%                file version ("a","b") 
%
% available_dates: Returns the dates for which data for a given
%                  rat/task combination are available on the current
%                  computer  
%
% parse_filename:  Given a filename in standard convention, breaks it
%                  down into directory, ratname, task, date, and
%                  extension. 
% 
% EXAMINING DATA FILES
% get_method_fieldnames: Returns the fieldnames associated with a method (e.g. ChordSection, VpdsSection) (needs a "saved" struct)
%  
% SEPARATING AND ANALYSING TASK SWITCHING
% get_task_switches: Indicates trials where task was switched
% make_chunks: Returns indices of PD and DD in a block-by-block manner (used with get_task_switches)
% indicate_pd_dd_trials: Marks each trial as being either pitch or duration discrimination.
% separate_pd_dd_trials: Special version of indicate_pd_dd_trials, used by dual_runner to plot performance during task-switching sessions
% 
% EVENT ANALYSIS
% Tools in Analysis/
% parse_trials: Gets start/end times for all states and poke events on trial-by-trial basis
% get_state_name: Resolves an array of state numbers into state descriptions (dead_time, wait_for_apoke, etc.,)
% get_trial_events: Given a saved_history vector, returns the events and
%   state name-to-number mappings for a single trial
%
% Tools for analysis in: Analysis/Event_Analysis/
%
% General
% --------
%  get_pokes_rel_timepoint: Get left/center/right/all pokes before or after a fixed time (e.g. 23.432)
%  get_pokes_fancy: Same thing as get_pokes_rel_timepoints but allows filtering by multiple conditions and conjunction or disjunction of these conditions
%  get_correct_side: Gets correct sides for each trial in binary array (1=left, 0=right)
%  multiple_timeouts: Gets trials with specified ranges of timeouts
% 
% A little fancier but still general:
% -----------------------------------
%  apoke_during_timeout: Gets trials where left or right poke occurred during timeout
%  correct_poke_during_timeout: Gets trials where animal timed out and then make correct left or right poke
%  timeout_aggregator: Returns sum of all timeouts associated with each sound event (e.g. as defined in timeout_distribution_dual)
% 
% Protocol-specific; may be copied and modified for other protocols:
% ------------------------------------------------------------------
% parse_sound_evs_dual: Gets start/end times for all sounds where timeout may occur (e.g. pre_sound, cue, pre_go)
% timeout_distribution_dual: Counts timeouts occurring in all "sound events" as defined by parse_sound_evs_dual
% 
