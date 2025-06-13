function pd = makeFieldLengthsUniform(pd)
    fieldnames = fields(pd);
    excludeFields = {'leftwatertime','rightwatertime'};
    fieldnames = fieldnames(~ismember(fieldnames,excludeFields));
    for f=1:length(fieldnames)
        fieldlengths(f) = length(pd.(fieldnames{f}));
    end
    minFieldLength = min(fieldlengths);
    if (mean(fieldlengths) - minFieldLength) > std(fieldlengths)*3
        warning('min field length is anomalously short.');
    end
    for f=1:length(fieldnames)
        pd.(fieldnames{f}) = pd.(fieldnames{f})(1:minFieldLength);
    end
end
