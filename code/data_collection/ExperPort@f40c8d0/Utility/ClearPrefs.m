function ClearPrefs(user)
% CLEARPREFS(USER)
% Using builtin Matlab pref functions, clear saved preferences
% for the specified user
% See SAVEPREFS(USER), RESTOREPREFS(USER)

% ZF MAINEN, CSHL, 1/01

global exper

% look at all the preferences
p = getpref;
pref = fieldnames(p);
% find preferences matching the user
for n=1:length(pref)
    [prefuser module_param] = strtok(pref{n},'.');
    if strcmp(prefuser,user)
        % decompose pref into module, param
        [module param] = strtok(module_param,'.');
        param = strtok(param,'.');
    
        % clear the preferences
        rmpref(pref{n});
    end
end