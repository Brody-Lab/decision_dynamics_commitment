function [] = define_function(obj, varargin);

GetSoloFunctionArgs;

% Both *_arg_pairs arrays are v-by-2 cell arrays where each row has the
% (name, value) of avar to be assigned for the function
% ro_arg_pairs: will have variables assigned as read-only during the
% following SoloFunction definition;
% rw_arg_pairs: will have variables assigned as read-write during the
% SoloFunction definition

pairs = { ...
    'function_name'		, ''	;	...
    'ro_args'   		, {}	;	...
    'rw_args'       	, {}	;	...
    };
parse_knownargs(varargin, pairs);

% make the ro_args
for currvar = 1:length(ro_args)        % assign in workspace for SF check
    val = evalin('caller', ro_args{currvar});
    eval([ro_args{currvar} ' = val;']);
end;

% now_make the rw_args
for currvar = 1:size(rw_args,1)
    val = evalin('caller', rw_args{currvar});
    eval([rw_args{currvar} ' = val;']);
end;
rw_args{1, length(rw_args)+1} = 'mychild';

available_functions = {'SidesSection', 'TimesSection', 'VpdsSection', 'ChordSection'};

if isempty(function_name)
    error('Need a function name to define one!');
elseif ~ismember(function_name, available_functions)
    error('Sorry, can only register functions available in protocol class');
end;

% and then, declare the function ... easy as pie!
SoloFunction(function_name, 'ro_args', ro_args, 'rw_args', rw_args);

