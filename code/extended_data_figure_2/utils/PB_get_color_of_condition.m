%=OPTIONAL NAME-VALUE PAIRS
%
%   coloration
%       a CHAR array specifying which parameter is the basis of P.coloration.
%       The possible values are {'side', 'choice', 'poke', 'LR'}.
function the_color = PB_get_color_of_condition(Conditions,i, varargin)
    input_parser = inputParser;
    addParameter(input_parser, 'coloration', '', @(x) ischar(x) || isnumeric(x))
    parse(input_parser, varargin{:});
    P = input_parser.Results;
    kColor = PB_get_constant('Color');
    if strcmp(P.coloration, 'opsin')
        opsin_color = get_color_of_opsin(Conditions.rat);
    end
    if Conditions.parameters.pharma_manip{i} ~= string('none') % back-compatibility
        the_color = kColor.(Conditions.parameters.pharma_manip{i});
    elseif ~ismissing(Conditions.parameters.stim_per(i)) &&...
           isempty(Conditions.parameters.stim_per{i})
        the_color = 'k';
    else
        the_color = [];
        if strcmp(P.coloration, 'opsin')
            the_color = opsin_color;
        elseif ~ismissing(Conditions.parameters.stim_per(i)) &&...
                isfield(kColor, Conditions.parameters.stim_per{i})
            the_color = kColor.(Conditions.parameters.stim_per{i});
        end            
        if isempty(the_color)
            the_color = kColor.opto(i,:);
        end
    end
    if any(strcmp(P.coloration, {'side', 'choice', 'poke', 'LR'}))
        if isempty(Conditions.parameters.laterality{i})
            the_color = 'k';
        else
            the_color = kColor.(Conditions.parameters.laterality{i});
        end
    end        
end

function the_color = get_color_of_opsin(rat_name)
    the_color = [];
    Log = PB_import_implant_log;
    kColor = PB_get_constant('Color');
    idx = ismember(Log.rat, rat_name) & Log.implant_type == string('fiber');
    virus_injected = unique(Log.virus_injected(idx));
    if numel(virus_injected) == 1
        if contains(virus_injected, 'eNpHR')
            the_color = kColor.halorhodopsin;
        elseif contains(virus_injected, 'ChR2')
            the_color = kColor.channelrhodopsin;
        end
    end
end