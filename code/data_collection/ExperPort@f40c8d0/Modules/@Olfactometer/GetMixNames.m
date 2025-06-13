% function [ mixes ] = GetMixNames( olf )
%
% Returns an array of strings, the name of all the mixes in this
% olfactometer.
%
function [ mixes ] = GetMixNames( olf )
    mixes = olf.mixes;