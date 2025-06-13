function output = remove_duplicate_lines2(input)

duplines = [];
for i = 1:length(input) - 1
    if strcmp(input{i},input{i+1}) && ~all(input{i} == ' '); duplines(end+1) = i+1; end %#ok<AGROW>
end

output = input;
output(duplines) = [];
            