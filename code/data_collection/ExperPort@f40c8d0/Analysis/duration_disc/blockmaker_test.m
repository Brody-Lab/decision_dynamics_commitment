function [] = blockmaker_test
binmin=200;
binmax=500;
numbins=8;

blocksize=32;
sl = [ones(blocksize/2,1) zeros(blocksize/2,1)];
sl = sl(randperm(blocksize));


bins = generate_bins(binmin, binmax, numbins,'pitches',0);
logbins = log(bins);logmin = log(binmin);
logmax =log(binmax);

n2m = ones(blocksize/4,1) * 4;

bk=sub__block_maker(logmin,logmax, logbins, n2m,sl);
figure;hist(bk,log(bins));

% generates tones for a given block
function [final_block] = sub__block_maker(logmin,logmax, logbins, n2m,sl)

numbins= length(logbins);
block_tones = [];

% make the tones to be presented in the block
for idx=1:numbins
    if idx == 1, bin_from = logmin;
    else bin_from = (logbins(idx-1)+logbins(idx))/2; end;

    if idx == numbins, bin_to = logmax;
    else bin_to = (logbins(idx)+logbins(idx+1))/2; end;

    new_tones = (rand(1,n2m(idx)) * (bin_to - bin_from) ) + bin_from;
    block_tones = horzcat(block_tones, new_tones);
end;

% now permute the tones.
left_trials = sum(n2m(1:numbins/2));
right_trials = sum(n2m((numbins/2)+1:numbins));

left_tones = block_tones(1:left_trials);
mix = randperm(length(left_tones));
left_tones = left_tones(mix);

right_tones = block_tones(left_trials+1:end);
mix = randperm(length(right_tones));
right_tones = right_tones(mix);

% now stitch the mixed tones together using the mixed sides list
final_block = zeros(size(sl));
final_block(find(sl > 0)) = left_tones(1:length(find(sl>0)));
final_block(find(sl==0)) = right_tones(1:length(find(sl==0)));
