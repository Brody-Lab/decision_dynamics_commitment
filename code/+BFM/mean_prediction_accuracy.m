function [pointestimate, ci] = mean_prediction_accuracy(Y,Yhat)
% return an index of how well the mean is predicted and the index's confidence interval
%
% ARGUMENT
%
% 'Y': an N-by-T matrix, where N is the number of samples, and T the number of time steps
%
% 'Yhat': predictions
assert(all(size(Y)==size(Yhat)))
Ymean = mean(Y,2);
Ymeanhat = mean(Yhat,2);
u = datasample(Ymean, 1e3);
v = datasample(Ymeanhat, 1e3);
z = (abs(u) - abs(u-v))./abs(u);
pointestimate = (abs(mean(Ymean)) - abs(mean(Ymean)-mean(Ymeanhat)))/abs(mean(Ymean));
z(z <0) = 0;
ci = quantile(z, [0.025, 0.975]);