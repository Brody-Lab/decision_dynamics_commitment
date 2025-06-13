function [] = rxntime_bias_corr(rat, task, rxn, bias, varargin)
  
  % This script correlates the difference in mean reaction time for LHS
  % and RHS trials, to the session-wide bias.
  % The goal is to determine whether a bias contributes to the reaction
  % time; for example, one expects that a response due to bias would have
  % a shorter reaction than one where the rule is used to arrive at an
  % answer.
    
  pairs = {'from', '00000'; ...
           'to', '9999999'; ...
           };
  parse_knownargs(varargin, pairs);
  
% $$$   [rxn, bias] = rxn_time_by_side(rat, task, 'from', from, 'to', to,'no_plot', ...
% $$$                                  1);
  
  mr = mean(rxn); mb = mean(bias);
 
  covar = ((rxn - mr) * (bias-mb)')/(length(rxn)-1);
  corr = covar / sqrt(var(rxn) * var(bias));
  
  other = cov(rxn, bias);
  othercor= corrcoef(rxn, bias);
  
  fprintf(1, 'Covariance = %e\nCorrelation = %1.2f\n', covar, corr);
  fprintf(1, 'Matlab says %e\n, CorrCoef = %1.2f\n',other(1,2), othercor(1,2));
  
  
    