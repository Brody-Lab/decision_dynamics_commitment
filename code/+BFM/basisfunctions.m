function Phi = basisfunctions(D,N, varargin)
% Radial basis function
%
%=INPUT
%
% 	D
%       Number of basis functions
%
%   N
%       Number of bins
%
%=OPTIONAL INPUT
%
%   compression
%       Positive scalar indicating the degree of compressioning. Larger values
%       indicates more compressioning 
%	
%   begins_at_0
%       Logical scalar indicating whether at the first element, the first
%       cosine is equal to zero or to its maximum value
%
%   ends_at_0
%       Logical scalar indicating whether at the last element, the last
%       cosine is equal to zero or to its maximum value
%
%   zeroindex
%       the bin corresponding to the zero
parser = inputParser;
addParameter(parser, 'compression', NaN,  ...
             @(x) validateattributes(x, {'numeric'}, {'scalar'}))
addParameter(parser, 'begins_at_0', false,  ...
             @(x) validateattributes(x, {'logical'}, {'scalar'}))
addParameter(parser, 'ends_at_0', false,  ...
             @(x) validateattributes(x, {'logical'}, {'scalar'}))
addParameter(parser, 'overlap', true,  ...
             @(x) validateattributes(x, {'logical'}, {'scalar'}))
addParameter(parser, 'orthogonal_to_constant', false,  ...
             @(x) validateattributes(x, {'logical'}, {'scalar'}))
addParameter(parser, 'unitary', false,  ...
             @(x) validateattributes(x, {'logical'}, {'scalar'}))
addParameter(parser, 'zeroindex', 1,  ...
             @(x) validateattributes(x, {'numeric'}, {'scalar', 'integer'}))
addParameter(parser, 'amplify_first_last', true,  ...
             @(x) validateattributes(x, {'logical'}, {'scalar'}))
parse(parser, varargin{:});
P = parser.Results; 
binindinces = (1:N) - P.zeroindex;
if P.compression > 0
    y = asinh(binindinces*P.compression);
else
    y = binindinces;
end
yrange = y(end)-y(1);
if P.begins_at_0 && P.ends_at_0
    Delta_centers = yrange / (D+3);
    centers = y(1)+2*Delta_centers:Delta_centers:y(end)-2*Delta_centers;
elseif P.begins_at_0 && ~P.ends_at_0
    Delta_centers = yrange / (D+1);
    centers = y(1)+2*Delta_centers:Delta_centers:y(end);
elseif ~P.begins_at_0 && P.ends_at_0
    Delta_centers = yrange / (D+1);
    centers = y(1):Delta_centers:y(end)-2*Delta_centers;
else
    Delta_centers = yrange / (D-1);
    centers = y(1):Delta_centers:y(end);
end
Phi = BFM.raisedcosines(centers, Delta_centers, y);
if P.amplify_first_last && ~P.begins_at_0 && ~P.ends_at_0
    lefttail = BFM.raisedcosines(centers(1)-Delta_centers, Delta_centers, y);
    righttail = BFM.raisedcosines(centers(end)+Delta_centers, Delta_centers, y);
    Phi(:,1) = Phi(:,1) +  lefttail;
    Phi(:,end) = Phi(:,end) + righttail;
    indices = y <= centers(1) + 2*Delta_centers;
    deviations = 2.0 - sum(Phi,2);
    Phi(indices,1) = Phi(indices,1) + deviations(indices);
end

if P.orthogonal_to_constant
	Phi = (eye(N) - ones(N,N)/N)*Phi;
end
if P.unitary
    [U,S,~] = svd(Phi);
    s = diag(S);
    indices = s/max(s) > 0.01;
    Phi = U(:, indices);
end