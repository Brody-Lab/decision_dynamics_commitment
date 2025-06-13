function [] = SaveSettings(obj, interactive);

    GetSoloFunctionArgs;

    if nargin < 2, interactive = 1; commit = 0; else commit = 1; end;
   
    title = class(obj);
    if length(title>3) && strcmp(title(end-2:end), 'obj'), 
       title = [upper(title(1)) title(2:end-3)];
    end;
    prot_title.value = title;
    save_solouiparamvalues(RatName, ...
                           'interactive', interactive, 'commit', commit);
    