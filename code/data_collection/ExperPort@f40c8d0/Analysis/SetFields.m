function to = SetFields(to,varargin)
    % sets the fields in A to their values in struct B, and adds new fields
    % when necessary.  Also accepts unlimited fieldname, fieldvalue pairs.
    
    % example: A = setFields(A,B) where A and B are structures.
    
    % example 2: A = setFields(A,'myfieldname',myfieldval);
    
    % Adrian Bondy, 2015
    p=inputParser;
    p.KeepUnmatched=true;
    p.addOptional('from',struct(),@(x)validateattributes(x,{'struct'},{}));
    p.parse(varargin{:});
    from=p.Results.from;
    fields=fieldnames(from);
    if ~isempty(fields)
        for f=1:length(fields)
            to.(fields{f})=from.(fields{f});
        end
    end
    if nargin>3
        if ismember('from',p.UsingDefaults)
            k=1;
        else
            k=2;
        end
        for i=k:2:length(varargin)
            fieldname=varargin{i};
            if i==length(varargin)
                error('Non-matching parameter-value pairs.');
            end
            fieldval=varargin{i+1};
            to.(fieldname)=fieldval;
        end
    end
end