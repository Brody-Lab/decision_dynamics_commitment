function y = softplus(x)
    % Smooth approximation of the rectifier
    %
    %=ARGUMENT
    %
    %   x
    %       A scalar or array of double-precision floating-point numbers
    %
    %=RETURN
    %
    %   y
    %       rectified values of `x`
    validateattributes(x, {'double'}, {})
    t = softplusthresholds();
    y = x;
    indices = x < t(1);
    if sum(indices) > 0
        y(indices) = 0;
    end
    indices = x >= t(1) & x < t(2);
    if sum(indices) > 0
        y(indices) = exp(x(indices));
    end
    indices = x >= t(2) & x < t(3);
    if sum(indices) > 0
        y(indices) = log1p(exp(x(indices)));
    end
    indices = x >= t(3) & x < t(4);
    if sum(indices) > 0
        y(indices) = x(indices) + exp(-x(indices));
    end
end
function x = softplusthresholds()
    % Return thresholds for computing the softplus function for double-precision floating point numbers
    %
    % based on `https://github.com/JuliaStats/LogExpFunctions.jl/blob/master/src/basicfuns.jl`
    %
    % RETURN
    %
    %   x
    %       A four-element array
    logtwo = log(2);
    prec = 53;
    x = zeros(4,1);
    x(1) = -1075 * logtwo;
    x(2) = -prec * logtwo;
    x(3) = (prec - 1) * logtwo / 2;
    x(4) = -x(2) - log(-x(2)) * (1 + 1 / x(2));
end