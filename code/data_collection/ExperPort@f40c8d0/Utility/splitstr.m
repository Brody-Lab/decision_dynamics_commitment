function out = splitstr(str, separator)
    sep_indices = strfind(str, separator);
    if ~isempty(sep_indices)
        out = cell(length(sep_indices)+1, 1);
        starting_index = 1;
        for ctr = 1:length(out)-1
            out{ctr} = str(starting_index:sep_indices(ctr)-1);
            starting_index = sep_indices(ctr)+length(separator);
        end
        out{ctr+1} = str(starting_index:end);
    else
        out = {str};
    end
end