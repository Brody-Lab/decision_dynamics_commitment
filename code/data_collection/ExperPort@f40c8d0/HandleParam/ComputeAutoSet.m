function [] = ComputeAutoSet
%
% Central function that computes all the autoset_strings of the
% SoloParamHandles, and updates SoloParamHandles accordingly.
%
% Goes through the set of SoloParamHandles that were registered with
% RegisterAutoSetParam. For each of these SPHs, the autoset_string is
% evaluated in a a context equal to that of the function in which the
% SPH was created-- that is, all the SPHs available there will be
% available here, with the caveat that they are all made available as
% read_only. The relevant function for context is obtained from the
% SPH's get_owner, get_name, and get_fullname. The SPH's value is then
% set to whatever the autoset_string evaluated to.
%
%    For efficiency, the SPHs are grouped into sets that share the same
% context. Within each set, strings for all SPHs are evaluated in
% parallel; after that, the new SPH values are set. The order in which
% function contexts are run through is the same as
% the order in which they were implicitly registered, through their
% variables, with RegisterAutoSetParam.
%


global private_autoset_list

if isempty(private_autoset_list), return; end;

for i=1:rows(private_autoset_list),
    mod = private_autoset_list{i,1};
    funclist = private_autoset_list{i, 2};
    for j=1:rows(funclist),
        param_list = funclist{j,2};
        autoset_string_list = cell(size(param_list));
        for k=1:length(param_list),
            autoset_string_list{k} = get_autoset_string(param_list{k});
        end;
        compute_new_values(mod, funclist{j,1}, param_list, autoset_string_list);

        %         for k=1:length(param_list)
        %             are_same = 0; oldval = value(param_list{k});
        %             try,
        %                 % Try executing as statement
        %                 try,
        %                     eval(private_autoset_strings{k});  % execute statement
        %                 catch,
        %                     error('Invalid syntax for ' get_name(param_list{k}));
        %                 end;
        %
        %                 % -----
        %
        %                 % true only if autoset_string is a statement
        %                 if ~(isstr(new_values{k}) && strcmp(new_values{k},autoset_string_list{k}))
        %                     if isstr(oldval),
        %                         are_same = strcmp(oldval, new_values{k}) || strcmp(oldval, post_execval);
        %                     else
        %                         are_same = (oldval == new_values{k});
        %                     end;
        %                 end;
        %                 % -----
        %             catch, % Oops, equals operator not defined. Will treat as if value
        %                 % had changed, for just in case (default are_same is 0).
        %             end;
        %             % If old and new vals are not the same, set val and call callback:
        %             if ~are_same,
        %                 % fprintf(1, 'Setting new val for %s\n', get_name(param_list{k}));
        %                 param_list{k}.value = new_values{k};
        %                 callback(param_list{k});
        %             end;
        %         end;
    end;
end;

% ----
function [] = compute_new_values(private_owner, ...
                                            private_funcname, ...
                                            private_varlist, ...
                                            private_autoset_strings);
    % Now go through new values, and if any value changed, set to new
    % value and go through the standard callback interface as if the
    % user had changed the value on the GUI.
    GetSoloFunctionArgs('func_owner',    private_owner, ...
        'func_name',     private_funcname, ...
        'all_read_only', 'on');

%    private_new_values = cell(size(private_autoset_strings));

    for private_i = 1:length(private_autoset_strings),
        try,
            % Try eval-ing autoset as a statement first
            oldval = value(private_varlist{private_i});
            % private_new_values{private_i} = ...
            eval([private_autoset_strings{private_i} ';']);    % Statement or value?
            newval = value(private_varlist{private_i});
            if isstr(oldval), are_same = strcmp(newval, oldval);         % value unchanged
            else are_same = newval == oldval;end;

            % If the value of the param did not change, the autoset string
            % is either not a statement, or it is a statement and the old
            % value is simply the same as the new value
            if are_same
                try,
                    testval = eval([private_autoset_strings{private_i} ';']);
                    % if we're still here, this is a value evaluation
                    if isstr(testval), are_same = strcmp(oldval, testval);
                    else are_same = (oldval == testval); end;
                    if ~are_same
                        private_varlist{private_i}.value = testval;
                        callback(private_varlist{private_i});
                    end;
                catch,
                end;
            else
                callback(private_varlist{private_i});
            end;
        catch,
            fprintf(1, ['\n\n ** Error evaluating an autoset_string-- value ' ...
                'not changed.\n\n']);
            fprintf(1, 'String: %s\n\n', private_autoset_strings{private_i});
            fprintf(1, 'Error: %s\n\n', lasterr);
    end;
end;
