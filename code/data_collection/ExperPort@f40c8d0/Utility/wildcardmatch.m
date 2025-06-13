function out = wildcardmatch(varargin)
%WILDCARDMATCH
%   e.g. out = wildcardmatch(str_wildcard, str);
%   e.g. out = wildcardmatch(str1, c1);
%   e.g. out = wildcardmatch(c1, c2);
%
%   e.g. out = wildcardmatch('#bi#row#ox', 'bigbrownfox') returns true
%   Matching can be done only for valid variable names
% Sundeep Tuteja.

if ischar(varargin{1}) && ischar(varargin{2})
    out = wildcardmatch_helper(varargin{1}, varargin{2});
elseif ischar(varargin{1}) && iscellstr(varargin{2})
    cellstr = varargin{2};
    out = false(length(cellstr), 1);
    for ctr = 1:length(cellstr)
        out(ctr, 1) = wildcardmatch_helper(varargin{1}, cellstr{ctr});
    end
elseif iscellstr(varargin{1}) && iscellstr(varargin{2})
    if ~isequal(length(varargin{1}), length(varargin{2}))
        error('Both arguments have to be equal in length');
    end
    cellstr1 = varargin{1};
    cellstr2 = varargin{2};
    out = false(length(cellstr1), 1);
    for ctr = 1:length(cellstr1)
        out(ctr, 1) = wildcardmatch_helper(cellstr1{ctr}, cellstr2{ctr});
    end
end

end


function out = wildcardmatch_helper(str1, str2)


if ~isvarname(str2) || ~isvarname(regexprep(str1, '#+', 'x'))
    error('Matching can be done only for valid variable names');
end


%Step 1:
str1 = regexprep(str1, '#+', '#');
str1_split = splitstr(str1, '#');

if length(str1_split)==1
    out = strcmp(str1_split{1}, str2);
    return;
end


out = true;

%Step 3: str1_split{1} should match right in the beginning. If it doesn't,
%out=false and return. Similarly, str1_split{end} should match right in the
%end.
if ~isempty(str1_split{1}) && isempty(regexp(str2, ['^' str1_split{1}], 'once'))
    out = false;
    return;
end
if ~isempty(str1_split{end}) && isempty(regexp(str2, [str1_split{end} '$'], 'once'))
    out = false;
    return;
end


old_strfind_index = -Inf;
for ctr = 2:length(str1_split)
    if isempty(str1_split{ctr})
        continue;
    end
    
    found_indices = strfind(str2, str1_split{ctr});
    found_indices = setdiff(found_indices, old_strfind_index);
    
    if ~any(found_indices > old_strfind_index + length(str1_split{ctr-1}) - 1)
        out = false;
        return;
    end
    
    old_strfind_index = min(found_indices);
end

end
