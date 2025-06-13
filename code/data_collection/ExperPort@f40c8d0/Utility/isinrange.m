function is = isinrange(data,bins,varargin)
    j=1;
    circular=false;
    if numel(bins)~=2
        error('Second input must be a two element vector specifying a range.');
    end
    while j<=length(varargin)
        if strncmpi(varargin{j},'period',6)
            j=j+1;
            period=varargin{j};
            circular=true;
        end
        j=j+1;
    end
    if ~circular
        is = data>=bins(1) & data<bins(2); % interval is like ( bin(1) bin(2)]
    else
        data=mod(data,period);
        bins=mod(bins,period);
        factor = period/(2*pi);
        is = circ_dist(data/factor,bins(1)/factor)>0 & circ_dist(data/factor,bins(2)/factor)<=0 ;
    end
end