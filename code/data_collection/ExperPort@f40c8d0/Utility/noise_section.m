function [stm, endstate] = ...
    noise_section(stm,startstate,pokestate,donestate,BadBoySound,Len, ...
    bbln, bbsd, wnln, whsd)
%
% General:
% Given a state matrix (stm), creates a reinit-able penalty/ITI state. In
% case of reinitialisation, prefaces the penalty state with a
% 'BadBoySound'.
%
% Details:
% Pads with zeros up to startstate; then puts in a BadBoySound (if
% 'on'), followed by Len secs of white noise (Len must be a multiple of
% wnln). On poke, goes to pokestate; at end, goes to donestate. wnln is
% the length, in secs, of the white noise signal
%
% Params:
% bbln : bad boy length, in sec
% bbsd : trigger for bad boy sound (i.e., column 10 of stm
% wnln : white noise length in sec
% whsd : trigger for white noise

trg = get_generic('trigger_time');

% NOTE !!! Len must be a multiple of wnln !!!!
if ~is_multiple(Len, wnln)
    error('Len should be a multiple of wnln!');
end;

if strcmp(BadBoySound, 'off') && Len==0
    % There is nothing to do here-- go to your done state asap
    c = size(stm,1);
    stm = [stm ; ...
        c      c       c       c        c     c    donestate 0.001 0 0];
    endstate = c;
    return
end;

stm = [stm ; zeros(startstate-size(stm,1),10)];
b0 = pokestate; c = size(stm,1);
%if strcmp(BadBoySound, 'on')
if ~strcmp(BadBoySound, 'off')
    % Start with bad boy sound, then go to white noises..
    stm = [stm ; ...
        b0     b0      b0      b0       b0    b0      c+1      trg     0       0 ; ...
        b0     b0      b0      b0       b0    b0      c+2      bbln     0    bbsd];
end

% If done with the white noises, go to the done state
if Len==0, stm(end,7) = donestate; end

for i=1:Len/wnln
    c = size(stm, 1);
    stm = [stm ; ...
        b0    b0       b0      b0       b0    b0      c+1      trg     0       0 ; ...
        b0    b0       b0      b0       b0    b0      c+2      wnln     0    whsd];
    % If done with the white noises, go to the done state
    if i==Len/wnln, stm(end,7) = donestate; end
end;

endstate = c+1;
return