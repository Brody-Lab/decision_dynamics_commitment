function [] = blockmaker_check_block_and_tones
% puts a side list and tone list through SidesSEction correction battery
% and see if it needed any correction.
% If it did, the way the protocol made it probably wasn't correct.

global Solo_datadir;
indir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'orca' filesep];
load([indir 'blocktest_080918.mat']);

%bl = cell2mat(saved_history.BlocksSection_Blocks_Switch);
sl = saved.SidesSection_side_list;
tones = saved.ChordSection_tones_list;
flp = cell2mat(saved_history.ChordSection_right_is_low);

% these are set in the protocol >>
maxtrials = 1000;
starting_at = 5;
max_same_val = 3;
lprob_val = 0.5;
blocksize = 32;
% << ------------------------------

trials_left = (maxtrials-starting_at)+1;
blocks_left = round(floor(trials_left) / blocksize);
rem = trials_left - (blocks_left * blocksize);


% ------------------
% check goodness of each block
sidx = starting_at;
isgood = [];
badblock = {};
oldsum = [];
for idx=1:blocks_left
    eidx = (sidx+blocksize)-1;
    
    g= sub__checksides(sl(sidx:eidx), max_same_val, lprob_val);
    isgood = horzcat(isgood, g);
    oldsum = horzcat(oldsum, sum(sl(sidx:eidx)));
    
    if g == 0,
        badblock{end+1} = sl(sidx:eidx);
    end;

    sidx = eidx+1;
end;

% -------------------
% check that sides and tones match
sltmp = sl(starting_at:end);
ttmp = tones(starting_at:end);
flp = flp(end);

if flp > 0, isleft = 1; isright = 0; 
else isleft = 0; isright = 1; end; 

leftones =ttmp(sltmp == isleft);
rightones = ttmp(sltmp == isright);
figure;
plot(find(sltmp == isleft), leftones,'.b'); hold on;
plot(find(sltmp == isright), rightones, '.r');


2;

% ----------------------------------------------------------
% Subroutines

function [isgood] = sub__checksides(sl_sub, max_same_val, lprob_val)

myinput = sl_sub;
totalleft = sum(sl_sub);
tmptotal = 0;
no_change1=0; no_change2=0; no_change3=0;

[sl_sub, no_change1] = MaxSame_correction(sl_sub, max_same_val);
[sl_sub, no_change2] = correct_alternation(sl_sub, lprob_val, 5);   % HARDCODED value: Any block of alternation > 5 is considered a run
[sl_sub, no_change3] = correct_sidebias(sl_sub, lprob_val, 0.1, max_same_val);  % HARDCODED value: Lenience of 20%

tmptotal = sum(sl_sub);

if no_change1 && no_change2 && no_change3 %&& tmptotal == totalleft
    isgood = 1;
else
    isgood = 0;
end;

