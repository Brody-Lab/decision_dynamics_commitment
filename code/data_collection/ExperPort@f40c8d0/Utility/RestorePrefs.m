function RestorePrefs(user)
% RESTOREPREFS(USER)
% Using builtin Matlab pref functions, restore saved preferences
% for the specified user
% See SAVEPREFS(USER)

% ZF MAINEN, CSHL, 1/01

global exper

% look at all the preferences
if ~ispref(user)
    return;
end

p = getpref(user);

pref = fieldnames(p);
% find preferences matching the user
for n=1:length(pref)
    [module param] = strtok(pref{n},'_');
    param = param(2:end);
    
    % set the preferences
    a = getpref(user,pref{n},'');
    if ~isempty(a) 
        if isstruct(a)
            fields = fieldnames(a);
            q=1;
            for i=1:length(fields)
                switch fields{i}
                case {'name','type','ui','h','trial'}
                    % don't restore these        
                otherwise
                    pairs{q} = fields{i};
                    pairs{q+1} = getfield(a,fields{i});
                    q = q+2;
                end
            end
            SetParam(module,param,pairs{:});
        else
            SetParam(module,param,a);
        end
    end
end