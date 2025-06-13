function out = eval_pokesplot_expression(obj, str, trialnum, varargin)
%EVAL_POKESPLOT_EXPRESSION: Evaluates a MATLAB expression specially for
%pokesplot2. These expressions are normally to be evaluated for every trial.
%
%   SYNTAX: OUT = EVAL_POKESPLOT_EXPRESSION(OBJ, STR, TRIALNUM)
%
%   OBJ: Protocol Object.
%
%   TRIALNUM: Trial number
%
%   STR: Formatted string that has to be passed. See examples in
%   PokesPlotSection to see how the formatting has to be done. Certain
%   shortcuts and reserved words exist.
%
%   Shortcuts: ps: parsed_events_history{trialnum}.states
%              pk: parsed_events_history{trialnum}.pokes
%              pw: parsed_events_history{trialnum}.waves
%              pspk: parsed_events_history{trialnum}.spikes
%              pd: protocol_data from the sessions table (available only if
%              bdata has been set up, and only while viewing historical
%              data, empty otherwise)
%
%   Reserved words/keywords
%    - All variable names of variables instantiated by GetSoloFunctionArgs
%    - out, str: DO NOT MODIFY THESE VARIABLES!!!
%    - obj: Protocol object (do not modify)
%    - trial_info: A read-only version of the trial_info SoloParamHandle is
%    available to all pokesplot expressions
%    - trialnum: Available to all pokesplot expressions, denoting the trial
%    number for which the expression is being evaluated.
%    - this_trial: If the expression is complicated, it might be more practical
%    to have the evaluated value stored in the this_trial variable. If this
%    variable exists, its value will be the value returned.
%    - randstring, isalnum: Internal functions
%
%   LIMITATIONS:
%   - Do not define functions in any of the pokesplot expression edit
%   windows. If necessary, define functions externally.
%
%   WILDCARDS:
%   A new feature in pokesplot2 is the ability to incorporate wildcards in pokesplot
%   expressions. The wildcard #, when used to represent a state name, poke
%   name, or wave name, or a group of state names, poke names, or wave
%   names, denotes zero or more characters. Wildcards may be used only to
%   identify states, pokes, and waves, and must be used with the shortcuts
%   ps, pk, and pw respectively. The function wildcardmatch is used to
%   perform the matching.
%
%   e.g. Consider the expression: rows(ps.#reward#) > 3
%   When evaluated, this expression will be treated as:
%   rows(ps.fakestate) > 3 where:
%   ps.fakestate == [ps.reward1; ps.reward2; ps.blureward].
%   The order in which the elements are concatenated depends on the order
%   in which they are specified in state_colors.m, poke_colors.m, or
%   wave_colors.m

try
    %GetSoloFunctionArgs instantiates parsed_events_history.
    GetSoloFunctionArgs(obj);
    parsed_events_history = value(parsed_events_history);
    parsed_events_history = [parsed_events_history(:); parsed_events];
    
    
    if isfield(parsed_events_history{trialnum}, 'states')
        ps = parsed_events_history{trialnum}.states;
        statenames = setdiff(fieldnames(ps), {'starting_state', 'ending_state'});
    end
    if isfield(parsed_events_history{trialnum}, 'pokes')
        pk = parsed_events_history{trialnum}.pokes;
        pokenames = setdiff(fieldnames(pk), {'starting_state', 'ending_state'});
    end
    if isfield(parsed_events_history{trialnum}, 'waves')
        pw = parsed_events_history{trialnum}.waves;
        wavenames = setdiff(fieldnames(pw), {'starting_state', 'ending_state'});
    end
    if isfield(parsed_events_history{trialnum}, 'spikes')
        pspk = parsed_events_history{trialnum}.spikes;
    end
    pd = PROTOCOL_DATA; clear('PROTOCOL_DATA');
    
    if isfield(parsed_events_history{trialnum}, 'states')
        %Step 1: Prepare state fields
        %Getting positions of 'ps.' and
        %'parsed_events_history(trialnum).states.'
        pos = strfind(str, 'ps.');
        for ctr = 1:length(pos)
            %endindex is the first occurrence of a character after str(pos(ctr)+3)
            %which is not an alphanumeric character and is not an underscore and is
            %not the # symbol
            endindex = pos(ctr)+3;
            while endindex <= length(str) && (strcmp(str(endindex), '#') || strcmp(str(endindex), '_') || isalnum(str(endindex)))
                endindex = endindex + 1;
            end
            endindex = endindex - 1;
            statename_with_wildcards = str(pos(ctr)+3:endindex);
            
            statenames_match = statenames(wildcardmatch(statename_with_wildcards, statenames));
            
            new_fakestate = randstring;
            new_fakestateval = zeros(0, 2);
            for ctr2 = 1:length(statenames_match)
                if ~isempty(ps.(statenames_match{ctr2}))
                    new_fakestateval = [new_fakestateval; ps.(statenames_match{ctr2})];
                end
            end
            ps.(new_fakestate) = new_fakestateval;
            
            str = regexprep(str, str(pos(ctr):endindex), ['ps.' new_fakestate], 'once');
            %Very subtle bug discovered. The above step can change the indices.
            %Hence, this step to refresh the indices.
            pos = strfind(str, 'ps.');
        end
    end
    
    
    %Similarly for pokes
    if isfield(parsed_events_history{trialnum}, 'pokes')
        %Step 1: Prepare poke fields
        %Getting positions of 'pk.' and 'parsed_events_history(trialnum).pokes.'
        pos = strfind(str, 'pk.');
        for ctr = 1:length(pos)
            %endindex is the first occurrence of a character after str(pos(ctr)+3)
            %which is not an alphanumeric character and is not an underscore and is
            %not the # symbol
            endindex = pos(ctr)+3;
            while endindex <= length(str) && (strcmp(str(endindex), '#') || strcmp(str(endindex), '_') || isalnum(str(endindex)))
                endindex = endindex + 1;
            end
            endindex = endindex - 1;
            pokename_with_wildcards = str(pos(ctr)+3:endindex);
            
            pokenames_match = pokenames(wildcardmatch(pokename_with_wildcards, pokenames));
            
            new_fakepoke = randstring;
            new_fakepokeval = zeros(0, 2);
            for ctr2 = 1:length(pokenames_match)
                if ~isempty(pk.(pokenames_match{ctr2}))
                    new_fakepokeval = [new_fakepokeval; pk.(pokenames_match{ctr2})];
                end
            end
            pk.(new_fakepoke) = new_fakepokeval;
            
            str = regexprep(str, str(pos(ctr):endindex), ['pk.' new_fakepoke], 'once');
            pos = strfind(str, 'pk.');
        end
    end
    
    
    %Similarly for waves
    if isfield(parsed_events_history{trialnum}, 'waves')
        %Step 1: Prepare wave fields
        %Getting positions of 'pw.' and 'parsed_events_history(trialnum).waves.'
        pos = strfind(str, 'pw.');
        for ctr = 1:length(pos)
            %endindex is the first occurrence of a character after str(pos(ctr)+3)
            %which is not an alphanumeric character and is not an underscore and is
            %not the # symbol
            endindex = pos(ctr)+3;
            while endindex < length(str) && (strcmp(str(endindex), '#') || strcmp(str(endindex), '_') || isalnum(str(endindex)))
                endindex = endindex + 1;
            end
            endindex = endindex - 1;
            wavename_with_wildcards = str(pos(ctr)+3:endindex);
            
            wavenames_match = wavenames(wildcardmatch(wavename_with_wildcards, wavenames));
            
            new_fakewave = randstring;
            new_fakewaveval = zeros(0, 2);
            for ctr2 = 1:length(wavenames_match)
                if ~isempty(pw.(wavenames_match{ctr2}))
                    new_fakewaveval = [new_fakewaveval; pw.(wavenames_match{ctr2})];
                end
            end
            pw.(new_fakewave) = new_fakewaveval;
            
            str = regexprep(str, str(pos(ctr):endindex), ['pw.' new_fakewave], 'once');
            pos = strfind(str, 'pw.');
        end
    end
    
    
    %Add a semicolon to str, just in case
    str = [str ';'];
    
    %Clearing unnecessary variables to reduce the number of reserved words.
    clear('statenames', 'pokenames', 'wavenames', 'pos');
    
    try
        eval(['this_trial = ' sprintf(str)]);
    catch
        append_str = ['if ~exist(''this_trial'', ''var'') && exist(''ans'', ''var'')\n' ...
            'this_trial = ans;\n' ...
            'elseif ~exist(''this_trial'', ''var'') && ~exist(''ans'', ''var'')\n' ...
            'error(''Could not evaluate this_trial'');\n' ...
            'end'];
        
        str = sprintf([str '\n\n' append_str]);
        eval(str);
    end
    
    if ~isscalar(this_trial)
        error('this_trial must evaluate to a scalar');
    end
    
    out = this_trial;
    
catch
    out = 'ERROR';
end

end


function out = randstring

[dummy, out] = fileparts(tempname);

end

function out = isalnum(character)

ascii_value = int8(character);

if ascii_value >=48 && ascii_value <= 57 || ...
        ascii_value >= 65 && ascii_value <= 90 || ...
        ascii_value >= 97 && ascii_value <= 122
    out = true;
else
    out = false;
end

end