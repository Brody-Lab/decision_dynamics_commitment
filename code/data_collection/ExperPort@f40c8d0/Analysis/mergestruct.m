function T = mergestruct(varargin)

% first args should all be scalar structures with (for now) scalar elements
% or string

% optional args at end

% intersect = true means only includes common fields in output

% output can be a struct Array or a scalar array with vector fields

%% parse and validate inputs
p=inputParser;
p.addParamValue('fill',[],@isscalar);
p.addParamValue('intersect',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
p.addParamValue('output','structArray',@(x)validateattributes(x,{'char'},{'nonempty'}));
for i=1:length(varargin)
    if isstruct(varargin{i}) && isscalar(varargin{i})
        structs{i} = varargin{i};        
    elseif ischar(varargin{i})
        optionalArgs=varargin(i:end);
        if any(cellfun(@isstruct,optionalArgs))
            error('Cannot parse this sequence of args. Inputs must consist of a series of scalar structs followed by option-argument pairs.');
        end
        break
    else
        error('Cannot parse this sequence of args. Inputs must consist of a series of scalar structs followed by option-argument pairs.');
    end
end
p.parse(optionalArgs{:});
params=p.Results;
validatestring(params.output,{'structArray','scalarStruct'},'mergeStruct','output');
%% gather field names
fields={};
for i=1:length(structs)
    if params.intersect
        fields = intersect(fields,fieldnames(structs{i}));
    else
        fields = union(fields,fieldnames(structs{i}));
    end
end
%% merge structs
isScalarStruct = strcmp(params.output,'scalarStruct');
for i=length(structs):-1:1        
    for f=1:length(fields)
        if isfield(structs{i},fields{f})
            val=structs{i}.(fields{f});        
            if ~ischar(val) && numel(val)>1 && isScalarStruct
                error('Currently, fields require scalar values if you want to make a scalar struct with vector valued fields.');
            end
        else % this field ain't a field of the current struct
            if isScalarStruct && isfield(T.(fields{f})) && class(T.(fields{f})) ~= class(params.fill)
                warning('Type conversion required for filling in missing values and scalar structure output selected. Make sure you know what you are doing.');
            end
            if params.intersect
                error('With intersect on, you shouldn''t ever need to be filling in. Why are you at this line?');
            end
            val=params.fill;
        end
        if isScalarStruct
            if ischar(val)
                T.(fields{f}){i}=val;
            else
                T.(fields{f})(i)=val;                
            end
        else
            T(i).(fields{f})=val;
        end
    end
end

        
%% below is an olrder, much worse version of this function %%

% 
% 
% 
% function T = mergestruct(varargin)
%     % concatenates structures which might not have matching fields
%     % default is to make each input one element in a structured array, with
%     % fields not contained by all getting filled in as empties
%     % 'intersect' = true removes fields that are not shared by all   
%     f=1;
%     intersect=false;
%     T=[];
%     dummyFieldName='aslfgkasnglaks';
%     count=0;
%     fill=[];
%     while f<=length(varargin)
%         if ischar(varargin{f})
%             if strcmp(varargin{f},'intersect')
%                 validateattributes(varargin{f+1},{'logical'},{'scalar'},'','intersect');
%                 intersect=varargin{f+1};
%                 f=f+2;
%             elseif strcmp(varargin{f},'fill')
%                 fill=varargin{f+1};
%                 f=f+2;
%             end
%         end
%         count=count+1;
%         validateattributes(varargin{f},{'struct','numeric'},{},'','',f);
%         if isnumeric(varargin{f})
%             if ~isempty(varargin{f})
%                 error('Inputs must be structured arrays or empty.');
%             else
%                 varargin{f}=struct(dummyFieldName,[]);
%             end
%         end
%         if ~isscalar(varargin{f}) && ~isvector(varargin{f}) && ~isempty(varargin{f})
%             error('Input %g has more than one non-singleton dimension',f);
%         elseif isempty(varargin{f})
%             varargin{f}=struct(dummyFieldName,[]);            
%         end
%         fields{count}=fieldnames(varargin{f});
%         if ~isempty(varargin{f})       
%             [varargin{f}.(dummyFieldName)]=deal([]);            
%             if count==1
%                 T=varargin{f};
%                 f=f+1;
%                 continue
%             end
%             inds=(numel(T)+1):(numel(T)+numel(varargin{f}));
%             for ff=1:length(fields{count})
%                 [T(inds).(fields{count}{ff})] = varargin{f}.(fields{count}{ff}) ;
%             end
%         else
%             inds=numel(T)+1;
%             for ff=1:length(fields{count})
%                 T(inds).(fields{count}) = fill ;
%             end
%         end
%         f=f+1;
%     end
%     if intersect
%         T = rmfield(T,setxor(fields{:}));
%     end
%     T=rmfield(T,dummyFieldName);
% end