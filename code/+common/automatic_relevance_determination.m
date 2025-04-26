function Opt = automatic_relevance_determination(X,y, varargin)
%{
Evidence optimization scheme for linear-Gaussian regression

The prior on the weights is assumed to be a Gaussian with diagonal covariance

ARGUMENT
-`X`: design matrix
-`y`: response

RETURN
-`Opt`: a structure indicating the optimization trace

OPTIONAL ARGUMENT
-`a0`: initial values of the precision parameters
-`maxiterations`: maximum number of iterations
-`minumu`: minimumal absolute value of the $\mu$
-`mu_tol`: minimum difference in the norm of $mu$ between iterations before stopping
%}
[T, D] = size(X);
assert(T==numel(y))
validateattributes(X, {'numeric'}, {})
validateattributes(y, {'numeric'}, {'column'})
parser = inputParser;
addParameter(parser, 'a0', 1e-2*ones(D,1), @(x) isscalar(x) && isnumeric(x))
addParameter(parser, 'maxiterations', 100, @(x) isscalar(x) && isnumeric(x) && issinteger(x))
addParameter(parser, 'minmu', 1e-8, @(x) isscalar(x) && isnumeric(x))
addParameter(parser, 'mu_tol', 1e-4, @(x) isscalar(x) && isnumeric(x))
parse(parser, varargin{:});
P = parser.Results; 
a = P.a0; 
A = diag(a);
Xt = X';
XtX = X'*X;
mu = (XtX + A) \ (Xt*y);
delta = X*mu - y;
sigma2 = (delta'*delta - mu'*A*mu)/T;
Sigma_inv = XtX/sigma2 + A;
mu = Sigma_inv \ (Xt/sigma2*y);
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
    Sigma = inv(XtX/sigma2 + diag(a));
    a = (1 - a.* diag(Sigma))./mu.^2; % fixed point iteration
    delta = X*mu - y;
    sigma2 = (delta'*delta) / (T - D + diag(Sigma)'*a);
    Sigma_inv = XtX/sigma2 + diag(a);
    mu = Sigma_inv \ (Xt/sigma2*y);
    almost0 = abs(mu)<P.minmu;
    mu(almost0) = sign(mu(almost0))*1e-8;
    Opt(i).mu = mu;
    Opt(i).a = a;
    Opt(i).sigma2 = sigma2;
    Opt(i).Sigma = Sigma;
    if norm(Opt(i).mu-Opt(i-1).mu) < P.mu_tol
        return
    end
end