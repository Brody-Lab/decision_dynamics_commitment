function [] = blockmaker_with_corrections


n2m = ones(8,1) * 4; %value(Num2Make);
blocksize = sum(n2m);
numbins = 8;
max_same_val = 3;
lprob_val = 0.5;

left_trials = sum(n2m(1:numbins/2));
right_trials = sum(n2m((numbins/2)+1:numbins));
block_sides = [ones(1,left_trials) zeros(1,right_trials)];

trials_left = 100000;
sl = NaN(trials_left,1);
blocks_left = round(floor(trials_left) / blocksize);
rem = trials_left - (blocks_left * blocksize);

sidx = 1;
% put in blocks for the sides list
numiter = []; % how many while loops does it take to find a correct side list?
tmtaken = [];
for idx=1:blocks_left
    eidx = (sidx+blocksize)-1;
    mix = randperm(blocksize);
    [sltmp n t]= sub__correctsides(block_sides(mix), max_same_val, lprob_val);
    sl(sidx:eidx) = sltmp;
    sidx = eidx+1;
    numiter = horzcat(numiter, n);
    tmtaken = horzcat(tmtaken, t);
    fprintf(1,'.');
end;

% fill in the remainder
mix = randperm(blocksize); tmp = block_sides(mix);
[sltmp n t]= sub__correctsides(tmp(1:rem), max_same_val, lprob_val);
sl(eidx+1:end) = sltmp;
numiter = horzcat(numiter, n);
tmtaken = horzcat(tmtaken, t);
fprintf(1,'\n');

% Now examine the generated blocks
sidx = 1;
for idx=1:blocks_left
    eidx = (sidx+blocksize)-1;
    currblock = sl(sidx:eidx);
    fprintf(1,'%i ', idx, sidx, eidx, sum(currblock));
        sidx = eidx+1;
    2;
end;
2;
fprintf(1,'\n');

% results from simulation
% run of session of 10,000 (3125 blocks)
% 1. All while loops terminated.
% 2. 73% of them took <50 iterations
% 3. 83% of them took <100 iterations
% 4. 97% of them took <200 iterations


function [sl_sub ctr tm] = sub__correctsides(sl_sub, max_same_val, lprob_val)

myinput = sl_sub;
totalleft = sum(sl_sub);
%fprintf(1,'%i ', totalleft);
tmptotal = 0;
no_change1=0; no_change2=0; no_change3=0;
ctr = 0;

tic
% sl_before = sl_sub;
while ~(no_change1 && no_change2 && no_change3) || (totalleft ~= tmptotal)
    mix = randperm(length(sl_sub)); sl_sub = sl_sub(mix);
    [sl_sub, no_change1] = MaxSame_correction(sl_sub, max_same_val);
    [sl_sub, no_change2] = correct_alternation(sl_sub, lprob_val, 5);   % HARDCODED value: Any block of alternation > 5 is considered a run
    [sl_sub, no_change3] = correct_sidebias(sl_sub, lprob_val, 0.1, max_same_val);  % HARDCODED value: Lenience of 20%

%     same_as_before = sum(abs(sl_sub - sl_before)) == 0;
%     sl_before = sl_sub;
    tmptotal = sum(sl_sub);
%      fprintf(1,'\t(%i,%i,%i) %i= %i)\n', no_change1, no_change2, no_change3, same_as_before, tmptotal);
 %   sl_sub
    ctr = ctr+1;
    if ctr > 200
        tm = toc;
        sl_sub = myinput; ctr = -1;
        return;
    end;
end;
    
tm = toc;

