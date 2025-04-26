function lambda = gamma2lambda(gamma)
% convert the log ratio of two values to the difference between the values
    lambda = (exp(gamma)-exp(-gamma))./(2+exp(gamma)+exp(-gamma));
end