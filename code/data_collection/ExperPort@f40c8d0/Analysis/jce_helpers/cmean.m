function y = cmean(x,dim)
%MEAN   Average or mean value.
% EDITED by JCE on Jan 22, 2007.  Now calls nanmean by default and will
% take the mean of 
%   For vectors, MEAN(X) is the mean value of the elements in X. For
%   matrices, MEAN(X) is a row vector containing the mean value of
%   each column.  For N-D arrays, MEAN(X) is the mean value of the
%   elements along the first non-singleton dimension of X.
%
%   MEAN(X,DIM) takes the mean along the dimension DIM of X.
%
%   Example: If X = [0 1 2
%                    3 4 5]
%
%   then mean(X,1) is [1.5 2.5 3.5] and mean(X,2) is [1
%                                                     4]
%
%   Class support for input X:
%      float: double, single
%
%   See also MEDIAN, STD, MIN, MAX, VAR, COV, MODE.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision$  $Date$

if nargin==1
    
    if iscell(x)
        for xi=1:numel(x)
         t{xi}=cmean(x{xi});
        end
        try
            y=cell2mat(t);
        catch
            y=t;
        end
    else %not a cell and no dim
    dim = min(find(size(x)~=1));
        if isempty(dim), dim = 1; end
        y=nanmean(x, dim);
    end
else


if iscell(x)
    for xi=1:numel(x)
        t{xi}=cmean(x{xi},dim);
    end
    try
        y=cell2mat(t);
    catch
        y=t;
    end
else% Determine which dimension SUM will use

        y = nanmean(x,dim);
end
end