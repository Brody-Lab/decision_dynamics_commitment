% This directory contains verious miscellany functions that are useful
% in general, not just for protocol writing. They don't depend on the
% Solo system at all.
%
%
% MATRIX MANIPULATIONS:
% ---------------------
%
% cols            get the number of columns of a cell or matrix
% rows            get the number of rows of a cell or matrix
% rowvec          resize argument into a single row vector.
%
%
%
% GRAPHICS:
% ---------
%
% set_size        Set the width and height of a graphics object without
%                 changing its lower left hand corner position
%
%
% CELL MANIPULATIONS:
% -------------------
%
% cell2num        Superseded by Matlab's built-in cell2mat
% sortcell        Sorts cell arrays, by rows. Elements of the cell may
%                 be scalar numbers or strings
% uniquecell      Find unique, sorted rows, of a cell array. Elements
%                 of the cell may be scalar numbers or strings.
% uniquecell_nonsquare    Like uniquecell, but may be used when some
%                 elements in the cell are empty. 