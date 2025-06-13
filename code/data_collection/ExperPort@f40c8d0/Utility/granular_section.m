
% ----- GRANULAR STATE

function [stm, donestate] = ...
    granular_section(start, penalty_state, timelength, granularity, legalskipout, initial_trigger)

if nargin < 6, initial_trigger = 0; end;

if legalskipout == 0,
    ps = penalty_state;
    stm = [start ps   ps ps   ps ps   start+1 timelength    0 initial_trigger];
    donestate = start+1;
    return;
end;

% e.g. of how this works
% if timelength is 150ms, granularity 25ms, legalskipout 75ms
% full_reg_units = 6 = nreg_states
% full_legal_units = 3 = nlegal_states
% stm will have the following states:
% r1  [ (this_state) r1+1 ps ps ps ps r2 25 ]
%    l1_1 [ r1 (this_state) ps ps ps ps l1_2 25 ]
%    l1_2 [ r1 (this_state) ps ps ps ps l1_3 25 ]
%    l1_3 [ r1 ps ps ps ps ps l1_4 25 ]
% r2  [ (this state) r2+1 ps ps ps ps r3 25]
% l2_1 - l2_3 like l1_1 - l1_3
% r3  [ (this_state) r3+1 ps ps ps ps ds 25 ]
% l3_1 - l3_3 like l1_3 - l1_3
%


full_reg_units   = floor(timelength/granularity);
last_reg_unit    = timelength - granularity*full_reg_units;
if last_reg_unit < 0, last_reg_unit = 0; end;
last_reg_unit    = floor(last_reg_unit*10000)/10000;  % do away with rounding errors
if last_reg_unit > 0, nreg_states = full_reg_units+1;
else                  nreg_states = full_reg_units;
end;

full_legal_units = floor(legalskipout/granularity);
last_legal_unit  = legalskipout - granularity*full_legal_units;
last_legal_unit  = floor(last_legal_unit*10000)/10000;  % do away with rounding errors
if last_legal_unit > 0, nlegal_states = full_legal_units+1;
else                    nlegal_states = full_legal_units;
end;

ps = penalty_state;

if nreg_states > 0
    ds = start + (nreg_states-1)*(nlegal_states+1) + 1;
else
    ds = start + 1;
end;
donestate = ds;

stm = [];

for i=1:nreg_states-1,
    b = start + size(stm,1);
    stm = [stm ;
        b  b+1    ps  ps   ps  ps    b+nlegal_states+1    granularity  0  0];  % add nreg unit's STM
    % Note: This is a mini state of unit granularity.

    for j=1:nlegal_states-1 % The regular-sized legal poke-out states
        pokeback = start + (j-1)*(nlegal_states+1) + (i-1)*(nlegal_states+1);
        if pokeback <= start + (nreg_states-1)*(nlegal_states-1) % take care of timelength constraint
            stm = [stm ;
                pokeback  b+j   ps  ps    ps  ps    b+j+1    granularity  0  0];
        else % We're done here-- but must end with poke back in!
            stm = [stm ; ds b+j   b+j b+j   b+j b+j   b+j+1 granularity  0 0];
        end;
    end;

    if last_legal_unit == 0, last_legal_time = granularity; % The final, leftovers legal poke-out state
    else                     last_legal_time = last_legal_unit;
    end;

    pokeback = start + (nlegal_states-1)*(nlegal_states+1);
    if pokeback <= start + (nreg_states-1)*(nlegal_states-1)
        stm = [stm ;
            pokeback  ps   ps  ps    ps  ps    ps  last_legal_unit  0  0];
    else % We're done here-- but must end with poke back in!
        b = start + size(stm,1);
        stm = [stm ; ds b   b b   b b   ps last_legal_unit  0 0];
    end;
end;
if last_reg_unit == 0, last_reg_unit = granularity; end;
b = start + size(stm,1);
stm = [stm ;
    b ps   b b   b b   ds last_reg_unit  0  0];


stm(1,10) = initial_trigger;
return;

