function [obj] = sessionmodel2(varargin)
%SESSIONMODEL2 Constructor for the sessionmodel2 plugin
%   Inherits from the saveload plugin
%
%   See also 
%    - SESSIONMODEL2/CREATEHELPERVAR
%    - SESSIONMODEL2/SESSIONDEFINITION
%	 - SESSIONMODEL2/CLEARHELPERVARSNOTOWNED
%
%   Author: Sundeep Tuteja
%           sundeeptuteja@gmail.com

obj = class(struct, mfilename, saveload);