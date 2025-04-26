function lambda = selectridge(X,y,lambdas)
%{
optimize the L2 regularization parameter

ARGUMENT
-`X`: design matrix. Please remember to parametrize the constant term.
-`y`: response
-`lambdas`: range of ridge parameters

OUTPUT
-`lambda`: the best among the ridge parameters
%}
validateattributes(X, {'numeric'}, {})
validateattributes(y, {'numeric'}, {'column'})
validateattributes(lambdas, {'numeric'}, {'vector'})
kfold = 5;
cvp = cvpartition(size(X,1), 'KFold', kfold);
MSE = zeros(numel(lambdas),1);
I = eye(size(X,2));
for k = 1:kfold
    trainingindices = training(cvp,k);
    testindices = test(cvp,k);
    Xtrain = X(trainingindices,:);
    ytrain = y(trainingindices);
    Xtest = X(testindices,:);
    ytest = y(testindices);
    Xt = Xtrain';
    XtX = Xt*Xtrain;
    for i = 1:numel(lambdas)
        what = (XtX + lambdas(i)*I) \ (Xt * ytrain);
        yhat = Xtest*what;
        MSE(i) = MSE(i) + mean((ytest - yhat).^2)/kfold;
    end
end
[~, index] = min(MSE);
if index == 1 || index == length(lambdas)
    error('range is too limited')
end
lambda = lambdas(index);