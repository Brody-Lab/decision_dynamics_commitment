function [count, vals] = Counts(x, varargin)
    %[counts, vals] = Counts(x) 
    %return counts for each unique value of x
    %[counts, vals] = Counts(x, vals)
    %return counts for each value in vals. N.B. not a histogram, 
    % only counts exact matches
    % if x is a cell array of strings, vals is returns a cell array
    % if x is a cell array of numeric values, count returns a vector, with counts
    %  counts(1) is the number of unique elements. counts(2:n+1) is the count of unique values of
    %  the nth element of each element of x. 
    %Counts (x, 'decend') sorts results in descending order of count. So first
    %element of vals is the most commonn
    if isempty(x)
        count = [];
        if nargout>1
            vals  = NaN;
        end
        return;
    end
    if isempty(varargin) && isnumeric(x)
        x=x(:);
        if nargout>1
            [vals,tmp,uniqueIdx]=unique(x);
        else
            [tmp,tmp,uniqueIdx]=unique(x);
        end            
        count=accumarray(uniqueIdx,1);
        return
    elseif ~isempty(varargin) && isnumeric(varargin{1})
        x=x(:);
        vals = varargin{1};
        count = countvals(x,vals);
    elseif iscellstr(x) 
        vals = unique(x);
        for j = length(vals):-1:1
            count(j) = sum(strcmp(vals{j},x(:)));
        end        
    elseif iscell(x)
        for j = length(x):-1:1
            lens(j) = length(x{j});
            for k = length(x{j}):-1:1
                allvals(j,k) = x{j}(k);
            end
        end
        count(1) = length(unique(lens));
        if max(lens) > 1
            for j = size(allvals,2):-1:1
                count(j+1) = length(unique(allvals(:,j)));
                if nargout>1
                    vals{j} = unique(unique(allvals(:,j)));
                end
            end
        else %cell array but with single values
            vals = unique(cat(1,x{:})); %used to do this. but bad for
            count = countvals(x,vals);
        end
    else
        vals = unique(x);
        count = countvals(x,vals);    
    end
end

function count = countvals(x,vals)
    for j = length(vals):-1:1
        count(j) = sum(x(:) == vals(j));
    end  
end