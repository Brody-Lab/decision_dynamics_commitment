function Opt = maximizeevidence(X,y, varargin)
%{
Simplest possible evidence optimization scheme for linear-Gaussian regression

The prior on the weights is assumed to be a Gaussian with isotropic covariance

ARGUMENT
-`X`: design matrix
-`y`: response

RETURN
-`Opt`: a structure indicating the optimization trace

OPTIONAL ARGUMENT
-`a0`: initial values of the precision parameters
-`maxiterations`: maximum number of iterations
-`mu_tol`: minimum difference in the norm of $mu$ between iterations before stopping
%}
validateattributes(X, {'numeric'}, {})
validateattributes(y, {'numeric'}, {'column'})
parser = inputParser;
addParameter(parser, 'a0', 1e-2, @(x) isscalar(x) && isnumeric(x))
addParameter(parser, 'maxiterations', 100, @(x) isscalar(x) && isnumeric(x) && issinteger(x))
addParameter(parser, 'mu_tol', 1e-4, @(x) isscalar(x) && isnumeric(x))
parse(parser, varargin{:});
P = parser.Results; 
[T, D] = size(X);
assert(T==numel(y))
a = P.a0; % precision parameter
A = a*eye(D); % precision matrix
Xt = X';
XtX = X'*X;
mu = (XtX + A) \ (Xt*y);
delta = X*mu - y;
% sigma2 = (delta'*delta - mu'*A*mu)/T; % MAP estimate
sigma2 = (delta'*delta)/T; % MLE estimate
Sigma_inv = XtX/sigma2 + A; % inverse of estimate of covariance of the posterior on $w$
mu = Sigma_inv \ (Xt/sigma2*y); % MAP estimate
T = size(X,1);
Opt = struct;
Opt(1).mu = mu;
Opt(1).a = a;
Opt(1).sigma2 = sigma2;
Opt(1).Sigma = inv(Sigma_inv);
for i = 2:P.maxiterations
    a = Opt(i-1).a;
    mu = Opt(i-1).mu;
    sigma2 = Opt(i-1).sigma2;
    Sigma = inv(XtX/sigma2 + a*eye(D));
    S = trace(Sigma);
    M = mu'*mu;
    a = (D - a*S)/M; % fixed point iteration
    delta = X*mu - y;
    sigma2 = (delta'*delta) / (T - D + S*a);
    Sigma_inv = XtX/sigma2 + a*eye(D);
    Opt(i).mu = Sigma_inv \ (Xt/sigma2*y);
    Opt(i).a = a;
    Opt(i).sigma2 = sigma2;
    Opt(i).Sigma = Sigma;
    if norm(Opt(i).mu-Opt(i-1).mu) < P.mu_tol
        return
    end
end