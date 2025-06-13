function [yhat] = logistic_setbound(beta,x,varargin)
% Logistic function constrained to the endpoints
% L (lower bound) and H (upper bound).
% see logistic_equations.m for discussion of how each of the 4 parameters
% changes the shape of the curve

pairs = { ...
    'constrain_bounds', 0 ; ... % if true, uses logistic function where low and high values
    'binrange_mp', NaN ; ...
    'usefunction', 'general_logistic' ; ... % options: [general_logistic | 4paramsigmoid]
    % are retrieved from rat data and the
    % curve is forced to obey the constraints
    };
parse_knownargs(varargin,pairs);

if constrain_bounds > 0
    m = beta(1);
    tau = beta(2);

    [L H] = logistic_fitter('get_lims');
    if L == 0, L = 0.001; end;
    K =H/L;

    x= x-(logistic_fitter('get_bin_midpoint'));

    exp_term = exp(-x / tau);
    num =1 + (m * exp_term);
    den =1 + (K* m * exp_term);

    yhat = ( H*(num ./ den) );

    %    nanidx = find(isnan(yhat) > 0);
    yhat(isnan(yhat)) = 10000; % big number.
    nanidx = find(~isfinite(yhat) > 0);
    yhat(nanidx) = 10000;
else
    switch usefunction
        case 'general_logistic'
            a = beta(1);
            m = beta(2);
            n = beta(3);
            tau = beta(4);

            if isnan(binrange_mp)
                binrange_mp = logistic_fitter('get_bin_midpoint');
            end;

            x= x-binrange_mp;

            exp_term = exp(-x / tau);
            num =1 + (m * exp_term);
            den =1 + (n * exp_term);

            yhat = ( a *(num ./ den) );

            nanidx = find(isnan(yhat) > 0);
            yhat(nanidx) = 10000; % big number.
            nanidx = find(~isfinite(yhat) > 0);
            yhat(nanidx) = 10000;

        case '4paramsigmoid'

        otherwise
            error('unknown fit function. please write a case statement for it');
    end;

end;