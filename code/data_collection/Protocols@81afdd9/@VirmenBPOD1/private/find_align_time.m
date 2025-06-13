% [a] = find_align_time(alignstr, parsed_events)    
%
%     Given an event (format below) and a representation of the events from
%       a trial (as returned by disassembler.m), returns the time that the
%       event occurred, in seconds since the start of the experiment.
%
%     This information is used to align the pokes plot, but can be used for
%       other purposes and should probably be moved somewhere more
%       convenient.
%
%     Possible events:
%
%       - the Nth poke in or poke out of a specified poke in this trial
%       - the Nth entry into or exit from a specified state in this trial
%
%     
%     The event is specified with a string of the form:
%
%           pokes.whichpoke(N,pole)
%       or  states.statename(N,pole)
%       or  statename(N,pole)           (abbreviated form of previous)
%
%       where:
%           N     indicates which occurrence of the event within the trial
%           pole  indicates entry into (1) or exit from (2 or end) the
%                   poke/state
%
% If the initial 'states.' or 'pokes.' is missing, then find_align_time
% will behave as if a 'states.' had been provided (i.e., states is default)
%
%
%     Details: --------------------
%
%     parsed_events (pe) has the simple structure:
%
%           pe.states.statename = [ t_entry_1,  t_exit_1;   ...
%                                   t_entry_2,  t_exit_2;   ...
%                                   t_entry_3,  t_exit_3;   ... etc.]
%           pe.pokes.whichpoke  = [ t_pokein_1, t_pokeout_1 ...
%                                   t_pokein_2, t_pokeout_2 ... etc.
%       
%     The format used for the alignon string is exactly the same as that
%       which would address the times in the matrices in that struct.
%
function [private_a] = find_align_time(alignstr, parsed_events)

try
   private_a= NaN;
   
   arithchars = '()+-/*.><=&|~^,';

   u = find(alignstr == '(');   if isempty(u),       return; end;
   myfield   = alignstr(1:u-1); if isempty(myfield), return; end;
   postparen = alignstr(u:end);
   
   u = find(alignstr == '.', 1, 'first'); 
   if isempty(u), atype = 'states'; 
   else           atype = myfield(1:u-1); myfield = myfield(u+1:end);
   end;
   if isempty(atype) || isempty(myfield),            return; end;
   if ~ismember(atype, {'states' 'pokes'}),          return; end;
   
   if ~isfield(parsed_events.(atype), myfield),      return; end;
   if isempty(parsed_events.(atype).(myfield)),      return; end;
   
   myguys = parsed_events.(atype).(myfield); %#ok<NASGU> (This line OK.)
   

   private_a = eval(['myguys' postparen ';']);

catch
  pk = parsed_events.pokes; %#ok<NASGU>
  ps = parsed_events.states; %#ok<NASGU>
  
  eval([alignstr ';']);
  if exist('this_trial', 'var'),
    private_a = this_trial;
  else
    fprintf(1, ['\nWARNING -- if you''re not using simple pokes or states ' ...
      'in the alignon, you need to set a variable called "this_trial" ' ...
      'that defines the align point']);
    private_a = NaN;    
  end;
end;
   
   

