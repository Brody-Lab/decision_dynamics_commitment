function [] = remove_protocol_preferences(protname)

    prefs  = getpref('carlos');
    fnames = fieldnames(prefs);
    
    I = strmatch(protname, fnames);
    for i=1:length(I),
        fprintf(1, 'Removing %s\n', fnames{I(i)});
        rmpref('carlos', fnames{I(i)});    
    end;
    