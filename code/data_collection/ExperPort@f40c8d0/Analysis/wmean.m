function y = wmean(x,w,dim)
    % weighted mean
    % by default, operates along the first non-scalar dimension.
    % NaN weights are treated like zeros
    % no singleton expansion. should add that.
    sz=size(x);
    if any(size(w)~=sz)
        error('wMean:sizeMismatch','x and w must be the same size');
    end      
    if any(isinf(w))
        error('Weights cannot be Inf.');
    end
    w(isnan(x))=NaN;
    w(w==0)=NaN;
    if nargin<3
        if max(sz)==1
            dim=1;
        else
            ndims=length(sz);
            for j=1:ndims
                if sz(j)>1
                    dim=j;
                    break
                end
            end
        end
    end           
    xw = x.*w;
    wsum = nansum(xw,dim);
    y = wsum ./ nansum(w,dim);
end
