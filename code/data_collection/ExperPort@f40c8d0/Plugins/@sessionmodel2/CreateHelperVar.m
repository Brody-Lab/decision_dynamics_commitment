function CreateHelperVar(obj, varname, varargin)
%CREATEHELPERVAR Function to create helper vars
%   This function is used to create helper vars, (normally in the helper
%   vars section of the training stage file).
%
%   Syntax: CreateHelperVar(obj, varname, varargin)
%
%   'value', varval: Sets the helper var to varval if the helper var does
%   not already exist. If this option is not specified, varval defaults to
%   the empty matrix.
%
%   'force_init', true: Forces the helper var to be set to the specified
%   value. If this option is not specified, 'force_init' is assumed to be
%   false.
%
%   Author: Sundeep Tuteja
%           sundeeptuteja@gmail.com

if nargin<2
    error('Invalid number of arguments. The number of arguments has to be greater than or equal to 2.');
elseif ~isvarname(varname)
    error('varname has to be a valid MATLAB variable name');
end

pairs = {'force_init', false;
    'value', []};
parseargs(varargin, pairs);
varval = value; clear('value');

try
    force_init = logical(force_init); %#ok<NODEF>
catch %#ok<CTCH>
    error('The value for the force_init flag has to be a logical, or should be convertible to a logical');
end

assert(isvarname(varname) && islogical(force_init));

GetSoloFunctionArgs(obj);

%%
%If the stage name of the helper var is the same as that of the current
%active stage, ignore the force_init flag
if exist(varname, 'var') && isa(eval(varname), 'SoloParamHandle')
    active_stage = SessionDefinition(obj, 'get_active_stage_details');
    previous_active_stage = SessionDefinition(obj, 'get_previous_active_stage_details');
    if strcmp(active_stage.name, previous_active_stage.name) && isequal(active_stage.number, previous_active_stage.number)
        force_init = false;
    end
end
%%


if ~exist(varname, 'var') || ~isa(eval(varname), 'SoloParamHandle')
    %A new helper var is being created
    SoloParamHandle(obj, varname, 'value', []);
    set_saveable(eval(varname), true);
    set_save_with_settings(eval(varname), true);
    set_userprop(eval(varname), 'save_to_helper_vars_table', 1);
    active_stage = SessionDefinition(obj, 'get_active_stage_details');
    set_userprop(eval(varname), 'stage_name', active_stage.name);
    set_userprop(eval(varname), 'initial_value', varval);
    
    for ctr = 1:n_done_trials-1
        push_history(eval(varname));
    end
    eval([varname '.value = varval;']);
    push_history(eval(varname));
    
    %if varname not present in GLOBAL_HELPER_VAR_NAME_LIST...
    varname_cellarray = cell(length(GLOBAL_HELPER_VAR_NAME_LIST), 1); %#ok<NODEF>
    for ctr = 1:length(GLOBAL_HELPER_VAR_NAME_LIST)
        varname_cellarray{ctr} = GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name;
    end
    if ~ismember(varname, varname_cellarray)
        GLOBAL_HELPER_VAR_NAME_LIST(end+1).var_name = varname;
        GLOBAL_HELPER_VAR_NAME_LIST(end).stage_name = active_stage.name;
        GLOBAL_HELPER_VAR_NAME_LIST(end).initial_value = varval; %#ok<NASGU>
    end
    
    stagefilename = SessionDefinition(obj, 'get_training_stages_file_name');
    DeclareGlobals(obj, 'ro_args', {varname});
    SoloFunctionAddVars(obj, stagefilename, 'rw_args', varname);
    SoloFunctionAddVars(obj, 'SessionDefinition', 'rw_args', varname);
    assignin('caller', varname, eval(varname));
    
elseif exist(varname, 'var') && isa(eval(varname), 'SoloParamHandle') && force_init
    
    eval([varname '.value = varval;']);
    active_stage = SessionDefinition(obj, 'get_active_stage_details');
    set_userprop(eval(varname), 'initial_value', varval);
    set_userprop(eval(varname), 'stage_name', active_stage.name);
    %Reassign helper var ownership
    for ctr = 1:length(GLOBAL_HELPER_VAR_NAME_LIST) %#ok<NODEF>
        if strcmp(GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name, varname)
            GLOBAL_HELPER_VAR_NAME_LIST(ctr).stage_name = active_stage.name; %#ok<AGROW>
            GLOBAL_HELPER_VAR_NAME_LIST(ctr).initial_value = varval; %#ok<AGROW,NASGU>
            break;
        end
    end
    assignin('caller', varname, eval(varname));
    
elseif exist(varname, 'var') && isa(eval(varname), 'SoloParamHandle') && ~force_init
    
    %Simply give the active training stage ownership of the helper var, and
    %use assignin, but don't touch the value
    active_stage = SessionDefinition(obj, 'get_active_stage_details');
    set_userprop(eval(varname), 'stage_name', active_stage.name);
    for ctr = 1:length(GLOBAL_HELPER_VAR_NAME_LIST) %#ok<NODEF>
        if strcmp(GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name, varname)
            GLOBAL_HELPER_VAR_NAME_LIST(ctr).stage_name = active_stage.name; %#ok<AGROW,NASGU>
            break;
        end
    end
    assignin('caller', varname, eval(varname));

end

end