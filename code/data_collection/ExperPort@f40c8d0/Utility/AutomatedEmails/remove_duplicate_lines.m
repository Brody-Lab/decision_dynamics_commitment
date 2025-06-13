function output = remove_duplicate_lines(input)

duplines = [];
for i = 1:length(input) - 1
    if all(input{i} == ' '); continue; end
    for j = i+1:length(input)
        if length(input{i}) == length(input{j}) && all(input{i} == input{j})
            duplines(end+1) = j; %#ok<AGROW>
        end
    end
end

duplines = unique(duplines);
output = input;
output(duplines) = [];
            