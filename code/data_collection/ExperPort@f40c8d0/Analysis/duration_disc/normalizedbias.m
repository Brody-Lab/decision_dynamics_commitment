function [b] = normalizedbias(bins, mp, replongs, tallies)
% returns a bias value between -1 (all short/low responses) and +1 (all
% long/high responses)
% Bias defined as (H-L)/(H+L)
% Always says 'hi' = 1 ; Always says 'low' = -1 ; Perfectly balanced = 0.
%
% Precondition: bins must be arranged from smallest to largest. THis means
% that rats with flipped sides should have their side choices preflipped
% before this script is used.

if tallies < 20,
    2;
end;

if bins(1) > bins(2), error('Sorry, bins need to be rearranged');
end;

if rows(replongs)>1 && cols(replongs)>1, error('replongs should be  vector'); end;
if rows(tallies)>1 && cols(tallies)>1, error('replongs should be  vector'); end;

if rows(replongs)>1, replongs=replongs';end;
if rows(tallies)>1, tallies=tallies'; end;

sbins = bins < mp;

l = sum(tallies(sbins > 0)) - sum(replongs(sbins>0));
h = sum(replongs(sbins==0));
t = sum(tallies);
lfrac = l/t;
hfrac= h/t;

% b = (hfrac-lfrac)/(lfrac+hfrac)

% correct(sbins==1) = tallies(sbins==1) - replongs(sbins==1);

 h = sum(replongs);
 l = sum(tallies) - h; 
 b= (h-l)/(h+l);

