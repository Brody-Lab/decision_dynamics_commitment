function SSE = sse_lbfm(spiketrains, Phi, w)
% sum of squared error for a linear model with basis functions
    SSE = 0;
    yhat = Phi*w;
    for i = 1:numel(spiketrains)
        T = numel(spiketrains{i});
        SSE = SSE + sum((spiketrains{i} - yhat(1:T)).^2);
    end
end