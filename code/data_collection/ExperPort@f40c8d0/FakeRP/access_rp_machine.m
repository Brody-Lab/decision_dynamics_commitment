function [out, updated_machine] = access_rp_machine(rp_machine, command, moreargs)
%
% THIS IS AN OBSOLETE FUNCTION -- IGNORE
%
% As called by the invokeWrapper, extra args will come in this form:
if nargin > 2, varargin = moreargs; else varargin = {}; end;

switch command,
    case 'GetTagVal',
        if length(varargin)<1, error('Need a string Tag'); end;
        tag = lower(varargin{1}); check_tagname_exists(rp_machine, tag);
        out = rp_machine.(tag); updated_machine = rp_machine;
        return;
        
    case 'SetTagVal',
        if length(varargin)<2, error('Need a string Tag and need a Tag Value to set'); end;
        tag = lower(varargin{1});  check_tagname_exists(rp_machine, tag); 
        rp_machine.(tag) = varargin{2}; out=1; updated_machine = rp_machine;
        return;
        
    case 'WriteTagV',
        if length(varargin)<3, error('WriteTagV: need tagname, offset, datavector'); end;
        tag = lower(varargin{1}); check_tagname_exists(rp_machine, tag);
        offset = varargin{2}; datavec = varargin{3};
        rp_machine.(tag) = datavec(1+offset:end); out=1; updated_machine = rp_machine;
        return;
        
    case 'WriteTagVEX',
        if length(varargin)<4, error('WriteTagVEX: need tagname, offset, datatype, datavec'); end;
        tag = lower(varargin{1}); check_tagname_exists(rp_machine, tag);
        offset = varargin{2}; datatype = varargin{3}; datavec = varargin{4};
        rp_machine.(tag) = datavec(1+offset:end); out=1; updated_machine = rp_machine;
        return;
        
    case 'ReadTagVEX', 
        if length(varargin)<6, error('Need tag, offset, length, format, format, nchannels'); end;
        tag = lower(varargin{1}); check_tagname_exists(rp_machine, tag);
        offset = varargin{2}; len = varargin{3};
        if ~isnum(offset) | offset<0 | ~isnum(len) | len<0, error('Need offset and length to be positive integers'); end;
        out = rp_machine.(tag); out = out(1+offset : 1+offset+len); updated_machine = rp_machine;
        return;    

    case 'SoftTrg', 
        if length(varargin)<1, error('Need the soft trigger number'); end;
        trigger_number = varargin{1}; 
        if ~isnumeric(trigger_number) | prod(size(trigger_number))~=1, error('Need a single integer soft trigger number'); end;
        if trigger_number<1 | trigger_number > length(rp_machine.soft_triggers) | ...
                ~ismember(exist(rp_machine.soft_triggers(trigger_number)), [2 3]), 
            error(['Trigger ' num2str(trigger_number) ' not registered for this rp_machine']); 
        end;
        updated_machine = feval(rp_machine.soft_triggers(trigger_number), rp_machine);
        return;
        
    case 'Halt', 
        rp_machine.halt = 1; out=1; updated_machine = rp_machine;
        return;
        
    case 'ClearCOF',
        out=1; updated_machine = struct('halt', 0); 
        return;
        
    case 'LoadCOF',
        if length(varargin)<1, error('Need the virtual RP circuit to load'); end;
        fname = varargin{1}; fname = [noextension(fname) '.vrp'];
        if ~exist(fname, 'dir')
        % FIGURE OUT HOW TO ADD THINGS TO A STRUCT
        
    case 'DefStatus',
        out = 0; updated_machine = rp_machine;
        return;
        
    otherwise,
        error(['Virtual rp machine: Don''t know how to handle the command ' command]);
       
    end;
end;




% -------------------
function check_tag_name_exists(rp_machine, tag)

if ~isfield(rp_machine, tag), error(['This machine doesn''t have a ' tag ' Tag']); end;
return;
