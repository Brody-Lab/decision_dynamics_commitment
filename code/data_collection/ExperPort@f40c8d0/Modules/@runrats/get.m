function y=get(obj, varargin)

if nargin==1
    fn=fieldnames(obj);
    for xi=1:numel(fn)
        fv{xi}=obj.(fn{xi});
    end

    y=cell2struct(fv', fn);

elseif nargin>1
    for xi=2:nargin
        y{xi-1}=obj.(varargin{xi-1});
    end
end
