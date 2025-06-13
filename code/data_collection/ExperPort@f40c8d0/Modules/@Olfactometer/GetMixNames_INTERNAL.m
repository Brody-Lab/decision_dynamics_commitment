% function [ mixes ] = GetMixNames_INTERNAL( olf )
%   Internal to olfactometer -- Returns an array of strings, the name of all the mixes
function [ mixes ] = GetMixNames_INTERNAL( olf )
    line = DoQueryCmd(olf, sprintf('GET MIXES'));
    mixes = {};
    while(1), 
        [ mix, line ] = strtok(line);
        if (isempty(mix)), break; end;
        mixes = vertcat(mixes, cellstr([mix]));
    end;
