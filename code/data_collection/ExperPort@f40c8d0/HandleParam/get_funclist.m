% [funclist] = get_funclist(param_owner)     
%
% Get a list of all functions that can own SoloParamHandles for a particular
% function-owning object. Also returns all the SoloParamHandles-- so use
% with care!
%
% PARAMETERS:
% -----------
%
% param_owner   The owner of functions that we are considering. Typically an
%               object, e.g., a protocol object. Can also be a string, in
%               which case it should be of the form '@ObjectClassName'.
%
% RETURNS:
% --------
%
% funclist     An n-by-3 cell, where each row corresponds to the name of a 
%              method of param_owner. The first column is a string with the
%              full function name. The second column is an n-by-2 cell, where 
%              each row is a read-write SoloParamHandles, that the function
%              has access to (first column is SPH name, second is the SPH
%              itself). The third column in funclist is an m-by-2 cell,
%              where each row is a read-only SoloParamHandle that the
%              function has access to (first col is SPH name, second is SPH
%              itself).
%
% EXAMPLES:
% --------
%
% These two produce the same output:
%
%   >> flist = get_funclist(SameDifferent)
%
%   >> flist = get_funclist('@SameDifferent')
%
%

function [funclist] = get_funclist(param_owner)

if isobject(param_owner), param_owner = ['@' class(param_owner)]; end;

[modid, funclist] = find_modules_funclist(param_owner);