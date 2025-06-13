function [] = see_autoset(ratname,date, fname)

fullname = '';

switch fname
    case 'vpd'
        fullname = 'VpdsSection_MaxValidPokeDur';
    case 'lprob'
        fullname = 'SidesSection_LeftProb';
    case 'bbspl'
        fullname = 'TimesSection_BadBoySPL';
    otherwise
        error('Invalid name');
end;
        

load_datafile(ratname,date);

2;
fnames =fieldnames(saved_autoset);
idx = -1;
idx = strmatch(fullname, fieldnames(saved_autoset));

if isempty(idx), fprintf(1,'No autoset string for %s', fullname); 
else
    fprintf(1,'Autoset for %s:\n%s\n', fullname, eval(['saved_autoset.' fullname]));
end;
 